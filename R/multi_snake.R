#' Plot many state sequences as a serpentine index or distribution plot
#'
#' @description
#' `multi_snake()` draws a multi-sequence snake plot, which shows a set of
#' categorical sequences, such as the weekly activity states of a class of
#' students, with their common time axis folded into bands joined by U-turns.
#' Each time point is a block along the serpentine path, so long sequences
#' fit in one panel while the order of time points is kept.
#'
#' Two displays are available. With `type = "index"` each block holds one
#' thin tick per sequence, colored by that sequence's state at the time
#' point, as in a sequence index plot; every sequence keeps the same position
#' in all blocks, and sequences can be ordered with `sort_by`. With
#' `type = "distribution"` each block is a stacked bar of the share of
#' sequences in each state at that time point, as in a state distribution
#' plot (Gabadinho et al., 2011). The U-turns are neutral connectors: time
#' points that fall on a U-turn are not drawn, and the label of each band
#' gives the range of time points it shows. The plot is drawn on the current
#' device and `NULL` is returned invisibly.
#'
#' For a single long sequence use [sequence_snake()]; for phases with start
#' and end dates use [timeline_snake()]. Distributions of ordinal survey
#' responses are shown by [survey_sequence()].
#'
#' @param sequences A matrix or data frame with one row per sequence and one
#'   column per time point; cells hold state labels. Column names, if any,
#'   label the time points.
#' @param type `"index"` (default) or `"distribution"`.
#' @param states State labels in the order used for the legend and for
#'   sorting. `NULL` (default) takes them in order of first appearance.
#' @param colors State colors: a vector named by state, or an unnamed vector
#'   recycled over `states`. States missing from a named vector are drawn in
#'   grey. `NULL` (default) uses a built-in qualitative palette.
#' @param sort_by Order of the sequences in the index display: `"none"`
#'   (default, input order), `"first"` or `"last"` (by the state at the first
#'   or last time point), `"freq"` (by each sequence's most frequent state)
#'   or `"entropy"` (by increasing Shannon entropy of its states). Ignored
#'   for `type = "distribution"`.
#' @param rows Number of bands. `NULL` (default) uses one band per 11 time
#'   points, rounded up.
#' @param band_height,band_gap Height of each band and gap between bands, in
#'   plot units (defaults 28 and 18).
#' @param plot_width Length of each band in plot units (default 500).
#' @param margin Named numeric vector of `top`, `right`, `bottom` and `left`
#'   margins in plot units (default
#'   `c(top = 30, right = 10, bottom = 50, left = 80)`).
#' @param flow `"snake"` (default): bands alternate direction. `"natural"`:
#'   every band reads in the same direction.
#' @param show_labels Label each band with the range of time points it shows
#'   (default `TRUE`).
#' @param show_legend Draw the state legend and the number of sequences
#'   (default `TRUE`).
#' @param show_percent Print percentages inside distribution segments wide
#'   enough to hold them (default `TRUE`).
#' @param border_color Color of block outlines, or `NA` (default) for none.
#' @param title Plot title, or `NULL` (default) for none.
#' @param background Background color (default `"white"`).
#' @param shadow Draw drop shadows (default `TRUE`).
#' @param legend_text_size Size of the legend text (default 0.8).
#' @param tick_opacity Opacity of the ticks in the index display, between 0
#'   and 1 (default 0.85).
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
#' @seealso [sequence_snake()] for one sequence; [timeline_snake()] for dated
#'   phases; [survey_sequence()] for ordinal survey responses.
#'
#' @examples
#' # 50 students observed over 33 weeks
#' set.seed(42)
#' weeks <- matrix(
#'   sample(c("Active", "Passive", "Absent"), 50 * 33, replace = TRUE,
#'          prob = c(0.5, 0.3, 0.2)),
#'   nrow = 50
#' )
#' multi_snake(weeks, sort_by = "freq",
#'             colors = c(Active = "#009E73", Passive = "#E69F00",
#'                        Absent = "#999999"))
#' multi_snake(weeks, type = "distribution")
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
                        flow = c("snake", "natural"),
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
  flow    <- match.arg(flow)

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
    plot_width = plot_width, margin = margin,
    flow = flow
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
    bh2 <- layout$params$band_height / 2
    cap_side1 <- if (bands$direction[1L] == "ltr") "left" else "right"
    cap_x1 <- if (cap_side1 == "left") bands$x_left[1L] else bands$x_right[1L]
    cap1 <- end_cap_polygon(cap_x1, bands$y_center[1L], bh2, cap_side1)
    polygon(cap1$x, cap1$y, col = "#E8E8E8", border = NA)

    cap_side2 <- if (bands$direction[rows] == "ltr") "right" else "left"
    cap_x2 <- if (cap_side2 == "right") bands$x_right[rows] else bands$x_left[rows]
    cap2 <- end_cap_polygon(cap_x2, bands$y_center[rows], bh2, cap_side2)
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
