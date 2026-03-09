describe("parse_time()", {
  it("passes POSIXct through unchanged", {
    ts <- as.POSIXct("2024-01-15 08:30:00")
    result <- parse_time(ts)
    expect_s3_class(result, "POSIXct")
    expect_equal(result, ts)
  })

  it("converts POSIXlt to POSIXct", {
    ts <- as.POSIXlt("2024-01-15 08:30:00")
    result <- parse_time(ts)
    expect_s3_class(result, "POSIXct")
  })

  it("parses YYYY-MM-DD HH:MM:SS", {
    result <- parse_time("2024-01-15 08:30:00")
    expect_s3_class(result, "POSIXct")
    expect_equal(format(result, "%Y-%m-%d %H:%M"), "2024-01-15 08:30")
  })

  it("parses YYYY/MM/DD HH:MM:SS", {
    result <- parse_time("2024/01/15 08:30:00")
    expect_s3_class(result, "POSIXct")
  })

  it("parses ISO 8601 with T separator", {
    result <- parse_time("2024-01-15T08:30:00")
    expect_s3_class(result, "POSIXct")
  })

  it("parses date-only YYYY-MM-DD", {
    result <- parse_time("2024-01-15")
    expect_s3_class(result, "POSIXct")
  })

  it("parses DD/MM/YYYY", {
    result <- parse_time("15/01/2024")
    expect_s3_class(result, "POSIXct")
  })

  it("parses month name formats", {
    result <- parse_time("15 Jan 2024 08:30:00")
    expect_s3_class(result, "POSIXct")
  })

  it("parses YYYY-MM (month level)", {
    result <- parse_time("2024-01")
    expect_s3_class(result, "POSIXct")
  })

  it("handles numeric Unix timestamps (seconds)", {
    result <- parse_time(1705312200)
    expect_s3_class(result, "POSIXct")
  })

  it("handles numeric Unix timestamps (milliseconds)", {
    result <- parse_time(1705312200000)
    expect_s3_class(result, "POSIXct")
  })

  it("handles numeric Unix timestamps (microseconds)", {
    result <- parse_time(1705312200000000)
    expect_s3_class(result, "POSIXct")
  })

  it("handles vector of mixed-valid timestamps", {
    x <- c("2024-01-15 08:00:00", "2024-01-16 09:00:00", NA)
    result <- parse_time(x)
    expect_s3_class(result, "POSIXct")
    expect_true(is.na(result[3]))
    expect_false(is.na(result[1]))
  })

  it("strips trailing Z from ISO timestamps", {
    result <- parse_time("2024-01-15T08:30:00Z")
    expect_s3_class(result, "POSIXct")
  })

  it("strips milliseconds", {
    result <- parse_time("2024-01-15T08:30:00.123Z")
    expect_s3_class(result, "POSIXct")
  })

  it("returns NULL for unparseable strings", {
    result <- parse_time(c("not a date", "also not"))
    expect_null(result)
  })

  it("returns NULL for all-NA input", {
    result <- parse_time(c(NA, NA))
    expect_null(result)
  })

  it("respects custom_format", {
    result <- parse_time("15-01-2024 08h30", custom_format = "%d-%m-%Y %Hh%M")
    expect_s3_class(result, "POSIXct")
  })

  it("parses stringified Unix timestamps", {
    result <- parse_time("1705312200")
    expect_s3_class(result, "POSIXct")
  })

  it("handles compact format YYYYMMDDHHMMSS", {
    result <- parse_time("20240115083000")
    expect_s3_class(result, "POSIXct")
  })
})

describe("format_duration()", {
  it("formats hours and minutes", {
    expect_equal(format_duration(0), "0m")
    expect_equal(format_duration(45), "45m")
    expect_equal(format_duration(60), "1h 0m")
    expect_equal(format_duration(90), "1h 30m")
    expect_equal(format_duration(155), "2h 35m")
  })

  it("rejects invalid input", {
    expect_error(format_duration(-1))
    expect_error(format_duration("abc"))
    expect_error(format_duration(c(1, 2)))
  })
})

describe("minutes_to_label()", {
  it("converts minutes to clock labels", {
    expect_equal(minutes_to_label(0), "12AM")
    expect_equal(minutes_to_label(360), "6AM")
    expect_equal(minutes_to_label(720), "12PM")
    expect_equal(minutes_to_label(780), "1PM")
    expect_equal(minutes_to_label(1080), "6PM")
    expect_equal(minutes_to_label(1440), "12AM")
  })

  it("handles vectorized input", {
    result <- minutes_to_label(c(0, 360, 720, 1080))
    expect_equal(result, c("12AM", "6AM", "12PM", "6PM"))
  })
})

describe("time_to_x()", {
  it("maps time to x linearly (ltr)", {
    x <- time_to_x(720, 360, 1440, 100, 600, "ltr")
    expected <- 100 + ((720 - 360) / (1440 - 360)) * 500
    expect_equal(x, expected)
  })

  it("maps time to x reversed (rtl)", {
    x <- time_to_x(720, 360, 1440, 100, 600, "rtl")
    expected <- 600 - ((720 - 360) / (1440 - 360)) * 500
    expect_equal(x, expected)
  })

  it("handles boundary values", {
    expect_equal(time_to_x(360, 360, 1440, 0, 500, "ltr"), 0)
    expect_equal(time_to_x(1440, 360, 1440, 0, 500, "ltr"), 500)
    expect_equal(time_to_x(360, 360, 1440, 0, 500, "rtl"), 500)
    expect_equal(time_to_x(1440, 360, 1440, 0, 500, "rtl"), 0)
  })
})

describe("validate_activity_data()", {
  it("accepts valid data", {
    d <- data.frame(day = "Mon", start = 420, duration = 30)
    result <- validate_activity_data(d)
    expect_s3_class(result, "data.frame")
    expect_true(is.factor(result$day))
  })

  it("preserves factor levels", {
    d <- data.frame(
      day = factor(c("Wed", "Mon"), levels = c("Mon", "Wed")),
      start = c(420, 480), duration = c(30, 60)
    )
    result <- validate_activity_data(d)
    expect_equal(levels(result$day), c("Mon", "Wed"))
  })

  it("rejects missing columns", {
    expect_error(validate_activity_data(data.frame(day = "Mon")),
                 "missing columns")
  })

  it("rejects non-data.frame", {
    expect_error(validate_activity_data(list(day = "Mon")),
                 "must be a data.frame")
  })

  it("rejects negative duration", {
    d <- data.frame(day = "Mon", start = 420, duration = -5)
    expect_error(validate_activity_data(d), "non-negative")
  })
})

describe("validate_survey_data()", {
  it("accepts valid inputs", {
    m <- matrix(1:10, nrow = 2)
    expect_no_error(validate_survey_data(m, c("A", "B"), letters[1:5]))
  })

  it("rejects mismatched dimensions", {
    m <- matrix(1:10, nrow = 2)
    expect_error(validate_survey_data(m, c("A"), letters[1:5]),
                 "must match")
    expect_error(validate_survey_data(m, c("A", "B"), letters[1:3]),
                 "must match")
  })

  it("accepts data.frame counts", {
    df <- data.frame(a = 1:3, b = 4:6, c = 7:9)
    expect_no_error(validate_survey_data(df, c("X", "Y", "Z"),
                                         c("lo", "mid", "hi")))
  })
})

describe("prepare_timestamps()", {
  it("converts POSIXct start column", {
    ts <- as.POSIXct(c("2024-01-15 08:30:00", "2024-01-15 14:00:00",
                        "2024-01-16 09:00:00"))
    d <- data.frame(start = ts)
    result <- prepare_timestamps(d)
    expect_s3_class(result, "data.frame")
    expect_true(all(c("day", "start", "duration") %in% names(result)))
    expect_equal(result$start[1], 8 * 60 + 30)
    expect_equal(result$start[2], 14 * 60)
    expect_equal(result$duration, c(0, 0, 0))
  })

  it("converts timestamp column", {
    ts <- as.POSIXct(c("2024-01-15 10:00:00", "2024-01-15 12:30:00"))
    d <- data.frame(timestamp = ts)
    result <- prepare_timestamps(d)
    expect_equal(result$start[1], 600)
    expect_equal(result$start[2], 750)
  })

  it("computes duration from end column", {
    ts_start <- as.POSIXct(c("2024-01-15 08:00:00", "2024-01-15 14:00:00"))
    ts_end   <- as.POSIXct(c("2024-01-15 08:45:00", "2024-01-15 15:30:00"))
    d <- data.frame(start = ts_start, end = ts_end)
    result <- prepare_timestamps(d)
    expect_equal(result$duration, c(45, 90))
  })

  it("uses day_format argument", {
    ts <- as.POSIXct(c("2024-01-15 10:00:00", "2024-01-16 10:00:00"))
    d <- data.frame(start = ts)
    result <- prepare_timestamps(d, day_format = "%b %d")
    expect_equal(levels(result$day), c("Jan 15", "Jan 16"))
  })

  it("returns NULL for non-timestamp data", {
    d <- data.frame(day = "Mon", start = 420, duration = 30)
    expect_null(prepare_timestamps(d))
  })

  it("preserves label column", {
    ts <- as.POSIXct("2024-01-15 08:00:00")
    d <- data.frame(start = ts, label = "Meeting")
    result <- prepare_timestamps(d)
    expect_equal(result$label, "Meeting")
  })
})

describe("coerce_activity_input()", {
  it("wraps bare POSIXct vector into data.frame", {
    ts <- as.POSIXct(c("2024-01-15 08:00:00", "2024-01-15 09:00:00"))
    result <- coerce_activity_input(ts)
    expect_s3_class(result, "data.frame")
    expect_true("timestamp" %in% names(result))
    expect_s3_class(result$timestamp, "POSIXct")
  })

  it("passes data.frame through unchanged", {
    d <- data.frame(day = "Mon", start = 420, duration = 30)
    result <- coerce_activity_input(d)
    expect_identical(result, d)
  })
})

describe("coerce_survey_input()", {
  it("auto-tabulates raw response data.frame", {
    set.seed(42)
    df <- data.frame(
      Q1 = sample(1:5, 100, replace = TRUE),
      Q2 = sample(1:5, 100, replace = TRUE)
    )
    result <- coerce_survey_input(df, NULL, NULL)
    expect_true(is.matrix(result$counts))
    expect_equal(nrow(result$counts), 2)
    expect_equal(ncol(result$counts), 5)
    expect_equal(sum(result$counts[1, ]), 100)
    expect_equal(length(result$labels), 2)
    expect_equal(length(result$levels), 5)
  })

  it("respects explicit levels for raw responses", {
    df <- data.frame(A = sample(1:3, 50, replace = TRUE))
    result <- coerce_survey_input(df, NULL, c("1", "2", "3"))
    expect_equal(result$levels, c("1", "2", "3"))
    expect_equal(ncol(result$counts), 3)
  })

  it("handles factor columns", {
    lvs <- c("Low", "Med", "High")
    df <- data.frame(
      X = factor(sample(lvs, 60, replace = TRUE), levels = lvs),
      Y = factor(sample(lvs, 60, replace = TRUE), levels = lvs)
    )
    result <- coerce_survey_input(df, NULL, NULL)
    expect_equal(result$levels, lvs)
    expect_equal(nrow(result$counts), 2)
  })

  it("passes matrix through unchanged", {
    m <- matrix(1:10, nrow = 2)
    result <- coerce_survey_input(m, c("A", "B"), c("1", "2", "3", "4", "5"))
    expect_identical(result$counts, m)
  })
})

describe("coerce_sequence_input()", {
  it("passes character vector through", {
    x <- c("A", "B", "C")
    expect_equal(coerce_sequence_input(x), x)
  })

  it("converts factor to character", {
    x <- factor(c("X", "Y", "Z"))
    expect_equal(coerce_sequence_input(x), c("X", "Y", "Z"))
  })

  it("splits comma-separated string", {
    result <- coerce_sequence_input("A, B, C, A")
    expect_equal(result, c("A", "B", "C", "A"))
  })

  it("splits string without spaces after commas", {
    result <- coerce_sequence_input("Read,Write,Discuss")
    expect_equal(result, c("Read", "Write", "Discuss"))
  })

  it("extracts first character column from data.frame", {
    df <- data.frame(id = 1:3, state = c("A", "B", "C"),
                     stringsAsFactors = FALSE)
    expect_message(
      result <- coerce_sequence_input(df),
      "Using column"
    )
    expect_equal(result, c("A", "B", "C"))
  })

  it("extracts factor column from data.frame", {
    df <- data.frame(id = 1:3,
                     cat = factor(c("X", "Y", "Z")))
    expect_message(
      result <- coerce_sequence_input(df),
      "Using column"
    )
    expect_equal(result, c("X", "Y", "Z"))
  })

  it("errors on data.frame with no character/factor columns", {
    df <- data.frame(a = 1:3, b = 4:6)
    expect_error(coerce_sequence_input(df), "no character or factor")
  })

  it("unlists a list", {
    x <- list("A", "B", c("C", "D"))
    expect_equal(coerce_sequence_input(x), c("A", "B", "C", "D"))
  })

  it("drops NAs with warning", {
    x <- c("A", NA, "B", NA, "C")
    expect_warning(
      result <- coerce_sequence_input(x),
      "Dropped 2 NA"
    )
    expect_equal(result, c("A", "B", "C"))
  })

  it("errors on all-NA input", {
    expect_warning(
      expect_error(
        coerce_sequence_input(c(NA, NA)),
        "empty after removing NAs"
      ),
      "Dropped"
    )
  })

  it("converts integers to character", {
    expect_equal(coerce_sequence_input(1:3), c("1", "2", "3"))
  })
})

describe("find_column()", {
  it("finds exact match", {
    df <- data.frame(timestamp = 1, value = 2)
    expect_equal(find_column(df, "timestamp"), "timestamp")
  })

  it("finds case-insensitive match", {
    df <- data.frame(Timestamp = 1, Value = 2)
    expect_equal(find_column(df, "timestamp"), "Timestamp")
  })

  it("returns NULL when no match", {
    df <- data.frame(x = 1, y = 2)
    expect_null(find_column(df, "timestamp"))
  })

  it("prefers exact match over case-insensitive", {
    df <- data.frame(Day = 1, day = 2)
    expect_equal(find_column(df, "day"), "day")
  })

  it("accepts multiple candidates", {
    df <- data.frame(Time = 1, value = 2)
    expect_equal(find_column(df, c("timestamp", "time")), "Time")
  })
})

describe("coerce_activity_input() — enhanced", {
  it("parses character timestamps", {
    ts <- c("2024-01-15 08:00:00", "2024-01-15 09:00:00")
    result <- coerce_activity_input(ts)
    expect_s3_class(result, "data.frame")
    expect_s3_class(result$timestamp, "POSIXct")
  })

  it("renames case-variant columns", {
    d <- data.frame(
      Day = c("Mon", "Tue"),
      Start = c(420, 480),
      Duration = c(30, 60)
    )
    result <- coerce_activity_input(d)
    expect_true("day" %in% names(result))
    expect_true("start" %in% names(result))
    expect_true("duration" %in% names(result))
  })

  it("finds aliased column names", {
    d <- data.frame(
      date = c("Mon", "Tue"),
      begin = c(420, 480),
      dur = c(30, 60)
    )
    result <- coerce_activity_input(d)
    expect_true("day" %in% names(result))
    expect_true("start" %in% names(result))
    expect_true("duration" %in% names(result))
  })

  it("auto-detects POSIXct column in data.frame", {
    ts <- as.POSIXct(c("2024-01-15 08:00:00", "2024-01-15 09:00:00"))
    d <- data.frame(my_times = ts, val = 1:2)
    result <- coerce_activity_input(d)
    expect_true("timestamp" %in% names(result))
  })

  it("parses character timestamp columns in data.frame", {
    d <- data.frame(
      timestamp = c("2024-01-15 08:00:00", "2024-01-15 09:00:00"),
      stringsAsFactors = FALSE
    )
    result <- coerce_activity_input(d)
    expect_s3_class(result$timestamp, "POSIXct")
  })
})

describe("coerce_survey_input() — enhanced", {
  it("auto-labels from matrix rownames", {
    m <- matrix(1:10, nrow = 2)
    rownames(m) <- c("Q1", "Q2")
    colnames(m) <- c("1", "2", "3", "4", "5")
    result <- coerce_survey_input(m, NULL, NULL)
    expect_equal(result$labels, c("Q1", "Q2"))
    expect_equal(result$levels, c("1", "2", "3", "4", "5"))
  })

  it("handles NAs in raw responses", {
    df <- data.frame(
      Q1 = c(1, 2, NA, 3, 1, 2, 3, 1, 2, 3,
             1, 2, 3, 1, 2, 3, 1, 2, 3, 1,
             2, 3, 1, 2, 3, 1, 2, 3, 1, 2),
      Q2 = c(1, NA, 3, 2, 1, 3, 2, 1, 3, 2,
             1, 3, 2, 1, 3, 2, 1, 3, 2, 1,
             3, 2, 1, 3, 2, 1, 3, 2, 1, 3)
    )
    expect_message(
      result <- coerce_survey_input(df, NULL, NULL),
      "NA responses excluded"
    )
    expect_true(is.matrix(result$counts))
    # NAs should be excluded from counts
    expect_true(sum(result$counts[1, ]) < 30)
  })

  it("auto-labels from data.frame colnames", {
    df <- data.frame(a = 1:3, b = 4:6, c = 7:9)
    result <- coerce_survey_input(df, NULL, NULL)
    # Treated as counts matrix (3 rows, few unique values but
    # nrow <= n_unique * 2) — should get colnames as levels
    expect_equal(result$levels, c("a", "b", "c"))
  })
})

describe("validate_activity_data() — case-insensitive", {
  it("accepts capitalized column names", {
    d <- data.frame(Day = "Mon", Start = 420, Duration = 30)
    result <- validate_activity_data(d)
    expect_s3_class(result, "data.frame")
    expect_true("day" %in% names(result))
  })
})

describe("assert_positive()", {
  it("accepts positive numbers", {
    expect_no_error(assert_positive(5))
    expect_no_error(assert_positive(0.001))
  })

  it("rejects non-positive values", {
    expect_error(assert_positive(0), "positive")
    expect_error(assert_positive(-1), "positive")
    expect_error(assert_positive("a"), "positive")
  })
})
