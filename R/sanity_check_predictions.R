sanity_check_predictions <- function(ensemble_preds, games_upcoming) {
  
  # Get home winning odds based on ELO
  home_win_elo_odds <- 1 / 
    (10^(-(games_upcoming$home_elo - games_upcoming$away_elo) / 400) + 1)
  
  # Correct predictions
  corrected_preds <- ensemble_preds %>% 
    bind_cols("home_win_elo_odds" = home_win_elo_odds) %>% 
    mutate(diff = abs(H - home_win_elo_odds),
           away_draw_ratio = A / (A + D)) %>% 
    mutate(H = ifelse(diff > 0.4, home_win_elo_odds, H),
           A = ifelse(diff > 0.4, (1 - home_win_elo_odds) * away_draw_ratio, A),
           D = ifelse(diff > 0.4, 1 - A - H, D)) %>% 
    select(-home_win_elo_odds, -diff, -away_draw_ratio)
  
  return(corrected_preds)
}