#' Import different maps
#'
#' `get_urbn_map()` loads maps that are different than `states` and `counties`
#'
#' @param map Selection of custom map. Current options are `"states"`, `"counties"`, `"ccdf"`, `"territories_states"`, and `"territories_counties"`.
#' @param sf Option indicates whether data is loaded as a `tibble()` or an `sf` object
#'
#' @md
#' @export
get_urbn_map <- function(map = "states", sf = FALSE) {

  if (sf == FALSE) {

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
    } else if (map == "territories_states") {
      rbind(
        urbnmapr::states[!urbnmapr::states$state_name %in%
                           c("Alaska", "Hawaii"), ],
        territories
      )
    } else if (map == "territories_counties") {
      rbind(
        urbnmapr::counties[!urbnmapr::counties$state_name %in%
                             c("Alaska", "Hawaii"), ],
        territories_counties
      )
    } else {
      stop("Invalid 'map' argument. Valid maps are: ",
           "states, counties, ccdf, territories_states, and territories_counties.",
           call. = FALSE
      )
    }

  } else if (sf == TRUE) {

    if (map == "states") {
      states_sf
    } else if (map == "counties") {
      counties_sf
    } else if (map == "ccdf") {
      stop("SF option not available for CCDF map")
    } else if (map == "territories_states") {
      rbind(
        states_sf[!states_sf$state_name %in%
                    c("Alaska", "Hawaii"), ],
        territories_sf
      )
    } else if (map == "territories_counties") {
      rbind(
        counties_sf[!counties_sf$state_name %in%
                      c("Alaska", "Hawaii"), ],
        territories_counties_sf
      )
    } else {
      stop("Invalid 'map' argument. Valid maps are: ",
           "states, counties, ccdf, territories_states, and territories_counties.",
           call. = FALSE
      )
    }
  }
}
