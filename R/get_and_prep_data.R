get_and_prep_data <- function(seasons) {
  
  # Get historic matches data
  historic_games <- get_games_data(seasons = historic_seasons)
  
  # Get ELO data
  elo_data <- get_elo_data(date_start = min(historic_games$date))
  elo_recent <- elo_data %>% 
    group_by(club) %>% 
    filter(date == max(date))
  
  # Clean final output data
  games_train <- historic_games %>% 
    select(date, home_team, away_team, result, B365H, B365D, B365A) %>% 
    left_join(elo_data, by = c("date" = "date", "home_team" = "club")) %>% 
    rename(home_elo = elo) %>% 
    left_join(elo_data, by = c("date" = "date", "away_team" = "club")) %>% 
    rename(away_elo = elo) %>% 
    select(-date, -home_team, -away_team)
  
  # Save to disc
  if (!dir.exists("data")) {
    dir.create("data")
  }
  save(games_train, file = "data/games_train.RData")
  save(elo_recent, file = "data/elo_recent.RData")
  
  return(games_train)
}