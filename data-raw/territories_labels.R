# territories lables
# to be called only by generate_sysdata.R for internal package use

territories_labels <- readr::read_csv(
"state_name, lat, long, state_abbv
American Samoa, 19.5, -90, AS
Guam, 20, -100, GU
Mariana Islands, 22, -78.5, MP
Puerto Rico, 21, -94, PR
Virgin Islands, 18, -81, VI")
