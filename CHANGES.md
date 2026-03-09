# Changes

### 2026-03-09 — rug style for sequence_snake, real data demos

- R/sequence_snake.R: Added `style = "rug"` parameter — thin colored ticks on light `#F5F5F5` band with `#EBEBEB` arcs/end caps. Added `rug_jitter` (vertical scatter), `rug_opacity`, `band_color`. New helpers: `draw_rug_band()`, `draw_rug_arc()`.
- tests/testthat/test-sequence_snake.R: Added 7 tests for rug style (basic, custom band_color, multi-row, large sequence, opacity, single row, jitter).
- tmp/demo_real.Rmd: Two real-data plots — index view (1000 events temporal order) and proportional view (sorted by frequency, distribution spread over 4 folds). Both use block style.
- Tests: 402 pass, 0 fail. R CMD check: 0 errors, 0 warnings, 1 NOTE (.github).

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
