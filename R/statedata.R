#' State data for mapping
#'
#' State-level data to use for example maps.
#' Includes state FIPS code to match with state shapefile data.
#'
#' @source Urban Institute Sloan ADRF Database,
#'  \url{https://adrf.urban.org}
#'
#' @format Data frame with columns
#' \describe{
#' \item{year}{Year of data}
#' \item{state_fips, state_name}{Two-digit FIPS code and state name}
#' \item{hhhpop}{Household population}
#' \item{horate}{Homeownership rate}
#' \item{medhhincome}{Median household income}
#' }
'statedata'

#' @importFrom tibble tibble
NULL
