# Plot a map and overlay data and/or geoprofile using google maps

Plots geoprofile on map, with various customisable options.

## Usage

``` r
geoPlotMap(
  params,
  data = NULL,
  source = NULL,
  surface = NULL,
  surfaceCols = NULL,
  zoom = NULL,
  latLimits = NULL,
  lonLimits = NULL,
  mapSource = "google",
  mapType = "hybrid",
  opacity = 0.6,
  plotContours = TRUE,
  breakPercent = seq(0, 100, l = 11),
  contourCol = "grey50",
  smoothScale = TRUE,
  crimeCex = 1.5,
  crimeCol = "red",
  crimeBorderCol = "white",
  crimeBorderWidth = 0.5,
  sourceCex = 1.5,
  sourceCol = "blue",
  gpLegend = TRUE
)
```

## Arguments

- params:

  parameters list in the format defined by
  [`geoParams()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.params.md).

- data:

  data object in the format defined by
  [`geoData()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.data.md).

- source:

  potential sources object in the format defined by
  [`geoDataSource()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.data.md).

- surface:

  a surface to overlay onto the map, typically a geoprofile obtained
  from the output of
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md).

- surfaceCols:

  vector of two or more colours to plot surface. Defaults to viridis
  palette.

- zoom:

  zoom level of map. If `NULL` then choose optimal zoom from params.

- latLimits:

  optional vector setting min and max latitude for zoom view.

- lonLimits:

  optional vector setting min and max longitude for zoom view.

- mapSource:

  which online source to use when downloading the map. Options include
  Google Maps (`"google"`), OpenStreetMap (`"osm"`), Stamen Maps
  (`"stamen"`) and CloudMade maps (`"cloudmade"`).

- mapType:

  the specific type of map to plot. Options available are `"terrain"`,
  `"satellite"`, `"roadmap"` and `"hybrid"` (google maps),
  `"terrain-background"`, `"terrain"`, `"watercolor"` and `"toner"`
  (stamen maps) or a positive integer for cloudmade maps (see
  [`ggmap::get_cloudmademap()`](https://rdrr.io/pkg/ggmap/man/get_cloudmademap.html)
  for details).

- opacity:

  value between `0` and `1` giving the opacity of surface colours.

- plotContours:

  whether or not to add contours to the surface plot.

- breakPercent:

  vector of values between `0` and `100` describing where in the surface
  contours appear.

- contourCol:

  single colour to plot contour lines showing boundaries on surface.

- smoothScale:

  should plot legend show continuous (`TRUE`) or discrete (`FALSE`)
  colours.

- crimeCex:

  relative size of symbols showing crimes.

- crimeCol:

  colour of crime symbols.

- crimeBorderCol:

  border colour of crime symbols.

- crimeBorderWidth:

  width of border of crime symbols.

- sourceCex:

  relative size of symbols showing suspect sites.

- sourceCol:

  colour of suspect sites symbols.

- gpLegend:

  whether or not to add legend to plot.

## Value

A `ggplot2` plot object.

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
geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
                breakPercent = seq(0, 50, 5), mapType = "hybrid",
                crimeCol = "black", crimeCex = 2, sourceCol = "red", sourceCex = 2)

# John Snow cholera data
d <- Cholera
s <- WaterPumps
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p, lambda=0.05)
# produce simple map
geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
                breakPercent = seq(0, 50, 5), mapType = "hybrid",
                crimeCol = "black", crimeCex = 2, sourceCol = "red", sourceCex = 2)

# simulated data
sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha=1, sigma=1, tau=3)
d <- geoData(sim$longitude, sim $latitude)
s <- geoDataSource(sim$source_lon, sim$source_lat)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
# change colour palette, map type, opacity and range of geoprofile and omit legend
geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
                breakPercent = seq(0, 30, 5), mapType = "terrain",
                surfaceCols = c("blue","white"), crimeCol = "black",
                crimeBorderCol = "white",crimeCex = 2, sourceCol = "red", sourceCex = 2,
                opacity = 0.7, gpLegend = FALSE)
} # }
}
```
