# Implementation notes removed from `?survey_snake` (2026-11-17)

Still true of R/survey_snake.R, R/utils.R and R/colors.R; kept for
maintainers.

- **raw vs counts detection** (`coerce_survey_input()`): a matrix is always
  counts. A data frame is raw responses when every column is a factor,
  character, or numeric whole-number column with at most 20 distinct
  non-missing values, *and* `nrow > 2 * max(distinct values per column)`.
  Otherwise it is a counts data frame (`as.matrix()`). Small raw data sets
  (e.g. 8 respondents on a 5-point scale) are therefore read as counts.
- **raw tabulation**: levels are `levels` if given (they must match the
  data values), else the levels of the first factor column, else the sorted
  distinct values. A message reports the number of NA responses excluded.
  Labels default to `"<column> (n=<responses>)"`. A respondent x item matrix
  of level positions (`scores`) is kept for correlations.
- **labels/levels for counts**: row names and column names of the table.
- **level_labels**: an unnamed vector of the same length as `levels`
  replaces them positionally; otherwise named entries replace matching
  levels and unmatched names are ignored.
- **colours**: default `diverging_palette(k)`: anchors `#d4502a #e8967a
  #b8b8b8 #7ab0d4 #2c6faa` (returned as is for k = 5, else
  `colorRampPalette`). `colors` is indexed by level position; only the first
  k are used.
- **band shade**: `shade_by_value(mean, 1, k)`: 101-step ramp of
  `band_palette` (default `#5c2a0e` -> `#3a3a5c`). `shade_band` is accepted
  but **not used**: the band is always shaded (the old help said it toggled
  shading; the new page says it has no effect).
- **item statistics**: means are count-weighted means of level positions
  1..k; medians the first level with cumulative proportion >= 0.5. Net
  score for k >= 4: `mid = ceiling(k / 2)`; levels `1..mid-1` negative,
  `mid+1..k` positive; `(pos - neg) / n`. For k < 4 the mean is used.
- **tick layout (line/dot)**: each non-empty level gets a zone of width
  proportional to its count; zones are separated by `level_gap`; positions
  within a zone are sorted `runif()` draws. Tick width
  `min(0.7 * usable width / n, 0.008 * band length)`; lines span 92% of the
  band height. Dots: `pch = 16`, cex 0.9, vertical jitter
  `runif(-jitter_range, jitter_range) * band_height / 2`.
- **color_mode = "individual"**: `hsv(seq(0, 1, length = n + 1)[1:n], 0.7,
  0.8)` over ticks in drawing order.
- **bar mode**: stacked segments, white bold percentages (cex 0.65) in
  segments wider than 5% of the band.
- **seed**: `set.seed(seed)` is called before drawing ticks; the caller's
  `.Random.seed` is not restored (open issue in HANDOFF.md).
- **arc_fill = "correlation"**: r from `.adjacent_correlations()` on
  `scores` reordered to band order, pairwise-complete respondents, NA when
  n < 3 or either item constant. Tint: `arc_color` for r >= 0, RGB
  complement `255 - rgb` for r < 0; darkness
  `frac = 0.85 * |r| + 0.15 * relative rank of |r|` (0.5 when all |r|
  equal), mixed with white. NA r: `arc_color` at `arc_opacity`. Labels
  `"r=%.2f"`, cex 0.6, bold, `#6a9ec0` (positive) or `#c0392b` (negative).
  End caps `arc_color` at `arc_opacity`.
- **arc_fill = "none"**: upper half of the arc in the shade of the upper
  band, lower half in the lower band's shade, full opacity. `"mean_prev"`
  and `"blend"` use `arc_opacity`; blend is a 50/50 RGB mean.
- **ESM mode (`var` + `day`)**: requires a data frame containing both
  columns (bare `stopifnot`). Days are the sorted unique values with a
  non-missing response; bands are labelled `"Day 1"`, ... by rank, not by
  the day value. Levels are the sorted distinct response values. `title`
  defaults to `var`. With `timestamp`, time of day is the fraction of 24 h
  since local midnight in the column's time zone (non-POSIXct columns go
  through `as.POSIXct()`); ticks are placed at that fraction of the band
  length (the full 24 h, not a window), width `0.6 * band length / n`;
  guide lines at 6, 12 and 18 h with `"6h"`, `"12h"`, `"18h"` labels above
  the first band. `tick_shape = "bar"` ignores the times. Without
  `timestamp` the ordinary zone layout is used.
- **facet = TRUE**: prefixes are column names with trailing digits removed
  (`LOC1` -> `LOC`); if that leaves every column in its own group, the part
  before the first `_` or `.` is used. Item labels drop the prefix and one
  following `_` or `.`. Panels use `par(mfrow)` with `facet_ncol` columns
  (capped at the number of groups) and a fixed margin `c(top = 30, right =
  10, bottom = 30, left = 100)`; per-panel legends are suppressed and one
  shared legend is drawn only if the grid has a spare cell. Each panel is
  drawn by re-evaluating `match.call()` in `parent.frame(2L)`, so arguments
  bound to local variables of a calling function are not found (known bug:
  `survey_snake(facet = TRUE)` fails inside a function).
- **legend**: one tick per level; `"Item r (arc)"` swatch in correlation
  mode; `"Low -> High mean"` swatch shows the band shade at the scale
  midpoint of a 1-5 range regardless of k. The legend adds 15 to the
  bottom margin; a title adds 18 to the top margin.
- **no `orientation` argument**: always horizontal.
