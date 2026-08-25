gtheory_multivariate_source_freeze_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-source-freeze-admission-preflight-0.2.4.R"
  )
}

load_gtheory_multivariate_source_freeze <- local({
  environment <- NULL
  function() {
    path <- gtheory_multivariate_source_freeze_path()
    skip_if_not(file.exists(path),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      sys.source(path, envir = environment)
    }
    environment
  }
})

gtvk_repo_root <- function() {
  testthat::test_path("..", "..")
}

gtvk_objects <- local({
  objects <- NULL
  function(env) {
    if (is.null(objects)) {
      root <- gtvk_repo_root()
      git <- env$mfrmr_gtvk_git_identity(root)
      artifacts <- env$mfrmr_gtvk_artifact_registry(root)
      manifest <- env$mfrmr_gtvk_manifest(root, git, artifacts)
      objects <<- list(
        root = root, git = git, artifacts = artifacts, manifest = manifest
      )
    }
    objects
  }
})

gtvk_rehash_git <- function(env, identity, status) {
  identity$StatusRegistry <- status
  identity$StatusRegistryHash <- env$mfrmr_gtvk_hash(status)
  identity$StatusEntryCount <- as.integer(nrow(status))
  identity$StagedEntryCount <- as.integer(sum(
    status$IndexStatus != " " & status$IndexStatus != "?"
  ))
  identity$UnstagedEntryCount <- as.integer(sum(
    status$WorktreeStatus != " " & status$WorktreeStatus != "?"
  ))
  identity$UntrackedEntryCount <- as.integer(sum(
    status$IndexStatus == "?" & status$WorktreeStatus == "?"
  ))
  payload_fields <- c(
    "Contract", "RepositoryName", "HeadCommit", "HeadTree", "Branch",
    "StatusRegistry", "StatusRegistryHash", "StatusEntryCount",
    "StagedEntryCount", "UnstagedEntryCount", "UntrackedEntryCount"
  )
  identity$IdentityHash <- env$mfrmr_gtvk_hash(identity[payload_fields])
  identity$GitAvailable <- TRUE
  identity$Clean <- nrow(status) == 0L
  identity
}

test_that("Draft.85c4d owns a distinct fourteen-function namespace", {
  env <- load_gtheory_multivariate_source_freeze()
  identity <- env$mfrmr_gtvk_implementation_identity()
  expect_identical(nrow(identity), 14L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvk_", identity$Function)))
  expect_true(all(nchar(identity$SHA256) == 64L))
})

test_that("Draft.85c4d hashes the exact source and test allowlist", {
  env <- load_gtheory_multivariate_source_freeze()
  objects <- gtvk_objects(env)
  artifacts <- objects$artifacts
  expect_identical(nrow(artifacts), 26L)
  expect_identical(artifacts$ArtifactOrdinal, 1:26)
  expect_identical(artifacts$Path, env$mfrmr_gtvk_artifact_paths())
  expect_identical(anyDuplicated(artifacts$Path), 0L)
  expect_true(all(artifacts$Bytes > 0))
  expect_true(all(nchar(artifacts$SHA256) == 64L))
  expect_false(any(grepl("^/|(^|/)\\.\\.(/|$)", artifacts$Path)))
  expect_identical(sum(artifacts$Role == "standalone_worker"), 2L)
  expect_identical(sum(artifacts$Role == "regression_test"), 11L)
})

test_that("Draft.85c4d Git identity derives cleanliness from status", {
  env <- load_gtheory_multivariate_source_freeze()
  identity <- gtvk_objects(env)$git
  status <- identity$StatusRegistry
  expect_silent(env$mfrmr_gtvk_assert_git_identity(identity))
  expect_s3_class(identity, "mfrmr_gtvk_git_identity")
  expect_true(identity$GitAvailable)
  expect_match(identity$HeadCommit, "^[0-9a-f]{40}$")
  expect_match(identity$HeadTree, "^[0-9a-f]{40}$")
  expect_identical(identity$StatusEntryCount, as.integer(nrow(status)))
  expect_identical(identity$Clean, nrow(status) == 0L)
  expect_identical(
    identity$StatusRegistryHash, env$mfrmr_gtvk_hash(status)
  )
})

test_that("Draft.85c4d constructs but cannot issue an external request", {
  env <- load_gtheory_multivariate_source_freeze()
  objects <- gtvk_objects(env)
  request <- objects$manifest$ExternalAnchorRequest
  expect_s3_class(request, "mfrmr_gtvk_anchor_request")
  expect_true(request$AnchorPayloadConstructed)
  expect_identical(request$SourceSnapshotClean, objects$git$Clean)
  expect_false(request$ImmutableArtifactMaterialized)
  expect_false(request$ExternalReceiptReceived)
  expect_false(request$ExternalAnchorRequestReady)
  expect_identical(request$RequiredExternalFields, c(
    "UTCFreezeTimestamp", "SignerOrAuthorityId", "ExternalRecordId",
    "ExternalAnchorProvider", "ExternalAnchorReference"
  ))
  expect_false(any(request$RequiredExternalFields %in% names(request)))
})

test_that("Draft.85c4d keeps source, artifact, and external states separate", {
  env <- load_gtheory_multivariate_source_freeze()
  objects <- gtvk_objects(env)
  manifest <- objects$manifest
  expect_silent(env$mfrmr_gtvk_assert_manifest(
    manifest, objects$root, objects$git, objects$artifacts
  ))
  expect_s3_class(manifest, "mfrmr_gtvk_manifest")
  expect_true(manifest$SourceArtifactRegistryReady)
  expect_true(manifest$CandidateSourceSnapshotReady)
  expect_true(manifest$GitIdentityMatchesCurrentRepository)
  expect_identical(manifest$CleanSourceIdentityReady, objects$git$Clean)
  expect_true(manifest$AnchorPayloadConstructed)
  expect_false(manifest$ImmutableArtifactMaterialized)
  expect_false(manifest$ExternalAnchorRequestReady)
  expect_false(manifest$ExternalFreezeReady)
  expect_false(manifest$PreOutcomeFreezeExternallyAnchored)
  expect_false(manifest$RecoveryDesignFrozen)
  expect_false(manifest$C4CManifestSuperseded)
  expect_true(manifest$ExecutionGateClosed)
  expect_false(manifest$PlannedSeedMaterialIncluded)
})

test_that("Draft.85c4d refuses synthetic clean-status promotion", {
  env <- load_gtheory_multivariate_source_freeze()
  objects <- gtvk_objects(env)
  empty_status <- objects$git$StatusRegistry[FALSE, , drop = FALSE]
  clean <- gtvk_rehash_git(env, objects$git, empty_status)
  expect_silent(env$mfrmr_gtvk_assert_git_identity(clean))
  manifest <- env$mfrmr_gtvk_manifest(
    objects$root, clean, objects$artifacts
  )
  expect_false(manifest$GitIdentityMatchesCurrentRepository)
  expect_false(manifest$CleanSourceIdentityReady)
  expect_true(manifest$ExternalAnchorRequest$SourceSnapshotClean)
  expect_false(manifest$ImmutableArtifactMaterialized)
  expect_false(manifest$ExternalAnchorRequestReady)
  expect_false(manifest$ExternalFreezeReady)
  expect_true(manifest$ExecutionGateClosed)
})

test_that("Draft.85c4d rejects forged clean and artifact identities", {
  env <- load_gtheory_multivariate_source_freeze()
  objects <- gtvk_objects(env)
  forged_git <- objects$git
  forged_git$Clean <- !forged_git$Clean
  expect_error(env$mfrmr_gtvk_assert_git_identity(forged_git),
               "identity or cleanliness was altered")

  changed_artifacts <- objects$artifacts
  changed_artifacts$SHA256[[1L]] <- paste(rep("0", 64L), collapse = "")
  expect_error(env$mfrmr_gtvk_manifest(
    objects$root, objects$git, changed_artifacts
  ), "source artifact registry was altered")
})

test_that("Draft.85c4d rejects rehashed readiness mutation", {
  env <- load_gtheory_multivariate_source_freeze()
  objects <- gtvk_objects(env)
  changed <- objects$manifest
  changed$ExternalFreezeReady <- TRUE
  expect_error(env$mfrmr_gtvk_assert_manifest(
    changed, objects$root, objects$git, objects$artifacts
  ), "source-freeze manifest or readiness was altered")

  changed <- objects$manifest
  changed$ExternalAnchorRequest$ExternalReceiptReceived <- TRUE
  changed$ExternalAnchorRequestHash <- env$mfrmr_gtvk_hash(
    changed$ExternalAnchorRequest
  )
  expect_error(env$mfrmr_gtvk_assert_manifest(
    changed, objects$root, objects$git, objects$artifacts
  ), "source-freeze manifest or readiness was altered")
})

test_that("Draft.85c4d dispatch cannot be opened by the caller", {
  env <- load_gtheory_multivariate_source_freeze()
  objects <- gtvk_objects(env)
  state <- new.env(parent = emptyenv())
  state$calls <- 0L
  callback <- function(...) {
    state$calls <- state$calls + 1L
    "unreachable"
  }
  for (authorize in c(FALSE, TRUE)) {
    expect_error(env$mfrmr_gtvk_dispatch_guard(
      objects$manifest, callback, authorize = authorize,
      repo_root = objects$root, git_identity = objects$git,
      artifacts = objects$artifacts
    ), "execution remains closed")
  }
  expect_identical(state$calls, 0L)
})

test_that("Draft.85c4d remains internal and opens no execution material", {
  env <- load_gtheory_multivariate_source_freeze()
  objects <- gtvk_objects(env)
  manifest <- objects$manifest
  closed <- c(
    "BackendQualificationReady", "PilotExecutionAuthorized",
    "ConfirmationExecutionAuthorized", "NegativeControlExecutionAuthorized",
    "BackendExecutionOccurred", "PlannedResponseGenerated",
    "RecoveryExecuted", "RecoveryEvidenceReady", "EstimationReady",
    "InferenceReady", "DecisionReady", "PublicSupportReady"
  )
  expect_false(any(vapply(closed, function(name) manifest[[name]],
                          logical(1L))))
  function_text <- vapply(
    env$mfrmr_gtvk_implementation_identity()$Function,
    function(name) paste(deparse(body(get(name, envir = env))), collapse = "\n"),
    character(1L)
  )
  expect_false(any(grepl("lme4::|glmmTMB::|ConQuest", function_text)))

  public_paths <- testthat::test_path(
    "..", "..", c("R", "man", "vignettes", "NEWS.md", "ROADMAP.md")
  )
  public_files <- unlist(lapply(public_paths, function(path) {
    if (dir.exists(path)) list.files(path, recursive = TRUE, full.names = TRUE)
    else path[file.exists(path)]
  }), use.names = FALSE)
  public_files <- public_files[!dir.exists(public_files)]
  public_files <- public_files[grepl(
    "\\.(R|Rd|Rmd|md)$|(^|/)(NEWS|ROADMAP)\\.md$", public_files
  )]
  public_text <- unlist(lapply(public_files, function(path) {
    readLines(path, warn = FALSE, encoding = "UTF-8")
  }), use.names = FALSE)
  expect_false(any(grepl("Draft\\.85c4d|mfrmr_gtvk_", public_text)))
})
