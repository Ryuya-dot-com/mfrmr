test_that("segmented native-coordinate scores agree with independent response information", {
  for (maximum in c(1L, 3L)) {
    data <- expand.grid(Candidate = paste0("p", 1:4),
      A = c("a1", "a2", "a3"), B = c("b1", "b2", "b3", "b4"))
    data <- data[!(data$A == "a3" & data$B == "b2"), ]
    data$Rating <- rep(0:maximum, length.out = nrow(data))
    names(data)[2:3] <- c("First owner", "Second owner")
    problem <- mfrm_gmfrm_problem(data, maximum, gauss_hermite_normal(121L),
      c("First owner", "Second owner"), "Candidate", "Rating")
    setup <- problem$common; par <- unname(problem$start + .2 * sin(seq_along(problem$start)))
    ev <- mfrm_gmfrm_segmented_evaluator(setup$idx, setup$config, setup$sizes)
    expect_error(ev$value(NULL), "finite free-parameter")
    expect_error(ev$value(NULL), "finite free-parameter")
    result <- ev$evaluate(par)
    basis <- mfrmr_adaptive_quadrature_basis(setup$idx, setup$config,
      expand_params(par, setup$sizes, setup$config), gauss_hermite_normal(121L),
      compute_base_eta(setup$idx, expand_params(par, setup$sizes, setup$config), setup$config))
    ref <- gmfrm_louis_reference(problem$specification, par, basis$nodes, basis$log_weights)
    expect_lt(abs(result$value + sum(ref$log_marginal)), 1e-9)
    expect_lt(max(abs(result$gradient + colSums(ref$scores))), 1e-8)
    numerical <- vapply(seq_along(par), function(j) {
      plus <- minus <- par; plus[j] <- plus[j] + 1e-5; minus[j] <- minus[j] - 1e-5
      (ev$value(plus) - ev$value(minus)) / 2e-5
    }, 0)
    expect_lt(max(abs(result$gradient - numerical)), 1e-7)

    # A rejected trial must not become a stale successful cache hit.
    ev$value(par); before <- ev$diagnostics()$Evaluations
    expect_identical(ev$gradient(par), result$gradient)
    expect_identical(ev$diagnostics()$Evaluations, before)
    bad <- par; bad[length(bad)] <- 1000
    safe <- make_mfrm_boundary_safe_objective(ev)
    expect_identical(safe$value(bad), safe$penalty)
    expect_identical(safe$value(bad), safe$penalty)
    expect_equal(ev$value(par), result$value, tolerance = 0)
    expect_error(ev$value(par[-1]), "expected length")
    expect_error(ev$value(replace(par, 1, NA_real_)), "finite free-parameter")
    expect_error(ev$gradient(NULL), "finite free-parameter")
    expect_error(ev$gradient(NULL), "finite free-parameter")
    cfg <- setup$config; cfg$population_spec$active <- TRUE
    expect_error(mfrm_gmfrm_segmented_evaluator(setup$idx, cfg, setup$sizes), "fixed N")
    idx <- setup$idx; idx$weight <- rep(2, length(idx$score_k))
    expect_error(mfrm_gmfrm_segmented_evaluator(idx, setup$config, setup$sizes), "unweighted")

    # optim owns/reuses its callbacks' input buffers; the cached key must not.
    fit <- optim(par, ev$value, ev$gradient, method = "BFGS", control = list(maxit = 2L))
    fresh <- mfrm_gmfrm_segmented_evaluator(setup$idx, setup$config, setup$sizes)
    expect_equal(ev$value(fit$par), fresh$value(fit$par), tolerance = 0)
    expect_equal(ev$gradient(fit$par), fresh$gradient(fit$par), tolerance = 0)
    C <- numeric(length(par)); C[length(par)] <- 1
    map <- mfrm_gpcm_profile_constraint(par, C, .3)
    embedded <- map$embed(par[map$free])
    expect_identical(sum(embedded * C), .3)
    expect_equal(drop(crossprod(map$basis, ev$gradient(embedded))),
      ev$gradient(embedded)[map$free], tolerance = 0)
  }
})

test_that("segmented Legendre rules preserve polynomial integrals", {
  for (n in c(16L, 32L)) {
    q <- mfrm_legendre_unit_rule(n)
    expect_lt(max(abs(vapply(0:(2*n-1L), function(k)
      sum(q$weights * q$nodes^k) - 1/(k+1), 0))), 2e-14)
  }
  expect_error(mfrm_legendre_unit_rule(1), "Invalid")
})

test_that("segmented accuracy refusals retain the failing point and integration evidence", {
  original_rule <- mfrm_legendre_unit_rule
  testthat::local_mocked_bindings(mfrm_legendre_unit_rule = function(order) {
    rule <- original_rule(order)
    if (order == 32L) rule$weights <- rule$weights * 1.01
    rule
  }, .package = "mfrmr")
  data <- expand.grid(Person = paste0("p", 1:3), Task = c("t1", "t2"),
    Rater = c("r1", "r2"))
  data$Score <- rep(0:2, length.out = nrow(data))
  problem <- mfrm_gmfrm_problem(data, 2, gauss_hermite_normal(15L),
    c("Task", "Rater"), "Person", "Score")
  x <- problem$common
  ev <- mfrm_gmfrm_segmented_evaluator(x$idx, x$config, x$sizes)
  error <- tryCatch(ev$value(problem$start), error = identity)
  expect_s3_class(error, "mfrmr_adaptive_quadrature_numeric_error")
  expect_identical(error$parameters, problem$start)
  expect_gt(error$integration["NLLRuleDifference"], 1e-7)
  expect_length(error$person_errors, 3L)
  expect_true(all(vapply(error$person_errors, function(x)
    is.finite(x$high$log_marginal) && length(x$cuts) > 2L, TRUE)))
  expect_identical(ev$diagnostics()$Evaluations, 1L)
})

test_that("local coordinates retain narrow category transitions", {
  # True relative logits are k * 1e13 * displacement. Forming 1 +
  # displacement in one double first instead loses about 8e-4 here.
  for (categories in c(2L, 4L)) for (n in 1:2) {
    displacement <- c(1e-13, -1e-13)[seq_len(n)]
    logits <- mfrm_segmented_relative_logits(rep(1, n), displacement,
      -(seq_len(categories) - 1L), 1e13)
    expect_identical(dim(logits), c(n, categories))
    expect_equal(sweep(logits, 1L, logits[, 1L]),
      outer(displacement * 1e13, seq_len(categories) - 1L), tolerance = 1e-14)
  }
})
