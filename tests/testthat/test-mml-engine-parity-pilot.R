mml_engine_parity_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_mml_engine_parity_pilot <- function(include_numerical = TRUE) {
  validation_dir <- mml_engine_parity_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only engine-parity validation files are unavailable."
  )
  env <- new.env(parent = globalenv())
  if (isTRUE(include_numerical)) {
    sys.source(
      file.path(
        validation_dir,
        "numerical-stationarity-pilot-0.2.3.R"
      ),
      envir = env
    )
  }
  script <- file.path(
    validation_dir,
    "mml-engine-parity-pilot-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

mml_engine_common_evaluation_fixture <- function() {
  rows <- expand.grid(
    EvaluatorEngine = c("direct", "em", "hybrid"),
    CoordinateIndex = 1:2,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  rows$RunId <- "rsm_core"
  rows$ScenarioId <- "NUM-ENGINE-RSM"
  rows$Model <- "RSM"
  rows$EvaluatedPath <- "direct"
  rows$Objective <- 100.25
  rows$Score <- rep(c(0.01, -0.02), each = 3L)
  rows$ContextStructureIdentical <- TRUE
  rows
}

test_that("the MML engine-parity plan is fixed and dependency guarded", {
  loaded <- load_mml_engine_parity_pilot()
  env <- loaded$env
  plan <- env$mfrmr_engine_plan()

  expect_identical(env$mfrmr_engine_specification, "0.2.3-draft.13")
  expect_identical(
    env$mfrmr_engine_contract,
    "mfrmr_mml_engine_common_vector_audit_v1"
  )
  expect_identical(
    env$mfrmr_engine_dependency_contract,
    "mfrmr_mml_canonical_score_audit_v1"
  )
  expect_identical(
    env$mfrmr_engine_solution_paths,
    c("direct", "hybrid", "em_plus_common_direct_polish")
  )
  expect_identical(
    plan$RunId,
    c("binary_rsm", "binary_pcm", "rsm_core", "pcm_core")
  )
  expect_identical(plan$Model, c("RSM", "PCM", "RSM", "PCM"))
  expect_identical(
    plan$FixtureId,
    c(
      "binary_fixed", "binary_fixed",
      "polytomous_fixed", "polytomous_fixed"
    )
  )
  expect_true(all(plan$QuadPoints == 31L))
  expect_true(all(plan$Maxit == 2000L))
  expect_true(all(plan$Reltol == 1e-12))
  expect_true(all(plan$Optimizer == "L-BFGS-B"))
  expect_true(all(!plan$SelectionAuthorized))
  expect_true(all(!plan$ConfirmationAuthorized))
  expect_false(exists("parity", envir = env, inherits = FALSE))

  engine_only <- load_mml_engine_parity_pilot(include_numerical = FALSE)$env
  expect_error(
    engine_only$mfrmr_run_mml_engine_parity_pilot(),
    "Source numerical-stationarity-pilot-0.2.3.R",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_engine_fit_args(plan[1, , drop = FALSE], list(), "unknown"),
    "must be direct, em, or hybrid",
    fixed = TRUE
  )
})

test_that("the engine scope registry keeps fallbacks out of parity", {
  env <- load_mml_engine_parity_pilot()$env
  registry <- env$mfrmr_engine_scope_registry()

  expect_identical(nrow(registry), 11L)
  expect_identical(anyDuplicated(registry$ScopeId), 0L)
  supported_ids <- c(
    "rsm_direct", "rsm_em", "rsm_hybrid",
    "pcm_direct", "pcm_em", "pcm_hybrid"
  )
  supported <- registry[registry$ScopeId %in% supported_ids, , drop = FALSE]
  expect_true(all(supported$ParityScope))
  expect_true(all(!supported$Fallback))
  expect_identical(supported$Used, supported$Requested)

  gpcm <- registry[registry$Model == "GPCM", , drop = FALSE]
  expect_identical(
    gpcm$ScopeId,
    c("gpcm_direct", "gpcm_em", "gpcm_hybrid")
  )
  expect_false(gpcm$Fallback[gpcm$Requested == "direct"])
  expect_true(all(gpcm$Fallback[gpcm$Requested != "direct"]))
  expect_true(all(gpcm$Used == "direct"))
  expect_true(all(!gpcm$ParityScope))

  interaction <- registry[
    registry$ScopeId == "rsm_interaction_em",
    ,
    drop = FALSE
  ]
  population <- registry[
    registry$ScopeId == "pcm_population_hybrid",
    ,
    drop = FALSE
  ]
  expect_true(interaction$Fallback)
  expect_true(population$Fallback)
  expect_false(interaction$ParityScope)
  expect_false(population$ParityScope)
  expect_true(all(!registry$SelectionAuthorized))
  expect_true(all(!registry$ConfirmationAuthorized))
})

test_that("retained-vector fingerprints are deterministic and fail closed", {
  testthat::skip_if_not_installed("digest")
  env <- load_mml_engine_parity_pilot()$env
  value <- c(-1.25, 0, pi, 2e-12)
  first <- env$mfrmr_engine_vector_fingerprint(value)
  second <- env$mfrmr_engine_vector_fingerprint(value)

  expect_identical(first, second)
  expect_match(first, "^[0-9a-f]{64}$")
  expect_false(identical(
    first,
    env$mfrmr_engine_vector_fingerprint(value + c(0, 0, 0, 1e-13))
  ))
  expect_error(
    env$mfrmr_engine_vector_fingerprint(c(1, NA_real_)),
    "finite retained coordinates",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_engine_vector_fingerprint(numeric(0)),
    "finite retained coordinates",
    fixed = TRUE
  )
})

test_that("common-vector summaries reject missing or drifting evaluators", {
  env <- load_mml_engine_parity_pilot()$env
  rows <- mml_engine_common_evaluation_fixture()
  summary <- env$mfrmr_engine_common_vector_summarize(rows)

  expect_identical(summary$ReferenceStatus, "review_complete")
  expect_identical(summary$EvaluatorCount, 3L)
  expect_identical(summary$CoordinateCount, 2L)
  expect_equal(summary$ObjectiveEvaluatorRange, 0, tolerance = 0)
  expect_equal(summary$MaxScoreEvaluatorRange, 0, tolerance = 0)
  expect_true(summary$ContextStructureIdentical)
  expect_true(summary$CommonEvaluatorIdentityObserved)
  expect_false(summary$SelectionAuthorized)
  expect_false(summary$ConfirmationAuthorized)

  drifting <- rows
  drifting$Score[drifting$EvaluatorEngine == "em" &
                   drifting$CoordinateIndex == 1L] <- 0.0101
  drift_summary <- env$mfrmr_engine_common_vector_summarize(drifting)
  expect_identical(drift_summary$ReferenceStatus, "review_complete")
  expect_false(drift_summary$CommonEvaluatorIdentityObserved)
  expect_gt(drift_summary$MaxScoreEvaluatorRange, 1e-12)

  missing <- rows[-1, , drop = FALSE]
  missing_summary <- env$mfrmr_engine_common_vector_summarize(missing)
  expect_identical(missing_summary$ReferenceStatus, "rejected")
  expect_false(missing_summary$CommonEvaluatorIdentityObserved)
  expect_true(is.na(missing_summary$ObjectiveEvaluatorRange))

  duplicate <- rbind(rows, rows[1, , drop = FALSE])
  duplicate_summary <- env$mfrmr_engine_common_vector_summarize(duplicate)
  expect_identical(duplicate_summary$ReferenceStatus, "rejected")

  bad_context <- rows
  bad_context$ContextStructureIdentical[1] <- FALSE
  bad_context_summary <- env$mfrmr_engine_common_vector_summarize(bad_context)
  expect_identical(bad_context_summary$ReferenceStatus, "rejected")

  missing_label <- rows
  missing_label$EvaluatorEngine[1] <- NA_character_
  expect_error(
    env$mfrmr_engine_common_vector_summarize(missing_label),
    "complete identity labels",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_engine_common_vector_summarize(
      rows[, setdiff(names(rows), "Objective")]
    ),
    "does not satisfy",
    fixed = TRUE
  )
})

test_that("the fixed engine pilot records common-vector review evidence", {
  testthat::skip_if_not_installed("digest")
  env <- load_mml_engine_parity_pilot()$env
  pilot <- env$mfrmr_run_mml_engine_parity_pilot()

  expect_s3_class(pilot, "mfrmr_mml_engine_parity_pilot")
  expect_identical(pilot$specification, "0.2.3-draft.13")
  expect_identical(pilot$status, "review")
  expect_identical(nrow(pilot$fixture_manifest), 2L)
  expect_identical(nrow(pilot$path_results), 16L)
  expect_identical(nrow(pilot$common_vector_evaluations), 264L)
  expect_identical(nrow(pilot$common_vector_summary), 16L)
  expect_identical(nrow(pilot$pairwise_results), 12L)
  expect_setequal(
    pilot$path_results$Path,
    env$mfrmr_engine_all_paths
  )
  expect_true(all(
    pilot$path_results$ReferenceStatus == "review_complete"
  ))
  expect_true(all(grepl(
    "^[0-9a-f]{64}$",
    pilot$path_results$RetainedVectorSHA256
  )))
  expect_lte(
    max(pilot$path_results$NativeCommonObjectiveAbsDifference),
    1e-12
  )

  public <- pilot$path_results[
    pilot$path_results$Path %in% c("direct", "hybrid", "em_raw"),
    ,
    drop = FALSE
  ]
  expect_true(all(!public$Fallback))
  expect_true(all(public$RequestedEngine == public$UsedEngine))

  em_plus <- pilot$path_results[
    pilot$path_results$Path == "em_plus_common_direct_polish",
    ,
    drop = FALSE
  ]
  expect_identical(nrow(em_plus), 4L)
  expect_true(all(em_plus$StartedFromRawEM))
  expect_identical(
    em_plus$StartingVectorSHA256,
    em_plus$SourceEMVectorSHA256
  )
  expect_true(all(em_plus$InferenceReady))

  mandatory <- pilot$path_results[
    pilot$path_results$ParitySolutionPath,
    ,
    drop = FALSE
  ]
  expect_identical(nrow(mandatory), 12L)
  expect_true(all(mandatory$InferenceReady))
  expect_true(all(!mandatory$Fallback))
  expect_true(all(is.finite(mandatory$MaxAbsCommonScore)))

  expect_true(all(
    pilot$common_vector_summary$ReferenceStatus == "review_complete"
  ))
  expect_true(all(
    pilot$common_vector_summary$CommonEvaluatorIdentityObserved
  ))
  expect_equal(
    max(pilot$common_vector_summary$ObjectiveEvaluatorRange),
    0,
    tolerance = 0
  )
  expect_equal(
    max(pilot$common_vector_summary$MaxScoreEvaluatorRange),
    0,
    tolerance = 0
  )

  expect_true(all(
    pilot$pairwise_results$ReferenceStatus == "review_complete"
  ))
  expect_true(all(pilot$pairwise_results$BothInferenceReady))
  expect_true(all(is.finite(
    pilot$pairwise_results$ObjectiveAbsDifference
  )))
  expect_true(all(is.finite(
    pilot$pairwise_results$MaxFreeParameterAbsDifference
  )))
  expect_true(all(is.finite(
    pilot$pairwise_results$MaxExpandedParameterAbsDifference
  )))
  expect_true(all(
    pilot$pairwise_results$ObjectiveToleranceStatus == "pilot_required"
  ))
  expect_true(all(
    pilot$pairwise_results$ParameterToleranceStatus == "pilot_required"
  ))
  expect_false(any(c(
    "PairPass", "ParityPass", "SelectionConclusion"
  ) %in% names(pilot$pairwise_results)))

  expect_true(pilot$summary$FixedFixturesComplete)
  expect_true(pilot$summary$AllPathReferencesComplete)
  expect_true(pilot$summary$PublicEngineIdentityComplete)
  expect_true(pilot$summary$EMPolishStartIdentityComplete)
  expect_true(pilot$summary$AllMandatoryPathsInferenceReady)
  expect_identical(pilot$summary$RawEMPathCount, 4L)
  expect_true(pilot$summary$AllCommonEvaluatorIdentitiesObserved)
  expect_true(pilot$summary$AllPairwiseReferencesComplete)
  expect_true(pilot$summary$FallbackScopeComplete)
  expect_identical(
    pilot$summary$ObjectiveToleranceStatus,
    "pilot_required"
  )
  expect_identical(
    pilot$summary$ParameterToleranceStatus,
    "pilot_required"
  )
  expect_identical(
    pilot$summary$GpcmEngineParityStatus,
    "not_applicable_single_supported_engine"
  )
  expect_false(pilot$summary$SelectionAuthorized)
  expect_false(pilot$summary$ConfirmationAuthorized)
  expect_false(pilot$selection_authorized)
  expect_false(pilot$confirmation_authorized)
})

test_that("the engine global summary fails closed on incomplete evidence", {
  testthat::skip_if_not_installed("digest")
  env <- load_mml_engine_parity_pilot()$env
  pilot <- env$mfrmr_run_mml_engine_parity_pilot()
  summarize <- function(paths = pilot$path_results,
                        pairs = pilot$pairwise_results,
                        common = pilot$common_vector_summary,
                        fixtures = pilot$fixture_manifest,
                        scope = pilot$scope_registry) {
    env$mfrmr_engine_global_summary(
      paths,
      pairs,
      common,
      fixtures,
      scope
    )
  }

  fallback_path <- pilot$path_results
  fallback_path$Fallback[
    fallback_path$Path == "hybrid" &
      fallback_path$RunId == "rsm_core"
  ] <- TRUE
  fallback_summary <- summarize(paths = fallback_path)
  expect_false(fallback_summary$PublicEngineIdentityComplete)
  expect_false(fallback_summary$AllMandatoryPathsInferenceReady)

  wrong_start <- pilot$path_results
  wrong_start$StartingVectorSHA256[
    wrong_start$Path == "em_plus_common_direct_polish"
  ][1] <- paste(rep("0", 64L), collapse = "")
  start_summary <- summarize(paths = wrong_start)
  expect_false(start_summary$EMPolishStartIdentityComplete)

  missing_pair <- pilot$pairwise_results[-1, , drop = FALSE]
  pair_summary <- summarize(pairs = missing_pair)
  expect_false(pair_summary$AllPairwiseReferencesComplete)
  expect_true(is.na(pair_summary$MaxPairwiseObjectiveAbsDifference))

  drifting_common <- pilot$common_vector_summary
  drifting_common$CommonEvaluatorIdentityObserved[1] <- FALSE
  common_summary <- summarize(common = drifting_common)
  expect_false(common_summary$AllCommonEvaluatorIdentitiesObserved)
  expect_true(is.na(common_summary$MaxObjectiveEvaluatorRange))

  bad_fixture <- pilot$fixture_manifest
  bad_fixture$SHA256[1] <- "invalid"
  fixture_summary <- summarize(fixtures = bad_fixture)
  expect_false(fixture_summary$FixedFixturesComplete)

  bad_scope <- pilot$scope_registry
  bad_scope$Fallback[bad_scope$ScopeId == "gpcm_em"] <- FALSE
  scope_summary <- summarize(scope = bad_scope)
  expect_false(scope_summary$FallbackScopeComplete)

  expect_error(
    summarize(paths = pilot$path_results[, setdiff(
      names(pilot$path_results),
      "UsedEngine"
    )]),
    "`path_results` is incomplete",
    fixed = TRUE
  )
})
