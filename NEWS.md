## urbnmapr 0.0.0.9001

Two functions have been added to the package, with two additional shape 
options:

* `get_urbn_map` will return the requested shapefile, parsed into a `tibble`
* `get_urbn_labels` will return a `tibble` of coordinates and map labels

The valid options for each are:

1. states
2. counties
3. ccdf
4. territories_counties

## urbnmapr 0.0.0.9000

This is the initial release of the `urbnmapr` package. It includes state and 
county-level shapefiles parsed into a `tibble` for easy plotting with 
`ggplot2`.  
