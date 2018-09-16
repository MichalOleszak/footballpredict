get_elo_data <- function(date_start) {
  elo_data <- lapply(elo_teams, function(team) {
    download <- paste0("api.clubelo.com/", team) %>% getURL()
    elo_data <- read.csv(text = download) %>% 
      bind_rows() %>% 
      select(club = Club, elo = Elo, date = From) %>% 
      mutate(date = as_date(date)) %>% 
      filter(!is.na(club)) %>% 
      as_tibble() %>% 
      right_join(seq.Date(from = date_start - days(30), to = today(), by = "day") %>% as_tibble(),
                 by = c("date" = "value")) %>% 
      fill(everything(), .direction = "down")
  }) %>% 
    bind_rows() %>% 
    filter(!is.na(club), date >= date_start)
return(elo_data)
}