describe("survey_snake()", {
  make_counts <- function(n_items = 5, n_levels = 5) {
    set.seed(99)
    m <- matrix(sample(5:50, n_items * n_levels, replace = TRUE),
                nrow = n_items)
    m
  }

  it("produces a plot without error", {
    counts <- make_counts()
    labels <- paste0("Q", seq_len(5))
    levs <- as.character(seq_len(5))
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, labels, levs)
    })
  })

  it("returns a snake_layout", {
    counts <- make_counts(3, 5)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(counts, paste0("Q", 1:3), as.character(1:5))
    expect_s3_class(result, "snake_layout")
    expect_equal(nrow(result$bands), 3)
  })

  it("works with dot tick shape", {
    counts <- make_counts(3, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                   tick_shape = "dot")
    })
  })

  it("works with sorting", {
    counts <- make_counts(5, 5)
    labels <- paste0("Q", 1:5)
    levs <- as.character(1:5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, labels, levs, sort_by = "mean")
    })
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, labels, levs, sort_by = "net")
    })
  })

  it("toggles mean and median markers", {
    counts <- make_counts(3, 5)
    labels <- paste0("Q", 1:3)
    levs <- as.character(1:5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, labels, levs,
                   show_mean = FALSE, show_median = TRUE)
    })
  })

  it("works without correlation display", {
    counts <- make_counts(4, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:4), as.character(1:5),
                   show_correlation = FALSE)
    })
  })

  it("accepts data.frame counts", {
    df <- data.frame(a = c(10, 20), b = c(30, 25), c = c(40, 35))
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(df, c("X", "Y"), c("lo", "mid", "hi"))
    })
  })

  it("rejects mismatched dimensions", {
    m <- matrix(1:15, nrow = 3)
    expect_error(
      survey_snake(m, c("A"), as.character(1:5)),
      "must match"
    )
  })

  it("accepts raw response data.frame (simplest API)", {
    set.seed(88)
    survey_df <- data.frame(
      Item1 = sample(1:5, 200, replace = TRUE),
      Item2 = sample(1:5, 200, replace = TRUE),
      Item3 = sample(1:5, 200, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df)
    expect_s3_class(result, "snake_layout")
    expect_equal(nrow(result$bands), 3)
  })

  it("accepts raw responses with factor levels", {
    set.seed(89)
    lvs <- c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")
    survey_df <- data.frame(
      Q1 = factor(sample(lvs, 100, replace = TRUE), levels = lvs),
      Q2 = factor(sample(lvs, 100, replace = TRUE), levels = lvs)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df)
    expect_s3_class(result, "snake_layout")
    expect_equal(nrow(result$bands), 2)
  })

  it("accepts raw responses with explicit levels override", {
    set.seed(90)
    survey_df <- data.frame(
      A = sample(1:5, 80, replace = TRUE),
      B = sample(1:5, 80, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, levels = c("1", "2", "3", "4", "5"))
    expect_s3_class(result, "snake_layout")
  })

  it("arc_fill='none' draws two-tone arcs without error", {
    counts <- make_counts(4, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:4), as.character(1:5),
                   arc_fill = "none")
    })
  })

  it("arc_fill='correlation' preserves r labels", {
    counts <- make_counts(4, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:4), as.character(1:5),
                   arc_fill = "correlation", show_correlation = TRUE)
    })
  })

  it("arc_fill='mean_prev' runs without error", {
    counts <- make_counts(4, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:4), as.character(1:5),
                   arc_fill = "mean_prev")
    })
  })

  it("arc_fill='blend' runs without error", {
    counts <- make_counts(4, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:4), as.character(1:5),
                   arc_fill = "blend")
    })
  })

  it("respects level_gap parameter", {
    counts <- make_counts(3, 5)
    labels <- paste0("Q", 1:3)
    levs <- as.character(1:5)
    # No gap
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, labels, levs, level_gap = 0)
    })
    # Large gap between levels
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, labels, levs, level_gap = 15)
    })
  })

  it("tick_shape='bar' draws stacked bars without error", {
    counts <- make_counts(4, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:4), as.character(1:5),
                   tick_shape = "bar")
    })
  })

  it("tick_shape='bar' works with raw response data.frame", {
    set.seed(91)
    survey_df <- data.frame(
      A = sample(1:5, 100, replace = TRUE),
      B = sample(1:5, 100, replace = TRUE),
      C = sample(1:5, 100, replace = TRUE)
    )
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(survey_df, tick_shape = "bar")
    })
  })

  it("level_labels maps values to display labels", {
    counts <- make_counts(3, 5)
    labels_map <- c("1" = "Str. Disagree", "2" = "Disagree",
                    "3" = "Neutral", "4" = "Agree", "5" = "Str. Agree")
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                   level_labels = labels_map)
    })
  })

  it("level_labels works positionally (unnamed)", {
    counts <- make_counts(3, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                   level_labels = c("SD", "D", "N", "A", "SA"))
    })
  })

  it("legend_cex scales legend text", {
    counts <- make_counts(3, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                   legend_cex = 1.2)
    })
  })

  it("label_cex scales label text", {
    counts <- make_counts(3, 5)
    expect_no_error({
      pdf(nullfile())
      on.exit(dev.off())
      survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                   label_cex = 1.5)
    })
  })

  it("sort_by='mean' reorders items", {
    set.seed(92)
    survey_df <- data.frame(
      Low = sample(1:2, 100, replace = TRUE),
      High = sample(4:5, 100, replace = TRUE),
      Mid = sample(2:4, 100, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, sort_by = "mean")
    expect_s3_class(result, "snake_layout")
  })

  it("ESM auto-pivot with var and day", {
    set.seed(93)
    esm_df <- data.frame(
      angry = sample(1:7, 100, replace = TRUE),
      day   = rep(1:10, each = 10)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(esm_df, var = "angry", day = "day")
    expect_s3_class(result, "snake_layout")
    expect_equal(nrow(result$bands), 10)
  })

  it("ESM auto-pivot with var, day, and timestamp", {
    set.seed(94)
    n <- 100
    esm_df <- data.frame(
      happy = sample(1:7, n, replace = TRUE),
      day   = rep(1:10, each = 10),
      start_time = as.POSIXct("2024-01-01 08:00:00") +
                   rep(0:9, each = 10) * 86400 +
                   sample(0:(3600 * 14), n, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(esm_df, var = "happy", day = "day",
                           timestamp = "start_time")
    expect_s3_class(result, "snake_layout")
    expect_equal(nrow(result$bands), 10)
  })

  it("ESM rejects missing var column", {
    esm_df <- data.frame(x = 1:10, day = rep(1:2, each = 5))
    expect_error(
      survey_snake(esm_df, var = "missing_col", day = "day")
    )
  })

  it("facet=TRUE auto-groups by prefix", {
    set.seed(95)
    survey_df <- data.frame(
      LOC1 = sample(1:5, 80, replace = TRUE),
      LOC2 = sample(1:5, 80, replace = TRUE),
      LOC3 = sample(1:5, 80, replace = TRUE),
      SAT1 = sample(1:5, 80, replace = TRUE),
      SAT2 = sample(1:5, 80, replace = TRUE),
      SAT3 = sample(1:5, 80, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, facet = TRUE)
    expect_type(result, "list")
    expect_equal(length(result), 2)
    expect_true(all(c("LOC", "SAT") %in% names(result)))
  })

  it("facet with explicit groups", {
    set.seed(96)
    survey_df <- data.frame(
      A1 = sample(1:5, 60, replace = TRUE),
      A2 = sample(1:5, 60, replace = TRUE),
      B1 = sample(1:5, 60, replace = TRUE),
      B2 = sample(1:5, 60, replace = TRUE)
    )
    grps <- list(GroupA = c("A1", "A2"), GroupB = c("B1", "B2"))
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, facet = grps)
    expect_type(result, "list")
    expect_equal(length(result), 2)
  })

  it("facet with facet_ncol argument", {
    set.seed(97)
    survey_df <- data.frame(
      X1 = sample(1:5, 50, replace = TRUE),
      X2 = sample(1:5, 50, replace = TRUE),
      Y1 = sample(1:5, 50, replace = TRUE),
      Y2 = sample(1:5, 50, replace = TRUE),
      Z1 = sample(1:5, 50, replace = TRUE),
      Z2 = sample(1:5, 50, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, facet = TRUE, facet_ncol = 3L)
    expect_type(result, "list")
    expect_equal(length(result), 3)
  })

  it("facet with level_labels and legend_cex", {
    set.seed(98)
    survey_df <- data.frame(
      P1 = sample(1:5, 60, replace = TRUE),
      P2 = sample(1:5, 60, replace = TRUE),
      Q1 = sample(1:5, 60, replace = TRUE),
      Q2 = sample(1:5, 60, replace = TRUE),
      R1 = sample(1:5, 60, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, facet = TRUE, facet_ncol = 2L,
                           level_labels = c("1" = "SD", "2" = "D",
                                            "3" = "N", "4" = "A",
                                            "5" = "SA"),
                           legend_cex = 0.9)
    expect_type(result, "list")
  })

  it("band_palette darkens band shading", {
    counts <- make_counts(4, 5)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(counts, paste0("Q", 1:4), as.character(1:5),
                           band_palette = c("#1a1228", "#1a2a42"))
    expect_s3_class(result, "snake_layout")
  })

  it("band_palette works with arc_fill modes", {
    counts <- make_counts(4, 5)
    pdf(nullfile())
    on.exit(dev.off())
    expect_no_error(
      survey_snake(counts, paste0("Q", 1:4), as.character(1:5),
                   arc_fill = "correlation",
                   band_palette = c("#0a0a1a", "#1a1a3a"))
    )
    expect_no_error(
      survey_snake(counts, paste0("Q", 1:4), as.character(1:5),
                   arc_fill = "blend",
                   band_palette = c("#0a0a1a", "#1a1a3a"))
    )
  })

  it("band_palette works with dot tick_shape", {
    survey_df <- data.frame(
      A = sample(1:5, 50, replace = TRUE),
      B = sample(1:5, 50, replace = TRUE),
      C = sample(1:5, 50, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, tick_shape = "dot",
                           band_palette = c("#1a1228", "#1a2a42"))
    expect_s3_class(result, "snake_layout")
  })

  it("band_palette passes through facet dispatch", {
    set.seed(90)
    survey_df <- data.frame(
      A1 = sample(1:5, 30, replace = TRUE),
      A2 = sample(1:5, 30, replace = TRUE),
      B1 = sample(1:5, 30, replace = TRUE),
      B2 = sample(1:5, 30, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, facet = TRUE,
                           band_palette = c("#1a1228", "#1a2a42"))
    expect_type(result, "list")
  })
})
