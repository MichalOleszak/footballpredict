get_games_data <- function(seasons) {
  results <- list()
  print("Getting and prepping historic data")
  pb <- txtProgressBar(min = 0, max = length(seasons), style = 3, char = "~")
  for (season in seq(seasons)) {
    url <- paste0("http://www.football-data.co.uk/mmz4281/", seasons[[season]], "/E0.csv")
    results[[season]] <- read.csv(url)
    setTxtProgressBar(pb, season)
  }
  close(pb)
  results <- results %>% 
    bind_rows() %>% 
    as_tibble() %>% 
    filter(Date != "") %>% 
    select(Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR, B365H, B365D, B365A) %>% 
    mutate(Date = ifelse(nchar(Date) == 8, Date, str_replace(Date, "/20", "/")),
           Date = as.Date(Date, format = "%d/%m/%y")) %>% 
    rename(date = Date, home_team = HomeTeam, away_team = AwayTeam,
           home_goals = FTHG, away_goals = FTAG, result = FTR) %>% 
    mutate(home_team = ifelse(home_team == "Middlesboro", "Middlesbrough", home_team),
           away_team = ifelse(away_team == "Middlesboro", "Middlesbrough", away_team))
  return(results)
}