# Repository-only result binding for the six ordered candidate-003 executions.
# It validates immutable output and semantic-success identities after launch,
# but does not parse a numerical comparison or infer equivalence.

mfrmr_cq_c3er_specification <-
  "0.2.3-wave-c-conquest-six-arm-candidate-003-execution-result-v1"
mfrmr_cq_c3er_contract <-
  "mfrmr_conquest_six_arm_candidate_003_execution_result_v1"
mfrmr_cq_c3er_candidate_id <- "mfrmr-0.2.3-conquest-six-arm-003"
mfrmr_cq_c3er_output_bundle_sha256 <-
  "efef3f3b18a503b1a70f8bc8667be3655754d2f976e95cf8761a26028a6a0c6a"
mfrmr_cq_c3er_execution_summary_sha256 <-
  "f7bc74ce4cf4fa121333c4de101f37c4d2446d88f30d666ec8f781bdcf58fdc7"

mfrmr_cq_c3er_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_c3er_require_handoff <- function() {
  target <- environment(mfrmr_cq_c3er_require_handoff)
  required <- c(
    "mfrmr_cq_c3eh_semantic_status", "mfrmr_cq_cb_output_registry",
    "mfrmr_cq_cb_canonical_text", "mfrmr_cq_cb_file_sha256"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity_ok <- exists(
    "mfrmr_cq_c3eh_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_c3eh_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_six_arm_candidate_003_execution_handoff_v1"
  ) && identical(
    get("mfrmr_cq_c3eh_candidate_id", envir = target, inherits = TRUE),
    mfrmr_cq_c3er_candidate_id
  )
  mfrmr_cq_c3er_assert(
    all(available) && identity_ok,
    "Source the candidate-003 execution handoff before this result binding."
  )
  invisible(TRUE)
}

mfrmr_cq_c3er_execution_registry <- function() {
  data.frame(
    ExecutionOrder = seq_len(6L),
    ArmId = c(
      "binary_q031", "binary_q061", "rsm_q031", "rsm_q061",
      "pcm_q031", "pcm_q061"
    ),
    ProcessExitStatus = 0L,
    SemanticSuccess = TRUE,
    ExpectedNativeOutputCount = c(6L, 6L, 8L, 8L, 8L, 8L),
    ConsoleSHA256 = c(
      "fe3cb8c001c2cc0299404fc12427d4898c93119ac53a86fb58db283dae190cae",
      "cc5ec33e91d293977b62fc1fc898e7d00b743f81324912162c35ef883f86a776",
      "32312497505108a0a68116c4ce5ca36633510048ca8d9b7ae6e4c8884a91174b",
      "9c0d4bcf74d3469d1850d138495f025d0e4c3598fe0f99a1bee458efc1e99583",
      "a9a64f936c1745c3c51cfea8eee14bd8514acb800ba3ee41caf10958a9610bb5",
      "31d2d713cc46fc91aefb45474257f004c80365da050bfc07295be8e7f6fcd656"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_c3er_execution_summary_hash <- function() {
  mfrmr_cq_c3er_require_handoff()
  digest::digest(
    mfrmr_cq_cb_canonical_text(
      mfrmr_cq_c3er_execution_registry(), "ExecutionOrder"
    ),
    algo = "sha256", serialize = FALSE
  )
}

mfrmr_cq_c3er_output_audit <- function(candidate_root) {
  mfrmr_cq_c3er_require_handoff()
  root <- normalizePath(candidate_root, winslash = "/", mustWork = TRUE)
  output <- mfrmr_cq_cb_output_registry()
  path <- file.path(root, output$RelativePath)
  output$SHA256 <- vapply(path, mfrmr_cq_cb_file_sha256, character(1L))
  output$Bytes <- as.numeric(file.info(path)$size)
  output$Present <- file.exists(path)
  output$Nonempty <- output$Present & is.finite(output$Bytes) & output$Bytes > 0
  hash_columns <- output[, c(
    "ArmId", "OutputKind", "RelativePath", "ExpectedAbsentAtBinding",
    "SHA256", "Bytes"
  )]
  bundle_sha256 <- digest::digest(
    mfrmr_cq_cb_canonical_text(hash_columns, c("ArmId", "OutputKind")),
    algo = "sha256", serialize = FALSE
  )
  list(
    registry = output,
    output_bundle_sha256 = bundle_sha256,
    expected_output_bundle_sha256 = mfrmr_cq_c3er_output_bundle_sha256,
    output_bundle_identity_ok = identical(
      bundle_sha256, mfrmr_cq_c3er_output_bundle_sha256
    ),
    all_50_present = nrow(output) == 50L && all(output$Present),
    all_50_nonempty = nrow(output) == 50L && all(output$Nonempty)
  )
}

mfrmr_cq_c3er_review <- function(candidate_root) {
  mfrmr_cq_c3er_require_handoff()
  root <- normalizePath(candidate_root, winslash = "/", mustWork = TRUE)
  execution <- mfrmr_cq_c3er_execution_registry()
  semantic <- lapply(seq_len(nrow(execution)), function(index) {
    mfrmr_cq_c3eh_semantic_status(
      root, execution$ArmId[index], execution$ProcessExitStatus[index]
    )
  })
  semantic_summary <- data.frame(
    ArmId = execution$ArmId,
    ExitStatusOK = vapply(semantic, `[[`, logical(1L), "exit_status_ok"),
    TerminalMarkerPresent = vapply(
      semantic, `[[`, logical(1L), "terminal_marker_present"
    ),
    FailurePatternCount = vapply(
      semantic, function(x) sum(x$failure_patterns$Observed), integer(1L)
    ),
    NativeOutputCount = vapply(
      semantic, `[[`, integer(1L), "native_output_count"
    ),
    AllNativeOutputsNonempty = vapply(
      semantic, function(x) all(x$native_outputs_nonempty), logical(1L)
    ),
    SemanticSuccess = vapply(
      semantic, `[[`, logical(1L), "semantic_success"
    ),
    stringsAsFactors = FALSE
  )
  console_hash <- vapply(semantic, function(x) {
    mfrmr_cq_cb_file_sha256(x$console_path)
  }, character(1L))
  output <- mfrmr_cq_c3er_output_audit(root)
  summary_sha256 <- mfrmr_cq_c3er_execution_summary_hash()
  summary_identity_ok <- identical(
    summary_sha256, mfrmr_cq_c3er_execution_summary_sha256
  )
  semantic_identity_ok <-
    identical(console_hash, execution$ConsoleSHA256) &&
    identical(semantic_summary$NativeOutputCount,
              execution$ExpectedNativeOutputCount) &&
    all(semantic_summary$SemanticSuccess) &&
    all(execution$SemanticSuccess)
  ready <- isTRUE(output$output_bundle_identity_ok) &&
    isTRUE(output$all_50_present) && isTRUE(output$all_50_nonempty) &&
    summary_identity_ok && semantic_identity_ok
  list(
    specification = mfrmr_cq_c3er_specification,
    contract_version = mfrmr_cq_c3er_contract,
    status = if (ready) {
      "candidate_003_execution_complete_native_comparison_review_pending"
    } else {
      "candidate_003_execution_result_invalid"
    },
    candidate_id = mfrmr_cq_c3er_candidate_id,
    execution_registry = execution,
    semantic_summary = semantic_summary,
    output_audit = output,
    execution_summary_sha256 = summary_sha256,
    expected_execution_summary_sha256 =
      mfrmr_cq_c3er_execution_summary_sha256,
    execution_summary_identity_ok = summary_identity_ok,
    semantic_identity_ok = semantic_identity_ok,
    execution_complete = ready,
    execution_handoff_consumed = TRUE,
    rerun_authorized = FALSE,
    numerical_comparison_review_authorized = ready,
    comparison_passed = FALSE,
    scientific_equivalence_inferred = FALSE,
    inference_ready = FALSE,
    confirmation_authorized = FALSE,
    sparse_extension_authorized = FALSE,
    gpcm_extension_authorized = FALSE,
    large_simulation_authorized = FALSE
  )
}
