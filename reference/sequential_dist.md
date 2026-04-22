# Sequential Distribution Plot

Like
[`survey_sequence`](https://saqr.me/Snakeplot/reference/survey_sequence.md)
but uses a sequential (monochrome) palette instead of diverging colors.
Suitable for ordinal scales without a natural midpoint (e.g., "Never" to
"Always").

## Usage

``` r
sequential_dist(
  counts,
  labels = NULL,
  levels = NULL,
  hue = 210,
  band_height = 28,
  band_gap = 14,
  plot_width = 500,
  colors = NULL,
  show_percent = TRUE,
  min_segment = 34,
  arc_style = c("gradient", "neutral"),
  arc_opacity = 0.85,
  sort_by = c("none", "mean", "net"),
  shadow = TRUE,
  show_legend = TRUE,
  label_color = "#333333",
  label_size = 0.85,
  label_align = "left",
  reverse_rtl = FALSE,
  start_from = c("left", "right"),
  flow = c("snake", "natural"),
  title = NULL,
  margin = c(top = 30, right = 10, bottom = 55, left = 100),
  background = "white"
)
```

## Arguments

- counts:

  Numeric matrix of response counts (rows=items, cols=levels).

- labels:

  Character vector of item labels.

- levels:

  Character vector of level labels.

- hue:

  Numeric 0-360. Base hue for the sequential palette (default 210 =
  blue).

- band_height:

  Numeric (default 28).

- band_gap:

  Numeric (default 14).

- plot_width:

  Numeric (default 500).

- colors:

  Character vector of segment colors. Default: diverging palette.

- show_percent:

  Logical. Show percentages inside segments (default TRUE).

- min_segment:

  Numeric. Hide label if segment narrower than this (default 34).

- arc_style:

  Character: "gradient" or "neutral" (default "gradient").

- arc_opacity:

  Numeric 0-1 (default 0.5).

- sort_by:

  Character: "none", "mean", "net" (default "none").

- shadow:

  Logical (default TRUE).

- show_legend:

  Logical (default TRUE).

- label_color:

  Character (default "#333333").

- label_size:

  Numeric (default 0.85).

- label_align:

  Character. Label alignment: "left" (default), "right", or "direction"
  (follows band reading direction).

- reverse_rtl:

  Logical. Reverse segment order on right-to-left bands so the visual
  reading direction mirrors the data order (default FALSE).

- start_from:

  Character: "left" (default) or "right". Which side the first band
  starts from.

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
counts <- matrix(c(
  15, 25, 60, 80, 45,
  10, 20, 50, 90, 55,
  20, 30, 65, 70, 40
), nrow = 3, byrow = TRUE)
labels <- c("Behavior A", "Behavior B", "Behavior C")
levs <- c("Never", "Rarely", "Sometimes", "Often", "Always")
sequential_dist(counts, labels, levs, hue = 160)

```
