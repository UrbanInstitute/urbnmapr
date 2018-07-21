#' Import different maps
#'
#' `get_urbn_labels()` loads labels and coordinates for maps from the `get_urbn_map()` functions.
#'
#' @param map Selection of custom labels. Current options are `"states"`, `"counties"`, `"ccdf"`, and `"territories_counties"`.
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
  } else if (map == "territories_counties") {
    territories_labels
  } else {
    stop("Invalid 'map' argument. Valid maps are: ",
         "states, counties, ccdf, and territories_counties.",
         call. = FALSE
    )
  }
}
