# Calculate hitscores

Calculate hitscores of the potential sources for a given surface
(usually the geoprofile).

## Usage

``` r
geoReportHitscores(params, source, surface)
```

## Arguments

- params:

  input parameters in the format defined by
  [`geoParams()`](https://emmadeeks97.github.io/GeoProfile/reference/geoParams.md).

- source:

  longitude and latitude of one or more source locations in the format
  defined by
  [`geoDataSource()`](https://emmadeeks97.github.io/GeoProfile/reference/geoDataSource.md).

- surface:

  the surface from which to calculate hitscores. Usually an object
  produced by
  [`geoProfile()`](https://emmadeeks97.github.io/GeoProfile/reference/geoProfile.md).

## Examples

``` r
if (FALSE) { # interactive()
# John Snow cholera data
d <- geoData(Cholera$longitude, Cholera$latitude)
s <- geoDataSource(WaterPumps$longitude, WaterPumps$latitude)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p, lambda=0.05)
geoReportHitscores(params = p, source = s, surface = m$geoProfile)
}
```
