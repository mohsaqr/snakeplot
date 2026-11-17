# Built-in color palettes for snake plots

`snake_palettes` is a named list of ten palettes for the response levels
of rating scales. Each palette has seven anchor colors ordered from the
low to the high end of the scale;
[`snake_palette()`](https://pak.dynasite.org/Snakeplot/reference/snake_palette.md)
returns a palette by name and interpolates it to the number of levels in
the data.

Five palettes are diverging, with a grey midpoint, for bipolar scales
such as agree-disagree: `classic` (red to blue), `earth` (brown to
teal), `ocean` (red to blue through orange), `sunset` (orange to purple)
and `berry` (pink to green). Five are sequential, light to dark, for
unipolar scales such as frequency or intensity: `blues`, `greens`,
`grays`, `warm` (cream to dark red) and `viridis` (yellow to blue,
colors from the viridis scale).

## Usage

``` r
snake_palettes
```

## Format

A named list of 10 character vectors, each holding 7 hex color strings
from the low to the high end of the scale.

## See also

[`snake_palette()`](https://pak.dynasite.org/Snakeplot/reference/snake_palette.md)
to get a palette with a given number of colors;
[`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md),
[`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md)
and
[`sequential_dist()`](https://pak.dynasite.org/Snakeplot/reference/sequential_dist.md),
which take the colors through their `colors` argument.

## Examples

``` r
names(snake_palettes)
#>  [1] "classic" "earth"   "ocean"   "sunset"  "berry"   "blues"   "greens" 
#>  [8] "grays"   "warm"    "viridis"

# ema_emotions has 5 levels, so interpolate the palette to 5 colors
survey_snake(ema_emotions, colors = snake_palette("earth", n = 5),
             tick_shape = "bar", sort_by = "mean")

```
