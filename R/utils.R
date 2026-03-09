#' Parse timestamps from flexible formats
#'
#' Robust date/time parser inspired by tna's \code{parse_time()}. Accepts
#' POSIXct (pass-through), character strings in 40+ formats, or numeric Unix
#' timestamps. Tries each format until one works.
#'
#' @param time Character, numeric, or POSIXct vector.
#' @param custom_format Optional strptime format string to try first.
#' @return POSIXct vector, or \code{NULL} if parsing fails completely.
#' @noRd
parse_time <- function(time, custom_format = NULL) {
  # Already POSIXct — pass through
  if (inherits(time, "POSIXct")) return(time)
  if (inherits(time, "POSIXlt")) return(as.POSIXct(time))

  # Numeric — assume Unix timestamps
  if (is.numeric(time)) {
    # Auto-detect unit: seconds vs milliseconds vs microseconds
    med <- stats::median(abs(time), na.rm = TRUE)
    if (med > 1e15) {
      return(as.POSIXct(time / 1e6, origin = "1970-01-01"))
    } else if (med > 1e12) {
      return(as.POSIXct(time / 1e3, origin = "1970-01-01"))
    } else {
      return(as.POSIXct(time, origin = "1970-01-01"))
    }
  }

  # Character — try formats
  time <- trimws(as.character(time))

  # Handle empty/NA
  empty <- is.na(time) | !nzchar(time)
  if (all(empty)) return(NULL)

  # Strip trailing timezone letters (Z), milliseconds, trailing whitespace
  clean <- gsub("(\\.\\d{1,6})?[Zz]?\\s*$", "", time)

  # Try custom format first

  if (!is.null(custom_format)) {
    parsed <- as.POSIXct(strptime(clean, format = custom_format))
    if (sum(!is.na(parsed)) > sum(empty)) return(parsed)
  }

  # Special case: YYYY-MM → append -01
  is_ym <- grepl("^\\d{4}-\\d{2}$", clean)
  if (any(is_ym)) {
    clean[is_ym] <- paste0(clean[is_ym], "-01")
  }

  # Comprehensive format list (adapted from tna::parse_time)
  formats <- c(
    # Standard YYYY-MM-DD with time
    "%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M",
    "%Y/%m/%d %H:%M:%S", "%Y/%m/%d %H:%M",
    "%Y.%m.%d %H:%M:%S", "%Y.%m.%d %H:%M",

    # ISO 8601 with T separator
    "%Y-%m-%dT%H:%M:%S", "%Y-%m-%dT%H:%M",

    # With timezone offset
    "%Y-%m-%d %H:%M:%S%z", "%Y-%m-%d %H:%M%z",

    # Compact (no separators)
    "%Y%m%d%H%M%S", "%Y%m%d%H%M",

    # Day first
    "%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M",
    "%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M",
    "%d.%m.%Y %H:%M:%S", "%d.%m.%Y %H:%M",

    # Month first (US)
    "%m-%d-%Y %H:%M:%S", "%m-%d-%Y %H:%M",
    "%m/%d/%Y %H:%M:%S", "%m/%d/%Y %H:%M",

    # Month names
    "%d %b %Y %H:%M:%S", "%d %b %Y %H:%M",
    "%d %B %Y %H:%M:%S", "%d %B %Y %H:%M",
    "%b %d %Y %H:%M:%S", "%b %d %Y %H:%M",
    "%B %d %Y %H:%M:%S", "%B %d %Y %H:%M",
    "%b %d, %Y %H:%M:%S", "%b %d, %Y %H:%M",
    "%B %d, %Y %H:%M:%S", "%B %d, %Y %H:%M",

    # Date-only formats
    "%Y-%m-%d", "%Y/%m/%d", "%Y.%m.%d",
    "%d-%m-%Y", "%d/%m/%Y", "%d.%m.%Y",
    "%m-%d-%Y", "%m/%d/%Y",
    "%d %b %Y", "%d %B %Y",
    "%b %d %Y", "%B %d %Y",
    "%b %d, %Y", "%B %d, %Y"
  )

  for (fmt in formats) {
    parsed <- as.POSIXct(strptime(clean, format = fmt))
    n_ok <- sum(!is.na(parsed))
    if (n_ok > sum(empty)) {
      # Sanity check: years should be in 1900-2100 range
      years <- as.integer(format(parsed[!is.na(parsed)], "%Y"))
      if (all(years >= 1900L & years <= 2100L)) return(parsed)
    }
  }

  # Last resort: try numeric conversion (maybe stringified Unix timestamps)
  nums <- suppressWarnings(as.numeric(time))
  if (!all(is.na(nums))) {
    med <- stats::median(abs(nums), na.rm = TRUE)
    if (med > 1e15) return(as.POSIXct(nums / 1e6, origin = "1970-01-01")) # nocov
    if (med > 1e12) return(as.POSIXct(nums / 1e3, origin = "1970-01-01")) # nocov
    if (med > 1e8) return(as.POSIXct(nums, origin = "1970-01-01"))
  }

  NULL
}

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

#' Coerce flexible input to a character vector for sequence_snake
#'
#' Accepts a character/factor/integer vector, a data.frame (extracts first
#' character/factor column), a list (unlists), or a single comma-separated
#' string (splits). NAs are dropped with a warning.
#'
#' @param x Input to coerce.
#' @return Character vector of states.
#' @noRd
coerce_sequence_input <- function(x) {
  # Single string: split by comma (with optional spaces)
  if (is.character(x) && length(x) == 1L && grepl(",", x)) {
    x <- trimws(strsplit(x, ",\\s*")[[1L]])
  }

  # Data.frame: extract first character/factor column
  if (is.data.frame(x)) {
    char_cols <- vapply(x, function(col) {
      is.character(col) || is.factor(col)
    }, logical(1))
    if (any(char_cols)) {
      col_idx <- which(char_cols)[1L]
      message(sprintf("Using column '%s' as sequence", names(x)[col_idx]))
      x <- x[[col_idx]]
    } else {
      stop("data.frame has no character or factor column to use as sequence",
           call. = FALSE)
    }
  }

  # List: unlist
  if (is.list(x)) {
    x <- unlist(x)
  }

  x <- as.character(x)

  # Drop NAs with warning
  na_count <- sum(is.na(x))
  if (na_count > 0L) {
    warning(sprintf("Dropped %d NA values from sequence", na_count),
            call. = FALSE)
    x <- x[!is.na(x)]
  }

  if (length(x) < 1L) {
    stop("'sequence' is empty after removing NAs", call. = FALSE)
  }

  x
}

#' Find a column by name, case-insensitive
#'
#' @param df A data.frame.
#' @param candidates Character vector of candidate column names to try.
#' @return The actual column name found, or NULL if none match.
#' @noRd
find_column <- function(df, candidates) {
  nms <- names(df)
  nms_lower <- tolower(nms)
  for (cand in candidates) {
    # Exact match first
    if (cand %in% nms) return(cand)
    # Case-insensitive
    idx <- which(nms_lower == tolower(cand))
    if (length(idx) > 0L) return(nms[idx[1L]])
  }
  NULL
}

#' Coerce input to a data.frame for activity_snake
#'
#' Accepts a bare POSIXct vector, a character vector of timestamp strings,
#' a data.frame (with case-insensitive column matching), or a matrix.
#' @param data POSIXct vector, character vector of timestamps, or data.frame.
#' @return A data.frame suitable for prepare_timestamps / validate_activity_data.
#' @noRd
coerce_activity_input <- function(data) {
  # Bare POSIXct vector
  if (inherits(data, "POSIXt")) {
    return(data.frame(timestamp = data))
  }

  # Character or numeric vector: try to parse as timestamps
  if ((is.character(data) || is.numeric(data)) && length(data) > 0L) {
    parsed <- parse_time(data)
    if (!is.null(parsed) && !all(is.na(parsed))) {
      return(data.frame(timestamp = parsed))
    }
  }

  # Data.frame: case-insensitive column matching
  if (is.data.frame(data)) {
    nms <- names(data)
    nms_lower <- tolower(nms)

    # Map common column name variants to canonical names
    col_map <- list(
      timestamp = c("timestamp", "time", "datetime", "date_time"),
      start     = c("start", "start_time", "begin"),
      end       = c("end", "end_time", "stop"),
      day       = c("day", "date", "weekday"),
      duration  = c("duration", "dur", "length"),
      label     = c("label", "name", "activity", "event", "category")
    )

    # Find and rename columns
    renamed <- FALSE
    for (canonical in names(col_map)) {
      if (canonical %in% nms) next
      for (variant in col_map[[canonical]]) {
        idx <- which(nms_lower == tolower(variant))
        if (length(idx) > 0L) {
          names(data)[idx[1L]] <- canonical
          renamed <- TRUE
          break
        }
      }
    }

    # Auto-detect POSIXct columns if no timestamp/start found
    if (!("timestamp" %in% names(data)) && !("start" %in% names(data))) {
      posix_cols <- vapply(data, inherits, logical(1), what = "POSIXt")
      if (any(posix_cols)) {
        idx <- which(posix_cols)[1L]
        names(data)[idx] <- "timestamp"
      }
    }

    # Try parsing character columns that look like timestamps
    # (do NOT parse numeric columns — they may be minutes-from-midnight)
    for (col in names(data)) {
      if (col %in% c("timestamp", "start", "end") &&
          is.character(data[[col]])) {
        parsed <- parse_time(data[[col]])
        if (!is.null(parsed)) data[[col]] <- parsed
      }
    }
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
    # Auto-generate labels/levels from dimnames if not provided
    if (is.null(labels) && !is.null(rownames(counts))) {
      labels <- rownames(counts)
    }
    if (is.null(levels) && !is.null(colnames(counts))) {
      levels <- colnames(counts)
    }
    return(list(counts = counts, labels = labels, levels = levels))
  }

  if (is.data.frame(counts)) {
    # Check if this looks like raw responses (non-numeric columns, or
    # values that aren't plausible counts — e.g., small integers repeated)
    # Heuristic: if all columns are factors/character/integer with few unique
    # values relative to nrow, treat as raw responses
    is_raw <- vapply(counts, function(col) {
      is.factor(col) || is.character(col) ||
        (is.numeric(col) && length(unique(na.omit(col))) <= 20 &&
         all(col == round(col), na.rm = TRUE))
    }, logical(1))

    n_unique_max <- max(vapply(counts, function(col) {
      length(unique(na.omit(col)))
    }, integer(1)))

    if (all(is_raw) && nrow(counts) > n_unique_max * 2) {
      # Raw responses — tabulate each column
      all_levels <- if (!is.null(levels)) {
        levels
      } else {
        # Use factor levels if any column is a factor, else sort unique values
        first_factor <- which(vapply(counts, is.factor, logical(1)))[1]
        if (!is.na(first_factor)) {
          as.character(base::levels(counts[[first_factor]]))
        } else {
          lvs <- sort(unique(unlist(lapply(counts, function(col) {
            unique(na.omit(col))
          }))))
          as.character(lvs)
        }
      }

      # Report NA drop count
      total_na <- sum(vapply(counts, function(col) sum(is.na(col)),
                             integer(1)))
      if (total_na > 0L) {
        message(sprintf("Note: %d NA responses excluded from tabulation",
                        total_na))
      }

      count_mat <- t(vapply(counts, function(col) {
        tbl <- table(factor(col, levels = all_levels))
        as.integer(tbl)
      }, integer(length(all_levels))))

      auto_labels <- if (!is.null(labels)) {
        labels
      } else {
        nms <- names(counts)
        paste0(nms, " (n=", rowSums(count_mat), ")")
      }

      return(list(counts = count_mat, labels = auto_labels,
                  levels = all_levels))
    }

    # Otherwise treat as a counts data.frame — coerce to matrix
    mat <- as.matrix(counts)
    if (is.null(labels) && !is.null(rownames(counts))) {
      labels <- rownames(counts)
    }
    if (is.null(levels) && !is.null(colnames(counts))) {
      levels <- colnames(counts)
    }
    return(list(counts = mat, labels = labels, levels = levels))
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
  # Find the timestamp column (case-insensitive)
  ts_col <- NULL
  for (cand in c("timestamp", "start")) {
    found <- find_column(data, cand)
    if (!is.null(found) && inherits(data[[found]], "POSIXt")) {
      ts_col <- found
      break
    }
  }
  if (is.null(ts_col)) return(NULL)

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
  # Case-insensitive column resolution
  required <- c("day", "start", "duration")
  nms <- names(data)
  nms_lower <- tolower(nms)
  for (req in required) {
    if (!(req %in% nms)) {
      idx <- which(nms_lower == req)
      if (length(idx) > 0L) {
        names(data)[idx[1L]] <- req
      }
    }
  }

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
