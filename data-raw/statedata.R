library(tidyverse)

# read county level household variables from Sloan database
temp <- tempfile(fileext = '.zip')
download.file('https://s3.amazonaws.com/ui-spark-social-science-public/sloan-hfpc-data/state_household_csv.zip', temp)
temp_dir <- tempdir()
unzip(temp, exdir = temp_dir, junkpaths = TRUE)
statedata <- read_csv(paste(temp_dir, 'state_household.csv', sep='/'),
                       guess_max = 40000)

statedata <- statedata %>%
  filter(YEAR == 2015) %>%
  # create accurate state FIPS code variable
  mutate(state_fips = ifelse(str_length(state) == 1, paste0("0", state), state)) %>%
  mutate(hhpop = OWNERSHP_1 + OWNERSHP_2,
         horate = OWNERSHP_1 / hhpop) %>%
  select(year = YEAR, state_fips, state_name = STATENAME,
         hhpop, horate,
         medhhincome = HHINCOME_P50)

save(statedata, file = 'data/statedata.rda', compress = 'bzip2')
