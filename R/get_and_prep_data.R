get_and_prep_data <- function(seasons) {
  
  # Get historic data
  games_train <- get_games_data(seasons = historic_seasons)
  
  # Clean final output data
  games_train <- games_train %>% 
    select(result, B365H, B365D, B365A)
  
  # Save to disc
  if (!dir.exists("data")) {
    dir.create("data")
  }
  save(games_train, file = "games_train.RData")
  
  return(games_train)
}