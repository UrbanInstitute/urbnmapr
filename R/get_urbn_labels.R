#' Import different maps
#'
#' `get_urbn_labels()` loads labels and coordinates for maps from the `get_urbn_map()` functions.
#'
#' @param map Selection of custom labels. Current options are `"states"`, `"counties"`, `"ccdf"`, `"territories"`, and `"territories_counties"`.
#'
#' @md
#' @export
get_urbn_labels <- function(map = "states") {
  if (map == "states") {
    states_labels
  } else if (map == "counties") {
    counties_labels
  } else if (map == "ccdf") {
    ccdf_labels
  } else if (map == "territories") {
    rbind(states_labels, territories_labels[, c("state_name", "lat", "long", "state_abbv")])
  } else if (map == "territories_counties") {
    rbind(counties_labels, territories_labels[, !(names(territories_labels) %in% "state_abbv")])
  } else {
    stop("Invalid 'map' argument. Valid maps are: ",
         "states, counties, ccdf, and territories_counties.",
         call. = FALSE
    )
  }
}
