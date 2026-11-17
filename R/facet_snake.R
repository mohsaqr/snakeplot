#' Draw one snake plot per group in a grid of panels
#'
#' @description
#' `facet_snake()` splits a data frame by a grouping column and draws one
#' snake plot per group in a grid of panels, so that groups such as
#' participants, classes or conditions can be compared in the same display.
#' Each panel is drawn by `FUN`, by default [activity_snake()], with the
#' group value as its title.
#'
#' The panels are independent plots: each is scaled to its own data. The
#' grid is set with `par(mfrow)` and the previous graphical parameters are
#' restored afterwards. It returns, invisibly, a list with the value `FUN`
#' returned for each panel.
#'
#' To draw groups of items (columns) rather than groups of rows, use the
#' `facet` argument of [survey_snake()].
#'
#' @param data A data frame. It is split by `facet_var`, and each part,
#'   without the grouping column, is passed to `FUN` as its first argument.
#' @param facet_var Name of the grouping column. Panels follow the order in
#'   which its values first appear.
#' @param FUN Plotting function for each panel (default [activity_snake()]).
#'   It must take the data as its first argument and accept a `title`
#'   argument; [line_snake()], [survey_snake()], [survey_sequence()] and
#'   [sequential_dist()] qualify.
#' @param ncol Number of panel columns. `NULL` (default) places all panels in
#'   one row.
#' @param ... Further arguments passed to `FUN`.
#'
#' @return The panels are drawn on the current device. The function returns,
#'   invisibly, an unnamed list with one element per group, in order of first
#'   appearance, holding the value `FUN` returned for that panel (a
#'   `snake_layout` object for [activity_snake()]).
#'
#' @seealso [activity_snake()], [survey_snake()] and its `facet` argument.
#'
#' @examples
#' # Two participants' prompts, one panel each
#' two <- subset(ema_beeps, id %in% c("xcVDLRQOwn", "6pig43CFyl"),
#'               select = c(id, start_time))
#' facet_snake(two, facet_var = "id", ncol = 1, show_total = FALSE)
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
