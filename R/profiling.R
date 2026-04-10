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
#' @returns A `gp.profile` object containing the fit geoprofile, prior/posterior rasters, allocations, groupings, and other parameters/outputs of the model.
#'
#' @export
#'
#' @concept profiling
#'
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

  # extract ranges etc. from params$output object
  ranges_list <- extract_mcmc_ranges(params$output)

  # transform data to cartesian coordinates relative to centre of prior. After transformation data are defined relative to point 0,0 (i.e. the origin represents the centre of the prior). Add transformed coordinates to data object before feeding into C++ function
  data_cartesian <- latlon_to_cartesian(params$model$priorMean_latitude, params$model$priorMean_longitude, data$latitude, data$longitude)
  data$x <- data_cartesian$x
  data$y <- data_cartesian$y

  # if using fixed sigma model then change alpha and beta from NULL to -1. This value will be ignored, but needs to be numeric before feeding into the C++ function.
  if (params$model$sigma_var == 0) {
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
  mu_smooth <- geoSmooth(mu_draws$longitude, mu_draws$latitude, ranges_list$breaks_lon, ranges_list$breaks_lat, lambda, smoothprogress)

  # calculate coordinates of lat/lon matrix in original cartesian coordinates
  cart <-latlon_to_cartesian(params$model$priorMean_latitude, params$model$priorMean_longitude, ranges_list$mids_lat_mat, ranges_list$mids_lon_mat)

  # produce prior matrix. Note that each cell of this matrix contains the probability density at that point multiplied by the size of that cell, meaning the total sum of the matrix from -infinity to +infinity would equal 1. However, as the matrix is limited to the region specified by the limits, in reality this matrix will usually sum to less than 1.
  priorMat <- stats::dnorm(cart$x, sd=params$model$tau) * stats::dnorm(cart$y, sd=params$model$tau) * (ranges_list$cellSize_lon*ranges_list$cellSize_lat)

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
  # FW: This only seems to return an upper tri matrix, with NAs in the lower tri. May be worth seeing if reflection across the diagonal is sensible?
  coAllocation <- matrix(unlist(rawOutput$coAllocation), n, byrow=T)/params$MCMC$samples
  diag(coAllocation) <- 1
  coAllocation[row(coAllocation)>col(coAllocation)] <- NA

  # finalise output format
  output <- new_gp.profile(
    method = "MCMC",
    priorSurface = priorMat,
    posteriorSurface = posteriorMat,
    geoProfile = gp,
    midpoints_longitude = ranges_list$mids_lon,
    midpoints_latitude = ranges_list$mids_lat,
    sigma = rawOutput$sigma,
    alpha = alpha,
    allocation = allocation,
    bestGrouping = bestGrouping,
    coAllocation = coAllocation,
    params = params,
    data = data
  )
  return(output)
}

#------------------------------------------------
#' Calculate geoprofile from surface
#'
#' Converts surface to hitscore percentage
#'
#' @param surface matrix to convert to geoprofile
#'
#' @returns A `matrix` of the geoprofile of the surface
#'
#' @export
#'
#' @concept profiling
#'
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
#' @returns A `data.frame` of hitscored of the input sources given the input surface.
#'
#' @export
#'
#' @concept profiling
#'
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
#' @returns A `data.frame` of the centroids of the data split by best grouping
#'
#' @export
#'
#' @concept profiling
#'
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

  return(data.frame(longitude=lon, latitude=lat))
}


#' Produces a surface based on an alternative ring-search strategy
#'
#' Produces a surface based on an alternative ring-search strategy (ie searching in an expanding radius out from the 'crimes'). The output from this function can be used with [geoProfile()] and [geoReportHitscores()] to produce a map and hitscores based on this strategy.
#'
#' @param params Parameters list in the format defined by [geoParams()].
#' @param data Data object in the format defined by [geoData()].
#' @param source Potential sources object in the format defined by [geoDataSource()].
#' @param mcmc mcmc object of the form produced by [geoMCMC()].
#'
#' @returns A `matrix` containing a surface based on a ring-search strategy.
#'
#' @export
#'
#' @concept profiling
#'
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
#' @returns A `list` of the probability and scale of the reprocessed probability surface
#'
#' @export
#'
#' @concept profiling
#'
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

#------------------------------------------------
#' Produce a smooth surface using 2D kernel density smoothing
#'
#' Takes lon/lat coordinates, bins in two dimensions, and smooths using kernel density smoothing. Kernel densities are computed using the fast Fourier transform method, which is many times faster than simple summation when using a large number of points. Each Kernel is student's-t distributed with 3 degrees of freedom, and scaled by the bandwidth lambda. If lambda is set to `NULL` then the optimal value of lambda is chosen automatically using the leave-one-out maximum likelihood method.
#'
#' @param longitude longitude of input points
#' @param latitude latitude of input points
#' @param breaks_lon positions of longitude breaks
#' @param breaks_lat positions of latitude breaks
#' @param lambda bandwidth to use in posterior smoothing. If NULL then optimal bandwidth is chosen automatically by maximum-likelihood.
#' @param smoothprogress whether to include a progress spinner.
#'
#' @returns A smoothed surface of the binned lon/lat coordinates.
#'
#' @references Barnard, Etienne. "Maximum leave-one-out likelihood for kernel density estimation." Proceedings of the Twenty-First Annual Symposium of the Pattern Recognition Association of South Africa. 2010.
#' @export
#'
#' @concept profiling
#'
#' @examplesIf interactive()
#' # create smooth surface based on raw LondonExample_crimes
#' breaks_lon <- seq(-0.25,0.05,l=101)
#' breaks_lat <- seq(51.45,51.6,l=101)
#' m <- geoSmooth(LondonExample_crimes$longitude, LondonExample_crimes$latitude,
#'                  breaks_lon, breaks_lat)
#'
#' # produce image plot of surface and overlay points
#' image(breaks_lon, breaks_lat, t(m), xlab="longitude", ylab="latitude")
#' points(LondonExample_crimes$longitude, LondonExample_crimes$latitude)

geoSmooth <- function(longitude, latitude, breaks_lon, breaks_lat, lambda=NULL, smoothprogress = TRUE) {

  # get properties of cells in each dimension
  cells_lon <- length(breaks_lon) - 1
  cells_lat <- length(breaks_lat) - 1
  centre_lon <- mean(breaks_lon)
  centre_lat <- mean(breaks_lat)
  cellSize_lon <- diff(breaks_lon[1:2])
  cellSize_lat <- diff(breaks_lat[1:2])

  # bin lon/lat values in two dimensions and check that at least one value in chosen region
  surface_raw <- bin2D(longitude, latitude, breaks_lon, breaks_lat)$z
  if (all(surface_raw==0)) {
    cli::cli_abort(c("x" = 'Chosen lat/long window contains no posterior draws!'))
  }

  # temporarily add guard rail to surface to avoid Fourier series bleeding round edges
  railSize_lon <- cells_lon
  railSize_lat <- cells_lat
  railMat_lon <- matrix(0, cells_lat, railSize_lon)
  railMat_lat <- matrix(0, railSize_lat, cells_lon + 2*railSize_lon)

  surface_normalised <- surface_raw/sum(surface_raw)
  surface_normalised <- cbind(railMat_lon, surface_normalised, railMat_lon)
  surface_normalised <- rbind(railMat_lat, surface_normalised, railMat_lat)

  # calculate Fourier transform of posterior surface
  f1 = fftwtools::fftw2d(surface_normalised)

  # calculate x and y size of one cell in cartesian space. Because of transformation, this size will technically be different for each cell, but use centre of space to get a middling value
  cellSize_trans <- latlon_to_cartesian(centre_lat, centre_lon, centre_lat + cellSize_lat, centre_lon + cellSize_lon)
  cellSize_trans_lon <- cellSize_trans$x
  cellSize_trans_lat <- cellSize_trans$y

  # produce surface over which kernel will be calculated. This surface wraps around in both x and y (i.e. the kernel is actually defined over a torus).
  kernel_lon <- cellSize_trans_lon * c(0:floor(ncol(surface_normalised)/2), floor((ncol(surface_normalised) - 1)/2):1)
  kernel_lat <- cellSize_trans_lat * c(0:floor(nrow(surface_normalised)/2), floor((nrow(surface_normalised) - 1)/2):1)
  kernel_lon_mat <- outer(rep(1,length(kernel_lat)), kernel_lon)
  kernel_lat_mat <- outer(kernel_lat, rep(1,length(kernel_lon)))
  kernel_s_mat <- sqrt(kernel_lon_mat^2 + kernel_lat_mat^2)

  # set lambda (bandwidth) range to be explored
  if (is.null(lambda)) {
    lambda_step <- min(cellSize_trans_lon, cellSize_trans_lat)/5
    lambda_vec <- lambda_step*(1:100)
  } else {
    lambda_vec <- lambda
  }

  # loop through range of values of lambda
  logLike <- -Inf
  if (smoothprogress) {
    cli::cli_progress_bar(name = "Smoothing posterior surface", total = length(lambda_vec), format = "{cli::pb_spin} {cli::pb_name} | ETA: {cli::pb_eta}")
  } else {
    cli::cli_alert_info("Smoothing posterior surface...")
  }

  for (i in 1:length(lambda_vec)) {
    if (smoothprogress) {
      cli::cli_progress_update()
    }

    # calculate Fourier transform of kernel
    lambda_this <- lambda_vec[i]
    kernel <- dts(kernel_s_mat, df=3, scale=lambda_this)
    f2 = fftwtools::fftw2d(kernel)

    # combine Fourier transformed surfaces and take inverse. f4 will ultimately become the main surface of interest.
    f3 = f1*f2
    f4 = Re(fftwtools::fftw2d(f3,inverse=T))/length(surface_normalised)

    # subtract from f4 the probability density of each point measured from itself. In other words, move towards a leave-one-out kernel density method
    f5 <- f4 - surface_normalised*dts(0, df=3, scale=lambda_this)
    f5[f5<0] <- 0
    f5 <- f5/sum(f4)

    # calculate leave-one-out log-likelihood at each point on surface
    f6 <- surface_normalised*log(f5)

    # break if total log-likelihood is at a local maximum
    if (sum(f6,na.rm=T)<logLike) { break() }

    # otherwise update logLike
    logLike <- sum(f6,na.rm=T)
  }
  if (smoothprogress) {
    cli::cli_progress_done()
  }


  # report chosen value of lambda
  if (is.null(lambda)) {
    cli::cli_alert_success("Maximum-Likelihood lambda = {.val {round(lambda_this,3)}}")
  }

  # remove guard rail
  f4 <- f4[,(railSize_lon+1):(ncol(f4)-railSize_lon)]
  f4 <- f4[(railSize_lat+1):(nrow(f4)-railSize_lat),]

  # return surface
  return(f4)
}
