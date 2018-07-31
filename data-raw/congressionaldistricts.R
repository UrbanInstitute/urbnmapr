# load utility functions
source('data-raw/utils.R')

# get state shapefile, tidy, add fips data
congressional_districts <- get_shapefile(2016, 'cd115', '5m') %>%
  tidy(region = "GEOID") %>%
  rename(cd_fips = id) %>%
  mutate(state_fips = substr(cd_fips, 1, 2)) %>%
  as_tibble() %>%
  left_join(get_state_fips(), by = "state_fips") %>%
  filter(!state_fips %in% c("60", "66", "69", "72", "78"))

# compress and save
save(congressional_districts, file = 'data/congressionaldistricts.rda', compress = 'bzip2')