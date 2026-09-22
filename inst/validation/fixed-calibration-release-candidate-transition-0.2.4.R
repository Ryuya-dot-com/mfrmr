# mfrmr 0.2.4 release-candidate transition contract.
#
# This repository-only preflight binds the G6-validated payload and constrains
# the later development-to-candidate metadata transition. It never edits,
# stages, commits, tags, builds, checks, submits, or publishes the package.

mfrmr_rc04_contract <- function() {
  list(
    ContractId = "mfrmr_release_candidate_transition_0_2_4_v1",
    TargetVersion = "0.2.4",
    DevelopmentVersion = "0.2.4.9000",
    PublicPredecessor = "0.2.3.1",
    G6ValidatedCommit =
      "cf20dd0167db3f39224cea7d1c70998b1142f81f",
    G6HostedRunId = "32906087561",
    G6DecisionRecord =
      "fixed-calibration-g6-release-decision-record-0.2.4.md",
    CandidatePackagePaths = c("DESCRIPTION", "NEWS.md"),
    CandidateRepositoryPaths = c(
      "CITATION.cff", "cran-comments.md", "ROADMAP.md"
    ),
    CandidateInternalPatterns = c(
      "^inst/validation/",
      "^tests/testthat/test-fixed-calibration-g4-evidence[.]R$",
      "^tests/testthat/test-release-readiness-protocol[.]R$"
    ),
    CandidateDescriptionMutableFields = c(
      "Version", "Date", "Config/mfrmr/release-status"
    ),
    CandidateCffMutableFields = c("version", "date-released"),
    CandidateNewsMutableSurface = "first_heading_only",
    ProductionChangePolicy =
      "invalidate_candidate_return_to_development_and_rerun_evidence",
    SubmissionAuthorized = FALSE
  )
}

mfrmr_rc04_git <- function(repo_root, arguments) {
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

mfrmr_rc04_git_lines <- function(repo_root, revision, path) {
  call <- mfrmr_rc04_git(
    repo_root, c("show", shQuote(paste0(revision, ":", path)))
  )
  if (call$Status != 0L) {
    stop("Unable to read the G6 baseline path: ", path, call. = FALSE)
  }
  call$Output
}

mfrmr_rc04_read_lines <- function(path) {
  if (!file.exists(path)) return(character(0))
  readLines(path, warn = FALSE, encoding = "UTF-8")
}

mfrmr_rc04_dcf <- function(lines) {
  connection <- textConnection(lines)
  on.exit(close(connection), add = TRUE)
  read.dcf(connection)
}

mfrmr_rc04_dcf_value <- function(dcf, field) {
  if (nrow(dcf) != 1L || !field %in% colnames(dcf)) return(NA_character_)
  as.character(dcf[1L, field])
}

mfrmr_rc04_changed_dcf_fields <- function(reference, candidate) {
  fields <- union(colnames(reference), colnames(candidate))
  fields[vapply(fields, function(field) {
    !identical(
      mfrmr_rc04_dcf_value(reference, field),
      mfrmr_rc04_dcf_value(candidate, field)
    )
  }, logical(1L))]
}

mfrmr_rc04_cff_value <- function(lines, field) {
  hit <- grep(paste0("^", field, ":[[:space:]]*"), lines, value = TRUE)
  if (length(hit) != 1L) return(NA_character_)
  value <- sub(paste0("^", field, ":[[:space:]]*"), "", hit)
  sub("^['\"](.*)['\"]$", "\\1", trimws(value))
}

mfrmr_rc04_cff_invariant_lines <- function(lines) {
  lines[!grepl("^(version|date-released):[[:space:]]*", lines)]
}

mfrmr_rc04_news_body <- function(lines) {
  heading <- grep("^# ", lines)[1L]
  if (is.na(heading)) return(lines)
  lines[-heading]
}

mfrmr_rc04_valid_iso_date <- function(value) {
  if (length(value) != 1L || is.na(value) ||
      !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", value)) {
    return(FALSE)
  }
  parsed <- suppressWarnings(as.Date(value, format = "%Y-%m-%d"))
  !is.na(parsed) && identical(format(parsed, "%Y-%m-%d"), value)
}

mfrmr_rc04_cran_comments_review <- function(lines) {
  text <- paste(lines, collapse = "\n")
  required <- c(
    TargetVersion = "0\\.2\\.4",
    PublicPredecessor = "0\\.2\\.3\\.1",
    PortableCalibration = "portable[- ]calibration",
    RSM = "\\bRSM\\b",
    PCM = "\\bPCM\\b",
    MML = "\\bMML\\b",
    FixedStandardNormal = "fixed[- ]standard[- ]normal",
    GPCM = "\\bGPCM\\b",
    JML = "\\bJML\\b",
    UnavailableBoundary = "unavailable|outside|not supported",
    ZeroErrors = "0 errors",
    ZeroWarnings = "0 warnings",
    ZeroNotes = "0 notes"
  )
  matched <- vapply(required, function(pattern) {
    grepl(pattern, text, ignore.case = TRUE, perl = TRUE)
  }, logical(1L))
  data.frame(
    Requirement = names(required),
    Pattern = unname(required),
    Matched = unname(matched),
    stringsAsFactors = FALSE
  )
}

mfrmr_rc04_metadata_review <- function(
    description_lines,
    cff_lines,
    news_lines,
    cran_comments_lines,
    baseline_description_lines,
    baseline_cff_lines,
    baseline_news_lines) {
  contract <- mfrmr_rc04_contract()
  description <- mfrmr_rc04_dcf(description_lines)
  baseline_description <- mfrmr_rc04_dcf(baseline_description_lines)
  version <- mfrmr_rc04_dcf_value(description, "Version")
  release_status <- tolower(mfrmr_rc04_dcf_value(
    description, "Config/mfrmr/release-status"
  ))
  public_version <- mfrmr_rc04_dcf_value(
    description, "Config/mfrmr/public-version"
  )
  description_date <- mfrmr_rc04_dcf_value(description, "Date")
  cff_version <- mfrmr_rc04_cff_value(cff_lines, "version")
  cff_date <- mfrmr_rc04_cff_value(cff_lines, "date-released")
  news_heading <- news_lines[grep("^# ", news_lines)][1L]

  stage <- if (
      identical(version, contract$DevelopmentVersion) &&
      identical(release_status, "development")) {
    "development"
  } else if (
      identical(version, contract$TargetVersion) &&
      identical(release_status, "candidate")) {
    "candidate"
  } else {
    "invalid_transition_state"
  }

  changed_description_fields <- mfrmr_rc04_changed_dcf_fields(
    baseline_description, description
  )
  description_allowed <- length(setdiff(
    changed_description_fields,
    contract$CandidateDescriptionMutableFields
  )) == 0L
  cff_allowed <- identical(
    mfrmr_rc04_cff_invariant_lines(cff_lines),
    mfrmr_rc04_cff_invariant_lines(baseline_cff_lines)
  )
  news_body_unchanged <- identical(
    mfrmr_rc04_news_body(news_lines),
    mfrmr_rc04_news_body(baseline_news_lines)
  )
  cran_review <- mfrmr_rc04_cran_comments_review(cran_comments_lines)

  development_ok <- identical(stage, "development") &&
    identical(description_lines, baseline_description_lines) &&
    identical(cff_lines, baseline_cff_lines) &&
    identical(news_lines, baseline_news_lines) &&
    identical(public_version, contract$PublicPredecessor) &&
    is.na(description_date) && is.na(cff_date)

  candidate_ok <- identical(stage, "candidate") &&
    description_allowed && cff_allowed && news_body_unchanged &&
    identical(public_version, contract$PublicPredecessor) &&
    mfrmr_rc04_valid_iso_date(description_date) &&
    identical(description_date, cff_date) &&
    identical(cff_version, contract$TargetVersion) &&
    identical(news_heading, paste("# mfrmr", contract$TargetVersion)) &&
    all(cran_review$Matched)

  list(
    ContractId = contract$ContractId,
    Stage = stage,
    Version = version,
    ReleaseStatus = release_status,
    PublicVersion = public_version,
    DescriptionDate = description_date,
    CffVersion = cff_version,
    CffDate = cff_date,
    NewsHeading = news_heading,
    ChangedDescriptionFields = changed_description_fields,
    DescriptionAllowedFieldsOnly = description_allowed,
    CffAllowedFieldsOnly = cff_allowed,
    NewsBodyUnchanged = news_body_unchanged,
    CranCommentsReview = cran_review,
    CranCommentsReady = all(cran_review$Matched),
    DevelopmentMetadataOK = development_ok,
    CandidateMetadataOK = candidate_ok,
    MetadataTransitionOK = development_ok || candidate_ok
  )
}

mfrmr_rc04_classify_path <- function(path) {
  contract <- mfrmr_rc04_contract()
  if (path %in% contract$CandidatePackagePaths) {
    return("candidate_package_metadata")
  }
  if (path %in% contract$CandidateRepositoryPaths) {
    return("candidate_repository_metadata_or_internal_roadmap")
  }
  if (any(vapply(contract$CandidateInternalPatterns, function(pattern) {
    grepl(pattern, path, perl = TRUE)
  }, logical(1L)))) {
    return("candidate_internal_evidence")
  }
  "package_payload_change_forbidden"
}

mfrmr_rc04_changed_paths <- function(repo_root, baseline_commit) {
  tracked <- mfrmr_rc04_git(
    repo_root, c("diff", "--name-only", shQuote(baseline_commit), "--")
  )
  untracked <- mfrmr_rc04_git(
    repo_root, c("ls-files", "--others", "--exclude-standard")
  )
  if (tracked$Status != 0L || untracked$Status != 0L) {
    stop("Unable to enumerate the release-candidate transition.", call. = FALSE)
  }
  sort(unique(c(
    tracked$Output[nzchar(tracked$Output)],
    untracked$Output[nzchar(untracked$Output)]
  )))
}

mfrmr_rc04_review <- function(repo_root = ".") {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  contract <- mfrmr_rc04_contract()
  baseline <- contract$G6ValidatedCommit
  ancestor <- mfrmr_rc04_git(
    repo_root, c("merge-base", "--is-ancestor", baseline, "HEAD")
  )$Status == 0L
  branch_call <- mfrmr_rc04_git(
    repo_root, c("rev-parse", "--abbrev-ref", "HEAD")
  )
  branch <- if (branch_call$Status == 0L) branch_call$Output[1L] else NA_character_
  status_call <- mfrmr_rc04_git(
    repo_root, c("status", "--porcelain=v1", "--untracked-files=all")
  )
  working_tree_clean <- status_call$Status == 0L &&
    !any(nzchar(status_call$Output))
  paths <- mfrmr_rc04_changed_paths(repo_root, baseline)
  classification <- vapply(paths, mfrmr_rc04_classify_path, character(1L))
  inventory <- data.frame(
    Path = paths,
    Classification = unname(classification),
    stringsAsFactors = FALSE
  )
  changed_paths_allowed <- !any(
    inventory$Classification == "package_payload_change_forbidden"
  )
  production_payload_unchanged <- !any(
    inventory$Classification == "package_payload_change_forbidden"
  )

  metadata <- mfrmr_rc04_metadata_review(
    description_lines = mfrmr_rc04_read_lines(
      file.path(repo_root, "DESCRIPTION")
    ),
    cff_lines = mfrmr_rc04_read_lines(file.path(repo_root, "CITATION.cff")),
    news_lines = mfrmr_rc04_read_lines(file.path(repo_root, "NEWS.md")),
    cran_comments_lines = mfrmr_rc04_read_lines(
      file.path(repo_root, "cran-comments.md")
    ),
    baseline_description_lines = mfrmr_rc04_git_lines(
      repo_root, baseline, "DESCRIPTION"
    ),
    baseline_cff_lines = mfrmr_rc04_git_lines(
      repo_root, baseline, "CITATION.cff"
    ),
    baseline_news_lines = mfrmr_rc04_git_lines(
      repo_root, baseline, "NEWS.md"
    )
  )

  g6_record <- paste(mfrmr_rc04_read_lines(file.path(
    repo_root, "inst", "validation",
    contract$G6DecisionRecord
  )), collapse = "\n")
  g6_decision_bound <- all(vapply(c(
    paste0("ValidatedPayloadCommitSHA40=", baseline),
    paste0("HostedRunId=", contract$G6HostedRunId),
    "HostedWorkflowConclusion=success",
    "G6ExitComplete=TRUE",
    "PublicAPIAuthorizedForRelease=TRUE",
    "CRANSubmissionPerformed=FALSE"
  ), function(value) grepl(value, g6_record, fixed = TRUE), logical(1L)))

  development_transition_ready <- ancestor && changed_paths_allowed &&
    production_payload_unchanged && metadata$DevelopmentMetadataOK &&
    g6_decision_bound
  candidate_ready <- ancestor && working_tree_clean && changed_paths_allowed &&
    production_payload_unchanged && metadata$CandidateMetadataOK &&
    g6_decision_bound

  list(
    Contract = contract,
    Branch = branch,
    G6BaselineAncestor = ancestor,
    WorkingTreeClean = working_tree_clean,
    Inventory = inventory,
    ChangedPathCount = nrow(inventory),
    ChangedPathsAllowed = changed_paths_allowed,
    ProductionPayloadUnchanged = production_payload_unchanged,
    Metadata = metadata,
    G6DecisionBound = g6_decision_bound,
    DevelopmentTransitionReady = development_transition_ready,
    CandidateReady = candidate_ready,
    SubmissionAuthorized = FALSE
  )
}
