new_gp.params <- function(
  model,
  MCMC, # chains=10, burnin=1e3, samples=1e4, burnin_printConsole=100, samples_printConsole=1000,
  output # longitude_minMax=NULL, latitude_minMax=NULL, longitude_cells=500, latitude_cells=500
  ) {
  out <- list(model = model, MCMC = MCMC, output = output)
  out <- structure(out, class = c("gp.params", "list"))
  # FW: Should call geoParamsCheck prior to return, to validate
  out
}

new_gp.params.model <- function(sigma_mean = 1, sigma_var = NULL, sigma_squared_shape = NULL, sigma_squared_rate = NULL, priorMean_longitude = NULL, priorMean_latitude = NULL, tau = NULL, alpha_shape = 0.1, alpha_rate = 0.1) {
  out <- list(
    sigma_mean = sigma_mean,
    sigma_var = sigma_var,
    sigma_squared_shape = sigma_squared_shape,
    sigma_squared_rate = sigma_squared_rate,
    priorMean_longitude = priorMean_longitude,
    priorMean_latitude = priorMean_latitude,
    tau = tau,
    alpha_shape = alpha_shape,
    alpha_rate = alpha_rate
    )
  structure(out, class = c("gp.params.model", "list"))
}

new_gp.params.MCMC <- function(chains=10, burnin=1e3, samples=1e4, burnin_printConsole=100, samples_printConsole=1000) {
  out <- list(
    chains = chains,
    burnin = burnin,
    samples = samples,
    burnin_printConsole = burnin_printConsole,
    samples_printConsole = samples_printConsole
  )
  structure(out, class = c("gp.params.MCMC", "list"))
}

new_gp.params.output <- function(data = NULL, sources = NULL, longitude_minMax=NULL, latitude_minMax=NULL, longitude_cells=500, latitude_cells=500) {
  out <- list(
    longitude_minMax = longitude_minMax,
    latitude_minMax = latitude_minMax,
    longitude_cells = longitude_cells,
    latitude_cells = latitude_cells
  )
  structure(out, class = c("gp.params.output", "list"))
}

# --- User-facing constructors

#------------------------------------------------
#' Create Rgeoprofile parameters object
#'
#' This function can be used to generate parameters in the format required by other Rgeoprofile functions. Parameter values can be specified as input arguments to this function, or alternatively if data is input as an argument then some parameters can take default values directly from the data.
#'
#' @param data observations in the format defined by [geoData()].
#' @param sources observations in the format defined by [geoDataSource()].
#' @param sigma_mean the mean of the prior on sigma (sigma = standard deviation of the dispersal distribution) in km.
#' @param sigma_var the variance of the prior on sigma in km^2.
#' @param sigma_squared_shape as an alternative to defining the prior mean and variance of sigma, it is possible to directly define the parameters of the inverse-gamma prior on sigma^2. If so, this is the shape parameter of the inverse-gamma prior.
#' @param sigma_squared_rate the rate parameter of the inverse-gamma prior on sigma^2.
#' @param priorMean_longitude the mean longitude of the normal prior on source locations (in degrees). If `NULL` then defaults to the midpoint of the range of the data, or `-0.1277` if no data provided.
#' @param priorMean_latitude the mean latitude of the normal prior on source locations (in degrees). If `NULL` then defaults to the midpoint of the range of the data, or `51.5074` if no data provided.
#' @param tau the standard deviation of the normal prior on source locations, i.e. how far we expect sources to lie from the centre. If `NULL` then defaults to the maximum distance of any observation from the prior mean, or `10.0` if no data provided.
#' @param alpha_shape shape parameter of the gamma prior on the parameter alpha.
#' @param alpha_rate rate parameter of the gamma prior on the parameter alpha.
#' @param chains number of MCMC chains to use in the burn-in step.
#' @param burnin number of burn-in iterations to be discarded at start of MCMC.
#' @param samples number of sampling iterations. These iterations are used to generate final posterior distribution.
#' @param burnin_printConsole how frequently (in iterations) to report progress to the console during the burn-in phase.
#' @param samples_printConsole how frequently (in iterations) to report progress to the console during the sampling phase.
#' @param longitude_minMax vector containing minimum and maximum longitude over which to generate geoprofile. If `NULL` then defaults to the range of the data plus a guard rail on either side, or `c(-0.1377,-0.1177)` if no data provided.
#' @param latitude_minMax vector containing minimum and maximum latitude over which to generate geoprofile. If `NULL` then defaults to the range of the data plus a guard rail on either side, or `c(51.4974, 51.5174)` if no data provided.
#' @param longitude_cells number of cells in the final geoprofile (longitude direction). Higher values generate smoother distributions, but take longer to run.
#' @param latitude_cells number of cells in the final geoprofile (latitude direction). Higher values generate smoother distributions, but take longer to run.
#' @param guardRail when data input is used, `longitude_minMax` and `latitude_minMax` default to the range of the data plus a guard rail. This parameter defines the size of the guard rail as a proportion of the range. For example, a value of `0.05` would give an extra 5 percent on the range of the data.
#'
#' @rdname gp.params
#' @export
#' @examplesIf interactive()
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' # define parameters such that the model fits sigma from the data
#' gp.params(data = d, sigma_mean = 1.0, sigma_squared_shape = 2,
#' chains = 10, burnin = 1000, samples = 10000, guardRail = 0.1)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' d <- gp.params(sim$longitude, sim $latitude)
#' # use a fixed value of sigma
#' gp.params(data = d, sigma_mean = 1.0, sigma_var = 0,
#' chains=10, burnin=1000, samples = 10000, guardRail = 0.1)

gp.params <- function(data=NULL, sources=NULL, sigma_mean=1, sigma_var=NULL, sigma_squared_shape=NULL, sigma_squared_rate=NULL, priorMean_longitude=NULL, priorMean_latitude=NULL, tau=NULL, alpha_shape=0.1, alpha_rate=0.1, chains=10, burnin=1e3, samples=1e4, burnin_printConsole=100, samples_printConsole=1000, longitude_minMax=NULL, latitude_minMax=NULL, longitude_cells=500, latitude_cells=500, guardRail=0.05) {

  # if data or sources arguments used then get defaults from these values
  if (!is.null(data) | !is.null(sources)) {

    # check correct format of data
    geoDataCheck(data, silent=TRUE)

    # Use data as source for priorMeans, or use sources if data = NULL
    priorMean_data <- data %||% sources

    # if prior mean not defined then set as midpoint of data (if present), otherwise midpoint of sources
    if (is.null(priorMean_longitude)) {
      priorMean_longitude <- sum(range(priorMean_data$longitude))/2
    }
    if (is.null(priorMean_latitude)) {
      priorMean_latitude <- sum(range(priorMean_data$latitude))/2
    }

    # convert data to bearing and great circle distance, and extract maximum great circle distance to any point. Use maximum distance as default value of tau
    if (!is.null(data) & is.null(tau)) {
      data_trans <- latlon_to_bearing(priorMean_latitude, priorMean_longitude, data$latitude, data$longitude)
      tau <- max(data_trans$gc_dist)
    }

    # OUTPUT PARAMS
    # combine data and sources into single object for convenience
    data_sources <- list(longitude = c(data$longitude, sources$longitude), latitude = c(data$latitude, sources$latitude))

    # set map limits based on data, sources, or both
    longitude_minMax <- longitude_minMax %||% infer_minmax(data_sources$longitude, guardRail)
    latitude_minMax <- latitude_minMax %||% infer_minmax(data_sources$latitude, guardRail)
  } else {
    # Set defaults if neither data nor sources are specified
    priorMean_longitude <- priorMean_longitude %||% -0.1277
    priorMean_latitude <- priorMean_latitude %||% 51.5074
    longitude_minMax <- longitude_minMax %||% (priorMean_longitude + c(-0.01,0.01))
    latitude_minMax <- latitude_minMax %||% (priorMean_latitude + c(-0.01,0.01))
    tau <- tau %||% 10
  }

  # Calculate sigma vars
  sigma_params <- calc_sigma_params(sigma_mean, sigma_var, sigma_squared_shape, sigma_squared_rate)

  # set model parameters (need to use do.call because the args are in a list)
  model <- do.call("new_gp.params.model", c(sigma_params, list(priorMean_longitude=priorMean_longitude, priorMean_latitude=priorMean_latitude, tau=tau, alpha_shape=alpha_shape, alpha_rate=alpha_rate)))

  # set MCMC parameters
  MCMC <- new_gp.params.MCMC(chains=chains, burnin=burnin, samples=samples, burnin_printConsole=burnin_printConsole, samples_printConsole=samples_printConsole)

  # set output parameters
  output <- new_gp.params.output(longitude_minMax=longitude_minMax, latitude_minMax=latitude_minMax, longitude_cells=longitude_cells, latitude_cells=latitude_cells)

  # combine and return
  ret <- new_gp.params(model=model, MCMC=MCMC, output=output)
  return(ret)
}
