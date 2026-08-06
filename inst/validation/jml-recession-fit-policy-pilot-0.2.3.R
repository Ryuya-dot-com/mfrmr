# Internal fit-level JML recession-policy comparison for mfrmr 0.2.3.
# It may select one implementation candidate but cannot change production.

mfrmr_fit_policy_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-recession-fit-policy-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) return(dirname(normalizePath(
    hit[length(hit)], winslash = "/", mustWork = FALSE
  )))
  candidates <- c(
    file.path(
      "inst", "validation", "jml-recession-fit-policy-pilot-0.2.3.R"
    ),
    "jml-recession-fit-policy-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else dirname(normalizePath(
    path, winslash = "/", mustWork = TRUE
  ))
})

mfrmr_fit_policy_source <- function(file, target_env) {
  candidates <- c(
    if (!is.na(mfrmr_fit_policy_source_dir)) {
      file.path(mfrmr_fit_policy_source_dir, file)
    } else character(0),
    file.path("inst", "validation", file), file
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) stop("Cannot locate fit-policy support: ", file,
                        call. = FALSE)
  sys.source(path, envir = target_env)
  invisible(path)
}

mfrmr_fit_policy_require_support <- function() {
  target_env <- environment(mfrmr_fit_policy_require_support)
  if (!exists(
    "mfrmr_replay_require_support", envir = target_env,
    mode = "function", inherits = TRUE
  )) mfrmr_fit_policy_source(
    "jml-recession-replay-policy-pilot-0.2.3.R", target_env
  )
  mfrmr_replay_require_support()
  required <- c(
    "mfrmr_target_cone_registry", "mfrmr_target_cone_build",
    "mfrmr_target_cone_fit_args", "mfrmr_target_bridge_readiness",
    "mfrmr_target_cone_boundary", "mfrmr_jml_phase_semantic_hash",
    "mfrmr_jml_phase_structural_status_hash",
    "mfrmr_solver_base_sha256", "mfrmr_solver_problem_sha256",
    "mfrmr_replay_stage", "mfrmr_replay_write_atomic_rds",
    "mfrmr_gpcm_repilot_hash_object", "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_package_content_identity",
    "mfrmr_target_scale_artifact_inventory"
  )
  if (!all(vapply(
    required, exists, logical(1), envir = target_env,
    mode = "function", inherits = TRUE
  ))) stop("Fit-policy support did not load completely.", call. = FALSE)
  invisible(TRUE)
}

mfrmr_fit_policy_capabilities <- function() {
  mfrmr_fit_policy_require_support()
  packages <- c("mfrmr", "Matrix", "digest", "lpSolve", "processx")
  available <- vapply(packages, requireNamespace, logical(1), quietly = TRUE)
  data.frame(
    Capability = packages, Available = available,
    Version = vapply(packages, function(package) {
      if (requireNamespace(package, quietly = TRUE)) {
        as.character(utils::packageVersion(package))
      } else NA_character_
    }, character(1)),
    RuntimeSHA256 = vapply(seq_along(packages), function(i) {
      if (available[i]) {
        mfrmr_gpcm_repilot_package_content_identity(packages[i])$PackageSHA256
      } else NA_character_
    }, character(1)),
    Role = c(
      "runtime_under_review", "sparse_geometry", "artifact_identity",
      "production_lp", "isolated_fit_and_parent_deadline"
    ),
    RequiredForLivePilot = TRUE, stringsAsFactors = FALSE
  )
}

mfrmr_fit_policy_registry <- function() {
  data.frame(
    PolicyId = c(
      "production_original_2s", "bounded_retry_2s_8s",
      "bounded_single_10s", "os_bounded_native_zero"
    ),
    Implementation = c("original", "custom", "custom", "custom"),
    CapacityTimeoutLadder = c("original", "2,8", "10", "0"),
    StrictnessTimeoutLadder = c("original", "2,8", "10", "0"),
    ParentDeadlineAfterStartMs = c(120000L, 180000L, 180000L, 180000L),
    MaximumNativeSecondsPerCapacityStage = c(2L, 10L, 10L, NA_integer_),
    MaximumNativeSecondsPerPositiveTarget = c(4L, 20L, 20L, NA_integer_),
    CandidatePolicy = c(FALSE, TRUE, TRUE, FALSE),
    AttributionReference = c(FALSE, FALSE, FALSE, TRUE),
    ProductionPolicy = c(TRUE, FALSE, FALSE, FALSE),
    EvidenceUse = c(
      "current_fit_replay", "bounded_retry_fit_candidate",
      "bounded_single_fit_candidate", "os_bounded_fit_attribution_only"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fit_policy_prespecification <- function() {
  list(
    schema = "mfrmr-jml-recession-fit-policy-prespec-v1",
    draft59_schema = "mfrmr-jml-target-positive-cone-completion-v1",
    draft59_execution_sha256 =
      "7cd2606e4f203cb6afa8f305bafa26a1ea323a20d4bb6408ea615422f111c34d",
    draft59_inventory_sha256 =
      "845b3d0f51bfd39bddb8e104f31bb71682a4584a893a147d8af7f9e1c82800aa",
    draft60_schema = "mfrmr-jml-recession-replay-completion-v1",
    draft60_execution_sha256 =
      "4153139e7e0588334472c4ee2e89a5548a2b06d5478bb4878365ed5bdf5977af",
    draft60_inventory_sha256 =
      "853be8656a365a163e9a8ebb87b8e890c95135cbe3f72c52ecd7506000e12aca",
    routes = 6L, policies = 4L, repetitions = 3L,
    maxit = 60L, reltol = 1e-9,
    isolated_process_per_route_policy_repetition = TRUE,
    order_rule = paste(
      "four-policy cyclic order by repetition; six-route order rotates and",
      "reverses on even repetitions"
    ),
    input_rule = paste(
      "every worker regenerates its Draft.59 route and must match retained",
      "data, truth, response, topology, and exposure hashes before fitting"
    ),
    optimizer_rule = paste(
      "every policy and repetition within a route must preserve one exact",
      "optimizer hash because recession auditing occurs after optimization"
    ),
    candidate_rule = paste(
      "all three fits complete safely and stably on all six routes, preserve",
      "one target-problem sequence, and match the stable OS-bounded reference",
      "for semantic, readiness, structural, and joint boundary identities"
    ),
    selection_rule = paste(
      "if both candidates qualify, select bounded_single_10s only when its",
      "target sequence matches retry/reference, its declared positive-target",
      "native bound equals retry, it uses no more solver attempts in every",
      "matched route/repetition and strictly fewer in at least one; otherwise",
      "select the sole qualified candidate or make no selection"
    ),
    elapsed_time_selection_prohibited = TRUE,
    implementation_candidate_selection_only = TRUE,
    production_change_authorized = FALSE,
    replay_blocker_resolved = FALSE,
    confirmation_authorized = FALSE
  )
}

mfrmr_fit_policy_validate_bundle <- function(
    evidence_dir, expected_schema, expected_execution,
    expected_inventory, expected_artifacts) {
  evidence_dir <- normalizePath(evidence_dir, winslash = "/", mustWork = TRUE)
  marker <- readRDS(file.path(evidence_dir, "run-complete.rds"))
  if (!identical(marker$schema, expected_schema) ||
      !identical(as.character(marker$execution_sha256), expected_execution) ||
      !identical(
        as.character(marker$artifact_inventory_sha256), expected_inventory
      )) stop("Upstream fit-policy evidence identity mismatch.", call. = FALSE)
  inventory <- marker$artifacts
  if (!is.data.frame(inventory) || nrow(inventory) != expected_artifacts ||
      anyDuplicated(inventory$File) || !identical(
        mfrmr_gpcm_repilot_hash_object(inventory),
        as.character(marker$artifact_inventory_sha256)
      )) stop("Upstream fit-policy inventory is invalid.", call. = FALSE)
  relative <- gsub("\\\\", "/", as.character(inventory$File))
  unsafe <- !nzchar(relative) | grepl("^(?:[A-Za-z]:|/)", relative) |
    grepl("(?:^|/)\\.\\.(?:/|$)", relative)
  if (any(unsafe)) stop("Upstream fit-policy inventory path is unsafe.",
                        call. = FALSE)
  paths <- file.path(evidence_dir, relative)
  if (any(!file.exists(paths)) || any(dir.exists(paths))) stop(
    "Upstream fit-policy artifact is missing.", call. = FALSE
  )
  observed_hash <- unname(vapply(
    paths, mfrmr_gpcm_repilot_hash_file, character(1)
  ))
  observed_size <- as.numeric(unname(file.info(paths)$size))
  if (!identical(observed_hash, as.character(inventory$SHA256)) ||
      !identical(observed_size, as.numeric(inventory$Bytes))) stop(
    "Upstream fit-policy artifact hash or size mismatch.", call. = FALSE
  )
  list(dir = evidence_dir, marker = marker, inventory = inventory)
}

mfrmr_fit_policy_route_registry <- function(draft59) {
  registry <- mfrmr_target_cone_registry()
  audit_path <- file.path(draft59$dir, "fit-audit.csv")
  audit <- utils::read.csv(audit_path, stringsAsFactors = FALSE,
                           check.names = FALSE)
  expected <- audit[, c(
    "ScenarioId", "DataSHA256", "TruthSHA256", "ResponseSHA256",
    "TopologySHA256", "ExposureSHA256"
  ), drop = FALSE]
  if (nrow(registry) != 6L || nrow(expected) != 6L ||
      anyDuplicated(expected$ScenarioId)) stop(
    "Draft.59 route identity is invalid.", call. = FALSE
  )
  idx <- match(registry$ScenarioId, expected$ScenarioId)
  if (anyNA(idx)) stop("Draft.59 route registry mismatch.", call. = FALSE)
  expected <- expected[idx, , drop = FALSE]
  out <- cbind(registry, expected[, setdiff(
    names(expected), "ScenarioId"
  ), drop = FALSE])
  out$RouteOrdinal <- seq_len(nrow(out))
  out
}

mfrmr_fit_policy_schedule <- function(routes, policies, repetitions = 3L) {
  route_ids <- routes$ScenarioId
  policy_ids <- policies$PolicyId
  rows <- list(); cursor <- 0L
  for (replicate in seq_len(as.integer(repetitions))) {
    shift <- (replicate - 1L) %% length(route_ids)
    route_order <- c(
      route_ids[(shift + 1L):length(route_ids)],
      if (shift > 0L) route_ids[seq_len(shift)] else character(0)
    )
    if (replicate %% 2L == 0L) route_order <- rev(route_order)
    policy_shift <- (replicate - 1L) %% length(policy_ids)
    policy_order <- c(
      policy_ids[(policy_shift + 1L):length(policy_ids)],
      if (policy_shift > 0L) policy_ids[seq_len(policy_shift)] else character(0)
    )
    for (scenario_id in route_order) {
      for (policy_id in policy_order) {
        cursor <- cursor + 1L
        rows[[cursor]] <- data.frame(
          ExecutionOrdinal = cursor, Replicate = replicate,
          ScenarioId = scenario_id, PolicyId = policy_id,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  out <- do.call(rbind, rows)
  out$ExecutionKeySHA256 <- vapply(seq_len(nrow(out)), function(i) {
    mfrmr_gpcm_repilot_hash_object(list(
      schema = "mfrmr-jml-fit-policy-execution-key-v1",
      replicate = out$Replicate[i], scenario_id = out$ScenarioId[i],
      policy_id = out$PolicyId[i]
    ))
  }, character(1))
  rownames(out) <- NULL
  out
}

mfrmr_fit_policy_empty_calls <- function() {
  data.frame(
    CallId = integer(0), ScenarioId = character(0), Model = character(0),
    Scope = character(0), PolicyId = character(0),
    BaseSHA256 = character(0), ProblemSHA256 = character(0),
    Parameters = integer(0), Constraints = integer(0),
    StoredNonzeros = double(0), InputTimeoutSeconds = integer(0),
    Evaluated = logical(0), Certified = logical(0),
    Reason = character(0), SolverStatus = integer(0),
    TargetCapacity = double(0), TargetChange = double(0),
    MinimumMargin = double(0), PositiveMargin = double(0),
    StrictRows = integer(0), SolverAttempts = integer(0),
    OriginalScaleCertificateValid = logical(0),
    ResultSchemaValid = logical(0), SafeResult = logical(0),
    ElapsedSeconds = double(0), stringsAsFactors = FALSE
  )
}

mfrmr_fit_policy_empty_attempts <- function() {
  out <- mfrmr_replay_empty_attempts()
  cbind(
    data.frame(
      CallId = integer(0), ScenarioId = character(0),
      Scope = character(0), PolicyId = character(0),
      ProblemSHA256 = character(0), stringsAsFactors = FALSE
    ),
    out
  )
}

mfrmr_fit_policy_validate_target <- function(
    lp_base, target, result, objective_tolerance, certificate_tolerance) {
  n <- length(target)
  direction <- as.numeric(mfrmr_replay_or(result$direction, numeric(0)))
  direction_finite <- length(direction) == n && all(is.finite(direction))
  if (direction_finite) {
    margins <- as.numeric(lp_base$contrast_design %*% direction)
    target_change <- sum(target * direction)
    minimum_margin <- if (length(margins) > 0L) min(margins) else Inf
    positive_margin <- sum(pmax(margins, 0))
    strict_rows <- sum(margins > certificate_tolerance)
  } else {
    target_change <- minimum_margin <- positive_margin <- NA_real_
    strict_rows <- NA_integer_
  }
  certificate_valid <- isTRUE(result$certified) && direction_finite &&
    is.finite(target_change) && target_change > objective_tolerance &&
    is.finite(minimum_margin) && minimum_margin >= -certificate_tolerance &&
    is.finite(positive_margin) && positive_margin > objective_tolerance &&
    strict_rows > 0L
  reason <- as.character(mfrmr_replay_or(result$reason, NA_character_))
  schema_valid <- if (isTRUE(result$certified)) {
    isTRUE(result$evaluated) && identical(
      reason, "certified_additive_recession_direction"
    ) && certificate_valid
  } else if (identical(reason, "no_target_recession_direction")) {
    isTRUE(result$evaluated) && is.finite(result$target_capacity) &&
      result$target_capacity <= 10 * objective_tolerance &&
      direction_finite && all(abs(direction) <= certificate_tolerance)
  } else if (reason %in% c(
    "linear_program_capacity_failed", "linear_program_strictness_failed"
  )) {
    !isTRUE(result$evaluated) && !isTRUE(result$certified)
  } else !isTRUE(result$certified)
  list(
    certificate_valid = certificate_valid,
    schema_valid = isTRUE(schema_valid),
    safe = isTRUE(schema_valid) && (!isTRUE(result$certified) ||
      certificate_valid)
  )
}

mfrmr_fit_policy_custom_target <- function(
    lp_base, target, objective_tolerance, certificate_tolerance,
    policy, journal_dir) {
  problem <- list(
    lp_base = lp_base, target = as.numeric(target),
    objective_tolerance = as.numeric(objective_tolerance),
    certificate_tolerance = as.numeric(certificate_tolerance)
  )
  capacity <- mfrmr_replay_stage(
    problem, "capacity",
    mfrmr_replay_parse_ladder(policy$CapacityTimeoutLadder), journal_dir
  )
  attempts <- capacity$rows
  strict <- NULL
  if (is.null(capacity$accepted)) {
    result <- list(
      evaluated = FALSE, certified = FALSE,
      solver_status = tail(capacity$rows$SolverStatus, 1L),
      target_capacity = NA_real_, target_change = NA_real_,
      minimum_margin = NA_real_, positive_margin = NA_real_,
      strict_rows = NA_integer_, direction = rep(NA_real_, length(target)),
      lp_calls = capacity$attempted,
      reason = "linear_program_capacity_failed"
    )
  } else {
    capacity_value <- capacity$accepted$row$Objective
    if (capacity_value <= 10 * objective_tolerance) {
      result <- list(
        evaluated = TRUE, certified = FALSE,
        solver_status = capacity$accepted$row$SolverStatus,
        target_capacity = capacity_value, target_change = 0,
        minimum_margin = 0, positive_margin = 0, strict_rows = 0L,
        direction = rep(0, length(target)), lp_calls = capacity$attempted,
        reason = "no_target_recession_direction"
      )
    } else {
      strict <- mfrmr_replay_stage(
        problem, "strictness",
        mfrmr_replay_parse_ladder(policy$StrictnessTimeoutLadder),
        journal_dir, attempt_offset = capacity$attempted,
        capacity = capacity_value
      )
      attempts <- rbind(attempts, strict$rows)
      if (is.null(strict$accepted)) {
        result <- list(
          evaluated = FALSE, certified = FALSE,
          solver_status = tail(strict$rows$SolverStatus, 1L),
          target_capacity = capacity_value, target_change = NA_real_,
          minimum_margin = NA_real_, positive_margin = NA_real_,
          strict_rows = NA_integer_, direction = rep(NA_real_, length(target)),
          lp_calls = capacity$attempted + strict$attempted,
          reason = "linear_program_strictness_failed"
        )
      } else {
        direction <- strict$accepted$direction
        margins <- as.numeric(lp_base$contrast_design %*% direction)
        target_change <- sum(target * direction)
        minimum_margin <- min(margins)
        positive_margin <- sum(pmax(margins, 0))
        strict_rows <- sum(margins > certificate_tolerance)
        certified <- is.finite(target_change) &&
          target_change > objective_tolerance &&
          is.finite(minimum_margin) &&
          minimum_margin >= -certificate_tolerance &&
          is.finite(positive_margin) &&
          positive_margin > objective_tolerance && strict_rows > 0L
        result <- list(
          evaluated = TRUE, certified = isTRUE(certified),
          solver_status = strict$accepted$row$SolverStatus,
          target_capacity = capacity_value, target_change = target_change,
          minimum_margin = minimum_margin, positive_margin = positive_margin,
          strict_rows = as.integer(strict_rows), direction = direction,
          lp_calls = capacity$attempted + strict$attempted,
          reason = if (isTRUE(certified)) {
            "certified_additive_recession_direction"
          } else "candidate_failed_postsolve_certificate"
        )
      }
    }
  }
  list(result = result, attempts = attempts)
}

mfrmr_fit_policy_session_start <- function(
    sink, policy, scenario_id, model, journal_root) {
  namespace <- asNamespace("mfrmr")
  originals <- list(
    structural = get(
      "audit_mfrm_jml_structural_recession", namespace, inherits = FALSE
    ),
    joint = get(
      "audit_mfrm_jml_joint_recession", namespace, inherits = FALSE
    ),
    target = get(
      "mfrmr_jml_recession_target_lp", namespace, inherits = FALSE
    )
  )
  scope <- "outside"
  stopped <- FALSE
  scope_wrapper <- function(name, original) {
    force(name); force(original)
    function(...) {
      previous <- scope
      scope <<- name
      on.exit(scope <<- previous, add = TRUE)
      original(...)
    }
  }
  target_wrapper <- function(lp_base, target,
                             objective_tolerance = 1e-7,
                             certificate_tolerance = 1e-7,
                             timeout = 5L) {
    call_id <- length(sink$calls) + 1L
    call_dir <- file.path(journal_root, sprintf("call-%04d", call_id))
    dir.create(call_dir, recursive = TRUE, showWarnings = FALSE)
    base_sha <- mfrmr_solver_base_sha256(lp_base)
    problem_sha <- mfrmr_solver_problem_sha256(
      lp_base, target, objective_tolerance, certificate_tolerance
    )
    started <- unname(proc.time()[["elapsed"]])
    value <- if (identical(as.character(policy$Implementation), "original")) {
      list(result = originals$target(
        lp_base = lp_base, target = target,
        objective_tolerance = objective_tolerance,
        certificate_tolerance = certificate_tolerance, timeout = timeout
      ), attempts = mfrmr_replay_empty_attempts())
    } else mfrmr_fit_policy_custom_target(
      lp_base, target, objective_tolerance, certificate_tolerance,
      policy, call_dir
    )
    elapsed <- max(0, unname(proc.time()[["elapsed"]]) - started)
    validation <- mfrmr_fit_policy_validate_target(
      lp_base, target, value$result,
      objective_tolerance, certificate_tolerance
    )
    call_row <- data.frame(
      CallId = call_id, ScenarioId = scenario_id, Model = model,
      Scope = scope, PolicyId = policy$PolicyId,
      BaseSHA256 = base_sha, ProblemSHA256 = problem_sha,
      Parameters = lp_base$n_parameters,
      Constraints = lp_base$n_constraints,
      StoredNonzeros = as.double(lp_base$stored_constraint_nonzeros),
      InputTimeoutSeconds = as.integer(timeout),
      Evaluated = isTRUE(value$result$evaluated),
      Certified = isTRUE(value$result$certified),
      Reason = as.character(value$result$reason),
      SolverStatus = as.integer(value$result$solver_status),
      TargetCapacity = as.numeric(value$result$target_capacity),
      TargetChange = as.numeric(value$result$target_change),
      MinimumMargin = as.numeric(value$result$minimum_margin),
      PositiveMargin = as.numeric(value$result$positive_margin),
      StrictRows = as.integer(value$result$strict_rows),
      SolverAttempts = as.integer(value$result$lp_calls),
      OriginalScaleCertificateValid = validation$certificate_valid,
      ResultSchemaValid = validation$schema_valid,
      SafeResult = validation$safe, ElapsedSeconds = elapsed,
      stringsAsFactors = FALSE
    )
    sink$calls[[call_id]] <- call_row
    mfrmr_replay_write_atomic_rds(
      call_row, file.path(call_dir, "call-complete.rds")
    )
    if (nrow(value$attempts) > 0L) {
      attempt_rows <- cbind(
        data.frame(
          CallId = call_id, ScenarioId = scenario_id, Scope = scope,
          PolicyId = policy$PolicyId, ProblemSHA256 = problem_sha,
          stringsAsFactors = FALSE
        )[rep(1L, nrow(value$attempts)), , drop = FALSE],
        value$attempts
      )
      sink$attempts[[length(sink$attempts) + 1L]] <- attempt_rows
    }
    value$result
  }
  assignInNamespace(
    "audit_mfrm_jml_structural_recession",
    scope_wrapper("structural", originals$structural), ns = "mfrmr"
  )
  assignInNamespace(
    "audit_mfrm_jml_joint_recession",
    scope_wrapper("joint", originals$joint), ns = "mfrmr"
  )
  assignInNamespace(
    "mfrmr_jml_recession_target_lp", target_wrapper, ns = "mfrmr"
  )
  stop_session <- function() {
    if (stopped) return(result)
    assignInNamespace(
      "mfrmr_jml_recession_target_lp", originals$target, ns = "mfrmr"
    )
    assignInNamespace(
      "audit_mfrm_jml_joint_recession", originals$joint, ns = "mfrmr"
    )
    assignInNamespace(
      "audit_mfrm_jml_structural_recession", originals$structural,
      ns = "mfrmr"
    )
    stopped <<- TRUE
    result <<- list(
      calls = if (length(sink$calls) == 0L) {
        mfrmr_fit_policy_empty_calls()
      } else do.call(rbind, sink$calls),
      attempts = if (length(sink$attempts) == 0L) {
        mfrmr_fit_policy_empty_attempts()
      } else do.call(rbind, sink$attempts)
    )
    rownames(result$calls) <- rownames(result$attempts) <- NULL
    result
  }
  list(stop = stop_session)
}

mfrmr_fit_policy_compact_result <- function(
    fit, generated, expected, policy, captured, elapsed) {
  fit_ok <- !inherits(fit, "error")
  result <- data.frame(
    ScenarioId = expected$ScenarioId, DesignId = expected$DesignId,
    Model = expected$Model, PolicyId = policy$PolicyId,
    FitSucceeded = fit_ok,
    FitError = if (fit_ok) NA_character_ else conditionMessage(fit),
    DataSHA256 = generated$support$RetainedDataHash,
    TruthSHA256 = generated$TruthSHA256,
    ResponseSHA256 = generated$ResponseSHA256,
    TopologySHA256 = generated$topology$TopologySHA256,
    ExposureSHA256 = generated$topology$ExposureSHA256,
    InputIdentityMatched = identical(
      as.character(generated$support$RetainedDataHash),
      as.character(expected$DataSHA256)
    ) && identical(generated$TruthSHA256, as.character(expected$TruthSHA256)) &&
      identical(generated$ResponseSHA256,
                as.character(expected$ResponseSHA256)) &&
      identical(generated$topology$TopologySHA256,
                as.character(expected$TopologySHA256)) &&
      identical(generated$topology$ExposureSHA256,
                as.character(expected$ExposureSHA256)),
    OptimizerSHA256 = NA_character_, CoreEstimateSHA256 = NA_character_,
    FullSemanticSHA256 = NA_character_, ReadinessSHA256 = NA_character_,
    FitReadiness = NA_character_, ReasonCodes = NA_character_,
    StructuralState = NA_character_, StructuralStatusSHA256 = NA_character_,
    JointState = NA_character_, JointStatusSHA256 = NA_character_,
    TargetCalls = nrow(captured$calls),
    SolverAttempts = sum(captured$calls$SolverAttempts),
    CertifiedCalls = sum(captured$calls$Certified),
    NegativeCalls = sum(
      captured$calls$Reason == "no_target_recession_direction"
    ),
    FailedCalls = sum(captured$calls$Reason %in% c(
      "linear_program_capacity_failed", "linear_program_strictness_failed"
    )),
    SafeCalls = sum(captured$calls$SafeResult),
    CallSequenceSHA256 = mfrmr_gpcm_repilot_hash_object(
      captured$calls[, intersect(c(
        "CallId", "Scope", "ProblemSHA256"
      ), names(captured$calls)), drop = FALSE]
    ),
    FitSafe = nrow(captured$calls) > 0L && all(captured$calls$SafeResult),
    FitElapsedSeconds = elapsed,
    ProductionChangeAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  if (fit_ok) {
    readiness <- mfrmr_target_bridge_readiness(fit)
    structural <- mfrmr_target_cone_boundary(fit, "structural_additive")
    joint <- mfrmr_target_cone_boundary(fit, "joint_additive")
    result$OptimizerSHA256 <- mfrmr_gpcm_repilot_hash_object(list(
      par = fit$opt$par, value = fit$opt$value,
      convergence = fit$opt$convergence, message = fit$opt$message
    ))
    result$CoreEstimateSHA256 <- mfrmr_gpcm_repilot_hash_object(list(
      facets = fit$facets, interactions = fit$interactions,
      steps = fit$steps, slopes = fit$slopes,
      optimizer = result$OptimizerSHA256
    ))
    result$FullSemanticSHA256 <- mfrmr_jml_phase_semantic_hash(fit)
    result$ReadinessSHA256 <- mfrmr_gpcm_repilot_hash_object(readiness)
    result$FitReadiness <- as.character(mfrmr_replay_or(
      readiness$FitReadiness, NA_character_
    ))
    result$ReasonCodes <- as.character(mfrmr_replay_or(
      readiness$ReasonCodes, NA_character_
    ))
    result$StructuralState <- structural$state
    result$StructuralStatusSHA256 <- structural$status_sha256
    result$JointState <- joint$state
    result$JointStatusSHA256 <- joint$status_sha256
  }
  result
}

mfrmr_fit_policy_run_worker_job <- function(job) {
  route <- job$route
  expected <- job$expected
  policy <- job$policy
  generated <- mfrmr_target_cone_build(route)
  identity_ok <- identical(
    as.character(generated$support$RetainedDataHash),
    as.character(expected$DataSHA256)
  ) && identical(generated$TruthSHA256, as.character(expected$TruthSHA256)) &&
    identical(generated$ResponseSHA256, as.character(expected$ResponseSHA256)) &&
    identical(generated$topology$TopologySHA256,
              as.character(expected$TopologySHA256)) &&
    identical(generated$topology$ExposureSHA256,
              as.character(expected$ExposureSHA256))
  if (!identity_ok) stop("Fit worker regenerated-input identity mismatch.",
                         call. = FALSE)
  mfrmr_replay_write_atomic_rds(list(
    schema = "mfrmr-jml-fit-policy-worker-started-v1",
    pid = Sys.getpid(), execution_key_sha256 = job$execution_key_sha256,
    plan_sha256 = job$plan_sha256,
    started_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
  ), job$started_path)
  sink <- new.env(parent = emptyenv())
  sink$calls <- list(); sink$attempts <- list()
  session <- mfrmr_fit_policy_session_start(
    sink, policy, expected$ScenarioId, expected$Model, job$journal_root
  )
  stopped <- FALSE
  on.exit({
    if (!stopped) session$stop()
  }, add = TRUE)
  fit_args <- mfrmr_target_cone_fit_args(
    route, generated, job$maxit, job$reltol
  )
  started <- unname(proc.time()[["elapsed"]])
  fit <- tryCatch(
    suppressWarnings(do.call(mfrmr_gpcm_stress_fun("fit_mfrm"), fit_args)),
    error = identity
  )
  elapsed <- max(0, unname(proc.time()[["elapsed"]]) - started)
  captured <- session$stop(); stopped <- TRUE
  result <- mfrmr_fit_policy_compact_result(
    fit, generated, expected, policy, captured, elapsed
  )
  list(result = result, calls = captured$calls,
       attempts = captured$attempts)
}

mfrmr_fit_policy_empty_result <- function() {
  data.frame(
    ScenarioId = NA_character_, DesignId = NA_character_,
    Model = NA_character_, PolicyId = NA_character_, FitSucceeded = FALSE,
    FitError = NA_character_, DataSHA256 = NA_character_,
    TruthSHA256 = NA_character_, ResponseSHA256 = NA_character_,
    TopologySHA256 = NA_character_, ExposureSHA256 = NA_character_,
    InputIdentityMatched = FALSE, OptimizerSHA256 = NA_character_,
    CoreEstimateSHA256 = NA_character_, FullSemanticSHA256 = NA_character_,
    ReadinessSHA256 = NA_character_, FitReadiness = NA_character_,
    ReasonCodes = NA_character_, StructuralState = NA_character_,
    StructuralStatusSHA256 = NA_character_, JointState = NA_character_,
    JointStatusSHA256 = NA_character_, TargetCalls = 0L,
    SolverAttempts = 0L, CertifiedCalls = 0L, NegativeCalls = 0L,
    FailedCalls = 0L, SafeCalls = 0L, CallSequenceSHA256 = NA_character_,
    FitSafe = TRUE, FitElapsedSeconds = NA_real_,
    WorkerCompleted = FALSE, ParentKilled = FALSE,
    ProcessExitStatus = NA_integer_, StartedMarkerObserved = FALSE,
    OutputProduced = FALSE, ParentElapsedSeconds = NA_real_,
    ProductionChangeAuthorized = FALSE, ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fit_policy_worker_paths <- function(work_dir, ordinal) {
  root <- file.path(work_dir, sprintf("execution-%04d", ordinal))
  list(
    root = root, job = file.path(root, "job.rds"),
    output = file.path(root, "output.rds"),
    started = file.path(root, "started.rds"),
    journal = file.path(root, "journal"),
    stdout = file.path(root, "stdout.txt"),
    stderr = file.path(root, "stderr.txt"),
    checkpoint = file.path(work_dir, sprintf("checkpoint-%04d.rds", ordinal))
  )
}

mfrmr_fit_policy_collect_calls <- function(journal_root) {
  files <- sort(list.files(
    journal_root, pattern = "^call-complete\\.rds$",
    recursive = TRUE, full.names = TRUE
  ))
  if (length(files) == 0L) return(mfrmr_fit_policy_empty_calls())
  values <- lapply(files, function(path) tryCatch(readRDS(path), error = identity))
  values <- values[!vapply(values, inherits, logical(1), "error")]
  if (length(values) == 0L) return(mfrmr_fit_policy_empty_calls())
  out <- do.call(rbind, values); rownames(out) <- NULL; out
}

mfrmr_fit_policy_collect_attempts <- function(journal_root, calls) {
  files <- sort(list.files(
    journal_root, pattern = "^attempt-[0-9]+\\.rds$",
    recursive = TRUE, full.names = TRUE
  ))
  if (length(files) == 0L) return(mfrmr_fit_policy_empty_attempts())
  rows <- lapply(files, function(path) {
    value <- tryCatch(readRDS(path), error = identity)
    if (inherits(value, "error")) return(NULL)
    call_id <- as.integer(sub("call-", "", basename(dirname(path))))
    call <- calls[calls$CallId == call_id, , drop = FALSE]
    if (nrow(call) != 1L) return(NULL)
    cbind(
      call[, c(
        "CallId", "ScenarioId", "Scope", "PolicyId", "ProblemSHA256"
      ), drop = FALSE],
      value
    )
  })
  rows <- rows[!vapply(rows, is.null, logical(1))]
  if (length(rows) == 0L) return(mfrmr_fit_policy_empty_attempts())
  out <- do.call(rbind, rows); rownames(out) <- NULL; out
}

mfrmr_fit_policy_execute_one <- function(schedule_row, route, expected,
                                         policy, paths, plan_sha256,
                                         maxit, reltol) {
  dir.create(paths$root, recursive = TRUE, showWarnings = FALSE)
  dir.create(paths$journal, recursive = TRUE, showWarnings = FALSE)
  job <- list(
    schema = "mfrmr-jml-fit-policy-worker-job-v1",
    execution_key_sha256 = schedule_row$ExecutionKeySHA256,
    plan_sha256 = plan_sha256, route = route, expected = expected,
    policy = policy, maxit = as.integer(maxit), reltol = as.numeric(reltol),
    lib_paths = .libPaths(),
    mfrmr_lib = dirname(system.file(package = "mfrmr")),
    runner_path = file.path(
      mfrmr_fit_policy_source_dir,
      "jml-recession-fit-policy-pilot-0.2.3.R"
    ),
    output_path = paths$output, started_path = paths$started,
    journal_root = paths$journal
  )
  mfrmr_replay_write_atomic_rds(job, paths$job)
  worker <- file.path(
    mfrmr_fit_policy_source_dir,
    "jml-recession-fit-policy-worker-0.2.3.R"
  )
  rscript <- file.path(R.home("bin"), "Rscript.exe")
  if (!file.exists(rscript)) rscript <- file.path(R.home("bin"), "Rscript")
  parent_started <- unname(proc.time()[["elapsed"]])
  process <- processx::process$new(
    rscript, c(worker, paths$job), stdout = paths$stdout,
    stderr = paths$stderr, cleanup_tree = TRUE
  )
  start_wait <- Sys.time()
  while (process$is_alive() && !file.exists(paths$started) &&
         as.numeric(difftime(Sys.time(), start_wait, units = "secs")) < 60) {
    Sys.sleep(0.05)
  }
  started <- file.exists(paths$started)
  if (started && process$is_alive()) process$wait(
    timeout = as.integer(policy$ParentDeadlineAfterStartMs)
  )
  killed <- FALSE
  if (process$is_alive()) {
    process$kill_tree(); killed <- TRUE; process$wait(timeout = 5000L)
  }
  exit_status <- process$get_exit_status()
  output_produced <- file.exists(paths$output)
  value <- if (output_produced) tryCatch(
    readRDS(paths$output), error = identity
  ) else NULL
  valid <- !is.null(value) && !inherits(value, "error") &&
    identical(value$schema, "mfrmr-jml-fit-policy-worker-v1") &&
    identical(value$execution_key_sha256, schedule_row$ExecutionKeySHA256) &&
    identical(value$plan_sha256, plan_sha256) &&
    is.data.frame(value$result) && nrow(value$result) == 1L
  calls <- if (valid) value$calls else mfrmr_fit_policy_collect_calls(
    paths$journal
  )
  attempts <- if (valid) value$attempts else mfrmr_fit_policy_collect_attempts(
    paths$journal, calls
  )
  result <- if (valid) value$result else mfrmr_fit_policy_empty_result()
  if (!valid) {
    result$ScenarioId <- schedule_row$ScenarioId
    result$DesignId <- route$DesignId
    result$Model <- route$Model
    result$PolicyId <- schedule_row$PolicyId
    result$FitError <- if (killed) "parent_os_deadline" else if (!started) {
      "worker_start_failed"
    } else "worker_output_invalid"
    result$TargetCalls <- nrow(calls)
    result$SolverAttempts <- sum(calls$SolverAttempts)
    result$SafeCalls <- sum(calls$SafeResult)
    result$FitSafe <- nrow(calls) == 0L || all(calls$SafeResult)
  }
  result$WorkerCompleted <- valid
  result$ParentKilled <- killed
  result$ProcessExitStatus <- as.integer(mfrmr_replay_or(
    exit_status, NA_integer_
  ))
  result$StartedMarkerObserved <- started
  result$OutputProduced <- output_produced
  result$ParentElapsedSeconds <- max(
    0, unname(proc.time()[["elapsed"]]) - parent_started
  )
  result <- cbind(
    schedule_row[, c(
      "ExecutionOrdinal", "ExecutionKeySHA256", "Replicate"
    ), drop = FALSE],
    result
  )
  if (nrow(calls) > 0L) calls <- cbind(
    schedule_row[, c(
      "ExecutionOrdinal", "ExecutionKeySHA256", "Replicate"
    ), drop = FALSE][rep(1L, nrow(calls)), , drop = FALSE], calls
  )
  if (nrow(attempts) > 0L) attempts <- cbind(
    schedule_row[, c(
      "ExecutionOrdinal", "ExecutionKeySHA256", "Replicate"
    ), drop = FALSE][rep(1L, nrow(attempts)), , drop = FALSE], attempts
  )
  logs <- paste(c(
    if (file.exists(paths$stdout)) readLines(paths$stdout, warn = FALSE),
    if (file.exists(paths$stderr)) readLines(paths$stderr, warn = FALSE)
  ), collapse = " | ")
  list(
    schema = "mfrmr-jml-fit-policy-checkpoint-v1",
    execution_key_sha256 = schedule_row$ExecutionKeySHA256,
    plan_sha256 = plan_sha256, result = result, calls = calls,
    attempts = attempts,
    log = data.frame(
      ExecutionOrdinal = schedule_row$ExecutionOrdinal,
      ExecutionKeySHA256 = schedule_row$ExecutionKeySHA256,
      StartedMarkerObserved = started, ParentKilled = killed,
      ExitStatus = as.integer(mfrmr_replay_or(exit_status, NA_integer_)),
      OutputProduced = output_produced, WorkerResultValid = valid,
      Logs = logs, stringsAsFactors = FALSE
    )
  )
}

mfrmr_fit_policy_cell_stability <- function(results) {
  keys <- unique(results[, c("PolicyId", "ScenarioId"), drop = FALSE])
  rows <- lapply(seq_len(nrow(keys)), function(i) {
    cell <- results[
      results$PolicyId == keys$PolicyId[i] &
        results$ScenarioId == keys$ScenarioId[i], , drop = FALSE
    ]
    hash_fields <- c(
      "OptimizerSHA256", "CoreEstimateSHA256", "FullSemanticSHA256",
      "ReadinessSHA256", "StructuralState", "StructuralStatusSHA256",
      "JointState", "JointStatusSHA256", "CallSequenceSHA256",
      "TargetCalls", "CertifiedCalls", "NegativeCalls", "FailedCalls"
    )
    stable <- nrow(cell) == 3L && all(cell$WorkerCompleted) &&
      !any(cell$ParentKilled) && all(cell$FitSucceeded) &&
      all(cell$InputIdentityMatched) && all(cell$FitSafe) &&
      all(vapply(hash_fields, function(field) {
        length(unique(cell[[field]])) == 1L
      }, logical(1)))
    data.frame(
      PolicyId = keys$PolicyId[i], ScenarioId = keys$ScenarioId[i],
      Repetitions = nrow(cell), Completed = sum(cell$WorkerCompleted),
      FitSucceeded = sum(cell$FitSucceeded), ParentKills = sum(cell$ParentKilled),
      SafeFits = sum(cell$FitSafe), CellStable = stable,
      RepresentativeSemanticSHA256 = if (stable) {
        cell$FullSemanticSHA256[1L]
      } else NA_character_,
      RepresentativeReadinessSHA256 = if (stable) {
        cell$ReadinessSHA256[1L]
      } else NA_character_,
      RepresentativeStructuralSHA256 = if (stable) {
        cell$StructuralStatusSHA256[1L]
      } else NA_character_,
      RepresentativeJointSHA256 = if (stable) {
        cell$JointStatusSHA256[1L]
      } else NA_character_,
      RepresentativeCallSequenceSHA256 = if (stable) {
        cell$CallSequenceSHA256[1L]
      } else NA_character_,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows); rownames(out) <- NULL; out
}

mfrmr_fit_policy_reference_match <- function(candidate, reference) {
  if (nrow(candidate) != 1L || nrow(reference) != 1L ||
      !candidate$CellStable || !reference$CellStable) return(FALSE)
  fields <- c(
    "RepresentativeSemanticSHA256", "RepresentativeReadinessSHA256",
    "RepresentativeStructuralSHA256", "RepresentativeJointSHA256",
    "RepresentativeCallSequenceSHA256"
  )
  all(vapply(fields, function(field) {
    identical(candidate[[field]], reference[[field]])
  }, logical(1)))
}

mfrmr_fit_policy_summary <- function(results, cells, policies, routes) {
  reference_id <- policies$PolicyId[policies$AttributionReference]
  rows <- lapply(seq_len(nrow(policies)), function(i) {
    policy <- policies[i, , drop = FALSE]
    fit_rows <- results[results$PolicyId == policy$PolicyId, , drop = FALSE]
    policy_cells <- cells[cells$PolicyId == policy$PolicyId, , drop = FALSE]
    reference_matches <- vapply(routes$ScenarioId, function(scenario_id) {
      mfrmr_fit_policy_reference_match(
        policy_cells[policy_cells$ScenarioId == scenario_id, , drop = FALSE],
        cells[cells$PolicyId == reference_id &
          cells$ScenarioId == scenario_id, , drop = FALSE]
      )
    }, logical(1))
    optimizer_stable <- all(vapply(routes$ScenarioId, function(scenario_id) {
      route_rows <- results[results$ScenarioId == scenario_id, , drop = FALSE]
      length(unique(route_rows$OptimizerSHA256)) == 1L
    }, logical(1)))
    all_cells <- nrow(policy_cells) == nrow(routes) &&
      all(policy_cells$CellStable)
    pilot_qualified <- isTRUE(policy$CandidatePolicy) && all_cells &&
      all(fit_rows$FitSafe) && optimizer_stable && all(reference_matches)
    data.frame(
      PolicyId = policy$PolicyId, Fits = nrow(fit_rows),
      Completed = sum(fit_rows$WorkerCompleted),
      ParentKills = sum(fit_rows$ParentKilled),
      StableCells = sum(policy_cells$CellStable),
      TotalCells = nrow(policy_cells),
      ReferenceMatches = sum(reference_matches),
      OptimizerInvariantAcrossPolicies = optimizer_stable,
      TotalTargetCalls = sum(fit_rows$TargetCalls),
      TotalSolverAttempts = sum(fit_rows$SolverAttempts),
      CandidatePolicy = policy$CandidatePolicy,
      AttributionReference = policy$AttributionReference,
      FitPilotQualified = pilot_qualified,
      ProductionChangeAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows); rownames(out) <- NULL; out
}

mfrmr_fit_policy_select <- function(results, policy_summary, policies) {
  retry_id <- "bounded_retry_2s_8s"
  single_id <- "bounded_single_10s"
  retry_ok <- policy_summary$FitPilotQualified[
    policy_summary$PolicyId == retry_id
  ]
  single_ok <- policy_summary$FitPilotQualified[
    policy_summary$PolicyId == single_id
  ]
  selected <- NA_character_
  reason <- "no_fit_qualified_policy"
  dominance_rows <- data.frame()
  if (retry_ok && single_ok) {
    retry <- results[results$PolicyId == retry_id, ]
    single <- results[results$PolicyId == single_id, ]
    keys <- c("ScenarioId", "Replicate")
    dominance_rows <- merge(
      retry[, c(keys, "CallSequenceSHA256", "SolverAttempts")],
      single[, c(keys, "CallSequenceSHA256", "SolverAttempts")],
      by = keys, suffixes = c("Retry", "Single"), sort = FALSE
    )
    same_sequence <- nrow(dominance_rows) == 18L && all(
      dominance_rows$CallSequenceSHA256Retry ==
        dominance_rows$CallSequenceSHA256Single
    )
    no_more <- same_sequence && all(
      dominance_rows$SolverAttemptsSingle <=
        dominance_rows$SolverAttemptsRetry
    )
    strictly_fewer <- no_more && any(
      dominance_rows$SolverAttemptsSingle <
        dominance_rows$SolverAttemptsRetry
    )
    retry_bound <- policies$MaximumNativeSecondsPerPositiveTarget[
      policies$PolicyId == retry_id
    ]
    single_bound <- policies$MaximumNativeSecondsPerPositiveTarget[
      policies$PolicyId == single_id
    ]
    same_bound <- identical(retry_bound, single_bound)
    if (same_sequence && no_more && strictly_fewer && same_bound) {
      selected <- single_id
      reason <- "single_10s_dominates_restarts_at_equal_native_bound"
    } else {
      reason <- "two_fit_qualified_policies_without_prespecified_dominance"
    }
  } else if (single_ok) {
    selected <- single_id; reason <- "sole_fit_qualified_policy"
  } else if (retry_ok) {
    selected <- retry_id; reason <- "sole_fit_qualified_policy"
  }
  list(
    selected_policy = selected, selection_reason = reason,
    selection_authorized = !is.na(selected), dominance = dominance_rows
  )
}

mfrmr_run_jml_recession_fit_policy <- function(
    dry_run = TRUE, authorize = FALSE, draft59_dir = NULL,
    draft60_dir = NULL, output_dir = NULL, progress = interactive()) {
  mfrmr_fit_policy_require_support()
  capabilities <- mfrmr_fit_policy_capabilities()
  prespec <- mfrmr_fit_policy_prespecification()
  policies <- mfrmr_fit_policy_registry()
  source_files <- c(
    "jml-recession-fit-policy-pilot-0.2.3.R",
    "jml-recession-fit-policy-worker-0.2.3.R",
    "jml-recession-replay-policy-pilot-0.2.3.R",
    "jml-target-positive-cone-pilot-0.2.3.R"
  )
  source_identity <- data.frame(
    Component = c(
      "fit_policy_runner", "isolated_fit_worker",
      "draft60_replay_runner", "draft59_target_runner"
    ),
    File = source_files,
    SHA256 = vapply(
      file.path(mfrmr_fit_policy_source_dir, source_files),
      mfrmr_gpcm_repilot_hash_file, character(1)
    ),
    stringsAsFactors = FALSE
  )
  if (isTRUE(dry_run)) {
    routes <- mfrmr_target_cone_registry()
    schedule <- mfrmr_fit_policy_schedule(
      routes, policies, prespec$repetitions
    )
    return(list(
      schema = "mfrmr-jml-recession-fit-policy-pilot-v1",
      prespecification = prespec, route_registry = routes,
      policy_registry = policies, schedule = schedule,
      capabilities = capabilities, source_identity = source_identity,
      implementation_candidate_selected = FALSE,
      production_change_authorized = FALSE,
      confirmation_authorized = FALSE
    ))
  }
  if (!isTRUE(authorize)) stop(
    "Live fit-policy execution requires `authorize = TRUE`.", call. = FALSE
  )
  if (any(!capabilities$Available)) stop(
    "Live fit-policy execution lacks required capabilities: ",
    paste(capabilities$Capability[!capabilities$Available], collapse = ", "),
    call. = FALSE
  )
  required_paths <- list(
    draft59_dir = draft59_dir, draft60_dir = draft60_dir,
    output_dir = output_dir
  )
  if (any(vapply(required_paths, function(path) {
    is.null(path) || length(path) != 1L || is.na(path) || !nzchar(path)
  }, logical(1)))) stop(
    "Live fit-policy execution requires draft59, draft60, and output paths.",
    call. = FALSE
  )
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
  if (file.exists(output_dir) || dir.exists(output_dir)) stop(
    "`output_dir` must not already exist.", call. = FALSE
  )
  draft59 <- mfrmr_fit_policy_validate_bundle(
    draft59_dir, prespec$draft59_schema, prespec$draft59_execution_sha256,
    prespec$draft59_inventory_sha256, 14L
  )
  draft60 <- mfrmr_fit_policy_validate_bundle(
    draft60_dir, prespec$draft60_schema, prespec$draft60_execution_sha256,
    prespec$draft60_inventory_sha256, 17L
  )
  routes <- mfrmr_fit_policy_route_registry(draft59)
  schedule <- mfrmr_fit_policy_schedule(
    routes, policies, prespec$repetitions
  )
  schedule <- merge(
    schedule,
    routes[, c("ScenarioId", "DesignId", "Model", "RouteOrdinal")],
    by = "ScenarioId", all.x = TRUE, sort = FALSE
  )
  schedule <- merge(
    schedule,
    policies[, c("PolicyId", "ParentDeadlineAfterStartMs")],
    by = "PolicyId", all.x = TRUE, sort = FALSE
  )
  schedule <- schedule[order(schedule$ExecutionOrdinal), , drop = FALSE]
  rownames(schedule) <- NULL
  package_identity <- mfrmr_gpcm_repilot_package_content_identity("mfrmr")
  upstream_identity <- data.frame(
    Evidence = c("draft59_target_cones", "draft60_problem_replay"),
    Schema = c(draft59$marker$schema, draft60$marker$schema),
    ExecutionSHA256 = c(
      draft59$marker$execution_sha256, draft60$marker$execution_sha256
    ),
    ArtifactInventorySHA256 = c(
      draft59$marker$artifact_inventory_sha256,
      draft60$marker$artifact_inventory_sha256
    ), stringsAsFactors = FALSE
  )
  plan <- list(
    schema = "mfrmr-jml-recession-fit-policy-plan-v1",
    prespecification = prespec, route_registry = routes,
    policy_registry = policies, schedule = schedule,
    source_identity = source_identity, capabilities = capabilities,
    upstream_identity = upstream_identity,
    installed_package_sha256 = package_identity$PackageSHA256,
    r_version = R.version.string, platform = R.version$platform
  )
  plan_sha256 <- mfrmr_gpcm_repilot_hash_object(plan)
  staging <- paste0(output_dir, ".incomplete")
  work_dir <- file.path(staging, "work")
  state_path <- file.path(staging, "run-state.rds")
  if (dir.exists(staging)) {
    state <- tryCatch(readRDS(state_path), error = identity)
    if (inherits(state, "error") || !identical(
      state$schema, "mfrmr-jml-recession-fit-policy-state-v1"
    ) || !identical(state$plan_sha256, plan_sha256)) stop(
      "Existing fit-policy checkpoint does not match this plan.",
      call. = FALSE
    )
  } else {
    dir.create(work_dir, recursive = TRUE)
    mfrmr_replay_write_atomic_rds(list(
      schema = "mfrmr-jml-recession-fit-policy-state-v1",
      plan_sha256 = plan_sha256,
      created_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ), state_path)
  }
  dir.create(work_dir, recursive = TRUE, showWarnings = FALSE)
  checkpoints <- vector("list", nrow(schedule))
  for (i in seq_len(nrow(schedule))) {
    schedule_row <- schedule[i, , drop = FALSE]
    route <- routes[routes$ScenarioId == schedule_row$ScenarioId, , drop = FALSE]
    expected <- route
    policy <- policies[policies$PolicyId == schedule_row$PolicyId,
                       , drop = FALSE]
    paths <- mfrmr_fit_policy_worker_paths(
      work_dir, schedule_row$ExecutionOrdinal
    )
    checkpoint <- if (file.exists(paths$checkpoint)) tryCatch(
      readRDS(paths$checkpoint), error = identity
    ) else NULL
    valid_checkpoint <- !is.null(checkpoint) && !inherits(checkpoint, "error") &&
      identical(checkpoint$schema, "mfrmr-jml-fit-policy-checkpoint-v1") &&
      identical(checkpoint$execution_key_sha256,
                schedule_row$ExecutionKeySHA256) &&
      identical(checkpoint$plan_sha256, plan_sha256)
    if (!valid_checkpoint) {
      if (isTRUE(progress)) message(
        "[fit-policy ", i, "/", nrow(schedule), "] rep=",
        schedule_row$Replicate, " route=", schedule_row$ScenarioId,
        " policy=", schedule_row$PolicyId
      )
      checkpoint <- mfrmr_fit_policy_execute_one(
        schedule_row, route, expected, policy, paths, plan_sha256,
        prespec$maxit, prespec$reltol
      )
      mfrmr_replay_write_atomic_rds(checkpoint, paths$checkpoint)
    } else if (isTRUE(progress)) message(
      "[fit-policy ", i, "/", nrow(schedule), "] checkpoint reused"
    )
    checkpoints[[i]] <- checkpoint
  }
  results <- do.call(rbind, lapply(checkpoints, `[[`, "result"))
  call_values <- lapply(checkpoints, `[[`, "calls")
  calls <- do.call(rbind, call_values[vapply(call_values, nrow, integer(1)) > 0L])
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
  policy_summary <- mfrmr_fit_policy_summary(
    results, cells, policies, routes
  )
  selection <- mfrmr_fit_policy_select(results, policy_summary, policies)
  dominance <- selection$dominance
  route_summary <- do.call(rbind, lapply(routes$ScenarioId, function(id) {
    route_rows <- results[results$ScenarioId == id, , drop = FALSE]
    data.frame(
      ScenarioId = id, Fits = nrow(route_rows),
      Completed = sum(route_rows$WorkerCompleted),
      ParentKills = sum(route_rows$ParentKilled),
      OptimizerHashes = length(unique(route_rows$OptimizerSHA256)),
      StablePolicyCells = sum(cells$CellStable[cells$ScenarioId == id]),
      TotalPolicyCells = sum(cells$ScenarioId == id),
      stringsAsFactors = FALSE
    )
  }))
  rownames(route_summary) <- NULL
  selected <- selection$selected_policy
  execution_identity <- data.frame(
    Schema = "mfrmr-jml-recession-fit-policy-identity-v1",
    PlanSHA256 = plan_sha256,
    PrespecificationSHA256 = mfrmr_gpcm_repilot_hash_object(prespec),
    RouteRegistrySHA256 = mfrmr_gpcm_repilot_hash_object(routes),
    PolicyRegistrySHA256 = mfrmr_gpcm_repilot_hash_object(policies),
    ScheduleSHA256 = mfrmr_gpcm_repilot_hash_object(schedule),
    SourceIdentitySHA256 = mfrmr_gpcm_repilot_hash_object(source_identity),
    CapabilityManifestSHA256 = mfrmr_gpcm_repilot_hash_object(capabilities),
    UpstreamIdentitySHA256 = mfrmr_gpcm_repilot_hash_object(upstream_identity),
    ResultSHA256 = mfrmr_gpcm_repilot_hash_object(results),
    CallSHA256 = mfrmr_gpcm_repilot_hash_object(calls),
    AttemptSHA256 = mfrmr_gpcm_repilot_hash_object(attempts),
    CellStabilitySHA256 = mfrmr_gpcm_repilot_hash_object(cells),
    PolicySummarySHA256 = mfrmr_gpcm_repilot_hash_object(policy_summary),
    DominanceSHA256 = mfrmr_gpcm_repilot_hash_object(dominance),
    InstalledPackageSHA256 = package_identity$PackageSHA256,
    SelectedImplementationPolicy = if (is.na(selected)) NA_character_ else selected,
    ImplementationCandidateSelected = selection$selection_authorized,
    ProductionChangeAuthorized = FALSE,
    ReplayBlockerResolved = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  execution_identity$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(
    execution_identity
  )
  run_summary <- data.frame(
    Schema = "mfrmr-jml-recession-fit-policy-pilot-v1",
    Routes = nrow(routes), Policies = nrow(policies),
    Repetitions = prespec$repetitions, ScheduledFits = nrow(schedule),
    WorkerCompleted = sum(results$WorkerCompleted),
    FitSucceeded = sum(results$FitSucceeded),
    ParentKills = sum(results$ParentKilled), SafeFits = sum(results$FitSafe),
    TargetCalls = nrow(calls), SolverAttempts = sum(calls$SolverAttempts),
    AttemptRows = nrow(attempts), StableCells = sum(cells$CellStable),
    TotalCells = nrow(cells),
    QualifiedFitPolicies = sum(policy_summary$FitPilotQualified),
    SelectedImplementationPolicy = if (is.na(selected)) NA_character_ else selected,
    SelectionReason = selection$selection_reason,
    ImplementationCandidateSelected = selection$selection_authorized,
    ProductionChangeAuthorized = FALSE,
    ReplayBlockerResolved = FALSE, RuntimeCriterionFrozen = FALSE,
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "isolated_fit_policy_calibration_only",
    stringsAsFactors = FALSE
  )
  completion_valid <- nrow(results) == nrow(schedule) &&
    nrow(cells) == nrow(routes) * nrow(policies) &&
    all(results$FitSafe) && all(calls$SafeResult) &&
    !execution_identity$ProductionChangeAuthorized &&
    !execution_identity$ReplayBlockerResolved &&
    !execution_identity$ConfirmationAuthorized
  if (!completion_valid) stop(
    "Fit-policy evidence did not complete safely.", call. = FALSE
  )
  output <- list(
    schema = "mfrmr-jml-recession-fit-policy-pilot-v1",
    prespecification = prespec, route_registry = routes,
    policy_registry = policies, schedule = schedule, results = results,
    target_calls = calls, attempts = attempts, cell_stability = cells,
    policy_summary = policy_summary, route_summary = route_summary,
    dominance = dominance, logs = logs, capabilities = capabilities,
    source_identity = source_identity, upstream_identity = upstream_identity,
    package_identity = package_identity,
    execution_identity = execution_identity, run_summary = run_summary,
    selected_implementation_policy = selected,
    implementation_candidate_selected = selection$selection_authorized,
    production_change_authorized = FALSE,
    replay_blocker_resolved = FALSE, confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  files <- list(
    `route-registry.csv` = routes, `policy-registry.csv` = policies,
    `execution-schedule.csv` = schedule, `fit-results.csv` = results,
    `target-calls.csv` = calls, `stage-attempts.csv` = attempts,
    `cell-stability.csv` = cells, `policy-summary.csv` = policy_summary,
    `route-summary.csv` = route_summary, `dominance.csv` = dominance,
    `process-logs.csv` = logs, `capabilities.csv` = capabilities,
    `source-identity.csv` = source_identity,
    `upstream-identity.csv` = upstream_identity,
    `package-identity.csv` = package_identity,
    `execution-identity.csv` = execution_identity,
    `run-summary.csv` = run_summary
  )
  for (name in names(files)) utils::write.csv(
    files[[name]], file.path(staging, name), row.names = FALSE, na = ""
  )
  saveRDS(output, file.path(staging, "jml-recession-fit-policy-pilot.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  work_root <- normalizePath(work_dir, winslash = "/", mustWork = TRUE)
  staging_root <- normalizePath(staging, winslash = "/", mustWork = TRUE)
  if (!startsWith(work_root, paste0(staging_root, "/"))) stop(
    "Fit-policy work directory escaped staging.", call. = FALSE
  )
  invisible(gc())
  for (cleanup_attempt in seq_len(5L)) {
    unlink(work_root, recursive = TRUE, force = TRUE)
    if (!dir.exists(work_root) && !file.exists(work_root)) break
    Sys.sleep(0.2); invisible(gc())
  }
  if (dir.exists(work_root) || file.exists(work_root)) stop(
    "Fit-policy work directory could not be removed before promotion.",
    call. = FALSE
  )
  unlink(state_path, force = TRUE)
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  marker <- list(
    schema = "mfrmr-jml-recession-fit-policy-completion-v1",
    execution_sha256 = execution_identity$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    selected_implementation_policy = selected,
    implementation_candidate_selected = selection$selection_authorized,
    production_change_authorized = FALSE,
    replay_blocker_resolved = FALSE, confirmation_authorized = FALSE
  )
  saveRDS(marker, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) stop(
    "Completed fit-policy evidence could not be promoted.", call. = FALSE
  )
  invisible(output)
}
