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
predict_future_games <- FALSE
scrape_new_data <- FALSE
train_new_models <- TRUE

prefix <- "calibration_test"
plot_predictions <- FALSE

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
  path_output <- file.path(path_results, 
                           paste0(prefix, "_preds_", timestamp, ".fst"))
  
  # Get and prep data
  if (scrape_new_data) {
    games_train <- get_and_prep_data(seasons = historic_seasons)
  } else {
    games_train <- readRDS(file.path(path_data, "games_train.rds"))
  }
  if (predict_future_games) {
    games_upcoming <- get_upcoming_fixtures()
  } else {
    obs_train <- 1:round(nrow(games_train) * 0.8)
    obs_test <- (tail(obs_train, 1) + 1):nrow(games_train)
    games_upcoming <- games_train %>% 
      .[obs_test, ] %>% 
      select(-result) %>% 
      mutate(home_team = "hteam", away_team = "ateam", date = NA)
    games_train <- games_train %>% 
      .[obs_train, ]
  }
  
  # Train models
  if (train_new_models) {
    # Train & save base learners
    base_learners <- train_models(games_train, models_to_train)
    # Fit models to traning data and buiid a deep ensemble & save
    models_fitted <- fit_models(base_learners)
    keras_ensemble <- ensemble_models(models_fitted, base_learners, games_train)
    keras_ensemble_model <- keras_ensemble[["keras_ensemble_model"]]
    stand_stats <- keras_ensemble[["stand_stats"]]
    # Fit Poisson model
    #poisson_model <- fit_poisson_model()
    #saveRDS(poisson_model, file.path(path_models, "poisson_model.rds"))
  } else {
    base_learners <- readRDS(file.path(path_models, paste0(prefix, "_base_learners.rds")))
    keras_ensemble_model <- load_model_hdf5(
      file.path(path_models, paste0(prefix, "_keras_ensemble_model.h5"))
    )
    stand_stats <- readRDS(file.path(path_models, paste0(prefix, "_stand_stats.rds")))
  }
  
  # Predict with each learner
  base_preds <- lapply(seq(base_learners), function(model_ind) {
    base_learners[[model_ind]] %>% 
      predict(games_upcoming, type = "prob")  %>%
      select(A, D, H) %>% 
      mutate(model = names(base_learners[model_ind]))
  }) %>% bind_rows()
  
  # Predict with deep ensemble& save
  ensemble_preds <- keras_ensemble_predict(games_upcoming, keras_ensemble_model, 
                                           base_preds, stand_stats)
  write_fst(ensemble_preds, path_output)
  
  # Predict with Poisson model
  #poisson_model <- readRDS(file.path(path_models, "poisson_model.rds"))
  #poisson_preds <- predict_poisson(games_upcoming, poisson_model)
  
  # Visualise predictions
  if (plot_predictions) {
    #preds_plot <- plot_predictions(poisson_preds %>% select(-H_goals, -A_goals))
    preds_plot <- plot_predictions(ensemble_preds)
    ggsave(file.path(path_results, paste0(prefix, "plot_", timestamp, ".png")), 
           plot = preds_plot)
  }
}

# Run main modelling framework if script is called from command line
if (!interactive()) {
  main()
}


# TODO
# - optimize ppv in keras
# - remove initial games of each team from data (used to get recent form)
# - add more data (other leagues)
# - add Bayesian multinomial logit
# - add some Poisson modelling based on number of goals scored and lost