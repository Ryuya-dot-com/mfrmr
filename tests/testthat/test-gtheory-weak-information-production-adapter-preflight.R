gtheory_production_adapter_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  file.path(validation, c(
    "gtheory-design-algebra-prototype-0.2.3.R",
    "gtheory-balanced-estimation-prototype-0.2.3.R",
    "gtheory-design-incidence-audit-0.2.3.R",
    "gtheory-covariance-information-audit-0.2.3.R",
    "gtheory-glmmtmb-parity-prototype-0.2.3.R",
    "gtheory-ademp-registry-prototype-0.2.3.R",
    "gtheory-ademp-generator-prototype-0.2.3.R",
    "gtheory-ademp-prefit-prototype-0.2.3.R",
    "gtheory-ademp-fit-prototype-0.2.3.R",
    "gtheory-weak-information-calibration-prototype-0.2.3.R",
    "gtheory-weak-information-pilot-prototype-0.2.3.R",
    "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R",
    "gtheory-weak-information-bootstrap-prototype-0.2.3.R",
    "gtheory-weak-information-feasibility-prototype-0.2.3.R",
    "gtheory-weak-information-feasibility-runner-0.2.3.R",
    "gtheory-weak-information-numerical-sensitivity-0.2.3.R",
    "gtheory-weak-information-typed-replay-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stabilization-prototype-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stabilization-runner-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stationarity-instrumentation-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stationarity-calibration-design-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stationarity-reference-calibration-0.2.3.R",
    "gtheory-weak-information-stationarity-calibration-authorization-audit-0.2.3.R",
    "gtheory-weak-information-glmmtmb-ml-reference-coverage-0.2.3.R",
    "gtheory-weak-information-lme4-objective-reference-preflight-0.2.3.R",
    "gtheory-weak-information-lme4-reference-coverage-0.2.3.R",
    "gtheory-weak-information-stationarity-acceptance-policy-0.2.3.R",
    "gtheory-weak-information-production-boundary-probe-0.2.3.R",
    "gtheory-weak-information-stationarity-exact-resume-runner-0.2.3.R",
    "gtheory-weak-information-production-adapter-preflight-0.2.3.R"
  ))
}

load_gtheory_production_adapter <- function() {
  paths <- gtheory_production_adapter_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c(
    "digest", "lme4", "Matrix", "glmmTMB", "TMB", "minqa", "nloptr",
    "numDeriv", "withr"
  )) skip_if_not_installed(package)
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_production_adapter_objects <- function(env) {
  plan <- env$mfrmr_gtwp_plan()
  design <- env$mfrmr_gtwsz_contract(plan)
  design_manifest <- env$mfrmr_gtwsz_manifest(design, plan)
  glmm_reference <- env$mfrmr_gtwta_contract(design)
  glmm_reference_manifest <- env$mfrmr_gtwta_manifest(glmm_reference)
  authorization <- env$mfrmr_gtwaa_contract(
    design, design_manifest, glmm_reference, glmm_reference_manifest
  )
  sealed <- env$mfrmr_gtwaa_manifest(authorization, design_manifest)
  ml_coverage <- env$mfrmr_gtwab_contract(authorization, glmm_reference)
  objective_preflight <- env$mfrmr_gtwac_contract(ml_coverage)
  lme4_reference <- env$mfrmr_gtwad_contract(objective_preflight)
  acceptance <- env$mfrmr_gtwae_contract(lme4_reference)
  boundary <- env$mfrmr_gtwaf_contract(acceptance)
  runner <- env$mfrmr_gtwag_contract(boundary, authorization, sealed)
  contract <- env$mfrmr_gtwah_contract(
    runner, boundary, glmm_reference, lme4_reference
  )
  reserved <- env$mfrmr_gtwah_reserved_manifest(contract, sealed)
  dry <- env$mfrmr_gtwah_dry_manifest(contract)
  list(
    Design = design, Authorization = authorization, Sealed = sealed,
    Boundary = boundary, Runner = runner, Contract = contract,
    Reserved = reserved, Dry = dry
  )
}

gtheory_production_adapter_cache <- new.env(parent = emptyenv())

gtheory_production_adapter_context <- function() {
  if (!is.null(gtheory_production_adapter_cache$context)) {
    return(gtheory_production_adapter_cache$context)
  }
  context <- list(
    Env = load_gtheory_production_adapter()
  )
  context$Objects <- gtheory_production_adapter_objects(context$Env)
  gtheory_production_adapter_cache$context <- context
  context
}

gtheory_production_adapter_execution <- function() {
  mfrmr_skip_if_not_gtheory_slow()
  if (!is.null(gtheory_production_adapter_cache$result)) {
    return(gtheory_production_adapter_cache$result)
  }
  context <- gtheory_production_adapter_context()
  env <- context$Env
  objects <- context$Objects
  root <- tempfile("mfrmr-gtwah-dry-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  execution <- env$mfrmr_gtwag_execute(
    objects$Contract, objects$Dry, root,
    candidate_evaluator = env$mfrmr_gtwah_candidate_evaluator,
    reference_evaluator = env$mfrmr_gtwah_reference_evaluator
  )
  reuse <- env$mfrmr_gtwag_execute(
    objects$Contract, objects$Dry, root,
    candidate_evaluator = env$mfrmr_gtwah_candidate_evaluator,
    reference_evaluator = env$mfrmr_gtwah_reference_evaluator
  )
  preflight <- env$mfrmr_gtwah_preflight(
    objects$Contract, objects$Reserved, execution
  )
  result <- list(
    Env = env, Objects = objects, Execution = execution,
    Reuse = reuse, Preflight = preflight
  )
  gtheory_production_adapter_cache$result <- result
  result
}

test_that("b1g14 freezes production adapter and runtime identities", {
  context <- gtheory_production_adapter_context()
  env <- context$Env
  objects <- context$Objects
  contract <- objects$Contract

  expect_s3_class(contract, "mfrmr_gtwah_contract")
  expect_s3_class(contract, "mfrmr_gtwag_contract")
  expect_identical(
    contract$UpstreamB1g13ContractHash,
    "8fb599cd4abbabb454ce416fe3470d3e0f8d23f0bc8f2662630083fb1ec388da"
  )
  expect_true(env$mfrmr_gtwah_policy_hash_valid(contract$AdapterPolicy))
  expect_identical(length(contract$AdapterHashes), 2L)
  expect_identical(length(contract$AdapterDependencyHashes), 15L)
  expect_true(all(nchar(contract$AdapterHashes) == 64L))
  expect_true(all(nchar(contract$AdapterDependencyHashes) == 64L))
  expect_true(nchar(contract$Runtime$RuntimeHash) == 64L)
  expect_true(contract$ProductionEvaluatorAdaptersFrozen)
  expect_true(contract$AdapterRuntimeIdentityFrozen)
  expect_true(contract$AdapterDependencyGraphFrozen)
  expect_false(contract$ReservedRunManifestFrozen)
  expect_false(contract$ProductionAdapterPreflightReady)
  expect_false(contract$CalibrationAuthorizationReady)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$CalibrationDataGenerated)
  expect_false(contract$CalibrationResultsViewed)
  expect_false(contract$StationarityThresholdFrozen)
  expect_false(contract$StationarityCriterionReady)
  expect_false(contract$ConfirmationAuthorized)
  expect_false(contract$InferenceReady)
  expect_false(contract$CoefficientEligible)
  expect_false(contract$DecisionReady)
  expect_identical(length(env$mfrmr_gtwah_function_hashes()), 23L)
})

test_that("b1g14 reserved manifest freezes exact shards but no execution", {
  context <- gtheory_production_adapter_context()
  env <- context$Env
  objects <- context$Objects
  manifest <- objects$Reserved

  expect_true(env$mfrmr_gtwah_reserved_manifest_hash_valid(manifest))
  expect_identical(manifest$DatasetCount, 3000L)
  expect_identical(manifest$AtomicUnitCount, 12000L)
  expect_identical(manifest$CandidateFitRowCount, 108000L)
  expect_identical(manifest$CandidateDecisionRowCount, 576000L)
  expect_identical(manifest$ReferenceRowCount, 24000L)
  expect_identical(manifest$ShardCount, 100L)
  expect_identical(manifest$Shards$Replicate, 201:300)
  expect_true(all(manifest$Shards$AtomicUnitCount == 120L))
  expect_true(all(manifest$Shards$CandidateFitRowCount == 1080L))
  expect_true(all(manifest$Shards$CandidateDecisionRowCount == 5760L))
  expect_true(all(manifest$Shards$ReferenceRowCount == 240L))
  expect_true(all(nchar(manifest$Shards$ShardIdentityHash) == 64L))
  expect_true(manifest$ReservedRunManifestFrozen)
  expect_false(manifest$ExecutionAuthorized)
  expect_false(manifest$CalibrationExecutionAuthorized)
  expect_false(manifest$CalibrationDataGenerated)
  expect_false(manifest$CalibrationResultsViewed)
  expect_false(grepl("^/", manifest$OutputRoot))
  expect_false(grepl("..", manifest$OutputRoot, fixed = TRUE))
})

test_that("b1g14 dry manifest is one nonreserved dataset across four lanes", {
  context <- gtheory_production_adapter_context()
  env <- context$Env
  objects <- context$Objects
  manifest <- objects$Dry

  expect_true(env$mfrmr_gtwag_manifest_hash_valid(manifest))
  expect_identical(manifest$AtomicUnitCount, 4L)
  expect_identical(manifest$DatasetCount, 1L)
  expect_identical(manifest$CandidateFitRowCount, 36L)
  expect_identical(manifest$CandidateDecisionRowCount, 192L)
  expect_identical(manifest$ReferenceRowCount, 8L)
  expect_identical(manifest$Replicates, 902L)
  expect_setequal(
    manifest$Units$MethodId,
    c("glmmTMB_ml", "glmmTMB_reml", "lme4_ml", "lme4_reml")
  )
  expect_true(all(manifest$Units$ProductionAdapterDryRun))
  expect_true(all(!manifest$Units$CalibrationUse))
  expect_true(manifest$ExecutionAuthorized)
  expect_false(manifest$CalibrationExecutionAuthorized)
  expect_false(any(manifest$Units$Replicate %in% c(201:300, 501:700)))
  expect_identical(
    manifest$CandidateEvaluatorHash,
    objects$Contract$AdapterHashes[["CandidateEvaluator"]]
  )
  expect_identical(
    manifest$ReferenceEvaluatorHash,
    objects$Contract$AdapterHashes[["ReferenceEvaluator"]]
  )
})

test_that("b1g14 adapters reject reserved or inconsistent direct calls", {
  context <- gtheory_production_adapter_context()
  env <- context$Env
  objects <- context$Objects
  unit <- objects$Dry$Units[1L, , drop = FALSE]
  reserved <- unit
  reserved$Replicate <- 201L
  reserved$DatasetId <- sprintf("%s/R0201", reserved$ScenarioId)
  reserved$AtomicUnitId <- paste(
    reserved$DatasetId, reserved$MethodId, sep = "::"
  )
  inconsistent <- unit
  inconsistent$Backend <- "lme4"

  expect_error(
    env$mfrmr_gtwah_prepare_unit(objects$Contract, reserved),
    "not authorized"
  )
  expect_error(
    env$mfrmr_gtwah_candidate_evaluator(objects$Contract, reserved),
    "not authorized"
  )
  expect_error(
    env$mfrmr_gtwah_reference_evaluator(objects$Contract, reserved),
    "not authorized"
  )
  expect_error(
    env$mfrmr_gtwah_prepare_unit(objects$Contract, inconsistent),
    "inconsistent"
  )
})

test_that("b1g14 real adapters complete all four nonreserved atomic units", {
  result <- gtheory_production_adapter_execution()
  execution <- result$Execution
  reuse <- result$Reuse

  expect_true(execution$Complete)
  expect_true(execution$ExactAccountingPassed)
  expect_identical(nrow(execution$CandidateFits), 36L)
  expect_identical(nrow(execution$CandidateDecisions), 192L)
  expect_identical(nrow(execution$References), 8L)
  expect_identical(execution$CandidateFitFailureCount, 1L)
  expect_identical(execution$ReferenceUnresolvedCount, 0L)
  expect_identical(sum(execution$CandidateFits$FitReturned), 35L)
  expect_identical(
    execution$CandidateFits$FailureStage[
      !execution$CandidateFits$FitReturned
    ], "start_snapshot"
  )
  expect_true(all(execution$References$ReferenceState %in% c(
    "finite_local_minimum", "finite_box_local_minimum"
  )))
  expect_true(all(execution$References$FailureStage == "none"))
  expect_true(all(!execution$CandidateDecisions$GeneratingTruthUsed))
  expect_true(all(!execution$CandidateDecisions$MetricUsedToSelectProfile))
  expect_setequal(
    unique(execution$CandidateFits$MethodId),
    c("glmmTMB_ml", "glmmTMB_reml", "lme4_ml", "lme4_reml")
  )
  candidate_hash <- tapply(
    execution$CandidateFits$GeneratorHash,
    execution$CandidateFits$AtomicUnitId, unique
  )
  reference_hash <- tapply(
    execution$References$GeneratorHash,
    execution$References$AtomicUnitId, unique
  )
  expect_identical(
    unname(candidate_hash[sort(names(candidate_hash))]),
    unname(reference_hash[sort(names(reference_hash))])
  )
  candidate_prefit <- tapply(
    execution$CandidateFits$PreFitHash,
    execution$CandidateFits$AtomicUnitId, unique
  )
  reference_prefit <- tapply(
    execution$References$PreFitHash,
    execution$References$AtomicUnitId, unique
  )
  expect_identical(
    unname(candidate_prefit[sort(names(candidate_prefit))]),
    unname(reference_prefit[sort(names(reference_prefit))])
  )
  expect_identical(reuse$ReusedUnitCount, 4L)
  expect_identical(reuse$ComputedUnitCount, 0L)
  expect_identical(reuse$ExecutionHash, execution$ExecutionHash)
  expect_false(execution$CalibrationEvidenceReady)
  expect_false(execution$CalibrationExecutionAuthorized)
  expect_false(execution$StationarityThresholdFrozen)
  expect_false(execution$ConfirmationAuthorized)
  expect_false(execution$InferenceReady)
  expect_false(execution$DecisionReady)
})

test_that("b1g14 manifests reject adapter shard and runtime mutation", {
  context <- gtheory_production_adapter_context()
  env <- context$Env
  objects <- context$Objects
  reserved <- objects$Reserved
  reserved$Shards$AtomicUnitCount[[1L]] <- 119L
  dry <- objects$Dry
  dry$CandidateEvaluatorHash <- paste0(
    "x", substring(dry$CandidateEvaluatorHash, 2L)
  )

  expect_false(env$mfrmr_gtwah_reserved_manifest_hash_valid(reserved))
  expect_false(env$mfrmr_gtwag_manifest_hash_valid(dry))
  changed <- objects$Reserved
  changed$RuntimeHash <- paste0("x", substring(changed$RuntimeHash, 2L))
  expect_false(env$mfrmr_gtwah_reserved_manifest_hash_valid(changed))
})

test_that("b1g14 preflight rejects executed-result mutation", {
  result <- gtheory_production_adapter_execution()
  env <- result$Env
  objects <- result$Objects

  changed_execution <- result$Execution
  changed_execution$CandidateFits$PreFitHash[[1L]] <- paste0(
    "x", substring(changed_execution$CandidateFits$PreFitHash[[1L]], 2L)
  )
  expect_false(env$mfrmr_gtwah_execution_hash_valid(changed_execution))
  expect_error(
    env$mfrmr_gtwah_preflight(
      objects$Contract, objects$Reserved, changed_execution
    ),
    "Exact b1g14 preflight inputs"
  )
})

test_that("b1g14 preflight advances no calibration or inference flag", {
  result <- gtheory_production_adapter_execution()
  preflight <- result$Preflight

  expect_s3_class(preflight, "mfrmr_gtwah_preflight")
  expect_true(preflight$ProductionEvaluatorAdaptersFrozen)
  expect_true(preflight$ReservedRunManifestFrozen)
  expect_true(preflight$ProductionAdapterPreflightReady)
  expect_true(preflight$DryRunEvidenceReady)
  expect_true(preflight$GeneratorHashMatch)
  expect_true(preflight$PreFitHashMatch)
  expect_true(preflight$ShardAccountingExact)
  expect_true(result$Env$mfrmr_gtwah_execution_hash_valid(result$Execution))
  expect_identical(
    preflight$ExactCounts,
    c(
      Datasets = 3000L, AtomicUnits = 12000L,
      CandidateFits = 108000L, CandidateDecisions = 576000L,
      References = 24000L, Shards = 100L
    )
  )
  expect_false(preflight$CalibrationAuthorizationReady)
  expect_false(preflight$CalibrationExecutionAuthorized)
  expect_false(preflight$CalibrationDataGenerated)
  expect_false(preflight$CalibrationResultsViewed)
  expect_false(preflight$StationarityThresholdFrozen)
  expect_false(preflight$StationarityCriterionReady)
  expect_false(preflight$ConfirmationAuthorized)
  expect_false(preflight$InferenceReady)
  expect_false(preflight$CoefficientEligible)
  expect_false(preflight$DecisionReady)
})
