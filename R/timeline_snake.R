#' Timeline Snake Plot
#'
#' Displays a career or life-event timeline as a serpentine sequence of
#' colored phases. Each block represents one month, colored by the current
#' state/role. State names are overlaid inside runs of consecutive blocks,
#' and transition dates are shown at juncture points where the state changes.
#'
#' @param sequence Either a character/factor vector of states (one per time
#'   unit), or a \strong{data.frame with 3 columns}: state/role, start date
#'   (\code{"YYYY-MM"} or Date), end date. When a data.frame is given, the
#'   function auto-generates monthly blocks, transition labels, and band
#'   labels.
#' @inheritParams sequence_snake
#' @param band_height Numeric, height of each band (default 28).
#' @param band_gap Numeric, gap between bands (default 18).
#' @param plot_width Numeric, width of each band (default 500).
#' @param margin Named numeric vector with top, right, bottom, left margins
#'   (default \code{c(top = 35, right = 10, bottom = 65, left = 20)}).
#' @param show_labels Logical, show position range labels (default
#'   \code{FALSE}).
#' @param show_state Logical, show state names inside blocks (default
#'   \code{TRUE}).
#' @param state_size Numeric, state label size (default 1).
#' @param tick_size Numeric, text size for band and transition labels
#'   (default 0.8).
#' @param legend_text_size Numeric, legend text size (default 1.2).
#'
#' @return Invisible \code{NULL}. Called for its side effect of producing
#'   a plot.
#'
#' @examples
#' # Data.frame input (easiest)
#' career <- data.frame(
#'   role  = c("Junior", "Senior", "Lead"),
#'   start = c("2018-01", "2020-06", "2023-01"),
#'   end   = c("2020-05", "2022-12", "2024-12")
#' )
#' timeline_snake(career, title = "Career Timeline")
#'
#' @export
timeline_snake <- function(sequence,
                           states = NULL,
                           colors = NULL,
                           rows = NULL,
                           band_height = 28,
                           band_gap = 30,
                           plot_width = 500,
                           margin = c(top = 35, right = 10,
                                      bottom = 65, left = 20),
                           orientation = "horizontal",
                           start_from = "left",
                           show_labels = FALSE,
                           show_legend = TRUE,
                           show_numbers = FALSE,
                           show_state = TRUE,
                           state_size = 1,
                           show_ticks = FALSE,
                           tick_labels = NULL,
                           transition_labels = NULL,
                           transition_pos = NULL,
                           tick_color = "#444444",
                           tick_length = 6,
                           tick_size = 0.8,
                           border_color = NA,
                           block_labels = NULL,
                           band_labels = NULL,
                           title = NULL,
                           background = "white",
                           shadow = TRUE,
                           text_size = 0.5,
                           legend_text_size = 1.2) {

  # --- Auto sequential palette for timelines ---
  if (is.null(colors)) {
    alpha_vec <- if (is.data.frame(sequence)) {
      unique(as.character(sequence[[1]]))
    } else if (!is.null(states)) {
      states
    } else {
      unique(as.character(sequence))
    }
    colors <- timeline_palette(length(alpha_vec))
    names(colors) <- alpha_vec
  }

  # --- Data.frame input: auto-generate monthly blocks ---
  if (is.data.frame(sequence)) {
    df <- sequence
    stopifnot(ncol(df) >= 3L)

    roles     <- as.character(df[[1]])
    start_str <- as.character(df[[2]])
    end_str   <- as.character(df[[3]])

    # Parse dates flexibly via parse_time() — handles YYYY-MM, YYYY-MM-DD,
    # DD/MM/YYYY, month names, Unix timestamps, POSIXt, etc.
    to_date <- function(x) {
      if (inherits(x, "Date")) return(x) # nocov
      if (inherits(x, "POSIXt")) return(as.Date(x)) # nocov
      x <- trimws(as.character(x))
      # YYYY-MM shorthand → YYYY-MM-01 (parse_time handles the rest)
      x <- ifelse(nchar(x) == 7L & grepl("^\\d{4}-\\d{2}$", x),
                   paste0(x, "-01"), x)
      parsed <- parse_time(x)
      if (!is.null(parsed)) return(as.Date(parsed))
      as.Date(x) # nocov
    }
    starts <- to_date(start_str)
    ends   <- to_date(end_str)

    # Months per role (compute once, reuse sequences)
    month_seqs <- mapply(function(s, e) seq.Date(s, e, by = "month"),
                         starts, ends, SIMPLIFY = FALSE)
    months_per <- lengths(month_seqs)

    # Build monthly sequence
    sequence <- rep(roles, months_per)
    total_months <- length(sequence)
    all_months <- do.call(c, month_seqs)

    # Alphabet from data.frame order
    if (is.null(states)) states <- unique(roles)

    # Auto transition labels from start dates (skip first role)
    if (is.null(transition_labels)) {
      transition_labels <- format(starts[-1L], "%b %Y")
    }

    # Auto rows: ~20 blocks per band
    if (is.null(rows)) {
      rows <- max(2L, round(total_months / 20))
    }

    # Auto band labels: approximate year at center of each band
    if (is.null(band_labels)) {
      center_idx <- pmax(1L, round(
        (seq_len(rows) - 0.5) * total_months / rows
      ))
      center_idx <- pmin(center_idx, total_months)
      band_labels <- format(all_months[center_idx], "%Y")
    }
  }

  sequence_snake(
    sequence = sequence,
    states = states,
    colors = colors,
    rows = rows,
    band_height = band_height,
    band_gap = band_gap,
    plot_width = plot_width,
    margin = margin,
    orientation = orientation,
    start_from = start_from,
    show_labels = show_labels,
    show_legend = show_legend,
    show_numbers = show_numbers,
    show_state = show_state,
    state_size = state_size,
    show_ticks = show_ticks,
    tick_labels = tick_labels,
    transition_labels = transition_labels,
    transition_pos = transition_pos,
    tick_color = tick_color,
    tick_length = tick_length,
    tick_size = tick_size,
    border_color = border_color,
    block_labels = block_labels,
    band_labels = band_labels,
    title = title,
    background = background,
    shadow = shadow,
    text_size = text_size,
    legend_text_size = legend_text_size
  )
}

#' Sequential palette for timelines
#'
#' Light-to-dark ramp (sky blue → deep indigo) suitable for ordered phases.
#' @param n Integer, number of colors.
#' @return Character vector of hex colors.
#' @noRd
timeline_palette <- function(n) {
  anchors <- c("#4FC3F7", "#039BE5", "#0277BD", "#01579B", "#1A237E")
  grDevices::colorRampPalette(anchors)(n)
}
