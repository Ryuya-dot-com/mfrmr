# mfrmr 0.2.3 repository-only review of all four native ConQuest arms
#
# Source the additive design, numeric-resolution, RSM q31 review, and PCM q31
# review files first. This checker reads completed native artifacts; it never
# launches ConQuest and never promotes descriptive agreement to equivalence.

mfrmr_cq_native_four_arm_specification <-
  "0.2.3-wave-c-native-four-arm-review-v1"
mfrmr_cq_native_four_arm_contract <-
  "mfrmr_conquest_native_four_arm_review_v1"

mfrmr_cq_native_four_arm_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_native_four_arm_files <- function(output_dir, run_id) {
  run_id <- as.character(run_id)[1]
  prefix <- paste0("cq_additive_", run_id)
  run_dir <- file.path(output_dir, run_id)
  list(
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
    console = file.path(run_dir, paste0(run_id, "_console.txt"))
  )
}

mfrmr_cq_native_four_arm_reference <- function(
    output_dir, run_id, model, native_parameters, native_regression,
    native_covariance, native_history) {
  reference_dir <- file.path(output_dir, "mfrmr_reference")
  parameter_file <- file.path(
    reference_dir, paste0(run_id, "_mfrmr_reference_parameters.csv")
  )
  summary_file <- file.path(
    reference_dir, paste0(run_id, "_mfrmr_reference_summary.csv")
  )
  reference_parameters <- utils::read.csv(
    parameter_file, check.names = FALSE, stringsAsFactors = FALSE
  )
  reference_summary <- utils::read.csv(
    summary_file, check.names = FALSE, stringsAsFactors = FALSE
  )
  export_levels <- if (model == "RSM") {
    c("R1", "C1", "Step1", "Step2")
  } else {
    c("R1", "C1", "C1:Step1", "C1:Step2", "C2:Step1", "C2:Step2")
  }
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
    native_regression$Estimate,
    native_covariance$Covariance[1],
    native_parameters$Estimate,
    utils::tail(native_history$LogLikelihood, 1L)
  )
  mfrmr_cq_native_four_arm_assert(
    length(native_value) == length(reference_value) &&
      all(is.finite(c(native_value, reference_value))),
    paste0("The native/reference coordinates are incomplete for `", run_id, "`.")
  )
  data.frame(
    RunId = run_id,
    Model = model,
    Coordinate = c(
      "population_intercept", "population_slope", "population_variance",
      export_levels, "deviance"
    ),
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

mfrmr_review_conquest_additive_native_four_arms <- function(output_dir) {
  helper_environment <- environment(
    mfrmr_review_conquest_additive_native_four_arms
  )
  required_helpers <- c(
    "mfrmr_cq_additive_hash_file",
    "mfrmr_cq_resolution_audit_native_exports",
    "mfrmr_cq_native_rsm_q31_expected_amatrix",
    "mfrmr_cq_native_pcm_q31_expected_amatrix",
    "mfrmr_review_conquest_additive_native_rsm_q31",
    "mfrmr_review_conquest_additive_native_pcm_q31"
  )
  mfrmr_cq_native_four_arm_assert(
    all(vapply(
      required_helpers, exists, logical(1), envir = helper_environment,
      mode = "function", inherits = TRUE
    )),
    "Source all four prerequisite ConQuest validation files before review."
  )
  output_dir <- normalizePath(
    as.character(output_dir)[1], winslash = "/", mustWork = TRUE
  )
  rsm_q31 <- mfrmr_review_conquest_additive_native_rsm_q31(output_dir)
  pcm_q31 <- mfrmr_review_conquest_additive_native_pcm_q31(output_dir)
  manifest_file <- file.path(output_dir, "conquest_additive_mfrm_manifest.csv")
  reference_manifest_file <- file.path(
    output_dir, "mfrmr_reference", "reference_manifest.csv"
  )
  manifest <- utils::read.csv(
    manifest_file, check.names = FALSE, stringsAsFactors = FALSE
  )
  reference_manifest <- utils::read.csv(
    reference_manifest_file, check.names = FALSE, stringsAsFactors = FALSE
  )
  expected_run_ids <- c("rsm_q031", "rsm_q061", "pcm_q031", "pcm_q061")
  plan_columns <- c("RunId", "Model", "Nodes", "ExpectedNpar")
  mfrmr_cq_native_four_arm_assert(
    all(plan_columns %in% names(manifest)) &&
      all(plan_columns %in% names(reference_manifest)) &&
      identical(as.character(manifest$RunId), expected_run_ids) &&
      identical(as.character(reference_manifest$RunId), expected_run_ids) &&
      identical(
        manifest[, plan_columns, drop = FALSE],
        reference_manifest[, plan_columns, drop = FALSE]
      ) &&
      identical(
        as.character(manifest$WideSHA256),
        as.character(reference_manifest$WideSHA256)
      ) &&
      length(unique(reference_manifest$SourceTreeSHA256)) == 1L,
    paste(
      "The native and source-bound manifests do not share the exact sealed",
      "run/model/node/dimension/input identity."
    )
  )
  plan <- manifest[, c("RunId", "Model", "Nodes", "ExpectedNpar")]
  summaries <- vector("list", nrow(plan))
  differences <- vector("list", nrow(plan))
  hashes <- vector("list", nrow(plan))
  final_vectors <- vector("list", nrow(plan))

  for (index in seq_len(nrow(plan))) {
    arm <- plan[index, , drop = FALSE]
    files <- mfrmr_cq_native_four_arm_files(output_dir, arm$RunId)
    required_names <- setdiff(names(files), "console")
    required <- unlist(files[required_names], use.names = FALSE)
    missing <- required[!file.exists(required)]
    mfrmr_cq_native_four_arm_assert(
      length(missing) == 0L,
      paste0("The native arm `", arm$RunId, "` is missing: ",
             paste(basename(missing), collapse = ", "), ".")
    )
    manifest_row <- manifest[manifest$RunId == arm$RunId, , drop = FALSE]
    reference_row <- reference_manifest[
      reference_manifest$RunId == arm$RunId, , drop = FALSE
    ]
    reference_summary_file <- file.path(
      output_dir, "mfrmr_reference", reference_row$SummaryFile
    )
    reference_parameter_file <- file.path(
      output_dir, "mfrmr_reference", reference_row$ParameterFile
    )
    mfrmr_cq_native_four_arm_assert(
      identical(mfrmr_cq_additive_hash_file(files$command),
                manifest_row$CommandSHA256) &&
        identical(mfrmr_cq_additive_hash_file(files$wide),
                  manifest_row$WideSHA256) &&
        identical(mfrmr_cq_additive_hash_file(reference_summary_file),
                  reference_row$SummarySHA256) &&
        identical(mfrmr_cq_additive_hash_file(reference_parameter_file),
                  reference_row$ParameterSHA256),
      paste0("The command/input/reference identity failed for `",
             arm$RunId, "`.")
    )
    expected_amatrix <- if (arm$Model == "RSM") {
      mfrmr_cq_native_rsm_q31_expected_amatrix()
    } else {
      mfrmr_cq_native_pcm_q31_expected_amatrix()
    }
    amatrix <- utils::read.csv(
      files$amatrix, check.names = FALSE, stringsAsFactors = FALSE
    )
    mfrmr_cq_native_four_arm_assert(
      identical(amatrix, expected_amatrix),
      paste0("The exact native A matrix failed for `", arm$RunId, "`.")
    )
    parameters <- utils::read.csv(
      files$parameters, check.names = FALSE, stringsAsFactors = FALSE
    )
    regression <- utils::read.csv(
      files$regression, check.names = FALSE, stringsAsFactors = FALSE
    )
    covariance <- utils::read.csv(
      files$covariance, check.names = FALSE, stringsAsFactors = FALSE
    )
    history <- utils::read.csv(
      files$history, check.names = FALSE, stringsAsFactors = FALSE
    )
    cases <- utils::read.csv(
      files$cases, check.names = FALSE, stringsAsFactors = FALSE
    )
    expected_iterations <- if (arm$Model == "RSM") 96L else 95L
    expected_parameter_rows <- if (arm$Model == "RSM") 4L else 6L
    mfrmr_cq_native_four_arm_assert(
      nrow(parameters) == expected_parameter_rows &&
        nrow(regression) == 2L && nrow(covariance) == 1L &&
        nrow(history) == expected_iterations &&
        identical(history$Iteration, seq_len(expected_iterations)) &&
        nrow(cases) == 96L && length(unique(trimws(cases$PID))) == 96L,
      paste0("The native export dimensions failed for `", arm$RunId, "`.")
    )
    internal_log <- readLines(files$internal_log, warn = FALSE)
    console_complete <- if (file.exists(files$console)) {
      any(grepl("End of Program", readLines(files$console, warn = FALSE),
                fixed = TRUE))
    } else {
      NA
    }
    mfrmr_cq_native_four_arm_assert(
      any(grepl(
        paste0("Iteration=  ", expected_iterations), internal_log,
        fixed = TRUE
      )) && any(grepl("quit", utils::tail(internal_log, 20L), fixed = TRUE)) &&
        isTRUE(console_complete),
      paste0("The completion evidence failed for `", arm$RunId, "`.")
    )
    resolution <- mfrmr_cq_resolution_audit_native_exports(
      history_file = files$history,
      parameter_file = files$parameters,
      regression_file = files$regression,
      covariance_file = files$covariance,
      case_file = files$cases,
      rounding_rules = "unknown"
    )
    mfrmr_cq_native_four_arm_assert(
      identical(resolution$status,
                "raw_tokens_retained_rounding_unestablished"),
      paste0("The raw-token state failed for `", arm$RunId, "`.")
    )
    difference <- mfrmr_cq_native_four_arm_reference(
      output_dir, arm$RunId, arm$Model, parameters, regression,
      covariance, history
    )
    differences[[index]] <- difference
    final_vectors[[index]] <- c(
      regression$Estimate, covariance$Covariance, parameters$Estimate,
      utils::tail(history$LogLikelihood, 1L)
    )
    summaries[[index]] <- data.frame(
      Specification = mfrmr_cq_native_four_arm_specification,
      ContractVersion = mfrmr_cq_native_four_arm_contract,
      RunId = arm$RunId,
      Model = arm$Model,
      Nodes = arm$Nodes,
      ExpectedNpar = arm$ExpectedNpar,
      Iterations = expected_iterations,
      NativeDeviance = utils::tail(history$LogLikelihood, 1L),
      ReferenceDeviance = utils::tail(difference$MfrmrReferenceValue, 1L),
      DevianceAbsDifference = utils::tail(difference$AbsDifference, 1L),
      MaximumCoordinateAbsDifference = max(difference$AbsDifference),
      NativeDesignMatrixExact = TRUE,
      RawTokenStatus = resolution$status,
      ConsoleEndOfProgramObserved = console_complete,
      HistoryHeaderSemantics =
        "LogLikelihood_column_contains_positive_deviance",
      AcceptanceThresholdSpecified = FALSE,
      CandidateBound = FALSE,
      ComparisonReady = FALSE,
      ScientificEquivalenceInferred = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
    file_names <- names(files)[vapply(files, file.exists, logical(1))]
    file_paths <- unlist(files[file_names], use.names = FALSE)
    hashes[[index]] <- data.frame(
      RunId = arm$RunId,
      FileRole = file_names,
      FileName = basename(file_paths),
      SHA256 = vapply(
        file_paths, mfrmr_cq_additive_hash_file, character(1L)
      ),
      stringsAsFactors = FALSE,
      row.names = NULL
    )
  }
  summary <- do.call(rbind, summaries)
  difference <- do.call(rbind, differences)
  file_hash <- do.call(rbind, hashes)
  q31_q61 <- do.call(rbind, lapply(c("RSM", "PCM"), function(model) {
    index <- which(plan$Model == model)
    difference <- max(abs(final_vectors[[index[1]]] - final_vectors[[index[2]]]))
    data.frame(
      Model = model,
      MaximumPrintedFinalCoordinateAbsDifference = difference,
      PrintedFinalCoordinatesIdentical = difference == 0,
      RoundingRuleEstablished = FALSE,
      ScientificEquivalenceInferred = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  mfrmr_cq_native_four_arm_assert(
    all(q31_q61$PrintedFinalCoordinatesIdentical),
    "The q31/q61 final native coordinates differ at the retained CSV digits."
  )
  repeat_dir <- file.path(output_dir, "rsm_q031_initial_no_console")
  repeat_roles <- c(
    "amatrix", "cases", "covariance", "history", "parameters", "regression"
  )
  repeat_core_byte_identical <- NA
  if (dir.exists(repeat_dir)) {
    current_files <- mfrmr_cq_native_four_arm_files(output_dir, "rsm_q031")
    old_files <- lapply(current_files, function(path) {
      file.path(repeat_dir, basename(path))
    })
    repeat_core_byte_identical <- all(vapply(repeat_roles, function(role) {
      file.exists(old_files[[role]]) &&
        identical(
          mfrmr_cq_additive_hash_file(old_files[[role]]),
          mfrmr_cq_additive_hash_file(current_files[[role]])
        )
    }, logical(1)))
    mfrmr_cq_native_four_arm_assert(
      repeat_core_byte_identical,
      "The RSM q31 transcript-completion repeat changed a core native export."
    )
  }
  out <- list(
    specification = mfrmr_cq_native_four_arm_specification,
    contract_version = mfrmr_cq_native_four_arm_contract,
    decision = "four_arm_native_outputs_ready_tolerance_and_candidate_missing",
    runtime_available = TRUE,
    four_arms_complete = TRUE,
    complete_console_transcripts = all(
      summary$ConsoleEndOfProgramObserved %in% TRUE
    ),
    cross_manifest_plan_identical = TRUE,
    cross_manifest_wide_sha256_identical = TRUE,
    unit_weights_contract = TRUE,
    native_design_matrices_exact = TRUE,
    q31_q61_printed_final_coordinates_identical = TRUE,
    rsm_q31_repeat_core_byte_identical = repeat_core_byte_identical,
    raw_token_status = "raw_tokens_retained_rounding_unestablished",
    acceptance_threshold_specified = FALSE,
    candidate_bound = FALSE,
    comparison_ready = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    source_tree_sha256 = unique(reference_manifest$SourceTreeSHA256),
    summary = summary,
    q31_q61 = q31_q61,
    descriptive_differences = difference,
    file_hashes = file_hash,
    q31_reviews = list(rsm = rsm_q31, pcm = pcm_q31)
  )
  class(out) <- c("mfrmr_conquest_native_four_arm_review", class(out))
  out
}
