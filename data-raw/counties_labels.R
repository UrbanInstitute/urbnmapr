# generate counties labels
# to be called only by generate_sysdata.R for internal package use

library(dplyr)

counties_labels <- urbnmapr::counties %>%
  group_by(county_name, state_name, county_fips, state_fips, fips_class) %>%
  summarize(lat = mean(lat), long = mean(long)) %>%
  ungroup()
