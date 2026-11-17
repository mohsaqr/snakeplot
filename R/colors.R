#' Generate a diverging color palette
#'
#' Creates a warm-to-cool palette suitable for Likert-type data.
#'
#' @param n Integer, number of colors.
#' @return Character vector of hex color strings.
#' @noRd
diverging_palette <- function(n = 5L) {
  stopifnot(is.numeric(n), length(n) == 1L, n >= 2L)
  # Red-to-blue diverging: warm reds, light gray mid, cool blues
  anchors <- c("#d4502a", "#e8967a", "#b8b8b8", "#7ab0d4", "#2c6faa")
  if (n == length(anchors)) return(anchors)
  grDevices::colorRampPalette(anchors)(n)
}

#' Generate a sequential (monochrome) palette
#'
#' @param n Integer, number of colors.
#' @param hue Numeric 0-360, base hue (default 210 = blue).
#' @return Character vector of hex color strings.
#' @noRd
sequential_palette <- function(n = 5L, hue = 210) {
  stopifnot(is.numeric(n), length(n) == 1L, n >= 2L)
  s_range <- seq(0.15, 0.75, length.out = n)
  v_range <- seq(0.95, 0.35, length.out = n)
  grDevices::hsv(rep(hue / 360, n), s_range, v_range)
}

#' Add alpha transparency to a color
#'
#' @param col Character, hex color or R color name.
#' @param alpha Numeric 0-1.
#' @return Character, hex color with alpha.
#' @noRd
alpha_col <- function(col, alpha = 0.5) {
  grDevices::adjustcolor(col, alpha.f = alpha)
}

#' Map a numeric value to a warm-cool color
#'
#' Low values map warm (red-brown), high values map cool (blue-gray).
#'
#' @param value Numeric, the value to map.
#' @param min_val Numeric, minimum of the scale.
#' @param max_val Numeric, maximum of the scale.
#' @return Character, hex color.
#' @noRd
shade_by_value <- function(value, min_val = 1, max_val = 5, palette = NULL) {
  frac <- (value - min_val) / (max_val - min_val)
  frac <- max(0, min(1, frac))
  # Rich dark warm-to-cool ramp (brown -> dark slate)
  anchors <- if (is.null(palette)) c("#5c2a0e", "#3a3a5c") else palette
  ramp <- grDevices::colorRampPalette(anchors)(101)
  ramp[round(frac * 100) + 1L]
}

#' Blend two colors by averaging their RGB values
#'
#' @param col1 Character, first hex color or R color name.
#' @param col2 Character, second hex color or R color name.
#' @return Character, hex color (50/50 RGB average).
#' @noRd
blend_colors <- function(col1, col2) {
  rgb1 <- grDevices::col2rgb(col1)[, 1L]
  rgb2 <- grDevices::col2rgb(col2)[, 1L]
  avg <- (rgb1 + rgb2) / 2
  grDevices::rgb(avg[1L], avg[2L], avg[3L], maxColorValue = 255)
}

#' Cycle colors to match a target length
#'
#' @param colors Character vector of colors.
#' @param n Target length.
#' @return Character vector of length n (recycled).
#' @noRd
cycle_colors <- function(colors, n) {
  rep_len(colors, n)
}

#' Built-in color palettes for snake plots
#'
#' @description
#' `snake_palettes` is a named list of ten palettes for the response levels of
#' rating scales. Each palette has seven anchor colors ordered from the low to
#' the high end of the scale; [snake_palette()] returns a palette by name and
#' interpolates it to the number of levels in the data.
#'
#' Five palettes are diverging, with a grey midpoint, for bipolar scales such
#' as agree-disagree: `classic` (red to blue), `earth` (brown to teal),
#' `ocean` (red to blue through orange), `sunset` (orange to purple) and
#' `berry` (pink to green). Five are sequential, light to dark, for unipolar
#' scales such as frequency or intensity: `blues`, `greens`, `grays`, `warm`
#' (cream to dark red) and `viridis` (yellow to blue, colors from the viridis
#' scale).
#'
#' @format A named list of 10 character vectors, each holding 7 hex color
#'   strings from the low to the high end of the scale.
#'
#' @seealso [snake_palette()] to get a palette with a given number of colors;
#'   [survey_snake()], [survey_sequence()] and [sequential_dist()], which take
#'   the colors through their `colors` argument.
#'
#' @examples
#' names(snake_palettes)
#'
#' # ema_emotions has 5 levels, so interpolate the palette to 5 colors
#' survey_snake(ema_emotions, colors = snake_palette("earth", n = 5),
#'              tick_shape = "bar", sort_by = "mean")
#'
#' @export
snake_palettes <- list(
  classic = c("#B2182B", "#D6604D", "#F4A582", "#D1D1D1",
              "#92C5DE", "#4393C3", "#2166AC"),
  earth   = c("#8C510A", "#BF812D", "#DFC27D", "#C7C7C7",
              "#80CDC1", "#35978F", "#01665E"),
  ocean   = c("#D73027", "#F46D43", "#FDAE61", "#E0E0E0",
              "#ABD9E9", "#74ADD1", "#4575B4"),
  sunset  = c("#B35806", "#E08214", "#FDB863", "#D8D8D8",
              "#B2ABD2", "#8073AC", "#542788"),
  berry   = c("#C51B7D", "#DE77AE", "#F1B6DA", "#D4D4D4",
              "#B8E186", "#7FBC41", "#4D9221"),
  blues   = c("#EFF3FF", "#C6DBEF", "#9ECAE1", "#6BAED6",
              "#4292C6", "#2171B5", "#084594"),
  greens  = c("#EDF8E9", "#C7E9C0", "#A1D99B", "#74C476",
              "#41AB5D", "#238B45", "#005A32"),
  grays   = c("#F7F7F7", "#D9D9D9", "#BDBDBD", "#969696",
              "#737373", "#525252", "#252525"),
  warm    = c("#FFF5EB", "#FDD0A2", "#FDAE6B", "#FD8D3C",
              "#F16913", "#D94801", "#8C2D04"),
  viridis = c("#FDE725", "#ADDC30", "#5EC962", "#28AE80",
              "#21918C", "#2C728E", "#3B528B")
)

#' Get a built-in palette for snake plots
#'
#' @description
#' `snake_palette()` returns one of the palettes in [snake_palettes],
#' interpolated to `n` colors. The survey plots match colors to response
#' levels by position and use only the first `length(levels)` colors, so `n`
#' should equal the number of response levels for a palette to span the whole
#' scale; a diverging palette then has its midpoint at the middle level.
#'
#' Diverging palettes (`classic`, `earth`, `ocean`, `sunset`, `berry`) suit
#' bipolar scales; sequential palettes (`blues`, `greens`, `grays`, `warm`,
#' `viridis`) suit unipolar scales and [sequential_dist()].
#'
#' @param name Palette name, one of `names(snake_palettes)` (default
#'   `"classic"`). An unknown name is an error that lists the available
#'   names.
#' @param n Number of colors (default 7). With 7 the anchor colors are
#'   returned unchanged; other values interpolate between them with
#'   [grDevices::colorRampPalette()].
#'
#' @return A character vector of `n` hex colors, ordered from the low to the
#'   high end of the scale.
#'
#' @seealso [snake_palettes] for the anchor colors; [survey_snake()],
#'   [survey_sequence()] and [sequential_dist()], which take the colors
#'   through their `colors` argument.
#'
#' @examples
#' snake_palette("ocean", n = 5)
#' snake_palette("blues", n = 3)
#' survey_sequence(ema_emotions, colors = snake_palette("berry", n = 5))
#'
#' @export
snake_palette <- function(name = "classic", n = 7L) {
  pal <- snake_palettes[[name]]
  if (is.null(pal)) {
    stop("Unknown palette '", name, "'. Available: ",
         paste(names(snake_palettes), collapse = ", "))
  }
  if (n == length(pal)) return(pal)
  grDevices::colorRampPalette(pal)(n)
}
