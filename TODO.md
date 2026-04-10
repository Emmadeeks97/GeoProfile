# Main TODO

## General package structure changes

- use_pkgdown to get a docs site
- Consider imports, see if they need to be consolidated at all
  - Why use raster, sf, AND terra? That shouldn't be needed.
  - Same for RColorBrewer & viridis. Are those needed, or should they maybe be suggestions?
- Consider package rename?
  - How about `geoprofileR`??
- Brand it (because of course)
- Need to write some tests
- Probably worthwhile shifting over to the cli package for much more fully-featured messaging - in progress!
- Examples take a HUGE amount of time to run. This needs to be fixed to make development significantly easier.
- Consider shifting from shapefiles in inst/extdata to using something better and more modern [see here](http://switchfromshapefile.org/). Probably just geopackage?
- Eventually remove the pretty 3D vis from the vignette again. Sadly this is too large for a package to really contain in a vignette :'(
- Consider switching over to a class-based system for organising the internal workings of geoprofile.
  - Could use S3 or R6

## Obvious code changes
- rDPM might be able to be optimised
  
---

# Things FW has done

## 02/04/26

- Added gplv3 license (in discussion with ED)
- Set up CI checking using github actions
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
  - `aes_string()` -> `ggplot2::aes()` (x7) [Note: `aes_string()` was deprecated in July 2018 in ggplot 3.0.0!!!!]
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
- Moved example to a vignette and got to a point where it works (though there are certain parts that aren't working still due to incorrect args).
- Added some initial explanatory text to the vignette. As I'm no-where near an expert, this probably needs some refining but I did my best.
- Implemented new `geoSurface3D()` function to allow for interactive 3D plotting (I have a _real_ thing against static 3D plots. These should at least be more informative.)
- Migrated many user-facing messages to the `cli` package for more complete messaging.
  - Still in the process of converting `stop()` calls.
  - Frankly a lot of these occur in the integrity verifiers, which I suspect would benefit from a significant overhaul.
  - I feel they should give a much more thorough report on what is wrong with the data, rather than just the first wrong thing they encounter.
- geoSurface3D plot now represents a heavily downsampled surface to avoid bloating the package too much.
- Overall change in dependencies thusfar: 2 removed (`utils` and `raster`), 3 added (`rlang` , and `cli`).
  - These are all very sensible dependencies for a modern package to have, particularly when it comes to messaging.

## 09/04/26

- Started to move functionality over to an [S3 class system](https://adv-r.hadley.nz/s3.html).
  - All parameter objects have been moved across to a new `gp.params` class.
  - All data objects have been moved across to a new `gp.data` class.
  - These are drop-in replacements for the old lists.
  - The old functions currently redirect to the new classes with a warning.
  - Soft-deprecated `geoData()`, `geoDataSource()` and `geoParams()`
- Fixed unspecified behaviour around log arg in `dts()` and `dRIG()`
  - These likely only worked due to the way that R calls primitives vs regular R variables
  - Looks like it didn't actually have an effect on the code, but the functionality is now more explicit (by replacing the `log` arg with a `logspace` arg).
- Minor changes to `geoMCMC()` to make maintenance easier.

## 10/04/26

- Reformatting of the pkgdown site setup to group topics into categories.
- Added params & data to output of geoMCMC
  - This is in preparation for a more in-depth rework of how data is passed to post-processing and plotting functions.
  - It keeps together all the information used to make a geoprofile, which should lead to easier and more reliable plotting, especially when performing multiple geoprofiles at once.
  - I will either add an argument for sources to geoMCMC, or add appropriate functions to add source data to a gp.profile object.
  - This does lead to larger geoprofile objects in general, but point data is always going to be smaller than rasters, so this should be fine.
- Move functions to R files with more reasonable groupings.
- `geoModelSources()` now returns a data.frame (as longitude and latitude should always be the same length, and dfs are much easier to work with downstream than lists.)
- `geoData()`, `geoDataSources()` and `gp.data()` now return data.frame objects rather than lists. This should be a more sensible approach that should fail earlier if data is not in the correct format.
- `geoMCMC()` now returns a `gp.profile` object
- Added nice printing for `gp.profile` objects to make for nicer summaries.
- Added return values to the docs of (hopefully) all exported functions.

# Questions/things to investigate

- I have tried to mark anything where there might be a problem with a comment starting "# FW:". You can search for that as a first port of call if something doesn't work, and generally it's a good idea to keep an eye on these.
- Because of the way that imports were previously handled, many functions have been replaced with "best guesses". For example `crs()` is in the `raster`, `sf`, and `terra` packages.
  - It is very likely that most of these imports will have been from `terra` anyway, but these are super important to check!!!
  - All the base R plotting functions (provided by the `graphics` package) seem to have alternatives in terra.
  - Honestly from looking at that code, the graphics version should still call the appropriate functions (I hope) but all of the plotting is worth checking out.
  - Two functions (`rasterize()` and `distance()`) were using the raster version, when a terra version exists. They should be drop-in replacements as `terra` has fully superseded `raster` as a package. Still worth a check of functionality though.
- I am not precisely sure what the Lorentz plot is for, and as such have not written any explanation in the vignette at present.
- Generally speaking, all the documentation needs a chunk of work. It is not particularly intuitive to a user without a lot of background knowledge. 
- I assume lower hitscores are better, but I don't know this for sure.
- Sadly the pretty 3D vis in the vignette will probably have to be removed. It makes the package way too large for something like CRAN to like. I'm leaving it in for now though just as an example.
