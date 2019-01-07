get_upcoming_fixtures <- function() {
  historic_games <- readRDS("data/historic_games.rds")
  elo_recent <- readRDS("data/elo_recent.rds") %>% 
    select(-date)
  recent_form <- get_recent_form(recent_games = historic_games)
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
    rename(away_elo = elo) %>% 
    left_join(recent_form %>% 
                set_names(paste0("home_", colnames(recent_form))), 
              by = c("home_team")) %>% 
    left_join(recent_form %>% 
                set_names(paste0("away_", colnames(recent_form))), 
              by = c("away_team"))
  out <- out[complete.cases(out), ]
  if (nrow(out) == 0) {
    stop("No upcoming fixtures available!")
  }
  return(out)
}