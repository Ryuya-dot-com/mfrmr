# mfrmr 0.2.3 current-default paired-owner GPCM smoke P1s
#
# P1s executes only the eight P1r routes.  It reuses the existing owner data
# generator and public fit/manifest/replay/summary paths, retaining full source
# owner, fitted owner, estimator-scale, support, and runtime identity.  No
# recovery threshold, owner ranking, external comparison, or replication is
# authorized.

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

mfrmr_gocs_p1s_specification <- "0.2.3-draft.1"
mfrmr_gocs_p1s_contract <- "mfrmr_gpcm_owner_current_default_smoke_p1s_v1"
mfrmr_gocs_p1s_dependency_contract <-
  "mfrmr_gpcm_owner_current_default_contract_p1r_v1"
mfrmr_gocs_p1s_dependency_sha256 <-
  "e029a4cd8b0a42bd593fa4a1d56b539389de20af1c8f766592d7954e1222b75e"
mfrmr_gocs_p1s_generator_sha256 <-
  "b71ee33aa39d07431f43505d70dc531f0abb9db2529ff9a433ea74b4b1dbfb16"
mfrmr_gocs_p1s_covering_sha256 <-
  "02d068594a4253539d74f517e293640e9a0da3d38269a15c63951ed73085a3a6"
mfrmr_gocs_p1s_support_sha256 <-
  "8c895c17bde1f916b5369b5e6d4dfebe64502a7acf5e55a971ec446514477aa1"

mfrmr_gocs_p1s_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gocs_p1s_hash_object <- function(object) {
  mfrmr_gocs_p1s_assert(requireNamespace("digest", quietly = TRUE),
                        "P1s requires package `digest`.")
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_gocs_p1s_hash_file <- function(path) {
  mfrmr_gocs_p1s_assert(file.exists(path),
                        paste0("P1s cannot hash missing file: ", path))
  digest::digest(path, algo = "sha256", file = TRUE, serialize = FALSE)
}

mfrmr_gocs_p1s_validation_dir <- local({
  source_files <- unlist(lapply(sys.frames(), function(frame) {
    as.character(frame$ofile %||% character(0))
  }), use.names = FALSE)
  hit <- source_files[grepl(
    "gpcm-owner-current-default-smoke-p1s-0[.]2[.]3[.]R$", source_files
  )]
  roots <- c(
    getwd(), file.path(getwd(), ".."), file.path(getwd(), "..", ".."),
    file.path(getwd(), "..", "..", "..")
  )
  candidates <- c(
    if (length(hit) > 0L) dirname(hit[length(hit)]) else character(0),
    roots, file.path(roots, "inst", "validation")
  )
  candidates <- unique(normalizePath(
    candidates, winslash = "/", mustWork = FALSE
  ))
  found <- candidates[file.exists(file.path(
    candidates, "gpcm-owner-current-default-smoke-p1s-0.2.3.R"
  ))]
  if (length(found) == 0L) NA_character_ else found[1L]
})

mfrmr_gocs_p1s_paths <- function() {
  files <- c(
    contract = "gpcm-owner-current-default-contract-p1r-0.2.3.R",
    generator = "gpcm-owner-specific-pilot-0.2.3.R",
    covering = "gpcm-stress-covering-grid-0.2.3.R",
    support = "gpcm-attribution-replicated-pilot-0.2.3.R",
    runner = "gpcm-owner-current-default-smoke-p1s-0.2.3.R"
  )
  out <- file.path(mfrmr_gocs_p1s_validation_dir, unname(files))
  names(out) <- names(files)
  out
}

mfrmr_gocs_p1s_require_support <- function() {
  paths <- mfrmr_gocs_p1s_paths()
  mfrmr_gocs_p1s_assert(all(file.exists(paths)),
                        "P1s source dependencies are incomplete.")
  expected <- c(
    contract = mfrmr_gocs_p1s_dependency_sha256,
    generator = mfrmr_gocs_p1s_generator_sha256,
    covering = mfrmr_gocs_p1s_covering_sha256,
    support = mfrmr_gocs_p1s_support_sha256
  )
  observed <- vapply(paths[names(expected)], mfrmr_gocs_p1s_hash_file,
                     character(1L))
  mfrmr_gocs_p1s_assert(identical(unname(observed), unname(expected)),
                        "P1s source dependency identity drifted.")
  target <- environment(mfrmr_gocs_p1s_require_support)
  if (!exists("mfrmr_gocd_p1r_manifest", envir = target, inherits = TRUE)) {
    sys.source(paths[["contract"]], envir = target)
  }
  if (!exists("mfrmr_gpcm_owner_build", envir = target, inherits = TRUE)) {
    sys.source(paths[["generator"]], envir = target)
  }
  if (!exists("mfrmr_gpcm_stress_fun", envir = target, inherits = TRUE)) {
    sys.source(paths[["covering"]], envir = target)
  }
  if (!exists(
      "mfrmr_gpcm_repilot_runtime_package_identity",
      envir = target, inherits = TRUE
  )) {
    sys.source(paths[["support"]], envir = target)
  }
  required <- c(
    "mfrmr_gocd_p1r_manifest", "mfrmr_gocd_p1r_surface_contract",
    "mfrmr_gpcm_owner_build", "mfrmr_gpcm_repilot_runtime_package_identity"
  )
  mfrmr_gocs_p1s_assert(all(vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )), "P1s support functions did not load.")
  invisible(paths)
}

mfrmr_gocs_p1s_capture <- function(expression) {
  warnings <- character(0)
  value <- tryCatch(
    withCallingHandlers(
      expression,
      warning = function(warning) {
        warnings <<- c(warnings, conditionMessage(warning))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(error) error
  )
  list(value = value, warnings = unique(warnings))
}

mfrmr_gocs_p1s_context <- function() {
  paths <- mfrmr_gocs_p1s_require_support()
  mfrmr_gocs_p1s_assert(
    as.character(utils::packageVersion("mfrmr")) == "0.2.3",
    "P1s requires the loaded mfrmr 0.2.3 development runtime."
  )
  runtime <- mfrmr_gpcm_repilot_runtime_package_identity()
  runner_sha <- mfrmr_gocs_p1s_hash_file(paths[["runner"]])
  manifest <- mfrmr_gocd_p1r_manifest(
    runtime_identity = runtime$PackageSHA256,
    execution_runner_sha256 = runner_sha,
    contract_sha256 = mfrmr_gocs_p1s_dependency_sha256
  )
  source_identity <- data.frame(
    Component = names(paths),
    File = basename(paths),
    SHA256 = unname(vapply(paths, mfrmr_gocs_p1s_hash_file, character(1L))),
    stringsAsFactors = FALSE
  )
  execution <- data.frame(
    Schema = "mfrmr-gpcm-owner-current-default-smoke-execution-v1",
    Specification = mfrmr_gocs_p1s_specification,
    RuntimeIdentity = runtime$PackageSHA256,
    RuntimeVersion = runtime$Version,
    RunnerSHA256 = runner_sha,
    ContractSHA256 = mfrmr_gocs_p1s_dependency_sha256,
    GeneratorSHA256 = mfrmr_gocs_p1s_generator_sha256,
    CoveringSHA256 = mfrmr_gocs_p1s_covering_sha256,
    SupportSHA256 = mfrmr_gocs_p1s_support_sha256,
    ManifestSHA256 = unique(manifest$ManifestSHA256),
    PlannedDatasets = 2L,
    PlannedRoutes = 8L,
    QuadPointsMML = 31L,
    Maxit = 400L,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gocs_p1s_hash_object(execution)
  list(
    paths = paths, runtime = runtime, manifest = manifest,
    source_identity = source_identity, execution_identity = execution
  )
}

mfrmr_gocs_p1s_build_datasets <- function(manifest) {
  rows <- manifest[!duplicated(manifest$DataScenarioId), , drop = FALSE]
  datasets <- vector("list", nrow(rows))
  ledger <- vector("list", nrow(manifest))
  names(datasets) <- rows$DataScenarioId
  for (i in seq_len(nrow(rows))) {
    row <- rows[i, , drop = FALSE]
    build_row <- data.frame(
      SlopeOwner = row$SourceSlopeOwner,
      NPersons = row$NPersons,
      NRaters = row$NRaters,
      NCriteria = row$NCriteria,
      NCategories = row$NCategories,
      DesignId = "core",
      Seed = row$DataSeed,
      stringsAsFactors = FALSE
    )
    built <- mfrmr_gpcm_owner_build(build_row)
    observed <- sort(unique(as.integer(built$data$Score)))
    mfrmr_gocs_p1s_assert(
      identical(observed, 1:4),
      paste0("P1s generated support drifted for ", row$DataScenarioId, ".")
    )
    datasets[[row$DataScenarioId]] <- built
  }
  for (i in seq_len(nrow(manifest))) {
    row <- manifest[i, , drop = FALSE]
    data <- datasets[[row$DataScenarioId]]$data
    counts <- table(factor(as.integer(data$Score), levels = 1:4))
    ledger[[i]] <- cbind(
      row[, mfrmr_gocd_p1r_identity_fields(), drop = FALSE],
      data.frame(
        RouteId = row$RouteId,
        DataScenarioId = row$DataScenarioId,
        DataSeed = row$DataSeed,
        DataSHA256 = mfrmr_gocs_p1s_hash_object(data),
        Rows = nrow(data),
        Persons = length(unique(data$Person)),
        Raters = length(unique(data$Rater)),
        Criteria = length(unique(data$Criterion)),
        CategoryCounts = paste(as.integer(counts), collapse = ";"),
        stringsAsFactors = FALSE
      )
    )
  }
  ledger <- do.call(rbind, ledger)
  rownames(ledger) <- NULL
  for (id in unique(ledger$DataScenarioId)) {
    index <- ledger$DataScenarioId == id
    mfrmr_gocs_p1s_assert(
      length(unique(ledger$DataSHA256[index])) == 1L,
      paste0("P1s common-data hash pairing failed for ", id, ".")
    )
  }
  list(datasets = datasets, ledger = ledger)
}

mfrmr_gocs_p1s_setting <- function(table, key) {
  if (!is.data.frame(table) || !all(c("Setting", "Value") %in% names(table))) {
    return(NA_character_)
  }
  value <- as.character(table$Value[table$Setting == key])
  if (length(value) == 1L) value else NA_character_
}

mfrmr_gocs_p1s_numeric_scalar <- function(value) {
  value <- suppressWarnings(as.numeric(value %||% NA_real_))
  if (length(value) >= 1L) value[[1L]] else NA_real_
}

mfrmr_gocs_p1s_expected_identification <- function(estimator) {
  if (identical(as.character(estimator), "MML")) {
    "free_population"
  } else {
    "not_applicable_jml"
  }
}

mfrmr_gocs_p1s_empty_result <- function(row, data_sha) {
  cbind(
    row[, mfrmr_gocd_p1r_identity_fields(), drop = FALSE],
    data.frame(
      RouteId = row$RouteId,
      DataScenarioId = row$DataScenarioId,
      DataSHA256 = data_sha,
      Executed = FALSE,
      FitSucceeded = FALSE,
      Error = NA_character_,
      Warnings = NA_character_,
      ConfigIdentityMatch = FALSE,
      PublicManifestIdentityMatch = FALSE,
      ReplayIdentityMatch = FALSE,
      PublicSummaryIdentityMatch = FALSE,
      CodeConverged = FALSE,
      FitReadiness = NA_character_,
      InferenceReady = FALSE,
      Objective = NA_real_,
      PopulationSD = NA_real_,
      ReplaySHA256 = NA_character_,
      stringsAsFactors = FALSE
    )
  )
}

mfrmr_gocs_p1s_run_one <- function(row, built) {
  data <- built$data
  data_sha <- mfrmr_gocs_p1s_hash_object(data)
  out <- mfrmr_gocs_p1s_empty_result(row, data_sha)
  args <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1L,
    rating_max = 4L,
    keep_original = TRUE,
    model = "GPCM",
    method = as.character(row$Estimator),
    step_facet = as.character(row$StepOwner),
    slope_facet = as.character(row$SlopeOwner),
    quad_points = 31L,
    maxit = 400L,
    attach_diagnostics = FALSE,
    gpcm_mml_identification = "free_population"
  )
  fitted <- mfrmr_gocs_p1s_capture(do.call(
    getFromNamespace("fit_mfrm", "mfrmr"), args
  ))
  out$Executed <- TRUE
  out$Warnings <- paste(fitted$warnings, collapse = " | ")
  if (inherits(fitted$value, "error")) {
    out$Error <- conditionMessage(fitted$value)
    return(list(result = out, fit = NULL, replay = NULL))
  }
  fit <- fitted$value
  cfg <- fit$config %||% list()
  replay_inputs <- cfg$replay_inputs %||% list()
  population_active <- isTRUE((fit$population %||% list())$active)
  expected_population <- identical(as.character(row$Estimator), "MML")
  expected_identification <- mfrmr_gocs_p1s_expected_identification(
    row$Estimator
  )
  config_match <- identical(as.character(cfg$model), "GPCM") &&
    identical(as.character(cfg$slope_facet), as.character(row$SlopeOwner)) &&
    identical(as.character(cfg$step_facet), as.character(row$StepOwner)) &&
    identical(as.character(cfg$gpcm_mml_identification),
              expected_identification) &&
    identical(as.integer(cfg$rating_min), 1L) &&
    identical(as.integer(cfg$rating_max), 4L) &&
    identical(population_active, expected_population) &&
    identical(as.character(replay_inputs$gpcm_mml_identification),
              "free_population") &&
    identical(as.integer(replay_inputs$rating_min), 1L) &&
    identical(as.integer(replay_inputs$rating_max), 4L)

  public_manifest <- getFromNamespace("build_mfrm_manifest", "mfrmr")(fit)
  settings <- public_manifest$model_settings
  manifest_match <- identical(
    mfrmr_gocs_p1s_setting(settings, "slope_facet"),
    as.character(row$SlopeOwner)
  ) && identical(
    mfrmr_gocs_p1s_setting(settings, "step_facet"),
    as.character(row$StepOwner)
  ) && identical(
    mfrmr_gocs_p1s_setting(settings, "gpcm_mml_identification"),
    expected_identification
  ) && identical(mfrmr_gocs_p1s_setting(settings, "n_categories"), "4")

  replay <- getFromNamespace("build_mfrm_replay_script", "mfrmr")(
    fit = fit, data_file = paste0(row$DataScenarioId, ".csv")
  )
  replay_text <- paste(as.character(replay$script), collapse = "\n")
  replay_match <- all(vapply(c(
    "gpcm_mml_identification", "free_population", "rating_min = 1",
    "rating_max = 4", paste0("step_facet = \"", row$StepOwner, "\""),
    paste0("slope_facet = \"", row$SlopeOwner, "\"")
  ), grepl, logical(1L), x = replay_text, fixed = TRUE))

  public_summary <- summary(fit)
  overview <- as.data.frame(public_summary$settings_overview %||% data.frame(),
                            stringsAsFactors = FALSE)
  summary_match <- nrow(overview) == 1L &&
    identical(as.character(overview$SlopeFacet), as.character(row$SlopeOwner)) &&
    identical(as.character(overview$StepFacet), as.character(row$StepOwner)) &&
    identical(as.character(overview$GpcmMmlIdentification),
              expected_identification) &&
    identical(as.numeric(overview$RatingMin), 1) &&
    identical(as.numeric(overview$RatingMax), 4)

  convergence <- getFromNamespace("mfrm_convergence_state", "mfrmr")(fit)
  fit_summary <- as.data.frame(fit$summary %||% data.frame(),
                               stringsAsFactors = FALSE)
  objective_candidates <- c("Objective", "NegativeLogLikelihood", "NLL")
  objective_name <- objective_candidates[objective_candidates %in%
                                           names(fit_summary)][1L]
  objective <- if (length(objective_name) == 1L) {
    mfrmr_gocs_p1s_numeric_scalar(fit_summary[[objective_name]])
  } else {
    mfrmr_gocs_p1s_numeric_scalar((fit$opt %||% list())$value)
  }
  population_sd <- if (population_active) {
    sqrt(mfrmr_gocs_p1s_numeric_scalar(fit$population$sigma2))
  } else NA_real_

  out$FitSucceeded <- TRUE
  out$ConfigIdentityMatch <- config_match
  out$PublicManifestIdentityMatch <- manifest_match
  out$ReplayIdentityMatch <- replay_match
  out$PublicSummaryIdentityMatch <- summary_match
  out$CodeConverged <- isTRUE(convergence$code_converged)
  out$FitReadiness <- as.character(convergence$fit_readiness)
  out$InferenceReady <- isTRUE(convergence$inference_ready)
  out$Objective <- objective
  out$PopulationSD <- population_sd
  out$ReplaySHA256 <- mfrmr_gocs_p1s_hash_object(replay_text)
  list(result = out, fit = fit, replay = replay_text)
}

mfrmr_gocs_p1s_checkpoint <- function(manifest_row, result, execution_sha) {
  manifest_row <- as.data.frame(manifest_row, stringsAsFactors = FALSE)
  result <- as.data.frame(result, stringsAsFactors = FALSE)
  rownames(manifest_row) <- NULL
  rownames(result) <- NULL
  structure(list(
    schema = "mfrmr-gpcm-owner-current-default-smoke-checkpoint-v1",
    execution_sha256 = execution_sha,
    route_id = as.character(manifest_row$RouteId),
    row_manifest_sha256 = mfrmr_gocs_p1s_hash_object(manifest_row),
    result_sha256 = mfrmr_gocs_p1s_hash_object(result),
    row_manifest = manifest_row,
    result = result
  ), class = "mfrmr_gpcm_owner_current_default_smoke_checkpoint")
}

mfrmr_gocs_p1s_validate_checkpoint <- function(checkpoint, manifest_row,
                                                execution_sha) {
  manifest_row <- as.data.frame(manifest_row, stringsAsFactors = FALSE)
  rownames(manifest_row) <- NULL
  identity <- mfrmr_gocd_p1r_identity_fields()
  result <- checkpoint$result
  valid <- inherits(
    checkpoint, "mfrmr_gpcm_owner_current_default_smoke_checkpoint"
  ) && identical(
    checkpoint$schema,
    "mfrmr-gpcm-owner-current-default-smoke-checkpoint-v1"
  ) && identical(as.character(checkpoint$execution_sha256), execution_sha) &&
    identical(as.character(checkpoint$route_id),
              as.character(manifest_row$RouteId)) &&
    identical(as.character(checkpoint$row_manifest_sha256),
              mfrmr_gocs_p1s_hash_object(manifest_row)) &&
    identical(as.character(checkpoint$result_sha256),
              mfrmr_gocs_p1s_hash_object(result)) &&
    all(vapply(identity, function(field) identical(
      as.character(result[[field]]), as.character(manifest_row[[field]])
    ), logical(1L)))
  mfrmr_gocs_p1s_assert(valid, "P1s checkpoint identity validation failed.")
  invisible(TRUE)
}

mfrmr_gocs_p1s_bind_identity <- function(table, manifest) {
  table <- as.data.frame(table, stringsAsFactors = FALSE)
  identity <- mfrmr_gocd_p1r_identity_fields()
  if (all(identity %in% names(table))) return(table)
  keys <- c("RouteId", identity)
  out <- merge(table, manifest[, keys, drop = FALSE],
               by = "RouteId", all.x = TRUE, sort = FALSE)
  mfrmr_gocs_p1s_assert(
    nrow(out) == nrow(table) && all(identity %in% names(out)) &&
      all(complete.cases(out[, identity, drop = FALSE])),
    "P1s aggregate identity binding failed."
  )
  out
}

mfrmr_gocs_p1s_aggregate <- function(manifest, results, data_ledger,
                                      execution_identity, checkpoints,
                                      replays) {
  identity <- mfrmr_gocd_p1r_identity_fields()
  base <- results[, c("RouteId", identity), drop = FALSE]
  summary <- cbind(base, results[, c(
    "DataScenarioId", "FitSucceeded", "ConfigIdentityMatch",
    "PublicManifestIdentityMatch", "ReplayIdentityMatch",
    "PublicSummaryIdentityMatch", "CodeConverged", "FitReadiness",
    "InferenceReady"
  ), drop = FALSE])
  rate <- cbind(base, data.frame(
    Planned = 1L, Executed = as.integer(results$Executed),
    FitSucceeded = as.integer(results$FitSucceeded),
    FullIdentityMatch = as.integer(
      results$ConfigIdentityMatch & results$PublicManifestIdentityMatch &
        results$ReplayIdentityMatch & results$PublicSummaryIdentityMatch
    ), stringsAsFactors = FALSE
  ))
  numeric <- cbind(base, results[, c(
    "Objective", "PopulationSD"
  ), drop = FALSE])
  execution_by_route <- cbind(
    base,
    execution_identity[rep(1L, nrow(base)), setdiff(
      names(execution_identity), "RuntimeIdentity"
    ), drop = FALSE]
  )
  policy <- cbind(base, data.frame(
    EvidenceUse = "software_identity_and_paired_attribution_smoke_only",
    RecoveryClaimAuthorized = FALSE,
    OwnerSuperiorityClaimAuthorized = FALSE,
    AdditionalReplicationAuthorized = FALSE,
    BroadSimulationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  ))
  checkpoint_ledger <- do.call(rbind, lapply(seq_along(checkpoints), function(i) {
    data.frame(
      RouteId = manifest$RouteId[[i]],
      CheckpointSHA256 = mfrmr_gocs_p1s_hash_object(checkpoints[[i]]),
      stringsAsFactors = FALSE
    )
  }))
  checkpoint_ledger <- mfrmr_gocs_p1s_bind_identity(
    checkpoint_ledger, manifest
  )
  replay_ledger <- cbind(base, data.frame(
    ReplaySHA256 = vapply(replays, mfrmr_gocs_p1s_hash_object, character(1L)),
    ReplayIdentityMatch = results$ReplayIdentityMatch,
    stringsAsFactors = FALSE
  ))
  list(
    generated_data_ledger = data_ledger,
    run_result = results,
    summary_by_stratum = summary,
    rate_summary = rate,
    numeric_summary = numeric,
    execution_identity_by_stratum = execution_by_route,
    execution_policy_by_stratum = policy,
    checkpoint_ledger = checkpoint_ledger,
    replay_call = replay_ledger
  )
}

mfrmr_gocs_p1s_surface_audit <- function(manifest, aggregates,
                                          checkpoints) {
  contract <- mfrmr_gocd_p1r_surface_contract()
  identity <- mfrmr_gocd_p1r_identity_fields()
  rows <- lapply(contract$Surface, function(surface) {
    if (surface == "declared_manifest") {
      complete <- all(identity %in% names(manifest))
      state <- if (complete) "complete" else "failed"
    } else if (surface %in% c("checkpoint_row_manifest", "checkpoint_result")) {
      target <- if (surface == "checkpoint_row_manifest") {
        lapply(checkpoints, `[[`, "row_manifest")
      } else lapply(checkpoints, `[[`, "result")
      complete <- length(target) == 8L && all(vapply(
        target, function(x) all(identity %in% names(x)), logical(1L)
      ))
      state <- if (complete) "complete" else "failed"
    } else if (surface == "external_normalizer_if_instantiated") {
      complete <- NA
      state <- "conditional_not_instantiated_no_external_claim"
    } else {
      table <- aggregates[[surface]]
      complete <- is.data.frame(table) && nrow(table) == 8L &&
        all(identity %in% names(table)) &&
        all(complete.cases(table[, identity, drop = FALSE]))
      state <- if (complete) "complete" else "failed"
    }
    data.frame(
      Surface = surface,
      State = state,
      FullIdentityRetained = complete,
      RequiredForSmoke = contract$Admission[
        contract$Surface == surface
      ] == "required_for_smoke",
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gocs_p1s_atomic_save <- function(object, path) {
  mfrmr_gocs_p1s_assert(!file.exists(path),
                        paste0("P1s refuses to replace ", path, "."))
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  temporary <- tempfile(".p1s-", tmpdir = dirname(path), fileext = ".partial")
  on.exit(unlink(temporary, force = TRUE), add = TRUE)
  saveRDS(object, temporary)
  check <- readRDS(temporary)
  mfrmr_gocs_p1s_assert(
    identical(mfrmr_gocs_p1s_hash_object(object),
              mfrmr_gocs_p1s_hash_object(check)),
    "P1s atomic-save verification failed."
  )
  mfrmr_gocs_p1s_assert(file.rename(temporary, path),
                        "P1s atomic rename failed.")
  invisible(path)
}

mfrmr_gocs_p1s_write <- function(result, output_dir) {
  mfrmr_gocs_p1s_assert(
    !dir.exists(output_dir) || length(list.files(
      output_dir, all.files = TRUE, no.. = TRUE
    )) == 0L,
    "P1s output directory must be absent or empty."
  )
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  checkpoint_dir <- file.path(output_dir, "checkpoints")
  dir.create(checkpoint_dir, showWarnings = FALSE)
  for (i in seq_along(result$checkpoints)) {
    mfrmr_gocs_p1s_atomic_save(
      result$checkpoints[[i]],
      file.path(checkpoint_dir, paste0(result$manifest$RouteId[[i]], ".rds"))
    )
  }
  tables <- c(
    list(declared_manifest = result$manifest), result$aggregates,
    list(surface_audit = result$surface_audit)
  )
  file_names <- paste0(gsub("_", "-", names(tables)), ".csv")
  for (i in seq_along(tables)) {
    utils::write.csv(tables[[i]], file.path(output_dir, file_names[[i]]),
                     row.names = FALSE, na = "")
  }
  mfrmr_gocs_p1s_atomic_save(result, file.path(output_dir, "p1s-result.rds"))
  files <- list.files(output_dir, recursive = TRUE, full.names = TRUE)
  files <- files[basename(files) != "run-complete.rds"]
  relative <- substring(
    normalizePath(files, winslash = "/", mustWork = TRUE),
    nchar(normalizePath(output_dir, winslash = "/", mustWork = TRUE)) + 2L
  )
  inventory <- data.frame(
    File = relative,
    SHA256 = vapply(files, mfrmr_gocs_p1s_hash_file, character(1L)),
    stringsAsFactors = FALSE
  )
  marker <- list(
    schema = "mfrmr-gpcm-owner-current-default-smoke-completion-v1",
    execution_sha256 = result$execution_identity$ExecutionSHA256,
    artifact_inventory = inventory,
    artifact_inventory_sha256 = mfrmr_gocs_p1s_hash_object(inventory)
  )
  mfrmr_gocs_p1s_atomic_save(marker, file.path(output_dir, "run-complete.rds"))
  invisible(result)
}

mfrmr_run_gpcm_owner_current_default_smoke_p1s <- function(
    execute = FALSE, output_dir = NULL, progress = interactive()) {
  context <- mfrmr_gocs_p1s_context()
  if (!isTRUE(execute)) {
    return(structure(list(
      specification = mfrmr_gocs_p1s_specification,
      contract = mfrmr_gocs_p1s_contract,
      manifest = context$manifest,
      surface_contract = mfrmr_gocd_p1r_surface_contract(),
      execution_identity = context$execution_identity,
      SmokeExecuted = FALSE,
      CurrentDefaultOwnerEvidenceComplete = FALSE,
      AdditionalReplicationAuthorized = FALSE,
      BroadSimulationAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ), class = "mfrmr_gpcm_owner_current_default_smoke_p1s"))
  }
  mfrmr_gocs_p1s_assert(!is.null(output_dir) && nzchar(output_dir),
                        "P1s execution requires an output directory.")
  built <- mfrmr_gocs_p1s_build_datasets(context$manifest)
  results <- vector("list", nrow(context$manifest))
  checkpoints <- vector("list", nrow(context$manifest))
  replays <- vector("list", nrow(context$manifest))
  execution_sha <- context$execution_identity$ExecutionSHA256
  for (i in seq_len(nrow(context$manifest))) {
    row <- context$manifest[i, , drop = FALSE]
    if (isTRUE(progress)) message("P1s ", i, "/8 ", row$RouteId)
    run <- mfrmr_gocs_p1s_run_one(
      row, built$datasets[[row$DataScenarioId]]
    )
    results[[i]] <- run$result
    replays[[i]] <- run$replay %||% ""
    checkpoints[[i]] <- mfrmr_gocs_p1s_checkpoint(
      row, run$result, execution_sha
    )
    mfrmr_gocs_p1s_validate_checkpoint(
      checkpoints[[i]], row, execution_sha
    )
  }
  results <- do.call(rbind, results)
  rownames(results) <- NULL
  aggregates <- mfrmr_gocs_p1s_aggregate(
    context$manifest, results, built$ledger, context$execution_identity,
    checkpoints, replays
  )
  surface_audit <- mfrmr_gocs_p1s_surface_audit(
    context$manifest, aggregates, checkpoints
  )
  required <- surface_audit$RequiredForSmoke
  required_complete <- all(
    surface_audit$State[required] == "complete" &
      surface_audit$FullIdentityRetained[required]
  )
  all_identity <- all(
    results$ConfigIdentityMatch & results$PublicManifestIdentityMatch &
      results$ReplayIdentityMatch & results$PublicSummaryIdentityMatch
  )
  result <- structure(list(
    specification = mfrmr_gocs_p1s_specification,
    contract = mfrmr_gocs_p1s_contract,
    manifest = context$manifest,
    source_identity = context$source_identity,
    execution_identity = context$execution_identity,
    datasets = built$ledger,
    results = results,
    checkpoints = checkpoints,
    aggregates = aggregates,
    surface_audit = surface_audit,
    PairedDatasets = 2L,
    PlannedRoutes = 8L,
    ExecutedRoutes = sum(results$Executed),
    FitSucceededRoutes = sum(results$FitSucceeded),
    RequiredSmokeSurfacesComplete = required_complete,
    AllRouteIdentityChecksPass = all_identity,
    SmokeExecuted = TRUE,
    CurrentDefaultOwnerEvidenceComplete = required_complete && all_identity &&
      all(results$FitSucceeded),
    RecoveryClaimAuthorized = FALSE,
    OwnerSuperiorityClaimAuthorized = FALSE,
    ExternalComparisonAuthorized = FALSE,
    AdditionalReplicationAuthorized = FALSE,
    BroadSimulationAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  ), class = "mfrmr_gpcm_owner_current_default_smoke_p1s")
  mfrmr_gocs_p1s_write(result, output_dir)
  result
}
