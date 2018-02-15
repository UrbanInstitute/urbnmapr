
library(tidyverse)
library(rgeos)
library(maptools)
library(rgdal)
library(broom)
library(readxl)

source('https://raw.githubusercontent.com/UrbanInstitute/urban_R_theme/master/urban_theme_windows.R')

theme_map <- theme(
  axis.text = element_blank(),
  axis.ticks = element_blank(),
  axis.title = element_blank(),
  panel.grid = element_blank(),
  axis.line = element_blank()
)

transform_state <- function(object, rot, scale, shift){
  object %>% elide(rotate = rot) %>%
    elide(scale = max(apply(bbox(object), 1, diff)) / scale) %>%
    elide(shift = shift)
}

# Load shapefiles and fips codes ------------------------------------------
# soucre: https://www.census.gov/geo/maps-data/data/cbf/cbf_zcta.html
zipcodes <- readOGR(dsn = "shapefiles", layer = "cb_2016_us_zcta510_500k", verbose = FALSE) %>%
  spTransform(CRS("+init=epsg:2163"))

# source: https://www.huduser.gov/portal/datasets/usps_crosswalk.html
zipcounty <- read_excel("ZIP_COUNTY_122017.xlsx") %>% 
  select(ZCTA5CE10 = zip, county) %>% 
  mutate(state = substr(county, 1, 2))

akzips <- zipcounty %>% filter(state == "02")
hizips <- zipcounty %>% filter(state == "15")
exclude <- zipcounty %>% filter(state %in% c("02", "15", "60", "66", "69", "72", "78"))


# Alaska
alaska <- zipcodes[zipcodes$ZCTA5CE10 %in% unique(akzips$ZCTA5CE10), ] %>%
  # transform state drops the projecion
  transform_state(-35, 2, c(-2600000, -2300000))

# Return to EPSG 2163 (US National Atlas Equal Area)
proj4string(alaska) <- proj4string(zipcodes)

# Hawaii
hawaii <- zipcodes[zipcodes$ZCTA5CE10 %in% unique(hizips$ZCTA5CE10), ] %>%
  transform_state(-35, 0.8, c(-1170000, -2363000))
proj4string(hawaii) <- proj4string(zipcodes)

# combine, transform, and tidy
zips <-
  zipcodes[!zipcodes$ZCTA5CE10 %in% unique(exclude$ZCTA5CE10), ] %>%
  rbind(alaska) %>%
  rbind(hawaii) %>%
  # convert from EPSG2163 to (US National Atlas Equal Area) WGS84
  spTransform(CRS("+init=epsg:4326")) %>% 
  tidy(region = "GEOID10") %>%
  rename(zip = id) %>%
  as_tibble()

# Plot
zips %>%
  ggplot(aes(long, lat, group = group)) +
  geom_polygon(fill = "grey", color = "#ffffff", size = 0.25) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  theme_map
# ggsave("test.png")


