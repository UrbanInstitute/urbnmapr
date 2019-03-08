# get county shapefile, convert to SF, add fips data, filter out territories
counties_sf <- get_shapefile(2016, 'county', '5m') %>%
  sf::st_as_sf() %>%
  mutate(county_fips = paste0(STATEFP, COUNTYFP)) %>%
  select(county_fips) %>%
  left_join(get_county_fips(), by = "county_fips") %>%
  filter(!state_fips %in% c("60", "66", "69", "72", "78"))
