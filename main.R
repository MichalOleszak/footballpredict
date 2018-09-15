# Packages & sourcing ---------------------------------------------------------
library(dplyr)
library(caret)
library(caretEnsemble)
for (file in list.files("R")) {
  source(file.path("R", file))
}

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



