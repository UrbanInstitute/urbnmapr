# source & save various data creation files for internal sysdata.rda
source('data-raw/utils.R')
source('data-raw/states_labels.R')
source('data-raw/counties_labels.R')
source('data-raw/ccdf_labels.R')
source('data-raw/territories_labels.R')
source('data-raw/territories_counties.R')
source('data-raw/territories.R')
source('data-raw/ccdf.R')

# sf data
source('data-raw/counties_sf.R')
source('data-raw/territories_counties_sf.R')
source('data-raw/states_sf.R')
source('data-raw/territories_sf.R')


save(states_labels,
     counties_labels,
     ccdf_labels,
     territories_labels,
     territories_counties,
     territories,
     ccdf,
     counties_sf,
     territories_counties_sf,
     states_sf,
     territories_sf,
     file = 'R/sysdata.rda',
     compress = 'bzip2')
