#' County data for mapping
#'
#' County-level data to use for example maps.
#' Includes county FIPS code to match with county shapefile data.
#'
#' @source Urban Institute Sloan ADRF Database,
#'  \url{https://adrf.urban.org}
#'
#' @format Data frame with columns
#' \describe{
#' \item{year}{Year of data}
#' \item{county_fips}{Five-digit FIPS code}
#' \item{hhhpop}{Household population}
#' \item{horate}{Homeownership rate}
#' \item{medhhincome}{Median household income}
#' }
'countydata'

#' @importFrom tibble tibble
NULL
