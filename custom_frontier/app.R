# Dependencies
library(shiny)
library(tidyverse)
library(rPref)
library(magrittr)
library(ggrepel)
library(DT)

load("~/ParetoPassers/input/qb_lines.Rdata")
qb_lines <- filter(qb_lines, att >= 5)
stat_choices <- c("Completions" = "cmp",
                  "Attempts" = "att",
                  "Completion %" = "pct",
                  "Pass Yards" = "yds",
                  "Pass TD" = "td",
                  "Interceptions" = "int",
                  "QB Rating" = "rtg",
                  "Sacks" = "sk",
                  "Sack Yards" = "sk_yds",
                  "Yards per Attempt" = "ypa",
                  "Adj. Yards per Attempt" = "adj_ypa",
                  "Rush Yards" = "rush_yds",
                  "Rush TD" = "rush_td",
                  "Yards per Rush" = "ypr",
                  "Fumbles" = "fmb")

ui <- fluidPage(
   
   # Title
   fluidRow(h2("Pick your own Pareto frontier:")),
   
   # Sidebar with dropdown select for each stat
   fluidRow(
         column(width = 4,
                selectInput("stat1", "First stat (y):",
                     stat_choices, selected = "yds")),
         column(width = 4,
                selectInput("stat2", "Second stat (x):",
                     stat_choices, selected = "rush_yds"))
      ),
   fluidRow(
     column(width = 8,
         plotOutput("frontierPlot", hover = "plotHover")
        )
     ),
  fluidRow(
    column(width = 8,
     DT::dataTableOutput("chosenPlayer")
     )
    ),
   fluidRow(
         DT::dataTableOutput("frontierTable")
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  frontier <- reactive({
    qb_lines %>%
      psel(high_(input$stat1) * high_(input$stat2))
  })
  
  colorGen <- reactive({
    paste0("#", as.character.hexmode(runif(1, 1048576, 16777215)))
  })
  
   output$frontierPlot <- renderPlot({
      p <- ggplot(qb_lines, aes_string(x = input$stat2, y = input$stat1)) +
        geom_point(size = 2, color = "#000000", alpha = 0.25) +
        geom_point(data = frontier(), color = colorGen(), size = 4) +
        geom_line(data = frontier(), color = colorGen(), alpha = 0.25, size = 1) +
        geom_hline(yintercept = 0) +
        geom_vline(xintercept = 0) +
        expand_limits(x=0, y = 0) +
        theme(
          # # Text
          # plot.title = element_text(
          #   size = 18,
          #   face = "bold"
          # ),
          # plot.subtitle = element_text(size = 12),
          # plot.caption = element_text(face = 'italic'),
          axis.title.x = element_text(size = 14, face = 'bold'),
          axis.title.y = element_text(size = 14, face = 'bold'),
          axis.text = element_text(size = 12, face = "italic"),
          panel.background = element_blank()
        )
      return(p)
   })
   
   output$chosenPlayer <- renderDataTable({
     nearPoints(qb_lines, input$plotHover, yvar = input$stat1, xvar = input$stat2, maxpoints=1) %>%
       select(player, age, date, team, opp, result, att, input$stat1, input$stat2)
   }, options = list(paging = F, searching = F))
   
   output$frontierTable <- renderDataTable({
     frontier() %>%
       select(player, age, date, team, opp, result, cmp:fmb)
   }, options = list(scrollX = T, paging = F))
}

# Run the application 
shinyApp(ui = ui, server = server)

