# Get a Snake Plot Palette

Returns a color palette interpolated to `n` colors.

## Usage

``` r
snake_palette(name = "classic", n = 7L)
```

## Arguments

- name:

  Character, palette name (see
  [`snake_palettes`](https://saqr.me/Snakeplot/reference/snake_palettes.md)).

- n:

  Integer, number of colors to return (default 7).

## Value

Character vector of `n` hex color strings.

## Examples

``` r
snake_palette("ocean", 5)
#> [1] "#D73027" "#F88D52" "#E0E0E0" "#8FC3DC" "#4575B4"
snake_palette("earth", 7)
#> [1] "#8C510A" "#BF812D" "#DFC27D" "#C7C7C7" "#80CDC1" "#35978F" "#01665E"
snake_palette("blues", 3)
#> [1] "#EFF3FF" "#6BAED6" "#084594"
```
