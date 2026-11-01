# snakeplot 0.3.2

* Documentation revision: corrected stale defaults (`survey_snake()`
  `tick_opacity`, `timeline_snake()` `band_gap`, `tick_color`, `tick_length`,
  `rows`), described the structure of every returned object, documented that
  `colors` uses only the first `length(levels)` colors and that
  `show_correlation` only acts with `arc_fill = "correlation"`, and fixed the
  `sequence_snake()` rug-style description (light gray band; `band_color` is
  currently unused).
* Examples, README and vignette use `snake_palette(name, n = 5)` instead of
  `snake_palettes$name`, so diverging palettes span the bundled 1-5 scales;
  the README uses 5-point level labels to match the data and lists
  `multi_snake()`. The vignette explains why to use each plot.

# snakeplot 0.3.0

* New `flow` parameter on all snake functions: `"snake"` (boustrophedon,
  default for most functions) or `"natural"` (all rows read left-to-right,
  default for `timeline_snake()` and `sequence_snake()`).
* New `multi_snake()` function for faceted multi-construct panels.
* New `sequence_snake()` function for categorical sequence visualization.
* New `timeline_snake()` function for state-transition timelines.
* Added Sonsoles Lopez-Pernas as package author.
* Bug fixes: survey_sequence arc gradient, survey_snake first end cap,
  multi_snake end cap polygon arguments, activity_snake arc labels.

# snakeplot 0.2.0

* 10 built-in color palettes via `snake_palettes` and `snake_palette()`:
  5 diverging (classic, earth, ocean, sunset, berry) and
  5 sequential (blues, greens, grays, warm, viridis).
* New `band_palette` parameter for custom band shading colors.
* New `bar_reverse` parameter to draw bars from highest level first.
* `ema_beeps` expanded from 500 sampled rows to full 11 474 beeps.
* Tick width capped for sparse daily data to prevent overly thick ticks.
* Dot size increased (cex 0.5 → 0.9) for better visibility.
* Vignette and README rewritten with `snake_palettes$ocean` examples.
* 100% test coverage (292 tests).

# snakeplot 0.1.0

* Initial release.
* `survey_snake()`: Survey response snake plots with distribution bars,
  tick marks, inter-item correlation arcs, faceting, and daily EMA support.
* `activity_snake()`: Daily activity timeline with event blocks and rug ticks.
* `survey_sequence()`: Stacked 100% horizontal bar plots in serpentine layout.
* `sequential_dist()`: Sequential palette variant of `survey_sequence()`.
* `line_snake()`: Continuous intensity line plot (experimental).
* `facet_snake()`: Generic multi-panel faceting wrapper.
* Three bundled datasets: `ema_emotions`, `student_survey`, `ema_beeps`.
