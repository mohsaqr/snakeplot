describe("start_from parameter", {
  it("works with activity_snake start_from='right'", {
    d <- data.frame(day = rep(c("Mon", "Tue", "Wed"), each = 5),
                    start = round(runif(15, 360, 1400)), duration = 0)
    pdf(nullfile())
    on.exit(dev.off())
    result <- activity_snake(d, start_from = "right")
    expect_s3_class(result, "snake_layout")
    # First band should be RTL when starting from right
    expect_equal(result$bands$direction[1], "rtl")
  })

  it("works with survey_snake start_from='right'", {
    set.seed(42)
    counts <- matrix(sample(10:50, 15, replace = TRUE), nrow = 3)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                           start_from = "right")
    expect_s3_class(result, "snake_layout")
    expect_equal(result$bands$direction[1], "rtl")
  })

  it("works with survey_sequence start_from='right'", {
    set.seed(42)
    counts <- matrix(sample(10:50, 20, replace = TRUE), nrow = 4)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_sequence(counts, paste0("Q", 1:4), as.character(1:5),
                              start_from = "right")
    expect_s3_class(result, "snake_layout")
  })
})

describe("vertical orientation", {
  it("produces vertical activity_snake", {
    set.seed(1)
    d <- data.frame(
      day = rep(c("Mon", "Tue", "Wed"), each = 10),
      start = round(runif(30, 360, 1400)),
      duration = round(runif(30, 0, 60))
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- activity_snake(d, orientation = "vertical")
    expect_s3_class(result, "snake_layout")
    expect_equal(result$orientation, "vertical")
    expect_true(result$bands$direction[1] %in% c("ttb", "btt"))
  })

  it("vertical with start_from='right'", {
    d <- data.frame(day = rep(c("A", "B"), each = 5),
                    start = round(runif(10, 0, 1440)), duration = 0)
    pdf(nullfile())
    on.exit(dev.off())
    result <- activity_snake(d, orientation = "vertical", start_from = "right")
    expect_equal(result$bands$direction[1], "btt")
  })

  it("vertical single band works", {
    d <- data.frame(day = "Mon", start = c(420, 720), duration = c(30, 60))
    pdf(nullfile())
    on.exit(dev.off())
    result <- activity_snake(d, orientation = "vertical")
    expect_equal(nrow(result$bands), 1)
  })
})

describe("line_snake()", {
  it("produces a plot from data.frame", {
    set.seed(42)
    d <- data.frame(
      day = rep(c("Mon", "Tue", "Wed"), each = 50),
      time = rep(seq(0, 1440, length.out = 50), 3),
      value = sin(seq(0, 6 * pi, length.out = 150)) * 30 + 50
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- line_snake(d)
    expect_s3_class(result, "snake_layout")
    expect_equal(nrow(result$bands), 3)
  })

  it("accepts a numeric vector", {
    pdf(nullfile())
    on.exit(dev.off())
    result <- line_snake(sin(seq(0, 4 * pi, length.out = 100)) * 50 + 50)
    expect_s3_class(result, "snake_layout")
    expect_equal(nrow(result$bands), 1)
  })

  it("works with fill", {
    d <- data.frame(
      day = rep(c("A", "B"), each = 30),
      time = rep(seq(0, 1440, length.out = 30), 2),
      value = runif(60, 0, 100)
    )
    pdf(nullfile())
    on.exit(dev.off())
    expect_no_error(line_snake(d, fill_color = "#3498db"))
  })

  it("works with title", {
    d <- data.frame(day = "Day1", time = seq(0, 1440, by = 30),
                    value = runif(49, 0, 100))
    pdf(nullfile())
    on.exit(dev.off())
    expect_no_error(line_snake(d, title = "Traffic Flow"))
  })
})

describe("facet_snake()", {
  it("creates faceted activity_snake", {
    set.seed(42)
    d <- data.frame(
      group = rep(c("A", "B"), each = 21),
      day = rep(rep(c("Mon", "Tue", "Wed"), each = 7), 2),
      start = round(runif(42, 360, 1400)),
      duration = 0
    )
    pdf(nullfile())
    on.exit(dev.off())
    results <- facet_snake(d, "group")
    expect_type(results, "list")
    expect_length(results, 2)
  })

  it("works with ncol parameter", {
    set.seed(42)
    d <- data.frame(
      grp = rep(c("X", "Y", "Z"), each = 14),
      day = rep(rep(c("Mon", "Tue"), each = 7), 3),
      start = round(runif(42, 360, 1400)),
      duration = 0
    )
    pdf(nullfile())
    on.exit(dev.off())
    results <- facet_snake(d, "grp", ncol = 2)
    expect_length(results, 3)
  })

  it("rejects invalid facet_var", {
    d <- data.frame(day = "Mon", start = 420, duration = 0)
    expect_error(facet_snake(d, "nonexistent"))
  })
})

describe("time_to_y()", {
  it("maps time to y linearly (ttb)", {
    y <- time_to_y(720, 360, 1440, 100, 600, "ttb")
    expected <- 100 + ((720 - 360) / (1440 - 360)) * 500
    expect_equal(y, expected)
  })

  it("maps time to y reversed (btt)", {
    y <- time_to_y(720, 360, 1440, 100, 600, "btt")
    expected <- 600 - ((720 - 360) / (1440 - 360)) * 500
    expect_equal(y, expected)
  })
})

describe("arc_polygon() sides", {
  it("produces valid bottom arc", {
    pts <- arc_polygon(250, 400, 30, 10, "bottom")
    expect_true(all(c("x", "y") %in% names(pts)))
    expect_true(max(pts$y) > 400)  # extends below center
  })

  it("produces valid top arc", {
    pts <- arc_polygon(250, 100, 30, 10, "top")
    expect_true(min(pts$y) < 100)  # extends above center
  })
})

describe("end_cap_polygon() sides", {
  it("produces valid top cap", {
    cap <- end_cap_polygon(100, 50, 15, "top")
    expect_true(min(cap$y) < 50)
  })

  it("produces valid bottom cap", {
    cap <- end_cap_polygon(100, 400, 15, "bottom")
    expect_true(max(cap$y) > 400)
  })
})
