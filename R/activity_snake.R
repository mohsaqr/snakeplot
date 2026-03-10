#' Activity Snake Plot
#'
#' A daily activity timeline where each band is one day and colored
#' ticks or blocks on a dark ribbon represent events. The serpentine
#' (boustrophedon) layout connects days via U-turn arcs.
#'
#' @param data Input in one of three formats.
#'   (1) \strong{POSIXct vector}: a bare vector of timestamps, producing rug
#'   ticks grouped by day.
#'   (2) \strong{Numeric format}: a data.frame with columns \code{day}
#'   (character/factor day label), \code{start} (numeric minutes from midnight,
#'   0--1440), \code{duration} (numeric minutes; 0 = rug tick), and optionally
#'   \code{label} (character event label).
#'   (3) \strong{Timestamp format}: a data.frame with POSIXct column
#'   \code{timestamp} (or \code{start}), optionally \code{end} (POSIXct; if
#'   present, duration is computed), \code{duration} (numeric minutes; used when
#'   \code{end} is absent), and \code{label} (character event label).
#' @param band_height Numeric. Height of each day band in plot units
#'   (default 28).
#' @param band_gap Numeric. Vertical gap between bands (default 18).
#' @param day_start Numeric. Start of the time window in minutes from midnight
#'   (default 360 = 6AM).
#' @param day_end Numeric. End of the time window in minutes from midnight
#'   (default 1440 = midnight).
#' @param plot_width Numeric. Width of the band area in plot units
#'   (default 500).
#' @param band_color Character or character vector. Band ribbon color(s).
#'   If a vector, colors cycle per day (default "#3d3d4a").
#' @param event_color Character or character vector. Event tick/block color(s).
#'   If a vector, colors cycle per day (default "#d4a843").
#' @param arc_color Character. Overnight arc color (default "#2a2a3a").
#' @param band_opacity Numeric 0-1 (default 0.90).
#' @param arc_opacity Numeric 0-1 (default 0.85).
#' @param event_opacity Numeric 0-1 (default 0.85).
#' @param tick_width Numeric. Minimum event width in plot units
#'   (default 1.5). Use 1.0 for thin rug style.
#' @param show_grid Logical. Show hour gridlines (default TRUE).
#' @param show_total Logical. Show total duration after day label
#'   (default TRUE).
#' @param show_count Logical. Show event count in parentheses after day label
#'   (default FALSE).
#' @param show_hour_labels Logical. Show hour labels at bottom (default TRUE).
#' @param show_arc_labels Logical. Show "12AM" at arc tips (default TRUE).
#' @param shadow Logical. Draw drop shadows (default TRUE).
#' @param grid_color Character. Gridline color
#'   (default "rgba(255,255,255,0.25)").
#' @param label_color Character. Day label color (default "#cccccc").
#' @param label_size Numeric. Label font size multiplier (default 0.85).
#' @param label_align Character. Label alignment: "left" (default), "right",
#'   or "direction" (follows band reading direction).
#' @param orientation Character: "horizontal" (default) or "vertical".
#'   Controls whether the snake runs left-right or top-bottom.
#' @param start_from Character: "left" (default) or "right". Which side the
#'   first band starts from.
#' @param flow Character, \code{"snake"} (default) or \code{"natural"}.
#'   \code{"snake"} uses alternating boustrophedon direction;
#'   \code{"natural"} reads all bands in the same direction.
#' @param day_format Optional strftime format for day labels when \code{start}
#'   is POSIXct (e.g., \code{"\%a"} for "Mon", \code{"\%Y-\%m-\%d"} for
#'   dates). NULL = auto-detect (\code{"\%a"} for 7 or fewer days,
#'   \code{"\%Y-\%m-\%d"} otherwise).
#' @param legend List of legend items, each with \code{label} and
#'   \code{color}. NULL for no legend.
#' @param title Optional plot title.
#' @param margin Named numeric vector with top, right, bottom, left margins.
#' @param background Background color (default "white").
#'
#' @return Invisible \code{snake_layout} object (for downstream use).
#'
#' @examples
#' # Weekly rug-style activity plot
#' set.seed(42)
#' days <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
#' d <- data.frame(
#'   day      = rep(days, each = 40),
#'   start    = round(runif(280, 360, 1400)),
#'   duration = 0
#' )
#' activity_snake(d)
#'
#' # Duration blocks
#' d2 <- data.frame(
#'   day      = rep(days, each = 8),
#'   start    = round(runif(56, 360, 1200)),
#'   duration = round(runif(56, 15, 120))
#' )
#' activity_snake(d2, event_color = "#e09480", band_color = "#3d2518")
#'
#' @export
activity_snake <- function(data,
                           band_height    = 28,
                           band_gap       = 18,
                           day_start      = 360,
                           day_end        = 1440,
                           plot_width     = 500,
                           band_color     = "#3d3d4a",
                           event_color    = "#d4a843",
                           arc_color      = "#2a2a3a",
                           band_opacity   = 0.90,
                           arc_opacity    = 0.85,
                           event_opacity  = 0.85,
                           tick_width = 1.5,
                           show_grid      = TRUE,
                           show_total     = TRUE,
                           show_count     = FALSE,
                           show_hour_labels = TRUE,
                           show_arc_labels  = TRUE,
                           shadow         = TRUE,
                           grid_color     = "rgba(255,255,255,0.25)",
                           label_color    = "#cccccc",
                           label_size      = 0.85,
                           label_align    = "left",
                           orientation    = c("horizontal", "vertical"),
                           start_from     = c("left", "right"),
                           flow           = c("snake", "natural"),
                           day_format     = NULL,
                           legend         = NULL,
                           title          = NULL,
                           margin         = c(top = 30, right = 10,
                                              bottom = 50, left = 80),
                           background     = "white") {
  orientation <- match.arg(orientation)
  start_from  <- match.arg(start_from)
  flow        <- match.arg(flow)
  # Coerce bare POSIXct vector to data.frame
  was_timestamps <- inherits(data, "POSIXt") || (is.data.frame(data) &&
    (("timestamp" %in% names(data) && inherits(data$timestamp, "POSIXt")) ||
     ("start" %in% names(data) && inherits(data$start, "POSIXt"))))
  data <- coerce_activity_input(data)

  # Auto-convert timestamps if present
  ts_data <- prepare_timestamps(data, day_format)
  if (!is.null(ts_data)) data <- ts_data

  # Auto-adjust day_start/day_end to cover actual data when using timestamps
  if (was_timestamps && nrow(data) > 0L) {
    data_min <- floor(min(data$start, na.rm = TRUE) / 60) * 60
    data_max <- ceiling(max(data$start + data$duration, na.rm = TRUE) / 60) * 60
    day_start <- min(day_start, data_min)
    day_end   <- max(day_end, data_max)
  }

  # Validate
  data <- validate_activity_data(data)
  assert_positive(band_height, "band_height")
  assert_positive(band_gap, "band_gap")
  assert_positive(plot_width, "plot_width")
  stopifnot(day_start < day_end)

  day_levels <- levels(data$day)
  n_days     <- length(day_levels)
  day_events <- split(data, data$day)

  # Adjust top margin for title
  if (!is.null(title)) margin["top"] <- margin["top"] + 18

  # Adjust defaults for vertical orientation
  if (orientation == "vertical") {
    if (identical(margin, c(top = 30, right = 10, bottom = 50, left = 80))) {
      margin <- c(top = 55, right = 5, bottom = 5, left = 35)
    }
    if (plot_width == 500) plot_width <- 120
    if (band_height == 28) band_height <- 22
    if (band_gap == 18) band_gap <- 8
  }

  # Compute layout
  layout <- compute_snake_layout(n_days, band_height, band_gap,
                                 plot_width, margin,
                                 orientation = orientation,
                                 start_from = start_from,
                                 flow = flow)

  # Set up canvas
  op <- setup_canvas(layout, bg = background)
  on.exit(par(op), add = TRUE)

  # Title
  if (!is.null(title)) {
    text(layout$canvas$width / 2, 14, title,
         col = "#333333", cex = 1.1, font = 2)
  }

  # Shadows
  if (shadow) draw_shadows(layout)

  # Ribbon (bands + arcs + end caps)
  draw_ribbon(layout, band_colors = band_color, arc_color = arc_color,
              band_opacity = band_opacity, arc_opacity = arc_opacity)

  bands <- layout$bands
  vert <- orientation == "vertical"

  # Parse grid_color once
  gcol <- if (grepl("^rgba", grid_color)) parse_rgba(grid_color) else grid_color

  # Hour gridlines
  if (show_grid) {
    hour_start <- ceiling(day_start / 60) * 60
    hour_end   <- floor(day_end / 60) * 60
    hour_mins  <- seq(hour_start, hour_end, by = 60)

    vapply(seq_len(n_days), function(k) {
      if (!vert) {
        x_pos <- time_to_x(hour_mins, day_start, day_end,
                            bands$x_left[k], bands$x_right[k],
                            bands$read_direction[k])
        segments(x_pos, bands$y_top[k], x_pos, bands$y_bottom[k],
                 col = gcol, lwd = 0.4)
      } else {
        y_pos <- time_to_y(hour_mins, day_start, day_end,
                            bands$y_top[k], bands$y_bottom[k],
                            bands$read_direction[k])
        segments(bands$x_left[k], y_pos, bands$x_right[k], y_pos,
                 col = gcol, lwd = 0.4)
      }
      NA
    }, logical(1))
  }

  # Event ticks/blocks
  ecols <- cycle_colors(event_color, n_days)
  day_span <- day_end - day_start

  vapply(seq_len(n_days), function(k) {
    dname  <- day_levels[k]
    events <- day_events[[dname]]
    if (is.null(events) || nrow(events) == 0L) return(NA)

    dir  <- bands$read_direction[k]
    ecol <- alpha_col(ecols[k], event_opacity)

    if (!vert) {
      xl <- bands$x_left[k]; xr <- bands$x_right[k]
      yt <- bands$y_top[k];  yb <- bands$y_bottom[k]
      pw <- xr - xl
      x_starts <- time_to_x(events$start, day_start, day_end, xl, xr, dir)
      widths <- pmax(tick_width, (events$duration / day_span) * pw)
      if (dir == "ltr") {
        x0 <- x_starts; x1 <- pmin(x_starts + widths, xr)
      } else {
        x0 <- pmax(x_starts - widths, xl); x1 <- x_starts
      }
      rect(x0, yt, x1, yb, col = ecol, border = NA)
    } else {
      xl <- bands$x_left[k]; xr <- bands$x_right[k]
      yt <- bands$y_top[k];  yb <- bands$y_bottom[k]
      ph <- yb - yt
      y_starts <- time_to_y(events$start, day_start, day_end, yt, yb, dir)
      heights <- pmax(tick_width, (events$duration / day_span) * ph)
      if (dir == "ttb") {
        y0 <- y_starts; y1 <- pmin(y_starts + heights, yb)
      } else {
        y0 <- pmax(y_starts - heights, yt); y1 <- y_starts
      }
      rect(xl, y0, xr, y1, col = ecol, border = NA)
    }
    NA
  }, logical(1))

  # Labels
  totals <- if (show_total || show_count) {
    vapply(day_levels, function(dname) {
      ev <- day_events[[dname]]
      parts <- character(0)
      if (show_count) parts <- c(parts, sprintf("(%d)", nrow(ev)))
      if (show_total) {
        total_min <- sum(ev$duration, na.rm = TRUE)
        parts <- c(parts, format_duration(total_min))
      }
      paste(parts, collapse = " ")
    }, character(1))
  } else {
    NULL
  }

  draw_band_labels(layout, day_levels, totals, col = label_color,
                   cex = label_size, align = label_align)

  # Arc labels
  if (show_arc_labels && length(layout$arcs) > 0L) {
    start_label <- minutes_to_label(day_start)
    end_label   <- minutes_to_label(day_end)

    if (flow == "natural") {
      # Natural: all bands same direction.
      # start_from="left": all LTR, right edge = day_end, left edge = day_start
      # start_from="right": all RTL, right edge = day_start, left edge = day_end
      right_is_end <- (start_from == "left")
      if (!vert) {
        lapply(layout$arcs, function(a) {
          lbl <- if (a$side == "right") {
            if (right_is_end) end_label else start_label
          } else {
            if (right_is_end) start_label else end_label
          }
          text(a$tip_x, a$tip_y, lbl, col = "#666666", cex = 0.55,
               adj = c(if (a$side == "right") 0 else 1, 0.5))
        })
      } else {
        bottom_is_end <- (start_from == "left")
        lapply(layout$arcs, function(a) {
          lbl <- if (a$side == "bottom") {
            if (bottom_is_end) end_label else start_label
          } else {
            if (bottom_is_end) start_label else end_label
          }
          adj_y <- if (a$side == "bottom") 0 else 1
          text(a$tip_x, a$tip_y, lbl, col = "#666666", cex = 0.55,
               adj = c(0.5, adj_y))
        })
      }
    } else {
      # Snake: arcs always represent midnight (day_end)
      if (!vert) {
        draw_arc_labels(layout, label = end_label, col = "#666666", cex = 0.55)
      } else {
        lapply(layout$arcs, function(a) {
          adj_y <- if (a$side == "bottom") 0 else 1
          text(a$tip_x, a$tip_y, end_label, col = "#666666", cex = 0.55,
               adj = c(0.5, adj_y))
        })
      }
    }
  }

  # Hour axis labels
  if (show_hour_labels) {
    hour_start <- ceiling(day_start / 60) * 60
    hour_end   <- floor(day_end / 60) * 60
    tick_hours <- seq(hour_start, hour_end, by = 180)
    tick_labels <- minutes_to_label(tick_hours)

    if (!vert) {
      tick_x <- time_to_x(tick_hours, day_start, day_end,
                           layout$plot_area$x_left,
                           layout$plot_area$x_right, "ltr")
      names(tick_x) <- tick_labels
      draw_hour_labels(layout, tick_x, col = "#888888", cex = 0.7)
    } else {
      # Vertical: hour labels on the left side
      tick_y <- time_to_y(tick_hours, day_start, day_end,
                           layout$plot_area$y_top,
                           layout$plot_area$y_bottom, "ttb")
      x_pos <- layout$params$margin["left"] - 2
      text(rep(x_pos, length(tick_y)), tick_y, tick_labels,
           col = "#888888", cex = 0.6, adj = c(1, 0.5))
    }
  }

  # Legend
  if (!is.null(legend)) {
    draw_snake_legend(layout, legend, cex = 0.75)
  }

  invisible(layout)
}
