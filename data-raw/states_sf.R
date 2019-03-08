# get state shapefile, convert to SF, add fips data
states_sf <- get_shapefile(2016, 'state', '5m') %>%
  sf::st_as_sf() %>%
  select(state_fips = STATEFP) %>%
  left_join(get_state_fips(), by = "state_fips") %>%
  filter(!state_fips %in% c("66", "69", "72", "78", "60"))
