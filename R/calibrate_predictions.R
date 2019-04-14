calibrate_predictions <- function(preds, calibration_model) {
  
  # Predict with the calibration model
  multinomial_lr_preds <- predict(calibration_model, 
                                  newx = as.matrix(preds[, c("H", "D", "A")]),
                                  s = "lambda.min", type = "response")
  
  preds[, c("H", "D", "A")] <- multinomial_lr_preds[, c("H", "D", "A"), 1]
  
  return(preds) 
}