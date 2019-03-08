# American Samoa needs multiple transformations. The transformation are simpler
# with the county data. get American Samoa, tidy, add fips data, and remove
# county data
american_samoa_sf <- get_shapefile(2016, 'county', '5m') %>%
  sf::st_as_sf() %>%
  mutate(county_fips = paste0(STATEFP, COUNTYFP)) %>%
  select(county_fips) %>%
  left_join(get_county_fips(), by = "county_fips") %>%
  filter(state_name == "American Samoa") %>%
  select(-county_fips, -county_name, -fips_class) %>%
  group_by(state_name, state_abbv, state_fips) %>%
  summarize() %>%
  sf::st_as_sf()

# get state shapefile, tidy, add fips data
territories_sf <- get_shapefile(2016, 'state', '5m') %>%
  sf::st_as_sf() %>%
  select(state_fips = STATEFP) %>%
  left_join(get_state_fips(), by = "state_fips") %>%
  filter(state_fips %in% c("02", "15", "66", "69", "72", "78"))

territories_sf <- rbind(territories_sf, american_samoa_sf)
