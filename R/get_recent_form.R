get_recent_form <- function(recent_games) {

  # Define all unique teams
  teams <- union(
    recent_games %>% 
      pull(home_team) %>%
      unique(),
    recent_games %>% 
      pull(away_team) %>%
      unique()
  )
  
  # For each team get their recent games' results
  res <- lapply(teams, function(team) {
    out <- recent_games %>% 
      filter(home_team == team | away_team == team) %>%
      arrange(date) %>% 
      tail(10) %>% 
      mutate(team = team) %>% 
      group_by(team) %>% 
      summarise(recent_goals_scored_home = sum(home_goals[home_team == team]),
                recent_goals_scored_away = sum(away_goals[away_team == team]),
                recent_goals_conceded_home = sum(away_goals[home_team == team]),
                recent_goals_conceded_away = sum(home_goals[away_team == team]),
                recent_home_games_won = sum((result == "H")[home_team == team]),
                recent_home_games_lost = sum((result != "H")[home_team == team]),
                recent_away_games_won = sum((result == "A")[away_team == team]),
                recent_away_games_lost = sum((result != "A")[away_team == team]))
  }) %>% 
    bind_rows()
  
  return(res)
}