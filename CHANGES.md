# Changes

### 2026-03-08 — arc_fill, facet, ESM, bar ticks, level_labels

- R/layout.R: Added `half_arc_polygon()` for splitting arcs into upper/lower halves (two-tone fill).
- R/colors.R: Added `blend_colors()` for 50/50 RGB averaging of two colors.
- R/survey_snake.R: Major feature additions:
  - `arc_fill` parameter with 4 modes: "none" (two-tone), "correlation" (tint by r), "mean_prev" (upper shade), "blend" (RGB average)
  - `tick_shape = "bar"` for stacked proportional distribution bars with % labels
  - `facet` parameter for auto-grouping columns by name prefix into a `par(mfrow)` grid with shared legend
  - `facet_ncol` for controlling grid columns
  - `level_labels` for mapping raw level values to display labels (legend + text)
  - `legend_cex` for legend text sizing
  - `label_cex` for band label sizing
  - ESM auto-pivot via `var`, `day`, `timestamp` parameters — one band per day, ticks positioned by time-of-day
  - Correlation arc coloring uses `arc_color` with blended absolute+relative intensity
  - Mean/median markers scaled to `band_height * 0.38`
- tests/testthat/test-survey_snake.R: Added 20 tests for arc_fill, bar ticks, ESM pivot, facet, level_labels, legend_cex, sort_by
- tests/testthat/test-colors.R: Added 4 tests for blend_colors()
- tests/testthat/test-layout.R: Added 6 tests for half_arc_polygon()
- Tests: 232 pass, 0 fail
