# Implementation notes removed from `?activity_snake` (2026-11-17)

Material cut from the help page when it was rewritten for readers. It is
still true of the code (R/activity_snake.R, R/utils.R); it is kept here for
maintainers.

- **data, input detection** (`coerce_activity_input()`):
  - A bare POSIXct vector becomes `data.frame(timestamp = data)`.
  - A character or numeric *vector* is passed to `parse_time()`; if that
    parses, it is used as timestamps. A numeric vector is therefore read as
    Unix time (seconds, milliseconds or microseconds chosen from the median
    magnitude: > 1e15 microseconds, > 1e12 milliseconds, else seconds).
  - Data frame columns are renamed case-insensitively to canonical names
    when the canonical name is absent: `timestamp` <- time, datetime,
    date_time; `start` <- start_time, begin; `end` <- end_time, stop;
    `day` <- date, weekday; `duration` <- dur, length; `label` <- name,
    activity, event, category.
  - If neither `timestamp` nor `start` exists, the first POSIXct column is
    renamed `timestamp`.
  - Character `timestamp`/`start`/`end` columns are parsed with
    `parse_time()` (about 50 strptime formats, adapted from tna's
    `parse_time()`; a format is accepted only if all parsed years lie in
    1900-2100; `YYYY-MM` is padded to `YYYY-MM-01`). Numeric `start`
    columns are never parsed: they are minutes after midnight.
- **timestamps -> day/start/duration** (`prepare_timestamps()`): day labels
  by `format(ts, day_format)`, levels in order of first appearance; start in
  minutes after midnight including seconds; duration from `end - start`
  (minutes) if `end` is POSIXct, else a numeric `duration` column, else 0.
- **label column**: carried through but not drawn.
- **window widening**: `day_start`/`day_end` are widened to whole hours
  covering all events only when the *original* input was a POSIXct vector
  or had a POSIXct column literally named `timestamp` or `start`. A column
  named e.g. `start_time` is renamed and converted, but the window is not
  widened (the check runs before renaming).
- **validation**: `start` and `duration` numeric, `duration >= 0`,
  positive `band_height`/`band_gap`/`plot_width`, `day_start < day_end`
  (bare `stopifnot`). Errors are unclassed.
- **vertical defaults**: when `orientation = "vertical"`, arguments still at
  their default values are replaced: `margin` -> `c(top = 55, right = 5,
  bottom = 5, left = 35)`, `plot_width` 500 -> 120, `band_height` 28 -> 22,
  `band_gap` 18 -> 8. The test is equality with the default value.
- **title**: adds 18 plot units to the top margin.
- **drawing constants**: gridlines every hour, `lwd = 0.4`; hour axis
  labels every 3 hours (`#888888`, cex 0.7; 0.6 on the vertical layout, at
  the left); arc labels `#666666`, cex 0.55; event widths
  `max(tick_width, duration / window * band length)`, clipped to the band.
- **arc labels**: with `flow = "snake"` every U-turn is labelled with
  `day_end` (midnight by default). With `flow = "natural"` each U-turn shows
  the time at that edge: with `start_from = "left"` right/bottom arcs show
  `day_end` and left/top arcs `day_start`; reversed for `"right"`.
- **day label text**: `"(n)"` when `show_count`, then the summed duration
  as `"Xh Ym"`/`"Ym"` when `show_total`. With instantaneous events the total
  is `"0m"`.
- **legend items** may have `type = "tick"` (vertical line) or
  `"gradient"` (wider swatch); default is a filled square.
