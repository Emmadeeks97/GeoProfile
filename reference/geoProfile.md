# Calculate geoprofile from surface

Converts surface to hitscore percentage

## Usage

``` r
geoProfile(surface)
```

## Arguments

- surface:

  matrix to convert to geoprofile

## Value

A `matrix` of the geoprofile of the surface

## Examples

``` r
if (FALSE) { # interactive()
# John Snow cholera data
d <- geoData(Cholera$longitude, Cholera$latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p, lambda=0.05)
gp <- geoProfile(m$posteriorSurface)

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=1, sigma=1, tau=3)
d <- geoData(sim$longitude, sim $latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
gp <- geoProfile(m$posteriorSurface)
}
```
