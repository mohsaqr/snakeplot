describe("arc_sector_polygon()", {
  it("returns x and y coordinates", {
    pts <- arc_sector_polygon(100, 50, 30, 10, -pi / 4, pi / 4, "right")
    expect_type(pts, "list")
    expect_true(all(c("x", "y") %in% names(pts)))
    expect_equal(length(pts$x), length(pts$y))
  })

  it("right side sector extends to the right of cx", {
    pts <- arc_sector_polygon(100, 50, 30, 10, -pi / 2, pi / 2, "right")
    expect_true(min(pts$x) >= 100)
  })

  it("left side sector extends to the left of cx", {
    pts <- arc_sector_polygon(100, 50, 30, 10, -pi / 2, pi / 2, "left")
    expect_true(max(pts$x) <= 100)
  })

  it("bottom side sector extends below cy", {
    pts <- arc_sector_polygon(100, 50, 30, 10, -pi / 2, pi / 2, "bottom")
    expect_true(min(pts$y) >= 50 - 1)
  })

  it("top side sector extends above cy", {
    pts <- arc_sector_polygon(100, 50, 30, 10, -pi / 2, pi / 2, "top")
    expect_true(max(pts$y) <= 50 + 1)
  })

  it("number of points is 2 * n_pts", {
    pts <- arc_sector_polygon(0, 0, 20, 5, 0, pi / 4, "right", n_pts = 15)
    expect_length(pts$x, 30)
    expect_length(pts$y, 30)
  })

  it("narrow sector is subset of full arc range", {
    full <- arc_sector_polygon(100, 50, 30, 10, -pi / 2, pi / 2, "right")
    narrow <- arc_sector_polygon(100, 50, 30, 10, -pi / 4, pi / 4, "right")
    expect_true(max(narrow$y) < max(full$y) + 1)
    expect_true(min(narrow$y) > min(full$y) - 1)
  })
})

describe("resolve_state_colors()", {
  it("uses default palette when colors is NULL", {
    cols <- resolve_state_colors(NULL, c("A", "B", "C"), 3)
    expect_length(cols, 3)
    expect_equal(names(cols), c("A", "B", "C"))
  })

  it("uses named colors for matching states", {
    cols <- resolve_state_colors(c(A = "red", B = "blue"), c("A", "B"), 2)
    expect_equal(unname(cols["A"]), "red")
    expect_equal(unname(cols["B"]), "blue")
  })

  it("fills missing named colors with gray", {
    cols <- resolve_state_colors(c(A = "red"), c("A", "B"), 2)
    expect_equal(unname(cols["A"]), "red")
    expect_equal(unname(cols["B"]), "#CCCCCC")
  })

  it("recycles unnamed colors", {
    cols <- resolve_state_colors(c("red", "blue"), c("X", "Y", "Z"), 3)
    expect_length(cols, 3)
    expect_equal(unname(cols[1]), "red")
    expect_equal(unname(cols[2]), "blue")
    expect_equal(unname(cols[3]), "red")
  })
})

describe("build_segment_table()", {
  it("single row has one band segment", {
    seg <- build_segment_table(1, 500, 23)
    expect_equal(nrow(seg), 1)
    expect_equal(seg$type, "band")
    expect_equal(seg$path_length, 500)
  })

  it("two rows have band-arc-band", {
    seg <- build_segment_table(2, 500, 23)
    expect_equal(nrow(seg), 3)
    expect_equal(seg$type, c("band", "arc", "band"))
    expect_equal(seg$index, c(1, 1, 2))
  })

  it("n rows have 2n-1 segments", {
    seg <- build_segment_table(7, 500, 23)
    expect_equal(nrow(seg), 13)
    expect_equal(sum(seg$type == "band"), 7)
    expect_equal(sum(seg$type == "arc"), 6)
  })

  it("arc path length is pi * r_mid", {
    r_mid <- 23
    seg <- build_segment_table(3, 400, r_mid)
    arc_rows <- seg$type == "arc"
    expect_true(all(abs(seg$path_length[arc_rows] - pi * r_mid) < 1e-10))
  })
})

describe("allocate_blocks()", {
  it("total allocation equals n_blocks", {
    seg_lengths <- c(500, 72, 500, 72, 500)
    alloc <- allocate_blocks(seg_lengths, 75)
    expect_equal(sum(alloc), 75)
  })

  it("allocation is proportional", {
    seg_lengths <- c(100, 100, 100)
    alloc <- allocate_blocks(seg_lengths, 9)
    expect_equal(alloc, c(3L, 3L, 3L))
  })

  it("longer segments get more blocks", {
    seg_lengths <- c(500, 50)
    alloc <- allocate_blocks(seg_lengths, 10)
    expect_true(alloc[1] > alloc[2])
  })

  it("handles single segment", {
    alloc <- allocate_blocks(500, 20)
    expect_equal(alloc, 20L)
  })

  it("handles n_blocks < n_segments", {
    alloc <- allocate_blocks(c(100, 50, 100), 2)
    expect_equal(sum(alloc), 2)
    # Longest segments should get the blocks
    expect_true(alloc[2] <= 1L)
  })
})

describe("sequence_snake()", {
  set.seed(42)
  verbs <- c("Read", "Write", "Discuss", "Listen")
  seq20 <- sample(verbs, 20, replace = TRUE)

  it("runs without error with defaults", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20))
  })

  it("accepts custom rows", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, rows = 3))
  })

  it("accepts named colors", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    cols <- c(Read = "red", Write = "blue", Discuss = "green",
              Listen = "purple")
    expect_silent(sequence_snake(seq20, colors = cols))
  })

  it("accepts unnamed colors", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, colors = c("red", "blue")))
  })

  it("shows position indices", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, show_numbers = TRUE))
  })

  it("hides labels and legend", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, show_labels = FALSE,
                                  show_legend = FALSE))
  })

  it("draws with title", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, title = "Test Title"))
  })

  it("draws without shadow", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, shadow = FALSE))
  })

  it("draws with no block border", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, border_color = NA))
  })

  it("accepts factor input", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    fseq <- factor(seq20, levels = verbs)
    expect_silent(sequence_snake(fseq))
  })

  it("accepts integer input", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    iseq <- sample(1:5, 20, replace = TRUE)
    expect_silent(sequence_snake(iseq))
  })

  it("accepts explicit alphabet", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20,
                                  states = c("Listen", "Read",
                                               "Write", "Discuss")))
  })

  it("works with single block", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake("A", rows = 1))
  })

  it("works with single row", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(rep("X", 5), rows = 1))
  })

  it("works with start_from = 'right'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, start_from = "right"))
  })

  it("errors on unknown states not in alphabet", {
    expect_error(
      sequence_snake(c("A", "B", "C"), states = c("A", "B")),
      "Unknown states"
    )
  })

  it("drops NA in sequence with warning", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_warning(
      sequence_snake(c("A", NA, "B", "A", "B")),
      "Dropped 1 NA"
    )
  })

  it("handles 75 blocks with 7 rows", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    seq75 <- sample(c("A", "B", "C", "D", "E"), 75, replace = TRUE)
    expect_silent(sequence_snake(seq75, rows = 7))
  })

  it("handles 200 blocks with auto rows", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    seq200 <- sample(letters[1:6], 200, replace = TRUE)
    expect_silent(sequence_snake(seq200))
  })

  it("works with vertical orientation", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, orientation = "vertical"))
  })

  it("shows state labels with run-based centering", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    # Run of same state should get one centered label
    run_seq <- c(rep("A", 5), rep("B", 3), rep("A", 2))
    expect_silent(sequence_snake(run_seq, show_state = TRUE,
                                  state_size = 0.8, rows = 2))
  })

  it("shows state labels together with block_labels", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    s <- c("X", "X", "Y", "Y", "Y")
    expect_silent(sequence_snake(s, block_labels = as.character(1:5),
                                  show_state = TRUE, state_size = 0.6,
                                  rows = 2))
  })

  it("draws ruler ticks at block boundaries", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, show_ticks = TRUE, rows = 3))
  })

  it("draws ticks with custom color and length", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, show_ticks = TRUE,
                                  tick_color = "red", tick_length = 8,
                                  rows = 3))
  })

  it("errors on block_labels length mismatch", {
    expect_error(
      sequence_snake(c("A", "B", "C"), block_labels = c("x", "y")),
      "must match"
    )
  })

  it("works with vertical orientation and >1 rows", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, rows = 3,
                                  orientation = "vertical"))
  })

  it("draws band_labels below each band", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, rows = 4,
                                  band_labels = c("A", "B", "C", "D")))
  })

  it("errors on band_labels length mismatch with rows", {
    expect_error(
      sequence_snake(seq20, rows = 3,
                      band_labels = c("X", "Y")),
      "must match"
    )
  })

  it("draws transition_labels inside bands", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    s <- c(rep("A", 5), rep("B", 5), rep("C", 5), rep("D", 5))
    expect_silent(sequence_snake(s, rows = 4,
                                  transition_labels = c("T1", "T2", "T3")))
  })

  it("draws transition_labels inside arcs", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    # 13 blocks across 13 segments (7 bands + 6 arcs) — some transitions
    # will fall on arc segments
    s <- c(rep("A", 1), rep("B", 1), rep("C", 1), rep("D", 1),
           rep("E", 1), rep("F", 1), rep("G", 1), rep("H", 1),
           rep("I", 1), rep("J", 1), rep("K", 1), rep("L", 1),
           rep("M", 1))
    expect_silent(sequence_snake(s, rows = 7,
                                  transition_labels = paste0("T", 1:12)))
  })
})

describe("timeline_snake()", {
  it("runs with minimal input", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(timeline_snake(c("A", "A", "B", "B", "C")))
  })

  it("uses timeline defaults (show_state, no labels)", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    roles <- c(rep("Junior", 3), rep("Senior", 2))
    expect_silent(timeline_snake(roles, rows = 3,
                                  transition_labels = "2020",
                                  band_labels = c("2018", "2020", "2022")))
  })

  it("accepts all sequence_snake parameters", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(timeline_snake(rep("X", 10), rows = 2,
                                  colors = c(X = "red"),
                                  shadow = FALSE, background = "#F0F0F0",
                                  title = "Test"))
  })

  it("accepts data.frame with 3 columns", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    df <- data.frame(
      role  = c("Junior", "Senior", "Lead"),
      start = c("2018-01", "2020-06", "2023-01"),
      end   = c("2020-05", "2022-12", "2024-12")
    )
    expect_silent(timeline_snake(df, title = "DF test"))
  })

  it("auto-generates transition_labels from data.frame", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    df <- data.frame(
      role  = c("A", "B"),
      start = c("2020-01", "2021-07"),
      end   = c("2021-06", "2022-12")
    )
    expect_silent(timeline_snake(df))
  })

  it("allows overriding auto-computed values from data.frame", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    df <- data.frame(
      role  = c("X", "Y"),
      start = c("2020-01", "2021-01"),
      end   = c("2020-12", "2022-06")
    )
    expect_silent(timeline_snake(df, rows = 3,
                                  transition_labels = "Custom",
                                  band_labels = c("A", "B", "C")))
  })
})

describe("sequence_snake() — coverage extras", {
  set.seed(42)
  verbs <- c("Read", "Write", "Discuss", "Listen")
  seq20 <- sample(verbs, 20, replace = TRUE)

  it("draws tick_labels ruler", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, rows = 3,
                                  tick_labels = month.abb[1:4]))
  })

  it("draws block_labels with show_ticks", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, rows = 3,
                                  show_ticks = TRUE,
                                  block_labels = as.character(seq_len(20))))
  })

  it("draws transition_pos fractional positions", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    s <- c(rep("A", 10), rep("B", 10))
    expect_silent(sequence_snake(s, rows = 3,
                                  transition_labels = "Mid",
                                  transition_pos = 7.5))
  })

  it("draws transition_pos on arc segment", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    # Force transition to land on an arc via fractional pos
    s <- c(rep("A", 20), rep("B", 20))
    # With 4 rows: ~10 blocks per band, ~3 per arc.
    # Band1 ends ~10, arc1 ~13, so pos 11.5 is in the arc
    expect_silent(sequence_snake(s, rows = 4,
                                  transition_labels = "T1",
                                  transition_pos = 11.5))
  })

  it("handles vertical orientation with show_state and transitions", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    s <- c(rep("X", 8), rep("Y", 8), rep("Z", 4))
    expect_silent(sequence_snake(s, rows = 3,
                                  orientation = "vertical",
                                  show_state = TRUE,
                                  transition_labels = c("T1", "T2")))
  })

  it("handles vertical show_numbers in arcs", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq20, rows = 3,
                                  orientation = "vertical",
                                  show_numbers = TRUE))
  })

  it("handles alloc with m == 0 segment", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    # 3 blocks across 5 segments (3 bands + 2 arcs) — some get 0
    expect_silent(sequence_snake(c("A", "B", "C"), rows = 3))
  })

  it("draws show_ticks with few blocks and show_labels with 0-alloc bands", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    # 2 blocks across 3 bands + 2 arcs = 5 segments — one band gets 0
    expect_silent(sequence_snake(c("A", "B"), rows = 3,
                                  show_ticks = TRUE, show_labels = TRUE))
  })

  it("draws transition_pos on LTR band", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    # First band is always LTR with start_from="left"
    s <- c(rep("A", 15), rep("B", 15))
    expect_silent(sequence_snake(s, rows = 3,
                                  transition_labels = "T1",
                                  transition_pos = 3.5))
  })

  it("draws transition_pos on vertical arc", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    s <- c(rep("A", 20), rep("B", 20))
    expect_silent(sequence_snake(s, rows = 4,
                                  orientation = "vertical",
                                  transition_labels = "T1",
                                  transition_pos = 11.5))
  })

  it("draws transition_pos out of range returns silently", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    s <- c(rep("A", 10), rep("B", 10))
    # pos 999 is beyond the sequence
    expect_silent(sequence_snake(s, rows = 2,
                                  transition_labels = "T1",
                                  transition_pos = 999))
  })

  it("timeline_snake with explicit alphabet (no data.frame)", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    s <- c(rep("X", 5), rep("Y", 5))
    expect_silent(timeline_snake(s, states = c("X", "Y")))
  })
})

describe("sequence_snake() — rug style", {
  set.seed(42)
  verbs <- c("Read", "Write", "Discuss", "Listen")
  seq30 <- sample(verbs, 30, replace = TRUE)

  it("renders rug style without error", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq30, style = "rug"))
  })

  it("renders rug style with custom band_color", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq30, style = "rug",
                                  band_color = "#1a1a2e"))
  })

  it("renders rug style with multiple rows", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq30, rows = 4, style = "rug",
                                  show_labels = TRUE, show_legend = TRUE,
                                  shadow = TRUE, title = "Rug test"))
  })

  it("renders rug style with large sequence", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    big <- sample(verbs, 500, replace = TRUE)
    expect_silent(sequence_snake(big, rows = 4, style = "rug"))
  })

  it("renders rug style with rug_opacity", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq30, style = "rug", rug_opacity = 0.5))
  })

  it("renders rug style with single row", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq30, rows = 1, style = "rug"))
  })

  it("renders rug style with jitter", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(seq30, rows = 4, style = "rug",
                                  jitter = 0.8))
  })
})

describe("sequence_snake() — flexible input formats", {
  it("accepts comma-separated string", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake("A, B, C, A, B, C, A, B"))
  })

  it("accepts data.frame with character column", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    df <- data.frame(id = 1:10,
                     state = sample(c("X", "Y", "Z"), 10, replace = TRUE),
                     stringsAsFactors = FALSE)
    expect_message(sequence_snake(df), "Using column")
  })

  it("accepts data.frame with factor column", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    df <- data.frame(num = 1:10,
                     cat = factor(sample(c("A", "B"), 10, replace = TRUE)))
    expect_message(sequence_snake(df), "Using column")
  })

  it("accepts list input", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    lst <- list("A", "B", c("C", "A"), "B")
    expect_silent(sequence_snake(lst))
  })

  it("drops NAs with warning", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    x <- c("A", NA, "B", "A", NA, "B", "A", "B")
    expect_warning(sequence_snake(x), "Dropped 2 NA")
  })

  it("accepts integer vector", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(sequence_snake(c(1L, 2L, 3L, 1L, 2L, 3L)))
  })
})
