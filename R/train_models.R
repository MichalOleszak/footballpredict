train_models <- function(games_train, models_to_train) {
  
  # Set training control
  train_control <- trainControl(method = "repeatedcv", 
                                number = 5, 
                                repeats = 5,
                                savePredictions = "final", 
                                classProbs = TRUE,
                                summaryFunction = multiClassSummary,
                                allowParallel = TRUE, 
                                verboseIter = TRUE)
  
  # Train the models
  models <- caretList(result ~ ., 
                      data = games_train, 
                      trControl = train_control,
                      preProcess = c("center", "scale"),
                      methodList = models_to_train,
                     #tuneList = list(
                     #       nnet = caretModelSpec(method = "nnet", 
                     #                             trace = FALSE, 
                     #                             tuneLength = 1)
                     #    ),
                      continue_on_fail = TRUE)
  
  # Print results
  results <- resamples(models)
  print(summary(results))
  
  # Box plots to compare models
  scales <- list(x = list(relation = "free"), y = list(relation = "free"))
  print(bwplot(results, scales = scales))
  
  return(models)
}