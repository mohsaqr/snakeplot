#' Plot daily activity as a serpentine timeline of days
#'
#' @description
#' `activity_snake()` draws an activity snake plot, which shows when events
#' occur over many days. Each day is a band spanning the same time-of-day
#' window, and consecutive days are joined by U-turns, so a long run of days
#' fits in one panel while their order is kept. Events appear as thin ticks
#' (instantaneous events) or as blocks whose width is the event's duration,
#' which places daily rhythms, gaps and irregular days side by side for
#' comparison.
#'
#' The function takes event times as a vector of timestamps, a data frame of
#' timestamps, or a data frame of day, start time and duration. It draws one
#' band per day on a dark ribbon, with hourly gridlines, an hour axis, day
#' labels carrying the day's total duration or number of events, and the
#' clock time at each U-turn. Bands can alternate direction
#' (`flow = "snake"`) so that time runs on through each U-turn, or all read
#' in the same direction (`flow = "natural"`); the layout can be horizontal
#' or vertical. It returns the layout invisibly as a `snake_layout` object.
#'
#' The display encodes the timing of events, not their values. For a
#' continuous measurement through the day use [line_snake()]; for a sequence
#' of categorical states use [sequence_snake()]; for ratings collected at each
#' prompt use the `var`/`day` interface of [survey_snake()]. [facet_snake()]
#' draws one activity snake plot per group.
#'
#' @param data Events, in one of three forms:
#'   * a POSIXct vector of event times;
#'   * a data frame with a POSIXct `timestamp` or `start` column, and
#'     optionally an `end` column (POSIXct) or a `duration` column (minutes);
#'   * a data frame with columns `day` (day label), `start` (minutes after
#'     midnight, 0-1440) and `duration` (minutes; 0 for an instantaneous
#'     event).
#'
#'   Column names are matched without regard to case, and common variants
#'   such as `start_time`, `end_time` or `date` are recognised. Character
#'   timestamps are parsed. Days appear in order of first occurrence.
#' @param band_height,band_gap Height of each day band and gap between bands,
#'   in plot units (defaults 28 and 18).
#' @param day_start,day_end Time window of each band, in minutes after
#'   midnight (defaults 360, 6 AM, and 1440, midnight). When `data` is a
#'   POSIXct vector, or a data frame whose `timestamp` or `start` column is
#'   POSIXct, the window is widened to whole hours covering all events.
#' @param plot_width Length of each band in plot units (default 500).
#' @param band_color,event_color Colors of the bands and of the events
#'   (defaults `"#3d3d4a"` and `"#d4a843"`). A vector of colors is recycled
#'   over days.
#' @param arc_color Color of the U-turns (default `"#2a2a3a"`).
#' @param band_opacity,arc_opacity,event_opacity Opacities between 0 and 1
#'   (defaults 0.90, 0.85 and 0.85).
#' @param tick_width Minimum width of an event in plot units (default 1.5),
#'   which keeps instantaneous events visible.
#' @param show_grid Draw hourly gridlines (default `TRUE`).
#' @param show_total Append the day's total event duration to its label
#'   (default `TRUE`).
#' @param show_count Append the day's number of events to its label
#'   (default `FALSE`).
#' @param show_hour_labels Draw the hour axis (default `TRUE`).
#' @param show_arc_labels Print the clock time at each U-turn
#'   (default `TRUE`).
#' @param shadow Draw drop shadows (default `TRUE`).
#' @param grid_color Gridline color: an R color or a CSS-style
#'   `"rgba(r,g,b,a)"` string (default `"rgba(255,255,255,0.25)"`).
#' @param label_color,label_size Color and size multiplier of the day labels
#'   (defaults `"#cccccc"` and 0.85).
#' @param label_align Alignment of the day labels: `"left"` (default),
#'   `"right"`, or `"direction"` to follow each band's reading direction.
#' @param orientation `"horizontal"` (default) for bands running across the
#'   page, or `"vertical"` for bands running down it. The vertical layout
#'   uses smaller sizes and margins for those arguments left at their
#'   defaults.
#' @param start_from Side on which the first band starts: `"left"` (default)
#'   or `"right"`.
#' @param flow `"snake"` (default): bands alternate direction, so time runs
#'   on through each U-turn. `"natural"`: every band reads in the same
#'   direction.
#' @param day_format [strftime()] format of day labels built from timestamps,
#'   such as `"%a"` or `"%d %b"`. `NULL` (default) uses `"%a"` for up to
#'   seven days and `"%Y-%m-%d"` otherwise.
#' @param legend Legend entries: a list of items, each a list with `label`
#'   and `color`, and optionally `type` (`"rect"`, the default, `"tick"` or
#'   `"gradient"`). `NULL` (default) draws no legend.
#' @param title Plot title, or `NULL` (default) for none.
#' @param margin Named numeric vector of `top`, `right`, `bottom` and `left`
#'   margins in plot units (default
#'   `c(top = 30, right = 10, bottom = 50, left = 80)`).
#' @param background Background color (default `"white"`).
#'
#' @return The plot is drawn on the current device. The function returns,
#'   invisibly, an object of class `snake_layout`: a list describing the drawn
#'   geometry, with `bands` (a data frame with one row per day band giving its
#'   index, position, and drawing and reading direction), `arcs` (a list with
#'   one element per U-turn), `canvas` and `plot_area` (dimensions in plot
#'   units), `orientation`, `flow` and `params` (the sizes used).
#'
#' @seealso [line_snake()] for a continuous value through the day;
#'   [sequence_snake()] for categorical states; [survey_snake()] for ratings
#'   at each prompt; [facet_snake()] for one panel per group.
#'
#' @examples
#' # One participant's 69 prompts over 14 days of experience sampling
#' beeps <- subset(ema_beeps, id == "xcVDLRQOwn", select = start_time)
#' activity_snake(beeps, show_total = FALSE, show_count = TRUE)
#'
#' # Sessions with durations: day, start (minutes after midnight), length
#' set.seed(1)
#' sessions <- data.frame(
#'   day      = rep(c("Mon", "Tue", "Wed", "Thu", "Fri"), each = 4),
#'   start    = round(runif(20, 420, 1260)),
#'   duration = round(runif(20, 20, 120))
#' )
#' activity_snake(sessions, event_color = "#E69F00", flow = "natural")
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
