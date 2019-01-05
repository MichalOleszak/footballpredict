plot_predictions <- function(preds) {
  preds_plot <- preds %>%
    mutate(label = paste0(home_team, " - ", away_team)) %>% 
    select(-home_team, -away_team) %>% 
    gather(key = "Result", value = "prob", -label) %>% 
    mutate(Result = case_when(
      Result == "H" ~ "Home",
      Result == "D" ~ "Draw",
      Result == "A" ~ "Away"
      )) %>% 
    ggplot(aes(x = label, y = prob, fill = Result)) +
      geom_bar(stat = "identity") +
      scale_fill_viridis(discrete = TRUE, option = "E", alpha = 0.7) +
      coord_flip() +
      geom_label(aes(label = scales::percent(prob, accuracy = 1)),
                stat = "identity", position = position_fill(vjust = 0.5),
                fill = "white", size = 5) +
      xlab("") +
      ylab("") +
      theme_minimal()
  
  return(preds_plot)
}  