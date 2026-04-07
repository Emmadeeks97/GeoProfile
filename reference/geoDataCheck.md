# Check data

Check that all data for use in Rgeoprofile MCMC is in the correct
format.

## Usage

``` r
geoDataCheck(data, silent = FALSE)
```

## Arguments

- data:

  a data list object, as defined by
  [`geoData()`](https://emmadeeks97.github.io/GeoProfile/reference/geoData.md).

- silent:

  whether to report if data passes checks to console.

## Examples

``` r
if (FALSE) { # interactive()
# John Snow cholera data
d <- geoData(Cholera$longitude, Cholera$latitude)
geoDataCheck(d)

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=1, sigma=1, tau=3)
d <- geoData(sim$longitude, sim $latitude)
geoDataCheck(d)
}
```
