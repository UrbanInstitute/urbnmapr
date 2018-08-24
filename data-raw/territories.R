# American Samoa needs multiple transformations. The transformation are simpler
# with the county data. get American Samoa, tidy, add fips data, and remove
# county data
american_samoa <- get_shapefile(2016, 'county', '5m') %>%
  tidy(region = "GEOID") %>%
  rename(county_fips = id) %>%
  as_tibble() %>%
  left_join(get_county_fips(), by = "county_fips") %>%
  filter(state_name == "American Samoa") %>%
  select(-county_fips, -county_name, -fips_class) %>%
  mutate(group = as.character(group),
         piece = as.character(piece))

# get state shapefile, tidy, add fips data
territories <- get_shapefile(2016, 'state', '5m') %>%
  tidy(region = "GEOID") %>%
  rename(state_fips = id) %>%
  as_tibble() %>%
  left_join(get_state_fips(), by = "state_fips") %>%
  filter(state_fips %in% c("02", "15", "66", "69", "72", "78")) %>%
  mutate(group = as.character(group),
         piece = as.character(piece))

territories <- bind_rows(territories, american_samoa)
