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
