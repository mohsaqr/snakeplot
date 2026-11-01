# Built-in Color Palettes

A named list of 10 color palettes for snake plots. Each palette contains
7 anchor colors that can be interpolated to any length with
[`snake_palette`](https://pak.dynasite.org/Snakeplot/reference/snake_palette.md).

## Usage

``` r
snake_palettes
```

## Format

A named list of 10 character vectors, each with 7 hex color strings.

## Details

- classic:

  Diverging red-to-blue. Clean Likert default.

- earth:

  Diverging brown-to-teal. Natural, understated.

- ocean:

  Diverging coral-to-navy. Warm/cool contrast.

- sunset:

  Diverging orange-to-indigo. Vivid but balanced.

- berry:

  Diverging rose-to-green. High contrast.

- blues:

  Sequential light-to-dark blue.

- greens:

  Sequential light-to-dark green.

- grays:

  Sequential light-to-dark gray.

- warm:

  Sequential cream-to-dark red.

- viridis:

  Sequential yellow-green-blue-purple (viridis-inspired).

## Examples

``` r
names(snake_palettes)
#>  [1] "classic" "earth"   "ocean"   "sunset"  "berry"   "blues"   "greens" 
#>  [8] "grays"   "warm"    "viridis"
# snake_palette() returns a palette by name; with the default n = 7 it
# gives the 7 anchor colors unchanged
snake_palette("ocean")
#> [1] "#D73027" "#F46D43" "#FDAE61" "#E0E0E0" "#ABD9E9" "#74ADD1" "#4575B4"
# ema_emotions has 5 levels, so interpolate the palette to 5 colors
survey_snake(ema_emotions, colors = snake_palette("earth", n = 5),
             tick_shape = "bar", sort_by = "mean")

```
