# Plot a map and overlay data and/or geoprofile using google maps

Plots geoprofile on map, with various customisable options. Warning:
google maps requires an API key. For a faster plotting method that has
more API free options, use the
[`geoPlotLeaflet()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPlotLeaflet.md)
function.

## Usage

``` r
geoPlotMap(
  params,
  data = NULL,
  source = NULL,
  surface = NULL,
  surfaceCols = NULL,
  smoothScale = TRUE,
  hitscoreType = c("percentage", "absolute"),
  gpLegend = TRUE,
  opacity = 0.4,
  threshold = 1,
  removeNAs = TRUE,
  breakPercent = seq(0, 100, length.out = 11),
  xbreaks = 100,
  ybreaks = 100,
  plotContours = FALSE,
  contoursMatchResolution = TRUE,
  contourCol = "grey50",
  contourWeight = 0.3,
  contourOpacity = 1,
  zoom = NULL,
  latLimits = NULL,
  lonLimits = NULL,
  mapSource = "google",
  mapType = "hybrid",
  crimeCex = 1.5,
  crimeCol = "red",
  crimeBorderCol = "white",
  crimeBorderWidth = 0.5,
  sourceCex = 1.5,
  sourceCol = "blue",
  colOpacity = 1
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

- smoothScale:

  should plot legend show continuous (`TRUE`) or discrete (`FALSE`)
  colours.

- hitscoreType:

  `"percentage"` = hit score percentage (0-100); `"absolute"` = absolute
  hit score (0-1, i.e. not multiplied by 100).

- gpLegend:

  whether or not to add the legend to the plot. `TRUE` shows the legend,
  `FALSE` removes it.

- opacity:

  value between `0` and `1` giving the opacity of surface colours.

- threshold:

  defines the range of hitscores plotted. i.e., 1 includes all hitscore
  values (100-0) and should cover the entire map (unless a mask has been
  applied). Lower values restrict the plot to particular hitscores i.e.,
  0.1 = the top 10%.

- removeNAs:

  `TRUE` removes bins with NA hitscores from the plot, `FALSE` leaves
  them in and they are plotted as grey.

- breakPercent:

  only relevant when `smoothScale` is `FALSE`, defines the band edges
  for discrete colour coding and contours. Always given on the 0-100
  scale, regardless of `hitscoreType`.

- xbreaks:

  assigns the resolution of the plotted geoprofile surface for the x
  axis. Larger numbers take longer to process. Test at low values
  initially. Select values that divide cleanly into the surface cell
  count. Do not choose values greater than the geoprofile surface cell
  count.

- ybreaks:

  assigns the resolution of the plotted geoprofile surface for the y
  axis. Larger numbers take longer to process. Test at low values
  initially. Select values that divide cleanly into the surface cell
  count. Do not choose values greater than the geoprofile surface cell
  count.

- plotContours:

  whether or not to add contours to the surface plot.

- contoursMatchResolution:

  if `TRUE`, contours are drawn from the binned (`xbreaks` / `ybreaks`)
  surface so they match the rectangles, `FALSE` draws them from the full
  resolution surface.

- contourCol:

  single colour to plot contour lines showing boundaries on surface.

- contourWeight:

  contour line width.

- contourOpacity:

  contour line opacity, a value between `0` and `1`.

- zoom:

  zoom level of map. If `NULL` then choose optimal zoom from params.

- latLimits:

  optional vector setting min and max latitude for zoom view.

- lonLimits:

  optional vector setting min and max longitude for zoom view.

- mapSource:

  which online source to use when downloading the map. Options include
  Google Maps (`"google"`), OpenStreetMap (`"osm"`), Stamen Maps
  (`"stamen"`) and CloudMade maps (`"cloudmade"`). An API key is
  required for using Google Maps and potentially some of the other
  sources. Register your key before running this function by using the
  `register_google()` function.

- mapType:

  the specific type of map to plot. Options available are `"terrain"`,
  `"satellite"`, `"roadmap"` and `"hybrid"` (google maps),
  `"terrain-background"`, `"terrain"`, `"watercolor"` and `"toner"`
  (stamen maps) or a positive integer for cloudmade maps (see
  [`ggmap::get_cloudmademap()`](https://rdrr.io/pkg/ggmap/man/get_cloudmademap.html)
  for details).

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

- colOpacity:

  opacity of the crime and source points, a value between `0` and `1`.

## Value

A `ggplot2` plot object.

## Examples

``` r
if (FALSE) { # interactive()
if (FALSE) { # \dontrun{
# London example data, all options shown
d <- LondonExample_crimes
s <- LondonExample_sources
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
           surfaceCols = c("blue", "white"),
           smoothScale = TRUE,
           hitscoreType = "percentage",
           gpLegend = TRUE,
           opacity = 0.4,
           threshold = 0.1,
           removeNAs = TRUE,
           breakPercent = seq(0, 100, length.out = 11),
           xbreaks = 50, ybreaks = 50,
           plotContours = FALSE,
           contoursMatchResolution = TRUE,
           contourCol = "grey50", contourWeight = 0.3, contourOpacity = 1,
           zoom = NULL, latLimits = NULL, lonLimits = NULL,
           mapSource = "google", mapType = "hybrid",
           crimeCex = 2, crimeCol = "black",
           crimeBorderCol = "white", crimeBorderWidth = 0.5,
           sourceCex = 2, sourceCol = "red",
           colOpacity = 1)

# John Snow cholera data, discrete colours, contours and absolute hit scores
d <- Cholera
s <- WaterPumps
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p, lambda = 0.05)
geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
           smoothScale = FALSE,
           hitscoreType = "absolute",
           threshold = 0.5,
           breakPercent = seq(0, 50, 5),
           xbreaks = 50, ybreaks = 50,
           plotContours = TRUE,
           contoursMatchResolution = TRUE,
           contourCol = "white", contourWeight = 0.5, contourOpacity = 0.8,
           mapType = "hybrid",
           crimeCol = "black", crimeCex = 2,
           sourceCol = "red", sourceCex = 2)

# simulated data, change colour palette, map type, opacity and range of geoprofile
sim <- rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
51.5235505, alpha = 1, sigma = 1, tau = 3)
d <- geoData(sim$longitude, sim$latitude)
s <- geoDataSource(sim$source_lon, sim$source_lat)
p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
m <- geoMCMC(data = d, params = p)
geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
           surfaceCols = c("blue", "white"),
           opacity = 0.7,
           breakPercent = seq(0, 30, 5),
           mapType = "terrain",
           crimeCol = "black", crimeBorderCol = "white", crimeCex = 2,
           sourceCol = "red", sourceCex = 2)
} # }
}
```
