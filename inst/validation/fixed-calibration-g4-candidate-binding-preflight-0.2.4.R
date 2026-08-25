# 0.2.4 fixed-calibration G4 current-candidate binding preflight.
#
# Repository-internal and fail-closed. This file observes Git, package source,
# the prospective contract, and an optional source tarball. It neither changes
# Git nor builds, installs, tests, scores, checkpoints, or opens confirmation.

mfrmr_fc_g4b_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("G4 candidate binding requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_fc_g4b_file_hash <- function(path) {
  if (!file.exists(path) || dir.exists(path)) {
    stop("A required G4 candidate-binding file is absent.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_fc_g4b_command <- function(repo_root, arguments) {
  output <- tryCatch(
    suppressWarnings(system2(
      "git", c("-C", shQuote(repo_root), arguments),
      stdout = TRUE, stderr = TRUE
    )),
    error = function(condition) structure(
      conditionMessage(condition), status = 127L
    )
  )
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  list(Status = as.integer(status), Output = enc2utf8(as.character(output)))
}

mfrmr_fc_g4b_git_identity <- function(repo_root = ".") {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  commit_call <- mfrmr_fc_g4b_command(repo_root, c("rev-parse", "HEAD"))
  tree_call <- mfrmr_fc_g4b_command(repo_root, c("rev-parse", "HEAD^{tree}"))
  branch_call <- mfrmr_fc_g4b_command(
    repo_root, c("branch", "--show-current")
  )
  status_call <- mfrmr_fc_g4b_command(
    repo_root, c("status", "--porcelain=v1", "--untracked-files=all")
  )
  status_lines <- status_call$Output[nzchar(status_call$Output)]
  registry <- if (length(status_lines) == 0L) {
    data.frame(
      Ordinal = integer(), IndexStatus = character(),
      WorktreeStatus = character(), Path = character(),
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(
      Ordinal = seq_along(status_lines),
      IndexStatus = substring(status_lines, 1L, 1L),
      WorktreeStatus = substring(status_lines, 2L, 2L),
      Path = substring(status_lines, 4L),
      stringsAsFactors = FALSE
    )
  }
  scalar <- function(call) {
    if (call$Status == 0L && length(call$Output) == 1L) {
      call$Output[[1L]]
    } else {
      NA_character_
    }
  }
  commit <- scalar(commit_call)
  tree <- scalar(tree_call)
  branch <- scalar(branch_call)
  if (is.na(branch) || !nzchar(branch)) branch <- "(detached_or_unknown)"
  payload <- list(
    Contract = "mfrmr_fixed_calibration_g4_git_identity_v1",
    RepositoryRoot = repo_root,
    HeadCommit = commit,
    HeadTree = tree,
    Branch = branch,
    StatusRegistry = registry,
    StatusRegistryHash = mfrmr_fc_g4b_hash(registry),
    StatusEntryCount = as.integer(nrow(registry)),
    StagedEntryCount = as.integer(sum(
      registry$IndexStatus != " " & registry$IndexStatus != "?"
    )),
    UnstagedEntryCount = as.integer(sum(
      registry$WorktreeStatus != " " & registry$WorktreeStatus != "?"
    )),
    UntrackedEntryCount = as.integer(sum(
      registry$IndexStatus == "?" & registry$WorktreeStatus == "?"
    ))
  )
  available <-
    is.character(commit) && length(commit) == 1L && !is.na(commit) &&
    grepl("^[0-9a-f]{40}$", commit) &&
    is.character(tree) && length(tree) == 1L && !is.na(tree) &&
    grepl("^[0-9a-f]{40}$", tree) && status_call$Status == 0L
  structure(c(payload, list(
    IdentityHash = mfrmr_fc_g4b_hash(payload),
    GitAvailable = available,
    Clean = available && nrow(registry) == 0L
  )), class = c("mfrmr_fc_g4b_git_identity", "list"))
}

mfrmr_fc_g4b_assert_git_identity <- function(identity) {
  payload_names <- c(
    "Contract", "RepositoryRoot", "HeadCommit", "HeadTree", "Branch",
    "StatusRegistry", "StatusRegistryHash", "StatusEntryCount",
    "StagedEntryCount", "UnstagedEntryCount", "UntrackedEntryCount"
  )
  expected_names <- c(payload_names, "IdentityHash", "GitAvailable", "Clean")
  if (!identical(names(identity), expected_names) ||
      !identical(class(identity), c("mfrmr_fc_g4b_git_identity", "list"))) {
    stop("A typed G4 Git identity is required.", call. = FALSE)
  }
  registry <- identity$StatusRegistry
  valid_registry <- is.data.frame(registry) && identical(
    names(registry), c("Ordinal", "IndexStatus", "WorktreeStatus", "Path")
  ) && identical(registry$Ordinal, seq_len(nrow(registry))) &&
    all(nchar(registry$IndexStatus) == 1L) &&
    all(nchar(registry$WorktreeStatus) == 1L) && all(nzchar(registry$Path))
  available <- grepl("^[0-9a-f]{40}$", identity$HeadCommit) &&
    grepl("^[0-9a-f]{40}$", identity$HeadTree)
  valid <- valid_registry &&
    identical(identity$Contract, "mfrmr_fixed_calibration_g4_git_identity_v1") &&
    identical(identity$StatusRegistryHash, mfrmr_fc_g4b_hash(registry)) &&
    identical(identity$StatusEntryCount, as.integer(nrow(registry))) &&
    identical(identity$StagedEntryCount, as.integer(sum(
      registry$IndexStatus != " " & registry$IndexStatus != "?"
    ))) &&
    identical(identity$UnstagedEntryCount, as.integer(sum(
      registry$WorktreeStatus != " " & registry$WorktreeStatus != "?"
    ))) &&
    identical(identity$UntrackedEntryCount, as.integer(sum(
      registry$IndexStatus == "?" & registry$WorktreeStatus == "?"
    ))) &&
    identical(identity$IdentityHash, mfrmr_fc_g4b_hash(identity[payload_names])) &&
    identical(identity$GitAvailable, available) &&
    identical(identity$Clean, available && nrow(registry) == 0L)
  if (!valid) {
    stop("The G4 Git identity or cleanliness was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_fc_g4b_contract_context <- function(repo_root = ".") {
  path <- file.path(
    repo_root, "inst", "validation",
    "fixed-calibration-g4-current-source-contract-0.2.4.R"
  )
  if (!file.exists(path)) {
    stop("The amended G4 contract is absent.", call. = FALSE)
  }
  environment <- new.env(parent = globalenv())
  sys.source(path, envir = environment)
  review <- environment$mfrmr_fc_g4_current_review()
  if (!identical(
    review$status,
    "G4_current_rules_frozen_candidate_unbound_confirmation_unopened"
  ) || !isTRUE(review$rules_frozen) ||
      isTRUE(review$current_execution_opened) ||
      isTRUE(review$G4_exit_complete)) {
    stop("The amended G4 contract is not frozen and unopened.", call. = FALSE)
  }
  list(Path = normalizePath(path, mustWork = TRUE), Environment = environment,
       Review = review)
}

mfrmr_fc_g4b_package_version <- function(repo_root = ".") {
  description <- file.path(repo_root, "DESCRIPTION")
  value <- tryCatch(read.dcf(description, fields = "Version")[1L, 1L],
                    error = function(condition) NA_character_)
  as.character(value)
}

mfrmr_fc_g4b_file_registry <- function(root, paths, role) {
  if (anyDuplicated(paths) || length(paths) != length(role)) {
    stop("The G4 candidate source registry is duplicated or misaligned.",
         call. = FALSE)
  }
  full <- file.path(root, paths)
  if (!all(file.exists(full)) || any(dir.exists(full))) {
    stop("The G4 candidate source registry is incomplete.", call. = FALSE)
  }
  data.frame(
    Ordinal = seq_along(paths), Path = paths, Role = role,
    Bytes = as.numeric(file.info(full)$size),
    SHA256 = vapply(full, mfrmr_fc_g4b_file_hash, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4b_description_semantics <- function(source_path, built_path) {
  read_one <- function(path) {
    value <- tryCatch(read.dcf(path), error = function(condition) NULL)
    if (is.null(value) || nrow(value) != 1L || anyDuplicated(colnames(value))) {
      return(NULL)
    }
    value <- as.character(value[1L, ])
    names(value) <- colnames(read.dcf(path))
    value
  }
  normalize <- function(value) {
    trimws(gsub("[[:space:]]+", " ", as.character(value)))
  }
  source <- read_one(source_path)
  built <- read_one(built_path)
  allowed_added <- c("NeedsCompilation", "Packaged", "Author", "Maintainer")
  if (is.null(source) || is.null(built)) {
    return(list(
      Match = FALSE, SourceFields = character(), BuiltFields = character(),
      AddedFields = character(), ChangedSourceFields = character(),
      ErrorCode = "DESCRIPTION_DCF_INVALID"
    ))
  }
  source_fields <- names(source)
  built_fields <- names(built)
  missing <- setdiff(source_fields, built_fields)
  added <- setdiff(built_fields, source_fields)
  common <- intersect(source_fields, built_fields)
  changed <- common[normalize(source[common]) != normalize(built[common])]
  valid <- length(missing) == 0L && length(changed) == 0L &&
    all(added %in% allowed_added)
  list(
    Match = valid, SourceFields = source_fields, BuiltFields = built_fields,
    AddedFields = added, ChangedSourceFields = changed,
    ErrorCode = if (valid) "" else "DESCRIPTION_SEMANTIC_MISMATCH"
  )
}

mfrmr_fc_g4b_repository_registries <- function(repo_root = ".") {
  context <- mfrmr_fc_g4b_contract_context(repo_root)
  boundary <- context$Environment$mfrmr_fc_g4_current_production_boundary()
  production <- mfrmr_fc_g4b_file_registry(
    repo_root, boundary$Path, rep("production_boundary", nrow(boundary))
  )
  support_paths <- c(
    "inst/validation/fixed-calibration-g4-current-source-contract-0.2.4.R",
    "inst/validation/fixed-calibration-g4-confirmation-worker-0.2.4.R",
    "tests/testthat/test-fixed-calibration-g4-evidence.R",
    "inst/validation/fixed-calibration-g4-candidate-binding-preflight-0.2.4.R"
  )
  support <- mfrmr_fc_g4b_file_registry(
    repo_root, support_paths,
    c("contract", "confirmation_worker", "confirmation_test", "binding_preflight")
  )
  list(
    Production = production,
    ProductionRegistryHash = mfrmr_fc_g4b_hash(
      production[c("Path", "Bytes", "SHA256")]
    ),
    Support = support,
    SupportRegistryHash = mfrmr_fc_g4b_hash(
      support[c("Path", "Bytes", "SHA256")]
    ),
    ContractReview = context$Review
  )
}

mfrmr_fc_g4b_empty_tarball <- function(path = "", code = "TARBALL_ABSENT") {
  list(
    Contract = "mfrmr_fixed_calibration_g4_tarball_observation_v1",
    Path = as.character(path), Exists = FALSE, Safe = FALSE,
    PackageRoot = NA_character_, PackageVersion = NA_character_,
    TarballSHA256 = NA_character_, FileRegistry = data.frame(
      Ordinal = integer(), Path = character(), Bytes = numeric(),
      SHA256 = character(), stringsAsFactors = FALSE
    ),
    FileRegistryHash = NA_character_,
    DescriptionSemanticMatch = FALSE,
    DescriptionAddedFields = character(),
    DescriptionChangedSourceFields = character(),
    ProductionBoundaryMatchesRepository = FALSE,
    ErrorCode = code
  )
}

mfrmr_fc_g4b_tarball_observation <- function(
    tarball = NULL, repo_root = ".", repository_registries = NULL) {
  if (is.null(tarball) || length(tarball) != 1L || is.na(tarball) ||
      !nzchar(as.character(tarball))) {
    return(mfrmr_fc_g4b_empty_tarball())
  }
  tarball <- path.expand(as.character(tarball))
  if (!file.exists(tarball) || dir.exists(tarball)) {
    return(mfrmr_fc_g4b_empty_tarball(tarball, "TARBALL_ABSENT"))
  }
  gzip_magic <- tryCatch({
    connection <- file(tarball, open = "rb")
    tryCatch(
      readBin(connection, what = "raw", n = 2L),
      finally = close(connection)
    )
  }, error = function(condition) raw(0L))
  if (!identical(gzip_magic, as.raw(c(0x1f, 0x8b)))) {
    return(mfrmr_fc_g4b_empty_tarball(tarball, "TARBALL_INVALID"))
  }
  if (is.null(repository_registries)) {
    repository_registries <- mfrmr_fc_g4b_repository_registries(repo_root)
  }
  listed <- tryCatch(
    suppressWarnings(utils::untar(tarball, list = TRUE)),
    error = function(condition) NULL
  )
  if (is.null(listed) || length(listed) == 0L) {
    return(mfrmr_fc_g4b_empty_tarball(tarball, "TARBALL_INVALID"))
  }
  listed <- sub("/$", "", enc2utf8(as.character(listed)))
  unsafe <- grepl("^/", listed) | grepl("(^|/)\\.\\.(/|$)", listed)
  roots <- unique(sub("/.*$", "", listed[nzchar(listed)]))
  if (any(unsafe) || length(roots) != 1L || !identical(roots, "mfrmr")) {
    return(mfrmr_fc_g4b_empty_tarball(tarball, "TARBALL_LAYOUT_UNSAFE"))
  }
  extraction <- tempfile("mfrmr-g4-binding-")
  dir.create(extraction)
  on.exit(unlink(extraction, recursive = TRUE, force = TRUE), add = TRUE)
  extracted <- tryCatch({
    utils::untar(tarball, exdir = extraction)
    TRUE
  }, error = function(condition) FALSE)
  package_root <- file.path(extraction, roots)
  if (!isTRUE(extracted) || !dir.exists(package_root)) {
    return(mfrmr_fc_g4b_empty_tarball(tarball, "TARBALL_EXTRACTION_FAILED"))
  }
  files <- list.files(
    package_root, recursive = TRUE, full.names = FALSE, all.files = TRUE,
    include.dirs = FALSE, no.. = TRUE
  )
  files <- sort(enc2utf8(files))
  full <- file.path(package_root, files)
  if (length(files) == 0L || any(!file.exists(full)) || any(dir.exists(full))) {
    return(mfrmr_fc_g4b_empty_tarball(tarball, "TARBALL_FILE_REGISTRY_INVALID"))
  }
  registry <- data.frame(
    Ordinal = seq_along(files), Path = files,
    Bytes = as.numeric(file.info(full)$size),
    SHA256 = vapply(full, mfrmr_fc_g4b_file_hash, character(1L)),
    stringsAsFactors = FALSE
  )
  description <- file.path(package_root, "DESCRIPTION")
  package_version <- tryCatch(
    as.character(read.dcf(description, fields = "Version")[1L, 1L]),
    error = function(condition) NA_character_
  )
  production <- repository_registries$Production
  tar_index <- match(production$Path, registry$Path)
  description_semantics <- mfrmr_fc_g4b_description_semantics(
    file.path(repo_root, "DESCRIPTION"),
    file.path(package_root, "DESCRIPTION")
  )
  code_rows <- production$Path != "DESCRIPTION"
  code_matches <- !anyNA(tar_index[code_rows]) && identical(
    unname(registry$SHA256[tar_index[code_rows]]),
    unname(production$SHA256[code_rows])
  )
  boundary_matches <- code_matches && isTRUE(description_semantics$Match)
  list(
    Contract = "mfrmr_fixed_calibration_g4_tarball_observation_v1",
    Path = normalizePath(tarball, mustWork = TRUE), Exists = TRUE, Safe = TRUE,
    PackageRoot = roots, PackageVersion = package_version,
    TarballSHA256 = mfrmr_fc_g4b_file_hash(tarball),
    FileRegistry = registry,
    FileRegistryHash = mfrmr_fc_g4b_hash(registry),
    DescriptionSemanticMatch = isTRUE(description_semantics$Match),
    DescriptionAddedFields = description_semantics$AddedFields,
    DescriptionChangedSourceFields =
      description_semantics$ChangedSourceFields,
    ProductionBoundaryMatchesRepository = boundary_matches,
    ErrorCode = if (boundary_matches) "" else "TARBALL_SOURCE_MISMATCH"
  )
}

mfrmr_fc_g4b_reason_table <- function(codes) {
  codes <- unique(as.character(codes[nzchar(codes)]))
  data.frame(
    Ordinal = seq_along(codes), Code = codes,
    Disposition = "candidate_binding_refused_confirmation_unopened",
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4b_manifest <- function(
    repo_root = ".", tarball = NULL,
    git_identity = mfrmr_fc_g4b_git_identity(repo_root)) {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  mfrmr_fc_g4b_assert_git_identity(git_identity)
  live_git <- mfrmr_fc_g4b_git_identity(repo_root)
  mfrmr_fc_g4b_assert_git_identity(live_git)
  git_current <- identical(git_identity, live_git)
  registries <- mfrmr_fc_g4b_repository_registries(repo_root)
  version <- mfrmr_fc_g4b_package_version(repo_root)
  tar_observation <- mfrmr_fc_g4b_tarball_observation(
    tarball, repo_root, registries
  )
  support <- registries$Support
  support_hash <- function(role) {
    value <- support$SHA256[support$Role == role]
    if (length(value) == 1L) value else NA_character_
  }
  binding <- data.frame(
    Field = c(
      "GitCommitSHA40", "GitTreeClean", "PackageVersion",
      "SourceTarballSHA256", "SourceTarballFileRegistrySHA256",
      "ProductionBoundaryRegistrySHA256", "ConfirmationWorkerSHA256",
      "ConfirmationTestSHA256", "ContractSHA256"
    ),
    Value = c(
      git_identity$HeadCommit,
      if (git_current && git_identity$Clean) "TRUE" else "FALSE",
      version, tar_observation$TarballSHA256,
      tar_observation$FileRegistryHash,
      registries$ProductionRegistryHash,
      support_hash("confirmation_worker"),
      support_hash("confirmation_test"), support_hash("contract")
    ),
    Required = TRUE,
    stringsAsFactors = FALSE
  )
  codes <- character()
  if (!git_current) codes <- c(codes, "GIT_IDENTITY_NOT_CURRENT")
  if (!git_identity$GitAvailable) codes <- c(codes, "GIT_UNAVAILABLE")
  if (!git_identity$Clean || !git_current) codes <- c(codes, "WORKTREE_DIRTY_OR_UNBOUND")
  if (!identical(version, "0.2.4.9000")) {
    codes <- c(codes, "PACKAGE_VERSION_INVALID")
  }
  if (!tar_observation$Exists || !tar_observation$Safe) {
    codes <- c(codes, tar_observation$ErrorCode)
  } else {
    if (!identical(tar_observation$PackageVersion, version)) {
      codes <- c(codes, "TARBALL_VERSION_MISMATCH")
    }
    if (!tar_observation$ProductionBoundaryMatchesRepository) {
      codes <- c(codes, "TARBALL_SOURCE_MISMATCH")
    }
  }
  if (anyNA(binding$Value) || any(!nzchar(binding$Value))) {
    codes <- c(codes, "BINDING_FIELD_INCOMPLETE")
  }
  refusals <- mfrmr_fc_g4b_reason_table(codes)
  complete <- nrow(refusals) == 0L && all(nchar(binding$Value) > 0L)
  payload <- list(
    Contract = "mfrmr_fixed_calibration_g4_candidate_binding_preflight_v1",
    ProspectiveContract = registries$ContractReview$contract_version,
    ProspectiveSpecification = registries$ContractReview$specification,
    ObservedGitIdentity = git_identity,
    LiveGitIdentityHash = live_git$IdentityHash,
    GitIdentityMatchesLive = git_current,
    ProductionRegistry = registries$Production,
    ProductionRegistryHash = registries$ProductionRegistryHash,
    SupportRegistry = registries$Support,
    SupportRegistryHash = registries$SupportRegistryHash,
    TarballObservation = tar_observation,
    Binding = binding,
    Refusals = refusals
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_fc_g4b_hash(payload),
    CandidateBindingComplete = complete,
    IsolatedExecutionAdmissionReady = complete,
    CurrentExecutionOpened = FALSE,
    ConfirmationResultObserved = FALSE,
    CORE05Complete = FALSE,
    CORE06Complete = FALSE,
    G4ExitComplete = FALSE,
    G6Authorized = FALSE,
    PublicAPIAuthorized = FALSE
  )), class = c("mfrmr_fc_g4b_manifest", "list"))
}

mfrmr_fc_g4b_assert_manifest <- function(manifest, repo_root = ".",
                                         tarball = NULL) {
  canonical <- mfrmr_fc_g4b_manifest(repo_root, tarball)
  if (!identical(manifest, canonical)) {
    stop("The G4 candidate-binding manifest or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_fc_g4b_require_bound_candidate <- function(manifest, repo_root = ".",
                                                  tarball = NULL) {
  mfrmr_fc_g4b_assert_manifest(manifest, repo_root, tarball)
  if (!isTRUE(manifest$CandidateBindingComplete)) {
    codes <- paste(manifest$Refusals$Code, collapse = ", ")
    stop("G4 candidate binding is incomplete: ", codes, ".", call. = FALSE)
  }
  invisible(TRUE)
}
