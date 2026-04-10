#' @rdname gp.data
geoData <- function(longitude=NULL, latitude=NULL) {
  cli::cli_warn(c("{.fn GeoProfile::geoData} will be deprecated in future versions.", "i" = "Use {.fn GeoProfile::gp.data} instead."), .frequency = "regularly", .frequency_id = "geoData_deprecation")
  return(gp.data(longitude, latitude))
}

#' @rdname gp.data
geoDataSource <- function(longitude=NULL, latitude=NULL) {
  # FW: This is exactly the same as above so one should be deprecated.
  # For now call the other fn, but pass the current env for messaging purposes
  cli::cli_warn(c("{.fn GeoProfile::geoDataSource} will be deprecated in future versions.", "i" = "Use {.fn GeoProfile::gp.data} with {.arg is.source = TRUE} instead."), .frequency = "regularly", .frequency_id = "geoDataSource_deprecation")
  return(gp.data(longitude, latitude, is.source = TRUE))
}

#------------------------------------------------
#' @rdname gp.params
#' @export

geoParams <- function(data=NULL, sources=NULL, sigma_mean=1, sigma_var=NULL, sigma_squared_shape=NULL, sigma_squared_rate=NULL, priorMean_longitude=NULL, priorMean_latitude=NULL, tau=NULL, alpha_shape=0.1, alpha_rate=0.1, chains=10, burnin=1e3, samples=1e4, burnin_printConsole=100, samples_printConsole=1000, longitude_minMax=NULL, latitude_minMax=NULL, longitude_cells=500, latitude_cells=500, guardRail=0.05) {
  cli::cli_warn(c("{.fn GeoProfile::geoParams} will be deprecated in future versions.", "i" = "Use {.fn GeoProfile::gp.params} instead."), .frequency = "regularly", .frequency_id = "geoParams_deprecation")
  return(gp.params(data, sources, sigma_mean, sigma_var, sigma_squared_shape, sigma_squared_rate, priorMean_longitude, priorMean_latitude, tau, alpha_shape, alpha_rate, chains, burnin, samples, burnin_printConsole, samples_printConsole, longitude_minMax, latitude_minMax, longitude_cells, latitude_cells, guardRail))
}
#------------------------------------------------
#' Import shapefile
#'
#' This function imports spatial information in the form of `SpatialPolygonsDataFrame`, `SpatialLinesDataFrame` or `RasterLayer` for use with [geoMask()].
#'
#' @param fileName the object to be imported. Must be one of `SpatialPolygonsDataFrame`, `SpatialLinesDataFrame` or `RasterLayer` if it is to be used with [geoMask()].
#'
#' @export
#'
#' @concept spec
#'
#' @examplesIf interactive()
#' # load London boroughs by default
#' geoShapefile()

geoShapefile <- function(fileName=NULL) {
  # FW: Check whether these functions actually require these old data classes, or whether they use new terra-style equivalents

  # load north London boroughs by default
  if (is.null(fileName)) {
    fileName <- system.file('extdata', 'London_north', package='GeoProfile')
  }

  # load shapefile
  # FW: Worthwhile switching to terra for this, and moving the shapefile to a geopackage
  ret <- sf::st_read(fileName, quiet = TRUE) ### MODIFICATION

  return(ret)
}

#------------------------------------------------
#' Check data
#'
#' Check that all data for use in Rgeoprofile MCMC is in the correct format.
#'
#' @param data a data list object, as defined by [geoData()].
#' @param silent whether to report if data passes checks to console.
#'
#' @returns Nothing (throws an error if check fails)
#'
#' @export
#'
#' @concept spec
#'
#' @examplesIf interactive()
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' geoDataCheck(d)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' d <- geoData(sim$longitude, sim $latitude)
#' geoDataCheck(d)

geoDataCheck <- function(data, silent=FALSE) {

  # check that data is a list or a gp.data object
  if (!inherits(data, "gp.data")) {
    cli_stopifnot(is.list(data), "Data is not a gp.data object or a list!")
  }

  # check that contains longitude and latitude
  cli_stopifnot("longitude" %in% names(data), "Longitude is not present in data!")
  cli_stopifnot("latitude" %in% names(data), "Latitude is not present in data!")

  # check that data values are correct format and range
  cli_stopifnot(is.numeric(data$longitude), "Longitude is not numeric!")
  cli_stopifnot(all(is.finite(data$longitude)), "Longitude is not entirely finite!")
  cli_stopifnot(is.numeric(data$latitude), "Latitude is not numeric!")
  cli_stopifnot(all(is.finite(data$latitude)), "Latitude is not entirely finite!")

  # check same number of observations in logitude and latitude, and n>1
  cli_stopifnot(length(data$longitude)==length(data$latitude), "Longitude & Latitude lengths do not match!")
  cli_stopifnot(length(data$longitude)>1, "Fewer than 2 observations!")

  # if passed all checks
  if (!silent) { cli::cli_alert_success("Data object passed all checks!") }
}

#------------------------------------------------
#' Check parameters
#'
#' Check that all parameters for use in Rgeoprofile MCMC are in the correct format.
#'
#' @param params a list of parameters, as defined by [geoParams()].
#' @param silent whether to report passing check to console.
#'
#' @returns Nothing (throws an error if check fails)
#'
#' @export
#'
#' @concept spec
#'
#' @examplesIf interactive()
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' geoParamsCheck(p)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_var=0)
#' geoParamsCheck(p)

geoParamsCheck <- function(params, silent=FALSE) {

  # check that params is a list
  if (!is.list(params))
    stop("params must be in list format")

  # check that contains 'model', 'MCMC' and 'output' as sublists
  if (!"model"%in%names(params) | !"MCMC"%in%names(params) | !"output"%in%names(params))
    stop("params must contain sublists 'model', 'MCMC' and 'output'")

  # check that 'model', 'MCMC' and 'output' are indeed lists
  if (!is.list(params$model))
    stop("params$model must be in list format")
  if (!is.list(params$MCMC))
    stop("params$MCMC must be in list format")
  if (!is.list(params$output))
    stop("params$output must be in list format")

  #---------------------------------------

  # check that params$model contains all necessary parameters
  # FW: Rework to reduce duplicated code
  req_params <- c("sigma_mean", "sigma_var", "sigma_squared_shape", "sigma_squared_rate", "priorMean_longitude", "priorMean_latitude", "tau", "alpha_shape", "alpha_rate")
  missing_params <- setdiff(req_params, names(params$model))

  if (length(missing_params) > 0) {
    stop(paste0("params$model missing parameter/s: ", paste(missing_params, collapse = ", ")))
  }

  # if (!("sigma_mean"%in%names(params$model)))
  #   stop("params$model must contain parameter 'sigma_mean'")
  # if (!("sigma_var"%in%names(params$model)))
  #   stop("params$model must contain parameter 'sigma_var'")
  # if (!("sigma_squared_shape"%in%names(params$model)))
  #   stop("params$model must contain parameter 'sigma_squared_shape'")
  # if (!("sigma_squared_rate"%in%names(params$model)))
  #   stop("params$model must contain parameter 'sigma_squared_rate'")
  # if (!("priorMean_longitude"%in%names(params$model)))
  #   stop("params$model must contain parameter 'priorMean_longitude'")
  # if (!("priorMean_latitude"%in%names(params$model)))
  #   stop("params$model must contain parameter 'priorMean_latitude'")
  # if (!("tau"%in%names(params$model)))
  #   stop("params$model must contain parameter 'tau'")
  # if (!("alpha_shape"%in%names(params$model)))
  #   stop("params$model must contain parameter 'alpha_shape'")
  # if (!("alpha_rate"%in%names(params$model)))
  #   stop("params$model must contain parameter 'alpha_rate'")

  # check that params$model values are correct format and range
  if (!is.numeric(params$model$sigma_mean) | !is.finite(params$model$sigma_mean))
    stop("params$model$sigma_mean must be numeric and finite")
  if (params$model$sigma_mean<=0)
    stop("params$model$sigma_mean must be greater than 0")
  if (!is.numeric(params$model$sigma_var) | !is.finite(params$model$sigma_var))
    stop("params$model$sigma_var must be numeric and finite")
  if (params$model$sigma_var<0)
    stop("params$model$sigma_var must be greater than or equal to 0")

  # the only time that sigma_squared_shape and sigma_squared_rate are allowed to be NULL is under the fixed sigma model
  if (is.null(params$model$sigma_squared_shape) | is.null(params$model$sigma_squared_rate)) {
    if (params$model$sigma_var!=0) {
      stop('params$model$sigma_squared_shape and params$model$sigma_squared_rate can only be NULL under the fixed sigma model, i.e. when params$model$sigma_var==0. ')
    }
  }

  if (!is.null(params$model$sigma_squared_shape)) {
    if (!is.numeric(params$model$sigma_squared_shape) | !is.finite(params$model$sigma_squared_shape))
      stop("params$model$sigma_squared_shape must be numeric and finite")
  }
  if (!is.null(params$model$sigma_squared_rate)) {
    if (!is.numeric(params$model$sigma_squared_rate) | !is.finite(params$model$sigma_squared_rate))
      stop("params$model$sigma_squared_rate must be numeric and finite")
  }
  if (!is.numeric(params$model$priorMean_longitude) | !is.finite(params$model$priorMean_longitude))
    stop("params$model$priorMean_longitude must be numeric and finite")
  if (!is.numeric(params$model$priorMean_latitude) | !is.finite(params$model$priorMean_latitude))
    stop("params$model$priorMean_latitude must be numeric and finite")
  if (!is.numeric(params$model$tau) | !is.finite(params$model$tau))
    stop("params$model$tau must be numeric and finite")
  if (params$model$tau<=0)
    stop("params$model$tau must be greater than 0")
  if (!is.numeric(params$model$alpha_shape) | !is.finite(params$model$alpha_shape))
    stop("params$model$alpha_shape must be numeric and finite")
  if (params$model$alpha_shape<=0)
    stop("params$model$alpha_shape must be greater than 0")
  if (!is.numeric(params$model$alpha_rate) | !is.finite(params$model$alpha_rate))
    stop("params$model$alpha_rate must be numeric and finite")
  if (params$model$alpha_rate<=0)
    stop("params$model$alpha_rate must be greater than 0")

  #---------------------------------------

  # check that params$MCMC contains all necessary parameters
  # FW: Rework to reduce duplicated code
  req_params <- c("chains", "burnin", "samples", "burnin_printConsole", "samples_printConsole")
  missing_params <- setdiff(req_params, names(params$MCMC))

  if (length(missing_params) > 0) {
    stop(paste0("params$MCMC missing parameter/s: ", paste(missing_params, collapse = ", ")))
  }
  # if (!("chains"%in%names(params$MCMC)))
  #   stop("params$MCMC must contain parameter 'chains'")
  # if (!("burnin"%in%names(params$MCMC)))
  #   stop("params$MCMC must contain parameter 'burnin'")
  # if (!("samples"%in%names(params$MCMC)))
  #   stop("params$MCMC must contain parameter 'samples'")
  # if (!("burnin_printConsole"%in%names(params$MCMC)))
  #   stop("params$MCMC must contain parameter 'burnin_printConsole'")
  # if (!("samples_printConsole"%in%names(params$MCMC)))
  #   stop("params$MCMC must contain parameter 'samples_printConsole'")

  # check that params$MCMC values are correct format and range
  if (!is.numeric(params$MCMC$chains) | !is.finite(params$MCMC$chains))
    stop("params$MCMC$chains must be numeric and finite")
  if (params$MCMC$chains<=1)
    stop("params$MCMC$chains must be 2 or more")
  if (!is.numeric(params$MCMC$burnin) | !is.finite(params$MCMC$burnin))
    stop("params$MCMC$burnin must be numeric and finite")
  if (params$MCMC$burnin<0)
    stop("params$MCMC$burnin must be greater than or equal to 0")
  if (!is.numeric(params$MCMC$samples) | !is.finite(params$MCMC$samples))
    stop("params$MCMC$samples must be numeric and finite")
  if (params$MCMC$samples<=0)
    stop("params$MCMC$samples must be greater than 0")
  if (!is.numeric(params$MCMC$burnin_printConsole) | !is.finite(params$MCMC$burnin_printConsole))
    stop("params$MCMC$burnin_printConsole must be numeric and finite")
  if (params$MCMC$burnin_printConsole<=0)
    stop("params$MCMC$burnin_printConsole must be greater than 0")
  if (!is.numeric(params$MCMC$samples_printConsole) | !is.finite(params$MCMC$samples_printConsole))
    stop("params$MCMC$samples_printConsole must be numeric and finite")
  if (params$MCMC$samples_printConsole<=0)
    stop("params$MCMC$samples_printConsole must be greater than 0")

  #---------------------------------------

  # check that params$output contains all necessary parameters
  # FW: Rework to reduce duplicated code
  req_params <- c("longitude_minMax", "latitude_minMax", "longitude_cells", "latitude_cells")
  missing_params <- setdiff(req_params, names(params$output))

  if (length(missing_params) > 0) {
    stop(paste0("params$output missing parameter/s: ", paste(missing_params, collapse = ", ")))
  }
  # if (!("longitude_minMax"%in%names(params$output)))
  #   stop("params$output must contain parameter 'longitude_minMax'")
  # if (!("latitude_minMax"%in%names(params$output)))
  #   stop("params$output must contain parameter 'latitude_minMax'")
  # if (!("longitude_cells"%in%names(params$output)))
  #   stop("params$output must contain parameter 'longitude_cells'")
  # if (!("latitude_cells"%in%names(params$output)))
  #   stop("params$output must contain parameter 'latitude_cells'")

  #---------------------------------------

  # if passed all checks
  if (!silent) { cli::cli_alert_success("Params object passed all checks!") }
}
