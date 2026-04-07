# Import shapefile

This function imports spatial information in the form of
`SpatialPolygonsDataFrame`, `SpatialLinesDataFrame` or `RasterLayer` for
use with
[`geoMask()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMask.md).

## Usage

``` r
geoShapefile(fileName = NULL)
```

## Arguments

- fileName:

  the object to be imported. Must be one of `SpatialPolygonsDataFrame`,
  `SpatialLinesDataFrame` or `RasterLayer` if it is to be used with
  [`geoMask()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMask.md).

## Examples

``` r
if (FALSE) { # interactive()
# load London boroughs by default
geoShapefile()
}
```
