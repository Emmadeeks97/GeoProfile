# Plot posterior allocation

Produces plot of posterior allocation from output of MCMC.

## Usage

``` r
geoPlotAllocation(
  mcmc,
  colours = NULL,
  barBorderCol = NA,
  barBorderWidth = 0.25,
  mainBorderCol = "black",
  mainBorderWidth = 2,
  yTicks_on = TRUE,
  yTicks = seq(0, 1, 0.2),
  xTicks_on = FALSE,
  xTicks_size = 1,
  xlab = "",
  ylab = "posterior allocation",
  mainTitle = "",
  names = NA,
  names_size = 1,
  orderBy = "group"
)
```

## Arguments

- mcmc:

  stored output obtained by running
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).

- colours:

  vector of colours for each allocation. If NULL then use default colour
  scheme.

- barBorderCol:

  colour of borders around each bar. Set as NA to omit this border
  (useful when there are a large number of observations).

- barBorderWidth:

  line width of borders around each bar.

- mainBorderCol:

  colour of border around plot.

- mainBorderWidth:

  line width of border around plot.

- yTicks_on:

  whether to include ticks on the y-axis.

- yTicks:

  vector of y-axis tick positions.

- xTicks_on:

  whether to include ticks on the x-axis.

- xTicks_size:

  size of ticks on the x-axis.

- xlab:

  x-axis label.

- ylab:

  x-axis label.

- mainTitle:

  main title over plot.

- names:

  individual names of each observation, written horizontally below each
  bar.

- names_size:

  size of names under each bar.

- orderBy:

  whether to order segments within each bar by `"group"` or by
  `"probability"`. If ordered by group, all segments of a particular
  group are laid down before moving to the next group. If ordered by
  probability the segments within each bar are ordered from large to
  small.

## Value

Nothing (called for plotting)

## Examples

``` r
if (FALSE) { # interactive()
# London example data
d <- LondonExample_crimes
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
geoPlotAllocation(m)

# John Snow cholera data
d <- Cholera
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p, lambda=0.05)
geoPlotAllocation(m, barBorderCol=NA)  # (should allocate all to a single source!)

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
               51.5235505, alpha=1, sigma=1, tau=3)
d <- geoData(sim$longitude, sim $latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
geoPlotAllocation(m)
}
```
