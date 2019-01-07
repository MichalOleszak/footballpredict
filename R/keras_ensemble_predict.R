keras_ensemble_predict <- function(games_upcoming, base_preds, stand_stats) {
  # Load keras ensemble model
  keras_ensemble_model <- load_model_hdf5(
    file.path(path_models, "keras_ensemble_model.h5")
  )
  # Prep data for the ensemble
  ensemble_input <- base_preds %>% 
    select(-D) %>% 
    split(.$model) %>% 
    lapply(function(x) {
      set_names(x, c(paste0("A_", x$model[1]), paste0("H_", x$model[1]), "model")) %>% 
        select(-model)
    }) %>% 
    bind_cols(games_upcoming %>% select(-home_team, -away_team, -date))
  # Prepare new data for ensemble's predicting function
  X <- ensemble_input %>% 
    as.matrix() %>% 
    scale(center = stand_stats$X_means, scale = stand_stats$X_stds)
  # Predict
  ensemble_preds <- keras_ensemble_model %>% 
    predict(X) %>% 
    as_tibble() %>% 
    set_names(c("H", "D", "A"))
  out <- games_upcoming %>% 
    select(home_team, away_team) %>% 
    bind_cols(ensemble_preds)
  return(out)
}