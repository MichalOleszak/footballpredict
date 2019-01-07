predict_poisson <- function(games_upcoming, poisson_model) {
  probs <- tibble()
  goals <- tibble()
  for (game in seq(nrow(games_upcoming))) {
    # Predict expected number of goals scored
    home_goals_avg <- predict(poisson_model,
                              games_upcoming[game, ] %>% 
                                select(-date) %>% 
                                mutate(home = 1),
                              type = "response")
    away_goals_avg <- predict( poisson_model,
                               games_upcoming[game, ] %>% 
                                 select(-date) %>% 
                                 mutate(home = 0),
                               type = "response")
    
    # Simulate the games
    results_matrix <- dpois(0:5, home_goals_avg) %o% dpois(0:5, away_goals_avg)
    
    # Get the predictions
    most_prob_res <- which(results_matrix == max(results_matrix), arr.ind = TRUE) %>% 
      as_tibble() %>% 
      set_names(c("H_goals", "A_goals"))
    home <- (lower.tri(results_matrix) * results_matrix) %>% sum()
    away <- (upper.tri(results_matrix) * results_matrix) %>% sum()
    draw <- diag(results_matrix) %>% sum()
    
    probs <- probs %>% bind_rows(tibble("H" = home, "D" = draw, "A" = away))
    goals <- goals %>% bind_rows(most_prob_res)
  }
  
  # Return predictions
  poisson_preds_prob <- games_upcoming %>% 
    as_tibble() %>% 
    select(home_team, away_team) %>% 
    bind_cols(probs) %>% 
    bind_cols(goals)
  
  return(poisson_preds_prob)
  
}