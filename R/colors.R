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

#' Built-in Color Palettes
#'
#' A named list of 10 color palettes for snake plots. Each palette contains
#' 7 anchor colors that can be interpolated to any length with
#' \code{\link{snake_palette}}.
#'
#' \describe{
#'   \item{classic}{Diverging red-to-blue. Clean Likert default.}
#'   \item{earth}{Diverging brown-to-teal. Natural, understated.}
#'   \item{ocean}{Diverging coral-to-navy. Warm/cool contrast.}
#'   \item{sunset}{Diverging orange-to-indigo. Vivid but balanced.}
#'   \item{berry}{Diverging rose-to-green. High contrast.}
#'   \item{blues}{Sequential light-to-dark blue.}
#'   \item{greens}{Sequential light-to-dark green.}
#'   \item{grays}{Sequential light-to-dark gray.}
#'   \item{warm}{Sequential cream-to-dark red.}
#'   \item{viridis}{Sequential yellow-green-blue-purple (viridis-inspired).}
#' }
#'
#' @format A named list of 10 character vectors, each with 7 hex color strings.
#'
#' @examples
#' snake_palettes$ocean
#' survey_snake(ema_emotions, colors = snake_palettes$earth,
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

#' Get a Snake Plot Palette
#'
#' Returns a color palette interpolated to \code{n} colors.
#'
#' @param name Character, palette name (see \code{\link{snake_palettes}}).
#' @param n Integer, number of colors to return (default 7).
#' @return Character vector of \code{n} hex color strings.
#'
#' @examples
#' snake_palette("ocean", 5)
#' snake_palette("earth", 7)
#' snake_palette("blues", 3)
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
