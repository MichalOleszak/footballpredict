# Packages & sourcing ---------------------------------------------------------
library(dplyr)
library(caret)
library(caretEnsemble)
for (file in list.files("R")) {
  source(file.path("R", file))
}


# Settings --------------------------------------------------------------------
historic_seasons <- c("0203", "0304", "0405", "0506", "0607", "0708", 
                      "0809", "0910", "1011", "1112", "1213", "1314", 
                      "1415", "1516", "1617", "1718")
models_to_train <- c("rf", "LogitBoost", "xgbDART")
scrape_new_data <- FALSE


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
  models_ensembled <- ensemble_models(models_trained)
}



