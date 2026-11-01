# Faceted Snake Plot

Splits data by a grouping variable and draws side-by-side snake panels.
Works with `activity_snake`, `survey_snake`, `survey_sequence`,
`sequential_dist`, or `line_snake`.

## Usage

``` r
facet_snake(data, facet_var, FUN = activity_snake, ncol = NULL, ...)
```

## Arguments

- data:

  A data.frame to plot. It is split by `facet_var`; each subset, with
  the facet column removed, is passed to `FUN`.

- facet_var:

  Character. Column name in `data` to facet by.

- FUN:

  Function to call for each panel. Default `activity_snake`. It must
  accept a `title` argument, which receives the facet level.

- ncol:

  Integer. Number of columns in the facet grid. Default: number of facet
  levels (all in one row).

- ...:

  Additional arguments passed to `FUN`.

## Value

Called for its side effect of drawing one panel per facet level.
Invisibly returns an unnamed list with one element per facet level, in
order of first appearance, each holding the value returned by `FUN` for
that panel (a `snake_layout` list for `activity_snake`).

## Examples

``` r
set.seed(42)
d <- data.frame(
  group    = rep(c("A", "B"), each = 70),
  day      = rep(rep(c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
                 each = 10), 2),
  start    = round(runif(140, 360, 1400)),
  duration = 0
)
facet_snake(d, "group")

```
