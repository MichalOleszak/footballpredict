mean_ensemble <- function(games_upcoming, base_preds) {
  
  ensemble_preds <- base_preds %>% 
    group_by(model) %>% 
    mutate(game_number = dplyr::row_number()) %>% 
    group_by(game_number) %>% 
    summarize(A = mean(A),
              D = mean(D),
              H = mean(H)) %>% 
    ungroup() %>% 
    select(-game_number)
  
  out <- games_upcoming %>% 
    select(home_team, away_team) %>% 
    bind_cols(ensemble_preds)
  
  return(out)
}