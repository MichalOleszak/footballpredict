ensemble_models <- function(models_fitted, models_trained, games_train) {
  
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
  X_means <- apply(X, 2, mean)
  X_stds <- apply(X, 2, sd)
  X <- apply(X, 2, function(x) (x - mean(x)) / sd(x))
  y <- ensemble_input %>% pull(result) %>% factor(levels = c("H", "D", "A")) %>% as.numeric()
  one_hot_y <- to_categorical(y - 1, num_classes = 3)
  # TODO: train with a validation set
  # Train a densely connected neural network using original features and base learner's output
  keras_ensemble_model <- build_keras_model(input_shape = ncol(X))
  keras_ensemble_model %>% fit(X, 
                               one_hot_y,
                               epochs = 40,
                               batch_size = 16)
  
  # Serialize and save model
  save_model_hdf5(keras_ensemble_model, file.path(path_models, "keras_ensemble_model.h5"))
  
  # Return standarisation statistics
  stand_stats <- list("X_means" = X_means,
                      "X_stds" = X_stds)
  
  return(stand_stats)
}