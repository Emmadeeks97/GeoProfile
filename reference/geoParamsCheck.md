# Check parameters

Check that all parameters for use in Rgeoprofile MCMC are in the correct
format.

## Usage

``` r
geoParamsCheck(params, silent = FALSE)
```

## Arguments

- params:

  a list of parameters, as defined by
  [`geoParams()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.params.md).

- silent:

  whether to report passing check to console.

## Examples

``` r
if (FALSE) { # interactive()
# John Snow cholera data
d <- geoData(Cholera$longitude, Cholera$latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
geoParamsCheck(p)

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=1, sigma=1, tau=3)
d <- geoData(Cholera$longitude, Cholera$latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_var=0)
geoParamsCheck(p)
}
```
