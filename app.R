library(shiny)
library(shinythemes)
library(fst)
library(dplyr)
library(tidyr)
library(highcharter)
source('R/plot_prediction_highchart.R')
source('R/plot_calibration.R')

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
               mainPanel(
                 plotOutput("calibration_plot", width = "700px", height = "500px")
               )
      )
    )
  ),
  server = function(input, output) {
    output$preds_plot <- renderHighchart({
      preds <- read_fst("predictions/run_preds_2019-04-09_18-50.fst")
      plot_predictions_highchart(preds)
    })
    output$calibration_plot <- renderPlot({
      preds <- read_fst("predictions/testing_preds_2019-04-10_20-45.fst")
      plot_calibration(preds)
    })
  }
)
