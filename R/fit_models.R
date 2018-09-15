fit_models <- function(models_trained) {
  lapply(models_trained, function(model) {
    predict(model, type = "prob") %>% 
      mutate("model" = model$method)
  }) %>% 
    bind_rows()
}