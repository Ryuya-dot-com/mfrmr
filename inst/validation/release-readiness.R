# mfrmr release-readiness protocol
#
# Source this file in a development or release-check session:
#
#   source(system.file("validation", "release-readiness.R", package = "mfrmr"))
#   readiness <- mfrmr_release_readiness_review(pkg_dir = ".")
#   summary(readiness)
#
# The functions are intentionally not exported. They provide a reproducible
# release-readiness review of release evidence without adding work to routine tests.

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

mfrmr_release_readiness_has_value <- function(x) {
  !is.null(x) && length(x) > 0L && !is.na(x[1]) && nzchar(x[1])
}

mfrmr_release_readiness_prompt_steps <- function(target_version = NULL) {
  target_label <- if (!mfrmr_release_readiness_has_value(target_version)) {
    "the target release"
  } else {
    target_version[1]
  }
  data.frame(
    Step = seq_len(8L),
    Label = c(
      "Version contract",
      "Mathematical blockers",
      "GPCM boundary",
      "FACETS relationship",
      "UX and plot-data access",
      "Terminology",
      "Package check",
      "Submission handoff"
    ),
    Prompt = c(
      paste0(
        "Does DESCRIPTION, NEWS, generated help, and the selected check log ",
        "all describe ", target_label, " rather than a development snapshot ",
        "or stale release artifact?"
      ),
      "Do blocker rows for identification, GPCM slope/information kernels, fair-average uncertainty, person fit, and recovery validation have explicit evidence?",
      "Are supported, caveated, blocked, and deferred bounded-GPCM routes visible before users reach unsupported score-side workflows?",
      "Does the package describe FACETS-style output as comparison and handoff support rather than numerical FACETS reproduction?",
      "Can users start from summaries, status tables, and reusable draw-free plot data before reading row-level internals?",
      "Do public-facing docs use review/check/traceability wording and avoid exposing removed helper names as current API?",
      "Does R CMD build/check complete with zero errors and zero warnings, and does CI preserve cross-platform check evidence?",
      "Do cran-comments, NEWS, and validation artifacts tell the same story about release scope, caveats, and deferred work?"
    ),
    Evidence = c(
      "DESCRIPTION Version; first NEWS heading; check-log package version; absence of development labels in current release files",
      "release-evidence-checklist blocker rows; targeted mathematical tests; recovery-validation summary",
      "gpcm_capability_matrix(); README; vignettes; NEWS deferred-work section; post-0.2.2 GPCM roadmap",
      "facets_positioning_guide(); facets_fit_review(); read_facets_fit_table(); output guide",
      "summary methods; plot(..., draw = FALSE); plot_data(); summary-table bundles",
      "README/vignettes/man/cheatsheet terminology scan",
      "mfrmr.Rcheck/00check.log or attached check log; GitHub Actions warning policy and check artifacts",
      "cran-comments.md; NEWS.md; release-evidence map; GPCM roadmap; external parameter-recovery summary and local review helper"
    ),
    Gate = c(
      "blocker",
      "blocker",
      "blocker",
      "caveat",
      "caveat",
      "caveat",
      "blocker",
      "caveat"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_description_version <- function(pkg_dir) {
  description <- file.path(pkg_dir, "DESCRIPTION")
  if (!file.exists(description)) {
    return(NA_character_)
  }
  dcf <- read.dcf(description)
  if ("Version" %in% colnames(dcf)) {
    as.character(dcf[1, "Version"])
  } else {
    NA_character_
  }
}

mfrmr_release_readiness_resolve_target_version <- function(pkg_dir,
                                                           target_version = NULL) {
  if (mfrmr_release_readiness_has_value(target_version)) {
    return(target_version[1])
  }
  mfrmr_release_readiness_description_version(pkg_dir)
}

mfrmr_release_readiness_versioned_file <- function(validation_dir,
                                                   prefix,
                                                   target_version,
                                                   fallback_version = "0.2.0",
                                                   ext) {
  candidates <- character(0)
  if (mfrmr_release_readiness_has_value(target_version)) {
    candidates <- c(
      candidates,
      file.path(validation_dir, paste0(prefix, target_version, ext))
    )
    development_base <- sub("\\.9000$", "", target_version[1])
    if (!identical(development_base, target_version[1])) {
      candidates <- c(
        candidates,
        file.path(validation_dir, paste0(prefix, development_base, ext))
      )
    }
  }
  candidates <- c(
    candidates,
    file.path(validation_dir, paste0(prefix, fallback_version, ext))
  )
  candidates <- unique(candidates)
  hits <- candidates[file.exists(candidates)]
  if (length(hits) > 0L) {
    hits[1]
  } else {
    candidates[1]
  }
}

mfrmr_release_readiness_paths <- function(pkg_dir = ".",
                                          target_version = NULL) {
  pkg_dir <- normalizePath(pkg_dir, winslash = "/", mustWork = FALSE)
  if (!file.exists(file.path(pkg_dir, "DESCRIPTION")) &&
      identical(basename(pkg_dir), "inst") &&
      file.exists(file.path(dirname(pkg_dir), "DESCRIPTION"))) {
    pkg_dir <- dirname(pkg_dir)
  }
  target_version <- mfrmr_release_readiness_resolve_target_version(
    pkg_dir,
    target_version = target_version
  )
  validation_dir <- file.path(pkg_dir, "inst", "validation")
  if (!dir.exists(validation_dir)) {
    validation_dir <- file.path(pkg_dir, "validation")
  }
  list(
    target_version = target_version,
    pkg_dir = pkg_dir,
    description = file.path(pkg_dir, "DESCRIPTION"),
    news = file.path(pkg_dir, "NEWS.md"),
    cran_comments = file.path(pkg_dir, "cran-comments.md"),
    ci_workflow = file.path(pkg_dir, ".github", "workflows", "R-CMD-check.yaml"),
    evidence_map = mfrmr_release_readiness_versioned_file(
      validation_dir,
      prefix = "release-evidence-map-",
      target_version = target_version,
      ext = ".md"
    ),
    evidence_checklist = mfrmr_release_readiness_versioned_file(
      validation_dir,
      prefix = "release-evidence-checklist-",
      target_version = target_version,
      ext = ".csv"
    ),
    gpcm_roadmap = file.path(validation_dir, "gpcm-post-0.2.2-roadmap.md"),
    gpcm_capability_source = file.path(pkg_dir, "R", "help_gpcm_scope.R"),
    external_recovery_evidence = mfrmr_release_readiness_versioned_file(
      validation_dir,
      prefix = "external-parameter-recovery-simulation-",
      target_version = target_version,
      ext = ".md"
    ),
    external_recovery_helper = file.path(validation_dir, "external-recovery-audit.R"),
    mh_dif_alignment_note = file.path(
      dirname(validation_dir),
      "references",
      "mh-dif-r-package-alignment.md"
    ),
    mh_dif_comparison_helper = file.path(
      validation_dir,
      "mh-dif-package-comparison-0.2.2.R"
    ),
    mh_dif_simulation_helper = file.path(
      validation_dir,
      "mh-dif-simulation-0.2.2.R"
    ),
    dif_apa_reporting_note = file.path(
      dirname(validation_dir),
      "references",
      "dif-apa-reporting-0.2.2.md"
    ),
    dif_apa_reporting_helper = file.path(
      validation_dir,
      "dif-apa-reporting-0.2.2.R"
    ),
    dif_apa_reporting_evidence = file.path(
      validation_dir,
      "dif-apa-reporting-0.2.2.md"
    ),
    dif_dff_simulation_helper = file.path(
      validation_dir,
      "dif-dff-simulation-matrix-0.2.2.R"
    ),
    dif_dff_simulation_evidence = file.path(
      validation_dir,
      "dif-dff-simulation-matrix-0.2.2.md"
    ),
    convergence_reporting_stress_helper = file.path(
      validation_dir,
      "convergence-reporting-stress-0.2.2.R"
    ),
    convergence_reporting_stress_evidence = file.path(
      validation_dir,
      "convergence-reporting-stress-0.2.2.md"
    ),
    gpcm_score_side_simulation_helper = file.path(
      validation_dir,
      "gpcm-score-side-simulation-0.2.2.R"
    ),
    gpcm_score_side_simulation_evidence = file.path(
      validation_dir,
      "gpcm-score-side-simulation-0.2.2.md"
    ),
    gpcm_score_side_simulation_summary = file.path(
      validation_dir,
      "gpcm-score-side-sim-summary-0.2.2.csv"
    ),
    gpcm_score_side_simulation_checks = file.path(
      validation_dir,
      "gpcm-score-side-sim-checks-0.2.2.csv"
    ),
    gpcm_score_side_external_helper = file.path(
      validation_dir,
      "gpcm-score-side-external-comparison-0.2.2.R"
    ),
    gpcm_score_side_external_evidence = file.path(
      validation_dir,
      "gpcm-score-side-external-comparison-0.2.2.md"
    ),
    gpcm_score_side_external_results = file.path(
      validation_dir,
      "gpcm-score-side-external-comparison-0.2.2-results.csv"
    ),
    gpcm_score_side_external_checks = file.path(
      validation_dir,
      "gpcm-score-side-external-comparison-0.2.2-checks.csv"
    ),
    release_scope_helper = file.path(
      validation_dir,
      "release-scope-review-0.2.2.R"
    ),
    release_scope_evidence = file.path(
      validation_dir,
      "release-scope-review-0.2.2.md"
    ),
    release_scope_checks = file.path(
      validation_dir,
      "release-scope-review-0.2.2-checks.csv"
    ),
    network_anchor_stress_helper = file.path(
      validation_dir,
      "network-anchor-stress-0.2.2.R"
    ),
    network_anchor_stress_evidence = file.path(
      validation_dir,
      "network-anchor-stress-0.2.2.md"
    ),
    network_anchor_stress_summary = file.path(
      validation_dir,
      "network-anchor-stress-0.2.2-summary.csv"
    ),
    network_anchor_stress_checks = file.path(
      validation_dir,
      "network-anchor-stress-0.2.2-checks.csv"
    ),
    network_anchor_stress_rater_modes = file.path(
      validation_dir,
      "network-anchor-stress-0.2.2-rater-modes.csv"
    ),
    self_other_speaking_network_helper = file.path(
      validation_dir,
      "self-other-speaking-network-0.2.2.R"
    ),
    self_other_speaking_network_evidence = file.path(
      validation_dir,
      "self-other-speaking-network-0.2.2.md"
    ),
    self_other_speaking_network_summary = file.path(
      validation_dir,
      "self-other-speaking-network-0.2.2-summary.csv"
    ),
    self_other_speaking_network_checks = file.path(
      validation_dir,
      "self-other-speaking-network-0.2.2-checks.csv"
    ),
    self_other_speaking_network_templates = file.path(
      validation_dir,
      "self-other-speaking-network-0.2.2-templates.csv"
    ),
    check_log = file.path(pkg_dir, "mfrmr.Rcheck", "00check.log")
  )
}

mfrmr_release_readiness_check_log_package_version <- function(lines) {
  version_line <- grep("\\* this is package .* version ", lines, value = TRUE)
  if (length(version_line) == 0L) {
    return(NA_character_)
  }
  version_line <- tail(version_line, 1L)
  match <- regexec("version [‘'`](.*)[’'`]", version_line)
  parsed <- regmatches(version_line, match)[[1]]
  if (length(parsed) >= 2L) {
    parsed[2]
  } else {
    NA_character_
  }
}

mfrmr_release_readiness_find_check_log <- function(pkg_dir,
                                                   target_version = NULL) {
  candidates <- c(
    file.path(pkg_dir, "mfrmr.Rcheck", "00check.log"),
    file.path(pkg_dir, "check", "mfrmr.Rcheck", "00check.log")
  )
  recursive <- if (dir.exists(pkg_dir)) {
    list.files(pkg_dir, pattern = "^00check[.]log$", recursive = TRUE, full.names = TRUE)
  } else {
    character(0)
  }
  candidates <- unique(c(candidates, recursive))
  existing <- candidates[file.exists(candidates)]
  if (length(existing) > 1L) {
    mtimes <- file.info(existing)$mtime
    existing <- existing[order(mtimes, decreasing = TRUE, na.last = TRUE)]
  }
  if (length(existing) > 0L &&
      mfrmr_release_readiness_has_value(target_version)) {
    versions <- vapply(existing, function(path) {
      mfrmr_release_readiness_check_log_package_version(
        mfrmr_release_readiness_read_lines(path)
      )
    }, character(1))
    matching <- existing[!is.na(versions) & versions == target_version[1]]
    if (length(matching) > 0L) {
      return(matching[1])
    }
  }
  existing[1] %||% file.path(pkg_dir, "mfrmr.Rcheck", "00check.log")
}

mfrmr_release_readiness_read_lines <- function(path) {
  if (!file.exists(path)) {
    return(character(0))
  }
  readLines(path, warn = FALSE, encoding = "UTF-8")
}

mfrmr_release_readiness_source_files <- function(pkg_dir) {
  pkg_dir <- normalizePath(pkg_dir, winslash = "/", mustWork = FALSE)
  roots <- c(
    "DESCRIPTION", "NAMESPACE", "NEWS.md", "README.md",
    "R", "man", "tests", "vignettes", "inst", "src",
    "data", "data-raw", "configure", "configure.win", "cleanup",
    "cleanup.win"
  )
  paths <- file.path(pkg_dir, roots)
  files <- unlist(lapply(paths, function(path) {
    if (!file.exists(path)) {
      return(character(0))
    }
    if (dir.exists(path)) {
      list.files(path, recursive = TRUE, full.names = TRUE,
                 all.files = TRUE, no.. = TRUE)
    } else {
      path
    }
  }), use.names = FALSE)
  files <- files[file.exists(files) & !dir.exists(files)]
  if (length(files) == 0L) {
    return(character(0))
  }
  rel <- sub(paste0("^", gsub("([\\^$.|?*+(){}\\[\\]\\\\])", "\\\\\\1", pkg_dir), "/?"),
             "", normalizePath(files, winslash = "/", mustWork = FALSE))
  keep <- !grepl("(^|/)(mfrmr[.]Rcheck|check)(/|$)", rel)
  normalizePath(files[keep], winslash = "/", mustWork = FALSE)
}

mfrmr_release_readiness_source_mtime_status <- function(pkg_dir, check_log) {
  files <- mfrmr_release_readiness_source_files(pkg_dir)
  if (length(files) == 0L || !file.exists(check_log)) {
    return(data.frame(
      FreshAgainstSource = NA,
      SourceFiles = length(files),
      SourceLatestMTime = as.POSIXct(NA),
      SourceLatestFile = NA_character_,
      CheckLogMTime = if (file.exists(check_log)) {
        file.info(check_log)$mtime[1]
      } else {
        as.POSIXct(NA)
      },
      stringsAsFactors = FALSE
    ))
  }
  info <- file.info(files)
  mtimes <- info$mtime
  ok <- !is.na(mtimes)
  if (!any(ok)) {
    return(data.frame(
      FreshAgainstSource = NA,
      SourceFiles = length(files),
      SourceLatestMTime = as.POSIXct(NA),
      SourceLatestFile = NA_character_,
      CheckLogMTime = file.info(check_log)$mtime[1],
      stringsAsFactors = FALSE
    ))
  }
  latest_idx <- which.max(as.numeric(mtimes[ok]))
  ok_files <- files[ok]
  latest_file <- ok_files[latest_idx]
  latest_mtime <- mtimes[ok][latest_idx]
  check_mtime <- file.info(check_log)$mtime[1]
  data.frame(
    FreshAgainstSource = isTRUE(!is.na(check_mtime) && check_mtime >= latest_mtime),
    SourceFiles = length(files),
    SourceLatestMTime = latest_mtime,
    SourceLatestFile = sub(
      paste0("^", gsub("([\\^$.|?*+(){}\\[\\]\\\\])", "\\\\\\1",
                       normalizePath(pkg_dir, winslash = "/", mustWork = FALSE)), "/?"),
      "",
      latest_file
    ),
    CheckLogMTime = check_mtime,
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_count_status <- function(status_line, label) {
  if (length(status_line) == 0L || !nzchar(status_line[1])) {
    return(NA_integer_)
  }
  pattern <- paste0("([0-9]+) ", label, "S?")
  hit <- regexec(pattern, status_line[1], ignore.case = TRUE)
  match <- regmatches(status_line[1], hit)[[1]]
  if (length(match) >= 2L) {
    return(as.integer(match[2]))
  }
  0L
}

mfrmr_release_readiness_parse_check_log <- function(path,
                                                    target_version = NULL,
                                                    pkg_dir = NULL) {
  lines <- mfrmr_release_readiness_read_lines(path)
  freshness <- if (is.null(pkg_dir)) {
    data.frame(
      FreshAgainstSource = NA,
      SourceFiles = NA_integer_,
      SourceLatestMTime = as.POSIXct(NA),
      SourceLatestFile = NA_character_,
      CheckLogMTime = if (file.exists(path)) file.info(path)$mtime[1] else as.POSIXct(NA),
      stringsAsFactors = FALSE
    )
  } else {
    mfrmr_release_readiness_source_mtime_status(pkg_dir, path)
  }
  if (length(lines) == 0L) {
    return(cbind(data.frame(
      CheckLog = path,
      PackageVersion = NA_character_,
      TargetVersion = target_version %||% NA_character_,
      VersionMatchesTarget = if (is.null(target_version)) NA else FALSE,
      StatusLine = NA_character_,
      Errors = NA_integer_,
      Warnings = NA_integer_,
      Notes = NA_integer_,
      CheckPassed = FALSE,
      NeedsExplanation = TRUE,
      stringsAsFactors = FALSE
    ), freshness))
  }
  package_version <- mfrmr_release_readiness_check_log_package_version(lines)
  version_matches_target <- if (!mfrmr_release_readiness_has_value(target_version)) {
    NA
  } else {
    identical(package_version, target_version[1])
  }
  status <- grep("^Status:", lines, value = TRUE)
  status <- if (length(status) > 0L) tail(status, 1L) else "Status: OK"
  errors <- mfrmr_release_readiness_count_status(status, "ERROR")
  warnings <- mfrmr_release_readiness_count_status(status, "WARNING")
  notes <- mfrmr_release_readiness_count_status(status, "NOTE")
  if (identical(status, "Status: OK")) {
    errors <- warnings <- notes <- 0L
  }
  cbind(data.frame(
    CheckLog = path,
    PackageVersion = package_version,
    TargetVersion = target_version %||% NA_character_,
    VersionMatchesTarget = version_matches_target,
    StatusLine = status,
    Errors = errors,
    Warnings = warnings,
    Notes = notes,
    CheckPassed = isTRUE(errors == 0L && warnings == 0L),
    NeedsExplanation = isTRUE(notes > 0L),
    stringsAsFactors = FALSE
  ), freshness)
}

mfrmr_release_readiness_version_status <- function(paths, target_version = NULL) {
  target_version <- target_version %||% paths$target_version
  desc_version <- NA_character_
  if (file.exists(paths$description)) {
    dcf <- read.dcf(paths$description)
    if ("Version" %in% colnames(dcf)) {
      desc_version <- as.character(dcf[1, "Version"])
    }
  }
  news_lines <- mfrmr_release_readiness_read_lines(paths$news)
  first_heading <- news_lines[grep("^# ", news_lines)][1] %||% NA_character_
  current_files <- c(paths$description, paths$news, paths$cran_comments, paths$evidence_map)
  current_lines <- unlist(lapply(current_files[file.exists(current_files)], mfrmr_release_readiness_read_lines), use.names = FALSE)
  dev_label_present <- any(grepl(paste0("\\b", gsub(".", "\\\\.", target_version, fixed = TRUE), "\\.9000\\b"), current_lines))
  # Between releases the conventional pairing is a four-component
  # development version in DESCRIPTION (x.y.z.9000) with a
  # "# mfrmr (development version)" NEWS heading. Treat that pairing as a
  # valid development-cycle state; release candidates still require the
  # exact version heading.
  is_dev_version <- grepl("\\.9[0-9]{3}$", desc_version %||% "")
  dev_pairing_ok <- isTRUE(is_dev_version) &&
    identical(first_heading, "# mfrmr (development version)")
  data.frame(
    TargetVersion = target_version,
    DescriptionVersion = desc_version,
    NewsHeading = first_heading,
    DevelopmentLabelPresent = dev_label_present,
    DevCycle = dev_pairing_ok,
    VersionOK = (identical(desc_version, target_version) &&
      identical(first_heading, paste("# mfrmr", target_version)) &&
      !isTRUE(dev_label_present)) ||
      (identical(desc_version, target_version) && dev_pairing_ok),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_public_doc_files <- function(pkg_dir) {
  list_rmd <- function(path) {
    if (!dir.exists(path)) {
      return(character(0))
    }
    list.files(path, pattern = "\\.Rmd$", recursive = TRUE, full.names = TRUE)
  }
  list_rd <- function(path) {
    if (!dir.exists(path)) {
      return(character(0))
    }
    list.files(path, pattern = "\\.Rd$", recursive = TRUE, full.names = TRUE)
  }
  candidates <- c(
    file.path(pkg_dir, "README.md"),
    list_rmd(file.path(pkg_dir, "vignettes")),
    list_rd(file.path(pkg_dir, "man")),
    list_rmd(file.path(pkg_dir, "inst", "cheatsheet"))
  )
  candidates[file.exists(candidates)]
}

mfrmr_release_readiness_term_status <- function(pkg_dir) {
  files <- mfrmr_release_readiness_public_doc_files(pkg_dir)
  allow_patterns <- c(
    "^% Please edit documentation in R/.*audit.*\\.R$",
    "mfrm_analysis_audit",
    "summary\\.mfrm_analysis_audit",
    "print\\.mfrm_analysis_audit",
    "Cross-analysis audit",
    "analysis audit summary"
  )
  is_allowed <- function(line) {
    any(vapply(allow_patterns, grepl, logical(1),
               x = line, perl = TRUE, ignore.case = TRUE))
  }
  hits <- character(0)
  for (path in files) {
    lines <- mfrmr_release_readiness_read_lines(path)
    idx <- grep("\\baudit\\b|\\bAudit\\b|_audit|audit_", lines, perl = TRUE)
    if (length(idx) == 0L) {
      next
    }
    rel <- sub(paste0("^", gsub("([\\^$.|?*+(){}\\[\\]\\\\])", "\\\\\\1", pkg_dir), "/?"), "", path)
    for (i in idx) {
      line <- lines[[i]]
      if (!is_allowed(line)) {
        hits <- c(hits, paste0(rel, ":", i, ": ", line))
      }
    }
  }
  data.frame(
    FilesScanned = length(files),
    DisallowedRemovedTerms = length(hits),
    TerminologyOK = length(hits) == 0L,
    Examples = paste(utils::head(hits, 5L), collapse = " | "),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_checklist_status <- function(path) {
  if (!file.exists(path)) {
    return(data.frame(
      Checklist = path,
      Rows = 0L,
      BlockerRows = 0L,
      CaveatRows = 0L,
      RoadmapRows = 0L,
      ChecklistAvailable = FALSE,
      stringsAsFactors = FALSE
    ))
  }
  checklist <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  decision <- as.character(checklist$ReleaseDecision %||% character(0))
  data.frame(
    Checklist = path,
    Rows = nrow(checklist),
    BlockerRows = sum(decision == "blocker_if_failed", na.rm = TRUE),
    CaveatRows = sum(decision == "caveat_if_incomplete", na.rm = TRUE),
    RoadmapRows = sum(decision == "roadmap_if_missing", na.rm = TRUE),
    ChecklistAvailable = nrow(checklist) > 0L,
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_gpcm_scope_status <- function(paths,
                                                      checklist_status = NULL) {
  empty_status <- function(status, detail) {
    data.frame(
      GPCMScopeStatus = status,
      MatrixRows = 0L,
      OutstandingRows = 0L,
      RoadmapRows = 0L,
      ChecklistRoadmapRows = if (!is.null(checklist_status)) {
        checklist_status$RoadmapRows[1] %||% NA_integer_
      } else {
        NA_integer_
      },
      RuntimeGuardRows = 0L,
      RuntimeGuardAreas = 0L,
      GuidanceComplete = FALSE,
      RoadmapCoversOutstanding = FALSE,
      RuntimeGuardCoverageOK = FALSE,
      RuntimeGuardStatusOK = FALSE,
      MissingRoadmapAreas = "",
      MissingRuntimeGuardAreas = "",
      Detail = detail,
      stringsAsFactors = FALSE
    )
  }

  if (!file.exists(paths$gpcm_roadmap)) {
    return(empty_status("concern", "GPCM roadmap is missing"))
  }

  env <- new.env(parent = globalenv())
  if (file.exists(paths$gpcm_capability_source)) {
    source(paths$gpcm_capability_source, local = env)
  } else if (isNamespaceLoaded("mfrmr") ||
             requireNamespace("mfrmr", quietly = TRUE)) {
    # Installed-package review context (for example R CMD check runs or CI
    # artifact reviews): installed packages do not retain `R/` source files,
    # so read the capability matrix and guard coverage from the installed
    # namespace instead of the source tree.
    env$gpcm_capability_matrix <-
      getExportedValue("mfrmr", "gpcm_capability_matrix")
    env$gpcm_runtime_guard_coverage <-
      getExportedValue("mfrmr", "gpcm_runtime_guard_coverage")
  } else {
    return(empty_status("concern", "GPCM capability source is missing"))
  }
  if (!exists("gpcm_capability_matrix", envir = env, inherits = FALSE)) {
    return(empty_status("concern", "GPCM capability matrix function is missing"))
  }
  if (!exists("gpcm_runtime_guard_coverage", envir = env, inherits = FALSE)) {
    return(empty_status("concern", "GPCM runtime guard coverage function is missing"))
  }

  matrix <- env$gpcm_capability_matrix()
  required_columns <- c(
    "Area", "Status", "RecommendedRoute", "NextValidationStep"
  )
  missing_columns <- setdiff(required_columns, names(matrix))
  if (length(missing_columns) > 0L) {
    return(empty_status(
      "concern",
      paste("GPCM capability matrix missing columns:", paste(missing_columns, collapse = ", "))
    ))
  }
  guard_coverage <- env$gpcm_runtime_guard_coverage()
  required_guard_columns <- c(
    "Area", "Helper", "Status", "GuardMode", "ExpectedConditionClass",
    "RecommendedRoute", "NextValidationStep"
  )
  missing_guard_columns <- setdiff(required_guard_columns, names(guard_coverage))
  if (length(missing_guard_columns) > 0L) {
    return(empty_status(
      "concern",
      paste("GPCM runtime guard coverage missing columns:",
            paste(missing_guard_columns, collapse = ", "))
    ))
  }

  outstanding <- matrix[matrix$Status %in% c("blocked", "deferred"), , drop = FALSE]
  guard_idx <- match(guard_coverage$Area, matrix$Area)
  guard_status_ok <- all(!is.na(guard_idx)) &&
    all(guard_coverage$Status == matrix$Status[guard_idx]) &&
    all(guard_coverage$RecommendedRoute == matrix$RecommendedRoute[guard_idx]) &&
    all(guard_coverage$NextValidationStep == matrix$NextValidationStep[guard_idx])
  runtime_rows <- guard_coverage[guard_coverage$GuardMode == "runtime_error", , drop = FALSE]
  runtime_condition_ok <- nrow(runtime_rows) > 0L &&
    all(runtime_rows$ExpectedConditionClass == "mfrmr_gpcm_scope_error")
  covered_guard_areas <- unique(guard_coverage$Area[
    guard_coverage$GuardMode %in% c("runtime_error", "roadmap_only")
  ])
  missing_guard_areas <- setdiff(outstanding$Area, covered_guard_areas)
  runtime_guard_coverage_ok <- length(missing_guard_areas) == 0L &&
    isTRUE(guard_status_ok) &&
    isTRUE(runtime_condition_ok)
  roadmap <- paste(mfrmr_release_readiness_read_lines(paths$gpcm_roadmap), collapse = "\n")
  area_present <- vapply(outstanding$Area, function(area) {
    grepl(area, roadmap, fixed = TRUE)
  }, logical(1))
  missing_areas <- outstanding$Area[!area_present]
  guidance_complete <- all(nzchar(outstanding$RecommendedRoute)) &&
    all(nzchar(outstanding$NextValidationStep))
  checklist_rows <- if (!is.null(checklist_status)) {
    checklist_status$RoadmapRows[1] %||% NA_integer_
  } else {
    NA_integer_
  }
  checklist_covers <- if (is.na(checklist_rows)) {
    NA
  } else {
    checklist_rows >= nrow(outstanding)
  }
  ok <- guidance_complete &&
    length(missing_areas) == 0L &&
    (is.na(checklist_covers) || isTRUE(checklist_covers)) &&
    isTRUE(runtime_guard_coverage_ok)

  data.frame(
    GPCMScopeStatus = if (ok) "ok" else "concern",
    MatrixRows = nrow(matrix),
    OutstandingRows = nrow(outstanding),
    RoadmapRows = length(grep("^### ", mfrmr_release_readiness_read_lines(paths$gpcm_roadmap))),
    ChecklistRoadmapRows = checklist_rows,
    RuntimeGuardRows = nrow(runtime_rows),
    RuntimeGuardAreas = length(unique(guard_coverage$Area)),
    GuidanceComplete = guidance_complete,
    RoadmapCoversOutstanding = length(missing_areas) == 0L,
    RuntimeGuardCoverageOK = runtime_guard_coverage_ok,
    RuntimeGuardStatusOK = isTRUE(guard_status_ok) && isTRUE(runtime_condition_ok),
    MissingRoadmapAreas = paste(missing_areas, collapse = " | "),
    MissingRuntimeGuardAreas = paste(missing_guard_areas, collapse = " | "),
    Detail = paste0(
      "outstanding_rows=", nrow(outstanding),
      "; guidance_complete=", guidance_complete,
      "; roadmap_covers_outstanding=", length(missing_areas) == 0L,
      "; checklist_roadmap_rows=", checklist_rows,
      "; runtime_guard_coverage=", runtime_guard_coverage_ok,
      "; runtime_guard_rows=", nrow(runtime_rows)
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_ci_workflow_status <- function(path) {
  if (!file.exists(path)) {
    return(data.frame(
      Workflow = path,
      WorkflowAvailable = FALSE,
      MatrixIncludesMainOS = FALSE,
      MatrixIncludesRDevelOldrelRelease = FALSE,
      PackageCheckStepPresent = FALSE,
      WarningsAreFailures = FALSE,
      CheckArtifactsUploaded = FALSE,
      ReadinessGatePresent = FALSE,
      CIWorkflowOK = FALSE,
      stringsAsFactors = FALSE
    ))
  }
  lines <- mfrmr_release_readiness_read_lines(path)
  contains <- function(pattern) {
    any(grepl(pattern, lines, fixed = TRUE))
  }
  matrix_os <- all(vapply(
    c("ubuntu-latest", "macos-latest", "windows-latest"),
    contains,
    logical(1)
  ))
  matrix_r <- all(vapply(
    c("devel", "release", "oldrel-1"),
    contains,
    logical(1)
  ))
  package_check <- contains("r-lib/actions/check-r-package@v2")
  warning_policy <- any(grepl("error-on:", lines, fixed = TRUE) &
    grepl("warning", lines, fixed = TRUE))
  artifact_upload <- contains("actions/upload-artifact@v4") &&
    any(grepl("check", lines, fixed = TRUE) | grepl("Rcheck", lines, fixed = TRUE))
  readiness_gate <- contains("Release-readiness gate") &&
    contains("mfrmr_release_readiness_review")
  data.frame(
    Workflow = path,
    WorkflowAvailable = TRUE,
    MatrixIncludesMainOS = matrix_os,
    MatrixIncludesRDevelOldrelRelease = matrix_r,
    PackageCheckStepPresent = package_check,
    WarningsAreFailures = warning_policy,
    CheckArtifactsUploaded = artifact_upload,
    ReadinessGatePresent = readiness_gate,
    CIWorkflowOK = isTRUE(matrix_os && matrix_r && package_check && warning_policy &&
      artifact_upload && readiness_gate),
    stringsAsFactors = FALSE
  )
}

# Example-runtime policy review. Since the 0.2.1 release cycle, long-running illustration
# examples must use \dontrun (not \donttest): CRAN incoming pre-tests run
# \donttest examples and count them toward the overall-checktime limit
# (the 0.2.1 submission was auto-rejected at 12 min > 10 min on the
# Windows incoming host). This review checks the source tree for
# remaining \donttest tags and, when a check run is available, reviews
# the per-page and total example timings from `mfrmr-Ex.timings`.
mfrmr_release_readiness_example_policy_status <- function(paths) {
  r_dir <- file.path(paths$pkg_dir, "R")
  r_files <- if (dir.exists(r_dir)) {
    list.files(r_dir, pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
  } else {
    character(0)
  }
  donttest_scan_available <- length(r_files) > 0L
  donttest_count <- if (donttest_scan_available) {
    sum(vapply(r_files, function(path) {
      sum(grepl("\\\\donttest\\{", readLines(path, warn = FALSE), perl = TRUE))
    }, numeric(1)))
  } else {
    NA_real_
  }

  timings_path <- file.path(dirname(paths$check_log), "mfrmr-Ex.timings")
  timings_available <- file.exists(timings_path)
  example_count <- NA_integer_
  total_elapsed <- NA_real_
  slow_examples <- character(0)
  slow_threshold <- 4
  total_budget <- 120
  if (timings_available) {
    timings <- tryCatch(
      utils::read.delim(timings_path, header = FALSE,
                        col.names = c("name", "user", "system", "elapsed"),
                        stringsAsFactors = FALSE),
      error = function(e) NULL
    )
    if (!is.null(timings) && nrow(timings) > 0L) {
      elapsed <- suppressWarnings(as.numeric(timings$elapsed))
      example_count <- nrow(timings)
      total_elapsed <- sum(elapsed, na.rm = TRUE)
      slow_examples <- as.character(
        timings$name[is.finite(elapsed) & elapsed > slow_threshold]
      )
    } else {
      timings_available <- FALSE
    }
  }

  data.frame(
    DonttestScanAvailable = donttest_scan_available,
    DonttestCount = donttest_count,
    TimingsAvailable = timings_available,
    ExampleCount = example_count,
    TotalExampleElapsed = total_elapsed,
    SlowExampleThreshold = slow_threshold,
    SlowExampleCount = length(slow_examples),
    SlowExamples = paste(slow_examples, collapse = ", "),
    TotalExampleBudget = total_budget,
    ExamplePolicyOK =
      (!donttest_scan_available || isTRUE(donttest_count == 0)) &&
        (!timings_available ||
           (length(slow_examples) == 0L &&
              isTRUE(total_elapsed <= total_budget))),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_gate_summary <- function(version_status,
                                                 check_status,
                                                 term_status,
                                                 checklist_status,
                                                 ci_workflow_status,
                                                 paths,
                                                 gpcm_scope_status = NULL,
                                                 mh_dif_comparison_status = NULL,
                                                 dif_apa_reporting_status = NULL,
                                                 dif_dff_simulation_status = NULL,
                                                 convergence_reporting_status = NULL,
                                                 gpcm_score_side_status = NULL,
                                                 gpcm_score_side_external_status = NULL,
                                                 release_scope_status = NULL,
                                                 network_anchor_stress_status = NULL,
                                                 self_other_speaking_network_status = NULL,
                                                 example_policy_status = NULL) {
  path_exists <- function(path) {
    is.character(path) && length(path) > 0L && file.exists(path[1])
  }
  gpcm_scope_ok <- if (is.null(gpcm_scope_status)) {
    TRUE
  } else {
    identical(gpcm_scope_status$GPCMScopeStatus[1], "ok")
  }
  mh_dif_status <- if (is.null(mh_dif_comparison_status)) {
    "not_checked"
  } else {
    mh_dif_comparison_status$MHDIFComparisonStatus[1]
  }
  mh_dif_gate_ok <- is.null(mh_dif_comparison_status) ||
    isTRUE(mh_dif_comparison_status$ComparisonGateOK[1])
  dif_apa_status <- if (is.null(dif_apa_reporting_status)) {
    "not_checked"
  } else {
    dif_apa_reporting_status$DIFAPAReportingStatus[1]
  }
  dif_apa_gate_ok <- is.null(dif_apa_reporting_status) ||
    isTRUE(dif_apa_reporting_status$ReportingGateOK[1])
  dif_dff_sim_status <- if (is.null(dif_dff_simulation_status)) {
    "not_checked"
  } else {
    dif_dff_simulation_status$DIFDFFSimulationStatus[1]
  }
  dif_dff_sim_gate_ok <- is.null(dif_dff_simulation_status) ||
    isTRUE(dif_dff_simulation_status$SimulationGateOK[1])
  convergence_reporting_value <- if (is.null(convergence_reporting_status)) {
    "not_checked"
  } else {
    convergence_reporting_status$ConvergenceReportingStressStatus[1]
  }
  convergence_reporting_gate_ok <- is.null(convergence_reporting_status) ||
    isTRUE(convergence_reporting_status$StressGateOK[1])
  gpcm_score_side_sim_status <- if (is.null(gpcm_score_side_status)) {
    "not_checked"
  } else {
    gpcm_score_side_status$GPCMScoreSideSimulationStatus[1]
  }
  gpcm_score_side_gate_ok <- is.null(gpcm_score_side_status) ||
    isTRUE(gpcm_score_side_status$SimulationGateOK[1])
  gpcm_score_side_external_value <- if (is.null(gpcm_score_side_external_status)) {
    "not_checked"
  } else {
    gpcm_score_side_external_status$GPCMScoreSideExternalComparisonStatus[1]
  }
  gpcm_score_side_external_gate_ok <- is.null(gpcm_score_side_external_status) ||
    isTRUE(gpcm_score_side_external_status$ExternalComparisonGateOK[1])
  release_scope_value <- if (is.null(release_scope_status)) {
    "not_checked"
  } else {
    release_scope_status$ReleaseScopeReviewStatus[1]
  }
  release_scope_gate_ok <- is.null(release_scope_status) ||
    isTRUE(release_scope_status$ScopeGateOK[1])
  network_anchor_stress_value <- if (is.null(network_anchor_stress_status)) {
    "not_checked"
  } else {
    network_anchor_stress_status$NetworkAnchorStressStatus[1]
  }
  network_anchor_stress_gate_ok <- is.null(network_anchor_stress_status) ||
    isTRUE(network_anchor_stress_status$StressGateOK[1])
  self_other_speaking_network_value <- if (is.null(self_other_speaking_network_status)) {
    "not_checked"
  } else {
    self_other_speaking_network_status$SelfOtherSpeakingNetworkStatus[1]
  }
  self_other_speaking_network_gate_ok <- is.null(self_other_speaking_network_status) ||
    isTRUE(self_other_speaking_network_status$NetworkGateOK[1])
  evidence_available <- path_exists(paths$evidence_map) &&
    path_exists(paths$gpcm_roadmap) &&
    path_exists(paths$external_recovery_evidence) &&
    path_exists(paths$external_recovery_helper) &&
    path_exists(paths$mh_dif_alignment_note) &&
    path_exists(paths$mh_dif_comparison_helper) &&
    path_exists(paths$mh_dif_simulation_helper) &&
    path_exists(paths$dif_apa_reporting_note) &&
    path_exists(paths$dif_apa_reporting_helper) &&
    path_exists(paths$dif_apa_reporting_evidence) &&
    path_exists(paths$dif_dff_simulation_helper) &&
    path_exists(paths$dif_dff_simulation_evidence) &&
    path_exists(paths$convergence_reporting_stress_helper) &&
    path_exists(paths$convergence_reporting_stress_evidence) &&
    path_exists(paths$gpcm_score_side_simulation_helper) &&
    path_exists(paths$gpcm_score_side_simulation_evidence) &&
    path_exists(paths$gpcm_score_side_simulation_summary) &&
    path_exists(paths$gpcm_score_side_simulation_checks) &&
    path_exists(paths$gpcm_score_side_external_helper) &&
    path_exists(paths$gpcm_score_side_external_evidence) &&
    path_exists(paths$gpcm_score_side_external_results) &&
    path_exists(paths$gpcm_score_side_external_checks) &&
    path_exists(paths$release_scope_helper) &&
    path_exists(paths$release_scope_evidence) &&
    path_exists(paths$release_scope_checks) &&
    path_exists(paths$network_anchor_stress_helper) &&
    path_exists(paths$network_anchor_stress_evidence) &&
    path_exists(paths$network_anchor_stress_summary) &&
    path_exists(paths$network_anchor_stress_checks) &&
    path_exists(paths$network_anchor_stress_rater_modes) &&
    path_exists(paths$self_other_speaking_network_helper) &&
    path_exists(paths$self_other_speaking_network_evidence) &&
    path_exists(paths$self_other_speaking_network_summary) &&
    path_exists(paths$self_other_speaking_network_checks) &&
    path_exists(paths$self_other_speaking_network_templates) &&
    isTRUE(checklist_status$ChecklistAvailable[1]) &&
    isTRUE(gpcm_scope_ok) &&
    isTRUE(mh_dif_gate_ok) &&
    isTRUE(dif_apa_gate_ok) &&
    isTRUE(dif_dff_sim_gate_ok) &&
    isTRUE(convergence_reporting_gate_ok) &&
    isTRUE(gpcm_score_side_gate_ok) &&
    isTRUE(gpcm_score_side_external_gate_ok) &&
    isTRUE(release_scope_gate_ok) &&
    isTRUE(network_anchor_stress_gate_ok) &&
    isTRUE(self_other_speaking_network_gate_ok)
  rows <- data.frame(
    Gate = c("version_contract", "package_check", "ci_workflow", "terminology", "evidence_artifacts"),
    Status = c(
      if (isTRUE(version_status$VersionOK[1])) "ok" else "concern",
      if (isTRUE(check_status$CheckPassed[1]) &&
          !isTRUE(check_status$NeedsExplanation[1]) &&
          !identical(check_status$VersionMatchesTarget[1], FALSE) &&
          !identical(check_status$FreshAgainstSource[1], FALSE)) {
        "ok"
      } else if (isTRUE(check_status$CheckPassed[1])) {
        "review"
      } else {
        "concern"
      },
      if (isTRUE(ci_workflow_status$CIWorkflowOK[1])) "ok" else "review",
      if (isTRUE(term_status$TerminologyOK[1])) "ok" else "concern",
      if (evidence_available) "ok" else "concern"
    ),
    Detail = c(
      paste0("DESCRIPTION=", version_status$DescriptionVersion[1], "; NEWS=", version_status$NewsHeading[1]),
      paste0(
        check_status$StatusLine[1],
        "; check_version=", check_status$PackageVersion[1],
        "; target=", check_status$TargetVersion[1],
        "; version_match=", check_status$VersionMatchesTarget[1],
        "; fresh_against_source=", check_status$FreshAgainstSource[1],
        "; source_latest=", check_status$SourceLatestFile[1]
      ),
      paste0(
        "workflow=", ci_workflow_status$WorkflowAvailable[1],
        "; check_step=", ci_workflow_status$PackageCheckStepPresent[1],
        "; warnings_fail=", ci_workflow_status$WarningsAreFailures[1],
        "; artifacts=", ci_workflow_status$CheckArtifactsUploaded[1],
        "; gate=", ci_workflow_status$ReadinessGatePresent[1]
      ),
      paste0(term_status$DisallowedRemovedTerms[1], " disallowed removed-name hit(s)"),
      paste0(
        "evidence_map=", path_exists(paths$evidence_map),
        "; gpcm_roadmap=", path_exists(paths$gpcm_roadmap),
        "; external_recovery=", path_exists(paths$external_recovery_evidence),
        "; external_helper=", path_exists(paths$external_recovery_helper),
        "; mh_dif_alignment=", path_exists(paths$mh_dif_alignment_note),
        "; mh_dif_helper=", path_exists(paths$mh_dif_comparison_helper),
        "; mh_dif_simulation=", path_exists(paths$mh_dif_simulation_helper),
        "; dif_apa_reporting=", path_exists(paths$dif_apa_reporting_note),
        "; dif_apa_helper=", path_exists(paths$dif_apa_reporting_helper),
        "; dif_apa_evidence=", path_exists(paths$dif_apa_reporting_evidence),
        "; dif_apa_status=", dif_apa_status,
        "; dif_dff_sim_helper=", path_exists(paths$dif_dff_simulation_helper),
        "; dif_dff_sim_evidence=", path_exists(paths$dif_dff_simulation_evidence),
        "; dif_dff_sim_status=", dif_dff_sim_status,
        "; convergence_reporting_helper=", path_exists(paths$convergence_reporting_stress_helper),
        "; convergence_reporting_evidence=", path_exists(paths$convergence_reporting_stress_evidence),
        "; convergence_reporting_status=", convergence_reporting_value,
        "; gpcm_score_side_helper=", path_exists(paths$gpcm_score_side_simulation_helper),
        "; gpcm_score_side_evidence=", path_exists(paths$gpcm_score_side_simulation_evidence),
        "; gpcm_score_side_summary=", path_exists(paths$gpcm_score_side_simulation_summary),
        "; gpcm_score_side_checks=", path_exists(paths$gpcm_score_side_simulation_checks),
        "; gpcm_score_side_status=", gpcm_score_side_sim_status,
        "; gpcm_score_side_external_helper=", path_exists(paths$gpcm_score_side_external_helper),
        "; gpcm_score_side_external_evidence=", path_exists(paths$gpcm_score_side_external_evidence),
        "; gpcm_score_side_external_results=", path_exists(paths$gpcm_score_side_external_results),
        "; gpcm_score_side_external_checks=", path_exists(paths$gpcm_score_side_external_checks),
        "; gpcm_score_side_external_status=", gpcm_score_side_external_value,
        "; release_scope_helper=", path_exists(paths$release_scope_helper),
        "; release_scope_evidence=", path_exists(paths$release_scope_evidence),
        "; release_scope_checks=", path_exists(paths$release_scope_checks),
        "; release_scope_status=", release_scope_value,
        "; network_anchor_stress_helper=", path_exists(paths$network_anchor_stress_helper),
        "; network_anchor_stress_evidence=", path_exists(paths$network_anchor_stress_evidence),
        "; network_anchor_stress_summary=", path_exists(paths$network_anchor_stress_summary),
        "; network_anchor_stress_checks=", path_exists(paths$network_anchor_stress_checks),
        "; network_anchor_stress_rater_modes=", path_exists(paths$network_anchor_stress_rater_modes),
        "; network_anchor_stress_status=", network_anchor_stress_value,
        "; self_other_speaking_network_helper=", path_exists(paths$self_other_speaking_network_helper),
        "; self_other_speaking_network_evidence=", path_exists(paths$self_other_speaking_network_evidence),
        "; self_other_speaking_network_summary=", path_exists(paths$self_other_speaking_network_summary),
        "; self_other_speaking_network_checks=", path_exists(paths$self_other_speaking_network_checks),
        "; self_other_speaking_network_templates=", path_exists(paths$self_other_speaking_network_templates),
        "; self_other_speaking_network_status=", self_other_speaking_network_value,
        "; mh_dif_status=", mh_dif_status,
        "; checklist_rows=", checklist_status$Rows[1],
        "; gpcm_scope=", if (is.null(gpcm_scope_status)) {
          "not_checked"
        } else {
          gpcm_scope_status$GPCMScopeStatus[1]
        },
        "; gpcm_runtime_guard=", if (is.null(gpcm_scope_status)) {
          "not_checked"
        } else {
          gpcm_scope_status$RuntimeGuardCoverageOK[1]
        }
      )
    ),
    stringsAsFactors = FALSE
  )
  if (!is.null(example_policy_status)) {
    example_gate <- if (isTRUE(example_policy_status$DonttestScanAvailable[1]) &&
                        !isTRUE(example_policy_status$DonttestCount[1] == 0)) {
      "concern"
    } else if (isTRUE(example_policy_status$TimingsAvailable[1]) &&
               (isTRUE(example_policy_status$SlowExampleCount[1] > 0) ||
                isTRUE(example_policy_status$TotalExampleElapsed[1] >
                         example_policy_status$TotalExampleBudget[1]))) {
      "review"
    } else {
      "ok"
    }
    rows <- rbind(rows, data.frame(
      Gate = "example_policy",
      Status = example_gate,
      Detail = paste0(
        "donttest=", example_policy_status$DonttestCount[1],
        "; slow_examples(>", example_policy_status$SlowExampleThreshold[1],
        "s)=", example_policy_status$SlowExampleCount[1],
        if (nzchar(example_policy_status$SlowExamples[1])) {
          paste0(" [", example_policy_status$SlowExamples[1], "]")
        } else {
          ""
        },
        "; total_elapsed=",
        round(example_policy_status$TotalExampleElapsed[1], 1),
        "s (budget ", example_policy_status$TotalExampleBudget[1], "s)",
        "; timings=", example_policy_status$TimingsAvailable[1]
      ),
      stringsAsFactors = FALSE
    ))
  }
  rows
}

mfrmr_release_readiness_decision <- function(gate_summary) {
  status <- as.character(gate_summary$Status)
  if (any(status == "concern", na.rm = TRUE)) {
    "concern"
  } else if (any(status == "review", na.rm = TRUE)) {
    "review"
  } else {
    "ok"
  }
}

mfrmr_release_readiness_external_recovery_status <- function(paths, external_recovery_dir = NULL) {
  if (is.null(external_recovery_dir) || !nzchar(external_recovery_dir)) {
    return(data.frame(
      ExternalRecoveryRequested = FALSE,
      ExternalRecoveryDir = NA_character_,
      EvidenceStatus = NA_character_,
      RequiredSchemaOK = NA,
      Detail = "not requested",
      stringsAsFactors = FALSE
    ))
  }
  external_recovery_dir <- normalizePath(external_recovery_dir, winslash = "/", mustWork = FALSE)
  if (!file.exists(paths$external_recovery_helper)) {
    return(data.frame(
      ExternalRecoveryRequested = TRUE,
      ExternalRecoveryDir = external_recovery_dir,
      EvidenceStatus = "concern",
      RequiredSchemaOK = FALSE,
      Detail = "external recovery helper is missing",
      stringsAsFactors = FALSE
    ))
  }
  env <- new.env(parent = globalenv())
  source(paths$external_recovery_helper, local = env)
  if (!exists("mfrmr_review_external_recovery_simulation", envir = env, inherits = FALSE)) {
    return(data.frame(
      ExternalRecoveryRequested = TRUE,
      ExternalRecoveryDir = external_recovery_dir,
      EvidenceStatus = "concern",
      RequiredSchemaOK = FALSE,
      Detail = "external recovery helper did not define the review function",
      stringsAsFactors = FALSE
    ))
  }
  review <- env$mfrmr_review_external_recovery_simulation(external_recovery_dir)
  required_schema <- review$schema_status$Required
  required_schema_ok <- if (length(required_schema) == 0L) {
    FALSE
  } else {
    all(review$schema_status$SchemaOK[required_schema], na.rm = FALSE)
  }
  data.frame(
    ExternalRecoveryRequested = TRUE,
    ExternalRecoveryDir = external_recovery_dir,
    EvidenceStatus = as.character(review$decision$EvidenceStatus[1]),
    RequiredSchemaOK = isTRUE(required_schema_ok),
    Detail = as.character(review$decision$Interpretation[1]),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_mh_dif_comparison_status <- function(paths) {
  helper <- paths$mh_dif_comparison_helper %||% NA_character_
  if (!is.character(helper) || length(helper) == 0L || !file.exists(helper[1])) {
    return(data.frame(
      MHDIFComparisonStatus = "missing",
      ComparisonGateOK = FALSE,
      DifRVersion = NA_character_,
      FixtureSeed = NA_integer_,
      FixtureN = NA_integer_,
      ZeroCorrection = NA_real_,
      MaxAbsDiff = NA_real_,
      Detail = "MH DIF comparison helper is missing",
      stringsAsFactors = FALSE
    ))
  }
  env <- new.env(parent = globalenv())
  source(helper[1], local = env)
  if (!exists("mfrmr_review_mh_dif_package_comparison",
              envir = env, inherits = FALSE)) {
    return(data.frame(
      MHDIFComparisonStatus = "error",
      ComparisonGateOK = FALSE,
      DifRVersion = NA_character_,
      FixtureSeed = NA_integer_,
      FixtureN = NA_integer_,
      ZeroCorrection = NA_real_,
      MaxAbsDiff = NA_real_,
      Detail = "helper did not define mfrmr_review_mh_dif_package_comparison()",
      stringsAsFactors = FALSE
    ))
  }
  if (!exists("analyze_dif_mh", mode = "function", inherits = TRUE) &&
      requireNamespace("pkgload", quietly = TRUE) &&
      file.exists(file.path(paths$pkg_dir, "DESCRIPTION"))) {
    try(pkgload::load_all(paths$pkg_dir, quiet = TRUE), silent = TRUE)
  }
  review <- tryCatch(
    env$mfrmr_review_mh_dif_package_comparison(),
    error = function(e) e
  )
  if (inherits(review, "error")) {
    return(data.frame(
      MHDIFComparisonStatus = "error",
      ComparisonGateOK = FALSE,
      DifRVersion = NA_character_,
      FixtureSeed = NA_integer_,
      FixtureN = NA_integer_,
      ZeroCorrection = NA_real_,
      MaxAbsDiff = NA_real_,
      Detail = conditionMessage(review),
      stringsAsFactors = FALSE
    ))
  }
  status <- as.character(review$status %||% "unknown")
  max_abs <- review$max_abs_diff %||% NA_real_
  max_abs <- suppressWarnings(max(as.numeric(max_abs), na.rm = TRUE))
  if (!is.finite(max_abs)) {
    max_abs <- NA_real_
  }
  data.frame(
    MHDIFComparisonStatus = status[1],
    ComparisonGateOK = status[1] %in% c("ok", "skipped"),
    DifRVersion = as.character(review$difr_version %||% NA_character_)[1],
    FixtureSeed = as.integer(review$fixture_seed %||% NA_integer_)[1],
    FixtureN = as.integer(review$fixture_n_person %||% NA_integer_)[1],
    ZeroCorrection = as.numeric(review$zero_correction %||% NA_real_)[1],
    MaxAbsDiff = max_abs,
    Detail = if (!is.null(review$reason)) {
      as.character(review$reason)[1]
    } else {
      paste0("status=", status[1], "; tolerance=", review$tolerance %||% NA)
    },
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_dif_apa_reporting_status <- function(paths) {
  helper <- paths$dif_apa_reporting_helper %||% NA_character_
  if (!is.character(helper) || length(helper) == 0L || !file.exists(helper[1])) {
    return(data.frame(
      DIFAPAReportingStatus = "missing",
      ReportingGateOK = FALSE,
      Cases = NA_integer_,
      Checks = NA_integer_,
      FailedChecks = NA_integer_,
      Detail = "DIF/DFF APA reporting helper is missing",
      stringsAsFactors = FALSE
    ))
  }
  env <- new.env(parent = globalenv())
  source(helper[1], local = env)
  if (!exists("mfrmr_review_dif_apa_reporting",
              envir = env, inherits = FALSE)) {
    return(data.frame(
      DIFAPAReportingStatus = "error",
      ReportingGateOK = FALSE,
      Cases = NA_integer_,
      Checks = NA_integer_,
      FailedChecks = NA_integer_,
      Detail = "helper did not define mfrmr_review_dif_apa_reporting()",
      stringsAsFactors = FALSE
    ))
  }
  if (!exists("fit_mfrm", mode = "function", inherits = TRUE) &&
      requireNamespace("pkgload", quietly = TRUE) &&
      file.exists(file.path(paths$pkg_dir, "DESCRIPTION"))) {
    try(pkgload::load_all(paths$pkg_dir, quiet = TRUE), silent = TRUE)
  }
  review_warnings <- character(0)
  review <- tryCatch(
    withCallingHandlers(
      env$mfrmr_review_dif_apa_reporting(
        include_refit = TRUE,
        include_gpcm = TRUE
      ),
      warning = function(w) {
        review_warnings <<- c(review_warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) e
  )
  if (inherits(review, "error")) {
    return(data.frame(
      DIFAPAReportingStatus = "error",
      ReportingGateOK = FALSE,
      Cases = NA_integer_,
      Checks = NA_integer_,
      FailedChecks = NA_integer_,
      Detail = conditionMessage(review),
      stringsAsFactors = FALSE
    ))
  }
  checks <- as.data.frame(review$checks %||% data.frame(),
                          stringsAsFactors = FALSE)
  failed <- if (nrow(checks) > 0L && "Passed" %in% names(checks)) {
    sum(!isTRUE(checks$Passed) & !checks$Passed, na.rm = TRUE)
  } else {
    NA_integer_
  }
  status <- as.character(review$status %||% "unknown")[1]
  warning_is_expected <- grepl(
    "Optimizer result needs convergence review",
    review_warnings,
    fixed = TRUE
  )
  unexpected_warnings <- sum(!warning_is_expected, na.rm = TRUE)
  warning_summary <- if (length(review_warnings) == 0L) {
    ""
  } else {
    paste(unique(review_warnings), collapse = " | ")
  }
  data.frame(
    DIFAPAReportingStatus = status,
    ReportingGateOK = identical(status, "ok") &&
      identical(failed, 0L) &&
      identical(unexpected_warnings, 0L),
    Cases = nrow(as.data.frame(review$case_table %||% data.frame())),
    Checks = nrow(checks),
    FailedChecks = failed,
    WarningCount = length(review_warnings),
    UnexpectedWarnings = unexpected_warnings,
    Detail = paste0(
      "include_refit=", isTRUE(review$include_refit),
      "; include_gpcm=", isTRUE(review$include_gpcm),
      "; captured_warnings=", length(review_warnings),
      "; unexpected_warnings=", unexpected_warnings,
      "; warning_summary=", warning_summary
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_dif_dff_simulation_status <- function(paths) {
  helper <- paths$dif_dff_simulation_helper %||% NA_character_
  evidence <- paths$dif_dff_simulation_evidence %||% NA_character_
  missing <- character(0)
  if (!is.character(helper) || length(helper) == 0L || !file.exists(helper[1])) {
    missing <- c(missing, "helper")
  }
  if (!is.character(evidence) || length(evidence) == 0L ||
      !file.exists(evidence[1])) {
    missing <- c(missing, "evidence")
  }
  if (length(missing) > 0L) {
    return(data.frame(
      DIFDFFSimulationStatus = "missing",
      SimulationGateOK = FALSE,
      Cases = NA_integer_,
      Checks = NA_integer_,
      FailedChecks = NA_integer_,
      Detail = paste("DIF/DFF simulation matrix", paste(missing, collapse = "+"),
                     "missing"),
      stringsAsFactors = FALSE
    ))
  }

  env <- new.env(parent = globalenv())
  source(helper[1], local = env)
  if (!exists("mfrmr_dif_dff_simulation_matrix_expected_cases",
              envir = env, inherits = FALSE)) {
    return(data.frame(
      DIFDFFSimulationStatus = "error",
      SimulationGateOK = FALSE,
      Cases = NA_integer_,
      Checks = NA_integer_,
      FailedChecks = NA_integer_,
      Detail = "helper did not define expected simulation matrix cases",
      stringsAsFactors = FALSE
    ))
  }
  expected <- env$mfrmr_dif_dff_simulation_matrix_expected_cases()
  expected_models <- sort(unique(as.character(expected$Model)))
  expected_scenarios <- sort(unique(as.character(expected$Scenario)))
  lines <- readLines(evidence[1], warn = FALSE)
  extract_scalar <- function(pattern, default = NA_character_) {
    hit <- grep(pattern, lines, value = TRUE)
    if (length(hit) == 0L) {
      return(default)
    }
    sub(pattern, "\\1", hit[1])
  }
  status <- extract_scalar(".*DIFDFFSimulationStatus = \"([^\"]+)\".*")
  cases <- suppressWarnings(as.integer(
    extract_scalar(".*Cases = ([0-9]+).*", NA_character_)
  ))
  checks <- suppressWarnings(as.integer(
    extract_scalar(".*Checks = ([0-9]+).*", NA_character_)
  ))
  failed <- suppressWarnings(as.integer(
    extract_scalar(".*FailedChecks = ([0-9]+).*", NA_character_)
  ))
  models_line <- extract_scalar(".*Models = ([^`;]+).*", "")
  scenarios_line <- extract_scalar(".*Scenarios = ([^`;]+).*", "")
  models <- sort(trimws(strsplit(models_line, ",", fixed = TRUE)[[1]]))
  scenarios <- sort(trimws(strsplit(scenarios_line, ",", fixed = TRUE)[[1]]))
  models_ok <- identical(models, expected_models)
  scenarios_ok <- identical(scenarios, expected_scenarios)
  gate_ok <- identical(status, "ok") &&
    identical(failed, 0L) &&
    isTRUE(cases >= nrow(expected)) &&
    isTRUE(checks > 0L) &&
    models_ok &&
    scenarios_ok
  data.frame(
    DIFDFFSimulationStatus = status,
    SimulationGateOK = gate_ok,
    Cases = cases,
    Checks = checks,
    FailedChecks = failed,
    Detail = paste0(
      "models_ok=", models_ok,
      "; scenarios_ok=", scenarios_ok,
      "; expected_cases=", nrow(expected)
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_convergence_reporting_status <- function(paths) {
  helper <- paths$convergence_reporting_stress_helper %||% NA_character_
  evidence <- paths$convergence_reporting_stress_evidence %||% NA_character_
  path_ok <- function(path) {
    is.character(path) && length(path) > 0L && file.exists(path[1])
  }
  missing <- character(0)
  if (!path_ok(helper)) {
    missing <- c(missing, "helper")
  }
  if (!path_ok(evidence)) {
    missing <- c(missing, "evidence")
  }
  if (length(missing) > 0L) {
    return(data.frame(
      ConvergenceReportingStressStatus = "missing",
      StressGateOK = FALSE,
      CRANTimeSimulation = NA,
      RequiredChecks = NA_integer_,
      OutputFiles = NA_integer_,
      Detail = paste("convergence-reporting stress",
                     paste(missing, collapse = "+"), "missing"),
      stringsAsFactors = FALSE
    ))
  }

  evidence_lines <- readLines(evidence[1], warn = FALSE)
  script_lines <- readLines(helper[1], warn = FALSE)
  evidence_text <- paste(evidence_lines, collapse = "\n")
  script_text <- paste(script_lines, collapse = "\n")
  extract_scalar <- function(pattern, default = NA_character_) {
    hit <- grep(pattern, evidence_lines, value = TRUE)
    if (length(hit) == 0L) {
      return(default)
    }
    sub(pattern, "\\1", hit[1])
  }
  status <- extract_scalar(".*ConvergenceReportingStressStatus = \"([^\"]+)\".*")
  cran_time_simulation <- grepl("`CRANTimeSimulation = FALSE`",
                                evidence_text,
                                fixed = TRUE)
  default_output_ok <- grepl(
    "validation-results/convergence-reporting-stress-0.2.2",
    evidence_text,
    fixed = TRUE
  ) &&
    grepl("validation-results", script_text, fixed = TRUE)
  cran_boundary_ok <- grepl("outside the CRAN-time test suite",
                            script_text,
                            fixed = TRUE) &&
    grepl("does not source the script or run[[:space:]]+fits",
          evidence_text)
  required_checks <- c(
    "all_runs_completed",
    "direct_iterations_are_function_evaluations",
    "bfgs_iterations_mirror_gradient_evaluations",
    "bfgs_iterations_do_not_exceed_maxit",
    "function_evaluations_can_exceed_maxit_observed",
    "large_gradient_plateau_mapping",
    "large_gradient_status_is_well_formed",
    "pass_direct_rows_have_small_terminal_gradient",
    "iteration_limit_stress_observed",
    "em_basis_rows_remain_distinct"
  )
  checks_in_evidence <- vapply(required_checks, grepl, logical(1),
                               x = evidence_text, fixed = TRUE)
  checks_in_script <- vapply(required_checks, grepl, logical(1),
                             x = script_text, fixed = TRUE)
  output_files <- c(
    "convergence-reporting-stress-0.2.2-runs.csv",
    "convergence-reporting-stress-0.2.2-checks.csv",
    "convergence-reporting-stress-0.2.2-summary.csv",
    "convergence-reporting-stress-0.2.2.md"
  )
  outputs_in_evidence <- vapply(output_files, grepl, logical(1),
                                x = evidence_text, fixed = TRUE)
  outputs_in_script <- vapply(output_files, grepl, logical(1),
                              x = script_text, fixed = TRUE)
  gate_ok <- identical(status, "available") &&
    isTRUE(cran_time_simulation) &&
    isTRUE(default_output_ok) &&
    isTRUE(cran_boundary_ok) &&
    all(checks_in_evidence) &&
    all(checks_in_script) &&
    all(outputs_in_evidence) &&
    all(outputs_in_script)

  data.frame(
    ConvergenceReportingStressStatus = status,
    StressGateOK = gate_ok,
    CRANTimeSimulation = FALSE,
    RequiredChecks = sum(checks_in_evidence & checks_in_script),
    OutputFiles = sum(outputs_in_evidence & outputs_in_script),
    Detail = paste0(
      "cran_boundary_ok=", cran_boundary_ok,
      "; default_output_ok=", default_output_ok,
      "; checks_ok=", all(checks_in_evidence) && all(checks_in_script),
      "; outputs_ok=", all(outputs_in_evidence) && all(outputs_in_script)
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_gpcm_score_side_status <- function(paths) {
  helper <- paths$gpcm_score_side_simulation_helper %||% NA_character_
  evidence <- paths$gpcm_score_side_simulation_evidence %||% NA_character_
  summary_csv <- paths$gpcm_score_side_simulation_summary %||% NA_character_
  checks_csv <- paths$gpcm_score_side_simulation_checks %||% NA_character_
  missing <- character(0)
  path_ok <- function(path) {
    is.character(path) && length(path) > 0L && file.exists(path[1])
  }
  if (!path_ok(helper)) {
    missing <- c(missing, "helper")
  }
  if (!path_ok(evidence)) {
    missing <- c(missing, "evidence")
  }
  if (!path_ok(summary_csv)) {
    missing <- c(missing, "summary")
  }
  if (!path_ok(checks_csv)) {
    missing <- c(missing, "checks")
  }
  if (length(missing) > 0L) {
    return(data.frame(
      GPCMScoreSideSimulationStatus = "missing",
      SimulationGateOK = FALSE,
      Replications = NA_integer_,
      Conditions = NA_integer_,
      SummaryRows = NA_integer_,
      FailedChecks = NA_integer_,
      ErroredReplications = NA_integer_,
      MaxSERatioDiff = NA_real_,
      MinConvergedRate = NA_real_,
      Detail = paste("GPCM score-side simulation", paste(missing, collapse = "+"),
                     "missing"),
      stringsAsFactors = FALSE
    ))
  }

  lines <- readLines(evidence[1], warn = FALSE)
  extract_scalar <- function(pattern, default = NA_character_) {
    hit <- grep(pattern, lines, value = TRUE)
    if (length(hit) == 0L) {
      return(default)
    }
    sub(pattern, "\\1", hit[1])
  }
  status <- extract_scalar(".*GPCMScoreSideSimulationStatus = \"([^\"]+)\".*")
  reps <- suppressWarnings(as.integer(
    extract_scalar(".*Replications = ([0-9]+).*", NA_character_)
  ))
  conditions <- suppressWarnings(as.integer(
    extract_scalar(".*Conditions = ([0-9]+).*", NA_character_)
  ))
  summary_rows <- suppressWarnings(as.integer(
    extract_scalar(".*SummaryRows = ([0-9]+).*", NA_character_)
  ))
  errored <- suppressWarnings(as.integer(
    extract_scalar(".*ErroredReplications = ([0-9]+).*", NA_character_)
  ))
  max_se_ratio_diff <- suppressWarnings(as.numeric(
    extract_scalar(".*MaxSERatioDiff = ([0-9.eE+-]+).*", NA_character_)
  ))
  min_converged_rate <- suppressWarnings(as.numeric(
    extract_scalar(".*MinConvergedRate = ([0-9.eE+-]+).*", NA_character_)
  ))
  failed <- suppressWarnings(as.integer(
    extract_scalar(".*FailedChecks = ([0-9]+).*", NA_character_)
  ))

  summary <- tryCatch(
    utils::read.csv(summary_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  checks <- tryCatch(
    utils::read.csv(checks_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  summary_schema_ok <- !is.null(summary) &&
    all(c("regime", "n_person", "band", "reps", "se_ratio_mean",
          "inv_var_mean", "converged_rate") %in% names(summary))
  checks_schema_ok <- !is.null(checks) &&
    all(c("Check", "Value", "Threshold", "Passed") %in% names(checks))
  if (summary_schema_ok) {
    expected_summary_rows <- length(unique(summary$regime)) *
      length(unique(summary$n_person)) * length(unique(summary$band))
    summary_rows_match <- identical(nrow(summary), summary_rows) &&
      isTRUE(summary_rows >= expected_summary_rows)
    all_rows <- summary[summary$band == "all", , drop = FALSE]
    summary_min_converged <- suppressWarnings(min(all_rows$converged_rate, na.rm = TRUE))
    summary_max_ratio_diff <- suppressWarnings(max(abs(
      summary$se_ratio_mean - summary$inv_var_mean
    ), na.rm = TRUE))
  } else {
    expected_summary_rows <- NA_integer_
    summary_rows_match <- FALSE
    summary_min_converged <- NA_real_
    summary_max_ratio_diff <- NA_real_
  }
  if (checks_schema_ok) {
    checks_passed <- if (is.logical(checks$Passed)) {
      checks$Passed
    } else {
      tolower(as.character(checks$Passed)) %in% c("true", "t", "1", "yes")
    }
    checks_pass <- all(checks_passed, na.rm = FALSE)
  } else {
    checks_pass <- FALSE
  }

  gate_ok <- identical(status, "ok") &&
    identical(failed, 0L) &&
    identical(errored, 0L) &&
    isTRUE(conditions >= 6L) &&
    isTRUE(summary_rows_match) &&
    isTRUE(checks_schema_ok) &&
    isTRUE(checks_pass) &&
    isTRUE(is.finite(max_se_ratio_diff) && max_se_ratio_diff <= 1e-10) &&
    isTRUE(is.finite(summary_max_ratio_diff) && summary_max_ratio_diff <= 1e-10) &&
    isTRUE(is.finite(min_converged_rate) && min_converged_rate >= 0.95) &&
    isTRUE(is.finite(summary_min_converged) && summary_min_converged >= 0.95)

  data.frame(
    GPCMScoreSideSimulationStatus = status,
    SimulationGateOK = gate_ok,
    Replications = reps,
    Conditions = conditions,
    SummaryRows = summary_rows,
    FailedChecks = failed,
    ErroredReplications = errored,
    MaxSERatioDiff = max_se_ratio_diff,
    MinConvergedRate = min_converged_rate,
    Detail = paste0(
      "summary_schema_ok=", summary_schema_ok,
      "; checks_schema_ok=", checks_schema_ok,
      "; checks_pass=", checks_pass,
      "; summary_rows_match=", summary_rows_match,
      "; expected_summary_rows=", expected_summary_rows,
      "; summary_max_ratio_diff=", summary_max_ratio_diff,
      "; summary_min_converged=", summary_min_converged
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_gpcm_score_side_external_status <- function(paths) {
  helper <- paths$gpcm_score_side_external_helper %||% NA_character_
  evidence <- paths$gpcm_score_side_external_evidence %||% NA_character_
  results_csv <- paths$gpcm_score_side_external_results %||% NA_character_
  checks_csv <- paths$gpcm_score_side_external_checks %||% NA_character_
  missing <- character(0)
  path_ok <- function(path) {
    is.character(path) && length(path) > 0L && file.exists(path[1])
  }
  if (!path_ok(helper)) {
    missing <- c(missing, "helper")
  }
  if (!path_ok(evidence)) {
    missing <- c(missing, "evidence")
  }
  if (!path_ok(results_csv)) {
    missing <- c(missing, "results")
  }
  if (!path_ok(checks_csv)) {
    missing <- c(missing, "checks")
  }
  if (length(missing) > 0L) {
    return(data.frame(
      GPCMScoreSideExternalComparisonStatus = "missing",
      ExternalComparisonGateOK = FALSE,
      ExternalComparisonRows = NA_integer_,
      FailedChecks = NA_integer_,
      PackagesCovered = NA_character_,
      HasMirt = FALSE,
      HasTAM = FALSE,
      ERmBoundaryOK = FALSE,
      MaxProbabilityTraceDiff = NA_real_,
      Detail = paste("GPCM score-side external comparison",
                     paste(missing, collapse = "+"), "missing"),
      stringsAsFactors = FALSE
    ))
  }

  lines <- readLines(evidence[1], warn = FALSE)
  evidence_text <- paste(lines, collapse = "\n")
  extract_scalar <- function(pattern, default = NA_character_) {
    hit <- grep(pattern, lines, value = TRUE)
    if (length(hit) == 0L) {
      return(default)
    }
    sub(pattern, "\\1", hit[1])
  }
  status <- extract_scalar(".*GPCMScoreSideExternalComparisonStatus = \"([^\"]+)\".*")
  rows <- suppressWarnings(as.integer(
    extract_scalar(".*ExternalComparisonRows = ([0-9]+).*", NA_character_)
  ))
  failed <- suppressWarnings(as.integer(
    extract_scalar(".*FailedChecks = ([0-9]+).*", NA_character_)
  ))
  results <- tryCatch(
    utils::read.csv(results_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  checks <- tryCatch(
    utils::read.csv(checks_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  results_schema_ok <- !is.null(results) &&
    all(c("Package", "Item", "Comparison", "MaxAbsDiff", "Threshold",
          "Passed", "Detail") %in% names(results))
  checks_schema_ok <- !is.null(checks) &&
    all(c("Check", "Value", "Threshold", "Passed", "Detail") %in% names(checks))
  passed_values <- function(x) {
    if (is.logical(x)) {
      x
    } else {
      tolower(as.character(x)) %in% c("true", "t", "1", "yes")
    }
  }
  if (results_schema_ok) {
    result_passed <- passed_values(results$Passed)
    results_pass <- all(result_passed, na.rm = FALSE)
    results_rows_match <- identical(nrow(results), rows)
    packages <- sort(unique(as.character(results$Package)))
    has_mirt <- "mirt" %in% packages
    has_tam <- "TAM" %in% packages
    expected_mirt <- expand.grid(
      Package = "mirt",
      Item = paste0("I", 1:4),
      Comparison = c(
        "probtrace_vs_local_kernel",
        "expected_score_vs_local_kernel",
        "variance_vs_local_kernel",
        "derivative_identity_local"
      ),
      stringsAsFactors = FALSE
    )
    expected_tam <- expand.grid(
      Package = "TAM",
      Item = paste0("I", 1:4),
      Comparison = c(
        "rprobs_vs_local_kernel",
        "expected_score_vs_local_kernel",
        "variance_vs_local_kernel",
        "derivative_identity_local"
      ),
      stringsAsFactors = FALSE
    )
    expected_grid <- rbind(expected_mirt, expected_tam)
    result_keys <- paste(results$Package, results$Item, results$Comparison,
                         sep = "\r")
    expected_keys <- paste(expected_grid$Package, expected_grid$Item,
                           expected_grid$Comparison, sep = "\r")
    expected_grid_ok <- identical(sort(result_keys), sort(expected_keys))
    trace_rows <- grepl("probtrace|rprobs", results$Comparison)
    max_probability_diff <- suppressWarnings(max(
      as.numeric(results$MaxAbsDiff[trace_rows]),
      na.rm = TRUE
    ))
    if (!is.finite(max_probability_diff)) {
      max_probability_diff <- NA_real_
    }
  } else {
    results_pass <- FALSE
    results_rows_match <- FALSE
    packages <- character(0)
    has_mirt <- FALSE
    has_tam <- FALSE
    expected_grid_ok <- FALSE
    max_probability_diff <- NA_real_
  }
  if (checks_schema_ok) {
    checks_passed <- passed_values(checks$Passed)
    checks_pass <- all(checks_passed, na.rm = FALSE)
    erm_boundary_ok <- any(
      checks$Check == "eRm_pcm_boundary_available" & checks_passed
    )
  } else {
    checks_pass <- FALSE
    erm_boundary_ok <- FALSE
  }
  evidence_mapping_ok <- grepl("mirt::probtrace()", evidence_text, fixed = TRUE) &&
    grepl("does not claim full many-facet parameter", evidence_text, fixed = TRUE) &&
    grepl("not treated as many-facet MFRM comparators",
          evidence_text, fixed = TRUE) &&
    grepl("tau_k = b_k", evidence_text, fixed = TRUE) &&
    grepl("tam.mml.2pl", evidence_text, fixed = TRUE) &&
    grepl("tau_k = beta + tau.Cat_k", evidence_text, fixed = TRUE) &&
    grepl("eRm", evidence_text, fixed = TRUE) &&
    grepl("not treated as a free-slope GPCM score-side comparator",
          evidence_text, fixed = TRUE) &&
    grepl("does not validate FACETS", evidence_text, fixed = TRUE)
  gate_ok <- identical(status, "ok") &&
    identical(failed, 0L) &&
    isTRUE(rows >= 16L) &&
    isTRUE(results_schema_ok) &&
    isTRUE(checks_schema_ok) &&
    isTRUE(results_rows_match) &&
    isTRUE(expected_grid_ok) &&
    isTRUE(results_pass) &&
    isTRUE(checks_pass) &&
    isTRUE(has_mirt) &&
    isTRUE(has_tam) &&
    isTRUE(erm_boundary_ok) &&
    isTRUE(evidence_mapping_ok) &&
    isTRUE(is.finite(max_probability_diff) && max_probability_diff <= 5e-4)

  data.frame(
    GPCMScoreSideExternalComparisonStatus = status,
    ExternalComparisonGateOK = gate_ok,
    ExternalComparisonRows = rows,
    FailedChecks = failed,
    PackagesCovered = paste(packages, collapse = ";"),
    ResultsRowsMatch = results_rows_match,
    ExpectedGridOK = expected_grid_ok,
    HasMirt = has_mirt,
    HasTAM = has_tam,
    ERmBoundaryOK = erm_boundary_ok,
    MaxProbabilityTraceDiff = max_probability_diff,
    Detail = paste0(
      "results_schema_ok=", results_schema_ok,
      "; checks_schema_ok=", checks_schema_ok,
      "; results_rows_match=", results_rows_match,
      "; expected_grid_ok=", expected_grid_ok,
      "; results_pass=", results_pass,
      "; checks_pass=", checks_pass,
      "; evidence_mapping_ok=", evidence_mapping_ok
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_release_scope_status <- function(paths) {
  helper <- paths$release_scope_helper %||% NA_character_
  evidence <- paths$release_scope_evidence %||% NA_character_
  checks_csv <- paths$release_scope_checks %||% NA_character_
  path_ok <- function(path) {
    is.character(path) && length(path) > 0L && file.exists(path[1])
  }
  missing <- character(0)
  if (!path_ok(helper)) {
    missing <- c(missing, "helper")
  }
  if (!path_ok(evidence)) {
    missing <- c(missing, "evidence")
  }
  if (!path_ok(checks_csv)) {
    missing <- c(missing, "checks")
  }
  if (length(missing) > 0L) {
    return(data.frame(
      ReleaseScopeReviewStatus = "missing",
      ScopeGateOK = FALSE,
      Checks = NA_integer_,
      FailedChecks = NA_integer_,
      LiveStatus = NA_character_,
      Detail = paste("release-scope review",
                     paste(missing, collapse = "+"), "missing"),
      stringsAsFactors = FALSE
    ))
  }

  env <- new.env(parent = globalenv())
  source(helper[1], local = env)
  if (!exists("mfrmr_review_release_scope",
              envir = env, inherits = FALSE)) {
    return(data.frame(
      ReleaseScopeReviewStatus = "error",
      ScopeGateOK = FALSE,
      Checks = NA_integer_,
      FailedChecks = NA_integer_,
      LiveStatus = NA_character_,
      Detail = "helper did not define mfrmr_review_release_scope()",
      stringsAsFactors = FALSE
    ))
  }

  review <- tryCatch(
    env$mfrmr_review_release_scope(pkg_dir = paths$pkg_dir),
    error = function(e) e
  )
  if (inherits(review, "error")) {
    return(data.frame(
      ReleaseScopeReviewStatus = "error",
      ScopeGateOK = FALSE,
      Checks = NA_integer_,
      FailedChecks = NA_integer_,
      LiveStatus = "error",
      Detail = conditionMessage(review),
      stringsAsFactors = FALSE
    ))
  }

  lines <- readLines(evidence[1], warn = FALSE)
  extract_scalar <- function(pattern, default = NA_character_) {
    hit <- grep(pattern, lines, value = TRUE)
    if (length(hit) == 0L) {
      return(default)
    }
    sub(pattern, "\\1", hit[1])
  }
  status <- extract_scalar(".*ReleaseScopeReviewStatus = \"([^\"]+)\".*")
  checks_n <- suppressWarnings(as.integer(
    extract_scalar(".*`Checks = ([0-9]+)`.*", NA_character_)
  ))
  failed <- suppressWarnings(as.integer(
    extract_scalar(".*`FailedChecks = ([0-9]+)`.*", NA_character_)
  ))
  checks <- tryCatch(
    utils::read.csv(checks_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  checks_schema_ok <- !is.null(checks) &&
    all(c("Area", "Check", "Passed", "Detail") %in% names(checks))
  checks_pass <- if (checks_schema_ok) {
    passed <- if (is.logical(checks$Passed)) {
      checks$Passed
    } else {
      tolower(as.character(checks$Passed)) %in% c("true", "t", "1", "yes")
    }
    all(passed, na.rm = FALSE)
  } else {
    FALSE
  }
  live_status <- as.character(review$status %||% "unknown")[1]
  live_failed <- as.integer(review$failed_checks %||% NA_integer_)[1]
  live_checks <- nrow(as.data.frame(review$checks %||% data.frame()))
  gate_ok <- identical(status, "ok") &&
    identical(failed, 0L) &&
    identical(live_status, "ok") &&
    identical(live_failed, 0L) &&
    isTRUE(checks_schema_ok) &&
    isTRUE(checks_pass) &&
    identical(nrow(checks), checks_n) &&
    identical(live_checks, checks_n)

  data.frame(
    ReleaseScopeReviewStatus = status,
    ScopeGateOK = gate_ok,
    Checks = checks_n,
    FailedChecks = failed,
    LiveStatus = live_status,
    Detail = paste0(
      "checks_schema_ok=", checks_schema_ok,
      "; checks_pass=", checks_pass,
      "; live_checks=", live_checks,
      "; live_failed=", live_failed
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_passed_values <- function(x) {
  if (is.logical(x)) {
    x
  } else {
    tolower(as.character(x)) %in% c("true", "t", "1", "yes")
  }
}

mfrmr_release_readiness_network_anchor_stress_status <- function(paths) {
  helper <- paths$network_anchor_stress_helper %||% NA_character_
  evidence <- paths$network_anchor_stress_evidence %||% NA_character_
  summary_csv <- paths$network_anchor_stress_summary %||% NA_character_
  checks_csv <- paths$network_anchor_stress_checks %||% NA_character_
  rater_modes_csv <- paths$network_anchor_stress_rater_modes %||% NA_character_
  path_ok <- function(path) {
    is.character(path) && length(path) > 0L && file.exists(path[1])
  }
  missing <- character(0)
  if (!path_ok(helper)) missing <- c(missing, "helper")
  if (!path_ok(evidence)) missing <- c(missing, "evidence")
  if (!path_ok(summary_csv)) missing <- c(missing, "summary")
  if (!path_ok(checks_csv)) missing <- c(missing, "checks")
  if (!path_ok(rater_modes_csv)) missing <- c(missing, "rater_modes")
  if (length(missing) > 0L) {
    return(data.frame(
      NetworkAnchorStressStatus = "missing",
      StressGateOK = FALSE,
      Scenarios = NA_integer_,
      Checks = NA_integer_,
      FailedChecks = NA_integer_,
      RaterModeRows = NA_integer_,
      ModesCovered = NA_character_,
      Detail = paste("network-anchor stress", paste(missing, collapse = "+"),
                     "missing"),
      stringsAsFactors = FALSE
    ))
  }

  summary <- tryCatch(
    utils::read.csv(summary_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  checks <- tryCatch(
    utils::read.csv(checks_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  rater_modes <- tryCatch(
    utils::read.csv(rater_modes_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  summary_schema_ok <- !is.null(summary) &&
    all(c("Scenario", "FullComponents", "ProjectedComponents",
          "AssumptionCheckRows", "VisualizationRows",
          "ReportTemplateRows", "ReviewNetworkPlotAvailable",
          "NetworkLayoutRows", "NetworkNodePlotRows", "NetworkEdgePlotRows",
          "NetworkLayoutFinite", "NetworkNodePlotFinite",
          "NetworkEdgePlotFinite") %in% names(summary))
  checks_schema_ok <- !is.null(checks) &&
    all(c("Scenario", "Check", "Passed", "Detail") %in% names(checks))
  modes_schema_ok <- !is.null(rater_modes) &&
    all(c("Scenario", "Mode", "PairRows", "ZeroOverlapPairs",
          "Edges", "Components", "AssumptionCheckRows",
          "VisualizationRows", "ReportTemplateRows", "AvoidRows",
          "VisualizationRoutes", "TemplateIds") %in% names(rater_modes))

  passed <- if (checks_schema_ok) {
    mfrmr_release_readiness_passed_values(checks$Passed)
  } else {
    FALSE
  }
  failed <- if (checks_schema_ok) {
    sum(!passed, na.rm = TRUE)
  } else {
    NA_integer_
  }
  required_checks <- c(
    "projected_graph_disconnected",
    "projected_connected_with_self_leaves",
    "all_modes_empty_edges",
    "all_modes_zero_overlap_only",
    "full_graph_masks_panel_gap",
    "role_projection_masks_rater_only_question",
    "collapsed_self_assessor_more_lenient",
    "network_plot_payload_available",
    "rater_mode_downstream_tables_available",
    "coverage_zero_disconnected_after_projection",
    "coverage_one_rotating_panel_disconnected",
    "coverage_common_or_full_connected_after_projection",
    "group_anchor_recommendation_present"
  )
  required_scenarios <- c(
    "self_only_zero_overlap",
    "mixed_literal_self_plus_teachers_seed1",
    "self_teacher_role_rater_only_projection",
    "self_teacher_role_rater_projection",
    "speaking_peer_literal_student_ids",
    "speaking_peer_collapsed_self_assessor",
    "speaking_role_only_modes",
    "two_panel_gap_full_graph_masked",
    "coverage_T0",
    "coverage_T1_rotating_panel",
    "coverage_T1_common_teacher",
    "coverage_T4",
    "group_anchor_only_low_common"
  )
  checks_present <- checks_schema_ok &&
    all(required_checks %in% as.character(checks$Check))
  scenarios_present <- summary_schema_ok &&
    all(required_scenarios %in% as.character(summary$Scenario))
  modes_covered <- if (modes_schema_ok) {
    sort(unique(as.character(rater_modes$Mode)))
  } else {
    character(0)
  }
  modes_ok <- all(c("agreement", "disagreement", "severity_direction") %in%
                    modes_covered)
  evidence_text <- paste(readLines(evidence[1], warn = FALSE), collapse = "\n")
  evidence_ok <- grepl("- Failed checks: 0", evidence_text, fixed = TRUE) &&
    grepl("projected graph", evidence_text, ignore.case = TRUE) &&
    grepl("group-anchor", evidence_text, fixed = TRUE) &&
    grepl("Each rater-network mode is checked", evidence_text, fixed = TRUE)
  downstream_ok <- summary_schema_ok &&
    any(summary$AssumptionCheckRows >= 10L &
          summary$VisualizationRows >= 5L &
          summary$ReportTemplateRows >= 5L, na.rm = TRUE)
  rater_downstream_ok <- modes_schema_ok &&
    nrow(rater_modes) > 0L &&
    isTRUE(all(rater_modes$AssumptionCheckRows >= 6L, na.rm = FALSE)) &&
    isTRUE(all(rater_modes$VisualizationRows >= 5L, na.rm = FALSE)) &&
    isTRUE(all(rater_modes$ReportTemplateRows >= 5L, na.rm = FALSE)) &&
    isTRUE(all(rater_modes$AvoidRows >= 5L, na.rm = FALSE))
  active_rows <- if (summary_schema_ok) {
    as.character(summary$Scenario) != "group_anchor_only_low_common"
  } else {
    logical(0)
  }
  plot_payload_ok <- summary_schema_ok &&
    any(active_rows) &&
    isTRUE(all(mfrmr_release_readiness_passed_values(
      summary$ReviewNetworkPlotAvailable[active_rows]
    ))) &&
    isTRUE(all(summary$NetworkLayoutRows[active_rows] > 0L)) &&
    isTRUE(all(summary$NetworkNodePlotRows[active_rows] > 0L)) &&
    isTRUE(all(summary$NetworkEdgePlotRows[active_rows] > 0L)) &&
    isTRUE(all(mfrmr_release_readiness_passed_values(
      summary$NetworkLayoutFinite[active_rows]
    ))) &&
    isTRUE(all(mfrmr_release_readiness_passed_values(
      summary$NetworkNodePlotFinite[active_rows]
    ))) &&
    isTRUE(all(mfrmr_release_readiness_passed_values(
      summary$NetworkEdgePlotFinite[active_rows]
    )))
  zero_overlap_ok <- modes_schema_ok &&
    all(rater_modes$ZeroOverlapPairs[
      rater_modes$Scenario == "self_only_zero_overlap"
    ] > 0, na.rm = TRUE)
  zero_overlap_downstream_ok <- modes_schema_ok &&
    any(rater_modes$Scenario == "self_only_zero_overlap") &&
    isTRUE(all(rater_modes$Edges[
      rater_modes$Scenario == "self_only_zero_overlap"
    ] == 0L, na.rm = FALSE)) &&
    isTRUE(all(rater_modes$AssumptionCheckRows[
      rater_modes$Scenario == "self_only_zero_overlap"
    ] >= 6L, na.rm = FALSE)) &&
    isTRUE(all(rater_modes$VisualizationRows[
      rater_modes$Scenario == "self_only_zero_overlap"
    ] >= 5L, na.rm = FALSE)) &&
    isTRUE(all(rater_modes$ReportTemplateRows[
      rater_modes$Scenario == "self_only_zero_overlap"
    ] >= 5L, na.rm = FALSE)) &&
    isTRUE(all(rater_modes$AvoidRows[
      rater_modes$Scenario == "self_only_zero_overlap"
    ] >= 5L, na.rm = FALSE))
  gate_ok <- summary_schema_ok &&
    checks_schema_ok &&
    modes_schema_ok &&
    identical(failed, 0L) &&
    checks_present &&
    scenarios_present &&
    modes_ok &&
    evidence_ok &&
    downstream_ok &&
    rater_downstream_ok &&
    plot_payload_ok &&
    zero_overlap_ok &&
    zero_overlap_downstream_ok

  data.frame(
    NetworkAnchorStressStatus = if (gate_ok) "ok" else "review",
    StressGateOK = gate_ok,
    Scenarios = if (summary_schema_ok) length(unique(summary$Scenario)) else NA_integer_,
    Checks = if (checks_schema_ok) nrow(checks) else NA_integer_,
    FailedChecks = failed,
    RaterModeRows = if (modes_schema_ok) nrow(rater_modes) else NA_integer_,
    ModesCovered = paste(modes_covered, collapse = ";"),
    Detail = paste0(
      "summary_schema_ok=", summary_schema_ok,
      "; checks_schema_ok=", checks_schema_ok,
      "; modes_schema_ok=", modes_schema_ok,
      "; checks_present=", checks_present,
      "; scenarios_present=", scenarios_present,
      "; modes_ok=", modes_ok,
      "; evidence_ok=", evidence_ok,
      "; downstream_ok=", downstream_ok,
      "; rater_downstream_ok=", rater_downstream_ok,
      "; plot_payload_ok=", plot_payload_ok,
      "; zero_overlap_ok=", zero_overlap_ok,
      "; zero_overlap_downstream_ok=", zero_overlap_downstream_ok
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_self_other_speaking_network_status <- function(paths) {
  helper <- paths$self_other_speaking_network_helper %||% NA_character_
  evidence <- paths$self_other_speaking_network_evidence %||% NA_character_
  summary_csv <- paths$self_other_speaking_network_summary %||% NA_character_
  checks_csv <- paths$self_other_speaking_network_checks %||% NA_character_
  templates_csv <- paths$self_other_speaking_network_templates %||% NA_character_
  path_ok <- function(path) {
    is.character(path) && length(path) > 0L && file.exists(path[1])
  }
  missing <- character(0)
  if (!path_ok(helper)) missing <- c(missing, "helper")
  if (!path_ok(evidence)) missing <- c(missing, "evidence")
  if (!path_ok(summary_csv)) missing <- c(missing, "summary")
  if (!path_ok(checks_csv)) missing <- c(missing, "checks")
  if (!path_ok(templates_csv)) missing <- c(missing, "templates")
  if (length(missing) > 0L) {
    return(data.frame(
      SelfOtherSpeakingNetworkStatus = "missing",
      NetworkGateOK = FALSE,
      Checks = NA_integer_,
      FailedChecks = NA_integer_,
      TemplateRows = NA_integer_,
      Detail = paste("self/other speaking network",
                     paste(missing, collapse = "+"), "missing"),
      stringsAsFactors = FALSE
    ))
  }

  summary <- tryCatch(
    utils::read.csv(summary_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  checks <- tryCatch(
    utils::read.csv(checks_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  templates <- tryCatch(
    utils::read.csv(templates_csv[1], stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  summary_schema_ok <- !is.null(summary) &&
    all(c("Scenario", "Persons", "TeacherRaters", "FullComponents",
          "FullArticulationPoints", "FullBridges",
          "RaterProjectedArticulationPoints", "RaterProjectedBridges",
          "SelfRaterNodes", "SelfRaterDegreeMin", "SelfRaterDegreeMax",
          "AssessorNetworkEdges", "SelfModeSeverityIndex",
          "AssumptionCheckRows",
          "ReviewNetworkPlotAvailable", "ReviewNetworkLayoutRows",
          "ReviewNetworkNodePlotRows", "ReviewNetworkEdgePlotRows",
          "ReviewNetworkPlotFinite", "AssessorNetworkPlotAvailable",
          "AssessorNetworkLayoutRows", "AssessorNetworkNodePlotRows",
          "AssessorNetworkEdgePlotRows",
          "AssessorNetworkPlotFinite") %in% names(summary))
  checks_schema_ok <- !is.null(checks) &&
    all(c("Check", "Passed", "Detail") %in% names(checks))
  templates_schema_ok <- !is.null(templates) &&
    all(c("TemplateId", "APASection", "Text", "Avoid",
          "ExampleScope") %in% names(templates))
  passed <- if (checks_schema_ok) {
    mfrmr_release_readiness_passed_values(checks$Passed)
  } else {
    FALSE
  }
  failed <- if (checks_schema_ok) {
    sum(!passed, na.rm = TRUE)
  } else {
    NA_integer_
  }
  required_checks <- c(
    "literal_fit_converged",
    "full_graph_connected_but_hub_masked",
    "rater_projection_recovers_self_leaves",
    "review_downstream_tables_available",
    "design_network_plot_payload_available",
    "assessor_type_fit_converged",
    "assessor_type_mode_graph_is_not_literal_identity_graph",
    "collapsed_assessor_network_detects_self_mode_leniency",
    "assessor_network_plot_payload_available"
  )
  checks_present <- checks_schema_ok &&
    all(required_checks %in% as.character(checks$Check))
  summary_values_ok <- summary_schema_ok &&
    identical(as.character(summary$Scenario[1]), "self_teacher_speaking") &&
    isTRUE(summary$FullComponents[1] == 1L) &&
    isTRUE(summary$FullArticulationPoints[1] == 0L) &&
    isTRUE(summary$FullBridges[1] == 0L) &&
    isTRUE(summary$RaterProjectedArticulationPoints[1] >= summary$Persons[1]) &&
    isTRUE(summary$RaterProjectedBridges[1] >= summary$Persons[1]) &&
    isTRUE(summary$SelfRaterNodes[1] == summary$Persons[1]) &&
    isTRUE(summary$SelfRaterDegreeMin[1] == 1L) &&
    isTRUE(summary$SelfRaterDegreeMax[1] == 1L) &&
    isTRUE(summary$AssessorNetworkEdges[1] > 0L) &&
    isTRUE(is.finite(summary$SelfModeSeverityIndex[1])) &&
    isTRUE(summary$AssumptionCheckRows[1] >= 10L)
  template_values_ok <- templates_schema_ok &&
    isTRUE(nrow(templates) >= 5L) &&
    all(nzchar(as.character(templates$Avoid)))
  plot_payload_ok <- summary_schema_ok &&
    isTRUE(mfrmr_release_readiness_passed_values(summary$ReviewNetworkPlotAvailable[1])) &&
    isTRUE(summary$ReviewNetworkLayoutRows[1] > 0L) &&
    isTRUE(summary$ReviewNetworkNodePlotRows[1] > 0L) &&
    isTRUE(summary$ReviewNetworkEdgePlotRows[1] > 0L) &&
    isTRUE(mfrmr_release_readiness_passed_values(summary$ReviewNetworkPlotFinite[1])) &&
    isTRUE(mfrmr_release_readiness_passed_values(summary$AssessorNetworkPlotAvailable[1])) &&
    isTRUE(summary$AssessorNetworkLayoutRows[1] > 0L) &&
    isTRUE(summary$AssessorNetworkNodePlotRows[1] > 0L) &&
    isTRUE(summary$AssessorNetworkEdgePlotRows[1] > 0L) &&
    isTRUE(mfrmr_release_readiness_passed_values(summary$AssessorNetworkPlotFinite[1]))
  evidence_text <- paste(readLines(evidence[1], warn = FALSE), collapse = "\n")
  evidence_ok <- grepl("- Status: ok", evidence_text, fixed = TRUE) &&
    grepl("- Failed checks: 0", evidence_text, fixed = TRUE) &&
    grepl("Person-plus-Rater projection", evidence_text, fixed = TRUE) &&
    grepl("AssessorType", evidence_text, fixed = TRUE)
  gate_ok <- summary_schema_ok &&
    checks_schema_ok &&
    templates_schema_ok &&
    identical(failed, 0L) &&
    checks_present &&
    summary_values_ok &&
    template_values_ok &&
    plot_payload_ok &&
    evidence_ok

  data.frame(
    SelfOtherSpeakingNetworkStatus = if (gate_ok) "ok" else "review",
    NetworkGateOK = gate_ok,
    Checks = if (checks_schema_ok) nrow(checks) else NA_integer_,
    FailedChecks = failed,
    TemplateRows = if (templates_schema_ok) nrow(templates) else NA_integer_,
    Detail = paste0(
      "summary_schema_ok=", summary_schema_ok,
      "; checks_schema_ok=", checks_schema_ok,
      "; templates_schema_ok=", templates_schema_ok,
      "; checks_present=", checks_present,
      "; summary_values_ok=", summary_values_ok,
      "; template_values_ok=", template_values_ok,
      "; plot_payload_ok=", plot_payload_ok,
      "; evidence_ok=", evidence_ok
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_review <- function(pkg_dir = ".",
                                           check_log = NULL,
                                           checklist = NULL,
                                           target_version = NULL,
                                           external_recovery_dir = NULL) {
  paths <- mfrmr_release_readiness_paths(pkg_dir, target_version = target_version)
  target_version <- target_version %||% paths$target_version
  if (!is.null(check_log)) {
    paths$check_log <- check_log
  } else {
    paths$check_log <- mfrmr_release_readiness_find_check_log(
      paths$pkg_dir,
      target_version = target_version
    )
  }
  if (!is.null(checklist)) {
    paths$evidence_checklist <- checklist
  }
  version_status <- mfrmr_release_readiness_version_status(paths, target_version = target_version)
  check_status <- mfrmr_release_readiness_parse_check_log(
    paths$check_log,
    target_version = target_version,
    pkg_dir = paths$pkg_dir
  )
  term_status <- mfrmr_release_readiness_term_status(paths$pkg_dir)
  checklist_status <- mfrmr_release_readiness_checklist_status(paths$evidence_checklist)
  ci_workflow_status <- mfrmr_release_readiness_ci_workflow_status(paths$ci_workflow)
  gpcm_scope_status <- mfrmr_release_readiness_gpcm_scope_status(
    paths = paths,
    checklist_status = checklist_status
  )
  mh_dif_comparison_status <- mfrmr_release_readiness_mh_dif_comparison_status(
    paths = paths
  )
  dif_apa_reporting_status <- mfrmr_release_readiness_dif_apa_reporting_status(
    paths = paths
  )
  dif_dff_simulation_status <- mfrmr_release_readiness_dif_dff_simulation_status(
    paths = paths
  )
  convergence_reporting_status <- mfrmr_release_readiness_convergence_reporting_status(
    paths = paths
  )
  gpcm_score_side_status <- mfrmr_release_readiness_gpcm_score_side_status(
    paths = paths
  )
  gpcm_score_side_external_status <- mfrmr_release_readiness_gpcm_score_side_external_status(
    paths = paths
  )
  release_scope_status <- mfrmr_release_readiness_release_scope_status(
    paths = paths
  )
  network_anchor_stress_status <- mfrmr_release_readiness_network_anchor_stress_status(
    paths = paths
  )
  self_other_speaking_network_status <- mfrmr_release_readiness_self_other_speaking_network_status(
    paths = paths
  )
  example_policy_status <- mfrmr_release_readiness_example_policy_status(paths)
  gate_summary <- mfrmr_release_readiness_gate_summary(
    version_status = version_status,
    check_status = check_status,
    term_status = term_status,
    checklist_status = checklist_status,
    ci_workflow_status = ci_workflow_status,
    paths = paths,
    gpcm_scope_status = gpcm_scope_status,
    mh_dif_comparison_status = mh_dif_comparison_status,
    dif_apa_reporting_status = dif_apa_reporting_status,
    dif_dff_simulation_status = dif_dff_simulation_status,
    convergence_reporting_status = convergence_reporting_status,
    gpcm_score_side_status = gpcm_score_side_status,
    gpcm_score_side_external_status = gpcm_score_side_external_status,
    release_scope_status = release_scope_status,
    network_anchor_stress_status = network_anchor_stress_status,
    self_other_speaking_network_status = self_other_speaking_network_status,
    example_policy_status = example_policy_status
  )
  external_recovery_status <- mfrmr_release_readiness_external_recovery_status(
    paths = paths,
    external_recovery_dir = external_recovery_dir
  )
  out <- list(
    prompt_steps = mfrmr_release_readiness_prompt_steps(target_version = target_version),
    gate_summary = gate_summary,
    release_decision = data.frame(
      ReleaseReadinessStatus = mfrmr_release_readiness_decision(gate_summary),
      Explanation = paste(gate_summary$Gate, gate_summary$Status, sep = "=", collapse = "; "),
      stringsAsFactors = FALSE
    ),
    version_status = version_status,
    check_status = check_status,
    ci_workflow_status = ci_workflow_status,
    terminology_status = term_status,
    checklist_status = checklist_status,
    gpcm_scope_status = gpcm_scope_status,
    mh_dif_comparison_status = mh_dif_comparison_status,
    dif_apa_reporting_status = dif_apa_reporting_status,
    dif_dff_simulation_status = dif_dff_simulation_status,
    convergence_reporting_status = convergence_reporting_status,
    gpcm_score_side_status = gpcm_score_side_status,
    gpcm_score_side_external_status = gpcm_score_side_external_status,
    release_scope_status = release_scope_status,
    network_anchor_stress_status = network_anchor_stress_status,
    self_other_speaking_network_status = self_other_speaking_network_status,
    example_policy_status = example_policy_status,
    external_recovery_status = external_recovery_status,
    paths = paths
  )
  class(out) <- "mfrmr_release_readiness_review"
  out
}

summary.mfrmr_release_readiness_review <- function(object, ...) {
  if (!inherits(object, "mfrmr_release_readiness_review")) {
    stop("`object` must be output from mfrmr_release_readiness_review().", call. = FALSE)
  }
  out <- list(
    release_decision = object$release_decision,
    gate_summary = object$gate_summary,
    prompt_steps = object$prompt_steps,
    check_status = object$check_status,
    ci_workflow_status = object$ci_workflow_status,
    gpcm_scope_status = object$gpcm_scope_status,
    mh_dif_comparison_status = object$mh_dif_comparison_status,
    dif_apa_reporting_status = object$dif_apa_reporting_status,
    dif_dff_simulation_status = object$dif_dff_simulation_status,
    convergence_reporting_status = object$convergence_reporting_status,
    gpcm_score_side_status = object$gpcm_score_side_status,
    gpcm_score_side_external_status = object$gpcm_score_side_external_status,
    release_scope_status = object$release_scope_status,
    network_anchor_stress_status = object$network_anchor_stress_status,
    self_other_speaking_network_status = object$self_other_speaking_network_status,
    external_recovery_status = object$external_recovery_status
  )
  class(out) <- "summary.mfrmr_release_readiness_review"
  out
}

print.mfrmr_release_readiness_review <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

print.summary.mfrmr_release_readiness_review <- function(x, ...) {
  cat("mfrmr release-readiness review\n\n")
  print(x$release_decision, row.names = FALSE)
  cat("\nGate summary:\n")
  print(x$gate_summary, row.names = FALSE)
  cat("\nReview steps:\n")
  print(x$prompt_steps[, c("Step", "Label", "Gate")], row.names = FALSE)
  if (!is.null(x$gpcm_scope_status)) {
    cat("\nGPCM scope status:\n")
    print(x$gpcm_scope_status, row.names = FALSE)
  }
  if (!is.null(x$dif_dff_simulation_status)) {
    cat("\nDIF/DFF simulation matrix status:\n")
    print(x$dif_dff_simulation_status, row.names = FALSE)
  }
  if (!is.null(x$convergence_reporting_status)) {
    cat("\nConvergence-reporting stress status:\n")
    print(x$convergence_reporting_status, row.names = FALSE)
  }
  if (!is.null(x$network_anchor_stress_status)) {
    cat("\nNetwork/anchor stress status:\n")
    print(x$network_anchor_stress_status, row.names = FALSE)
  }
  if (!is.null(x$self_other_speaking_network_status)) {
    cat("\nSelf/other speaking network status:\n")
    print(x$self_other_speaking_network_status, row.names = FALSE)
  }
  if (isTRUE(x$external_recovery_status$ExternalRecoveryRequested[1])) {
    cat("\nExternal recovery status:\n")
    print(x$external_recovery_status, row.names = FALSE)
  }
  invisible(x)
}
