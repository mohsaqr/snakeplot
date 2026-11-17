#' Plot a timeline of phases as a serpentine of monthly blocks
#'
#' @description
#' A timeline snake plot shows a succession of phases, such as the positions held
#' in a career or the stages of a project, as colored blocks folded into
#' bands joined by U-turns. With dated input each block is one month, so the
#' length of a phase is proportional to its duration and a span of many years
#' fits in one panel while its order is kept.
#'
#' `timeline_snake()` takes a data frame with one row per phase (state, start
#' date, end date) and builds the monthly sequence. It labels each change of
#' phase with its start month, labels each band with the year at its middle,
#' and prints the state names inside the phases. A vector of states, one per
#' time unit, is drawn as given. Colors default to a light-to-dark blue ramp
#' in phase order. The drawing is done by [sequence_snake()], and its display
#' options can be passed here.
#'
#' For an undated sequence of many short events use [sequence_snake()]; for
#' many sequences use [multi_snake()].
#'
#' @param sequence Phases as a data frame whose first three columns are the
#'   state, the start date and the end date, one row per phase. Dates may be
#'   `"YYYY-MM"`, `"YYYY-MM-DD"`, other common date formats, or `Date`
#'   values; start and end months are both included. Alternatively a vector of
#'   states, one per time unit.
#' @inheritParams sequence_snake
#' @param colors State colors: a vector named by state, or an unnamed vector
#'   recycled over the states. `NULL` (default) uses a light-to-dark blue ramp
#'   over the states in order.
#' @param rows Number of bands. `NULL` (default) uses about 20 months per
#'   band and at least two bands for data frame input, and one band per 11
#'   positions for vector input.
#' @param band_gap Gap between bands in plot units (default 30, which leaves
#'   room for the year labels).
#' @param margin Named numeric vector of `top`, `right`, `bottom` and `left`
#'   margins in plot units (default
#'   `c(top = 35, right = 10, bottom = 65, left = 20)`).
#' @param show_labels Label each band with the range of positions it holds
#'   (default `FALSE`).
#' @param show_state Print the state name inside each phase
#'   (default `TRUE`).
#' @param state_size Text size of the state names (default 1).
#' @param transition_labels Labels for the points where the state changes, in
#'   order. `NULL` (default) uses, for data frame input, the start month of
#'   each phase after the first, such as `"Jun 2020"`.
#' @param band_labels One label per band (length `rows`). `NULL` (default)
#'   uses, for data frame input, the year at the middle of each band.
#' @param tick_color Color of ticks and of band and transition labels
#'   (default `"#444444"`).
#' @param tick_length Length of ticks in plot units (default 6).
#' @param tick_size Text size of tick, band and transition labels
#'   (default 0.8).
#' @param legend_text_size Size of the legend text (default 1.2).
#'
#' @return The plot is drawn on the current device; the function returns
#'   `NULL` invisibly.
#'
#' @seealso [sequence_snake()], which draws the plot; [multi_snake()] for
#'   many sequences; [activity_snake()] for events within days.
#'
#' @examples
#' # An academic career, one row per position
#' career <- data.frame(
#'   role  = c("PhD student", "Postdoc", "Lecturer", "Senior lecturer"),
#'   start = c("2012-09", "2016-10", "2019-01", "2023-08"),
#'   end   = c("2016-09", "2018-12", "2023-07", "2025-12")
#' )
#' timeline_snake(career)
#'
#' # The same kind of display from a vector, one element per year
#' schooling <- rep(c("School", "Bachelor", "Master", "Work"),
#'                  times = c(12, 3, 2, 8))
#' timeline_snake(schooling, rows = 3)
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
                           flow = c("natural", "snake"),
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
      if (inherits(x, "POSIXt")) return(.local_date(x)) # nocov
      x <- trimws(as.character(x))
      # YYYY-MM shorthand → YYYY-MM-01 (parse_time handles the rest)
      x <- ifelse(nchar(x) == 7L & grepl("^\\d{4}-\\d{2}$", x),
                   paste0(x, "-01"), x)
      parsed <- parse_time(x)
      if (!is.null(parsed)) return(.local_date(parsed))
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
    flow = match.arg(flow),
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
