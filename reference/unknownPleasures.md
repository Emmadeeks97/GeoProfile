# Unknown pleasures

A frivolous alternative to
[`geoPlotMap()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPlotMap.md),
this function takes the output of
[`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md)
and plots the resulting geoprofile in the style of the cover of Joy
Division's 'Unknown pleasures' album.

## Usage

``` r
unknownPleasures(
  input_matrix,
  paper_ref = NULL,
  nlines = 80,
  bgcol = "black",
  fgcol = "white",
  wt = 2
)
```

## Arguments

- input_matrix:

  The surface to plot, usually the object `$geoProfile` produced by
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).

- paper_ref:

  A text string, for example a reference to a paper.

- nlines:

  The number of lines (defaults to the correct number of 80).

- bgcol:

  Background colour

- fgcol:

  Foreground colour

- wt:

  line weight

## Examples

``` r
if (FALSE) { # interactive()
# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=10, sigma=1, tau=3)
d <- geoData(sim$longitude, sim $latitude)
s <- geoDataSource(sim$source_lon, sim$source_lat)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
unknownPleasures(m$geoProfile, paper_ref = "Rgeoprofile v2.1.0")
}
```
