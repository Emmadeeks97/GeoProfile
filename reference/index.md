# Package index

## Specification

Functions for specifying a geoprofiling task.

- [`geoDataCheck()`](https://emmadeeks97.github.io/GeoProfile/reference/geoDataCheck.md)
  : Check data
- [`geoParamsCheck()`](https://emmadeeks97.github.io/GeoProfile/reference/geoParamsCheck.md)
  : Check parameters
- [`geoShapefile()`](https://emmadeeks97.github.io/GeoProfile/reference/geoShapefile.md)
  : Import shapefile
- [`gp.data()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.data.md)
  [`geoData()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.data.md)
  [`geoDataSource()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.data.md)
  : Create a new data object
- [`gp.params()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.params.md)
  [`geoParams()`](https://emmadeeks97.github.io/GeoProfile/reference/gp.params.md)
  : Create a new parameters object

## Profiling and Processing

Functions for performing geoprofiling and processing the results.

- [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md)
  : MCMC under Rgeoprofile model

- [`geoMask()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMask.md)
  : Incorporate shapefile or raster information into a geoprofile

- [`geoModelSources()`](https://emmadeeks97.github.io/GeoProfile/reference/geoModelSources.md)
  :

  Extract latitude and longitude of points identified as sources by
  [`geoMCMC()`](https://emmadeeks97.github.io/GeoProfile/reference/geoMCMC.md)

- [`geoProfile()`](https://emmadeeks97.github.io/GeoProfile/reference/geoProfile.md)
  : Calculate geoprofile from surface

- [`geoReportHitscores()`](https://emmadeeks97.github.io/GeoProfile/reference/geoReportHitscores.md)
  : Calculate hitscores

- [`geoRing()`](https://emmadeeks97.github.io/GeoProfile/reference/geoRing.md)
  : Produces a surface based on an alternative ring-search strategy

- [`geoSmooth()`](https://emmadeeks97.github.io/GeoProfile/reference/geoSmooth.md)
  : Produce a smooth surface using 2D kernel density smoothing

## Plotting

Methods of visualising geoprofiles.

- [`geoPersp()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPersp.md)
  : Perspective plot of geoprofile or raw probabilities
- [`geoPlotAllocation()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPlotAllocation.md)
  : Plot posterior allocation
- [`geoPlotCoallocation()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPlotCoallocation.md)
  : Calculate and plot probability of coallocation
- [`geoPlotLeaflet()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPlotLeaflet.md)
  : Plot a map and overlay data and/or geoprofile via leaflet
- [`geoPlotLorenz()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPlotLorenz.md)
  : Produce Lorenz Plot
- [`geoPlotMap()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPlotMap.md)
  : Plot a map and overlay data and/or geoprofile using google maps
- [`geoPlotSigma()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPlotSigma.md)
  : Plot prior and posterior distributions of sigma.
- [`geoSurface3D()`](https://emmadeeks97.github.io/GeoProfile/reference/geoSurface3D.md)
  : Interactive 3D plot of geoprofile or raw probabilities
- [`unknownPleasures()`](https://emmadeeks97.github.io/GeoProfile/reference/unknownPleasures.md)
  : Unknown pleasures

## Data

Provided datasets.

- [`Cholera`](https://emmadeeks97.github.io/GeoProfile/reference/Cholera.md)
  : Cholera data
- [`LondonExample_crimes`](https://emmadeeks97.github.io/GeoProfile/reference/LondonExample_crimes.md)
  : Example London crimes
- [`LondonExample_sources`](https://emmadeeks97.github.io/GeoProfile/reference/LondonExample_sources.md)
  : Example London sources
- [`WaterPumps`](https://emmadeeks97.github.io/GeoProfile/reference/WaterPumps.md)
  : Cholera sources

## Deprecated

Functions that are deprecated and will be removed in future versions.

## Other

Miscellaneous functions.

- [`rDPM()`](https://emmadeeks97.github.io/GeoProfile/reference/rDPM.md)
  : Draw from Dirichlet process mixture model
