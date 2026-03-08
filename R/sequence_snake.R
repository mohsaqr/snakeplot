#' Sequence Index Snake Plot
#'
#' Displays a state sequence as colored blocks flowing through a serpentine
#' (boustrophedon) layout. Each block represents one time point colored by
#' its state. Blocks flow continuously through both bands AND arcs, wrapping
#' a long sequence into a compact multi-row display.
#'
#' @param sequence Character, integer, or factor vector of states.
#'   Each element represents one time point.
#' @param alphabet Character vector of unique states in desired order.
#'   If \code{NULL}, derived from \code{unique(sequence)}.
#' @param colors Named character vector of colors keyed by state, or an
#'   unnamed vector recycled to match \code{alphabet}. If \code{NULL},
#'   a built-in qualitative palette is used.
#' @param n_rows Integer, number of serpentine rows. If \code{NULL},
#'   auto-calculated targeting approximately 10 blocks per band.
#' @param band_height Numeric, height of each band in pixels (default 28).
#' @param band_gap Numeric, gap between bands (default 18).
#' @param plot_width Numeric, width of each band (default 500).
#' @param margin Named numeric vector with top, right, bottom, left margins.
#' @param orientation Character, \code{"horizontal"} (default) or
#'   \code{"vertical"}.
#' @param start_from Character, \code{"left"} (default) or \code{"right"}.
#' @param show_labels Logical, show position range labels per row
#'   (default \code{TRUE}).
#' @param show_legend Logical, draw color legend (default \code{TRUE}).
#' @param show_index Logical, print small position numbers inside blocks
#'   (default \code{FALSE}).
#' @param show_state Logical, print the state name inside each block
#'   (default \code{FALSE}).
#' @param state_cex Numeric, text size for state labels (default 0.35).
#' @param show_ticks Logical, draw ruler-style tick marks at block
#'   boundaries outside the bands (default \code{FALSE}).
#' @param tick_labels Character vector of labels for evenly spaced ruler
#'   marks within each band (e.g., \code{month.abb} for monthly ticks).
#'   Implies \code{show_ticks = TRUE}.
#' @param transition_labels Character vector of date labels for state
#'   transition points (e.g., \code{c("Oct 2017", "Apr 2019")}). One
#'   label per transition (length = number of state changes).
#' @param transition_pos Numeric vector of fractional block positions for
#'   transition labels (e.g., \code{c(6.5, 24.3)}). When provided, labels
#'   are placed at exact interpolated positions along the serpentine path
#'   rather than at state-change boundaries.
#' @param tick_col Color for tick marks (default \code{"#333333"}).
#' @param tick_len Numeric, length of tick marks in pixels (default 5).
#' @param tick_cex Numeric, text size for tick labels (default 0.4).
#' @param block_border Color for thin borders between blocks, or \code{NA}
#'   for no borders (default \code{NA}).
#' @param title Optional character string for plot title.
#' @param bg Background color (default \code{"white"}).
#' @param shadow Logical, draw drop shadows (default \code{TRUE}).
#' @param block_labels Optional character vector of labels to display inside
#'   each block (same length as \code{sequence}). Overrides \code{show_index}.
#' @param band_labels Character vector of labels to display centered below
#'   each band (e.g., year labels). Length must equal \code{n_rows}.
#' @param cex Numeric, text size multiplier for block labels (default 0.5).
#' @param legend_cex Numeric, legend text size (default 0.8).
#'
#' @return Invisible \code{NULL}. Called for its side effect of producing
#'   a plot.
#'
#' @examples
#' set.seed(42)
#' verbs <- c("Read", "Write", "Discuss", "Listen",
#'            "Search", "Plan", "Code", "Review")
#' seq75 <- sample(verbs, 75, replace = TRUE)
#' sequence_snake(seq75)
#'
#' # Custom colors
#' cols <- c(Read = "#E41A1C", Write = "#377EB8", Discuss = "#4DAF4A",
#'           Listen = "#984EA3", Search = "#FF7F00", Plan = "#A6D854",
#'           Code = "#A65628", Review = "#F781BF")
#' sequence_snake(seq75, colors = cols, n_rows = 5)
#'
#' @export
sequence_snake <- function(sequence,
                           alphabet = NULL,
                           colors = NULL,
                           n_rows = NULL,
                           band_height = 28,
                           band_gap = 18,
                           plot_width = 500,
                           margin = c(top = 30, right = 10,
                                      bottom = 50, left = 80),
                           orientation = "horizontal",
                           start_from = "left",
                           show_labels = TRUE,
                           show_legend = TRUE,
                           show_index = FALSE,
                           show_state = FALSE,
                           state_cex = 0.35,
                           show_ticks = FALSE,
                           tick_labels = NULL,
                           transition_labels = NULL,
                           transition_pos = NULL,
                           tick_col = "#333333",
                           tick_len = 5,
                           tick_cex = 0.4,
                           block_border = NA,
                           block_labels = NULL,
                           band_labels = NULL,
                           title = NULL,
                           bg = "white",
                           shadow = TRUE,
                           cex = 0.5,
                           legend_cex = 0.8) {
  # --- Input validation ---
  stopifnot(length(sequence) >= 1L)
  sequence <- as.character(sequence)
  if (any(is.na(sequence))) {
    stop("'sequence' contains NA values", call. = FALSE)
  }
  n_blocks <- length(sequence)

  if (is.null(alphabet)) {
    alphabet <- unique(sequence)
  }
  alphabet <- as.character(alphabet)
  n_states <- length(alphabet)

  # Validate all states are in alphabet
  unknown <- setdiff(unique(sequence), alphabet)
  if (length(unknown) > 0L) {
    stop(sprintf("Unknown states not in alphabet: %s",
                 paste(unknown, collapse = ", ")), call. = FALSE)
  }

  # --- Block labels ---
  if (!is.null(block_labels)) {
    block_labels <- as.character(block_labels)
    if (length(block_labels) != n_blocks) {
      stop(sprintf("length(block_labels) = %d but length(sequence) = %d; must match",
                   length(block_labels), n_blocks), call. = FALSE)
    }
    # When ticks are on, labels go outside; otherwise inside blocks
    if (!show_ticks && is.null(tick_labels)) show_index <- TRUE
  }

  # --- Colors ---
  state_colors <- resolve_state_colors(colors, alphabet, n_states)

  # --- Auto-calculate n_rows ---
  if (is.null(n_rows)) {
    n_rows <- max(1L, ceiling(n_blocks / 11))
  }
  stopifnot(is.numeric(n_rows), length(n_rows) == 1L, n_rows >= 1L)
  n_rows <- as.integer(n_rows)

  # --- Band labels validation ---
  if (!is.null(band_labels)) {
    band_labels <- as.character(band_labels)
    if (length(band_labels) != n_rows) {
      stop(sprintf("length(band_labels) = %d but n_rows = %d; must match",
                   length(band_labels), n_rows), call. = FALSE)
    }
  }

  # --- Layout ---
  layout <- compute_snake_layout(
    n_bands = n_rows, band_height = band_height, band_gap = band_gap,
    plot_width = plot_width, margin = margin,
    orientation = orientation, start_from = start_from
  )

  bands  <- layout$bands
  arcs   <- layout$arcs
  params <- layout$params
  outer_r <- params$outer_r
  inner_r <- params$inner_r
  r_mid   <- (outer_r + inner_r) / 2

  # --- Build segment table (band, arc, band, arc, ..., band) ---
  seg_info <- build_segment_table(n_rows, plot_width, r_mid)

  # --- Allocate blocks to segments ---
  alloc <- allocate_blocks(seg_info$path_length, n_blocks)
  cum_start <- c(0L, cumsum(alloc))

  # --- Set up canvas ---
  op <- setup_canvas(layout, bg = bg)
  on.exit(par(op), add = TRUE)

  # Title
  if (!is.null(title)) {
    text(layout$canvas$width / 2, margin["top"] / 2, title,
         cex = 1.2, font = 2, col = "#333333")
  }

  # Shadows
  if (shadow) draw_shadows(layout)

  # --- Draw neutral arc backgrounds (connector color for empty arcs) ---
  lapply(arcs, function(a) {
    polygon(a$pts$x, a$pts$y, col = "#E0E0E0", border = NA)
  })

  # --- Draw blocks ---
  n_segments <- nrow(seg_info)
  lapply(seq_len(n_segments), function(seg) {
    m <- alloc[seg]
    if (m == 0L) return(invisible(NULL))

    block_start <- cum_start[seg] + 1L
    block_end   <- block_start + m - 1L
    block_states <- sequence[block_start:block_end]
    block_cols   <- state_colors[block_states]
    seg_labels   <- if (!is.null(block_labels)) {
      block_labels[block_start:block_end]
    } else {
      NULL
    }

    seg_st <- if (show_state) block_states else NULL

    if (seg_info$type[seg] == "band") {
      draw_band_blocks(bands[seg_info$index[seg], ], m, block_cols,
                       block_border, show_index, block_start, cex,
                       seg_labels, seg_st, state_cex)
    } else {
      draw_arc_blocks(arcs[[seg_info$index[seg]]], m, block_cols,
                      outer_r, inner_r, r_mid, block_border,
                      show_index, block_start, cex, seg_labels,
                      seg_st, state_cex)
    }
  })

  # --- Ruler ticks ---
  if (!is.null(tick_labels)) show_ticks <- TRUE
  if (show_ticks) {
    lapply(seq_len(n_rows), function(k) {
      b <- bands[k, ]
      bw <- b$x_right - b$x_left
      if (!is.null(tick_labels)) {
        # Labeled ruler: evenly spaced ticks with text
        n_tk <- length(tick_labels)
        frac <- seq(0, 1, length.out = n_tk + 1L)
        # Tick positions at boundaries
        if (b$direction %in% c("ltr", "ttb")) {
          tk_x <- b$x_left + frac * bw
        } else {
          tk_x <- b$x_right - frac * bw
        }
        # Internal boundary ticks (skip first and last)
        int_x <- tk_x[-c(1L, length(tk_x))]
        segments(int_x, b$y_top - tick_len, int_x, b$y_top,
                 col = tick_col, lwd = 0.6)
        segments(int_x, b$y_bottom, int_x, b$y_bottom + tick_len,
                 col = tick_col, lwd = 0.6)
        # Labels centered between boundary ticks
        mid_x <- (tk_x[-length(tk_x)] + tk_x[-1L]) / 2
        text(mid_x, b$y_bottom + tick_len + 5, tick_labels,
             cex = tick_cex, col = tick_col)
      } else {
        # Block-boundary ticks with optional labels outside
        seg_idx <- which(seg_info$type == "band" & seg_info$index == k)
        m <- alloc[seg_idx]
        if (m == 0L) return(invisible(NULL))
        coords <- band_block_x(b, m)
        # Internal boundary ticks
        if (m > 1L) {
          tick_x <- coords$x1[-m]
          segments(tick_x, b$y_top - tick_len, tick_x, b$y_top,
                   col = tick_col, lwd = 0.8)
          segments(tick_x, b$y_bottom, tick_x, b$y_bottom + tick_len,
                   col = tick_col, lwd = 0.8)
        }
        # Block labels outside (centered under each block)
        if (!is.null(block_labels)) {
          blk_start <- cum_start[seg_idx] + 1L
          blk_lbls <- block_labels[blk_start:(blk_start + m - 1L)]
          mid_x <- (coords$x0 + coords$x1) / 2
          text(mid_x, b$y_bottom + tick_len + 6, blk_lbls,
               cex = tick_cex, col = tick_col)
        }
      }
    })
  }

  # --- Transition markers ---
  if (!is.null(transition_labels)) {
    if (!is.null(transition_pos)) {
      # Fractional positions provided — true timeline placement
      n_trans <- min(length(transition_pos), length(transition_labels))
      lapply(seq_len(n_trans), function(ti) {
        draw_transition_mark_at(transition_pos[ti], transition_labels[ti],
                                 seg_info, alloc, cum_start, bands, arcs,
                                 outer_r, inner_r, tick_cex)
      })
    } else {
      # Default: place at state-change block boundaries
      runs <- rle(sequence)
      if (length(runs$lengths) > 1L) {
        trans_pos <- cumsum(runs$lengths)[-length(runs$lengths)]
        n_trans <- min(length(trans_pos), length(transition_labels))
        lapply(seq_len(n_trans), function(ti) {
          draw_transition_mark(trans_pos[ti], transition_labels[ti],
                                seg_info, alloc, cum_start, bands, arcs,
                                outer_r, tick_cex)
        })
      }
    }
  }

  # --- Band labels (centered below each band) ---
  if (!is.null(band_labels)) {
    lapply(seq_len(n_rows), function(k) {
      b <- bands[k, ]
      mid_x <- (b$x_left + b$x_right) / 2
      text(mid_x, b$y_bottom + tick_len * 1.5 + 8, band_labels[k],
           cex = tick_cex * 1.3, col = tick_col, font = 1)
    })
  }

  # --- End caps ---
  draw_sequence_end_caps(layout, bands, n_rows, band_height,
                         orientation, state_colors, sequence, n_blocks)

  # --- Row labels ---
  if (show_labels) {
    band_idx <- which(seg_info$type == "band")
    range_labels <- vapply(band_idx, function(seg) {
      m <- alloc[seg]
      if (m == 0L) return("")
      s <- cum_start[seg] + 1L
      sprintf("%d-%d", s, s + m - 1L)
    }, character(1))
    draw_band_labels(layout, range_labels, col = "#333333", cex = 0.75)
  }

  # --- Legend ---
  if (show_legend) {
    legend_items <- lapply(seq_along(alphabet), function(i) {
      list(label = alphabet[i], color = state_colors[alphabet[i]])
    })
    draw_snake_legend(layout, legend_items, cex = legend_cex)
  }

  invisible(NULL)
}

# ---- Internal helpers --------------------------------------------------------

#' Resolve state colors from user input
#' @noRd
resolve_state_colors <- function(colors, alphabet, n_states) {
  # Default qualitative palette (Set2-inspired)
  default_pal <- c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3",
                   "#A6D854", "#FFD92F", "#E5C494", "#FB8072",
                   "#E41A1C", "#377EB8", "#4DAF4A", "#984EA3")

  if (is.null(colors)) {
    state_colors <- rep_len(default_pal, n_states)
    names(state_colors) <- alphabet
  } else if (!is.null(names(colors))) {
    state_colors <- colors[alphabet]
    missing <- is.na(state_colors)
    if (any(missing)) state_colors[missing] <- "#CCCCCC"
    names(state_colors) <- alphabet
  } else {
    state_colors <- rep_len(colors, n_states)
    names(state_colors) <- alphabet
  }
  state_colors
}

#' Build segment table (band/arc interleaved)
#' @noRd
build_segment_table <- function(n_rows, plot_width, r_mid) {
  band_df <- data.frame(
    type = rep("band", n_rows),
    index = seq_len(n_rows),
    path_length = rep(plot_width, n_rows),
    stringsAsFactors = FALSE
  )

  if (n_rows <= 1L) return(band_df)

  n_arcs <- n_rows - 1L
  arc_df <- data.frame(
    type = rep("arc", n_arcs),
    index = seq_len(n_arcs),
    path_length = rep(pi * r_mid, n_arcs),
    stringsAsFactors = FALSE
  )

  # Interleave: band1, arc1, band2, arc2, ..., band_n
  combined <- rbind(band_df, arc_df)
  band_pos <- seq(1L, by = 2L, length.out = n_rows)
  arc_pos  <- seq(2L, by = 2L, length.out = n_arcs)
  order_idx <- integer(n_rows + n_arcs)
  order_idx[band_pos] <- seq_len(n_rows)
  order_idx[arc_pos]  <- n_rows + seq_len(n_arcs)
  result <- combined[order_idx, ]
  rownames(result) <- NULL
  result
}

#' Allocate n items to segments proportionally
#'
#' Each segment gets at least 1 block when n_blocks >= n_segments,
#' then remaining blocks are distributed by largest remainder method.
#' @noRd
allocate_blocks <- function(seg_lengths, n_blocks) {
  n_seg <- length(seg_lengths)

  if (n_blocks >= n_seg) {
    alloc <- rep(1L, n_seg)
    remaining <- n_blocks - n_seg
    if (remaining > 0L) {
      total <- sum(seg_lengths)
      raw <- seg_lengths / total * remaining
      fl  <- floor(raw)
      remainders <- raw - fl
      deficit <- remaining - sum(fl)
      if (deficit > 0L) {
        bump <- order(remainders, decreasing = TRUE)[seq_len(deficit)]
        fl[bump] <- fl[bump] + 1L
      }
      alloc <- alloc + as.integer(fl)
    }
  } else {
    alloc <- rep(0L, n_seg)
    top_segs <- order(seg_lengths, decreasing = TRUE)[seq_len(n_blocks)]
    alloc[top_segs] <- 1L
  }
  alloc
}

#' Compute block x-coordinates within a band
#' @noRd
band_block_x <- function(b, m) {
  bw <- (b$x_right - b$x_left) / m
  if (b$direction %in% c("ltr", "ttb")) {
    x0 <- b$x_left + (seq_len(m) - 1L) * bw
    x1 <- b$x_left + seq_len(m) * bw
  } else {
    x0 <- b$x_right - seq_len(m) * bw
    x1 <- b$x_right - (seq_len(m) - 1L) * bw
  }
  list(x0 = x0, x1 = x1)
}

#' Draw colored blocks within a band
#' @noRd
draw_band_blocks <- function(b, m, block_cols, block_border,
                              show_index, block_start, cex,
                              seg_labels = NULL,
                              seg_states = NULL, state_cex = NULL) {
  coords <- band_block_x(b, m)
  # Draw rectangles
  rect(coords$x0, b$y_top, coords$x1, b$y_bottom,
       col = block_cols, border = block_border)
  # Block labels (year, index, etc.)
  if (show_index) {
    lbls <- if (!is.null(seg_labels)) seg_labels else block_start + seq_len(m) - 1L
    y_lbl <- if (!is.null(seg_states)) {
      b$y_center - (b$y_bottom - b$y_top) * 0.18
    } else {
      b$y_center
    }
    text((coords$x0 + coords$x1) / 2, y_lbl, lbls,
         cex = cex, col = "#FFFFFF")
  }
  # State labels — centered across runs of same state
  if (!is.null(seg_states)) {
    runs <- rle(seg_states)
    end_pos <- cumsum(runs$lengths)
    start_pos <- c(1L, end_pos[-length(end_pos)] + 1L)
    y_st <- if (show_index) {
      b$y_center + (b$y_bottom - b$y_top) * 0.22
    } else {
      b$y_center
    }
    lapply(seq_along(runs$values), function(r) {
      run_x0 <- coords$x0[start_pos[r]]
      run_x1 <- coords$x1[end_pos[r]]
      text((run_x0 + run_x1) / 2, y_st, runs$values[r],
           cex = state_cex, col = "#FFFFFF", font = 2)
    })
  }
  invisible(NULL)
}

#' Draw colored blocks (annular sectors) within an arc
#' @noRd
draw_arc_blocks <- function(a, m, block_cols, outer_r, inner_r, r_mid,
                             block_border, show_index, block_start, cex,
                             seg_labels = NULL,
                             seg_states = NULL, state_cex = NULL) {
  theta_per <- pi / m
  lapply(seq_len(m), function(j) {
    theta1 <- -pi / 2 + (j - 1L) * theta_per
    theta2 <- -pi / 2 + j * theta_per
    pts <- arc_sector_polygon(a$cx, a$cy, outer_r, inner_r,
                               theta1, theta2, a$side)
    polygon(pts$x, pts$y, col = block_cols[j], border = block_border)
    if (show_index || !is.null(seg_states)) {
      theta_mid <- (theta1 + theta2) / 2
      if (a$side %in% c("right", "left")) {
        sign_x <- if (a$side == "right") 1 else -1
        lx <- a$cx + sign_x * r_mid * cos(theta_mid)
        ly <- a$cy + r_mid * sin(theta_mid)
      } else {
        sign_y <- if (a$side == "bottom") 1 else -1
        lx <- a$cx + r_mid * sin(theta_mid)
        ly <- a$cy + sign_y * r_mid * cos(theta_mid)
      }
      if (show_index) {
        lbl <- if (!is.null(seg_labels)) seg_labels[j] else block_start + j - 1L
        text(lx, ly, lbl, cex = cex * 0.8, col = "#FFFFFF")
      }
    }
  })
  invisible(NULL)
}

#' Draw semicircular end caps colored by first/last state
#' @noRd
draw_sequence_end_caps <- function(layout, bands, n_rows, band_height,
                                    orientation, state_colors, sequence,
                                    n_blocks) {
  bh2  <- band_height / 2
  vert <- identical(orientation, "vertical")

  if (!vert) {
    # Start cap
    first_dir <- bands$direction[1]
    cap_side <- if (first_dir == "ltr") "left" else "right"
    cap_x <- if (cap_side == "left") bands$x_left[1] else bands$x_right[1]
    cap1 <- end_cap_polygon(cap_x, bands$y_center[1], bh2, cap_side)
    polygon(cap1$x, cap1$y, col = state_colors[sequence[1]], border = NA)

    # End cap
    if (n_rows > 1L) {
      last_dir <- bands$direction[n_rows]
      if (last_dir == "ltr") {
        cap2 <- end_cap_polygon(bands$x_right[n_rows],
                                bands$y_center[n_rows], bh2, "right")
      } else {
        cap2 <- end_cap_polygon(bands$x_left[n_rows],
                                bands$y_center[n_rows], bh2, "left")
      }
      polygon(cap2$x, cap2$y, col = state_colors[sequence[n_blocks]],
              border = NA)
    }
  } else {
    first_dir <- bands$direction[1]
    cap_side <- if (first_dir == "ttb") "top" else "bottom"
    cap_y <- if (cap_side == "top") bands$y_top[1] else bands$y_bottom[1]
    cap1 <- end_cap_polygon(bands$x_center[1], cap_y, bh2, cap_side)
    polygon(cap1$x, cap1$y, col = state_colors[sequence[1]], border = NA)

    if (n_rows > 1L) {
      last_dir <- bands$direction[n_rows]
      if (last_dir == "ttb") {
        cap2 <- end_cap_polygon(bands$x_center[n_rows],
                                bands$y_bottom[n_rows], bh2, "bottom")
      } else {
        cap2 <- end_cap_polygon(bands$x_center[n_rows],
                                bands$y_top[n_rows], bh2, "top")
      }
      polygon(cap2$x, cap2$y, col = state_colors[sequence[n_blocks]],
              border = NA)
    }
  }
  invisible(NULL)
}

#' Draw a transition marker at a state change point
#'
#' Overlays label inside the band or arc at the transition boundary.
#' @noRd
draw_transition_mark <- function(pos, label, seg_info, alloc, cum_start,
                                  bands, arcs, outer_r, tick_cex) {
  n_seg <- nrow(seg_info)
  # Find which segment block 'pos' belongs to (vectorized)
  cs <- cum_start[seq_len(n_seg)]
  seg <- which(pos >= cs + 1L & pos <= cs + alloc)[1L]
  if (is.na(seg)) return(invisible(NULL)) # nocov

  if (seg_info$type[seg] == "band") {
    k <- seg_info$index[seg]
    b <- bands[k, ]
    m <- alloc[seg]
    local_pos <- pos - cum_start[seg]
    coords <- band_block_x(b, m)

    # Transition at EXIT edge: LTR → x1, RTL → x0
    if (b$direction %in% c("ltr", "ttb")) {
      tx <- coords$x1[local_pos]
    } else {
      tx <- coords$x0[local_pos]
    }

    # Overlaid label inside band at the transition edge
    text(tx, b$y_center, label,
         cex = tick_cex, col = "#FFFFFF", font = 2)

  } else if (seg_info$type[seg] == "arc") {
    a <- arcs[[seg_info$index[seg]]]
    m <- alloc[seg]
    local_pos <- pos - cum_start[seg]

    # Exit edge angle — the actual juncture where state changes
    theta_per <- pi / m
    theta_exit <- -pi / 2 + local_pos * theta_per
    r_mid <- (outer_r + a$inner_r) / 2

    if (a$side %in% c("right", "left")) {
      sign_x <- if (a$side == "right") 1 else -1
      lx <- a$cx + sign_x * r_mid * cos(theta_exit)
      ly <- a$cy + r_mid * sin(theta_exit)
    } else {
      sign_y <- if (a$side == "bottom") 1 else -1
      lx <- a$cx + r_mid * sin(theta_exit)
      ly <- a$cy + sign_y * r_mid * cos(theta_exit)
    }

    text(lx, ly, label,
         cex = tick_cex, col = "#FFFFFF", font = 2)
  }
  invisible(NULL)
}

#' Draw a transition marker at a fractional position along the snake
#'
#' Maps a fractional block position (e.g., 1.42 = 42% through block 2)
#' to (x, y) coordinates on the serpentine path and overlays the label.
#' @noRd
draw_transition_mark_at <- function(frac_pos, label, seg_info, alloc,
                                     cum_start, bands, arcs,
                                     outer_r, inner_r, tick_cex) {
  n_seg <- nrow(seg_info)
  r_mid <- (outer_r + inner_r) / 2

  # Find which segment the fractional position falls in
  for (s in seq_len(n_seg)) {
    s_start <- cum_start[s]
    s_end   <- cum_start[s] + alloc[s]
    if (alloc[s] == 0L) next # nocov
    if (frac_pos >= s_start && frac_pos <= s_end) {
      frac <- (frac_pos - s_start) / alloc[s]  # 0..1 within segment

      if (seg_info$type[s] == "band") {
        b <- bands[seg_info$index[s], ]
        if (b$direction %in% c("ltr", "ttb")) {
          lx <- b$x_left + frac * (b$x_right - b$x_left)
        } else {
          lx <- b$x_right - frac * (b$x_right - b$x_left)
        }
        text(lx, b$y_center, label,
             cex = tick_cex, col = "#FFFFFF", font = 2)
      } else {
        a <- arcs[[seg_info$index[s]]]
        theta <- -pi / 2 + frac * pi
        if (a$side %in% c("right", "left")) {
          sign_x <- if (a$side == "right") 1 else -1
          lx <- a$cx + sign_x * r_mid * cos(theta)
          ly <- a$cy + r_mid * sin(theta)
        } else { # nocov start
          sign_y <- if (a$side == "bottom") 1 else -1
          lx <- a$cx + r_mid * sin(theta)
          ly <- a$cy + sign_y * r_mid * cos(theta)
        } # nocov end
        text(lx, ly, label,
             cex = tick_cex, col = "#FFFFFF", font = 2)
      }
      return(invisible(NULL))
    }
  }
  invisible(NULL) # nocov
}
