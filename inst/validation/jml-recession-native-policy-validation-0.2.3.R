# Native post-implementation validation of the Draft.61 JML recession policy.
# This runner observes production calls but does not replace their fit policy.

mfrmr_native_policy_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-recession-native-policy-validation-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) return(dirname(normalizePath(
    hit[length(hit)], winslash = "/", mustWork = FALSE
  )))
  candidates <- c(
    file.path(
      "inst", "validation",
      "jml-recession-native-policy-validation-0.2.3.R"
    ),
    "jml-recession-native-policy-validation-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else dirname(normalizePath(
    path, winslash = "/", mustWork = TRUE
  ))
})

mfrmr_native_policy_require_support <- function() {
  target_env <- environment(mfrmr_native_policy_require_support)
  if (!exists(
    "mfrmr_run_jml_recession_fit_policy", envir = target_env,
    mode = "function", inherits = TRUE
  )) {
    path <- file.path(
      mfrmr_native_policy_source_dir,
      "jml-recession-fit-policy-pilot-0.2.3.R"
    )
    if (!file.exists(path)) stop(
      "Cannot locate Draft.61 fit-policy support.", call. = FALSE
    )
    sys.source(path, envir = target_env)
  }
  mfrmr_fit_policy_require_support()
  invisible(TRUE)
}

mfrmr_native_policy_prespecification <- function() {
  list(
    schema = "mfrmr-jml-recession-native-policy-prespec-v1",
    draft61_schema = "mfrmr-jml-recession-fit-policy-completion-v1",
    draft61_execution_sha256 =
      "d4786b196687501c91d27f1fef443a45b840f4dc5d71dd099f1231c6a91a12f0",
    draft61_inventory_sha256 =
      "f79fc66f03930b63a7f6d994a4cf730df9e32019ca8c5a2eedb8fa3838fb8dde",
    draft61_artifacts = 19L,
    selected_policy = "bounded_single_10s",
    native_policy = "production_native_single_10s",
    routes = 6L,
    repetitions = 3L,
    maxit = 60L,
    reltol = 1e-9,
    parent_deadline_after_start_ms = 180000L,
    policy_contract_version = "mfrmr-jml-recession-fit-policy-v1",
    native_timeout_seconds = 10L,
    attempts_per_stage = 1L,
    retry_after_unaccepted = FALSE,
    maximum_native_seconds_per_positive_target = 20L,
    exact_candidate_result_identity_required = TRUE,
    exact_candidate_call_outcomes_required = TRUE,
    intercepted_candidate_input_is_transport_metadata = TRUE,
    elapsed_time_comparison_prohibited = TRUE,
    production_implementation_validation_only = TRUE,
    regression_validation_complete = FALSE,
    package_check_complete = FALSE,
    replay_blocker_resolved = FALSE,
    confirmation_authorized = FALSE
  )
}

mfrmr_native_policy_contract <- function() {
  namespace <- asNamespace("mfrmr")
  if (!exists(
    "mfrmr_jml_recession_fit_policy", envir = namespace,
    mode = "function", inherits = FALSE
  )) stop("Installed mfrmr lacks the Draft.62 fit policy.", call. = FALSE)
  value <- get(
    "mfrmr_jml_recession_fit_policy", envir = namespace,
    inherits = FALSE
  )()
  expected <- list(
    contract_version = "mfrmr-jml-recession-fit-policy-v1",
    scope = "additive_structural_and_joint_recession",
    native_timeout_seconds = 10L,
    attempts_per_stage = 1L,
    retry_after_unaccepted = FALSE,
    maximum_native_seconds_per_positive_target = 20L
  )
  if (!identical(value, expected)) stop(
    "Installed mfrmr fit-policy contract is not the Draft.62 candidate.",
    call. = FALSE
  )
  value
}

mfrmr_native_policy_registry <- function(prespecification) {
  data.frame(
    PolicyId = prespecification$native_policy,
    Implementation = "original",
    CapacityTimeoutLadder = "native_default",
    StrictnessTimeoutLadder = "native_default",
    ParentDeadlineAfterStartMs =
      prespecification$parent_deadline_after_start_ms,
    MaximumNativeSecondsPerCapacityStage =
      prespecification$native_timeout_seconds,
    MaximumNativeSecondsPerPositiveTarget =
      prespecification$maximum_native_seconds_per_positive_target,
    CandidatePolicy = FALSE,
    AttributionReference = FALSE,
    ProductionPolicy = TRUE,
    EvidenceUse = "native_postimplementation_validation",
    stringsAsFactors = FALSE
  )
}

mfrmr_native_policy_hash_row <- function(data, fields) {
  value <- data[, fields, drop = FALSE]
  rownames(value) <- NULL
  mfrmr_gpcm_repilot_hash_object(value)
}

mfrmr_native_policy_call_hash <- function(calls) {
  fields <- c(
    "CallId", "Scope", "BaseSHA256", "ProblemSHA256", "Parameters",
    "Constraints", "StoredNonzeros", "Evaluated", "Certified", "Reason",
    "SolverStatus", "TargetCapacity",
    "TargetChange", "MinimumMargin", "PositiveMargin", "StrictRows",
    "SolverAttempts", "OriginalScaleCertificateValid", "ResultSchemaValid",
    "SafeResult"
  )
  value <- calls[order(calls$CallId), fields, drop = FALSE]
  rownames(value) <- NULL
  mfrmr_gpcm_repilot_hash_object(value)
}

mfrmr_native_policy_compare <- function(native_results, native_calls,
                                         draft61) {
  candidate_results <- draft61$results[
    draft61$results$PolicyId == "bounded_single_10s", , drop = FALSE
  ]
  candidate_calls <- draft61$target_calls[
    draft61$target_calls$PolicyId == "bounded_single_10s", , drop = FALSE
  ]
  keys <- native_results[, c("ScenarioId", "Replicate"), drop = FALSE]
  result_fields <- c(
    "FitSucceeded", "InputIdentityMatched", "OptimizerSHA256",
    "CoreEstimateSHA256", "FullSemanticSHA256", "ReadinessSHA256",
    "FitReadiness", "ReasonCodes", "StructuralState",
    "StructuralStatusSHA256", "JointState", "JointStatusSHA256",
    "TargetCalls", "SolverAttempts", "CertifiedCalls", "NegativeCalls",
    "FailedCalls", "SafeCalls", "CallSequenceSHA256", "FitSafe"
  )
  rows <- lapply(seq_len(nrow(keys)), function(i) {
    scenario <- keys$ScenarioId[i]
    replicate <- keys$Replicate[i]
    native_result <- native_results[
      native_results$ScenarioId == scenario &
        native_results$Replicate == replicate, , drop = FALSE
    ]
    candidate_result <- candidate_results[
      candidate_results$ScenarioId == scenario &
        candidate_results$Replicate == replicate, , drop = FALSE
    ]
    native_call <- native_calls[
      native_calls$ScenarioId == scenario &
        native_calls$Replicate == replicate, , drop = FALSE
    ]
    candidate_call <- candidate_calls[
      candidate_calls$ScenarioId == scenario &
        candidate_calls$Replicate == replicate, , drop = FALSE
    ]
    result_complete <- nrow(native_result) == 1L &&
      nrow(candidate_result) == 1L
    call_complete <- nrow(native_call) > 0L &&
      nrow(native_call) == nrow(candidate_call)
    native_result_sha <- if (result_complete) {
      mfrmr_native_policy_hash_row(native_result, result_fields)
    } else NA_character_
    candidate_result_sha <- if (result_complete) {
      mfrmr_native_policy_hash_row(candidate_result, result_fields)
    } else NA_character_
    native_call_sha <- if (call_complete) {
      mfrmr_native_policy_call_hash(native_call)
    } else NA_character_
    candidate_call_sha <- if (call_complete) {
      mfrmr_native_policy_call_hash(candidate_call)
    } else NA_character_
    result_match <- result_complete && identical(
      native_result_sha, candidate_result_sha
    )
    call_match <- call_complete && identical(
      native_call_sha, candidate_call_sha
    )
    data.frame(
      ScenarioId = scenario,
      Replicate = replicate,
      NativeResultSHA256 = native_result_sha,
      CandidateResultSHA256 = candidate_result_sha,
      ResultIdentityMatched = result_match,
      NativeCallSHA256 = native_call_sha,
      CandidateCallSHA256 = candidate_call_sha,
      CallOutcomesMatched = call_match,
      NativeCalls = nrow(native_call),
      CandidateCalls = nrow(candidate_call),
      NativeTimeoutAll10 = nrow(native_call) > 0L &&
        all(native_call$InputTimeoutSeconds == 10L),
      CandidateInterceptedInputAll2 = nrow(candidate_call) > 0L &&
        all(candidate_call$InputTimeoutSeconds == 2L),
      ProductionCandidateMatched = result_match && call_match &&
        all(native_call$InputTimeoutSeconds == 10L) &&
        all(candidate_call$InputTimeoutSeconds == 2L),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_run_jml_recession_native_policy_validation <- function(
    dry_run = TRUE,
    authorize = FALSE,
    draft61_dir = NULL,
    output_dir = NULL,
    progress = interactive()) {
  mfrmr_native_policy_require_support()
  prespecification <- mfrmr_native_policy_prespecification()
  policy_contract <- mfrmr_native_policy_contract()
  policy <- mfrmr_native_policy_registry(prespecification)
  capabilities <- mfrmr_fit_policy_capabilities()
  capabilities <- rbind(
    capabilities,
    data.frame(
      Capability = "native_fit_policy_contract",
      Available = TRUE,
      Version = policy_contract$contract_version,
      RuntimeSHA256 = mfrmr_gpcm_repilot_hash_object(policy_contract),
      Role = "production_policy_under_validation",
      RequiredForLivePilot = TRUE,
      stringsAsFactors = FALSE
    )
  )
  source_files <- c(
    "jml-recession-native-policy-validation-0.2.3.R",
    "jml-recession-fit-policy-pilot-0.2.3.R",
    "jml-recession-fit-policy-worker-0.2.3.R"
  )
  source_identity <- data.frame(
    Component = c(
      "native_validation_runner", "draft61_fit_policy_support",
      "isolated_fit_worker"
    ),
    File = source_files,
    SHA256 = vapply(
      file.path(mfrmr_native_policy_source_dir, source_files),
      mfrmr_gpcm_repilot_hash_file,
      character(1)
    ),
    stringsAsFactors = FALSE
  )
  package_root <- dirname(dirname(mfrmr_native_policy_source_dir))
  production_files <- c(
    file.path("R", "core-jml-recession.R"),
    file.path(
      "tests", "testthat", "test-jml-structural-recession-audit.R"
    )
  )
  production_source_identity <- data.frame(
    Component = c("production_recession_policy", "policy_contract_test"),
    File = production_files,
    SHA256 = vapply(
      file.path(package_root, production_files),
      mfrmr_gpcm_repilot_hash_file,
      character(1)
    ),
    stringsAsFactors = FALSE
  )
  if (isTRUE(dry_run)) return(list(
    schema = "mfrmr-jml-recession-native-policy-validation-v1",
    prespecification = prespecification,
    policy_contract = policy_contract,
    policy_registry = policy,
    capabilities = capabilities,
    source_identity = source_identity,
    production_source_identity = production_source_identity,
    production_implementation_validated = FALSE,
    replay_blocker_resolved = FALSE,
    confirmation_authorized = FALSE
  ))
  if (!isTRUE(authorize)) stop(
    "Live native-policy validation requires `authorize = TRUE`.",
    call. = FALSE
  )
  if (any(!capabilities$Available)) stop(
    "Native-policy validation lacks required capabilities: ",
    paste(capabilities$Capability[!capabilities$Available], collapse = ", "),
    call. = FALSE
  )
  paths <- list(draft61_dir = draft61_dir, output_dir = output_dir)
  if (any(vapply(paths, function(path) {
    is.null(path) || length(path) != 1L || is.na(path) || !nzchar(path)
  }, logical(1)))) stop(
    "Live native-policy validation requires draft61 and output paths.",
    call. = FALSE
  )
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
  if (file.exists(output_dir) || dir.exists(output_dir)) stop(
    "`output_dir` must not already exist.", call. = FALSE
  )
  draft61_bundle <- mfrmr_fit_policy_validate_bundle(
    draft61_dir,
    prespecification$draft61_schema,
    prespecification$draft61_execution_sha256,
    prespecification$draft61_inventory_sha256,
    prespecification$draft61_artifacts
  )
  draft61 <- readRDS(file.path(
    draft61_bundle$dir, "jml-recession-fit-policy-pilot.rds"
  ))
  if (!identical(
    draft61$selected_implementation_policy,
    prespecification$selected_policy
  ) || !isTRUE(draft61$implementation_candidate_selected)) stop(
    "Draft.61 did not retain the expected implementation candidate.",
    call. = FALSE
  )
  candidate_policy <- draft61$policy_registry[
    draft61$policy_registry$PolicyId == prespecification$selected_policy,
    , drop = FALSE
  ]
  if (nrow(candidate_policy) != 1L ||
      !identical(candidate_policy$Implementation, "custom") ||
      !identical(candidate_policy$CapacityTimeoutLadder, "10") ||
      !identical(candidate_policy$StrictnessTimeoutLadder, "10") ||
      !identical(
        candidate_policy$MaximumNativeSecondsPerCapacityStage, 10L
      ) || !identical(
        candidate_policy$MaximumNativeSecondsPerPositiveTarget, 20L
      )) stop(
    "Draft.61 candidate registry does not encode single-ten-second.",
    call. = FALSE
  )
  routes <- draft61$route_registry
  if (nrow(routes) != prespecification$routes) stop(
    "Draft.61 route count is invalid.", call. = FALSE
  )
  schedule <- mfrmr_fit_policy_schedule(
    routes, policy, prespecification$repetitions
  )
  schedule <- merge(
    schedule,
    routes[, c("ScenarioId", "DesignId", "Model", "RouteOrdinal")],
    by = "ScenarioId", all.x = TRUE, sort = FALSE
  )
  schedule <- merge(
    schedule,
    policy[, c("PolicyId", "ParentDeadlineAfterStartMs")],
    by = "PolicyId", all.x = TRUE, sort = FALSE
  )
  schedule <- schedule[order(schedule$ExecutionOrdinal), , drop = FALSE]
  rownames(schedule) <- NULL
  package_identity <- mfrmr_gpcm_repilot_package_content_identity("mfrmr")
  upstream_identity <- data.frame(
    Evidence = "draft61_fit_policy",
    Schema = draft61_bundle$marker$schema,
    ExecutionSHA256 = draft61_bundle$marker$execution_sha256,
    ArtifactInventorySHA256 =
      draft61_bundle$marker$artifact_inventory_sha256,
    stringsAsFactors = FALSE
  )
  plan <- list(
    schema = "mfrmr-jml-recession-native-policy-plan-v1",
    prespecification = prespecification,
    policy_contract = policy_contract,
    route_registry = routes,
    policy_registry = policy,
    schedule = schedule,
    source_identity = source_identity,
    production_source_identity = production_source_identity,
    capabilities = capabilities,
    upstream_identity = upstream_identity,
    installed_package_sha256 = package_identity$PackageSHA256,
    r_version = R.version.string,
    platform = R.version$platform
  )
  plan_sha256 <- mfrmr_gpcm_repilot_hash_object(plan)
  staging <- paste0(output_dir, ".incomplete")
  work_dir <- file.path(staging, "work")
  state_path <- file.path(staging, "run-state.rds")
  if (dir.exists(staging)) {
    state <- tryCatch(readRDS(state_path), error = identity)
    if (inherits(state, "error") || !identical(
      state$schema, "mfrmr-jml-recession-native-policy-state-v1"
    ) || !identical(state$plan_sha256, plan_sha256)) stop(
      "Existing native-policy checkpoint does not match this plan.",
      call. = FALSE
    )
  } else {
    dir.create(work_dir, recursive = TRUE)
    mfrmr_replay_write_atomic_rds(list(
      schema = "mfrmr-jml-recession-native-policy-state-v1",
      plan_sha256 = plan_sha256,
      created_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ), state_path)
  }
  dir.create(work_dir, recursive = TRUE, showWarnings = FALSE)
  checkpoints <- vector("list", nrow(schedule))
  for (i in seq_len(nrow(schedule))) {
    schedule_row <- schedule[i, , drop = FALSE]
    route <- routes[
      routes$ScenarioId == schedule_row$ScenarioId, , drop = FALSE
    ]
    paths <- mfrmr_fit_policy_worker_paths(
      work_dir, schedule_row$ExecutionOrdinal
    )
    checkpoint <- if (file.exists(paths$checkpoint)) tryCatch(
      readRDS(paths$checkpoint), error = identity
    ) else NULL
    valid_checkpoint <- !is.null(checkpoint) &&
      !inherits(checkpoint, "error") &&
      identical(
        checkpoint$schema, "mfrmr-jml-fit-policy-checkpoint-v1"
      ) &&
      identical(
        checkpoint$execution_key_sha256,
        schedule_row$ExecutionKeySHA256
      ) && identical(checkpoint$plan_sha256, plan_sha256)
    if (!valid_checkpoint) {
      if (isTRUE(progress)) message(
        "[native-policy ", i, "/", nrow(schedule), "] rep=",
        schedule_row$Replicate, " route=", schedule_row$ScenarioId
      )
      checkpoint <- mfrmr_fit_policy_execute_one(
        schedule_row, route, route, policy, paths, plan_sha256,
        prespecification$maxit, prespecification$reltol
      )
      mfrmr_replay_write_atomic_rds(checkpoint, paths$checkpoint)
    } else if (isTRUE(progress)) message(
      "[native-policy ", i, "/", nrow(schedule), "] checkpoint reused"
    )
    checkpoints[[i]] <- checkpoint
  }
  results <- do.call(rbind, lapply(checkpoints, `[[`, "result"))
  call_values <- lapply(checkpoints, `[[`, "calls")
  calls <- do.call(rbind, call_values[vapply(
    call_values, nrow, integer(1)
  ) > 0L])
  attempt_values <- lapply(checkpoints, `[[`, "attempts")
  attempts <- if (all(vapply(attempt_values, nrow, integer(1)) == 0L)) {
    mfrmr_fit_policy_empty_attempts()
  } else do.call(rbind, attempt_values[vapply(
    attempt_values, nrow, integer(1)
  ) > 0L])
  logs <- do.call(rbind, lapply(checkpoints, `[[`, "log"))
  rownames(results) <- rownames(calls) <- rownames(attempts) <-
    rownames(logs) <- NULL
  cells <- mfrmr_fit_policy_cell_stability(results)
  comparison <- mfrmr_native_policy_compare(results, calls, draft61)
  route_summary <- do.call(rbind, lapply(routes$ScenarioId, function(id) {
    route_result <- results[results$ScenarioId == id, , drop = FALSE]
    route_comparison <- comparison[
      comparison$ScenarioId == id, , drop = FALSE
    ]
    data.frame(
      ScenarioId = id,
      Fits = nrow(route_result),
      Completed = sum(route_result$WorkerCompleted),
      ParentKills = sum(route_result$ParentKilled),
      SafeFits = sum(route_result$FitSafe),
      OptimizerHashes = length(unique(route_result$OptimizerSHA256)),
      NativeCandidateMatches =
        sum(route_comparison$ProductionCandidateMatched),
      stringsAsFactors = FALSE
    )
  }))
  rownames(route_summary) <- NULL
  implementation_validated <-
    nrow(results) == 18L && all(results$WorkerCompleted) &&
    all(results$FitSucceeded) && all(results$InputIdentityMatched) &&
    all(results$FitSafe) && !any(results$ParentKilled) &&
    nrow(calls) == 51L && all(calls$InputTimeoutSeconds == 10L) &&
    all(calls$SafeResult) && nrow(attempts) == 0L &&
    nrow(cells) == 6L && all(cells$CellStable) &&
    nrow(comparison) == 18L &&
    all(comparison$ProductionCandidateMatched) &&
    sum(calls$SolverAttempts) == 66L
  execution_identity <- data.frame(
    Schema = "mfrmr-jml-recession-native-policy-identity-v1",
    PlanSHA256 = plan_sha256,
    PrespecificationSHA256 =
      mfrmr_gpcm_repilot_hash_object(prespecification),
    PolicyContractSHA256 = mfrmr_gpcm_repilot_hash_object(policy_contract),
    RouteRegistrySHA256 = mfrmr_gpcm_repilot_hash_object(routes),
    PolicyRegistrySHA256 = mfrmr_gpcm_repilot_hash_object(policy),
    ScheduleSHA256 = mfrmr_gpcm_repilot_hash_object(schedule),
    SourceIdentitySHA256 = mfrmr_gpcm_repilot_hash_object(source_identity),
    ProductionSourceIdentitySHA256 =
      mfrmr_gpcm_repilot_hash_object(production_source_identity),
    CapabilityManifestSHA256 =
      mfrmr_gpcm_repilot_hash_object(capabilities),
    UpstreamIdentitySHA256 =
      mfrmr_gpcm_repilot_hash_object(upstream_identity),
    ResultSHA256 = mfrmr_gpcm_repilot_hash_object(results),
    CallSHA256 = mfrmr_gpcm_repilot_hash_object(calls),
    AttemptSHA256 = mfrmr_gpcm_repilot_hash_object(attempts),
    CellStabilitySHA256 = mfrmr_gpcm_repilot_hash_object(cells),
    ComparisonSHA256 = mfrmr_gpcm_repilot_hash_object(comparison),
    InstalledPackageSHA256 = package_identity$PackageSHA256,
    ProductionImplementationValidated = implementation_validated,
    RegressionValidationComplete = FALSE,
    PackageCheckComplete = FALSE,
    ReplayBlockerResolved = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  execution_identity$ExecutionSHA256 <-
    mfrmr_gpcm_repilot_hash_object(execution_identity)
  run_summary <- data.frame(
    Schema = "mfrmr-jml-recession-native-policy-validation-v1",
    Routes = nrow(routes),
    Repetitions = prespecification$repetitions,
    ScheduledFits = nrow(schedule),
    WorkerCompleted = sum(results$WorkerCompleted),
    FitSucceeded = sum(results$FitSucceeded),
    ParentKills = sum(results$ParentKilled),
    SafeFits = sum(results$FitSafe),
    TargetCalls = nrow(calls),
    SolverAttempts = sum(calls$SolverAttempts),
    AttemptRows = nrow(attempts),
    StableCells = sum(cells$CellStable),
    TotalCells = nrow(cells),
    CandidateComparisons = nrow(comparison),
    CandidateMatches = sum(comparison$ProductionCandidateMatched),
    NativeTimeoutAll10 = all(calls$InputTimeoutSeconds == 10L),
    ProductionImplementationValidated = implementation_validated,
    RegressionValidationComplete = FALSE,
    PackageCheckComplete = FALSE,
    ReplayBlockerResolved = FALSE,
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "native_postimplementation_validation_only",
    stringsAsFactors = FALSE
  )
  if (!isTRUE(implementation_validated)) stop(
    "Native-policy implementation did not reproduce Draft.61.",
    call. = FALSE
  )
  output <- list(
    schema = "mfrmr-jml-recession-native-policy-validation-v1",
    prespecification = prespecification,
    policy_contract = policy_contract,
    route_registry = routes,
    policy_registry = policy,
    schedule = schedule,
    results = results,
    target_calls = calls,
    attempts = attempts,
    cell_stability = cells,
    comparison = comparison,
    route_summary = route_summary,
    logs = logs,
    capabilities = capabilities,
    source_identity = source_identity,
    production_source_identity = production_source_identity,
    upstream_identity = upstream_identity,
    package_identity = package_identity,
    execution_identity = execution_identity,
    run_summary = run_summary,
    production_implementation_validated = implementation_validated,
    regression_validation_complete = FALSE,
    package_check_complete = FALSE,
    replay_blocker_resolved = FALSE,
    confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  files <- list(
    `route-registry.csv` = routes,
    `policy-registry.csv` = policy,
    `execution-schedule.csv` = schedule,
    `fit-results.csv` = results,
    `target-calls.csv` = calls,
    `stage-attempts.csv` = attempts,
    `cell-stability.csv` = cells,
    `candidate-comparison.csv` = comparison,
    `route-summary.csv` = route_summary,
    `process-logs.csv` = logs,
    `capabilities.csv` = capabilities,
    `source-identity.csv` = source_identity,
    `production-source-identity.csv` = production_source_identity,
    `upstream-identity.csv` = upstream_identity,
    `package-identity.csv` = package_identity,
    `execution-identity.csv` = execution_identity,
    `run-summary.csv` = run_summary
  )
  for (name in names(files)) utils::write.csv(
    files[[name]], file.path(staging, name), row.names = FALSE, na = ""
  )
  saveRDS(
    output,
    file.path(staging, "jml-recession-native-policy-validation.rds")
  )
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  work_root <- normalizePath(work_dir, winslash = "/", mustWork = TRUE)
  staging_root <- normalizePath(staging, winslash = "/", mustWork = TRUE)
  if (!startsWith(work_root, paste0(staging_root, "/"))) stop(
    "Native-policy work directory escaped staging.", call. = FALSE
  )
  invisible(gc())
  for (cleanup_attempt in seq_len(5L)) {
    unlink(work_root, recursive = TRUE, force = TRUE)
    if (!dir.exists(work_root) && !file.exists(work_root)) break
    Sys.sleep(0.2)
    invisible(gc())
  }
  if (dir.exists(work_root) || file.exists(work_root)) stop(
    "Native-policy work directory could not be removed before promotion.",
    call. = FALSE
  )
  unlink(state_path, force = TRUE)
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  marker <- list(
    schema = "mfrmr-jml-recession-native-policy-completion-v1",
    execution_sha256 = execution_identity$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 =
      mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    production_implementation_validated = implementation_validated,
    regression_validation_complete = FALSE,
    package_check_complete = FALSE,
    replay_blocker_resolved = FALSE,
    confirmation_authorized = FALSE
  )
  saveRDS(marker, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) stop(
    "Completed native-policy evidence could not be promoted.",
    call. = FALSE
  )
  invisible(output)
}
