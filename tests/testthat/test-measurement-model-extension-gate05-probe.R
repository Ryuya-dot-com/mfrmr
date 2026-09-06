load_gate05_grm_gpcm_probe <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  script <- file.path(
    root, "inst", "validation",
    "measurement-model-extension-gate05-grm-gpcm-probe-0.2.4.R"
  )
  skip_if_not(file.exists(script), "Gate 0.5 internal probe is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, script = script, env = env)
}

load_b2_data_eligibility_audit <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  script <- file.path(
    root, "inst", "validation",
    "measurement-model-extension-b2-data-eligibility-0.2.4.R"
  )
  skip_if_not(file.exists(script), "B2 internal data audit is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, script = script, env = env)
}

gate05_smoke_result <- local({
  cached <- NULL
  function() {
    if (!is.null(cached)) return(cached)
    skip_if_not_installed("mirt")
    probe <- load_gate05_grm_gpcm_probe()
    cached <<- probe$env$mfrmr_run_gate05_grm_gpcm_probe(smoke = TRUE)
    cached
  }
})

test_that("Gate 0.5 changes only response-family geometry", {
  probe <- load_gate05_grm_gpcm_probe()
  contract <- probe$env$mfrmr_gate05_contract()
  registry <- probe$env$mfrmr_gate05_registry(smoke = FALSE)

  expect_identical(contract$StageId, "B2")
  expect_identical(contract$Status, "parked_mechanical_probe_only")
  expect_identical(contract$PredictionTarget, "new_person_complete_item_vector")
  expect_identical(contract$MajorIdentityAxesChanged, "response_family_only")
  expect_setequal(contract$DGPFamilies, c("GRM", "GPCM"))
  expect_setequal(contract$FitFamilies, c("GRM", "GPCM"))
  expect_false(contract$PublicApiChange)
  expect_true(all(c(
    "observed_facets", "latent_dimension", "portable_calibration",
    "response_time"
  ) %in% contract$ExcludedAxes))
  expect_identical(nrow(registry), 4L)
  expect_true(all(registry$Replications == 30L))
  expect_setequal(registry$ThresholdRegime, c("regular", "compressed"))

  namespace <- readLines(file.path(probe$root, "NAMESPACE"), warn = FALSE)
  expect_false(any(grepl("gate05", namespace, ignore.case = TRUE)))
})

test_that("Gate 0.5 DGP has binary closure and polytomous nonequivalence", {
  probe <- load_gate05_grm_gpcm_probe()
  theta <- seq(-3, 3, length.out = 31L)

  binary_parameters <- probe$env$mfrmr_gate05_parameters(3L, 2L, "regular")
  binary_grm <- probe$env$mfrmr_gate05_probabilities(
    "GRM", theta, binary_parameters
  )
  binary_gpcm <- probe$env$mfrmr_gate05_probabilities(
    "GPCM", theta, binary_parameters
  )
  expect_equal(binary_grm, binary_gpcm, tolerance = 1e-14)

  ordinal_parameters <- probe$env$mfrmr_gate05_parameters(3L, 4L, "regular")
  ordinal_grm <- probe$env$mfrmr_gate05_probabilities(
    "GRM", theta, ordinal_parameters
  )
  ordinal_gpcm <- probe$env$mfrmr_gate05_probabilities(
    "GPCM", theta, ordinal_parameters
  )
  expect_true(all(vapply(
    c(ordinal_grm, ordinal_gpcm),
    function(probability) {
      all(is.finite(probability)) && all(probability >= 0) &&
        max(abs(rowSums(probability) - 1)) < 1e-12
    },
    logical(1)
  )))
  expect_gt(max(abs(ordinal_grm[[2L]] - ordinal_gpcm[[2L]])), 0.05)
})

test_that("Gate 0.5 identity seeds do not depend on registry order", {
  probe <- load_gate05_grm_gpcm_probe()
  registry <- probe$env$mfrmr_gate05_registry(smoke = TRUE)
  contract_id <- probe$env$mfrmr_gate05_contract()$ContractId
  seeds <- setNames(vapply(registry$CellPrefix, function(prefix) {
    probe$env$mfrmr_gate05_seed(
      contract_id, paste0(prefix, "-R001"), "data"
    )
  }, integer(1)), registry$CellPrefix)
  reversed <- rev(registry$CellPrefix)
  reversed_seeds <- setNames(vapply(reversed, function(prefix) {
    probe$env$mfrmr_gate05_seed(
      contract_id, paste0(prefix, "-R001"), "data"
    )
  }, integer(1)), reversed)

  expect_identical(seeds, reversed_seeds[names(seeds)])
  expect_identical(unname(seeds), c(
    1281852471L, 1773968388L, 722712418L, 1130372951L
  ))
})

test_that("Gate 0.5 smoke preserves every fit attempt and ambient RNG", {
  skip_if_not_installed("mirt")
  set.seed(9137)
  ambient_seed <- .Random.seed
  result <- gate05_smoke_result()

  expect_identical(.Random.seed, ambient_seed)
  expect_s3_class(result, "mfrmr_gate05_grm_gpcm_probe")
  expect_identical(result$decision$ExpectedAttempts, 8L)
  expect_identical(result$decision$ObservedAttempts, 8L)
  expect_identical(result$decision$ValidPairs, 4L)
  expect_identical(
    result$decision$Disposition,
    "mechanics_passed_no_portfolio_admission"
  )
  expect_false(result$decision$PublicApiChange)
  expect_identical(nrow(result$attempts), 8L)
  expect_identical(length(unique(result$attempts$AttemptId)), 8L)
  expect_true(all(result$attempts$TerminalStatus == "valid"))
  expect_identical(sum(result$terminal_counts$Attempts), 8L)
  expect_identical(nrow(result$scores), 8L)
  expect_identical(nrow(result$pairs), 4L)
  expect_true(all(is.finite(result$scores$MeanLogScorePerResponse)))
  expect_true(all(abs(result$scores$QuadratureMeanShift) < 1e-7))
  expect_true(all(result$pairs$PortfolioEffect ==
                    "none_mechanical_probe_only"))
  expect_setequal(
    result$pairs$Direction,
    intersect(
      unique(result$pairs$Direction),
      c("matched_better", "mismatched_better", "indeterminate")
    )
  )
})

test_that("Gate 0.5 retains invalid DGP cells in the denominator", {
  skip_if_not_installed("mirt")
  probe <- load_gate05_grm_gpcm_probe()
  registry <- probe$env$mfrmr_gate05_registry(smoke = TRUE)[1L, , drop = FALSE]
  registry$MinimumTrainCategoryCount <- 1000L
  result <- probe$env$mfrmr_run_gate05_grm_gpcm_probe(
    smoke = TRUE,
    registry = registry
  )

  expect_identical(result$decision$ExpectedAttempts, 2L)
  expect_identical(result$decision$ObservedAttempts, 2L)
  expect_identical(result$decision$ValidPairs, 0L)
  expect_true(all(result$attempts$TerminalStatus == "dgm_invalid"))
  expect_identical(sum(result$terminal_counts$Attempts), 2L)
  expect_identical(result$decision$Disposition, "mechanics_failed_keep_parked")
})

test_that("Gate 0.5 malformed registries fail closed", {
  skip_if_not_installed("mirt")
  probe <- load_gate05_grm_gpcm_probe()
  registry <- probe$env$mfrmr_gate05_registry(smoke = TRUE)

  missing <- registry[, setdiff(names(registry), "DGPFamily"), drop = FALSE]
  expect_error(
    probe$env$mfrmr_run_gate05_grm_gpcm_probe(
      smoke = TRUE, registry = missing
    ),
    "registry is missing"
  )
  duplicate <- registry[1:2, , drop = FALSE]
  duplicate$CellPrefix[2L] <- duplicate$CellPrefix[1L]
  expect_error(
    probe$env$mfrmr_run_gate05_grm_gpcm_probe(
      smoke = TRUE, registry = duplicate
    ),
    "must be unique"
  )
})

test_that("Gate 0.5 pilot receipt binds the exact executable and denominator", {
  skip_if_not_installed("digest")
  probe <- load_gate05_grm_gpcm_probe()
  receipt_path <- file.path(
    probe$root, "inst", "validation",
    "measurement-model-extension-gate05-grm-gpcm-pilot-0.2.4.csv"
  )
  expect_true(file.exists(receipt_path))
  receipt <- utils::read.csv(
    receipt_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  script_hash <- tolower(digest::digest(
    file = probe$script, algo = "sha256"
  ))

  expect_identical(nrow(receipt), 4L)
  expect_identical(unique(receipt$script_sha256), script_hash)
  expect_identical(unique(receipt$engine), "mirt")
  expect_equal(unique(receipt$engine_version), 1.47, tolerance = 0)
  expect_setequal(receipt$scenario_id, c("G05-COMPRESSED", "G05-REGULAR"))
  expect_setequal(receipt$dgp_family, c("GRM", "GPCM"))
  expect_identical(sum(receipt$fit_attempts), 240L)
  expect_identical(sum(receipt$valid_attempts), 240L)
  expect_identical(sum(receipt$valid_pairs), 120L)
  expect_identical(sum(receipt$dgm_invalid), 0L)
  expect_identical(sum(receipt$fit_error), 0L)
  expect_identical(sum(receipt$nonconverged), 0L)
  expect_identical(sum(receipt$invalid_probability), 0L)
  expect_identical(sum(receipt$metric_undefined), 0L)
  expect_true(all(receipt$direction == "matched_better"))
  expect_equal(
    range(receipt$mean_matched_minus_mismatched_log_score_per_response),
    c(0.0010808864841386, 0.0025787153263451),
    tolerance = 1e-15
  )
  expect_true(all(receipt$disposition ==
    "geometry_detectable_reopen_problem_discovery_only"))
  expect_true(all(!receipt$public_api_change))
})

test_that("B2 intake keeps facets distinct from latent dimensions", {
  probe <- load_b2_data_eligibility_audit()
  contract <- probe$env$mfrmr_b2_data_contract()

  expect_identical(contract$ContractId, "MFRMR-B2-REAL-DATA-INTAKE-V1")
  expect_identical(contract$StageId, "B2")
  expect_identical(contract$Status, "problem_discovery_only")
  expect_identical(contract$LatentDimension, 1L)
  expect_match(contract$FacetInterpretation, "observed design roles")
  expect_match(contract$FacetInterpretation, "neither is a latent dimension")
  expect_setequal(
    contract$ForbiddenSilentTransforms,
    c(
      "mean_then_round_repeated_ratings",
      "majority_vote_repeated_ratings",
      "select_latest_or_first_rating",
      "treat_rater_by_criterion_as_item",
      "treat_observed_facets_as_latent_dimensions"
    )
  )
  expect_true(all(c(
    "cumulative_boundary_interpretation", "repeated_rating_policy",
    "named_decision", "action_if_result_changes", "practical_threshold",
    "build_versus_mirt_integration_question"
  ) %in% contract$RequiredPacketFields))
  expect_false(contract$PublicApiChange)
})

test_that("B2 bundled-data audit refuses every nonempirical packet before fit", {
  probe <- load_b2_data_eligibility_audit()
  result <- probe$env$mfrmr_run_b2_data_eligibility_audit(probe$root)
  audit <- result$audit

  expect_s3_class(result, "mfrmr_b2_data_eligibility_audit")
  expect_identical(result$decision$bundled_objects_expected, 10L)
  expect_identical(result$decision$bundled_objects_observed, 10L)
  expect_identical(result$decision$eligible_objects, 0L)
  expect_identical(result$decision$model_fits_executed, 0L)
  expect_identical(
    result$decision$disposition,
    "no_eligible_bundled_problem_packet_external_intake_required"
  )
  expect_identical(
    result$decision$next_action,
    "request_one_owner_confirmed_deidentified_problem_packet"
  )
  expect_identical(result$decision$portfolio_effect, "none_B2_remains_parked")
  expect_false(result$decision$public_api_change)

  expect_identical(nrow(audit), 10L)
  expect_false(any(audit$empirical_representative_packet))
  expect_true(all(audit$eligibility_status == "ineligible"))
  expect_identical(sum(audit$has_score), 9L)
  expect_identical(sum(!audit$has_score), 1L)
  expect_true(all(audit$repeated_person_criterion_cells > 0L))
  expect_true(all(audit$duplicate_response_identities == 0L))
  expect_true(all(grepl("named_decision_missing", audit$blocker_codes)))
  expect_true(all(grepl("action_linked_metric_missing", audit$blocker_codes)))
  expect_true(all(grepl(
    "repeated_ratings_no_prespecified_facet_handling", audit$blocker_codes
  )))

  current_examples <- audit$documented_geometry == "adjacent_RSM_generator"
  expect_identical(sum(current_examples), 3L)
  expect_true(all(grepl(
    "documented_adjacent_DGP_not_cumulative_workflow",
    audit$blocker_codes[current_examples]
  )))
  combined <- startsWith(audit$object, "ej2021_combined")
  expect_identical(sum(combined), 2L)
  expect_true(all(!audit$scale_identity_reviewed[combined]))
  expect_true(all(grepl(
    "cross_study_linking_unreviewed", audit$blocker_codes[combined]
  )))
})

test_that("B2 data-eligibility receipt binds inventory and executable", {
  skip_if_not_installed("digest")
  probe <- load_b2_data_eligibility_audit()
  receipt_path <- file.path(
    probe$root, "inst", "validation",
    "measurement-model-extension-b2-data-eligibility-0.2.4.csv"
  )
  expect_true(file.exists(receipt_path))
  receipt <- utils::read.csv(
    receipt_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  script_hash <- tolower(digest::digest(
    file = probe$script, algo = "sha256"
  ))

  expect_identical(nrow(receipt), 10L)
  expect_identical(length(unique(receipt$object)), 10L)
  expect_identical(unique(receipt$contract_id),
                   "MFRMR-B2-REAL-DATA-INTAKE-V1")
  expect_identical(unique(receipt$script_sha256), script_hash)
  expect_identical(sum(receipt$model_fits_executed), 0L)
  expect_true(all(receipt$study_disposition ==
    "no_eligible_bundled_problem_packet_external_intake_required"))
  expect_true(all(receipt$eligibility_status == "ineligible"))
  expect_true(all(!receipt$public_api_change))
})
