
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


exclude_names <- c("Alaska", "Hawaii", "Puerto Rico", "American Samoa", "Guam", "Commonwealth of the Northern Mariana Islands", "United States Virgin Islands")
exclude_codes <- c("02", "15", "60", "66", "69", "72", "78")
testmap <- counties_sp[!counties_sp$STATEFP %in% exclude_codes, ]


# guam --------------------------------------------------------------------

guam <- counties_sp[counties_sp$STATEFP %in% c("66"), ] %>%
  transform_state(rot = -35, scale = 0.2, shift = c(-180000, -2520000))

proj4string(guam) <- proj4string(counties_sp)

test <- rbind(testmap, hawaii, alaska, guam)
plot(test)


# puerto rico -------------------------------------------------------------

puerto_rico <- counties_sp[counties_sp$STATEFP %in% c("72"), ] %>%
  transform_state(rot = 0, scale = .5, shift = c(200000, -2500000))

proj4string(puerto_rico) <- proj4string(counties_sp)



# american samoa ----------------------------------------------------------

american_samoa <- counties_sp[counties_sp$STATEFP %in% c("60"), ] %>%
  transform_state(rot = 0, scale = 0.1, shift = c(-1250000, -5050000))

as1 <- american_samoa[american_samoa$NAME %in% c("Manu'a"), ] %>%
  transform_state(rot = 0, scale = 0.5, shift = c(-1250000, -5050000))

as1 <- american_samoa[american_samoa$NAME %in% c("Acadia"), ] %>%
  transform_state(rot = 0, scale = 0.1, shift = c(-1250000, -5050000))


proj4string(as1) <- proj4string(counties_sp)

test <- rbind(testmap, hawaii, alaska, guam, puerto_rico, as1)
plot(test)

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

as1 <-

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

