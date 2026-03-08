# Tests targeting zero-coverage lines for 100% coverage

# ── snake_palette() (colors.R:147-153) ──────────────────────────────────────

describe("snake_palette()", {
  it("returns 7 colors for a valid palette name", {
    pal <- snake_palette("ocean", 7L)
    expect_length(pal, 7)
    expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", pal)))
  })

  it("interpolates to arbitrary length", {
    pal3 <- snake_palette("earth", 3L)
    expect_length(pal3, 3)
    pal10 <- snake_palette("blues", 10L)
    expect_length(pal10, 10)
  })

  it("errors on unknown palette name", {
    expect_error(snake_palette("nonexistent"), "Unknown palette")
  })

  it("returns original palette when n matches length", {
    pal <- snake_palette("classic", 7L)
    expect_identical(pal, snake_palettes$classic)
  })
})

# ── half_arc_polygon() with bottom/top sides (layout.R:209-213) ─────────────

describe("half_arc_polygon() bottom/top sides", {
  it("works for bottom side upper half", {
    pts <- half_arc_polygon(200, 300, 30, 10, "bottom", "upper")
    expect_type(pts, "list")
    expect_true(all(c("x", "y") %in% names(pts)))
  })

  it("works for bottom side lower half", {
    pts <- half_arc_polygon(200, 300, 30, 10, "bottom", "lower")
    expect_type(pts, "list")
    expect_true(length(pts$x) > 0)
  })

  it("works for top side upper half", {
    pts <- half_arc_polygon(200, 100, 30, 10, "top", "upper")
    expect_type(pts, "list")
  })

  it("works for top side lower half", {
    pts <- half_arc_polygon(200, 100, 30, 10, "top", "lower")
    expect_type(pts, "list")
  })
})

# ── line_snake() edge cases ─────────────────────────────────────────────────

describe("line_snake() edge cases", {
  it("auto-converts POSIXct time column", {
    ts <- as.POSIXct("2024-01-01 08:00:00") + seq(0, 3600 * 12, by = 600)
    d <- data.frame(
      time = ts,
      value = sin(seq_along(ts) / 10) * 50 + 50
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- line_snake(d)
    expect_s3_class(result, "snake_layout")
  })

  it("draws grid lines", {
    d <- data.frame(
      day = rep(c("Mon", "Tue"), each = 50),
      time = rep(seq(0, 1440, length.out = 50), 2),
      value = runif(100, 0, 100)
    )
    pdf(nullfile())
    on.exit(dev.off())
    expect_no_error(line_snake(d, show_grid = TRUE))
  })

  it("handles single-day data without day column", {
    d <- data.frame(
      time = seq(0, 1440, by = 30),
      value = runif(49, 0, 100)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- line_snake(d)
    expect_equal(nrow(result$bands), 1)
  })

  it("skips day with fewer than 2 points", {
    d <- data.frame(
      day = factor(c("Mon", "Tue", "Tue", "Wed", "Wed", "Wed"),
                   levels = c("Mon", "Tue", "Wed")),
      time = c(720, 360, 1200, 360, 720, 1200),
      value = c(50, 30, 70, 40, 60, 80)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- line_snake(d)
    expect_s3_class(result, "snake_layout")
  })

  it("handles empty day in arc connections", {
    # Create data with a day that has zero rows (factor level exists but no data)
    d <- data.frame(
      day = factor(c(rep("Mon", 20), rep("Wed", 20)),
                   levels = c("Mon", "Tue", "Wed")),
      time = rep(seq(0, 1440, length.out = 20), 2),
      value = runif(40, 0, 100)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- line_snake(d)
    expect_s3_class(result, "snake_layout")
  })
})

# ── draw_ribbon() end caps for vertical ─────────────────────────────────────

describe("draw_ribbon() vertical end caps", {
  it("draws end caps for ttb last band (odd bands)", {
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
    # 3 bands: ttb, btt, ttb — last is ttb
    expect_equal(result$bands$direction[3], "ttb")
  })

  it("draws end caps for btt last band (even bands)", {
    set.seed(1)
    d <- data.frame(
      day = rep(c("Mon", "Tue"), each = 15),
      start = round(runif(30, 360, 1400)),
      duration = round(runif(30, 0, 60))
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- activity_snake(d, orientation = "vertical")
    expect_s3_class(result, "snake_layout")
    # 2 bands: ttb, btt — last is btt
    expect_equal(result$bands$direction[2], "btt")
  })
})

# ── draw_gridlines() (render.R:146-157) ─────────────────────────────────────

describe("draw_gridlines()", {
  it("draws gridlines on a snake layout", {
    layout <- compute_snake_layout(3, band_height = 20, band_gap = 10,
                                   plot_width = 400)
    pdf(nullfile())
    on.exit(dev.off())
    setup_canvas(layout)
    expect_no_error(draw_gridlines(layout, c(100, 200, 300)))
  })

  it("handles rgba color string", {
    layout <- compute_snake_layout(2, band_height = 20, band_gap = 10)
    pdf(nullfile())
    on.exit(dev.off())
    setup_canvas(layout)
    expect_no_error(
      draw_gridlines(layout, c(100, 200), col = "rgba(255,255,255,0.25)")
    )
  })
})

# ── draw_band_labels() alignment modes (render.R:194-206) ───────────────────

describe("draw_band_labels() alignment", {
  it("draws labels with 'direction' alignment", {
    layout <- compute_snake_layout(3, band_height = 20, band_gap = 10)
    pdf(nullfile())
    on.exit(dev.off())
    setup_canvas(layout)
    expect_no_error(
      draw_band_labels(layout, c("A", "B", "C"), align = "direction")
    )
  })

  it("draws labels with 'right' alignment", {
    layout <- compute_snake_layout(3, band_height = 20, band_gap = 10)
    pdf(nullfile())
    on.exit(dev.off())
    setup_canvas(layout)
    expect_no_error(
      draw_band_labels(layout, c("A", "B", "C"), align = "right")
    )
  })
})

# ── draw_snake_legend() with empty items (render.R:262) ─────────────────────

describe("draw_snake_legend()", {
  it("returns invisible NULL for empty items", {
    layout <- compute_snake_layout(3, band_height = 20, band_gap = 10)
    pdf(nullfile())
    on.exit(dev.off())
    setup_canvas(layout)
    result <- draw_snake_legend(layout, list())
    expect_null(result)
  })
})

# ── survey_sequence() edge cases ────────────────────────────────────────────

describe("survey_sequence() edge cases", {
  it("gradient arc mode blends colors", {
    set.seed(42)
    counts <- matrix(sample(10:50, 20, replace = TRUE), nrow = 4)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_sequence(counts, paste0("Q", 1:4), as.character(1:5),
                              arc_mode = "gradient")
    expect_s3_class(result, "snake_layout")
  })

  it("reverse_rtl reverses RTL band segments", {
    set.seed(42)
    counts <- matrix(sample(10:50, 15, replace = TRUE), nrow = 3)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_sequence(counts, paste0("Q", 1:3), as.character(1:5),
                              reverse_rtl = TRUE)
    expect_s3_class(result, "snake_layout")
  })
})

# ── survey_snake() uncovered branches ────────────────────────────────────────

describe("survey_snake() uncovered branches", {
  it("ESM with timestamp that is not POSIXct (character)", {
    set.seed(42)
    n <- 50
    esm_df <- data.frame(
      val = sample(1:7, n, replace = TRUE),
      day = rep(1:5, each = 10),
      ts  = as.character(as.POSIXct("2024-01-01 08:00:00") +
                          rep(0:4, each = 10) * 86400 +
                          sample(0:36000, n, replace = TRUE))
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(esm_df, var = "val", day = "day", timestamp = "ts")
    expect_s3_class(result, "snake_layout")
  })

  it("facet with underscore-prefixed columns", {
    set.seed(42)
    survey_df <- data.frame(
      Emo_Happy = sample(1:5, 40, replace = TRUE),
      Emo_Sad   = sample(1:5, 40, replace = TRUE),
      Mot_Int   = sample(1:5, 40, replace = TRUE),
      Mot_Enj   = sample(1:5, 40, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, facet = TRUE)
    expect_type(result, "list")
    expect_equal(length(result), 2)
  })

  it("facet with show_legend=FALSE suppresses legend", {
    set.seed(42)
    survey_df <- data.frame(
      A1 = sample(1:5, 30, replace = TRUE),
      A2 = sample(1:5, 30, replace = TRUE),
      B1 = sample(1:5, 30, replace = TRUE),
      B2 = sample(1:5, 30, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, facet = TRUE, show_legend = FALSE)
    expect_type(result, "list")
  })

  # 3 groups in ncol=2 grid → 2x2=4 panels, 3 used, 1 empty for legend
  it("facet with unnamed level_labels and empty legend panel", {
    set.seed(42)
    survey_df <- data.frame(
      X1 = sample(1:5, 30, replace = TRUE),
      X2 = sample(1:5, 30, replace = TRUE),
      Y1 = sample(1:5, 30, replace = TRUE),
      Y2 = sample(1:5, 30, replace = TRUE),
      Z1 = sample(1:5, 30, replace = TRUE),
      Z2 = sample(1:5, 30, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, facet = TRUE, facet_ncol = 2L,
                           level_labels = c("SD", "D", "N", "A", "SA"))
    expect_type(result, "list")
  })

  it("facet with partial named level_labels triggers else branch", {
    set.seed(42)
    survey_df <- data.frame(
      X1 = sample(1:5, 30, replace = TRUE),
      X2 = sample(1:5, 30, replace = TRUE),
      Y1 = sample(1:5, 30, replace = TRUE),
      Y2 = sample(1:5, 30, replace = TRUE),
      Z1 = sample(1:5, 30, replace = TRUE),
      Z2 = sample(1:5, 30, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    # Only map levels 1 and 5 — levels 2, 3, 4 fall to "else lv"
    result <- survey_snake(survey_df, facet = TRUE, facet_ncol = 2L,
                           level_labels = c("1" = "Lowest", "5" = "Highest"))
    expect_type(result, "list")
  })

  it("facet with correlation arc_fill and legend panel", {
    set.seed(42)
    survey_df <- data.frame(
      A1 = sample(1:5, 40, replace = TRUE),
      A2 = sample(1:5, 40, replace = TRUE),
      A3 = sample(1:5, 40, replace = TRUE),
      B1 = sample(1:5, 40, replace = TRUE),
      B2 = sample(1:5, 40, replace = TRUE),
      B3 = sample(1:5, 40, replace = TRUE),
      C1 = sample(1:5, 40, replace = TRUE),
      C2 = sample(1:5, 40, replace = TRUE),
      C3 = sample(1:5, 40, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(survey_df, facet = TRUE, facet_ncol = 2L,
                           arc_fill = "correlation",
                           show_correlation = TRUE)
    expect_type(result, "list")
  })

  it("partial named level_labels in non-facet mode (else branch)", {
    set.seed(42)
    counts <- matrix(sample(5:50, 15, replace = TRUE), nrow = 3)
    pdf(nullfile())
    on.exit(dev.off())
    # Only map levels 1 and 5 — levels 2, 3, 4 fall to "else lv"
    result <- survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                           level_labels = c("1" = "Low", "5" = "High"))
    expect_s3_class(result, "snake_layout")
  })

  it("color_mode='individual' uses hue-based coloring", {
    set.seed(42)
    counts <- matrix(sample(5:50, 15, replace = TRUE), nrow = 3)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                           color_mode = "individual")
    expect_s3_class(result, "snake_layout")
  })

  it("correlation arc_fill with negative correlations", {
    # Create count vectors that are negatively correlated across levels
    # Item 1: high counts at level 1, low at level 5
    # Item 2: low counts at level 1, high at level 5
    counts <- matrix(c(
      80, 60, 30, 10, 5,   # item 1: skewed low
      5, 10, 30, 60, 80,   # item 2: skewed high (negative r with item 1)
      40, 40, 40, 40, 40,  # item 3: uniform
      80, 60, 30, 10, 5    # item 4: same as item 1
    ), nrow = 4, byrow = TRUE)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(counts, paste0("Q", 1:4), as.character(1:5),
                           arc_fill = "correlation",
                           show_correlation = TRUE)
    expect_s3_class(result, "snake_layout")
  })

  it("correlation arc_fill with equal correlations (rel_frac = 0.5)", {
    # All items identical → all r = 1.0 → r_range has 0 spread
    counts <- matrix(rep(c(10, 20, 30, 20, 10), 3), nrow = 3, byrow = TRUE)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                           arc_fill = "correlation",
                           show_correlation = TRUE)
    expect_s3_class(result, "snake_layout")
  })

  it("correlation arc_fill with NA r_val", {
    # Item with constant values → SD=0 → cor=NA
    counts <- matrix(c(
      0, 0, 100, 0, 0,  # item 1: all at level 3
      0, 0, 100, 0, 0,  # item 2: all at level 3 (cor = NA: 0 variance)
      10, 20, 40, 20, 10 # item 3: has variance
    ), nrow = 3, byrow = TRUE)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                           arc_fill = "correlation",
                           show_correlation = TRUE)
    expect_s3_class(result, "snake_layout")
  })

  it("ESM dot tick_shape with timestamp", {
    set.seed(42)
    n <- 60
    esm_df <- data.frame(
      val = sample(1:7, n, replace = TRUE),
      day = rep(1:3, each = 20),
      ts  = as.POSIXct("2024-01-01 08:00:00") +
            rep(0:2, each = 20) * 86400 +
            sample(0:36000, n, replace = TRUE)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(esm_df, var = "val", day = "day",
                           timestamp = "ts", tick_shape = "dot")
    expect_s3_class(result, "snake_layout")
  })

  it("ESM line tick_shape without timestamp (proportional zones)", {
    set.seed(42)
    esm_df <- data.frame(
      val = sample(1:7, 50, replace = TRUE),
      day = rep(1:5, each = 10)
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(esm_df, var = "val", day = "day",
                           tick_shape = "line")
    expect_s3_class(result, "snake_layout")
  })

  it("zero-count row is skipped", {
    counts <- matrix(c(
      10, 20, 30, 20, 10,
      0, 0, 0, 0, 0,      # zero total
      15, 25, 35, 15, 10
    ), nrow = 3, byrow = TRUE)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(counts, paste0("Q", 1:3), as.character(1:5))
    expect_s3_class(result, "snake_layout")
  })

  it("bar with zero-count cells skips via next", {
    # Some levels have 0 counts → cnt == 0L → next
    counts <- matrix(c(
      50, 0, 30, 0, 20,  # levels 2 and 4 are zero
      0, 40, 0, 40, 0,   # levels 1, 3, 5 are zero
      10, 20, 30, 20, 10
    ), nrow = 3, byrow = TRUE)
    pdf(nullfile())
    on.exit(dev.off())
    result <- survey_snake(counts, paste0("Q", 1:3), as.character(1:5),
                           tick_shape = "bar")
    expect_s3_class(result, "snake_layout")
  })
})

# ── coerce_survey_input() edge cases ────────────────────────────────────────

describe("coerce_survey_input() edge cases", {
  it("raw data.frame with explicit labels passed", {
    survey_df <- data.frame(
      A = sample(1:5, 50, replace = TRUE),
      B = sample(1:5, 50, replace = TRUE)
    )
    result <- coerce_survey_input(survey_df, c("ItemA", "ItemB"), NULL)
    expect_equal(result$labels, c("ItemA", "ItemB"))
  })

  it("matrix counts pass through unchanged", {
    m <- matrix(1:15, nrow = 3)
    result <- coerce_survey_input(m, NULL, NULL)
    expect_identical(result$counts, m)
  })
})

# ── validate_activity_data() error paths ────────────────────────────────────

describe("validate_activity_data() error paths", {
  it("rejects non-numeric start", {
    d <- data.frame(day = "Mon", start = "abc", duration = 0)
    expect_error(validate_activity_data(d), "start.*numeric")
  })

  it("rejects non-numeric duration", {
    d <- data.frame(day = "Mon", start = 420, duration = "abc")
    expect_error(validate_activity_data(d), "duration.*numeric")
  })
})

# ── validate_survey_data() error paths ──────────────────────────────────────

describe("validate_survey_data() error paths", {
  it("rejects non-matrix/non-data.frame counts", {
    expect_error(validate_survey_data(list(1, 2), "A", "1"),
                 "must be a matrix")
  })

  it("rejects non-numeric matrix", {
    m <- matrix(c("a", "b", "c", "d"), nrow = 2)
    expect_error(validate_survey_data(m, c("A", "B"), c("1", "2")),
                 "must be numeric")
  })
})

# ── activity_snake() no count/total labels ──────────────────────────────────

describe("activity_snake() no count/total labels", {
  it("NULL totals when show_count and show_total are FALSE", {
    set.seed(42)
    d <- data.frame(
      day = rep(c("Mon", "Tue"), each = 10),
      start = round(runif(20, 360, 1400)),
      duration = round(runif(20, 0, 60))
    )
    pdf(nullfile())
    on.exit(dev.off())
    result <- activity_snake(d, show_count = FALSE, show_total = FALSE)
    expect_s3_class(result, "snake_layout")
  })
})
