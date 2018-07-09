#' Import different maps
#'
#' `get_urbn_map()` loads maps that are different than `states` and `counties`
#'
#' @param map Selection of custom map. Current options are `"states"`, `"counties"`, and `"ccdf"`.
#'
#' @md
#' @export
get_urbn_map <- function(map = "states") {
  if (map == "states") {
    urbnmapr::states
  } else if (map == "counties") {
    urbnmapr::counties
  } else if (map == "ccdf") {
    rbind(states[!states$state_name %in% c("Alaska", "Hawaii", "District of Columbia"), ], urbnmapr::ccdfmap)
  } else if (map == "county-territories") {
  rbind(counties[!counties$state_name %in% c("Alaska", "Hawaii"), ], urbnmapr::county-territories)
  }
}
