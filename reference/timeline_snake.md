# Plot a timeline of phases as a serpentine of monthly blocks

`timeline_snake()` draws a timeline snake plot, which shows a succession
of phases, such as the positions held in a career or the stages of a
project, as colored blocks folded into bands joined by U-turns. With
dated input each block is one month, so the length of a phase is
proportional to its duration and a span of many years fits in one panel
while its order is kept.

The function takes a data frame with one row per phase (state, start
date, end date) and builds the monthly sequence. It labels each change
of phase with its start month, labels each band with the year at its
middle, and prints the state names inside the phases. A vector of
states, one per time unit, is drawn as given. Colors default to a
light-to-dark blue ramp in phase order. The drawing is done by
[`sequence_snake()`](https://pak.dynasite.org/Snakeplot/reference/sequence_snake.md),
and its display options can be passed here. The plot is drawn on the
current device and `NULL` is returned invisibly.

For an undated sequence of many short events use
[`sequence_snake()`](https://pak.dynasite.org/Snakeplot/reference/sequence_snake.md);
for many sequences use
[`multi_snake()`](https://pak.dynasite.org/Snakeplot/reference/multi_snake.md).

## Usage

``` r
timeline_snake(
  sequence,
  states = NULL,
  colors = NULL,
  rows = NULL,
  band_height = 28,
  band_gap = 30,
  plot_width = 500,
  margin = c(top = 35, right = 10, bottom = 65, left = 20),
  orientation = "horizontal",
  start_from = "left",
  flow = c("natural", "snake"),
  show_labels = FALSE,
  show_legend = TRUE,
  show_numbers = FALSE,
  show_state = TRUE,
  state_size = 1,
  show_ticks = FALSE,
  tick_labels = NULL,
  transition_labels = NULL,
  transition_pos = NULL,
  tick_color = "#444444",
  tick_length = 6,
  tick_size = 0.8,
  border_color = NA,
  block_labels = NULL,
  band_labels = NULL,
  title = NULL,
  background = "white",
  shadow = TRUE,
  text_size = 0.5,
  legend_text_size = 1.2
)
```

## Arguments

- sequence:

  Phases as a data frame whose first three columns are the state, the
  start date and the end date, one row per phase. Dates may be
  `"YYYY-MM"`, `"YYYY-MM-DD"`, other common date formats, or `Date`
  values; start and end months are both included. Alternatively a vector
  of states, one per time unit.

- states:

  State labels in legend order. `NULL` (default) takes them in order of
  first appearance. Every state in `sequence` must be listed.

- colors:

  State colors: a vector named by state, or an unnamed vector recycled
  over the states. `NULL` (default) uses a light-to-dark blue ramp over
  the states in order.

- rows:

  Number of bands. `NULL` (default) uses about 20 months per band and at
  least two bands for data frame input, and one band per 11 positions
  for vector input.

- band_height:

  Height of each band in plot units (default 28).

- band_gap:

  Gap between bands in plot units (default 30, which leaves room for the
  year labels).

- plot_width:

  Length of each band in plot units (default 500).

- margin:

  Named numeric vector of `top`, `right`, `bottom` and `left` margins in
  plot units (default
  `c(top = 35, right = 10, bottom = 65, left = 20)`).

- orientation:

  `"horizontal"` (default). `"vertical"` turns the bands into columns
  but places the blocks across each column rather than along it, so the
  horizontal layout is recommended.

- start_from:

  Side on which the first band starts: `"left"` (default) or `"right"`.

- flow:

  `"natural"` (default): every band reads in the same direction, like
  lines of text. `"snake"`: bands alternate direction, so the sequence
  runs on through each U-turn.

- show_labels:

  Label each band with the range of positions it holds (default
  `FALSE`).

- show_legend:

  Draw the state legend (default `TRUE`).

- show_numbers:

  Print each block's position inside it (default `FALSE`).

- show_state:

  Print the state name inside each phase (default `TRUE`).

- state_size:

  Text size of the state names (default 1).

- show_ticks:

  Draw ruler ticks at block boundaries, outside the bands (default
  `FALSE`).

- tick_labels:

  Labels for evenly spaced ruler marks on every band, such as
  `month.abb`. Setting them turns on `show_ticks`.

- transition_labels:

  Labels for the points where the state changes, in order. `NULL`
  (default) uses, for data frame input, the start month of each phase
  after the first, such as `"Jun 2020"`.

- transition_pos:

  Positions of `transition_labels` along the sequence, in blocks;
  fractions such as `6.5` are allowed. `NULL` (default) places the
  labels at the changes of state.

- tick_color:

  Color of ticks and of band and transition labels (default
  `"#444444"`).

- tick_length:

  Length of ticks in plot units (default 6).

- tick_size:

  Text size of tick, band and transition labels (default 0.8).

- border_color:

  Color of block outlines, or `NA` (default) for none.

- block_labels:

  Labels for the blocks, one per position. They replace the position
  numbers, and are drawn below the blocks when ruler ticks are shown.

- band_labels:

  One label per band (length `rows`). `NULL` (default) uses, for data
  frame input, the year at the middle of each band.

- title:

  Plot title, or `NULL` (default) for none.

- background:

  Background color (default `"white"`).

- shadow:

  Draw drop shadows (default `TRUE`).

- text_size:

  Text size of block numbers and block labels (default 0.5).

- legend_text_size:

  Size of the legend text (default 1.2).

## Value

The plot is drawn on the current device; the function returns `NULL`
invisibly.

## See also

[`sequence_snake()`](https://pak.dynasite.org/Snakeplot/reference/sequence_snake.md),
which draws the plot;
[`multi_snake()`](https://pak.dynasite.org/Snakeplot/reference/multi_snake.md)
for many sequences;
[`activity_snake()`](https://pak.dynasite.org/Snakeplot/reference/activity_snake.md)
for events within days.

## Examples

``` r
# An academic career, one row per position
career <- data.frame(
  role  = c("PhD student", "Postdoc", "Lecturer", "Senior lecturer"),
  start = c("2012-09", "2016-10", "2019-01", "2023-08"),
  end   = c("2016-09", "2018-12", "2023-07", "2025-12")
)
timeline_snake(career)


# The same kind of display from a vector, one element per year
schooling <- rep(c("School", "Bachelor", "Master", "Work"),
                 times = c(12, 3, 2, 8))
timeline_snake(schooling, rows = 3)

```
