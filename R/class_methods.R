#' @export
print.gp.params.model <- function(x, ..., digits = 4) {
  outstr <- paste(
    format_printstr("Sigma: mean = {round(x$sigma_mean, digits)}, var = {round(x$sigma_var, digits)}, squared_shape = {round(x$sigma_squared_shape, digits)}, squared_rate = {round(x$sigma_squared_rate, digits)}\n"),
    format_printstr("Prior: Mean longitude = {round(x$priorMean_longitude, digits)}\u00B0, Mean latitude = {round(x$priorMean_latitude, digits)}\u00B0\n"),
    format_printstr("Tau: {round(x$tau, digits)}\n"),
    format_printstr("Alpha: shape = {round(x$alpha_shape, digits)}, rate = {round(x$alpha_rate, digits)}\n")
  , sep = "\n")
  cat(outstr)
  invisible(x)
}

#' @export
print.gp.params.MCMC <- function(x, ...) {
  outstr <- format_printstr("Burnin: {x$chains} chain{?s} @ {x$burnin} iteration{?s} (print every {x$burnin_printConsole})\nSampling: {x$samples} iteration{?s} (print every {x$samples_printConsole})\n")
  cat(outstr)
  invisible(x)
}

#' @export
print.gp.params.output <- function(x, ..., digits = 4) {
  outstr <- format_printstr("Longitude range: {round(x$longitude_minMax[1], digits)}\u00B0:{round(x$longitude_minMax[2], digits)}\u00B0\nLatitude range:  {round(x$latitude_minMax[1], digits)}\u00B0:{round(x$latitude_minMax[2], digits)}\u00B0\nCells: {x$longitude_cells}x{x$latitude_cells}\n")
  cat(outstr)
  invisible(x)
}

#' @export
print.gp.params <- function(x, ..., digits = 4) {
  cat(paste0("Geoprofile Parameters (to ", digits," dp):\n\n=== Model ===\n"))
  print(x$model, digits = digits)
  cat("\n\n=== MCMC ===\n")
  print(x$MCMC)
  cat("\n\n=== Output ===\n")
  print(x$output, digits = digits)
  invisible(x)
}

#' @export
print.gp.data <- function(x, ...) {
  if (attr(x, "is.source")) {
    cat("Geoprofile sources\n")
  } else {
    cat("Geoprofile data\n")
  }
  print.data.frame(x)
  invisible(x)
}

#' @export
print.gp.profile <- function(x, ..., digits = 6) {
  cat("----- Geoprofile -----\n")
  cat(format_printstr("\n\nMethod: {x$method}"))
  cat(format_printstr("\n\nPrint dp: {digits}"))
  cat("\n\n=== Surfaces ===\n")
  cat(paste("\nPrior surface:", format_print_raster(x$priorSurface, 15)))
  cat(paste("\nPosterior surface:", format_print_raster(x$posteriorSurface, digits)))
  cat(paste("\ngeoProfile:", format_print_raster(x$geoProfile, digits)))
  cat("\n\n=== Other information ===\n")
  cat(format_printstr("\n\nMidpoints (longitude): {length(x$midpoints_longitude)} row{?s}, range = {round(min(x$midpoints_longitude, na.rm = TRUE), digits)}\u00B0 - {round(max(x$midpoints_longitude, na.rm = TRUE), digits)}\u00B0"))
  cat(format_printstr("\n\nMidpoints (latitude): {length(x$midpoints_latitude)} row{?s}, range = {round(min(x$midpoints_latitude, na.rm = TRUE), digits)}\u00B0 - {round(max(x$midpoints_latitude, na.rm = TRUE), digits)}\u00B0"))
  cat(format_printstr("\n\nSigma: {length(x$sigma)} entr{?y/ies}, range = {round(min(x$sigma, na.rm = TRUE), digits)} - {round(max(x$sigma, na.rm = TRUE), digits)}"))
  cat(format_printstr("\n\nAlpha: {length(x$alpha)} entr{?y/ies}, range = {round(min(x$alpha, na.rm = TRUE), digits)} - {round(max(x$alpha, na.rm = TRUE), digits)}"))
  cat(format_printstr("\n\nAllocation: {ncol(x$allocation)} group{?s}"))
  cat(format_printstr("\n\nBest grouping:"))
  print(table(x$bestGrouping))
  cat(format_printstr("\nData: {nrow(x$data)} row{?s}"))
  if (!is.null(x$sources)) {
    cat(format_printstr("\n\nSources: {nrow(x$sources)} row{?s}"))
  } else {
    cat(format_printstr("\n\nSources not present"))
  }
  cat("\n\n----- Params -----\n\n")
  print(x$params, digits = digits)
  invisible(x)
}
