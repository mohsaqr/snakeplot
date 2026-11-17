# Implementation notes removed from `?line_snake` (2026-11-17)

Still true of R/line_snake.R; kept for maintainers.

- **POSIXct `time`**: converted to minutes after midnight from hour and
  minute (seconds dropped); `day` is overwritten with `format(time, "%a")`,
  so observations on the same weekday in different weeks share a band. Any
  supplied `day` column is replaced in this case.
- **numeric vector input**: one band labelled `"Series"`, times spread
  evenly over `day_start`..`day_end`.
- **value scale**: shared by all bands, from the overall minimum to the
  overall maximum (`na.rm = TRUE`); a constant series uses a range of 1.
  High values are drawn near the top of the band.
- **bands with fewer than two observations** draw no line.
- **within-band order**: rows are sorted by `time` before drawing.
- **U-turn segments**: the line drops vertically from the last value of a
  band to the inner edge of the arc, follows the inner semicircle (40
  points), then rises to the first value of the next band. The arc segment
  does not encode values.
- **grid**: fixed colour `rgba(255,255,255,0.15)`, `lwd = 0.3`, every hour.
  Hour axis labels every 3 hours.
- **orientation = "vertical"**: fails with
  `'names' attribute [9] must be the same length as the vector [0]`
  because the hour axis uses `plot_area$x_left`, which the vertical layout
  does not have; the grid and line code are also written for horizontal
  bands only. The help page states that only horizontal is supported.
- **Experimental status**: the old title carried "(Experimental)"; the
  help page keeps one sentence saying the interface may change.
