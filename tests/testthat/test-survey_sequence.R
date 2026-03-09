describe("survey_sequence()", {
  make_counts <- function(n_items = 5, n_levels = 5) {
    set.seed(88)
    matrix(sample(10:80, n_items * n_levels, replace = TRUE),
           nrow = n_items)
  }

  it("produces a plot without error", {
    counts <- make_counts()
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_sequence(counts, paste0("Q", 1:5), as.character(1:5))
    })
  })

  it("returns a snake_layout", {
    counts <- make_counts(3, 5)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_sequence(counts, paste0("Q", 1:3), as.character(1:5))
    expect_s3_class(result, "snake_layout")
  })

  it("works with neutral arc mode", {
    counts <- make_counts(4, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_sequence(counts, paste0("Q", 1:4), as.character(1:5),
                      arc_style = "neutral")
    })
  })

  it("works with custom colors", {
    counts <- make_counts(3, 3)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_sequence(counts, paste0("Q", 1:3), c("A", "B", "C"),
                      colors = c("red", "gray", "blue"))
    })
  })

  it("handles sorting options", {
    counts <- make_counts(5, 5)
    labels <- paste0("Q", 1:5)
    levs <- as.character(1:5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_sequence(counts, labels, levs, sort_by = "mean")
    })
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_sequence(counts, labels, levs, sort_by = "net")
    })
  })

  it("renders with title and no legend", {
    counts <- make_counts(3, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_sequence(counts, paste0("Q", 1:3), as.character(1:5),
                      title = "Survey", show_legend = FALSE)
    })
  })

  it("hides percentage labels on narrow segments", {
    # Create heavily skewed data (one large, rest tiny)
    counts <- matrix(c(200, 1, 1, 1, 1,
                        1, 1, 1, 1, 200), nrow = 2, byrow = TRUE)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_sequence(counts, c("A", "B"), as.character(1:5))
    })
  })
})

describe("sequential_dist()", {
  it("produces a plot with sequential palette", {
    counts <- matrix(c(15, 25, 60, 80, 45,
                        10, 20, 50, 90, 55), nrow = 2, byrow = TRUE)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      sequential_dist(counts, c("A", "B"),
                      c("Never", "Rarely", "Sometimes", "Often", "Always"))
    })
  })

  it("accepts custom hue", {
    counts <- matrix(c(10, 30, 60, 20, 40, 40), nrow = 2, byrow = TRUE)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      sequential_dist(counts, c("X", "Y"), c("Lo", "Mid", "Hi"), hue = 120)
    })
  })

  it("returns a snake_layout", {
    counts <- matrix(c(10, 30, 60, 20, 40, 40), nrow = 2, byrow = TRUE)
    pdf(nullfile())
    on.exit(dev.off())
    result <- sequential_dist(counts, c("X", "Y"), c("Lo", "Mid", "Hi"))
    expect_s3_class(result, "snake_layout")
  })
})
