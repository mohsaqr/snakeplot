#' Plot a continuous series as a line through a serpentine of days
#'
#' @description
#' `line_snake()` draws a line snake plot, which shows a continuous
#' measurement, such as foot traffic or a sensor reading, over many days.
#' Each day is a band covering the same time-of-day window; within a band the
#' height of the line encodes the value, and the line continues through the
#' U-turn into the next day. The series stays unbroken while each day can be
#' compared with the days above and below it.
#'
#' The function takes a data frame of times and values, optionally with a
#' day column, or a numeric vector drawn as one band of evenly spaced values.
#' The value axis is shared by all bands and runs from the overall minimum to
#' the overall maximum. An optional fill shades the area under the line. It
#' returns the layout invisibly as a `snake_layout` object. The interface of
#' this function is experimental and may change in a later release.
#'
#' For the timing of discrete events use [activity_snake()]; for categorical
#' states use [sequence_snake()].
#'
#' @param data A data frame with columns `time` (minutes after midnight, or
#'   POSIXct), `value` (numeric) and optionally `day` (band label). With
#'   POSIXct times the band label is the abbreviated weekday, so times more
#'   than a week apart share a band. A numeric vector is drawn as a single
#'   band.
#' @param band_height,band_gap Height of each band and gap between bands, in
#'   plot units (defaults 40 and 18).
#' @param day_start,day_end Time window of each band, in minutes after
#'   midnight (defaults 0 and 1440).
#' @param plot_width Length of each band in plot units (default 500).
#' @param line_color,line_width Color and width of the line (defaults
#'   `"#e74c3c"` and 1.5).
#' @param fill_color,fill_opacity Color of the area under the line, `NULL`
#'   (default) for no fill, and its opacity (default 0.3).
#' @param band_color,arc_color Colors of the bands and U-turns (defaults
#'   `"#2d2d3d"` and `"#1a1a2e"`).
#' @param band_opacity,arc_opacity Opacities between 0 and 1 (defaults 0.90
#'   and 0.85).
#' @param show_grid Draw hourly gridlines (default `TRUE`).
#' @param shadow Draw drop shadows (default `TRUE`).
#' @param label_color,label_size Color and size multiplier of the band labels
#'   (defaults `"#cccccc"` and 0.85).
#' @param orientation Only `"horizontal"` (default) is supported at present;
#'   `"vertical"` gives an error.
#' @param start_from Side on which the first band starts: `"left"` (default)
#'   or `"right"`.
#' @param flow `"snake"` (default): bands alternate direction, so time runs
#'   on through each U-turn. `"natural"`: every band reads in the same
#'   direction.
#' @param title Plot title, or `NULL` (default) for none.
#' @param margin Named numeric vector of `top`, `right`, `bottom` and `left`
#'   margins in plot units (default
#'   `c(top = 30, right = 10, bottom = 50, left = 80)`).
#' @param background Background color (default `"white"`).
#'
#' @return The plot is drawn on the current device. The function returns,
#'   invisibly, an object of class `snake_layout`: a list describing the drawn
#'   geometry, with `bands` (a data frame with one row per band giving its
#'   index, position, and drawing and reading direction), `arcs` (a list with
#'   one element per U-turn), `canvas` and `plot_area` (dimensions in plot
#'   units), `orientation`, `flow` and `params` (the sizes used).
#'
#' @seealso [activity_snake()] for event times; [sequence_snake()] for
#'   categorical states; [facet_snake()] for one panel per group.
#'
#' @examples
#' # Four days of a value measured every 10 minutes
#' set.seed(42)
#' minutes <- seq(0, 1440, by = 10)
#' traffic <- data.frame(
#'   day   = rep(c("Mon", "Tue", "Wed", "Thu"), each = length(minutes)),
#'   time  = rep(minutes, 4),
#'   value = 50 + 50 * sin(rep(minutes, 4) / 1440 * 4 * pi) +
#'     rnorm(4 * length(minutes), 0, 8)
#' )
#' line_snake(traffic, line_color = "#D55E00", fill_color = "#D55E00")
#'
#' @export
line_snake <- function(data,
                       band_height  = 40,
                       band_gap     = 18,
                       day_start    = 0,
                       day_end      = 1440,
                       plot_width   = 500,
                       line_color   = "#e74c3c",
                       line_width   = 1.5,
                       fill_color   = NULL,
                       fill_opacity = 0.3,
                       band_color   = "#2d2d3d",
                       arc_color    = "#1a1a2e",
                       band_opacity = 0.90,
                       arc_opacity  = 0.85,
                       show_grid    = TRUE,
                       shadow       = TRUE,
                       label_color  = "#cccccc",
                       label_size    = 0.85,
                       orientation  = c("horizontal", "vertical"),
                       start_from   = c("left", "right"),
                       flow         = c("snake", "natural"),
                       title        = NULL,
                       margin       = c(top = 30, right = 10,
                                        bottom = 50, left = 80),
                       background   = "white") {
  orientation <- match.arg(orientation)
  start_from  <- match.arg(start_from)
  flow        <- match.arg(flow)

  # Coerce numeric vector to single-band data.frame
  if (is.numeric(data) && is.null(dim(data))) {
    n <- length(data)
    data <- data.frame(
      day   = rep("Series", n),
      time  = seq(day_start, day_end, length.out = n),
      value = data
    )
  }

  # Auto-convert POSIXct
  if ("time" %in% names(data) && inherits(data$time, "POSIXt")) {
    ts <- data$time
    dates <- .local_date(ts)
    data$day <- format(ts, "%a")
    h <- as.numeric(format(ts, "%H"))
    m <- as.numeric(format(ts, "%M"))
    data$time <- h * 60 + m
    unique_days <- unique(data$day)
    data$day <- factor(data$day, levels = unique_days)
  }

  stopifnot(is.data.frame(data),
            all(c("time", "value") %in% names(data)))
  if (!"day" %in% names(data)) data$day <- "Series"
  if (!is.factor(data$day)) data$day <- factor(data$day, levels = unique(data$day))

  day_levels <- levels(data$day)
  n_days     <- length(day_levels)
  day_data   <- split(data, data$day)

  # Value range
  val_min <- min(data$value, na.rm = TRUE)
  val_max <- max(data$value, na.rm = TRUE)
  val_range <- if (val_max > val_min) val_max - val_min else 1

  if (!is.null(title)) margin["top"] <- margin["top"] + 18

  layout <- compute_snake_layout(n_days, band_height, band_gap,
                                 plot_width, margin,
                                 orientation = orientation,
                                 start_from = start_from,
                                 flow = flow)
  op <- setup_canvas(layout, bg = background)
  on.exit(par(op), add = TRUE)

  if (!is.null(title)) {
    text(layout$canvas$width / 2, 14, title,
         col = "#333333", cex = 1.1, font = 2)
  }

  if (shadow) draw_shadows(layout)
  draw_ribbon(layout, band_colors = band_color, arc_color = arc_color,
              band_opacity = band_opacity, arc_opacity = arc_opacity)

  bands <- layout$bands

  # Grid
  if (show_grid) {
    gcol <- if (grepl("^rgba", "rgba(255,255,255,0.15)")) {
      parse_rgba("rgba(255,255,255,0.15)")
    } else {
      "rgba(255,255,255,0.15)" # nocov
    }
    hour_mins <- seq(ceiling(day_start / 60) * 60,
                     floor(day_end / 60) * 60, by = 60)
    vapply(seq_len(n_days), function(k) {
      x_pos <- time_to_x(hour_mins, day_start, day_end,
                          bands$x_left[k], bands$x_right[k],
                          bands$read_direction[k])
      segments(x_pos, bands$y_top[k], x_pos, bands$y_bottom[k],
               col = gcol, lwd = 0.3)
      NA
    }, logical(1))
  }

  # Helper: map value to y-position within band (high value = near top)
  val_to_band_y <- function(val, yt, yb) {
    frac <- (val - val_min) / val_range
    yb - frac * (yb - yt)  # inverted: high value = smaller y (toward top)
  }

  # Draw line through each band
  vapply(seq_len(n_days), function(k) {
    dname <- day_levels[k]
    dd <- day_data[[dname]]
    if (is.null(dd) || nrow(dd) < 2L) return(NA)

    dd <- dd[order(dd$time), ]
    dir <- bands$read_direction[k]
    xl  <- bands$x_left[k]; xr <- bands$x_right[k]
    yt  <- bands$y_top[k];  yb <- bands$y_bottom[k]

    x_pts <- time_to_x(dd$time, day_start, day_end, xl, xr, dir)
    y_pts <- val_to_band_y(dd$value, yt, yb)

    # Fill below line
    if (!is.null(fill_color)) {
      polygon(c(x_pts, rev(x_pts)),
              c(y_pts, rep(yb, length(y_pts))),
              col = alpha_col(fill_color, fill_opacity), border = NA)
    }

    lines(x_pts, y_pts, col = line_color, lwd = line_width)
    NA
  }, logical(1))

  # Arc transitions: follow inner arc edge, then drop vertically to next band
  lapply(seq_along(layout$arcs), function(a_idx) {
    a <- layout$arcs[[a_idx]]
    k_from <- a$from + 1L
    k_to   <- a$to + 1L

    dd_from <- day_data[[day_levels[k_from]]]
    dd_to   <- day_data[[day_levels[k_to]]]
    if (is.null(dd_from) || nrow(dd_from) == 0L ||
        is.null(dd_to) || nrow(dd_to) == 0L) return(NULL)

    dd_from <- dd_from[order(dd_from$time), ]
    dd_to   <- dd_to[order(dd_to$time), ]

    # End/start values for the line
    val_end   <- dd_from$value[nrow(dd_from)]
    val_start <- dd_to$value[1]
    yt_f <- bands$y_top[k_from]; yb_f <- bands$y_bottom[k_from]
    yt_t <- bands$y_top[k_to];   yb_t <- bands$y_bottom[k_to]
    y_line_end   <- val_to_band_y(val_end, yt_f, yb_f)
    y_line_start <- val_to_band_y(val_start, yt_t, yb_t)

    if (a$side %in% c("right", "left")) {
      sign_x <- if (a$side == "right") 1 else -1

      # 1. Vertical drop from line end to inner arc edge
      dir_from <- bands$read_direction[k_from]
      xl_f <- bands$x_left[k_from]; xr_f <- bands$x_right[k_from]
      x_end <- if (dir_from == "ltr") xr_f else xl_f
      inner_y_entry <- a$cy - a$inner_r  # top of inner arc
      segments(x_end, y_line_end, x_end, inner_y_entry,
               col = line_color, lwd = line_width)

      # 2. Follow inner arc edge (semicircle)
      n_arc <- 40L
      theta_seq <- seq(-pi / 2, pi / 2, length.out = n_arc)
      arc_x <- a$cx + sign_x * a$inner_r * cos(theta_seq)
      arc_y <- a$cy + a$inner_r * sin(theta_seq)

      lines(arc_x, arc_y, col = line_color, lwd = line_width)

      # 3. Vertical rise from inner arc edge to line start in next band
      dir_to <- bands$read_direction[k_to]
      xl_t <- bands$x_left[k_to]; xr_t <- bands$x_right[k_to]
      x_start <- if (dir_to == "ltr") xl_t else xr_t
      inner_y_exit <- a$cy + a$inner_r  # bottom of inner arc
      segments(x_start, inner_y_exit, x_start, y_line_start,
               col = line_color, lwd = line_width)
    }
    NULL
  })

  # Labels
  draw_band_labels(layout, day_levels, col = label_color, cex = label_size)

  # Hour axis
  hour_start <- ceiling(day_start / 60) * 60
  hour_end   <- floor(day_end / 60) * 60
  tick_hours <- seq(hour_start, hour_end, by = 180)
  tick_labels <- minutes_to_label(tick_hours)
  tick_x <- time_to_x(tick_hours, day_start, day_end,
                       layout$plot_area$x_left, layout$plot_area$x_right, "ltr")
  names(tick_x) <- tick_labels
  draw_hour_labels(layout, tick_x, col = "#888888", cex = 0.7)

  invisible(layout)
}
