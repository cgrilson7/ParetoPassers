library(tidyverse)

# Dependencies:
require(tidyverse); require(rvest); require(foreach); 
require(magrittr); require(pbapply);

# Helpful functions
nabs <- function(x) {
  
  ## Description
  # nabs() returns x after first converting it to class numeric via character
  # Its primary use is converting objects of class factor to numeric
  # It also provides a more concise wrapper for standard numeric conversion
  
  return(as.numeric(as.character(x)))
  
}

# get_lines
# Loads one page of stat lines at a time from P-F-R play finder (query detailed below)
get_lines <- function(offset=0){
  
  # Description
  # 
  
  url <- paste0(
    "https://www.pro-football-reference.com/play-index/pgl_finder.cgi?request=1",
    "&match=game&year_min=1970&year_max=2018&season_start=1&season_end=-1&game_type=E", # all games played in regular/postseason, since AFL-NFL merger in 1970
    "&career_game_num_min=1&career_game_num_max=500", # no limits on when in players' careers the game happened
    "&game_num_min=0&game_num_max=99&week_num_min=0",  # no limits on when in the season the game happened
    "&week_num_max=99&c1stat=pass_att&c1comp=gt&c1val=1&c2stat=rush_att&c2comp=gt&c3stat=fumbles&c3comp=gt&c5val=1.0", #telling the play finder to include passing, rushing and fumbles statistics
    "&order_by=game_date", # ordered descending (most recent games first)
    "&offset=", offset # 100 games displayed per page; will need to loop over this 
    )
  
  out <- tryCatch({
    
    page <- read_html(url)
    
    # Get schedule table
    
    page %>%
      html_nodes("table.sortable.stats_table") %>%
      html_table() -> lines_table
    
    lines_df <- lines_table[[1]][-1,-1]
    colnames(lines_df) <-
      c("player", "pos", "age",
        "date", "league",
        "team", "is_away", "opp","result",
        "game_num", "week", "day",
        "cmp", "att", "pct",
        "yds", "td", "int", "rtg",
        "sk", "sk_yds",
        "ypa", "adj_ypa",
        "rush", "rush_yds", "ypr", "rush_td",
        "fmb", "ff", "fr", "f_yds", "f_td")
    
    lines_df %<>%
      filter(!(week %in% c("Week", ""))) %>% # get rid of relic header rows
      mutate(is_away = is_away != "") %>% # 
      mutate_at(vars(c(age, game_num, week, cmp:f_td)), nabs) # convert chr columns to numeric
    
    # Get player P-F-R ids from links
    
    page %>% 
      html_nodes("table.sortable.stats_table") %>%
      html_nodes("a") %>%
      html_attr("href") -> all_links
    
    player_links <- all_links[grepl("players/[A-Z]+", all_links)]
    
    lines_df$player_page <- player_links
  
    return(lines_df)
  },
  error = function(cond){
    
    message(paste("^ The URL does not seem to exist:",url))
    closeAllConnections()
    
  })
  
  return(out)
  
}

# Loop over pages, building list of stat line data.frames
stat_lines_list <- list()
i = 1
for(offset in seq(0,30600,100)){
  stat_lines_list[[i]] <- get_lines(offset)
  i = i + 1
}

# Bind data.frames together
passer_games <- do.call('rbind', all_games)

# Write to file
save(passer_games, file = "input/passer_games.Rdata")

