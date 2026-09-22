load_conquest_p5_evidence_disposition_ledger <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation, "conquest-p5-evidence-disposition-ledger-0.2.3.R"
  )
  skip_if_not(file.exists(script), "ConQuest P5 evidence ledger is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

test_that("runtime scope is exact and nonportable", {
  env <- load_conquest_p5_evidence_disposition_ledger()$env
  runtime <- env$mfrmr_cq_p5edl_runtime()

  expect_identical(runtime$Version, "5.47.5")
  expect_identical(runtime$Edition, "Demonstration Version")
  expect_identical(runtime$ExecutableArchitecture, "x86_64 Mach-O")
  expect_identical(runtime$InvocationRoute, "/usr/bin/arch -x86_64")
  expect_identical(runtime$ExpiryDate, "2026-09-01")
  expect_true(runtime$RuntimeSemanticSentinelPassed)
  expect_false(runtime$RuntimePortableBeyondObservedPlatform)
  expect_false(runtime$PublicPromotionAuthorized)
})

test_that("execution lineages remain separate and denominator-complete", {
  env <- load_conquest_p5_evidence_disposition_ledger()$env
  ledger <- env$mfrmr_cq_p5edl_execution_ledger()

  expect_identical(nrow(ledger), 7L)
  expect_identical(anyDuplicated(ledger$LineageId), 0L)
  expect_identical(
    ledger$AttemptedConQuestArms, c(4L, 1L, 6L, 1L, 0L, 0L, 4L)
  )
  expect_identical(
    ledger$SemanticallyCompleteConQuestArms,
    c(4L, 0L, 6L, 0L, 0L, 0L, 4L)
  )
  expect_identical(
    ledger$BoundedComparisonRowsExpected,
    c(0L, 0L, 57L, 0L, 0L, 0L, 886L)
  )
  expect_false(any(ledger$IndependentReviewPassed))
  expect_false(any(ledger$RerunAuthorized))
  expect_false(any(ledger$PublicPromotionAuthorized))
})

test_that("matched overlap names every covered design and class", {
  env <- load_conquest_p5_evidence_disposition_ledger()$env
  overlap <- env$mfrmr_cq_p5edl_overlap_registry()

  expect_identical(nrow(overlap), 5L)
  expect_identical(anyDuplicated(overlap$OverlapId), 0L)
  lineage_count <- table(overlap$EvidenceLineage)
  expect_identical(as.integer(lineage_count), c(3L, 2L))
  expect_identical(
    names(lineage_count),
    c("L1-six-arm-candidate-003", "L2-p2-minimum-candidate-004")
  )
  expect_true(any(grepl("item-only binary", overlap$Design, fixed = TRUE)))
  expect_true(any(grepl("connected-multibridge", overlap$Design, fixed = TRUE)))
  expect_true(all(grepl("population", overlap$ParameterClasses)))
  expect_false(any(overlap$InferenceReady))
  expect_false(any(overlap$GeneralInterchangeabilityInferred))
})

test_that("adverse and unresolved outcomes keep fixed denominators", {
  env <- load_conquest_p5_evidence_disposition_ledger()$env
  outcomes <- env$mfrmr_cq_p5edl_outcome_ledger()

  expect_identical(nrow(outcomes), 13L)
  expect_identical(anyDuplicated(outcomes$OutcomeId), 0L)
  expect_identical(
    outcomes$FixedDenominator,
    c(6L, 4L, 13L, 4L, 4L, 96L, 96L, 4L, 4L, 2L, 2L, 7L, 5073L)
  )
  expect_identical(
    outcomes$ObservedOrClassified,
    c(6L, 4L, 13L, 4L, 4L, 96L, 96L, 4L, 4L, 2L, 2L, 7L, 0L)
  )
  expect_true(all(c(
    "failed", "negative_control_rejection", "integration_limited",
    "ineligible", "unresolved", "negative_control"
  ) %in% outcomes$OutcomeClass))
  expect_false(any(outcomes$DropAllowed))
  expect_false(any(outcomes$PublicPromotionAuthorized))
})

test_that("public map supports only the pure-R handoff boundary", {
  env <- load_conquest_p5_evidence_disposition_ledger()$env
  public <- env$mfrmr_cq_p5edl_public_disposition()

  expect_identical(nrow(public), 10L)
  expect_identical(
    as.integer(table(factor(
      public$Disposition,
      levels = c("supported", "caveated", "disabled", "deferred")
    ))),
    c(1L, 2L, 5L, 2L)
  )
  expect_identical(
    public$DecisionId[public$Disposition == "supported"],
    "P1-pure-R-handoff"
  )
  expect_false(any(public$PublicTextChangeAuthorizedByThisLedger))
  expect_false(any(public$IndependentReviewRequiredBeforePromotion))
  expect_false(any(public$ScientificEquivalenceInferred))
})

test_that("review closes synthesis without making human review a release gate", {
  env <- load_conquest_p5_evidence_disposition_ledger()$env
  review <- env$mfrmr_cq_p5edl_review()

  expect_identical(
    review$status,
    "conquest_P5_evidence_and_disposition_ledger_complete_claim_scope_bounded"
  )
  expect_true(review$exact_overlap_stated)
  expect_true(review$adverse_and_unresolved_denominators_stated)
  expect_true(review$public_decisions_mapped)
  expect_false(review$independent_review_passed)
  expect_false(review$independent_review_required_before_public_promotion)
  expect_false(review$independent_review_blocks_0_2_3_release)
  expect_true(review$independent_review_optional_quality_enhancement)
  expect_false(review$release_spine_update_authorized)
  expect_false(review$public_text_change_authorized)
  expect_false(review$general_software_interchangeability_inferred)
})

test_that("the ledger cannot read results, fit, or launch", {
  ctx <- load_conquest_p5_evidence_disposition_ledger()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")

  expect_false(grepl("read[.]csv\\s*\\(|readRDS\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap expose synthesis without public edits", {
  ctx <- load_conquest_p5_evidence_disposition_ledger()
  record <- paste(readLines(file.path(
    ctx$validation, "conquest-p5-evidence-disposition-ledger-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p5edl_specification, fixed = TRUE)
  expect_match(record, "`PublicTextChangeAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap, "[x] State the exact matched overlap", fixed = TRUE
  )
  expect_match(
    roadmap, "[x] List all negative-control", fixed = TRUE
  )
  expect_match(
    roadmap, "[x] Map the evidence to public decisions", fixed = TRUE
  )
  expect_match(
    roadmap, "[ ] Update the release spine and public support boundary",
    fixed = TRUE
  )
})
