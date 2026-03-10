describe("flow parameter — layout engine", {
  it("snake flow produces alternating read_direction", {
    layout <- compute_snake_layout(5, flow = "snake")
    expect_equal(layout$bands$read_direction,
                 c("ltr", "rtl", "ltr", "rtl", "ltr"))
  })

  it("natural flow produces uniform ltr read_direction", {
    layout <- compute_snake_layout(5, flow = "natural")
    expect_true(all(layout$bands$read_direction == "ltr"))
  })

  it("natural flow with start_from='right' produces uniform rtl", {
    layout <- compute_snake_layout(4, flow = "natural",
                                   start_from = "right")
    expect_true(all(layout$bands$read_direction == "rtl"))
  })

  it("snake flow preserves direction == read_direction", {
    layout <- compute_snake_layout(4, flow = "snake")
    expect_equal(layout$bands$direction, layout$bands$read_direction)
  })

  it("natural flow keeps direction alternating (for arcs)", {
    layout <- compute_snake_layout(4, flow = "natural")
    expect_equal(layout$bands$direction,
                 c("ltr", "rtl", "ltr", "rtl"))
    # But read_direction is uniform
    expect_true(all(layout$bands$read_direction == "ltr"))
  })

  it("flow is stored in the layout object", {
    layout_s <- compute_snake_layout(3, flow = "snake")
    layout_n <- compute_snake_layout(3, flow = "natural")
    expect_equal(layout_s$flow, "snake")
    expect_equal(layout_n$flow, "natural")
  })

  it("vertical natural flow produces uniform ttb", {
    layout <- compute_snake_layout(4, flow = "natural",
                                   orientation = "vertical")
    expect_true(all(layout$bands$read_direction == "ttb"))
  })

  it("vertical snake flow alternates ttb/btt", {
    layout <- compute_snake_layout(4, flow = "snake",
                                   orientation = "vertical")
    expect_equal(layout$bands$read_direction,
                 c("ttb", "btt", "ttb", "btt"))
  })
})

describe("flow parameter — sequence_snake()", {
  set.seed(42)
  seq20 <- sample(c("A", "B", "C"), 20, replace = TRUE)

  it("defaults to natural flow", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, rows = 3))
  })

  it("accepts flow='snake'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, rows = 3, flow = "snake"))
  })

  it("accepts flow='natural' explicitly", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, rows = 3, flow = "natural"))
  })

  it("snake flow with start_from='right' and tick_labels (RTL ruler)", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, rows = 3, flow = "snake",
                                 start_from = "right",
                                 tick_labels = c("Q1", "Q2", "Q3")))
  })

  it("snake flow with start_from='right' transition on RTL band", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    # Band 1 is RTL with start_from=right; put transition in band 1
    s <- c(rep("A", 3), rep("B", 17))
    expect_silent(sequence_snake(s, rows = 2, flow = "snake",
                                 start_from = "right",
                                 transition_labels = "T1"))
  })

  it("snake flow with start_from='right' and transition_pos", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    s <- c(rep("A", 15), rep("B", 15))
    expect_silent(sequence_snake(s, rows = 3, flow = "snake",
                                 start_from = "right",
                                 transition_labels = "T1",
                                 transition_pos = 3.5))
  })

  it("rejects invalid flow value", {
    expect_error(sequence_snake(seq20, flow = "invalid"))
  })
})

describe("flow parameter — timeline_snake()", {
  career <- data.frame(
    role  = c("Junior", "Senior"),
    start = c("2020-01", "2022-01"),
    end   = c("2021-12", "2023-12")
  )

  it("defaults to natural flow", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(timeline_snake(career))
  })

  it("accepts flow='snake'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(timeline_snake(career, flow = "snake"))
  })

  it("rejects invalid flow value", {
    expect_error(timeline_snake(career, flow = "invalid"))
  })
})

describe("flow parameter — activity_snake()", {
  days <- c("Mon", "Tue", "Wed")
  d <- data.frame(
    day      = rep(days, each = 10),
    start    = round(runif(30, 360, 1400)),
    duration = 0
  )

  it("defaults to snake flow", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(activity_snake(d))
  })

  it("accepts flow='natural'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(activity_snake(d, flow = "natural"))
  })

  it("natural flow with start_from='right'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(activity_snake(d, flow = "natural", start_from = "right"))
  })

  it("natural flow with vertical orientation", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(activity_snake(d, flow = "natural",
                                 orientation = "vertical"))
  })

  it("natural flow vertical with start_from='right'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(activity_snake(d, flow = "natural",
                                 orientation = "vertical",
                                 start_from = "right"))
  })

  it("rejects invalid flow value", {
    expect_error(activity_snake(d, flow = "invalid"))
  })
})

describe("flow parameter — survey_snake()", {
  it("defaults to snake flow", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    counts <- matrix(sample(1:50, 15), nrow = 3)
    expect_silent(survey_snake(counts,
                               labels = c("Q1", "Q2", "Q3"),
                               levels = as.character(1:5)))
  })

  it("accepts flow='natural'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    counts <- matrix(sample(1:50, 15), nrow = 3)
    expect_silent(survey_snake(counts,
                               labels = c("Q1", "Q2", "Q3"),
                               levels = as.character(1:5),
                               flow = "natural"))
  })
})

describe("flow parameter — survey_sequence()", {
  counts <- matrix(c(10, 20, 30, 40, 50,
                     15, 25, 35, 45, 55,
                     20, 30, 40, 50, 60), nrow = 3, byrow = TRUE)

  it("defaults to snake flow", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(survey_sequence(counts,
                                  labels = c("Q1", "Q2", "Q3"),
                                  levels = as.character(1:5)))
  })

  it("accepts flow='natural'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(survey_sequence(counts,
                                  labels = c("Q1", "Q2", "Q3"),
                                  levels = as.character(1:5),
                                  flow = "natural"))
  })
})

describe("flow parameter — multi_snake()", {
  set.seed(42)
  seqs <- matrix(sample(c("A", "B", "C"), 100, replace = TRUE),
                 nrow = 10, ncol = 10)

  it("defaults to snake flow", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs))
  })

  it("accepts flow='natural'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs, flow = "natural"))
  })
})

describe("flow parameter — line_snake()", {
  set.seed(42)
  hours <- seq(0, 1440, by = 60)
  d <- data.frame(
    day   = rep(c("Mon", "Tue", "Wed"), each = length(hours)),
    time  = rep(hours, 3),
    value = runif(3 * length(hours), 0, 100)
  )

  it("defaults to snake flow", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(line_snake(d))
  })

  it("accepts flow='natural'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(line_snake(d, flow = "natural"))
  })
})
