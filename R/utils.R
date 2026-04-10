# A more sensible name for cli::pluralize() which is basically glue::glue() with extra bits.
format_printstr <- function(..., .envir = parent.frame()) {
  cli::pluralize(..., .envir = .envir)
}

format_print_raster <- function(r, digits = 4) {
  format_printstr("{nrow(r)}x{ncol(r)} range = {round(min(r, na.rm = TRUE), digits)} - {round(max(r, na.rm = TRUE), digits)}")
}

#' Abort if any conditions is not TRUE
#'
#' @param condition Condition to evaluate when deciding when to error
#' @param message Message to include in the error.
#' @param call Environment within which to emit the error (defaults to caller environment).
#'
#' @keywords internal
#'
#' @returns Nothing
cli_stopifnot <- function(condition, message = "condition is not TRUE", call = rlang::caller_env()) {
  if (!all(condition)) {cli::cli_abort(c("x" = message), call = call)}
}

#' Abort if any condition is TRUE
#'
#' @param condition Condition to evaluate when deciding when to error
#' @param message Message to include in the error.
#' @param call Environment within which to emit the error (defaults to caller environment).
#'
#' @keywords internal
#'
#' @returns Nothing
cli_stopif <- function(condition, message = "condition is TRUE", call = rlang::caller_env()) {
  if (any(condition)) {cli::cli_abort(c("x" = message), call = call)}
}
