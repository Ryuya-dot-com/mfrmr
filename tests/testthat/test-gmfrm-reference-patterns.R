reference_pattern_model <- function() {
  d <- data.frame(Person = rep(paste0("p", 1:4), each = 4L),
    Task = rep(c("t1", "t2", "t1", "t2"), 4L),
    Rater = rep(c("r1", "r1", "r2", "r2"), 4L),
    Score = rep(c(0L, 1L, 2L, 0L), 4L))
  # p2 duplicates p1, but rows arrive in reverse order. p3 has the same total;
  # p4 has the same ordered responses on a different rater allocation.
  d[5:8, 2:4] <- d[8:5, 2:4]
  d$Score[9:12] <- c(0L, 2L, 1L, 0L)
  d$Rater[13:16] <- c("r2", "r2", "r1", "r1")
  s <- list(data = d, max_score = 2L, slope_facets = c("Task", "Rater"),
    person = "Person", score = "Score")
  mfrm_gmfrm_reference_design(s, rep(0, 8L))
}

test_that("exact pattern reuse preserves each person's likelihood, score and error budget", {
  model <- reference_pattern_model()
  individual <- lapply(model$groups, function(rows) {
    one <- model; one$groups <- list(rows)
    mfrm_gmfrm_reference_integrate(one)
  })
  # Equal likelihoods do not imply equal native scores at zero parameters.
  expect_equal(individual[[1]]$nll, individual[[4]]$nll, tolerance = 1e-12)
  expect_gt(max(abs(individual[[1]]$score - individual[[4]]$score)), .1)
  calls <- 0L; original <- mfrm_gmfrm_reference_person
  testthat::local_mocked_bindings(mfrm_gmfrm_reference_person = function(model, rows) {
    calls <<- calls + 1L
    original(model, rows)
  })
  answer <- mfrm_gmfrm_reference_integrate(model)
  expect_identical(calls, 3L)
  expect_true(answer$qualified)
  expect_named(answer$people, names(model$groups))
  expect_equal(answer$nll, sum(vapply(individual, `[[`, 0, "nll")), tolerance = 1e-12)
  expect_equal(answer$score, Reduce(`+`, lapply(individual, `[[`, "score")), tolerance = 1e-12)
  for (j in seq_along(individual))
    expect_equal(answer$people[[j]], individual[[j]]$people[[1L]], tolerance = 1e-12)
  expect_equal(unname(answer$checks[4L]),
    sum(vapply(individual, function(x) x$checks[4L], 0)), tolerance = 1e-12)
  calls <- 0L
  expect_equal(mfrm_gmfrm_reference_integrate(model, FALSE), answer$nll, tolerance = 1e-12)
  expect_identical(calls, 3L)
})

test_that("reference pattern equality is exact and recomputed after input changes", {
  model <- reference_pattern_model()
  calls <- 0L; original <- mfrm_gmfrm_reference_person
  testthat::local_mocked_bindings(mfrm_gmfrm_reference_person = function(model, rows) {
    calls <<- calls + 1L
    original(model, rows)
  })
  # A small offset difference must not be rounded away by a character key.
  model$offset[5L, 2L] <- 1e-14
  expect_true(is.finite(mfrm_gmfrm_reference_integrate(model, FALSE)))
  expect_identical(calls, 4L)
  model$offset[5L, 2L] <- 0
  calls <- 0L
  expect_true(is.finite(mfrm_gmfrm_reference_integrate(model, FALSE)))
  expect_identical(calls, 3L)
  model$score[5L] <- 1L
  calls <- 0L
  expect_true(is.finite(mfrm_gmfrm_reference_integrate(model, FALSE)))
  expect_identical(calls, 4L)
})
