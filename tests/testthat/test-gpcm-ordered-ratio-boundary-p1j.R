gpcm_or_p1j_paths <- function() {
  files <- c(
    numerical = "numerical-stationarity-pilot-0.2.3.R",
    p0 = "gpcm-solution-stability-p0-0.2.3.R",
    p0b = "gpcm-endpoint-solution-stability-p0b-0.2.3.R",
    p1a = "gpcm-population-variance-profile-p1a-0.2.3.R",
    p1b = "gpcm-low-basin-quadrature-p1b-0.2.3.R",
    p1c = "gpcm-zero-variance-boundary-p1c-0.2.3.R",
    p1d = "gpcm-zero-variance-log-slope-path-p1d-0.2.3.R",
    p1e = "gpcm-coordinate-scaled-joint-limit-p1e-0.2.3.R",
    p1f = "gpcm-slope-rate-cone-p1f-0.2.3.R",
    p1g = "gpcm-c4-face-to-deterministic-rater-p1g-0.2.3.R",
    p1h = "gpcm-single-target-face-screen-p1h-0.2.3.R",
    p1i = "gpcm-two-target-radial-screen-p1i-0.2.3.R",
    p1j = "gpcm-ordered-ratio-boundary-p1j-0.2.3.R"
  )
  paths <- vapply(files, function(file) testthat::test_path(
    "..", "..", "inst", "validation", file
  ), character(1L))
  c(
    paths,
    record = testthat::test_path(
      "..", "..", "inst", "validation",
      "gpcm-ordered-ratio-boundary-p1j-record-0.2.3.md"
    )
  )
}

gpcm_or_p1j_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_or_p1j_paths()
    testthat::skip_if_not(
      all(file.exists(paths)),
      "internal validation artifacts are excluded"
    )
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    for (path in paths[!names(paths) %in% "record"]) {
      sys.source(path, envir = value)
    }
    value
  }
})

gpcm_or_p1j_synthetic_context <- function() {
  n_person <- 3L
  n_criterion <- 4L
  n_rater <- 2L
  person <- rep(seq_len(n_person), each = n_criterion * n_rater)
  criterion <- rep(rep(seq_len(n_criterion), each = n_rater), n_person)
  rater <- rep(rep(seq_len(n_rater), n_criterion), n_person)
  score <- (2L * person + criterion + rater) %% 3L
  list(
    config = list(
      facet_levels = list(
        Rater = paste0("R", seq_len(n_rater)),
        Criterion = paste0("C", seq_len(n_criterion))
      ),
      n_cat = 3L,
      n_person = n_person
    ),
    sizes = list(steps = 4L),
    idx = list(
      score_k = score,
      person = person,
      slope_idx = criterion,
      facets = list(Rater = rater, Criterion = criterion),
      weight = rep(1, length(score))
    ),
    quad = list(
      nodes = c(-sqrt(3), 0, sqrt(3)),
      weights = c(1 / 6, 2 / 3, 1 / 6)
    )
  )
}

test_that("P1j freezes P1i and the ordered boundary plan", {
  env <- gpcm_or_p1j_environment()
  paths <- gpcm_or_p1j_paths()
  plan <- env$mfrmr_gorb_p1j_plan()

  expect_identical(
    env$mfrmr_gorb_p1j_contract,
    "mfrmr_gpcm_ordered_ratio_boundary_p1j_v1"
  )
  expect_identical(
    digest::digest(
      paths[["p1i"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gorb_p1j_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["p1j"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "b8438e014db1cfa55ea55669991b693f43a2ec8834a97ffb5505268774be6d26"
  )
  expect_equal(nrow(plan$ordered_pairs), 12L)
  expect_equal(length(unique(plan$ordered_pairs$OrderedPairId)), 12L)
  expect_equal(nrow(plan$singleton_nesting), 672L)
  expect_equal(
    sum(plan$singleton_nesting$IndependentRhoDerivativeScheduled), 192L
  )
  expect_equal(plan$positive_p1i_transport_count, 288L)
  expect_false(plan$fixed_rho_profiles_planned)
  expect_false(plan$coefficient_ratio_profiles_completed)
  expect_false(plan$three_target_faces_evaluated)
  expect_false(plan$SelectionAuthorized)
  expect_false(plan$ConfirmationAuthorized)
})

test_that("P1j ordered coordinates round trip for all directions", {
  env <- gpcm_or_p1j_environment()
  context <- gpcm_or_p1j_synthetic_context()
  for (index in seq_len(nrow(env$mfrmr_gorb_p1j_ordered_pairs))) {
    order <- env$mfrmr_gorb_p1j_ordered_pairs[index, ]
    targets <- sort(c(order$FastIndex, order$SlowIndex))
    layout <- env$mfrmr_gsrc_p1f_layout(context, targets)
    y <- seq(-0.35, 0.45, length.out = layout$dimension)
    lambda <- setNames(c(0.09, 0.18), c(order$FastIndex, order$SlowIndex))
    y[layout$log_lambda] <- log(lambda[as.character(layout$target_indices)])
    converted <- env$mfrmr_gorb_p1j_from_p1f(
      y, context, order$FastIndex, order$SlowIndex
    )
    recovered <- env$mfrmr_gorb_p1j_to_p1f(
      converted$x, converted$mu, converted$rho, context,
      order$FastIndex, order$SlowIndex
    )
    expect_equal(recovered, y, tolerance = 1e-15)
    expect_equal(converted$mu, 0.18, tolerance = 1e-15)
    expect_equal(converted$rho, 0.5, tolerance = 1e-15)

    p1i <- env$mfrmr_gorb_p1j_to_p1i(
      converted$x, converted$mu, converted$rho, context,
      order$FastIndex, order$SlowIndex
    )
    transported <- env$mfrmr_gorb_p1j_from_p1i(
      p1i$w, p1i$tau, context, targets,
      order$FastIndex, order$SlowIndex
    )
    expect_equal(transported$x, converted$x, tolerance = 1e-15)
    expect_equal(transported$mu, converted$mu, tolerance = 1e-15)
    expect_equal(transported$rho, converted$rho, tolerance = 1e-15)
  }
})

test_that("P1j equals P1f and its derivatives are independently correct", {
  env <- gpcm_or_p1j_environment()
  context <- gpcm_or_p1j_synthetic_context()
  h <- 1e-6
  for (index in seq_len(nrow(env$mfrmr_gorb_p1j_ordered_pairs))) {
    order <- env$mfrmr_gorb_p1j_ordered_pairs[index, ]
    targets <- sort(c(order$FastIndex, order$SlowIndex))
    layout <- env$mfrmr_gsrc_p1f_layout(context, targets)
    y <- seq(-0.2, 0.25, length.out = layout$dimension)
    lambda <- setNames(c(0.08, 0.16), c(order$FastIndex, order$SlowIndex))
    y[layout$log_lambda] <- log(lambda[as.character(layout$target_indices)])
    converted <- env$mfrmr_gorb_p1j_from_p1f(
      y, context, order$FastIndex, order$SlowIndex
    )
    p1f <- env$mfrmr_gsrc_p1f_limit_bundle(
      y, context, targets, include_gradient = FALSE
    )
    ordered <- env$mfrmr_gorb_p1j_bundle(
      converted$x, converted$mu, converted$rho, context,
      order$FastIndex, order$SlowIndex, include_gradient = TRUE
    )
    numeric_gradient <- env$mfrmr_num_central_gradient(
      function(value) env$mfrmr_gorb_p1j_bundle(
        value, converted$mu, converted$rho, context,
        order$FastIndex, order$SlowIndex,
        include_gradient = FALSE
      )$objective,
      converted$x,
      h
    )
    numeric_mu <- (
      env$mfrmr_gorb_p1j_bundle(
        converted$x, converted$mu + h, converted$rho, context,
        order$FastIndex, order$SlowIndex, include_gradient = FALSE
      )$objective -
        env$mfrmr_gorb_p1j_bundle(
          converted$x, converted$mu - h, converted$rho, context,
          order$FastIndex, order$SlowIndex, include_gradient = FALSE
        )$objective
    ) / (2 * h)
    numeric_rho <- (
      env$mfrmr_gorb_p1j_bundle(
        converted$x, converted$mu, converted$rho + h, context,
        order$FastIndex, order$SlowIndex, include_gradient = FALSE
      )$objective -
        env$mfrmr_gorb_p1j_bundle(
          converted$x, converted$mu, converted$rho - h, context,
          order$FastIndex, order$SlowIndex, include_gradient = FALSE
        )$objective
    ) / (2 * h)

    expect_equal(ordered$objective, p1f$objective, tolerance = 1e-12)
    expect_lt(max(abs(ordered$gradient - numeric_gradient)), 1e-6)
    expect_equal(ordered$mu_gradient, numeric_mu, tolerance = 1e-6)
    expect_equal(ordered$rho_gradient, numeric_rho, tolerance = 1e-6)
  }
})

test_that("P1j rho zero is exactly the P1h and P1g singleton likelihood", {
  env <- gpcm_or_p1j_environment()
  context <- gpcm_or_p1j_synthetic_context()
  layout <- env$mfrmr_gc4_p1g_layout(context)
  x <- seq(-0.1, 0.2, length.out = layout$dimension)
  for (mu in c(0, 0.15)) {
    for (slow_index in seq_len(4L)) {
      single <- env$mfrmr_gorb_p1j_single_bundle(
        x, mu, context, slow_index, include_gradient = TRUE
      )
      for (fast_index in setdiff(seq_len(4L), slow_index)) {
        ordered <- env$mfrmr_gorb_p1j_bundle(
          x, mu, 0, context, fast_index, slow_index,
          include_gradient = TRUE
        )
        expect_equal(ordered$objective, single$objective, tolerance = 1e-12)
        expect_equal(ordered$gradient, single$gradient, tolerance = 1e-12)
        expect_equal(
          ordered$mu_gradient, single$lambda_gradient, tolerance = 1e-12
        )

        h <- env$mfrmr_gorb_p1j_rho_derivative_step
        f0 <- ordered$objective
        f1 <- env$mfrmr_gorb_p1j_bundle(
          x, mu, h, context, fast_index, slow_index,
          include_gradient = FALSE
        )$objective
        f2 <- env$mfrmr_gorb_p1j_bundle(
          x, mu, 2 * h, context, fast_index, slow_index,
          include_gradient = FALSE
        )$objective
        numeric_rho <- (-3 * f0 + 4 * f1 - f2) / (2 * h)
        expect_equal(ordered$rho_gradient, numeric_rho, tolerance = 1e-6)
      }
    }
  }
})

test_that("P1j decision separates identity from profile completion", {
  env <- gpcm_or_p1j_environment()
  transport <- data.frame(
    PositiveP1iTransportIdentityComplete = rep(TRUE, 288L)
  )
  nesting <- data.frame(
    OrderedRatioBoundaryIdentityComplete = rep(TRUE, 672L),
    BoundaryRhoDerivativeNonnegative = c(
      rep(TRUE, 280L), rep(FALSE, 392L)
    )
  )
  decision <- env$mfrmr_gorb_p1j_overall_decision(transport, nesting)

  expect_true(decision$AllPositiveP1iPointsTransported)
  expect_true(decision$AllTwelveOrderedRatioBoundaryIdentitiesCertified)
  expect_true(decision$CoefficientRatioBoundaryLikelihoodIdentityCertified)
  expect_false(decision$AllBoundaryRhoDerivativesNonnegative)
  expect_false(decision$CoefficientRatioLocalDerivativeGridScreened)
  expect_false(decision$CoefficientRatioProfilesCompleted)
  expect_false(decision$AllSixTwoTargetFacesGloballyCertified)
  expect_false(decision$ThreeTargetFacesEvaluated)
  expect_false(decision$EmptyRandomProductHierarchyComplete)
  expect_false(decision$GlobalJointBoundaryProfileCertified)
  expect_false(decision$HessianAuthorized)
  expect_false(decision$DFFFitRankAuthorized)
  expect_false(decision$SelectionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("P1j dependency rebuild remains separately opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_P1J_DEPENDENCY_REBUILD"), "true"),
    "set MFRMR_RUN_P1J_DEPENDENCY_REBUILD=true for the P1j chained audit"
  )
  env <- gpcm_or_p1j_environment()
  result <- env$mfrmr_run_gpcm_ordered_ratio_boundary_p1j(
    allow_dependency_rebuild = TRUE,
    progress = FALSE
  )

  expect_s3_class(result, "mfrmr_gpcm_ordered_ratio_boundary_p1j")
  expect_equal(nrow(result$transport), 288L)
  expect_equal(nrow(result$singleton_nesting), 672L)
  expect_true(result$AllPositiveP1iPointsTransported)
  expect_true(result$AllTwelveOrderedRatioBoundaryIdentitiesCertified)
  expect_true(result$CoefficientRatioBoundaryLikelihoodIdentityCertified)
  expect_equal(
    sum(result$singleton_nesting$BoundaryRhoDerivativeNonnegative), 280L
  )
  expect_false(result$AllBoundaryRhoDerivativesNonnegative)
  expect_false(result$CoefficientRatioLocalDerivativeGridScreened)
  expect_false(result$CoefficientRatioProfilesCompleted)
  expect_false(result$AllSixTwoTargetFacesGloballyCertified)
  expect_false(result$ThreeTargetFacesEvaluated)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1j record preserves exact nesting and the profile blocker", {
  paths <- gpcm_or_p1j_paths()
  text <- paste(readLines(paths[["record"]], warn = FALSE), collapse = "\n")

  expect_match(text, "288/288", fixed = TRUE)
  expect_match(text, "672/672", fixed = TRUE)
  expect_match(text, "280/672", fixed = TRUE)
  expect_match(
    text,
    "CoefficientRatioBoundaryLikelihoodIdentityCertified = TRUE",
    fixed = TRUE
  )
  expect_match(
    text, "CoefficientRatioProfilesCompleted = FALSE", fixed = TRUE
  )
  expect_match(
    text, "AllSixTwoTargetFacesGloballyCertified = FALSE", fixed = TRUE
  )
  expect_match(text, "ThreeTargetFacesEvaluated = FALSE", fixed = TRUE)
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
