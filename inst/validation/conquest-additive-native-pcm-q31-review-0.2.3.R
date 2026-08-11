# mfrmr 0.2.3 repository-only review of the native ConQuest PCM q=31 arm
#
# This checker mirrors the bounded RSM review for criterion-specific steps.
# It establishes export/schema and exact A-matrix readiness only; it does not
# infer a rounding rule, tolerance, scientific equivalence, or confirmation.

mfrmr_cq_native_pcm_q31_specification <-
  "0.2.3-wave-c-native-pcm-q31-review-v1"
mfrmr_cq_native_pcm_q31_contract <-
  "mfrmr_conquest_native_pcm_q31_review_v1"

mfrmr_cq_native_pcm_q31_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_native_pcm_q31_expected_amatrix <- function() {
  design <- expand.grid(
    Rater = c("R1", "R2"),
    Criterion = c("C1", "C2"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  score <- rep(0:3, times = nrow(design))
  design <- design[rep(seq_len(nrow(design)), each = 4L), , drop = FALSE]
  step_1 <- c(0L, -1L, -1L, 0L)[score + 1L]
  step_2 <- c(0L, 0L, -1L, 0L)[score + 1L]
  data.frame(
    GIN = rep(seq_len(4L), each = 4L),
    Category = score + 1L,
    `rater R1` = ifelse(design$Rater == "R1", -score, score),
    `criterion C1` = ifelse(design$Criterion == "C1", -score, score),
    `criterion C1 category 1` = ifelse(
      design$Criterion == "C1", step_1, 0L
    ),
    `criterion C1 category 2` = ifelse(
      design$Criterion == "C1", step_2, 0L
    ),
    `criterion C2 category 1` = ifelse(
      design$Criterion == "C2", step_1, 0L
    ),
    `criterion C2 category 2` = ifelse(
      design$Criterion == "C2", step_2, 0L
    ),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_native_pcm_q31_paths <- function(output_dir) {
  output_dir <- normalizePath(
    as.character(output_dir)[1], winslash = "/", mustWork = TRUE
  )
  prefix <- "cq_additive_pcm_q031"
  run_dir <- file.path(output_dir, "pcm_q031")
  list(
    output_dir = output_dir,
    run_dir = run_dir,
    manifest = file.path(output_dir, "conquest_additive_mfrm_manifest.csv"),
    command = file.path(run_dir, paste0(prefix, ".cqc")),
    wide = file.path(run_dir, paste0(prefix, "_wide.csv")),
    amatrix = file.path(run_dir, paste0(prefix, "_conquest_amatrix.csv")),
    cases = file.path(run_dir, paste0(prefix, "_conquest_cases_eap.csv")),
    covariance = file.path(run_dir, paste0(prefix, "_conquest_covariance.csv")),
    history = file.path(run_dir, paste0(prefix, "_conquest_history.csv")),
    internal_log = file.path(run_dir, paste0(prefix, "_conquest_internal.log")),
    parameters = file.path(run_dir, paste0(prefix, "_conquest_parameters.csv")),
    parameter_review = file.path(
      run_dir, paste0(prefix, "_conquest_parameters_review.txt")
    ),
    regression = file.path(
      run_dir, paste0(prefix, "_conquest_reg_coefficients.csv")
    ),
    reference_manifest = file.path(
      output_dir, "mfrmr_reference", "reference_manifest.csv"
    ),
    reference_parameters = file.path(
      output_dir, "mfrmr_reference", "pcm_q031_mfrmr_reference_parameters.csv"
    ),
    reference_summary = file.path(
      output_dir, "mfrmr_reference", "pcm_q031_mfrmr_reference_summary.csv"
    )
  )
}

mfrmr_cq_native_pcm_q31_reference_differences <- function(paths) {
  native_parameters <- utils::read.csv(
    paths$parameters, check.names = FALSE, stringsAsFactors = FALSE
  )
  native_regression <- utils::read.csv(
    paths$regression, check.names = FALSE, stringsAsFactors = FALSE
  )
  native_covariance <- utils::read.csv(
    paths$covariance, check.names = FALSE, stringsAsFactors = FALSE
  )
  native_history <- utils::read.csv(
    paths$history, check.names = FALSE, stringsAsFactors = FALSE
  )
  reference_parameters <- utils::read.csv(
    paths$reference_parameters, check.names = FALSE, stringsAsFactors = FALSE
  )
  reference_summary <- utils::read.csv(
    paths$reference_summary, check.names = FALSE, stringsAsFactors = FALSE
  )
  export_levels <- c(
    "R1", "C1", "C1:Step1", "C1:Step2", "C2:Step1", "C2:Step2"
  )
  reference_value <- c(
    reference_parameters$Estimate[
      reference_parameters$Level == "Intercept"
    ],
    reference_parameters$Estimate[reference_parameters$Level == "X"],
    reference_parameters$Estimate[
      reference_parameters$Level == "Variance"
    ],
    reference_parameters$Estimate[match(
      export_levels, reference_parameters$Level
    )],
    reference_summary$Deviance
  )
  native_value <- c(
    native_regression$Estimate[1:2],
    native_covariance$Covariance[1],
    native_parameters$Estimate[1:6],
    utils::tail(native_history$LogLikelihood, 1L)
  )
  coordinate <- c(
    "population_intercept", "population_slope", "population_variance",
    "rater_R1", "criterion_C1", "criterion_C1_step_1",
    "criterion_C1_step_2", "criterion_C2_step_1", "criterion_C2_step_2",
    "deviance"
  )
  mfrmr_cq_native_pcm_q31_assert(
    length(native_value) == length(reference_value) &&
      all(is.finite(c(native_value, reference_value))),
    "The native/reference PCM q=31 coordinate extraction is incomplete."
  )
  data.frame(
    Coordinate = coordinate,
    NativeValue = native_value,
    MfrmrReferenceValue = reference_value,
    Difference = native_value - reference_value,
    AbsDifference = abs(native_value - reference_value),
    AcceptanceThresholdSpecified = FALSE,
    AcceptanceDecision = NA,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_review_conquest_additive_native_pcm_q31 <- function(output_dir) {
  helper_environment <- environment(
    mfrmr_review_conquest_additive_native_pcm_q31
  )
  required_helpers <- c(
    "mfrmr_cq_additive_hash_file",
    "mfrmr_cq_resolution_audit_native_exports"
  )
  mfrmr_cq_native_pcm_q31_assert(
    all(vapply(
      required_helpers, exists, logical(1), envir = helper_environment,
      mode = "function", inherits = TRUE
    )),
    "Source the additive design and numeric-resolution contracts before the native PCM q=31 review."
  )
  paths <- mfrmr_cq_native_pcm_q31_paths(output_dir)
  required_names <- c(
    "manifest", "command", "wide", "amatrix", "cases", "covariance",
    "history", "internal_log", "parameters", "parameter_review",
    "regression", "reference_manifest", "reference_parameters",
    "reference_summary"
  )
  required <- unlist(paths[required_names], use.names = FALSE)
  missing <- required[!file.exists(required)]
  mfrmr_cq_native_pcm_q31_assert(
    length(missing) == 0L,
    paste0("The native PCM q=31 review is missing: ",
           paste(basename(missing), collapse = ", "), ".")
  )

  manifest <- utils::read.csv(
    paths$manifest, check.names = FALSE, stringsAsFactors = FALSE
  )
  row <- manifest[manifest$RunId == "pcm_q031", , drop = FALSE]
  mfrmr_cq_native_pcm_q31_assert(
    nrow(row) == 1L && row$Model == "PCM" && row$Nodes == 31L &&
      row$ExpectedNpar == 9L &&
      identical(mfrmr_cq_additive_hash_file(paths$command), row$CommandSHA256) &&
      identical(mfrmr_cq_additive_hash_file(paths$wide), row$WideSHA256),
    "The native PCM q=31 command/input identity does not match the sealed manifest."
  )

  amatrix <- utils::read.csv(
    paths$amatrix, check.names = FALSE, stringsAsFactors = FALSE
  )
  expected_amatrix <- mfrmr_cq_native_pcm_q31_expected_amatrix()
  mfrmr_cq_native_pcm_q31_assert(
    identical(amatrix, expected_amatrix),
    "The native PCM q=31 A matrix does not match the exact criterion-step coordinate map."
  )

  parameters <- utils::read.csv(
    paths$parameters, check.names = FALSE, stringsAsFactors = FALSE
  )
  regression <- utils::read.csv(
    paths$regression, check.names = FALSE, stringsAsFactors = FALSE
  )
  covariance <- utils::read.csv(
    paths$covariance, check.names = FALSE, stringsAsFactors = FALSE
  )
  history <- utils::read.csv(
    paths$history, check.names = FALSE, stringsAsFactors = FALSE
  )
  cases <- utils::read.csv(
    paths$cases, check.names = FALSE, stringsAsFactors = FALSE
  )
  expected_labels <- c(
    "rater R1", "criterion C1", "criterion C1 category 1",
    "criterion C1 category 2", "criterion C2 category 1",
    "criterion C2 category 2"
  )
  mfrmr_cq_native_pcm_q31_assert(
    identical(parameters$P, 1:6) &&
      identical(trimws(parameters$Label), expected_labels) &&
      identical(regression$Dimension, c(1L, 1L)) &&
      identical(regression$Regressor, 1:2) &&
      nrow(covariance) == 1L && covariance$Dim1 == 1L &&
      covariance$Dim2 == 1L && nrow(history) == 95L &&
      identical(history$Iteration, 1:95) && nrow(cases) == 96L &&
      length(unique(trimws(cases$PID))) == 96L,
    "The native PCM q=31 exports do not match the audited row/label schema."
  )
  log_lines <- readLines(paths$internal_log, warn = FALSE)
  review_lines <- readLines(paths$parameter_review, warn = FALSE)
  mfrmr_cq_native_pcm_q31_assert(
    any(grepl("Iteration=  95", log_lines, fixed = TRUE)) &&
      any(grepl("Deviance=       930.505", log_lines, fixed = TRUE)) &&
      any(grepl("Version: 5.47.5", review_lines, fixed = TRUE)),
    "The native log/review does not bind iteration 95, deviance, and version 5.47.5."
  )

  resolution <- mfrmr_cq_resolution_audit_native_exports(
    history_file = paths$history,
    parameter_file = paths$parameters,
    regression_file = paths$regression,
    covariance_file = paths$covariance,
    case_file = paths$cases,
    rounding_rules = "unknown"
  )
  mfrmr_cq_native_pcm_q31_assert(
    identical(resolution$status,
              "raw_tokens_retained_rounding_unestablished"),
    "The native PCM q=31 numeric-token audit did not retain the unknown-rounding state."
  )
  differences <- mfrmr_cq_native_pcm_q31_reference_differences(paths)

  out <- list(
    specification = mfrmr_cq_native_pcm_q31_specification,
    contract_version = mfrmr_cq_native_pcm_q31_contract,
    decision = "schema_amatrix_ready_pcm_q31_only",
    execution_complete = TRUE,
    native_design_matrix_observed = TRUE,
    native_design_matrix_exact = TRUE,
    free_dimension = 9L,
    history_header_semantics =
      "LogLikelihood_column_contains_positive_deviance",
    raw_token_status = resolution$status,
    comparison_ready = FALSE,
    candidate_bound = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    expected_amatrix = expected_amatrix,
    resolution = resolution,
    descriptive_differences = differences
  )
  class(out) <- c("mfrmr_conquest_native_pcm_q31_review", class(out))
  out
}
