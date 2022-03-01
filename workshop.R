
# Libraries
library(tidyverse)
library(data.table)
library(tidycensus)
library(sf)
# remotes::install_github("walkerke/crsuggest")
library(crsuggest)

# color presets 
elab_orange <- "#E24000"
elab_blue <- "#434878"
elab_green <- "#2C897F"
labels_gray <- "#333333"
background_gray <- "#f4f7f9"
title_black <- "#050403"
blog_background <- "#EEF2F5"


# if you saved the downloaded data in the same place you cloned your github repo to, you 
# should be able to access it here
allsites_path <- paste0(getwd(), "/all_sites_weekly_2020_2021.csv")

# filepath to the all_sites_weekly 
read_csv(allsites_path) -> allsites

# take an initial look at the data
summary(allsites)

allsites %>% 
  mutate(pct_historical = filings_2020 / filings_avg) %>% 
  ggplot(aes(x = week_date, y = pct_historical)) +
  geom_col() + 
  facet_wrap(city ~ .)


# For all sites at once 
allsites %>%   
  group_by(week, week_date,city) %>% 
  summarize(filings_2020 = sum(filings_2020),
            filings_avg = sum(filings_avg, na.rm = T)) %>%
  pivot_longer(cols = filings_2020:filings_avg,
               names_to = "year",
               values_to = "filings",
               names_prefix = "filings_") %>% 
  mutate(year = recode(year,
                       avg = "pre-pandemic")) %>% 
  mutate(year = recode(year,
                       "2020" = "pandemic")) %>% 
  ggplot(aes(x = week,
             y = filings)) +
  geom_line(aes(color = year)) +
  theme_minimal() + 
  facet_wrap(city ~.) + 
  scale_color_manual(values = c(elab_orange,elab_blue)) +
  labs(title = "Weekly Eviction Filings: Pandemic vs. Pre-Pandemic")

allsites %>%   
  filter(str_detect(city, "Austin")) %>% 
  group_by(week_date,city) %>% 
  summarize(filings_2020 = sum(filings_2020),
            filings_avg = sum(filings_avg, na.rm = T)) %>%
  pivot_longer(cols = filings_2020:filings_avg,
               names_to = "year",
               values_to = "filings",
               names_prefix = "filings_") %>% 
  mutate(year = recode(year,
                       avg = "pre-pandemic")) %>% 
  mutate(year = recode(year,
                       "2020" = "pandemic")) %>% 
  ggplot(aes(x = week_date,
             y = filings)) +
  geom_line(aes(color = year)) +
  facet_wrap(city ~.) + 
  theme_minimal() + 
  scale_color_manual(values = c(elab_orange,elab_blue)) +
  labs(title = "Weekly Eviction Filings in Austin: Pandemic vs. Pre-Pandemic")


# looking into racial patterns of filing change in Charleston 
allsites %>% 
  filter(str_detect(city, "Charles")) %>% 
  group_by(racial_majority) %>% 
  mutate(count = n_distinct(GEOID)) %>% 
  group_by(week_date,GEOID) %>%
  mutate(pct_historical = (filings_2020 / filings_avg)*100) %>%
  mutate(pct_historical = ifelse(is.infinite(pct_historical),(filings_2020 / (filings_avg + 1))*100,pct_historical)) %>% 
  group_by(racial_majority) %>% 
  summarise(mean(pct_historical,na.rm = T))


# mapping the percent change by tract in Charleston
shp_df <- get_acs(state = "SC", county = c("Berkeley","Charleston","Dorchester"), geography = "tract", 
                  variables = "B19013_001", geometry = TRUE)

# Note - this won't work for places without GEOID data - i.e. Austin, Richmond, Philadelphia
# for these places, map using zip codes
allsites %>% 
  filter(str_detect(city, "Charles")) %>% 
  group_by(week_date,GEOID) %>%
  mutate(pct_historical = (filings_2020 / filings_avg)*100) %>%
  mutate(pct_historical = ifelse(is.infinite(pct_historical),(filings_2020 / (filings_avg + 1))*100,pct_historical)) %>%
  mutate(GEOID = as.character(GEOID)) %>%
  left_join(shp_df, by = "GEOID") -> vis_sf

n_distinct(vis_sf$GEOID)
n_distinct(vis_sf$week_date)

vis_sf %>% 
  ggplot(aes(fill = pct_historical, geometry = geometry)) + 
  geom_sf(color = NA) + 
  scale_fill_viridis_c(option = "magma",direction = -1,limits = c(0,100)) 


### Same process as above, but in Fort Dallas ----------
# mapping the percent change by tract in Dallas
shp_df <- get_acs(state = "TX", county = c("Dallas"), geography = "tract", 
                  variables = "B19013_001", geometry = TRUE)

# Note - this won't work for places without GEOID data - i.e. Austin, Richmond, Philadelphia
# for these places, map using zip codes
allsites %>% 
  filter(str_detect(city, "Dallas")) %>% 
  group_by(week_date,week,GEOID) %>%
  summarize(filings_2020 = sum(filings_2020),
            filings_avg = sum(filings_avg, na.rm = T)) %>%
  mutate(pct_historical = (filings_2020 / filings_avg)*100) %>%
  mutate(pct_historical = ifelse(is.infinite(pct_historical),(filings_2020 / (filings_avg + 1))*100,pct_historical)) %>%
  mutate(GEOID = as.character(GEOID)) %>%
  inner_join(shp_df, by = "GEOID") -> vis_sf

# suggest best CRS 
suggest_top_crs(vis_sf$geometry)

n_distinct(vis_sf$GEOID)
n_distinct(vis_sf$week_date)

vis_sf %>% 
  ggplot(aes(fill = pct_historical, geometry = geometry)) + 
  geom_sf(color = NA) + 
  coord_sf(crs = 32138) + 
  scale_fill_viridis_c(direction = 1,limits = c(0,130),na.value = background_gray) + 
  theme_void() + 
  theme(panel.background = element_rect(fill = background_gray)) + 
  labs(fill = "Percent of historical evictions",
       title = "Percent of historical evictions in Dallas")



##### ---- TOP EVICTORS -------------------------------------------------------

# load hotspots filepaths 
hotspots_paths <- list.files(paste0(getwd(),"/hotspots_reports"),full.names = T)
#change number here to get different filepath from vector
top_evictors_df <- read.csv(hotspots_paths[1])

###### data dictionary: also available on README: 
# position = ranking among "top evictors"
# time period - there are 2 start dates in the file - one ranking for start of pandemic - present, another 
# for the the 8-week period before the most recent quarterly update in December. 
# xplaintiff = name of the plaintiff in the eviction filing
# xstreet_clean = cleaned address 
# filings = number of filings 
# top100 = proportion of eviction filings made up by the top 100 highest evicting addresses
# new data will be avaiable in March
########


top_evictors_df 




   
