# source & save various data creation files for internal sysdata.rda
source('data-raw/utils.R')
source('data-raw/states_labels.R')
source('data-raw/counties_labels.R')
source('data-raw/ccdf_labels.R')
source('data-raw/territories_labels.R')
source('data-raw/territories_counties.R')
source('data-raw/territories.R')
source('data-raw/ccdf.R')

save(states_labels,
     counties_labels,
     ccdf_labels,
     territories_labels,
     territories_counties,
     territories,
     ccdf,
     file = 'R/sysdata.rda',
     compress = 'bzip2')
