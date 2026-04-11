# Create a new data object

Create a new data object

## Usage

``` r
gp.data(
  longitude,
  latitude = NULL,
  lonname = "longitude",
  latname = "latitude",
  is.source = FALSE
)

geoData(...)

geoDataSource(...)
```

## Arguments

- longitude:

  the locations of the observed data in degrees longitude (or
  alternatively a `data.frame` or `list` with latitude and longitude as
  columns).

- latitude:

  the locations of the observed data in degrees latitude or `NULL` if
  `longitude` contains the data in full.

- lonname:

  the name of the longitude column if `longitude` contains the data in
  full.

- latname:

  the name of the latitude column if `longitude` contains the data in
  full.

- is.source:

  `TRUE` if the data is to be considered a source.

- ...:

  arguments to pass to `gp.data()`

## Value

A `gp.data` dataframe containing the data.

## Examples

``` r
# John Snow cholera data
gp.data(WaterPumps$longitude, WaterPumps$latitude)
#> Geoprofile data
#>    longitude latitude
#> 1  -0.139678 51.51486
#> 2  -0.139583 51.51382
#> 3  -0.136670 51.51327
#> 4  -0.139656 51.51007
#> 5  -0.138266 51.51119
#> 6  -0.135990 51.51142
#> 7  -0.133641 51.51202
#> 8  -0.131694 51.51223
#> 9  -0.139649 51.51634
#> 10 -0.137783 51.51662
#> 11 -0.135909 51.51605
#> 12 -0.134724 51.51624
#> 13 -0.134102 51.50995

# Loading all-in-one
gp.data(WaterPumps)
#> Geoprofile data
#>    longitude latitude
#> 1  -0.139678 51.51486
#> 2  -0.139583 51.51382
#> 3  -0.136670 51.51327
#> 4  -0.139656 51.51007
#> 5  -0.138266 51.51119
#> 6  -0.135990 51.51142
#> 7  -0.133641 51.51202
#> 8  -0.131694 51.51223
#> 9  -0.139649 51.51634
#> 10 -0.137783 51.51662
#> 11 -0.135909 51.51605
#> 12 -0.134724 51.51624
#> 13 -0.134102 51.50995

# Loading as source data
gp.data(WaterPumps, is.source = TRUE)
#> Geoprofile sources
#>    longitude latitude
#> 1  -0.139678 51.51486
#> 2  -0.139583 51.51382
#> 3  -0.136670 51.51327
#> 4  -0.139656 51.51007
#> 5  -0.138266 51.51119
#> 6  -0.135990 51.51142
#> 7  -0.133641 51.51202
#> 8  -0.131694 51.51223
#> 9  -0.139649 51.51634
#> 10 -0.137783 51.51662
#> 11 -0.135909 51.51605
#> 12 -0.134724 51.51624
#> 13 -0.134102 51.50995
```
