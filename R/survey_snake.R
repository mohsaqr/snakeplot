#' Plot survey responses as a serpentine band per item
#'
#' @description
#' A survey snake shows the distribution of responses to a set of rating
#' items, one band per item, with consecutive items joined by U-turns so that
#' a long instrument fits in one panel in its item order. Each band shows
#' every response as a tick placed in the zone of its response level, the
#' item mean as a diamond, and a shade running from warm (low mean) to cool
#' (high mean). The display shows how responses are spread on each item and
#' how the items compare.
#'
#' `survey_snake()` accepts raw responses (one row per respondent, one column
#' per item), a table of counts (one row per item, one column per response
#' level), or experience-sampling data in long format, where `var` and `day`
#' make each day a band and `timestamp` places each response at its time of
#' day. Responses can be drawn as lines, jittered dots, or a stacked bar with
#' percentages. The U-turns can carry the Pearson correlation between the two
#' items they join (`arc_fill = "correlation"`); this needs raw responses,
#' because a table of counts does not record which respondent gave which
#' answer. With `facet`, groups of items are drawn as separate panels.
#'
#' For a compact 100% stacked bar per item use [survey_sequence()], or
#' [sequential_dist()] for scales without a neutral midpoint. Palettes for
#' the response levels are given by [snake_palette()].
#'
#' @param counts Responses, in one of four forms:
#'   * a data frame of raw responses, one row per respondent and one column
#'     per item;
#'   * a numeric matrix of counts, items in rows and response levels in
#'     columns;
#'   * a data frame of counts, converted to a matrix;
#'   * a long data frame of experience-sampling responses, used with `var`
#'     and `day`.
#'
#'   A data frame is read as raw responses when its columns hold few distinct
#'   whole-number or categorical values relative to its number of rows, and
#'   as counts otherwise.
#' @param labels Item labels, one per item. `NULL` (default) uses the row
#'   names of a count table, or, for raw responses, the column names with the
#'   number of responses.
#' @param levels Response levels in scale order. `NULL` (default) uses the
#'   column names of a count table, or, for raw responses, the factor levels
#'   or the sorted distinct values. For raw responses the levels must match
#'   the values in the data; use `level_labels` to relabel them.
#' @param var,day,timestamp Column names for experience-sampling data in long
#'   format: the response variable, the day (or other period) that defines
#'   each band, and optionally a POSIXct timestamp that places each response
#'   at its time of day. Bands are labelled `"Day 1"`, `"Day 2"`, and so on,
#'   and `title` defaults to `var`.
#' @param level_labels Display labels for the response levels: a vector named
#'   by level, such as `c("1" = "Never", "5" = "Always")`, or an unnamed
#'   vector with one label per level.
#' @param band_height,band_gap Height of each band and gap between bands, in
#'   plot units (defaults 28 and 18).
#' @param plot_width Length of each band in plot units (default 500).
#' @param tick_shape `"line"` (default), `"dot"` (jittered points) or
#'   `"bar"` (a stacked bar with percentages).
#' @param bar_reverse For `tick_shape = "bar"`, draw the highest level first
#'   (default `FALSE`).
#' @param tick_opacity Opacity of the ticks, between 0 and 1 (default 0.75).
#' @param level_gap Gap, in plot units, between the zones of adjacent
#'   response levels (default 15; 0 for none).
#' @param color_mode `"level"` (default) colors each tick by its response
#'   level; `"individual"` gives every tick its own hue.
#' @param colors One color per response level, in scale order. Only the first
#'   `length(levels)` colors are used, so pass
#'   `snake_palette(name, n = <number of levels>)`. `NULL` (default) uses a
#'   red-to-blue diverging palette.
#' @param shade_band Has no effect at present: the band is always shaded by
#'   the item mean.
#' @param show_mean Draw a diamond at the item mean (default `TRUE`).
#' @param show_median Draw a dashed line at the item median
#'   (default `FALSE`).
#' @param show_correlation With `arc_fill = "correlation"`, print the
#'   correlation at each U-turn (default `TRUE`).
#' @param jitter_range For `tick_shape = "dot"`, vertical scatter of the
#'   points as a fraction of half the band height (default 0.22).
#' @param sort_by Order of the items: `"none"` (default, input order),
#'   `"mean"` (increasing item mean) or `"net"` (increasing share of
#'   responses above the middle level minus share below; the mean for scales
#'   with fewer than four levels).
#' @param shadow Draw drop shadows (default `TRUE`).
#' @param label_color,label_size Color and size multiplier of the item labels
#'   (defaults `"#333333"` and 0.85).
#' @param label_align Alignment of the item labels: `"left"` (default),
#'   `"right"`, or `"direction"` to follow each band's reading direction.
#' @param show_legend Draw the legend (default `TRUE`).
#' @param legend_text_size Size of the legend text (default 0.65).
#' @param arc_color Color of the U-turns for a positive correlation when
#'   `arc_fill = "correlation"`; a negative correlation uses its complement
#'   (default `"#2c3e6b"`).
#' @param arc_opacity Opacity of the U-turns for `arc_fill = "mean_prev"` and
#'   `"blend"`, and of U-turns without a correlation (default 0.80).
#' @param arc_fill Fill of the U-turns: `"none"` (default) continues the
#'   shades of the two bands it joins; `"correlation"` tints it by the
#'   Pearson correlation between the two items, darker for a larger absolute
#'   value; `"mean_prev"` uses the shade of the preceding item; `"blend"`
#'   mixes the two shades.
#' @param band_palette Two or more colors for the band shade, from low to
#'   high item mean. `NULL` (default) uses a dark brown-to-slate ramp.
#' @param start_from Side on which the first band starts: `"left"` (default)
#'   or `"right"`.
#' @param flow `"snake"` (default): bands alternate direction. `"natural"`:
#'   every band reads in the same direction.
#' @param facet `FALSE` (default) for one panel. `TRUE` groups the columns of
#'   raw responses by name prefix (`LOC1`, `LOC2` become `LOC`; `Emo_Happy`
#'   becomes `Emo`) and draws one panel per group, with the prefix removed
#'   from the item labels and one shared legend in a spare panel. A named list
#'   of column-name vectors gives the groups explicitly.
#' @param facet_ncol Number of panel columns for `facet` (default 2).
#' @param title Plot title, or `NULL` (default) for none.
#' @param margin Named numeric vector of `top`, `right`, `bottom` and `left`
#'   margins in plot units (default
#'   `c(top = 30, right = 10, bottom = 55, left = 100)`).
#' @param background Background color (default `"white"`).
#' @param seed Seed for the random placement of ticks within their zones
#'   (default 42). It is set with [set.seed()], which changes the random
#'   number stream of the session.
#'
#' @return The plot is drawn on the current device. The function returns,
#'   invisibly, an object of class `snake_layout`: a list describing the drawn
#'   geometry, with `bands` (a data frame with one row per item band and
#'   columns `i`, `y_center`, `y_top`, `y_bottom`, `x_left`, `x_right`,
#'   `direction` and `read_direction`), `arcs` (a list with one element per
#'   U-turn), `canvas` and `plot_area` (dimensions in plot units),
#'   `orientation`, `flow` and `params` (the sizes used).
#'
#'   With `arc_fill = "correlation"` the list also holds `correlations`, a
#'   data frame with one row per U-turn and columns `from` and `to` (the item
#'   names), `r` (the Pearson correlation over the respondents who answered
#'   both items; `NA` when fewer than three did or either item is constant
#'   among them) and `n` (the number of those respondents). With other
#'   `arc_fill` values the list has no `correlations` component.
#'   [as.data.frame()][as.data.frame.snake_layout] returns these tables.
#'
#'   With `facet`, a named list of such objects, one per panel.
#'
#' @section Conditions:
#'   An error of class `snakeplot_no_respondent_data` when
#'   `arc_fill = "correlation"` and `counts` is a table of counts or `var`
#'   and `day` are given.
#'
#' @seealso [as.data.frame.snake_layout()] for the tables of the returned
#'   layout; [survey_sequence()] and [sequential_dist()] for stacked bars;
#'   [snake_palette()] for level colors; [ema_emotions], [student_survey] and
#'   [ema_beeps] for example data.
#'
#' @examples
#' # Raw responses: 280 students, ten emotion items rated 1-5
#' survey_snake(ema_emotions, sort_by = "mean")
#'
#' # Correlations between adjacent items on the U-turns
#' survey_snake(ema_emotions, arc_fill = "correlation", tick_shape = "dot")
#'
#' # Experience sampling: one band per study day, responses at their time
#' survey_snake(ema_beeps, var = "happy", day = "day",
#'              timestamp = "start_time")
#'
#' # A table of counts with named levels
#' counts <- matrix(c(110, 210, 79,  84, 42,
#'                    126, 205, 68, 100, 26,
#'                    184, 226, 47,  58, 10),
#'                  nrow = 3, byrow = TRUE,
#'                  dimnames = list(c("LOC1", "LOC2", "LOC3"),
#'                                  c("Never", "Rarely", "Sometimes",
#'                                    "Often", "Always")))
#' survey_snake(counts, tick_shape = "bar",
#'              colors = snake_palette("earth", n = 5))
#'
#' # One panel per group of items
#' survey_snake(student_survey, facet = TRUE, tick_shape = "bar")
#'
#' @export
survey_snake <- function(counts, labels = NULL, levels = NULL,
                         var              = NULL,
                         day              = NULL,
                         timestamp        = NULL,
                         level_labels     = NULL,
                         band_height      = 28,
                         band_gap         = 18,
                         plot_width       = 500,
                         tick_shape       = c("line", "dot", "bar"),
                         bar_reverse      = FALSE,
                         tick_opacity     = 0.75,
                         level_gap        = 15,
                         color_mode       = c("level", "individual"),
                         colors           = NULL,
                         shade_band       = TRUE,
                         show_mean        = TRUE,
                         show_median      = FALSE,
                         show_correlation = TRUE,
                         jitter_range     = 0.22,
                         sort_by          = c("none", "mean", "net"),
                         shadow           = TRUE,
                         label_color      = "#333333",
                         label_size        = 0.85,
                         label_align      = "left",
                         show_legend      = TRUE,
                         legend_text_size       = 0.65,
                         arc_color        = "#2c3e6b",
                         arc_opacity      = 0.80,
                         arc_fill         = c("none", "correlation",
                                              "mean_prev", "blend"),
                         band_palette     = NULL,
                         start_from       = c("left", "right"),
                         flow             = c("snake", "natural"),
                         facet            = FALSE,
                         facet_ncol       = 2L,
                         title            = NULL,
                         margin           = c(top = 30, right = 10,
                                              bottom = 55, left = 100),
                         background       = "white",
                         seed             = 42L) {
  # --- ESM auto-pivot ---
  esm_time_info <- NULL
  if (!is.null(var) && !is.null(day)) {
    stopifnot(is.data.frame(counts), var %in% names(counts),
              day %in% names(counts))
    esm_df <- counts
    vals    <- esm_df[[var]]
    day_col <- esm_df[[day]]
    unique_days <- sort(unique(day_col[!is.na(day_col) & !is.na(vals)]))

    # Time-of-day fractions (0-1) if timestamp column provided
    has_time <- !is.null(timestamp) && timestamp %in% names(esm_df)
    tod <- if (has_time) {
      ts_col <- esm_df[[timestamp]]
      if (!inherits(ts_col, "POSIXct")) ts_col <- as.POSIXct(ts_col)
      dates <- .local_date(ts_col)
      day_start <- as.POSIXct(paste(dates, "00:00:00"),
                               tz = if (is.null(attr(ts_col, "tzone"))) "" else attr(ts_col, "tzone"))
      as.numeric(difftime(ts_col, day_start, units = "hours")) / 24
    } else {
      NULL
    }

    # Store per-day value + time info for tick positioning
    esm_time_info <- lapply(unique_days, function(dy) {
      mask <- day_col == dy & !is.na(vals)
      ti <- list(values = vals[mask])
      ti$time_frac <- if (!is.null(tod)) tod[mask] else NULL
      ti
    })

    # Build counts matrix: rows = days, cols = response levels
    all_vals <- vals[!is.na(vals)]
    esm_levels <- sort(unique(all_vals))
    count_mat <- t(vapply(esm_time_info, function(x) {
      tbl <- table(factor(x$values, levels = esm_levels))
      as.integer(tbl)
    }, integer(length(esm_levels))))
    rownames(count_mat) <- paste0("Day ", seq_along(unique_days))
    counts <- count_mat
    labels <- rownames(count_mat)
    levels <- as.character(esm_levels)
    if (is.null(title)) title <- var
  }

  # --- Facet dispatch ---
  if (!identical(facet, FALSE)) {
    stopifnot(is.data.frame(counts))
    if (isTRUE(facet)) {
      # Auto-detect groups from column name prefixes
      # Try trailing-digit pattern first (LOC1, LOC2 → LOC)
      prefixes <- gsub("[0-9]+$", "", names(counts))
      # If every column is its own group, try underscore prefix (Emo_Happy → Emo)
      if (length(unique(prefixes)) == length(prefixes)) {
        parts <- strsplit(names(counts), "[_.]")
        prefixes <- vapply(parts, `[[`, character(1), 1L)
      }
      groups <- split(names(counts), factor(prefixes, levels = unique(prefixes)))
    } else {
      stopifnot(is.list(facet))
      groups <- facet
    }
    n_groups <- length(groups)
    n_col <- min(facet_ncol, n_groups)
    n_row <- ceiling(n_groups / n_col)
    op_facet <- par(mfrow = c(n_row, n_col), mar = c(0, 0, 0, 0))
    on.exit(par(op_facet), add = TRUE)

    # Collect all formals except facet-specific ones to pass through
    cl <- match.call()
    cl[["facet"]] <- FALSE
    if ("facet_ncol" %in% names(cl)) cl[["facet_ncol"]] <- NULL
    # Suppress per-panel legends; draw one shared legend at the end
    user_legend <- if ("show_legend" %in% names(cl)) {
      eval(cl[["show_legend"]], parent.frame())
    } else {
      TRUE
    }
    cl[["show_legend"]] <- FALSE
    # Shrink bottom margin since panels have no legend
    facet_margin <- c(top = 30, right = 10, bottom = 30, left = 100)
    cl[["margin"]] <- facet_margin

    layouts <- lapply(names(groups), function(nm) {
      grp_df <- counts[, groups[[nm]], drop = FALSE]
      # Clean column names: strip prefix + separator (Emo_Happy → Happy)
      clean <- sub(paste0("^", nm, "[_.]?"), "", names(grp_df))
      # If stripping left anything, use it; otherwise keep original
      clean[clean == ""] <- names(grp_df)[clean == ""]
      names(grp_df) <- clean
      cl[["counts"]] <- grp_df
      cl[["title"]]  <- nm
      eval(cl, parent.frame(2L))
    })
    names(layouts) <- names(groups)

    # Draw shared legend on the remaining empty panel (or below last panel)
    if (user_legend && n_groups < n_row * n_col) {
      # Empty panel available — use it for the legend
      plot.new()
      # Infer levels from first group to build legend items
      first_df <- counts[, groups[[1L]], drop = FALSE]
      coerced_f <- coerce_survey_input(first_df, NULL, NULL)
      n_lev <- ncol(coerced_f$counts)
      f_levels <- coerced_f$levels
      # Apply level_labels to facet legend
      if (!is.null(level_labels)) {
        if (is.null(names(level_labels)) && length(level_labels) == n_lev) {
          f_levels <- as.character(level_labels)
        } else {
          f_levels <- vapply(f_levels, function(lv) {
            if (lv %in% names(level_labels)) level_labels[[lv]] else lv
          }, character(1), USE.NAMES = FALSE)
        }
      }
      f_colors <- if (is.null(colors)) diverging_palette(n_lev) else colors
      arc_fill_m <- match.arg(arc_fill)
      items <- lapply(seq_len(n_lev), function(j) {
        list(label = f_levels[j], color = f_colors[j], type = "tick")
      })
      if (show_correlation && arc_fill_m == "correlation") {
        items <- c(items, list(list(label = "Item r (arc)",
                                    color = arc_color, type = "gradient")))
      }
      items <- c(items, list(list(label = "Low -> High mean",
                                  color = shade_by_value(3, 1, 5, palette = band_palette),
                                  type = "gradient")))
      # Center legend in the empty panel
      plot.window(xlim = c(0, 400), ylim = c(0, 100))
      y_pos <- 50
      total_w <- sum(vapply(items, function(it) {
        strwidth(it$label, cex = legend_text_size) + 20
      }, numeric(1)))
      x_cur <- (400 - total_w) / 2
      lapply(items, function(it) {
        if (!is.null(it$type) && it$type == "tick") {
          segments(x_cur + 2, y_pos - 6, x_cur + 2, y_pos + 6,
                   col = it$color, lwd = 2.5)
          text(x_cur + 8, y_pos, it$label, adj = c(0, 0.5),
               col = "#333333", cex = legend_text_size)
          x_cur <<- x_cur + strwidth(it$label, cex = legend_text_size) + 20
        } else {
          rect(x_cur, y_pos - 5, x_cur + 14, y_pos + 5,
               col = it$color, border = NA)
          text(x_cur + 18, y_pos, it$label, adj = c(0, 0.5),
               col = "#333333", cex = legend_text_size)
          x_cur <<- x_cur + strwidth(it$label, cex = legend_text_size) + 28
        }
      })
    }

    return(invisible(layouts))
  }

  # Auto-detect raw responses and coerce
  coerced <- coerce_survey_input(counts, labels, levels)
  counts  <- coerced$counts
  labels  <- coerced$labels
  levels  <- coerced$levels
  scores  <- coerced$scores

  # Apply level_labels mapping for display
  if (!is.null(level_labels)) {
    if (is.null(names(level_labels)) && length(level_labels) == length(levels)) {
      levels <- as.character(level_labels)
    } else {
      levels <- vapply(levels, function(lv) {
        if (lv %in% names(level_labels)) level_labels[[lv]] else lv
      }, character(1), USE.NAMES = FALSE)
    }
  }

  # Validate
  if (is.data.frame(counts)) counts <- as.matrix(counts) # nocov
  validate_survey_data(counts, labels, levels)
  tick_shape  <- match.arg(tick_shape)
  color_mode  <- match.arg(color_mode)
  sort_by     <- match.arg(sort_by)
  start_from  <- match.arg(start_from)
  arc_fill    <- match.arg(arc_fill)
  flow        <- match.arg(flow)

  # A correlation needs each respondent's answers to both items; a counts
  # table (or an ESM pivot, whose bands are days) has lost that pairing.
  if (arc_fill == "correlation" && is.null(scores)) {
    stop(errorCondition(
      paste(
        "`arc_fill = \"correlation\"` needs raw responses: a data frame with",
        "one row per respondent and one column per item.",
        "A counts table or a `var`/`day` (ESM) pivot does not record which",
        "respondent gave which answer, so item correlations cannot be",
        "computed from it."
      ),
      class = "snakeplot_no_respondent_data", call = NULL
    ))
  }

  n_items  <- nrow(counts)
  n_levels <- ncol(counts)
  if (is.null(colors)) colors <- diverging_palette(n_levels)

  # Local shade helper: uses band_palette if provided
  shade <- function(value) {
    shade_by_value(value, 1, n_levels, palette = band_palette)
  }

  # Compute item statistics
  level_vals <- seq_len(n_levels)
  row_totals <- rowSums(counts)
  item_means <- vapply(seq_len(n_items), function(i) {
    stats::weighted.mean(level_vals, counts[i, ])
  }, numeric(1))
  item_medians <- if (show_median) {
    vapply(seq_len(n_items), function(i) {
      cum_p <- cumsum(counts[i, ]) / row_totals[i]
      level_vals[which(cum_p >= 0.5)[1L]]
    }, numeric(1))
  } else {
    numeric(n_items)
  }

  # Net score: (agree + strongly agree) - (disagree + strongly disagree)
  # Assuming first levels are negative, last are positive
  net_scores <- if (n_levels >= 4) {
    mid <- ceiling(n_levels / 2)
    neg <- rowSums(counts[, seq_len(mid - 1L), drop = FALSE])
    pos <- rowSums(counts[, seq(mid + 1L, n_levels), drop = FALSE])
    (pos - neg) / row_totals
  } else {
    item_means
  }

  # Sort
  item_order <- switch(sort_by,
    none = seq_len(n_items),
    mean = order(item_means),
    net  = order(net_scores)
  )
  counts      <- counts[item_order, , drop = FALSE]
  labels      <- labels[item_order]
  item_means  <- item_means[item_order]
  item_medians <- item_medians[item_order]
  if (!is.null(scores)) scores <- scores[, item_order, drop = FALSE]

  # Adjust margins for legend
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

  # Band body: the shade IS the band (dark warm-to-cool gradient per mean)
  vapply(seq_len(n_items), function(k) {
    bcol <- shade(item_means[k])
    rect(bands$x_left[k], bands$y_top[k],
         bands$x_right[k], bands$y_bottom[k],
         col = bcol, border = NA)
    NA
  }, logical(1))

  # ESM hour grid: subtle hour markers on time-positioned bands
  if (!is.null(esm_time_info)) {
    hour_marks <- c(6, 12, 18)
    hour_fracs <- hour_marks / 24
    vapply(seq_len(n_items), function(k) {
      if (k > length(esm_time_info) || is.null(esm_time_info[[k]]$time_frac))
        return(NA)
      xl <- bands$x_left[k]
      xr <- bands$x_right[k]
      yt <- bands$y_top[k]
      yb <- bands$y_bottom[k]
      pw <- xr - xl
      # Vertical guide lines
      x_hrs <- xl + hour_fracs * pw
      segments(x_hrs, yt, x_hrs, yb, col = alpha_col("#000000", 0.18), lwd = 0.8)
      # Hour labels on the first band only
      if (k == 1L) {
        text(x_hrs, yt - 5, paste0(hour_marks, "h"),
             cex = label_size * 0.8, col = "#444444", font = 2)
      }
      NA
    }, logical(1))
  }

  # Pre-compute adjacent correlations for correlation mode (need range).
  # Computed from respondent-level scores: correlating counts-rebuilt
  # vectors (sorted, pairing lost) gives r near +1 whatever the data.
  correlations <- if (arc_fill == "correlation") {
    .adjacent_correlations(
      scores,
      from = vapply(layout$arcs, function(a) a$from + 1L, integer(1)),
      to   = vapply(layout$arcs, function(a) a$to + 1L, integer(1))
    )
  } else {
    NULL
  }
  arc_r_vals <- if (is.null(correlations)) {
    rep(NA_real_, length(layout$arcs))
  } else {
    correlations$r
  }

  # Arcs — fill style controlled by arc_fill
  lapply(seq_along(layout$arcs), function(a_idx) {
    a <- layout$arcs[[a_idx]]
    i1 <- a$from + 1L
    i2 <- a$to + 1L

    if (arc_fill == "none") {
      # Two-tone: upper half = from-band shade, lower half = to-band shade
      # Full opacity so arcs match band colors seamlessly
      col_upper <- shade(item_means[i1])
      col_lower <- shade(item_means[i2])
      pts_u <- half_arc_polygon(a$cx, a$cy, a$outer_r, a$inner_r,
                                a$side, "upper")
      pts_l <- half_arc_polygon(a$cx, a$cy, a$outer_r, a$inner_r,
                                a$side, "lower")
      polygon(pts_u$x, pts_u$y, col = col_upper, border = NA)
      polygon(pts_l$x, pts_l$y, col = col_lower, border = NA)

    } else if (arc_fill == "correlation") {
      r_val <- arc_r_vals[a_idx]

      acol <- if (!is.na(r_val)) {
        # Positive r → arc_color, negative r → complementary
        tint <- if (r_val >= 0) arc_color else {
          rgb_ac <- grDevices::col2rgb(arc_color)[, 1L]
          grDevices::rgb(255L - rgb_ac[1L], 255L - rgb_ac[2L],
                         255L - rgb_ac[3L], maxColorValue = 255)
        }
        # Blend absolute |r| (85%) with relative rank (15%)
        # so high-r arcs stay dark with mild differentiation
        abs_r <- abs(arc_r_vals)
        r_range <- range(abs_r, na.rm = TRUE)
        rel_frac <- if (r_range[2L] - r_range[1L] < 1e-8) {
          0.5
        } else {
          (abs(r_val) - r_range[1L]) / (r_range[2L] - r_range[1L])
        }
        frac <- 0.85 * abs(r_val) + 0.15 * rel_frac
        # Interpolate arc_color with white: low r → lighter, high r → darker
        tint_rgb <- grDevices::col2rgb(tint)[, 1L]
        mixed <- round(255 + frac * (tint_rgb - 255))
        grDevices::rgb(mixed[1L], mixed[2L], mixed[3L], maxColorValue = 255)
      } else {
        alpha_col(arc_color, arc_opacity)
      }
      polygon(a$pts$x, a$pts$y, col = acol, border = NA)
      # Correlation label
      if (show_correlation && !is.na(r_val)) {
        r_col <- if (r_val >= 0) "#6a9ec0" else "#c0392b"
        text(a$tip_x, a$tip_y, sprintf("r=%.2f", r_val),
             col = r_col, cex = 0.6, font = 2,
             adj = c(if (a$side == "right") 0 else 1, 0.5))
      }

    } else if (arc_fill == "mean_prev") {
      # Solid: upper band's mean shade
      acol <- alpha_col(
        shade(item_means[i1]), arc_opacity)
      polygon(a$pts$x, a$pts$y, col = acol, border = NA)

    } else {
      # "blend": 50/50 RGB average of adjacent band shades
      c1 <- shade(item_means[i1])
      c2 <- shade(item_means[i2])
      acol <- alpha_col(blend_colors(c1, c2), arc_opacity)
      polygon(a$pts$x, a$pts$y, col = acol, border = NA)
    }
  })

  # End caps — match band shades unless using correlation mode
  bh2 <- band_height / 2
  cap1_col <- if (arc_fill == "correlation") {
    alpha_col(arc_color, arc_opacity)
  } else if (arc_fill == "none") {
    shade(item_means[1])
  } else {
    alpha_col(shade(item_means[1]), arc_opacity)
  }
  first_dir <- bands$direction[1]
  cap_side1 <- if (first_dir == "ltr") "left" else "right"
  cap_x1 <- if (cap_side1 == "left") bands$x_left[1] else bands$x_right[1]
  cap1 <- end_cap_polygon(cap_x1, bands$y_center[1], bh2, cap_side1)
  polygon(cap1$x, cap1$y, col = cap1_col, border = NA)
  if (n_items > 1L) {
    last <- n_items
    last_dir <- bands$direction[last]
    cap_side <- if (last_dir == "ltr") "right" else "left"
    cap_x <- if (cap_side == "right") bands$x_right[last] else bands$x_left[last]
    cap2 <- end_cap_polygon(cap_x, bands$y_center[last], bh2, cap_side)
    cap2_col <- if (arc_fill == "correlation") {
      alpha_col(arc_color, arc_opacity)
    } else if (arc_fill == "none") {
      shade(item_means[last])
    } else {
      alpha_col(shade(item_means[last]), arc_opacity)
    }
    polygon(cap2$x, cap2$y, col = cap2_col, border = NA)
  }

  # Tick marks — sorted by level so color bands are visible (low→high),
  # then each level's ticks are shuffled within their proportional zone
  set.seed(seed)
  vapply(seq_len(n_items), function(k) {
    xl  <- bands$x_left[k]
    xr  <- bands$x_right[k]
    yt  <- bands$y_top[k]
    yb  <- bands$y_bottom[k]
    yc  <- bands$y_center[k]
    bh  <- yb - yt
    pw  <- xr - xl

    n_total <- sum(counts[k, ])
    if (n_total == 0L) return(NA)

    if (tick_shape == "bar") {
      # Stacked proportional bars with % labels
      x_cursor <- xl
      draw_order <- if (bar_reverse) rev(level_vals) else level_vals
      for (lv in draw_order) {
        cnt <- counts[k, lv]
        if (cnt == 0L) next
        seg_w <- (cnt / n_total) * pw
        rect(x_cursor, yt, x_cursor + seg_w, yb,
             col = colors[lv], border = NA)
        pct <- round(cnt / n_total * 100)
        if (seg_w > pw * 0.05) {
          text(x_cursor + seg_w / 2, yc, sprintf("%d%%", pct),
               col = "white", cex = 0.65, font = 2)
        }
        x_cursor <- x_cursor + seg_w
      }
    } else if (!is.null(esm_time_info) && k <= length(esm_time_info) &&
               !is.null(esm_time_info[[k]]$time_frac)) {
      # ESM mode: position ticks by time-of-day, color by response level
      ti <- esm_time_info[[k]]
      obs_vals <- ti$values
      obs_tod  <- ti$time_frac
      x_pos <- xl + obs_tod * pw
      obs_colors <- alpha_col(colors[obs_vals], tick_opacity)
      tick_w <- pw / length(obs_vals) * 0.6

      if (tick_shape == "line") {
        rect(x_pos - tick_w / 2, yt + bh * 0.04,
             x_pos + tick_w / 2, yb - bh * 0.04,
             col = obs_colors, border = NA)
      } else {
        jitter_y <- stats::runif(length(x_pos),
                                  -jitter_range, jitter_range) * bh / 2
        points(x_pos, yc + jitter_y, pch = 16, cex = 0.7, col = obs_colors)
      }
    } else {
      # Standard mode: proportional zones by level
      n_nonempty <- sum(counts[k, ] > 0L)
      n_gaps     <- max(0L, n_nonempty - 1L)
      usable_w   <- pw - n_gaps * level_gap

      obs_levels <- integer(0)
      x_pos <- numeric(0)
      x_cursor <- 0
      for (lv in level_vals) {
        cnt <- counts[k, lv]
        if (cnt == 0L) next
        zone_w <- (cnt / n_total) * usable_w
        offsets <- sort(stats::runif(cnt, 0, zone_w))
        x_pos <- c(x_pos, xl + x_cursor + offsets)
        obs_levels <- c(obs_levels, rep(lv, cnt))
        x_cursor <- x_cursor + zone_w + level_gap
      }

      space_per_tick <- usable_w / n_total
      tick_w <- min(space_per_tick * 0.7, pw * 0.008)

      obs_colors <- if (color_mode == "level") {
        alpha_col(colors[obs_levels], tick_opacity)
      } else {
        n_obs <- length(obs_levels)
        hues <- seq(0, 1, length.out = n_obs + 1L)[seq_len(n_obs)]
        alpha_col(grDevices::hsv(hues, 0.7, 0.8), tick_opacity)
      }

      if (tick_shape == "line") {
        rect(x_pos - tick_w / 2, yt + bh * 0.04,
             x_pos + tick_w / 2, yb - bh * 0.04,
             col = obs_colors, border = NA)
      } else {
        jitter_y <- stats::runif(length(x_pos),
                                  -jitter_range, jitter_range) * bh / 2
        points(x_pos, yc + jitter_y, pch = 16, cex = 0.9, col = obs_colors)
      }
    }
    NA
  }, logical(1))

  # Mean markers
  if (show_mean) {
    vapply(seq_len(n_items), function(k) {
      frac <- (item_means[k] - 1) / (n_levels - 1)
      x_pos <- bands$x_left[k] + frac * (bands$x_right[k] - bands$x_left[k])
      sz <- band_height * 0.38
      polygon(
        c(x_pos, x_pos + sz, x_pos, x_pos - sz),
        c(bands$y_center[k] - sz, bands$y_center[k],
          bands$y_center[k] + sz, bands$y_center[k]),
        col = "#FFFFFF", border = "#333333", lwd = 1.5
      )
      NA
    }, logical(1))
  }

  # Median markers
  if (show_median) {
    vapply(seq_len(n_items), function(k) {
      frac <- (item_medians[k] - 1) / (n_levels - 1)
      x_pos <- bands$x_left[k] + frac * (bands$x_right[k] - bands$x_left[k])
      segments(x_pos, bands$y_top[k], x_pos, bands$y_bottom[k],
               col = "#FFFFFF", lwd = 2.5, lty = 2)
      NA
    }, logical(1))
  }

  # Labels
  draw_band_labels(layout, labels, col = label_color, cex = label_size,
                   align = label_align)

  # Legend — tick lines for levels, gradient swatches for profile/mean
  if (show_legend) {
    items <- lapply(seq_len(n_levels), function(j) {
      list(label = levels[j], color = colors[j], type = "tick")
    })
    if (show_correlation && arc_fill == "correlation") {
      items <- c(items, list(list(label = "Item r (arc)",
                                  color = arc_color, type = "gradient")))
    }
    items <- c(items, list(list(label = "Low -> High mean",
                                color = shade_by_value(3, 1, 5, palette = band_palette),
                                type = "gradient")))
    draw_snake_legend(layout, items, cex = legend_text_size)
  }

  layout$correlations <- correlations
  invisible(layout)
}
