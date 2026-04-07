# Perspective plot of geoprofile or raw probabilities

Plots persp plot of geoprofile or posterior surface (coloured according
to height), reducing matrix dimensions if necessary to avoid grid lines
being too close together. NB Only works with square matrix

## Usage

``` r
geoPersp(
  surface,
  aggregate_size = 3,
  surface_type = "gp",
  perspCol = c("red", "orange", "yellow", "white"),
  phiGP = 30,
  thetaGP = -30
)
```

## Arguments

- surface:

  surface to plot; either the geoprofile or posteriorSurface output by
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).

- aggregate_size:

  the number of cells to aggregate to smooth the surface.

- surface_type:

  type of surface; should be either `"gp"` for geoprofile or `"prob"`
  for posteriorSurface.

- perspCol:

  colour palette. Defaults to red/orange/yellow/white.

- phiGP:

  value of phi to pass to
  [`graphics::persp()`](https://rdrr.io/r/graphics/persp.html).

- thetaGP:

  value of theta to pass to
  [`graphics::persp()`](https://rdrr.io/r/graphics/persp.html).

## Examples

``` r
if (FALSE) { # interactive()
# John Snow cholera data
d <- geoData(Cholera$longitude, Cholera$latitude)
s <- geoDataSource(WaterPumps$longitude, WaterPumps$latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p, lambda=0.05)
# raw probabilities
geoPersp(m$posteriorSurface, surface_type = "prob")
# geoprofile
geoPersp(m$geoProfile, aggregate_size = 3, surface_type = "gp")

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=1, sigma=1, tau=3)
d <- geoData(sim$longitude, sim $latitude)
s <- geoDataSource(sim$source_lon, sim$source_lat)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
# raw probabilities
geoPersp(m$posteriorSurface, surface_type = "prob")
# geoprofile
geoPersp(surface = m$geoProfile, aggregate_size = 3, surface_type = "gp")
}
```
