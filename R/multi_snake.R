#' Multi-Sequence Snake Plot
#'
#' Displays many sequences simultaneously in a serpentine layout. Time points
#' are packed as blocks within each band (like \code{sequence_snake}), with
#' multiple time points flowing through bands and arcs.
#'
#' Two display modes are supported:
#' \describe{
#'   \item{\code{"index"}}{Each block contains thin colored ticks stacked
#'     side by side — one tick per sequence, colored by state at that time
#'     point. Like TraMineR's \code{seqiplot()} folded into a serpentine.}
#'   \item{\code{"distribution"}}{Each block is a stacked proportional bar
#'     showing what fraction of sequences is in each state at that time
#'     point. Like TraMineR's \code{seqdplot()}.}
#' }
#'
#' @param sequences Matrix or data.frame where rows are sequences and
#'   columns are time points. Each cell contains a state label.
#' @param type Character, \code{"index"} (default) or \code{"distribution"}.
#' @param states Character vector of unique states in desired legend order.
#'   If \code{NULL}, derived from the data.
#' @param colors Named or unnamed character vector of colors. If \code{NULL},
#'   a built-in qualitative palette is used.
#' @param sort_by Character controlling sequence order in index mode:
#'   \code{"none"} (default), \code{"first"} (sort by first state),
#'   \code{"last"} (sort by last state), \code{"freq"} (sort by most
#'   frequent state), or \code{"entropy"} (sort by Shannon entropy).
#' @param rows Integer, number of serpentine rows. If \code{NULL},
#'   auto-calculated (~10 blocks per band).
#' @param band_height Numeric, height of each band in pixels (default 28).
#' @param band_gap Numeric, gap between bands (default 18).
#' @param plot_width Numeric, width of each band (default 500).
#' @param margin Named numeric vector with top, right, bottom, left margins.
#' @param show_labels Logical, show time-point range per row (default TRUE).
#' @param show_legend Logical, draw color legend (default TRUE).
#' @param show_percent Logical, show percentage labels inside distribution bars
#'   (default TRUE). Only used when \code{type = "distribution"}.
#' @param border_color Color for thin borders between blocks, or \code{NA}
#'   for no borders (default \code{NA}).
#' @param title Optional character string for plot title.
#' @param background Background color (default \code{"white"}).
#' @param shadow Logical, draw drop shadows (default TRUE).
#' @param legend_text_size Numeric, legend text size (default 0.8).
#' @param tick_opacity Numeric 0-1, opacity of ticks in index mode
#'   (default 0.85).
#'
#' @return Invisible \code{NULL}. Called for its side effect of producing
#'   a plot.
#'
#' @examples
#' set.seed(42)
#' states <- c("Active", "Passive", "Absent")
#' seqs <- matrix(sample(states, 500, replace = TRUE), nrow = 50, ncol = 10)
#' multi_snake(seqs, type = "index")
#' multi_snake(seqs, type = "distribution")
#'
#' @export
multi_snake <- function(sequences,
                        type = c("index", "distribution"),
                        states = NULL,
                        colors = NULL,
                        sort_by = c("none", "first", "last",
                                    "freq", "entropy"),
                        rows = NULL,
                        band_height = 28,
                        band_gap = 18,
                        plot_width = 500,
                        margin = c(top = 30, right = 10,
                                   bottom = 50, left = 80),
                        show_labels = TRUE,
                        show_legend = TRUE,
                        show_percent = TRUE,
                        border_color = NA,
                        title = NULL,
                        background = "white",
                        shadow = TRUE,
                        legend_text_size = 0.8,
                        tick_opacity = 0.85) {

  type    <- match.arg(type)
  sort_by <- match.arg(sort_by)

  # --- Coerce input ---
  if (is.data.frame(sequences)) sequences <- as.matrix(sequences)
  stopifnot(is.matrix(sequences), nrow(sequences) >= 1L, ncol(sequences) >= 1L)
  storage.mode(sequences) <- "character"

  n_seq   <- nrow(sequences)
  n_time  <- ncol(sequences)

  # --- Alphabet ---
  if (is.null(states)) {
    states <- unique(as.vector(sequences))
    states <- states[!is.na(states)]
  }
  n_states <- length(states)

  # --- Colors ---
  state_colors <- resolve_state_colors(colors, states, n_states)

  # --- Sort sequences (index mode) ---
  if (type == "index" && sort_by != "none") {
    row_order <- switch(sort_by,
      first = order(factor(sequences[, 1L], levels = states)),
      last  = order(factor(sequences[, n_time], levels = states)),
      freq  = {
        dominant <- vapply(seq_len(n_seq), function(i) {
          tbl <- table(factor(sequences[i, ], levels = states))
          names(which.max(tbl))[1L]
        }, character(1))
        order(factor(dominant, levels = states))
      },
      entropy = {
        ent <- vapply(seq_len(n_seq), function(i) {
          tbl <- table(factor(sequences[i, ], levels = states))
          p <- tbl / sum(tbl)
          p <- p[p > 0]
          -sum(p * log(p))
        }, numeric(1))
        order(ent)
      }
    )
    sequences <- sequences[row_order, , drop = FALSE]
  }

  # --- Tabulate state counts per time point ---
  counts <- vapply(seq_len(n_time), function(t) {
    tbl <- table(factor(sequences[, t], levels = states))
    as.integer(tbl)
  }, integer(n_states))
  counts <- t(counts)  # n_time x n_states

  # --- Time labels ---
  time_labels <- if (!is.null(colnames(sequences))) {
    colnames(sequences)
  } else {
    seq_len(n_time)
  }

  # --- Auto rows (targeting ~10-12 blocks per band) ---
  if (is.null(rows)) {
    rows <- max(1L, ceiling(n_time / 11))
  }
  rows <- as.integer(rows)

  # --- Adjust margins ---
  if (show_legend) margin["bottom"] <- margin["bottom"] + 15
  if (!is.null(title)) margin["top"] <- margin["top"] + 18

  # --- Layout: rows serpentine bands ---
  layout <- compute_snake_layout(
    n_bands = rows, band_height = band_height, band_gap = band_gap,
    plot_width = plot_width, margin = margin
  )
  bands  <- layout$bands
  arcs   <- layout$arcs
  params <- layout$params
  outer_r <- params$outer_r
  inner_r <- params$inner_r
  r_mid   <- (outer_r + inner_r) / 2

  # --- Allocate time-point blocks to segments ---
  seg_info <- build_segment_table(rows, plot_width, r_mid)
  alloc    <- allocate_blocks(seg_info$path_length, n_time)
  cum_start <- c(0L, cumsum(alloc))

  # --- Canvas ---
  op <- setup_canvas(layout, bg = background)
  on.exit(par(op), add = TRUE)

  if (!is.null(title)) {
    text(layout$canvas$width / 2, 14, title,
         col = "#333333", cex = 1.1, font = 2)
  }
  if (shadow) draw_shadows(layout)

  # --- Draw blocks in each segment ---
  lapply(seq_len(nrow(seg_info)), function(seg) {
    m <- alloc[seg]
    if (m == 0L) return(invisible(NULL)) # nocov

    block_start <- cum_start[seg] + 1L
    block_end   <- block_start + m - 1L
    time_idx    <- block_start:block_end

    if (seg_info$type[seg] == "band") {
      k <- seg_info$index[seg]
      draw_multi_band_blocks(bands[k, ], m, time_idx, sequences,
                              counts, n_seq, n_states, states,
                              state_colors, type, tick_opacity,
                              show_percent, border_color)
    } else {
      # Simple neutral arc fill — no data in arcs
      a <- arcs[[seg_info$index[seg]]]
      polygon(a$pts$x, a$pts$y, col = "#E0E0E0", border = NA)
    }
  })

  # --- End caps (subtle, matching adjacent band edge) ---
  if (rows >= 1L) {
    cap_side1 <- if (bands$direction[1L] == "ltr") "left" else "right"
    cap1 <- end_cap_polygon(bands$x_left[1L], bands$y_top[1L],
                            bands$y_bottom[1L], cap_side1, outer_r)
    polygon(cap1$x, cap1$y, col = "#E8E8E8", border = NA)

    cap_side2 <- if (bands$direction[rows] == "ltr") "right" else "left"
    cap2 <- end_cap_polygon(bands$x_right[rows], bands$y_top[rows],
                            bands$y_bottom[rows], cap_side2, outer_r)
    polygon(cap2$x, cap2$y, col = "#E8E8E8", border = NA)
  }

  # --- Row labels ---
  if (show_labels) {
    band_segs <- which(seg_info$type == "band")
    vapply(band_segs, function(s) {
      k <- seg_info$index[s]
      b_start <- cum_start[s] + 1L
      b_end   <- cum_start[s] + alloc[s]
      if (b_end < b_start) return(NA) # nocov
      lab <- sprintf("%s-%s", time_labels[b_start], time_labels[b_end])
      text(bands$x_left[k] - 6, bands$y_center[k], lab,
           adj = 1, cex = 0.55, col = "#555555")
      NA
    }, logical(1))
  }

  # --- Legend ---
  if (show_legend) {
    draw_multi_legend(layout, states, state_colors, legend_text_size, n_seq,
                      type)
  }

  invisible(NULL)
}


# ---- Internal drawing helpers ----

#' Draw blocks within a band for multi_snake
#' @noRd
draw_multi_band_blocks <- function(band, m, time_idx, sequences,
                                    counts, n_seq, n_states, states,
                                    state_colors, type, tick_opacity,
                                    show_percent, border_color) {
  coords <- band_block_x(band, m)
  vapply(seq_len(m), function(j) {
    t_idx <- time_idx[j]
    x0 <- coords$x0[j]
    x1 <- coords$x1[j]
    yt <- band$y_top
    yb <- band$y_bottom
    bw <- x1 - x0

    if (type == "distribution") {
      draw_dist_block(x0, x1, yt, yb, bw, counts[t_idx, ],
                      n_states, state_colors, show_percent)
    } else {
      draw_index_block(x0, x1, yt, yb, sequences[, t_idx],
                        n_seq, state_colors, tick_opacity)
    }

    if (!is.na(border_color)) { # nocov start
      rect(x0, yt, x1, yb, col = NA, border = border_color, lwd = 0.3)
    } # nocov end
    NA
  }, logical(1))
  invisible(NULL)
}


#' Draw a single distribution block (stacked bar)
#' @noRd
draw_dist_block <- function(x0, x1, yt, yb, bw, count_row,
                             n_states, state_colors, show_percent) {
  row_total <- sum(count_row)
  if (row_total == 0L) return(invisible(NULL)) # nocov

  x_cursor <- x0
  vapply(seq_len(n_states), function(s) {
    cnt <- count_row[s]
    if (cnt == 0L) return(NA) # nocov
    seg_w <- (cnt / row_total) * bw
    rect(x_cursor, yt, x_cursor + seg_w, yb,
         col = state_colors[s], border = NA)
    if (show_percent) {
      pct <- round(cnt / row_total * 100)
      if (seg_w > bw * 0.12) {
        text(x_cursor + seg_w / 2, (yt + yb) / 2,
             sprintf("%d%%", pct),
             col = "white", cex = 0.4, font = 2)
      }
    }
    x_cursor <<- x_cursor + seg_w
    NA
  }, logical(1))
  invisible(NULL)
}


#' Draw a single index block (stacked ticks)
#' @noRd
draw_index_block <- function(x0, x1, yt, yb, states_at_t,
                              n_seq, state_colors, tick_opacity) {
  bw <- x1 - x0
  # Light background
  rect(x0, yt, x1, yb, col = "#F5F5F5", border = NA)
  # One tick per sequence
  tick_w <- bw / n_seq
  x_starts <- x0 + (seq_len(n_seq) - 1L) * tick_w
  tick_cols <- alpha_col(state_colors[states_at_t], tick_opacity)
  rect(x_starts, yt, x_starts + tick_w, yb,
       col = tick_cols, border = NA)
  invisible(NULL)
}


#' Draw legend for multi_snake
#' @noRd
draw_multi_legend <- function(layout, states, state_colors, legend_text_size,
                               n_seq, type) {
  n_states <- length(states)
  cw <- layout$canvas$width
  ch <- layout$canvas$height
  legend_y <- ch - 8

  swatch_w <- 10
  gap <- 6
  total_w <- n_states * (swatch_w + gap) +
    sum(nchar(states)) * 5 * legend_text_size
  x_start <- max(5, (cw - total_w) / 2)

  x_cursor <- x_start
  lapply(seq_len(n_states), function(s) {
    rect(x_cursor, legend_y - 5, x_cursor + swatch_w, legend_y + 5,
         col = state_colors[s], border = NA)
    text(x_cursor + swatch_w + 3, legend_y, states[s],
         adj = c(0, 0.5), cex = legend_text_size * 0.9, col = "#444444")
    x_cursor <<- x_cursor + swatch_w + gap +
      nchar(states[s]) * 5 * legend_text_size + 4
  })

  info <- sprintf("n = %d sequences", n_seq)
  text(cw - 10, legend_y, info, adj = c(1, 0.5),
       cex = legend_text_size * 0.75, col = "#888888")

  invisible(NULL)
}
