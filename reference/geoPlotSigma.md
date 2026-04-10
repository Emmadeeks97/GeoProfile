# Plot prior and posterior distributions of sigma.

Plot prior distribution of sigma as defined by current parameter values.
Can optionally overlay a kernel density plot of posterior draws of
sigma.

## Usage

``` r
geoPlotSigma(params, mcmc = NULL, plotMax = NULL)
```

## Arguments

- params:

  a list of parameters as defined by
  [`geoParams()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.params.md).

- mcmc:

  stored output obtained by running
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).
  Leave as `NULL` to plot prior only.

- plotMax:

  maximum x-axis range to plot. Leave as `NULL` to use default settings.

## Examples

``` r
if (FALSE) { # interactive()
# John Snow cholera data
d <- geoData(Cholera$longitude, Cholera$latitude)
p <- geoParams(data = d, sigma_mean = 0.2, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
geoPlotSigma(params = p, mcmc = m)

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=1, sigma=1, tau=3)
d <- geoData(sim$longitude, sim$latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
geoPlotSigma(params = p, mcmc = m)
}
```
