# Correlation arcs of survey_snake(arc_fill = "correlation").
#
# Regression context: up to 0.3.2 the arcs rebuilt each item from its
# counts (rep(levels, counts)), which sorts the responses and discards
# which respondent gave which answer. Correlating two sorted vectors gives
# r near +1 for any data, so a perfectly negative pair was reported as
# r = +1. These tests pin r to independently computed values.

draw_quietly <- function(...) {
  grDevices::pdf(nullfile())
  on.exit(grDevices::dev.off(), add = TRUE)
  survey_snake(...)
}

describe("survey_snake() correlation arcs", {

  it("reports r = -1 for a mirrored item and r = +1 for a copy", {
    a <- rep(1:5, each = 8)
    raw <- data.frame(A = a, B = 6L - a, C = a)
    res <- draw_quietly(raw, arc_fill = "correlation")
    expect_equal(res$correlations$from, c("A", "B"))
    expect_equal(res$correlations$to, c("B", "C"))
    expect_equal(res$correlations$r, c(-1, -1))
    a_copy <- data.frame(A = a, B = a)
    res_copy <- draw_quietly(a_copy, arc_fill = "correlation")
    expect_equal(res_copy$correlations$r, 1)
  })

  it("matches stats::cor() on the bundled data, in band order", {
    res <- draw_quietly(ema_emotions, arc_fill = "correlation",
                        sort_by = "mean")
    cor_mat <- stats::cor(ema_emotions, use = "pairwise.complete.obs")
    expected <- cor_mat[cbind(res$correlations$from, res$correlations$to)]
    expect_equal(res$correlations$r, expected,
                 tolerance = sqrt(.Machine$double.eps))
    expect_equal(res$correlations$n, rep(nrow(ema_emotions), 9L))
  })

  it("recovers the negative Exhausted-Lively association", {
    # The pre-fix code reported +0.88 for this pair; the data say -0.52
    res <- draw_quietly(ema_emotions[c("Exhausted", "Lively")],
                        arc_fill = "correlation")
    expect_lt(res$correlations$r, 0)
    expect_equal(res$correlations$r,
                 stats::cor(ema_emotions$Exhausted, ema_emotions$Lively),
                 tolerance = sqrt(.Machine$double.eps))
  })

  it("uses pairwise-complete respondents and reports their number", {
    a <- rep(1:5, each = 8)
    b <- rev(a)
    a[c(1, 2, 3)] <- NA
    b[c(3, 4)] <- NA
    raw <- data.frame(A = a, B = b)
    res <- suppressMessages(draw_quietly(raw, arc_fill = "correlation"))
    both <- !is.na(a) & !is.na(b)
    expect_equal(res$correlations$n, sum(both))
    expect_equal(res$correlations$r, stats::cor(a[both], b[both]),
                 tolerance = sqrt(.Machine$double.eps))
  })

  it("is NA when fewer than three respondents answered both items", {
    raw <- data.frame(A = c(1, 2, NA, NA, NA, 3, 4, 5, 1, 2, 3, 4),
                      B = c(2, 1, 3, 4, 5, NA, NA, NA, NA, NA, NA, NA))
    res <- suppressMessages(draw_quietly(raw, arc_fill = "correlation"))
    expect_equal(res$correlations$n, 2L)
    expect_true(is.na(res$correlations$r))
  })

  it("returns a zero-row table for a single item", {
    res <- draw_quietly(data.frame(A = rep(1:5, 8)),
                        arc_fill = "correlation")
    expect_s3_class(res$correlations, "data.frame")
    expect_equal(nrow(res$correlations), 0L)
    expect_named(res$correlations, c("from", "to", "r", "n"))
  })

  it("does not depend on the order of respondents", {
    set.seed(7)
    shuffled <- ema_emotions[sample(nrow(ema_emotions)), ]
    res_a <- draw_quietly(ema_emotions, arc_fill = "correlation")
    res_b <- draw_quietly(shuffled, arc_fill = "correlation")
    expect_equal(res_a$correlations, res_b$correlations,
                 tolerance = sqrt(.Machine$double.eps))
  })

  it("gives the same r for character responses with ordered levels", {
    a <- rep(1:5, each = 8)
    b <- rep(c(2, 1, 4, 3, 5), times = 8)
    labs <- c("SD", "D", "N", "A", "SA")
    numeric_res <- draw_quietly(data.frame(A = a, B = b),
                                arc_fill = "correlation")
    char_res <- draw_quietly(
      data.frame(A = factor(labs[a], levels = labs),
                 B = factor(labs[b], levels = labs)),
      arc_fill = "correlation"
    )
    expect_equal(char_res$correlations$r, numeric_res$correlations$r,
                 tolerance = sqrt(.Machine$double.eps))
  })

  it("computes correlations within each facet", {
    set.seed(3)
    a <- sample(1:5, 60, replace = TRUE)
    raw <- data.frame(X1 = a, X2 = 6L - a,
                      Y1 = a, Y2 = a)
    # Called directly: facet dispatch re-evaluates the call two frames up
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    res <- survey_snake(raw, facet = TRUE, arc_fill = "correlation")
    expect_equal(res$X$correlations$r, -1)
    expect_equal(res$Y$correlations$r, 1)
  })

  it("omits the table when arcs are not correlation-filled", {
    res <- draw_quietly(ema_emotions, arc_fill = "none")
    expect_null(res$correlations)
  })

  it("refuses counts input, which has no respondent pairing", {
    counts <- matrix(c(80, 60, 30, 10, 5,
                       5, 10, 30, 60, 80), nrow = 2, byrow = TRUE)
    expect_error(
      draw_quietly(counts, paste0("Q", 1:2), as.character(1:5),
                   arc_fill = "correlation"),
      class = "snakeplot_no_respondent_data"
    )
  })

  it("refuses the ESM (var/day) mode, whose bands are days", {
    esm <- data.frame(day = rep(1:4, each = 10),
                      mood = rep(1:5, times = 8))
    expect_error(
      draw_quietly(esm, var = "mood", day = "day",
                   arc_fill = "correlation"),
      class = "snakeplot_no_respondent_data"
    )
  })
})
