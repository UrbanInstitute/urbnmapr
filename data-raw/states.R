# load utility functions
source('data-raw/utils.R')

# get state shapefile, tidy, add fips data

# General workflow
# states tigris::states %>% (filter out territories) %>% shift_geometry() %>%
# Just territories %>% shift_geometry_territories()
# Renaming columsn with our column
# Bind all together

# Might want to expose cb argm and year to user
minimal_states <- tigris::states(cb = TRUE, progress_bar = FALSE,
                                 year = 2020) %>%
  sf::st_transform('ESRI:102003') %>%
  dplyr::select(-ALAND, -AWATER, -LSAD)


all_states_plus_pr <- minimal_states %>%
  tidylog::filter(!STATEFP %in% c(60, 66, 69, 78)) %>%
  shift_geometry()


territories_minus_pr <- minimal_states %>%
  tidylog::filter(STATEFP %in% c(60, 66, 69, 78)) %>%
  shift_territory_geometry()


all_states_and_territories <- bind_rows(all_states_plus_pr, territories_minus_pr)


# Shift_geometry_territories
states <- get_shapefile(2016, 'state', '5m') %>%
  tidy(region = "STATEFP") %>%
  rename(state_fips = id) %>%
  as_tibble() %>%
  left_join(get_state_fips(), by = "state_fips") %>%
  filter(!state_fips %in% c("66", "69", "72", "78", "60"))

# compress and save
save(states, file = 'data/states.rda', compress = 'bzip2')
