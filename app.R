library(shiny)
library(shinythemes)
library(highcharter)
source('main.R')
source('app_config.R')

shinyApp(
  ui = tagList(
    navbarPage(
      theme = shinytheme("cerulean"),
      "footballpredict AI",
      tabPanel("Home",
               "App under construction"
      ),
      tabPanel("England",
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
    preds <- main()
    output$preds_plot <- renderHighchart({
      plot_predictions_highchart(preds)
    })
    output$calibration_plot <- renderPlot({
      calibration_preds <- read_fst(paste0("app_files/", prefix, 
                                           "_calibration_preds.fst"))
      calibration_games_train <- read_rds(paste0("app_files/", prefix, 
                                                 "_calibration_games_train.rds"))
      plot_calibration(calibration_preds, calibration_games_train)
    })
  }
)
