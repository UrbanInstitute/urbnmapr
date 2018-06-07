#' Import different maps
#'
#' `get_urbn_map()` loads maps that are different than `states` and `counties`
#'
#' @param map Selection of custom map. Current option is `"ccdf"`.
#'
#' @md
#' @export
get_urbn_map <- function(map) {
  if (map == "ccdf") {
    rbind(states[!states$state_name %in% c("Alaska", "Hawaii", "District of Columbia"), ], urbnmapr::ccdfmap)
  }
}
