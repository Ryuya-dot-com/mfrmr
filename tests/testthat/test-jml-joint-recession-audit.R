make_joint_recession_fixture <- function(separated = TRUE, reverse = FALSE) {
  cells <- expand.grid(
    Person = c("P1", "P2"),
    Item = c("I1", "I2"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  cells$Score <- if (isTRUE(separated)) {
    c(0L, 0L, 1L, 0L)
  } else {
    c(0L, 1L, 1L, 0L)
  }
  data <- cells[rep(seq_len(nrow(cells)), each = 3L), , drop = FALSE]
  if (isTRUE(reverse)) data <- data[nrow(data):1L, , drop = FALSE]
  rownames(data) <- NULL
  data
}

fit_joint_recession_fixture <- function(separated = TRUE, reverse = FALSE) {
  group_anchors <- data.frame(
    Facet = "Person",
    Level = c("P1", "P2"),
    Group = "calibration_group",
    GroupValue = 0,
    stringsAsFactors = FALSE
  )
  suppressWarnings(fit_mfrm(
    make_joint_recession_fixture(separated, reverse),
    person = "Person",
    facets = "Item",
    score = "Score",
    rating_min = 0,
    rating_max = 1,
    method = "JML",
    model = "RSM",
    group_anchors = group_anchors,
    maxit = 80
  ))
}

joint_recession_problem <- function(fit) {
  config <- fit$config
  sizes <- mfrmr:::build_param_sizes(config)
  idx <- mfrmr:::build_indices(
    fit$prep,
    step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs
  )
  params <- mfrmr:::expand_params(fit$opt$par, sizes, config)
  adjacent <- mfrmr:::mfrmr_estimability_adjacent_design(
    prep = fit$prep,
    idx = idx,
    config = config,
    sizes = sizes,
    include_person = TRUE,
    include_population_beta = FALSE
  )
  contrast <- mfrmr:::mfrmr_jml_observed_contrast_design(
    adjacent_design = adjacent$design,
    score_k = idx$score_k,
    n_obs = adjacent$observation_rows,
    n_steps = adjacent$transitions
  )
  target_system <- mfrmr:::mfrmr_jml_structural_target_system(
    config, sizes, params, include_person = TRUE
  )
  selected <- fit$config$boundary_audit$joint_additive$target_status$ParameterId
  target_index <- match(selected, target_system$metadata$ParameterId)
  list(
    config = config,
    sizes = sizes,
    idx = idx,
    params = params,
    map = adjacent$map,
    contrast = contrast,
    target_metadata = target_system$metadata[target_index, , drop = FALSE],
    target_expansion = target_system$expansion[target_index, , drop = FALSE]
  )
}

joint_grid_directions <- function(n_parameters) {
  stopifnot(n_parameters >= 1L, n_parameters <= 8L)
  grid <- expand.grid(
    rep(list(c(-1, 0, 1)), n_parameters),
    KEEP.OUT.ATTRS = FALSE
  )
  direction <- as.matrix(grid)
  direction[rowSums(abs(direction)) > 0, , drop = FALSE]
}

joint_grid_cone_oracle <- function(contrast, tolerance = 1e-10) {
  contrast <- as.matrix(contrast)
  direction <- joint_grid_directions(ncol(contrast))
  margins <- contrast %*% t(direction)
  any(
    apply(margins >= -tolerance, 2L, all) &
      apply(margins > tolerance, 2L, any)
  )
}

joint_grid_target_oracle <- function(contrast, target, tolerance = 1e-10) {
  contrast <- as.matrix(contrast)
  target <- as.numeric(target)
  direction <- joint_grid_directions(ncol(contrast))
  margins <- contrast %*% t(direction)
  feasible <- apply(margins >= -tolerance, 2L, all) &
    apply(margins > tolerance, 2L, any)
  target_change <- as.numeric(direction %*% target)
  c(
    positive = any(feasible & target_change > tolerance),
    negative = any(feasible & target_change < -tolerance)
  )
}

test_that("joint Person-structural recession closes the separated-audit gap", {
  skip_if_not_installed("lpSolve")
  fit <- fit_joint_recession_fixture(TRUE)
  person <- fit$config$boundary_audit
  structural <- person$structural_additive
  joint <- person$joint_additive

  expect_identical(person$readiness$BoundaryState, "not_evaluated")
  expect_identical(person$readiness$ConstraintCoupledExtremeN, 1L)
  expect_identical(structural$state, "none_certified")
  expect_identical(joint$state, "certified_recession")
  expect_true(isTRUE(joint$complete))
  expect_true(isTRUE(joint$cone_certificate$Certified))
  expect_gte(joint$cone_certificate$MinimumContrastMargin, -1e-7)
  expect_gt(joint$cone_certificate$StrictContrastRows, 0L)
  expect_identical(
    joint$prescreen$contract_version,
    "mfrmr-jml-global-cone-prescreen-v1"
  )
  expect_identical(
    joint$prescreen$state,
    "positive_cone_target_enumeration"
  )
  expect_true(isTRUE(joint$prescreen$evaluated))
  expect_true(isTRUE(joint$prescreen$cone_certified))
  expect_false(isTRUE(joint$prescreen$target_enumeration_skipped))
  expect_identical(
    joint$prescreen$target_directions_evaluated,
    joint$dimensions$TargetDirections
  )
  expect_gte(
    joint$prescreen$target_lp_calls,
    joint$prescreen$target_directions_evaluated
  )
  expect_identical(
    joint$prescreen$total_lp_calls,
    joint$prescreen$cone_lp_calls + joint$prescreen$target_lp_calls
  )

  targets <- joint$target_status
  expect_setequal(
    targets$ParameterId,
    c("Person:P2", "Facet:Item:I1", "Facet:Item:I2", "Step:shared:Step_1")
  )
  person_p2 <- targets[targets$ParameterId == "Person:P2", , drop = FALSE]
  expect_identical(person_p2$CandidateStatus, "unbounded_low")
  item <- targets[targets$ParameterClass == "facet", , drop = FALSE]
  item <- item[match(c("I1", "I2"), item$Level), , drop = FALSE]
  expect_identical(item$CandidateStatus, c("unbounded_high", "unbounded_low"))

  # Every certified selected direction requires both blocks in this fixture.
  loading_blocks <- ifelse(
    grepl("^Person:", joint$direction_loadings$Coordinate),
    "Person", "structural"
  )
  loading_groups <- split(
    loading_blocks,
    paste(
      joint$direction_loadings$ParameterId,
      joint$direction_loadings$RequestedDirection
    )
  )
  expect_true(all(vapply(
    loading_groups,
    function(blocks) setequal(unique(blocks), c("Person", "structural")),
    logical(1)
  )))

  problem <- joint_recession_problem(fit)
  person_columns <- problem$map$Block == "Person"
  expect_true(joint_grid_cone_oracle(problem$contrast))
  expect_false(joint_grid_cone_oracle(
    problem$contrast[, person_columns, drop = FALSE]
  ))
  expect_false(joint_grid_cone_oracle(
    problem$contrast[, !person_columns, drop = FALSE]
  ))
  oracle <- t(vapply(seq_len(nrow(problem$target_expansion)), function(i) {
    joint_grid_target_oracle(
      problem$contrast, problem$target_expansion[i, ]
    )
  }, numeric(2)))
  expect_identical(
    as.logical(oracle[, "positive"]), targets$PositiveRecession
  )
  expect_identical(
    as.logical(oracle[, "negative"]), targets$NegativeRecession
  )

  # WP4 remains separate: the joint candidate is not yet a public primary value.
  public_p2 <- fit$facets$person[fit$facets$person$Person == "P2", , drop = FALSE]
  expect_identical(public_p2$ParameterStatus, "weak_information")
  expect_true(is.finite(public_p2$Estimate))
})

test_that("joint sparse and dense certificates are row-order invariant", {
  skip_if_not_installed("lpSolve")
  fit <- fit_joint_recession_fixture(TRUE)
  problem <- joint_recession_problem(fit)
  sparse <- fit$config$boundary_audit$joint_additive
  dense <- mfrmr:::audit_mfrm_jml_joint_recession(
    prep = fit$prep,
    idx = problem$idx,
    config = problem$config,
    sizes = problem$sizes,
    params = problem$params,
    person_boundary_audit = fit$config$boundary_audit,
    lp_representation = "dense_reference"
  )
  reversed <- fit_joint_recession_fixture(TRUE, reverse = TRUE)$config$
    boundary_audit$joint_additive

  expect_identical(dense$state, sparse$state)
  expect_identical(
    dense$target_status$CandidateStatus,
    sparse$target_status$CandidateStatus
  )
  expect_equal(
    dense$cone_certificate$TargetCapacity,
    sparse$cone_certificate$TargetCapacity,
    tolerance = 1e-8
  )
  sparse_order <- order(
    sparse$certificates$ParameterId,
    sparse$certificates$RequestedDirection
  )
  reversed_order <- order(
    reversed$certificates$ParameterId,
    reversed$certificates$RequestedDirection
  )
  expect_identical(
    sparse$certificates$Certified[sparse_order],
    reversed$certificates$Certified[reversed_order]
  )
  expect_equal(
    sparse$certificates$TargetCapacity[sparse_order],
    reversed$certificates$TargetCapacity[reversed_order],
    tolerance = 1e-8
  )
})

test_that("global joint-cone screening stops cleanly when no ray exists", {
  skip_if_not_installed("lpSolve")
  fit <- fit_joint_recession_fixture(FALSE)
  joint <- fit$config$boundary_audit$joint_additive
  problem <- joint_recession_problem(fit)
  zero_target_budget <- mfrmr:::audit_mfrm_jml_joint_recession(
    prep = fit$prep,
    idx = problem$idx,
    config = problem$config,
    sizes = problem$sizes,
    params = problem$params,
    person_boundary_audit = fit$config$boundary_audit,
    max_target_directions = 0L
  )

  expect_identical(joint$state, "none_certified")
  expect_true(isTRUE(joint$complete))
  expect_false(isTRUE(joint$cone_certificate$Certified))
  expect_identical(nrow(joint$certificates), 0L)
  expect_identical(
    joint$prescreen$state,
    "negative_cone_enumeration_skipped"
  )
  expect_true(isTRUE(joint$prescreen$evaluated))
  expect_false(isTRUE(joint$prescreen$cone_certified))
  expect_true(isTRUE(joint$prescreen$target_enumeration_skipped))
  expect_gt(joint$prescreen$cone_lp_calls, 0L)
  expect_identical(joint$prescreen$target_directions_evaluated, 0L)
  expect_identical(joint$prescreen$target_lp_calls, 0L)
  expect_identical(
    joint$prescreen$total_lp_calls,
    joint$prescreen$cone_lp_calls
  )
  expect_true(all(
    joint$target_status$CandidateStatus %in%
      c("finite_in_audited_subspace", "fixed")
  ))
  expect_identical(zero_target_budget$state, "none_certified")
  expect_true(isTRUE(zero_target_budget$complete))
  expect_identical(nrow(zero_target_budget$certificates), 0L)
})

test_that("joint coordinate limits fail closed and MML is not reinterpreted", {
  skip_if_not_installed("lpSolve")
  fit <- fit_joint_recession_fixture(TRUE)
  problem <- joint_recession_problem(fit)
  limited <- mfrmr:::audit_mfrm_jml_joint_recession(
    prep = fit$prep,
    idx = problem$idx,
    config = problem$config,
    sizes = problem$sizes,
    params = problem$params,
    person_boundary_audit = fit$config$boundary_audit,
    max_person_coordinates = 0L
  )
  expect_identical(limited$state, "not_evaluated_size_limit")
  expect_false(isTRUE(limited$complete))
  expect_identical(nrow(limited$cone_certificate), 0L)
  expect_identical(limited$prescreen$state, "not_evaluated_size_limit")
  expect_identical(limited$prescreen$total_lp_calls, 0L)

  target_limited <- mfrmr:::audit_mfrm_jml_joint_recession(
    prep = fit$prep,
    idx = problem$idx,
    config = problem$config,
    sizes = problem$sizes,
    params = problem$params,
    person_boundary_audit = fit$config$boundary_audit,
    max_target_directions = 0L
  )
  expect_identical(target_limited$state, "certified_recession")
  expect_false(isTRUE(target_limited$complete))
  expect_true(isTRUE(target_limited$cone_certificate$Certified))
  expect_identical(
    target_limited$prescreen$state,
    "positive_cone_target_limit"
  )
  expect_gt(target_limited$prescreen$cone_lp_calls, 0L)
  expect_identical(target_limited$prescreen$target_lp_calls, 0L)
  expect_true(any(
    target_limited$target_status$CandidateStatus ==
      "not_evaluated_size_limit"
  ))
  expect_true(any(
    target_limited$target_status$ReasonCodes ==
      "bounded_target_direction_limit"
  ))

  mml <- mfrmr:::audit_mfrm_jml_joint_recession(
    prep = list(),
    idx = list(),
    config = list(method = "MML", model = "RSM"),
    sizes = list(),
    params = list(),
    person_boundary_audit = list()
  )
  expect_identical(mml$state, "not_applicable_mml")
  expect_true(isTRUE(mml$complete))
  expect_identical(mml$prescreen$state, "not_applicable_mml")
  expect_identical(mml$prescreen$total_lp_calls, 0L)
})
