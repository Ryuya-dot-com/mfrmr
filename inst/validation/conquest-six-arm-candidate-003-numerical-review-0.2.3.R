# Repository-only exact-reported-decimal numerical review for candidate 003.
# It consumes the bound 50-file execution result and the prospectively frozen
# 57-row tolerance table. It never launches or reruns ConQuest.

mfrmr_cq_c3nr_specification <-
  "0.2.3-wave-c-conquest-six-arm-candidate-003-numerical-review-v1"
mfrmr_cq_c3nr_contract <-
  "mfrmr_conquest_six_arm_candidate_003_numerical_review_v1"
mfrmr_cq_c3nr_candidate_id <- "mfrmr-0.2.3-conquest-six-arm-003"
mfrmr_cq_c3nr_coordinate_bundle_sha256 <-
  "77ada46c876b3280b054f423b6a5717e71643ad65716796256f92c08c90b0dac"
mfrmr_cq_c3nr_ledger_bundle_sha256 <-
  "8a248d978ee4b319351110404380caa242bf58e4cb20abbd9d3d745b45c2b8f0"

mfrmr_cq_c3nr_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_c3nr_require_contracts <- function() {
  target <- environment(mfrmr_cq_c3nr_require_contracts)
  required <- c(
    "mfrmr_cq_c3er_review", "mfrmr_review_conquest_additive_native_four_arms",
    "mfrmr_cq_native_four_arm_files", "mfrmr_cq_rop_review_four_arm",
    "mfrmr_cq_rop_validate_policy", "mfrmr_cq_brop_arm_token_rows",
    "mfrmr_cq_brop_rows_sha256", "mfrmr_cq_brop_validate_policy",
    "mfrmr_cq_becec_coordinate_registry", "mfrmr_cq_ecec_coordinate_registry",
    "mfrmr_cq_ptf_build_tolerances", "mfrmr_cq_ptf_validate_tolerances",
    "mfrmr_cq_cb_canonical_text"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity_ok <- exists(
    "mfrmr_cq_c3er_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_c3er_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_six_arm_candidate_003_execution_result_v1"
  ) && identical(
    get("mfrmr_cq_c3er_candidate_id", envir = target, inherits = TRUE),
    mfrmr_cq_c3nr_candidate_id
  )
  mfrmr_cq_c3nr_assert(
    all(available) && identity_ok,
    "Source all candidate-003 execution, native-token, and tolerance contracts."
  )
  invisible(TRUE)
}

mfrmr_cq_c3nr_additive_review <- function(additive_root) {
  mfrmr_cq_c3nr_require_contracts()
  base_files <- mfrmr_cq_native_four_arm_files
  reviewer <- mfrmr_review_conquest_additive_native_four_arms
  reviewer_environment <- new.env(parent = environment(reviewer))
  reviewer_environment$mfrmr_cq_native_four_arm_files <- function(
      output_dir, run_id) {
    files <- base_files(output_dir, run_id)
    files$console <- file.path(
      output_dir, run_id, paste0("cq_additive_", run_id, "_console.log")
    )
    files
  }
  environment(reviewer) <- reviewer_environment
  reviewer(additive_root)
}

mfrmr_cq_c3nr_binary_policy <- function(binary_root) {
  rows <- do.call(rbind, lapply(c("q031a", "q061"), function(run_id) {
    mfrmr_cq_brop_arm_token_rows(binary_root, run_id)
  }))
  rownames(rows) <- NULL
  policy <- list(
    specification = mfrmr_cq_becec_specification,
    contract_version = mfrmr_cq_brop_contract,
    policy_id = mfrmr_cq_rop_policy_id,
    rows_sha256 = mfrmr_cq_brop_rows_sha256(rows),
    status = "reported_output_stratum_ready_hidden_solution_unresolved",
    reported_output_estimand_ready = TRUE,
    hidden_solution_interval_available = FALSE,
    hidden_solution_equivalence_eligible = FALSE,
    rounding_rule_inferred = FALSE,
    tolerance_frozen = FALSE,
    candidate_bound = TRUE,
    comparison_ready = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    rows = rows
  )
  class(policy) <- c(
    "mfrmr_conquest_binary_reported_output_precision", class(policy)
  )
  mfrmr_cq_brop_validate_policy(policy)
  policy
}

mfrmr_cq_c3nr_coordinate_rows <- function(candidate_root) {
  mfrmr_cq_c3nr_require_contracts()
  root <- normalizePath(candidate_root, winslash = "/", mustWork = TRUE)
  binary_root <- file.path(root, "binary")
  additive_root <- file.path(root, "additive")
  additive_review <- mfrmr_cq_c3nr_additive_review(additive_root)
  mfrmr_cq_c3nr_assert(
    isTRUE(additive_review$four_arms_complete) &&
      isTRUE(additive_review$native_design_matrices_exact) &&
      isTRUE(additive_review$complete_console_transcripts),
    "The candidate-003 additive native review is incomplete."
  )
  additive_policy <- mfrmr_cq_rop_review_four_arm(
    additive_root, additive_review
  )
  mfrmr_cq_rop_validate_policy(additive_policy)
  binary_policy <- mfrmr_cq_c3nr_binary_policy(binary_root)

  binary <- binary_policy$rows
  binary_registry <- mfrmr_cq_becec_coordinate_registry()
  binary$Family <- "Binary"
  binary$Nodes <- ifelse(binary$RunId == "q031a", 31L, 61L)
  binary$ParameterClass <- binary_registry$ParameterClass[
    match(binary$Coordinate, binary_registry$Coordinate)
  ]

  additive <- additive_policy$rows
  additive$Family <- additive$Model
  additive$Nodes <- ifelse(grepl("q031$", additive$RunId), 31L, 61L)
  additive$ParameterClass <- vapply(seq_len(nrow(additive)), function(index) {
    registry <- mfrmr_cq_ecec_coordinate_registry(additive$Family[index])
    registry$ParameterClass[
      match(additive$Coordinate[index], registry$Coordinate)
    ]
  }, character(1L))

  columns <- c(
    "RunId", "Family", "Nodes", "Coordinate", "ParameterClass",
    "NativeToken", "NativeValue", "CanonicalExactDecimal",
    "MfrmrReferenceValue", "SignedReportedDifference",
    "AbsoluteReportedDifference", "Metric", "SourcePrecisionStatus"
  )
  rows <- rbind(binary[, columns], additive[, columns])
  rows <- rows[order(rows$Family, rows$Nodes, rows$Coordinate), , drop = FALSE]
  rownames(rows) <- NULL
  mfrmr_cq_c3nr_assert(
    nrow(rows) == 54L &&
      identical(as.integer(table(rows$Family)[c("Binary", "PCM", "RSM")]),
                c(18L, 20L, 16L)) &&
      !anyDuplicated(paste(rows$Family, rows$Nodes, rows$Coordinate)) &&
      all(is.finite(rows$NativeValue)) &&
      all(is.finite(rows$MfrmrReferenceValue)) &&
      all(rows$SourcePrecisionStatus == "match") &&
      all(rows$Metric == "absolute_difference_to_exact_reported_decimal"),
    "The candidate-003 54-coordinate reported-decimal ledger is invalid."
  )
  list(
    rows = rows,
    additive_review = additive_review,
    additive_policy = additive_policy,
    binary_policy = binary_policy
  )
}

mfrmr_cq_c3nr_integration_rows <- function(rows) {
  split_index <- split(
    seq_len(nrow(rows)), paste(rows$Family, rows$Coordinate, sep = "\r")
  )
  make_engine <- function(engine, value_column) {
    out <- lapply(split_index, function(index) {
      arm <- rows[index, , drop = FALSE]
      mfrmr_cq_c3nr_assert(
        nrow(arm) == 2L && identical(sort(arm$Nodes), c(31L, 61L)) &&
          length(unique(arm$ParameterClass)) == 1L,
        "A q31/q61 coordinate pair is incomplete or ambiguous."
      )
      value <- arm[[value_column]]
      data.frame(
        Engine = engine,
        Family = arm$Family[1L],
        Coordinate = arm$Coordinate[1L],
        ParameterClass = arm$ParameterClass[1L],
        SignedDifference = value[arm$Nodes == 61L] - value[arm$Nodes == 31L],
        stringsAsFactors = FALSE
      )
    })
    do.call(rbind, out)
  }
  out <- rbind(
    make_engine("ConQuest", "NativeValue"),
    make_engine("mfrmr", "MfrmrReferenceValue")
  )
  rownames(out) <- NULL
  mfrmr_cq_c3nr_assert(
    nrow(out) == 54L && all(is.finite(out$SignedDifference)),
    "The candidate-003 integration-difference ledger is invalid."
  )
  out
}

mfrmr_cq_c3nr_tolerance_ledger <- function(rows, tolerances) {
  integration <- mfrmr_cq_c3nr_integration_rows(rows)
  ledger <- lapply(seq_len(nrow(tolerances)), function(index) {
    tolerance <- tolerances[index, , drop = FALSE]
    value <- if (tolerance$CriterionId == "EXT-CQ-TOL") {
      rows$SignedReportedDifference[
        rows$Family == tolerance$Family &
          rows$ParameterClass == tolerance$EstimandClass
      ]
    } else {
      integration$SignedDifference[
        integration$Engine == tolerance$Engine &
          integration$Family == tolerance$Family &
          integration$ParameterClass == tolerance$EstimandClass
      ]
    }
    mfrmr_cq_c3nr_assert(
      length(value) > 0L && all(is.finite(value)),
      paste0("No finite observations exist for `", tolerance$ToleranceRowId,
             "`.")
    )
    signed_pass <- all(
      value >= tolerance$SignedLower & value <= tolerance$SignedUpper
    )
    absolute_pass <- all(abs(value) <= tolerance$AbsoluteTolerance)
    data.frame(
      ToleranceRowId = tolerance$ToleranceRowId,
      CriterionId = tolerance$CriterionId,
      Engine = tolerance$Engine,
      Family = tolerance$Family,
      EstimandClass = tolerance$EstimandClass,
      Units = tolerance$Units,
      ObservationCount = length(value),
      SignedMinimum = min(value),
      SignedMaximum = max(value),
      MaximumAbsoluteDifference = max(abs(value)),
      SignedLower = tolerance$SignedLower,
      SignedUpper = tolerance$SignedUpper,
      AbsoluteTolerance = tolerance$AbsoluteTolerance,
      SignedPass = signed_pass,
      AbsolutePass = absolute_pass,
      RowPass = signed_pass && absolute_pass,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, ledger)
  rownames(out) <- NULL
  mfrmr_cq_c3nr_assert(
    nrow(out) == 57L && !anyDuplicated(out$ToleranceRowId),
    "The candidate-003 tolerance ledger must contain 57 unique rows."
  )
  list(ledger = out, integration = integration)
}

mfrmr_cq_c3nr_coordinate_hash <- function(rows) {
  stable <- rows[order(
    rows$Family, rows$Nodes, rows$Coordinate, method = "radix"
  ), , drop = FALSE]
  stable$CanonicalRowOrder <- seq_len(nrow(stable))
  digest::digest(
    mfrmr_cq_cb_canonical_text(
      stable, "CanonicalRowOrder"
    ),
    algo = "sha256", serialize = FALSE
  )
}

mfrmr_cq_c3nr_ledger_hash <- function(ledger) {
  stable <- ledger[order(ledger$ToleranceRowId, method = "radix"), , drop = FALSE]
  stable$CanonicalRowOrder <- seq_len(nrow(stable))
  digest::digest(
    mfrmr_cq_cb_canonical_text(stable, "CanonicalRowOrder"),
    algo = "sha256", serialize = FALSE
  )
}

mfrmr_cq_c3nr_review <- function(candidate_root) {
  mfrmr_cq_c3nr_require_contracts()
  execution <- mfrmr_cq_c3er_review(candidate_root)
  mfrmr_cq_c3nr_assert(
    isTRUE(execution$execution_complete) &&
      isTRUE(execution$numerical_comparison_review_authorized),
    "The bound candidate-003 execution result is not review-ready."
  )
  coordinate <- mfrmr_cq_c3nr_coordinate_rows(candidate_root)
  tolerances <- mfrmr_cq_ptf_build_tolerances()
  tolerance_status <- mfrmr_cq_ptf_validate_tolerances(tolerances)
  adjudication <- mfrmr_cq_c3nr_tolerance_ledger(
    coordinate$rows, tolerances
  )
  coordinate_sha256 <- mfrmr_cq_c3nr_coordinate_hash(coordinate$rows)
  ledger_sha256 <- mfrmr_cq_c3nr_ledger_hash(adjudication$ledger)
  identity_ok <- identical(
    coordinate_sha256, mfrmr_cq_c3nr_coordinate_bundle_sha256
  ) && identical(ledger_sha256, mfrmr_cq_c3nr_ledger_bundle_sha256)
  passed <- isTRUE(tolerance_status$all_rows_ready) && identity_ok &&
    all(adjudication$ledger$RowPass)
  list(
    specification = mfrmr_cq_c3nr_specification,
    contract_version = mfrmr_cq_c3nr_contract,
    status = if (passed) {
      "candidate_003_exact_reported_decimal_all_57_rows_pass"
    } else {
      "candidate_003_numerical_comparison_failed_or_invalid"
    },
    candidate_id = mfrmr_cq_c3nr_candidate_id,
    execution = execution,
    tolerance_status = tolerance_status,
    coordinate_rows = coordinate$rows,
    integration_rows = adjudication$integration,
    tolerance_ledger = adjudication$ledger,
    additive_native_review = coordinate$additive_review,
    additive_reported_output_policy = coordinate$additive_policy,
    binary_reported_output_policy = coordinate$binary_policy,
    coordinate_bundle_sha256 = coordinate_sha256,
    expected_coordinate_bundle_sha256 =
      mfrmr_cq_c3nr_coordinate_bundle_sha256,
    ledger_bundle_sha256 = ledger_sha256,
    expected_ledger_bundle_sha256 = mfrmr_cq_c3nr_ledger_bundle_sha256,
    bundle_identity_ok = identity_ok,
    coordinate_rows_observed = nrow(coordinate$rows),
    tolerance_rows_expected = 57L,
    tolerance_rows_observed = nrow(adjudication$ledger),
    tolerance_rows_passed = sum(adjudication$ledger$RowPass),
    cross_engine_rows_passed = sum(
      adjudication$ledger$CriterionId == "EXT-CQ-TOL" &
        adjudication$ledger$RowPass
    ),
    integration_rows_passed = sum(
      adjudication$ledger$CriterionId == "IC-INTEGRATION-TOL" &
        adjudication$ledger$RowPass
    ),
    comparison_passed = passed,
    reported_decimal_confirmation_passed = passed,
    source_precision_scope = "exact_reported_decimal",
    hidden_solution_interval_available = FALSE,
    hidden_solution_equivalence_eligible = FALSE,
    scientific_equivalence_inferred = FALSE,
    inference_ready = FALSE,
    dff_fit_rank_invariance_evaluated = FALSE,
    generic_confirmation_authorized = FALSE,
    release_authorized = FALSE,
    sparse_extension_authorized = FALSE,
    gpcm_extension_authorized = FALSE,
    large_simulation_authorized = FALSE
  )
}
