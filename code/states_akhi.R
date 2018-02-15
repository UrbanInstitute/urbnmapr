
library(tidyverse)
library(rgeos)
library(maptools)
library(rgdal)
library(broom)

source('https://raw.githubusercontent.com/UrbanInstitute/urban_R_theme/urban_R_theme_revamp/urban_theme_windows.R')

theme_map <- theme(
  axis.text = element_blank(),
  axis.ticks = element_blank(),
  axis.title = element_blank(),
  panel.grid = element_blank(),
  axis.line = element_blank()
)

# Load shapefiles and fips codes ------------------------------------------
states <- readOGR(dsn = "shapefiles", layer = "cb_2016_us_state_5m", verbose = FALSE) %>%
  spTransform(CRS("+init=epsg:2163"))

# source: https://www.census.gov/geo/reference/ansi_statetables.html
state_fips <- read_csv("state_fips.csv", skip = 1, col_names = c("state_name", "state_code", "state"),
                       col_types = cols(state_name = col_character(),
                                        state_code = col_character(),
                                        state = col_character())) %>%
  mutate(state_code = ifelse(str_length(state_code) == 1, paste0("0", state_code), state_code))


# Define functions --------------------------------------------------------
transform_state <- function(object, rot, scale, shift){
  object %>% elide(rotate = rot) %>%
    elide(scale = max(apply(bbox(object), 1, diff)) / scale) %>%
    elide(shift = shift)
}


alaska <- states[states$STATEFP == "02", ] %>%
  # transform state drops the projecion
  transform_state(-35, 2, c(-2600000, -2300000))

# Return to EPSG 2163 (US National Atlas Equal Area)
proj4string(alaska) <- proj4string(states)

# Hawaii
hawaii <- states[states$STATEFP == "15", ] %>%
  transform_state(-35, 0.8, c(-1170000, -2363000))
proj4string(hawaii) <- proj4string(states)

# combine, transform, and tidy
states51 <-
  states[!states$STATEFP %in% c("02", "15", "60", "66", "69", "72", "78"), ] %>%
  rbind(alaska) %>%
  rbind(hawaii) %>%
  # convert from EPSG2163 to (US National Atlas Equal Area) WGS84
  spTransform(CRS("+init=epsg:4326")) %>% 
  tidy(region = "STATEFP") %>%
  rename(state_code = id) %>% 
  as_tibble() %>%
  left_join(state_fips, by = "state_code")


# Plot
states51 %>%
  ggplot(aes(long, lat, group = group)) +
  geom_polygon(fill = "grey", color = "#ffffff", size = 0.25) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  urban_map


