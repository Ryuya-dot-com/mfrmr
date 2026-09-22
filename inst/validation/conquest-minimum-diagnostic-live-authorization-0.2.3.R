# Repository-only live binding for the minimum P2 ConQuest diagnostic.
#
# This file records a data-free runtime observation and disclosed maintainer
# attestation. It can authorize only the exact diagnostic slice frozen by the
# minimum-authorization contract. It never launches either engine and cannot
# promote evidence, widen execution, authorize P3, or create a public claim.

mfrmr_cq_mdal_specification <-
  "0.2.3-conquest-minimum-diagnostic-live-authorization-v1"
mfrmr_cq_mdal_contract <-
  "mfrmr_conquest_minimum_diagnostic_live_authorization_v1"
mfrmr_cq_mdal_observation_date <- as.Date("2026-08-15")
mfrmr_cq_mdal_run_not_after <- as.Date("2026-08-16")
mfrmr_cq_mdal_executable_path <- "/Applications/ConQuest/ConQuest"

mfrmr_cq_mdal_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_mdal_require_contracts <- function() {
  target <- environment(mfrmr_cq_mdal_require_contracts)
  ready <- exists("mfrmr_cq_mda_contract", envir = target, inherits = TRUE) &&
    identical(
      get("mfrmr_cq_mda_contract", envir = target, inherits = TRUE),
      "mfrmr_conquest_minimum_diagnostic_authorization_v1"
    ) &&
    exists("mfrmr_cq_srp_contract", envir = target, inherits = TRUE) &&
    identical(
      get("mfrmr_cq_srp_contract", envir = target, inherits = TRUE),
      "mfrmr_conquest_semantic_runtime_preflight_v1"
    ) &&
    exists("mfrmr_cq_srp_assess", envir = target, mode = "function",
           inherits = TRUE) &&
    exists("mfrmr_cq_mda_assess", envir = target, mode = "function",
           inherits = TRUE)
  mfrmr_cq_mdal_assert(
    ready,
    "Source the exact runtime and minimum diagnostic authorization contracts."
  )
  invisible(TRUE)
}

mfrmr_cq_mdal_runtime_observation <- function() {
  mfrmr_cq_mdal_require_contracts()
  mfrmr_cq_srp_assess(
    console_lines = c(
      "ConQuest version: 5.47.5",
      "Demonstration Version",
      "This version expires 1 September 2026",
      "<End of Program"
    ),
    exit_status = 0L,
    executable_path = mfrmr_cq_mdal_executable_path,
    executable_available = TRUE,
    executable = TRUE,
    launcher_available = TRUE,
    architecture = paste0(
      mfrmr_cq_mdal_executable_path,
      ": Mach-O 64-bit executable x86_64"
    ),
    invocation_route = paste(
      "/usr/bin/arch -x86_64", shQuote(mfrmr_cq_mdal_executable_path)
    ),
    locale = "C.UTF-8/C.UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8",
    run_date = mfrmr_cq_mdal_observation_date,
    command_is_data_free_quit = TRUE
  )
}

mfrmr_cq_mdal_attestation <- function() {
  mfrmr_cq_mdal_require_contracts()
  mfrmr_cq_mda_attestation(
    auditor_id = "Codex maintainer audit 2026-08-15",
    reviewer_role = "maintainer",
    author_overlap_declared = TRUE,
    fatal_gate_checklist_completed = TRUE,
    exact_slice_and_cap_accepted = TRUE,
    no_interpretive_claim_accepted = TRUE,
    audit_date = mfrmr_cq_mdal_observation_date
  )
}

mfrmr_cq_mdal_review <- function(
    authorization_date = mfrmr_cq_mdal_observation_date) {
  mfrmr_cq_mdal_require_contracts()
  authorization_date <- as.Date(authorization_date)[1L]
  assessment <- mfrmr_cq_mda_assess(
    runtime_preflight = mfrmr_cq_mdal_runtime_observation(),
    explicit_executable_path = mfrmr_cq_mdal_executable_path,
    attestation = mfrmr_cq_mdal_attestation(),
    authorization_date = authorization_date,
    candidate_outputs_absent = TRUE,
    ordinary_tests_external_runtime_free = TRUE,
    worktree_clean = TRUE,
    maximum_preflight_age_days = 1L
  )
  within_live_window <- !is.na(authorization_date) &&
    authorization_date >= mfrmr_cq_mdal_observation_date &&
    authorization_date <= mfrmr_cq_mdal_run_not_after
  authorized <- within_live_window &&
    isTRUE(assessment$smallest_P2_diagnostic_execution_authorized)
  list(
    specification = mfrmr_cq_mdal_specification,
    contract_version = mfrmr_cq_mdal_contract,
    status = if (authorized) {
      "minimum_P2_diagnostic_live_authorization_active"
    } else {
      "minimum_P2_diagnostic_live_authorization_inactive"
    },
    observation_date = mfrmr_cq_mdal_observation_date,
    run_not_after = mfrmr_cq_mdal_run_not_after,
    authorization_date = authorization_date,
    executable_path = mfrmr_cq_mdal_executable_path,
    runtime_observation = mfrmr_cq_mdal_runtime_observation(),
    attestation = mfrmr_cq_mdal_attestation(),
    assessment = assessment,
    all_fifteen_fatal_gates_passed = all(assessment$gates$Passed),
    smallest_P2_diagnostic_execution_authorized = authorized,
    independent_comprehensive_review_passed = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
