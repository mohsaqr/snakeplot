#' Plot a long state sequence as blocks along a serpentine path
#'
#' @description
#' A sequence snake plot shows one long categorical sequence, such as the actions
#' in a learning session or a person's daily states over months, as a row of
#' colored blocks, one per position. The row is folded into bands joined by
#' U-turns, and the blocks continue through the U-turns, so a sequence of
#' several hundred positions fits in one panel while the order of positions
#' is kept. Runs, recurrences and changes of state can be followed along the
#' path, as in a sequence index plot of a single sequence (Gabadinho et al.,
#' 2011).
#'
#' `sequence_snake()` accepts the sequence as a vector, a comma-separated
#' string, a list, or a data frame whose first character or factor column
#' holds the states. Blocks can carry position numbers, state names or other
#' labels, and the path can be annotated with ruler ticks, a label for each
#' band and labels at changes of state. With `style = "rug"` blocks become
#' thin ticks on a light band, which keeps many positions legible.
#'
#' For many sequences at once use [multi_snake()]. For phases defined by start
#' and end dates use [timeline_snake()], which builds the monthly sequence and
#' its labels from the dates.
#'
#' @param sequence The states in order: a character, factor or integer
#'   vector; a single comma-separated string such as `"A,B,C"`; a list; or a
#'   data frame, whose first character or factor column is used. Missing
#'   values are dropped with a warning.
#' @param states State labels in legend order. `NULL` (default) takes them in
#'   order of first appearance. Every state in `sequence` must be listed.
#' @param colors State colors: a vector named by state, or an unnamed vector
#'   recycled over `states`. States missing from a named vector are drawn in
#'   grey. `NULL` (default) uses a built-in qualitative palette.
#' @param rows Number of bands. `NULL` (default) uses one band per 11
#'   positions, rounded up.
#' @param band_height Height of each band in plot units (default 28).
#' @param band_gap Gap between bands in plot units (default 18).
#' @param plot_width Length of each band in plot units (default 500).
#' @param margin Named numeric vector of `top`, `right`, `bottom` and `left`
#'   margins in plot units (default
#'   `c(top = 30, right = 10, bottom = 50, left = 80)`).
#' @param orientation `"horizontal"` (default). `"vertical"` turns the bands
#'   into columns but places the blocks across each column rather than along
#'   it, so the horizontal layout is recommended.
#' @param start_from Side on which the first band starts: `"left"` (default)
#'   or `"right"`.
#' @param flow `"natural"` (default): every band reads in the same direction,
#'   like lines of text. `"snake"`: bands alternate direction, so the sequence
#'   runs on through each U-turn.
#' @param show_labels Label each band with the range of positions it holds
#'   (default `TRUE`).
#' @param show_legend Draw the state legend (default `TRUE`).
#' @param show_numbers Print each block's position inside it
#'   (default `FALSE`).
#' @param show_state Print the state name inside each block
#'   (default `FALSE`).
#' @param state_size Text size of the state names (default 0.35).
#' @param show_ticks Draw ruler ticks at block boundaries, outside the bands
#'   (default `FALSE`).
#' @param tick_labels Labels for evenly spaced ruler marks on every band,
#'   such as `month.abb`. Setting them turns on `show_ticks`.
#' @param transition_labels Labels for the points where the state changes, in
#'   order; the first `length(transition_labels)` changes are labelled.
#' @param transition_pos Positions of `transition_labels` along the sequence,
#'   in blocks; fractions such as `6.5` are allowed. `NULL` (default) places
#'   the labels at the changes of state.
#' @param tick_color Color of ticks and of band and transition labels
#'   (default `"#333333"`).
#' @param tick_length Length of ticks in plot units (default 5).
#' @param tick_size Text size of tick, band and transition labels
#'   (default 0.4).
#' @param style `"block"` (default) fills each band with blocks; `"rug"`
#'   draws thin ticks on a light band, suited to sequences with many
#'   positions.
#' @param band_color Not used at present; rug bands are drawn light grey.
#' @param rug_opacity Opacity of the rug ticks, between 0 and 1
#'   (default 0.9).
#' @param jitter For `style = "rug"`, vertical scatter of the ticks as a
#'   fraction of the band height (default 0, none). The scatter is random;
#'   call [set.seed()] first for a reproducible plot.
#' @param border_color Color of block outlines, or `NA` (default) for none.
#' @param block_labels Labels for the blocks, one per position. They replace
#'   the position numbers, and are drawn below the blocks when ruler ticks
#'   are shown.
#' @param band_labels One label per band (length `rows`), printed below the
#'   band, for example a year.
#' @param title Plot title, or `NULL` (default) for none.
#' @param background Background color (default `"white"`).
#' @param shadow Draw drop shadows (default `TRUE`).
#' @param text_size Text size of block numbers and block labels
#'   (default 0.5).
#' @param legend_text_size Size of the legend text (default 0.8).
#'
#' @return The plot is drawn on the current device; the function returns
#'   `NULL` invisibly.
#'
#' @references
#' Gabadinho, A., Ritschard, G., \enc{Müller}{Muller}, N. S., & Studer, M. (2011).
#' Analyzing and visualizing state sequences in R with TraMineR.
#' *Journal of Statistical Software*, 40(4), 1-37.
#' \doi{10.18637/jss.v040.i04}
#'
#' @seealso [timeline_snake()] for dated phases; [multi_snake()] for many
#'   sequences; [activity_snake()] for event times within days.
#'
#' @examples
#' # 75 actions in a learning session
#' set.seed(42)
#' actions <- sample(c("Read", "Write", "Discuss", "Plan", "Review"), 75,
#'                   replace = TRUE)
#' sequence_snake(actions)
#' sequence_snake(actions, rows = 5, flow = "snake", show_state = TRUE,
#'                colors = c(Read = "#56B4E9", Write = "#E69F00",
#'                           Discuss = "#009E73", Plan = "#CC79A7",
#'                           Review = "#999999"))
#'
#' # 400 observations of on- and off-task behaviour as a rug
#' on_task <- sample(c("On task", "Off task"), 400, replace = TRUE,
#'                   prob = c(0.8, 0.2))
#' sequence_snake(on_task, style = "rug", rows = 8)
#'
#' @export
sequence_snake <- function(sequence,
                           states = NULL,
                           colors = NULL,
                           rows = NULL,
                           band_height = 28,
                           band_gap = 18,
                           plot_width = 500,
                           margin = c(top = 30, right = 10,
                                      bottom = 50, left = 80),
                           orientation = "horizontal",
                           start_from = "left",
                           flow = c("natural", "snake"),
                           show_labels = TRUE,
                           show_legend = TRUE,
                           show_numbers = FALSE,
                           show_state = FALSE,
                           state_size = 0.35,
                           show_ticks = FALSE,
                           tick_labels = NULL,
                           transition_labels = NULL,
                           transition_pos = NULL,
                           tick_color = "#333333",
                           tick_length = 5,
                           tick_size = 0.4,
                           style = c("block", "rug"),
                           band_color = "#3d3d4a",
                           rug_opacity = 0.9,
                           jitter = 0,
                           border_color = NA,
                           block_labels = NULL,
                           band_labels = NULL,
                           title = NULL,
                           background = "white",
                           shadow = TRUE,
                           text_size = 0.5,
                           legend_text_size = 0.8) {
  style <- match.arg(style)
  flow  <- match.arg(flow)

  # --- Smart input coercion ---
  sequence <- coerce_sequence_input(sequence)
  n_blocks <- length(sequence)

  if (is.null(states)) {
    states <- unique(sequence)
  }
  states <- as.character(states)
  n_states <- length(states)

  # Validate all states are in states
  unknown <- setdiff(unique(sequence), states)
  if (length(unknown) > 0L) {
    stop(sprintf("Unknown states not in states: %s",
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
    if (!show_ticks && is.null(tick_labels)) show_numbers <- TRUE
  }

  # --- Colors ---
  state_colors <- resolve_state_colors(colors, states, n_states)

  # --- Auto-calculate rows ---
  if (is.null(rows)) {
    rows <- max(1L, ceiling(n_blocks / 11))
  }
  stopifnot(is.numeric(rows), length(rows) == 1L, rows >= 1L)
  rows <- as.integer(rows)

  # --- Band labels validation ---
  if (!is.null(band_labels)) {
    band_labels <- as.character(band_labels)
    if (length(band_labels) != rows) {
      stop(sprintf("length(band_labels) = %d but rows = %d; must match",
                   length(band_labels), rows), call. = FALSE)
    }
  }

  # --- Layout ---
  layout <- compute_snake_layout(
    n_bands = rows, band_height = band_height, band_gap = band_gap,
    plot_width = plot_width, margin = margin,
    orientation = orientation, start_from = start_from,
    flow = flow
  )

  bands  <- layout$bands
  arcs   <- layout$arcs
  params <- layout$params
  outer_r <- params$outer_r
  inner_r <- params$inner_r
  r_mid   <- (outer_r + inner_r) / 2

  # --- Build segment table (band, arc, band, arc, ..., band) ---
  seg_info <- build_segment_table(rows, plot_width, r_mid)

  # --- Allocate blocks to segments ---
  alloc <- allocate_blocks(seg_info$path_length, n_blocks)
  cum_start <- c(0L, cumsum(alloc))

  # --- Set up canvas ---
  op <- setup_canvas(layout, bg = background)
  on.exit(par(op), add = TRUE)

  # Title
  if (!is.null(title)) {
    text(layout$canvas$width / 2, margin["top"] / 2, title,
         cex = 1.2, font = 2, col = "#333333")
  }

  # Shadows
  if (shadow) draw_shadows(layout)

  if (style == "rug") {
    # --- Rug mode: thin colored ticks, light band background ---
    # Light band background
    vapply(seq_len(rows), function(k) {
      rect(bands$x_left[k], bands$y_top[k],
           bands$x_right[k], bands$y_bottom[k],
           col = "#F5F5F5", border = NA)
      NA
    }, logical(1))
    # Neutral arcs
    lapply(arcs, function(a) {
      polygon(a$pts$x, a$pts$y, col = "#EBEBEB", border = NA)
    })
    n_segments <- nrow(seg_info)
    lapply(seq_len(n_segments), function(seg) {
      m <- alloc[seg]
      if (m == 0L) return(invisible(NULL)) # nocov
      block_start <- cum_start[seg] + 1L
      block_states <- sequence[block_start:(block_start + m - 1L)]
      block_cols <- alpha_col(state_colors[block_states], rug_opacity)
      if (seg_info$type[seg] == "band") {
        draw_rug_band(bands[seg_info$index[seg], ], m, block_cols,
                      jitter)
      } else {
        draw_rug_arc(arcs[[seg_info$index[seg]]], m, block_cols,
                     outer_r, inner_r, jitter)
      }
    })
  } else {
    # --- Block mode: colored rectangles ---
    lapply(arcs, function(a) {
      polygon(a$pts$x, a$pts$y, col = "#E0E0E0", border = NA)
    })
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
                         border_color, show_numbers, block_start, text_size,
                         seg_labels, seg_st, state_size)
      } else {
        draw_arc_blocks(arcs[[seg_info$index[seg]]], m, block_cols,
                        outer_r, inner_r, r_mid, border_color,
                        show_numbers, block_start, text_size, seg_labels,
                        seg_st, state_size)
      }
    })
  }

  # --- Ruler ticks ---
  if (!is.null(tick_labels)) show_ticks <- TRUE
  if (show_ticks) {
    lapply(seq_len(rows), function(k) {
      b <- bands[k, ]
      bw <- b$x_right - b$x_left
      if (!is.null(tick_labels)) {
        # Labeled ruler: evenly spaced ticks with text
        n_tk <- length(tick_labels)
        frac <- seq(0, 1, length.out = n_tk + 1L)
        # Tick positions at boundaries
        if (b$read_direction %in% c("ltr", "ttb")) {
          tk_x <- b$x_left + frac * bw
        } else {
          tk_x <- b$x_right - frac * bw
        }
        # Internal boundary ticks (skip first and last)
        int_x <- tk_x[-c(1L, length(tk_x))]
        segments(int_x, b$y_top - tick_length, int_x, b$y_top,
                 col = tick_color, lwd = 0.6)
        segments(int_x, b$y_bottom, int_x, b$y_bottom + tick_length,
                 col = tick_color, lwd = 0.6)
        # Labels centered between boundary ticks
        mid_x <- (tk_x[-length(tk_x)] + tk_x[-1L]) / 2
        text(mid_x, b$y_bottom + tick_length + 5, tick_labels,
             cex = tick_size, col = tick_color)
      } else {
        # Block-boundary ticks with optional labels outside
        seg_idx <- which(seg_info$type == "band" & seg_info$index == k)
        m <- alloc[seg_idx]
        if (m == 0L) return(invisible(NULL))
        coords <- band_block_x(b, m)
        # Internal boundary ticks
        if (m > 1L) {
          tick_x <- coords$x1[-m]
          segments(tick_x, b$y_top - tick_length, tick_x, b$y_top,
                   col = tick_color, lwd = 0.8)
          segments(tick_x, b$y_bottom, tick_x, b$y_bottom + tick_length,
                   col = tick_color, lwd = 0.8)
        }
        # Block labels outside (centered under each block)
        if (!is.null(block_labels)) {
          blk_start <- cum_start[seg_idx] + 1L
          blk_lbls <- block_labels[blk_start:(blk_start + m - 1L)]
          mid_x <- (coords$x0 + coords$x1) / 2
          text(mid_x, b$y_bottom + tick_length + 6, blk_lbls,
               cex = tick_size, col = tick_color)
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
                                 outer_r, inner_r, tick_size)
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
                                outer_r, tick_size)
        })
      }
    }
  }

  # --- Band labels (centered in gap between bands) ---
  if (!is.null(band_labels)) {
    lapply(seq_len(rows), function(k) {
      b <- bands[k, ]
      mid_x <- (b$x_left + b$x_right) / 2
      if (k < rows) {
        # Place in the middle of the gap between this band and the next
        b_next <- bands[k + 1L, ]
        label_y <- (b$y_bottom + b_next$y_top) / 2
      } else {
        # Last band: place below
        label_y <- b$y_bottom + band_gap / 2
      }
      text(mid_x, label_y, band_labels[k],
           cex = tick_size, col = tick_color, font = 1)
    })
  }

  # --- End caps ---
  if (style == "rug") {
    # Light neutral end caps for rug mode
    if (rows >= 1L) {
      bh2 <- band_height / 2
      cap_side1 <- if (bands$direction[1L] == "ltr") "left" else "right"
      cap_x1 <- if (cap_side1 == "left") bands$x_left[1L] else bands$x_right[1L]
      cap1 <- end_cap_polygon(cap_x1, bands$y_center[1L], bh2, cap_side1)
      polygon(cap1$x, cap1$y, col = "#EBEBEB", border = NA)
      if (rows > 1L) {
        cap_side2 <- if (bands$direction[rows] == "ltr") "right" else "left"
        cap_x2 <- if (cap_side2 == "right") bands$x_right[rows] else bands$x_left[rows]
        cap2 <- end_cap_polygon(cap_x2, bands$y_center[rows], bh2, cap_side2)
        polygon(cap2$x, cap2$y, col = "#EBEBEB", border = NA)
      }
    }
  } else {
    draw_sequence_end_caps(layout, bands, rows, band_height,
                           orientation, state_colors, sequence, n_blocks)
  }

  # --- Row labels ---
  if (show_labels) {
    band_idx <- which(seg_info$type == "band")
    range_labels <- vapply(band_idx, function(seg) {
      m <- alloc[seg]
      if (m == 0L) return("")
      s <- cum_start[seg] + 1L
      sprintf("%d-%d", s, s + m - 1L)
    }, character(1))
    lbl_col <- if (style == "rug") "#999999" else "#333333"
    draw_band_labels(layout, range_labels, col = lbl_col, cex = 0.75)
  }

  # --- Legend ---
  if (show_legend) {
    legend_items <- lapply(seq_along(states), function(i) {
      list(label = states[i], color = state_colors[states[i]])
    })
    draw_snake_legend(layout, legend_items, cex = legend_text_size)
  }

  invisible(NULL)
}

# ---- Internal helpers --------------------------------------------------------

#' Resolve state colors from user input
#' @noRd
resolve_state_colors <- function(colors, states, n_states) {
  # Default qualitative palette (Set2-inspired)
  default_pal <- c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3",
                   "#A6D854", "#FFD92F", "#E5C494", "#FB8072",
                   "#E41A1C", "#377EB8", "#4DAF4A", "#984EA3")

  if (is.null(colors)) {
    state_colors <- rep_len(default_pal, n_states)
    names(state_colors) <- states
  } else if (!is.null(names(colors))) {
    state_colors <- colors[states]
    missing <- is.na(state_colors)
    if (any(missing)) state_colors[missing] <- "#CCCCCC"
    names(state_colors) <- states
  } else {
    state_colors <- rep_len(colors, n_states)
    names(state_colors) <- states
  }
  state_colors
}

#' Build segment table (band/arc interleaved)
#' @noRd
build_segment_table <- function(rows, plot_width, r_mid) {
  band_df <- data.frame(
    type = rep("band", rows),
    index = seq_len(rows),
    path_length = rep(plot_width, rows),
    stringsAsFactors = FALSE
  )

  if (rows <= 1L) return(band_df)

  n_arcs <- rows - 1L
  arc_df <- data.frame(
    type = rep("arc", n_arcs),
    index = seq_len(n_arcs),
    path_length = rep(pi * r_mid, n_arcs),
    stringsAsFactors = FALSE
  )

  # Interleave: band1, arc1, band2, arc2, ..., band_n
  combined <- rbind(band_df, arc_df)
  band_pos <- seq(1L, by = 2L, length.out = rows)
  arc_pos  <- seq(2L, by = 2L, length.out = n_arcs)
  order_idx <- integer(rows + n_arcs)
  order_idx[band_pos] <- seq_len(rows)
  order_idx[arc_pos]  <- rows + seq_len(n_arcs)
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
  if (b$read_direction %in% c("ltr", "ttb")) {
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
draw_band_blocks <- function(b, m, block_cols, border_color,
                              show_numbers, block_start, text_size,
                              seg_labels = NULL,
                              seg_states = NULL, state_size = NULL) {
  coords <- band_block_x(b, m)
  # Draw rectangles
  rect(coords$x0, b$y_top, coords$x1, b$y_bottom,
       col = block_cols, border = border_color)
  # Block labels (year, index, etc.)
  if (show_numbers) {
    lbls <- if (!is.null(seg_labels)) seg_labels else block_start + seq_len(m) - 1L
    y_lbl <- if (!is.null(seg_states)) {
      b$y_center - (b$y_bottom - b$y_top) * 0.18
    } else {
      b$y_center
    }
    text((coords$x0 + coords$x1) / 2, y_lbl, lbls,
         cex = text_size, col = "#FFFFFF")
  }
  # State labels — centered across runs of same state
  if (!is.null(seg_states)) {
    runs <- rle(seg_states)
    end_pos <- cumsum(runs$lengths)
    start_pos <- c(1L, end_pos[-length(end_pos)] + 1L)
    y_st <- if (show_numbers) {
      b$y_center + (b$y_bottom - b$y_top) * 0.22
    } else {
      b$y_center
    }
    lapply(seq_along(runs$values), function(r) {
      run_x0 <- coords$x0[start_pos[r]]
      run_x1 <- coords$x1[end_pos[r]]
      run_width <- abs(run_x1 - run_x0)
      label_width <- strwidth(runs$values[r], cex = state_size, font = 2)
      # Only draw label if the run is wide enough to fit it
      if (run_width >= label_width * 1.1) {
        text((run_x0 + run_x1) / 2, y_st, runs$values[r],
             cex = state_size, col = "#FFFFFF", font = 2)
      }
    })
  }
  invisible(NULL)
}

#' Draw colored blocks (annular sectors) within an arc
#' @noRd
draw_arc_blocks <- function(a, m, block_cols, outer_r, inner_r, r_mid,
                             border_color, show_numbers, block_start, text_size,
                             seg_labels = NULL,
                             seg_states = NULL, state_size = NULL) {
  theta_per <- pi / m
  lapply(seq_len(m), function(j) {
    theta1 <- -pi / 2 + (j - 1L) * theta_per
    theta2 <- -pi / 2 + j * theta_per
    pts <- arc_sector_polygon(a$cx, a$cy, outer_r, inner_r,
                               theta1, theta2, a$side)
    polygon(pts$x, pts$y, col = block_cols[j], border = border_color)
    if (show_numbers || !is.null(seg_states)) {
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
      if (show_numbers) {
        lbl <- if (!is.null(seg_labels)) seg_labels[j] else block_start + j - 1L
        text(lx, ly, lbl, cex = text_size * 0.8, col = "#FFFFFF")
      }
    }
  })
  invisible(NULL)
}

#' Draw semicircular end caps colored by first/last state
#' @noRd
draw_sequence_end_caps <- function(layout, bands, rows, band_height,
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
    if (rows > 1L) {
      last_dir <- bands$direction[rows]
      if (last_dir == "ltr") {
        cap2 <- end_cap_polygon(bands$x_right[rows],
                                bands$y_center[rows], bh2, "right")
      } else {
        cap2 <- end_cap_polygon(bands$x_left[rows],
                                bands$y_center[rows], bh2, "left")
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

    if (rows > 1L) {
      last_dir <- bands$direction[rows]
      if (last_dir == "ttb") {
        cap2 <- end_cap_polygon(bands$x_center[rows],
                                bands$y_bottom[rows], bh2, "bottom")
      } else {
        cap2 <- end_cap_polygon(bands$x_center[rows],
                                bands$y_top[rows], bh2, "top")
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
                                  bands, arcs, outer_r, tick_size) {
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
    if (b$read_direction %in% c("ltr", "ttb")) {
      tx <- coords$x1[local_pos]
    } else {
      tx <- coords$x0[local_pos]
    }

    # Transition label inside band near the bottom edge
    bh <- b$y_bottom - b$y_top
    ty <- b$y_bottom - bh * 0.28
    text(tx, ty, label,
         cex = tick_size, col = "#FFFFFFBB", font = 3)

  } else if (seg_info$type[seg] == "arc") {
    # Skip transition labels in arcs — not enough space
    invisible(NULL)
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
                                     outer_r, inner_r, tick_size) {
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
        if (b$read_direction %in% c("ltr", "ttb")) {
          lx <- b$x_left + frac * (b$x_right - b$x_left)
        } else {
          lx <- b$x_right - frac * (b$x_right - b$x_left)
        }
        bh <- b$y_bottom - b$y_top
        ty <- b$y_bottom - bh * 0.28
        text(lx, ty, label,
             cex = tick_size, col = "#FFFFFFBB", font = 3)
      } else {
        # Skip transition labels in arcs
        invisible(NULL)
      }
      return(invisible(NULL))
    }
  }
  invisible(NULL) # nocov
}

#' Draw rug ticks within a band
#' @noRd
draw_rug_band <- function(b, m, tick_colors, jitter = 0) {
  coords <- band_block_x(b, m)
  bh <- b$y_bottom - b$y_top
  tick_h <- bh * 0.2  # each tick is 20% of band height
  if (jitter > 0) {
    # Random y center for each tick within the band
    pad <- tick_h / 2
    y_min <- b$y_top + pad
    y_max <- b$y_bottom - pad
    y_center <- y_min + runif(m) * jitter * (y_max - y_min)
    rect(coords$x0, y_center - tick_h / 2, coords$x1, y_center + tick_h / 2,
         col = tick_colors, border = NA)
  } else {
    rug_top <- b$y_bottom - bh * 0.35
    rect(coords$x0, rug_top, coords$x1, b$y_bottom,
         col = tick_colors, border = NA)
  }
  invisible(NULL)
}

#' Draw rug ticks within an arc
#' @noRd
draw_rug_arc <- function(a, m, tick_colors, outer_r, inner_r, jitter = 0) {
  r_range <- outer_r - inner_r
  tick_r <- r_range * 0.2
  theta_per <- pi / m
  if (jitter > 0) {
    pad <- tick_r / 2
    r_min <- inner_r + pad
    r_max <- outer_r - pad
    r_centers <- r_min + runif(m) * jitter * (r_max - r_min)
    lapply(seq_len(m), function(j) {
      theta1 <- -pi / 2 + (j - 1L) * theta_per
      theta2 <- -pi / 2 + j * theta_per
      pts <- arc_sector_polygon(a$cx, a$cy, r_centers[j] + tick_r / 2,
                                 r_centers[j] - tick_r / 2,
                                 theta1, theta2, a$side)
      polygon(pts$x, pts$y, col = tick_colors[j], border = NA)
    })
  } else {
    rug_outer <- inner_r + r_range * 0.35
    lapply(seq_len(m), function(j) {
      theta1 <- -pi / 2 + (j - 1L) * theta_per
      theta2 <- -pi / 2 + j * theta_per
      pts <- arc_sector_polygon(a$cx, a$cy, rug_outer, inner_r,
                                 theta1, theta2, a$side)
      polygon(pts$x, pts$y, col = tick_colors[j], border = NA)
    })
  }
  invisible(NULL)
}
