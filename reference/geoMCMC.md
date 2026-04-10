# MCMC under Rgeoprofile model

This function carries out the main MCMC under the Rgeoprofile model.
Posterior draws are smoothed to produce a posterior surface, and
converted into a geoProfile. Outputs include posterior draws of alpha
and sigma under the variable-sigma model.

## Usage

``` r
geoMCMC(data, params, lambda = NULL, smoothprogress = TRUE)
```

## Arguments

- data:

  input data in the format defined by
  [`geoData()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.data.md).

- params:

  input parameters in the format defined by
  [`geoParams()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.params.md).

- lambda:

  bandwidth to use in posterior smoothing. If `NULL` then optimal
  bandwidth is chosen automatically by maximum-likelihood.

- smoothprogress:

  whether to include a progress spinner for the smoothing stage.

## Examples

``` r
if (FALSE) { # interactive()
# John Snow cholera data
d <- geoData(Cholera$longitude, Cholera$latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p, lambda=0.05)

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=1, sigma=1, tau=3)
d <- geoData(sim$longitude, sim $latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
}
```
