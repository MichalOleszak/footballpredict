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
for (file in list.files("R")) {
  source(file.path("R", file))
}

# Settings --------------------------------------------------------------------
scrape_new_data <- TRUE
train_new_models <- TRUE

# Modelling framework ---------------------------------------------------------
main <- function() {
  # Create paths and set output file name
  if (!dir.exists("predictions")) {
    for (path in c(path_data, path_models, path_results)) {
      dir.create(path)
    }
  }
  timestamp <- now() %>% 
    str_sub(1, 20) %>% 
    str_replace_all(" ", "_") %>% 
    str_replace_all(":", "-")
  output_path <- file.path(path_results, paste0("preds_", timestamp, ".xlsx"))
  # Get and prep data
  if (scrape_new_data) {
    games_train <- get_and_prep_data(seasons = historic_seasons)
  } else {
    games_train <- readRDS(file.path(path_data, "games_train.rds"))
  }
  # Train models
  if (train_new_models) {
    # Train base learners
    base_learners <- train_models(games_train, models_to_train)
    # Fit models to traning data and buiid a deep ensemble
    models_fitted <- fit_models(base_learners)
    ensemble_models(models_fitted, base_learners, games_train)
    # Save base learneres and ensemble
    saveRDS(base_learners, file.path(path_models, "base_learners.rds"))
  } else {
    base_learners <- readRDS(file.path(path_models, "base_learners.rds"))
  }
  # Get & predict testing data
  games_upcoming <- get_upcoming_fixtures()
  # Predict with each learner
  base_preds <- lapply(seq(base_learners), function(model_ind) {
    base_learners[[model_ind]] %>% 
      predict(games_upcoming, type = "prob")  %>%
      select(A, D, H) %>% 
      mutate(model = names(base_learners[model_ind]))
  }) %>% bind_rows()
  # TODO Predict with deep ensemble  
  ensemble_preds <- keras_ensemble_predict(games_upcoming, base_preds)
  
  # TODO save pres in a csv at output_path
  
}



