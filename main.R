# Packages & sourcing ---------------------------------------------------------
library(dplyr)
library(caret)
library(caretEnsemble)
library(RCurl)
library(tidyr)
library(lubridate)
library(stringr)
library(pbapply)
pboptions(type = "txt", style = 3, char = "~", txt.width = NA)
for (file in list.files("R")) {
  source(file.path("R", file))
}

# Settings --------------------------------------------------------------------
scrape_new_data <- TRUE
train_new_models <- TRUE

# Modelling framework ---------------------------------------------------------
main <- function() {
  # Set output file name
  if (!dir.exists("predictions")) {
    dir.create("predictions")
  }
  timestamp <- now() %>% 
    str_sub(1, 20) %>% 
    str_replace_all(" ", "_") %>% 
    str_replace_all(":", "-")
  output_path <- paste0("predictions/preds_", timestamp, ".xlsx")
  # Get and prep data
  if (scrape_new_data) {
    games_train <- get_and_prep_data(seasons = historic_seasons)
  } else {
    games_train <- readRDS("data/games_train.rds")
  }
  # Train models
  if (train_new_models) {
    models_trained <- train_models(games_train, models_to_train)
    # Fit models to traning data and buiid a regression-based ensembles
    # for home wins and away wins
    models_fitted <- fit_models(models_trained)
    models_ensemble <- ensemble_models(models_fitted, models_trained)
    saveRDS(models_ensemble, "data/models_ensemble.rds")
  } else {
    models_ensemble <- readRDS("data/models_ensemble.rds")
  }
  # Get & predict testing data
  games_test <- get_upcoming_fixtures()
  preds <- models_ensemble[[1]] %>% 
    predict(games_test, type = "prob")  %>%
    round(3) %>% 
    bind_cols(games_test) %>% 
    select(date, home_team, away_team, H, D, A) %>% 
    write.xlsx(output_path, row.names = FALSE)
}



