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
get_rb_lines <- function(offset=0){
  
  # Description
  # Scrapes all games since 1970 from P-F-R where player had at least 5 rushing attempts

  url <- paste0(
    "https://www.pro-football-reference.com/play-index/pgl_finder.cgi?request=1&match=game&year_min=1970&year_max=2018&season_start=1&season_end=-1&is_starter=E&game_type=E&career_game_num_min=1&career_game_num_max=500&game_num_min=0&game_num_max=99&week_num_min=0&week_num_max=99&c1stat=rush_att&c1comp=gt&c1val=5&c2stat=rec&c2comp=gt&c2val=0&c3stat=fumbles&c3comp=gt&c3val=0&c4stat=ret_yds&c4comp=gt&c4val=0&c5val=1.0&order_by=game_date", # ordered descending (most recent games first)
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
        "date", "league", "team", "is_away", "opp","result", "game_num", "week", "day",
        "rush_att", "rush_yds", "yprush", "rush_td",
        "tgt", "rec", "rec_yds", "yprec", "rec_td", "catch_pct", "yptgt",
        "fmb", "ff", "fr", "f_yds", "f_td",
        "touches", "tot_off", "yds_scm", "ap_yds", "ret_yds")
    
    lines_df %<>%
      filter(!(week %in% c("Week", ""))) %>% # get rid of relic header rows
      mutate(is_away = is_away != "") %>% # 
      mutate_at(vars(c(age, game_num, week, rush_att:rec_td, yptgt:ret_yds)), nabs) %>% # convert chr columns to numeric
      mutate(catch_pct = rec/tgt) # replace catch_pct column with calculation
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
rb_lines_list <- list()
i = 1
for(offset in seq(0,46200,100)){
  rb_lines_list[[i]] <- get_rb_lines(offset)
  i = i + 1
  print(i)
}

# Bind data.frames together
rb_lines <- do.call('rbind', rb_lines_list)

# Remove asterisks from player names
rb_lines$player <- gsub("[*]", "",rb_lines$player)

# Write to file
save(rb_lines, file = "input/rb_lines.Rdata")