# Source functions & config
source("requirements.R")
source("config.R")
for (file in list.files("R")) {
  source(file.path("R", file))
}

# Modelling framework
main <- function() {
  
  # Create paths and set output file name
  if (!dir.exists("predictions")) {
    for (path in c(path_data, path_models, path_results)) {
      dir.create(path)
    }
  }
  timestamp <- now() %>% 
    str_sub(1, 16) %>% 
    str_replace_all(" ", "_") %>% 
    str_replace_all(":", "-")
  path_output <- file.path(path_results, 
                           paste0(prefix, "_preds_", timestamp, ".fst"))
  
  # Get and prep data
  if (scrape_new_data) {
    games_train <- get_and_prep_data(seasons = historic_seasons)
  } else {
    games_train <- readRDS(file.path(path_data, "games_train.rds"))
  }
  if (predict_future_games) {
    games_upcoming <- get_upcoming_fixtures()
  } else {
    obs_train <- 1:round(nrow(games_train) * 0.8)
    obs_test <- (tail(obs_train, 1) + 1):nrow(games_train)
    games_upcoming <- games_train %>% 
      .[obs_test, ] %>% 
      select(-result) %>% 
      mutate(home_team = "hteam", away_team = "ateam", date = NA)
    games_train <- games_train %>% 
      .[obs_train, ]
  }
  
  # Train models
  if (train_new_models) {
    # Train & save base learners
    base_learners <- train_models(games_train, models_to_train)
    # Fit models to traning data and buiid a deep ensemble & save
    models_fitted <- fit_models(base_learners)
    keras_ensemble <- ensemble_models(models_fitted, base_learners, games_train)
    keras_ensemble_model <- keras_ensemble[["keras_ensemble_model"]]
    stand_stats <- keras_ensemble[["stand_stats"]]
  } else {
    base_learners <- readRDS(file.path(path_models, paste0(prefix, "_base_learners.rds")))
    keras_ensemble_model <- load_model_hdf5(
      file.path(path_models, paste0(prefix, "_keras_ensemble_model.h5"))
    )
    stand_stats <- readRDS(file.path(path_models, paste0(prefix, "_stand_stats.rds")))
  }
  
  # Predict with each learner
  base_preds <- lapply(seq(base_learners), function(model_ind) {
    base_learners[[model_ind]] %>% 
      predict(games_upcoming, type = "prob")  %>%
      select(A, D, H) %>% 
      mutate(model = names(base_learners[model_ind]))
  }) %>% bind_rows()
  
  # Predict with deep ensemble
  ensemble_preds <- keras_ensemble_predict(games_upcoming, keras_ensemble_model, 
                                           base_preds, stand_stats)
  
  # Calibrate predictions
  # TODO
  
  # Save final predictoins
  write_fst(ensemble_preds, path_output)
  
  # Visualise predictions
  if (do_plot_preds) {
    #preds_plot <- plot_predictions(poisson_preds %>% select(-H_goals, -A_goals))
    preds_plot <- plot_predictions(ensemble_preds)
    ggsave(file.path(path_results, paste0(prefix, "plot_", timestamp, ".png")), 
           plot = preds_plot)
  }
  if (do_plot_calibration) {
    calibration_plot <- plot_calibration(ensemble_preds)
    ggsave(file.path(path_results, paste0(prefix, "calibration_", timestamp, ".png")), 
           plot = calibration_plot)
  }
}

# Run main modelling framework if script is called from command line
if (!interactive()) {
  main()
}
