gtheory_multivariate_incidence_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_incidence <- function() {
  paths <- gtheory_multivariate_incidence_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtvi_balanced_fixture <- function() {
  data <- expand.grid(
    Object = paste0("P", seq_len(4L)),
    Stratum = c("A", "B"),
    Rater = c("R1", "R2"),
    Item = c("I1", "I2"),
    stringsAsFactors = FALSE
  )
  data$Score <- seq_len(nrow(data)) / 10
  data
}

gtvi_audit <- function(env, data, strata = c("A", "B"),
                       condition_scope = c(Rater = "global", Item = "global"),
                       missingness = "complete") {
  env$mfrmr_gtvi_audit(
    data = data, object_col = "Object", stratum_col = "Stratum",
    score_col = "Score", condition_cols = c("Rater", "Item"),
    condition_scope = condition_scope, strata = strata,
    missingness = missingness
  )
}

test_that("Draft.85b0 accepts linked balanced long-form incidence only", {
  env <- load_gtheory_multivariate_incidence()
  data <- gtvi_balanced_fixture()
  audit <- gtvi_audit(env, data)

  expect_s3_class(audit, "mfrmr_gtvi_audit")
  expect_identical(audit$ObjectColumn, "Object")
  expect_identical(audit$StratumColumn, "Stratum")
  expect_identical(audit$ScoreColumn, "Score")
  expect_true(audit$IncidenceReady)
  expect_identical(
    audit$AuditState, "incidence_ready_for_matched_backend_preflight"
  )
  expect_equal(audit$StratumAudit$RetainedRows, c(16L, 16L))
  expect_equal(audit$StratumAudit$ObservedObjects, c(4L, 4L))
  expect_equal(audit$ObjectPairAudit$SharedObjects, 4L)
  expect_true(audit$ObjectPairAudit$DirectCovarianceOverlapEligible)
  expect_true(audit$StratumGraphAudit$Connected)
  expect_true(audit$StratumGraphAudit$CompletePairwiseOverlap)
  expect_true(all(audit$ConditionPairAudit$SharingState == "observed_common"))
  expect_true(all(
    audit$ConditionPairAudit$CrossStratumCovarianceTarget ==
      "candidate_if_direct_overlap"
  ))
  expect_true(all(
    audit$ConditionPairAudit$DirectComponentCovarianceOverlapEligible
  ))
  expect_identical(audit$ObjectPatternAudit$Pattern, "A|B")
  expect_equal(audit$ObjectPatternAudit$ObjectCount, 4L)
  expect_match(audit$AuditHash, "^[0-9a-f]{64}$")
  expect_false(audit$EstimationReady)
  expect_false(audit$InferenceReady)
  expect_false(audit$CoefficientEligible)
  expect_false(audit$DecisionReady)
})

test_that("Draft.85b0 distinguishes global, partial, and local condition links", {
  env <- load_gtheory_multivariate_incidence()
  data <- gtvi_balanced_fixture()
  data$Rater[data$Stratum == "B" & data$Rater == "R1"] <- "R3"

  partial <- gtvi_audit(env, data)
  partial_rater <- partial$ConditionPairAudit[
    partial$ConditionPairAudit$Facet == "Rater", , drop = FALSE
  ]
  expect_identical(partial_rater$SharingState, "observed_partial")
  expect_equal(partial_rater$SharedLevels, 1L)
  expect_false(partial_rater$DirectComponentCovarianceOverlapEligible)
  expect_false(partial$IncidenceReady)
  expect_true(any(grepl(
    "insufficient_shared_global_conditions:Rater:A:B", partial$Issues,
    fixed = TRUE
  )))

  local <- gtvi_audit(
    env, data,
    condition_scope = c(Rater = "stratum_local", Item = "global")
  )
  local_rater <- local$ConditionPairAudit[
    local$ConditionPairAudit$Facet == "Rater", , drop = FALSE
  ]
  expect_identical(
    local_rater$SharingState, "structurally_disjoint_by_scope"
  )
  expect_identical(
    local_rater$CrossStratumCovarianceTarget, "structural_zero_by_scope"
  )
  expect_equal(local_rater$SharedLevels, 0L)
  expect_false(local_rater$DirectComponentCovarianceOverlapEligible)
  expect_true(local$IncidenceReady)
  expect_false(any(grepl(
    "insufficient_shared_global_conditions:Rater", local$Issues,
    fixed = TRUE
  )))
})

test_that("Draft.85b0 exposes indirect-only object links in three strata", {
  env <- load_gtheory_multivariate_incidence()
  make_rows <- function(objects, stratum) {
    data <- expand.grid(
      Object = objects, Rater = c("R1", "R2"), Item = c("I1", "I2"),
      stringsAsFactors = FALSE
    )
    data$Stratum <- stratum
    data$Score <- seq_len(nrow(data)) / 10
    data[c("Object", "Stratum", "Rater", "Item", "Score")]
  }
  data <- rbind(
    make_rows(c("P1", "P2", "P3"), "A"),
    make_rows(c("P2", "P3", "P4", "P5"), "B"),
    make_rows(c("P4", "P5", "P6"), "C")
  )
  audit <- gtvi_audit(env, data, strata = c("A", "B", "C"))

  expect_true(audit$StratumGraphAudit$Connected)
  expect_false(audit$StratumGraphAudit$CompletePairwiseOverlap)
  expect_false(audit$IncidenceReady)
  ac <- audit$ObjectPairAudit[
    audit$ObjectPairAudit$LeftStratum == "A" &
      audit$ObjectPairAudit$RightStratum == "C", , drop = FALSE
  ]
  expect_equal(ac$SharedObjects, 0L)
  expect_false(ac$DirectCovarianceOverlapEligible)
  expect_true(any(grepl(
    "insufficient_direct_object_overlap:A:C", audit$Issues, fixed = TRUE
  )))
  expect_true(all(c("A", "A|B", "B|C", "C") %in%
                    audit$ObjectPatternAudit$Pattern))
})

test_that("Draft.85b0 hashes row order and missingness separately", {
  env <- load_gtheory_multivariate_incidence()
  data <- gtvi_balanced_fixture()
  data$Score[[1L]] <- NA_real_
  first <- gtvi_audit(env, data, missingness = "MAR_covariate")
  replay <- gtvi_audit(
    env, data[rev(seq_len(nrow(data))), ], missingness = "MAR_covariate"
  )

  expect_equal(first$InputRows, 32L)
  expect_equal(first$RetainedRows, 31L)
  expect_equal(first$MissingScoreRows, 1L)
  expect_identical(first$CanonicalInputHash, replay$CanonicalInputHash)
  expect_identical(first$RetainedDataHash, replay$RetainedDataHash)
  expect_identical(first$OmissionPatternHash, replay$OmissionPatternHash)
  expect_identical(first$AuditHash, replay$AuditHash)

  conflict <- gtvi_audit(env, data, missingness = "complete")
  expect_false(conflict$IncidenceReady)
  expect_true("declared_complete_but_scores_missing" %in% conflict$Issues)
})

test_that("Draft.85b0 fails closed on ambiguous long-form semantics", {
  env <- load_gtheory_multivariate_incidence()
  data <- gtvi_balanced_fixture()

  expect_error(
    gtvi_audit(env, data, condition_scope = c(Rater = "global")),
    "named exactly"
  )
  expect_error(
    gtvi_audit(
      env, data,
      condition_scope = c(Rater = "unspecified", Item = "global")
    ),
    "global.*stratum_local"
  )
  unknown <- data
  unknown$Stratum[[1L]] <- "C"
  expect_error(gtvi_audit(env, unknown), "outside the declared order")

  missing_identity <- data
  missing_identity$Rater[[1L]] <- NA_character_
  expect_error(gtvi_audit(env, missing_identity), "must be nonmissing")

  infinite <- data
  infinite$Score[[1L]] <- Inf
  expect_error(gtvi_audit(env, infinite), "Inf and NaN")
  nan <- data
  nan$Score[[1L]] <- NaN
  expect_error(gtvi_audit(env, nan), "Inf and NaN")

  expect_error(
    env$mfrmr_gtvi_audit(
      data, "Object", "Stratum", "Score", c("Rater", "Item"),
      c(Rater = "global", Item = "global"), c("A", "B"),
      min_shared_objects = 1.5
    ),
    "positive integer"
  )
})
