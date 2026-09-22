gpcm_goip_p1q_paths <- function() {
  root <- testthat::test_path("..", "..")
  c(
    runner = file.path(
      root, "inst", "validation",
      "gpcm-owner-identity-propagation-p1q-0.2.3.R"
    ),
    owner_runner = file.path(
      root, "inst", "validation", "gpcm-owner-specific-pilot-0.2.3.R"
    ),
    api = file.path(root, "R", "api-estimation.R"),
    replay = file.path(root, "R", "api-export-bundles.R"),
    record = file.path(
      root, "inst", "validation",
      "gpcm-owner-identity-propagation-p1q-record-0.2.3.md"
    )
  )
}

gpcm_goip_p1q_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_goip_p1q_paths()
    testthat::skip_if_not(file.exists(paths[["runner"]]))
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    sys.source(paths[["runner"]], envir = value)
    value
  }
})

gpcm_goip_p1q_fixture <- function(env) {
  cells <- expand.grid(
    SlopeOwner = c("Criterion", "Rater"),
    Estimator = c("JML", "MML"),
    Replicate = seq_len(30L),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  cells <- cells[order(
    match(cells$SlopeOwner, c("Criterion", "Rater")),
    match(cells$Estimator, c("JML", "MML")), cells$Replicate
  ), , drop = FALSE]
  cells$ScenarioId <- sprintf("P1Q-S%03d", seq_len(nrow(cells)))
  cells$StepOwner <- cells$SlopeOwner
  cells$SlopeComposition <- "single_owner_relative_gm1"
  cells$LatentDimensionCount <- "1"
  cells$AbilityScaleContract <- ifelse(
    cells$Estimator == "MML", "standard_normal_latent_distribution",
    "fixed_person_coordinates"
  )
  cells$RuntimeIdentity <- paste(rep("a", 64L), collapse = "")
  manifest <- cells[, c(
    "ScenarioId", "SlopeOwner", "StepOwner", "SlopeComposition",
    "LatentDimensionCount", "Estimator", "AbilityScaleContract",
    "RuntimeIdentity"
  )]
  results <- manifest
  results$FitSucceeded <- TRUE
  keys <- unique(manifest[, c("SlopeOwner", "Estimator")])
  list(
    declared_manifest = manifest,
    manifest = manifest,
    results = results,
    summary = data.frame(ManifestRows = 120L),
    rate_summary = transform(keys, Planned = 30L),
    numeric_summary = transform(keys, Metric = "SlopeLogRMSE"),
    execution_identity = data.frame(
      ExecutionSHA256 = env$mfrmr_goip_p1q_historical_execution_sha256,
      RuntimeIdentity = manifest$RuntimeIdentity[[1L]],
      stringsAsFactors = FALSE
    ),
    execution_policy = data.frame(Profile = "pilot"),
    checkpoint_ledger = data.frame(
      ScenarioId = manifest$ScenarioId,
      CheckpointSHA256 = paste(rep("b", 64L), collapse = ""),
      stringsAsFactors = FALSE
    )
  )
}

test_that("P1q finds direct aggregate propagation gaps", {
  env <- gpcm_goip_p1q_environment()
  expect_identical(
    digest::digest(
      gpcm_goip_p1q_paths()[["runner"]],
      algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "8216884cb08948ae3be3b4134dacc07bcb88a635a6c96dce7e25f26d793dea73"
  )
  bundle <- gpcm_goip_p1q_fixture(env)
  audit <- env$mfrmr_goip_p1q_surface_table(bundle)

  expect_identical(audit$Surface, c(
    "declared_manifest", "manifest", "results", "summary",
    "rate_summary", "numeric_summary", "execution_identity",
    "execution_policy", "checkpoint_ledger"
  ))
  expect_true(all(
    audit$HistoricalIdentityFieldsPresent[1:3] == 7L
  ))
  expect_true(all(!audit$ExactCategorySupportDirect))
  expect_true(all(!audit$FullDirectIdentity))
})

test_that("P1q derives a complete envelope without changing evidence", {
  env <- gpcm_goip_p1q_environment()
  bundle <- gpcm_goip_p1q_fixture(env)
  source_hash <- env$mfrmr_goip_p1q_hash_object(bundle)
  envelope <- env$mfrmr_goip_p1q_build_envelope(bundle)

  expect_s3_class(envelope, "mfrmr_gpcm_owner_identity_envelope_p1q")
  expect_identical(nrow(envelope$identity_registry), 4L)
  expect_identical(
    unique(envelope$identity_registry$DeclaredCategorySupport), "1:4"
  )
  expect_true(all(envelope$surface_complete$FullIdentityRetained))
  expect_false(envelope$frozen_bundle_modified)
  expect_false(envelope$substantive_evidence_added)
  expect_identical(env$mfrmr_goip_p1q_hash_object(bundle), source_hash)
  expect_identical(envelope$source_bundle_sha256, source_hash)
  expect_identical(nrow(envelope$surfaces$results), 120L)
  expect_identical(nrow(envelope$surfaces$checkpoint_ledger), 120L)
})

test_that("P1q rejects a different historical execution", {
  env <- gpcm_goip_p1q_environment()
  bundle <- gpcm_goip_p1q_fixture(env)
  bundle$execution_identity$ExecutionSHA256 <- paste(
    rep("c", 64L), collapse = ""
  )
  expect_error(
    env$mfrmr_goip_p1q_build_envelope(bundle),
    "only the sealed Draft.66 execution identity",
    fixed = TRUE
  )
  bundle <- gpcm_goip_p1q_fixture(env)
  expect_error(
    env$mfrmr_goip_p1q_build_envelope(
      bundle, rating_min = 0L, rating_max = 3L
    ),
    "only the sealed Draft.66 declared category support 1:4",
    fixed = TRUE
  )
})

test_that("P1q separates historical and current MML scale contracts", {
  env <- gpcm_goip_p1q_environment()
  paths <- gpcm_goip_p1q_paths()
  audit <- env$mfrmr_goip_p1q_source_audit(
    paths[["owner_runner"]], paths[["api"]], paths[["replay"]]
  )

  expect_true(audit$HistoricalRunnerHashMatches)
  expect_false(audit$HistoricalRunnerExplicitlySetsMMLIdentification)
  expect_false(audit$HistoricalRunnerIdentityCheckIncludesAbilityScale)
  expect_true(audit$CurrentDefaultIsFreePopulation)
  expect_true(audit$CurrentReplayEmitsMMLIdentification)
  expect_true(audit$CurrentReplayRetainsRatingBounds)
})

test_that("P1q stored Draft.66 audit remains separately opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_P1Q_PILOT"), "true"),
    "set MFRMR_RUN_P1Q_PILOT=true and MFRMR_P1Q_BUNDLE_DIR"
  )
  env <- gpcm_goip_p1q_environment()
  paths <- gpcm_goip_p1q_paths()
  directory <- Sys.getenv("MFRMR_P1Q_BUNDLE_DIR")
  testthat::skip_if_not(dir.exists(directory))
  bundle <- readRDS(file.path(
    directory, "gpcm-owner-specific-pilot.rds"
  ))
  result <- env$mfrmr_run_gpcm_owner_identity_propagation_p1q(
    bundle = bundle,
    checkpoint_dir = file.path(directory, "checkpoints"),
    owner_runner = paths[["owner_runner"]],
    api_estimation = paths[["api"]],
    replay_source = paths[["replay"]]
  )
  expect_true(result$HistoricalRowIdentityRetained)
  expect_true(result$HistoricalCheckpointIdentityRetained)
  expect_true(all(result$checkpoint_audit$RowManifestHashValid))
  expect_true(all(result$checkpoint_audit$ResultHashValid))
  expect_true(all(result$checkpoint_audit$ResultIdentityMatchesManifest))
  expect_false(result$FrozenDirectPropagationComplete)
  expect_true(result$DerivedEnvelopePropagationComplete)
  expect_false(result$HistoricalPilotRepresentsCurrentDefaultMML)
  expect_false(result$IdentityPropagationRequiresAdditionalSimulation)
  expect_true(result$CurrentDefaultOwnerEvidenceStillRequired)
  expect_false(result$OwnerEvidenceGatePass)
  expect_false(result$BroadSimulationAuthorized)
})

test_that("P1q record preserves the bounded conclusion", {
  text <- paste(
    readLines(gpcm_goip_p1q_paths()[["record"]], warn = FALSE),
    collapse = "\n"
  )
  expect_match(text, "FrozenDirectPropagationComplete = FALSE", fixed = TRUE)
  expect_match(text, "DerivedEnvelopePropagationComplete = TRUE", fixed = TRUE)
  expect_match(
    text, "HistoricalPilotRepresentsCurrentDefaultMML = FALSE", fixed = TRUE
  )
  expect_match(
    text, "IdentityPropagationRequiresAdditionalSimulation = FALSE",
    fixed = TRUE
  )
  expect_match(text, "OwnerEvidenceGatePass = FALSE", fixed = TRUE)
  expect_match(text, "BroadSimulationAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
