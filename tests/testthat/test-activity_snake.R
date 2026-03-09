describe("activity_snake()", {
  # Shared test data constructor
  make_activity_data <- function(n_days = 7, n_events = 10) {
    days <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")[seq_len(n_days)]
    data.frame(
      day      = rep(days, each = n_events),
      start    = round(stats::runif(n_days * n_events, 360, 1400)),
      duration = round(stats::runif(n_days * n_events, 0, 120)),
      stringsAsFactors = FALSE
    )
  }

  it("produces a plot without error (duration blocks)", {
    set.seed(1)
    d <- make_activity_data(7, 8)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      activity_snake(d)
    })
  })

  it("produces a plot without error (rug ticks)", {
    set.seed(2)
    d <- make_activity_data(7, 40)
    d$duration <- 0
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      activity_snake(d, tick_width = 1.0)
    })
  })

  it("returns a snake_layout invisibly", {
    set.seed(3)
    d <- make_activity_data(3, 5)
    pdf(nullfile())
    on.exit(dev.off())
    result <- activity_snake(d)
    expect_s3_class(result, "snake_layout")
    expect_equal(nrow(result$bands), 3)
  })

  it("works with a single day", {
    d <- data.frame(day = "Mon", start = c(420, 720), duration = c(30, 60))
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      activity_snake(d)
    })
  })

  it("works with factor-ordered days", {
    d <- data.frame(
      day      = factor(rep(c("Sun", "Sat"), each = 3),
                        levels = c("Sat", "Sun")),
      start    = c(420, 600, 900, 480, 720, 1080),
      duration = rep(30, 6)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- activity_snake(d)
    expect_equal(nrow(result$bands), 2)
  })

  it("respects per-day color arrays", {
    set.seed(4)
    d <- make_activity_data(3, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      activity_snake(d,
                     band_color = c("#2d2d3d", "#1a3a3a"),
                     event_color = c("#e09480", "#00cec9"))
    })
  })

  it("handles empty events for a day", {
    d <- data.frame(
      day      = factor(c("Mon", "Tue"), levels = c("Mon", "Tue", "Wed")),
      start    = c(420, 720),
      duration = c(30, 60)
    )
    # Wed has no events
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      activity_snake(d)
    })
  })

  it("renders with title and legend", {
    set.seed(5)
    d <- make_activity_data(5, 6)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      activity_snake(d, title = "Test Title",
                     legend = list(
                       list(label = "Timeline", color = "#3d3d4a"),
                       list(label = "Events", color = "#d4a843")
                     ))
    })
  })

  it("rejects invalid data", {
    expect_error(activity_snake(data.frame(x = 1)), "missing columns")
    expect_error(activity_snake("not_a_df"), "must be a data.frame")
  })

  it("rejects invalid parameters", {
    d <- data.frame(day = "Mon", start = 420, duration = 30)
    expect_error(activity_snake(d, band_height = -1), "positive")
    expect_error(activity_snake(d, band_gap = 0), "positive")
  })

  it("handles show_count option", {
    set.seed(6)
    d <- make_activity_data(3, 10)
    pdf(nullfile())
    on.exit(dev.off())
    expect_no_error(activity_snake(d, show_count = TRUE, show_total = TRUE))
  })

  it("accepts POSIXct timestamps and converts automatically", {
    ts <- as.POSIXct(c(
      "2024-01-15 08:30:00", "2024-01-15 14:00:00",
      "2024-01-16 09:15:00", "2024-01-16 18:00:00"
    ))
    d <- data.frame(timestamp = ts)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      activity_snake(d)
    })
  })

  it("computes duration from end timestamps", {
    ts_s <- as.POSIXct(c("2024-01-15 08:00:00", "2024-01-15 14:00:00"))
    ts_e <- as.POSIXct(c("2024-01-15 08:45:00", "2024-01-15 15:30:00"))
    d <- data.frame(start = ts_s, end = ts_e)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      result <- activity_snake(d)
    })
  })

  it("respects day_format parameter", {
    ts <- as.POSIXct(c("2024-03-01 10:00:00", "2024-03-02 10:00:00",
                        "2024-03-03 10:00:00"))
    d <- data.frame(start = ts, duration = c(30, 60, 45))
    pdf(nullfile())
    on.exit(dev.off())
    result <- activity_snake(d, day_format = "%b %d")
    expect_equal(nrow(result$bands), 3)
  })

  it("accepts a bare POSIXct vector (simplest API)", {
    set.seed(10)
    base <- as.POSIXct("2024-03-04")
    ts <- base + sort(sample(0:(7 * 86400), 50))
    pdf(nullfile())
    on.exit(dev.off())
    result <- activity_snake(ts)
    expect_s3_class(result, "snake_layout")
    expect_true(nrow(result$bands) >= 1)
  })
})
