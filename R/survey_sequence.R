#' Survey Sequence Plot
#'
#' Each survey item is a 100\% stacked horizontal bar in a serpentine layout.
#' Color segments represent response levels; percentages are shown inside
#' segments when wide enough. Arcs blend adjacent end-colors.
#'
#' @param counts Numeric matrix of response counts (rows=items, cols=levels).
#' @param labels Character vector of item labels.
#' @param levels Character vector of level labels.
#' @param band_height Numeric (default 28).
#' @param band_gap Numeric (default 14).
#' @param plot_width Numeric (default 500).
#' @param colors Character vector of segment colors. Default: diverging palette.
#' @param show_percent Logical. Show percentages inside segments (default TRUE).
#' @param min_segment Numeric. Hide label if segment narrower than this
#'   (default 34).
#' @param arc_style Character: "gradient" or "neutral" (default "gradient").
#' @param arc_opacity Numeric 0-1 (default 0.5).
#' @param sort_by Character: "none", "mean", "net" (default "none").
#' @param shadow Logical (default TRUE).
#' @param show_legend Logical (default TRUE).
#' @param label_color Character (default "#333333").
#' @param label_size Numeric (default 0.85).
#' @param label_align Character. Label alignment: "left" (default), "right",
#'   or "direction" (follows band reading direction).
#' @param reverse_rtl Logical. Reverse segment order on right-to-left bands
#'   so the visual reading direction mirrors the data order (default FALSE).
#' @param start_from Character: "left" (default) or "right". Which side the
#'   first band starts from.
#' @param flow Character, \code{"snake"} (default) or \code{"natural"}.
#'   \code{"snake"} uses alternating boustrophedon direction;
#'   \code{"natural"} reads all bands in the same direction.
#' @param title Optional title.
#' @param margin Named numeric vector.
#' @param background Background color.
#'
#' @return Invisible \code{snake_layout} object.
#'
#' @examples
#' counts <- matrix(c(
#'   110, 210, 79, 84, 42,
#'   126, 205, 68, 100, 26,
#'   184, 226, 47, 58, 10,
#'   200, 205, 52, 47, 21,
#'   205, 210, 42, 53, 15,
#'   197, 214, 53, 47, 14,
#'   194, 242, 47, 31, 11
#' ), nrow = 7, byrow = TRUE)
#' labels <- c("LOC1", "LOC2", "LOC3", "CCA1", "LOC5", "LOC5", "LOC4")
#' labels <- paste0(labels, " (n=525)")
#' levs <- as.character(1:5)
#' survey_sequence(counts, labels, levs)
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


#' Sequential Distribution Plot
#'
#' Like \code{\link{survey_sequence}} but uses a sequential (monochrome)
#' palette instead of diverging colors. Suitable for ordinal scales without
#' a natural midpoint (e.g., "Never" to "Always").
#'
#' @inheritParams survey_sequence
#' @param hue Numeric 0-360. Base hue for the sequential palette
#'   (default 210 = blue).
#'
#' @return Invisible \code{snake_layout} object.
#'
#' @examples
#' counts <- matrix(c(
#'   15, 25, 60, 80, 45,
#'   10, 20, 50, 90, 55,
#'   20, 30, 65, 70, 40
#' ), nrow = 3, byrow = TRUE)
#' labels <- c("Behavior A", "Behavior B", "Behavior C")
#' levs <- c("Never", "Rarely", "Sometimes", "Often", "Always")
#' sequential_dist(counts, labels, levs, hue = 160)
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
