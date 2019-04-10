plot_calibration <- function(ensemble_preds) {
  games_train <- readRDS(file.path(path_data, "games_train.rds"))
  obs_train <- 1:round(nrow(games_train) * 0.8)
  obs_test <- (tail(obs_train, 1) + 1):nrow(games_train)
  
  dat <- ensemble_preds %>% 
    bind_cols(games_train[obs_test, "result"]) %>% 
    select(-home_team, -away_team) %>% 
    bind_cols(pred = colnames(.)[apply(.[, 1:3], 1, which.max)]) %>% 
    bind_cols(prob_pred = apply(.[, 1:3], 1, max)) %>% 
    filter(prob_pred > 0.0)
  
  res <- tibble()
  for (predicted_class in c("H", "A", "D")) {
    for (predicted_prob in seq(0.5, 0.95, by = 0.05)) {
      temp <- dat %>% 
        filter(pred == predicted_class) %>% 
        filter(prob_pred >= predicted_prob & prob_pred < predicted_prob + 0.05)
      # rows predicted, columns real
      tb <- table(temp$pred, temp$result)
      if (predicted_class %in% colnames(tb)) {
        ppv <- tb[, predicted_class] / sum(tb)
      } else {
        ppv <- 0
      }
      res <- bind_rows(res, tibble("class" = predicted_class,
                                   "prob" = predicted_prob,
                                   "ppv" = ppv,
                                   "n_obs" = nrow(temp)))
    }
  }
  res <- res %>% 
    filter(class != "D") %>% 
    rename(result = class)
  
  grid.arrange(ggplot(res, aes(prob, ppv, colour = result)) + 
                 ylim(c(0, 1)) +
                 xlim(c(0.5, 0.95)) +
                 geom_line(size = 1) +
                 geom_point(size = 3) +
                 geom_abline() +
                 ggtitle("Model Calibration") +
                 ylab("Positive Predictive Value") +
                 xlab("") +
                 theme_minimal(),
               ggplot(res, aes(prob, n_obs, fill = result)) +
                 geom_bar(stat = "identity", position = "dodge") +
                 ylab("# observations") +
                 xlab("Predicted result probability (intervals of length 0.05)") +
                 theme_minimal(),
               layout_matrix = matrix(c(1,1,2), ncol = 1))
}



