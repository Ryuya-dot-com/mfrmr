make_structural_recession_rater_data <- function(separated = TRUE) {
  data <- expand.grid(
    Person = sprintf("P%02d", seq_len(12L)),
    Rater = c("R1", "R2"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  data$Score <- if (isTRUE(separated)) {
    ifelse(data$Rater == "R1", 0L, 1L)
  } else {
    ifelse(data$Rater == "R1", 0L, rep(c(0L, 1L), 12L))
  }
  data
}

fit_structural_recession_rater <- function(data, ...) {
  suppressWarnings(fit_mfrm(
    data,
    person = "Person",
    facets = "Rater",
    score = "Score",
    rating_min = 0,
    rating_max = 1,
    method = "JML",
    model = "RSM",
    maxit = 80,
    ...
  ))
}

test_that("sum-zero Rater separation receives an exact structural certificate", {
  skip_if_not_installed("lpSolve")
  fit <- fit_structural_recession_rater(
    make_structural_recession_rater_data(TRUE)
  )
  audit <- fit$config$boundary_audit$structural_additive
  rater <- audit$target_status[
    audit$target_status$ParameterClass == "facet", , drop = FALSE
  ]
  rater <- rater[match(c("R1", "R2"), rater$Level), , drop = FALSE]

  expect_identical(audit$state, "certified_recession")
  expect_true(isTRUE(audit$complete))
  expect_identical(
    rater$CandidateStatus,
    c("unbounded_high", "unbounded_low")
  )
  expect_identical(rater$PositiveRecession, c(TRUE, FALSE))
  expect_identical(rater$NegativeRecession, c(FALSE, TRUE))
  expect_true(all(is.finite(rater$OptimizerEstimate)))
  expect_true(all(audit$certificates$MinimumContrastMargin >= -1e-7))
  certified <- audit$certificates[audit$certificates$Certified, , drop = FALSE]
  expect_true(all(certified$StrictContrastRows > 0L))
  expect_true(all(certified$PositiveContrastMargin > 0))
  expect_true(nrow(audit$direction_loadings) > 0L)

  # This slice stores the certificate but deliberately does not yet mutate
  # public result tables. Cross-surface primary-value propagation is WP4.
  expect_true(all(is.finite(fit$facets$others$Estimate)))
})

test_that("a response-constant level alone does not prove structural recession", {
  skip_if_not_installed("lpSolve")
  fit <- fit_structural_recession_rater(
    make_structural_recession_rater_data(FALSE)
  )
  audit <- fit$config$boundary_audit$structural_additive
  rater <- audit$target_status[
    audit$target_status$ParameterClass == "facet", , drop = FALSE
  ]

  expect_identical(audit$state, "none_certified")
  expect_true(isTRUE(audit$complete))
  expect_true(all(rater$CandidateStatus == "finite_in_audited_subspace"))
  expect_false(any(rater$PositiveRecession))
  expect_false(any(rater$NegativeRecession))
  expect_true(any(
    as.character(fit$prep$data$Rater) == "R1" & fit$prep$data$Score == 0L
  ))
  expect_true(all(
    fit$prep$data$Score[as.character(fit$prep$data$Rater) == "R1"] == 0L
  ))
})

test_that("structural contrasts use retained positive-weight observations", {
  skip_if_not_installed("lpSolve")
  data <- make_structural_recession_rater_data(TRUE)
  data$Weight <- 1
  zero_row <- which(data$Person == "P01" & data$Rater == "R1")
  missing_row <- which(data$Person == "P02" & data$Rater == "R2")
  data$Score[zero_row] <- 1L
  data$Weight[zero_row] <- 0
  data$Score[missing_row] <- NA_integer_

  fit <- suppressWarnings(fit_mfrm(
    data,
    person = "Person",
    facets = "Rater",
    score = "Score",
    weight = "Weight",
    rating_min = 0,
    rating_max = 1,
    method = "JML",
    model = "RSM",
    maxit = 80
  ))
  audit <- fit$config$boundary_audit$structural_additive
  rater <- audit$target_status[
    audit$target_status$ParameterClass == "facet", , drop = FALSE
  ]
  rater <- rater[match(c("R1", "R2"), rater$Level), , drop = FALSE]

  expect_identical(nrow(fit$prep$data), 22L)
  expect_identical(audit$dimensions$Observations, 22L)
  expect_identical(
    rater$CandidateStatus,
    c("unbounded_high", "unbounded_low")
  )
})

test_that("facet signs and direct anchors enter the structural certificate", {
  skip_if_not_installed("lpSolve")
  data <- make_structural_recession_rater_data(TRUE)
  positive_fit <- fit_structural_recession_rater(
    data,
    positive_facets = "Rater"
  )
  positive <- positive_fit$config$boundary_audit$structural_additive$target_status
  positive <- positive[positive$ParameterClass == "facet", , drop = FALSE]
  positive <- positive[match(c("R1", "R2"), positive$Level), , drop = FALSE]
  expect_identical(
    positive$CandidateStatus,
    c("unbounded_low", "unbounded_high")
  )

  anchored_fit <- fit_structural_recession_rater(
    data,
    anchors = data.frame(
      Facet = "Rater",
      Level = "R1",
      Anchor = 0,
      stringsAsFactors = FALSE
    )
  )
  anchored <- anchored_fit$config$boundary_audit$structural_additive$target_status
  anchored <- anchored[anchored$ParameterClass == "facet", , drop = FALSE]
  anchored <- anchored[match(c("R1", "R2"), anchored$Level), , drop = FALSE]
  expect_identical(anchored$CandidateStatus, c("fixed", "fixed"))
  expect_false(any(anchored$PositiveRecession))
  expect_false(any(anchored$NegativeRecession))
  expect_identical(
    anchored_fit$config$boundary_audit$structural_additive$state,
    "no_free_structural_coordinates"
  )
})

test_that("checkerboard interaction cells receive sign-specific certificates", {
  skip_if_not_installed("lpSolve")
  data <- expand.grid(
    Person = sprintf("P%02d", seq_len(12L)),
    Rater = c("R1", "R2"),
    Criterion = c("C1", "C2"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  data$Score <- as.integer(
    (data$Rater == "R1") == (data$Criterion == "C1")
  )
  fit <- suppressWarnings(fit_mfrm(
    data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 0,
    rating_max = 1,
    method = "JML",
    model = "RSM",
    facet_interactions = "Rater:Criterion",
    min_obs_per_interaction = 1,
    maxit = 80
  ))
  audit <- fit$config$boundary_audit$structural_additive
  interaction <- audit$target_status[
    audit$target_status$ParameterClass == "interaction", , drop = FALSE
  ]
  interaction <- interaction[
    match(c("R1*C1", "R2*C1", "R1*C2", "R2*C2"), interaction$Level),
    , drop = FALSE
  ]

  expect_identical(audit$state, "certified_recession")
  expect_identical(
    interaction$CandidateStatus,
    c("unbounded_high", "unbounded_low", "unbounded_low", "unbounded_high")
  )
  expect_true(all(interaction$EvaluationState == "evaluated"))
})

test_that("MML is not reduced to the JML structural recession contract", {
  config <- list(method = "MML", model = "RSM")
  audit <- mfrmr:::audit_mfrm_jml_structural_recession(
    prep = list(),
    idx = list(),
    config = config,
    sizes = list(),
    params = list()
  )

  expect_identical(audit$state, "not_applicable_mml")
  expect_true(isTRUE(audit$complete))
  expect_identical(nrow(audit$target_status), 0L)
})

test_that("bounded execution limits fail closed without inventing a certificate", {
  skip_if_not_installed("lpSolve")
  fit <- fit_structural_recession_rater(
    make_structural_recession_rater_data(TRUE)
  )
  config <- fit$config
  sizes <- mfrmr:::build_param_sizes(config)
  idx <- mfrmr:::build_indices(
    fit$prep,
    step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs
  )
  params <- mfrmr:::expand_params(fit$opt$par, sizes, config)
  audit <- mfrmr:::audit_mfrm_jml_structural_recession(
    prep = fit$prep,
    idx = idx,
    config = config,
    sizes = sizes,
    params = params,
    max_lp_elements = 1
  )

  expect_identical(audit$state, "not_evaluated_size_limit")
  expect_false(isTRUE(audit$complete))
  expect_false(any(audit$target_status$PositiveRecession, na.rm = TRUE))
  expect_false(any(audit$target_status$NegativeRecession, na.rm = TRUE))
  expect_true(any(
    audit$target_status$CandidateStatus == "not_evaluated_size_limit"
  ))
  expect_identical(nrow(audit$certificates), 0L)
})
