# Plot a map and overlay data and/or geoprofile via leaflet

Plots geoprofile on map, with various customisable options. Interactive
and static map options available.

## Usage

``` r
geoPlotLeaflet(
  params = NULL,
  data = NULL,
  source = NULL,
  surface = NULL,
  surfaceCols = c("#F0F921FF", "#FDC926FF", "#FA9E3BFF", "#ED7953FF", "#D8576BFF",
    "#BD3786FF", "#9C179EFF", "#7301A8FF", "#47039FFF", "#0D0887FF"),
  threshold = 0.1,
  smoothing = 1,
  opacity = 0.8,
  plotContours = FALSE,
  contourBreaks = seq(0, 100, length.out = 11),
  contourCol = "grey50",
  contourWeight = 1,
  contourOpacity = 1,
  crimeCex = 1.5,
  crimeCol = "red",
  sourceCex = 1.5,
  sourceCol = "blue",
  colOpacity = 1,
  mapType = "Esri.WorldImagery",
  apiKey = NULL,
  showBoundary = TRUE,
  boundaryWeight = 2,
  boundaryCol = grDevices::grey(0.2),
  gpLegend = FALSE,
  legendPosition = "bottomright",
  legendScale = 1,
  saveFile = NULL,
  cropToBoundary = TRUE,
  mapZoom = 5,
  saveWidth = 1200,
  saveHeight = 1200,
  saveZoom = 2
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

- threshold:

  what level of the geoprofile to display. 1 = the whole geoprofile
  surface. 0.1 = the top 10% of the surface.

- smoothing:

  smoothing affects the plotted resolution of the colour heatmaps.
  Higher values = more pixels, smoother colour gradients but increased
  plotting time.

- opacity:

  value between `0` and `1` giving the opacity of surface colours.

- plotContours:

  Another way of viewing the geoprofile surface which uses contour lines
  to represent the surface as a heightmap.

- contourBreaks:

  hitscore % levels, as in breakPercent. Set the range and bins of the
  geoprofile surface the contours will represent.

- contourCol:

  colour of contour lines.

- contourWeight:

  thickness of contour lines.

- contourOpacity:

  opacity of contour lines.

- crimeCex:

  relative size of symbols showing crimes.

- crimeCol:

  colour of crime symbols.

- sourceCex:

  relative size of symbols showing suspect sites.

- sourceCol:

  colour of suspect sites symbols.

- colOpacity:

  opacity of crime and source colours.

- mapType:

  the specific type of map to plot. See
  [leaflet::providers](https://rstudio.github.io/leaflet/reference/providers.html)
  for options.

- apiKey:

  API keys may be required for some maptypes. Note: API keys for Carto
  maps will not work with the current leaflet package version available
  on CRAN.

- showBoundary:

  plot a bounding box that encompasses the extent of the geoprofile
  surface.

- boundaryWeight:

  thickness of the bounding box.

- boundaryCol:

  colour of the boundary box.

- gpLegend:

  whether or not to add legend to plot.

- legendPosition:

  "bottomright", \# "topright", "bottomright", "bottomleft", "topleft".

- legendScale:

  size of the legend.

- saveFile:

  take a static screenshot of the plot for figures. UI such as the zoom
  options are automatically removed. Set by inputting a name for the
  resulting file.

- cropToBoundary:

  crop so that the saved figure matches the extent of the geoprofile
  surface.

- mapZoom:

  control the zoom of the plot. Ignored if cropToBoundary = TRUE.

- saveWidth:

  set the width of the resulting saved image.

- saveHeight:

  set the height of the resulting saved image.

- saveZoom:

  does not affect the zoom of the map but instead affects the resolution
  of the saved image. Affects the zoom option of the function
  [webshot2::webshot](https://rstudio.github.io/webshot2/reference/webshot.html).

## Value

A `leaflet` plot object.

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
