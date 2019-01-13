# Dependencies
library(tidyverse); library(rPref); library(magrittr); library(ggrepel)

# Load data from input folder
load("input/passer_games.Rdata")

# passer_games %<>%
#   mutate(rush_yds = rush_yds-sk_yds)

dual_threat <- passer_games %>%
  filter(att > 5) %>%
  psel(high(yds)*high(rush_yds))

brady <- dual_threat %>%
  filter(player == "Tom Brady")

kaepernick <- dual_threat %>%
  filter(player == "Colin Kaepernick")

mahomes <- dual_threat %>%
  filter(player == "Patrick Mahomes")

vick <- dual_threat %>%
  filter(player == "Michael Vick")

newton <- dual_threat %>%
  filter(player == "Cam Newton")

png("run_pass_tradeoff.png", height = 3000, width=3000, units='px', res=300)
passer_games %>%
  filter(att > 5) %>%
ggplot(aes(x = rush_yds, y = yds)) +
  geom_point(alpha = 0.1) +
  geom_point(data = dual_threat, size = 2) +
  geom_line(data = dual_threat, linetype = 'dotdash', size = 0.5, colour = 'black') + 
  geom_segment(size=0.5, colour = 'black', linetype='dotdash', y=527, yend=527, x=0, xend=2) + # cut off frontier at Warren Moon (y=527)
  geom_segment(size=0.5, colour = 'black', linetype='dotdash', y=0, yend=263, x=181, xend=181) + # cut off frontier at Kaepernick (x=181)
  geom_point(data = brady, size = 5, color = "#002244") +
  geom_label_repel(data = brady,
                   aes(label = player),
                   color="#002244", fontface='bold',
                   box.padding = 0.5,
                   point.padding = 0.5,
                   nudge_y = 5) +
  geom_point(data = kaepernick, size = 5, color = "#AA0000") + 
  geom_label_repel(data = kaepernick,
                   aes(label = player),
                   color="#AA0000", fontface='bold',
                   box.padding = 0.5,
                   point.padding = 0.5) +
  geom_point(data = mahomes, size = 5, color = "#E31837") + 
  geom_label_repel(data = mahomes,
                   aes(label = player),
                   color="#E31837", fontface='bold',
                   box.padding = 0.5,
                   point.padding = 0.5) +
  geom_point(data = newton, size = 5, color = "#0085CA") + 
  geom_label_repel(data = newton,
                   aes(label = player),
                   color="#0085CA", fontface='bold',
                   box.padding = 0.05,
                   point.padding = 0.5) +
  geom_point(data = vick, size = 5, color = "#004C54") + 
  geom_label_repel(data = vick, aes(label = player), #paste(player,
  #                                                    #paste0(team, " vs. ", opp, ", ", date),
  #                                                    #paste(yds, "passing", "|", rush_yds, "rushing", sep = " "),
  #                                                    #sep = "\n")),
                    color="#004C54", fontface='bold',
                    box.padding = 1.5, 
                    point.padding = 0.5) + 
  labs(x="Yards Rushing",
       y = "Yards Passing",
       title="The Run/Pass Tradeoff",
       subtitle="Pareto efficiency in QB single-game rushing/passing yardage,\na frontier past which no other player has both thrown and rushed for more yards.",
       caption="Source: Pro-Football-Reference.com's play index finder, 1970 - 2018 (Week 17)")+ 
# \n11 of the 14 Pareto-optimal performances were from active players,\n including 3 in the 2019 playoffs (Brady, Wilson, Mahomes).") +
#  geom_label(x=160, y=470,
#             size=10,
#             label="11 of the 14 Pareto-optimal performances were from active players,\nincluding 3 in the 2019 playoffs (Brady, Wilson, Mahomes).") +
  scale_x_continuous(limits=c(0, 225), expand=c(0,0))+ 
  scale_y_continuous(limits=c(0, 550), expand=c(0,0))+ 
  geom_hline(yintercept = 0) + 
  geom_vline(xintercept = 0) +
  theme(
    # Text
    plot.title = element_text(size=18, family='Palatino', face="bold"),
    plot.subtitle = element_text(size=12, family='Palatino'),
    plot.caption = element_text(face='italic', family='Palatino'),
    axis.title.x = element_text(size=14, face='bold'),
    axis.title.y = element_text(size=14, face='bold'),
    axis.text = element_text(size = 12, face = "italic"),
    panel.background = element_blank(),
    text = element_text(family = "Palatino")
  )
dev.off()

# Build example to explain Pareto optimality:
example <-
  data.frame(Rings=1:4, MVPs=c(4, 3, 2, 2),name=c("A","B","C","D"))
example_frontier <-
  example %>%
  psel(high(Rings)*high(MVPs))
new_point <-
  data.frame(Rings=3, MVPs=3,name="E")
new_frontier <-
  bind_rows(example, new_point) %>%
  psel(high(Rings)*high(MVPs))

# 
ggplot(example, aes(x=Rings,y=MVPs,label=name)) +
  scale_x_continuous(limits=c(0,4.5),expand=c(0,0)) +
  scale_y_continuous(limits=c(0,4.5),expand=c(0,0)) +
  geom_segment(x=0, xend=1,y=4,yend=4, size=1, linetype='dashed', color="#004C54") +
  geom_segment(x=4, xend=4,y=0,yend=2, size=1, linetype='dashed', color="#004C54") +
  geom_point(size=3, color="grey") +
  geom_text_repel(size=6) + 
  geom_point(data=example_frontier, size=4, color="#004C54") +
  geom_line(data=example_frontier, linetype='dashed', size=1, color="#004C54") +
  geom_point(data=new_point, size=4, color="#007a3d",pch=1) +
  geom_text_repel(data=new_point, size=6, color="#007a3d") +
  geom_line(data=new_frontier, linetype='dotted', size=1, color="#007a3d") +
  geom_hline(yintercept = 0) + 
  geom_vline(xintercept = 0) +
  labs(title="Ex. the Pareto frontier for hypothetical Hall of Fame candidates\n") +
  theme(
    # Text
    plot.title = element_text(size=16, family='Palatino', face="bold"),
    plot.subtitle = element_text(size=9, family='Palatino'),
    plot.caption = element_text(face='italic', family='Palatino'),
    axis.title.x = element_text(size=16, face='bold'),
    axis.title.y = element_text(size=16, face='bold'),
    axis.text = element_text(size = 12, face = "italic"),
    panel.background = element_blank()
  )
  
# favresque <- passer_games %>%
#   filter(att > 5) %>%
#   psel(high(att)*high(int)*high(td))
# 
# elite <- 
#   passer_games %>%
#   filter(att >= 10) %>%
#   psel(high(ypa)*high(pct))
# 