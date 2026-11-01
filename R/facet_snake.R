#' Faceted Snake Plot
#'
#' Splits data by a grouping variable and draws side-by-side snake panels.
#' Works with \code{activity_snake}, \code{survey_snake}, \code{survey_sequence},
#' \code{sequential_dist}, or \code{line_snake}.
#'
#' @param data A data.frame to plot. It is split by \code{facet_var}; each
#'   subset, with the facet column removed, is passed to \code{FUN}.
#' @param facet_var Character. Column name in \code{data} to facet by.
#' @param FUN Function to call for each panel. Default \code{activity_snake}.
#'   It must accept a \code{title} argument, which receives the facet level.
#' @param ncol Integer. Number of columns in the facet grid. Default: number
#'   of facet levels (all in one row).
#' @param ... Additional arguments passed to \code{FUN}.
#'
#' @return Called for its side effect of drawing one panel per facet level.
#'   Invisibly returns an unnamed list with one element per facet level, in
#'   order of first appearance, each holding the value returned by \code{FUN}
#'   for that panel (a \code{snake_layout} list for \code{activity_snake}).
#'
#' @examples
#' set.seed(42)
#' d <- data.frame(
#'   group    = rep(c("A", "B"), each = 70),
#'   day      = rep(rep(c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
#'                  each = 10), 2),
#'   start    = round(runif(140, 360, 1400)),
#'   duration = 0
#' )
#' facet_snake(d, "group")
#'
#' @export
facet_snake <- function(data, facet_var, FUN = activity_snake,
                        ncol = NULL, ...) {
  stopifnot(is.data.frame(data), facet_var %in% names(data))

  groups <- unique(data[[facet_var]])
  n_groups <- length(groups)

  if (is.null(ncol)) ncol <- n_groups
  nrow_grid <- ceiling(n_groups / ncol)

  # Save and restore par

  op <- par(mfrow = c(nrow_grid, ncol), mar = c(0, 0, 0, 0), oma = c(0, 0, 0, 0))
  on.exit(par(op), add = TRUE)

  results <- lapply(groups, function(g) {
    subset_data <- data[data[[facet_var]] == g, ]
    # Drop the facet column to avoid confusion
    subset_data[[facet_var]] <- NULL
    FUN(subset_data, title = as.character(g), ...)
  })

  invisible(results)
}
