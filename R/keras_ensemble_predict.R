keras_ensemble_predict <- function(games_upcoming, base_preds) {
  # Load keras ensemble model
  keras_ensemble_model <- load_model_hdf5(
    file.path(path_models, "keras_ensemble_model.h5")
  )
  # Predict
  
}