# Line Snake Plot (Experimental)

A continuous intensity line winding through a serpentine layout. Each
band represents a time segment (e.g., a day); the line's vertical
position within the band encodes a continuous value (e.g., foot traffic,
CPU usage). The line smoothly curves through U-turn arcs between bands.

## Usage

``` r
line_snake(
  data,
  band_height = 40,
  band_gap = 18,
  day_start = 0,
  day_end = 1440,
  plot_width = 500,
  line_color = "#e74c3c",
  line_width = 1.5,
  fill_color = NULL,
  fill_opacity = 0.3,
  band_color = "#2d2d3d",
  arc_color = "#1a1a2e",
  band_opacity = 0.9,
  arc_opacity = 0.85,
  show_grid = TRUE,
  shadow = TRUE,
  label_color = "#cccccc",
  label_size = 0.85,
  orientation = c("horizontal", "vertical"),
  start_from = c("left", "right"),
  flow = c("snake", "natural"),
  title = NULL,
  margin = c(top = 30, right = 10, bottom = 50, left = 80),
  background = "white"
)
```

## Arguments

- data:

  A data.frame with columns:

  time

  :   Numeric (minutes from midnight) or POSIXct timestamps.

  value

  :   Numeric intensity value.

  day

  :   (Optional) Day labels. Auto-detected from timestamps if absent.

  Alternatively, a numeric vector (interpreted as evenly-spaced values
  for a single band).

- band_height:

  Numeric (default 40).

- band_gap:

  Numeric (default 18).

- day_start:

  Numeric, minutes from midnight (default 0).

- day_end:

  Numeric, minutes from midnight (default 1440).

- plot_width:

  Numeric (default 500).

- line_color:

  Character (default "#e74c3c").

- line_width:

  Numeric (default 1.5).

- fill_color:

  Optional fill color below the line (default NULL = no fill).

- fill_opacity:

  Numeric 0-1 (default 0.3).

- band_color:

  Character (default "#2d2d3d").

- arc_color:

  Character (default "#1a1a2e").

- band_opacity:

  Numeric (default 0.90).

- arc_opacity:

  Numeric (default 0.85).

- show_grid:

  Logical (default TRUE).

- shadow:

  Logical (default TRUE).

- label_color:

  Character (default "#cccccc").

- label_size:

  Numeric (default 0.85).

- orientation:

  Character, "horizontal" or "vertical" (default "horizontal").

- start_from:

  Character, "left" or "right" (default "left").

- flow:

  Character, `"snake"` (default) or `"natural"`. `"snake"` uses
  alternating boustrophedon direction; `"natural"` reads all bands in
  the same direction.

- title:

  Optional title.

- margin:

  Named numeric vector.

- background:

  Background color.

## Value

Invisible `snake_layout` object.

## Examples

``` r
set.seed(42)
hours <- seq(0, 1440, by = 10)
d <- data.frame(
  day = rep(c("Mon", "Tue", "Wed"), each = length(hours)),
  time = rep(hours, 3),
  value = sin(rep(hours, 3) / 1440 * 4 * pi) * 50 + 50 +
          rnorm(3 * length(hours), 0, 8)
)
line_snake(d, fill_color = "#e74c3c")

```
