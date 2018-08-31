#' County shapefile data with U.S. territories
#'
#' County shapefile data with territories, cleaned and parsed into a tibble
#' for easy mapping. Includes various state identifiers for easy merging.
#'
#' @source United States Census Bureau,
#'  \url{https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html}
#'
#' @format Data frame with columns
#' \describe{
#' \item{long, lat}{Longitude and latitude}
#' \item{county_name, county_fips, fips_class}{County name, five-digit FIPS and FIPS class code}
#' \item{state_name, state_abbv, state_fips}{State name, postal abbreviation, and two-digit FIPS code}
#' }
'territories_counties'

#' @importFrom tibble tibble
NULL
