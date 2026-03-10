#' Set up the base R plotting canvas for a snake layout
#'
#' @param layout A snake_layout object.
#' @param bg Background color.
#' @return The previous par settings (for on.exit restoration).
#' @noRd
setup_canvas <- function(layout, bg = "white") {
  op <- par(mar = c(0, 0, 0, 0), bg = bg, xpd = TRUE)
  plot.new()
  plot.window(
    xlim = c(0, layout$canvas$width),
    ylim = c(layout$canvas$height, 0),
    asp  = NA
  )
  op
}

#' Draw drop shadows behind bands and arcs
#'
#' @param layout snake_layout.
#' @param shadow_color Color for shadow.
#' @param shadow_opacity Opacity 0-1.
#' @param offset Numeric vector c(dx, dy) for shadow offset.
#' @noRd
draw_shadows <- function(layout, shadow_color = "#adb5bd",
                         shadow_opacity = 0.12, offset = c(3, 3)) {
  scol <- alpha_col(shadow_color, shadow_opacity)
  bands <- layout$bands

  # Band shadows
  rect(bands$x_left + offset[1], bands$y_top + offset[2],
       bands$x_right + offset[1], bands$y_bottom + offset[2],
       col = scol, border = NA)

  # Arc shadows
  lapply(layout$arcs, function(a) {
    polygon(a$pts$x + offset[1], a$pts$y + offset[2],
            col = scol, border = NA)
  })
  invisible(NULL)
}

#' Draw the snake ribbon: bands + arcs + end caps
#'
#' @param layout snake_layout.
#' @param band_colors Character vector of colors (recycled per band).
#' @param arc_color Single color for arcs.
#' @param band_opacity Numeric 0-1.
#' @param arc_opacity Numeric 0-1.
#' @param end_caps Logical, draw semicircular end caps.
#' @noRd
draw_ribbon <- function(layout, band_colors = "#3d2518",
                        arc_color = "#1a1a2e",
                        band_opacity = 0.85, arc_opacity = 0.85,
                        end_caps = TRUE) {
  bands <- layout$bands
  n <- nrow(bands)
  bcols <- cycle_colors(band_colors, n)

  # Draw arcs first (behind bands at connection points)
  acol <- alpha_col(arc_color, arc_opacity)
  lapply(layout$arcs, function(a) {
    polygon(a$pts$x, a$pts$y, col = acol, border = NA)
  })

  # Draw bands
  vapply(seq_len(n), function(k) {
    rect(bands$x_left[k], bands$y_top[k],
         bands$x_right[k], bands$y_bottom[k],
         col = alpha_col(bcols[k], band_opacity), border = NA)
    NA
  }, logical(1))

  # End caps
  if (end_caps && n > 0L) {
    bh2 <- layout$params$band_height / 2
    vert <- identical(layout$orientation, "vertical")

    if (!vert) {
      # Horizontal end caps
      first_dir <- bands$direction[1]
      cap_side_first <- if (first_dir == "ltr") "left" else "right"
      cap_x_first <- if (cap_side_first == "left") {
        bands$x_left[1]
      } else {
        bands$x_right[1]
      }
      cap1 <- end_cap_polygon(cap_x_first, bands$y_center[1], bh2,
                              cap_side_first)
      polygon(cap1$x, cap1$y,
              col = alpha_col(bcols[1], band_opacity), border = NA)

      if (n > 1L) {
        last_dir <- bands$direction[n]
        if (last_dir == "ltr") {
          cap2 <- end_cap_polygon(bands$x_right[n], bands$y_center[n],
                                  bh2, "right")
        } else {
          cap2 <- end_cap_polygon(bands$x_left[n], bands$y_center[n],
                                  bh2, "left")
        }
        polygon(cap2$x, cap2$y,
                col = alpha_col(bcols[n], band_opacity), border = NA)
      }
    } else {
      # Vertical end caps (top/bottom of columns)
      first_dir <- bands$direction[1]
      cap_side_first <- if (first_dir == "ttb") "top" else "bottom"
      cap_y_first <- if (cap_side_first == "top") {
        bands$y_top[1]
      } else {
        bands$y_bottom[1]
      }
      cap1 <- end_cap_polygon(bands$x_center[1], cap_y_first, bh2,
                              cap_side_first)
      polygon(cap1$x, cap1$y,
              col = alpha_col(bcols[1], band_opacity), border = NA)

      if (n > 1L) {
        last_dir <- bands$direction[n]
        if (last_dir == "ttb") {
          cap2 <- end_cap_polygon(bands$x_center[n], bands$y_bottom[n],
                                  bh2, "bottom")
        } else {
          cap2 <- end_cap_polygon(bands$x_center[n], bands$y_top[n],
                                  bh2, "top")
        }
        polygon(cap2$x, cap2$y,
                col = alpha_col(bcols[n], band_opacity), border = NA)
      }
    }
  }
  invisible(NULL)
}

#' Draw vertical gridlines across all bands
#'
#' @param layout snake_layout.
#' @param positions Numeric vector of x-positions in plot coords.
#' @param col Gridline color.
#' @param lwd Line width.
#' @noRd
draw_gridlines <- function(layout, positions, col = "rgba(255,255,255,0.25)",
                           lwd = 0.5) {
  # Parse rgba if needed
  if (grepl("^rgba", col)) col <- parse_rgba(col)
  bands <- layout$bands
  n <- nrow(bands)
  # Draw a segment through each band at each position
  for (pos in positions) {
    segments(
      x0 = rep(pos, n), y0 = bands$y_top,
      x1 = rep(pos, n), y1 = bands$y_bottom,
      col = col, lwd = lwd
    )
  }
  invisible(NULL)
}

#' Draw day/item labels in the gaps between bands
#'
#' @param layout snake_layout.
#' @param labels Character vector (one per band).
#' @param totals Optional character vector of duration totals.
#' @param col Label color.
#' @param cex Font size multiplier.
#' @param align Label alignment: "left", "right", or "direction" (follows
#'   band reading direction). Default "left".
#' @noRd
draw_band_labels <- function(layout, labels, totals = NULL,
                             col = "#333333", cex = 0.85,
                             align = "left") {
  bands <- layout$bands
  n <- nrow(bands)
  bg <- layout$params$band_gap
  stopifnot(length(labels) == n)
  vert <- identical(layout$orientation, "vertical")

  label_text <- if (!is.null(totals)) {
    paste(labels, totals)
  } else {
    labels
  }

  if (!vert) {
    # Horizontal: labels in gaps above bands
    vapply(seq_len(n), function(k) {
      lbl_y <- if (k == 1L) {
        bands$y_top[k] - bg / 2
      } else {
        (bands$y_bottom[k - 1L] + bands$y_top[k]) / 2
      }
      if (align == "direction") {
        lbl_x <- if (bands$read_direction[k] == "ltr") {
          bands$x_left[k]
        } else {
          bands$x_right[k]
        }
        adj_x <- if (bands$read_direction[k] == "ltr") 0 else 1
      } else if (align == "right") {
        lbl_x <- bands$x_right[k]
        adj_x <- 1
      } else {
        lbl_x <- bands$x_left[k]
        adj_x <- 0
      }
      text(lbl_x, lbl_y, label_text[k], adj = c(adj_x, 0.5),
           col = col, cex = cex, font = 1)
      NA
    }, logical(1))
  } else {
    # Vertical: labels above each column, rotated 45° to avoid overlap
    vapply(seq_len(n), function(k) {
      lbl_x <- bands$x_center[k]
      lbl_y <- bands$y_top[k] - bg * 0.8
      text(lbl_x, lbl_y, label_text[k], adj = c(0.5, 1),
           col = col, cex = cex * 0.85, font = 1, srt = 45)
      NA
    }, logical(1))
  }
  invisible(NULL)
}

#' Draw hour labels along the bottom of the plot
#'
#' @param layout snake_layout.
#' @param hour_positions Named numeric vector (names = labels, values = x-pos).
#' @param col Label color.
#' @param cex Font size.
#' @noRd
draw_hour_labels <- function(layout, hour_positions, col = "#888888",
                             cex = 0.75) {
  y_pos <- layout$canvas$height - layout$params$margin["bottom"] / 2
  text(hour_positions, rep(y_pos, length(hour_positions)),
       names(hour_positions), col = col, cex = cex)
  invisible(NULL)
}

#' Draw "12AM" or custom label at arc tips
#'
#' @param layout snake_layout.
#' @param label Text to show at each arc tip.
#' @param col Color.
#' @param cex Size.
#' @noRd
draw_arc_labels <- function(layout, label = "12AM", col = "#666666",
                            cex = 0.6) {
  lapply(layout$arcs, function(a) {
    text(a$tip_x, a$tip_y, label, col = col, cex = cex,
         adj = c(if (a$side == "right") 0 else 1, 0.5))
  })
  invisible(NULL)
}

#' Draw a legend below the plot
#'
#' @param layout snake_layout.
#' @param items List of lists with 'label' and 'color' elements.
#' @param cex Font size.
#' @noRd
draw_snake_legend <- function(layout, items, cex = 0.8) {
  if (length(items) == 0L) return(invisible(NULL))

  y_pos <- layout$canvas$height - 10
  total_width <- sum(vapply(items, function(it) {
    strwidth(it$label, cex = cex) + 18
  }, numeric(1)))
  x_start <- (layout$canvas$width - total_width) / 2
  x_cur <- x_start

  lapply(items, function(it) {
    item_type <- if (!is.null(it$type)) it$type else "rect"
    if (item_type == "tick") {
      # Vertical tick line
      segments(x_cur + 2, y_pos - 6, x_cur + 2, y_pos + 6,
               col = it$color, lwd = 2.5)
      text(x_cur + 8, y_pos, it$label, adj = c(0, 0.5),
           col = "#333333", cex = cex)
      x_cur <<- x_cur + strwidth(it$label, cex = cex) + 20
    } else if (item_type == "gradient") {
      # Gradient swatch (two-tone rect)
      rect(x_cur, y_pos - 5, x_cur + 14, y_pos + 5,
           col = it$color, border = NA)
      text(x_cur + 18, y_pos, it$label, adj = c(0, 0.5),
           col = "#333333", cex = cex)
      x_cur <<- x_cur + strwidth(it$label, cex = cex) + 28
    } else {
      # Default: filled rect
      rect(x_cur, y_pos - 5, x_cur + 10, y_pos + 5,
           col = it$color, border = NA)
      text(x_cur + 14, y_pos, it$label, adj = c(0, 0.5),
           col = "#333333", cex = cex)
      x_cur <<- x_cur + strwidth(it$label, cex = cex) + 24
    }
  })
  invisible(NULL)
}

#' Parse an rgba() CSS string to an R color with alpha
#'
#' @param rgba_str Character like "rgba(255,255,255,0.25)".
#' @return Hex color string with alpha.
#' @noRd
parse_rgba <- function(rgba_str) {
  vals <- regmatches(rgba_str,
                     gregexpr("[0-9]*\\.?[0-9]+", rgba_str))[[1]]
  if (length(vals) < 4L) return("#FFFFFF40")
  r <- as.integer(vals[1])
  g <- as.integer(vals[2])
  b <- as.integer(vals[3])
  a <- as.numeric(vals[4])
  grDevices::rgb(r, g, b, alpha = round(a * 255), maxColorValue = 255)
}
