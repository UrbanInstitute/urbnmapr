library(tidyverse)

# read county level household variables from Sloan database
temp <- tempfile(fileext = '.zip')
download.file('https://s3.amazonaws.com/ui-spark-social-science-public/sloan-hfpc-data/county_household_csv.zip', temp)
temp_dir <- tempdir()
unzip(temp, exdir = temp_dir, junkpaths = TRUE)
countydata <- read_csv(paste(temp_dir, 'county_household.csv', sep='/'))

countydata <- countydata %>%
  filter(YEAR == 2015) %>%
  mutate(hhpop = OWNERSHP_1 + OWNERSHP_2,
         horate = OWNERSHP_1 / hhpop) %>%
  select(year = YEAR, county_fips = county,
         hhpop, horate,
         medhhincome = HHINCOME_P50)

save(countydata, file = 'data/countydata.rda', compress = 'bzip2')
