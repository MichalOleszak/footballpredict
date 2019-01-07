fit_poisson_model <- function() {
  
  # Prep data
  temp <- readRDS("data/historic_games.rds") %>% 
    inner_join(readRDS("data/games_train_date_teams.rds"),
               by = c("date", "home_team", "away_team", "result")) %>% 
    select(-B365H, -B365D, -B365A, -date, -result)
  
  poisson_data <- temp %>%
    select(-away_goals) %>% 
    rename(goals = home_goals) %>% 
    mutate(home = 1) %>% 
    bind_rows(
      temp %>%
        select(-home_goals) %>% 
        rename(goals = away_goals) %>% 
        mutate(home = 0)
    )
  
  # Fit Poisson model 
  poisson_model <- glm(goals ~ ., family = poisson(link = log), data = poisson_data)
  
  return(poisson_model)
}



