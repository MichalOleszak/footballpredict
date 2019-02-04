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
  
  # Calculate class weights to account for imbalance
  cw <- get_balancing_class_weights(games_train$result)
  
  # Train a densely connected neural network using original features and base learner's output
  keras_ensemble_model <- build_keras_model(input_shape = ncol(X))
  keras_ensemble_model %>% fit(X, 
                               one_hot_y,
                               epochs = keras_num_epochs,
                               batch_size = 16,
                               class_weight = cw)
  
  # Serialize and save model
  save_model_hdf5(keras_ensemble_model, 
                  file.path(path_models, paste0(prefix, "_keras_ensemble_model.h5")))
  
  # Save standarisation statistics
  stand_stats <- list("X_means" = X_means, "X_stds" = X_stds)
  saveRDS(stand_stats, file.path(path_models, paste0(prefix, "_stand_stats.rds")))
  
  out <- list("stand_stats" = stand_stats,
              "keras_ensemble_model" = keras_ensemble_model)
  
  return(out)
}