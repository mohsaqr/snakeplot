describe("multi_snake()", {
  set.seed(42)
  states <- c("Active", "Passive", "Absent")
  seqs <- matrix(sample(states, 500, replace = TRUE), nrow = 50, ncol = 10)

  it("renders index mode without error", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs, type = "index"))
  })

  it("renders distribution mode without error", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs, type = "distribution"))
  })

  it("accepts data.frame input", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    df <- as.data.frame(seqs, stringsAsFactors = FALSE)
    expect_silent(multi_snake(df, type = "index"))
  })

  it("accepts custom alphabet and colors", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    cols <- c(Active = "#E41A1C", Passive = "#377EB8", Absent = "#999999")
    expect_silent(multi_snake(seqs, colors = cols,
                              alphabet = c("Active", "Passive", "Absent")))
  })

  it("handles sort_by = 'first'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs, sort_by = "first"))
  })

  it("handles sort_by = 'last'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs, sort_by = "last"))
  })

  it("handles sort_by = 'freq'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs, sort_by = "freq"))
  })

  it("handles sort_by = 'entropy'", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs, sort_by = "entropy"))
  })

  it("handles named column labels", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    seqs2 <- seqs
    colnames(seqs2) <- paste0("T", seq_len(ncol(seqs2)))
    expect_silent(multi_snake(seqs2, type = "distribution"))
  })

  it("respects title, show_labels, show_legend, shadow", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs, title = "Test",
                              show_labels = FALSE,
                              show_legend = FALSE,
                              shadow = FALSE))
  })

  it("respects show_pct = FALSE in distribution", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs, type = "distribution",
                              show_pct = FALSE))
  })

  it("handles n_rows override", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    expect_silent(multi_snake(seqs, n_rows = 3))
  })

  it("works with large number of sequences (1000)", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    big <- matrix(sample(states, 50000, replace = TRUE),
                  nrow = 1000, ncol = 50)
    expect_silent(multi_snake(big, type = "index"))
    expect_silent(multi_snake(big, type = "distribution"))
  })

  it("works with many states", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    many_states <- paste0("S", seq_len(12))
    big <- matrix(sample(many_states, 6000, replace = TRUE),
                  nrow = 200, ncol = 30)
    expect_silent(multi_snake(big, type = "index"))
    expect_silent(multi_snake(big, type = "distribution"))
  })

  it("handles single time point", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    single <- matrix(sample(states, 20, replace = TRUE), ncol = 1)
    expect_silent(multi_snake(single, type = "index"))
    expect_silent(multi_snake(single, type = "distribution"))
  })

  it("handles single sequence", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    single <- matrix(sample(states, 10, replace = TRUE), nrow = 1)
    expect_silent(multi_snake(single, type = "index"))
  })

  it("handles two sequences", {
    grDevices::pdf(nullfile())
    on.exit(grDevices::dev.off(), add = TRUE)
    small <- matrix(sample(states, 20, replace = TRUE), nrow = 2)
    expect_silent(multi_snake(small, type = "index",
                              sort_by = "entropy"))
  })
})
