release_readiness_protocol_path <- function() {
  source_path <- testthat::test_path("..", "..", "inst", "validation", "release-readiness.R")
  if (file.exists(source_path)) {
    source_path
  } else {
    system.file("validation", "release-readiness.R", package = "mfrmr")
  }
}

test_that("public roadmap and current NEWS exclude internal release operations", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  public_path <- file.path(pkg_root, "ROADMAP.md")
  news_path <- file.path(pkg_root, "NEWS.md")
  internal_path <- file.path(pkg_root, "inst", "validation",
                             "internal-roadmap-0.2.3.md")
  skip_if_not(all(file.exists(c(public_path, news_path))))
  expect_true(file.exists(internal_path))

  public <- paste(readLines(public_path, warn = FALSE, encoding = "UTF-8"),
                  collapse = "\n")
  news <- readLines(news_path, warn = FALSE, encoding = "UTF-8")
  historical_boundary <- match("# mfrmr 0.2.2", news)
  expect_true(is.finite(historical_boundary))
  current_news <- paste(news[seq_len(historical_boundary - 1L)], collapse = "\n")
  internal <- paste(readLines(internal_path, warn = FALSE, encoding = "UTF-8"),
                    collapse = "\n")
  forbidden <- c(
    "0\\.2\\.3-draft", "SHA-256", "candidate manifest", "M1:", "M2:",
    "Confirmation authorized", "inst/validation", "C:/", "C:\\\\",
    "WP[0-9]-", "ReadinessContractVersion",
    "population_assumption_linked", "metric_specific_comparison_eligibility",
    "ready_with_exclusions", "legacy_contract_missing",
    "mfrmr-internal-readiness"
  )
  for (pattern in forbidden) {
    expect_false(grepl(pattern, public, perl = TRUE), info = pattern)
  }
  news_forbidden <- c(
    "candidate manifest", "frozen gate", "gate-development",
    "unauthorized confirmation", "candidate-linked result",
    "internal development and validation roadmap"
  )
  for (pattern in news_forbidden) {
    expect_false(grepl(pattern, current_news, fixed = TRUE), info = pattern)
  }
  expect_match(public, "single source of truth for mfrmr's public release direction",
               fixed = TRUE)
  expect_match(public,
               "does not\\s+imply that the two estimators have identical statistical maturity")
  expect_match(public, "CML or CCML as current\\s+mfrmr fitting methods")
  expect_match(public, "Hierarchical rater models address a different",
               fixed = TRUE)
  expect_match(public, "The 0.2.3 exit decision is claim-based", fixed = TRUE)
  expect_match(public, "a caveat cannot be", fixed = TRUE)
  expect_match(internal, "internal development and validation roadmap",
               fixed = TRUE)

  ignore <- readLines(file.path(pkg_root, ".Rbuildignore"), warn = FALSE)
  expect_true(any(grepl("ROADMAP", ignore, fixed = TRUE)))
  expect_true(any(grepl("inst/validation", ignore, fixed = TRUE)))
})

test_that("internal draft.62 roadmap and GPCM work remain explicit and private", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  internal_path <- file.path(
    pkg_root, "inst", "validation", "internal-roadmap-0.2.3.md"
  )
  gate_path <- file.path(
    pkg_root, "inst", "validation", "release-gate-spec-0.2.3.md"
  )
  checklist_path <- file.path(
    pkg_root, "inst", "validation", "release-evidence-checklist-0.2.3.csv"
  )
  estimator_plan_path <- file.path(
    pkg_root, "inst", "validation",
    "tam-immer-estimator-stress-plan-0.2.3.md"
  )
  contract_path <- file.path(
    pkg_root, "inst", "validation", "readiness-contract-0.2.3.md"
  )
  fixture_path <- file.path(
    pkg_root, "inst", "validation",
    "readiness-contract-fixtures-0.2.3.csv"
  )
  gpcm_smoke_record_path <- file.path(
    pkg_root, "inst", "validation",
    "gpcm-stress-covering-grid-smoke-record-0.2.3.md"
  )
  attribution_smoke_record_path <- file.path(
    pkg_root, "inst", "validation",
    "gpcm-isolated-attribution-smoke-record-0.2.3.md"
  )
  attribution_replicated_record_path <- file.path(
    pkg_root, "inst", "validation",
    "gpcm-attribution-replicated-feasibility-record-0.2.3.md"
  )
  checkpoint_record_path <- file.path(
    pkg_root, "inst", "validation",
    "gpcm-attribution-checkpoint-resume-record-0.2.3.md"
  )
  metamorphic_record_path <- file.path(
    pkg_root, "inst", "validation",
    "mml-metamorphic-grid-record-0.2.3.md"
  )
  roadmap_record_path <- file.path(
    pkg_root, "inst", "validation",
    "roadmap-reassessment-record-0.2.3.md"
  )
  target_scale_record_path <- file.path(
    pkg_root, "inst", "validation",
    "target-scale-sparse-stress-pilot-record-0.2.3.md"
  )
  target_bridge_record_path <- file.path(
    pkg_root, "inst", "validation",
    "target-scale-baseline-bridge-pilot-record-0.2.3.md"
  )
  jml_profile_record_path <- file.path(
    pkg_root, "inst", "validation",
    "jml-bottleneck-decomposition-pilot-record-0.2.3.md"
  )
  jml_phase_record_path <- file.path(
    pkg_root, "inst", "validation",
    "jml-phase-profile-pilot-record-0.2.3.md"
  )
  jml_prescreen_record_path <- file.path(
    pkg_root, "inst", "validation",
    "jml-structural-cone-prescreen-pilot-record-0.2.3.md"
  )
  skip_if_not(all(file.exists(c(
    internal_path, gate_path, checklist_path, estimator_plan_path,
    contract_path, fixture_path, gpcm_smoke_record_path,
    attribution_smoke_record_path, attribution_replicated_record_path,
    checkpoint_record_path, metamorphic_record_path, roadmap_record_path,
    target_scale_record_path, target_bridge_record_path,
    jml_profile_record_path, jml_phase_record_path,
    jml_prescreen_record_path
  ))))

  internal <- paste(readLines(internal_path, warn = FALSE, encoding = "UTF-8"),
                    collapse = "\n")
  gate <- paste(readLines(gate_path, warn = FALSE, encoding = "UTF-8"),
                collapse = "\n")
  checklist <- utils::read.csv(checklist_path, stringsAsFactors = FALSE,
                               check.names = FALSE)
  estimator_plan <- paste(
    readLines(estimator_plan_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  gpcm_smoke_record <- paste(
    readLines(gpcm_smoke_record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  attribution_smoke_record <- paste(
    readLines(attribution_smoke_record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  attribution_replicated_record <- paste(
    readLines(attribution_replicated_record_path, warn = FALSE,
              encoding = "UTF-8"),
    collapse = "\n"
  )
  checkpoint_record <- paste(
    readLines(checkpoint_record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  metamorphic_record <- paste(
    readLines(metamorphic_record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  roadmap_record <- paste(
    readLines(roadmap_record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  target_scale_record <- paste(
    readLines(target_scale_record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  target_bridge_record <- paste(
    readLines(target_bridge_record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  jml_profile_record <- paste(
    readLines(jml_profile_record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  jml_phase_record <- paste(
    readLines(jml_phase_record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  jml_prescreen_record <- paste(
    readLines(jml_prescreen_record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )

  expect_match(internal, "WP0-READINESS-CONTRACT", fixed = TRUE)
  expect_match(internal, "WP7-REPILOT-AND-FREEZE", fixed = TRUE)
  expect_match(internal, "population_assumption_linked", fixed = TRUE)
  expect_match(internal, "ReadinessContractVersion", fixed = TRUE)
  expect_match(internal, "expected, eligible, rejected", fixed = TRUE)
  expect_match(internal, "WP0 is structurally complete", fixed = TRUE)
  expect_match(internal,
               "in_progress_mml_all_pattern_design_reuse",
               fixed = TRUE)
  expect_match(internal,
               "in_progress_support_preflight",
               fixed = TRUE)
  expect_match(internal, "Draft.25 fitted-information instrumentation slice",
               fixed = TRUE)
  expect_match(internal, "Draft.26 nonlinear transformation instrumentation slice",
               fixed = TRUE)
  expect_match(internal, "Draft.27 JML GPCM conditional response-kernel slice",
               fixed = TRUE)
  expect_match(internal, "Draft.28 MML observed Person-pattern score slice",
               fixed = TRUE)
  expect_match(internal,
               "Draft.29 MML all-pattern expected-information slice",
               fixed = TRUE)
  expect_match(internal,
               "Draft.30 exact Person-design reuse slice",
               fixed = TRUE)
  expect_match(internal,
               "Draft.31 category/step preflight slice",
               fixed = TRUE)
  expect_match(internal,
               "Draft.32 Person sufficient-score boundary slice",
               fixed = TRUE)
  expect_match(internal,
               "Draft.33 Person-fixed structural recession certificate",
               fixed = TRUE)
  expect_match(internal,
               "Draft.34 sparse LP and independent microcase oracle",
               fixed = TRUE)
  expect_match(internal,
               "Draft.35 joint Person-structural additive certificate",
               fixed = TRUE)
  expect_match(internal,
               "Draft.36 retained-additive GPCM log-slope boundary paths",
               fixed = TRUE)
  expect_match(internal, "Draft.37 near-term corrective program", fixed = TRUE)
  expect_match(internal, "Corrective-program execution lanes", fixed = TRUE)
  expect_match(internal, "partitioned\\s+exhaustively")
  expect_match(internal, "Estimator ecosystem and maturity boundary", fixed = TRUE)
  expect_match(internal, "method = \"HRM\"", fixed = TRUE)
  expect_match(gate, "Specification ID | `0.2.3-draft.62`", fixed = TRUE)
  expect_match(internal, "Draft.40 adds the first bounded joint nonlinear GPCM path family", fixed = TRUE)
  expect_match(internal, "Draft.41 makes the prespecified GPCM stress envelope executable", fixed = TRUE)
  expect_match(internal, "Draft.42 adds the isolated-attribution layer", fixed = TRUE)
  expect_match(internal,
               "Draft.43 adds a guarded replicated-feasibility layer",
               fixed = TRUE)
  expect_match(internal,
               "Draft.44 removes the all-or-nothing writer", fixed = TRUE)
  expect_match(internal,
               "Draft.45 closes the small-design cross-model MML metamorphic slice",
               fixed = TRUE)
  expect_match(internal,
               "Draft.46 rechecks those official sources", fixed = TRUE)
  expect_match(internal,
               "Draft.47 begins target-scale execution", fixed = TRUE)
  expect_match(internal,
               "Draft.48 separates scale from adversity", fixed = TRUE)
  expect_match(internal,
               "Draft.49 decomposes the JML computation hypothesis",
               fixed = TRUE)
  expect_match(internal,
               "Draft.50 instruments the exact execution phases",
               fixed = TRUE)
  expect_match(internal,
               "Draft.51 implements the certificate-equivalent structural global-cone",
               fixed = TRUE)
  expect_match(internal,
               "Draft.62 implements the selected bounded single-ten-second policy",
               fixed = TRUE)
  expect_match(internal, "`release_spine`", fixed = TRUE)
  expect_match(internal, "in_progress_core_slice_unblocked", fixed = TRUE)
  expect_match(internal,
               "in_progress_replay_blocker_resolved_nonlinear_gpcm_pca_ademp_resume",
               fixed = TRUE)
  expect_match(internal,
               "in_progress_replay_resolved_profile_and_precision_remaining",
               fixed = TRUE)
  expect_match(gate, "`ReplayBlockerResolved=true`", fixed = TRUE)
  expect_match(internal, "70 pilot cells covering all 1,330", fixed = TRUE)
  expect_match(gpcm_smoke_record, "zero false-ready rows", fixed = TRUE)
  expect_match(
    gpcm_smoke_record,
    "1157044b089f9b2c261f9feceb6bf25c16aa71435307afed635aef30c05c4994",
    fixed = TRUE
  )
  expect_match(attribution_smoke_record, "zero pair-\\s+identity violations")
  expect_match(
    attribution_smoke_record,
    "3c5114b2657866f8874fa4ffd5fb82324b620e5c88e6540ba4d51c9e03e63b86",
    fixed = TRUE
  )
  expect_match(attribution_replicated_record,
               "EAP Person-order defect found and corrected", fixed = TRUE)
  expect_match(attribution_replicated_record,
               "0/2 gives `[0, 0.658]`", fixed = TRUE)
  expect_match(
    attribution_replicated_record,
    "A3FF87ADB29ACC09FA8D141A390D793D36528FB712AEC96755F43221E94E6BD9",
    fixed = TRUE
  )
  expect_match(
    attribution_replicated_record,
    "88EBD28817AD1924A9AE235F56301264D5EC47FD06A9416D6A4BA55C5C59DFA6",
    fixed = TRUE
  )
  expect_match(
    gate,
    "Pre-fix Person and EAP-derived diagnostic evidence is invalidated",
    fixed = TRUE
  )
  expect_match(gate, "two-replicate", fixed = TRUE)
  expect_match(checkpoint_record,
               "mfrmr-gpcm-repilot-checkpoint-v1", fixed = TRUE)
  expect_match(checkpoint_record,
               "real reference data cell", fixed = TRUE)
  expect_match(
    checkpoint_record,
    "f2b2e9db19a93ba4884cc9b669784b382799d1c876acc53920ffd0a446305d10",
    fixed = TRUE
  )
  expect_match(gate, "complete four-route data cell", fixed = TRUE)
  expect_match(metamorphic_record, "passed 30 of 30", fixed = TRUE)
  expect_match(
    metamorphic_record,
    "2fc9e48a6722a77b2b0b5f95385fd9815533ef93327a38345fe0fa544d3cbefb",
    fixed = TRUE
  )
  expect_match(metamorphic_record,
               "The v1 directory is retained only as a", fixed = TRUE)
  expect_match(roadmap_record,
               "The existing checklist has 87 rows", fixed = TRUE)
  expect_match(roadmap_record,
               "Claim-conditional promotion", fixed = TRUE)
  expect_match(roadmap_record,
               "CRAN distributes TAM 4.3-25", fixed = TRUE)
  expect_match(target_scale_record,
               "zero\\s+false-ready results")
  expect_match(target_scale_record,
               "capacity-feasibility evidence", fixed = TRUE)
  expect_match(
    target_scale_record,
    "6d6dea58d3e64fc6f06754ed90d024efaa1d61896dccc822adfc35b2c52036ef",
    fixed = TRUE
  )
  expect_match(
    target_scale_record,
    "be175b4f941b5a29c0d1d5bf4617a1bffb3f7399776e71616d6ac9410cfc388a",
    fixed = TRUE
  )
  expect_match(target_bridge_record,
               "same generated data through JML and MML", fixed = TRUE)
  expect_match(target_bridge_record,
               "one common truth hash", fixed = TRUE)
  expect_match(
    target_bridge_record,
    "c3057c41358a49d3db9f52ecdd854a08883a9734d6cc35b6fae82af2628ba871",
    fixed = TRUE
  )
  expect_match(
    target_bridge_record,
    "c69d07597b0ecd2814c25e5bf5865601ab15d76aa373c5c687d473c88c37779f",
    fixed = TRUE
  )
  expect_match(jml_profile_record,
               "auto optimizer threshold at 200 parameters", fixed = TRUE)
  expect_match(jml_profile_record,
               "do not show a universal BFGS solution", fixed = TRUE)
  expect_match(
    jml_profile_record,
    "36c1c81440827f11089e22b8e20a2dfb1677ad5d07c9d081140d5964167f29a9",
    fixed = TRUE
  )
  expect_match(
    jml_profile_record,
    "c035b0bf0ce93fc42f5252c6d036787a6c0cd5a041c8a2b2f1a277961dd51019",
    fixed = TRUE
  )
  expect_match(jml_phase_record,
               "structural and joint recession phases together consumed",
               fixed = TRUE)
  expect_match(jml_phase_record,
               "optimizer switch can change numerical readiness", fixed = TRUE)
  expect_match(
    jml_phase_record,
    "1827f40c3a1314363656123b755ab7a9edbacf6a6987d607d208e9d95b88ea95",
    fixed = TRUE
  )
  expect_match(
    jml_phase_record,
    "4544117792cce08af26bc1bb4510eedf94b1647cf1fedd38527d4dd2b47148e7",
    fixed = TRUE
  )
  expect_match(jml_prescreen_record,
               "old audits made 908", fixed = TRUE)
  expect_match(jml_prescreen_record,
               "all 12 JML outer fits were faster", ignore.case = TRUE)
  expect_match(jml_prescreen_record,
               "near-boundary `5e-7` counterexample", fixed = TRUE)
  expect_match(
    jml_prescreen_record,
    "721aac67fea1f63b473aaf84a2194c38193d7f840566b150141d18033eb578ec",
    fixed = TRUE
  )
  expect_match(
    jml_prescreen_record,
    "3e89491c5e02b1d05c21fd5c9f9fa6d9efc652d6d94fe63e01008a9974bef485",
    fixed = TRUE
  )
  expect_match(
    jml_prescreen_record,
    "bd72d5256d4f721ed735d08306bf6b8cba029108c913707b942095070d56a1df",
    fixed = TRUE
  )
  expect_match(
    jml_prescreen_record,
    "d267352a743fed66d215e42bc57d88bc7f0ad7e948e6d74591a451f13b78e061",
    fixed = TRUE
  )
  expect_match(gate,
               "any checklist item lacks a reviewed portfolio", fixed = TRUE)
  expect_match(internal, "GPCM discrepancy decomposition and stress envelope", fixed = TRUE)
  expect_match(internal, "different_slope_estimand", fixed = TRUE)
  expect_match(internal, "Table 7 discrimination is never a", fixed = TRUE)
  expect_match(gate, "unbounded_both", fixed = TRUE)
  expect_match(gate, "marginal-MML boundary", fixed = TRUE)
  expect_match(gate, "EXT-TAM-JML-RAW", fixed = TRUE)
  expect_match(gate, "EXT-IMMER-CCML", fixed = TRUE)
  expect_match(gate, "ALT-IMMER-HRM-LD", fixed = TRUE)
  expect_match(estimator_plan, "EXT-TAM-JML-BC-ADJ", fixed = TRUE)
  expect_match(estimator_plan, "Increasing Persons while observations per Person stay fixed",
               fixed = TRUE)
  expect_match(estimator_plan, "No native CML/CCML milestone", fixed = TRUE)
  expect_true(all(c(
    "readiness_contract_schema",
    "readiness_scope_and_propagation",
    "category_support_behavior",
    "fitted_information_instrumentation",
    "nonlinear_parameterization_jacobians",
    "jml_gpcm_response_kernel_jacobian",
    "mml_observed_person_pattern_score",
    "mml_all_pattern_expected_information",
    "mml_all_pattern_exact_design_reuse",
    "jml_structural_recession_certificate",
    "jml_joint_recession_certificate",
    "jml_gpcm_slope_boundary_path",
    "jml_gpcm_joint_boundary_path",
    "gpcm_stress_covering_grid",
    "gpcm_isolated_attribution_pilot",
    "gpcm_attribution_replicated_feasibility",
    "gpcm_attribution_checkpoint_resume",
    "mml_metamorphic_invariance_grid",
    "sparse_estimability_performance",
    "metric_specific_comparison_eligibility",
    "jml_estimator_maturity",
    "tam_mml_core",
    "tam_immer_jml_overlap",
    "conditional_estimator_overlap",
    "hrm_local_dependence_boundary",
    "ecosystem_positioning_claims"
  ) %in% checklist$Item))
  expect_identical(anyDuplicated(paste(checklist$Gate, checklist$Item)), 0L)
})

test_that("WP0 readiness contract freezes scoped fail-closed semantics", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validator_path <- file.path(
    pkg_root, "inst", "validation", "readiness-contract-0.2.3.R"
  )
  fixture_path <- file.path(
    pkg_root, "inst", "validation",
    "readiness-contract-fixtures-0.2.3.csv"
  )
  skip_if_not(all(file.exists(c(validator_path, fixture_path))))

  env <- new.env(parent = globalenv())
  sys.source(validator_path, envir = env)
  audit <- env$mfrmr_readiness_validate_fixtures(fixture_path, strict = TRUE)

  expect_true(audit$Valid)
  expect_identical(audit$Rows, 36L)
  expect_identical(audit$FitRows, 14L)
  expect_identical(audit$ParameterRows, 16L)
  expect_identical(audit$ComparisonRows, 6L)
  expect_identical(
    audit$ContractVersion,
    "mfrmr-readiness-0.2.3-v3"
  )
  expect_true(all(c("unbounded_both", "not_evaluated") %in%
                    env$mfrmr_readiness_contract_states()$ParameterStatus))
  expect_true(all(c(
    "jml_gpcm_slope_boundary_both",
    "jml_gpcm_joint_boundary_candidate_both",
    "jml_gpcm_joint_boundary_none_certified",
    "jml_gpcm_joint_boundary_not_evaluated",
    "mml_gpcm_slope_boundary_not_evaluated"
  ) %in% env$mfrmr_readiness_reason_codes()$ReasonCode))

  expect_true(env$mfrmr_readiness_inference_ready("ready"))
  expect_false(env$mfrmr_readiness_inference_ready("ready_with_exclusions"))
  expect_false(env$mfrmr_readiness_inference_ready("review"))
  expect_false(env$mfrmr_readiness_inference_ready("blocked"))
  expect_false(env$mfrmr_readiness_inference_ready("legacy_unknown"))
  expect_identical(
    env$mfrmr_readiness_derive_fit(
      "pass", "identified", "adequate", "has_exclusions", "ready"
    ),
    "ready_with_exclusions"
  )
  expect_identical(
    env$mfrmr_readiness_derive_fit(
      "pass", "weak_information", "adequate", "has_exclusions", "ready"
    ),
    "review"
  )
  expect_identical(
    env$mfrmr_readiness_derive_fit(
      "pass", "identified", "unsupported_coordinate", "finite", "ready"
    ),
    "blocked"
  )

  expect_identical(env$mfrmr_readiness_legacy_map(TRUE)$FitReadiness,
                   "legacy_unknown")
  expect_false(env$mfrmr_readiness_legacy_map(TRUE)$InferenceReady)
  expect_false(env$mfrmr_readiness_legacy_map(FALSE)$InferenceReady)

  reasons <- env$mfrmr_readiness_reason_codes()
  conditions <- env$mfrmr_readiness_condition_classes()
  expect_identical(anyDuplicated(reasons$ReasonCode), 0L)
  expect_true(all(grepl("^[a-z0-9]+(?:_[a-z0-9]+)*$",
                        reasons$ReasonCode, perl = TRUE)))
  expect_true(all(conditions$ParentClass == "mfrmr_readiness_condition"))

  fixtures <- utils::read.csv(
    fixture_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  jml_zero <- fixtures[
    fixtures$FixtureId == "two_rater_no_common_jml" &
      fixtures$ReadinessScope == "fit", , drop = FALSE
  ]
  mml_zero <- fixtures[
    fixtures$FixtureId == "two_rater_no_common_mml" &
      fixtures$ReadinessScope == "fit", , drop = FALSE
  ]
  extreme_fit <- fixtures[
    fixtures$FixtureId == "jml_extreme" &
      fixtures$ReadinessScope == "fit", , drop = FALSE
  ]
  extreme_parameter <- fixtures[
    fixtures$FixtureId == "jml_extreme" &
      fixtures$ReadinessScope == "parameter", , drop = FALSE
  ]
  expect_identical(jml_zero$FitReadiness, "blocked")
  expect_identical(mml_zero$FitReadiness, "review")
  expect_identical(mml_zero$EstimabilityState,
                   "population_assumption_linked")
  expect_identical(extreme_fit$FitReadiness, "ready_with_exclusions")
  expect_identical(extreme_parameter$ParameterStatus, "unbounded_high")
})

test_that("WP0 fixture validator rejects post-hoc readiness upgrades", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validator_path <- file.path(
    pkg_root, "inst", "validation", "readiness-contract-0.2.3.R"
  )
  fixture_path <- file.path(
    pkg_root, "inst", "validation",
    "readiness-contract-fixtures-0.2.3.csv"
  )
  skip_if_not(all(file.exists(c(validator_path, fixture_path))))

  env <- new.env(parent = globalenv())
  sys.source(validator_path, envir = env)
  fixtures <- utils::read.csv(
    fixture_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  target <- fixtures$FixtureId == "two_rater_no_common_jml" &
    fixtures$ReadinessScope == "fit"
  fixtures$FitReadiness[target] <- "ready"
  fixtures$InferenceReady[target] <- "TRUE"
  mutated <- tempfile(fileext = ".csv")
  on.exit(unlink(mutated), add = TRUE)
  utils::write.csv(fixtures, mutated, row.names = FALSE, na = "")

  audit <- env$mfrmr_readiness_validate_fixtures(mutated)
  expect_false(audit$Valid)
  expect_true(any(grepl("derives blocked, not ready", audit$Errors,
                        fixed = TRUE)))
})

test_that("FACETS and diagnostic stress registries retain prior edge cells under draft.31", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."),
                            winslash = "/", mustWork = TRUE)
  facets_path <- file.path(
    pkg_root, "inst", "validation", "facets-4.5.0-stress-pilot-0.2.3.R"
  )
  diagnostic_path <- file.path(
    pkg_root, "inst", "validation",
    "interaction-bias-pca-stress-pilot-0.2.3.R"
  )
  skip_if_not(file.exists(facets_path))
  skip_if_not(file.exists(diagnostic_path))

  env <- new.env(parent = globalenv())
  sys.source(facets_path, envir = env)
  sys.source(diagnostic_path, envir = env)

  expanded <- env$mfrmr_facets_450_registry("expanded")
  extension <- env$mfrmr_facets_450_registry("extension")
  smoke <- env$mfrmr_facets_450_registry("smoke")
  diagnostic <- env$mfrmr_diag_stress_registry("expanded")

  expect_equal(nrow(expanded), 31L)
  expect_equal(nrow(extension), 9L)
  expect_equal(nrow(smoke), 10L)
  expect_equal(length(diagnostic), 10L)
  expect_equal(length(env$mfrmr_diag_stress_registry("smoke")), 5L)
  expect_identical(anyDuplicated(expanded$Scenario), 0L)
  expect_setequal(
    extension$Scenario,
    setdiff(diagnostic, "balanced_complete")
  )
  expect_true(all(c(
    "two_rater_one_per_person", "category_single_dominant",
    "interaction_checkerboard_weak", "interaction_checkerboard_strong",
    "residual_local_dependence"
  ) %in% expanded$Scenario))

  severe_rsm <- env$mfrmr_facets_450_thresholds(
    "RSM", sprintf("C%02d", 1:5), "category_single_dominant"
  )
  severe_pcm <- env$mfrmr_facets_450_thresholds(
    "PCM", sprintf("C%02d", 1:5), "category_single_dominant"
  )
  expect_equal(sum(severe_rsm), 0)
  expect_true(all(vapply(severe_pcm, function(x) sum(x) == 0, logical(1))))

  category <- env$mfrmr_diag_stress_category(data.frame(Score = c(1L, 2L, 2L, 2L)))
  expect_identical(category$CategoryCounts, "1;3;0;0")
  expect_equal(category$MinCategoryCount, 0L)
  expect_equal(category$MaxCategoryFraction, 0.75)

  truth <- env$mfrmr_diag_stress_interaction_truth(
    data.frame(
      Rater = rep(c("R01", "R02"), each = 2L),
      Criterion = rep(c("C01", "C02"), times = 2L)
    ),
    data.frame(
      Rater = c("R01", "R01", "R02", "R02"),
      Criterion = c("C01", "C02", "C01", "C02"),
      Effect = c(0.4, -0.4, -0.4, 0.4)
    )
  )
  expect_equal(sum(truth$TrueEffect), 0)
  expect_equal(
    truth$TrueEffect[
      truth$FacetA_Level == "R01" & truth$FacetB_Level == "C01"
    ],
    0.4
  )
})

test_that("FACETS divergence audit fails closed on rank and category contracts", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."),
                            winslash = "/", mustWork = TRUE)
  audit_path <- file.path(
    pkg_root, "inst", "validation",
    "facets-mfrmr-divergence-audit-0.2.3.R"
  )
  skip_if_not(file.exists(audit_path))
  env <- new.env(parent = globalenv())
  sys.source(audit_path, envir = env)

  complete <- expand.grid(
    participant_id = sprintf("P%02d", 1:4),
    rater_id = c("R01", "R02"),
    criteria = c("C01", "C02"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  complete$score <- rep(0:3, length.out = nrow(complete))
  complete_rank <- env$mfrmr_divergence_design_audit(complete)
  expect_true(complete_rank$FullColumnRank)
  expect_equal(complete_rank$Nullity, 0L)

  nested <- expand.grid(
    participant_id = sprintf("P%02d", 1:4),
    criteria = c("C01", "C02"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  nested$rater_id <- ifelse(nested$participant_id %in% c("P01", "P02"),
                            "R01", "R02")
  nested$score <- rep(0:3, length.out = nrow(nested))
  nested_rank <- env$mfrmr_divergence_design_audit(nested)
  expect_false(nested_rank$FullColumnRank)
  expect_equal(nested_rank$Nullity, 1L)

  anchor <- tempfile(fileext = ".anc")
  writeLines(c(
    "Models =", "?,?,1,RS1,1 ; R3", "?,?,2,RS2,1 ; R3", "*",
    "Rating (or partial credit) scale = RS1,R3,G,O",
    " 0=,0,A", " 1=,-1,A", " 2=,0,A", " 3=,1,A", "*",
    "Rating (or partial credit) scale = RS2,R3,G,O",
    " 1=,0,A", " 2=,0,A", "*", "Labels =", "1=P01,0"
  ), anchor)
  pcm <- data.frame(
    criteria = rep(c("C01", "C02"), each = 4L),
    score = c(0:3, 1L, 1L, 2L, 2L),
    stringsAsFactors = FALSE
  )
  category <- env$mfrmr_divergence_category_audit(pcm, "PCM", anchor)
  expect_true(category$CategoryContractComparable[category$ScaleScope == "C01"])
  expect_false(category$CategoryContractComparable[category$ScaleScope == "C02"])
  expect_equal(category$RetainedCategories[category$ScaleScope == "C02"], 2L)

  extreme <- env$mfrmr_divergence_extreme_rows(data.frame(
    participant_id = rep(c("P01", "P02", "P03"), each = 2L),
    score = c(0L, 0L, 1L, 2L, 3L, 3L)
  ))
  expect_identical(
    extreme$ExtremeClass,
    c("extreme_low", "nonextreme", "extreme_high")
  )
})

release_readiness_gate_fixture <- function(env, check_status,
                                           freshness_status = NULL,
                                           example_policy_status = NULL,
                                           check_timing_scope = "cran") {
  evidence_file <- tempfile()
  writeLines("evidence", evidence_file)
  target <- as.character(check_status$TargetVersion[1])
  if (is.null(freshness_status)) {
    freshness_status <- data.frame(
      FreshnessOK = TRUE,
      LatestInput = "DESCRIPTION",
      CheckLogFresh = TRUE,
      TarballAvailable = TRUE,
      TarballFresh = TRUE,
      CheckAfterTarball = TRUE,
      StaleInputs = "",
      stringsAsFactors = FALSE
    )
  }
  if (is.null(example_policy_status)) {
    example_policy_status <- data.frame(
      DontrunSourceTargets = paste(
        c("normalize_conquest_overlap_exports", "review_conquest_overlap"),
        collapse = ", "
      ),
      ExamplesIfSourceTargets = "launch_mfrmr_viewer",
      DonttestRdPages = 147L,
      Detail = "",
      ExamplePolicyOK = TRUE,
      stringsAsFactors = FALSE
    )
  }
  env$mfrmr_release_readiness_gate_summary(
    version_status = data.frame(
      TargetVersion = target,
      DescriptionVersion = target,
      NewsHeading = paste("# mfrmr", target),
      DevelopmentLabelPresent = FALSE,
      VersionOK = TRUE
    ),
    check_status = check_status,
    term_status = data.frame(
      FilesScanned = 1L,
      DisallowedRemovedTerms = 0L,
      TerminologyOK = TRUE,
      Examples = ""
    ),
    checklist_status = data.frame(
      Checklist = evidence_file,
      Rows = 1L,
      BlockerRows = 1L,
      CaveatRows = 0L,
      RoadmapRows = 0L,
      ChecklistAvailable = TRUE
    ),
    ci_workflow_status = data.frame(
      WorkflowAvailable = TRUE,
      PackageCheckStepPresent = TRUE,
      WarningsAreFailures = TRUE,
      CheckArtifactsUploaded = TRUE,
      ReadinessGatePresent = TRUE,
      CIWorkflowOK = TRUE
    ),
    paths = list(
      evidence_map = evidence_file,
      gpcm_roadmap = evidence_file,
      external_recovery_evidence = evidence_file,
      external_recovery_helper = evidence_file
    ),
    freshness_status = freshness_status,
    example_policy_status = example_policy_status,
    check_timing_scope = check_timing_scope
  )
}

test_that("release-readiness protocol exposes review steps and parses check logs", {
  protocol <- release_readiness_protocol_path()
  expect_true(nzchar(protocol))

  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  steps <- env$mfrmr_release_readiness_prompt_steps()
  expect_s3_class(steps, "data.frame")
  expect_equal(nrow(steps), 8L)
  expect_true(all(c("Step", "Label", "Prompt", "Evidence", "Gate") %in% names(steps)))
  expect_true(all(c("blocker", "caveat") %in% steps$Gate))

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* using options ‘--run-donttest --as-cran’",
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "* checking package namespace information ... OK",
    "* checking examples ... [3s/4s] OK",
    "* checking examples with --run-donttest ... [5s/6s] OK",
    "* checking tests ... [1s/1s] OK",
    "* checking re-building of vignette outputs ... [1s/1s] OK",
    "* checking PDF version of manual ... OK",
    "* checking HTML version of manual ... OK",
    "Status: 1 NOTE"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(log_file, target_version = "0.2.1")
  expect_identical(parsed$PackageVersion, "0.2.1")
  expect_true(parsed$VersionMatchesTarget)
  expect_true(parsed$StatusPresent)
  expect_true(parsed$AsCRAN)
  expect_true(parsed$RunDonttest)
  expect_true(parsed$ManualChecked)
  expect_true(parsed$CheckPassed)
  expect_true(parsed$NeedsExplanation)
  expect_equal(parsed$Errors, 0L)
  expect_equal(parsed$Warnings, 0L)
  expect_equal(parsed$Notes, 1L)
  expect_true(parsed$TimingAvailable)
  expect_equal(parsed$ComponentElapsedSeconds, 12)
  expect_equal(parsed$CranWorkloadElapsedSeconds, 12)
  expect_equal(parsed$ExamplesSeconds, 4)
  expect_equal(parsed$DonttestExamplesSeconds, 6)
  expect_equal(parsed$TestsSeconds, 1)
  expect_equal(parsed$VignetteRebuildSeconds, 1)
  expect_true(parsed$UnderTenMinutes)
})

test_that("release-readiness timing excludes check infrastructure overhead", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* using options ‘--run-donttest --as-cran’",
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "* checking package dependencies ... [1s/700s] OK",
    "* checking examples ... [90s/100s] OK",
    "* checking examples with --run-donttest ... [290s/300s] OK",
    "* checking tests ... [9s/10s] OK",
    "* checking re-building of vignette outputs ... [9s/10s] OK",
    "* checking PDF version of manual ... OK",
    "* checking HTML version of manual ... OK",
    "Status: OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(
    log_file,
    target_version = "0.2.1"
  )

  expect_equal(parsed$ComponentElapsedSeconds, 1120)
  expect_equal(parsed$CranWorkloadElapsedSeconds, 420)
  expect_true(parsed$UnderTenMinutes)
  gate <- release_readiness_gate_fixture(env, parsed)
  expect_identical(
    gate$Status[gate$Gate == "check_timing"],
    "ok"
  )
})

test_that("release-readiness protocol flags check timing above ten minutes", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* using options ‘--run-donttest --as-cran’",
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "* checking examples ... [1s/601s] OK",
    "Status: OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(
    log_file,
    target_version = "0.2.1"
  )

  expect_true(parsed$TimingAvailable)
  expect_equal(parsed$ComponentElapsedSeconds, 601)
  expect_equal(parsed$CranWorkloadElapsedSeconds, 601)
  expect_false(parsed$UnderTenMinutes)
  gate <- release_readiness_gate_fixture(env, parsed)
  expect_identical(
    gate$Status[gate$Gate == "check_timing"],
    "concern"
  )
  full_gate <- release_readiness_gate_fixture(
    env,
    parsed,
    check_timing_scope = "full_non_cran"
  )
  expect_identical(
    full_gate$Status[full_gate$Gate == "check_timing"],
    "ok"
  )
  expect_identical(
    env$mfrmr_release_readiness_check_timing_scope("true"),
    "full_non_cran"
  )
  expect_identical(
    env$mfrmr_release_readiness_check_timing_scope("false"),
    "cran"
  )
})

test_that("release-readiness protocol rejects a check log without Status", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "* checking tests ... OK",
    "* checking examples ... OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(
    log_file,
    target_version = "0.2.1"
  )

  expect_true(parsed$VersionMatchesTarget)
  expect_false(parsed$StatusPresent)
  expect_false(parsed$AsCRAN)
  expect_true(is.na(parsed$StatusLine))
  expect_false(parsed$CheckPassed)
  expect_true(parsed$NeedsExplanation)
  expect_true(all(is.na(parsed[c("Errors", "Warnings", "Notes")])))

  gate <- release_readiness_gate_fixture(env, parsed)
  expect_identical(gate$Status[gate$Gate == "package_check"], "concern")
})

test_that("release-readiness protocol rejects stale check logs by version", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.0’",
    "* checking tests ... OK",
    "Status: OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(log_file, target_version = "0.2.1")
  expect_true(parsed$CheckPassed)
  expect_false(parsed$VersionMatchesTarget)

  gate <- release_readiness_gate_fixture(env, parsed)
  expect_identical(gate$Status[gate$Gate == "package_check"], "concern")
})

test_that("release-readiness protocol requires --as-cran provenance", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "Status: OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(
    log_file,
    target_version = "0.2.1"
  )
  expect_true(parsed$CheckPassed)
  expect_false(parsed$AsCRAN)

  gate <- release_readiness_gate_fixture(env, parsed)
  expect_identical(gate$Status[gate$Gate == "package_check"], "concern")
})

test_that("release-readiness binds a 0.2.3 candidate to frozen hashed inputs", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)
  skip_if_not_installed("digest")

  root <- tempfile("candidate-identity")
  dir.create(root, recursive = TRUE)
  description <- file.path(root, "DESCRIPTION")
  tarball <- file.path(root, "mfrmr_0.2.3.tar.gz")
  check_log <- file.path(root, "00check.log")
  specification <- file.path(root, "release-gate-spec-0.2.3.md")
  checklist <- file.path(root, "release-evidence-checklist-0.2.3.csv")
  manifest <- file.path(root, "release-candidate-manifest-0.2.3.csv")
  writeLines(c(
    "Package: mfrmr",
    "Version: 0.2.3",
    "Config/mfrmr/release-status: candidate",
    "Config/mfrmr/public-version: 0.2.2"
  ), description)
  writeLines("candidate tarball fixture", tarball)
  writeLines(c(
    "* using options '--run-donttest --as-cran'",
    "* this is package 'mfrmr' version '0.2.3'",
    "Status: OK"
  ), check_log)
  writeLines(c(
    "# gate specification fixture",
    "",
    "| Field | Value |",
    "| --- | --- |",
    "| Specification ID | `0.2.3-frozen.1` |",
    "| Confirmation authorized | Yes |"
  ), specification)
  utils::write.csv(data.frame(
    ReleaseDecision = "blocker_if_failed",
    CriterionState = "frozen_structural",
    AcceptanceRule = "Exact identity fields and hashes agree",
    stringsAsFactors = FALSE
  ), checklist, row.names = FALSE)

  manifest_values <- c(
    CandidateId = "mfrmr-0.2.3-fixture",
    PackageVersion = "0.2.3",
    SourceCommit = strrep("a", 40L),
    SourceTreeHash = strrep("b", 40L),
    TarballSHA256 = env$mfrmr_release_readiness_file_sha256(tarball),
    CheckLogSHA256 = env$mfrmr_release_readiness_file_sha256(check_log),
    SpecificationId = "0.2.3-frozen.1",
    SpecificationSHA256 = env$mfrmr_release_readiness_file_sha256(specification),
    ChecklistSHA256 = env$mfrmr_release_readiness_file_sha256(checklist),
    RVersion = R.version.string,
    Platform = R.version$platform,
    DependencyIdentity = "fixture-lock-sha256",
    Compiler = "fixture-compiler",
    EnvironmentFlags = "NOT_CRAN=false",
    DataRegistryIdentity = "fixture-data-registry",
    ModelRegistryIdentity = "fixture-model-registry",
    IntegrationRegistryIdentity = "fixture-integration-registry",
    ExternalRegistryIdentity = "not_applicable",
    SeedRegistryIdentity = "fixture-seed-registry"
  )
  utils::write.csv(data.frame(
    Field = names(manifest_values),
    Value = unname(manifest_values),
    stringsAsFactors = FALSE
  ), manifest, row.names = FALSE)
  paths <- list(
    target_version = "0.2.3",
    description = description,
    candidate_manifest = manifest,
    tarball = tarball,
    check_log = check_log,
    gate_specification = specification,
    evidence_checklist = checklist
  )

  status <- env$mfrmr_release_readiness_candidate_identity_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(status$CandidateIdentityStatus, "ok")
  expect_true(status$CandidateIdentityOK)
  expect_true(status$ReleaseStatusCandidate)
  expect_true(status$ManifestSchemaOK)
  expect_true(status$PackageVersionMatches)
  expect_true(status$TarballHashMatches)
  expect_true(status$CheckLogHashMatches)
  expect_true(status$SpecificationIdMatches)
  expect_true(status$SpecificationHashMatches)
  expect_true(status$ChecklistHashMatches)
  expect_true(status$SpecificationFrozen)
  expect_true(status$ConfirmationAuthorized)
  expect_true(status$BlockerCriteriaFrozen)

  writeLines(c(
    "Package: mfrmr",
    "Version: 0.2.3",
    "Config/mfrmr/release-status: development",
    "Config/mfrmr/public-version: 0.2.2"
  ), description)
  development <- env$mfrmr_release_readiness_candidate_identity_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(development$CandidateIdentityStatus, "concern")
  expect_false(development$CandidateIdentityOK)
  expect_false(development$ReleaseStatusCandidate)
  expect_match(
    development$Detail,
    "DESCRIPTION release status is not candidate",
    fixed = TRUE
  )
  writeLines(c(
    "Package: mfrmr",
    "Version: 0.2.3",
    "Config/mfrmr/release-status: candidate",
    "Config/mfrmr/public-version: 0.2.2"
  ), description)

  writeLines(c(
    "# gate specification fixture",
    "",
    "| Field | Value |",
    "| --- | --- |",
    "| Specification ID | `0.2.3-draft.14` |",
    "| Confirmation authorized | No |"
  ), specification)
  manifest_values[["SpecificationId"]] <- "0.2.3-draft.14"
  manifest_values[["SpecificationSHA256"]] <-
    env$mfrmr_release_readiness_file_sha256(specification)
  utils::write.csv(data.frame(
    Field = names(manifest_values),
    Value = unname(manifest_values),
    stringsAsFactors = FALSE
  ), manifest, row.names = FALSE)
  draft <- env$mfrmr_release_readiness_candidate_identity_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(draft$CandidateIdentityStatus, "concern")
  expect_true(draft$SpecificationIdMatches)
  expect_true(draft$SpecificationHashMatches)
  expect_false(draft$SpecificationFrozen)
  expect_false(draft$ConfirmationAuthorized)

  writeLines("mutated candidate tarball fixture", tarball)
  mutated <- env$mfrmr_release_readiness_candidate_identity_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(mutated$CandidateIdentityStatus, "concern")
  expect_false(mutated$CandidateIdentityOK)
  expect_false(mutated$TarballHashMatches)
  expect_match(mutated$Detail, "tarball SHA-256 mismatch", fixed = TRUE)
})

test_that("release-readiness reconstructs checklist decisions from hashed result rows", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)
  skip_if_not_installed("digest")

  root <- tempfile("gate-results")
  dir.create(root, recursive = TRUE)
  evidence <- file.path(root, "evidence.txt")
  checklist <- file.path(root, "release-evidence-checklist-0.2.3.csv")
  manifest <- file.path(root, "release-candidate-manifest-0.2.3.csv")
  results_path <- file.path(root, "release-gate-results-0.2.3.csv")
  writeLines("candidate-linked aggregate evidence", evidence)
  utils::write.csv(data.frame(
    Gate = c("G1", "G6", "G4"),
    Item = c("structural_contract", "future_guard", "replication_scope"),
    ScenarioId = c(
      "NUM-BIN-REDUCE; NUM-RSM-CORE",
      "ALL",
      "DIM-EMP-CONFIRM"
    ),
    ReleaseDecision = c(
      "blocker_if_failed",
      "roadmap_if_missing",
      "caveat_if_incomplete"
    ),
    stringsAsFactors = FALSE
  ), checklist, row.names = FALSE)
  commit <- strrep("a", 40L)
  spec_id <- "0.2.3-frozen.1"
  utils::write.csv(data.frame(
    Field = c("SourceCommit", "SpecificationId"),
    Value = c(commit, spec_id),
    stringsAsFactors = FALSE
  ), manifest, row.names = FALSE)
  evidence_hash <- env$mfrmr_release_readiness_file_sha256(evidence)
  results <- data.frame(
    Gate = c("G1", "G1", "G6", "G4"),
    Item = c(
      "structural_contract", "structural_contract", "future_guard",
      "replication_scope"
    ),
    ScenarioId = c(
      "NUM-BIN-REDUCE", "NUM-RSM-CORE", "ALL", "DIM-EMP-CONFIRM"
    ),
    CandidateCommit = commit,
    SpecId = spec_id,
    EvidenceRole = "unit",
    Metric = "exact structural rule",
    Estimate = NA_character_,
    Threshold = "all required assertions true",
    Direction = "exact",
    MonteCarloSE = NA_character_,
    NumericalSE = NA_character_,
    ReplicatesPlanned = NA_character_,
    ReplicatesRetained = NA_character_,
    FailedReplicates = NA_character_,
    Status = "ok",
    EvidencePath = "evidence.txt",
    EvidenceHash = evidence_hash,
    stringsAsFactors = FALSE
  )
  write_results <- function(value) {
    utils::write.csv(value, results_path, row.names = FALSE, na = "")
  }
  write_results(results)
  paths <- list(
    target_version = "0.2.3",
    pkg_dir = root,
    gate_results = results_path,
    evidence_checklist = checklist,
    candidate_manifest = manifest
  )
  identity <- data.frame(
    CandidateIdentityStatus = "ok",
    CandidateIdentityOK = TRUE,
    stringsAsFactors = FALSE
  )

  status <- env$mfrmr_release_readiness_gate_results_status(
    paths,
    candidate_identity_status = identity,
    target_version = "0.2.3"
  )
  expect_identical(status$GateResultsStatus, "ok")
  expect_true(status$GateResultsOK)
  expect_true(status$IdentityRowsOK)
  expect_true(status$EvidenceRowsOK)
  expect_identical(status$MissingItems, "")
  expect_identical(status$MissingScenarios, "")
  expect_identical(status$BlockingItemsNotOK, "")

  write_results(results[results$ScenarioId != "NUM-RSM-CORE", , drop = FALSE])
  missing <- env$mfrmr_release_readiness_gate_results_status(
    paths,
    candidate_identity_status = identity,
    target_version = "0.2.3"
  )
  expect_identical(missing$GateResultsStatus, "concern")
  expect_match(missing$MissingScenarios, "NUM-RSM-CORE", fixed = TRUE)

  wrong_identity <- results
  wrong_identity$CandidateCommit[1] <- strrep("b", 40L)
  write_results(wrong_identity)
  mismatched <- env$mfrmr_release_readiness_gate_results_status(
    paths,
    candidate_identity_status = identity,
    target_version = "0.2.3"
  )
  expect_identical(mismatched$GateResultsStatus, "concern")
  expect_false(mismatched$IdentityRowsOK)

  wrong_hash <- results
  wrong_hash$EvidenceHash[1] <- strrep("0", 64L)
  write_results(wrong_hash)
  tampered <- env$mfrmr_release_readiness_gate_results_status(
    paths,
    candidate_identity_status = identity,
    target_version = "0.2.3"
  )
  expect_identical(tampered$GateResultsStatus, "concern")
  expect_false(tampered$EvidenceRowsOK)

  caveated <- results
  caveated$Status[caveated$Item == "replication_scope"] <- "review"
  write_results(caveated)
  review <- env$mfrmr_release_readiness_gate_results_status(
    paths,
    candidate_identity_status = identity,
    target_version = "0.2.3"
  )
  expect_identical(review$GateResultsStatus, "review")
  expect_false(review$GateResultsOK)
  expect_match(review$CaveatItemsForReview, "G4::replication_scope", fixed = TRUE)
})

test_that("release-readiness keeps the 0.2.3 current/future API truth explicit", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION"))) {
    pkg_root <- system.file(package = "mfrmr")
  }
  paths <- env$mfrmr_release_readiness_paths(
    pkg_root,
    target_version = "0.2.3"
  )
  status <- env$mfrmr_release_readiness_public_scope_status(
    paths,
    target_version = "0.2.3"
  )

  expect_identical(status$PublicScopeStatus, "ok")
  expect_true(status$PublicScopeOK)
  expect_equal(status$BoundaryRows, status$RequiredBoundaryRows)
  expect_true(status$FutureRoutesBlocked)
  expect_true(status$VisualClaimSeparated)
  expect_true(status$ReadmeBoundaryExplicit)
  expect_true(status$FutureArgumentsAbsent)
})

test_that("release-readiness rejects stale numeric pass counts in current prose", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("prose-counts")
  dir.create(root, recursive = TRUE)
  readme <- file.path(root, "README.md")
  news <- file.path(root, "NEWS.md")
  cran_comments <- file.path(root, "cran-comments.md")
  writeLines("Current package guide without fixed test counts.", readme)
  writeLines(c(
    "# mfrmr 0.2.3",
    "",
    "Current changes use candidate-linked release evidence.",
    "",
    "# mfrmr 0.2.2",
    "Historical release record: 300 checks passed."
  ), news)
  writeLines(c(
    "## R CMD check results",
    "The installed-package selection completed with 392 passes."
  ), cran_comments)
  paths <- list(
    target_version = "0.2.3",
    readme = readme,
    news = news,
    cran_comments = cran_comments
  )

  stale <- env$mfrmr_release_readiness_prose_count_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(stale$ProseCountStatus, "concern")
  expect_false(stale$ProseCountsOK)
  expect_equal(stale$PassCountClaims, 1L)
  expect_match(stale$Examples, "392 passes", fixed = TRUE)
  expect_false(grepl("300 checks", stale$Examples, fixed = TRUE))

  writeLines(c(
    "## R CMD check results",
    "The exact candidate logs and hashes are retained in release evidence."
  ), cran_comments)
  current <- env$mfrmr_release_readiness_prose_count_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(current$ProseCountStatus, "ok")
  expect_true(current$ProseCountsOK)
  expect_equal(current$PassCountClaims, 0L)
})

test_that("release-readiness protocol rejects stale tarball and check evidence", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  dir.create(file.path(root, "R"), recursive = TRUE)
  dir.create(file.path(root, "man"), recursive = TRUE)
  dir.create(file.path(root, "vignettes"), recursive = TRUE)
  dir.create(file.path(root, "inst", "validation"), recursive = TRUE)
  writeLines("Package: mfrmr", file.path(root, "DESCRIPTION"))
  writeLines("# mfrmr", file.path(root, "README.md"))
  writeLines("# mfrmr 0.2.1", file.path(root, "NEWS.md"))
  writeLines("^inst/validation$", file.path(root, ".Rbuildignore"))
  writeLines("fit <- function() NULL", file.path(root, "R", "fit.R"))
  writeLines("\\name{fit}", file.path(root, "man", "fit.Rd"))
  writeLines("---", file.path(root, "vignettes", "workflow.Rmd"))
  writeLines(
    "repository-only helper",
    file.path(root, "inst", "validation", "gate.R")
  )

  tarball <- file.path(root, "mfrmr_0.2.1.tar.gz")
  check_log <- file.path(root, "mfrmr.Rcheck", "00check.log")
  dir.create(dirname(check_log), recursive = TRUE)
  writeLines("source archive placeholder", tarball)
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "Status: OK"
  ), check_log)

  input_files <- c(
    file.path(root, "DESCRIPTION"),
    file.path(root, "README.md"),
    file.path(root, "NEWS.md"),
    file.path(root, ".Rbuildignore"),
    file.path(root, "R", "fit.R"),
    file.path(root, "man", "fit.Rd"),
    file.path(root, "vignettes", "workflow.Rmd"),
    file.path(root, "inst", "validation", "gate.R")
  )
  base_time <- Sys.time() - 120
  invisible(lapply(input_files, Sys.setFileTime, time = base_time))
  Sys.setFileTime(tarball, base_time + 30)
  Sys.setFileTime(check_log, base_time + 60)

  paths <- list(
    pkg_dir = normalizePath(root, winslash = "/", mustWork = TRUE),
    check_log = check_log,
    tarball = tarball
  )
  fresh <- env$mfrmr_release_readiness_evidence_freshness(
    paths,
    tolerance_seconds = 0
  )
  expect_true(fresh$FreshnessOK)
  expect_true(fresh$TarballFresh)
  expect_true(fresh$CheckLogFresh)
  expect_true(fresh$CheckAfterTarball)

  Sys.setFileTime(
    file.path(root, "inst", "validation", "gate.R"),
    base_time + 90
  )
  ignored_change <- env$mfrmr_release_readiness_evidence_freshness(
    paths,
    tolerance_seconds = 0
  )
  expect_true(ignored_change$FreshnessOK)

  Sys.setFileTime(check_log, base_time + 20)
  wrong_order <- env$mfrmr_release_readiness_evidence_freshness(
    paths,
    tolerance_seconds = 0
  )
  expect_true(wrong_order$TarballFresh)
  expect_true(wrong_order$CheckLogFresh)
  expect_false(wrong_order$CheckAfterTarball)
  expect_false(wrong_order$FreshnessOK)
  Sys.setFileTime(check_log, base_time + 60)

  Sys.setFileTime(file.path(root, "R", "fit.R"), base_time + 90)
  stale <- env$mfrmr_release_readiness_evidence_freshness(
    paths,
    tolerance_seconds = 0
  )
  expect_false(stale$FreshnessOK)
  expect_false(stale$TarballFresh)
  expect_false(stale$CheckLogFresh)
  expect_match(stale$StaleInputs, "R/fit.R", fixed = TRUE)

  parsed <- env$mfrmr_release_readiness_parse_check_log(
    check_log,
    target_version = "0.2.1"
  )
  gate <- release_readiness_gate_fixture(
    env,
    parsed,
    freshness_status = stale
  )
  expect_identical(
    gate$Status[gate$Gate == "release_evidence_freshness"],
    "concern"
  )
})

test_that("release-readiness protocol finds common check-log locations", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  dir.create(file.path(root, "check", "mfrmr.Rcheck"), recursive = TRUE)
  log_file <- file.path(root, "check", "mfrmr.Rcheck", "00check.log")
  writeLines("Status: OK", log_file)

  found <- env$mfrmr_release_readiness_find_check_log(root)
  expect_identical(normalizePath(found, winslash = "/", mustWork = TRUE),
                   normalizePath(log_file, winslash = "/", mustWork = TRUE))

  stale_root_log <- file.path(root, "mfrmr.Rcheck", "00check.log")
  dir.create(dirname(stale_root_log), recursive = TRUE)
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.0’",
    "Status: OK"
  ), stale_root_log)
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "Status: OK"
  ), log_file)
  found_current <- env$mfrmr_release_readiness_find_check_log(
    root,
    target_version = "0.2.1"
  )
  expect_identical(normalizePath(found_current, winslash = "/", mustWork = TRUE),
                   normalizePath(log_file, winslash = "/", mustWork = TRUE))
})

test_that("release-readiness prefers candidate check logs over newer archives", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  candidate_dir <- file.path(root, "release-candidates", "checked")
  archive_dir <- file.path(root, "release-candidates", "win-builder")
  dir.create(candidate_dir, recursive = TRUE)
  dir.create(archive_dir, recursive = TRUE)

  candidate_log <- file.path(candidate_dir, "00check.log")
  archive_log <- file.path(archive_dir, "00check.log")
  writeLines(c(
    "* using options '--run-donttest --as-cran'",
    "* this is package 'mfrmr' version '0.2.2'",
    "Status: OK"
  ), candidate_log)
  writeLines(c(
    "* this is package 'mfrmr' version '0.2.2'",
    "Status: OK"
  ), archive_log)
  writeLines(
    "checked candidate",
    file.path(candidate_dir, "mfrmr_0.2.2.tar.gz")
  )

  base_time <- Sys.time() - 60
  Sys.setFileTime(candidate_log, base_time)
  Sys.setFileTime(archive_log, base_time + 30)

  found <- env$mfrmr_release_readiness_find_check_log(
    root,
    target_version = "0.2.2"
  )
  expect_identical(
    normalizePath(found, winslash = "/", mustWork = TRUE),
    normalizePath(candidate_log, winslash = "/", mustWork = TRUE)
  )
})

test_that("release-readiness prefers submission and checked tarballs over backups", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  checked_dir <- file.path(root, "release-candidates", "checked")
  backup_dir <- file.path(root, "release-candidates", "pre-replacement")
  dir.create(checked_dir, recursive = TRUE)
  dir.create(backup_dir, recursive = TRUE)

  checked_tarball <- file.path(checked_dir, "mfrmr_0.2.2.tar.gz")
  backup_tarball <- file.path(backup_dir, "mfrmr_0.2.2.tar.gz")
  writeLines("checked candidate", checked_tarball)
  writeLines("newer backup", backup_tarball)
  writeLines(c(
    "* this is package 'mfrmr' version '0.2.2'",
    "Status: OK"
  ), file.path(checked_dir, "00check.log"))

  base_time <- Sys.time() - 60
  Sys.setFileTime(checked_tarball, base_time)
  Sys.setFileTime(backup_tarball, base_time + 30)

  found_checked <- env$mfrmr_release_readiness_find_tarball(
    root,
    target_version = "0.2.2"
  )
  expect_identical(
    normalizePath(found_checked, winslash = "/", mustWork = TRUE),
    normalizePath(checked_tarball, winslash = "/", mustWork = TRUE)
  )

  root_tarball <- file.path(root, "mfrmr_0.2.2.tar.gz")
  writeLines("explicit submission tarball", root_tarball)
  Sys.setFileTime(root_tarball, base_time - 30)
  found_root <- env$mfrmr_release_readiness_find_tarball(
    root,
    target_version = "0.2.2"
  )
  expect_identical(
    normalizePath(found_root, winslash = "/", mustWork = TRUE),
    normalizePath(root_tarball, winslash = "/", mustWork = TRUE)
  )
})

test_that("release-readiness protocol checks CI workflow contract", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  dir.create(file.path(root, ".github", "workflows"), recursive = TRUE)
  workflow <- file.path(root, ".github", "workflows", "R-CMD-check.yaml")
  writeLines(c(
    "name: R-CMD-check",
    "matrix:",
    "  config:",
    "    - {os: macos-latest, r: 'release'}",
    "    - {os: windows-latest, r: 'release'}",
    "    - {os: ubuntu-latest, r: 'devel'}",
    "    - {os: ubuntu-latest, r: 'oldrel-1'}",
    "- uses: r-lib/actions/check-r-package@v2",
    "  with:",
    "    error-on: '\"warning\"'",
    "- name: Upload check results",
    "  uses: actions/upload-artifact@v4",
    "  with:",
    "    path: check",
    "- name: Repository validation review",
    "  run: mfrmr_release_readiness_review(pkg_dir = \".\")"
  ), workflow)

  status <- env$mfrmr_release_readiness_ci_workflow_status(workflow)
  expect_true(status$WorkflowAvailable)
  expect_true(status$MatrixIncludesMainOS)
  expect_true(status$MatrixIncludesRDevelOldrelRelease)
  expect_true(status$PackageCheckStepPresent)
  expect_true(status$WarningsAreFailures)
  expect_true(status$CheckArtifactsUploaded)
  expect_true(status$ReadinessGatePresent)
  expect_true(status$CIWorkflowOK)
})

test_that("release-readiness protocol checks source-truth alignment", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  dir.create(file.path(root, "inst", "validation"), recursive = TRUE)
  writeLines(c(
    "Package: mfrmr",
    "Version: 0.2.2",
    "Date: 2026-07-26",
    "Config/mfrmr/release-status: candidate",
    "Config/mfrmr/public-version: 0.2.1"
  ), file.path(root, "DESCRIPTION"))
  writeLines(c(
    "cff-version: 1.2.0",
    "version: \"0.2.2\"",
    "date-released: \"2026-07-26\""
  ), file.path(root, "CITATION.cff"))
  writeLines("^ROADMAP\\.md$", file.path(root, ".Rbuildignore"))
  writeLines(c(
    "# Roadmap",
    "This file is the single source of truth."
  ), file.path(root, "ROADMAP.md"))
  writeLines(
    "Current contract: gpcm_capability_matrix().",
    file.path(root, "inst", "validation", "gpcm-post-0.2.2-roadmap.md")
  )
  paths <- env$mfrmr_release_readiness_paths(root, target_version = "0.2.2")
  status <- env$mfrmr_release_readiness_source_truth_status(paths)

  expect_true(status$VersionMatchesCFF)
  expect_true(status$DateMatchesCFF)
  expect_identical(status$ReleaseStatus, "candidate")
  expect_identical(status$PublicVersion, "0.2.1")
  expect_true(status$LifecycleStatusOK)
  expect_true(status$PublicVersionOK)
  expect_true(status$ReleaseDatePolicyOK)
  expect_true(status$RoadmapAvailable)
  expect_true(status$RoadmapExcludedFromTarball)
  expect_true(status$RoadmapAuthoritative)
  expect_identical(status$DevelopmentOnlyCurrentClaims, "")
  expect_true(status$SourceTruthOK)

  writeLines(
    "The current API is mfrmr_model_family_scope().",
    paths$gpcm_roadmap
  )
  stale <- env$mfrmr_release_readiness_source_truth_status(paths)
  expect_false(stale$SourceTruthOK)
  expect_match(
    stale$DevelopmentOnlyCurrentClaims,
    "mfrmr_model_family_scope()",
    fixed = TRUE
  )

  writeLines(c(
    "Package: mfrmr",
    "Version: 0.2.3",
    "Config/mfrmr/release-status: development",
    "Config/mfrmr/public-version: 0.2.2"
  ), paths$description)
  writeLines(c(
    "cff-version: 1.2.0",
    "version: \"0.2.3\""
  ), paths$cff)
  writeLines(
    "Current contract: gpcm_capability_matrix().",
    paths$gpcm_roadmap
  )
  development <- env$mfrmr_release_readiness_source_truth_status(paths)
  expect_identical(development$ReleaseStatus, "development")
  expect_identical(development$PublicVersion, "0.2.2")
  expect_true(development$DevelopmentDatesUnset)
  expect_true(development$ReleaseDatePolicyOK)
  expect_true(development$SourceTruthOK)

  writeLines(c(
    "cff-version: 1.2.0",
    "version: \"0.2.3\"",
    "date-released: \"2026-08-03\""
  ), paths$cff)
  prematurely_dated <- env$mfrmr_release_readiness_source_truth_status(paths)
  expect_false(prematurely_dated$DevelopmentDatesUnset)
  expect_false(prematurely_dated$ReleaseDatePolicyOK)
  expect_false(prematurely_dated$SourceTruthOK)
})

test_that("release-readiness protocol enforces semantic example guards", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION"))) {
    pkg_root <- system.file(package = "mfrmr")
  }
  status <- env$mfrmr_release_readiness_example_policy_status(pkg_root)

  expect_true(status$SourceAvailable)
  expect_true(status$GeneratedRdAvailable)
  expect_identical(
    status$DontrunSourceTargets,
    "normalize_conquest_overlap_exports, review_conquest_overlap"
  )
  expect_identical(status$ExamplesIfSourceTargets, "launch_mfrmr_viewer")
  expect_gt(status$DonttestRdPages, 0L)
  expect_identical(status$Detail, "")
  expect_true(status$ExamplePolicyOK)

  status$ExamplePolicyOK <- FALSE
  status$Detail <- "unexpected dontrun target"
  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* using option ‘--as-cran’",
    "* this is package ‘mfrmr’ version ‘0.2.2’",
    "Status: OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(
    log_file,
    target_version = "0.2.2"
  )
  gate <- release_readiness_gate_fixture(
    env,
    parsed,
    example_policy_status = status
  )
  expect_identical(
    gate$Status[gate$Gate == "example_policy"],
    "concern"
  )
})

test_that("release-readiness protocol checks GPCM scope alignment", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION"))) {
    pkg_root <- system.file(package = "mfrmr")
  }
  paths <- env$mfrmr_release_readiness_paths(pkg_root, target_version = "0.2.2")
  checklist_status <- env$mfrmr_release_readiness_checklist_status(paths$evidence_checklist)
  status <- env$mfrmr_release_readiness_gpcm_scope_status(
    paths = paths,
    checklist_status = checklist_status
  )

  expect_s3_class(status, "data.frame")
  expect_equal(status$GPCMScopeStatus[1], "ok")
  expect_gt(status$OutstandingRows[1], 0L)
  expect_true(status$GuidanceComplete[1])
  expect_true(status$RoadmapCoversOutstanding[1])
  expect_true(status$RuntimeGuardCoverageOK[1])
  expect_true(status$RuntimeGuardStatusOK[1])
  expect_gt(status$RuntimeGuardRows[1], 0L)
  expect_true(status$RuntimeGuardAreas[1] >= status$OutstandingRows[1])
  expect_identical(status$MissingRuntimeGuardAreas[1], "")
  expect_true(status$ChecklistRoadmapRows[1] >= status$OutstandingRows[1])
})

test_that("release-readiness protocol reviews the source tree shape", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION"))) {
    pkg_root <- system.file(package = "mfrmr")
  }
  expect_true(nzchar(pkg_root))
  review <- env$mfrmr_release_readiness_review(pkg_dir = pkg_root)
  expect_s3_class(review, "mfrmr_release_readiness_review")
  expect_true(all(c(
    "prompt_steps", "gate_summary", "release_decision",
    "version_status", "check_status", "freshness_status", "ci_workflow_status",
    "source_truth_status", "candidate_identity_status", "public_scope_status",
    "gate_results_status", "prose_count_status",
    "terminology_status", "example_policy_status",
    "check_timing_scope",
    "checklist_status", "gpcm_scope_status", "external_recovery_status"
  ) %in% names(review)))
  expect_false(review$external_recovery_status$ExternalRecoveryRequested[1])
  description_version <- as.character(review$version_status$DescriptionVersion[1])
  if (grepl("\\.9000$", description_version)) {
    expect_false(isTRUE(review$version_status$VersionOK[1]))
    expect_true(isTRUE(review$version_status$DevelopmentLabelPresent[1]))
    expect_match(review$version_status$NewsHeading[1], "development version", fixed = TRUE)
  } else {
    expect_true(isTRUE(review$version_status$VersionOK[1]))
  }
  expect_true(file.exists(review$paths$gpcm_roadmap))
  expect_true(isTRUE(review$source_truth_status$SourceTruthOK[1]))
  contract_applies <- utils::compareVersion(
    description_version,
    "0.2.3"
  ) >= 0L
  if (contract_applies) {
    expect_identical(
      review$candidate_identity_status$CandidateIdentityStatus[1],
      "concern"
    )
    expect_identical(
      review$gate_results_status$GateResultsStatus[1],
      "concern"
    )
    expect_identical(
      review$public_scope_status$PublicScopeStatus[1],
      "ok"
    )
    expect_identical(
      review$prose_count_status$ProseCountStatus[1],
      "ok"
    )
  } else {
    expect_identical(
      review$candidate_identity_status$CandidateIdentityStatus[1],
      "not_applicable"
    )
    expect_identical(
      review$gate_results_status$GateResultsStatus[1],
      "not_applicable"
    )
    expect_identical(
      review$public_scope_status$PublicScopeStatus[1],
      "not_applicable"
    )
    expect_identical(
      review$prose_count_status$ProseCountStatus[1],
      "not_applicable"
    )
  }
  expect_equal(review$gpcm_scope_status$GPCMScopeStatus[1], "ok")
  if (file.exists(file.path(pkg_root, ".github", "workflows", "R-CMD-check.yaml"))) {
    expect_true(isTRUE(review$ci_workflow_status$CIWorkflowOK[1]))
  }
  expect_true(isTRUE(review$terminology_status$TerminologyOK[1]))
  expect_true(isTRUE(review$example_policy_status$ExamplePolicyOK[1]))
  expect_identical(
    review$gate_summary$Status[review$gate_summary$Gate == "example_policy"],
    "ok"
  )
  expect_true(isTRUE(review$checklist_status$ChecklistAvailable[1]))
})

test_that("GPCM stress manifest covers every prespecified axis pair", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation", "gpcm-stress-covering-grid-0.2.3.R"
  )
  expect_true(file.exists(runner))
  env <- new.env(parent = globalenv())
  source(runner, local = env)

  pilot <- env$mfrmr_gpcm_stress_manifest("pilot")
  confirmation <- env$mfrmr_gpcm_stress_manifest("confirmation")
  coverage <- env$mfrmr_gpcm_stress_coverage(pilot)

  expect_identical(nrow(pilot), 70L)
  expect_identical(sum(pilot$DesignSource == "mandatory_corner"), 12L)
  expect_identical(coverage$summary$RequiredPairs, 1330L)
  expect_identical(coverage$summary$UncoveredPairs, 0L)
  expect_true(coverage$summary$PairwiseComplete)
  expect_identical(anyDuplicated(pilot$ScenarioId), 0L)
  expect_false(any(pilot$Seed %in% confirmation$Seed))
  expect_true(all(!pilot$NumericExternalEligible))
  expect_true(all(pilot$ThresholdStatus == "pilot_required_not_frozen"))
  expect_true(all(pilot$ReleaseUse == "calibration_only"))
  expect_true(all(nchar(pilot$ManifestHash) == 64L))

  one_level <- pilot[pilot$SlopeLevels == "one", , drop = FALSE]
  expect_gt(nrow(one_level), 0L)
  expect_true(all(!one_level$Executable))
  expect_true(all(
    one_level$ExecutionReason == "single_slope_level_generator_not_supported"
  ))
})

test_that("GPCM stress smoke generator is deterministic and fails closed", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation", "gpcm-stress-covering-grid-0.2.3.R"
  )
  env <- new.env(parent = globalenv())
  source(runner, local = env)
  smoke <- env$mfrmr_gpcm_stress_manifest("smoke")

  executable <- smoke[smoke$Executable, , drop = FALSE]
  support <- lapply(seq_len(nrow(executable)), function(i) {
    generated <- env$mfrmr_gpcm_stress_build(executable[i, , drop = FALSE])
    transformed <- env$mfrmr_gpcm_stress_transform(
      generated, executable[i, , drop = FALSE]
    )
    env$mfrmr_gpcm_stress_support(
      transformed$data, executable$NCategories[i]
    )
  })
  hashes <- vapply(support, `[[`, character(1), "RetainedDataHash")
  expect_true(all(nchar(hashes) == 64L))
  expect_identical(anyDuplicated(hashes), 0L)

  dry <- env$mfrmr_run_gpcm_stress_covering_grid(
    "smoke", dry_run = TRUE, verbose = FALSE
  )
  dry_summary <- env$mfrmr_summarize_gpcm_stress_covering_grid(dry)
  expect_true(dry_summary$PairwiseComplete)
  expect_identical(dry_summary$UncoveredPairs, 0L)
  expect_identical(dry_summary$KnownGapRows, 1L)
  expect_identical(dry_summary$ExecutedRows, 0L)
  expect_identical(dry_summary$NumericExternalEligibleRows, 0L)

  negative_ids <- smoke$ScenarioId[smoke$CornerId %in% c(
    "zero_shared_jml", "internal_zero_mml"
  )]
  negative <- env$mfrmr_run_gpcm_stress_covering_grid(
    "smoke", scenario_ids = negative_ids, maxit = 50L, verbose = FALSE
  )
  expect_true(all(negative$results$Executed))
  expect_true(all(!negative$results$FalseReady))
  expect_identical(
    negative$results$MinCommonPersons[
      negative$results$CornerId == "zero_shared_jml"
    ],
    0L
  )
  expect_identical(
    negative$results$ZeroCategories[
      negative$results$CornerId == "internal_zero_mml"
    ],
    1L
  )
  expect_true(all(!negative$results$NumericExternalEligible))
})

test_that("GPCM local-dependence corner reaches exploratory residual PCA", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation", "gpcm-stress-covering-grid-0.2.3.R"
  )
  env <- new.env(parent = globalenv())
  source(runner, local = env)
  smoke <- env$mfrmr_gpcm_stress_manifest("smoke")
  scenario_id <- smoke$ScenarioId[
    smoke$CornerId == "local_dependence_jml"
  ]
  result <- env$mfrmr_run_gpcm_stress_covering_grid(
    "smoke",
    scenario_ids = scenario_id,
    run_diagnostics = TRUE,
    maxit = 60L,
    verbose = FALSE
  )
  expect_identical(result$results$RunState, "completed_calibration")
  expect_identical(result$results$PCAState, "available_exploratory")
  expect_true(is.finite(result$results$PCAFirstEigenvalue))
  expect_gt(result$results$ExactCellDuplicates, 0L)
  expect_identical(result$results$DistinguishedCellDuplicates, 0L)
  expect_false(result$results$InferenceReady)
  expect_false(result$results$FalseReady)
})

test_that("target-scale sparse feasibility execution is fixed and guarded", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation",
    "target-scale-sparse-stress-pilot-0.2.3.R"
  )
  expect_true(file.exists(runner))
  env <- new.env(parent = globalenv())
  source(runner, local = env)

  dry <- env$mfrmr_run_target_scale_sparse_stress(
    dry_run = TRUE, run_diagnostics = TRUE, progress = FALSE
  )
  expect_identical(
    env$mfrmr_gpcm_repilot_hash_file(runner),
    "50ee40562080cc5b2561d7e93bd9ec0eb13c451a6d728b8d61071bd0b306e0c8"
  )
  expect_identical(
    dry$registry$ScenarioId,
    c(
      "GPCM-P-008", "GPCM-P-018", "GPCM-P-019",
      "GPCM-P-024", "GPCM-P-031", "GPCM-P-040"
    )
  )
  expect_true(all(dry$registry$SampleSize == "target_sparse"))
  expect_true(all(dry$registry$NPersons == 400L))
  expect_true(all(dry$registry$Executable))
  expect_true(all(dry$registry$ExecutedReplicates == 1L))
  expect_true(all(dry$registry$DeclaredPilotReplicates == 5L))
  expect_true(all(!dry$registry$ConfirmationAuthorized))
  expect_identical(dry$execution_identity$SelectedCells, 6L)
  expect_identical(
    dry$execution_identity$EvidenceUse,
    "capacity_feasibility_calibration_only"
  )
  expect_false(dry$execution_identity$ConfirmationAuthorized)
  expect_false(dry$confirmation_authorized)
  expect_identical(nchar(dry$execution_identity$DeclaredManifestSHA256), 64L)
  expect_identical(nchar(dry$execution_identity$SelectedManifestSHA256), 64L)
  expect_false(identical(
    dry$execution_identity$DeclaredManifestSHA256,
    dry$execution_identity$SelectedManifestSHA256
  ))

  expect_error(
    env$mfrmr_run_target_scale_sparse_stress(
      dry_run = FALSE, progress = FALSE
    ),
    "authorize = TRUE",
    fixed = TRUE
  )
  existing_output <- tempfile("target-scale-existing-")
  dir.create(existing_output)
  on.exit(unlink(existing_output, recursive = TRUE, force = TRUE), add = TRUE)
  expect_error(
    env$mfrmr_run_target_scale_sparse_stress(
      dry_run = FALSE, authorize = TRUE, output_dir = existing_output,
      progress = FALSE
    ),
    "must not already exist"
  )
  expect_error(
    env$mfrmr_run_target_scale_sparse_stress(
      dry_run = TRUE, quad_points = 2L, progress = FALSE
    ),
    "quad_points"
  )
})

test_that("target-scale completion markers fail closed on artifact changes", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation",
    "target-scale-sparse-stress-pilot-0.2.3.R"
  )
  env <- new.env(parent = globalenv())
  source(runner, local = env)
  env$mfrmr_target_scale_require_support()

  output_dir <- tempfile("target-scale-completion-")
  dir.create(output_dir)
  on.exit(unlink(output_dir, recursive = TRUE, force = TRUE), add = TRUE)
  artifact <- file.path(output_dir, "result.txt")
  writeLines("fixed target-scale result", artifact, useBytes = TRUE)
  inventory <- env$mfrmr_target_scale_artifact_inventory(output_dir)
  marker <- list(
    schema = "mfrmr-target-scale-feasibility-completion-v1",
    execution_sha256 = paste(rep("a", 64L), collapse = ""),
    artifacts = inventory,
    artifact_inventory_sha256 = env$mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = "2026-08-05 00:00:00 UTC",
    confirmation_authorized = FALSE
  )
  saveRDS(marker, file.path(output_dir, "run-complete.rds"))
  expect_invisible(env$mfrmr_target_scale_validate_completion(
    output_dir, marker$execution_sha256
  ))
  writeLines("changed target-scale result", artifact, useBytes = TRUE)
  expect_error(
    env$mfrmr_target_scale_validate_completion(
      output_dir, marker$execution_sha256
    ),
    "hash or size mismatch"
  )
})

test_that("target baseline and bridge execution is fixed and guarded", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation",
    "target-scale-baseline-bridge-pilot-0.2.3.R"
  )
  expect_true(file.exists(runner))
  old_wd <- setwd(pkg_root)
  on.exit(setwd(old_wd), add = TRUE)
  env <- new.env(parent = globalenv())
  source(runner, local = env)

  dry <- env$mfrmr_run_target_scale_baseline_bridge(
    dry_run = TRUE, progress = FALSE
  )
  expect_identical(
    env$mfrmr_gpcm_repilot_hash_file(runner),
    "6caf66044fff6a1bced6fcdb605bef061143f8115f081a6ea40055ef112637d5"
  )
  expect_identical(dry$execution_identity$DataCells, 13L)
  expect_identical(dry$execution_identity$Routes, 26L)
  expect_setequal(unique(dry$registry$Model), c("RSM", "PCM", "GPCM"))
  expect_setequal(unique(dry$registry$Method), c("JML", "MML"))
  expect_identical(nchar(
    dry$execution_identity$DeclaredManifestSHA256
  ), 64L)
  expect_false(dry$execution_identity$PCARun)
  expect_false(dry$execution_identity$ConfirmationAuthorized)
  expect_false(dry$confirmation_authorized)
  bridge <- dry$registry[
    dry$registry$Design == "two_rater_bridge_gradient", , drop = FALSE
  ]
  expect_identical(sort(unique(bridge$LinkPersons)),
                   c(0L, 1L, 2L, 5L, 10L, 20L, 40L))
  expect_identical(unique(bridge$Seed), 248007L)
  expect_identical(unique(bridge$TruthSeedGroup), "bridge_common_truth")

  cells <- bridge[!duplicated(bridge$DataCellId), , drop = FALSE]
  generated <- lapply(seq_len(nrow(cells)), function(i) {
    env$mfrmr_target_bridge_build(cells[i, , drop = FALSE])
  })
  expect_identical(
    vapply(generated, function(x) x$support$MinCommonPersons, integer(1)),
    c(0L, 1L, 2L, 5L, 10L, 20L, 40L)
  )
  expect_length(unique(vapply(
    generated, function(x) x$TruthHash, character(1)
  )), 1L)

  expect_error(
    env$mfrmr_run_target_scale_baseline_bridge(
      dry_run = FALSE, progress = FALSE
    ),
    "authorize = TRUE",
    fixed = TRUE
  )
  existing_output <- tempfile("target-bridge-existing-")
  dir.create(existing_output)
  on.exit(unlink(existing_output, recursive = TRUE, force = TRUE), add = TRUE)
  expect_error(
    env$mfrmr_run_target_scale_baseline_bridge(
      dry_run = FALSE, authorize = TRUE, output_dir = existing_output,
      progress = FALSE
    ),
    "must not already exist"
  )
  expect_error(
    env$mfrmr_run_target_scale_baseline_bridge(
      dry_run = TRUE, quad_points = 2L, progress = FALSE
    ),
    "quad_points"
  )
})

test_that("target baseline completion markers fail closed on artifact changes", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation",
    "target-scale-baseline-bridge-pilot-0.2.3.R"
  )
  old_wd <- setwd(pkg_root)
  on.exit(setwd(old_wd), add = TRUE)
  env <- new.env(parent = globalenv())
  source(runner, local = env)
  env$mfrmr_target_bridge_require_support()

  output_dir <- tempfile("target-bridge-completion-")
  dir.create(output_dir)
  on.exit(unlink(output_dir, recursive = TRUE, force = TRUE), add = TRUE)
  artifact <- file.path(output_dir, "result.txt")
  writeLines("fixed target bridge result", artifact, useBytes = TRUE)
  inventory <- env$mfrmr_target_scale_artifact_inventory(output_dir)
  marker <- list(
    schema = "mfrmr-target-baseline-bridge-completion-v1",
    execution_sha256 = paste(rep("b", 64L), collapse = ""),
    artifacts = inventory,
    artifact_inventory_sha256 = env$mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = "2026-08-05 00:00:00 UTC",
    confirmation_authorized = FALSE
  )
  saveRDS(marker, file.path(output_dir, "run-complete.rds"))
  expect_invisible(env$mfrmr_target_bridge_validate_completion(
    output_dir, marker$execution_sha256
  ))
  writeLines("changed target bridge result", artifact, useBytes = TRUE)
  expect_error(
    env$mfrmr_target_bridge_validate_completion(
      output_dir, marker$execution_sha256
    ),
    "hash or size mismatch"
  )
})

test_that("JML bottleneck decomposition manifest is fixed and guarded", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation",
    "jml-bottleneck-decomposition-pilot-0.2.3.R"
  )
  expect_true(file.exists(runner))
  old_wd <- setwd(pkg_root)
  on.exit(setwd(old_wd), add = TRUE)
  env <- new.env(parent = globalenv())
  source(runner, local = env)

  dry <- env$mfrmr_run_jml_bottleneck_profile(
    dry_run = TRUE, progress = FALSE
  )
  expect_identical(
    env$mfrmr_gpcm_repilot_hash_file(runner),
    "fd8e11b52d09815d19a714090b02bbf76373a4748128b078a1fdc7a30e2f8ba5"
  )
  expect_identical(dry$execution_identity$DataCells, 14L)
  expect_identical(dry$execution_identity$Routes, 34L)
  expect_identical(nchar(
    dry$execution_identity$DeclaredManifestSHA256
  ), 64L)
  expect_false(dry$execution_identity$PCARun)
  expect_false(dry$execution_identity$ConfirmationAuthorized)
  expect_false(dry$confirmation_authorized)
  routes <- dry$registry
  expect_identical(sum(
    routes$Method == "JML" & routes$OptimizerRequested == "auto"
  ), 14L)
  expect_identical(sum(
    routes$Method == "MML" & routes$OptimizerRequested == "auto"
  ), 14L)
  expect_identical(sum(routes$OptimizerRequested == "BFGS"), 5L)
  expect_identical(sum(routes$OptimizerRequested == "L-BFGS-B"), 1L)
  expect_setequal(
    routes$DataCellId[routes$OptimizerRequested == "BFGS"],
    c("JBP-P200", "JBP-P400", "JBP-R12", "JBP-C12-E04",
      "JBP-P200-X20")
  )

  cells <- env$mfrmr_jml_profile_cells()
  generated <- lapply(seq_len(nrow(cells)), function(i) {
    env$mfrmr_jml_profile_build(cells[i, , drop = FALSE])
  })
  expect_identical(
    vapply(generated, function(x) x$support$Rows, integer(1)),
    c(600L, 1200L, 2400L, 4800L, rep(2400L, 6L),
      1200L, 4800L, 7200L, 2400L)
  )
  expect_true(all(vapply(
    generated, function(x) x$support$Rows == x$support$ExpectedRows,
    logical(1)
  )))
  master_groups <- split(seq_len(nrow(cells)), cells$MasterGroup)
  expect_true(all(vapply(master_groups, function(index) {
    length(unique(vapply(
      generated[index], function(x) x$MasterTruthHash, character(1)
    ))) == 1L
  }, logical(1))))
  p200 <- which(cells$DataCellId == "JBP-P200")
  x20 <- which(cells$DataCellId == "JBP-P200-X20")
  expect_identical(generated[[p200]]$CellTruthHash,
                   generated[[x20]]$CellTruthHash)
  expect_identical(generated[[x20]]$support$ForcedExtremePersons, 40L)
  expect_identical(generated[[x20]]$support$DataExtremeLowN, 20L)
  expect_identical(generated[[x20]]$support$DataExtremeHighN, 20L)

  expect_error(
    env$mfrmr_run_jml_bottleneck_profile(
      dry_run = FALSE, progress = FALSE
    ),
    "authorize = TRUE",
    fixed = TRUE
  )
  existing_output <- tempfile("jml-profile-existing-")
  dir.create(existing_output)
  on.exit(unlink(existing_output, recursive = TRUE, force = TRUE), add = TRUE)
  expect_error(
    env$mfrmr_run_jml_bottleneck_profile(
      dry_run = FALSE, authorize = TRUE, output_dir = existing_output,
      progress = FALSE
    ),
    "must not already exist"
  )
  expect_error(
    env$mfrmr_run_jml_bottleneck_profile(
      dry_run = TRUE, quad_points = 2L, progress = FALSE
    ),
    "quad_points"
  )
  expect_error(
    env$mfrmr_run_jml_bottleneck_profile(
      dry_run = TRUE, reltol = 0, progress = FALSE
    ),
    "reltol"
  )
})

test_that("JML profile completion markers fail closed on artifact changes", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation",
    "jml-bottleneck-decomposition-pilot-0.2.3.R"
  )
  old_wd <- setwd(pkg_root)
  on.exit(setwd(old_wd), add = TRUE)
  env <- new.env(parent = globalenv())
  source(runner, local = env)
  env$mfrmr_jml_profile_require_support()

  output_dir <- tempfile("jml-profile-completion-")
  dir.create(output_dir)
  on.exit(unlink(output_dir, recursive = TRUE, force = TRUE), add = TRUE)
  artifact <- file.path(output_dir, "result.txt")
  writeLines("fixed JML profile result", artifact, useBytes = TRUE)
  inventory <- env$mfrmr_target_scale_artifact_inventory(output_dir)
  marker <- list(
    schema = "mfrmr-jml-bottleneck-profile-completion-v1",
    execution_sha256 = paste(rep("c", 64L), collapse = ""),
    artifacts = inventory,
    artifact_inventory_sha256 = env$mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = "2026-08-05 00:00:00 UTC",
    confirmation_authorized = FALSE
  )
  saveRDS(marker, file.path(output_dir, "run-complete.rds"))
  expect_invisible(env$mfrmr_jml_profile_validate_completion(
    output_dir, marker$execution_sha256
  ))
  writeLines("changed JML profile result", artifact, useBytes = TRUE)
  expect_error(
    env$mfrmr_jml_profile_validate_completion(
      output_dir, marker$execution_sha256
    ),
    "hash or size mismatch"
  )
})

test_that("GPCM attribution manifest isolates one axis and four fit routes", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation",
    "gpcm-isolated-attribution-pilot-0.2.3.R"
  )
  expect_true(file.exists(runner))
  env <- new.env(parent = globalenv())
  source(runner, local = env)

  pilot <- env$mfrmr_gpcm_attribution_manifest("pilot")
  audit <- env$mfrmr_gpcm_attribution_manifest_audit(pilot)
  expect_identical(audit$Arms, 40L)
  expect_identical(audit$Rows, 800L)
  expect_identical(audit$Replicates, 5L)
  expect_true(audit$FourRoutesPerDataCell)
  expect_true(audit$CompleteRouteSetPerDataCell)
  expect_true(audit$OneSeedPerDataCell)
  expect_true(audit$OneAxisChangePerChallenge)
  expect_true(audit$KnownOneLevelGap)
  expect_true(audit$ConfirmationSeparated)
  expect_false(audit$ConfirmationAuthorized)
  expect_identical(audit$NumericExternalEligibleRows, 0L)
  expect_identical(audit$FrozenThresholdRows, 0L)
  expect_identical(anyDuplicated(pilot$ScenarioId), 0L)
  expect_true(all(pilot$ReleaseUse == "calibration_only"))
  expect_true(all(pilot$ThresholdStatus == "pilot_required_not_frozen"))
  expect_true(all(nchar(pilot$ManifestHash) == 64L))

  expect_error(
    env$mfrmr_run_gpcm_isolated_attribution_pilot(
      "pilot", reps = 1L, progress = FALSE
    ),
    "resource-significant"
  )
  dry <- env$mfrmr_run_gpcm_isolated_attribution_pilot(
    "pilot", reps = 1L, dry_run = TRUE, progress = FALSE
  )
  expect_identical(nrow(dry$manifest), 160L)
  expect_false(dry$confirmation_authorized)
  expect_identical(nrow(dry$results), 0L)
})

test_that("GPCM attribution routes retain identical paired data and fail closed", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation",
    "gpcm-isolated-attribution-pilot-0.2.3.R"
  )
  env <- new.env(parent = globalenv())
  source(runner, local = env)
  result <- env$mfrmr_run_gpcm_isolated_attribution_pilot(
    "smoke",
    arms = c("reference", "assignment_zero_shared"),
    maxit = 30L,
    quad_points = 5L,
    progress = FALSE
  )

  expect_identical(result$summary$SelectedRows, 8L)
  expect_identical(result$summary$DataCells, 2L)
  expect_identical(result$summary$FalseReadyRows, 0L)
  expect_identical(result$summary$PairIdentityViolations, 0L)
  expect_true(all(result$results$PairedDataIdentity))
  expect_true(all(!result$results$NumericExternalEligible))
  expect_true(all(!result$results$SlopePrimaryMetricEligible))
  hashes <- split(result$results$RetainedDataHash, result$results$DataCellId)
  expect_true(all(vapply(hashes, function(x) length(unique(x)) == 1L,
                         logical(1))))
  reference <- result$results[result$results$ArmId == "reference", ]
  expect_true(all(is.finite(reference$StepRMSE)))
  expect_true(all(reference$StepContrastN == 12L))
  zero_shared <- result$results[
    result$results$ArmId == "assignment_zero_shared", , drop = FALSE
  ]
  expect_true(all(zero_shared$MinCommonPersons == 0L))
  expect_true(all(!zero_shared$FalseReady))
  expect_true(all(!result$contrasts$RecoveryClaimEligible))
  expect_true(all(grepl("not_a_causal", result$contrasts$Interpretation,
                        fixed = TRUE)))
})

test_that("GPCM replicated pilot prespecifies tiers and uncertainty summaries", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation",
    "gpcm-attribution-replicated-pilot-0.2.3.R"
  )
  expect_true(file.exists(runner))
  env <- new.env(parent = globalenv())
  source(runner, local = env)

  dry <- env$mfrmr_run_gpcm_attribution_replicated_pilot(
    "feasibility", dry_run = TRUE, progress = FALSE
  )
  expect_identical(dry$registry$Arms, 10L)
  expect_identical(dry$registry$Replicates, 2L)
  expect_identical(dry$registry$DataCells, 20L)
  expect_identical(dry$registry$AnalysisRows, 80L)
  expect_false(dry$registry$ConfirmationAuthorized)
  expect_identical(dry$registry$ThresholdStatus,
                   "pilot_required_not_frozen")
  expect_false(dry$confirmation_authorized)
  expect_null(dry$run)
  expect_identical(nchar(dry$execution_identity$ExecutionSHA256), 64L)
  expect_identical(dry$registry$Maxit, 120L)
  expect_identical(dry$registry$QuadPoints, 7L)
  expect_true(dry$registry$RunPCA)
  expect_error(
    env$mfrmr_run_gpcm_attribution_replicated_pilot(
      "core", reps = 1L, progress = FALSE
    ),
    "authorize_core"
  )
  expect_error(
    env$mfrmr_run_gpcm_attribution_replicated_pilot(
      "expanded", reps = 1L, progress = FALSE
    ),
    "authorize_expanded"
  )

  interval <- env$mfrmr_gpcm_repilot_wilson(0L, 2L)
  expect_equal(interval[["Lower"]], 0, tolerance = 1e-12)
  expect_equal(interval[["Upper"]], 0.6576198, tolerance = 1e-6)

  numeric_input <- data.frame(
    ArmId = c("reference", "reference"),
    ChangedAxis = c(NA_character_, NA_character_),
    ChangedLevel = c(NA_character_, NA_character_),
    Route = c("GPCM_MML", "GPCM_MML"),
    FitModel = c("GPCM", "GPCM"),
    FitMethod = c("MML", "MML"),
    PersonRMSE = c(0.3, 0.5),
    stringsAsFactors = FALSE
  )
  numeric_summary <- env$mfrmr_gpcm_repilot_numeric_summary(
    numeric_input,
    value_names = "PersonRMSE",
    group_names = c(
      "ArmId", "ChangedAxis", "ChangedLevel", "Route", "FitModel",
      "FitMethod"
    )
  )
  expect_identical(nrow(numeric_summary), 1L)
  expect_true(is.na(numeric_summary$ChangedAxis))
  expect_identical(numeric_summary$N, 2L)
  expect_equal(numeric_summary$Mean, 0.4, tolerance = 1e-12)
  expect_true(is.finite(numeric_summary$MCSE))

  manifest <- dry$registry
  expect_identical(nchar(manifest$ManifestHash), 64L)
})

test_that("GPCM replicated checkpoints resume atomically and fail closed", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation",
    "gpcm-attribution-replicated-pilot-0.2.3.R"
  )
  env <- new.env(parent = globalenv())
  source(runner, local = env)
  env$mfrmr_gpcm_repilot_require_runner()

  calls <- 0L
  env$mfrmr_gpcm_attribution_run_one <- function(
      row, run_pca = FALSE, maxit = NULL, quad_points = 7L) {
    calls <<- calls + 1L
    out <- env$mfrmr_gpcm_attribution_empty_result(row, "fitted")
    out$Executed <- TRUE
    out$GenerationSucceeded <- TRUE
    out$FitSucceeded <- TRUE
    out$RuntimeSeconds <- 1
    out$RetainedDataHash <- paste0("retained-", row$DataCellId)
    out$FitReadiness <- "ready"
    out$InferenceReady <- TRUE
    out$PersonN <- 1L
    out$PersonRMSE <- as.numeric(row$Replicate) / 10
    out$StepContrastN <- 1L
    out$PCAState <- if (isTRUE(run_pca)) {
      "available_exploratory"
    } else {
      "not_run"
    }
    out
  }

  resumed_dir <- tempfile("gpcm-repilot-resume-")
  fresh_dir <- tempfile("gpcm-repilot-fresh-")
  dir.create(resumed_dir)
  dir.create(fresh_dir)
  on.exit(unlink(c(resumed_dir, fresh_dir), recursive = TRUE, force = TRUE),
          add = TRUE)

  expect_error(
    env$mfrmr_run_gpcm_attribution_replicated_pilot(
      "feasibility", reps = 1L, maxit = 11L, quad_points = 3L,
      run_pca = FALSE, progress = FALSE, output_dir = resumed_dir,
      interrupt_after_cells = 1L
    ),
    class = "mfrmr_gpcm_repilot_interruption"
  )
  checkpoint_dir <- file.path(resumed_dir, "checkpoints")
  expect_identical(length(list.files(checkpoint_dir, pattern = "[.]rds$")),
                   1L)
  expect_identical(calls, 4L)
  expect_error(
    env$mfrmr_run_gpcm_attribution_replicated_pilot(
      "feasibility", reps = 1L, maxit = 11L, quad_points = 3L,
      run_pca = FALSE, progress = FALSE, output_dir = resumed_dir
    ),
    "require `resume = TRUE`"
  )
  unexpected <- file.path(checkpoint_dir, "unexpected.rds")
  saveRDS(list(not = "a checkpoint"), unexpected)
  expect_error(
    env$mfrmr_run_gpcm_attribution_replicated_pilot(
      "feasibility", reps = 1L, maxit = 11L, quad_points = 3L,
      run_pca = FALSE, progress = FALSE, output_dir = resumed_dir,
      resume = TRUE
    ),
    "unexpected RDS files"
  )
  unlink(unexpected)
  writeLines("orphan temporary payload",
             file.path(checkpoint_dir, ".orphan.partial"))

  resumed <- env$mfrmr_run_gpcm_attribution_replicated_pilot(
    "feasibility", reps = 1L, maxit = 11L, quad_points = 3L,
    run_pca = FALSE, progress = FALSE, output_dir = resumed_dir,
    resume = TRUE
  )
  expect_identical(calls, 40L)
  expect_identical(resumed$checkpoint_summary$NewCells, 9L)
  expect_identical(resumed$checkpoint_summary$ResumedCells, 1L)
  expect_identical(resumed$checkpoint_summary$TotalCells, 10L)
  expect_identical(resumed$registry$Maxit, 11L)
  expect_identical(resumed$registry$QuadPoints, 3L)
  expect_false(resumed$registry$RunPCA)
  expect_identical(nrow(resumed$checkpoint_ledger), 10L)
  expect_identical(sum(
    resumed$checkpoint_ledger$Source == "resumed_checkpoint"
  ), 1L)
  expect_true(all(resumed$checkpoint_ledger$CompleteRouteSet))
  expect_true(all(nchar(resumed$checkpoint_ledger$CheckpointSHA256) == 64L))
  expect_true(all(c(
    "execution-identity.csv", "package-identity.csv",
    "runner-identity.csv", "capability-manifest.csv",
    "checkpoint-ledger.csv", "run-complete.rds"
  ) %in% list.files(resumed_dir)))
  expect_silent(env$mfrmr_gpcm_repilot_validate_completion(
    resumed_dir, resumed$execution_identity$ExecutionSHA256
  ))
  expect_identical(nchar(resumed$execution_identity$ExecutionSHA256), 64L)
  expect_identical(row.names(resumed$runner_identity), as.character(1:3))
  expect_false(any(grepl(pkg_root, unlist(resumed$runner_identity),
                         fixed = TRUE)))
  expect_true(all(c(
    "R", "mfrmr", "digest", "Matrix", "lpSolve", "psych"
  ) %in% resumed$capability_manifest$Capability))
  package_capabilities <- resumed$capability_manifest$Capability %in%
    c("mfrmr", "digest", "Matrix", "lpSolve", "psych")
  expect_true(all(nchar(
    resumed$capability_manifest$RuntimeSHA256[package_capabilities]
  ) == 64L))

  fresh <- env$mfrmr_run_gpcm_attribution_replicated_pilot(
    "feasibility", reps = 1L, maxit = 11L, quad_points = 3L,
    run_pca = FALSE, progress = FALSE, output_dir = fresh_dir
  )
  expect_identical(calls, 80L)
  expect_identical(resumed$execution_identity$ExecutionSHA256,
                   fresh$execution_identity$ExecutionSHA256)
  expect_equal(resumed$run$results, fresh$run$results,
               ignore_attr = TRUE)
  expect_equal(resumed$run$contrasts, fresh$run$contrasts,
               ignore_attr = TRUE)
  expect_equal(resumed$analysis, fresh$analysis,
               ignore_attr = TRUE)

  marker_path <- file.path(resumed_dir, "run-complete.rds")
  marker <- readRDS(marker_path)
  unsafe_marker <- marker
  unsafe_marker$artifacts$File[1L] <- "../outside.csv"
  unsafe_marker$artifact_inventory_sha256 <-
    env$mfrmr_gpcm_repilot_hash_object(unsafe_marker$artifacts)
  saveRDS(unsafe_marker, marker_path)
  expect_error(
    env$mfrmr_gpcm_repilot_validate_completion(
      resumed_dir, resumed$execution_identity$ExecutionSHA256
    ),
    "unsafe path"
  )
  saveRDS(marker, marker_path)

  expect_error(
    env$mfrmr_run_gpcm_attribution_replicated_pilot(
      "feasibility", reps = 1L, maxit = 12L, quad_points = 3L,
      run_pca = FALSE, progress = FALSE, output_dir = resumed_dir,
      resume = TRUE
    ),
    "execution identity mismatch"
  )

  first_checkpoint <- list.files(
    checkpoint_dir, pattern = "[.]rds$", full.names = TRUE
  )[1L]
  writeLines("not an RDS checkpoint", first_checkpoint)
  expect_error(
    env$mfrmr_run_gpcm_attribution_replicated_pilot(
      "feasibility", reps = 1L, maxit = 11L, quad_points = 3L,
      run_pca = FALSE, progress = FALSE, output_dir = resumed_dir,
      resume = TRUE
    ),
    "artifact hash mismatch"
  )
})

test_that("MML metamorphic grid is prespecified, guarded, and fail closed", {
  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/",
                            mustWork = TRUE)
  runner <- file.path(
    pkg_root, "inst", "validation", "mml-metamorphic-grid-0.2.3.R"
  )
  expect_true(file.exists(runner))
  env <- new.env(parent = globalenv())
  source(runner, local = env)

  dry <- env$mfrmr_run_mml_metamorphic_grid(
    dry_run = TRUE, progress = FALSE
  )
  expect_identical(
    env$mfrmr_gpcm_repilot_hash_file(runner),
    "2fc9e48a6722a77b2b0b5f95385fd9815533ef93327a38345fe0fa544d3cbefb"
  )
  expect_identical(dry$registry$Comparisons, 30L)
  expect_identical(dry$registry$Models, 3L)
  expect_identical(dry$registry$Scenarios, 10L)
  expect_identical(dry$registry$Maxit, 400L)
  expect_equal(dry$registry$Reltol, 1e-9, tolerance = 0)
  expect_false(dry$registry$ConfirmationAuthorized)
  expect_identical(dry$registry$CriterionState,
                   "pilot_required_not_frozen")
  expect_false(dry$confirmation_authorized)
  expect_identical(nchar(dry$registry$DeclaredManifestSHA256), 64L)
  expect_identical(nchar(dry$registry$SelectedManifestSHA256), 64L)
  expect_identical(
    dry$registry$DeclaredManifestSHA256,
    dry$registry$SelectedManifestSHA256
  )
  expect_true(all(!dry$manifest$ConfirmationAuthorized))
  expect_true(all(dry$manifest$CriterionState ==
                    "pilot_required_not_frozen"))
  expect_identical(
    dry$manifest$ScenarioId[!dry$manifest$InputProvenanceEqualityRequired],
    rep(c(
      "missing_outcome_filter", "zero_weight_filter",
      "appended_zero_weight_levels", "combined_filter_label_factor"
    ), each = 3L)
  )

  selected <- env$mfrmr_run_mml_metamorphic_grid(
    models = "PCM", scenarios = "row_reverse",
    dry_run = TRUE, progress = FALSE
  )
  expect_identical(selected$registry$Comparisons, 1L)
  expect_identical(selected$registry$Models, 1L)
  expect_identical(selected$registry$Scenarios, 1L)
  expect_false(identical(
    selected$registry$DeclaredManifestSHA256,
    selected$registry$SelectedManifestSHA256
  ))
  deduplicated <- env$mfrmr_run_mml_metamorphic_grid(
    models = c("PCM", "PCM"), dry_run = TRUE, progress = FALSE
  )
  expect_identical(deduplicated$registry$Models, 1L)
  expect_identical(deduplicated$registry$Comparisons, 10L)
  expect_error(
    env$mfrmr_run_mml_metamorphic_grid(
      scenarios = "not_declared", dry_run = TRUE, progress = FALSE
    ),
    "Unknown metamorphic scenario"
  )
  expect_error(
    env$mfrmr_run_mml_metamorphic_grid(progress = FALSE),
    "authorize = TRUE",
    fixed = TRUE
  )
  existing_output <- tempfile("mml-metamorphic-existing-")
  dir.create(existing_output)
  on.exit(unlink(existing_output, recursive = TRUE, force = TRUE), add = TRUE)
  expect_error(
    env$mfrmr_run_mml_metamorphic_grid(
      authorize = TRUE, progress = FALSE, output_dir = existing_output
    ),
    "must not already exist"
  )
  expect_error(
    env$mfrmr_run_mml_metamorphic_grid(
      quad_points = 2L, dry_run = TRUE, progress = FALSE
    ),
    "quad_points"
  )
  expect_error(
    env$mfrmr_run_mml_metamorphic_grid(
      reltol = 0, dry_run = TRUE, progress = FALSE
    ),
    "reltol"
  )

  base <- env$mfrmr_mml_meta_base_data()
  maps <- env$mfrmr_mml_meta_maps(base, person = TRUE, facets = TRUE)
  relabelled <- env$mfrmr_mml_meta_relabel(base, maps)
  expect_identical(
    env$mfrmr_mml_meta_restore_map(relabelled$Person, maps$Person),
    as.character(base$Person)
  )
  empty <- env$mfrmr_mml_meta_compare_table(
    data.frame(id = "x"), data.frame(id = "x"), "slope", "id",
    character(0), "parameter"
  )
  expect_identical(nrow(empty), 0L)
  expect_identical(
    names(empty),
    c(
      "Component", "Metric", "Comparable", "KeySetEqual", "N",
      "MaxAbsDifference", "MeanAbsDifference", "ToleranceClass"
    )
  )
})
