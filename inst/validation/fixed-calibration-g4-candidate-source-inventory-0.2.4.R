# 0.2.4 fixed-calibration G4 candidate-source inventory.
#
# Read-only classification of every live Git change. This file does not stage,
# commit, ignore, move, delete, build, install, test, or open confirmation.

mfrmr_fc_g4i_command <- function(repo_root, arguments) {
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

mfrmr_fc_g4i_status_registry <- function(repo_root = ".") {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  call <- mfrmr_fc_g4i_command(
    repo_root, c("status", "--porcelain=v1", "--untracked-files=all")
  )
  if (call$Status != 0L) {
    stop("The G4 candidate inventory could not observe Git status.",
         call. = FALSE)
  }
  lines <- call$Output[nzchar(call$Output)]
  if (length(lines) == 0L) {
    return(data.frame(
      Ordinal = integer(), IndexStatus = character(),
      WorktreeStatus = character(), Path = character(),
      stringsAsFactors = FALSE
    ))
  }
  data.frame(
    Ordinal = seq_along(lines),
    IndexStatus = substring(lines, 1L, 1L),
    WorktreeStatus = substring(lines, 2L, 2L),
    Path = substring(lines, 4L),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4i_classify_path <- function(path) {
  path <- as.character(path)
  if (grepl(
    "^(inst/validation/gtheory-multivariate-|tests/testthat/test-gtheory-multivariate-)",
    path
  )) {
    return("deferred_multivariate_gtheory_research")
  }
  if (grepl(
    "^(inst/validation/rater-anchor-|tests/testthat/test-rater-anchor-)",
    path
  )) {
    return("deferred_rater_anchor_design_research")
  }
  if (grepl("^R/[^/]+[.]R$", path) || identical(path, "DESCRIPTION")) {
    return("release_production_code_and_metadata")
  }
  if (identical(path, "NEWS.md") || identical(path, "CITATION.cff") ||
      identical(path, "ROADMAP.md") || grepl("^man/[^/]+[.]Rd$", path) ||
      grepl("^vignettes/[^/]+[.]Rmd$", path) ||
      grepl("^inst/extdata/vignette-artifacts/", path)) {
    return("release_public_and_user_facing_surface")
  }
  if (identical(path, ".Rbuildignore") ||
      path %in% c(
        "inst/validation/README.md",
        "inst/validation/internal-roadmap-0.2.3.md",
        "inst/validation/release-readiness.R"
      ) || grepl("^inst/validation/fixed-calibration-", path) ||
      path %in% c(
        "tests/testthat/test-prediction.R",
        "tests/testthat/test-replay-roundtrip.R",
        "tests/testthat/test-resumable-fits.R",
        "tests/testthat/test-gpcm-capability-matrix.R",
        "tests/testthat/test-release-readiness-protocol.R"
      ) || grepl("^tests/testthat/test-fixed-calibration-", path)) {
    return("release_build_test_and_repository_evidence")
  }
  "unclassified_fail_closed"
}

mfrmr_fc_g4i_package_payload_expected <- function(path, classification) {
  if (classification %in% c(
    "deferred_multivariate_gtheory_research",
    "deferred_rater_anchor_design_research"
  )) {
    return(FALSE)
  }
  if (classification == "release_production_code_and_metadata") return(TRUE)
  if (classification == "release_public_and_user_facing_surface") {
    return(!path %in% c("CITATION.cff", "ROADMAP.md"))
  }
  if (classification == "release_build_test_and_repository_evidence") {
    repository_only <- identical(path, ".Rbuildignore") ||
      grepl("^inst/validation/", path) ||
      path %in% c(
        "tests/testthat/test-fixed-calibration-g0-contract.R",
        "tests/testthat/test-fixed-calibration-g1-schema.R",
        "tests/testthat/test-fixed-calibration-g2-anchors.R",
        "tests/testthat/test-fixed-calibration-g3-scoring.R",
        "tests/testthat/test-fixed-calibration-g4-evidence.R",
        "tests/testthat/test-fixed-calibration-g5-disposition.R",
        "tests/testthat/test-release-readiness-protocol.R"
      )
    return(!repository_only)
  }
  NA
}

mfrmr_fc_g4i_inventory <- function(repo_root = ".") {
  status <- mfrmr_fc_g4i_status_registry(repo_root)
  if (nrow(status) == 0L) {
    status$Classification <- character()
    status$CommitLane <- character()
    status$PackagePayloadExpected <- logical()
    status$PublicScopeEffect <- character()
    return(status)
  }
  classification <- vapply(
    status$Path, mfrmr_fc_g4i_classify_path, character(1L)
  )
  research <- classification %in% c(
    "deferred_multivariate_gtheory_research",
    "deferred_rater_anchor_design_research"
  )
  status$Classification <- classification
  status$CommitLane <- ifelse(
    research,
    "separate_research_history_before_candidate_freeze",
    ifelse(
      classification == "unclassified_fail_closed",
      "no_commit_until_adjudicated",
      "release_candidate_history"
    )
  )
  status$PackagePayloadExpected <- vapply(
    seq_len(nrow(status)),
    function(index) mfrmr_fc_g4i_package_payload_expected(
      status$Path[index], classification[index]
    ), logical(1L)
  )
  status$PublicScopeEffect <- ifelse(
    research, "none_research_only",
    ifelse(
      classification == "unclassified_fail_closed", "unknown_blocking",
      ifelse(
        classification == "release_public_and_user_facing_surface",
        "user_visible_review_required", "release_supporting"
      )
    )
  )
  status
}

mfrmr_fc_g4i_buildignore_contract <- function(repo_root = ".") {
  lines <- readLines(file.path(repo_root, ".Rbuildignore"), warn = FALSE)
  required <- c(
    "^inst/validation$",
    "^tests/testthat/test-gtheory-.*[.]R$",
    "^tests/testthat/test-rater-anchor-.*[.]R$",
    "^tests/testthat/test-fixed-calibration-g4-evidence[.]R$",
    "^tests/testthat/test-fixed-calibration-g5-disposition[.]R$"
  )
  data.frame(
    Pattern = required,
    PresentExactly = required %in% lines,
    Role = c(
      "repository_validation_exclusion", "gtheory_research_test_exclusion",
      "anchor_research_test_exclusion", "g4_repository_test_exclusion",
      "g5_repository_test_exclusion"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4i_public_internal_language_audit <- function(repo_root = ".") {
  paths <- c(
    "NEWS.md",
    list.files(file.path(repo_root, "man"), pattern = "[.]Rd$",
               full.names = FALSE),
    list.files(file.path(repo_root, "vignettes"), pattern = "[.]Rmd$",
               full.names = FALSE)
  )
  paths <- c(
    "NEWS.md",
    file.path("man", paths[paths != "NEWS.md" & grepl("[.]Rd$", paths)]),
    file.path(
      "vignettes", paths[paths != "NEWS.md" & grepl("[.]Rmd$", paths)]
    )
  )
  paths <- unique(paths[file.exists(file.path(repo_root, paths))])
  prohibited <- paste0(
    "CORE-[0-9]|G[0-6] exit|claim[- ]ledger|candidate[- ]binding|",
    "confirmation denominator|HostedWorkflow|PublicAPIAuthorized|",
    "AmendedG4|Draft[.]85|c4[pq]"
  )
  hits <- lapply(paths, function(path) {
    lines <- readLines(file.path(repo_root, path), warn = FALSE,
                       encoding = "UTF-8")
    index <- grep(prohibited, lines, ignore.case = FALSE, perl = TRUE)
    if (length(index) == 0L) return(NULL)
    data.frame(
      Path = path, Line = as.integer(index), Text = lines[index],
      stringsAsFactors = FALSE
    )
  })
  hits <- Filter(Negate(is.null), hits)
  if (length(hits) == 0L) {
    return(data.frame(
      Path = character(), Line = integer(), Text = character(),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, hits)
}

mfrmr_fc_g4i_review <- function(repo_root = ".") {
  inventory <- mfrmr_fc_g4i_inventory(repo_root)
  ignore <- mfrmr_fc_g4i_buildignore_contract(repo_root)
  public_hits <- mfrmr_fc_g4i_public_internal_language_audit(repo_root)
  unknown <- inventory$Classification == "unclassified_fail_closed"
  research <- inventory$Classification %in% c(
    "deferred_multivariate_gtheory_research",
    "deferred_rater_anchor_design_research"
  )
  valid <- !any(unknown) && all(ignore$PresentExactly) &&
    !any(inventory$PackagePayloadExpected[research]) && nrow(public_hits) == 0L
  list(
    Contract = "mfrmr_fixed_calibration_g4_candidate_source_inventory_v1",
    Status = if (valid) {
      "all_live_changes_classified_commit_lanes_unexecuted"
    } else {
      "candidate_source_inventory_blocked"
    },
    Inventory = inventory,
    ClassificationSummary = as.data.frame(table(
      inventory$Classification, useNA = "ifany"
    ), stringsAsFactors = FALSE),
    CommitLaneSummary = as.data.frame(table(
      inventory$CommitLane, useNA = "ifany"
    ), stringsAsFactors = FALSE),
    BuildIgnoreContract = ignore,
    PublicInternalLanguageHits = public_hits,
    AllChangesClassified = !any(unknown),
    ResearchExcludedFromPackagePayload =
      length(research) == 0L || !any(inventory$PackagePayloadExpected[research]),
    PublicInternalLanguageClean = nrow(public_hits) == 0L,
    CommitPlanReady = valid,
    WorkingTreeClean = nrow(inventory) == 0L,
    CandidateBindingComplete = FALSE,
    CurrentExecutionOpened = FALSE,
    G4ExitComplete = FALSE,
    PublicAPIAuthorized = FALSE
  )
}
