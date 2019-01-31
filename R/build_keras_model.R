build_keras_model <- function(input_shape) {
  
  model <- keras_model_sequential() %>%
    layer_dense(units = 64, activation = "relu", input_shape = input_shape,
                kernel_regularizer = regularizer_l1(0.01)) %>%
    layer_dense(units = 32, activation = "relu",
                kernel_regularizer = regularizer_l1(0.01)) %>%
    layer_dense(units = 3, activation = "softmax")
  
  model %>% compile(
    optimizer = "rmsprop",
    loss = "categorical_crossentropy",
    metrics = "accuracy"
  )
  
  return(model)
}