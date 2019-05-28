# Dependencies
library(tidyverse); library(rPref); library(magrittr); library(ggrepel)

# Load data from input folder
load("input/rb_lines.Rdata")

frontier <- rb_lines %>%
  psel(high(rush_yds)*high(rec_yds)) %>%
  # Order alphabetically and then add team color list:
  arrange(player)
team_color <- c(
    "#4F2683", # Peterson (Vikings)
    "#FB4F14", # Dillon (Bengals)
    "#D50A0A", # Martin (Buccaneers)
    "#003594", # Walker (Cowboys)
    "#046A38", # Williams (Seahawks)
    "#FFB612", # Bell (Steelers)
    "#0080C6", # James (Chargers)
    rep("#0B215E",2), # Faulk (Retro Rams)
    "#E31837" # Holmes (Chiefs)
  )
names(team_color) <- frontier$player_page # need another unique identifier
  
png("test.png", height = 2300, width=3000, units='px', res=300)
ggplot(rb_lines, aes(x=rush_yds, y=rec_yds)) +
  geom_point(alpha=0.1) + 
  # First point: Marshall Faulk (54 rushing, 204 receiving)
  geom_segment(x=0, xend=54, y=204, yend=204, linetype='dotdash', color="#5b5b5b", size = 1) +
  geom_segment(x=296,xend=296,y=0,yend=19, linetype='dotdash', color="#5b5b5b", size = 1) +
  # geom_point(data=frontier, shape=21, size=6, stroke=1, aes(fill = player, color = player)) +
  geom_line(data=frontier, color = "#5b5b5b", linetype='dotdash', size = 1) +
  geom_label_repel(data=frontier,
                   aes(label=
                        paste(
                     paste0(player, " (",team, ")"),
                     paste0(format.Date(date, "%m/%d/%y"), " vs. ", opp),
                     paste0("(",
                            rush_yds, 
                            ifelse(player=="Herschel Walker", " rushing, ",", "),
                            rec_yds,
                            ifelse(player=="Herschel Walker", " receiving)", ")")),
                     sep="\n"),
                     color=player_page),
                   fontface='bold',
                   family='Palatino',
                   size = 4,
                   box.padding = 1) +
  scale_color_manual(values=team_color) +
  geom_point(data=frontier, size=4) + #, shape=21, aes(fill=player_page)) + scale_fill_manual(values=team_fill) +
  geom_hline(yintercept = 0) + 
  geom_vline(xintercept = 0) +
  scale_x_continuous(limits=c(0, 375), expand=c(0,0))+ 
  scale_y_continuous(limits=c(0, 310), expand=c(0,0))+ 
  labs(x="Yards Rushing",
       y = "Yards Receiving",
       title="Top All-Around Running Back Performances of the Last 20 Years\n\n",
       # subtitle="Single-game rushing/receiving yardage on the 'Pareto frontier', past which no RB has gained more yards in both categories at once.\n(Pareto efficiency explained further below)",
       caption="Source: Pro-Football-Reference.com's play index finder, 1970 - 2019 (Wild Card round)") +
  theme(
    legend.position="none",
    # Text
    plot.title = element_text(size=18, family='Palatino', face="bold"),
    plot.subtitle = element_text(size=12, family='Palatino'),
    plot.caption = element_text(face='italic', family='Palatino'),
    axis.title.x = element_text(size=14, face='bold', family = 'Palatino'),
    axis.title.y = element_text(size=14, face='bold', family = 'Palatino'),
    axis.text = element_text(size = 12, face = "italic"),
    panel.background = element_blank()
  )
dev.off()