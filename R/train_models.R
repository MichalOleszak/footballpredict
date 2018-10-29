train_models <- function(games_train, models_to_train) {

  # Set training control
  train_control <- trainControl(method = "repeatedcv", 
                                number = 5, 
                                repeats = 5,
                                savePredictions = "final", 
                                search = "random",
                                classProbs = TRUE,
                                summaryFunction = multiClassSummary,
                                allowParallel = TRUE, 
                                verboseIter = TRUE)
  
  # Train the models
  models <- caretList(result ~ ., 
                      data = games_train, 
                      trControl = train_control,
                      metric = "Mean_Pos_Pred_Value",
                      preProcess = c("center", "scale"),
                      tuneLength = 15,
                      methodList = models_to_train,
                      continue_on_fail = TRUE)
  
  # Box plots to compare models
  results <- resamples(models)
  results$metrics <- "Mean_Pos_Pred_Value"
  scales <- list(x = list(relation = "free"), y = list(relation = "free"))
  print(bwplot(results, scales = scales))
  
  return(models)
}