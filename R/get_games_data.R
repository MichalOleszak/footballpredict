get_games_data <- function(seasons) {
  results <- list()
  for (season in seq(seasons)) {
    url <- paste0("http://www.football-data.co.uk/mmz4281/", seasons[[season]], "/E0.csv")
    results[[season]] <- read.csv(url)
  }
  results <- results %>% 
    bind_rows() %>% 
    as_tibble() %>% 
    filter(Date != "") %>% 
    select(Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR, B365H, B365D, B365A) %>% 
    mutate(Date = as.Date(Date, format = "%d/%m/%Y")) %>% 
    rename(date = Date, home_team = HomeTeam, away_team = AwayTeam,
           home_goals = FTHG, away_goals = FTAG, result = FTR)
  return(results)
}