# Interactive 3D plot of geoprofile or raw probabilities

Plots an interactive 3D plot of geoprofile or posterior surface
(coloured according to height). This requires the `plotly` package to be
installed.

## Usage

``` r
geoSurface3D(surface, surface_type = "gp")
```

## Arguments

- surface:

  surface to plot; either the geoprofile or posteriorSurface output by
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).

- surface_type:

  type of surface; should be either `"gp"` for geoprofile or `"prob"`
  for posteriorSurface.

## Value

Nothing (called for plotting)

## Note

Generally speaking 3D plots are not particularly useful for static data
representation. As such these should only be used in decorative or
interactive formats rather than as the only way of representing data. If
you are looking to represent probability surfaces in a 2D medium such as
a paper, heatmaps are usually easier to interpret.

## Examples

``` r
if (FALSE) { # interactive()
# John Snow cholera data
d <- geoData(Cholera$longitude, Cholera$latitude)
s <- geoDataSource(WaterPumps$longitude, WaterPumps$latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p, lambda=0.05)
# raw probabilities
geoSurface3D(m$posteriorSurface, surface_type = "prob")
# geoprofile
geoSurface3D(m$geoProfile, surface_type = "gp")
}
```
