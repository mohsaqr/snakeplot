# Implementation notes removed from `?timeline_snake` (2026-11-17)

Still true of R/timeline_snake.R; kept for maintainers.

- **data frame input**: columns are taken by position (1 state, 2 start,
  3 end); at least three columns are required (`stopifnot`). Dates go
  through `as.character()` then `parse_time()`; `"YYYY-MM"` is padded to
  `"YYYY-MM-01"`. One block per month from start to end inclusive
  (`seq.Date(by = "month")`).
- **automatic labels** (only when the argument is `NULL`):
  `transition_labels` = `format(start, "%b %Y")` of every phase after the
  first; `rows` = `max(2, round(total_months / 20))`; `band_labels` = year
  (`"%Y"`) of the month at the centre of each band, centre index
  `round((k - 0.5) * total / rows)`.
- **vector input**: drawn as is by `sequence_snake()`; `rows` then defaults
  to `ceiling(n / 11)`.
- **colours**: `NULL` gives `colorRampPalette(c("#4FC3F7", "#039BE5",
  "#0277BD", "#01579B", "#1A237E"))(n)` named by the states in order (data
  frame: unique first column; else `states`; else unique values).
- **not exposed** from `sequence_snake()`: `style`, `band_color`,
  `rug_opacity`, `jitter` (block style only).
- **band_gap = 30**: wider than sequence_snake's 18 to leave room for the
  year labels between bands.
- **return**: `invisible(NULL)` (the value of `sequence_snake()`).
- **time zone (found 2026-11-17, not fixed)**: `parse_time()` returns
  POSIXct at local midnight (`tzone = ""`), and `as.Date()` on it converts
  in UTC. In a time zone east of UTC (checked in Europe/Helsinki, R 4.6.2)
  `"2016-10"` becomes 2016-09-30, so every phase starts and ends one month
  early and the automatic transition labels read e.g. `"Sep 2016"` for a
  phase starting October 2016. Under `TZ=UTC` the dates are correct.
