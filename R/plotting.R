
#------------------------------------------------
# ggplot theme that gets rid of all margins etc.
# credit to the Wilke lab and cowplot package for original code that this is taken from (https://github.com/wilkelab/cowplot)
# (not exported)

theme_nothing <- function(font_size = 14, font_family = ""){
  ggplot2::theme_void(base_size = font_size, base_family = font_family) %+replace%
    ggplot2::theme(
      line = ggplot2::element_blank(),
      rect = ggplot2::element_blank(),
      text = ggplot2::element_text(
        family = font_family, face = "plain",
        colour = "black", size = font_size,
        lineheight = 0.9, hjust = 0.5, vjust = 0.5, angle = 0,
        margin = ggplot2::margin(), debug = FALSE
      ),

      axis.line =          ggplot2::element_blank(),
      axis.line.x =        NULL,
      axis.line.y =        NULL,
      axis.text =          ggplot2::element_blank(),
      axis.text.x =        ggplot2::element_blank(),
      axis.text.x.top =    ggplot2::element_blank(),
      axis.text.y =        ggplot2::element_blank(),
      axis.text.y.right =  ggplot2::element_blank(),
      axis.ticks =         ggplot2::element_blank(),
      axis.ticks.length =  ggplot2::unit(0, "pt"),
      axis.title.x =       ggplot2::element_blank(),
      axis.title.x.top =   ggplot2::element_blank(),
      axis.title.y =       ggplot2::element_blank(),
      axis.title.y.right = ggplot2::element_blank(),

      legend.background =  ggplot2::element_blank(),
      legend.spacing =     ggplot2::unit(0.4, "cm"),
      legend.spacing.x =   NULL,
      legend.spacing.y =   NULL,
      legend.margin =      ggplot2::margin(0.2, 0.2, 0.2, 0.2, "cm"),
      legend.key =         ggplot2::element_blank(),
      legend.key.size =    ggplot2::unit(1.2, "lines"),
      legend.key.height =  NULL,
      legend.key.width =   NULL,
      legend.text =        ggplot2::element_text(size = ggplot2::rel(0.8)),
      legend.text.align =  NULL,
      legend.title =       ggplot2::element_text(hjust = 0),
      legend.title.align = NULL,
      legend.position =    "none",
      legend.direction =   NULL,
      legend.justification = "center",
      legend.box =         NULL,
      legend.box.margin =  ggplot2::margin(0, 0, 0, 0, "cm"),
      legend.box.background = ggplot2::element_blank(),
      legend.box.spacing = ggplot2::unit(0.4, "cm"),

      panel.background =   ggplot2::element_blank(),
      panel.border =       ggplot2::element_blank(),
      panel.grid.major =   ggplot2::element_blank(),
      panel.grid.minor =   ggplot2::element_blank(),
      panel.spacing =      ggplot2::unit(0, "pt"),
      panel.spacing.x =    NULL,
      panel.spacing.y =    NULL,
      panel.ontop    =     FALSE,

      strip.background =   ggplot2::element_blank(),
      strip.text =         ggplot2::element_blank(),
      strip.text.x =       ggplot2::element_blank(),
      strip.text.y =       ggplot2::element_blank(),
      strip.placement =    "inside",
      strip.placement.x =  NULL,
      strip.placement.y =  NULL,
      strip.switch.pad.grid = ggplot2::unit(0., "cm"),
      strip.switch.pad.wrap = ggplot2::unit(0., "cm"),

      plot.background =    ggplot2::element_blank(),
      plot.title =         ggplot2::element_blank(),
      plot.subtitle =      ggplot2::element_blank(),
      plot.caption =       ggplot2::element_blank(),
      plot.margin =        ggplot2::margin(0, 0, 0, 0),

      complete = TRUE
    )
}

#------------------------------------------------
#' Plot prior and posterior distributions of sigma.
#'
#' Plot prior distribution of sigma as defined by current parameter values. Can optionally overlay a kernel density plot of posterior draws of sigma.
#'
#' @param params a list of parameters as defined by [geoParams()].
#' @param mcmc stored output obtained by running [geoMCMC()]. Leave as `NULL` to plot prior only.
#' @param xlim numeric vector of length 2 giving the x-axis range (must be
#'   non-negative). Leave as `NULL` to use default settings.
#' @param ylim numeric vector of length 2 giving the y-axis range. Leave as
#'   `NULL` to use default settings.
#'
#' @returns Nothing (called for plotting)
#'
#' @export
#'
#' @concept plotting
#'
#' @examplesIf interactive()
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' p <- geoParams(data = d, sigma_mean = 0.2, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' geoPlotSigma(params = p, mcmc = m)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' d <- geoData(sim$longitude, sim$latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' geoPlotSigma(params = p, mcmc = m, xlim = c(0,3), ylim = c(0,6))

geoPlotSigma <- function(params, mcmc = NULL, xlim = NULL, ylim = NULL) {

  # check params
  geoParamsCheck(params, silent = TRUE)

  # check that xlim and ylim are sensible
  if (!is.null(xlim)) {
    cli_stopifnot(is.numeric(xlim) && length(xlim) == 2, "xlim must be a numeric vector of length 2")
    cli_stopifnot(all(is.finite(xlim)), "xlim must be finite")
    cli_stopifnot(xlim[1] >= 0, "xlim[1] must be >= 0 (sigma is positive)")
    cli_stopifnot(xlim[2] > xlim[1], "xlim[2] must be greater than xlim[1]")
  }
  if (!is.null(ylim)) {
    cli_stopifnot(is.numeric(ylim) && length(ylim) == 2, "ylim must be a numeric vector of length 2")
    cli_stopifnot(all(is.finite(ylim)), "ylim must be finite")
    cli_stopifnot(ylim[2] > ylim[1], "ylim[2] must be greater than ylim[1]")
  }

  # extract sigma parameters
  sigma_mean <- params$model$sigma_mean
  sigma_var <- params$model$sigma_var
  alpha <- params$model$sigma_squared_shape
  beta <- params$model$sigma_squared_rate

  # stop if using fixed sigma model
  if (sigma_var == 0) {
    cli::cli_abort(c("x" = 'Can only produce this plot under variable-sigma model (i.e. sigma_var > 0)'))
  }

  # extract sigma draws from mcmc object
  sigma_draws <- if (!is.null(mcmc)) mcmc$sigma else NULL

  # default xlim based on extent of prior distribution AND the extent of posterior draws if available
  if (is.null(xlim)) {
    x_max <- sigma_mean + 3 * sqrt(sigma_var)
    if (!is.null(sigma_draws)) {
      x_max <- max(x_max, 2 * max(sigma_draws, na.rm = TRUE))
    }
    xlim <- c(0, x_max)
  }

  # prior distribution over the x range
  sigma_vec <- seq(xlim[1], xlim[2], l = 501)
  sigma_prior <- dRIG(sigma_vec, alpha, beta)

  # posterior density (if draws available)
  sigma_posterior <- NULL
  if (!is.null(sigma_draws)) {
    sigma_posterior <- stats::density(sigma_draws, from = xlim[1], to = xlim[2])
  }

  # default ylim: 10% headroom above the taller of prior and posterior (finite values only)
  if (is.null(ylim)) {
    v <- c(sigma_prior, sigma_posterior$y)
    v <- v[is.finite(v)]
    ylim <- c(0, 1.1 * max(v))
  }

  # plot prior and overlay density of posterior draws if used
  plot(sigma_vec, sigma_prior, type = 'l', lty = 1, xlim = xlim, ylim = ylim,
       xlab = 'sigma (km)', ylab = 'probability density', main = '')

  if (is.null(sigma_posterior)) {
    graphics::legend(x = 'topright', legend = 'prior', lty = 1)
  } else {
    graphics::lines(sigma_posterior, lty = 2)
    graphics::legend(x = 'topright', legend = c('prior', 'posterior'), lty = c(1, 2))
  }

}

#------------------------------------------------
#' Plot prior and posterior distributions of alpha
#'
#' Plot the Gamma prior on alpha as defined by current parameter values.
#' Can optionally overlay a kernel density plot of posterior draws of alpha.
#'
#' @param params a list of parameters as defined by [geoParams()].
#' @param mcmc stored output obtained by running [geoMCMC()]. Leave as `NULL`
#'   to plot prior only.
#' @param xlim numeric vector of length 2 giving the x-axis range (must be
#'   non-negative). Leave as `NULL` to use default settings.
#' @param ylim numeric vector of length 2 giving the y-axis range. Leave as
#'   `NULL` to use default settings. If the prior diverges at 0
#'   (`alpha_shape < 1`) the default ignores the leftmost 5\% of the x-range
#'   when setting the height, so the prior will run off the top of the plot.
#'
#' @returns Nothing (called for plotting)
#' @export
#' @concept plotting
#'
#' @examplesIf interactive()
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' p <- geoParams(data = d, sigma_mean = 0.2, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' geoPlotAlpha(params = p, mcmc = m)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' d <- geoData(sim$longitude, sim$latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' geoPlotAlpha(params = p, mcmc = m, xlim = c(0,10), ylim = c(0,10))
#'

geoPlotAlpha <- function(params, mcmc = NULL, xlim = NULL, ylim = NULL) {
#JM: It might be more useful if we could plot an approximation of the number of sources a particular alpha distrib implies.

  # check params
  geoParamsCheck(params, silent = TRUE)

  # check xlim and ylim
  if (!is.null(xlim)) {
    cli_stopifnot(is.numeric(xlim) && length(xlim) == 2, "xlim must be a numeric vector of length 2")
    cli_stopifnot(all(is.finite(xlim)), "xlim must be finite")
    cli_stopifnot(xlim[1] >= 0, "xlim[1] must be >= 0 (alpha is positive)")
    cli_stopifnot(xlim[2] > xlim[1], "xlim[2] must be greater than xlim[1]")
  }
  if (!is.null(ylim)) {
    cli_stopifnot(is.numeric(ylim) && length(ylim) == 2, "ylim must be a numeric vector of length 2")
    cli_stopifnot(all(is.finite(ylim)), "ylim must be finite")
    cli_stopifnot(ylim[2] > ylim[1], "ylim[2] must be greater than ylim[1]")
  }

  # extract alpha prior parameters
  alpha_shape <- params$model$alpha_shape
  alpha_rate <- params$model$alpha_rate
  cli_stopifnot(!is.null(alpha_shape) && !is.null(alpha_rate),
                "alpha_shape / alpha_rate not found in params$model")

  # extract alpha draws from mcmc object
  alpha_draws <- if (!is.null(mcmc)) mcmc$alpha else NULL

  # default xlim: 99.9th percentile of prior, extended to cover posterior draws
  if (is.null(xlim)) {
    x_max <- stats::qgamma(0.999, shape = alpha_shape, rate = alpha_rate)
    if (!is.null(alpha_draws)) {
      x_max <- max(x_max, 2 * max(alpha_draws, na.rm = TRUE))
    }
    xlim <- c(0, x_max)
  }

  # prior density over the x range
  alpha_vec <- seq(xlim[1], xlim[2], l = 501)
  alpha_prior <- stats::dgamma(alpha_vec, shape = alpha_shape, rate = alpha_rate)

  # posterior density (if draws available)
  alpha_posterior <- NULL
  if (!is.null(alpha_draws)) {
    alpha_posterior <- stats::density(alpha_draws, from = xlim[1], to = xlim[2])
  }

  # default ylim: finite values only, ignoring the divergence near 0 when shape < 1
  if (is.null(ylim)) {
    prior_for_ylim <- alpha_prior
    if (alpha_shape < 1) {
      prior_for_ylim <- alpha_prior[alpha_vec > xlim[1] + 0.05 * diff(xlim)]
    }
    v <- c(prior_for_ylim, alpha_posterior$y)
    v <- v[is.finite(v)]
    ylim <- c(0, 1.1 * max(v))
  }

  # plot
  plot(alpha_vec, alpha_prior, type = 'l', lty = 1, xlim = xlim, ylim = ylim,
       xlab = 'alpha', ylab = 'probability density', main = '')

  if (is.null(alpha_posterior)) {
    graphics::legend(x = 'topright', legend = 'prior', lty = 1)
  } else {
    graphics::lines(alpha_posterior, lty = 2)
    graphics::legend(x = 'topright', legend = c('prior', 'posterior'), lty = c(1, 2))
  }
}


#------------------------------------------------
#' Plot posterior allocation
#'
#' Produces plot of posterior allocation from output of MCMC.
#'
#' @param mcmc stored output obtained by running [geoMCMC()].
#' @param colours vector of colours for each allocation. If NULL then use default colour scheme.
#' @param barBorderCol colour of borders around each bar. Set as NA to omit this border (useful when there are a large number of observations).
#' @param barBorderWidth line width of borders around each bar.
#' @param mainBorderCol colour of border around plot.
#' @param mainBorderWidth line width of border around plot.
#' @param yTicks_on whether to include ticks on the y-axis.
#' @param yTicks vector of y-axis tick positions.
#' @param xTicks_on whether to include ticks on the x-axis.
#' @param xTicks_size size of ticks on the x-axis.
#' @param xlab x-axis label.
#' @param ylab x-axis label.
#' @param mainTitle main title over plot.
#' @param names individual names of each observation, written horizontally below each bar.
#' @param names_size size of names under each bar.
#' @param orderBy whether to order segments within each bar by `"group"` or by `"probability"`. If ordered by group, all segments of a particular group are laid down before moving to the next group. If ordered by probability the segments within each bar are ordered from large to small.
#'
#' @returns Nothing (called for plotting)
#'
#' @export
#'
#' @concept plotting
#'
#' @examplesIf interactive()
#' # London example data
#' d <- LondonExample_crimes
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' geoPlotAllocation(m)
#'
#' # John Snow cholera data
#' d <- Cholera
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p, lambda=0.05)
#' geoPlotAllocation(m, barBorderCol=NA)	# (should allocate all to a single source!)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#'                51.5235505, alpha=1, sigma=1, tau=3)
#' d <- geoData(sim$longitude, sim $latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' geoPlotAllocation(m)

geoPlotAllocation <- function(mcmc, colours=NULL, barBorderCol=NA, barBorderWidth=0.25, mainBorderCol="black", mainBorderWidth=2, yTicks_on=TRUE, yTicks=seq(0,1,0.2), xTicks_on=FALSE, xTicks_size=1, xlab="", ylab="posterior allocation", mainTitle="", names=NA, names_size=1, orderBy="group") {

  # check that orderBy is either 'group' or 'probability'
  # Will abort with an informative error if not matching
  orderBy <- tolower(orderBy)
  orderBy <- rlang::arg_match0(orderBy, c("group","probability"))

  # get allocation from mcmc object
  allocation <- mcmc$allocation

  # check that allocation is a data frame
  if (!is.data.frame(allocation)) {
    cli::cli_abort(c("x" = "{.arg mcmc$allocation} must be a data frame, with observations in rows and groups in columns!"))
  }

  # extract useful parameters
  n <- nrow(allocation)
  k <- ncol(allocation)

  # replace colours if default
  if (is.null(colours)) {
    rawCols <- RColorBrewer::brewer.pal(n=11,name="RdYlBu")
    myPal <- grDevices::colorRampPalette(rawCols)
    colours <- myPal(k)
    colours <- colours[c(2*(1:ceiling(k/2))-1,2*(1:floor(k/2)))]
  }

  # if ordered by group
  if (orderBy=="group") {

    plot(0, type='n', xlim=c(0,n), ylim=c(0,1), xlab=xlab, ylab=ylab, xaxs="i", yaxs="i",axes=FALSE, main=mainTitle)
    graphics::barplot(t(allocation), col=colours, space=0, border=NA, axes=FALSE, add=TRUE)
    graphics::segments(0:n,c(0,0),0:n,c(1,1), col=barBorderCol, lwd=barBorderWidth)
    graphics::box(col=mainBorderCol, lwd=mainBorderWidth)
    graphics::axis(2, tick=yTicks_on, labels=yTicks_on, at=yTicks)
    graphics::axis(1, at=1:n-0.5, tick=xTicks_on, lwd.ticks=xTicks_size, labels=names, las=2, cex.axis=names_size)
  }

  # if ordered by probability
  if (orderBy=="probability") {

    plot(0, type='n', xlim=c(0,n), ylim=c(0,1), xlab=xlab, ylab=ylab, xaxs="i", yaxs="i",axes=FALSE, main=mainTitle)
    tM <- t(allocation)
    for (i in 1:n) {
      temp <- tM
      temp[,-i] <- NA
      temp_order <- order(temp[,i],decreasing=TRUE)
      graphics::barplot(temp[temp_order,], col=colours[temp_order], space=0, border=NA, axes=FALSE, add=TRUE)
    }
    graphics::segments(0:n,c(0,0),0:n,c(1,1), col=barBorderCol, lwd=barBorderWidth)
    graphics::box(col=mainBorderCol, lwd=mainBorderWidth)
    graphics::axis(2, tick=yTicks_on, labels=yTicks_on, at=yTicks)
    graphics::axis(1, at=1:n-0.5, tick=xTicks_on, lwd.ticks=xTicks_size, labels=names, las=2, cex.axis=names_size)
  }

}

#------------------------------------------------
# get optimal zoom level given x and y values
# (not exported)

getZoom <- function(x,y) {

  # calculate midpoint of range in x and y
  xmid <- min(x) + diff(range(x))/2
  ymid <- min(y) + diff(range(y))/2

  # calculate delta (half of longitude range) for a range of zoom levels
  z <- 20:2
  delta <- 445/(2^z)

  # calculate left and right longitude limits at all zoom levels
  long_angle_left <- xmid - delta
  long_angle_right <- xmid + delta

  # calculate top and bottom latitude limits at all zoom levels
  lat_angle <- ymid/360*2*pi
  projection_mid <- log(tan(pi/4+lat_angle/2))
  projection_top <- projection_mid + delta/360*2*pi
  projection_bot <- projection_mid - delta/360*2*pi
  lat_angle_top <- (2*atan(exp(projection_top))-pi/2)*360/(2*pi)
  lat_angle_bot <- (2*atan(exp(projection_bot))-pi/2)*360/(2*pi)

  # find the most zoomed-in level that captures all points
  zoomTest <- (min(x)>long_angle_left) & (max(x)<long_angle_right) & (min(y)>lat_angle_bot) & (max(y)<lat_angle_top)
  if (!any(zoomTest)) {
    cli::cli_abort(c("x" = "Values are outside of plotting range of earth"))
  }
  bestZoom <- z[which(zoomTest)[1]]

  return(bestZoom)
}

#------------------------------------------------
#' Plot a map and overlay data and/or geoprofile using google maps
#'
#' Plots geoprofile on map, with various customisable options. Warning: google maps requires an API key. For a faster plotting method that has more API free options, use the [geoPlotLeaflet()] function.
#'
#' @param params parameters list in the format defined by [geoParams()].
#' @param data data object in the format defined by [geoData()].
#' @param source potential sources object in the format defined by [geoDataSource()].
#' @param surface a surface to overlay onto the map, typically a geoprofile obtained from the output of [geoMCMC()].
#' @param surfaceCols vector of two or more colours to plot surface. Defaults to viridis palette.
#' @param smoothScale should plot legend show continuous (`TRUE`) or discrete (`FALSE`) colours.
#' @param hitscoreType `"percentage"` = hit score percentage (0-100); `"absolute"` = absolute hit score (0-1, i.e. not multiplied by 100).
#' @param gpLegend whether or not to add the legend to the plot. `TRUE` shows the legend, `FALSE` removes it.
#' @param opacity value between `0` and `1` giving the opacity of surface colours.
#' @param threshold defines the range of hitscores plotted. i.e., 1 includes all hitscore values (100-0) and should cover the entire map (unless a mask has been applied). Lower values restrict the plot to particular hitscores i.e., 0.1 = the top 10%.
#' @param removeNAs `TRUE` removes bins with NA hitscores from the plot, `FALSE` leaves them in and they are plotted as grey.
#' @param breakPercent only relevant when `smoothScale` is `FALSE`, defines the band edges for discrete colour coding and contours. Always given on the 0-100 scale, regardless of `hitscoreType`.
#' @param xbreaks assigns the resolution of the plotted geoprofile surface for the x axis. Larger numbers take longer to process. Test at low values initially. Select values that divide cleanly into the surface cell count. Do not choose values greater than the geoprofile surface cell count.
#' @param ybreaks assigns the resolution of the plotted geoprofile surface for the y axis. Larger numbers take longer to process. Test at low values initially. Select values that divide cleanly into the surface cell count. Do not choose values greater than the geoprofile surface cell count.
#' @param plotContours whether or not to add contours to the surface plot.
#' @param contoursMatchResolution if `TRUE`, contours are drawn from the binned (`xbreaks` / `ybreaks`) surface so they match the rectangles, `FALSE` draws them from the full resolution surface.
#' @param contourCol single colour to plot contour lines showing boundaries on surface.
#' @param contourWeight contour line width.
#' @param contourOpacity contour line opacity, a value between `0` and `1`.
#' @param zoom zoom level of map. If `NULL` then choose optimal zoom from params.
#' @param latLimits optional vector setting min and max latitude for zoom view.
#' @param lonLimits optional vector setting min and max longitude for zoom view.
#' @param mapSource which online source to use when downloading the map. Options include Google Maps (`"google"`), OpenStreetMap (`"osm"`), Stamen Maps (`"stamen"`) and CloudMade maps (`"cloudmade"`). An API key is required for using Google Maps and potentially some of the other sources. Register your key before running this function by using the `register_google()` function.
#' @param mapType the specific type of map to plot. Options available are `"terrain"`, `"satellite"`, `"roadmap"` and `"hybrid"` (google maps), `"terrain-background"`, `"terrain"`, `"watercolor"` and `"toner"` (stamen maps) or a positive integer for cloudmade maps (see [ggmap::get_cloudmademap()] for details).
#' @param crimeCex relative size of symbols showing crimes.
#' @param crimeCol colour of crime symbols.
#' @param crimeBorderCol border colour of crime symbols.
#' @param crimeBorderWidth width of border of crime symbols.
#' @param sourceCex relative size of symbols showing suspect sites.
#' @param sourceCol colour of suspect sites symbols.
#' @param colOpacity opacity of the crime and source points, a value between `0` and `1`.
#'
#' @returns A `ggplot2` plot object.
#'
#' @export
#'
#' @concept plotting
#'
#' @examplesIf interactive()
#' \dontrun{
#' # London example data, all options shown
#' d <- LondonExample_crimes
#' s <- LondonExample_sources
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
#'            surfaceCols = c("blue", "white"),
#'            smoothScale = TRUE,
#'            hitscoreType = "percentage",
#'            gpLegend = TRUE,
#'            opacity = 0.4,
#'            threshold = 0.1,
#'            removeNAs = TRUE,
#'            breakPercent = seq(0, 100, length.out = 11),
#'            xbreaks = 50, ybreaks = 50,
#'            plotContours = FALSE,
#'            contoursMatchResolution = TRUE,
#'            contourCol = "grey50", contourWeight = 0.3, contourOpacity = 1,
#'            zoom = NULL, latLimits = NULL, lonLimits = NULL,
#'            mapSource = "google", mapType = "hybrid",
#'            crimeCex = 2, crimeCol = "black",
#'            crimeBorderCol = "white", crimeBorderWidth = 0.5,
#'            sourceCex = 2, sourceCol = "red",
#'            colOpacity = 1)
#'
#' # John Snow cholera data, discrete colours, contours and absolute hit scores
#' d <- Cholera
#' s <- WaterPumps
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p, lambda = 0.05)
#' geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
#'            smoothScale = FALSE,
#'            hitscoreType = "absolute",
#'            threshold = 0.5,
#'            breakPercent = seq(0, 50, 5),
#'            xbreaks = 50, ybreaks = 50,
#'            plotContours = TRUE,
#'            contoursMatchResolution = TRUE,
#'            contourCol = "white", contourWeight = 0.5, contourOpacity = 0.8,
#'            mapType = "hybrid",
#'            crimeCol = "black", crimeCex = 2,
#'            sourceCol = "red", sourceCex = 2)
#'
#' # simulated data, change colour palette, map type, opacity and range of geoprofile
#' sim <- rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha = 1, sigma = 1, tau = 3)
#' d <- geoData(sim$longitude, sim$latitude)
#' s <- geoDataSource(sim$source_lon, sim$source_lat)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
#'            surfaceCols = c("blue", "white"),
#'            opacity = 0.7,
#'            breakPercent = seq(0, 30, 5),
#'            mapType = "terrain",
#'            crimeCol = "black", crimeBorderCol = "white", crimeCex = 2,
#'            sourceCol = "red", sourceCex = 2)
#' }

geoPlotMap <- function(
    params,                      # parameters object
    data = NULL,                 # observation data
    source = NULL,               # sources if applicable
    surface = NULL,              # the post analysis geoprofile matrix
    surfaceCols = NULL,
    smoothScale = TRUE,          # continuous or discrete colour coding
    hitscoreType = c("percentage", "absolute"), # "percentage" = hit score percentage (0-100); "absolute" = absolute hit score (0-1, i.e. not multiplied by 100)
    gpLegend = TRUE,             # TRUE shows the legend, FALSE removes it
    opacity = 0.4,
    threshold = 1,               # defines the range of hitscores plotted. i.e., 1 includes all hitscore values (100-0) and should cover the entire map (unless a mask has been applied). Lower values restrict the plot to particular hitscores i.e., 0.1 = the top 10%.
    removeNAs = TRUE,            # TRUE removes bins with NA hitscores from the plot, FALSE leaves them in and they are plotted as grey.
    breakPercent = seq(0, 100, length.out = 11), # only relevant when smoothScale is FALSE, defines the band edges for discrete colour coding and contours. Always given on the 0-100 scale, regardless of hitscoreType.
    xbreaks = 100,               # the higher these are the slower but better the results look, test at low levels.
    ybreaks = 100,
    plotContours = FALSE,        # another way to visualise the geoprofile surface. This will also slow plotting
    contoursMatchResolution = TRUE, # TRUE draws contours from the binned (xbreaks / ybreaks) surface so they match the rectangles, FALSE draws them from the full resolution surface.
    contourCol = "grey50",
    contourWeight = 0.3,         # contour line width
    contourOpacity = 1,          # contour line opacity
    zoom = NULL,
    latLimits = NULL,            # map centre / default zoom only, does not change the surface extent
    lonLimits = NULL,            # map centre / default zoom only, does not change the surface extent
    mapSource = "google",        # google requires an API code
    mapType = "hybrid",
    crimeCex = 1.5,
    crimeCol = "red",
    crimeBorderCol = "white",
    crimeBorderWidth = 0.5,
    sourceCex = 1.5,
    sourceCol = "blue",
    colOpacity = 1               # opacity of the crime and source points
) {

  ## checks
  geoParamsCheck(params)
  if (!is.null(data)) geoDataCheck(data)

  hitscoreType <- match.arg(hitscoreType)

  ## defaults
  if (is.null(surfaceCols))
    surfaceCols <- viridis::plasma(100)

  ## the surface ALWAYS sits at the extent used in the analysis. This is never
  ## changed by zoom or by lonLimits / latLimits.
  surfaceLon <- params$output$longitude_minMax
  surfaceLat <- params$output$latitude_minMax

  ## lonLimits / latLimits are used only to centre the map and choose a default zoom
  if (is.null(latLimits))
    latLimits <- surfaceLat

  if (is.null(lonLimits))
    lonLimits <- surfaceLon

  zoomIsDefault <- is.null(zoom)

  if (zoomIsDefault)
    zoom <- getZoom(lonLimits, latLimits)

  ## display scale: the surface is held on a 0-100 scale internally.
  ## "percentage" leaves it as is, "absolute" rescales to 0-1 (no x100).
  displayScale <- if (hitscoreType == "percentage") 1 else 0.01
  legendTitle  <- if (hitscoreType == "percentage") "Hit score\npercentage" else "Hit score"

  ## warnings
  if (!is.logical(gpLegend) || length(gpLegend) != 1 || is.na(gpLegend)) {
    stop("gpLegend should be TRUE or FALSE.", call. = FALSE)
  }

  if (contourOpacity < 0 || contourOpacity > 1) {
    warning("contourOpacity should be between 0 and 1.", call. = FALSE)
  }

  if (colOpacity < 0 || colOpacity > 1) {
    warning("colOpacity should be between 0 and 1.", call. = FALSE)
  }

  if (!is.null(surface)) {

    ### surface should be a matrix, note its dims (rows = latitude cells, columns = longitude cells)
    if (!is.matrix(surface)) {
      warning("surface should be a matrix.", call. = FALSE)
    }
    surface_dims <- dim(surface)

    ### threshold must fall between 0 and 1
    if (threshold < 0 || threshold > 1) {
      warning("threshold should be between 0 and 1.", call. = FALSE)
    }

    ### opacity must fall between 0 and 1
    if (opacity < 0 || opacity > 1) {
      warning("opacity should be between 0 and 1.", call. = FALSE)
    }

    if (length(surface_dims) == 2) {

      ### surface dims must match the cells in params, otherwise the grid cannot be built
      if (surface_dims[1] != params$output$latitude_cells ||
          surface_dims[2] != params$output$longitude_cells) {
        stop(
          "surface dimensions (", surface_dims[1], " x ", surface_dims[2],
          ") do not match params$output latitude_cells x longitude_cells (",
          params$output$latitude_cells, " x ", params$output$longitude_cells, ").",
          call. = FALSE
        )
      }

      ### xbreaks and ybreaks should not exceed the dims of the surface
      if (xbreaks > surface_dims[2]) {
        warning(
          "xbreaks (", xbreaks, ") is larger than the number of surface columns (",
          surface_dims[2], ").",
          call. = FALSE
        )
      }

      if (ybreaks > surface_dims[1]) {
        warning(
          "ybreaks (", ybreaks, ") is larger than the number of surface rows (",
          surface_dims[1], ").",
          call. = FALSE
        )
      }

      ### matching the dims exactly is not necessary and is the slowest option
      if (xbreaks == surface_dims[2] && ybreaks == surface_dims[1]) {
        warning(
          "higher resolutions take longer to run, consider testing at lower x and y break values",
          call. = FALSE
        )
      }
    }
  }

  ## download map centred on the plotting region
  loc <- c(mean(lonLimits), mean(latLimits))

  rawMap <- ggmap::get_map(
    location = loc,
    zoom = zoom,
    source = mapSource,
    maptype = mapType
  )

  ## extent of the visible map. This is only READ to clip numbers, no scales
  ## or coords are changed.
  if (zoomIsDefault) {
    viewLon <- range(lonLimits)
    viewLat <- range(latLimits)
  } else {
    bb      <- attr(rawMap, "bb")
    viewLon <- c(bb$ll.lon, bb$ur.lon)
    viewLat <- c(bb$ll.lat, bb$ur.lat)
  }

  ## trims rectangles to the visible map and drops any fully outside it
  clipToView <- function(d) {
    d <- d[d$xmax > viewLon[1] & d$xmin < viewLon[2] &
             d$ymax > viewLat[1] & d$ymin < viewLat[2], , drop = FALSE]
    d$xmin <- pmax(d$xmin, viewLon[1])
    d$xmax <- pmin(d$xmax, viewLon[2])
    d$ymin <- pmax(d$ymin, viewLat[1])
    d$ymax <- pmin(d$ymax, viewLat[2])
    d
  }

  ## ggmap() restricts the plot to the extent of the downloaded map and sets up
  ## the scales / projection so the image lines up with lon and lat. We leave
  ## these alone, so zoom changes the map and everything else stays registered.
  p <- ggmap::ggmap(rawMap)

  if (!is.null(surface)) {

    ## create plotting grid
    ### count number of cells lon and lat
    longitude_cells <- params$output$longitude_cells
    latitude_cells  <- params$output$latitude_cells

    ### cell size equals the surface range / by number of cells.
    longitude_cellSize <- diff(surfaceLon) / longitude_cells
    latitude_cellSize  <- diff(surfaceLat) / latitude_cells

    ### estimate midpoints of each cell
    longitude_midpoints <-
      surfaceLon[1] - longitude_cellSize / 2 +
      (1:longitude_cells) * longitude_cellSize

    latitude_midpoints <-
      surfaceLat[1] - latitude_cellSize / 2 +
      (1:latitude_cells) * latitude_cellSize

    ### fill in values
    df <- expand.grid(
      x = longitude_midpoints,
      y = latitude_midpoints
    )

    df$z <- as.vector(t(surface))

    df$x_cell <- rep(seq_len(longitude_cells), times = latitude_cells)
    df$y_cell <- rep(seq_len(latitude_cells), each = longitude_cells)

    ## threshold (applied on the 0-100 scale)
    df$z[df$z > threshold * 100] <- NA

    ## convert to the display scale (percentage stays as is, absolute = 0-1)
    df$z <- df$z * displayScale

    ## Aggregate cells into xbreaks x ybreaks bins, averaging hitscores within each bin
    x_bin_id <- ceiling(
      seq_len(longitude_cells) * xbreaks / longitude_cells
    )

    y_bin_id <- ceiling(
      seq_len(latitude_cells) * ybreaks / latitude_cells
    )

    df$x_bin <- x_bin_id[df$x_cell]
    df$y_bin <- y_bin_id[df$y_cell]

    ## Aggregate probability values
    df_down <- df |>
      dplyr::group_by(.data$x_bin, .data$y_bin) |>
      dplyr::summarise(
        z = if (all(is.na(.data$z))) NA_real_ else mean(.data$z, na.rm = TRUE),
        .groups = "drop"
      )

    ## Calculate the exact geographic boundaries of each bin
    x_bounds <- df |>
      dplyr::group_by(.data$x_bin) |>
      dplyr::summarise(
        xmin = surfaceLon[1] +
          (min(.data$x_cell) - 1) / longitude_cells * diff(surfaceLon),
        xmax = surfaceLon[1] +
          max(.data$x_cell) / longitude_cells * diff(surfaceLon),
        .groups = "drop"
      )

    y_bounds <- df |>
      dplyr::group_by(.data$y_bin) |>
      dplyr::summarise(
        ymin = surfaceLat[1] +
          (min(.data$y_cell) - 1) / latitude_cells * diff(surfaceLat),
        ymax = surfaceLat[1] +
          max(.data$y_cell) / latitude_cells * diff(surfaceLat),
        .groups = "drop"
      )

    ## Attach boundaries to each aggregated cell
    df_down <- df_down |>
      dplyr::left_join(x_bounds, by = "x_bin") |>
      dplyr::left_join(y_bounds, by = "y_bin")

    ## bin centres are used for contours when contoursMatchResolution = TRUE, otherwise the full df is used for contours
    df_down$x <- (df_down$xmin + df_down$xmax) / 2
    df_down$y <- (df_down$ymin + df_down$ymax) / 2

    ## band edges on the display scale (used for discrete colours and contours)
    breaksDisplay <- breakPercent * displayScale

    ## geoprofile is plotted using rectangles coloured on a continuous scale or discrete.
    if (smoothScale) {

      ## NA bins are either removed or left in (and plotted as grey)
      rect_data <- if (removeNAs) df_down[!is.na(df_down$z), ] else df_down
      rect_data <- clipToView(rect_data)

      ## legend runs from 0 to the threshold maximum, so both end values get a tick
      legendMax <- threshold * 100 * displayScale

      p <- p +
        ggplot2::geom_rect(
          ggplot2::aes(
            xmin = .data$xmin,
            xmax = .data$xmax,
            ymin = .data$ymin,
            ymax = .data$ymax,
            fill = .data$z
          ),
          data = rect_data,
          alpha = opacity,
          inherit.aes = FALSE
        ) +
        ggplot2::scale_fill_gradientn(
          colours = rev(surfaceCols),
          name = legendTitle,
          limits = c(0, legendMax),
          breaks = seq(0, legendMax, length.out = 5),
          guide = ggplot2::guide_colourbar(reverse = TRUE) # low values / warm colours at the top
        )

    } else {

      ## every bin is assigned a percentage band and these are each given a colour.
      geoCols <- grDevices::colorRampPalette(
        rev(surfaceCols)
      )

      nbcol <- length(breakPercent) - 1

      labs <- paste0(
        round(breaksDisplay, 3)[-length(breaksDisplay)],
        "-",
        round(breaksDisplay, 3)[-1],
        if (hitscoreType == "percentage") "%" else ""
      )

      df_down$cut <- cut(
        df_down$z,
        include.lowest = TRUE,
        breaks = breaksDisplay,
        labels = labs
      )

      df_down$col <- geoCols(nbcol)[as.integer(df_down$cut)]

      ## NA bins are either removed or left in (and plotted as grey)
      rect_data <- if (removeNAs) df_down[!is.na(df_down$z), ] else df_down
      rect_data <- clipToView(rect_data)

      p <- p +
        ggplot2::geom_rect(
          ggplot2::aes(
            xmin = .data$xmin,
            xmax = .data$xmax,
            ymin = .data$ymin,
            ymax = .data$ymax,
            fill = .data$col
          ),
          data = rect_data,
          alpha = opacity,
          inherit.aes = FALSE
        ) +
        ggplot2::scale_fill_identity(
          name = legendTitle,
          guide = "legend",
          breaks = geoCols(nbcol),   # first (lowest, warm) band is listed at the top
          labels = labs
        )
    }

    if (plotContours) {
      contour_data <- if (contoursMatchResolution) df_down else df
      p <- p +
        ggplot2::stat_contour(
          ggplot2::aes(x = .data$x, y = .data$y, z = .data$z),
          colour = contourCol,
          breaks = breaksDisplay,
          linewidth = contourWeight,
          alpha = contourOpacity,
          data = contour_data,
          inherit.aes = FALSE
        )
    }
  }

  ## crime locations
  if (!is.null(data)) {
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(
          x = .data$longitude,
          y = .data$latitude
        ),
        data = data,
        shape = 21,
        stroke = crimeBorderWidth,
        size = crimeCex,
        fill = crimeCol,
        colour = crimeBorderCol,
        alpha = colOpacity
      )
  }

  ## source locations
  if (!is.null(source)) {
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(
          x = .data$longitude,
          y = .data$latitude
        ),
        data = source,
        shape = 15,
        size = sourceCex,
        colour = sourceCol,
        alpha = colOpacity
      )
  }

  ## remove the legend if requested
  if (!gpLegend) {
    p <- p + ggplot2::theme(legend.position = "none")
  }

  if (zoomIsDefault) {
    p <- p +
      ggplot2::scale_x_continuous(
        limits = lonLimits,
        expand = c(0, 0)
      ) +
      ggplot2::scale_y_continuous(
        limits = latLimits,
        expand = c(0, 0)
      )
  }
  p
}


#------------------------------------------------
#' Plot a map and overlay data and/or geoprofile via leaflet
#'
#' Plots geoprofile on map, with various customisable options. Interactive and static map options available.
#'
#' @param params parameters list in the format defined by [geoParams()].
#' @param data data object in the format defined by [geoData()].
#' @param source potential sources object in the format defined by [geoDataSource()].
#' @param surface a surface to overlay onto the map, typically a geoprofile obtained from the output of [geoMCMC()].
#' @param surfaceCols vector of two or more colours to plot surface. Defaults to viridis palette.
#' @param threshold what level of the geoprofile to display. 1 = the whole geoprofile surface. 0.1 = the top 10% of the surface.
#' @param smoothing smoothing affects the plotted resolution of the colour heatmaps. Higher values = more pixels, smoother colour gradients but increased plotting time.
#' @param opacity value between `0` and `1` giving the opacity of surface colours.
#' @param plotContours Another way of viewing the geoprofile surface which uses contour lines to represent the surface as a heightmap.
#' @param contourBreaks hitscore % levels, as in breakPercent. Set the range and bins of the geoprofile surface the contours will represent.
#' @param contourCol colour of contour lines.
#' @param contourWeight thickness of contour lines.
#' @param contourOpacity opacity of contour lines.
#' @param crimeCex relative size of symbols showing crimes.
#' @param crimeCol colour of crime symbols.
#' @param sourceCex relative size of symbols showing suspect sites.
#' @param sourceCol colour of suspect sites symbols.
#' @param colOpacity opacity of crime and source colours.
#' @param mapType the specific type of map to plot. See [leaflet::providers] for options.
#' @param apiKey API keys may be required for some maptypes. Note: API keys for Carto maps will not work with the current leaflet package version available on CRAN.
#' @param showBoundary plot a bounding box that encompasses the extent of the geoprofile surface.
#' @param boundaryWeight thickness of the bounding box.
#' @param boundaryCol colour of the boundary box.
#' @param gpLegend whether or not to add legend to plot.
#' @param legendPosition "bottomright", # "topright", "bottomright", "bottomleft", "topleft".
#' @param legendScale size of the legend.
#' @param saveFile take a static screenshot of the plot for figures. UI such as the zoom options are automatically removed. Set by inputting a name for the resulting file.
#' @param cropToBoundary crop so that the saved figure matches the extent of the geoprofile surface.
#' @param mapZoom control the zoom of the plot. Ignored if cropToBoundary = TRUE.
#' @param saveWidth set the width of the resulting saved image.
#' @param saveHeight set the height of the resulting saved image.
#' @param saveZoom does not affect the zoom of the map but instead affects the resolution of the saved image. Affects the zoom option of the function [webshot2::webshot].
#'
#'
#' @returns A `leaflet` plot object.
#'
#' @export
#'
#' @concept plotting
#'
#' @examplesIf interactive()
#' \dontrun{
#' # London example data
#' d <- LondonExample_crimes
#' s <- LondonExample_sources
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' # produce simple map
#' geoPlotLeaflet(params = p,
#'                data = d,
#'                source = s,
#'                surface = m$geoProfile,
#'                crimeCol = "black",
#'                crimeCex = 2,
#'                sourceCol = "red",
#'                sourceCex = 2)
#'
#' # John Snow cholera data
#' d <- Cholera
#' s <- WaterPumps
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p, lambda=0.05)
#' # produce simple map
#' geoPlotLeaflet(params = p,
#'                data = d,
#'                source = s,
#'                surface = m$geoProfile,
#'                crimeCol = "black",
#'                crimeCex = 2,
#'                sourceCol = "red",
#'                sourceCex = 2)
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' d <- geoData(sim$longitude, sim $latitude)
#' s <- geoDataSource(sim$source_lon, sim$source_lat)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' # change colour palette, map type, opacity and range of geoprofile and omit legend
#' geoPlotLeaflet(params = p,
#'                data = d,
#'                source = s,
#'                surface = m$geoProfile,
#'                surfaceCols = c("blue","white"),
#'                crimeCol = "black",
#'                crimeCex = 2,
#'                sourceCol = "red",
#'                sourceCex = 2,
#'                opacity = 0.7,
#'                gpLegend = FALSE)
#' }

geoPlotLeaflet <- function(params = NULL,
                            data = NULL,
                            source = NULL,
                            surface = NULL,
                            surfaceCols = c("#F0F921FF", "#FDC926FF", "#FA9E3BFF", "#ED7953FF",
                                            "#D8576BFF", "#BD3786FF", "#9C179EFF", "#7301A8FF", "#47039FFF", "#0D0887FF") ,
                            threshold = 0.1, # threshold dictates the cutoff point of hitscores displayed on the plot. Choose 1 to plot the entire surface. 0.1 will plot only the top 10% of the surface.
                            smoothing = 1, # smoothing affects the plotted resolution of the colour heatmaps. higher values = more pixels, smoother colour gradients but increased plotting time.
                            opacity = 0.8,
                            plotContours = FALSE, # Another way of viewing the geoprofile surface which uses contour lines to represent the surface as a heightmap.
                            contourBreaks = seq(0, 100, length.out = 11),  # hitscore % levels, as in breakPercent. Essentially set the range and bins of the geoprofile surface the contours will represent.
                            contourCol = "grey50",
                            contourWeight = 1,
                            contourOpacity = 1,
                            crimeCex = 1.5,
                            crimeCol = 'red',
                            sourceCex = 1.5,
                            sourceCol = 'blue',
                            colOpacity = 1,
                            mapType = "Esri.WorldImagery", # options available based on the leaflet package
                            apiKey = NULL,
                            showBoundary = TRUE, # plot a bounding box that encompasses the extent of the geoprofile surface.
                            boundaryWeight = 2,
                            boundaryCol = grDevices::grey(0.2),
                            gpLegend  = FALSE,
                            legendPosition = "bottomright", # "topright", "bottomright", "bottomleft", "topleft"
                            legendScale = 1,
                            saveFile = NULL, # take a static screenshot of the plot for figures. UI such as the zoom options are automatically removed. Set by inputting a name for the resulting file.
                            cropToBoundary = TRUE, # crop so that the saved figure matches the extent of the geoprofile surface.
                            mapZoom = 5, # control the zoom of the plot. Ignored if cropToBoundary = TRUE.
                            saveWidth = 1200,
                            saveHeight = 1200,
                            saveZoom = 2 # does not affect the zoom of the map but instead affects the resolution of the saved image. Affects the zoom option of the function webshot2::webshot.
) {

  # check inputs
  # assert_bounded(threshold)
  # assert_string(surfaceCols)
  # assert_bounded(opacity)
  # assert_single_pos(opacity, zero_allowed = TRUE)
  #
  # assert_single_pos(smoothing)
  # assert_greq(smoothing, 1.0)
  # assert_single_logical(legend)
  # assert_in(map_type, 1:137, message = "map_type must be in 1:137")
  #
  # get output extent from params

  legendPosition <- match.arg(legendPosition,
                              c("topright", "bottomright", "bottomleft", "topleft"))

  # leaflet needs CSS colours, so convert R colour names (e.g. "grey50") to hex
  toHex <- function(x) grDevices::rgb(t(grDevices::col2rgb(x)), maxColorValue = 255)

  contourCol     <- toHex(contourCol)
  boundaryCol <- toHex(boundaryCol)
  crimeCol       <- toHex(crimeCol)
  sourceCol      <- toHex(sourceCol)

  if(is.null(params)){
    # if no params build extent based on data
    lonMnMx <- range(data$longitude)
    latMnMx <- range(data$latitude)

    lonEx <- (lonMnMx[2] - lonMnMx[1])*0.05
    latEx <- (latMnMx[2] - latMnMx[1])*0.05

    fullExt <- c(lonMnMx + c(-lonEx, lonEx), latMnMx + c(-latEx, latEx))
  } else {
    fullExt <- c(params$output$longitude_minMax, params$output$latitude_minMax)
  }

  # produce plot
  if(!is.null(saveFile)){

    myplot <- leaflet::leaflet(
      options = leaflet::leafletOptions(
        zoomControl = FALSE,
        zoomSnap = 0,      # allow fitBounds to use a fractional zoom
        zoomDelta = 0.5
      )
    )
    myplot <- leaflet::addProviderTiles(myplot, provider = mapType, options = leaflet::providerTileOptions(
      apikey = apiKey))
  } else {
    myplot <- leaflet::leaflet()
    myplot <- leaflet::addProviderTiles(myplot, provider = mapType, options = leaflet::providerTileOptions(
      apikey = apiKey))
  }

  if(!is.null(data)){
    # add crimes markers
    myplot <- leaflet::addCircleMarkers(myplot,
                                        lng = data$longitude,
                                        lat = data$latitude,
                                        radius = crimeCex,
                                        fillColor = crimeCol,
                                        stroke = FALSE,
                                        fillOpacity = colOpacity)
  }
  if(!is.null(source)){
    # add crimes markers
    myplot <- leaflet::addCircleMarkers(myplot,
                                        lng = source$longitude,
                                        lat = source$latitude,
                                        radius = sourceCex,
                                        fillColor = sourceCol,
                                        stroke = FALSE,
                                        fillOpacity = colOpacity)
  }

  if(!is.null(surface)){

    # make a raster from the surface
    surface_matrix <- apply(surface, 2, rev)

    surface <- terra::rast(
      surface_matrix,
      extent = terra::ext(fullExt[1], fullExt[2], fullExt[3], fullExt[4])
    )
    terra::crs(surface) <- "EPSG:4326"

    # apply smoothing
    if (smoothing > 1.0) {
      # FW: This is actually a function name change. terra::disagg looks like the exact same function as raster::disaggregate, but it is worth a check!
      surface <- terra::disagg(surface, smoothing, method = "bilinear")
    }

    # compute contours (before thresholding so NA cells don't break the lines)
    contour_lines <- NULL
    if (plotContours) {
      cmat <- matrix(terra::values(surface), nrow(surface), byrow = TRUE)
      cx <- terra::xFromCol(surface, seq_len(ncol(surface)))
      cy <- terra::yFromRow(surface, rev(seq_len(nrow(surface))))  # ascending lat
      cz <- t(cmat[nrow(cmat):1, , drop = FALSE])                  # [lon, lat]

      contour_levels <- contourBreaks[contourBreaks <= threshold * 100]
      if (length(contour_levels) > 0) {
        contour_lines <- grDevices::contourLines(x = cx, y = cy, z = cz,
                                                 levels = contour_levels)
      }
    }

    # apply threshold
    geoprofile_mat <- matrix(terra::values(surface), nrow(surface), byrow = TRUE)
    geoprofile_mat[geoprofile_mat > threshold*100] <- NA
    surface <- terra::setValues(surface, geoprofile_mat)

    # overlay raster
    myplot <- leaflet::addRasterImage(myplot, x = surface, colors = surfaceCols, opacity = opacity, project = TRUE)

    if (length(contour_lines) > 0) {
      for (cl in contour_lines) {
        myplot <- leaflet::addPolylines(
          myplot,
          lng = cl$x,
          lat = cl$y,
          color = contourCol,
          weight = contourWeight,
          opacity = contourOpacity
        )
      }
    }

    # add bounding rect
    if (showBoundary == TRUE) {
      myplot <- leaflet::addRectangles(myplot,
                                       terra::xmin(surface),
                                       terra::ymin(surface),
                                       terra::xmax(surface),
                                       terra::ymax(surface),
                                       fill = FALSE,
                                       weight = boundaryWeight,
                                       color = boundaryCol
      )
    }

    # add hitscore legend
    if (gpLegend == TRUE) {

      hitscore_sequence <- seq(
        0,
        threshold,
        threshold / (length(surfaceCols) - 1)
      )

      pal <- leaflet::colorNumeric(
        palette = surfaceCols,
        domain = hitscore_sequence
      )

      myplot <- leaflet::addLegend(
        myplot,
        position = legendPosition,
        pal = pal,
        values = hitscore_sequence,
        title = "Hit score",
        opacity = 1
      )

      # Scale the entire legend while preserving its internal proportions
      if (legendScale != 1) {
        origin <- paste(if (grepl("top", legendPosition)) "top" else "bottom",
                        if (grepl("right", legendPosition)) "right" else "left")

        myplot <- htmlwidgets::onRender(
          myplot,
          sprintf(
            "
      function(el, x) {
        var legend = el.querySelector('.info.legend');
        if (legend) {
          legend.style.transform = 'scale(%s)';
          legend.style.transformOrigin = '%s';
        }
      }
      ",
            legendScale, origin
          )
        )
      }
    }
  }

  # Set map view
  cropping <- !is.null(saveFile) && cropToBoundary

  if (cropping) {
    # Fit exactly to the box (padding leaves room for the boundary line stroke)
    pad <- if (showBoundary) boundaryWeight else 0
    myplot <- leaflet::fitBounds(
      myplot,
      lng1 = fullExt[1], lat1 = fullExt[3],
      lng2 = fullExt[2], lat2 = fullExt[4],
      options = list(padding = c(pad, pad))
    )
  } else if (!is.null(mapZoom)) {
    myplot <- leaflet::setView(
      myplot,
      lng = mean(fullExt[1:2]),
      lat = mean(fullExt[3:4]),
      zoom = mapZoom
    )
  } else if (cropToBoundary) {
    myplot <- leaflet::fitBounds(
      myplot,
      lng1 = fullExt[1], lat1 = fullExt[3],
      lng2 = fullExt[2], lat2 = fullExt[4]
    )
  }

  if (!is.null(saveFile)) {

    if (cropToBoundary) {
      # Make the viewport the same shape as the box in Web Mercator,
      # so the box fills the image with no extra map around it
      merc_y <- function(lat) log(tan(pi / 4 + lat * pi / 360))
      dx <- (fullExt[2] - fullExt[1]) * pi / 180
      dy <- merc_y(fullExt[4]) - merc_y(fullExt[3])
      saveHeight <- round(saveWidth * dy / dx)
    }

    tmp_html <- tempfile(fileext = ".html")
    htmlwidgets::saveWidget(myplot, tmp_html, selfcontained = TRUE)

    webshot2::webshot(
      tmp_html,
      file = saveFile,
      vwidth = saveWidth,
      vheight = saveHeight,
      zoom = saveZoom,
      delay = 2            # give tiles time to load after the fit
    )
  }

  # plot map
  return(myplot)
}

#------------------------------------------------
#' Perspective plot of geoprofile or raw probabilities
#'
#' Plots persp plot of geoprofile or posterior surface (coloured according to height), reducing matrix dimensions if necessary to avoid grid lines being too close together. NB Only works with square matrix
#'
#' @param surface surface to plot; either the geoprofile or posteriorSurface output by [geoMCMC()].
#' @param aggregate_size the number of cells to aggregate to smooth the surface.
#' @param surface_type type of surface; should be either `"gp"` for geoprofile or `"prob"` for posteriorSurface.
#' @param perspCol colour palette. Defaults to red/orange/yellow/white.
#' @param phiGP value of phi to pass to [graphics::persp()].
#' @param thetaGP value of theta to pass to [graphics::persp()].
#'
#' @returns Nothing (called for plotting)
#'
#' @export
#'
#' @concept plotting
#'
#' @examplesIf interactive()
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' s <- geoDataSource(WaterPumps$longitude, WaterPumps$latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p, lambda=0.05)
#' # raw probabilities
#' geoPersp(m$posteriorSurface, surface_type = "prob")
#' # geoprofile
#' geoPersp(m$geoProfile, aggregate_size = 3, surface_type = "gp")
#'
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=1, sigma=1, tau=3)
#' d <- geoData(sim$longitude, sim $latitude)
#' s <- geoDataSource(sim$source_lon, sim$source_lat)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' # raw probabilities
#' geoPersp(m$posteriorSurface, surface_type = "prob")
#' # geoprofile
#' geoPersp(surface = m$geoProfile, aggregate_size = 3, surface_type = "gp")

geoPersp <- function(surface, aggregate_size=3, surface_type="gp", perspCol=c("red", "orange", "yellow", "white"), phiGP=30, thetaGP=-30) {

  # rescale and transform surface
  scale <- 1
  if(surface_type=="gp") { scale <- -1 }
  surface <- t(scale*surface)

  # reduce matrix or not
  matrix_size <- unique(dim(surface))[1]
  breaks <- seq(1, (matrix_size-(aggregate_size-1)), aggregate_size)
  nb <- length(breaks)
  output <- matrix(NA, nrow=nb, ncol=nb)
  for (i in 1:nb) {
    for (j in 1:nb) {
      output[i,j] <- mean(as.vector(surface[breaks[i]:(breaks[i]+(aggregate_size-1)), breaks[j]:(breaks[j]+(aggregate_size-1))]))
    }
  }
  # Generate the desired number of colors
  colpal <- grDevices::colorRampPalette(perspCol)
  color <- colpal(100)

  # Compute the z-value at the facet centres
  ncz <- ncol(output)
  nrz <- nrow(output)
  zfacet <- output[-1, -1] + output[-1, -ncz] + output[-nrz, -1] + output[-nrz, -ncz]
  facetcol <- cut(zfacet, length(color))

  # FW: Assume this is correct, could alternatively be terra::persp, though that usually takes a SpatVector which output is not.
  graphics::persp(output, col=color[facetcol], border="black", phi=phiGP, theta=thetaGP, lwd=0.2, box=FALSE)
}


#' Interactive 3D plot of geoprofile or raw probabilities
#'
#' Plots an interactive 3D plot of geoprofile or posterior surface (coloured according to height). This requires the `plotly` package to be installed.
#'
#' @note
#' Generally speaking 3D plots are not particularly useful for static data representation. As such these should only be used in decorative or interactive formats rather than as the only way of representing data.
#' If you are looking to represent probability surfaces in a 2D medium such as a paper, heatmaps are usually easier to interpret.
#'
#' @param surface surface to plot; either the geoprofile or posteriorSurface output by [geoMCMC()].
#' @param surface_type type of surface; should be either `"gp"` for geoprofile or `"prob"` for posteriorSurface.
#'
#' @returns Nothing (called for plotting)
#'
#' @export
#'
#' @concept plotting
#'
#' @examplesIf interactive()
#' # John Snow cholera data
#' d <- geoData(Cholera$longitude, Cholera$latitude)
#' s <- geoDataSource(WaterPumps$longitude, WaterPumps$latitude)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p, lambda=0.05)
#' # raw probabilities
#' geoSurface3D(m$posteriorSurface, surface_type = "prob")
#' # geoprofile
#' geoSurface3D(m$geoProfile, surface_type = "gp")
geoSurface3D <- function(surface, surface_type="gp") {

  rlang::check_installed("plotly")

  # rescale and transform surface
  scale <- 1
  if(surface_type=="gp") { scale <- -1 }
  surface <- t(scale*surface)

  plotly::plot_ly(z = ~surface) |> plotly::add_surface()
}

#------------------------------------------------
#' Produce Lorenz Plot
#'
#' Produces a Lorenz plot showing the proportion of suspect sites or cimes identified as a function of area and calculates
#' the corresponding Gini coefficient using trapezoid rule.
#' Also allows an optional vector called crimeNumbers with numbers of crimes per suspect site; the length of this vector
#' should equal the number of suspect sites. If this is present, the function calculates and returns the Gini coefficient
#' based on the number of crimes; otherwise, this is calculated based on the number of suspect sites.
#'
#' @param hit_scores object in the format defined by [geoReportHitscores()].
#' @param crimeNumbers optional vector with numbers of crimes per suspect site.
#' @param suspects_col colour to plot curve for sources.
#' @param crimes_col colour to plot curve for crimes if crimeNumbers is supplied.
#'
#' @returns The Gini values (invisibly)
#'
#' @export
#'
#' @concept plotting
#'
#' @examplesIf interactive()
#' # London example data
#' d <- LondonExample_crimes
#' s <- LondonExample_sources
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' hs <- geoReportHitscores(params = p, source = s, surface = m$geoProfile)
#' hs
#' # Lorenz plot on sources
#' geoPlotLorenz(hs)
#' # Lorenz plot on sources and crimes
#' # extract numbers of crimes allocated per source as a proxy
#' cn <- as.vector(table(m$bestGrouping))
#' geoPlotLorenz(hs, crimeNumbers = cn)

geoPlotLorenz <- function(hit_scores, crimeNumbers=NULL, suspects_col="red", crimes_col="blue") {

  # trapezoid rule
  tpzd <- function(x,y) {
    idx = 2:length(x)
    return (as.double( (x[idx] - x[idx-1]) %*% (y[idx] + y[idx-1])) / 2)
  }

  # bind crimeNumbers if using
  crimeNumbers_on <- !is.null(crimeNumbers)
  if (crimeNumbers_on) {
    hit_scores <- cbind(hit_scores, crimeNumbers)
  }

  # put hitscore data frame in increasing order
  hit_scores <- hit_scores[order(hit_scores[,3]),]
  hs <- hit_scores[,3]
  n <- nrow(hit_scores)

  # cumulative crime sites
  cum_suspect_sites <- (1:n)/n

  # add initial 0 and terminal 1 to each so plots will begin at (0,0) and end at (1,1)
  hs <- c(0,hs,100)
  cum_suspect_sites <- c(0,cum_suspect_sites,1)

  # calculate gini coefficient for crimes
  auc <- (tpzd(hs/100, cum_suspect_sites) - 0.5)/0.5
  G_sources <- round(auc,3)

  # produce plot
  if (!crimeNumbers_on) {

    # plot
    plot(0, type="n", xlim=c(0,100), ylim=c(0,1), xlab="hit score percentage", ylab="proportion identified")
    graphics::abline(h=seq(0,1,0.2), v=seq(0,100,20), col="lightgray", lwd=0.4)
    graphics::abline(0, 0.01, col="gray")
    graphics::lines(hs, cum_suspect_sites, col=suspects_col)

    # add Gini value text and legend
    Gini_text <- paste0("G (sources) = ",G_sources)
    graphics::legend(60, 0.4, Gini_text, cex=0.8, bty="n")
    graphics::legend(65, 0.25, c("sources"), col=c(suspects_col), lwd=1, cex=0.8)

    # return Gini value(s) silently
    invisible(c(G_sources=G_sources))

  } else {

    # cumulative crime numbers
    cum_crimes <- cumsum(hit_scores[,4])/sum(hit_scores[,4])
    cum_crimes <- c(0,cum_crimes,1)

    # calculate gini coefficient for crimes
    auc <- (tpzd(hs/100, cum_crimes) - 0.5)/0.5
    G_crimes <- round(auc,3)

    # plot
    plot(0, type="n", xlim=c(0,100), ylim=c(0,1), xlab="hit score percentage", ylab="proportion identified")
    graphics::abline(h=seq(0,1,0.2), v=seq(0,100,20), col="lightgray", lwd=0.4)
    graphics::abline(0, 0.01, col="gray")
    graphics::lines(hs, cum_suspect_sites, col=suspects_col)
    graphics::lines(hs, cum_crimes, col=crimes_col)

    # add Gini value text and legend
    Gini_text <- c(paste0("G (sources) = ",G_sources), paste0("G (incidents) = ",G_crimes))
    graphics::legend(60, 0.5, Gini_text, cex=0.8, bty="n")
    graphics::legend(65, 0.25, c("sources","incidents"), col=c(suspects_col,crimes_col), lwd=1, cex=0.8)

    # return Gini value(s) silently
    invisible(c(G_sources=G_sources, G_incidents=G_crimes))
  }

}

#------------------------------------------------
#' Calculate and plot probability of coallocation
#'
#' For all pairs of crimes, calculates the probability that both originate from the same source and plots a coloured half matrix representing these data. The data underlying these calculations can be accessed as the object `$coAllocation` produced by [geoMCMC()].
#'
#' @param mcmc object of the type output by [geoMCMC()].
#' @param cols colour palette to use. Defaults to viridis palette.
#'
#' @returns A `ggplot2` plot object.
#'
#' @export
#'
#' @concept plotting
#'
#' @examplesIf interactive()
#' \donttest{
#' # London example data
#' d <- LondonExample_crimes
#' s <- LondonExample_sources
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' # produce simple map
#' geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile,
#'                 breakPercent = seq(0, 50, 5), mapType = "hybrid",
#'                 crimeCol = "black", crimeCex = 2, sourceCol = "red", sourceCex = 2)
#' # calculate coallocation matrix and plot
#' geoPlotCoallocation(m)
#' }

geoPlotCoallocation <- function(mcmc, cols=NULL) {

  # default colours
  if (is.null(cols)) {
    cols <- viridis::viridis(100)
  }

  # get co-allocation matrix from raw MCMC output
  comat <- mcmc$coAllocation

  # produce data frame for ggplot
  n <- nrow(comat)
  df <- data.frame(x=as.vector(row(comat)), y=as.vector(col(comat)), z=as.vector(t(comat)))

  # produce plot
  gg <- ggplot2::ggplot(df) + ggplot2::geom_tile(ggplot2::aes(x=.data$x, y=.data$y, fill=.data$z)) + ggplot2::scale_fill_gradientn(colours=cols, name="Probability\nco-allocation") + ggplot2::coord_cartesian(xlim=c(0.5,n+0.5), ylim=c(0.5,n+0.5), expand=FALSE) + ggplot2::labs(x="observation", y="observation")

  gg
}

#------------------------------------------------
#' Unknown pleasures
#'
#' A frivolous alternative to [geoPlotMap()], this function takes the output of [geoMCMC()] and plots the resulting geoprofile in the style of the cover of Joy Division's 'Unknown pleasures' album.
#'
#' @param input_matrix The surface to plot, usually the object `$geoProfile` produced by [geoMCMC()].
#' @param nlines The number of lines (defaults to the correct number of 80).
#' @param paper_ref A text string, for example a reference to a paper.
#' @param bgcol Background colour
#' @param fgcol Foreground colour
#' @param wt line weight
#'
#' @returns Nothing (called for plotting)
#'
#' @export
#'
#' @concept plotting
#'
#' @examplesIf interactive()
#' # simulated data
#' sim <-rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude =
#' 51.5235505, alpha=10, sigma=1, tau=3)
#' d <- geoData(sim$longitude, sim $latitude)
#' s <- geoDataSource(sim$source_lon, sim$source_lat)
#' p <- geoParams(data = d, sigma_mean = 1.0, sigma_squared_shape = 2)
#' m <- geoMCMC(data = d, params = p)
#' unknownPleasures(m$geoProfile, paper_ref = "Rgeoprofile v2.1.0")

unknownPleasures <- function(input_matrix, paper_ref = NULL, nlines = 80, bgcol = "black", fgcol = "white", wt = 2) {

  orig_prof <- input_matrix
  citation <- paper_ref
  # extract other params
  ncols <- ncol(orig_prof)
  # functions
  expandMatrix <- function(mat,output_long,output_lat)
  {
    # define function expanding vector
    expandVector <- function(input_vec,output_length)
    {
      my_vec <- input_vec
      desired_length <- output_length
      new_vec <- rep(NA, desired_length)

      vec_ID <- seq(1,length(my_vec),length=desired_length)

      for(i in 1:length(new_vec))
      {
        ifelse(vec_ID[i] %% 1 == 0,
               new_vec[i] <- my_vec[floor(vec_ID[i])],
               new_vec[i] <- mean((1-vec_ID[i] %% 1) * my_vec[floor(vec_ID[i])] + (vec_ID[i] %% 1) * my_vec[ceiling(vec_ID[i])])
        )
      }
      return(new_vec)
    }
    mat1 <- apply(mat,2, function(x) expandVector(x, output_long))
    mat2 <- apply(mat1,1, function(x) expandVector(x, output_lat))
    return(t(mat2))
  }

  # reduce to manageable number of rows and columns!
  reduced_mat <- expandMatrix(orig_prof ,nlines, ncols)

  # scale so values fall between -0.5 and +0.5
  reduced_mat <- 1-reduced_mat/max(reduced_mat)-0.5

  # set y coordinates of lines
  yvals <- seq(0, 1,length = nlines)

  # plot
  oldPar <- graphics::par(bg = bgcol)
  on.exit(graphics::par(oldPar))

  plot(1:ncols, reduced_mat[nlines,]+yvals[nlines], type="l", ylim=c(-1,max(yvals)+0.5), axes=FALSE, xlab="", ylab="", col=fgcol)

  for (i in nlines:1) {
    graphics::polygon(c(min(reduced_mat[i,]), reduced_mat[i,]+yvals[i], min(reduced_mat[i,])), col=bgcol, border=bgcol)
    graphics::points(1:ncol(reduced_mat), reduced_mat[i,]+yvals[i], type="l", col=fgcol, lwd=wt)
  }
  graphics::text(0,-0.6,citation,adj=0,col=fgcol)
}
