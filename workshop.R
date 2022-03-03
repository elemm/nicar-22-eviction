#### Eviction Lab at Princeton University
#### IRE-NICAR 2022 Presentation
#### Written by: Emily Lemmerman 

# Libraries---- 
library(tidyverse)
library(data.table)
library(tidycensus)
library(sf)
# remotes::install_github("walkerke/crsuggest")
library(crsuggest)
# you'll need an API key from one of these services to use this package: Census, Nominatim, Geocodio, or Location IQ 
library(tidygeocoder)
# Sys.setenv(GEOCODIO_API_KEY = "api_key")

# need a Census API key for some of this mapping
# you can get one online at: https://api.census.gov/data/key_signup.html
# to install the key to be saved as a local environment variable, run the following code
# census_api_key("111111abc", install = TRUE)


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
allcities_path <- paste0(getwd(), "/all_sites_weekly_2020_2021.csv")
allstates_path <- paste0(getwd(), "/allstates_weekly_2020_2021.csv")

# filepath to the all_sites_weekly 
read_csv(allcities_path) -> allcities
read_csv(allstates_path) -> allstates

# take an initial look at the data
# some GEOIDs are missing 
glimpse(allcities)
glimpse(allstates)

allcities %>% 
  group_by(city, week_date) %>% 
  summarise(hist_filings_sum = sum(filings_2020),
            pand_filings_sum = sum(filings_avg)) %>% 
  mutate(pct_historical = (hist_filings_sum / pand_filings_sum)* 100) %>%
  ggplot(aes(x = week_date, y = pct_historical)) +
  geom_col() + 
  geom_hline(yintercept = 100,color = elab_orange) + 
  geom_smooth(color = elab_blue,alpha = .7,method = "loess") + 
  facet_wrap(city ~ ., scales = "fixed") +
  scale_y_continuous(limits = c(0,120)) + 
  labs(x = "Date",
       y = "Percent of Historical Filings",
       title = "Pandemic eviction filings as % of historical filings") + 
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 300,
                                  hjust = -.4)) -> facet_by_city_pct

ggsave(facet_by_city_pct, filename = "nicar-22-eviction/facet_by_city_pct.png")

# For all cities at once 
allcities %>%   
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
  ggplot(aes(x = week_date,
             y = filings)) +
  geom_line(aes(color = year)) +
  theme_minimal() + 
  facet_wrap(city ~.,scales = "free") + 
  scale_color_manual(values = c(elab_orange,elab_blue)) +
  theme(axis.text.x = element_text(angle = 300,
                                   hjust = -.4)) + 
  labs(title = "Average Weekly Eviction Filings: Pandemic vs. Pre-Pandemic") -> facet_by_city_raw


ggsave(facet_by_city_raw, filename = "nicar-22-eviction/facet_by_city_raw.png")


## 1 individual city 
allcities %>%   
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
  geom_smooth(aes(color = year),se = FALSE) + 
  theme_minimal() + 
  theme(axis.title.x = element_blank()) + 
  scale_color_manual(values = c(elab_orange,elab_blue)) +
  labs(title = "Weekly Eviction Filings in Austin: Pandemic vs. Pre-Pandemic",
       y = "Number of Filings",
       color = "Time Period") -> atx_filings

ggsave(atx_filings, filename = "nicar-22-eviction/atx_filings.png")


## combining city + state data without overlap 

c <- allcities %>%
  filter(!city %in% c("Albuquerque, NM","Bridgeport, CT", "Hartford, CT", "Indianapolis, IN", "Kansas City, MO","Minneapolis-Saint Paul, MN", "South Bend, IN", "St Louis, MO","Wilmington, DE")) %>%
  select(city, week,week_date, filings_2020, filings_avg) %>%
  rename(site = city)

s <- allstates %>%   
  select(state, week, week_date, filings_2020, filings_avg) %>%
  rename(site = state)

a <- bind_rows(s,c)

a %>% 
  group_by(week,week_date) %>%
  summarise(filings_2020 = sum(filings_2020),
            filings_avg = sum(filings_avg),
            share = filings_2020/filings_avg)

# looking into racial patterns of filing change in Charleston 
allcities %>% 
  filter(str_detect(city, "Charles")) %>% 
  group_by(racial_majority) %>% 
  mutate(count = n_distinct(GEOID)) %>% 
  group_by(week_date,GEOID) %>%
  mutate(pct_historical = (filings_2020 / filings_avg)*100) %>%
  mutate(pct_historical = ifelse(is.infinite(pct_historical),(filings_2020 / (filings_avg + 1))*100,pct_historical)) %>% 
  group_by(racial_majority) %>% 
  summarise(mean(pct_historical,na.rm = T)) 


# # A tibble: 4 × 2
# racial_majority `mean(pct_historical, na.rm = T)`
# <chr>                                       <dbl>
#   1 Black                                        68.2
# 2 Other                                        79.5
# 3 White                                        67.5
# 4 NA                                          116. 

# mapping the percent change by tract in Charleston
shp_df <- get_acs(state = "SC", county = c("Berkeley","Charleston","Dorchester"), geography = "tract", 
                  variables = "B19013_001", geometry = TRUE)

# Note - this won't work for places without GEOID data - i.e. Austin, Richmond
# for these places, map using zip codes
allcities %>% 
  filter(str_detect(city, "Charles")) %>% 
  group_by(week_date,GEOID) %>%
  mutate(pct_historical = (filings_2020 / filings_avg)*100) %>%
  mutate(pct_historical = ifelse(is.infinite(pct_historical),(filings_2020 / (filings_avg + 1))*100,pct_historical)) %>%
  mutate(GEOID = as.character(GEOID)) %>%
  left_join(shp_df, by = "GEOID") -> vis_sf

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
allcities %>% 
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
# add city and state depending on which file you're looking at 
top_evictors_df %>% 
  mutate(full_addr = paste0(xstreet_clean, " Albuquerque",",NM")) %>% 
  geocode(full_addr) -> geocoded_df
  
# plot points on a shapefile map 
# add sf 
my_sf <- st_as_sf(geocoded_df %>% filter(!is.na(lat) & !is.na(long)), coords = c('long', 'lat'))  

shp_df_top_evictors <- get_acs(state = "NM", county = c("Bernalillo"), geography = "tract", 
                               variables = "B19013_001", geometry = TRUE)
suggest_top_crs(shp_df_top_evictors)

shp_df %>% st_transform(crs = 32113) -> shp_st

ggplot() + 
  geom_sf(my_sf, mapping = aes(size = filings), alpha = .2, color = elab_orange)

ggplot(data = shp_df_top_evictors) +
  geom_sf() +
  geom_point(data = geocoded_df, aes(x = long, y = lat, color = filings)) + 
  scale_color_viridis_c(limits=c(0,100))

## using leaflet to just plot locations ---- 
library(leaflet)
library(sp)
leaflet_df <- geocoded_df %>% filter(!is.na(lat) & !is.na(long))

coordinates(leaflet_df) <- ~long+lat

leaflet(leaflet_df) %>%   
  addCircleMarkers(
  label = ~ filings,
  fillColor = "goldenrod",
  fillOpacity = 1,
  radius = 5,
  stroke = F
  ) %>%
  addProviderTiles("CartoDB.Positron")
