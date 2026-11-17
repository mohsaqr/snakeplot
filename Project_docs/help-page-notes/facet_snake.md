# Implementation notes removed from `?facet_snake` (2026-11-17)

Still true of R/facet_snake.R; kept for maintainers.

- Validation is a bare `stopifnot(is.data.frame(data), facet_var %in%
  names(data))`.
- Groups are `unique(data[[facet_var]])`; each subset is
  `data[data[[facet_var]] == g, ]` with the facet column set to `NULL`, then
  `FUN(subset, title = as.character(g), ...)`.
- Grid: `par(mfrow = c(ceiling(n / ncol), ncol), mar = 0, oma = 0)`,
  restored on exit.
- Panels are independent: each scales to its own data (e.g. time window,
  value range, item means).
- `survey_snake(facet = TRUE)` is a separate mechanism (column groups);
  see survey_snake.md.
