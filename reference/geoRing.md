# Produces a surface based on an alternative ring-search strategy

Produces a surface based on an alternative ring-search strategy (ie
searching in an expanding radius out from the 'crimes'). The output from
this function can be used with
[`geoProfile()`](https://emmadeeks97.github.io/GeoProfile/reference/geoProfile.md)
and
[`geoReportHitscores()`](https://emmadeeks97.github.io/GeoProfile/reference/geoReportHitscores.md)
to produce a map and hitscores based on this strategy.

## Usage

``` r
geoRing(params, data, source, mcmc)
```

## Arguments

- params:

  Parameters list in the format defined by
  [`geoParams()`](https://emmadeeks97.github.io/GeoProfile/reference/geoParams.md).

- data:

  Data object in the format defined by
  [`geoData()`](https://emmadeeks97.github.io/GeoProfile/reference/geoData.md).

- source:

  Potential sources object in the format defined by
  [`geoDataSource()`](https://emmadeeks97.github.io/GeoProfile/reference/geoDataSource.md).

- mcmc:

  mcmc object of the form produced by
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).

## Examples

``` r
if (FALSE) { # interactive()
# \donttest{
# John Snow cholera data
d <- geoData(Cholera$longitude, Cholera$latitude)
s <- geoDataSource(WaterPumps$longitude, WaterPumps$latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
surface_ring <- geoRing(params = p, data = d, source = s, mcmc = m)
gp_ring <- geoProfile(surface = surface_ring)
map <- geoPlotLeaflet(params = p,
                      data = d,
                      source = s,
                      surface = gp_ring,
                      opacity = 1)
map
# }
}
```
