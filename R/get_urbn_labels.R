#' Import different maps
#'
#' `get_urbn_labels()` loads labels and coordinates for maps from the `get_urbn_map()` functions.
#'
#' @param map Selection of custom labels. Current options are `"states"`, `"counties"`, `"ccdf"`, and `"territories"`.
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
  } else if (map == "territories") {
    urbnmapr::territories_labels
  }
}
