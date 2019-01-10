# Dependencies
library(tidyverse); library(rPref); library(magrittr); library(ggrepel)

# Load data from input folder
load("input/passer_games.Rdata")

dual_threat <- passer_games %>%
  filter(att > 1) %>%
  psel(high(yds)*high(rush_yds))

kaepernick <- dual_threat %>%
  filter(player == "Colin Kaepernick")

mahomes <- dual_threat %>%
  filter(player == "Patrick Mahomes")

vick <- dual_threat %>%
  filter(player == "Michael Vick")

newton <- dual_threat %>%
  filter(player == "Cam Newton")


passer_games %>%
  filter(att > 5) %>%
ggplot(aes(x = rush_yds, y = yds)) +
  geom_point(alpha = 0.1) +
  geom_point(data = dual_threat, size = 2) +
  geom_line(data = dual_threat, linetype = 'dotdash') + 
  geom_point(data = kaepernick, size = 4, color = "#AA0000") + 
  geom_label_repel(data = kaepernick,
                   aes(label = player),
                   box.padding = 0.5,
                   point.padding = 0.5) +
  geom_point(data = mahomes, size = 4, color = "#E31837") + 
  geom_label_repel(data = mahomes, aes(label = player),
                   box.padding = 0.5,
                   point.padding = 0.5) +
  geom_point(data = newton, size = 4, color = "#0085CA") + 
  geom_label_repel(data = newton, aes(label = player),
                   box.padding = 0.05,
                   point.padding = 0.5) +
  geom_point(data = vick, size = 4, color = "#004C54") + 
  geom_label_repel(data = vick, aes(label = player), #paste(player,
                                                     #paste0(team, " vs. ", opp, ", ", date),
                                                     #paste(yds, "passing", "|", rush_yds, "rushing", sep = " "),
                                                     #sep = "\n")),
                   box.padding = 1.5, 
                   point.padding = 0.5) + 
  labs(x="Yards Rushing", y = "Yards Passing", title="The Dual-Threat Pareto Frontier", subtitle=">5 pass attempts") +
  scale_x_continuous(limits=c(0, 225), expand=c(0,0))+ 
  scale_y_continuous(limits=c(0, 550), expand=c(0,0))+ 
  geom_hline(yintercept = 0) + 
  geom_vline(xintercept = 0) +
  theme(
    # Text
    plot.title = element_text(size=14, face="bold.italic"),
    axis.title.x = element_text(size=14),
    axis.title.y = element_text(size=14),
    axis.text = element_text(size = 12, face = "italic"),
    panel.background = element_blank()
  )

favresque <- passer_games %>%
  filter(att > 1) %>%
  psel(high(td)*high(int))

efficient_and_deadly <- passer_games %>%
  filter(att > 10) %>%
  psel(high(pct)*high(ypa))
