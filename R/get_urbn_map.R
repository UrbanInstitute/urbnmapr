#' Import different maps
#'
#' `get_urbn_map()` loads maps that are different than `states` and `counties`
#'
#' @param map Selection of custom map. Current options are `"states"`, `"counties"`, `"ccdf"`, `"territories"`, and `"territories_counties"`.
#'
#' @md
#' @export
get_urbn_map <- function(map = "states") {
  if (map == "states") {
    urbnmapr::states
  } else if (map == "counties") {
    urbnmapr::counties
  } else if (map == "ccdf") {
    rbind(
      urbnmapr::states[!urbnmapr::states$state_name %in%
                         c("Alaska", "Hawaii", "District of Columbia"), ],
      ccdf
      )
  } else if (map == "territories") {
    rbind(
      urbnmapr::states[!urbnmapr::states$state_name %in%
                           c("Alaska", "Hawaii"), ],
      territories
    )
  }else if (map == "territories_counties") {
    rbind(
      urbnmapr::counties[!urbnmapr::counties$state_name %in%
                           c("Alaska", "Hawaii"), ],
      territories_counties
      )
  } else {
    stop("Invalid 'map' argument. Valid maps are: ",
         "states, counties, ccdf, and territories_counties.",
         call. = FALSE
         )
  }
}
