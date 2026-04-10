# Plot a map and overlay data and/or geoprofile via leaflet

Plots geoprofile on map, with various customisable options.

## Usage

``` r
geoPlotLeaflet(
  params = NULL,
  data = NULL,
  surface = NULL,
  source = NULL,
  surfaceCols = c("#F0F921FF", "#FDC926FF", "#FA9E3BFF", "#ED7953FF", "#D8576BFF",
    "#BD3786FF", "#9C179EFF", "#7301A8FF", "#47039FFF", "#0D0887FF"),
  crimeCex = 1.5,
  crimeCol = "red",
  sourceCex = 1.5,
  sourceCol = "blue",
  map_type = "CartoDB.Positron",
  threshold = 0.1,
  opacity = 0.8,
  colOpacity = 1,
  smoothing = 1,
  gpLegend = FALSE
)
```

## Arguments

- params:

  parameters list in the format defined by
  [`geoParams()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.params.md).

- data:

  data object in the format defined by
  [`geoData()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.data.md).

- surface:

  a surface to overlay onto the map, typically a geoprofile obtained
  from the output of
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).

- source:

  potential sources object in the format defined by
  [`geoDataSource()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.data.md).

- surfaceCols:

  vector of two or more colours to plot surface. Defaults to viridis
  palette.

- crimeCex:

  relative size of symbols showing crimes.

- crimeCol:

  colour of crime symbols.

- sourceCex:

  relative size of symbols showing suspect sites.

- sourceCol:

  colour of suspect sites symbols.

- map_type:

  the specific type of map to plot. See
  [leaflet::providers](https://rstudio.github.io/leaflet/reference/providers.html)
  for options.

- threshold:

  what level of the geoprofile to display

- opacity:

  value between `0` and `1` giving the opacity of surface colours.

- colOpacity:

  opacity of crime and source colours

- smoothing:

  smooth profile

- gpLegend:

  whether or not to add legend to plot.

## Examples

``` r
if (FALSE) { # interactive()
if (FALSE) { # \dontrun{
# London example data
d <- LondonExample_crimes
s <- LondonExample_sources
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
# produce simple map
geoPlotLeaflet(params = p,
               data = d,
               source = s,
               surface = m$geoProfile,
               map_type = 110,
               crimeCol = "black",
               crimeCex = 2,
               sourceCol = "red",
               sourceCex = 2)

# John Snow cholera data
d <- Cholera
s <- WaterPumps
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p, lambda=0.05)
# produce simple map
geoPlotLeaflet(params = p,
               data = d,
               source = s,
               surface = m$geoProfile,
               map_type = 110,
               crimeCol = "black",
               crimeCex = 2,
               sourceCol = "red",
               sourceCex = 2)

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=1, sigma=1, tau=3)
d <- geoData(sim$longitude, sim $latitude)
s <- geoDataSource(sim$source_lon, sim$source_lat)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
# change colour palette, map type, opacity and range of geoprofile and omit legend
geoPlotLeaflet(params = p,
               data = d,
               source = s,
               surface = m$geoProfile,
               map_type = 110,
               surfaceCols = c("blue","white"),
               crimeCol = "black",
               crimeCex = 2,
               sourceCol = "red",
               sourceCex = 2,
               opacity = 0.7,
               gpLegend = FALSE)
} # }
}
```
