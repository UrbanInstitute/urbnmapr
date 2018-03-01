#' State shapefile data
#'
#' State shapefile data, cleaned and parsed into a tibble for easy mapping.
#' Includes various state identifiers for easy merging.
#'
#' @source United States Census Bureau,
#'  \url{https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html}
#'
#' @format Data frame with columns
#' \describe{
#' \item{long, lat}{Longitude and latitude}
#' \item{state_name, state_abbv, state_fips}{State name, postal abbreviation, and two-digit FIPS code}
#' }
'states'

#' @importFrom tibble tibble
NULL
