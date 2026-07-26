# mfrmr release-readiness protocol
#
# Source this file in a development or release-check session:
#
#   source("inst/validation/release-readiness.R")
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
        "Do DESCRIPTION, NEWS, generated help, the source tarball, and the ",
        "selected check log all describe ", target_label, " rather than a ",
        "development snapshot or stale release artifact?"
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
      "DESCRIPTION/CITATION version and date; authoritative roadmap; first NEWS heading; tarball/check timestamps; check-log package version and --as-cran provenance; absence of development labels in current release files",
      "release-evidence-checklist blocker rows; targeted mathematical tests; recovery-validation summary",
      "gpcm_capability_matrix(); README; vignettes; NEWS deferred-work section; post-0.2.2 GPCM roadmap",
      "facets_positioning_guide(); facets_fit_review(); read_facets_fit_table(); output guide",
      "summary methods; plot(..., draw = FALSE); plot_data(); summary-table bundles",
      "README/vignettes/man/cheatsheet terminology scan",
      "mfrmr.Rcheck/00check.log or attached check log; GitHub Actions warning policy and check artifacts",
      "root ROADMAP.md; cran-comments.md; NEWS.md; release-evidence map; GPCM technical supplement; external parameter-recovery summary and local review helper"
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
    candidates <- c(candidates, file.path(validation_dir, paste0(prefix, target_version, ext)))
  }
  candidates <- c(
    candidates,
    file.path(validation_dir, paste0(prefix, fallback_version, ext))
  )
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
    cff = file.path(pkg_dir, "CITATION.cff"),
    roadmap = file.path(pkg_dir, "ROADMAP.md"),
    buildignore = file.path(pkg_dir, ".Rbuildignore"),
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
    gpcm_roadmap = mfrmr_release_readiness_versioned_file(
      validation_dir,
      prefix = "gpcm-post-",
      target_version = target_version,
      fallback_version = "0.2.2",
      ext = "-roadmap.md"
    ),
    gpcm_capability_source = file.path(pkg_dir, "R", "help_gpcm_scope.R"),
    external_recovery_evidence = mfrmr_release_readiness_versioned_file(
      validation_dir,
      prefix = "external-parameter-recovery-simulation-",
      target_version = target_version,
      ext = ".md"
    ),
    external_recovery_helper = file.path(validation_dir, "external-recovery-audit.R"),
    check_log = file.path(pkg_dir, "mfrmr.Rcheck", "00check.log"),
    tarball = file.path(pkg_dir, paste0("mfrmr_", target_version, ".tar.gz"))
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
  if (length(existing) > 0L &&
      mfrmr_release_readiness_has_value(target_version)) {
    versions <- vapply(existing, function(path) {
      mfrmr_release_readiness_check_log_package_version(
        mfrmr_release_readiness_read_lines(path)
      )
    }, character(1))
    matching <- existing[!is.na(versions) & versions == target_version[1]]
    if (length(matching) > 0L) {
      modified <- as.numeric(file.info(matching)$mtime)
      return(matching[which.max(modified)])
    }
  }
  if (length(existing) > 0L) {
    modified <- as.numeric(file.info(existing)$mtime)
    return(existing[which.max(modified)])
  }
  file.path(pkg_dir, "mfrmr.Rcheck", "00check.log")
}

mfrmr_release_readiness_find_tarball <- function(pkg_dir,
                                                 target_version = NULL) {
  expected <- paste0("mfrmr_", target_version, ".tar.gz")
  candidates <- c(
    file.path(pkg_dir, expected),
    if (dir.exists(pkg_dir)) {
      list.files(
        pkg_dir,
        pattern = "[.]tar[.]gz$",
        recursive = TRUE,
        full.names = TRUE
      )
    } else {
      character(0)
    }
  )
  candidates <- unique(candidates)
  matching <- candidates[
    file.exists(candidates) & basename(candidates) == expected
  ]
  if (length(matching) == 0L) {
    return(file.path(pkg_dir, expected))
  }
  modified <- as.numeric(file.info(matching)$mtime)
  matching[which.max(modified)]
}

mfrmr_release_readiness_read_lines <- function(path) {
  if (!file.exists(path)) {
    return(character(0))
  }
  readLines(path, warn = FALSE, encoding = "UTF-8")
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

mfrmr_release_readiness_check_timing <- function(lines) {
  timed <- grep(
    "^\\* checking .*\\[[0-9.]+s/[0-9.]+s\\]",
    lines,
    value = TRUE,
    perl = TRUE
  )
  elapsed_seconds <- function(x) {
    if (length(x) == 0L) return(NA_real_)
    as.numeric(sub(
      "^.*\\[[0-9.]+s/([0-9.]+)s\\].*$",
      "\\1",
      x[[1]],
      perl = TRUE
    ))
  }
  component <- function(pattern) {
    elapsed_seconds(grep(pattern, timed, value = TRUE, perl = TRUE))
  }
  elapsed <- vapply(timed, elapsed_seconds, numeric(1))
  timing_available <- length(timed) > 0L && all(is.finite(elapsed))
  estimated_seconds <- if (timing_available) sum(elapsed) else NA_real_
  data.frame(
    TimingAvailable = timing_available,
    ComponentElapsedSeconds = estimated_seconds,
    ExamplesSeconds = component("^\\* checking examples \\.\\.\\."),
    DonttestExamplesSeconds = component(
      "^\\* checking examples with --run-donttest"
    ),
    TestsSeconds = component("^\\* checking tests \\.\\.\\."),
    VignetteRebuildSeconds = component(
      "^\\* checking re-building of vignette outputs"
    ),
    UnderTenMinutes = if (timing_available) estimated_seconds <= 600 else NA,
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_check_timing_scope <- function(not_cran = Sys.getenv(
  "NOT_CRAN",
  unset = "false"
)) {
  if (identical(tolower(trimws(not_cran[1])), "true")) {
    "full_non_cran"
  } else {
    "cran"
  }
}

mfrmr_release_readiness_parse_check_log <- function(path,
                                                    target_version = NULL) {
  lines <- mfrmr_release_readiness_read_lines(path)
  if (length(lines) == 0L) {
    return(data.frame(
      CheckLog = path,
      PackageVersion = NA_character_,
      TargetVersion = target_version %||% NA_character_,
      VersionMatchesTarget = if (is.null(target_version)) NA else FALSE,
      StatusLine = NA_character_,
      StatusPresent = FALSE,
      AsCRAN = FALSE,
      RunDonttest = FALSE,
      ManualChecked = FALSE,
      Errors = NA_integer_,
      Warnings = NA_integer_,
      Notes = NA_integer_,
      TimingAvailable = FALSE,
      ComponentElapsedSeconds = NA_real_,
      ExamplesSeconds = NA_real_,
      DonttestExamplesSeconds = NA_real_,
      TestsSeconds = NA_real_,
      VignetteRebuildSeconds = NA_real_,
      UnderTenMinutes = NA,
      CheckPassed = FALSE,
      NeedsExplanation = TRUE,
      stringsAsFactors = FALSE
    ))
  }
  package_version <- mfrmr_release_readiness_check_log_package_version(lines)
  version_matches_target <- if (!mfrmr_release_readiness_has_value(target_version)) {
    NA
  } else {
    identical(package_version, target_version[1])
  }
  status_lines <- grep("^Status:", lines, value = TRUE)
  status_present <- length(status_lines) > 0L
  status <- if (status_present) tail(status_lines, 1L) else NA_character_
  errors <- if (status_present) {
    mfrmr_release_readiness_count_status(status, "ERROR")
  } else {
    NA_integer_
  }
  warnings <- if (status_present) {
    mfrmr_release_readiness_count_status(status, "WARNING")
  } else {
    NA_integer_
  }
  notes <- if (status_present) {
    mfrmr_release_readiness_count_status(status, "NOTE")
  } else {
    NA_integer_
  }
  if (isTRUE(status_present) && identical(status, "Status: OK")) {
    errors <- warnings <- notes <- 0L
  }
  timing <- mfrmr_release_readiness_check_timing(lines)
  out <- data.frame(
    CheckLog = path,
    PackageVersion = package_version,
    TargetVersion = target_version %||% NA_character_,
    VersionMatchesTarget = version_matches_target,
    StatusLine = status,
    StatusPresent = status_present,
    AsCRAN = any(grepl("--as-cran", lines, fixed = TRUE)),
    RunDonttest = any(grepl("--run-donttest", lines, fixed = TRUE)),
    ManualChecked = any(grepl(
      "* checking PDF version of manual",
      lines,
      fixed = TRUE
    )) && any(grepl(
      "* checking HTML version of manual",
      lines,
      fixed = TRUE
    )),
    Errors = errors,
    Warnings = warnings,
    Notes = notes,
    TimingAvailable = timing$TimingAvailable,
    ComponentElapsedSeconds = timing$ComponentElapsedSeconds,
    ExamplesSeconds = timing$ExamplesSeconds,
    DonttestExamplesSeconds = timing$DonttestExamplesSeconds,
    TestsSeconds = timing$TestsSeconds,
    VignetteRebuildSeconds = timing$VignetteRebuildSeconds,
    UnderTenMinutes = timing$UnderTenMinutes,
    CheckPassed = isTRUE(status_present) &&
      isTRUE(errors == 0L && warnings == 0L),
    NeedsExplanation = !isTRUE(status_present) || isTRUE(notes > 0L),
    stringsAsFactors = FALSE
  )
  out
}

mfrmr_release_readiness_buildignore_patterns <- function(pkg_dir) {
  path <- file.path(pkg_dir, ".Rbuildignore")
  if (!file.exists(path)) {
    return(character(0))
  }
  patterns <- trimws(mfrmr_release_readiness_read_lines(path))
  patterns[nzchar(patterns) & !startsWith(patterns, "#")]
}

mfrmr_release_readiness_relative_path <- function(path, pkg_dir) {
  pkg_dir <- normalizePath(pkg_dir, winslash = "/", mustWork = FALSE)
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  prefix <- paste0(pkg_dir, "/")
  ifelse(
    startsWith(path, prefix),
    substring(path, nchar(prefix) + 1L),
    basename(path)
  )
}

mfrmr_release_readiness_path_is_ignored <- function(path, patterns) {
  if (length(patterns) == 0L) {
    return(FALSE)
  }
  parts <- strsplit(path, "/", fixed = TRUE)[[1]]
  ancestors <- if (length(parts) > 1L) {
    vapply(seq_len(length(parts) - 1L), function(i) {
      paste(parts[seq_len(i)], collapse = "/")
    }, character(1))
  } else {
    character(0)
  }
  candidates <- c(path, ancestors)
  any(vapply(patterns, function(pattern) {
    tryCatch(
      any(grepl(pattern, candidates, perl = TRUE)),
      error = function(e) FALSE
    )
  }, logical(1)))
}

mfrmr_release_readiness_release_input_files <- function(pkg_dir) {
  pkg_dir <- normalizePath(pkg_dir, winslash = "/", mustWork = FALSE)
  if (!dir.exists(pkg_dir)) {
    return(character(0))
  }
  top_level <- list.files(
    pkg_dir,
    all.files = TRUE,
    no.. = TRUE,
    full.names = TRUE,
    recursive = FALSE
  )
  top_info <- file.info(top_level)
  top_level <- top_level[!is.na(top_info$isdir) & !top_info$isdir]
  package_dirs <- file.path(
    pkg_dir,
    c("R", "data", "demo", "exec", "inst", "man", "po", "src", "tests",
      "tools", "vignettes")
  )
  package_dirs <- package_dirs[dir.exists(package_dirs)]
  nested <- unlist(lapply(package_dirs, function(path) {
    list.files(
      path,
      all.files = TRUE,
      no.. = TRUE,
      full.names = TRUE,
      recursive = TRUE,
      include.dirs = FALSE
    )
  }), use.names = FALSE)
  files <- unique(c(top_level, nested))
  files <- files[file.exists(files) & !file.info(files)$isdir]
  relative <- mfrmr_release_readiness_relative_path(files, pkg_dir)

  # These are check evidence or incidental output, never source inputs.
  evidence_or_detritus <- grepl(
    "^mfrmr_[0-9.]+[.]tar[.]gz$|^Rplots[.]pdf$|^[.]git$",
    basename(relative)
  )
  patterns <- mfrmr_release_readiness_buildignore_patterns(pkg_dir)
  ignored <- vapply(relative, function(path) {
    mfrmr_release_readiness_path_is_ignored(path, patterns)
  }, logical(1))
  # .Rbuildignore affects the tarball contents and is itself a release input.
  ignored[relative == ".Rbuildignore"] <- FALSE
  files[!evidence_or_detritus & !ignored]
}

mfrmr_release_readiness_time_label <- function(value) {
  if (length(value) == 0L || is.na(value[1L])) {
    return(NA_character_)
  }
  format(
    as.POSIXct(value[1L], origin = "1970-01-01", tz = "UTC"),
    "%Y-%m-%d %H:%M:%S UTC"
  )
}

mfrmr_release_readiness_evidence_freshness <- function(paths,
                                                       check_log = NULL,
                                                       tarball = NULL,
                                                       tolerance_seconds = 1) {
  check_log <- as.character(check_log %||% paths$check_log %||% "")[1L]
  tarball <- as.character(tarball %||% paths$tarball %||% "")[1L]
  if (is.na(check_log)) check_log <- ""
  if (is.na(tarball)) tarball <- ""
  input_files <- mfrmr_release_readiness_release_input_files(paths$pkg_dir)
  input_times <- if (length(input_files) > 0L) {
    as.numeric(file.info(input_files)$mtime)
  } else {
    numeric(0)
  }
  valid_inputs <- is.finite(input_times)
  input_files <- input_files[valid_inputs]
  input_times <- input_times[valid_inputs]
  latest_index <- if (length(input_times) > 0L) which.max(input_times) else NA_integer_
  latest_time <- if (!is.na(latest_index)) input_times[latest_index] else NA_real_
  latest_input <- if (!is.na(latest_index)) {
    mfrmr_release_readiness_relative_path(
      input_files[latest_index],
      paths$pkg_dir
    )
  } else {
    NA_character_
  }

  check_available <- file.exists(check_log)
  tarball_available <- file.exists(tarball)
  check_time <- if (check_available) {
    as.numeric(file.info(check_log)$mtime)
  } else {
    NA_real_
  }
  tarball_time <- if (tarball_available) {
    as.numeric(file.info(tarball)$mtime)
  } else {
    NA_real_
  }
  tolerance_seconds <- as.numeric(tolerance_seconds)[1L]
  if (!is.finite(tolerance_seconds) || tolerance_seconds < 0) {
    tolerance_seconds <- 1
  }
  check_fresh <- check_available && is.finite(latest_time) &&
    is.finite(check_time) && latest_time <= check_time + tolerance_seconds
  tarball_fresh <- if (tarball_available && is.finite(latest_time) &&
                       is.finite(tarball_time)) {
    latest_time <= tarball_time + tolerance_seconds
  } else {
    NA
  }
  check_after_tarball <- if (check_available && tarball_available &&
                             is.finite(check_time) && is.finite(tarball_time)) {
    check_time + tolerance_seconds >= tarball_time
  } else {
    NA
  }
  freshness_ok <- length(input_times) > 0L && isTRUE(check_fresh) &&
    !identical(tarball_fresh, FALSE) &&
    !identical(check_after_tarball, FALSE)

  evidence_times <- c(
    if (check_available && is.finite(check_time)) check_time,
    if (tarball_available && is.finite(tarball_time)) tarball_time
  )
  stale_inputs <- if (length(evidence_times) > 0L && length(input_times) > 0L) {
    input_files[input_times > min(evidence_times) + tolerance_seconds]
  } else {
    input_files
  }
  stale_inputs <- mfrmr_release_readiness_relative_path(
    stale_inputs,
    paths$pkg_dir
  )
  stale_label <- if (length(stale_inputs) > 8L) {
    paste0(
      paste(utils::head(sort(stale_inputs), 8L), collapse = " | "),
      " | ... (", length(stale_inputs) - 8L, " more)"
    )
  } else {
    paste(sort(stale_inputs), collapse = " | ")
  }

  data.frame(
    InputsAvailable = length(input_times) > 0L,
    InputCount = length(input_times),
    LatestInput = latest_input,
    LatestInputTime = mfrmr_release_readiness_time_label(latest_time),
    CheckLog = check_log,
    CheckLogAvailable = check_available,
    CheckLogTime = mfrmr_release_readiness_time_label(check_time),
    CheckLogFresh = isTRUE(check_fresh),
    Tarball = tarball,
    TarballAvailable = tarball_available,
    TarballTime = mfrmr_release_readiness_time_label(tarball_time),
    TarballFresh = if (is.na(tarball_fresh)) NA else isTRUE(tarball_fresh),
    CheckAfterTarball = if (is.na(check_after_tarball)) {
      NA
    } else {
      isTRUE(check_after_tarball)
    },
    FreshnessOK = isTRUE(freshness_ok),
    StaleInputs = stale_label,
    stringsAsFactors = FALSE
  )
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
  release_version <- sub("\\.9000$", "", target_version)
  dev_label_present <- any(grepl(
    paste0(release_version, ".9000"),
    current_lines,
    fixed = TRUE
  ))
  data.frame(
    TargetVersion = target_version,
    DescriptionVersion = desc_version,
    NewsHeading = first_heading,
    DevelopmentLabelPresent = dev_label_present,
    VersionOK = identical(desc_version, target_version) &&
      identical(first_heading, paste("# mfrmr", target_version)) &&
      !isTRUE(dev_label_present),
    stringsAsFactors = FALSE
  )
}

mfrmr_release_readiness_cff_value <- function(lines, key) {
  hit <- grep(paste0("^", key, ":[[:space:]]*"), lines, value = TRUE)
  if (length(hit) == 0L) {
    return(NA_character_)
  }
  value <- sub(paste0("^", key, ":[[:space:]]*"), "", hit[1])
  sub("^['\"](.*)['\"]$", "\\1", trimws(value))
}

mfrmr_release_readiness_source_truth_status <- function(paths) {
  description <- if (file.exists(paths$description)) {
    read.dcf(paths$description)
  } else {
    matrix(character(0), nrow = 0L, ncol = 0L)
  }
  description_value <- function(field) {
    if (nrow(description) > 0L && field %in% colnames(description)) {
      as.character(description[1, field])
    } else {
      NA_character_
    }
  }
  cff_lines <- mfrmr_release_readiness_read_lines(paths$cff)
  description_version <- description_value("Version")
  description_date <- description_value("Date")
  cff_version <- mfrmr_release_readiness_cff_value(cff_lines, "version")
  cff_date <- mfrmr_release_readiness_cff_value(cff_lines, "date-released")
  patterns <- mfrmr_release_readiness_buildignore_patterns(paths$pkg_dir)
  roadmap_available <- file.exists(paths$roadmap)
  roadmap_excluded <- roadmap_available &&
    mfrmr_release_readiness_path_is_ignored("ROADMAP.md", patterns)
  roadmap_lines <- mfrmr_release_readiness_read_lines(paths$roadmap)
  roadmap_authoritative <- any(grepl(
    "single source of truth",
    roadmap_lines,
    fixed = TRUE
  ))
  supplement_lines <- mfrmr_release_readiness_read_lines(paths$gpcm_roadmap)
  forbidden_current_api <- c(
    "mfrmr_model_family_scope()",
    "mfrmr_estimation_scope()",
    "estimate_population_sd = TRUE",
    "analyze_eap_power_sensitivity()",
    "analyze_dff_moderation()",
    "analyze_dif_moderation()"
  )
  forbidden_hits <- forbidden_current_api[vapply(
    forbidden_current_api,
    function(value) any(grepl(value, supplement_lines, fixed = TRUE)),
    logical(1)
  )]
  version_match <- !is.na(description_version) &&
    identical(description_version, cff_version)
  date_match <- !is.na(description_date) &&
    identical(description_date, cff_date)
  ok <- version_match && date_match && roadmap_available &&
    roadmap_excluded && roadmap_authoritative && length(forbidden_hits) == 0L
  data.frame(
    DescriptionVersion = description_version,
    CFFVersion = cff_version,
    DescriptionDate = description_date,
    CFFDate = cff_date,
    VersionMatchesCFF = version_match,
    DateMatchesCFF = date_match,
    RoadmapAvailable = roadmap_available,
    RoadmapExcludedFromTarball = roadmap_excluded,
    RoadmapAuthoritative = roadmap_authoritative,
    DevelopmentOnlyCurrentClaims = paste(forbidden_hits, collapse = " | "),
    SourceTruthOK = ok,
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
  allow_source_header <- "^% Please edit documentation in R/.*audit.*\\.R$"
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
      if (!grepl(allow_source_header, line, perl = TRUE)) {
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

mfrmr_release_readiness_roxygen_marker_targets <- function(pkg_dir, marker) {
  r_dir <- file.path(pkg_dir, "R")
  if (!dir.exists(r_dir)) {
    return(data.frame(
      File = character(0),
      Line = integer(0),
      Target = character(0),
      stringsAsFactors = FALSE
    ))
  }
  files <- list.files(r_dir, pattern = "\\.R$", recursive = TRUE,
                      full.names = TRUE)
  rows <- list()
  for (path in files) {
    lines <- mfrmr_release_readiness_read_lines(path)
    marker_lines <- grep(marker, lines, fixed = TRUE)
    for (line_number in marker_lines) {
      remaining <- if (line_number < length(lines)) {
        lines[seq.int(line_number + 1L, length(lines))]
      } else {
        character(0)
      }
      assignment <- grep(
        "^[.A-Za-z][A-Za-z0-9._]*\\s*<-\\s*function\\s*\\(",
        remaining,
        perl = TRUE
      )
      target <- if (length(assignment) == 0L) {
        NA_character_
      } else {
        sub(
          "^([.A-Za-z][A-Za-z0-9._]*)\\s*<-.*$",
          "\\1",
          remaining[[assignment[[1]]]],
          perl = TRUE
        )
      }
      rows[[length(rows) + 1L]] <- data.frame(
        File = mfrmr_release_readiness_relative_path(path, pkg_dir),
        Line = line_number,
        Target = target,
        stringsAsFactors = FALSE
      )
    }
  }
  if (length(rows) == 0L) {
    return(data.frame(
      File = character(0),
      Line = integer(0),
      Target = character(0),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, rows)
}

mfrmr_release_readiness_rd_marker_pages <- function(pkg_dir, marker) {
  man_dir <- file.path(pkg_dir, "man")
  if (!dir.exists(man_dir)) {
    return(character(0))
  }
  files <- list.files(man_dir, pattern = "\\.Rd$", recursive = TRUE,
                      full.names = TRUE)
  hits <- vapply(files, function(path) {
    any(grepl(
      marker,
      mfrmr_release_readiness_read_lines(path),
      fixed = TRUE
    ))
  }, logical(1))
  sort(basename(files[hits]))
}

mfrmr_release_readiness_example_policy_status <- function(pkg_dir) {
  expected_dontrun_targets <- sort(c(
    "normalize_conquest_overlap_exports",
    "review_conquest_overlap"
  ))
  expected_dontrun_pages <- sort(paste0(expected_dontrun_targets, ".Rd"))
  expected_examples_if_targets <- "launch_mfrmr_viewer"
  expected_examples_if_pages <- paste0(expected_examples_if_targets, ".Rd")

  dontrun_source <- mfrmr_release_readiness_roxygen_marker_targets(
    pkg_dir,
    "#' \\dontrun{"
  )
  examples_if_source <- mfrmr_release_readiness_roxygen_marker_targets(
    pkg_dir,
    "#' @examplesIf interactive()"
  )
  dontrun_targets <- sort(as.character(dontrun_source$Target))
  examples_if_targets <- sort(as.character(examples_if_source$Target))
  dontrun_pages <- mfrmr_release_readiness_rd_marker_pages(
    pkg_dir,
    "\\dontrun{"
  )
  examples_if_pages <- mfrmr_release_readiness_rd_marker_pages(
    pkg_dir,
    "# examplesIf"
  )
  donttest_pages <- mfrmr_release_readiness_rd_marker_pages(
    pkg_dir,
    "\\donttest{"
  )

  source_available <- dir.exists(file.path(pkg_dir, "R"))
  man_available <- dir.exists(file.path(pkg_dir, "man"))
  dontrun_ok <- nrow(dontrun_source) == length(expected_dontrun_targets) &&
    identical(dontrun_targets, expected_dontrun_targets) &&
    identical(dontrun_pages, expected_dontrun_pages)
  examples_if_ok <- nrow(examples_if_source) ==
    length(expected_examples_if_targets) &&
    identical(examples_if_targets, expected_examples_if_targets) &&
    identical(examples_if_pages, expected_examples_if_pages)
  issue_parts <- c(
    if (!source_available) "R source unavailable" else character(0),
    if (!man_available) "generated Rd unavailable" else character(0),
    if (!dontrun_ok) paste0(
      "dontrun expected=", paste(expected_dontrun_targets, collapse = ","),
      "; observed=", paste(dontrun_targets, collapse = ","),
      "; Rd=", paste(dontrun_pages, collapse = ",")
    ) else character(0),
    if (!examples_if_ok) paste0(
      "examplesIf expected=", paste(expected_examples_if_targets, collapse = ","),
      "; observed=", paste(examples_if_targets, collapse = ","),
      "; Rd=", paste(examples_if_pages, collapse = ",")
    ) else character(0)
  )

  data.frame(
    SourceAvailable = source_available,
    GeneratedRdAvailable = man_available,
    DontrunSourceTargets = paste(dontrun_targets, collapse = ", "),
    DontrunRdPages = paste(dontrun_pages, collapse = ", "),
    ExamplesIfSourceTargets = paste(examples_if_targets, collapse = ", "),
    ExamplesIfRdPages = paste(examples_if_pages, collapse = ", "),
    DonttestRdPages = length(donttest_pages),
    Detail = paste(issue_parts, collapse = " | "),
    ExamplePolicyOK = isTRUE(source_available && man_available &&
      dontrun_ok && examples_if_ok),
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
    env$.gpcm_capability_registry <-
      getFromNamespace(".gpcm_capability_registry", "mfrmr")
    env$.gpcm_runtime_guard_registry <-
      getFromNamespace(".gpcm_runtime_guard_registry", "mfrmr")
  } else {
    return(empty_status("concern", "GPCM capability source is missing"))
  }
  if (!exists("gpcm_capability_matrix", envir = env, inherits = FALSE)) {
    return(empty_status("concern", "GPCM capability matrix function is missing"))
  }
  if (!exists("gpcm_runtime_guard_coverage", envir = env, inherits = FALSE)) {
    return(empty_status("concern", "GPCM runtime guard coverage function is missing"))
  }
  if (!exists(".gpcm_capability_registry", envir = env, inherits = FALSE) ||
      !exists(".gpcm_runtime_guard_registry", envir = env, inherits = FALSE)) {
    return(empty_status("concern", "GPCM scope data are missing"))
  }

  matrix <- env$.gpcm_capability_registry()
  required_columns <- c(
    "CapabilityID", "Area", "Status", "RecommendedRoute"
  )
  missing_columns <- setdiff(required_columns, names(matrix))
  if (length(missing_columns) > 0L) {
    return(empty_status(
      "concern",
      paste("GPCM capability matrix missing columns:", paste(missing_columns, collapse = ", "))
    ))
  }
  guard_coverage <- env$.gpcm_runtime_guard_registry()
  required_guard_columns <- c(
    "CapabilityID", "Area", "Helper", "Status", "AvailabilityMode",
    "ConditionClass", "RecommendedRoute"
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
  guard_idx <- match(guard_coverage$CapabilityID, matrix$CapabilityID)
  guard_status_ok <- all(!is.na(guard_idx)) &&
    all(guard_coverage$Status == matrix$Status[guard_idx]) &&
    all(guard_coverage$RecommendedRoute == matrix$RecommendedRoute[guard_idx])
  runtime_rows <- guard_coverage[
    guard_coverage$AvailabilityMode == "structured_error", , drop = FALSE
  ]
  runtime_condition_ok <- nrow(runtime_rows) > 0L &&
    all(runtime_rows$ConditionClass == "mfrmr_gpcm_scope_error")
  covered_guard_areas <- unique(guard_coverage$Area[
    guard_coverage$AvailabilityMode %in%
      c("structured_error", "no_public_helper")
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
  guidance_complete <- all(nzchar(outstanding$RecommendedRoute))
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
  readiness_gate <- contains("Repository validation review") &&
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

mfrmr_release_readiness_gate_summary <- function(version_status,
                                                 check_status,
                                                 term_status,
                                                 checklist_status,
                                                 ci_workflow_status,
                                                 paths,
                                                 gpcm_scope_status = NULL,
                                                 freshness_status = NULL,
                                                 source_truth_status = NULL,
                                                 example_policy_status = NULL,
                                                 check_timing_scope = c(
                                                   "cran", "full_non_cran"
                                                 )) {
  check_timing_scope <- match.arg(check_timing_scope)
  gpcm_scope_ok <- if (is.null(gpcm_scope_status)) {
    TRUE
  } else {
    identical(gpcm_scope_status$GPCMScopeStatus[1], "ok")
  }
  evidence_available <- file.exists(paths$evidence_map) &&
    file.exists(paths$gpcm_roadmap) &&
    file.exists(paths$external_recovery_evidence) &&
    file.exists(paths$external_recovery_helper) &&
    isTRUE(checklist_status$ChecklistAvailable[1]) &&
    isTRUE(gpcm_scope_ok)
  if (is.null(freshness_status)) {
    freshness_status <- data.frame(
      FreshnessOK = FALSE,
      LatestInput = NA_character_,
      CheckLogFresh = FALSE,
      TarballAvailable = FALSE,
      TarballFresh = NA,
      CheckAfterTarball = NA,
      StaleInputs = "freshness not assessed",
      stringsAsFactors = FALSE
    )
  }
  package_check_status <- if (!isTRUE(check_status$CheckPassed[1]) ||
                              !isTRUE(check_status$StatusPresent[1]) ||
                              !isTRUE(check_status$VersionMatchesTarget[1]) ||
                              !isTRUE(check_status$AsCRAN[1])) {
    "concern"
  } else if (isTRUE(check_status$NeedsExplanation[1]) ||
             !isTRUE(check_status$ManualChecked[1])) {
    "review"
  } else {
    "ok"
  }
  check_timing_status <- if (identical(
    check_timing_scope,
    "full_non_cran"
  )) {
    "ok"
  } else if (!isTRUE(check_status$RunDonttest[1])) {
    "concern"
  } else if (!isTRUE(check_status$TimingAvailable[1])) {
    "review"
  } else if (!isTRUE(check_status$UnderTenMinutes[1])) {
    "concern"
  } else {
    "ok"
  }
  freshness_gate_status <- if (!isTRUE(freshness_status$FreshnessOK[1])) {
    "concern"
  } else if (!isTRUE(freshness_status$TarballAvailable[1])) {
    "review"
  } else {
    "ok"
  }
  source_truth_ok <- is.null(source_truth_status) ||
    isTRUE(source_truth_status$SourceTruthOK[1])
  example_policy_gate_status <- if (is.null(example_policy_status)) {
    "review"
  } else if (isTRUE(example_policy_status$ExamplePolicyOK[1])) {
    "ok"
  } else {
    "concern"
  }
  rows <- data.frame(
    Gate = c(
      "version_contract", "source_truth", "package_check", "check_timing",
      "example_policy", "release_evidence_freshness", "ci_workflow",
      "terminology", "evidence_artifacts"
    ),
    Status = c(
      if (isTRUE(version_status$VersionOK[1])) "ok" else "concern",
      if (source_truth_ok) "ok" else "concern",
      package_check_status,
      check_timing_status,
      example_policy_gate_status,
      freshness_gate_status,
      if (isTRUE(ci_workflow_status$CIWorkflowOK[1])) "ok" else "review",
      if (isTRUE(term_status$TerminologyOK[1])) "ok" else "concern",
      if (evidence_available) "ok" else "concern"
    ),
    Detail = c(
      paste0("DESCRIPTION=", version_status$DescriptionVersion[1], "; NEWS=", version_status$NewsHeading[1]),
      if (is.null(source_truth_status)) {
        "source truth not checked separately"
      } else {
        paste0(
          "cff_version_match=", source_truth_status$VersionMatchesCFF[1],
          "; cff_date_match=", source_truth_status$DateMatchesCFF[1],
          "; roadmap=", source_truth_status$RoadmapAvailable[1],
          "; roadmap_excluded=", source_truth_status$RoadmapExcludedFromTarball[1],
          "; roadmap_authoritative=", source_truth_status$RoadmapAuthoritative[1],
          "; development_only_current_claims=",
          source_truth_status$DevelopmentOnlyCurrentClaims[1]
        )
      },
      paste0(
        check_status$StatusLine[1],
        "; status_present=", check_status$StatusPresent[1],
        "; check_version=", check_status$PackageVersion[1],
        "; target=", check_status$TargetVersion[1],
        "; version_match=", check_status$VersionMatchesTarget[1],
        "; as_cran=", check_status$AsCRAN[1],
        "; run_donttest=", check_status$RunDonttest[1],
        "; manual_checked=", check_status$ManualChecked[1]
      ),
      paste0(
        "scope=", check_timing_scope,
        "; component_elapsed_seconds=",
        check_status$ComponentElapsedSeconds[1],
        "; examples_seconds=", check_status$ExamplesSeconds[1],
        "; donttest_seconds=", check_status$DonttestExamplesSeconds[1],
        "; tests_seconds=", check_status$TestsSeconds[1],
        "; vignette_rebuild_seconds=",
        check_status$VignetteRebuildSeconds[1],
        "; under_600_seconds=", check_status$UnderTenMinutes[1],
        "; run_donttest=", check_status$RunDonttest[1]
      ),
      if (is.null(example_policy_status)) {
        "example wrapper semantics not checked separately"
      } else {
        paste0(
          "dontrun_targets=", example_policy_status$DontrunSourceTargets[1],
          "; examples_if_targets=",
          example_policy_status$ExamplesIfSourceTargets[1],
          "; donttest_pages=", example_policy_status$DonttestRdPages[1],
          "; detail=", example_policy_status$Detail[1]
        )
      },
      paste0(
        "latest_input=", freshness_status$LatestInput[1],
        "; check_fresh=", freshness_status$CheckLogFresh[1],
        "; tarball_available=", freshness_status$TarballAvailable[1],
        "; tarball_fresh=", freshness_status$TarballFresh[1],
        "; check_after_tarball=", freshness_status$CheckAfterTarball[1],
        "; stale_inputs=", freshness_status$StaleInputs[1]
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
        "evidence_map=", file.exists(paths$evidence_map),
        "; gpcm_roadmap=", file.exists(paths$gpcm_roadmap),
        "; external_recovery=", file.exists(paths$external_recovery_evidence),
        "; external_helper=", file.exists(paths$external_recovery_helper),
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

mfrmr_release_readiness_review <- function(pkg_dir = ".",
                                           check_log = NULL,
                                           tarball = NULL,
                                           checklist = NULL,
                                           target_version = NULL,
                                           external_recovery_dir = NULL,
                                           check_timing_scope = NULL) {
  if (is.null(check_timing_scope)) {
    check_timing_scope <- mfrmr_release_readiness_check_timing_scope()
  } else {
    check_timing_scope <- match.arg(
      check_timing_scope,
      c("cran", "full_non_cran")
    )
  }
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
  if (!is.null(tarball)) {
    paths$tarball <- tarball
  } else {
    paths$tarball <- mfrmr_release_readiness_find_tarball(
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
    target_version = target_version
  )
  freshness_status <- mfrmr_release_readiness_evidence_freshness(
    paths = paths,
    check_log = paths$check_log,
    tarball = paths$tarball
  )
  term_status <- mfrmr_release_readiness_term_status(paths$pkg_dir)
  example_policy_status <- mfrmr_release_readiness_example_policy_status(
    paths$pkg_dir
  )
  source_truth_status <- mfrmr_release_readiness_source_truth_status(paths)
  checklist_status <- mfrmr_release_readiness_checklist_status(paths$evidence_checklist)
  ci_workflow_status <- mfrmr_release_readiness_ci_workflow_status(paths$ci_workflow)
  gpcm_scope_status <- mfrmr_release_readiness_gpcm_scope_status(
    paths = paths,
    checklist_status = checklist_status
  )
  gate_summary <- mfrmr_release_readiness_gate_summary(
    version_status = version_status,
    check_status = check_status,
    term_status = term_status,
    checklist_status = checklist_status,
    ci_workflow_status = ci_workflow_status,
    paths = paths,
    gpcm_scope_status = gpcm_scope_status,
    freshness_status = freshness_status,
    source_truth_status = source_truth_status,
    example_policy_status = example_policy_status,
    check_timing_scope = check_timing_scope
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
    source_truth_status = source_truth_status,
    check_status = check_status,
    freshness_status = freshness_status,
    ci_workflow_status = ci_workflow_status,
    terminology_status = term_status,
    example_policy_status = example_policy_status,
    check_timing_scope = check_timing_scope,
    checklist_status = checklist_status,
    gpcm_scope_status = gpcm_scope_status,
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
    source_truth_status = object$source_truth_status,
    freshness_status = object$freshness_status,
    ci_workflow_status = object$ci_workflow_status,
    example_policy_status = object$example_policy_status,
    check_timing_scope = object$check_timing_scope,
    gpcm_scope_status = object$gpcm_scope_status,
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
  cat("\nRelease evidence freshness:\n")
  print(x$freshness_status, row.names = FALSE)
  cat("\nReview steps:\n")
  print(x$prompt_steps[, c("Step", "Label", "Gate")], row.names = FALSE)
  if (!is.null(x$gpcm_scope_status)) {
    cat("\nGPCM scope status:\n")
    print(x$gpcm_scope_status, row.names = FALSE)
  }
  if (isTRUE(x$external_recovery_status$ExternalRecoveryRequested[1])) {
    cat("\nExternal recovery status:\n")
    print(x$external_recovery_status, row.names = FALSE)
  }
  invisible(x)
}
