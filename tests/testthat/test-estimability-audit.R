.estimability_balanced_data <- function() {
  data <- expand.grid(
    Person = paste0("P", sprintf("%02d", 1:8)),
    Rater = c("R1", "R2"),
    Criterion = c("C1", "C2"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  data$Score <- 1L + (
    as.integer(factor(data$Person)) +
      as.integer(factor(data$Rater)) +
      as.integer(factor(data$Criterion))
  ) %% 4L
  data
}

.estimability_zero_common_data <- function() {
  data <- expand.grid(
    Person = paste0("P", sprintf("%02d", 1:8)),
    Criterion = c("C1", "C2"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  person_index <- as.integer(sub("P", "", data$Person))
  data$Rater <- ifelse(person_index <= 4L, "R1", "R2")
  data$Score <- 1L + (
    as.integer(factor(data$Person)) +
      as.integer(factor(data$Criterion))
  ) %% 4L
  data
}

.estimability_fit <- function(data, method = "JML", ...) {
  fit_mfrm(
    data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    model = "RSM",
    method = method,
    quad_points = 5,
    maxit = 5,
    ...
  )
}

test_that("balanced JML constrained design is full rank and invariant", {
  data <- .estimability_balanced_data()
  fit <- suppressWarnings(.estimability_fit(data, "JML"))
  audit <- fit$data_review$estimability

  expect_identical(
    audit$contract_version,
    "mfrmr-internal-readiness-0.2.3-v1"
  )
  expect_identical(audit$readiness$EstimabilityState, "identified")
  expect_true(audit$readiness$Complete)
  expect_identical(audit$design$rank, audit$design$free_dimension)
  expect_identical(audit$design$nullity, 0L)
  expect_identical(
    audit$readiness$AuditedFreeDimension,
    audit$readiness$OptimizerFreeDimension
  )
  expect_true(all(c("Person", "Rater", "Criterion", "steps") %in%
                    audit$parameter_blocks$Block))

  permuted <- data[c(seq(2L, nrow(data), by = 2L),
                     seq(1L, nrow(data), by = 2L)), , drop = FALSE]
  relabelled <- data
  relabelled$Person <- paste0("Candidate_", match(
    relabelled$Person, rev(unique(relabelled$Person))
  ))
  relabelled$Rater <- ifelse(relabelled$Rater == "R1", "Judge_B", "Judge_A")
  relabelled$Criterion <- ifelse(
    relabelled$Criterion == "C1", "Scale_Y", "Scale_X"
  )

  permuted_audit <- suppressWarnings(
    .estimability_fit(permuted, "JML")
  )$data_review$estimability
  relabelled_audit <- suppressWarnings(
    .estimability_fit(relabelled, "JML")
  )$data_review$estimability

  expect_identical(permuted_audit$readiness$EstimabilityState, "identified")
  expect_identical(relabelled_audit$readiness$EstimabilityState, "identified")
  expect_identical(permuted_audit$design$rank, audit$design$rank)
  expect_identical(relabelled_audit$design$rank, audit$design$rank)
  expect_identical(permuted_audit$design$nullity, audit$design$nullity)
  expect_identical(relabelled_audit$design$nullity, audit$design$nullity)
})

test_that("QR tolerance sensitivity is diagnostic until a weak-information rule is frozen", {
  design <- Matrix::sparseMatrix(
    i = c(1L, 1L, 2L),
    j = c(1L, 2L, 2L),
    x = c(1, 1, 1e-9),
    dims = c(2L, 2L)
  )
  map <- mfrmr:::mfrmr_estimability_map(
    Block = c("facet", "facet"),
    Coordinate = c("facet:a", "facet:b"),
    Facet = c("facet", "facet"),
    Level = c("a", "b"),
    ReferenceLevel = c("", ""),
    Constraint = c("test", "test"),
    OptimizerIndex = c(1L, 2L)
  )
  result <- mfrmr:::mfrmr_estimability_rank_audit(design, map)

  expect_identical(result$State, "identified")
  expect_true(result$ToleranceSensitive)
  expect_gt(length(unique(result$ToleranceRanks$Rank)), 1L)
})

test_that("sparse constraint Jacobian matches the optimizer expansion", {
  build <- mfrmr:::build_facet_constraint
  cases <- list(
    build(
      levels = c("A", "B", "C", "D"),
      centered = TRUE
    ),
    build(
      levels = c("A", "B", "C", "D"),
      anchors = c(A = 0),
      centered = TRUE
    ),
    build(
      levels = c("A", "B", "C", "D"),
      groups = c(A = "G1", B = "G1", C = "G2", D = "G2"),
      group_values = c(G1 = 0, G2 = 0.5),
      centered = TRUE
    ),
    build(
      levels = c("A", "B", "C", "D"),
      anchors = c(A = -0.2),
      centered = FALSE
    )
  )

  for (spec in cases) {
    sparse <- mfrmr:::mfrmr_constraint_jacobian_sparse(spec, "Facet")
    dense <- mfrmr:::constraint_jacobian(spec)
    expect_equal(unname(as.matrix(sparse$jacobian)), unname(dense),
                 tolerance = 0)
    expect_equal(ncol(sparse$jacobian), spec$n_params)
    expect_equal(nrow(sparse$map), spec$n_params)
  }
})

test_that("PCM step coordinates enter the constrained rank audit", {
  data <- .estimability_balanced_data()
  fit <- suppressWarnings(fit_mfrm(
    data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    model = "PCM",
    method = "JML",
    step_facet = "Criterion",
    maxit = 5
  ))
  audit <- fit$data_review$estimability
  step_block <- audit$parameter_blocks[
    audit$parameter_blocks$Block == "steps", , drop = FALSE
  ]
  expect_identical(audit$readiness$EstimabilityState, "identified")
  expect_identical(step_block$FreeCoordinates, 4L)
  expect_true(all(grepl(
    "^steps:",
    audit$parameter_map$Coordinate[audit$parameter_map$Block == "steps"]
  )))
})

test_that("zero-common-Person panels distinguish JML alias from MML linkage", {
  data <- .estimability_zero_common_data()

  condition <- tryCatch(
    suppressWarnings(.estimability_fit(data, "JML")),
    error = identity
  )
  expect_s3_class(condition, "mfrmr_estimability_error")
  expect_s3_class(condition, "mfrmr_readiness_condition")
  expect_identical(
    condition$readiness$EstimabilityState,
    "structurally_unidentified"
  )
  expect_identical(condition$estimability$design$nullity, 1L)
  expect_match(condition$readiness$ReasonCodes, "design_rank_deficient",
               fixed = TRUE)
  expect_match(conditionMessage(condition), "Optimization was not run",
               fixed = TRUE)
  expect_false(grepl("P01|P05", conditionMessage(condition)))

  mml <- NULL
  expect_warning(
    mml <- .estimability_fit(data, "MML"),
    class = "mfrmr_estimability_warning"
  )
  audit <- mml$data_review$estimability
  expect_identical(
    audit$readiness$EstimabilityState,
    "population_assumption_linked"
  )
  expect_true(audit$readiness$PopulationAssumptionLinked)
  expect_identical(audit$counterfactual_jml$State,
                   "structurally_unidentified")
  expect_identical(
    mml$data_review$status$Status[
      mml$data_review$status$Domain == "Design"
    ],
    "review_population_assumption_linked"
  )
})

test_that("a defensible anchor removes the zero-common-Person JML alias", {
  data <- .estimability_zero_common_data()
  anchors <- data.frame(
    Facet = "Rater",
    Level = "R1",
    Anchor = 0,
    stringsAsFactors = FALSE
  )

  fit <- suppressWarnings(.estimability_fit(
    data,
    method = "JML",
    anchors = anchors
  ))
  audit <- fit$data_review$estimability
  expect_identical(audit$readiness$EstimabilityState, "identified")
  expect_identical(audit$design$nullity, 0L)
  expect_identical(audit$design$rank, audit$design$free_dimension)
  expect_equal(
    unname(fit$config$anchor_summary$AnchoredLevels[
      fit$config$anchor_summary$Facet == "Rater"
    ]),
    1L
  )

  alternative <- data.frame(
    Facet = "Rater",
    Level = "R2",
    Anchor = 0,
    stringsAsFactors = FALSE
  )
  alternative_fit <- suppressWarnings(.estimability_fit(
    data,
    method = "JML",
    anchors = alternative
  ))
  alternative_audit <- alternative_fit$data_review$estimability
  expect_identical(alternative_audit$readiness$EstimabilityState,
                   "identified")
  expect_identical(alternative_audit$design$rank, audit$design$rank)
  expect_identical(alternative_audit$design$nullity, audit$design$nullity)
})

test_that("an unsupported interaction direction is blocked before optimization", {
  data <- .estimability_balanced_data()
  data <- data[!(data$Rater == "R2" & data$Criterion == "C2"), , drop = FALSE]

  condition <- tryCatch(
    suppressWarnings(.estimability_fit(
      data,
      method = "JML",
      facet_interactions = "Rater:Criterion"
    )),
    error = identity
  )
  expect_s3_class(condition, "mfrmr_estimability_error")
  expect_identical(condition$estimability$design$nullity, 1L)
  expect_true("interactions" %in% condition$estimability$null_blocks$Block)
  expect_identical(condition$readiness$EstimabilityState,
                   "structurally_unidentified")
})

test_that("GPCM additive rank does not overclaim nonlinear completeness", {
  data <- .estimability_balanced_data()
  fit <- suppressWarnings(fit_mfrm(
    data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    model = "GPCM",
    method = "MML",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    quad_points = 5,
    maxit = 5
  ))
  audit <- fit$data_review$estimability
  expect_identical(audit$design$state, "identified")
  expect_false(audit$readiness$Complete)
  expect_true("log_slopes" %in% audit$nonlinear_blocks)
  expect_match(audit$readiness$ReasonCodes, "design_rank_not_evaluated",
               fixed = TRUE)
})
