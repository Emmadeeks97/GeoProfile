# Calculate geoprofile from surface

Converts surface to hitscore percentage

## Usage

``` r
geoProfile(
  surface,
  equalRanks = TRUE,
  warnDuplicates = TRUE,
  zeroesAsNAs = TRUE
)
```

## Arguments

- surface:

  matrix to convert to geoprofile

- equalRanks:

  if true, equal values are given equal hit scroe ranks.

- warnDuplicates:

  this option allows muting of the duplicate values warning message.
  This message only appears if there are duplicate values and rankings
  are not set to equal, as doing so can cause artefacts in the
  geoprofile surface.

- zeroesAsNAs:

  if true, zero values from the posterior (not referring to hitscores
  yet) are treated as NAs and are unranked. If false, zeros are still
  given ranks and will appear on the output geoprofile surface. This is
  mostly relevant when using masks and setting the transform to 0.

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
