# load utility functions
source('data-raw/utils.R')

# get state shapefile, tidy, add fips data
states <- get_shapefile(2016, 'state', '5m') %>%
  tidy(region = "STATEFP") %>%
  rename(state_fips = id) %>%
  as_tibble() %>%
  left_join(get_state_fips(), by = "state_fips") %>%
  filter(!state_fips %in% c("66", "69", "72", "78", "60"))

# compress and save
save(states, file = 'data/states.rda', compress = 'bzip2')
