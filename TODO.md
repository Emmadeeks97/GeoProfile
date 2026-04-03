# Main TODO

## General package structure changes

- use_pkgdown to get a docs site
- Rework all documentation to use the proper markdown format (which will aid with crosslinking)
- Consider imports, see if they need to be consolidated at all
  - Why use raster, sf, AND terra? That shouldn't be needed.
  - Same for RColorBrewer & viridis. Are those needed, or should they maybe be suggestions?
- Move/rework demo into a proper vignette
- Consider package rename?
  - How about `geoprofileR`??
- Brand it (because of course)
- Need to write some tests
- Probably worthwhile shifting over to the cli package for much more fully-featured messaging
- Examples take a HUGE amount of time to run. This needs to be fixed to make development significantly easier.
- Consider shifting from shapefiles in inst/extdata to using something better and more modern [see here](http://switchfromshapefile.org/). Probably just geopackage?

## Obvious code changes
- dRIG & dts take a bool log as an argument but then use the `log` function. This could well cause a bug either way round!!!
- rDPM might be able to be optimised
- asserts are almost certainly not necessary and are likely from someone familiar programming in another language. Can likely be replaced ad-hoc.
  - Specifically they lead to incredibly non-idiomatic R. This is not good for maintenance.
  - They also hide extra assertions within themselves (i.e. assert_single actually also asserts that the tested value is non-null. But NULL is nominally singular, kinda.)
  - IN FACT on closer inspection they're all commented out anyway. As such assertions.R can and should be removed.
  
---

# Things FW has done

## 02/04/26

- Added gplv3 license (in discussion with ED)
- Set up CI checking using github actions
- 
- Initial R CMD CHECK. Found:
  - 1 error | 1 warning | 4 notes
  - Many clashing imports due to the use of `@import` directives.
  - Non-standard files/directories at top level
  - RcppArmadillo doesn't seem to be used in the package code (this needs checking).
  - Missing function definitions in multiple files (`disaggregate`, `flush.console`, `get_map`, `grey`), calling_funcs = (`geoPlotLeaflet()`, `geoPlotMap()`, `geoSmooth()`)
  - Very _very_ long-running examples.
  - Broken example for geoModelSources (calls geoPlotLeaflet with the wrong argument mapType = 110)
- Replaced all @examples directives with `@examplesIf interactive()` to prevent examples from bogging down the R CMD CHECK system.
- Added R_ignore and TODO.md to .Rbuildignore (so they don't interfere with the build procedure).
- Second R CMD CHECK
  - 0 errors | 1 warning | 3 notes
- Moved `GeoProfile.R` to `GeoProfile-package.R` to keep in with standard package conventions (and to allow import maintenance using `usethis`)
- Moved all import directives to `Geoprofile-package.R`
- Suppressed (temporarily) RcppArmadillo import note. **THIS STILL NEEDS TO BE EVALUATED TO SEE IF IT IS NEEDED!**
- `raster` package fully replaced with `terra`!!!
  - This should just work, but it's definitely worth checking.
- Replaced the following commands with their fully-qualified `::` style variants:
  - `fftw2d()` -> `fftwtools::fftw2d()` (x3)
  - `dnorm()` -> `stats::dnorm()` (x2)
  - `density()` -> `stats::density()` (x1) [Note: this might be `terra::density()` instead, but I don't think so, the args are not correct]
  - `optim()` -> `stats::optim()` (x1)
  - `rnorm()` -> `stats::rnorm()` (x2)
  - `ext()` -> `terra::ext()` (x2)
  - `crs()` -> `terra::crs()` (x3)
  - `res()` -> `terra::res()` (x2)
  - `disaggregate()` -> `terra::disagg()` (x1) [Note: this is an actual function name change, though it _should_ do the same job. Still worth a look.]
  - `setValues()` -> `terra::setValues()` (x1)
  - `values()` -> `terra::values()` (x5)
  - `xmin()` -> `terra::xmin()` (x1)
  - `ymin()` -> `terra::ymin()` (x1)
  - `xmax()` -> `terra::xmax()` (x1)
  - `ymax()` -> `terra::ymax()` (x1)
  - `rasterize()` -> `terra::rasterize()` (x1)
  - `distance()` -> `terra::distance()` (x2)
  - `persp()` -> `graphics::persp()` (x1) [Note: this might be `terra::persp()` instead, but I don't think so, the input is not a SpatVect]
  - `barplot()` -> `graphics::barplot()` (x2)
  - `segments()` -> `graphics::segments()` (x2)
  - `box()` -> `graphics::box()` (x2)
  - `axis()` -> `graphics::axis()` (x4)
  - `abline()` -> `graphics::abline()` (x4)
  - `lines()` -> `graphics::lines()` (x4)
  - `legend()` -> `graphics::legend()` (x6)
  - `par()` -> `graphics::par()` (x2)
  - `polygon()` -> `graphics::polygon()` (x1)
  - `points()` -> `graphics::points()` (x1)
  - `text()` -> `graphics::text()` (x1)
  - `ggplot()` -> `ggplot2::ggplot()` (x3)
  - `geom_tile()` -> `ggplot2::geom_tile()` (x1)
  - `aes_string()` -> `ggplot2::aes_string()` (x7)
  - `scale_fill_gradientn()` -> `ggplot2::scale_fill_gradientn()` (x2)
  - `coord_cartesian()` -> `ggplot2::coord_cartesian()` (x3)
  - `labs()` -> `ggplot2::labs()` (x2)
  - `geom_raster()` -> `ggplot2::geom_raster()` (x3)
  - `scale_fill_identity()` -> `ggplot2::scale_fill_identity()` (x1)
  - `annotation_custom()` -> `ggplot2::annotation_custom()` (x1)
  - `scale_fill_manual()` -> `ggplot2::scale_fill_manual()` (x1)
  - `theme()` -> `ggplot2::theme()` (x3)
  - `stat_contour()` -> `ggplot2::stat_contour()` (x1)
  - `geom_point()` -> `ggplot2::geom_point()` (x2)
  - `theme_void()` -> `ggplot2::theme_void()` (x1)
  - `element_blank()` -> `ggplot2::element_blank()` (x28)
  - `element_text()` -> `ggplot2::element_text()` (x3)
  - `margin()` -> `ggplot2::margin()` (x4)
  - `unit()` -> `ggplot2::unit()` (x7)
  - `rel()` -> `ggplot2::rel()` (x1)
  - `leaflet()` -> `leaflet::leaflet()` (x1)
  - `addProviderTiles()` -> `leaflet::addProviderTiles()` (x1)
  - `addCircleMarkers()` -> `leaflet::addCircleMarkers()` (x2)
  - `addRasterImage()` -> `leaflet::addRasterImage()` (x1)
  - `addRectangles()` -> `leaflet::addRectangles()` (x1)
  - `colorNumeric()` -> `leaflet::colorNumeric()` (x1)
  - `addLegend()` -> `leaflet::addLegend()` (x1)
  - `grey()` -> `grDevices::grey()` (x1)
  - `colorRampPalette()` -> `grDevices::colorRampPalette()` (x3)
  - `get_map()` -> `ggmap::get_map()` (x1)
  - `flush.console()` -> `utils::flush.console()` (x2)
  
## 03/04/26

- Started rework of geoParamsCheck code to make it more flexible
- Investigated current docs status for pkgdown
  - It works locally, however I do not have the permissions to fully set up the github side.
  - As such, ED will have to run `use_pkgdown_github_pages()` instead. This should set up everything on the repo side, including the appropriate github config.
- Reworked documentation to use markdown syntax (for which support has now been enabled).
  - This means there is now much more in the way of crosslinking between help pages, aiding navigation.

# Questions/things to investigate

- I have tried to mark anything where there might be a problem with a comment starting "# FW:". You can search for that as a first port of call if something doesn't work.
- Because of the way that imports were previously handled, many functions have been replaced with "best guesses". For example `crs()` is in the `raster`, `sf`, and `terra` packages.
- It is very likely that most of these imports will have been from `terra` anyway, but these are super important to check!!!
- All the base R plotting functions (provided by the `graphics` package) seem to have alternatives in terra.
- Honestly from looking at that code, the graphics version should still call the appropriate functions (I hope) but all of the plotting is worth checking out.
- Two functions (`rasterize()` and `distance()`) were using the raster version, when a terra version exists. They should be drop-in replacements as `terra` has fully superseded `raster` as a package. Still worth a check of functionality though.
