# Repository-only replicated-pilot orchestration for the draft.42 GPCM
# isolated-attribution runner.  This script adds prespecified execution tiers,
# completeness accounting, Monte Carlo summaries, and runtime forecasting.
# It cannot authorize confirmation or freeze a numerical criterion.

mfrmr_gpcm_repilot_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "gpcm-attribution-replicated-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path(
      "inst", "validation",
      "gpcm-attribution-replicated-pilot-0.2.3.R"
    ),
    "gpcm-attribution-replicated-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_gpcm_repilot_require_runner <- function() {
  target_env <- environment(mfrmr_gpcm_repilot_require_runner)
  required <- c(
    "mfrmr_run_gpcm_isolated_attribution_pilot",
    "mfrmr_gpcm_attribution_manifest",
    "mfrmr_gpcm_attribution_manifest_audit",
    "mfrmr_gpcm_attribution_arms",
    "mfrmr_gpcm_attribution_run_one",
    "mfrmr_gpcm_attribution_bind",
    "mfrmr_gpcm_attribution_pair_audit",
    "mfrmr_gpcm_attribution_contrasts"
  )
  if (all(vapply(required, exists, logical(1), envir = target_env,
                 mode = "function", inherits = TRUE))) {
    return(invisible(TRUE))
  }
  candidates <- c(
    if (!is.na(mfrmr_gpcm_repilot_source_dir)) {
      file.path(
        mfrmr_gpcm_repilot_source_dir,
        "gpcm-isolated-attribution-pilot-0.2.3.R"
      )
    } else character(0),
    file.path(
      "inst", "validation", "gpcm-isolated-attribution-pilot-0.2.3.R"
    ),
    "gpcm-isolated-attribution-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) stop("Cannot locate the attribution runner.", call. = FALSE)
  sys.source(path, envir = target_env)
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("The attribution runner did not load completely.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gpcm_repilot_checkpoint_schema <- function() {
  "mfrmr-gpcm-repilot-checkpoint-v1"
}

mfrmr_gpcm_repilot_hash_object <- function(x) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package `digest` is required for evidence identity.",
         call. = FALSE)
  }
  digest::digest(x, algo = "sha256", serialize = TRUE)
}

mfrmr_gpcm_repilot_hash_file <- function(path) {
  if (!file.exists(path)) {
    stop(sprintf("Cannot hash missing evidence file: %s", path),
         call. = FALSE)
  }
  digest::digest(path, algo = "sha256", serialize = FALSE, file = TRUE)
}

mfrmr_gpcm_repilot_package_content_identity <- function(package) {
  namespace_root <- tryCatch(
    getNamespaceInfo(asNamespace(package), "path"),
    error = function(error) ""
  )
  package_root <- if (
      nzchar(namespace_root) &&
        file.exists(file.path(namespace_root, "DESCRIPTION"))) {
    namespace_root
  } else {
    system.file(package = package)
  }
  if (!nzchar(package_root) || !dir.exists(package_root)) {
    stop(sprintf("Cannot identify the loaded %s installation.", package),
         call. = FALSE)
  }
  candidates <- c(
    file.path(package_root, "DESCRIPTION"),
    file.path(package_root, "NAMESPACE"),
    list.files(file.path(package_root, "R"), full.names = TRUE,
               recursive = TRUE, all.files = TRUE, no.. = TRUE),
    list.files(file.path(package_root, "src"), full.names = TRUE,
               recursive = TRUE, all.files = TRUE, no.. = TRUE),
    list.files(file.path(package_root, "libs"), full.names = TRUE,
               recursive = TRUE, all.files = TRUE, no.. = TRUE)
  )
  files <- sort(unique(candidates[file.exists(candidates) &
                                    !dir.exists(candidates)]))
  if (length(files) == 0L) {
    stop(sprintf(
      "The loaded %s installation has no hashable runtime files.", package
    ), call. = FALSE)
  }
  relative <- unname(substring(
    normalizePath(files, winslash = "/", mustWork = TRUE),
    nchar(normalizePath(package_root, winslash = "/", mustWork = TRUE)) + 2L
  ))
  inventory <- data.frame(
    File = relative,
    SHA256 = unname(vapply(
      files, mfrmr_gpcm_repilot_hash_file, character(1)
    )),
    stringsAsFactors = FALSE
  )
  row.names(inventory) <- NULL
  data.frame(
    Package = package,
    Version = as.character(utils::packageVersion(package)),
    RuntimeRoot = normalizePath(package_root, winslash = "/", mustWork = TRUE),
    RuntimeFiles = nrow(inventory),
    PackageSHA256 = mfrmr_gpcm_repilot_hash_object(inventory),
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_repilot_runtime_package_identity <- function() {
  mfrmr_gpcm_repilot_package_content_identity("mfrmr")
}

mfrmr_gpcm_repilot_runner_identity <- function() {
  if (is.na(mfrmr_gpcm_repilot_source_dir)) {
    stop("Cannot identify the replicated-pilot source directory.",
         call. = FALSE)
  }
  components <- c(
    replicated = "gpcm-attribution-replicated-pilot-0.2.3.R",
    isolated = "gpcm-isolated-attribution-pilot-0.2.3.R",
    covering = "gpcm-stress-covering-grid-0.2.3.R"
  )
  paths <- file.path(mfrmr_gpcm_repilot_source_dir, unname(components))
  if (any(!file.exists(paths))) {
    stop("One or more validation-runner identity files are missing.",
         call. = FALSE)
  }
  out <- data.frame(
    Component = names(components),
    File = unname(components),
    SHA256 = unname(vapply(
      paths, mfrmr_gpcm_repilot_hash_file, character(1)
    )),
    stringsAsFactors = FALSE
  )
  row.names(out) <- NULL
  attr(out, "CompositeSHA256") <- mfrmr_gpcm_repilot_hash_object(out)
  out
}

mfrmr_gpcm_repilot_capability_manifest <- function() {
  packages <- c("mfrmr", "digest", "Matrix", "lpSolve", "psych")
  role <- c(
    "model_runtime", "evidence_hashing", "sparse_numerics",
    "jml_additive_recession_audit", "residual_pca_smoothing"
  )
  available <- vapply(packages, requireNamespace, logical(1), quietly = TRUE)
  versions <- vapply(seq_along(packages), function(i) {
    if (available[i]) as.character(utils::packageVersion(packages[i]))
    else NA_character_
  }, character(1))
  runtime_hashes <- vapply(seq_along(packages), function(i) {
    if (available[i]) {
      mfrmr_gpcm_repilot_package_content_identity(
        packages[i]
      )$PackageSHA256
    } else {
      NA_character_
    }
  }, character(1))
  out <- rbind(
    data.frame(
      Capability = "R",
      Role = "language_runtime",
      Available = TRUE,
      Version = paste(R.version$major, R.version$minor, sep = "."),
      RuntimeSHA256 = NA_character_,
      Platform = R.version$platform,
      stringsAsFactors = FALSE
    ),
    data.frame(
      Capability = packages,
      Role = role,
      Available = available,
      Version = versions,
      RuntimeSHA256 = runtime_hashes,
      Platform = R.version$platform,
      stringsAsFactors = FALSE
    )
  )
  external <- base::extSoftVersion()
  blas_version <- unname(external["BLAS"])
  if (is.na(blas_version) || !nzchar(blas_version)) {
    blas_version <- base::La_library()
  }
  if (is.na(blas_version) || !nzchar(blas_version)) {
    blas_version <- "R-internal-or-unreported"
  }
  runtime <- data.frame(
    Capability = c("BLAS", "LAPACK", "RNGkind"),
    Role = c(
      "linear_algebra_runtime", "linear_algebra_runtime",
      "simulation_rng_contract"
    ),
    Available = TRUE,
    Version = c(
      blas_version,
      paste0("R-", paste(R.version[c("major", "minor")], collapse = "."),
             "-internal-or-unreported"),
      paste(RNGkind(), collapse = "/")
    ),
    RuntimeSHA256 = NA_character_,
    Platform = R.version$platform,
    stringsAsFactors = FALSE
  )
  out <- rbind(out, runtime)
  row.names(out) <- NULL
  attr(out, "CompositeSHA256") <- mfrmr_gpcm_repilot_hash_object(out)
  out
}

mfrmr_gpcm_repilot_execution_identity <- function(
    manifest, tier, reps, maxit, quad_points, run_pca) {
  package <- mfrmr_gpcm_repilot_runtime_package_identity()
  runners <- mfrmr_gpcm_repilot_runner_identity()
  capabilities <- mfrmr_gpcm_repilot_capability_manifest()
  selected_manifest_hash <- mfrmr_gpcm_repilot_hash_object(manifest)
  declared_manifest_hash <- unique(as.character(manifest$ManifestHash))
  if (length(declared_manifest_hash) != 1L ||
      !nzchar(declared_manifest_hash)) {
    stop("The selected manifest does not have one declared hash.",
         call. = FALSE)
  }
  execution <- data.frame(
    CheckpointSchema = mfrmr_gpcm_repilot_checkpoint_schema(),
    Tier = as.character(tier),
    Replicates = as.integer(reps),
    Maxit = as.integer(maxit),
    QuadPoints = as.integer(quad_points),
    RunPCA = isTRUE(run_pca),
    SelectedManifestSHA256 = selected_manifest_hash,
    DeclaredManifestSHA256 = declared_manifest_hash,
    PackageSHA256 = package$PackageSHA256,
    RunnerSHA256 = attr(runners, "CompositeSHA256"),
    CapabilitySHA256 = attr(capabilities, "CompositeSHA256"),
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(execution)
  list(
    execution = execution,
    package = package,
    runners = runners,
    capabilities = capabilities
  )
}

mfrmr_gpcm_repilot_checkpoint_path <- function(checkpoint_dir,
                                                data_cell_id) {
  if (length(data_cell_id) != 1L || is.na(data_cell_id) ||
      !grepl("^[A-Za-z0-9._-]+$", data_cell_id)) {
    stop("Unsafe checkpoint data-cell identifier.", call. = FALSE)
  }
  file.path(checkpoint_dir, paste0(data_cell_id, ".rds"))
}

mfrmr_gpcm_repilot_atomic_save_rds <- function(object, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (file.exists(path)) {
    stop(sprintf("Refusing to replace existing checkpoint: %s", path),
         call. = FALSE)
  }
  temporary <- tempfile(
    pattern = paste0(".", basename(path), "-"),
    tmpdir = dirname(path), fileext = ".partial"
  )
  on.exit(unlink(temporary, force = TRUE), add = TRUE)
  saveRDS(object, temporary)
  verified <- tryCatch(readRDS(temporary), error = identity)
  if (inherits(verified, "error") ||
      !identical(mfrmr_gpcm_repilot_hash_object(object),
                 mfrmr_gpcm_repilot_hash_object(verified))) {
    stop("Temporary checkpoint verification failed.", call. = FALSE)
  }
  if (!file.rename(temporary, path)) {
    stop(sprintf("Atomic checkpoint rename failed: %s", path),
         call. = FALSE)
  }
  invisible(path)
}

mfrmr_gpcm_repilot_tiers <- function() {
  list(
    feasibility = c(
      "reference", "slope_unit", "slope_strong", "slope_near_zero_high",
      "raters_2", "assignment_weak_bridge", "category_internal_zero",
      "missing_outcome", "interaction_person_rater",
      "diagnostic_local_dependence"
    ),
    core = c(
      "reference", "slope_unit", "slope_strong", "slope_near_zero_high",
      "slope_levels_two", "slope_levels_twelve",
      "categories_k2", "categories_k7", "category_rare_interior",
      "category_dominant_middle", "category_internal_zero",
      "category_boundary_zero", "raters_2", "raters_3",
      "assignment_sparse_connected", "assignment_weak_bridge",
      "assignment_zero_shared", "assignment_routed",
      "assignment_disconnected", "missing_mcar", "missing_rater",
      "missing_outcome", "cells_repeated", "cells_occasion",
      "cells_unequal_weights", "interaction_person_rater",
      "interaction_slope_correlated", "diagnostic_local_dependence",
      "diagnostic_bias", "sample_small"
    ),
    expanded = mfrmr_gpcm_attribution_arms()$ArmId
  )
}

mfrmr_gpcm_repilot_registry <- function(
    tier = c("feasibility", "core", "expanded"), reps = NULL,
    maxit = 120L, quad_points = 7L, run_pca = TRUE) {
  mfrmr_gpcm_repilot_require_runner()
  tier <- match.arg(tier)
  arms <- mfrmr_gpcm_repilot_tiers()[[tier]]
  reps <- as.integer(if (is.null(reps)) {
    c(feasibility = 2L, core = 5L, expanded = 5L)[[tier]]
  } else reps)
  if (length(reps) != 1L || is.na(reps) || reps < 1L) {
    stop("`reps` must be one positive integer.", call. = FALSE)
  }
  maxit <- as.integer(maxit)
  quad_points <- as.integer(quad_points)
  if (length(maxit) != 1L || is.na(maxit) || maxit < 1L) {
    stop("`maxit` must be one positive integer.", call. = FALSE)
  }
  if (length(quad_points) != 1L || is.na(quad_points) ||
      quad_points < 1L) {
    stop("`quad_points` must be one positive integer.", call. = FALSE)
  }
  if (!is.logical(run_pca) || length(run_pca) != 1L || is.na(run_pca)) {
    stop("`run_pca` must be one non-missing logical value.", call. = FALSE)
  }
  run_pca <- isTRUE(run_pca)
  manifest <- mfrmr_gpcm_attribution_manifest("pilot", reps = reps)
  manifest <- manifest[manifest$ArmId %in% arms, , drop = FALSE]
  row.names(manifest) <- NULL
  data.frame(
    Tier = tier,
    Arms = length(unique(manifest$ArmId)),
    Replicates = reps,
    DataCells = length(unique(manifest$DataCellId)),
    AnalysisRows = nrow(manifest),
    RoutesPerDataCell = 4L,
    RunPCA = run_pca,
    Maxit = maxit,
    QuadPoints = quad_points,
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "pilot_required_not_frozen",
    ManifestHash = unique(manifest$ManifestHash),
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_repilot_wilson <- function(successes, trials, level = 0.95) {
  if (!is.finite(trials) || trials <= 0L) return(c(Lower = NA, Upper = NA))
  p <- successes / trials
  z <- stats::qnorm(1 - (1 - level) / 2)
  denominator <- 1 + z^2 / trials
  center <- (p + z^2 / (2 * trials)) / denominator
  half <- z * sqrt(p * (1 - p) / trials + z^2 / (4 * trials^2)) /
    denominator
  c(Lower = max(0, center - half), Upper = min(1, center + half))
}

mfrmr_gpcm_repilot_rate_row <- function(data) {
  attempted <- nrow(data)
  summarize_rate <- function(value) {
    value <- as.logical(value)
    value[is.na(value)] <- FALSE
    successes <- sum(value)
    rate <- if (attempted > 0L) successes / attempted else NA_real_
    interval <- mfrmr_gpcm_repilot_wilson(successes, attempted)
    c(
      Count = successes,
      Rate = rate,
      BernoulliMCSE = if (attempted > 0L) {
        sqrt(rate * (1 - rate) / attempted)
      } else NA_real_,
      WilsonLower = interval[["Lower"]],
      WilsonUpper = interval[["Upper"]]
    )
  }
  metrics <- list(
    Executed = data$Executed,
    GenerationSucceeded = data$GenerationSucceeded,
    FitSucceeded = data$FitSucceeded,
    InferenceReady = data$InferenceReady,
    FalseReady = data$FalseReady,
    PairIdentityViolation = data$PairIdentityViolation,
    SlopePrimaryMetricEligible = data$SlopePrimaryMetricEligible,
    NumericExternalEligible = data$NumericExternalEligible
  )
  out <- data.frame(Attempted = attempted, stringsAsFactors = FALSE)
  for (name in names(metrics)) {
    values <- summarize_rate(metrics[[name]])
    for (suffix in names(values)) {
      out[[paste0(name, suffix)]] <- as.numeric(values[[suffix]])
    }
  }
  out
}

mfrmr_gpcm_repilot_rate_summary <- function(results) {
  groups <- split(
    seq_len(nrow(results)),
    interaction(results$ArmId, results$Route, drop = TRUE, lex.order = TRUE)
  )
  rows <- lapply(groups, function(index) {
    data <- results[index, , drop = FALSE]
    cbind(
      data.frame(
        ArmId = data$ArmId[1L],
        ChangedAxis = data$ChangedAxis[1L],
        ChangedLevel = data$ChangedLevel[1L],
        Route = data$Route[1L],
        FitModel = data$FitModel[1L],
        FitMethod = data$FitMethod[1L],
        stringsAsFactors = FALSE
      ),
      mfrmr_gpcm_repilot_rate_row(data)
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_repilot_numeric_summary <- function(data, value_names,
                                                group_names) {
  key_data <- lapply(data[group_names], function(value) {
    value <- as.character(value)
    value[is.na(value)] <- "<NA>"
    value
  })
  group_key <- do.call(paste, c(key_data, sep = "\034"))
  groups <- split(
    seq_len(nrow(data)),
    group_key,
    drop = TRUE
  )
  rows <- list()
  k <- 0L
  for (index in groups) {
    group <- data[index, , drop = FALSE]
    for (metric in value_names) {
      if (!metric %in% names(group)) next
      values <- as.numeric(group[[metric]])
      values <- values[is.finite(values)]
      k <- k + 1L
      n <- length(values)
      standard_deviation <- if (n >= 2L) stats::sd(values) else NA_real_
      rows[[k]] <- cbind(
        group[1L, group_names, drop = FALSE],
        data.frame(
          Metric = metric,
          N = n,
          Mean = if (n > 0L) mean(values) else NA_real_,
          SD = standard_deviation,
          MCSE = if (n >= 2L) standard_deviation / sqrt(n) else NA_real_,
          Median = if (n > 0L) stats::median(values) else NA_real_,
          Q95 = if (n > 0L) {
            as.numeric(stats::quantile(values, 0.95, names = FALSE, type = 8))
          } else NA_real_,
          Min = if (n > 0L) min(values) else NA_real_,
          Max = if (n > 0L) max(values) else NA_real_,
          stringsAsFactors = FALSE
        )
      )
    }
  }
  if (length(rows) == 0L) return(data.frame())
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_repilot_metric_summary <- function(results) {
  mfrmr_gpcm_repilot_numeric_summary(
    results,
    c(
      "RuntimeSeconds", "Rows", "PositiveWeightRows", "MinCommonPersons",
      "MaxCategoryFraction", "NormalizedCategoryEntropy", "PersonRMSE",
      "RaterRMSE", "CriterionRMSE", "StepRMSE",
      "SlopeOptimizerLogRMSE", "PCAFirstEigenvalue"
    ),
    c("ArmId", "ChangedAxis", "ChangedLevel", "Route", "FitModel",
      "FitMethod")
  )
}

mfrmr_gpcm_repilot_contrast_summary <- function(contrasts) {
  if (nrow(contrasts) == 0L) return(data.frame())
  mfrmr_gpcm_repilot_numeric_summary(
    contrasts,
    c(
      "RuntimeSecondsDelta", "RowsDelta", "MinCommonPersonsDelta",
      "PersonRMSEDelta", "RaterRMSEDelta", "CriterionRMSEDelta",
      "StepRMSEDelta", "SlopeOptimizerLogRMSEDelta", "RuntimeRatio"
    ),
    c("ArmId.Arm", "ChangedAxis.Arm", "ChangedLevel.Arm", "Route",
      "FitModel", "FitMethod")
  )
}

mfrmr_gpcm_repilot_completeness <- function(manifest, results) {
  cells <- unique(manifest[c(
    "DataCellId", "ArmId", "Replicate", "Seed", "ManifestHash"
  )])
  rows <- lapply(seq_len(nrow(cells)), function(i) {
    data <- results[results$DataCellId == cells$DataCellId[i], , drop = FALSE]
    observed_routes <- sort(unique(as.character(data$Route)))
    expected_routes <- sort(c("GPCM_JML", "GPCM_MML", "PCM_JML", "PCM_MML"))
    successful <- data$GenerationSucceeded & !is.na(data$RetainedDataHash)
    hashes <- unique(data$RetainedDataHash[successful])
    data.frame(
      cells[i, , drop = FALSE],
      ExpectedRows = 4L,
      ObservedRows = nrow(data),
      CompleteRouteSet = identical(observed_routes, expected_routes),
      GeneratedRoutes = sum(successful),
      UniqueRetainedHashes = length(hashes),
      PairedDataIdentity = nrow(data) == 4L && all(data$PairedDataIdentity),
      PairIdentityViolation = any(data$PairIdentityViolation, na.rm = TRUE),
      MissingRoutes = paste(setdiff(expected_routes, observed_routes),
                            collapse = ";"),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_repilot_checkpoint <- function(cell_manifest, results, identity) {
  structure(
    list(
      schema = mfrmr_gpcm_repilot_checkpoint_schema(),
      execution_sha256 = identity$execution$ExecutionSHA256,
      data_cell_id = unique(as.character(cell_manifest$DataCellId)),
      cell_manifest_sha256 = mfrmr_gpcm_repilot_hash_object(cell_manifest),
      results_sha256 = mfrmr_gpcm_repilot_hash_object(results),
      cell_manifest = cell_manifest,
      results = results,
      completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ),
    class = "mfrmr_gpcm_repilot_checkpoint"
  )
}

mfrmr_gpcm_repilot_validate_checkpoint <- function(
    checkpoint, cell_manifest, identity) {
  fail <- function(message) {
    stop(paste0("Checkpoint validation failed: ", message), call. = FALSE)
  }
  if (!inherits(checkpoint, "mfrmr_gpcm_repilot_checkpoint")) {
    fail("unexpected object class")
  }
  if (!identical(checkpoint$schema,
                 mfrmr_gpcm_repilot_checkpoint_schema())) {
    fail("schema mismatch")
  }
  expected_execution <- as.character(identity$execution$ExecutionSHA256)
  if (!identical(as.character(checkpoint$execution_sha256),
                 expected_execution)) {
    fail("execution identity mismatch")
  }
  expected_cell <- unique(as.character(cell_manifest$DataCellId))
  if (length(expected_cell) != 1L ||
      !identical(as.character(checkpoint$data_cell_id), expected_cell)) {
    fail("data-cell identity mismatch")
  }
  if (!identical(
    as.character(checkpoint$cell_manifest_sha256),
    mfrmr_gpcm_repilot_hash_object(cell_manifest)
  )) {
    fail("cell manifest hash mismatch")
  }
  results <- checkpoint$results
  if (!is.data.frame(results) || nrow(results) != nrow(cell_manifest)) {
    fail("result row count mismatch")
  }
  required_result_fields <- c(
    "ScenarioId", "DataCellId", "Route", "ManifestHash"
  )
  if (!all(required_result_fields %in% names(results))) {
    fail("result schema mismatch")
  }
  if (!identical(
    as.character(checkpoint$results_sha256),
    mfrmr_gpcm_repilot_hash_object(results)
  )) {
    fail("result payload hash mismatch")
  }
  if (!identical(sort(as.character(results$ScenarioId)),
                 sort(as.character(cell_manifest$ScenarioId)))) {
    fail("scenario identity mismatch")
  }
  if (!identical(sort(as.character(results$Route)),
                 sort(as.character(cell_manifest$Route)))) {
    fail("route identity mismatch")
  }
  if (any(as.character(results$DataCellId) != expected_cell)) {
    fail("result data-cell mismatch")
  }
  declared_hash <- unique(as.character(cell_manifest$ManifestHash))
  if (length(declared_hash) != 1L ||
      any(as.character(results$ManifestHash) != declared_hash)) {
    fail("declared manifest hash mismatch")
  }
  invisible(TRUE)
}

mfrmr_gpcm_repilot_read_checkpoint <- function(
    path, cell_manifest, identity) {
  checkpoint <- tryCatch(readRDS(path), error = function(error) error)
  if (inherits(checkpoint, "error")) {
    stop(
      sprintf("Checkpoint validation failed: unreadable file %s (%s)",
              basename(path), conditionMessage(checkpoint)),
      call. = FALSE
    )
  }
  mfrmr_gpcm_repilot_validate_checkpoint(
    checkpoint, cell_manifest, identity
  )
  checkpoint
}

mfrmr_gpcm_repilot_interruption <- function(new_cells) {
  structure(
    list(
      message = sprintf(
        "Intentional checkpoint interruption after %d new data cell(s).",
        new_cells
      ),
      call = NULL
    ),
    class = c("mfrmr_gpcm_repilot_interruption", "error", "condition")
  )
}

mfrmr_gpcm_repilot_build_run <- function(manifest, manifest_audit, identity,
                                          run_pca, maxit, quad_points,
                                          progress, checkpoint_dir = NULL,
                                          resume = FALSE,
                                          interrupt_after_cells = NULL) {
  cell_ids <- unique(as.character(manifest$DataCellId))
  expected_paths <- if (is.null(checkpoint_dir)) character(0) else {
    vapply(
      cell_ids,
      function(id) mfrmr_gpcm_repilot_checkpoint_path(checkpoint_dir, id),
      character(1), USE.NAMES = FALSE
    )
  }
  if (!is.null(checkpoint_dir)) {
    dir.create(checkpoint_dir, recursive = TRUE, showWarnings = FALSE)
    existing <- list.files(
      checkpoint_dir, pattern = "[.]rds$", full.names = TRUE
    )
    unexpected <- setdiff(basename(existing), basename(expected_paths))
    if (length(unexpected) > 0L) {
      stop(
        paste0(
          "Checkpoint directory contains unexpected RDS files: ",
          paste(unexpected, collapse = ", ")
        ),
        call. = FALSE
      )
    }
    if (!isTRUE(resume) && any(file.exists(expected_paths))) {
      stop(
        "Existing checkpoints require `resume = TRUE`; refusing to mix runs.",
        call. = FALSE
      )
    }
  } else if (isTRUE(resume)) {
    stop("`resume = TRUE` requires a checkpoint directory.", call. = FALSE)
  }
  if (!is.null(interrupt_after_cells) && is.null(checkpoint_dir)) {
    stop("Intentional interruption requires a checkpoint directory.",
         call. = FALSE)
  }

  cell_results <- vector("list", length(cell_ids))
  ledger <- vector("list", length(cell_ids))
  new_cells <- 0L
  for (cell_index in seq_along(cell_ids)) {
    cell_id <- cell_ids[cell_index]
    cell_manifest <- manifest[
      manifest$DataCellId == cell_id, , drop = FALSE
    ]
    checkpoint_path <- if (is.null(checkpoint_dir)) NA_character_ else {
      mfrmr_gpcm_repilot_checkpoint_path(checkpoint_dir, cell_id)
    }
    resumed <- !is.na(checkpoint_path) && file.exists(checkpoint_path)
    if (resumed) {
      checkpoint <- mfrmr_gpcm_repilot_read_checkpoint(
        checkpoint_path, cell_manifest, identity
      )
      results <- checkpoint$results
      if (isTRUE(progress)) {
        message(sprintf("[cell %d/%d] %s (resumed)", cell_index,
                        length(cell_ids), cell_id))
      }
    } else {
      if (isTRUE(progress)) {
        message(sprintf("[cell %d/%d] %s", cell_index,
                        length(cell_ids), cell_id))
      }
      rows <- lapply(seq_len(nrow(cell_manifest)), function(i) {
        if (isTRUE(progress)) {
          message(sprintf("  [route %d/%d] %s", i, nrow(cell_manifest),
                          cell_manifest$ScenarioId[i]))
        }
        mfrmr_gpcm_attribution_run_one(
          cell_manifest[i, , drop = FALSE], run_pca = run_pca,
          maxit = maxit, quad_points = quad_points
        )
      })
      results <- mfrmr_gpcm_attribution_pair_audit(
        mfrmr_gpcm_attribution_bind(rows)
      )
      checkpoint <- mfrmr_gpcm_repilot_checkpoint(
        cell_manifest, results, identity
      )
      mfrmr_gpcm_repilot_validate_checkpoint(
        checkpoint, cell_manifest, identity
      )
      if (!is.null(checkpoint_dir)) {
        mfrmr_gpcm_repilot_atomic_save_rds(
          checkpoint, checkpoint_path
        )
      }
      new_cells <- new_cells + 1L
    }
    cell_results[[cell_index]] <- results
    ledger[[cell_index]] <- data.frame(
      DataCellId = cell_id,
      Source = if (resumed) "resumed_checkpoint" else "executed",
      ResultRows = nrow(results),
      CompleteRouteSet = identical(
        sort(as.character(results$Route)),
        sort(c("GPCM_JML", "GPCM_MML", "PCM_JML", "PCM_MML"))
      ),
      ExecutionSHA256 = identity$execution$ExecutionSHA256,
      CheckpointFile = if (is.na(checkpoint_path)) NA_character_ else {
        basename(checkpoint_path)
      },
      CheckpointSHA256 = if (is.na(checkpoint_path)) NA_character_ else {
        mfrmr_gpcm_repilot_hash_file(checkpoint_path)
      },
      stringsAsFactors = FALSE
    )
    if (!is.null(interrupt_after_cells) &&
        new_cells >= interrupt_after_cells) {
      stop(mfrmr_gpcm_repilot_interruption(new_cells))
    }
  }

  results <- mfrmr_gpcm_attribution_pair_audit(
    mfrmr_gpcm_attribution_bind(cell_results)
  )
  results <- results[match(manifest$ScenarioId, results$ScenarioId),
                     , drop = FALSE]
  row.names(results) <- NULL
  contrasts <- mfrmr_gpcm_attribution_contrasts(results, manifest)
  summary <- data.frame(
    Profile = "pilot",
    SelectedRows = nrow(manifest),
    DataCells = length(cell_ids),
    ExecutedRows = sum(results$Executed),
    FitSucceededRows = sum(results$FitSucceeded),
    ExpectedFailClosedRows = sum(results$RunState == "expected_fail_closed"),
    FalseReadyRows = sum(results$FalseReady, na.rm = TRUE),
    PairIdentityViolations = sum(results$PairIdentityViolation, na.rm = TRUE),
    PrimarySlopeEligibleRows = sum(
      results$SlopePrimaryMetricEligible, na.rm = TRUE
    ),
    NumericExternalEligibleRows = 0L,
    ThresholdStatus = "pilot_required_not_frozen",
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  run <- structure(
    list(
      manifest = manifest,
      manifest_audit = manifest_audit,
      results = results,
      contrasts = contrasts,
      summary = summary,
      confirmation_authorized = FALSE,
      interpretation = paste0(
        "paired_internal_calibration_only;_optimizer_slope_metrics_are_",
        "diagnostic_traces;_no_causal_or_external_equivalence_claim"
      ),
      session_info = utils::sessionInfo()
    ),
    class = "mfrmr_gpcm_isolated_attribution"
  )
  list(
    run = run,
    checkpoint_ledger = do.call(rbind, ledger),
    new_cells = new_cells,
    resumed_cells = sum(vapply(
      ledger, function(x) identical(x$Source, "resumed_checkpoint"),
      logical(1)
    ))
  )
}

mfrmr_gpcm_repilot_analyze <- function(run, tier) {
  if (!inherits(run, "mfrmr_gpcm_isolated_attribution")) {
    stop("`run` must be an isolated-attribution pilot result.", call. = FALSE)
  }
  rates <- mfrmr_gpcm_repilot_rate_summary(run$results)
  metrics <- mfrmr_gpcm_repilot_metric_summary(run$results)
  contrast_metrics <- mfrmr_gpcm_repilot_contrast_summary(run$contrasts)
  completeness <- mfrmr_gpcm_repilot_completeness(run$manifest, run$results)
  total_runtime <- sum(run$results$RuntimeSeconds, na.rm = TRUE)
  data_cells <- length(unique(run$results$DataCellId))
  summary <- data.frame(
    Tier = tier,
    AnalysisRows = nrow(run$results),
    DataCells = data_cells,
    CompleteCells = sum(completeness$CompleteRouteSet),
    IdentityValidCells = sum(completeness$PairedDataIdentity),
    PairIdentityViolations = sum(completeness$PairIdentityViolation),
    FitFailures = sum(!run$results$FitSucceeded),
    FalseReadyRows = sum(run$results$FalseReady, na.rm = TRUE),
    PrimarySlopeEligibleRows = sum(
      run$results$SlopePrimaryMetricEligible, na.rm = TRUE
    ),
    NumericExternalEligibleRows = sum(
      run$results$NumericExternalEligible, na.rm = TRUE
    ),
    TotalFitRuntimeSeconds = total_runtime,
    MeanFitRuntimeSeconds = mean(run$results$RuntimeSeconds, na.rm = TRUE),
    RuntimePerDataCellSeconds = total_runtime / max(1L, data_cells),
    ThresholdStatus = "pilot_required_not_frozen",
    ConfirmationAuthorized = FALSE,
    MinimumReplicatesForCriterionFreeze = NA_integer_,
    Interpretation = paste0(
      "feasibility_and_variance_signal_only;_small_n_MCSE_and_Wilson_",
      "intervals_do_not_authorize_threshold_selection"
    ),
    stringsAsFactors = FALSE
  )
  list(
    summary = summary,
    rate_summary = rates,
    metric_summary = metrics,
    contrast_metric_summary = contrast_metrics,
    completeness = completeness
  )
}

mfrmr_gpcm_repilot_validate_completion <- function(
    output_dir, expected_execution_sha256 = NULL) {
  marker_path <- file.path(output_dir, "run-complete.rds")
  marker <- tryCatch(readRDS(marker_path), error = function(error) error)
  if (inherits(marker, "error")) {
    stop(
      sprintf("Completion marker is unreadable: %s",
              conditionMessage(marker)),
      call. = FALSE
    )
  }
  if (!inherits(marker, "mfrmr_gpcm_repilot_completion") ||
      !identical(marker$schema, "mfrmr-gpcm-repilot-completion-v1")) {
    stop("Completion marker schema mismatch.", call. = FALSE)
  }
  if (!is.null(expected_execution_sha256) &&
      !identical(as.character(marker$execution_sha256),
                 as.character(expected_execution_sha256))) {
    stop("Completion marker execution identity mismatch.", call. = FALSE)
  }
  inventory <- marker$artifacts
  if (!is.data.frame(inventory) ||
      !all(c("File", "SHA256") %in% names(inventory)) ||
      nrow(inventory) < 1L || anyDuplicated(inventory$File)) {
    stop("Completion artifact inventory schema mismatch.", call. = FALSE)
  }
  if (!identical(
    as.character(marker$artifact_inventory_sha256),
    mfrmr_gpcm_repilot_hash_object(inventory)
  )) {
    stop("Completion artifact inventory hash mismatch.", call. = FALSE)
  }
  relative <- gsub("\\\\", "/", as.character(inventory$File))
  unsafe <- !nzchar(relative) |
    grepl("^(?:[A-Za-z]:|/)", relative, perl = TRUE) |
    grepl("(?:^|/)\\.\\.(?:/|$)", relative, perl = TRUE)
  if (any(unsafe)) {
    stop("Completion artifact inventory contains an unsafe path.",
         call. = FALSE)
  }
  paths <- file.path(output_dir, inventory$File)
  if (any(!file.exists(paths))) {
    stop(
      paste0(
        "Completion marker references missing artifacts: ",
        paste(inventory$File[!file.exists(paths)], collapse = ", ")
      ),
      call. = FALSE
    )
  }
  observed <- vapply(paths, mfrmr_gpcm_repilot_hash_file, character(1))
  mismatch <- observed != inventory$SHA256
  if (any(mismatch)) {
    stop(
      paste0(
        "Completion artifact hash mismatch: ",
        paste(inventory$File[mismatch], collapse = ", ")
      ),
      call. = FALSE
    )
  }
  invisible(marker)
}

mfrmr_gpcm_repilot_write <- function(x, output_dir) {
  if (!inherits(x, "mfrmr_gpcm_attribution_replicated_pilot") ||
      is.null(x$run) || is.null(x$analysis)) {
    stop("`x` must contain a completed replicated pilot and analysis.",
         call. = FALSE)
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(x$registry, file.path(output_dir, "pilot-registry.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$run$manifest,
                   file.path(output_dir, "scenario-manifest.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$run$results, file.path(output_dir, "run-results.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$run$contrasts,
                   file.path(output_dir, "paired-contrasts.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$analysis$summary, file.path(output_dir, "summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$analysis$rate_summary,
                   file.path(output_dir, "rate-summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$analysis$metric_summary,
                   file.path(output_dir, "metric-summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$analysis$contrast_metric_summary,
                   file.path(output_dir, "contrast-metric-summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$analysis$completeness,
                   file.path(output_dir, "completeness-ledger.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$execution_identity,
                   file.path(output_dir, "execution-identity.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$package_identity,
                   file.path(output_dir, "package-identity.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$runner_identity,
                   file.path(output_dir, "runner-identity.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$capability_manifest,
                   file.path(output_dir, "capability-manifest.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$checkpoint_ledger,
                   file.path(output_dir, "checkpoint-ledger.csv"),
                   row.names = FALSE, na = "")
  final_rds <- file.path(
    output_dir, "gpcm-attribution-replicated-pilot.rds"
  )
  saveRDS(x, final_rds)
  artifact_names <- c(
    "pilot-registry.csv", "scenario-manifest.csv", "run-results.csv",
    "paired-contrasts.csv", "summary.csv", "rate-summary.csv",
    "metric-summary.csv", "contrast-metric-summary.csv",
    "completeness-ledger.csv", "execution-identity.csv",
    "package-identity.csv", "runner-identity.csv",
    "capability-manifest.csv", "checkpoint-ledger.csv",
    "gpcm-attribution-replicated-pilot.rds"
  )
  checkpoint_paths <- file.path(
    output_dir, "checkpoints", x$checkpoint_ledger$CheckpointFile
  )
  declared_checkpoints <- !is.na(x$checkpoint_ledger$CheckpointFile)
  if (any(declared_checkpoints & !file.exists(checkpoint_paths))) {
    stop("A checkpoint listed in the ledger is missing from the bundle.",
         call. = FALSE)
  }
  checkpoint_paths <- checkpoint_paths[declared_checkpoints]
  paths <- c(file.path(output_dir, artifact_names), checkpoint_paths)
  relative <- c(
    artifact_names,
    file.path("checkpoints", basename(checkpoint_paths))
  )
  relative <- gsub("\\\\", "/", relative)
  inventory <- data.frame(
    File = relative,
    SHA256 = unname(vapply(
      paths, mfrmr_gpcm_repilot_hash_file, character(1)
    )),
    stringsAsFactors = FALSE
  )
  row.names(inventory) <- NULL
  marker <- structure(
    list(
      schema = "mfrmr-gpcm-repilot-completion-v1",
      execution_sha256 = x$execution_identity$ExecutionSHA256,
      artifacts = inventory,
      artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
      completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ),
    class = "mfrmr_gpcm_repilot_completion"
  )
  marker_path <- file.path(output_dir, "run-complete.rds")
  mfrmr_gpcm_repilot_atomic_save_rds(marker, marker_path)
  mfrmr_gpcm_repilot_validate_completion(
    output_dir, x$execution_identity$ExecutionSHA256
  )
  invisible(x)
}

mfrmr_run_gpcm_attribution_replicated_pilot <- function(
    tier = c("feasibility", "core", "expanded"), reps = NULL,
    maxit = 120L, quad_points = 7L, run_pca = TRUE,
    dry_run = FALSE, progress = interactive(), output_dir = NULL,
    checkpoint_dir = NULL, resume = FALSE, interrupt_after_cells = NULL,
    authorize_core = FALSE, authorize_expanded = FALSE) {
  mfrmr_gpcm_repilot_require_runner()
  tier <- match.arg(tier)
  if (tier == "core" && !isTRUE(dry_run) && !isTRUE(authorize_core)) {
    stop("Core-tier execution requires `authorize_core = TRUE`.",
         call. = FALSE)
  }
  if (tier == "expanded" && !isTRUE(dry_run) &&
      !isTRUE(authorize_expanded)) {
    stop("Expanded-tier execution requires `authorize_expanded = TRUE`.",
         call. = FALSE)
  }
  arms <- mfrmr_gpcm_repilot_tiers()[[tier]]
  maxit <- as.integer(maxit)
  quad_points <- as.integer(quad_points)
  if (length(maxit) != 1L || is.na(maxit) || maxit < 1L) {
    stop("`maxit` must be one positive integer.", call. = FALSE)
  }
  if (length(quad_points) != 1L || is.na(quad_points) ||
      quad_points < 1L) {
    stop("`quad_points` must be one positive integer.", call. = FALSE)
  }
  if (!is.logical(run_pca) || length(run_pca) != 1L || is.na(run_pca)) {
    stop("`run_pca` must be one non-missing logical value.", call. = FALSE)
  }
  run_pca <- isTRUE(run_pca)
  registry <- mfrmr_gpcm_repilot_registry(
    tier, reps = reps, maxit = maxit, quad_points = quad_points,
    run_pca = run_pca
  )
  if (!is.null(interrupt_after_cells)) {
    interrupt_after_cells <- as.integer(interrupt_after_cells)
    if (length(interrupt_after_cells) != 1L ||
        is.na(interrupt_after_cells) || interrupt_after_cells < 1L) {
      stop("`interrupt_after_cells` must be one positive integer.",
           call. = FALSE)
    }
  }
  manifest_all <- mfrmr_gpcm_attribution_manifest(
    "pilot", reps = registry$Replicates
  )
  manifest_audit <- mfrmr_gpcm_attribution_manifest_audit(manifest_all)
  manifest <- manifest_all[manifest_all$ArmId %in% arms, , drop = FALSE]
  row.names(manifest) <- NULL
  identity <- mfrmr_gpcm_repilot_execution_identity(
    manifest = manifest, tier = tier, reps = registry$Replicates,
    maxit = maxit, quad_points = quad_points, run_pca = run_pca
  )
  if (isTRUE(dry_run)) {
    return(structure(
      list(
        registry = registry,
        arms = arms,
        manifest = manifest,
        run = NULL,
        analysis = NULL,
        execution_identity = identity$execution,
        package_identity = identity$package,
        runner_identity = identity$runners,
        capability_manifest = identity$capabilities,
        confirmation_authorized = FALSE
      ),
      class = "mfrmr_gpcm_attribution_replicated_pilot"
    ))
  }
  if (!is.null(output_dir)) {
    default_checkpoint_dir <- file.path(output_dir, "checkpoints")
    if (is.null(checkpoint_dir)) {
      checkpoint_dir <- default_checkpoint_dir
    } else {
      normalized_requested <- tolower(normalizePath(
        checkpoint_dir, winslash = "/", mustWork = FALSE
      ))
      normalized_default <- tolower(normalizePath(
        default_checkpoint_dir, winslash = "/", mustWork = FALSE
      ))
      if (!identical(normalized_requested, normalized_default)) {
        stop(
          "When `output_dir` is set, checkpoints must use its `checkpoints` directory.",
          call. = FALSE
        )
      }
    }
  }
  if (!is.null(output_dir) &&
      file.exists(file.path(output_dir, "run-complete.rds"))) {
    mfrmr_gpcm_repilot_validate_completion(
      output_dir, identity$execution$ExecutionSHA256
    )
    stop(
      "Output directory already contains a valid completed run.",
      call. = FALSE
    )
  }
  execution <- mfrmr_gpcm_repilot_build_run(
    manifest = manifest,
    manifest_audit = manifest_audit,
    identity = identity,
    run_pca = run_pca,
    maxit = maxit,
    quad_points = quad_points,
    progress = progress,
    checkpoint_dir = checkpoint_dir,
    resume = resume,
    interrupt_after_cells = interrupt_after_cells
  )
  run <- execution$run
  analysis <- mfrmr_gpcm_repilot_analyze(run, tier)
  out <- structure(
    list(
      registry = registry,
      arms = arms,
      run = run,
      analysis = analysis,
      execution_identity = identity$execution,
      package_identity = identity$package,
      runner_identity = identity$runners,
      capability_manifest = identity$capabilities,
      checkpoint_ledger = execution$checkpoint_ledger,
      checkpoint_summary = data.frame(
        NewCells = execution$new_cells,
        ResumedCells = execution$resumed_cells,
        TotalCells = length(unique(manifest$DataCellId)),
        stringsAsFactors = FALSE
      ),
      confirmation_authorized = FALSE,
      session_info = utils::sessionInfo()
    ),
    class = "mfrmr_gpcm_attribution_replicated_pilot"
  )
  if (!is.null(output_dir)) {
    mfrmr_gpcm_repilot_write(out, output_dir)
  }
  out
}
