draw_quietly <- function(f, ...) {
  grDevices::pdf(nullfile())
  on.exit(grDevices::dev.off(), add = TRUE)
  f(...)
}

describe("as.data.frame.snake_layout()", {

  it("returns the bands table, one row per band", {
    layout <- draw_quietly(survey_snake, ema_emotions)
    bands <- as.data.frame(layout)
    expect_s3_class(bands, "data.frame")
    expect_equal(nrow(bands), ncol(ema_emotions))
    expect_named(bands, c("i", "y_center", "y_top", "y_bottom", "x_left",
                          "x_right", "direction", "read_direction"))
    expect_identical(as.data.frame(layout, what = "bands"), bands)
  })

  it("returns the correlations of a correlation-filled plot", {
    layout <- draw_quietly(survey_snake, ema_emotions, sort_by = "mean",
                           arc_fill = "correlation")
    cors <- as.data.frame(layout, what = "correlations")
    expect_named(cors, c("from", "to", "r", "n"))
    expect_equal(nrow(cors), ncol(ema_emotions) - 1L)
    expected <- stats::cor(ema_emotions)[cbind(cors$from, cors$to)]
    expect_equal(cors$r, expected, tolerance = sqrt(.Machine$double.eps))
  })

  it("returns the canvas size as one row", {
    layout <- draw_quietly(survey_sequence, ema_emotions)
    canvas <- as.data.frame(layout, what = "canvas")
    expect_equal(dim(canvas), c(1L, 2L))
    expect_named(canvas, c("width", "height"))
    expect_true(all(canvas > 0))
  })

  it("grows the canvas with band height (invariant)", {
    small <- draw_quietly(survey_sequence, ema_emotions, band_height = 20)
    large <- draw_quietly(survey_sequence, ema_emotions, band_height = 40)
    expect_gt(as.data.frame(large, what = "canvas")$height,
              as.data.frame(small, what = "canvas")$height)
  })

  it("works on activity layouts", {
    one <- subset(ema_beeps, id == "xcVDLRQOwn", select = start_time)
    layout <- draw_quietly(activity_snake, one)
    expect_equal(nrow(as.data.frame(layout)), 14L)
  })

  it("signals a classed error when the plot has no correlations", {
    layout <- draw_quietly(survey_snake, ema_emotions, arc_fill = "none")
    expect_error(as.data.frame(layout, what = "correlations"),
                 class = "snakeplot_no_table")
  })

  it("rejects an unknown table", {
    layout <- draw_quietly(survey_snake, ema_emotions)
    expect_error(as.data.frame(layout, what = "arcs"), "should be one of")
  })
})
