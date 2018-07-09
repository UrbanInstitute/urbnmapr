library(tidyverse)
library(urbnmapr)

counties_labels <- counties %>%
  group_by(county_name, state_name, county_fips, state_fips, fips_class) %>%
  summarize(long = mean(long), lat = mean(lat))

save(counties_labels, file = "data/counties-labels.rda", compress = "bzip2")

