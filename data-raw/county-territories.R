
# Create a county map with all of the territories

library(dplyr)
library(readr)
library(rgeos)
library(maptools)
library(rgdal)
library(magrittr)
library(broom)

options(scipen = 999)

# Define functions --------------------------------------------------------
transform_state <- function(object, rot, scale, shift){
  object %>%
    elide(rotate = rot) %>%
    elide(scale = max(apply(bbox(object), 1, diff)) / scale) %>%
    elide(shift = shift)
}

# load utility functions
source('data-raw/utils.R')

# Load shapefiles ---------------------------------------------------------

url_base <- "http://www2.census.gov/geo/tiger/GENZ2016/shp/"
shape_base <- paste("cb", 2016, "us", "county", "5m", sep = "_")
url <- paste0(url_base, shape_base, ".zip")

# download data and unzip
temp <- tempfile(fileext = ".zip")

if (!file.exists(temp)) {
  download.file(url, temp)
  temp_dir <- tempdir()
  unzip(temp, exdir = temp_dir)
}

# https://www.census.gov/geo/maps-data/data/tiger-line.html
counties_sp <- readOGR(dsn = temp_dir, layer = shape_base, verbose = FALSE) %>%
  # Convert from NAD83 to EPSG 2163 (US National Atlas Equal Area)
  spTransform(CRS("+init=epsg:2163"))


exclude_names <- c("Alaska", "Hawaii", "Puerto Rico", "American Samoa", "Guam", "Commonwealth of the Northern Mariana Islands", "United States Virgin Islands")
exclude_codes <- c("02", "15", "60", "66", "69", "72", "78")
testmap <- counties_sp[!counties_sp$STATEFP %in% exclude_codes, ]

# alaska ------------------------------------------------------------------

alaska <- counties_sp[counties_sp$STATEFP == "02", ] %>%
  # transform state drops the projecion
  #                       horizontal vertical
  transform_state(-35, 2, c(-2600000, -2300000))

# Return to EPSG 2163 (US National Atlas Equal Area)
proj4string(alaska) <- proj4string(counties_sp)

# hawaii ------------------------------------------------------------------

hawaii <- counties_sp[counties_sp$STATEFP == "15", ] %>%
  transform_state(-35, 0.8, c(-1170000, -2363000))

# Return to EPSG 2163 (US National Atlas Equal Area)
proj4string(hawaii) <- proj4string(counties_sp)




# guam --------------------------------------------------------------------

guam <- counties_sp[counties_sp$STATEFP %in% c("66"), ] %>%
  transform_state(rot = -35, scale = 0.2, shift = c(-180000, -2700000))

proj4string(guam) <- proj4string(counties_sp)



# puerto rico -------------------------------------------------------------

puerto_rico <- counties_sp[counties_sp$STATEFP %in% c("72"), ] %>%
  transform_state(rot = 20, scale = .5, shift = c(200000, -2500000))

proj4string(puerto_rico) <- proj4string(counties_sp)



# virgin islands ----------------------------------------------------------

virgin_islands <- counties_sp[counties_sp$STATEFP %in% c("78"), ] %>%
  transform_state(rot = 0, scale = 0.2, shift = c(1550000, -2700000))

proj4string(virgin_islands) <- proj4string(counties_sp)



# mariana islands ---------------------------------------------------------

mariana_islands <- counties_sp[counties_sp$STATEFP %in% c("69"), ] %>%
  transform_state(rot = -35, scale = 0.3, shift = c(2150000, -2450000))

proj4string(mariana_islands) <- proj4string(counties_sp)

test <- rbind(testmap, hawaii, alaska, guam, puerto_rico, virgin_islands, mariana_islands)
plot(test)



# american samoa ----------------------------------------------------------

american_samoa <- counties_sp[counties_sp$STATEFP %in% c("60"), ] %>%
  transform_state(rot = 0, scale = 0.1, shift = c(-1250000, -5050000))
proj4string(american_samoa) <- proj4string(counties_sp)

# treat islands differently
as1 <- american_samoa[!american_samoa$NAME %in% c("Rose Island", "Swains Island", "Manu'a"), ] %>%
  transform_state(rot = 0, scale = 1.2, shift = c(950000, -2350000))
proj4string(as1) <- proj4string(counties_sp)

as2 <- american_samoa[american_samoa$NAME %in% c("Manu'a"), ] %>%
  transform_state(rot = 0, scale = 1.2, shift = c(1450000, -2800000))
proj4string(as2) <- proj4string(counties_sp)

american_samoa <- rbind(as1, as2) %>%
  # angle and size need to be slightly adjusted
  transform_state(rot = 15, scale = 1, shift = c(1000000,-3000000))
proj4string(american_samoa) <- proj4string(counties_sp)



test <- rbind(testmap, hawaii, alaska, guam, puerto_rico, virgin_islands, mariana_islands,
              american_samoa)
plot(test)


# combine and convert to tibble -------------------------------------------

territories_county <-
  rbind(alaska, hawaii, alaska, guam, puerto_rico, virgin_islands,
        mariana_islands, american_samoa) %>%
  # convert from EPSG2163 to (US National Atlas Equal Area) WGS84
  spTransform(CRS("+init=epsg:4326")) %>%
  tidy(region = "GEOID") %>%
  rename(county_fips = id) %>%
  as_tibble() %>%
  # get_county_fips() found in utils.R
  left_join(get_county_fips(), by = "county_fips")
save(territories_county, file = 'data/county-territories.rda', compress = 'bzip2')



# test merge with urbnmapr::counties --------------------------------------


x <- rbind(territories_county,
           filter(urbnmapr::counties, !state_name %in% c("Alaska", "Hawaii")))

urbnthemes::set_urban_defaults("print")

ggplot() +
  geom_polygon(data = x, mapping = aes(x = long, y = lat, group = group),
               fill = "white", color = "black") +
  # urbnthemes::theme_urban_map() +
  geom_text(data = territories_labels, mapping = aes(x = long, y = lat,
                                                     label = state_name)) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45)
