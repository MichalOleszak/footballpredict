# Packages & sourcing ---------------------------------------------------------
library(dplyr)
library(caret)
library(caretEnsemble)
library(RCurl)
library(tidyr)
library(lubridate)
library(stringr)
library(pbapply)
library(readr)
library(keras)
library(purrr)
library(fst)
library(ggplot2)
library(scales)
library(viridis)
for (file in list.files("R")) {
  source(file.path("R", file))
}

# Settings --------------------------------------------------------------------
predict_future_games <- TRUE
scrape_new_data <- FALSE
train_new_models <- FALSE

# Modelling framework ---------------------------------------------------------
main <- function() {
  
  # Create paths and set output file name
  if (!dir.exists("predictions")) {
    for (path in c(path_data, path_models, path_results)) {
      dir.create(path)
    }
  }
  timestamp <- now() %>% 
    str_sub(1, 16) %>% 
    str_replace_all(" ", "_") %>% 
    str_replace_all(":", "-")
  path_output <- file.path(path_results, paste0("preds_", timestamp, ".fst"))
  
  # Get and prep data
  if (scrape_new_data) {
    games_train <- get_and_prep_data(seasons = historic_seasons)
  } else {
    games_train <- readRDS(file.path(path_data, "games_train.rds"))
  }
  
  # Train models
  if (train_new_models) {
    # Train & save base learners
    base_learners <- train_models(games_train, models_to_train)
    saveRDS(base_learners, file.path(path_models, "base_learners.rds"))
    # Fit models to traning data and buiid a deep ensemble & save
    models_fitted <- fit_models(base_learners)
    stand_stats <- ensemble_models(models_fitted, base_learners, games_train)
    saveRDS(stand_stats, file.path(path_data, "stand_stats.rds"))
    # Fit Poisson model
    #poisson_model <- fit_poisson_model()
    #saveRDS(poisson_model, file.path(path_models, "poisson_model.rds"))
  }
 
  # Get & predict new data
  if (predict_future_games) {
    games_upcoming <- get_upcoming_fixtures()
  } else {
    games_upcoming <- games_train %>% tail() %>% select(-result) %>% 
      mutate(home_team = letters[1:6], away_team = letters[7:12])
  }
  
  # Predict with each learner
  base_learners <- readRDS(file.path(path_models, "base_learners.rds"))
  base_preds <- lapply(seq(base_learners), function(model_ind) {
    base_learners[[model_ind]] %>% 
      predict(games_upcoming, type = "prob")  %>%
      select(A, D, H) %>% 
      mutate(model = names(base_learners[model_ind]))
  }) %>% bind_rows()
  
  # Predict with deep ensemble& save
  stand_stats <- readRDS(file.path(path_data, "stand_stats.rds"))
  ensemble_preds <- keras_ensemble_predict(games_upcoming, base_preds, stand_stats)
  write_fst(ensemble_preds, path_output)
  
  # Predict with Poisson model
  #poisson_model <- readRDS(file.path(path_models, "poisson_model.rds"))
  #poisson_preds <- predict_poisson(games_upcoming, poisson_model)
  
  # Visualise predictions
  #preds_plot <- plot_predictions(poisson_preds %>% select(-H_goals, -A_goals))
  preds_plot <- plot_predictions(ensemble_preds)
  ggsave(file.path(path_results, paste0("plot_", timestamp, ".png")), plot = preds_plot)
}

# Run main modelling framework if script is called from command line
if (!interactive()) {
  main()
}

# TODO
# 2. Add error messages (e.g. if no upcoming games available)
# 4. Train ensemble with a validation set in ensemble_models.R
# 5. Add regularization, dropout, experiment with layers in build_keras_model.R
# 6. Add early stopping and these kinds of things in build_keras_model.R
# 7. Documentation, README
# 8. Write a script to train on up to last season, predict this season and check the 
#    Mean_Pos_Pred_Value as a function of front-runner's predicted winning probability.

