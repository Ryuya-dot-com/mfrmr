gtheory_ademp_generator_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-balanced-estimation-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-ademp-registry-prototype-0.2.3.R",
      "gtheory-ademp-generator-prototype-0.2.3.R"
    )
  )
}

load_gtheory_ademp_generator <- function() {
  paths <- gtheory_ademp_generator_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  if (!requireNamespace("reformulas", quietly = TRUE) &&
      !requireNamespace("lme4", quietly = TRUE)) {
    skip("Draft.81 formula parser requires reformulas or lme4")
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtd2_generation <- function(env, scenario_id, replicate = 1L) {
  env$mfrmr_gtd2_generate(
    env$mfrmr_gtd_registry(), scenario_id, replicate = replicate
  )
}

gtd2_omission_contrast <- function(generation, value) {
  omitted <- is.na(generation$AnalysisData$Score)
  c(
    Omitted = mean(value[omitted]),
    Retained = mean(value[!omitted])
  )
}

gtd2_residual_lag_correlation <- function(generation) {
  residual <- generation$GeneratedEffects$Residual$Effect
  person <- generation$FullPotentialData$Person
  sequences <- split(residual, person)
  left <- unlist(lapply(sequences, function(x) x[-length(x)]),
                 use.names = FALSE)
  right <- unlist(lapply(sequences, function(x) x[-1L]),
                  use.names = FALSE)
  stats::cor(left, right)
}

test_that("Draft.83d2a generates all executable registered scenarios", {
  env <- load_gtheory_ademp_generator()
  registry <- env$mfrmr_gtd_registry()
  smoke <- env$mfrmr_gtd2_generate_registry_smoke(registry)

  expect_equal(nrow(smoke$Summary), 24L)
  expect_equal(smoke$GeneratedScenarios, 22L)
  expect_equal(smoke$BlockedScenarios, 2L)
  expect_identical(smoke$Summary$ScenarioId, registry$Scenarios$ScenarioId)
  expect_true(all(
    smoke$Summary$GenerationState[seq_len(22L)] == "generated_not_fitted"
  ))
  expect_true(all(
    smoke$Summary$GenerationState[23:24] ==
      "blocked_not_current_gstudy_operation"
  ))
  expect_match(smoke$GeneratorSmokeHash, "^[0-9a-f]{64}$")
  expect_identical(
    smoke$GeneratorSmokeHash,
    "1ed0856cc91ceb36115806dcf0f135ef7491d9e1ef53106276c0fd81584e0844"
  )
  expect_false(smoke$EstimationReady)
  expect_false(smoke$DecisionReady)
})

test_that("Draft.83d2a realizes the registered assignment exactly", {
  env <- load_gtheory_ademp_generator()
  registry <- env$mfrmr_gtd_registry()
  smoke <- env$mfrmr_gtd2_generate_registry_smoke(registry)
  generated <- smoke$Results[seq_len(22L)]

  for (generation in generated) {
    scenario <- generation$Scenario
    audit <- generation$AssignmentAudit
    expect_equal(
      audit$RealizedAssignmentDensity,
      scenario$AssignmentDensity[[1L]],
      tolerance = 1e-14
    )
    expect_equal(
      audit$MinimumObservationsPerPerson,
      scenario$ObservationsPerPerson[[1L]]
    )
    expect_equal(
      audit$MaximumObservationsPerPerson,
      scenario$ObservationsPerPerson[[1L]]
    )
    expect_equal(audit$ZeroLoadRaters, 0L)
    expect_false(anyNA(generation$AssignedData$Score))
  }
})

test_that("Draft.83d2a restores RNG state and replays exact identities", {
  env <- load_gtheory_ademp_generator()
  set.seed(830201)
  before <- .Random.seed
  first <- gtd2_generation(env, "GT-IMBAL-HUB-HIGH")
  after_first <- .Random.seed
  second <- gtd2_generation(env, "GT-IMBAL-HUB-HIGH")
  third <- gtd2_generation(env, "GT-IMBAL-HUB-HIGH", replicate = 2L)

  expect_identical(after_first, before)
  expect_identical(.Random.seed, before)
  expect_identical(first$GeneratorHash, second$GeneratorHash)
  expect_identical(first$FullPotentialData, second$FullPotentialData)
  expect_identical(first$AssignedData, second$AssignedData)
  expect_false(identical(first$GeneratorHash, third$GeneratorHash))
  expect_false(identical(first$AssignedData, third$AssignedData))
  expect_length(first$GeneratorIdentity$FunctionHashes, 11L)
  expect_true(all(grepl(
    "^[0-9a-f]{64}$", first$GeneratorIdentity$FunctionHashes
  )))
  expect_match(first$GeneratorHash, "^[0-9a-f]{64}$")
})

test_that("Draft.83d2a separates sparsity from workload imbalance", {
  env <- load_gtheory_ademp_generator()
  low <- gtd2_generation(env, "GT-SPARSE-CYCLE-LOW")
  mid <- gtd2_generation(env, "GT-SPARSE-CYCLE-MID")
  moderate <- gtd2_generation(env, "GT-IMBAL-HUB-MOD")
  high <- gtd2_generation(env, "GT-IMBAL-HUB-HIGH")

  expect_equal(low$AssignmentAudit$RealizedAssignmentDensity, 0.125)
  expect_equal(mid$AssignmentAudit$RealizedAssignmentDensity, 0.5)
  expect_equal(moderate$AssignmentAudit$RealizedAssignmentDensity, 0.25)
  expect_equal(high$AssignmentAudit$RealizedAssignmentDensity, 0.25)
  expect_lt(low$AssignmentAudit$RaterLoadCV, 0.05)
  expect_equal(mid$AssignmentAudit$RaterLoadCV, 0)
  expect_gt(moderate$AssignmentAudit$RaterLoadCV, 0)
  expect_gt(
    high$AssignmentAudit$RaterLoadCV,
    moderate$AssignmentAudit$RaterLoadCV
  )
})

test_that("Draft.83d2a freezes bounded support and projection truth", {
  env <- load_gtheory_ademp_generator()
  ids <- c(
    "GT-BOUNDED-K03-ENDHI", "GT-BOUNDED-K05-ENDMOD",
    "GT-BOUNDED-K07-ENDNONE"
  )
  generated <- lapply(ids, gtd2_generation, env = env)
  endpoint <- vapply(generated, function(x) x$ScoreAudit$EndpointRate,
                     numeric(1L))
  observed <- vapply(
    generated, function(x) x$ScoreAudit$ObservedCategoryCount, integer(1L)
  )
  declared <- vapply(
    generated, function(x) x$ScoreAudit$DeclaredCategories, integer(1L)
  )

  expect_equal(endpoint, c(0.50, 0.25, 0))
  expect_equal(observed, c(3L, 5L, 5L))
  expect_equal(declared, c(3L, 5L, 7L))
  expect_true(all(vapply(
    generated, function(x) length(x$ProjectionTruth) == 7L, logical(1L)
  )))
  expect_true(all(vapply(
    generated, function(x) all(is.finite(x$ProjectionTruth)), logical(1L)
  )))
  expect_true(all(vapply(generated, function(x) {
    !isTRUE(all.equal(x$ProjectionTruth, x$NominalTruth))
  }, logical(1L))))
  expect_true(all(vapply(generated, function(x) {
    identical(
      x$Scenario$TargetBasis[[1L]],
      "full_potential_observed_score_projection"
    )
  }, logical(1L))))
})

test_that("Draft.83d2a realizes typed missingness at the exact rate", {
  env <- load_gtheory_ademp_generator()
  ids <- c("GT-MISS-MCAR", "GT-MISS-MAR", "GT-MISS-MNAR",
           "GT-MISS-UNKNOWN")
  generated <- stats::setNames(lapply(ids, gtd2_generation, env = env), ids)

  expect_equal(unname(vapply(
    generated, function(x) x$MissingnessAudit$RealizedMissingRate,
    numeric(1L)
  )), rep(0.20, 4L))
  expect_equal(unname(vapply(
    generated, function(x) x$MissingnessAudit$RetainedRows, integer(1L)
  )), c(1280L, 640L, 640L, 640L))
  expect_identical(
    unname(vapply(
      generated, function(x) x$MissingnessAudit$Mechanism, character(1L)
    )),
    c("MCAR", "MAR_rater_load", "MNAR_score", "unknown")
  )
  expect_true(all(vapply(
    generated, function(x) !anyNA(x$AssignedData$Score), logical(1L)
  )))
  expect_true(all(vapply(
    generated, function(x) anyNA(x$AnalysisData$Score), logical(1L)
  )))

  mcar_load <- table(generated[["GT-MISS-MCAR"]]$AssignedData$Rater)
  mcar_load <- as.numeric(mcar_load[
    as.character(generated[["GT-MISS-MCAR"]]$AssignedData$Rater)
  ])
  mar_load <- table(generated[["GT-MISS-MAR"]]$AssignedData$Rater)
  mar_load <- as.numeric(mar_load[
    as.character(generated[["GT-MISS-MAR"]]$AssignedData$Rater)
  ])
  expect_equal(unname(diff(gtd2_omission_contrast(
    generated[["GT-MISS-MCAR"]], mcar_load
  ))), 0)
  expect_lt(diff(gtd2_omission_contrast(
    generated[["GT-MISS-MAR"]], mar_load
  )), 0)
  expect_lt(diff(gtd2_omission_contrast(
    generated[["GT-MISS-MNAR"]],
    generated[["GT-MISS-MNAR"]]$AssignedData$Score
  )), 0)
})

test_that("Draft.83d2a realizes the registered residual dependence", {
  env <- load_gtheory_ademp_generator()
  low <- gtd2_generation(env, "GT-LD-RHO025")
  high <- gtd2_generation(env, "GT-LD-RHO050")
  low_correlation <- gtd2_residual_lag_correlation(low)
  high_correlation <- gtd2_residual_lag_correlation(high)

  expect_equal(low_correlation, 0.25, tolerance = 0.04)
  expect_equal(high_correlation, 0.50, tolerance = 0.04)
  expect_gt(high_correlation, low_correlation)
  expect_identical(
    low$Scenario$TargetBasis[[1L]],
    "independence_model_reference_not_component_truth"
  )
  expect_false(low$EstimationReady)
  expect_false(high$DecisionReady)
})

test_that("Draft.83d2a preserves exact and near-zero boundary truth", {
  env <- load_gtheory_ademp_generator()
  near <- gtd2_generation(env, "GT-BOUNDARY-NEARZERO")
  zero <- gtd2_generation(env, "GT-BOUNDARY-ZERO")

  expect_equal(near$NominalTruth[["Rater"]], 1e-10)
  expect_equal(zero$NominalTruth[["Rater"]], 0)
  expect_gt(stats::sd(near$GeneratedEffects$Rater$Effect), 0)
  expect_lt(stats::sd(near$GeneratedEffects$Rater$Effect), 1e-3)
  expect_true(all(zero$GeneratedEffects$Rater$Effect == 0))
  expect_identical(
    near$Scenario$ExpectedDesignState[[1L]], "must_fail_ready_gate"
  )
  expect_identical(
    zero$Scenario$ExpectedDesignState[[1L]], "must_fail_ready_gate"
  )
  expect_false(near$CoefficientEligible)
  expect_false(zero$DecisionReady)
})

test_that("Draft.83d2a negative controls fail the observed-design screen", {
  env <- load_gtheory_ademp_generator()
  nested <- gtd2_generation(env, "GT-NESTED-BAL")
  disconnected <- gtd2_generation(env, "GT-NEG-DISCONNECTED")
  aliased <- gtd2_generation(env, "GT-NEG-ALIASED")
  nested_audit <- env$mfrmr_gti_audit(
    nested$Spec, nested$AssignedData, missingness = "complete"
  )
  disconnected_audit <- env$mfrmr_gti_audit(
    disconnected$Spec, disconnected$AssignedData, missingness = "complete"
  )
  aliased_audit <- env$mfrmr_gti_audit(
    aliased$Spec, aliased$AssignedData, missingness = "complete"
  )

  expect_true(nested_audit$IncidenceScreenPassed)
  expect_false(disconnected_audit$IncidenceScreenPassed)
  expect_true(any(grepl(
    "non_nested_object_facet_disconnected:Rater",
    disconnected_audit$Issues, fixed = TRUE
  )))
  expect_false(aliased_audit$IncidenceScreenPassed)
  expect_true("highest_order_residual_not_separable" %in%
                aliased_audit$Issues)
  expect_false(disconnected$EstimationReady)
  expect_false(aliased$DecisionReady)
})

test_that("Draft.83d2a blocks anchors and rejects malformed requests", {
  env <- load_gtheory_ademp_generator()
  registry <- env$mfrmr_gtd_registry()
  anchor <- env$mfrmr_gtd2_generate(registry, "GT-ANCHOR-025")

  expect_s3_class(anchor, "mfrmr_gtd2_generation")
  expect_identical(
    anchor$GenerationState, "blocked_not_current_gstudy_operation"
  )
  expect_identical(
    anchor$BlockingReason, "blocked_anchor_not_gstudy_operation"
  )
  expect_null(anchor$FullPotentialData)
  expect_false(anchor$GenerationEvidenceReady)
  expect_false(anchor$EstimationReady)
  expect_false(anchor$DecisionReady)
  expect_error(
    env$mfrmr_gtd2_generate(registry, "not-registered"),
    "not present in the frozen registry"
  )
  expect_error(
    env$mfrmr_gtd2_generate(registry, "GT-EXACT-N030", replicate = 0L),
    "positive integer"
  )
  expect_error(
    env$mfrmr_gtd2_generate(registry, "GT-EXACT-N030", replicate = 1.5),
    "positive integer"
  )
})
