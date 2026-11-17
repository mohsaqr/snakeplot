# Draw one snake plot per group in a grid of panels

`facet_snake()` splits a data frame by a grouping column and draws one
snake plot per group in a grid of panels, so that groups such as
participants, classes or conditions can be compared in the same display.
Each panel is drawn by `FUN`, by default
[`activity_snake()`](https://pak.dynasite.org/Snakeplot/reference/activity_snake.md),
with the group value as its title.

The panels are independent plots: each is scaled to its own data. The
grid is set with `par(mfrow)` and the previous graphical parameters are
restored afterwards. It returns, invisibly, a list with the value `FUN`
returned for each panel.

To draw groups of items (columns) rather than groups of rows, use the
`facet` argument of
[`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md).

## Usage

``` r
facet_snake(data, facet_var, FUN = activity_snake, ncol = NULL, ...)
```

## Arguments

- data:

  A data frame. It is split by `facet_var`, and each part, without the
  grouping column, is passed to `FUN` as its first argument.

- facet_var:

  Name of the grouping column. Panels follow the order in which its
  values first appear.

- FUN:

  Plotting function for each panel (default
  [`activity_snake()`](https://pak.dynasite.org/Snakeplot/reference/activity_snake.md)).
  It must take the data as its first argument and accept a `title`
  argument;
  [`line_snake()`](https://pak.dynasite.org/Snakeplot/reference/line_snake.md),
  [`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md),
  [`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md)
  and
  [`sequential_dist()`](https://pak.dynasite.org/Snakeplot/reference/sequential_dist.md)
  qualify.

- ncol:

  Number of panel columns. `NULL` (default) places all panels in one
  row.

- ...:

  Further arguments passed to `FUN`.

## Value

The panels are drawn on the current device. The function returns,
invisibly, an unnamed list with one element per group, in order of first
appearance, holding the value `FUN` returned for that panel (a
`snake_layout` object for
[`activity_snake()`](https://pak.dynasite.org/Snakeplot/reference/activity_snake.md)).

## See also

[`activity_snake()`](https://pak.dynasite.org/Snakeplot/reference/activity_snake.md),
[`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md)
and its `facet` argument.

## Examples

``` r
# Two participants' prompts, one panel each
two <- subset(ema_beeps, id %in% c("xcVDLRQOwn", "6pig43CFyl"),
              select = c(id, start_time))
facet_snake(two, facet_var = "id", ncol = 1, show_total = FALSE)

```
