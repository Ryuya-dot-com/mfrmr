# No-top-level-execution successor to the consumed ASP-G4M live session.
#
# G4O leaves the consumed v1 target and authority quarantined. It binds the
# frozen tranche-A harness to a new v2 target and issuer, obtains a semantic
# data-free token in the live R process before authority issue, consumes that
# token, and then retains the original post-consumption fresh sentinel.

mfrmr_cq_ag4o_specification <-
  "0.2.3-conquest-adversarial-simulation-successor-live-execution-v2"
mfrmr_cq_ag4o_contract <- paste0(
  "mfrmr_conquest_adversarial_simulation_successor_",
  "live_execution_and_retained_reconstruction_v2"
)
mfrmr_cq_ag4o_authorization_specification <-
  "0.2.3-conquest-adversarial-simulation-successor-live-authorization-v2"
mfrmr_cq_ag4o_authorization_contract <- paste0(
  "mfrmr_conquest_adversarial_simulation_tranche_a_",
  "live_authorization_freeze_v2"
)
mfrmr_cq_ag4o_output_basename <-
  "conquest-adversarial-simulation-calibration-tranche-a-20260816-v2"
mfrmr_cq_ag4o_approval_id <-
  "user-2026-08-16-unsandboxed-conquest-successor-run"
mfrmr_cq_ag4o_run_not_after <- as.Date("2026-08-31")
mfrmr_cq_ag4o_executable_path <- "/Applications/ConQuest/ConQuest"
mfrmr_cq_ag4o_launcher_path <- "/usr/bin/arch"

mfrmr_cq_ag4o_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ag4o_same_frame <- function(observed, expected, fields = NULL) {
  if (!is.data.frame(observed) || !is.data.frame(expected) ||
      nrow(observed) != nrow(expected)) return(FALSE)
  if (is.null(fields)) {
    if (!setequal(names(observed), names(expected))) return(FALSE)
    fields <- names(expected)
  }
  if (!all(fields %in% names(observed)) ||
      !all(fields %in% names(expected))) return(FALSE)
  same_numeric <- function(left, right) {
    left <- as.numeric(left)
    right <- as.numeric(right)
    if (length(left) != length(right) ||
        !identical(is.na(left), is.na(right)) ||
        !identical(is.nan(left), is.nan(right)) ||
        !identical(is.infinite(left), is.infinite(right))) return(FALSE)
    finite <- is.finite(left) & is.finite(right)
    if (any(!finite & !is.na(left)) &&
        !identical(left[!finite & !is.na(left)],
                   right[!finite & !is.na(right)])) return(FALSE)
    tolerance <- 64 * .Machine$double.eps * pmax(
      1, abs(left[finite]), abs(right[finite])
    )
    all(abs(left[finite] - right[finite]) <= tolerance)
  }
  normalize <- function(value) {
    value <- as.character(value)
    value[is.na(value)] <- "<NA>"
    value
  }
  all(vapply(fields, function(field) {
    left <- observed[[field]]
    right <- expected[[field]]
    if (is.double(left) && is.double(right)) {
      same_numeric(left, right)
    } else {
      identical(normalize(left), normalize(right))
    }
  }, logical(1L)))
}

mfrmr_cq_ag4o_validate_g4m_contracts <- function() {
  target <- environment(mfrmr_cq_ag4o_validate_g4m_contracts)
  required <- c(
    "mfrmr_cq_atla_issue", "mfrmr_cq_atla_review",
    "mfrmr_cq_ach_consume_authorization", "mfrmr_cq_ach_fresh_sentinel",
    "mfrmr_cq_ach_dataset_generation_authority",
    "mfrmr_cq_ach_generate_dataset", "mfrmr_cq_ach_adapter_plan",
    "mfrmr_cq_ach_generation_journal_template",
    "mfrmr_cq_ach_attempt_journal_template", "mfrmr_cq_ach_outcome_template",
    "mfrmr_cq_ach_representation_bridge_audit",
    "mfrmr_cq_ach_expected_artifact_registry",
    "mfrmr_cq_ach_artifact_inventory", "mfrmr_cq_ach_resource_state",
    "mfrmr_cq_ach_resource_controller", "mfrmr_cq_ach_execute",
    "mfrmr_cq_ach_readiness_evidence",
    "mfrmr_cq_ach_apply_diagnostic_eligibility",
    "mfrmr_cq_ach_finalize_outcomes", "mfrmr_cq_ach_metric_summary",
    "mfrmr_cq_ach_review_execution", "mfrmr_cq_ado_truth",
    "mfrmr_cq_ado_direct_probability", "mfrmr_cq_ado_person_integral",
    "mfrmr_cq_ameh_response_layout", "mfrmr_cq_ameh_write_csv",
    "mfrmr_cq_ameh_retained_bytes"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_atla_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_atla_contract", envir = target, inherits = TRUE),
    mfrmr_cq_ag4o_authorization_contract
  )
  mfrmr_cq_ag4o_assert(
    all(available) && identity,
    "Source the complete G4O authority and G4C-P4 contracts before review."
  )
  invisible(TRUE)
}

mfrmr_cq_ag4o_bind_contract <- function(target) {
  mfrmr_cq_ag4o_assert(
    is.environment(target), "G4O requires one explicit source environment."
  )
  bindings <- list(
    mfrmr_cq_ataa_output_basename = mfrmr_cq_ag4o_output_basename,
    mfrmr_cq_atla_specification =
      mfrmr_cq_ag4o_authorization_specification,
    mfrmr_cq_atla_contract = mfrmr_cq_ag4o_authorization_contract,
    mfrmr_cq_ach_required_authorization_issuer_contract =
      mfrmr_cq_ag4o_authorization_contract,
    mfrmr_cq_ag4m_specification = mfrmr_cq_ag4o_specification,
    mfrmr_cq_ag4m_contract = mfrmr_cq_ag4o_contract,
    mfrmr_cq_ach_p4_same_frame = mfrmr_cq_ag4o_same_frame,
    mfrmr_cq_ag4m_same_detail = mfrmr_cq_ag4o_same_frame,
    mfrmr_cq_ag4m_require_contracts =
      mfrmr_cq_ag4o_validate_g4m_contracts
  )
  for (name in names(bindings)) {
    assign(name, bindings[[name]], envir = target)
  }
  invisible(bindings)
}

mfrmr_cq_ag4o_source_contracts <- function(source_root, target) {
  root <- normalizePath(source_root, winslash = "/", mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  predecessor <- file.path(
    validation,
    "conquest-adversarial-simulation-tranche-a-live-execution-0.2.3.R"
  )
  launch_tier <- file.path(
    validation,
    "conquest-adversarial-simulation-launch-tier-contract-0.2.3.R"
  )
  mfrmr_cq_ag4o_assert(
    is.environment(target) && file.exists(predecessor) &&
      file.exists(launch_tier),
    "G4O requires the committed G4M and launch-tier sources."
  )
  sys.source(predecessor, envir = target)
  target$mfrmr_cq_ag4m_source_contracts(root, target)
  sys.source(launch_tier, envir = target)
  target$mfrmr_cq_ag4o_bind_contract(target)
  invisible(c(predecessor, launch_tier))
}

mfrmr_cq_ag4o_require_contracts <- function() {
  target <- environment(mfrmr_cq_ag4o_require_contracts)
  required <- c(
    "mfrmr_cq_alt_preissue_probe", "mfrmr_cq_alt_validate_preissue_token",
    "mfrmr_cq_atla_issue", "mfrmr_cq_atla_review",
    "mfrmr_cq_atla_git_worktree_review",
    "mfrmr_cq_ach_consume_authorization", "mfrmr_cq_ach_fresh_sentinel",
    "mfrmr_cq_ag4m_absent_path", "mfrmr_cq_ag4m_authority_snapshot",
    "mfrmr_cq_ag4m_write_csv", "mfrmr_cq_ag4m_sentinel_failure_summary",
    "mfrmr_cq_ag4m_generation", "mfrmr_cq_ag4m_prepare_staging",
    "mfrmr_cq_ag4m_execute_attempts", "mfrmr_cq_ag4m_finalize",
    "mfrmr_cq_ag4m_review", "mfrmr_cq_ag4m_execution_summary"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- identical(
    get("mfrmr_cq_ataa_output_basename", envir = target, inherits = TRUE),
    mfrmr_cq_ag4o_output_basename
  ) && identical(
    get("mfrmr_cq_atla_contract", envir = target, inherits = TRUE),
    mfrmr_cq_ag4o_authorization_contract
  ) && identical(
    get(
      "mfrmr_cq_ach_required_authorization_issuer_contract",
      envir = target, inherits = TRUE
    ),
    mfrmr_cq_ag4o_authorization_contract
  )
  mfrmr_cq_ag4o_assert(
    all(available) && identity,
    "Source and bind the complete G4O successor contract before use."
  )
  invisible(TRUE)
}

mfrmr_cq_ag4o_target <- function(g4x_output_dir) {
  root <- normalizePath(
    dirname(g4x_output_dir), winslash = "/", mustWork = TRUE
  )
  file.path(root, mfrmr_cq_ag4o_output_basename)
}

mfrmr_cq_ag4o_review <- function(
    g4x_output_dir,
    smoke_output_dir = file.path(
      dirname(g4x_output_dir), mfrmr_cq_ase_output_basename
    ),
    run_date = Sys.Date(), worktree_clean_attested = FALSE,
    approval_id = NULL) {
  mfrmr_cq_ag4o_require_contracts()
  target <- mfrmr_cq_ag4o_target(g4x_output_dir)
  staging <- paste0(target, ".incomplete")
  preissue <- paste0(target, ".preissue")
  g4l <- mfrmr_cq_atla_review(
    g4x_output_dir, target, smoke_output_dir,
    authorization_date = run_date,
    worktree_clean = worktree_clean_attested,
    ordinary_tests_external_runtime_free = TRUE
  )
  approved <- identical(approval_id, mfrmr_cq_ag4o_approval_id)
  paths_absent <- !file.exists(target) && !dir.exists(target) &&
    !file.exists(staging) && !dir.exists(staging) &&
    !file.exists(preissue) && !dir.exists(preissue)
  ready_for_live_preissue <- isTRUE(g4l$authorization_issue_ready) &&
    paths_absent && approved && !is.na(as.Date(run_date)[1L]) &&
    as.Date(run_date)[1L] <= mfrmr_cq_ag4o_run_not_after
  list(
    specification = mfrmr_cq_ag4o_specification,
    contract_version = mfrmr_cq_ag4o_contract,
    authorization_contract = mfrmr_cq_ag4o_authorization_contract,
    approval_id = mfrmr_cq_ag4o_approval_id,
    user_approval_received = approved,
    output_dir = target,
    incomplete_dir = staging,
    preissue_dir = preissue,
    all_successor_paths_absent = paths_absent,
    g4l_review = g4l,
    ready_for_live_preissue = ready_for_live_preissue,
    preissue_probe_attempted = FALSE,
    run_authority_issued = FALSE,
    run_authority_consumed = FALSE,
    model_estimation_attempted = FALSE,
    confirmation_use_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_ag4o_issue <- function(
    preissue_token, g4x_output_dir, calibration_output_dir,
    smoke_output_dir, run_date, approval_id = NULL, authorize = FALSE) {
  mfrmr_cq_ag4o_assert(
    identical(authorize, TRUE) &&
      identical(approval_id, mfrmr_cq_ag4o_approval_id),
    "G4O authority requires the exact new user approval and live opt-in."
  )
  mfrmr_cq_ag4o_assert(
    mfrmr_cq_alt_validate_preissue_token(
      preissue_token,
      expected_executable_path = mfrmr_cq_ag4o_executable_path,
      expected_launcher_path = mfrmr_cq_ag4o_launcher_path,
      run_date = run_date
    ),
    "G4O authority requires a valid current-process pre-issue token."
  )
  preissue_token$Consumed <- TRUE
  authorization <- mfrmr_cq_atla_issue(
    g4x_output_dir, calibration_output_dir, smoke_output_dir,
    authorization_date = run_date,
    ordinary_tests_external_runtime_free = TRUE,
    authorize = TRUE
  )
  mfrmr_cq_ag4o_assert(
    isTRUE(preissue_token$Consumed) && !isTRUE(authorization$Consumed) &&
      identical(
        authorization$AuthorizationIssuerContract,
        mfrmr_cq_ag4o_authorization_contract
      ),
    "G4O issued an authority outside the successor token boundary."
  )
  authorization
}

mfrmr_cq_ag4o_execute <- function(
    g4x_output_dir,
    smoke_output_dir = file.path(
      dirname(g4x_output_dir), mfrmr_cq_ase_output_basename
    ),
    run_date = Sys.Date(), approval_id = NULL, authorize = FALSE) {
  mfrmr_cq_ag4o_assert(
    identical(authorize, TRUE) &&
      identical(approval_id, mfrmr_cq_ag4o_approval_id),
    "G4O live execution requires the exact new user approval and opt-in."
  )
  mfrmr_cq_ag4o_require_contracts()
  phase_start <- proc.time()[["elapsed"]]
  target <- mfrmr_cq_ag4o_target(g4x_output_dir)
  staging <- paste0(target, ".incomplete")
  preissue_dir <- paste0(target, ".preissue")
  mfrmr_cq_ag4o_assert(
    !file.exists(target) && !dir.exists(target) &&
      !file.exists(staging) && !dir.exists(staging) &&
      !file.exists(preissue_dir) && !dir.exists(preissue_dir),
    "G4O requires new absent final, incomplete, and pre-issue targets."
  )
  repository_root <- dirname(dirname(
    normalizePath(g4x_output_dir, winslash = "/", mustWork = TRUE)
  ))
  worktree <- mfrmr_cq_atla_git_worktree_review(repository_root)
  pre_review <- mfrmr_cq_atla_review(
    g4x_output_dir, target, smoke_output_dir,
    authorization_date = run_date,
    worktree_clean = worktree$clean,
    ordinary_tests_external_runtime_free = TRUE
  )
  mfrmr_cq_ag4o_assert(
    isTRUE(worktree$clean) && isTRUE(pre_review$authorization_issue_ready),
    "G4O requires a clean source tree and all successor gates before pre-issue."
  )
  mfrmr_cq_ag4o_assert(
    dir.create(preissue_dir, recursive = FALSE, showWarnings = FALSE),
    "G4O could not create its retained pre-issue directory."
  )
  preissue <- mfrmr_cq_alt_preissue_probe(
    executable_path = mfrmr_cq_ag4o_executable_path,
    launcher_path = mfrmr_cq_ag4o_launcher_path,
    run_not_after = mfrmr_cq_ag4o_run_not_after,
    working_dir = preissue_dir,
    run_date = run_date,
    timeout = 30L,
    authorize = TRUE
  )
  authorization <- mfrmr_cq_ag4o_issue(
    preissue_token = preissue$token,
    g4x_output_dir = g4x_output_dir,
    calibration_output_dir = target,
    smoke_output_dir = smoke_output_dir,
    run_date = run_date,
    approval_id = approval_id,
    authorize = TRUE
  )
  mfrmr_cq_ach_consume_authorization(
    authorization, target, authorize = TRUE
  )
  mfrmr_cq_ag4o_assert(
    dir.create(staging, recursive = TRUE, showWarnings = FALSE),
    "G4O could not create its exact incomplete staging root."
  )
  mfrmr_cq_ag4m_write_csv(
    mfrmr_cq_ag4m_authority_snapshot(authorization),
    file.path(staging, "authority_snapshot.csv")
  )
  writeLines("quit;", file.path(staging, "runtime_sentinel.cqc"), useBytes = TRUE)
  sentinel <- tryCatch(
    mfrmr_cq_ach_fresh_sentinel(
      staging, target, mfrmr_cq_ag4o_executable_path, run_date,
      timeout = 30L, authorize = TRUE
    ),
    error = function(error) {
      mfrmr_cq_ag4m_write_csv(
        mfrmr_cq_ag4m_sentinel_failure_summary(error),
        file.path(staging, "execution_summary.csv")
      )
      stop(error)
    }
  )
  generated <- mfrmr_cq_ag4m_generation(authorization, sentinel, target)
  root <- mfrmr_cq_ag4m_prepare_staging(
    staging, target, authorization, generated, sentinel, phase_start
  )
  execution <- mfrmr_cq_ag4m_execute_attempts(root, sentinel, phase_start)
  finalized <- mfrmr_cq_ag4m_finalize(
    root, execution, generated, authorization
  )
  review <- mfrmr_cq_ag4m_review(root)
  summary <- mfrmr_cq_ag4m_execution_summary(
    finalized$final$journal, finalized$final$outcome, finalized$resource,
    retained_review_complete = review$retained_execution_review_complete,
    numeric_agreement_inspected = TRUE
  )
  mfrmr_cq_ag4m_write_csv(summary, file.path(root, "execution_summary.csv"))
  review <- mfrmr_cq_ag4m_review(root)
  list(
    authorization_consumed = isTRUE(authorization$Consumed),
    preissue_token_consumed = isTRUE(preissue$token$Consumed),
    preissue_console_path = preissue$console_path,
    output_dir = root,
    finalization = finalized,
    review = review,
    rerun_authorized = FALSE,
    confirmation_use_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
