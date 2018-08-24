# Create map data with AK, HI inset.
# Inspired by http://stackoverflow.com/a/13767984
library(rgeos)
library(maptools)
library(rgdal)
library(tidyverse)
library(broom)

options(scipen = 999)

# Define functions --------------------------------------------------------
transform_state <- function(object, rot, scale, shift){
  object %>%
    elide(rotate = rot) %>%
    elide(scale = max(apply(bbox(object), 1, diff)) / scale) %>%
    elide(shift = shift)
}

# Load shapefiles ---------------------------------------------------------

# set shapefile url
url_base <- "http://www2.census.gov/geo/tiger/GENZ2016/shp/"
shape_base <- paste("cb", 2016, "us", "state", "5m", sep = "_")
url <- paste0(url_base, shape_base, ".zip")

# download data and unzip
temp <- tempfile(fileext = ".zip")

if (!file.exists(temp)) {
  download.file(url, temp)
  temp_dir <- tempdir()
  unzip(temp, exdir = temp_dir)
}

# https://www.census.gov/geo/maps-data/data/tiger-line.html
fifty_states_sp <- readOGR(dsn = temp_dir, layer = shape_base, verbose = FALSE) %>%
  # Convert from NAD83 to EPSG 2163 (US National Atlas Equal Area)
  spTransform(CRS("+init=epsg:2163"))


# alaska ------------------------------------------------------------------

alaska <- fifty_states_sp[fifty_states_sp$NAME == "Alaska", ] %>%
  # transform state drops the projecion
  #                       horizontal vertical
  transform_state(-5, 2, c(-3500000, -200000))

# Return to EPSG 2163 (US National Atlas Equal Area)
proj4string(alaska) <- proj4string(fifty_states_sp)


# hawaii ------------------------------------------------------------------

hawaii <- fifty_states_sp[fifty_states_sp$NAME == "Hawaii", ] %>%
  transform_state(0, 0.8, c(-2500000, -1000000))

# Return to EPSG 2163 (US National Atlas Equal Area)
proj4string(hawaii) <- proj4string(fifty_states_sp)

# puerto rico -------------------------------------------------------------

puerto_rico <- fifty_states_sp[fifty_states_sp$NAME %in% c("Puerto Rico"), ] %>%
  transform_state(rot = 0, scale = 1, shift = c(-1350000, 1000000))

proj4string(puerto_rico) <- proj4string(fifty_states_sp)

# virgin islands ----------------------------------------------------------

virgin_islands <- fifty_states_sp[fifty_states_sp$NAME %in% c("United States Virgin Islands"), ] %>%
  transform_state(rot = 0, scale = 0.1, shift = c(2150000, -1600000))

proj4string(virgin_islands) <- proj4string(fifty_states_sp)

# guam --------------------------------------------------------------------

guam <- fifty_states_sp[fifty_states_sp$NAME %in% c("Guam"), ] %>%
  transform_state(rot = -35, scale = 0.3, shift = c(-2600000, -700000))

proj4string(guam) <- proj4string(fifty_states_sp)

# american samoa ----------------------------------------------------------

american_samoa <- fifty_states_sp[fifty_states_sp$NAME %in% c("American Samoa"), ] %>%
  transform_state(rot = -35, scale = 0.15, shift = c(-4250000, -1450000))

proj4string(american_samoa) <- proj4string(fifty_states_sp)

# mariana islands ---------------------------------------------------------

mariana_islands <- fifty_states_sp[fifty_states_sp$NAME %in% c("Commonwealth of the Northern Mariana Islands"), ] %>%
  transform_state(rot = -35, scale = 0.1, shift = c(-3600000, -1250000))

proj4string(mariana_islands) <- proj4string(fifty_states_sp)

mariana_islands <- mariana_islands %>%
  # transforms into longitude/latitude
  spTransform(CRS("+init=epsg:4326")) %>%  # prime meridian/equator
  tidy(region = "NAME") %>%
  as_tibble() %>%
  filter(piece %in% 1:2)

# combine, transform, and tidy

ellided_areas <- c("Alaska", "Hawaii", "Puerto Rico", "American Samoa", "Guam", "Commonwealth of the Northern Mariana Islands", "United States Virgin Islands")

fifty_states <-
  fifty_states_sp[!fifty_states_sp$NAME %in% ellided_areas, ] %>%
  rbind(alaska) %>%
  rbind(hawaii) %>%
  rbind(puerto_rico) %>%
  rbind(virgin_islands) %>%
  rbind(guam) %>%
  rbind(american_samoa) %>%
  # convert from EPSG2163 to (US National Atlas Equal Area) WGS84
  spTransform(CRS("+init=epsg:4326")) %>%
  tidy(region = "NAME") %>%
  mutate(id = id) %>%
  as_tibble() %>%
  rbind(mariana_islands)

# star for Washington, D.C. -----------------------------------------------
star <- tribble(
  ~x, ~y, ~order, ~hole, ~piece, ~group, ~id,
  1, 0, 1, FALSE, 1, "Washington, D.C.",  "Washington, D.C.",
  0.3, -0.2, 2, FALSE, 1, "Washington, D.C.",  "Washington, D.C.",
  0.3, -0.95, 3, FALSE, 1, "Washington, D.C.",  "Washington, D.C.",
  -0.1, -0.375, 4, FALSE, 1, "Washington, D.C.",  "Washington, D.C.",
  -0.8, -0.6, 5,  FALSE, 1, "Washington, D.C.",  "Washington, D.C.",
  -0.39, 0, 6,  FALSE, 1, "Washington, D.C.",  "Washington, D.C.",
  -0.8, 0.6, 7,  FALSE, 1, "Washington, D.C.",  "Washington, D.C.",
  -0.1, 0.375, 8, FALSE, 1, "Washington, D.C.",  "Washington, D.C.",
  0.3, 0.95, 9, FALSE, 1, "Washington, D.C.",  "Washington, D.C.",
  0.3, 0.2, 10, FALSE, 1, "Washington, D.C.",  "Washington, D.C.",
  1, 0, 11, FALSE, 1, "Washington, D.C.",  "Washington, D.C."
) %>%
  # roate star by mutliplying points by rotation matrix
  mutate(long = x * cos(pi / 2) + y * -sin(pi / 2),
         lat = x * sin(pi / 2) + y * cos(pi / 2)) %>%
  # scale the plots big time
  mutate(long = long,
         lat = lat) %>%
  # transpose the plot to near DC
  mutate(long = long - 75,
         lat = lat + 37) %>%
  select(-x, -y)

# combine states and territories ------------------------------------------

ccdf <- rbind(fifty_states, star)

rm(alaska, hawaii, puerto_rico, virgin_islands, guam, american_samoa, mariana_islands, fifty_states, star)

#write_csv(combined, "output-data/ccdf-map.csv")
