describe("compute_snake_layout()", {
  it("computes correct band positions", {
    layout <- compute_snake_layout(3, band_height = 20, band_gap = 10,
                                   plot_width = 400)
    bands <- layout$bands
    expect_equal(nrow(bands), 3)
    expect_equal(bands$i, c(0, 1, 2))

    # Band height consistency
    expect_true(all(bands$y_bottom - bands$y_top == 20))

    # Gap between bands
    gaps <- bands$y_top[-1] - bands$y_bottom[-nrow(bands)]
    expect_true(all(gaps == 10))
  })

  it("alternates direction correctly", {
    layout <- compute_snake_layout(5, band_height = 20, band_gap = 10)
    expect_equal(layout$bands$direction,
                 c("ltr", "rtl", "ltr", "rtl", "ltr"))
  })

  it("computes correct number of arcs", {
    layout1 <- compute_snake_layout(1)
    expect_length(layout1$arcs, 0)

    layout3 <- compute_snake_layout(3)
    expect_length(layout3$arcs, 2)

    layout7 <- compute_snake_layout(7)
    expect_length(layout7$arcs, 6)
  })

  it("alternates arc sides correctly", {
    layout <- compute_snake_layout(5)
    sides <- vapply(layout$arcs, `[[`, character(1), "side")
    expect_equal(sides, c("right", "left", "right", "left"))
  })

  it("computes canvas dimensions", {
    layout <- compute_snake_layout(3, band_height = 20, band_gap = 10,
                                   plot_width = 400,
                                   margin = c(top = 30, right = 10,
                                              bottom = 50, left = 80))
    expect_true(layout$canvas$width > 400)
    expect_true(layout$canvas$height > 0)
    # Height = top + 3*20 + 2*10 + bottom = 30 + 60 + 20 + 50 = 160
    expect_equal(layout$canvas$height, 160)
  })

  it("returns snake_layout class", {
    layout <- compute_snake_layout(3)
    expect_s3_class(layout, "snake_layout")
  })

  it("stores parameters", {
    layout <- compute_snake_layout(3, band_height = 25, band_gap = 15)
    expect_equal(layout$params$band_height, 25)
    expect_equal(layout$params$band_gap, 15)
  })
})

describe("arc_polygon()", {
  it("returns x and y coordinates", {
    pts <- arc_polygon(100, 50, 30, 10, "right")
    expect_type(pts, "list")
    expect_true(all(c("x", "y") %in% names(pts)))
    expect_equal(length(pts$x), length(pts$y))
  })

  it("right arc extends to the right of cx", {
    pts <- arc_polygon(100, 50, 30, 10, "right")
    expect_true(max(pts$x) > 100)
    expect_true(min(pts$x) >= 100)
  })

  it("left arc extends to the left of cx", {
    pts <- arc_polygon(100, 50, 30, 10, "left")
    expect_true(min(pts$x) < 100)
    expect_true(max(pts$x) <= 100)
  })

  it("has correct vertical extent", {
    pts <- arc_polygon(100, 50, 30, 10, "right")
    expect_equal(min(pts$y), 50 - 30, tolerance = 0.5)
    expect_equal(max(pts$y), 50 + 30, tolerance = 0.5)
  })

  it("number of points is 2 * n_pts", {
    pts <- arc_polygon(0, 0, 20, 5, "right", n_pts = 25)
    expect_length(pts$x, 50)
  })
})

describe("half_arc_polygon()", {
  it("returns x and y coordinates", {
    pts <- half_arc_polygon(100, 50, 30, 10, "right", "upper")
    expect_type(pts, "list")
    expect_true(all(c("x", "y") %in% names(pts)))
    expect_equal(length(pts$x), length(pts$y))
  })

  it("upper half stays above center y for right side", {
    pts <- half_arc_polygon(100, 50, 30, 10, "right", "upper")
    expect_true(max(pts$y) <= 50 + 0.5)
  })

  it("lower half stays below center y for right side", {
    pts <- half_arc_polygon(100, 50, 30, 10, "right", "lower")
    expect_true(min(pts$y) >= 50 - 0.5)
  })

  it("upper + lower halves cover the same y range as full arc", {
    full <- arc_polygon(100, 50, 30, 10, "right")
    upper <- half_arc_polygon(100, 50, 30, 10, "right", "upper")
    lower <- half_arc_polygon(100, 50, 30, 10, "right", "lower")
    expect_equal(min(upper$y), min(full$y), tolerance = 0.5)
    expect_equal(max(lower$y), max(full$y), tolerance = 0.5)
  })

  it("works for left side", {
    pts <- half_arc_polygon(100, 50, 30, 10, "left", "upper")
    expect_true(max(pts$x) <= 100 + 0.5)
  })

  it("number of points is 2 * n_pts", {
    pts <- half_arc_polygon(0, 0, 20, 5, "right", "upper", n_pts = 20)
    expect_length(pts$x, 40)
  })
})

describe("end_cap_polygon()", {
  it("left cap extends left of x", {
    pts <- end_cap_polygon(100, 50, 14, "left")
    expect_true(min(pts$x) < 100)
  })

  it("right cap extends right of x", {
    pts <- end_cap_polygon(100, 50, 14, "right")
    expect_true(max(pts$x) > 100)
  })

  it("has correct vertical extent", {
    pts <- end_cap_polygon(100, 50, 14, "left")
    expect_equal(min(pts$y), 50 - 14, tolerance = 0.5)
    expect_equal(max(pts$y), 50 + 14, tolerance = 0.5)
  })
})
