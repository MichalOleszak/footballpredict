source("requirements_app.R")
source("config.R")
for (file in c("get_upcoming_fixtures.R",
               "get_recent_form.R",
               "mean_ensemble.R", 
               "calibrate_predictions.R", 
               "sanity_check_predictions.R")) {
  source(file.path("R", file))
}

app_main <- function() {
  
  # Load and scrape data
  games_train <- readRDS(file.path("data", "games_train.rds"))
  games_upcoming <- get_upcoming_fixtures()
  
  if (nrow(games_upcoming) > 0) {
    # Load models
    base_learners <- readRDS(file.path("models", paste0(prefix, "_base_learners.rds")))
    calibration_model <- readRDS(paste0("models/", prefix, "_calibration.rds"))
    
    # Predict with each learner
    base_preds <- lapply(seq(base_learners), function(model_ind) {
      base_learners[[model_ind]] %>% 
        predict(games_upcoming, type = "prob")  %>%
        select(A, D, H) %>% 
        mutate(model = names(base_learners[model_ind]))
    }) %>% bind_rows()
    
    # Ensemble models
    ensemble_preds <- mean_ensemble(games_upcoming, base_preds)
    
    # Calibrate predictions
    calibrated_preds <- calibrate_predictions(ensemble_preds, calibration_model)
    
    # Sanity check for improbably preds
    final_preds <- sanity_check_predictions(calibrated_preds, games_upcoming)
  } else {
    final_preds <- data.frame()
  }
  
  return(final_preds)
}