# Dependencies
library(tidyverse); library(rPref); library(magrittr)

# Load data from input folder
load("input/passer_games.Rdata")

dual_threat <- passer_games %>%
  filter(att > 1) %>%
  psel(high(yds)*high(rush_yds))

favreian <- passer_games %>%
  filter(att > 1) %>%
  psel(high(td)*high(int))

efficient_and_deadly <- passer_games %>%
  filter(att > 10) %>%
  psel(high(pct)*high(ypa))
