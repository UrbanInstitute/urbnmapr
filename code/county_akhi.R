
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

# Load shapefiles and FIPS codes-------------------------------------------
counties <- readOGR(dsn = "shapefiles", layer = "cb_2016_us_county_5m", verbose = FALSE) %>%
  spTransform(CRS("+init=epsg:2163"))

county_fips <- read_csv("national_county.txt", 
                        col_names =  c("state", "state_code", "county_code", 
                                       "county_name", "fips_class")) %>%
  mutate(county = paste0(state_code, county_code))

# Define functions --------------------------------------------------------
transform_state <- function(object, rot, scale, shift){
  object %>% elide(rotate = rot) %>%
    elide(scale = max(apply(bbox(object), 1, diff)) / scale) %>%
    elide(shift = shift)
}


# Alaska
alaska <- counties[counties$STATEFP == "02", ] %>%
  # transform state drops the projecion
  transform_state(-35, 2, c(-2600000, -2300000))

# Return to EPSG 2163 (US National Atlas Equal Area)
proj4string(alaska) <- proj4string(counties)

# Hawaii
hawaii <- counties[counties$STATEFP == "15", ] %>%
  transform_state(-35, 0.8, c(-1170000, -2363000))
proj4string(hawaii) <- proj4string(counties)

# combine, transform, and tidy
allcounties <-
  counties[!counties$STATEFP %in% c("02", "15", "60", "66", "69", "72", "78"), ] %>%
  rbind(alaska) %>%
  rbind(hawaii) %>%
  # convert from EPSG2163 to (US National Atlas Equal Area) WGS84
  spTransform(CRS("+init=epsg:4326")) %>% 
  tidy(region = "GEOID") %>%
  rename(county = id) %>%
  as_tibble() %>% 
  left_join(county_fips, by = "county") %>% 
  select(-fips_class)

uscounties <- left_join(allcounties, county_fips, by = "county")
x <- anti_join(allcounties, county_fips, by = "county")
unique(x$county)


# Plot
allcounties %>%
  ggplot(aes(long, lat, group = group)) +
  geom_polygon(fill = "grey", color = "#ffffff", size = 0.25) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  urban_map


