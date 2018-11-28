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

  # transform AK
  alaska <- shapes[shapes$STATEFP == "02", ] %>%
    transform_state(-35, 2, c(-2600000, -2300000))

  proj4string(alaska) <- proj4string(shapes)

  # transform HI

  hawaii <- shapes[shapes$STATEFP == "15", ] %>%
    transform_state(-35, 0.8, c(-1170000, -2363000))

  proj4string(hawaii) <- proj4string(shapes)

  # transform Guam

  guam <- shapes[shapes$STATEFP %in% c("66"), ] %>%
    transform_state(rot = -35, scale = 0.2, shift = c(-180000, -2700000))

  proj4string(guam) <- proj4string(shapes)


  # transform Puerto Rico

  puerto_rico <- shapes[shapes$STATEFP %in% c("72"), ] %>%
    transform_state(rot = 20, scale = .5, shift = c(200000, -2500000))

  proj4string(puerto_rico) <- proj4string(shapes)


  # transform American Samoa

  american_samoa <- shapes[shapes$STATEFP %in% c("60"), ] %>%
    transform_state(rot = 0, scale = 0.1, shift = c(-1250000, -5050000))
  proj4string(american_samoa) <- proj4string(shapes)


  # treat islands differently
  as1 <- american_samoa[!american_samoa$NAME %in% c("Rose Island", "Swains Island", "Manu'a"), ] %>%
    transform_state(rot = 0, scale = 1.2, shift = c(950000, -2350000))
  proj4string(as1) <- proj4string(shapes)

  as2 <- american_samoa[american_samoa$NAME %in% c("Manu'a"), ] %>%
    transform_state(rot = 0, scale = 1.2, shift = c(1450000, -2800000))
  proj4string(as2) <- proj4string(shapes)

  american_samoa <- rbind(as1, as2) %>%
    # angle and size need to be slightly adjusted
    transform_state(rot = 15, scale = 1, shift = c(1000000,-3000000))
  proj4string(american_samoa) <- proj4string(shapes)

  # transform US Virgin Islands

  virgin_islands <- shapes[shapes$STATEFP %in% c("78"), ] %>%
    transform_state(rot = 0, scale = 0.2, shift = c(1550000, -2700000))

  proj4string(virgin_islands) <- proj4string(shapes)


  # transform Mariana Islands

  mariana_islands <- shapes[shapes$STATEFP %in% c("69"), ] %>%
    transform_state(rot = -35, scale = 0.3, shift = c(2150000, -2450000))

  proj4string(mariana_islands) <- proj4string(shapes)


  # recombine shapefile
  exclude <- c("02", "15", "60", "66", "69", "72", "78")

  mapdata <-
    shapes[!shapes$STATEFP %in% exclude, ] %>%
    rbind(alaska, hawaii, guam, puerto_rico, virgin_islands,
          mariana_islands, american_samoa) %>%
    # convert from EPSG2163 to (US National Atlas Equal Area) WGS84
    spTransform(CRS("+init=epsg:4326"))

  mapdata

}


# retrieve shapefile from census and apply AK/HI transformations ---------------
get_ccdf_shapefile <- function(year, level, resolution) {
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

  # transform AK
  alaska <- shapes[shapes$STATEFP == "02", ] %>%
    transform_state(-5, 2, c(-3500000, -200000))

  proj4string(alaska) <- proj4string(shapes)

  # transform HI

  hawaii <- shapes[shapes$STATEFP == "15", ] %>%
    transform_state(0, 0.8, c(-2500000, -1000000))

  proj4string(hawaii) <- proj4string(shapes)

  # transform Guam

  guam <- shapes[shapes$STATEFP %in% c("66"), ] %>%
    transform_state(rot = -35, scale = 0.3, shift = c(-2600000, -700000))

  proj4string(guam) <- proj4string(shapes)


  # transform Puerto Rico

  puerto_rico <- shapes[shapes$STATEFP %in% c("72"), ] %>%
    transform_state(rot = 0, scale = 1, shift = c(-1350000, 1000000))

  proj4string(puerto_rico) <- proj4string(shapes)


  # transform American Samoa

  american_samoa <- shapes[shapes$STATEFP %in% c("60"), ] %>%
    transform_state(rot = 0, scale = 0.1, shift = c(-1250000, -5050000))
  proj4string(american_samoa) <- proj4string(shapes)

  # treat islands differently
  as1 <- american_samoa[!american_samoa$NAME %in% c("Rose Island", "Swains Island", "Manu'a"), ] %>%
    transform_state(rot = 0, scale = 1.2, shift = c(200000, -2800000))
  proj4string(as1) <- proj4string(shapes)

  as2 <- american_samoa[american_samoa$NAME %in% c("Manu'a"), ] %>%
    transform_state(rot = 0, scale = 1.2, shift = c(400000, -2800000))
  proj4string(as2) <- proj4string(shapes)

  american_samoa <- rbind(as1, as2) %>%
    # angle and size need to be slightly adjusted
    transform_state(rot = 15, scale = 1, shift = c(-2800000,-1300000))
  proj4string(american_samoa) <- proj4string(shapes)

  # transform US Virgin Islands

  virgin_islands <- shapes[shapes$STATEFP %in% c("78"), ] %>%
    transform_state(rot = 0, scale = 0.2, shift = c(2200000, -1850000))

  proj4string(virgin_islands) <- proj4string(shapes)


  # transform Mariana Islands

  mariana_islands <- shapes[shapes$STATEFP %in% c("69"), ] %>%
    transform_state(rot = -35, scale = 0.1, shift = c(-3600000, -1250000))

  proj4string(mariana_islands) <- proj4string(shapes)

  mariana_islands <- mariana_islands %>%
    # transforms into longitude/latitude
    spTransform(CRS("+init=epsg:4326")) %>%  # prime meridian/equator
    tidy(region = "STATEFP") %>%
    as_tibble() %>%
    filter(piece %in% 1:2)

  # combine, transform, and tidy
  ellided_areas <- c("02", "14", "15", "43", "52", "60", "66", "69", "72", "78")

  fifty_states <-
    shapes[!shapes$STATEFP %in% ellided_areas, ] %>%
    rbind(alaska) %>%
    rbind(hawaii) %>%
    rbind(puerto_rico) %>%
    rbind(virgin_islands) %>%
    rbind(guam) %>%
    rbind(american_samoa) %>%
    # convert from EPSG2163 to (US National Atlas Equal Area) WGS84
    spTransform(CRS("+init=epsg:4326")) %>%
    tidy(region = "STATEFP") %>%
    mutate(id = id) %>%
    as_tibble() %>%
    rbind(mariana_islands)

  # star for Washington, D.C. -----------------------------------------------
  star <- tribble(
    ~x, ~y, ~order, ~hole, ~piece, ~group, ~id,
    1, 0, 1, FALSE, 1, "11",  "11",
    0.3, -0.2, 2, FALSE, 1, "11",  "11",
    0.3, -0.95, 3, FALSE, 1, "11",  "11",
    -0.1, -0.375, 4, FALSE, 1, "11",  "11",
    -0.8, -0.6, 5,  FALSE, 1, "11",  "11",
    -0.39, 0, 6,  FALSE, 1, "11",  "11",
    -0.8, 0.6, 7,  FALSE, 1, "11",  "11",
    -0.1, 0.375, 8, FALSE, 1, "11",  "11",
    0.3, 0.95, 9, FALSE, 1, "11",  "11",
    0.3, 0.2, 10, FALSE, 1, "11",  "11",
    1, 0, 11, FALSE, 1, "11",  "11"
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

  ccdf <- rbind(fifty_states, star) %>%
    filter(id %in% c("11", ellided_areas)) %>%
    rename(state_fips = id)

  ids <- tribble(~state_name, ~state_abbv, ~state_fips,
                 "Alaska", "AK", "02",
                 "Hawaii", "HI", "15",
                 "American Samoa", "AS", "60",
                 "Commonwealth of the Northern Mariana Islands", "MP", "69",
                 "Guam", "GU", "66",
                 "Puerto Rico", "PR", "72",
                 "United States Virgin Islands", "VI", "52",
                 "United States Virgin Islands", "VI", "78",
                 "Washington, D.C.", "DC", "11")

  ccdf <- left_join(ccdf, ids, by = "state_fips")

  ccdf

}

# download and clean state fips data from census
get_state_fips <- function() {

  state_fips <-
    tribble(~state_fips, ~state_abbv, ~state_name,
    "01", "AL", "Alabama",
    "02", "AK", "Alaska",
    "04", "AZ", "Arizona",
    "05", "AR", "Arkansas",
    "06", "CA", "California",
    "08", "CO", "Colorado",
    "09", "CT", "Connecticut",
    "10", "DE", "Delaware",
    "11", "DC", "District of Columbia",
    "12", "FL", "Florida",
    "13", "GA", "Georgia",
    "15", "HI", "Hawaii",
    "16", "ID", "Idaho",
    "17", "IL", "Illinois",
    "18", "IN", "Indiana",
    "19", "IA", "Iowa",
    "20", "KS", "Kansas",
    "21", "KY", "Kentucky",
    "22", "LA", "Louisiana",
    "23", "ME", "Maine",
    "24", "MD", "Maryland",
    "25", "MA", "Massachusetts",
    "26", "MI", "Michigan",
    "27", "MN", "Minnesota",
    "28", "MS", "Mississippi",
    "29", "MO", "Missouri",
    "30", "MT", "Montana",
    "31", "NE", "Nebraska",
    "32", "NV", "Nevada",
    "33", "NH", "New Hampshire",
    "34", "NJ", "New Jersey",
    "35", "NM", "New Mexico",
    "36", "NY", "New York",
    "37", "NC", "North Carolina",
    "38", "ND", "North Dakota",
    "39", "OH", "Ohio",
    "40", "OK", "Oklahoma",
    "41", "OR", "Oregon",
    "42", "PA", "Pennsylvania",
    "44", "RI", "Rhode Island",
    "45", "SC", "South Carolina",
    "46", "SD", "South Dakota",
    "47", "TN", "Tennessee",
    "48", "TX", "Texas",
    "49", "UT", "Utah",
    "50", "VT", "Vermont",
    "51", "VA", "Virginia",
    "53", "WA", "Washington",
    "54", "WV", "West Virginia",
    "55", "WI", "Wisconsin",
    "56", "WY", "Wyoming",
    "60", "AS", "American Samoa",
    "66", "GU", "Guam",
    "69", "MP", "Mariana Islands",
    "72", "PR", "Puerto Rico",
    "78", "VI", "Virgin Islands")

  state_fips
}

# download and clean county fips data from census
get_county_fips <- function() {
  url <- 'https://www2.census.gov/geo/docs/reference/codes/national_county.txt'

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
