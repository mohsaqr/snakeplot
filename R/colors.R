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
  vapply(seq_len(n), function(i) {
    grDevices::hsv(hue / 360, s_range[i], v_range[i])
  }, character(1))
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
shade_by_value <- function(value, min_val = 1, max_val = 5) {
  frac <- (value - min_val) / (max_val - min_val)
  frac <- max(0, min(1, frac))
  # Rich dark warm-to-cool ramp (brown -> dark slate)
  ramp <- grDevices::colorRampPalette(c("#5c2a0e", "#3a3a5c"))(101)
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
