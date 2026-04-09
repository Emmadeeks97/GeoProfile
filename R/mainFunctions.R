#------------------------------------------------
#' Create Geoprofile data object
#'
#' Simple function that ensures that input data is in the correct format required by Rgeoprofile. Takes `longitude` and `latitude` as input vectors and returns these same values in `list` format.
#'
#' @param longitude the locations of the observed data in degrees longitude.
#' @param latitude the locations of the observed data in degrees latitude.
#' @param call the environment for any checking errors to be emitted from. Only really useful for internal use.
#'
#' @export
#' @examplesIf interactive()
#' # John Snow cholera data
#' geoData(Cholera$longitude, Cholera$latitude)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' geoData(sim$longitude, sim$latitude)

geoData <- function(longitude=NULL, latitude=NULL, call = rlang::current_env()) {

  # check input format
  cli_stopif(is.null(longitude), "Longitude is NULL!", call)
  cli_stopif(is.null(latitude), "Latitude is NULL!", call)
  cli_stopifnot(length(longitude)==length(latitude), "Longitude and Latitude are not the same length!", call)

  # combine and return
  ret <- list(longitude=longitude, latitude=latitude)
  return(ret)
}

#------------------------------------------------
#' Create sources data object in same format as observations
#'
#' Simple function that ensures that sources are in the correct format required by Rgeoprofile. Takes longitude and latitude as input vectors and returns these same values in list format. If no values are input then default values are used.
#'
#' @param longitude the locations of the potential sources in degrees longitude.
#' @param latitude the locations of the potential sources in degrees latitude.
#' @param call the environment for any checking errors to be emitted from. Only really useful for internal use.
#'
#' @export
#' @examplesIf interactive()
#' # John Snow cholera data
#' geoDataSource(WaterPumps$longitude, WaterPumps$latitude)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' geoDataSource(sim$longitude, sim$latitude)

geoDataSource <- function(longitude=NULL, latitude=NULL, call = rlang::current_env()) {
  # FW: This is exactly the same as above so one should be deprecated.
  # For now call the other fn, but pass the current env for messaging purposes
  geoData(longitude, latitude, call)
}

#------------------------------------------------
#' @rdname gp.params
#' @export

geoParams <- function(data=NULL, sources=NULL, sigma_mean=1, sigma_var=NULL, sigma_squared_shape=NULL, sigma_squared_rate=NULL, priorMean_longitude=NULL, priorMean_latitude=NULL, tau=NULL, alpha_shape=0.1, alpha_rate=0.1, chains=10, burnin=1e3, samples=1e4, burnin_printConsole=100, samples_printConsole=1000, longitude_minMax=NULL, latitude_minMax=NULL, longitude_cells=500, latitude_cells=500, guardRail=0.05) {
  cli::cli_warn(c("{.fn GeoProfile::geoParams} will be deprecated in future versions.", "i" = "Use {.fn GeoProfile::gp.params} instead"))
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
#' @export
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

  # check that data is a list
  cli_stopifnot(is.list(data), "Data is not a list!")

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
  if (!silent) { cli::cli_alert_success("Data file passed all checks!") }
}

#------------------------------------------------
#' Check parameters
#'
#' Check that all parameters for use in Rgeoprofile MCMC are in the correct format.
#'
#' @param params a list of parameters, as defined by [geoParams()].
#' @param silent whether to report passing check to console.
#'
#' @export
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

#------------------------------------------------
#' MCMC under Rgeoprofile model
#'
#' This function carries out the main MCMC under the Rgeoprofile model. Posterior draws are smoothed to produce a posterior surface, and converted into a geoProfile. Outputs include posterior draws of alpha and sigma under the variable-sigma model.
#'
#' @param data input data in the format defined by [geoData()].
#' @param params input parameters in the format defined by [geoParams()].
#' @param lambda bandwidth to use in posterior smoothing. If `NULL` then optimal bandwidth is chosen automatically by maximum-likelihood.
#' @param smoothprogress whether to include a progress spinner for the smoothing stage.
#'
#' @export
#' @examplesIf interactive()
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p, lambda=0.05)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' d <- geoData(sim$longitude, sim $latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)

geoMCMC <- function(data, params, lambda=NULL, smoothprogress = TRUE) {

  # check that data and parameters in correct format
  geoDataCheck(data)
  geoParamsCheck(params)
  cli::cli_rule(left = "MCMC Log")

  # extract ranges etc. from params object
  min_lon <- params$output$longitude_minMax[1]
  max_lon <- params$output$longitude_minMax[2]
  min_lat <- params$output$latitude_minMax[1]
  max_lat <- params$output$latitude_minMax[2]
  cells_lon <- params$output$longitude_cells
  cells_lat <- params$output$latitude_cells
  cellSize_lon <- (max_lon-min_lon)/cells_lon
  cellSize_lat <- (max_lat-min_lat)/cells_lat
  breaks_lon <- seq(min_lon, max_lon, l=cells_lon+1)
  breaks_lat <- seq(min_lat, max_lat, l=cells_lat+1)
  mids_lon <- breaks_lon[-1] - cellSize_lon/2
  mids_lat <- breaks_lat[-1] - cellSize_lat/2
  mids_lon_mat <- outer(rep(1,length(mids_lat)), mids_lon)
  mids_lat_mat <- outer(mids_lat, rep(1,length(mids_lon)))

  # transform data to cartesian coordinates relative to centre of prior. After transformation data are defined relative to point 0,0 (i.e. the origin represents the centre of the prior). Add transformed coordinates to data object before feeding into C++ function
  data_cartesian <-latlon_to_cartesian(params$model$priorMean_latitude, params$model$priorMean_longitude, data$latitude, data$longitude)
  data$x <- data_cartesian$x
  data$y <- data_cartesian$y

  # if using fixed sigma model then change alpha and beta from NULL to -1. This value will be ignored, but needs to be numeric before feeding into the C++ function.
  if (params$model$sigma_var==0) {
    params$model$sigma_squared_shape <- -1
    params$model$sigma_squared_rate <- -1
  }

  # carry out MCMC using efficient C++ function
  rawOutput <- C_geoMCMC(data, params)

  # Log delimiter
  cli::cli_rule(left = "MCMC Log End")

  # extract mu draws and convert from cartesian to lat/lon coordinates
  mu_draws <- cartesian_to_latlon(params$model$priorMean_latitude, params$model$priorMean_longitude, rawOutput$mu_x, rawOutput$mu_y)

  # produce smoothed surface
  mu_smooth <- geoSmooth(mu_draws$longitude, mu_draws$latitude, breaks_lon, breaks_lat, lambda, smoothprogress)

  # calculate coordinates of lat/lon matrix in original cartesian coordinates
  cart <-latlon_to_cartesian(params$model$priorMean_latitude, params$model$priorMean_longitude, mids_lat_mat, mids_lon_mat)

  # produce prior matrix. Note that each cell of this matrix contains the probability density at that point multiplied by the size of that cell, meaning the total sum of the matrix from -infinity to +infinity would equal 1. However, as the matrix is limited to the region specified by the limits, in reality this matrix will usually sum to less than 1.
  priorMat <- stats::dnorm(cart$x, sd=params$model$tau) * stats::dnorm(cart$y, sd=params$model$tau) * (cellSize_lon*cellSize_lat)

  # combine prior surface with stored posterior surface (the prior never fully goes away under the DPM model)
  n <- length(data$longitude)
  alpha <- rawOutput$alpha
  posteriorMat <-  mu_smooth + priorMat*mean(alpha/(alpha+n))

  # produce geoprofile
  gp <- geoProfile(posteriorMat)

  # calculate posterior allocation
  allocation <- matrix(unlist(rawOutput$allocation), n, byrow=T)
  allocation <- data.frame(allocation/params$MCMC$samples)
  names(allocation) <- paste("group", 1:ncol(allocation), sep="")

  # get single best posterior grouping
  bestGrouping <- apply(allocation, 1, which.max)

  # calculate posterior co-allocation
  coAllocation <- matrix(unlist(rawOutput$coAllocation), n, byrow=T)/params$MCMC$samples
  diag(coAllocation) <- 1
  coAllocation[row(coAllocation)>col(coAllocation)] <- NA

  # finalise output format
  output <- list()
  output$priorSurface <-  priorMat
  output$posteriorSurface <-  posteriorMat
  output$geoProfile <-  gp
  output$midpoints_longitude <- mids_lon
  output$midpoints_latitude <- mids_lat
  output$sigma <- rawOutput$sigma
  output$alpha <- alpha
  output$allocation <- allocation
  output$bestGrouping <- bestGrouping
  output$coAllocation <- coAllocation
  return(output)
}

#------------------------------------------------
#' Calculate geoprofile from surface
#'
#' Converts surface to hitscore percentage
#'
#' @param surface matrix to convert to geoprofile
#'
#' @export
#' @examplesIf interactive()
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p, lambda=0.05)
#' gp <- geoProfile(m$posteriorSurface)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' d <- geoData(sim$longitude, sim $latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' gp <- geoProfile(m$posteriorSurface)

geoProfile <- function(surface) {

  # check that surface is in correct format
  cli_stopifnot(is.matrix(surface), "Surface is not a matrix!")

  # create geoprofile from surface
  ret <- matrix(rank(surface, ties.method="first"), nrow=nrow(surface), byrow=FALSE)
  ret[is.na(surface)] <- NA
  ret <- 100 * (1 - (ret-1)/max(ret, na.rm=TRUE))

  return(ret)
}

#------------------------------------------------
#' Calculate hitscores
#'
#' Calculate hitscores of the potential sources for a given surface (usually the geoprofile).
#'
#' @param params input parameters in the format defined by [geoParams()].
#' @param source longitude and latitude of one or more source locations in the format defined by [geoDataSource()].
#' @param surface the surface from which to calculate hitscores. Usually an object produced by [geoProfile()].
#'
#' @export
#' @examplesIf interactive()
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' s <- geoDataSource(WaterPumps$longitude, WaterPumps$latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p, lambda=0.05)
#' geoReportHitscores(params = p, source = s, surface = m$geoProfile)
#'
geoReportHitscores <- function(params, source, surface) {

  # check parameters
  geoParamsCheck(params, silent = TRUE)

  # get size of cells
  delta_lat <- diff(params$output$latitude_minMax)/params$output$latitude_cells
  delta_lon <- diff(params$output$longitude_minMax)/params$output$longitude_cells

  # get index of closest point to each source
  index_lat <- round((source$latitude - params$output$latitude_minMax[1])/delta_lat + 0.5)
  index_lon <- round((source$longitude - params$output$longitude_minMax[1])/delta_lon + 0.5)

  # combine coordinates and indices in data frame
  df <- data.frame(latitude = source$latitude, longitude = source$longitude, index_lat = index_lat, index_lon = index_lon)

  # drop rows if index outside range, with warning
  df <- subset(df, index_lat>0 & index_lat<nrow(surface) & index_lon>0 & index_lon<ncol(surface))
  if (nrow(df) < length(source$longitude)) {
    cli::cli_warn(c("Some sources outside range of surface!", "i" = "Expected {length(source$longitude)} entr{?y/ies}, got {nrow(df)}."))
  }

  # append hitscore percentages
  df$hs <- surface[as.matrix(df[,c("index_lat", "index_lon")])]

  # return subset of data frame
  ret <- subset(df, select=c("latitude", "longitude", "hs"))
  return(ret)
}

#------------------------------------------------
#' Extract latitude and longitude of points identified as sources by [geoMCMC()]
#'
#' This function takes the output of [geoMCMC()] and, for each 'crime', extracts the group to which it is assigned with the highest probability. For each group, the model returns the mean lat/long of all crimes assigned to that group.
#'
#' @param mcmc Model output in the format produced by [geoMCMC()].
#' @param data Crime site data, in the format produced by [geoData()].
#'
#' @export
#' @examplesIf interactive()
#' \donttest{
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=10, sigma=1, tau=3)
#' d <- geoData(sim$longitude, sim $latitude)
#' s <- geoDataSource(sim$source_lon, sim$source_lat)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' # extract sources identified by the model
#' ms <- geoModelSources(mcmc = m, data = d)
#' # plot data showing the sources identified by the model (note: NOT the actual suspect sites)
#'  geoPlotLeaflet(data = d,
#'                 source = ms,
#'                 params = p,
#'                 mapType = 110,
#'                 surfaceCols = c("red", "orange","yellow","white"),
#'                 crimeCol = "black",
#'                 crimeCex = 2,
#'                 sourceCol = "red",
#'                 sourceCex = 2,
#'                 surface = m$geoProfile,
#'                 gpLegend=TRUE,
#'                 opacity = 0.4)
#' }

geoModelSources <- function (mcmc, data) {

  # get mean over data, split by best group
  lon <- mapply(mean, split(data$longitude, mcmc$bestGrouping))
  lat <- mapply(mean, split(data$latitude, mcmc$bestGrouping))

  return(list(longitude=lon, latitude=lat))
}

#------------------------------------------------
#' Produces a surface based on an alternative ring-search strategy
#'
#' Produces a surface based on an alternative ring-search strategy (ie searching in an expanding radius out from the 'crimes'). The output from this function can be used with [geoProfile()] and [geoReportHitscores()] to produce a map and hitscores based on this strategy.
#'
#' @param params Parameters list in the format defined by [geoParams()].
#' @param data Data object in the format defined by [geoData()].
#' @param source Potential sources object in the format defined by [geoDataSource()].
#' @param mcmc mcmc object of the form produced by [geoMCMC()].
#'
#' @export
#' @examplesIf interactive()
#' \donttest{
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' s <- geoDataSource(WaterPumps$longitude, WaterPumps$latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' surface_ring <- geoRing(params = p, data = d, source = s, mcmc = m)
#' gp_ring <- geoProfile(surface = surface_ring)
#' map <- geoPlotLeaflet(params = p,
#'                       data = d,
#'                       source = s,
#'                       surface = gp_ring,
#'                       opacity = 1)
#' map
#' }


geoRing <- function(params, data, source, mcmc) {

  # Calculates the percentage of the grid that must be searched before reaching each source under a ring search strategy. This search strategy assumes that we start from a given crime and search outwards in a circle of increasing radius until we reach a source. As there are multiple crimes the strategy assumes a separate individual searching from each crime simultaneously at an equal rate.
  # The basic logic of the approach here is that calculating the final search radius needed to identify a source is easy - it is simply the minimum radius from any crime to this source. The difficulty is calculating the amount of grid that will have been explored by the time we reach this radius, as circles will often overlap and the intersection should not be double-counted (we assume searching moves on if the area has already been explored by someone else). This is done by brute force - a grid is created and cells are filled in solid if they have been explored. The total percentage of filled cells gives the hitscore percentage. The distance matrices used in this brute force step are needed repeatedly, and so they are computed once at the begninning to save time.

  # get number of crimes and sources
  n <- length(data$latitude)
  ns <- length(source$source_latitude)

  # create matrices giving lat/lon at all points in search grid
  lonVec <- mcmc$midpoints_longitude
  latVec <- mcmc$midpoints_latitude
  lonMat <- matrix(rep(lonVec,each=length(latVec)), length(latVec))
  latMat <- matrix(rep(latVec,length(lonVec)), length(latVec))

  # calculate great circle distance from every data point to every point in search grid. This list of distance matrices will be used multiple times so best to pre-compute here.
  # FW: This can probably be vectorised for a notable speedup on large datasets.
  ret <- matrix(-Inf, nrow=nrow(lonMat), ncol=ncol(lonMat))
  for (i in 1:n) {
    neg_dist_i <- -latlon_to_bearing(data$latitude[i], data$longitude[i], latMat, lonMat)$gc_dist
    ret[neg_dist_i>ret] <- neg_dist_i[neg_dist_i>ret]
  }

  # return negative distance
  return(ret)
}

# FW: Can this be removed?
############### TRIAL
# load London example data and set params
#d <- LondonExample_crimes
#s <- LondonExample_sources
#p = geoParams(data = d, sigma_mean = 1, sigma_squared_shape = 2)
# run model
#m = geoMCMC(data = d, params = p)

 # plot original map
#Map1 <- geoPlotLeaflet(params = p, data = d, source = s, surface = m$geoProfile)
#Map1
#'
# mask out North London and replot
#north_london_mask <- geoShapefile()
#prob_masked <- geoMask(probSurface = m$posteriorSurface, params = p, mask = north_london_mask,
#               operation = "inside", scaleValue = 0)
#gp_masked <- geoProfile(prob_masked$prob)
# plot new surface
#map2 <- geoPlotLeaflet(params = p, data = d, source = s, surface = gp_masked)
#map2

#------------------------------------------------
#' Incorporate shapefile or raster information into a geoprofile
#'
#' This function allows information from a shapefile or raster to be incorporated within the geoprofile. For example, we might wish to exclude areas not on land, or weight the probabilities within a specific postcode differently. The spatial object used should be a `SpatialPolygonsDataFrame` as produced by the package sp or a raster.
#'
#' @param probSurface the original geoprofile, usually the object `$posteriorSurface` produced by [geoMCMC()].
#' @param params an object produced by [geoParams()].
#' @param mask the spatial information to include. Must be one of `SpatialPolygonsDataFrame`, `SpatialLinesDataFrame` or `RasterLayer.`
#' @param scaleValue different functions depending on value of `operation`. For `"inside'` or `"outside"`, the value by which probabilities should be multiplied inside or outside the shapefile. For `"near"` and `"far"`, `scaleValue` is the importance of proximity to, or distance from, the object described in the `SpatialPolygonsDataFrame`, `SpatialLinesDataFrame` or `RasterLayer.` Thus, the default value of `scaleValue = 1` can be increased to exaggerate the importance of proximity or distance. Not used for `"continuous"`.
#' @param operation how to combine the surface and the new spatial information. Must be one of `"inside"`, `"outside"`, `"near"`, `"far"` or `"continuous"`. The first two multiply areas inside or outside the area described in the shapefile (or raster) by scaleValue. `"near"` or `"far"` weight the geoprofile by its closeness to (or distance from) the area described in the shapefile (or raster). Finally, `"continuous"` uses a set of numerical values (eg altitude) to weight the geoprofile. NOTE: `'near'` and `'far'` can take a few minutes to run.
#' @param maths one of `"add"`, `"subtract"`, `"multiply"` or `"divide"`. The mathematical operation used to combine the new spatial data with the geoprofile when `operation = "continuous"`.
#'
#' @export
#' @examplesIf interactive()
#' \donttest{
#' # load London example data and set params
#' d <- LondonExample_crimes
#' s <- LondonExample_sources
#' p = geoParams(data = d, sigma_mean = 1, sigma_squared_shape = 2)
#' # run model
#' m = geoMCMC(data = d, params = p)
#'
#' # plot original map
#' map1 <- geoPlotLeaflet(params = p, data = d, source = s, surface = m$geoProfile)
#' map1
#'
#' # mask out North London and replot
#' north_london_mask <- geoShapefile()
#' prob_masked <- geoMask(probSurface = m$posteriorSurface, params = p, mask = north_london_mask,
#'                 operation = "inside", scaleValue = 0)
#' gp_masked <- geoProfile(prob_masked$prob)
#' # plot new surface
#' map2 <- geoPlotLeaflet(params = p, data = d, source = s, surface = gp_masked)
#' map2
#'
#' # repeat, restricting mask to Tower Hamlets and using 'near' instead of 'inside'
#' TH_mask <- north_london_mask[which(north_london_mask$NAME == "Tower Hamlets"), ]
#' prob_masked2 <- geoMask(probSurface = m$posteriorSurface, params = p, mask = TH_mask,
#'                  operation = "far", scaleValue = 1)
#' gp_masked2 <- geoProfile(prob_masked2$prob)
#' # plot new surface
#' map3 <- geoPlotLeaflet(params = p, data = d, source = s, surface = gp_masked2)
#' map3
#' }

geoMask <- function (probSurface, params, mask, scaleValue = 1, operation = "inside", maths = "multiply") {
  # FW: Again check that given a general switch over to terra, these checks and input specifications are valid
  cli_stopifnot(inherits(mask, c("sf", "RasterLayer")), "Mask is not an sf or RasterLayer object!")
  rlang::arg_match0(operation, c("inside", "outside", "near", "far", "continuous"))
  rlang::arg_match0(maths, c("multiply", "divide", "add", "subtract", "continuous"))

  raster_probSurface <- terra::rast(probSurface)
  terra::ext(raster_probSurface) <- c(params$output$longitude_minMax[1], params$output$longitude_minMax[2],
                               params$output$latitude_minMax[1], params$output$latitude_minMax[2])
  terra::crs(raster_probSurface) <- "+proj=longlat +datum=WGS84"

  if (inherits(mask, "sf")) {
    mask <- sf::st_transform(mask, crs = terra::crs(raster_probSurface))  # match CRS

    tmp <- terra::rast(ncol = params$output$longitude_cells,
                nrow = params$output$latitude_cells,
                extent = terra::ext(raster_probSurface),
                crs = terra::crs(raster_probSurface))

    terra::res(tmp) <- terra::res(raster_probSurface)  # match resolution
    # FW: This was using a raster function, but the terra func should do the same job!
    rf <- terra::rasterize(mask, tmp)
  } else {
    rf <- mask  # already raster
  }

  # extract raster values
  rf_mat <- matrix(terra::values(rf), ncol = ncol(rf), byrow = TRUE)
  rf_mat <- rf_mat[nrow(rf_mat):1, ]
  p_mat <- matrix(terra::values(raster_probSurface), ncol = ncol(raster_probSurface), byrow = TRUE)

  scale_mat <- NULL

  if (operation == "inside") {
    scale_mat <- ifelse(is.na(rf_mat), 1, scaleValue)
    p_mat <- p_mat * scale_mat
  }

  if (operation == "outside") {
    scale_mat <- ifelse(is.na(rf_mat), scaleValue, 1)
    p_mat <- p_mat * scale_mat
  }

  if (operation == "continuous") {
    if (maths == "add")      p_mat <- p_mat + rf_mat
    if (maths == "subtract") p_mat <- p_mat - rf_mat
    if (maths == "multiply") p_mat <- p_mat * rf_mat
    if (maths == "divide")   p_mat <- p_mat / rf_mat
  }

  if (operation == "near") {
    # FW: This was using a raster function, but the terra func should do the same job!
    d <- terra::distance(rf)
    d_mat <- matrix(terra::values(d), ncol = ncol(d), byrow = TRUE)
    d_mat <- d_mat[nrow(d_mat):1, ]
    scale_mat <- 1 / (d_mat^scaleValue)
    scale_mat[is.infinite(scale_mat)] <- 1
    p_mat <- p_mat * scale_mat
  }

  if (operation == "far") {
    # FW: This was using a raster function, but the terra func should do the same job!
    d <- terra::distance(rf)
    d_mat <- matrix(terra::values(d), ncol = ncol(d), byrow = TRUE)
    d_mat <- d_mat[nrow(d_mat):1,]
    scale_mat <- d_mat^scaleValue
    p_mat <- p_mat * scale_mat
  }

  list(prob = p_mat, scaleMatrix = scale_mat)
}
