build_calibration_model <- function(preds) {
  
  # Get actual targets
  games_train <- readRDS(file.path(path_data, "games_train.rds"))
  obs_train <- 1:round(nrow(games_train) * 0.8)
  obs_test <- (tail(obs_train, 1) + 1):nrow(games_train)
  calibration_data <- games_train[obs_test, "result"] %>%
    bind_cols(preds) %>% 
    mutate(result = as.factor(result))
  
  # Train calibrating logistic regression
  multinomial_lr_cv <- cv.glmnet(as.matrix(calibration_data[, c("H", "D", "A")]), 
                                 as.matrix(calibration_data[, "result"]),
                                 family = "multinomial", 
                                 type.multinomial = "grouped")
  
  # Save calibration model
  saveRDS(multinomial_lr_cv, paste0("models/", prefix, "_calibration.rds"))
  
  return(multinomial_lr_cv)
}