
library(tidyverse)

territories_labels <- read_csv("state_name, lat, long, state_abbv
Alaska, 22, -118, AK
American Samoa, 16.5, -90, AS
Guam, 20, -100, GU
Hawaii, 22.5, -107, HI
Mariana Islands, 25, -68, MP
Puerto Rico, 21, -94, PR
Virgin Islands, 18, -81, VI")

save(territories_labels, file = 'data/territories-labels.rda', compress = 'bzip2')

