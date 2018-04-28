### helper functions for parsing shapefile data --------------------------------

# load necessary libraries -----------------------------------------------------
library(dplyr)
library(readr)
library(rgeos)
library(maptools)
library(rgdal)
library(magrittr)
library(broom)

# transform AK/HI from shapefile -----------------------------------------------
# see https://github.com/wmurphyrd/fiftystater ---------------------------------
transform_state <- function(object, rot, scale, shift) {
  object %>% elide(rotate = rot) %>%
    elide(scale = max(apply(bbox(object), 1, diff)) / scale) %>%
    elide(shift = shift)
}

# retrieve shapefile from census and apply AK/HI transformations ---------------
get_shapefile <- function(year, level, resolution) {
  # set shapefile url
  url_base <- 'http://www2.census.gov/geo/tiger/GENZ2016/shp/'
  shape_base <- paste('cb', year, 'us', level, resolution, sep = '_')
  url <- paste0(url_base, shape_base, '.zip')

  # download data and unzip
  temp <- tempfile(fileext = '.zip')
  download.file(url, temp)

  temp_dir <- tempdir()
  unzip(temp, exdir = temp_dir)

  # read shapefile
  shapes <-
    readOGR(dsn = temp_dir,
            layer = shape_base,
            verbose = F) %>%
    spTransform(CRS("+init=epsg:2163"))

  # transform AK/HI
  alaska <- shapes[shapes$STATEFP == "02", ] %>%
    transform_state(-35, 2, c(-2600000, -2300000))

  proj4string(alaska) <- proj4string(shapes)

  hawaii <- shapes[shapes$STATEFP == "15", ] %>%
    transform_state(-35, 0.8, c(-1170000, -2363000))

  proj4string(hawaii) <- proj4string(shapes)

  # recombine shapefile
  exclude <- c("02", "15", "60", "66", "69", "72", "78")

  mapdata <-
    shapes[!shapes$STATEFP %in% exclude, ] %>%
    rbind(alaska) %>%
    rbind(hawaii) %>%
    # convert from EPSG2163 to (US National Atlas Equal Area) WGS84
    spTransform(CRS("+init=epsg:4326"))

  mapdata

}

# download and clean state fips data from census
get_state_fips <- function() {
  url <- 'https://www2.census.gov/geo/docs/reference/state.txt'

  state_fips <-
    read_delim(url,
               delim = '|',
               skip = 1,
               col_names = c('state_fips', 'state_abbv', 'state_name', 'state_ens'),
               col_types = 'cccc') %>%
    select(-state_ens)

  state_fips
}

# download and clean county fips data from census
get_county_fips <- function() {
  url <- 'https://www2.census.gov/geo/docs/reference/codes/files/national_county.txt'

  county_fips <-
    read_csv(url,
             col_names = c('state_abbv', 'state_fips', 'county_fips', 'county_name', 'fips_class'),
             col_types = 'ccccc') %>%
    mutate(county_fips = paste0(state_fips, county_fips)) %>%
    # recode county changes - see https://www.census.gov/geo/reference/county-changes.html
    # Shannon County, SD changed name to Oglala Lakota County effective May 1, 2015
    mutate(county_name = if_else(county_fips == '46113', 'Oglala Lakota County', county_name)) %>%
    mutate(county_fips = if_else(county_fips == '46113', '46102', county_fips)) %>%
    # Wade Hampton Census Area, AK changed name and code to Kusilvak Census Area effective July 1, 2015
    mutate(county_name = if_else(county_fips == '02270', 'Kusilvak Census Area', county_name)) %>%
    mutate(county_fips = if_else(county_fips == '02270', '02158', county_fips)) %>%
    # add in state name from state fips file
    left_join(get_state_fips())

  county_fips
}
