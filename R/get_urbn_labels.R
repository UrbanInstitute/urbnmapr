#' Import different map labels.
#'
#' `get_urbn_labels()` loads labels and coordinates for maps from the `get_urbn_map()` functions.
#' Note: there are currently only `sf` options for `states` and `territories_states`, as
#' these are the only options that have custom labels. To label `counties` and `territories_counties`,
#' use `geom_sf_text()` or `geom__sf_label()`.
#'
#' @param map Selection of custom labels. Current options are `"states"`, `"counties"`, `"ccdf"`, `"territories"`, and `"territories_counties"`.
#' @param sf Option indicates whether data is loaded as a `tibble()` or an `sf` object
#'
#' @md
#' @export
get_urbn_labels <- function(map = "states", sf = FALSE) {

  if (sf == FALSE) {

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
           "states, counties, ccdf, territories_states, territories_counties.",
           call. = FALSE
      )
    }

  } else if (sf == TRUE) {

      if (map == "states") {
        states_labels_sf
      } else if (map == "territories_states") {
        rbind(states_labels_sf, territories_labels_sf)
      } else {
        stop("SF option is only available for states and territories_states maps",
             call. = FALSE
             )
     }
   }
}
