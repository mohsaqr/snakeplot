#' Plot survey responses as a serpentine of stacked bars
#'
#' @description
#' `survey_sequence()` draws a survey sequence plot, which shows the
#' distribution of responses to a set of rating items as one 100% stacked bar
#' per item. The bars are the bands of a serpentine joined by U-turns, so a
#' long instrument fits in one panel in its item order and the share of each
#' response level can be compared between items. Heiberger and Robbins (2014)
#' discuss the design of stacked bar charts for rating scales.
#'
#' The function accepts raw responses or a table of counts. Segments are
#' colored by response level, with a diverging palette by default, and carry
#' their percentage when wide enough. Items can be sorted by mean or by net
#' agreement. Each U-turn takes the color midway between the levels at the
#' two ends it joins, or a neutral grey. It returns the layout invisibly as a
#' `snake_layout` object.
#'
#' [sequential_dist()] draws the same display with a single-hue palette for
#' scales without a neutral midpoint. [survey_snake()] shows each response as
#' a tick and can show correlations between adjacent items.
#'
#' @param counts Responses: a data frame of raw responses (one row per
#'   respondent, one column per item), a numeric matrix of counts (items in
#'   rows, response levels in columns), or a data frame of counts. A data
#'   frame is read as raw responses when its columns hold few distinct
#'   whole-number or categorical values relative to its number of rows.
#' @param labels Item labels, one per item. `NULL` (default) uses the row
#'   names of a count table, or, for raw responses, the column names with the
#'   number of responses.
#' @param levels Response levels in scale order. `NULL` (default) uses the
#'   column names of a count table, or, for raw responses, the factor levels
#'   or the sorted distinct values. For raw responses the levels must match
#'   the values in the data.
#' @param band_height Height of each band in plot units (default 28).
#' @param band_gap Gap between bands in plot units (default 14).
#' @param plot_width Length of each band in plot units (default 500).
#' @param colors One color per response level, in scale order. Only the first
#'   `length(levels)` colors are used, so pass
#'   `snake_palette(name, n = <number of levels>)`. `NULL` (default) uses a
#'   red-to-blue diverging palette.
#' @param show_percent Print percentages inside the segments
#'   (default `TRUE`).
#' @param min_segment Minimum segment width, in plot units, for a percentage
#'   to be printed (default 34).
#' @param arc_style `"gradient"` (default) colors each U-turn midway between
#'   the levels at its two ends; `"neutral"` draws it grey.
#' @param arc_opacity Opacity of the U-turns, between 0 and 1 (default 0.5).
#' @param sort_by Order of the items: `"none"` (default, input order),
#'   `"mean"` (increasing item mean) or `"net"` (increasing share of
#'   responses above the middle level minus share below; the mean for scales
#'   with fewer than four levels).
#' @param shadow Draw drop shadows (default `TRUE`).
#' @param show_legend Draw the legend (default `TRUE`).
#' @param label_color,label_size Color and size multiplier of the item labels
#'   (defaults `"#333333"` and 0.85).
#' @param label_align Alignment of the item labels: `"left"` (default),
#'   `"right"`, or `"direction"` to follow each band's reading direction.
#' @param reverse_rtl Reverse the order of levels on bands that read right
#'   to left, so every band starts with the lowest level in its reading
#'   direction (default `FALSE`: lowest level on the left of every band).
#' @param start_from Side on which the first band starts: `"left"` (default)
#'   or `"right"`.
#' @param flow `"snake"` (default): bands alternate direction. `"natural"`:
#'   every band reads in the same direction.
#' @param title Plot title, or `NULL` (default) for none.
#' @param margin Named numeric vector of `top`, `right`, `bottom` and `left`
#'   margins in plot units (default
#'   `c(top = 30, right = 10, bottom = 55, left = 100)`).
#' @param background Background color (default `"white"`).
#'
#' @return The plot is drawn on the current device. The function returns,
#'   invisibly, an object of class `snake_layout`: a list describing the drawn
#'   geometry, with `bands` (a data frame with one row per item band giving
#'   its index, position, and drawing and reading direction), `arcs` (a list
#'   with one element per U-turn), `canvas` and `plot_area` (dimensions in
#'   plot units), `orientation`, `flow` and `params` (the sizes used).
#'
#' @references
#' Heiberger, R. M., & Robbins, N. B. (2014). Design of diverging stacked bar
#' charts for Likert scales and other applications. *Journal of Statistical
#' Software*, 57(5), 1-32. \doi{10.18637/jss.v057.i05}
#'
#' @seealso [sequential_dist()] for single-hue bars; [survey_snake()] for
#'   individual responses and item correlations; [snake_palette()] for level
#'   colors.
#'
#' @examples
#' # Ten emotion items, sorted by net score
#' survey_sequence(ema_emotions, sort_by = "net")
#'
#' # Study motivation items with another diverging palette
#' motivation <- subset(student_survey,
#'                      select = Mot_Disappointed:Mot_Enjoyment)
#' survey_sequence(motivation, sort_by = "mean",
#'                 colors = snake_palette("ocean", n = 5))
#'
#' @export
survey_sequence <- function(counts, labels = NULL, levels = NULL,
                            band_height   = 28,
                            band_gap      = 14,
                            plot_width    = 500,
                            colors        = NULL,
                            show_percent      = TRUE,
                            min_segment = 34,
                            arc_style      = c("gradient", "neutral"),
                            arc_opacity   = 0.5,
                            sort_by       = c("none", "mean", "net"),
                            shadow        = TRUE,
                            show_legend   = TRUE,
                            label_color   = "#333333",
                            label_size     = 0.85,
                            label_align   = "left",
                            reverse_rtl   = FALSE,
                            start_from    = c("left", "right"),
                            flow          = c("snake", "natural"),
                            title         = NULL,
                            margin        = c(top = 30, right = 10,
                                              bottom = 55, left = 100),
                            background            = "white") {
  coerced <- coerce_survey_input(counts, labels, levels)
  counts  <- coerced$counts
  labels  <- coerced$labels
  levels  <- coerced$levels

  if (is.data.frame(counts)) counts <- as.matrix(counts) # nocov
  validate_survey_data(counts, labels, levels)
  arc_style   <- match.arg(arc_style)
  sort_by    <- match.arg(sort_by)
  start_from <- match.arg(start_from)
  flow       <- match.arg(flow)

  n_items  <- nrow(counts)
  n_levels <- ncol(counts)
  if (is.null(colors)) colors <- diverging_palette(n_levels)

  # Proportions
  row_totals <- rowSums(counts)
  props <- counts / row_totals  # each row sums to 1

  # Sort
  level_vals <- seq_len(n_levels)
  item_means <- vapply(seq_len(n_items), function(i) {
    stats::weighted.mean(level_vals, counts[i, ])
  }, numeric(1))
  net_scores <- if (n_levels >= 4) {
    mid <- ceiling(n_levels / 2)
    neg <- rowSums(counts[, seq_len(mid - 1L), drop = FALSE])
    pos <- rowSums(counts[, seq(mid + 1L, n_levels), drop = FALSE])
    (pos - neg) / row_totals
  } else {
    item_means
  }
  item_order <- switch(sort_by,
    none = seq_len(n_items),
    mean = order(item_means),
    net  = order(net_scores)
  )
  props   <- props[item_order, , drop = FALSE]
  labels  <- labels[item_order]

  # Layout
  if (show_legend) margin["bottom"] <- margin["bottom"] + 15
  if (!is.null(title)) margin["top"] <- margin["top"] + 18
  layout <- compute_snake_layout(n_items, band_height, band_gap,
                                 plot_width, margin,
                                 start_from = start_from,
                                 flow = flow)
  op <- setup_canvas(layout, bg = background)
  on.exit(par(op), add = TRUE)

  if (!is.null(title)) {
    text(layout$canvas$width / 2, 14, title,
         col = "#333333", cex = 1.1, font = 2)
  }

  if (shadow) draw_shadows(layout)

  bands <- layout$bands

  # Draw arcs (with gradient or neutral coloring)
  lapply(seq_along(layout$arcs), function(a_idx) {
    a <- layout$arcs[[a_idx]]
    if (arc_style == "neutral") {
      acol <- alpha_col("#999999", arc_opacity)
    } else {
      # Gradient: blend end color of from-band with start color of to-band
      # End cap color depends on whether segments reverse on RTL
      i_from <- a$from + 1L
      dir_from <- bands$direction[i_from]
      if (reverse_rtl && dir_from == "rtl") {
        end_level   <- 1L
        start_level <- n_levels
      } else {
        end_level   <- n_levels
        start_level <- 1L
      }
      acol <- alpha_col(
        grDevices::colorRampPalette(c(colors[end_level],
                                      colors[start_level]))(3)[2],
        arc_opacity
      )
    }
    polygon(a$pts$x, a$pts$y, col = acol, border = NA)
  })

  # End caps — color matches the first/last segment of that band
  bh2 <- band_height / 2
  first_dir <- bands$direction[1]
  cap_side1 <- if (first_dir == "ltr") "left" else "right"
  cap_x1 <- if (cap_side1 == "left") bands$x_left[1] else bands$x_right[1]
  cap_col1 <- colors[1]  # always first level on the left
  cap1 <- end_cap_polygon(cap_x1, bands$y_center[1], bh2, cap_side1)
  polygon(cap1$x, cap1$y, col = alpha_col(cap_col1, 0.85), border = NA)

  if (n_items > 1L) {
    last <- n_items
    last_dir <- bands$direction[last]
    cap_side2 <- if (last_dir == "ltr") "right" else "left"
    cap_x2 <- if (cap_side2 == "right") bands$x_right[last] else bands$x_left[last]
    cap_col2 <- colors[n_levels]  # always last level on the right
    cap2 <- end_cap_polygon(cap_x2, bands$y_center[last], bh2, cap_side2)
    polygon(cap2$x, cap2$y, col = alpha_col(cap_col2, 0.85), border = NA)
  }

  # Draw stacked segments on each band
  vapply(seq_len(n_items), function(k) {
    dir <- bands$read_direction[k]
    xl  <- bands$x_left[k]
    xr  <- bands$x_right[k]
    yt  <- bands$y_top[k]
    yb  <- bands$y_bottom[k]
    pw  <- xr - xl

    p <- props[k, ]
    # Optionally reverse segment order for RTL bands
    seg_order <- if (reverse_rtl && dir == "rtl") {
      rev(seq_len(n_levels))
    } else {
      seq_len(n_levels)
    }
    seg_colors <- colors[seg_order]
    seg_props  <- p[seg_order]
    seg_pcts   <- round(seg_props * 100)

    # Draw segments left-to-right
    x_cursor <- xl
    vapply(seq_along(seg_order), function(s) {
      seg_w <- seg_props[s] * pw
      rect(x_cursor, yt, x_cursor + seg_w, yb,
           col = seg_colors[s], border = NA)

      # Percentage label
      if (show_percent && seg_w >= min_segment && seg_pcts[s] > 0) {
        lbl_x <- x_cursor + seg_w / 2
        lbl_y <- (yt + yb) / 2
        # Auto text color: white on dark, dark on light
        rgb_vals <- grDevices::col2rgb(seg_colors[s])
        luminance <- (0.299 * rgb_vals[1] + 0.587 * rgb_vals[2] +
                        0.114 * rgb_vals[3]) / 255
        tcol <- if (luminance < 0.5) "white" else "#333333"
        text(lbl_x, lbl_y, sprintf("%d%%", seg_pcts[s]),
             col = tcol, cex = 0.6)
      }
      x_cursor <<- x_cursor + seg_w
      NA
    }, logical(1))
    NA
  }, logical(1))

  # Labels
  draw_band_labels(layout, labels, col = label_color, cex = label_size,
                   align = label_align)

  # Legend
  if (show_legend) {
    items <- lapply(seq_len(n_levels), function(j) {
      list(label = levels[j], color = colors[j])
    })
    draw_snake_legend(layout, items, cex = 0.7)
  }

  invisible(layout)
}


#' Plot unipolar survey responses as a serpentine of single-hue stacked bars
#'
#' @description
#' `sequential_dist()` draws the survey sequence plot of [survey_sequence()],
#' one 100% stacked bar per item along a serpentine, with a light-to-dark
#' palette of a single hue, so that darker segments stand for higher levels.
#' It is meant for rating scales with no neutral midpoint: frequency scales
#' from "Never" to "Always", or intensity scales from "Not at all" to
#' "Extremely". For such scales a diverging palette suggests a midpoint the
#' scale does not have.
#'
#' Input, sorting, labels and layout options are those of
#' [survey_sequence()]; `hue` sets the color of the palette. It returns the
#' value of [survey_sequence()], a `snake_layout` object, invisibly. For bipolar
#' (agree-disagree) scales use [survey_sequence()]; to show individual
#' responses use [survey_snake()].
#'
#' @inheritParams survey_sequence
#' @param hue Hue of the palette in degrees, 0-360 (default 210, blue).
#' @param colors One color per response level, in scale order. `NULL`
#'   (default) uses a light-to-dark palette of `hue`.
#' @param arc_opacity Opacity of the U-turns, between 0 and 1 (default 0.85).
#'
#' @return The value of [survey_sequence()]: the plot is drawn on the current
#'   device and an object of class `snake_layout` is returned invisibly.
#'
#' @references
#' Heiberger, R. M., & Robbins, N. B. (2014). Design of diverging stacked bar
#' charts for Likert scales and other applications. *Journal of Statistical
#' Software*, 57(5), 1-32. \doi{10.18637/jss.v057.i05}
#'
#' @seealso [survey_sequence()] for diverging colors; [survey_snake()] for
#'   individual responses; [snake_palette()] for the sequential palettes
#'   `"blues"`, `"greens"`, `"grays"`, `"warm"` and `"viridis"`.
#'
#' @examples
#' # Emotion intensity rated 1-5, a unipolar scale
#' sequential_dist(ema_emotions, sort_by = "mean", hue = 160)
#'
#' # A table of counts on a frequency scale
#' counts <- matrix(c(15, 25, 60, 80, 45,
#'                    10, 20, 50, 90, 55,
#'                    20, 30, 65, 70, 40),
#'                  nrow = 3, byrow = TRUE)
#' sequential_dist(counts,
#'                 labels = c("Plans study time", "Reviews notes",
#'                            "Asks for help"),
#'                 levels = c("Never", "Rarely", "Sometimes", "Often",
#'                            "Always"))
#'
#' @export
sequential_dist <- function(counts, labels = NULL, levels = NULL,
                            hue = 210,
                            band_height    = 28,
                            band_gap       = 14,
                            plot_width     = 500,
                            colors         = NULL,
                            show_percent       = TRUE,
                            min_segment = 34,
                            arc_style       = c("gradient", "neutral"),
                            arc_opacity    = 0.85,
                            sort_by        = c("none", "mean", "net"),
                            shadow         = TRUE,
                            show_legend    = TRUE,
                            label_color    = "#333333",
                            label_size      = 0.85,
                            label_align    = "left",
                            reverse_rtl    = FALSE,
                            start_from     = c("left", "right"),
                            flow           = c("snake", "natural"),
                            title          = NULL,
                            margin         = c(top = 30, right = 10,
                                              bottom = 55, left = 100),
                            background             = "white") {
  start_from <- match.arg(start_from)
  flow       <- match.arg(flow)
  coerced <- coerce_survey_input(counts, labels, levels)
  counts  <- coerced$counts
  labels  <- coerced$labels
  levels  <- coerced$levels

  if (is.data.frame(counts)) counts <- as.matrix(counts) # nocov
  n_levels <- ncol(counts)
  if (is.null(colors)) colors <- sequential_palette(n_levels, hue)

  survey_sequence(counts = counts, labels = labels, levels = levels,
                  band_height = band_height, band_gap = band_gap,
                  plot_width = plot_width, colors = colors,
                  show_percent = show_percent, min_segment = min_segment,
                  arc_style = arc_style, arc_opacity = arc_opacity,
                  sort_by = sort_by, shadow = shadow,
                  show_legend = show_legend, label_color = label_color,
                  label_size = label_size, label_align = label_align,
                  reverse_rtl = reverse_rtl, start_from = start_from,
                  flow = flow, title = title, margin = margin,
                  background = background)
}
