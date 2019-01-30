keras_ensemble_cv <- function(models_fitted, games_train) {
  
  # Prep data for the ensemble
  ensemble_input <- models_fitted %>% 
    select(-D) %>% 
    split(.$model) %>% 
    lapply(function(x) {
      set_names(x, c(paste0("A_", x$model[1]), paste0("H_", x$model[1]), "model")) %>% 
        select(-model)
    }) %>% 
    bind_cols(games_train)
  
  X <- ensemble_input %>% select(-result) %>% as.matrix()
  X <- apply(X, 2, function(x) (x - mean(x)) / sd(x))
  y <- ensemble_input %>% pull(result) %>% factor(levels = c("H", "D", "A")) %>% as.numeric()
  one_hot_y <- to_categorical(y - 1, num_classes = 3)
  
  # Assess performance of the model as desinged in build_keras_model() with cross-validation
  indices <- sample(1:nrow(X))
  folds <- cut(indices, breaks = keras_cv_k, labels = FALSE)
  all_acc_histories <- NULL
  for (i in 1:keras_cv_k) {
    message(paste0("Keras ensemble cross-validation: processing fold ", i, " of ", keras_cv_k))
    # Prepare validation data from partiion #k
    val_indices <- which(folds == i, arr.ind = TRUE)
    val_data <- X[val_indices, ]
    val_targets <- one_hot_y[val_indices, ]
    # Prepare training data from all other partitions
    partial_train_data <- X[-val_indices, ]
    partial_train_targets <- one_hot_y[-val_indices, ]
    # Build a compiled keras model
    model <- build_keras_model(input_shape = ncol(X))
    # Train the model (in silent mode)
    history <- model %>% fit(partial_train_data, 
                             partial_train_targets,
                             validation_data = list(val_data, val_targets),
                             epochs = keras_num_epochs,
                             batch_size = 1)
    # Evaluate the model on validation data
    acc_history <- history$metrics$val_acc
    all_acc_histories <- rbind(all_acc_histories, acc_history)
  }
  # Average per-epoch accuracy for all folds
  average_acc_history <- data.frame(
    epoch = seq(1:ncol(all_acc_histories)),
    validation_acc = apply(all_acc_histories, 2, mean)
  )
  plt <- ggplot(average_acc_history, aes(epoch, validation_acc)) +
    geom_smooth()
  plot(plt)
  
  return(average_acc_history)
}