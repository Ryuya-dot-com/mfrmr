# Draft.85c4d source-freeze admission preflight.
#
# Repository-internal only. This layer inventories the exact c1-c4c source and
# test snapshot and constructs the payload that a future external anchor would
# need. It does not clean or commit the worktree, materialize an immutable
# artifact, create a timestamp, contact an external service, or issue authority.

mfrmr_gtvk_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4d requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvk_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvk_command <- function(repo_root, arguments) {
  output <- tryCatch(suppressWarnings(system2(
    "git", c("-C", shQuote(repo_root), arguments),
    stdout = TRUE, stderr = TRUE
  )), error = function(condition) structure(
    conditionMessage(condition), status = 127L
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  list(Status = as.integer(status), Output = enc2utf8(as.character(output)))
}

mfrmr_gtvk_git_identity <- function(repo_root = ".") {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  commit_call <- mfrmr_gtvk_command(repo_root, c("rev-parse", "HEAD"))
  tree_call <- mfrmr_gtvk_command(repo_root, c("rev-parse", "HEAD^{tree}"))
  branch_call <- mfrmr_gtvk_command(
    repo_root, c("branch", "--show-current")
  )
  status_call <- mfrmr_gtvk_command(
    repo_root, c("status", "--porcelain=v1", "--untracked-files=all")
  )
  status_lines <- status_call$Output[nzchar(status_call$Output)]
  status_registry <- if (length(status_lines) == 0L) {
    data.frame(
      StatusOrdinal = integer(), IndexStatus = character(),
      WorktreeStatus = character(), Path = character(),
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(
      StatusOrdinal = seq_along(status_lines),
      IndexStatus = substring(status_lines, 1L, 1L),
      WorktreeStatus = substring(status_lines, 2L, 2L),
      Path = substring(status_lines, 4L),
      stringsAsFactors = FALSE
    )
  }
  commit <- if (commit_call$Status == 0L &&
                length(commit_call$Output) == 1L) {
    commit_call$Output[[1L]]
  } else NA_character_
  tree <- if (tree_call$Status == 0L && length(tree_call$Output) == 1L) {
    tree_call$Output[[1L]]
  } else NA_character_
  branch <- if (branch_call$Status == 0L &&
                length(branch_call$Output) == 1L &&
                nzchar(branch_call$Output[[1L]])) {
    branch_call$Output[[1L]]
  } else "(detached_or_unknown)"
  payload <- list(
    Contract = "gtheory_multivariate_git_identity_draft85c4d_v1",
    RepositoryName = basename(repo_root),
    HeadCommit = commit,
    HeadTree = tree,
    Branch = branch,
    StatusRegistry = status_registry,
    StatusRegistryHash = mfrmr_gtvk_hash(status_registry),
    StatusEntryCount = as.integer(nrow(status_registry)),
    StagedEntryCount = as.integer(sum(
      status_registry$IndexStatus != " " & status_registry$IndexStatus != "?"
    )),
    UnstagedEntryCount = as.integer(sum(
      status_registry$WorktreeStatus != " " &
        status_registry$WorktreeStatus != "?"
    )),
    UntrackedEntryCount = as.integer(sum(
      status_registry$IndexStatus == "?" &
        status_registry$WorktreeStatus == "?"
    ))
  )
  git_available <-
    is.character(commit) && length(commit) == 1L && !is.na(commit) &&
    grepl("^[0-9a-f]{40}$", commit) &&
    is.character(tree) && length(tree) == 1L && !is.na(tree) &&
    grepl("^[0-9a-f]{40}$", tree) && status_call$Status == 0L
  structure(c(payload, list(
    IdentityHash = mfrmr_gtvk_hash(payload),
    GitAvailable = git_available,
    Clean = git_available && nrow(status_registry) == 0L
  )), class = c("mfrmr_gtvk_git_identity", "list"))
}

mfrmr_gtvk_assert_git_identity <- function(identity) {
  payload_fields <- c(
    "Contract", "RepositoryName", "HeadCommit", "HeadTree", "Branch",
    "StatusRegistry", "StatusRegistryHash", "StatusEntryCount",
    "StagedEntryCount", "UnstagedEntryCount", "UntrackedEntryCount"
  )
  suffix_fields <- c("IdentityHash", "GitAvailable", "Clean")
  if (!mfrmr_gtvk_exact_object(
    identity, c(payload_fields, suffix_fields),
    c("mfrmr_gtvk_git_identity", "list")
  )) {
    stop("A typed Draft.85c4d Git identity is required.", call. = FALSE)
  }
  status <- identity$StatusRegistry
  valid_status <- is.data.frame(status) && identical(
    names(status),
    c("StatusOrdinal", "IndexStatus", "WorktreeStatus", "Path")
  ) && identical(status$StatusOrdinal, seq_len(nrow(status))) &&
    all(nchar(status$IndexStatus) == 1L) &&
    all(nchar(status$WorktreeStatus) == 1L) &&
    all(nzchar(status$Path))
  expected_staged <- sum(
    status$IndexStatus != " " & status$IndexStatus != "?"
  )
  expected_unstaged <- sum(
    status$WorktreeStatus != " " & status$WorktreeStatus != "?"
  )
  expected_untracked <- sum(
    status$IndexStatus == "?" & status$WorktreeStatus == "?"
  )
  git_available <- grepl("^[0-9a-f]{40}$", identity$HeadCommit) &&
    grepl("^[0-9a-f]{40}$", identity$HeadTree)
  valid <-
    identical(identity$Contract,
              "gtheory_multivariate_git_identity_draft85c4d_v1") &&
    is.character(identity$RepositoryName) &&
    length(identity$RepositoryName) == 1L &&
    nzchar(identity$RepositoryName) && valid_status &&
    identical(identity$StatusRegistryHash, mfrmr_gtvk_hash(status)) &&
    identical(identity$StatusEntryCount, as.integer(nrow(status))) &&
    identical(identity$StagedEntryCount, as.integer(expected_staged)) &&
    identical(identity$UnstagedEntryCount, as.integer(expected_unstaged)) &&
    identical(identity$UntrackedEntryCount, as.integer(expected_untracked)) &&
    identical(identity$IdentityHash,
              mfrmr_gtvk_hash(identity[payload_fields])) &&
    identical(identity$GitAvailable, git_available) &&
    identical(identity$Clean, git_available && nrow(status) == 0L)
  if (!valid) {
    stop("The Draft.85c4d Git identity or cleanliness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvk_upstream_roots <- function() {
  data.frame(
    RootOrdinal = 1:7,
    RootId = c(
      "c1_plan", "c1_plan_core", "c2_generator", "c3_admission",
      "c4a_candidate_receipt", "c4b_capability_evidence",
      "c4c_isolation_integration"
    ),
    SHA256 = c(
      "51f6d05a596cf05157b7599f48f29c144038e23b89cad045c47d8560d370cac2",
      "c61ddfcf59dec2e169079ad0d9a35ff8281925c105d426919180553794f368b2",
      "1bc7f3dd126803ab7d6165a8c81e6fe1a9e8ad7fa0e13ebdd5f7c4993f718308",
      "e1c7285018d814ac5332adb94f780e73410f70120cd079ca282d889935ea3b02",
      "aa0a3e95103e3d694b89fbba97a570668d5fd462bde75ca28df5dc6fdbe0e7ee",
      "f93584a4e4f3b8275c25ac5d8a31fd6eb9ccb5583dc8c6ced167da4598b1fb8c",
      "13004f7ca9074cd2737f41127adfa283faed3d1a62d1cc2bf1f3c153967ed64c"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvk_artifact_paths <- function() {
  c(
    "DESCRIPTION",
    file.path("inst", "validation", c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R",
      "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
      "gtheory-multivariate-k-oracle-prototype-0.2.4.R",
      "gtheory-multivariate-ademp-plan-prototype-0.2.4.R",
      "gtheory-multivariate-generator-preflight-0.2.4.R",
      "gtheory-multivariate-execution-admission-preflight-0.2.4.R",
      "gtheory-multivariate-candidate-receipt-preflight-0.2.4.R",
      "gtheory-multivariate-candidate-receipt-worker-0.2.4.R",
      "gtheory-multivariate-capability-isolation-preflight-0.2.4.R",
      "gtheory-multivariate-capability-worker-0.2.4.R",
      "gtheory-multivariate-isolation-integration-preflight-0.2.4.R",
      "gtheory-multivariate-source-freeze-admission-preflight-0.2.4.R"
    )),
    file.path("tests", "testthat", c(
      "test-gtheory-multivariate-algebra-prototype.R",
      "test-gtheory-multivariate-incidence-preflight.R",
      "test-gtheory-multivariate-matched-backend-prototype.R",
      "test-gtheory-multivariate-k-oracle-prototype.R",
      "test-gtheory-multivariate-ademp-plan-prototype.R",
      "test-gtheory-multivariate-generator-preflight.R",
      "test-gtheory-multivariate-execution-admission-preflight.R",
      "test-gtheory-multivariate-candidate-receipt-preflight.R",
      "test-gtheory-multivariate-capability-isolation-preflight.R",
      "test-gtheory-multivariate-isolation-integration-preflight.R",
      "test-gtheory-multivariate-source-freeze-admission-preflight.R"
    ))
  )
}

mfrmr_gtvk_file_hash <- function(path) {
  if (!file.exists(path) || dir.exists(path)) {
    stop("A Draft.85c4d source artifact is missing.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvk_artifact_registry <- function(repo_root = ".") {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  paths <- mfrmr_gtvk_artifact_paths()
  full_paths <- file.path(repo_root, paths)
  if (anyDuplicated(paths) || !all(file.exists(full_paths)) ||
      any(dir.exists(full_paths))) {
    stop("The Draft.85c4d artifact allowlist is incomplete or duplicated.",
         call. = FALSE)
  }
  role <- ifelse(
    paths == "DESCRIPTION", "package_metadata",
    ifelse(
      grepl("^tests/", paths), "regression_test",
      ifelse(
        grepl("worker-0[.]2[.]4[.]R$", paths), "standalone_worker",
        ifelse(
          grepl("source-freeze-admission", paths), "c4d_controller",
          "upstream_controller"
        )
      )
    )
  )
  data.frame(
    ArtifactOrdinal = seq_along(paths),
    Path = paths,
    Role = role,
    Bytes = as.numeric(file.info(full_paths)$size),
    SHA256 = vapply(full_paths, mfrmr_gtvk_file_hash, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvk_external_anchor_request <- function(git_identity, artifacts) {
  mfrmr_gtvk_assert_git_identity(git_identity)
  if (!is.data.frame(artifacts) || nrow(artifacts) != 26L ||
      !identical(artifacts$ArtifactOrdinal, 1:26) ||
      !identical(artifacts$Path, mfrmr_gtvk_artifact_paths()) ||
      anyNA(artifacts) || any(artifacts$Bytes <= 0) ||
      any(nchar(artifacts$SHA256) != 64L)) {
    stop("A canonical Draft.85c4d artifact registry is required.",
         call. = FALSE)
  }
  roots <- mfrmr_gtvk_upstream_roots()
  source_tree <- mfrmr_gtvk_hash(artifacts[c("Path", "SHA256")])
  artifact_digest <- mfrmr_gtvk_hash(list(
    UpstreamRootRegistryHash = mfrmr_gtvk_hash(roots),
    SourceTreeSHA256 = source_tree,
    ArtifactRegistryHash = mfrmr_gtvk_hash(artifacts)
  ))
  payload <- list(
    Contract = "gtheory_multivariate_external_anchor_request_draft85c4d_v1",
    PlanHash = roots$SHA256[roots$RootId == "c1_plan"],
    PlanCoreHash = roots$SHA256[roots$RootId == "c1_plan_core"],
    C4CManifestHash = roots$SHA256[
      roots$RootId == "c4c_isolation_integration"
    ],
    UpstreamRootRegistryHash = mfrmr_gtvk_hash(roots),
    SourceCommit = git_identity$HeadCommit,
    SourceCommitTree = git_identity$HeadTree,
    CandidateSourceTreeSHA256 = source_tree,
    CandidateArtifactSHA256 = artifact_digest,
    RequestedReceiptContract =
      "gtheory_multivariate_external_freeze_receipt_template_draft85c1_v1",
    RequiredExternalFields = c(
      "UTCFreezeTimestamp", "SignerOrAuthorityId", "ExternalRecordId",
      "ExternalAnchorProvider", "ExternalAnchorReference"
    )
  )
  structure(c(payload, list(
    RequestHash = mfrmr_gtvk_hash(payload),
    AnchorPayloadConstructed = TRUE,
    SourceSnapshotClean = git_identity$Clean,
    ImmutableArtifactMaterialized = FALSE,
    ExternalReceiptReceived = FALSE,
    ExternalAnchorRequestReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvk_anchor_request", "list"))
}

mfrmr_gtvk_implementation_identity <- function() {
  function_names <- c(
    "mfrmr_gtvk_hash", "mfrmr_gtvk_exact_object", "mfrmr_gtvk_command",
    "mfrmr_gtvk_git_identity", "mfrmr_gtvk_assert_git_identity",
    "mfrmr_gtvk_upstream_roots", "mfrmr_gtvk_artifact_paths",
    "mfrmr_gtvk_file_hash", "mfrmr_gtvk_artifact_registry",
    "mfrmr_gtvk_external_anchor_request",
    "mfrmr_gtvk_implementation_identity", "mfrmr_gtvk_manifest",
    "mfrmr_gtvk_assert_manifest", "mfrmr_gtvk_dispatch_guard"
  )
  environment <- environment(mfrmr_gtvk_implementation_identity)
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      if (!exists(name, envir = environment, inherits = FALSE)) {
        stop("A Draft.85c4d implementation function is missing: ", name, ".",
             call. = FALSE)
      }
      fun <- get(name, envir = environment, inherits = FALSE)
      mfrmr_gtvk_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvk_manifest <- function(
    repo_root = ".", git_identity = mfrmr_gtvk_git_identity(repo_root),
    artifacts = mfrmr_gtvk_artifact_registry(repo_root)) {
  mfrmr_gtvk_assert_git_identity(git_identity)
  current_git_identity <- mfrmr_gtvk_git_identity(repo_root)
  mfrmr_gtvk_assert_git_identity(current_git_identity)
  git_identity_matches_current <- identical(
    git_identity, current_git_identity
  )
  canonical_artifacts <- mfrmr_gtvk_artifact_registry(repo_root)
  if (!identical(artifacts, canonical_artifacts)) {
    stop("The Draft.85c4d source artifact registry was altered.",
         call. = FALSE)
  }
  roots <- mfrmr_gtvk_upstream_roots()
  request <- mfrmr_gtvk_external_anchor_request(git_identity, artifacts)
  implementation <- mfrmr_gtvk_implementation_identity()
  payload <- list(
    Contract = "gtheory_multivariate_source_freeze_admission_draft85c4d_v1",
    UpstreamRootRegistry = roots,
    UpstreamRootRegistryHash = mfrmr_gtvk_hash(roots),
    GitIdentity = git_identity,
    GitIdentityHash = git_identity$IdentityHash,
    CurrentGitIdentityHash = current_git_identity$IdentityHash,
    ArtifactRegistry = artifacts,
    ArtifactRegistryHash = mfrmr_gtvk_hash(artifacts),
    ExternalAnchorRequest = request,
    ExternalAnchorRequestHash = request$RequestHash,
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvk_hash(implementation),
    PlannedSeedMaterialIncluded = FALSE
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtvk_hash(payload),
    SourceArtifactRegistryReady = TRUE,
    CandidateSourceSnapshotReady = TRUE,
    GitIdentityMatchesCurrentRepository = git_identity_matches_current,
    CleanSourceIdentityReady =
      git_identity_matches_current && git_identity$Clean,
    AnchorPayloadConstructed = TRUE,
    ImmutableArtifactMaterialized = FALSE,
    ExternalAnchorRequestReady = FALSE,
    ExternalFreezeReady = FALSE,
    PreOutcomeFreezeExternallyAnchored = FALSE,
    RecoveryDesignFrozen = FALSE,
    C4CManifestSuperseded = FALSE,
    BackendQualificationReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    NegativeControlExecutionAuthorized = FALSE,
    ExecutionGateClosed = TRUE,
    BackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvk_manifest", "list"))
}

mfrmr_gtvk_assert_manifest <- function(
    manifest, repo_root = ".",
    git_identity = mfrmr_gtvk_git_identity(repo_root),
    artifacts = mfrmr_gtvk_artifact_registry(repo_root)) {
  canonical <- mfrmr_gtvk_manifest(repo_root, git_identity, artifacts)
  if (!mfrmr_gtvk_exact_object(
    manifest, names(canonical), class(canonical)
  ) || !identical(manifest, canonical)) {
    stop("The Draft.85c4d source-freeze manifest or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvk_dispatch_guard <- function(
    manifest, callback, ..., authorize = FALSE, repo_root = ".",
    git_identity = mfrmr_gtvk_git_identity(repo_root),
    artifacts = mfrmr_gtvk_artifact_registry(repo_root)) {
  mfrmr_gtvk_assert_manifest(
    manifest, repo_root, git_identity, artifacts
  )
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  stop(
    "Draft.85c4d has no clean externally anchored artifact; execution remains closed.",
    call. = FALSE
  )
}
