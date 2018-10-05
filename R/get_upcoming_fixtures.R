get_upcoming_fixtures <- function() {
  elo_recent <- readRDS("data/elo_recent.rds") %>% 
    select(-date)
  download <- "api.clubelo.com/Fixtures" %>% getURL()
  out <- read.csv(text = download) %>% 
    filter(Country == "ENG") %>% 
    select(date = Date, home_team = Home, away_team = Away) %>% 
    mutate(date = as_date(date),
           home_team = as.character(home_team),
           away_team = as.character(away_team)) %>%
    left_join(elo_recent, by = c("home_team" = "club")) %>% 
    rename(home_elo = elo) %>% 
    left_join(elo_recent, by = c("away_team" = "club")) %>% 
    rename(away_elo = elo)
  out <- out[complete.cases(out), ]
  return(out)
}