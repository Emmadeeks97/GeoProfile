# Main TODO

## General package structure changes

- use_pkgdown to get a docs site
- Consider imports, see if they need to be consolidated at all
  - Why use raster, sf, AND terra? That shouldn’t be needed.
  - Same for RColorBrewer & viridis. Are those needed, or should they
    maybe be suggestions?
- Consider package rename?
  - How about `geoprofileR`??
- Brand it (because of course)
- Need to write some tests
- Probably worthwhile shifting over to the cli package for much more
  fully-featured messaging - in progress!
- Examples take a HUGE amount of time to run. This needs to be fixed to
  make development significantly easier.
- Consider shifting from shapefiles in inst/extdata to using something
  better and more modern [see here](http://switchfromshapefile.org/).
  Probably just geopackage?
- Eventually remove the pretty 3D vis from the vignette again. Sadly
  this is too large for a package to really contain in a vignette :’(
- Consider switching over to a class-based system for organising the
  internal workings of geoprofile.
  - Could use S3 or R6

## Obvious code changes

- dRIG & dts take a bool log as an argument but then use the `log`
  function. This could well cause a bug either way round!!!
- rDPM might be able to be optimised

------------------------------------------------------------------------

# Things FW has done

## 02/04/26

- Added gplv3 license (in discussion with ED)
- Set up CI checking using github actions
- Initial R CMD CHECK. Found:
  - 1 error \| 1 warning \| 4 notes
  - Many clashing imports due to the use of `@import` directives.
  - Non-standard files/directories at top level
  - RcppArmadillo doesn’t seem to be used in the package code (this
    needs checking).
  - Missing function definitions in multiple files (`disaggregate`,
    `flush.console`, `get_map`, `grey`), calling_funcs =
    ([`geoPlotLeaflet()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPlotLeaflet.md),
    [`geoPlotMap()`](https://emmadeeks97.github.io/GeoProfile/reference/geoPlotMap.md),
    [`geoSmooth()`](https://emmadeeks97.github.io/GeoProfile/reference/geoSmooth.md))
  - Very *very* long-running examples.
  - Broken example for geoModelSources (calls geoPlotLeaflet with the
    wrong argument mapType = 110)
- Replaced all @examples directives with `@examplesIf interactive()` to
  prevent examples from bogging down the R CMD CHECK system.
- Added R_ignore and TODO.md to .Rbuildignore (so they don’t interfere
  with the build procedure).
- Second R CMD CHECK
  - 0 errors \| 1 warning \| 3 notes
- Moved `GeoProfile.R` to `GeoProfile-package.R` to keep in with
  standard package conventions (and to allow import maintenance using
  `usethis`)
- Moved all import directives to `Geoprofile-package.R`
- Suppressed (temporarily) RcppArmadillo import note. **THIS STILL NEEDS
  TO BE EVALUATED TO SEE IF IT IS NEEDED!**
- `raster` package fully replaced with `terra`!!!
  - This should just work, but it’s definitely worth checking.
- Replaced the following commands with their fully-qualified `::` style
  variants:
  - `fftw2d()` -\>
    [`fftwtools::fftw2d()`](https://rdrr.io/pkg/fftwtools/man/fftw2d.html)
    (x3)
  - [`dnorm()`](https://rdrr.io/r/stats/Normal.html) -\>
    [`stats::dnorm()`](https://rdrr.io/r/stats/Normal.html) (x2)
  - [`density()`](https://rdrr.io/r/stats/density.html) -\>
    [`stats::density()`](https://rdrr.io/r/stats/density.html) (x1)
    \[Note: this might be
    [`terra::density()`](https://rspatial.github.io/terra/reference/density.html)
    instead, but I don’t think so, the args are not correct\]
  - [`optim()`](https://rdrr.io/r/stats/optim.html) -\>
    [`stats::optim()`](https://rdrr.io/r/stats/optim.html) (x1)
  - [`rnorm()`](https://rdrr.io/r/stats/Normal.html) -\>
    [`stats::rnorm()`](https://rdrr.io/r/stats/Normal.html) (x2)
  - `ext()` -\>
    [`terra::ext()`](https://rspatial.github.io/terra/reference/ext.html)
    (x2)
  - `crs()` -\>
    [`terra::crs()`](https://rspatial.github.io/terra/reference/crs.html)
    (x3)
  - `res()` -\>
    [`terra::res()`](https://rspatial.github.io/terra/reference/dimensions.html)
    (x2)
  - `disaggregate()` -\>
    [`terra::disagg()`](https://rspatial.github.io/terra/reference/disaggregate.html)
    (x1) \[Note: this is an actual function name change, though it
    *should* do the same job. Still worth a look.\]
  - `setValues()` -\>
    [`terra::setValues()`](https://rspatial.github.io/terra/reference/setValues.html)
    (x1)
  - `values()` -\>
    [`terra::values()`](https://rspatial.github.io/terra/reference/values.html)
    (x5)
  - `xmin()` -\>
    [`terra::xmin()`](https://rspatial.github.io/terra/reference/xmin.html)
    (x1)
  - `ymin()` -\>
    [`terra::ymin()`](https://rspatial.github.io/terra/reference/xmin.html)
    (x1)
  - `xmax()` -\>
    [`terra::xmax()`](https://rspatial.github.io/terra/reference/xmin.html)
    (x1)
  - `ymax()` -\>
    [`terra::ymax()`](https://rspatial.github.io/terra/reference/xmin.html)
    (x1)
  - `rasterize()` -\>
    [`terra::rasterize()`](https://rspatial.github.io/terra/reference/rasterize.html)
    (x1)
  - `distance()` -\>
    [`terra::distance()`](https://rspatial.github.io/terra/reference/distance.html)
    (x2)
  - [`persp()`](https://rdrr.io/r/graphics/persp.html) -\>
    [`graphics::persp()`](https://rdrr.io/r/graphics/persp.html) (x1)
    \[Note: this might be
    [`terra::persp()`](https://rspatial.github.io/terra/reference/persp.html)
    instead, but I don’t think so, the input is not a SpatVect\]
  - [`barplot()`](https://rdrr.io/r/graphics/barplot.html) -\>
    [`graphics::barplot()`](https://rdrr.io/r/graphics/barplot.html)
    (x2)
  - [`segments()`](https://rdrr.io/r/graphics/segments.html) -\>
    [`graphics::segments()`](https://rdrr.io/r/graphics/segments.html)
    (x2)
  - [`box()`](https://rdrr.io/r/graphics/box.html) -\>
    [`graphics::box()`](https://rdrr.io/r/graphics/box.html) (x2)
  - [`axis()`](https://rdrr.io/r/graphics/axis.html) -\>
    [`graphics::axis()`](https://rdrr.io/r/graphics/axis.html) (x4)
  - [`abline()`](https://rdrr.io/r/graphics/abline.html) -\>
    [`graphics::abline()`](https://rdrr.io/r/graphics/abline.html) (x4)
  - [`lines()`](https://rdrr.io/r/graphics/lines.html) -\>
    [`graphics::lines()`](https://rdrr.io/r/graphics/lines.html) (x4)
  - [`legend()`](https://rdrr.io/r/graphics/legend.html) -\>
    [`graphics::legend()`](https://rdrr.io/r/graphics/legend.html) (x6)
  - [`par()`](https://rdrr.io/r/graphics/par.html) -\>
    [`graphics::par()`](https://rdrr.io/r/graphics/par.html) (x2)
  - [`polygon()`](https://rdrr.io/r/graphics/polygon.html) -\>
    [`graphics::polygon()`](https://rdrr.io/r/graphics/polygon.html)
    (x1)
  - [`points()`](https://rdrr.io/r/graphics/points.html) -\>
    [`graphics::points()`](https://rdrr.io/r/graphics/points.html) (x1)
  - [`text()`](https://rdrr.io/r/graphics/text.html) -\>
    [`graphics::text()`](https://rdrr.io/r/graphics/text.html) (x1)
  - `ggplot()` -\>
    [`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
    (x3)
  - `geom_tile()` -\>
    [`ggplot2::geom_tile()`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
    (x1)
  - `aes_string()` -\>
    [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html)
    (x7) \[Note: `aes_string()` was deprecated in July 2018 in ggplot
    3.0.0!!!!\]
  - `scale_fill_gradientn()` -\>
    [`ggplot2::scale_fill_gradientn()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
    (x2)
  - `coord_cartesian()` -\>
    [`ggplot2::coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html)
    (x3)
  - `labs()` -\>
    [`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html)
    (x2)
  - `geom_raster()` -\>
    [`ggplot2::geom_raster()`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
    (x3)
  - `scale_fill_identity()` -\>
    [`ggplot2::scale_fill_identity()`](https://ggplot2.tidyverse.org/reference/scale_identity.html)
    (x1)
  - `annotation_custom()` -\>
    [`ggplot2::annotation_custom()`](https://ggplot2.tidyverse.org/reference/annotation_custom.html)
    (x1)
  - `scale_fill_manual()` -\>
    [`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
    (x1)
  - `theme()` -\>
    [`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html)
    (x3)
  - `stat_contour()` -\>
    [`ggplot2::stat_contour()`](https://ggplot2.tidyverse.org/reference/geom_contour.html)
    (x1)
  - `geom_point()` -\>
    [`ggplot2::geom_point()`](https://ggplot2.tidyverse.org/reference/geom_point.html)
    (x2)
  - `theme_void()` -\>
    [`ggplot2::theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
    (x1)
  - `element_blank()` -\>
    [`ggplot2::element_blank()`](https://ggplot2.tidyverse.org/reference/element.html)
    (x28)
  - `element_text()` -\>
    [`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html)
    (x3)
  - `margin()` -\>
    [`ggplot2::margin()`](https://ggplot2.tidyverse.org/reference/element.html)
    (x4)
  - `unit()` -\> [`ggplot2::unit()`](https://rdrr.io/r/grid/unit.html)
    (x7)
  - `rel()` -\>
    [`ggplot2::rel()`](https://ggplot2.tidyverse.org/reference/element.html)
    (x1)
  - `leaflet()` -\>
    [`leaflet::leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html)
    (x1)
  - `addProviderTiles()` -\>
    [`leaflet::addProviderTiles()`](https://rstudio.github.io/leaflet/reference/addProviderTiles.html)
    (x1)
  - `addCircleMarkers()` -\>
    [`leaflet::addCircleMarkers()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
    (x2)
  - `addRasterImage()` -\>
    [`leaflet::addRasterImage()`](https://rstudio.github.io/leaflet/reference/addRasterImage.html)
    (x1)
  - `addRectangles()` -\>
    [`leaflet::addRectangles()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
    (x1)
  - `colorNumeric()` -\>
    [`leaflet::colorNumeric()`](https://rstudio.github.io/leaflet/reference/colorNumeric.html)
    (x1)
  - `addLegend()` -\>
    [`leaflet::addLegend()`](https://rstudio.github.io/leaflet/reference/addLegend.html)
    (x1)
  - [`grey()`](https://rdrr.io/r/grDevices/gray.html) -\>
    [`grDevices::grey()`](https://rdrr.io/r/grDevices/gray.html) (x1)
  - [`colorRampPalette()`](https://rdrr.io/r/grDevices/colorRamp.html)
    -\>
    [`grDevices::colorRampPalette()`](https://rdrr.io/r/grDevices/colorRamp.html)
    (x3)
  - `get_map()` -\>
    [`ggmap::get_map()`](https://rdrr.io/pkg/ggmap/man/get_map.html)
    (x1)
  - [`flush.console()`](https://rdrr.io/r/utils/flush.console.html) -\>
    [`utils::flush.console()`](https://rdrr.io/r/utils/flush.console.html)
    (x2)

## 03/04/26

- Started rework of geoParamsCheck code to make it more flexible
- Investigated current docs status for pkgdown
  - It works locally, however I do not have the permissions to fully set
    up the github side.
  - As such, ED will have to run `use_pkgdown_github_pages()` instead.
    This should set up everything on the repo side, including the
    appropriate github config.
- Reworked documentation to use markdown syntax (for which support has
  now been enabled).
  - This means there is now much more in the way of crosslinking between
    help pages, aiding navigation.
- Moved example to a vignette and got to a point where it works (though
  there are certain parts that aren’t working still due to incorrect
  args).
- Added some initial explanatory text to the vignette. As I’m no-where
  near an expert, this probably needs some refining but I did my best.
- Implemented new
  [`geoSurface3D()`](https://emmadeeks97.github.io/GeoProfile/reference/geoSurface3D.md)
  function to allow for interactive 3D plotting (I have a *real* thing
  against static 3D plots. These should at least be more informative.)
- Migrated many user-facing messages to the `cli` package for more
  complete messaging.
  - Still in the process of converting
    [`stop()`](https://rdrr.io/r/base/stop.html) calls.
  - Frankly a lot of these occur in the integrity verifiers, which I
    suspect would benefit from a significant overhaul.
  - I feel they should give a much more thorough report on what is wrong
    with the data, rather than just the first wrong thing they
    encounter.
- geoSurface3D plot now represents a heavily downsampled surface to
  avoid bloating the package too much.
- Overall change in dependencies thusfar: 2 removed (`utils` and
  `raster`), 2 added (`rlang` and `cli`).
  - These are both very sensible dependencies for a modern package to
    have, particularly when it comes to messaging

# Questions/things to investigate

- I have tried to mark anything where there might be a problem with a
  comment starting “# FW:”. You can search for that as a first port of
  call if something doesn’t work, and generally it’s a good idea to keep
  an eye on these.
- Because of the way that imports were previously handled, many
  functions have been replaced with “best guesses”. For example `crs()`
  is in the `raster`, `sf`, and `terra` packages.
  - It is very likely that most of these imports will have been from
    `terra` anyway, but these are super important to check!!!
  - All the base R plotting functions (provided by the `graphics`
    package) seem to have alternatives in terra.
  - Honestly from looking at that code, the graphics version should
    still call the appropriate functions (I hope) but all of the
    plotting is worth checking out.
  - Two functions (`rasterize()` and `distance()`) were using the raster
    version, when a terra version exists. They should be drop-in
    replacements as `terra` has fully superseded `raster` as a package.
    Still worth a check of functionality though.
- I am not precisely sure what the Lorentz plot is for, and as such have
  not written any explanation in the vignette at present.
- Generally speaking, all the documentation needs a chunk of work. It is
  not particularly intuitive to a user without a lot of background
  knowledge.
- I assume lower hitscores are better, but I don’t know this for sure.
- Sadly the pretty 3D vis in the vignette will probably have to be
  removed. It makes the package way too large for something like CRAN to
  like. I’m leaving it in for now though just as an example.
