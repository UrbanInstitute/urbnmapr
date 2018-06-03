#' Obtain shapefile from census.gov
#'
#' @param year shapefile year
#' @param fips state fips
#' @param level shapefile level
#'
#' @source United States Census Bureau,
#'  \url{https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html}
#'
#' @format Data frame with columns
#'
#' @importFrom magrittr "%>%"
#' @export

get_shapefile <- function(year, fips, level) {
  # set shapefile url
  url_base <- paste0('https://www2.census.gov/geo/tiger/GENZ', year, '/shp/')
  shape_base <- paste('cb', year, fips, level, '500k', sep = '_')
  url <- paste0(url_base, shape_base, '.zip')

  # download data and unzip
  temp <- tempfile(fileext = '.zip')
  utils::download.file(url, temp)

  temp_dir <- tempdir()
  utils::unzip(temp, exdir = temp_dir)

  # read shapefile
  shapes <-
    rgdal::readOGR(dsn = temp_dir,
                   layer = shape_base,
                   verbose = FALSE) %>%
    sp::spTransform(sp::CRS("+init=epsg:4326")) %>%
    broom::tidy(region = "GEOID") %>%
    tibble::as.tibble()

  file.remove(list.files(temp_dir, full.names = TRUE))

  shapes

}
