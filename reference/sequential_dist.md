# Plot unipolar survey responses as a serpentine of single-hue stacked bars

`sequential_dist()` draws the survey sequence plot of
[`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md),
one 100% stacked bar per item along a serpentine, with a light-to-dark
palette of a single hue, so that darker segments stand for higher
levels. It is meant for rating scales with no neutral midpoint:
frequency scales from "Never" to "Always", or intensity scales from "Not
at all" to "Extremely". For such scales a diverging palette suggests a
midpoint the scale does not have.

Input, sorting, labels and layout options are those of
[`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md);
`hue` sets the color of the palette. It returns the value of
[`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md),
a `snake_layout` object, invisibly. For bipolar (agree-disagree) scales
use
[`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md);
to show individual responses use
[`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md).

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

  Responses: a data frame of raw responses (one row per respondent, one
  column per item), a numeric matrix of counts (items in rows, response
  levels in columns), or a data frame of counts. A data frame is read as
  raw responses when its columns hold few distinct whole-number or
  categorical values relative to its number of rows.

- labels:

  Item labels, one per item. `NULL` (default) uses the row names of a
  count table, or, for raw responses, the column names with the number
  of responses.

- levels:

  Response levels in scale order. `NULL` (default) uses the column names
  of a count table, or, for raw responses, the factor levels or the
  sorted distinct values. For raw responses the levels must match the
  values in the data.

- hue:

  Hue of the palette in degrees, 0-360 (default 210, blue).

- band_height:

  Height of each band in plot units (default 28).

- band_gap:

  Gap between bands in plot units (default 14).

- plot_width:

  Length of each band in plot units (default 500).

- colors:

  One color per response level, in scale order. `NULL` (default) uses a
  light-to-dark palette of `hue`.

- show_percent:

  Print percentages inside the segments (default `TRUE`).

- min_segment:

  Minimum segment width, in plot units, for a percentage to be printed
  (default 34).

- arc_style:

  `"gradient"` (default) colors each U-turn midway between the levels at
  its two ends; `"neutral"` draws it grey.

- arc_opacity:

  Opacity of the U-turns, between 0 and 1 (default 0.85).

- sort_by:

  Order of the items: `"none"` (default, input order), `"mean"`
  (increasing item mean) or `"net"` (increasing share of responses above
  the middle level minus share below; the mean for scales with fewer
  than four levels).

- shadow:

  Draw drop shadows (default `TRUE`).

- show_legend:

  Draw the legend (default `TRUE`).

- label_color, label_size:

  Color and size multiplier of the item labels (defaults `"#333333"` and
  0.85).

- label_align:

  Alignment of the item labels: `"left"` (default), `"right"`, or
  `"direction"` to follow each band's reading direction.

- reverse_rtl:

  Reverse the order of levels on bands that read right to left, so every
  band starts with the lowest level in its reading direction (default
  `FALSE`: lowest level on the left of every band).

- start_from:

  Side on which the first band starts: `"left"` (default) or `"right"`.

- flow:

  `"snake"` (default): bands alternate direction. `"natural"`: every
  band reads in the same direction.

- title:

  Plot title, or `NULL` (default) for none.

- margin:

  Named numeric vector of `top`, `right`, `bottom` and `left` margins in
  plot units (default
  `c(top = 30, right = 10, bottom = 55, left = 100)`).

- background:

  Background color (default `"white"`).

## Value

The value of
[`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md):
the plot is drawn on the current device and an object of class
`snake_layout` is returned invisibly.

## References

Heiberger, R. M., & Robbins, N. B. (2014). Design of diverging stacked
bar charts for Likert scales and other applications. *Journal of
Statistical Software*, 57(5), 1-32.
[doi:10.18637/jss.v057.i05](https://doi.org/10.18637/jss.v057.i05)

## See also

[`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md)
for diverging colors;
[`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md)
for individual responses;
[`snake_palette()`](https://pak.dynasite.org/Snakeplot/reference/snake_palette.md)
for the sequential palettes `"blues"`, `"greens"`, `"grays"`, `"warm"`
and `"viridis"`.

## Examples

``` r
# Emotion intensity rated 1-5, a unipolar scale
sequential_dist(ema_emotions, sort_by = "mean", hue = 160)


# A table of counts on a frequency scale
counts <- matrix(c(15, 25, 60, 80, 45,
                   10, 20, 50, 90, 55,
                   20, 30, 65, 70, 40),
                 nrow = 3, byrow = TRUE)
sequential_dist(counts,
                labels = c("Plans study time", "Reviews notes",
                           "Asks for help"),
                levels = c("Never", "Rarely", "Sometimes", "Often",
                           "Always"))

```
