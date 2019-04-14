plot_predictions_highchart <- function(preds) {
  
  # Prep data
  preds_plot <- preds %>%
    mutate(label = paste0(home_team, " - ", away_team)) %>% 
    select(-home_team, -away_team) %>% 
    rename("Home" = "H", "Away" = "A", "Draw" = "D")
  
  # Create the plot
  hchart <- highchart() %>% 
    hc_chart(type = "bar") %>%
    hc_xAxis(categories = preds_plot$label) %>% 
    hc_title(text = "Upcoming Fixtures' Winning Odds") %>%
    hc_tooltip(pointFormat = "<span style=\"color:{series.color}\">{series.name}</span>:
               <b>{point.percentage:.1f}%</b> <br/>",
               shared = TRUE) %>% 
    hc_plotOptions(series = list(
      dataLabels = list(enabled = FALSE),
      stacking = "percent",
      enableMouseTracking = TRUE)
    ) %>%
    hc_series(list(name="Home", data = round(preds_plot$Home, 3), index = 3, legendIndex = 1),
              list(name="Draw", data = round(preds_plot$Draw, 3), index = 2, legendIndex = 2),
              list(name="Away", data = round(preds_plot$Away, 3), index = 1, legendIndex = 3)) 

}


