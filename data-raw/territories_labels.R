# territories lables
# to be called only by generate_sysdata.R for internal package use

territories_labels <- readr::read_csv(
"county_name, state_name, county_fips, state_fips, fips_class, lat, long, state_abbv
American Samoa, American Samoa, NA, 60, NA, 19.5, -90, AS
Guam, Guam, NA, 66, NA, 20, -100, GU
Mariana Islands, Mariana Islands, NA, 69, NA, 22, -78.5, MP
Puerto Rico, Puerto Rico, NA, 43, NA, 21, -94, PR
Virgin Islands, Virgin Islands, NA, 78, NA, 18, -81, VI",
col_types = cols(county_name = col_character(),
                 state_name = col_character(),
                 county_fips = col_character(),
                 state_fips = col_character(),
                 fips_class = col_character(),
                 lat = col_double(),
                 long = col_double(),
                 state_abbv = col_character()))
