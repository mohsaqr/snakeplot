# Get a Snake Plot Palette

Returns a color palette interpolated to `n` colors.

## Usage

``` r
snake_palette(name = "classic", n = 7L)
```

## Arguments

- name:

  Character, palette name: one of `names(snake_palettes)` (default
  `"classic"`). An unknown name is an error that lists the available
  palettes.

- n:

  Integer, number of colors to return (default 7). With `n = 7` the
  anchor colors are returned unchanged; other values interpolate between
  them with
  [`grDevices::colorRampPalette()`](https://rdrr.io/r/grDevices/colorRamp.html).
  Pass the number of response levels so a diverging palette spans the
  whole scale.

## Value

Character vector of `n` hex color strings, ordered from the first (low)
to the last (high) anchor color.

## Examples

``` r
snake_palette("ocean", 5)
#> [1] "#D73027" "#F88D52" "#E0E0E0" "#8FC3DC" "#4575B4"
snake_palette("earth", 7)
#> [1] "#8C510A" "#BF812D" "#DFC27D" "#C7C7C7" "#80CDC1" "#35978F" "#01665E"
snake_palette("blues", 3)
#> [1] "#EFF3FF" "#6BAED6" "#084594"
```
