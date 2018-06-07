#' Import different maps
#'
#' `get_urbn_labels()` loads labels and coordinates for maps from the `get_urbn_map()` functions.
#'
#' @param map Selection of custom labels. Current options are `"states"`, `"counties"`, and `"ccdf"`.
#'
#' @md
#' @export
get_urbn_labels <- function(map = "states") {
  if (map == "states") {
    urbnmapr::states_labels
  } else if (map == "counties") {
    urbnmapr::counties_labels
  } else if (map == "ccdf") {
    urbnmapr::ccdf_labels
  }
}
