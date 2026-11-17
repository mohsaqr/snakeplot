# Changelog

## snakeplot 0.3.4

### Changes

- The correlation arcs of `survey_snake(arc_fill = "correlation")` are
  now computed from respondent-level rows: Pearson r between adjacent
  items across the respondents who answered both (pairwise-complete),
  `NA` when fewer than three did or either item is constant among them.
  Previously they were computed from the response counts.
- `arc_fill = "correlation"` now requires raw responses (one row per
  respondent, one column per item). Counts input and the `var`/`day`
  (ESM) mode, which do not identify respondents, raise an error of class
  `snakeplot_no_respondent_data`.
- The returned `snake_layout` holds `correlations`, a data frame with
  one row per U-turn (`from`, `to`, `r`, `n`), so the printed values can
  be checked and reported.
- The legend entry for the arcs reads “Item r (arc)” and uses
  `arc_color`.
- Dates of date-times are taken in the time zone of the data.
  [`as.Date()`](https://rdrr.io/r/base/as.Date.html) converted through
  UTC, so in time zones east of UTC
  [`timeline_snake()`](https://pak.dynasite.org/Snakeplot/reference/timeline_snake.md)
  labelled each phase one month early (a phase starting 2016-10 as “Sep
  2016”), and the `timestamp` mode of
  [`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md)
  measured the time of day of a prompt answered shortly after midnight
  from the previous midnight, placing its tick beyond the end of the
  band.

### Documentation

- Help pages rewritten: each opens with what the display represents and
  when to use it, with cross-references, references and examples on the
  bundled data.
- New vignettes “Serpentine plots” and “Survey and experience sampling
  responses”; guides on sequences and timelines, daily activity, and
  palettes and layout; case studies on the bundled experience sampling
  data. The README is generated from `README.Rmd`.

### Packaging

- README figures in `man/figures/` are now included in the package; a
  `.Rbuildignore` pattern for `.png` files had excluded them, so the
  README showed broken images on CRAN.

## snakeplot 0.3.2

- Documentation revision: corrected stale defaults
  ([`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md)
  `tick_opacity`,
  [`timeline_snake()`](https://pak.dynasite.org/Snakeplot/reference/timeline_snake.md)
  `band_gap`, `tick_color`, `tick_length`, `rows`), described the
  structure of every returned object, documented that `colors` uses only
  the first `length(levels)` colors and that `show_correlation` only
  acts with `arc_fill = "correlation"`, and fixed the
  [`sequence_snake()`](https://pak.dynasite.org/Snakeplot/reference/sequence_snake.md)
  rug-style description (light gray band; `band_color` is currently
  unused).
- Examples, README and vignette use `snake_palette(name, n = 5)` instead
  of `snake_palettes$name`, so diverging palettes span the bundled 1-5
  scales; the README uses 5-point level labels to match the data and
  lists
  [`multi_snake()`](https://pak.dynasite.org/Snakeplot/reference/multi_snake.md).
  The vignette explains why to use each plot.

## snakeplot 0.3.0

CRAN release: 2026-03-16

- New `flow` parameter on all snake functions: `"snake"` (boustrophedon,
  default for most functions) or `"natural"` (all rows read
  left-to-right, default for
  [`timeline_snake()`](https://pak.dynasite.org/Snakeplot/reference/timeline_snake.md)
  and
  [`sequence_snake()`](https://pak.dynasite.org/Snakeplot/reference/sequence_snake.md)).
- New
  [`multi_snake()`](https://pak.dynasite.org/Snakeplot/reference/multi_snake.md)
  function for faceted multi-construct panels.
- New
  [`sequence_snake()`](https://pak.dynasite.org/Snakeplot/reference/sequence_snake.md)
  function for categorical sequence visualization.
- New
  [`timeline_snake()`](https://pak.dynasite.org/Snakeplot/reference/timeline_snake.md)
  function for state-transition timelines.
- Added Sonsoles Lopez-Pernas as package author.
- Bug fixes: survey_sequence arc gradient, survey_snake first end cap,
  multi_snake end cap polygon arguments, activity_snake arc labels.

## snakeplot 0.2.0

- 10 built-in color palettes via `snake_palettes` and
  [`snake_palette()`](https://pak.dynasite.org/Snakeplot/reference/snake_palette.md):
  5 diverging (classic, earth, ocean, sunset, berry) and 5 sequential
  (blues, greens, grays, warm, viridis).
- New `band_palette` parameter for custom band shading colors.
- New `bar_reverse` parameter to draw bars from highest level first.
- `ema_beeps` expanded from 500 sampled rows to full 11 474 beeps.
- Tick width capped for sparse daily data to prevent overly thick ticks.
- Dot size increased (cex 0.5 → 0.9) for better visibility.
- Vignette and README rewritten with `snake_palettes$ocean` examples.
- 100% test coverage (292 tests).

## snakeplot 0.1.0

- Initial release.
- [`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md):
  Survey response snake plots with distribution bars, tick marks,
  inter-item correlation arcs, faceting, and daily EMA support.
- [`activity_snake()`](https://pak.dynasite.org/Snakeplot/reference/activity_snake.md):
  Daily activity timeline with event blocks and rug ticks.
- [`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md):
  Stacked 100% horizontal bar plots in serpentine layout.
- [`sequential_dist()`](https://pak.dynasite.org/Snakeplot/reference/sequential_dist.md):
  Sequential palette variant of
  [`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md).
- [`line_snake()`](https://pak.dynasite.org/Snakeplot/reference/line_snake.md):
  Continuous intensity line plot (experimental).
- [`facet_snake()`](https://pak.dynasite.org/Snakeplot/reference/facet_snake.md):
  Generic multi-panel faceting wrapper.
- Three bundled datasets: `ema_emotions`, `student_survey`, `ema_beeps`.
