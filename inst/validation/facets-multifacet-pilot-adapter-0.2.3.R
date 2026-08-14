# Repository-only execution adapter for already-open FACETS pilot seeds.
# It never accepts confirmation seeds and never uses file hashes as evidence.

mfrmr_facets_mfx_contract_id <-
  "mfrmr_facets_multifacet_pilot_execution_adapter_v1"

mfrmr_facets_mfx_allowed_pilot_seeds <- function() {
  c(451001L, 452001L, 452101L, 452201L, 452301L, 452401L)
}

mfrmr_facets_mfx_validate_request <- function(
    base_seed, total_facets = 3:5, models = c("RSM", "PCM")) {
  valid_seed <- is.numeric(base_seed) && length(base_seed) == 1L &&
    !is.na(base_seed) && is.finite(base_seed) && base_seed == floor(base_seed)
  if (!valid_seed || !as.integer(base_seed) %in%
      mfrmr_facets_mfx_allowed_pilot_seeds()) {
    stop(
      "`base_seed` must be an already-open pilot seed; confirmation seeds ",
      "are not permitted.", call. = FALSE
    )
  }
  valid_facets <- is.numeric(total_facets) && length(total_facets) > 0L &&
    !anyNA(total_facets) && all(is.finite(total_facets)) &&
    all(total_facets == floor(total_facets)) &&
    all(total_facets %in% 3:5) && !anyDuplicated(total_facets)
  if (!valid_facets) {
    stop("`total_facets` must contain unique values from 3, 4, and 5.",
         call. = FALSE)
  }
  valid_models <- is.character(models) && length(models) > 0L &&
    !anyNA(models) && all(models %in% c("RSM", "PCM")) &&
    !anyDuplicated(models)
  if (!valid_models) {
    stop("`models` must contain unique values from RSM and PCM.",
         call. = FALSE)
  }
  list(
    base_seed = as.integer(base_seed),
    total_facets = as.integer(total_facets),
    models = models
  )
}

mfrmr_facets_mfx_require_execution_support <- function() {
  name <- "mfrmr_run_facets_mfp_external_pilot"
  support_env <- parent.env(environment())
  if (!exists(name, envir = support_env, mode = "function", inherits = TRUE)) {
    stop(
      "Pilot execution support is missing: source the multifacet precision ",
      "contract before this adapter.", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_facets_mfx_registry <- function(
    base_seed, total_facets = 3:5, models = c("RSM", "PCM")) {
  request <- mfrmr_facets_mfx_validate_request(
    base_seed, total_facets, models
  )
  registry <- expand.grid(
    Model = request$models,
    TotalFacets = request$total_facets,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  registry$BaseSeed <- request$base_seed
  registry$DesignSeed <- registry$BaseSeed +
    match(registry$Model, c("RSM", "PCM"))
  registry$ScenarioId <- paste0(
    "MFX-PILOT-", registry$Model, "-F", registry$TotalFacets,
    "-B", registry$BaseSeed
  )
  registry$ExpectedElementCoordinates <- unname(
    c(`3` = 48L, `4` = 51L, `5` = 53L)[
      as.character(registry$TotalFacets)
    ]
  )
  registry$ExpectedStepCoordinates <- ifelse(
    registry$Model == "RSM", 3L, 12L
  )
  registry[, c(
    "ScenarioId", "BaseSeed", "DesignSeed", "Model", "TotalFacets",
    "ExpectedElementCoordinates", "ExpectedStepCoordinates"
  )]
}

mfrmr_facets_mfx_report_version <- function(report_path) {
  if (!file.exists(report_path)) return(NA_character_)
  header <- readLines(report_path, n = 1L, warn = FALSE)
  if (length(header) != 1L) return(NA_character_)
  match <- regexpr("[0-9]+\\.[0-9]+\\.[0-9]+", header)
  if (match[1L] < 0L) return(NA_character_)
  regmatches(header, match)[1L]
}

mfrmr_facets_mfx_executable_metadata <- function(facets_exe) {
  path <- normalizePath(facets_exe, winslash = "/", mustWork = FALSE)
  present <- file.exists(facets_exe)
  info <- if (present) file.info(facets_exe) else NULL
  modified <- if (present && !is.na(info$mtime[1L])) {
    format(info$mtime[1L], "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  } else {
    NA_character_
  }
  list(
    path = path,
    present = present,
    size = if (present) as.numeric(info$size[1L]) else NA_real_,
    modified_utc = modified
  )
}

mfrmr_facets_mfx_report_paths <- function(registry, work_dir) {
  file.path(
    normalizePath(work_dir, winslash = "/", mustWork = FALSE),
    paste0(tolower(registry$Model), "-f", registry$TotalFacets),
    "report.txt"
  )
}

mfrmr_facets_mfx_empty_manifest <- function(registry, facets_exe, work_dir) {
  executable <- mfrmr_facets_mfx_executable_metadata(facets_exe)
  report_paths <- mfrmr_facets_mfx_report_paths(registry, work_dir)
  data.frame(
    registry,
    ExecutionStatus = "not_run",
    ResultOpened = FALSE,
    FACETSReturnCode = NA_integer_,
    FACETSReportedConvergenceScoreResidual = NA_real_,
    FACETSReportedConvergenceLogitChange = NA_real_,
    FACETSConvergenceSpecificationPassed = FALSE,
    FACETSConvergenceAchieved = FALSE,
    FACETSFinalIteration = NA_integer_,
    FACETSFinalElementScoreResidual = NA_real_,
    FACETSFinalElementLogitChange = NA_real_,
    MfrmrFitReturned = FALSE,
    MfrmrConvergenceCode = NA_integer_,
    MfrmrEstimationConverged = FALSE,
    MfrmrTerminalGradientSupNorm = NA_real_,
    MfrmrGradientReviewTolerance = NA_real_,
    ElementCoordinateContractPassed = FALSE,
    StepCoordinateContractPassed = FALSE,
    ComparisonEligible = FALSE,
    Warnings = "",
    Error = NA_character_,
    FACETSExecutablePath = executable$path,
    FACETSExecutablePresent = executable$present,
    FACETSExecutableSize = executable$size,
    FACETSExecutableModifiedUTC = executable$modified_utc,
    FACETSReportPath = normalizePath(
      report_paths, winslash = "/", mustWork = FALSE
    ),
    FACETSReportPresent = FALSE,
    FACETSReportVersion = NA_character_,
    FACETSExpectedVersion = "4.5.0",
    FACETSVersionMatched = FALSE,
    FileHashUsed = FALSE,
    PilotOnly = TRUE,
    ConfirmationAuthorized = FALSE,
    EquivalenceClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_mfx_empty_coordinates <- function(
    kind = c("element", "step")) {
  kind <- match.arg(kind)
  identity <- data.frame(
    ScenarioId = character(0), BaseSeed = integer(0),
    DesignSeed = integer(0), Model = character(0),
    TotalFacets = integer(0), stringsAsFactors = FALSE
  )
  coordinates <- if (identical(kind, "element")) {
    data.frame(Facet = character(0), Level = character(0),
               stringsAsFactors = FALSE)
  } else {
    data.frame(StepFacet = character(0), Step = character(0),
               stringsAsFactors = FALSE)
  }
  values <- data.frame(
    MfrmrEstimate = numeric(0), FACETSEstimate = numeric(0),
    Difference = numeric(0), AbsoluteDifference = numeric(0),
    stringsAsFactors = FALSE
  )
  cbind(identity, coordinates, values)
}

mfrmr_facets_mfx_preflight <- function(
    facets_exe, work_dir, base_seed = 451001L, total_facets = 3:5,
    models = c("RSM", "PCM")) {
  registry <- mfrmr_facets_mfx_registry(base_seed, total_facets, models)
  manifest <- mfrmr_facets_mfx_empty_manifest(
    registry, facets_exe, work_dir
  )
  out <- list(
    contract_id = mfrmr_facets_mfx_contract_id,
    manifest = manifest,
    element_coordinates = mfrmr_facets_mfx_empty_coordinates("element"),
    step_coordinates = mfrmr_facets_mfx_empty_coordinates("step"),
    facet_metrics = data.frame(),
    decision = data.frame(
      Status = "pilot_preflight_no_files_created",
      PlannedCases = nrow(registry),
      ExpectedElementCoordinates = sum(
        registry$ExpectedElementCoordinates
      ),
      ExpectedStepCoordinates = sum(registry$ExpectedStepCoordinates),
      ExternalExecutionRequested = FALSE,
      ExternalProvenanceValidated = FALSE,
      PilotOnly = TRUE,
      ConfirmationOutcomeOpened = FALSE,
      ConfirmationClaimAuthorized = FALSE,
      ExactEqualityClaimAuthorized = FALSE,
      FACETSReplacementClaimAuthorized = FALSE,
      FileHashRequired = FALSE,
      stringsAsFactors = FALSE
    ),
    work_dir = normalizePath(work_dir, winslash = "/", mustWork = FALSE)
  )
  class(out) <- c("mfrmr_facets_mfx_result", "list")
  out
}

mfrmr_facets_mfx_failure_status <- function(raw_row, version_matched) {
  if (!isTRUE(raw_row$FACETSReportPresent) ||
      is.na(raw_row$FACETSReturnCode) || raw_row$FACETSReturnCode != 0L) {
    return("facets_failure")
  }
  if (!version_matched) return("parse_failure")
  if (!isTRUE(raw_row$FACETSConvergenceSpecificationPassed) ||
      !isTRUE(raw_row$FACETSConvergenceAchieved)) {
    return("convergence_failure")
  }
  if (!isTRUE(raw_row$MfrmrFitReturned) ||
      !isTRUE(raw_row$MfrmrNumericalGatePassed)) {
    return("mfrmr_failure")
  }
  "coordinate_failure"
}

mfrmr_facets_mfx_failure_message <- function(status, raw_error) {
  raw_error <- as.character(raw_error)
  if (length(raw_error) == 1L && !is.na(raw_error) && nzchar(raw_error)) {
    return(raw_error)
  }
  switch(
    status,
    facets_failure = "FACETS did not return a readable result.",
    parse_failure = "FACETS report header does not identify version 4.5.0.",
    convergence_failure = "FACETS convergence contract failed.",
    mfrmr_failure = "mfrmr numerical convergence contract failed.",
    coordinate_failure = "Element or step coordinate contract failed.",
    "Pilot execution failed."
  )
}

mfrmr_facets_mfx_normalize_coordinates <- function(
    coordinates, manifest, kind = c("element", "step")) {
  kind <- match.arg(kind)
  eligible_ids <- manifest$ScenarioId[manifest$ComparisonEligible]
  if (!is.data.frame(coordinates) || nrow(coordinates) == 0L) {
    if (length(eligible_ids)) {
      stop("Pilot ", kind, " coordinates are missing for eligible cases.",
           call. = FALSE)
    }
    return(mfrmr_facets_mfx_empty_coordinates(kind))
  }
  coordinate_fields <- if (identical(kind, "element")) {
    c("Facet", "Level")
  } else {
    c("StepFacet", "Step")
  }
  required <- c(
    "BaseSeed", "DesignSeed", "Model", "TotalFacets", coordinate_fields,
    "MfrmrEstimate", "FACETSEstimate", "Difference", "AbsoluteDifference"
  )
  missing <- setdiff(required, names(coordinates))
  if (length(missing)) {
    stop("Pilot ", kind, " coordinates are missing: ",
         paste(missing, collapse = ", "), ".", call. = FALSE)
  }
  coordinates <- as.data.frame(coordinates, stringsAsFactors = FALSE)
  coordinates$ScenarioId <- paste0(
    "MFX-PILOT-", coordinates$Model, "-F", coordinates$TotalFacets,
    "-B", coordinates$BaseSeed
  )
  coordinates <- coordinates[
    coordinates$ScenarioId %in% eligible_ids, , drop = FALSE
  ]
  if (!nrow(coordinates)) return(mfrmr_facets_mfx_empty_coordinates(kind))
  fields <- c(
    "ScenarioId", "BaseSeed", "DesignSeed", "Model", "TotalFacets",
    coordinate_fields, "MfrmrEstimate", "FACETSEstimate", "Difference",
    "AbsoluteDifference"
  )
  coordinates <- coordinates[, fields, drop = FALSE]
  numeric_fields <- c(
    "MfrmrEstimate", "FACETSEstimate", "Difference", "AbsoluteDifference"
  )
  if (any(vapply(
        coordinates[numeric_fields], function(x) any(!is.finite(x)), logical(1)
      ))) {
    stop("Pilot ", kind, " coordinates must be finite.", call. = FALSE)
  }
  key <- do.call(paste, c(
    coordinates[c("ScenarioId", coordinate_fields)], sep = "::"
  ))
  if (anyDuplicated(key)) {
    stop("Pilot ", kind, " coordinates contain duplicate identities.",
         call. = FALSE)
  }
  calculated <- coordinates$MfrmrEstimate - coordinates$FACETSEstimate
  allowance <- 8 * .Machine$double.eps * pmax(
    1, abs(coordinates$MfrmrEstimate), abs(coordinates$FACETSEstimate),
    abs(calculated), abs(coordinates$Difference)
  )
  if (any(abs(coordinates$Difference - calculated) > allowance) ||
      any(abs(coordinates$AbsoluteDifference - abs(calculated)) > allowance)) {
    stop("Pilot ", kind, " coordinate arithmetic is inconsistent.",
         call. = FALSE)
  }
  expected_field <- if (identical(kind, "element")) {
    "ExpectedElementCoordinates"
  } else {
    "ExpectedStepCoordinates"
  }
  observed <- table(factor(
    coordinates$ScenarioId, levels = eligible_ids
  ))
  expected <- manifest[[expected_field]][match(eligible_ids, manifest$ScenarioId)]
  if (!identical(as.integer(observed), as.integer(expected))) {
    stop("Pilot ", kind, " coordinate counts do not match the manifest.",
         call. = FALSE)
  }
  row.names(coordinates) <- NULL
  coordinates
}

mfrmr_facets_mfx_normalize <- function(
    raw, facets_exe, work_dir, base_seed, total_facets, models) {
  registry <- mfrmr_facets_mfx_registry(base_seed, total_facets, models)
  if (!is.list(raw) || !is.data.frame(raw$manifest)) {
    stop("Pilot runner returned no manifest.", call. = FALSE)
  }
  identity <- c("BaseSeed", "DesignSeed", "Model", "TotalFacets")
  missing <- setdiff(identity, names(raw$manifest))
  if (length(missing) || nrow(raw$manifest) != nrow(registry) ||
      !identical(raw$manifest[identity], registry[identity])) {
    stop("Pilot runner manifest does not match the requested cases.",
         call. = FALSE)
  }
  manifest <- mfrmr_facets_mfx_empty_manifest(
    registry, facets_exe, work_dir
  )
  report_versions <- vapply(
    manifest$FACETSReportPath, mfrmr_facets_mfx_report_version, character(1)
  )
  version_matched <- !is.na(report_versions) & report_versions == "4.5.0"
  status <- vapply(seq_len(nrow(manifest)), function(i) {
    raw_row <- raw$manifest[i, , drop = FALSE]
    if (isTRUE(raw_row$ComparisonEligible) && version_matched[i]) {
      "completed"
    } else {
      mfrmr_facets_mfx_failure_status(raw_row, version_matched[i])
    }
  }, character(1))
  manifest$ExecutionStatus <- status
  manifest$ResultOpened <- TRUE
  copy_fields <- c(
    "FACETSReturnCode", "FACETSReportedConvergenceScoreResidual",
    "FACETSReportedConvergenceLogitChange",
    "FACETSConvergenceSpecificationPassed", "FACETSConvergenceAchieved",
    "FACETSFinalIteration", "FACETSFinalElementScoreResidual",
    "FACETSFinalElementLogitChange", "MfrmrFitReturned",
    "MfrmrConvergenceCode", "MfrmrEstimationConverged",
    "MfrmrTerminalGradientSupNorm", "MfrmrGradientReviewTolerance",
    "StepCoordinateContractPassed", "Warnings"
  )
  required_raw_fields <- c(
    copy_fields, "CoordinateContractPassed", "MfrmrNumericalGatePassed",
    "ComparisonEligible"
  )
  missing <- setdiff(required_raw_fields, names(raw$manifest))
  if (length(missing)) {
    stop("Pilot runner manifest is missing: ", paste(missing, collapse = ", "),
         ".", call. = FALSE)
  }
  for (field in copy_fields) manifest[[field]] <- raw$manifest[[field]]
  manifest$ElementCoordinateContractPassed <-
    as.logical(raw$manifest$CoordinateContractPassed) & version_matched
  manifest$StepCoordinateContractPassed <-
    as.logical(manifest$StepCoordinateContractPassed) & version_matched
  manifest$ComparisonEligible <- status == "completed"
  manifest$Warnings[is.na(manifest$Warnings)] <- ""
  manifest$FACETSReportPresent <- file.exists(manifest$FACETSReportPath)
  manifest$FACETSReportVersion <- report_versions
  manifest$FACETSVersionMatched <- version_matched
  raw_errors <- if ("Error" %in% names(raw$manifest)) {
    raw$manifest$Error
  } else {
    rep(NA_character_, nrow(manifest))
  }
  manifest$Error <- vapply(seq_len(nrow(manifest)), function(i) {
    if (identical(status[i], "completed")) return(NA_character_)
    mfrmr_facets_mfx_failure_message(status[i], raw_errors[i])
  }, character(1))

  element_coordinates <- mfrmr_facets_mfx_normalize_coordinates(
    raw$element_comparisons, manifest, "element"
  )
  step_coordinates <- mfrmr_facets_mfx_normalize_coordinates(
    raw$step_comparisons, manifest, "step"
  )
  executable_valid <- all(
    manifest$FACETSExecutablePresent &
      is.finite(manifest$FACETSExecutableSize) &
      manifest$FACETSExecutableSize > 0
  )
  provenance_valid <- executable_valid &&
    all(manifest$FACETSReportPresent & manifest$FACETSVersionMatched)
  out <- list(
    contract_id = mfrmr_facets_mfx_contract_id,
    manifest = manifest,
    element_coordinates = element_coordinates,
    step_coordinates = step_coordinates,
    facet_metrics = raw$metrics,
    decision = data.frame(
      Status = if (all(manifest$ExecutionStatus == "completed")) {
        "pilot_execution_completed"
      } else {
        "pilot_execution_completed_with_failures"
      },
      PlannedCases = nrow(manifest),
      CompletedCases = sum(manifest$ExecutionStatus == "completed"),
      EligibleCases = sum(manifest$ComparisonEligible),
      ExpectedElementCoordinates = sum(
        manifest$ExpectedElementCoordinates[manifest$ComparisonEligible]
      ),
      ReviewedElementCoordinates = nrow(element_coordinates),
      ExpectedStepCoordinates = sum(
        manifest$ExpectedStepCoordinates[manifest$ComparisonEligible]
      ),
      ReviewedStepCoordinates = nrow(step_coordinates),
      ExternalExecutionRequested = TRUE,
      ExternalProvenanceValidated = provenance_valid,
      PilotOnly = TRUE,
      ConfirmationOutcomeOpened = FALSE,
      ConfirmationClaimAuthorized = FALSE,
      ExactEqualityClaimAuthorized = FALSE,
      FACETSReplacementClaimAuthorized = FALSE,
      FileHashRequired = FALSE,
      stringsAsFactors = FALSE
    ),
    work_dir = normalizePath(work_dir, winslash = "/", mustWork = FALSE)
  )
  class(out) <- c("mfrmr_facets_mfx_result", "list")
  out
}

mfrmr_run_facets_mfx_pilot_adapter <- function(
    facets_exe, work_dir, base_seed = 451001L, total_facets = 3:5,
    models = c("RSM", "PCM"), execute = FALSE, maxit = 400L) {
  request <- mfrmr_facets_mfx_validate_request(
    base_seed, total_facets, models
  )
  if (!isTRUE(execute)) {
    return(mfrmr_facets_mfx_preflight(
      facets_exe = facets_exe, work_dir = work_dir,
      base_seed = request$base_seed, total_facets = request$total_facets,
      models = request$models
    ))
  }
  mfrmr_facets_mfx_require_execution_support()
  if (!file.exists(facets_exe)) {
    stop("FACETS executable was not found: ", facets_exe, ".", call. = FALSE)
  }
  raw <- mfrmr_run_facets_mfp_external_pilot(
    facets_exe = facets_exe,
    work_dir = work_dir,
    execute = TRUE,
    total_facets = request$total_facets,
    models = request$models,
    seed = request$base_seed,
    maxit = as.integer(maxit)
  )
  mfrmr_facets_mfx_normalize(
    raw = raw, facets_exe = facets_exe, work_dir = work_dir,
    base_seed = request$base_seed, total_facets = request$total_facets,
    models = request$models
  )
}

print.mfrmr_facets_mfx_result <- function(x, ...) {
  cat("FACETS multifacet pilot execution adapter\n")
  cat("Status:", x$decision$Status, "\n")
  cat("Planned cases:", x$decision$PlannedCases, "\n")
  if ("CompletedCases" %in% names(x$decision)) {
    cat("Completed cases:", x$decision$CompletedCases, "\n")
  }
  cat("Pilot only: yes\n")
  cat("Confirmation outcome opened: no\n")
  cat("File hash required: no\n")
  invisible(x)
}
