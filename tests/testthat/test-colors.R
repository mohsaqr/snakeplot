describe("diverging_palette()", {
  it("returns correct number of colors", {
    expect_length(diverging_palette(5), 5)
    expect_length(diverging_palette(3), 3)
    expect_length(diverging_palette(7), 7)
  })

  it("returns valid hex colors", {
    cols <- diverging_palette(5)
    expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", cols)))
  })

  it("has warm start and cool end", {
    cols <- diverging_palette(5)
    rgb_first <- grDevices::col2rgb(cols[1])
    rgb_last  <- grDevices::col2rgb(cols[5])
    # First color should be warmer (more red)
    expect_gt(rgb_first["red", 1], rgb_last["red", 1])
    # Last color should be cooler (more blue)
    expect_gt(rgb_last["blue", 1], rgb_first["blue", 1])
  })

  it("rejects n < 2", {
    expect_error(diverging_palette(1))
  })
})

describe("sequential_palette()", {
  it("returns correct number of colors", {
    expect_length(sequential_palette(5), 5)
    expect_length(sequential_palette(3, hue = 120), 3)
  })

  it("returns valid hex colors", {
    cols <- sequential_palette(5, hue = 210)
    expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", cols)))
  })

  it("gets darker with higher index", {
    cols <- sequential_palette(5)
    rgb_vals <- vapply(cols, function(c) {
      sum(grDevices::col2rgb(c))
    }, numeric(1))
    # Luminance should decrease (lighter to darker)
    expect_true(all(diff(rgb_vals) < 0))
  })
})

describe("alpha_col()", {
  it("adds alpha to a hex color", {
    result <- alpha_col("#FF0000", 0.5)
    expect_type(result, "character")
    # Should be a valid color (no error when converting)
    expect_no_error(grDevices::col2rgb(result, alpha = TRUE))
  })

  it("works with named colors", {
    result <- alpha_col("red", 0.3)
    rgba <- grDevices::col2rgb(result, alpha = TRUE)
    expect_equal(unname(rgba["alpha", 1]), round(0.3 * 255), tolerance = 1)
  })
})

describe("shade_by_value()", {
  it("returns valid hex color", {
    col <- shade_by_value(3, 1, 5)
    expect_true(grepl("^#[0-9A-Fa-f]{6}$", col))
  })

  it("returns warm color for low values", {
    col_low  <- shade_by_value(1, 1, 5)
    col_high <- shade_by_value(5, 1, 5)
    rgb_low  <- grDevices::col2rgb(col_low)
    rgb_high <- grDevices::col2rgb(col_high)
    # Low value should be warmer
    expect_gt(rgb_low["red", 1], rgb_high["red", 1])
  })

  it("clamps out-of-range values", {
    expect_no_error(shade_by_value(0, 1, 5))
    expect_no_error(shade_by_value(10, 1, 5))
  })

  it("accepts custom palette", {
    col <- shade_by_value(3, 1, 5, palette = c("#000000", "#FFFFFF"))
    expect_true(grepl("^#[0-9A-Fa-f]{6}$", col))
    # Midpoint of black-to-white should be gray
    rgb_val <- grDevices::col2rgb(col)[, 1L]
    expect_equal(unname(rgb_val["red"]), 128, tolerance = 2)
  })

  it("custom palette maps endpoints correctly", {
    col_low  <- shade_by_value(1, 1, 5, palette = c("#FF0000", "#0000FF"))
    col_high <- shade_by_value(5, 1, 5, palette = c("#FF0000", "#0000FF"))
    rgb_low  <- grDevices::col2rgb(col_low)
    rgb_high <- grDevices::col2rgb(col_high)
    expect_equal(unname(rgb_low["red", 1]), 255)
    expect_equal(unname(rgb_high["blue", 1]), 255)
  })
})

describe("cycle_colors()", {
  it("recycles shorter vector", {
    expect_equal(cycle_colors(c("a", "b"), 5), c("a", "b", "a", "b", "a"))
  })

  it("truncates longer vector", {
    expect_equal(cycle_colors(c("a", "b", "c"), 2), c("a", "b"))
  })

  it("returns as-is when lengths match", {
    expect_equal(cycle_colors(c("a", "b"), 2), c("a", "b"))
  })
})

describe("blend_colors()", {
  it("returns valid hex color", {
    result <- blend_colors("#FF0000", "#0000FF")
    expect_true(grepl("^#[0-9A-Fa-f]{6}$", result))
  })

  it("averages RGB channels", {
    result <- blend_colors("#FF0000", "#0000FF")
    rgb_val <- grDevices::col2rgb(result)[, 1L]
    # (255+0)/2 ~ 128 for red, 0 for green, (0+255)/2 ~ 128 for blue
    expect_equal(unname(rgb_val["red"]), 128, tolerance = 1)
    expect_equal(unname(rgb_val["green"]), 0)
    expect_equal(unname(rgb_val["blue"]), 128, tolerance = 1)
  })

  it("blending identical colors returns the same color", {
    result <- blend_colors("#5c2a0e", "#5c2a0e")
    expect_equal(toupper(result), "#5C2A0E")
  })

  it("works with named colors", {
    result <- blend_colors("red", "blue")
    expect_true(grepl("^#[0-9A-Fa-f]{6}$", result))
  })
})

describe("parse_rgba()", {
  it("parses valid rgba string", {
    result <- parse_rgba("rgba(255,255,255,0.25)")
    rgba <- grDevices::col2rgb(result, alpha = TRUE)
    expect_equal(unname(rgba["red", 1]), 255)
    expect_equal(unname(rgba["green", 1]), 255)
    expect_equal(unname(rgba["blue", 1]), 255)
    expect_equal(unname(rgba["alpha", 1]), round(0.25 * 255), tolerance = 1)
  })

  it("returns fallback for malformed input", {
    result <- parse_rgba("invalid")
    expect_type(result, "character")
  })
})
