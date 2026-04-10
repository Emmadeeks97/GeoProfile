# GeoProfile 0.1.0

> This is a revival of [RgeoProfile](https://github.com/bobverity/Rgeoprofile) originally by Bob Verity.
> As such the changelog for 0.1.0 is relative to the last release of Rgeoprofile.

* New `geoPlotLeaflet()` function allows for creation of an interactive embeddable geoprofile plot using Leaflet.
* Various changes to update the package to more modern dependencies (removing dependency on `gdal` and `raster`).
* Geoprofile is now licensed under the GPLv3 license.
* Geoprofile is now checked upon modification using GitHub Actions CI.
* New documentation site (https://emmadeeks97.github.io/GeoProfile/).
* New vignette to explain in more detail how to use GeoProfile.
* New `geoSurface3D()` function allows for interactive plotting of geoprofile surfaces.
  * Generally speaking 3D visualisations are much more useful when animated or interactive to mitigate data occlusion. This should significantly aid with that.
* User-facing messaging is nearly entirely handled by the `cli` package to give nicer, more intuitive package information.
* Many functions have been migrated to a new S3 class system to pave the way for improved usability and data integrity checking.
  * This has led to the soft-deprecation of various functions. These will be unlikely to be removed
    * `geoData()` -> `gp.data()`
    * `geoDataSource()` -> `gp.data(..., is.source = TRUE)`
    * `geoParams()` -> `gp.params()`
  * `geoMCMC()` now returns a `gp.profile` object which supports much nicer printing.
