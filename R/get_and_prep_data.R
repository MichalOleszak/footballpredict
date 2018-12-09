get_and_prep_data <- function(seasons) {
  
  # Get historic matches data
  historic_games <- get_games_data(seasons = historic_seasons)

  # Get ELO data
  elo_data <- get_elo_data(date_start = min(historic_games$date))
  elo_recent <- elo_data %>% 
    group_by(club) %>% 
    filter(date == max(date))

  # Get recent form data
  print("Calculating recent form for historic data")
  historic_recent_form <- pblapply(unique(historic_games$date), function(hist_date) {
    historic_recent_games <- historic_games %>% filter(date < hist_date)
    out <- get_recent_form(recent_games = historic_recent_games) %>% 
      mutate(search_date = hist_date)
    return(out)
  }) %>% bind_rows()

  # Clean final output data
  games_train <- historic_games %>% 
    select(date, home_team, away_team, result, B365H, B365D, B365A) %>% 
    left_join(elo_data, by = c("date" = "date", "home_team" = "club")) %>% 
    rename(home_elo = elo) %>% 
    left_join(elo_data, by = c("date" = "date", "away_team" = "club")) %>% 
    rename(away_elo = elo) %>% 
    left_join(historic_recent_form %>% 
                set_names(paste0("home_", colnames(historic_recent_form))), 
              by = c("home_team", "date" = "home_search_date")) %>% 
    left_join(historic_recent_form %>% 
                set_names(paste0("away_", colnames(historic_recent_form))), 
              by = c("away_team", "date" = "away_search_date")) %>% 
    select(-date, -home_team, -away_team, -B365H, -B365D, -B365A) %>% 
    filter(complete.cases(.))
  
  # Save to disc
  if (!dir.exists("data")) {
    dir.create("data")
  }
  saveRDS(games_train, file = "data/games_train.rds")
  saveRDS(elo_recent, file = "data/elo_recent.rds")
  saveRDS(historic_games, file = "data/historic_games.rds")
  
  return(games_train)
}