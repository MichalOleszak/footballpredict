# Packages & sourcing ---------------------------------------------------------
library(dplyr)
library(caret)
library(caretEnsemble)
library(RCurl)
library(tidyr)
for (file in list.files("R")) {
  source(file.path("R", file))
}

# Settings --------------------------------------------------------------------
scrape_new_data <- TRUE

# Modelling framework ---------------------------------------------------------
main <- function() {
  # Get and prep data
  if (scrape_new_data) {
    games_train <- get_and_prep_data(seasons = historic_seasons)
  } else {
    load("data/games_train.RData")
  }
  # Train models
  models_trained <- train_models(games_train, models_to_train)
  # Fit models to traning data and buiid a regression-based ensembles
  # for home wins and away wins
  models_fitted <- fit_models(models_trained)
  models_ensembled <- ensemble_models(models_trained)

}



