# American Samoa needs multiple transformations. The transformation are simpler
# with the county data. get American Samoa, tidy, add fips data, and remove
# county data
american_samoa <- get_ccdf_shapefile(2016, "county", "5m") %>%
  filter(state_name == "American Samoa")

# get state shapefile, tidy, add fips data
ccdf <- get_ccdf_shapefile(2016, "state", "5m") %>%
  filter(state_fips %in% c("02", "11", "15", "52", "66", "69", "72", "78")) %>%
  mutate(group = as.character(group),
         piece = as.character(piece))

ccdf <- bind_rows(ccdf, american_samoa)
