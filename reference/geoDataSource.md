# Create sources data object in same format as observations

Simple function that ensures that sources are in the correct format
required by Rgeoprofile. Takes longitude and latitude as input vectors
and returns these same values in list format. If no values are input
then default values are used.

## Usage

``` r
geoDataSource(longitude = NULL, latitude = NULL, call = rlang::current_env())
```

## Arguments

- longitude:

  the locations of the potential sources in degrees longitude.

- latitude:

  the locations of the potential sources in degrees latitude.

- call:

  the environment for any checking errors to be emitted from. Only
  really useful for internal use.

## Examples

``` r
if (FALSE) { # interactive()
# John Snow cholera data
geoDataSource(WaterPumps$longitude, WaterPumps$latitude)

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=1, sigma=1, tau=3)
geoDataSource(sim$longitude, sim$latitude)
}
```
