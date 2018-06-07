#' Import different maps
#'
#' `get_urbn_labels()` loads labels and coordinates for maps from the `get_urbn_map()` functions.
#'
#' @param map Selection of custom labels. Current option is `"ccdf"`.
#'
#' @md
#' @export
get_urbn_labels <- function(map) {
  if (map == "ccdf") {
    urbnmapr::ccdf_labels
  }
}
