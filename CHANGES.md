# Changes

### 2026-03-09 — vignette overhaul, 5-point scale, label overlap fixes

- data/: All three datasets rescaled from 1-7 to 1-5 Likert (linear transform). data-raw/esm_survey.R updated with `rescale_7to5()`.
- R/data.R: Documentation updated to reflect 1-5 scale.
- R/sequence_snake.R: State labels skip drawing when run is too narrow (`strwidth` check). Transition labels moved to bottom edge of band (28% from bottom, italic, semi-transparent). Band year labels centered in gap between bands.
- R/timeline_snake.R: Default `band_gap` increased from 18 to 30 to fit year labels between bands.
- vignettes/survey-snake-plots.Rmd: Overhauled — removed short non-snake examples, 5-point labels, varied palettes (sunset/berry/viridis/earth), dpi=150, proportional sizing.
- Tests: 470 pass, 0 fail.

### 2026-03-09 — smart input coercion, parse_time(), flexible formats

- R/utils.R: Added `parse_time()` — robust timestamp parser (40+ formats, Unix timestamps, auto-unit detection, year validation). Inspired by tna's `parse_time()`.
- R/utils.R: Added `coerce_sequence_input()` — accepts vectors, data.frames (auto-extract first char/factor column), lists, comma-separated strings. NAs dropped with warning.
- R/utils.R: Added `find_column()` — case-insensitive column name matching.
- R/utils.R: Enhanced `coerce_activity_input()` — accepts character/numeric timestamp vectors via `parse_time()`, case-insensitive column matching, aliased column names (date→day, begin→start, dur→duration, activity→label), auto-detects POSIXct columns.
- R/utils.R: Enhanced `coerce_survey_input()` — auto-labels from matrix rownames/colnames, NA handling with message, improved heuristic for raw vs counts detection.
- R/utils.R: Enhanced `validate_activity_data()` — case-insensitive column name resolution.
- R/sequence_snake.R: Uses `coerce_sequence_input()` for flexible input (string, data.frame, list, NA handling). Updated roxygen docs.
- R/timeline_snake.R: `to_date()` uses `parse_time()` for flexible date parsing (handles month names, DD/MM/YYYY, Unix timestamps, POSIXt).
- R/snakeplot-package.R: Added `na.omit` to stats imports.
- tests/testthat/test-utils.R: Added 38 tests for parse_time (20), coerce_sequence_input (10), find_column (5), enhanced coerce_activity_input (5), enhanced coerce_survey_input (3), case-insensitive validate_activity_data (1).
- tests/testthat/test-sequence_snake.R: Added 6 integration tests for flexible input formats + updated NA test.
- Tests: 470 pass, 0 fail. R CMD check: 0 errors, 0 warnings, 2 NOTEs.

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
