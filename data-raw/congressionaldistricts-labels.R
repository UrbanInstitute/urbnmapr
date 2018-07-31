library(tidyverse)
library(urbnmapr)

congressionaldistricts_labels <- congressional_districts %>%
  group_by(cd_fips, state_name) %>%
  summarize(long = mean(long), lat = mean(lat))

save(congressionaldistricts_labels, file = "data/congressionaldistricts-labels.rda", compress = "bzip2")

