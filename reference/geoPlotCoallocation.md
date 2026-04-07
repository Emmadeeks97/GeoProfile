# Calculate and plot probability of coallocation

For all pairs of crimes, calculates the probability that both originate
from the same source and plots a coloured half matrix representing these
data. The data underlying these calculations can be accessed as the
object `$coAllocation` produced by
[`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).

## Usage

``` r
geoPlotCoallocation(mcmc, cols = NULL)
```

## Arguments

- mcmc:

  object of the type output by
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).

- cols:

  colour palette to use. Defaults to viridis palette.

## Examples

``` r
if (FALSE) { # interactive()
# \donttest{
# London example data
d <- LondonExample_crimes
s <- LondonExample_sources
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
# produce simple map
geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
                breakPercent = seq(0, 50, 5), mapType = "hybrid",
                crimeCol = "black", crimeCex = 2, sourceCol = "red", sourceCex = 2)
# calculate coallocation matrix and plot
geoPlotCoallocation(m)
# }
}
```
