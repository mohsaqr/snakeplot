# survey_snake() seeds the generator for its tick jitter; the caller's
# random number state must be left as it was (CRAN policy).

draw_survey <- function() {
  grDevices::pdf(nullfile())
  on.exit(grDevices::dev.off(), add = TRUE)
  grDevices::dev.control("enable")
  survey_snake(student_survey, seed = 7L)
  grDevices::recordPlot()
}

test_that("survey_snake() leaves the caller's .Random.seed unchanged", {
  set.seed(2024)
  before <- get(".Random.seed", envir = globalenv())
  draw_survey()
  after <- get(".Random.seed", envir = globalenv())
  expect_identical(after, before)
})

test_that("the caller's next random draw is unaffected by survey_snake()", {
  set.seed(11)
  expected <- stats::runif(3)
  set.seed(11)
  draw_survey()
  expect_identical(stats::runif(3), expected)
})

test_that("survey_snake() creates no .Random.seed when there was none", {
  env <- globalenv()
  had_seed <- exists(".Random.seed", envir = env, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = env)
  on.exit(
    if (had_seed) assign(".Random.seed", old_seed, envir = env),
    add = TRUE
  )
  if (had_seed) rm(".Random.seed", envir = env)
  draw_survey()
  expect_false(exists(".Random.seed", envir = env, inherits = FALSE))
})

test_that("the tick jitter is reproducible whatever the caller's state", {
  set.seed(1)
  first <- draw_survey()
  set.seed(999)
  second <- draw_survey()
  expect_identical(first[[1]], second[[1]])
})
