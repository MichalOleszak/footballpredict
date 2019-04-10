library(shiny)
library(shinythemes)
library(fst)
library(dplyr)
library(tidyr)
library(highcharter)
source('R/plot_prediction_highchart.R')

shinyApp(
  ui = tagList(
    navbarPage(
      theme = shinytheme("cerulean"),
      "footballpredict AI",
      tabPanel("Home",
               "App under construction"
      ),
      tabPanel("Premier League Predictions",
               mainPanel(
                 highchartOutput("preds_plot", width = "600px", height = "650px")
               )
      ),
      tabPanel("Model Calibration",
               "to be filled"
      )
      
    )
  ),
  server = function(input, output) {
    output$preds_plot <- renderHighchart({
      preds <- read_fst("predictions/run_preds_2019-04-09_18-50.fst")
      plot_predictions_highchart(preds)
    })
  }
)


