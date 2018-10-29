build_keras_model <- function(input_shape) {
  
  model <- keras_model_sequential() %>%
    layer_dense(units = 64, activation = "relu", input_shape = input_shape) %>%
    layer_dense(units = 64, activation = "relu") %>%
    layer_dense(units = 3, activation = "softmax")
  
  model %>% compile(
    optimizer = "rmsprop",
    loss = "categorical_crossentropy",
    # TODO: custom metric, as the one use in caret for base learners
    metrics = "accuracy"
  )
  # TODO add regularization, dropout, experiment with layers
  # TODO add early stopping and these kinds of things
  return(model)
}