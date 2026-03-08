#' Format minutes as human-readable duration
#'
#' @param minutes Numeric, duration in minutes.
#' @return Character string like "2h 35m" or "45m".
#' @noRd
format_duration <- function(minutes) {
  stopifnot(is.numeric(minutes), length(minutes) == 1L, minutes >= 0)
  h <- floor(minutes / 60)
  m <- round(minutes %% 60)

  if (h > 0) sprintf("%dh %dm", h, m) else sprintf("%dm", m)
}

#' Convert minutes-from-midnight to clock label
#'
#' @param minutes Numeric, minutes from midnight (0-1440).
#' @return Character like "6AM", "12PM", "9PM".
#' @noRd
minutes_to_label <- function(minutes) {
  stopifnot(is.numeric(minutes))
  hours <- (minutes / 60) %% 24
  vapply(hours, function(h) {
    h_int <- floor(h)
    if (h_int == 0 || h_int == 24) return("12AM")
    if (h_int == 12) return("12PM")
    if (h_int < 12) return(sprintf("%dAM", h_int))
    sprintf("%dPM", h_int - 12L)
  }, character(1))
}

#' Map time value to x-coordinate (horizontal bands)
#'
#' @param time Numeric vector, minutes from midnight.
#' @param day_start Numeric, start of display window.
#' @param day_end Numeric, end of display window.
#' @param x_left Numeric, left edge of band in plot coords.
#' @param x_right Numeric, right edge of band in plot coords.
#' @param direction Character, "ltr" or "rtl".
#' @return Numeric vector of x-coordinates.
#' @noRd
time_to_x <- function(time, day_start, day_end, x_left, x_right,
                      direction = "ltr") {
  frac <- (time - day_start) / (day_end - day_start)
  if (direction == "ltr") {
    x_left + frac * (x_right - x_left)
  } else {
    x_right - frac * (x_right - x_left)
  }
}

#' Map time value to y-coordinate (vertical bands)
#'
#' @param time Numeric vector, minutes from midnight.
#' @param day_start Numeric, start of display window.
#' @param day_end Numeric, end of display window.
#' @param y_top Numeric, top edge of band in plot coords.
#' @param y_bottom Numeric, bottom edge of band in plot coords.
#' @param direction Character, "ttb" (top-to-bottom) or "btt".
#' @return Numeric vector of y-coordinates.
#' @noRd
time_to_y <- function(time, day_start, day_end, y_top, y_bottom,
                      direction = "ttb") {
  frac <- (time - day_start) / (day_end - day_start)
  if (direction == "ttb") {
    y_top + frac * (y_bottom - y_top)
  } else {
    y_bottom - frac * (y_bottom - y_top)
  }
}

#' Validate that a value is a positive number
#'
#' @param x Value to check.
#' @param name Name for error message.
#' @noRd
assert_positive <- function(x, name = deparse(substitute(x))) {
  if (!is.numeric(x) || length(x) != 1L || x <= 0) {
    stop(sprintf("'%s' must be a single positive number, got %s", name,
                 deparse(x)), call. = FALSE)
  }
}

#' Coerce input to a data.frame for activity_snake
#'
#' Accepts a bare POSIXct vector, a data.frame, or a matrix.
#' @param data POSIXct vector, or data.frame.
#' @return A data.frame suitable for prepare_timestamps / validate_activity_data.
#' @noRd
coerce_activity_input <- function(data) {
  if (inherits(data, "POSIXt")) {
    return(data.frame(timestamp = data))
  }
  data
}

#' Coerce input to counts/labels/levels for survey_snake
#'
#' If \code{counts} is a data.frame of raw survey responses (each column is
#' an item, each cell is a response value), auto-tabulate into a counts matrix.
#'
#' @param counts Matrix, data.frame of counts, or data.frame of raw responses.
#' @param labels Character vector or NULL.
#' @param levels Character vector or NULL.
#' @return A list with \code{counts} (matrix), \code{labels}, \code{levels}.
#' @noRd
coerce_survey_input <- function(counts, labels, levels) {
  if (is.matrix(counts)) {
    return(list(counts = counts, labels = labels, levels = levels))
  }

  if (is.data.frame(counts)) {
    # Check if this looks like raw responses (non-numeric columns, or
    # values that aren't plausible counts — e.g., small integers repeated)
    # Heuristic: if all columns are factors/character/integer with few unique
    # values relative to nrow, treat as raw responses
    is_raw <- vapply(counts, function(col) {
      is.factor(col) || is.character(col) ||
        (is.numeric(col) && length(unique(col)) <= 20 &&
         all(col == round(col), na.rm = TRUE))
    }, logical(1))

    if (all(is_raw) && nrow(counts) > max(vapply(counts, function(col) length(unique(col)), integer(1))) * 2) {
      # Raw responses — tabulate each column
      all_levels <- if (!is.null(levels)) {
        levels
      } else {
        # Use factor levels if any column is a factor, else sort unique values
        first_factor <- which(vapply(counts, is.factor, logical(1)))[1]
        if (!is.na(first_factor)) {
          as.character(base::levels(counts[[first_factor]]))
        } else {
          lvs <- sort(unique(unlist(lapply(counts, unique))))
          as.character(lvs)
        }
      }

      count_mat <- t(vapply(counts, function(col) {
        tbl <- table(factor(col, levels = all_levels))
        as.integer(tbl)
      }, integer(length(all_levels))))

      auto_labels <- if (!is.null(labels)) {
        labels
      } else {
        nms <- names(counts)
        n <- nrow(count_mat)
        paste0(nms, " (n=", rowSums(count_mat), ")")
      }

      return(list(counts = count_mat, labels = auto_labels,
                  levels = all_levels))
    }

    # Otherwise treat as a counts data.frame — coerce to matrix
    return(list(counts = as.matrix(counts), labels = labels, levels = levels))
  }

  list(counts = counts, labels = labels, levels = levels) # nocov
}

#' Convert timestamp data to activity data format
#'
#' Detects POSIXt columns and converts to day/start/duration format.
#'
#' @param data A data.frame with a timestamp or POSIXt start column.
#' @param day_format strftime format for day labels. NULL = auto-detect.
#' @return Converted data.frame with day, start, duration columns,
#'   or NULL if no timestamps detected.
#' @noRd
prepare_timestamps <- function(data, day_format = NULL) {
  # Find the timestamp column
  ts_col <- if ("timestamp" %in% names(data) &&
                inherits(data$timestamp, "POSIXt")) {
    "timestamp"
  } else if ("start" %in% names(data) && inherits(data$start, "POSIXt")) {
    "start"
  } else {
    return(NULL)
  }

  ts <- data[[ts_col]]
  dates <- as.Date(ts)

  # Day labels: auto-detect or use provided format
  if (is.null(day_format)) {
    n_unique <- length(unique(dates))
    day_format <- if (n_unique <= 7L) "%a" else "%Y-%m-%d"
  }
  day_labels <- format(ts, day_format)

  # Minutes from midnight
  h <- as.numeric(format(ts, "%H"))
  m <- as.numeric(format(ts, "%M"))
  s <- as.numeric(format(ts, "%S"))
  start_mins <- h * 60 + m + s / 60

  # Duration
  duration <- if ("end" %in% names(data) && inherits(data$end, "POSIXt")) {
    as.numeric(difftime(data$end, ts, units = "mins"))
  } else if ("duration" %in% names(data) && is.numeric(data$duration)) {
    data$duration
  } else {
    rep(0, nrow(data))
  }

  # Preserve day order by first occurrence
  unique_days <- unique(day_labels)
  result <- data.frame(
    day      = factor(day_labels, levels = unique_days),
    start    = start_mins,
    duration = duration,
    stringsAsFactors = FALSE
  )
  if ("label" %in% names(data)) result$label <- data$label
  result
}

#' Validate activity data
#'
#' @param data A data.frame with columns day, start, duration.
#' @return The validated data.frame (day converted to factor if needed).
#' @noRd
validate_activity_data <- function(data) {
  if (!is.data.frame(data)) {
    stop("'data' must be a data.frame with columns: day, start, duration",
         call. = FALSE)
  }
  required <- c("day", "start", "duration")
  missing_cols <- setdiff(required, names(data))
  if (length(missing_cols) > 0) {
    stop(sprintf("'data' is missing columns: %s",
                 paste(missing_cols, collapse = ", ")), call. = FALSE)
  }
  if (!is.numeric(data$start)) stop("'start' must be numeric", call. = FALSE)
  if (!is.numeric(data$duration)) {
    stop("'duration' must be numeric", call. = FALSE)
  }
  if (any(data$duration < 0, na.rm = TRUE)) {
    stop("'duration' must be non-negative", call. = FALSE)
  }
  if (!is.factor(data$day)) {
    data$day <- factor(data$day, levels = unique(data$day))
  }
  data
}

#' Validate survey data inputs
#'
#' @param counts Matrix of response counts (rows=items, cols=levels).
#' @param labels Character vector of item labels.
#' @param levels Character vector of level labels.
#' @return Invisible NULL (stops on error).
#' @noRd
validate_survey_data <- function(counts, labels, levels) {
  if (!is.matrix(counts)) {
    if (is.data.frame(counts)) {
      counts <- as.matrix(counts)
    } else {
      stop("'counts' must be a matrix or data.frame", call. = FALSE)
    }
  }
  if (!is.numeric(counts)) stop("'counts' must be numeric", call. = FALSE)
  if (nrow(counts) != length(labels)) {
    stop(sprintf("nrow(counts) = %d but length(labels) = %d; must match",
                 nrow(counts), length(labels)), call. = FALSE)
  }
  if (ncol(counts) != length(levels)) {
    stop(sprintf("ncol(counts) = %d but length(levels) = %d; must match",
                 ncol(counts), length(levels)), call. = FALSE)
  }
  invisible(NULL)
}
