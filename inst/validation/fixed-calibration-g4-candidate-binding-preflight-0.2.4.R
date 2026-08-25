# 0.2.4 fixed-calibration G4 current-candidate binding preflight.
#
# Repository-internal and fail-closed. This file observes Git, package source,
# the prospective contract, and an optional source tarball. It neither changes
# Git nor builds, installs, tests, scores, checkpoints, or opens confirmation.

mfrmr_fc_g4b_canonical_tokens <- function(value) {
  encode_character <- function(item) {
    if (is.na(item)) return("NA")
    bytes <- charToRaw(enc2utf8(item))
    paste0("utf8:", paste(sprintf("%02x", as.integer(bytes)), collapse = ""))
  }
  encode_atomic <- function(item) {
    type <- typeof(item)
    encoded <- switch(
      type,
      character = vapply(item, encode_character, character(1L)),
      logical = ifelse(is.na(item), "NA", ifelse(item, "TRUE", "FALSE")),
      integer = ifelse(is.na(item), "NA", as.character(item)),
      double = vapply(item, function(number) {
        if (is.na(number) && !is.nan(number)) return("NA")
        if (is.nan(number)) return("NaN")
        if (is.infinite(number)) {
          return(if (number > 0) "Inf" else "-Inf")
        }
        sprintf("%a", number)
      }, character(1L)),
      raw = sprintf("%02x", as.integer(item)),
      stop("The G4 canonical hash received an unsupported atomic type.",
           call. = FALSE)
    )
    c(
      paste0("atomic_type:", type),
      paste0("atomic_length:", length(item)),
      "atomic_names_begin",
      if (is.null(names(item))) "names:null" else
        mfrmr_fc_g4b_canonical_tokens(names(item)),
      "atomic_names_end",
      paste0("atomic_value:", seq_along(encoded), ":", encoded)
    )
  }

  if (is.null(value)) return("null")
  if (is.data.frame(value)) {
    columns <- unlist(lapply(seq_along(value), function(index) {
      c(
        paste0("data_frame_column_begin:", index),
        mfrmr_fc_g4b_canonical_tokens(value[[index]]),
        paste0("data_frame_column_end:", index)
      )
    }), use.names = FALSE)
    return(c(
      "data_frame_v1", paste0("rows:", nrow(value)),
      paste0("columns:", ncol(value)), "column_names_begin",
      mfrmr_fc_g4b_canonical_tokens(names(value)), "column_names_end",
      "row_names_begin",
      mfrmr_fc_g4b_canonical_tokens(rownames(value)), "row_names_end",
      columns
    ))
  }
  if (is.factor(value)) {
    return(c(
      "factor_v1", paste0("ordered:", is.ordered(value)),
      "levels_begin", mfrmr_fc_g4b_canonical_tokens(levels(value)),
      "levels_end", "codes_begin",
      mfrmr_fc_g4b_canonical_tokens(unclass(value)), "codes_end"
    ))
  }
  if (is.list(value)) {
    items <- unlist(lapply(seq_along(value), function(index) {
      c(
        paste0("list_item_begin:", index),
        mfrmr_fc_g4b_canonical_tokens(value[[index]]),
        paste0("list_item_end:", index)
      )
    }), use.names = FALSE)
    return(c(
      "list_v1", paste0("length:", length(value)), "list_names_begin",
      if (is.null(names(value))) "names:null" else
        mfrmr_fc_g4b_canonical_tokens(names(value)),
      "list_names_end", items
    ))
  }
  if (is.object(value)) {
    stop("The G4 canonical hash received an unsupported value.", call. = FALSE)
  }
  if (is.atomic(value) && is.null(dim(value))) return(encode_atomic(value))
  stop("The G4 canonical hash received an unsupported value.", call. = FALSE)
}

mfrmr_fc_g4b_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("G4 candidate binding requires `digest`.", call. = FALSE)
  }
  canonical <- paste(
    c("mfrmr_g4_canonical_text_v1", mfrmr_fc_g4b_canonical_tokens(value)),
    collapse = "\n"
  )
  digest::digest(canonical, algo = "sha256", serialize = FALSE)
}

mfrmr_fc_g4b_file_hash <- function(path) {
  if (!file.exists(path) || dir.exists(path)) {
    stop("A required G4 candidate-binding file is absent.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_fc_g4b_text_file_observation <- function(path) {
  if (!file.exists(path) || dir.exists(path)) {
    stop("A required G4 candidate-binding text file is absent.",
         call. = FALSE)
  }
  size <- file.info(path)$size
  bytes <- readBin(path, what = "raw", n = size)
  text <- tryCatch(rawToChar(bytes), error = identity)
  if (inherits(text, "error")) {
    stop("A G4 source-identity text file is not canonicalizable.",
         call. = FALSE)
  }
  text <- gsub("\r\n", "\n", text, fixed = TRUE, useBytes = TRUE)
  text <- gsub("\r", "\n", text, fixed = TRUE, useBytes = TRUE)
  canonical <- charToRaw(text)
  list(
    Bytes = as.numeric(length(canonical)),
    SHA256 = digest::digest(
      canonical, algo = "sha256", serialize = FALSE
    )
  )
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
  observation <- lapply(full, mfrmr_fc_g4b_text_file_observation)
  data.frame(
    Ordinal = seq_along(paths), Path = paths, Role = role,
    Bytes = vapply(observation, `[[`, numeric(1L), "Bytes"),
    SHA256 = vapply(observation, `[[`, character(1L), "SHA256"),
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
    "inst/validation/fixed-calibration-g4-candidate-binding-preflight-0.2.4.R",
    "inst/validation/fixed-calibration-g4-hosted-runner-0.2.4.R",
    ".github/workflows/R-CMD-check-cell.yaml",
    ".github/workflows/R-CMD-check.yaml"
  )
  support <- mfrmr_fc_g4b_file_registry(
    repo_root, support_paths,
    c(
      "contract", "confirmation_worker", "confirmation_test",
      "binding_preflight", "hosted_runner", "hosted_cell_workflow",
      "hosted_matrix_workflow"
    )
  )
  worker_path <- file.path(
    repo_root, "inst", "validation",
    "fixed-calibration-g4-confirmation-worker-0.2.4.R"
  )
  worker_environment <- new.env(parent = globalenv())
  worker_error <- tryCatch({
    sys.source(worker_path, envir = worker_environment)
    NULL
  }, error = identity)
  denominator <- context$Environment$mfrmr_fc_g4_current_denominator()
  worker_ids <- if (is.null(worker_error) &&
      exists("mfrmr_fc_g4w_cell_ids", envir = worker_environment,
             inherits = FALSE)) {
    tryCatch(
      worker_environment$mfrmr_fc_g4w_cell_ids(), error = identity
    )
  } else {
    if (is.null(worker_error)) {
      simpleError("The confirmation worker has no cell registry.")
    } else {
      worker_error
    }
  }
  handler_names <- if (!inherits(worker_ids, "error") &&
      exists("mfrmr_fc_g4w_current_handlers", envir = worker_environment,
             inherits = FALSE)) {
    tryCatch(names(worker_environment$mfrmr_fc_g4w_current_handlers(
      context$Environment, normalizePath(repo_root, mustWork = TRUE),
      normalizePath(worker_path, mustWork = TRUE)
    )), error = identity)
  } else {
    worker_ids
  }
  worker_coverage <- list(
    Contract = "mfrmr_fixed_calibration_g4_worker_denominator_coverage_v1",
    ExpectedCellIds = denominator$CellId,
    WorkerCellIds = if (inherits(worker_ids, "error")) character() else
      as.character(worker_ids),
    HandlerNames = if (inherits(handler_names, "error")) character() else
      as.character(handler_names),
    Error = if (inherits(worker_ids, "error")) conditionMessage(worker_ids) else
      if (inherits(handler_names, "error")) conditionMessage(handler_names) else "",
    Exact = !inherits(worker_ids, "error") &&
      !inherits(handler_names, "error") &&
      identical(as.character(worker_ids), denominator$CellId) &&
      identical(as.character(handler_names), denominator$CellId)
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
    WorkerDenominatorCoverage = worker_coverage,
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
    SHA256 = unname(vapply(
      full, mfrmr_fc_g4b_file_hash, character(1L)
    )),
    stringsAsFactors = FALSE
  )
  rownames(registry) <- NULL
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
  tar_code_hashes <- if (!anyNA(tar_index[code_rows])) {
    vapply(
      full[tar_index[code_rows]],
      function(path) mfrmr_fc_g4b_text_file_observation(path)$SHA256,
      character(1L)
    )
  } else {
    character()
  }
  code_matches <- !anyNA(tar_index[code_rows]) && identical(
    unname(tar_code_hashes), unname(production$SHA256[code_rows])
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
    Disposition = rep(
      "candidate_binding_refused_confirmation_unopened", length(codes)
    ),
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
      "ConfirmationTestSHA256", "ContractSHA256", "HostedRunnerSHA256",
      "HostedCellWorkflowSHA256", "HostedMatrixWorkflowSHA256"
    ),
    Value = c(
      git_identity$HeadCommit,
      if (git_current && git_identity$Clean) "TRUE" else "FALSE",
      version, tar_observation$TarballSHA256,
      tar_observation$FileRegistryHash,
      registries$ProductionRegistryHash,
      support_hash("confirmation_worker"),
      support_hash("confirmation_test"), support_hash("contract"),
      support_hash("hosted_runner"), support_hash("hosted_cell_workflow"),
      support_hash("hosted_matrix_workflow")
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
  if (!isTRUE(registries$WorkerDenominatorCoverage$Exact)) {
    codes <- c(codes, "CONFIRMATION_WORKER_DENOMINATOR_INCOMPLETE")
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
    WorkerDenominatorCoverage = registries$WorkerDenominatorCoverage,
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
