# Implementation notes removed from `?sequential_dist` (2026-11-17)

Still true of R/survey_sequence.R and R/colors.R; kept for maintainers.

- **palette**: `sequential_palette(k, hue)` =
  `hsv(hue / 360, s = seq(0.15, 0.75, length = k), v = seq(0.95, 0.35,
  length = k))`, light to dark.
- **delegation**: input is coerced once with `coerce_survey_input()` and the
  resulting counts, labels and levels are passed to `survey_sequence()`.
- **arc_opacity** default is 0.85 here and 0.5 in `survey_sequence()`.
