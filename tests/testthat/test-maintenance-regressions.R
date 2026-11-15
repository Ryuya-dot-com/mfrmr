test_that("diagnostic provenance rejects different data shapes without recycling", {
  example <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
  fit <- example$fit
  dg <- diagnose_mfrm(fit, residual_pca = "none")
  result <- mfrm_results(fit, diagnostics = dg, include = "fit", compute = "never")
  expect_identical(result$diagnostics, dg)
  for (change in c("shorter", "longer", "same_shape")) {
    bad <- dg
    d <- bad$parameter_uncertainty$source$source$data
    if (change == "shorter") d <- d[-1L, , drop = FALSE]
    if (change == "longer") d <- rbind(d, d[1L, , drop = FALSE])
    if (change == "same_shape") d$Score[1] <- d$Score[1] + 1
    bad$parameter_uncertainty$source$source$data <- d
    expect_warning(expect_error(
      mfrm_results(fit, diagnostics = bad, include = "fit", compute = "never"),
      "fit/diagnostics mismatch", fixed = TRUE), NA)
  }
})

test_that("RSM and PCM retain independently verified intervals with empty local cells", {
  skip_if_not_installed("numDeriv")
  set.seed(761)
  d <- expand.grid(Person = paste0("p", 1:60), Rater = c("a", "b", "c"),
    Criterion = c("c1", "c2"), stringsAsFactors = FALSE)
  theta <- rnorm(60)
  rater <- c(a = 2.3, b = 0, c = -2.3)
  criterion <- c(c1 = -.2, c2 = .2)
  d$Score <- vapply(seq_len(nrow(d)), function(i) {
    eta <- theta[match(d$Person[i], paste0("p", 1:60))] -
      rater[d$Rater[i]] - criterion[d$Criterion[i]]
    v <- c(0, cumsum(eta - c(-.4, .4)))
    sample(0:2, 1, prob = exp(v - max(v)))
  }, integer(1))
  d$Score[d$Rater == "a" & d$Score == 2L] <- 1L

  # Independent 81-point normal quadrature and explicit constrained likelihood.
  # Neither the package likelihood nor its parameter/gradient helpers are used.
  jacobi <- matrix(0, 81, 81)
  jacobi[cbind(1:80, 2:81)] <- jacobi[cbind(2:81, 1:80)] <- sqrt(1:80)
  eig <- eigen(jacobi, symmetric = TRUE)
  nodes <- eig$values
  weights <- eig$vectors[1, ]^2
  groups <- split(seq_len(nrow(d)), d$Person)
  for (model in c("RSM", "PCM")) {
    if (model == "PCM") {
      # PCM's existing review is based on its fitted step scopes. Keep a
      # supported singleton in one scope as well as the empty local cells.
      top <- which(d$Criterion == "c1" & d$Score == 2L)
      d$Score[top[-1L]] <- 1L
    }
    fit <- suppressWarnings(fit_mfrm(d, person = "Person",
      facets = c("Rater", "Criterion"), score = "Score", model = model,
      method = "MML", rating_min = 0, rating_max = 2,
      step_facet = if (model == "PCM") "Criterion" else NULL,
      noncenter_facet = "Person", mml_integration = "auto",
      quad_points = 31, maxit = 1000, reltol = 1e-10))
    original <- fit
    ci <- suppressWarnings(mfrm_facet_intervals(fit, "Rater"))
    expect_true(all(ci$table$CIEligible), info = model)
    audit <- audit_mfrm_category_support(fit$prep, fit$config, build_param_sizes(fit$config))
    expect_identical(audit$readiness$CategoryState, "weak_information")
    expect_true(any(nzchar(audit$local_support$MissingCategories)))
    expect_true(all(audit$category_table$WithinScopeCount > 0))
    nll <- function(p) {
      r <- c(a = p[1], b = p[2], c = -p[1] - p[2])
      criterion <- c(c1 = p[3], c2 = -p[3])
      step <- if (model == "RSM") rep(p[4], nrow(d)) else
        p[3 + match(d$Criterion, c("c1", "c2"))]
      eta <- outer(-r[d$Rater] - criterion[d$Criterion], nodes, "+")
      u1 <- eta - step
      u2 <- 2 * eta
      offset <- pmax(0, u1, u2)
      denominator <- offset + log(exp(-offset) + exp(u1-offset) + exp(u2-offset))
      logp <- eta * d$Score - ifelse(d$Score == 1, step, 0) - denominator
      -sum(vapply(groups, function(i) {
        v <- colSums(logp[i, , drop = FALSE])
        m <- max(v)
        m + log(sum(weights * exp(v-m)))
      }, numeric(1)))
    }
    expect_length(fit$opt$par, if (model == "RSM") 4L else 5L)
    expect_equal(nll(fit$opt$par), fit$opt$value, tolerance = 1e-9)
    inverse <- solve(numDeriv::hessian(nll, fit$opt$par))
    expect_equal(unname(ci$parameter_covariance), inverse, tolerance = 2e-6)
    transform <- matrix(0, 3, length(fit$opt$par))
    transform[, 1:2] <- rbind(c(1, 0), c(0, 1), c(-1, -1))
    expect_equal(unname(ci$covariance), transform %*% inverse %*% t(transform),
      tolerance = 2e-6)
    expect_identical(fit, original)
    bad <- fit
    bad$config$boundary_audit$gpcm_slope_boundary <- list(state = "certified_monotone_boundary_path")
    rejected <- suppressWarnings(mfrm_facet_intervals(bad, "Rater"))
    expect_false(any(rejected$table$CIEligible))
  }
})

test_that("saved two-family fits report in a session without Matrix preloaded", {
  skip_if_not_installed("callr")
  # The distributed fixture predates this fix; no refit or migration is needed.
  path <- normalizePath(test_path("fixtures", "gmfrm-explicit-start.rds"))
  replay <- callr::r(function(path, lib) {
    library(mfrmr, lib.loc = lib)
    initially <- "Matrix" %in% loadedNamespaces()
    fit <- readRDS(path)$fit
    before <- serialize(fit, NULL)
    result <- mfrm_results(fit, compute = "never")
    facet <- fit$config$facet_names[2L]
    rater <- as.character(fit$prep$levels[[facet]][1L])
    report <- mfrm_report(result, style = "rater", facet = facet, rater = rater)
    list(initially = initially, loaded = "Matrix" %in% loadedNamespaces(),
      report = inherits(report, "mfrm_rater_feedback"),
      # R versions may materialize a serialized representation differently.
      # Require exact values, types and attributes, rather than raw encodings.
      unchanged = identical(fit, unserialize(before)))
  }, list(path, dirname(find.package("mfrmr"))), libpath = .libPaths())
  expect_false(replay$initially)
  expect_true(replay$loaded)
  expect_true(replay$report)
  expect_true(replay$unchanged)
})
