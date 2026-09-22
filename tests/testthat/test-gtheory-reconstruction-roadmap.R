test_that("Draft.80 G-theory roadmap keeps formula and design semantics separate", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  roadmap_path <- file.path(
    pkg_root, "inst", "validation",
    "gtheory-reconstruction-roadmap-0.2.3.md"
  )
  expect_true(file.exists(roadmap_path))

  roadmap <- paste(
    readLines(roadmap_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  expect_match(roadmap, "repository-only Draft.80", fixed = TRUE)
  expect_match(
    roadmap,
    "An arbitrary mixed-model formula is necessary but not sufficient",
    fixed = TRUE
  )
  expect_match(roadmap, "NestingGraph", fixed = TRUE)
  expect_match(roadmap, "UniverseRole", fixed = TRUE)
  expect_match(roadmap, "ScaleBy", fixed = TRUE)
  expect_match(roadmap, "unresolved", fixed = TRUE)
})

test_that("Draft.80 freezes interaction-specific D-study algebra", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  roadmap <- paste(
    readLines(
      file.path(
        pkg_root, "inst", "validation",
        "gtheory-reconstruction-roadmap-0.2.3.md"
      ),
      warn = FALSE,
      encoding = "UTF-8"
    ),
    collapse = "\n"
  )

  expect_match(roadmap, "sigma2(p:r) / n_r", fixed = TRUE)
  expect_match(roadmap, "sigma2(p:i) / n_i", fixed = TRUE)
  expect_match(roadmap, "sigma2(r:i) / (n_r n_i)", fixed = TRUE)
  expect_match(roadmap, "allocation_operator", fixed = TRUE)
  expect_match(
    roadmap,
    "Observed median counts cannot silently define a D-study",
    fixed = TRUE
  )
})

test_that("Draft.80 keeps estimator boundaries and joint uncertainty explicit", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  roadmap <- paste(
    readLines(
      file.path(
        pkg_root, "inst", "validation",
        "gtheory-reconstruction-roadmap-0.2.3.md"
      ),
      warn = FALSE,
      encoding = "UTF-8"
    ),
    collapse = "\n"
  )

  expect_match(roadmap, "Negative raw components remain visible", fixed = TRUE)
  expect_match(roadmap, "constrained nonnegative", fixed = TRUE)
  expect_match(roadmap, "full-refit parametric bootstrap", fixed = TRUE)
  expect_match(
    roadmap,
    "Plugging marginal variance-component interval\\s+endpoints"
  )
  expect_match(roadmap, "failed-replicate ledger", fixed = TRUE)
})

test_that("Draft.80 multivariate plan uses covariance and sharing operators", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  roadmap <- paste(
    readLines(
      file.path(
        pkg_root, "inst", "validation",
        "gtheory-reconstruction-roadmap-0.2.3.md"
      ),
      warn = FALSE,
      encoding = "UTF-8"
    ),
    collapse = "\n"
  )

  expect_match(roadmap, "w' Sigma_p w", fixed = TRUE)
  expect_match(roadmap, "cross-stratum sharing/overlap", fixed = TRUE)
  expect_match(roadmap, "sqrt(n_a n_b)", fixed = TRUE)
  expect_match(roadmap, "positive semidefiniteness", fixed = TRUE)
  expect_match(roadmap, "PSD repair is separately labelled", fixed = TRUE)
})

test_that("Draft.80 remains a roadmap guard rather than a public scope claim", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  checklist <- utils::read.csv(
    file.path(
      pkg_root, "inst", "validation",
      "release-evidence-checklist-0.2.3.csv"
    ),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  rows <- checklist[grepl("^gtheory_", checklist$Item), , drop = FALSE]

  expect_equal(nrow(rows), 14L)
  expect_true(all(rows$Domain == "roadmap"))
  frozen_items <- c(
    "gtheory_preactivation_hardening",
    "gtheory_rng_hardened_generator",
    "gtheory_hardened_adapter_rebase",
    "gtheory_hardened_reserved_lineage",
    "gtheory_authorization_kernel",
    "gtheory_guarded_shard_runner",
    "gtheory_execution_authorization_decision",
    "gtheory_record_bound_entry_point",
    "gtheory_one_shard_issuance"
  )
  expect_true(all(
    rows$CriterionState[!rows$Item %in% frozen_items] ==
      "roadmap_guard"
  ))
  expect_true(all(
    rows$CriterionState[rows$Item %in% frozen_items] == "frozen_structural"
  ))
  review_items <- c(
    "gtheory_typed_design_algebra",
    "gtheory_univariate_crossed_nested",
    "gtheory_multivariate_covariance",
    "gtheory_current_surface_compatibility"
  )
  expect_true(all(
    rows$EvidenceStatus[rows$Item %in% review_items] == "review"
  ))
  expect_true(all(
    rows$EvidenceStatus[
      !rows$Item %in% c(review_items, frozen_items)
    ] ==
      "not_run"
  ))
  expect_true(all(
    rows$EvidenceStatus[rows$Item %in% frozen_items] == "concern"
  ))
  expect_identical(anyDuplicated(paste(checklist$Gate, checklist$Item)), 0L)
  univariate <- checklist[
    checklist$Item == "gtheory_univariate_crossed_nested", , drop = FALSE
  ]
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-typed-replay-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-glmmtmb-stabilization-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-glmmtmb-stabilization-smoke-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-glmmtmb-alignment-smoke-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-glmmtmb-numerical-adjudication-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-glmmtmb-stationarity-instrumentation-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-glmmtmb-stationarity-calibration-design-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-glmmtmb-stationarity-reference-calibration-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-stationarity-calibration-authorization-audit-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-glmmtmb-ml-reference-coverage-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-lme4-objective-reference-preflight-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-lme4-reference-coverage-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-stationarity-acceptance-policy-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-production-boundary-probe-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$PackageSurface,
               "gtheory-weak-information-stationarity-exact-resume-runner-record-0.2.3.md",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g1 negative covering smoke", fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g2 full-denominator alignment replay",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g3 no-refit multi-axis numerical adjudication",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g4 raw-derivative scale-aware measurement replay",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g5 sealed stationarity-calibration design",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g6 completed high-accuracy analytic/nonreserved reference calibration",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g7 completed fail-closed backend-accounting state-algebra and method-coverage preauthorization audit",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g8 completed repeatable nonreserved glmmTMB ML reference coverage",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g9 completed analytic lme4 objective-reference preflight",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g10 completed repeatable nonreserved lme4 ML/REML reference coverage",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g11 froze the truth-blind acceptance and Monte Carlo decision policy",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g12 completed the coordinate-correct production boundary probe",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g13 completed exact-resume complete-denominator runner mechanics",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g14 completed the response-free production-adapter and reserved-manifest preflight",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g15 completed the response-free one-way authorization-readiness preflight while issuing no execution authorization",
               fixed = TRUE)
  expect_match(univariate$FollowUp,
               "Draft.83d2b2b1g15a retained 100 planned trials per primary cell only for numerical-rule calibration while withholding achieved-precision broad-performance and universal-sample-size claims",
               fixed = TRUE)
  hardening <- checklist[
    checklist$Item == "gtheory_preactivation_hardening", , drop = FALSE
  ]
  expect_identical(nrow(hardening), 1L)
  expect_match(
    hardening$PackageSurface,
    "gtheory-weak-information-preactivation-hardening-audit-record-0.2.3.md",
    fixed = TRUE
  )
  expect_match(hardening$FollowUp,
               "First make generation RNG-self-contained", fixed = TRUE)
  expect_identical(hardening$CriterionState, "frozen_structural")
  expect_identical(hardening$EvidenceStatus, "concern")
  rng_hardened <- checklist[
    checklist$Item == "gtheory_rng_hardened_generator", , drop = FALSE
  ]
  expect_identical(nrow(rng_hardened), 1L)
  expect_match(
    rng_hardened$PackageSurface,
    "gtheory-weak-information-rng-hardened-generator-record-0.2.3.md",
    fixed = TRUE
  )
  expect_match(rng_hardened$FollowUp,
               "Rebase every downstream nonreserved adapter", fixed = TRUE)
  expect_identical(rng_hardened$CriterionState, "frozen_structural")
  expect_identical(rng_hardened$EvidenceStatus, "concern")
  adapter_rebase <- checklist[
    checklist$Item == "gtheory_hardened_adapter_rebase", , drop = FALSE
  ]
  expect_identical(nrow(adapter_rebase), 1L)
  expect_match(
    adapter_rebase$PackageSurface,
    "gtheory-weak-information-hardened-adapter-rebase-record-0.2.3.md",
    fixed = TRUE
  )
  expect_match(adapter_rebase$FollowUp,
               "Rebuild all 100 prospective reserved shard identities",
               fixed = TRUE)
  expect_identical(adapter_rebase$CriterionState, "frozen_structural")
  expect_identical(adapter_rebase$EvidenceStatus, "concern")
  reserved_lineage <- checklist[
    checklist$Item == "gtheory_hardened_reserved_lineage", , drop = FALSE
  ]
  expect_identical(nrow(reserved_lineage), 1L)
  expect_match(
    reserved_lineage$PackageSurface,
    "gtheory-weak-information-hardened-reserved-lineage-record-0.2.3.md",
    fixed = TRUE
  )
  expect_match(reserved_lineage$FollowUp,
               "inert reserved-only adapter entry point", fixed = TRUE)
  expect_identical(reserved_lineage$CriterionState, "frozen_structural")
  expect_identical(reserved_lineage$EvidenceStatus, "concern")
  authorization_kernel <- checklist[
    checklist$Item == "gtheory_authorization_kernel", , drop = FALSE
  ]
  expect_identical(nrow(authorization_kernel), 1L)
  expect_match(
    authorization_kernel$PackageSurface,
    "gtheory-weak-information-authorization-kernel-record-0.2.3.md",
    fixed = TRUE
  )
  expect_match(authorization_kernel$FollowUp,
               "Implement one guarded reserved runner", fixed = TRUE)
  expect_identical(authorization_kernel$CriterionState, "frozen_structural")
  expect_identical(authorization_kernel$EvidenceStatus, "concern")
  guarded_runner <- checklist[
    checklist$Item == "gtheory_guarded_shard_runner", , drop = FALSE
  ]
  expect_identical(nrow(guarded_runner), 1L)
  expect_match(
    guarded_runner$PackageSurface,
    "gtheory-weak-information-guarded-shard-runner-record-0.2.3.md",
    fixed = TRUE
  )
  expect_match(guarded_runner$FollowUp,
               "Issue or refuse one immutable authorization record",
               fixed = TRUE)
  expect_identical(guarded_runner$CriterionState, "frozen_structural")
  expect_identical(guarded_runner$EvidenceStatus, "concern")
  authorization_decision <- checklist[
    checklist$Item == "gtheory_execution_authorization_decision",
    , drop = FALSE
  ]
  expect_identical(nrow(authorization_decision), 1L)
  expect_match(
    authorization_decision$PackageSurface,
    "gtheory-weak-information-execution-authorization-decision-record-0.2.3.md",
    fixed = TRUE
  )
  expect_match(authorization_decision$AcceptanceRule,
               "RESERVED-ENTRY-01 ACTIVE-MANIFEST-01 and SITE-RECEIPT-01",
               fixed = TRUE)
  expect_identical(authorization_decision$CriterionState, "frozen_structural")
  expect_identical(authorization_decision$EvidenceStatus, "concern")
  record_bound_entry <- checklist[
    checklist$Item == "gtheory_record_bound_entry_point", , drop = FALSE
  ]
  expect_identical(nrow(record_bound_entry), 1L)
  expect_match(
    record_bound_entry$PackageSurface,
    "gtheory-weak-information-record-bound-entry-point-record-0.2.3.md",
    fixed = TRUE
  )
  expect_match(record_bound_entry$AcceptanceRule,
               "no production issuer record active R0201", fixed = TRUE)
  expect_identical(record_bound_entry$CriterionState, "frozen_structural")
  expect_identical(record_bound_entry$EvidenceStatus, "concern")
  one_shard_issuance <- checklist[
    checklist$Item == "gtheory_one_shard_issuance", , drop = FALSE
  ]
  expect_identical(nrow(one_shard_issuance), 1L)
  expect_match(
    one_shard_issuance$PackageSurface,
    "gtheory-weak-information-one-shard-issuance-record-0.2.3.md",
    fixed = TRUE
  )
  expect_match(one_shard_issuance$AcceptanceRule,
               "only exact R0201 may open", fixed = TRUE)
  expect_identical(one_shard_issuance$CriterionState, "frozen_structural")
  expect_identical(one_shard_issuance$EvidenceStatus, "concern")
})

test_that("Draft.81-83d2b2b1g24 and future Draft.85a0 artifacts retain prototype scope", {
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation_root <- file.path(pkg_root, "inst", "validation")
  artifacts <- c(
    "gtheory-design-algebra-contract-0.2.3.md",
    "gtheory-design-algebra-prototype-0.2.3.R",
    "gtheory-design-algebra-record-0.2.3.md",
    "gtheory-balanced-estimation-contract-0.2.3.md",
    "gtheory-balanced-estimation-prototype-0.2.3.R",
    "gtheory-balanced-estimation-record-0.2.3.md",
    "gtheory-design-incidence-contract-0.2.3.md",
    "gtheory-design-incidence-audit-0.2.3.R",
    "gtheory-design-incidence-record-0.2.3.md",
    "gtheory-allocation-operator-contract-0.2.3.md",
    "gtheory-allocation-operator-prototype-0.2.3.R",
    "gtheory-allocation-operator-record-0.2.3.md",
    "gtheory-covariance-information-contract-0.2.3.md",
    "gtheory-covariance-information-audit-0.2.3.R",
    "gtheory-covariance-information-record-0.2.3.md",
    "gtheory-glmmtmb-parity-contract-0.2.3.md",
    "gtheory-glmmtmb-parity-prototype-0.2.3.R",
    "gtheory-glmmtmb-parity-record-0.2.3.md",
    "gtheory-ademp-registry-contract-0.2.3.md",
    "gtheory-ademp-registry-prototype-0.2.3.R",
    "gtheory-ademp-registry-record-0.2.3.md",
    "gtheory-ademp-generator-contract-0.2.3.md",
    "gtheory-ademp-generator-prototype-0.2.3.R",
    "gtheory-ademp-generator-record-0.2.3.md",
    "gtheory-ademp-prefit-contract-0.2.3.md",
    "gtheory-ademp-prefit-prototype-0.2.3.R",
    "gtheory-ademp-prefit-record-0.2.3.md",
    "gtheory-ademp-fit-contract-0.2.3.md",
    "gtheory-ademp-fit-prototype-0.2.3.R",
    "gtheory-ademp-fit-record-0.2.3.md",
    "gtheory-weak-information-calibration-contract-0.2.3.md",
    "gtheory-weak-information-calibration-prototype-0.2.3.R",
    "gtheory-weak-information-calibration-record-0.2.3.md",
    "gtheory-weak-information-pilot-contract-0.2.3.md",
    "gtheory-weak-information-pilot-prototype-0.2.3.R",
    "gtheory-weak-information-pilot-record-0.2.3.md",
    "gtheory-weak-information-inference-audit-0.2.3.md",
    "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R",
    "gtheory-weak-information-diagnostic-refit-record-0.2.3.md",
    "gtheory-weak-information-bootstrap-contract-0.2.3.md",
    "gtheory-weak-information-bootstrap-prototype-0.2.3.R",
    "gtheory-weak-information-bootstrap-record-0.2.3.md",
    "gtheory-weak-information-feasibility-contract-0.2.3.md",
    "gtheory-weak-information-feasibility-prototype-0.2.3.R",
    "gtheory-weak-information-feasibility-record-0.2.3.md",
    "gtheory-weak-information-feasibility-runner-contract-0.2.3.md",
    "gtheory-weak-information-feasibility-runner-0.2.3.R",
    "gtheory-weak-information-feasibility-execution-record-0.2.3.md",
    "gtheory-weak-information-numerical-sensitivity-contract-0.2.3.md",
    "gtheory-weak-information-numerical-sensitivity-0.2.3.R",
    "gtheory-weak-information-numerical-sensitivity-record-0.2.3.md",
    "gtheory-weak-information-typed-replay-contract-0.2.3.md",
    "gtheory-weak-information-typed-replay-0.2.3.R",
    "gtheory-weak-information-typed-replay-record-0.2.3.md",
    "gtheory-weak-information-glmmtmb-stabilization-contract-0.2.3.md",
    "gtheory-weak-information-glmmtmb-stabilization-prototype-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stabilization-record-0.2.3.md",
    "gtheory-weak-information-glmmtmb-stabilization-runner-contract-0.2.3.md",
    "gtheory-weak-information-glmmtmb-stabilization-runner-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stabilization-smoke-record-0.2.3.md",
    "gtheory-weak-information-glmmtmb-alignment-contract-0.2.3.md",
    "gtheory-weak-information-glmmtmb-alignment-runner-0.2.3.R",
    "gtheory-weak-information-glmmtmb-alignment-smoke-record-0.2.3.md",
    "gtheory-weak-information-glmmtmb-numerical-adjudication-contract-0.2.3.md",
    "gtheory-weak-information-glmmtmb-numerical-adjudication-0.2.3.R",
    "gtheory-weak-information-glmmtmb-numerical-adjudication-record-0.2.3.md",
    "gtheory-weak-information-glmmtmb-stationarity-instrumentation-contract-0.2.3.md",
    "gtheory-weak-information-glmmtmb-stationarity-instrumentation-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stationarity-instrumentation-record-0.2.3.md",
    "gtheory-weak-information-glmmtmb-stationarity-calibration-design-contract-0.2.3.md",
    "gtheory-weak-information-glmmtmb-stationarity-calibration-design-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stationarity-calibration-design-record-0.2.3.md",
    "gtheory-weak-information-glmmtmb-stationarity-reference-calibration-contract-0.2.3.md",
    "gtheory-weak-information-glmmtmb-stationarity-reference-calibration-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stationarity-reference-calibration-record-0.2.3.md",
    "gtheory-weak-information-stationarity-calibration-authorization-audit-contract-0.2.3.md",
    "gtheory-weak-information-stationarity-calibration-authorization-audit-0.2.3.R",
    "gtheory-weak-information-stationarity-calibration-authorization-audit-record-0.2.3.md",
    "gtheory-weak-information-glmmtmb-ml-reference-coverage-contract-0.2.3.md",
    "gtheory-weak-information-glmmtmb-ml-reference-coverage-0.2.3.R",
    "gtheory-weak-information-glmmtmb-ml-reference-coverage-record-0.2.3.md",
    "gtheory-weak-information-lme4-objective-reference-preflight-contract-0.2.3.md",
    "gtheory-weak-information-lme4-objective-reference-preflight-0.2.3.R",
    "gtheory-weak-information-lme4-objective-reference-preflight-record-0.2.3.md",
    "gtheory-weak-information-lme4-reference-coverage-contract-0.2.3.md",
    "gtheory-weak-information-lme4-reference-coverage-0.2.3.R",
    "gtheory-weak-information-lme4-reference-coverage-record-0.2.3.md",
    "gtheory-weak-information-stationarity-acceptance-policy-contract-0.2.3.md",
    "gtheory-weak-information-stationarity-acceptance-policy-0.2.3.R",
    "gtheory-weak-information-stationarity-acceptance-policy-record-0.2.3.md",
    "gtheory-weak-information-production-boundary-probe-contract-0.2.3.md",
    "gtheory-weak-information-production-boundary-probe-0.2.3.R",
    "gtheory-weak-information-production-boundary-probe-record-0.2.3.md",
    "gtheory-weak-information-stationarity-exact-resume-runner-contract-0.2.3.md",
    "gtheory-weak-information-stationarity-exact-resume-runner-0.2.3.R",
    "gtheory-weak-information-stationarity-exact-resume-runner-record-0.2.3.md",
    "gtheory-weak-information-production-adapter-preflight-contract-0.2.3.md",
    "gtheory-weak-information-production-adapter-preflight-0.2.3.R",
    "gtheory-weak-information-production-adapter-preflight-record-0.2.3.md",
    "gtheory-weak-information-one-way-authorization-preflight-contract-0.2.3.md",
    "gtheory-weak-information-one-way-authorization-preflight-0.2.3.R",
    "gtheory-weak-information-one-way-authorization-preflight-record-0.2.3.md",
    "gtheory-weak-information-monte-carlo-value-audit-contract-0.2.3.md",
    "gtheory-weak-information-monte-carlo-value-audit-0.2.3.R",
    "gtheory-weak-information-monte-carlo-value-audit-record-0.2.3.md",
    "gtheory-weak-information-preactivation-hardening-audit-contract-0.2.3.md",
    "gtheory-weak-information-preactivation-hardening-audit-0.2.3.R",
    "gtheory-weak-information-preactivation-hardening-audit-record-0.2.3.md",
    "gtheory-weak-information-rng-hardened-generator-contract-0.2.3.md",
    "gtheory-weak-information-rng-hardened-generator-0.2.3.R",
    "gtheory-weak-information-rng-hardened-generator-record-0.2.3.md",
    "gtheory-weak-information-hardened-adapter-rebase-contract-0.2.3.md",
    "gtheory-weak-information-hardened-adapter-rebase-0.2.3.R",
    "gtheory-weak-information-hardened-adapter-rebase-record-0.2.3.md",
    "gtheory-weak-information-hardened-reserved-lineage-contract-0.2.3.md",
    "gtheory-weak-information-hardened-reserved-lineage-0.2.3.R",
    "gtheory-weak-information-hardened-reserved-lineage-record-0.2.3.md",
    "gtheory-weak-information-authorization-kernel-contract-0.2.3.md",
    "gtheory-weak-information-authorization-kernel-0.2.3.R",
    "gtheory-weak-information-authorization-kernel-worker-0.2.3.R",
    "gtheory-weak-information-authorization-kernel-record-0.2.3.md",
    "gtheory-weak-information-guarded-shard-runner-contract-0.2.3.md",
    "gtheory-weak-information-guarded-shard-runner-0.2.3.R",
    "gtheory-weak-information-guarded-shard-runner-worker-0.2.3.R",
    "gtheory-weak-information-guarded-shard-runner-record-0.2.3.md",
    "gtheory-weak-information-execution-authorization-decision-contract-0.2.3.md",
    "gtheory-weak-information-execution-authorization-decision-0.2.3.R",
    "gtheory-weak-information-execution-authorization-decision-record-0.2.3.md",
    "gtheory-weak-information-record-bound-entry-point-contract-0.2.3.md",
    "gtheory-weak-information-record-bound-entry-point-0.2.3.R",
    "gtheory-weak-information-record-bound-entry-point-worker-0.2.3.R",
    "gtheory-weak-information-record-bound-entry-point-record-0.2.3.md",
    "gtheory-weak-information-one-shard-issuance-contract-0.2.3.md",
    "gtheory-weak-information-one-shard-issuance-0.2.3.R",
    "gtheory-weak-information-one-shard-issuance-record-0.2.3.md",
    "gtheory-multivariate-algebra-contract-0.2.3.md",
    "gtheory-multivariate-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-algebra-record-0.2.3.md"
  )
  expect_true(all(file.exists(file.path(validation_root, artifacts))))

  gate <- paste(
    readLines(
      file.path(validation_root, "release-gate-spec-0.2.3.md"),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  record <- paste(
    readLines(
      file.path(validation_root, "gtheory-design-algebra-record-0.2.3.md"),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  estimation_record <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-balanced-estimation-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  incidence_record <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-design-incidence-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  allocation_contract <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-allocation-operator-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  allocation_record <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-allocation-operator-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  covariance_contract <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-covariance-information-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  covariance_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-covariance-information-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  parity_contract <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-glmmtmb-parity-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  parity_record <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-glmmtmb-parity-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  ademp_contract <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-ademp-registry-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  ademp_record <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-ademp-registry-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  generator_contract <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-ademp-generator-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  generator_record <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-ademp-generator-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  prefit_contract <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-ademp-prefit-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  prefit_record <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-ademp-prefit-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  fit_contract <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-ademp-fit-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  fit_record <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-ademp-fit-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_contract <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-calibration-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-calibration-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_pilot_contract <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-weak-information-pilot-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_pilot_record <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-weak-information-pilot-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_bootstrap_contract <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-bootstrap-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_bootstrap_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-bootstrap-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_feasibility_contract <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-feasibility-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_feasibility_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-feasibility-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_feasibility_runner_contract <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-feasibility-runner-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_feasibility_execution_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-feasibility-execution-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_numerical_contract <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-numerical-sensitivity-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_numerical_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-numerical-sensitivity-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_typed_replay_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-typed-replay-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_glmmtmb_stabilization_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-glmmtmb-stabilization-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_glmmtmb_stabilization_smoke_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-glmmtmb-stabilization-smoke-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_glmmtmb_alignment_smoke_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-glmmtmb-alignment-smoke-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_glmmtmb_numerical_adjudication_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-glmmtmb-numerical-adjudication-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_glmmtmb_stationarity_record <- paste(
    readLines(
      file.path(
        validation_root,
        paste0(
          "gtheory-weak-information-glmmtmb-stationarity-",
          "instrumentation-record-0.2.3.md"
        )
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_glmmtmb_stationarity_design_record <- paste(
    readLines(
      file.path(
        validation_root,
        paste0(
          "gtheory-weak-information-glmmtmb-stationarity-calibration-",
          "design-record-0.2.3.md"
        )
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_glmmtmb_stationarity_reference_record <- paste(
    readLines(
      file.path(
        validation_root,
        paste0(
          "gtheory-weak-information-glmmtmb-stationarity-reference-",
          "calibration-record-0.2.3.md"
        )
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_stationarity_authorization_record <- paste(
    readLines(
      file.path(
        validation_root,
        paste0(
          "gtheory-weak-information-stationarity-calibration-",
          "authorization-audit-record-0.2.3.md"
        )
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  weak_information_glmmtmb_ml_reference_coverage_record <- paste(
    readLines(
      file.path(
        validation_root,
        "gtheory-weak-information-glmmtmb-ml-reference-coverage-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  multivariate_contract <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-multivariate-algebra-contract-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  multivariate_record <- paste(
    readLines(
      file.path(
        validation_root, "gtheory-multivariate-algebra-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )

  expect_match(gate,
               "Specification ID | `0.2.3-draft.83d2b2b1g24`", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.81` |", fixed = TRUE)
  expect_match(gate, "eight tests and 46 expectations", fixed = TRUE)
  expect_match(gate, "Seven tests and 71 expectations", fixed = TRUE)
  expect_match(gate, "Seven tests and 69 expectations", fixed = TRUE)
  expect_match(gate, "No fitting engine, public formula grammar", fixed = TRUE)
  expect_match(record, "AlgebraReady=TRUE", fixed = TRUE)
  expect_match(record, "DecisionReady=FALSE", fixed = TRUE)
  expect_match(record, "Draft.82 is next", fixed = TRUE)
  expect_match(estimation_record, "seven tests and 71 expectations", fixed = TRUE)
  expect_match(estimation_record, "negative_raw", fixed = TRUE)
  expect_match(estimation_record, "constrained_zero_boundary", fixed = TRUE)
  expect_match(estimation_record,
               "main_effects_collapsed_residual_v1", fixed = TRUE)
  expect_match(incidence_record, "seven tests and 69 expectations", fixed = TRUE)
  expect_match(incidence_record,
               "not_adjudicated_draft83a", fixed = TRUE)
  expect_match(incidence_record,
               "fixed-effect-equivalent rank is not covariance-parameter",
               fixed = TRUE)
  expect_match(allocation_contract,
               "lambda_uC = sum_g a_uCg^2", fixed = TRUE)
  expect_match(allocation_contract,
               "heterogeneous_unit_specific_only", fixed = TRUE)
  expect_match(allocation_record,
               "seven tests and 71 expectations passed", fixed = TRUE)
  expect_match(allocation_record, "G=10/13", fixed = TRUE)
  expect_match(allocation_record,
               "EstimationReady=FALSE", fixed = TRUE)
  expect_match(covariance_contract,
               "K_c = \\frac{\\partial V}", fixed = TRUE)
  expect_match(covariance_contract,
               "point_estimation_gate_passed", fixed = TRUE)
  expect_match(covariance_record,
               "eight focused tests and 103 expectations pass", fixed = TRUE)
  expect_match(covariance_record,
               "boundary_nonregular", fixed = TRUE)
  expect_match(covariance_record,
               "CoefficientEligible", fixed = TRUE)
  expect_match(parity_contract, "MatchedOverlapPassed", fixed = TRUE)
  expect_match(parity_contract, "pdHess=TRUE", fixed = TRUE)
  expect_match(parity_record,
               "eight focused tests and 93 expectations pass", fixed = TRUE)
  expect_match(parity_record,
               "boundary_tolerance_reached", fixed = TRUE)
  expect_match(parity_record,
               "No estimator is selected", fixed = TRUE)
  expect_match(ademp_contract,
               "blocked_anchor_not_gstudy_operation", fixed = TRUE)
  expect_match(ademp_contract,
               "no_interval_until_draft84", fixed = TRUE)
  expect_match(ademp_contract,
               "not the Rasch or\\s+FACETS separation statistic")
  expect_match(ademp_record,
               "Nine focused tests and 77 expectations pass", fixed = TRUE)
  expect_match(ademp_record,
               "SimulationExecuted", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d1` |", fixed = TRUE)
  expect_match(generator_contract,
               "FullPotentialData", fixed = TRUE)
  expect_match(generator_contract,
               "blocked_not_current_gstudy_operation", fixed = TRUE)
  expect_match(generator_record,
               "Ten focused tests and 185 expectations pass", fixed = TRUE)
  expect_match(generator_record,
               "1ed0856cc91ceb36115806dcf0f135ef7491d9e1ef53106276c0fd81584e0844",
               fixed = TRUE)
  expect_match(prefit_contract,
               "exact scalable covariance-component rank audit", fixed = TRUE)
  expect_match(prefit_contract,
               "FitAttemptAuthorized = FALSE", fixed = TRUE)
  expect_match(prefit_record,
               "Eight focused tests and 71 expectations pass", fixed = TRUE)
  expect_match(prefit_record,
               "022ae8b01eb9febc3b1648bd232066fd11a56609e483e9e8b64d4a526ff94986",
               fixed = TRUE)
  expect_match(fit_contract,
               "zero false-ready gate | **failed**", fixed = TRUE)
  expect_match(fit_contract,
               "backend-local regularity diagnostics", fixed = TRUE)
  expect_match(fit_record,
               "atomic accounting passed; near-boundary zero-false-ready gate failed",
               fixed = TRUE)
  expect_match(fit_record,
               "1b0fa928f1aba1a9ac09bc3ec1c790f7fb94911a92cc6ea13ee7ad92d4884d49",
               fixed = TRUE)
  expect_match(weak_information_contract,
               "27 false-ready results", fixed = TRUE)
  expect_match(weak_information_contract,
               "ThresholdFrozen", fixed = TRUE)
  expect_match(weak_information_record,
               "27/40 false-ready", fixed = TRUE)
  expect_match(weak_information_record,
               "71978d3ea5bd747ae53526f8bbfe3bfde5a086e0267f6e9530b088cfb4f9f336",
               fixed = TRUE)
  expect_match(weak_information_pilot_contract,
               "ScenarioId x Replicate", fixed = TRUE)
  expect_match(weak_information_pilot_contract,
               "Confirmation remains unavailable", fixed = TRUE)
  expect_match(weak_information_pilot_record,
               "3,000\\s+atomic rows")
  expect_match(weak_information_pilot_record,
               "463a188717f389858635c5447d2c750b32920b5d370d3fbb39cbada43ed9780c",
               fixed = TRUE)
  expect_match(weak_information_bootstrap_contract,
               "does not mean an exact finite-", fixed = TRUE)
  expect_match(weak_information_bootstrap_contract,
               "1{,}200{,}000", fixed = TRUE)
  expect_match(weak_information_bootstrap_record,
               "full/reduced backend fits | 96", fixed = TRUE)
  expect_match(weak_information_bootstrap_record,
               "bootstrap pairs with a nuisance boundary | 8 / 36",
               fixed = TRUE)
  expect_match(weak_information_feasibility_contract,
               "must not\\s+call the generator")
  expect_match(weak_information_feasibility_contract,
               "excluded from the replayable execution hash", fixed = TRUE)
  expect_match(weak_information_feasibility_record,
               "common feasibility scores available | 111 / 120",
               fixed = TRUE)
  expect_match(weak_information_feasibility_record,
               "ResolutionFeasibilityAuthorized = TRUE", fixed = TRUE)
  expect_match(weak_information_feasibility_runner_contract,
               "n_+n_-", fixed = TRUE)
  expect_match(weak_information_feasibility_runner_contract,
               "No data-dependent early stopping", fixed = TRUE)
  expect_match(weak_information_feasibility_execution_record,
               "common-score-available rows | 2,804 / 3,000", fixed = TRUE)
  expect_match(weak_information_feasibility_execution_record,
               "04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b",
               fixed = TRUE)
  expect_match(weak_information_numerical_contract,
               "non-finite difference is `not evaluable`", fixed = TRUE)
  expect_match(weak_information_numerical_record,
               "planned and recorded profile pairs | 9,000 / 9,000",
               fixed = TRUE)
  expect_match(weak_information_numerical_record,
               "NumericalSensitivityEvidenceReady = FALSE", fixed = TRUE)
  expect_match(weak_information_typed_replay_record,
               "TypedReplayAdjudicationReady = TRUE", fixed = TRUE)
  expect_match(weak_information_typed_replay_record,
               "NumericalSensitivityEvidenceReady = FALSE", fixed = TRUE)
  expect_match(weak_information_typed_replay_record,
               "e200a9ee7984bbc3be32ab5ef209ce2eb26c0b42c8df3ad758bab7baf559f8c1",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_stabilization_record,
               "ManifestReady = TRUE", fixed = TRUE)
  expect_match(weak_information_glmmtmb_stabilization_record,
               "StabilizationExecutionAuthorized = FALSE", fixed = TRUE)
  expect_match(weak_information_glmmtmb_stabilization_record,
               "8feb8695c655c0621d61863e00d82fffe7fd5d7b619761decefaed6e89b0c326",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_stabilization_record,
               "92435f41b0dab7e13bf1febcf6e043fc1ae8d4a2cb7d159401dd1d78b4c9ff3e",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_stabilization_smoke_record,
               "SmokeRunnerMechanicsReady = TRUE", fixed = TRUE)
  expect_match(weak_information_glmmtmb_stabilization_smoke_record,
               "FullExecutionAuthorized = FALSE", fixed = TRUE)
  expect_match(weak_information_glmmtmb_stabilization_smoke_record,
               "c743de38ec7d5ff6606c5b1df7960caea4bca149b470063e8496db83b5ab439d",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_stabilization_smoke_record,
               "2.80e-10", fixed = TRUE)
  expect_match(weak_information_glmmtmb_alignment_smoke_record,
               "AlignmentMechanicsReady=TRUE", fixed = TRUE)
  expect_match(weak_information_glmmtmb_alignment_smoke_record,
               "FullExecutionAuthorized", fixed = TRUE)
  expect_match(weak_information_glmmtmb_alignment_smoke_record,
               "e2716a4ae71784e218d15f2509ed8c15326c1b7c6bc9acf78826a81822581482",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_alignment_smoke_record,
               "651b6f07cb7977b7d1245b1048e0b7b905c4999f8da43bfbcd30180d9581d435",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_alignment_smoke_record,
               "14 `nonfinite_objective_or_likelihood`", fixed = TRUE)
  expect_match(weak_information_glmmtmb_numerical_adjudication_record,
               "AdjudicationSchemaReady=TRUE", fixed = TRUE)
  expect_match(weak_information_glmmtmb_numerical_adjudication_record,
               "StationarityCriterionReady", fixed = TRUE)
  expect_match(weak_information_glmmtmb_numerical_adjudication_record,
               "934f96be6e23cd728576cfedbb44d48b68137fbbc74e84d19d7200b8ad52ccc0",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_numerical_adjudication_record,
               "c7c35d5b961c578b6234a1f29f628f13dac357bc1b046e012832d28ca7f3d4de",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_numerical_adjudication_record,
               "23 material negative", fixed = TRUE)
  expect_match(weak_information_glmmtmb_numerical_adjudication_record,
               "12 positive and 8", fixed = TRUE)
  expect_match(weak_information_glmmtmb_stationarity_record,
               "ScaleAwareMeasurementSchemaReady", fixed = TRUE)
  expect_match(weak_information_glmmtmb_stationarity_record,
               "224/240", fixed = TRUE)
  expect_match(weak_information_glmmtmb_stationarity_record,
               "a825ab427da7e4a8160e428a7a6b00038f364b1c15049df6d5e4bf03bbbbbade",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_stationarity_design_record,
               "278353d1668501d04dd3af4adc96dfcd39b232796057242418f89601b22b99ac",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_stationarity_design_record,
               "144,000 candidate fits", fixed = TRUE)
  expect_match(weak_information_glmmtmb_stationarity_design_record,
               "ReferenceToleranceFrozen", fixed = TRUE)
  expect_match(weak_information_glmmtmb_stationarity_reference_record,
               "60e04706736c0e7273dfa321d0d41a3a9ed4bb8362a0b7d428f8507653ecce9a",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_stationarity_reference_record,
               "28f155c91065cb56ebe695234eab7867392e25fe413ab362717e760f5e775e72",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_stationarity_reference_record,
               "ReferenceToleranceFrozen=TRUE", fixed = TRUE)
  expect_match(weak_information_stationarity_authorization_record,
               "108,000", fixed = TRUE)
  expect_match(weak_information_stationarity_authorization_record,
               "b293987e768ec0e998d3224a6df0689f0ab8b6f2268704ef422e333865d82765",
               fixed = TRUE)
  expect_match(weak_information_stationarity_authorization_record,
               "CalibrationAuthorizationReady=FALSE", fixed = TRUE)
  expect_match(weak_information_stationarity_authorization_record,
               "Five focused tests with 71 expectations pass", fixed = TRUE)
  expect_match(weak_information_glmmtmb_ml_reference_coverage_record,
               "1216ae3591fc026a61b4fb6581ebe79e33d34e4e2b6bf04a969a4c93c3e06689",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_ml_reference_coverage_record,
               "46ea4be751a3c54904bac28da31f15e5e05f347b9e8f10a1194887f55557807d",
               fixed = TRUE)
  expect_match(weak_information_glmmtmb_ml_reference_coverage_record,
               "GlmmTMBMethodCoverageReady=TRUE", fixed = TRUE)
  expect_match(weak_information_glmmtmb_ml_reference_coverage_record,
               "Six focused tests with 64 expectations pass", fixed = TRUE)
  expect_match(multivariate_contract,
               "Gamma_c o Lambda_c", fixed = TRUE)
  expect_match(multivariate_contract,
               "it is not `1/sqrt(2*3)`", fixed = TRUE)
  expect_match(multivariate_record,
               "Nine focused tests and 66 expectations pass", fixed = TRUE)
  expect_match(multivariate_record,
               "EstimationReady", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d1-mv1` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2a` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b0` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b1` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2a` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b0` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1a` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1b` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1c` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1d` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1e` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1f` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g1` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g2` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g3` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g4` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g5` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g6` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g7` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g8` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g9` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g10` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g11` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g12` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g13` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g14` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g15` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g15a` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g16` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g17` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g18` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g19` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g20` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g21` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g22` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g23` |", fixed = TRUE)
  expect_match(gate, "| `0.2.3-draft.83d2b2b1g24` |", fixed = TRUE)
})
