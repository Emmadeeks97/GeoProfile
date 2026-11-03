# Plot prior and posterior distributions of alpha

Plot the Gamma prior on alpha as defined by current parameter values.
Can optionally overlay a kernel density plot of posterior draws of
alpha.

## Usage

``` r
geoPlotAlpha(params, mcmc = NULL, xlim = NULL, ylim = NULL)
```

## Arguments

- params:

  a list of parameters as defined by
  [`geoParams()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.params.md).

- mcmc:

  stored output obtained by running
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).
  Leave as `NULL` to plot prior only.

- xlim:

  numeric vector of length 2 giving the x-axis range (must be
  non-negative). Leave as `NULL` to use default settings.

- ylim:

  numeric vector of length 2 giving the y-axis range. Leave as `NULL` to
  use default settings. If the prior diverges at 0 (`alpha_shape < 1`)
  the default ignores the leftmost 5\\ when setting the height, so the
  prior will run off the top of the plot.

## Value

Nothing (called for plotting)

## Examples

``` r
if (FALSE) { # interactive()
# John Snow cholera data
d <- geoData(Cholera$longitude, Cholera$latitude)
p <- geoParams(data = d, sigma_mean = 0.2, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
geoPlotAlpha(params = p, mcmc = m)

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=1, sigma=1, tau=3)
d <- geoData(sim$longitude, sim$latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
geoPlotAlpha(params = p, mcmc = m, xlim = c(0,10), ylim = c(0,10))
}
```
