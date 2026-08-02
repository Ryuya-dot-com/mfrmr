# mfrmr 0.2.3 repository-only ConQuest binary node-ladder pilot
#
# This runner prepares the documented synthetic binary overlap at a fixed node
# ladder and reviews native ConQuest output after the external program has been
# run. It deliberately does not launch ConQuest, authorize confirmation, freeze
# a tolerance, or turn a pilot observation into cross-engine comparability.
#
# From the repository root:
#
#   pkgload::load_all(".")
#   source("inst/validation/conquest-binary-ladder-pilot-0.2.3.R")
#   prepared <- mfrmr_prepare_conquest_binary_ladder(tempfile())
#   # Run each generated .cqc file in ConQuest and save console output as the
#   # *_run.log file named in prepared$commands.
#   reviewed <- mfrmr_review_conquest_binary_ladder(prepared$output_dir)

mfrmr_cq_binary_ladder_specification <- "0.2.3-draft.9"
mfrmr_cq_binary_ladder_contract <- "mfrmr_conquest_binary_ladder_v1"

mfrmr_cq_binary_ladder_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_binary_ladder_plan <- function() {
  data.frame(
    RunId = c(
      "q007", "q015", "q031a", "q061", "q091", "q121", "q031b"
    ),
    Nodes = c(7L, 15L, 31L, 61L, 91L, 121L, 31L),
    IntegrationTier = c(
      "coarse_screening",
      "intermediate_review",
      "standard_start",
      "dense_sensitivity",
      "dense_sensitivity",
      "dense_sensitivity",
      "same_platform_replication"
    ),
    EvidenceRole = c(
      rep("node_ladder_pilot", 6L), "same_platform_replication"
    ),
    CoreCandidate = c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE),
    ReplicateGroup = c(NA, NA, "q31", NA, NA, NA, "q31"),
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_binary_ladder_loaded_namespace <- function() {
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop(
      "Load the mfrmr working-tree source before running the ConQuest ladder.",
      call. = FALSE
    )
  }
  namespace <- asNamespace("mfrmr")
  required <- c(
    "resolve_conquest_overlap_input", "mfrm_ic_common_panel"
  )
  available <- vapply(
    required,
    exists,
    logical(1),
    envir = namespace,
    inherits = FALSE
  )
  if (!all(available)) {
    stop(
      "The loaded mfrmr namespace is not the 0.2.3 working-tree source; use pkgload::load_all('.').",
      call. = FALSE
    )
  }
  namespace
}

mfrmr_cq_binary_ladder_reference <- function(fit, bundle, run_id, nodes) {
  summary_row <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
  mfrmr_cq_binary_ladder_assert(
    nrow(summary_row) > 0L,
    "The mfrmr ladder fit has no summary row."
  )
  summary_row <- summary_row[1, , drop = FALSE]
  population <- as.data.frame(
    bundle$mfrmr_population, stringsAsFactors = FALSE
  )
  item <- as.data.frame(
    bundle$mfrmr_item_estimates, stringsAsFactors = FALSE
  )
  population_order <- match(
    c("(Intercept)", "X", "sigma2"), population$Parameter
  )
  mfrmr_cq_binary_ladder_assert(
    !anyNA(population_order) && nrow(item) == 6L,
    "The synthetic binary ladder does not have the expected population and six-item parameterization."
  )
  free_vector <- c(
    population$Estimate[population_order],
    item$CenteredEstimate[seq_len(5L)]
  )
  names(free_vector) <- c(
    "Intercept", "Slope", "Variance", paste0("Item", seq_len(5L))
  )
  data.frame(
    Specification = mfrmr_cq_binary_ladder_specification,
    ContractVersion = mfrmr_cq_binary_ladder_contract,
    RunId = as.character(run_id),
    Nodes = as.integer(nodes),
    MfrmrDeviance = as.numeric(summary_row$Deviance),
    MfrmrLogLik = as.numeric(summary_row$LogLik),
    MfrmrNpar = as.integer(summary_row$Npar),
    Persons = as.integer(summary_row$Persons),
    MfrmrMaxit = 2000L,
    MfrmrReltol = 1e-12,
    MfrmrTerminalGradientSupNorm = as.numeric(
      summary_row$TerminalGradientSupNorm
    ),
    MfrmrInferenceReady = isTRUE(summary_row$InferenceReady),
    as.list(free_vector),
    ConstrainedItem6 = as.numeric(item$CenteredEstimate[6]),
    ConfirmationAuthorized = FALSE,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_prepare_conquest_binary_ladder <- function(output_dir) {
  namespace <- mfrmr_cq_binary_ladder_loaded_namespace()
  output_dir <- normalizePath(
    as.character(output_dir)[1], winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_binary_ladder_assert(
    !is.na(output_dir) && nzchar(output_dir),
    "`output_dir` must be one non-empty path."
  )
  if (dir.exists(output_dir) &&
      length(list.files(output_dir, all.files = TRUE, no.. = TRUE)) > 0L) {
    stop(
      "The ConQuest ladder output directory must be absent or empty; use a new restricted directory for every pilot.",
      call. = FALSE
    )
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  mfrmr_cq_binary_ladder_assert(
    dir.exists(output_dir),
    "The ConQuest ladder output directory could not be created."
  )

  resolver <- get("resolve_conquest_overlap_input", envir = namespace)
  builder <- getExportedValue("mfrmr", "build_conquest_overlap_bundle")
  plan <- mfrmr_cq_binary_ladder_plan()
  manifest_rows <- vector("list", nrow(plan))

  for (index in seq_len(nrow(plan))) {
    run_id <- plan$RunId[index]
    nodes <- plan$Nodes[index]
    run_dir <- file.path(output_dir, run_id)
    dir.create(run_dir, recursive = TRUE, showWarnings = FALSE)
    prefix <- paste0("cq_", run_id)
    resolved <- resolver(
      fit = NULL,
      case = "synthetic_latent_regression",
      quad_points = nodes,
      maxit = 2000L,
      reltol = 1e-12
    )
    fit <- resolved$fit
    bundle <- suppressWarnings(builder(
      fit = fit,
      output_dir = run_dir,
      prefix = prefix,
      overwrite = FALSE,
      quad_points = nodes,
      maxit = 2000L,
      reltol = 1e-12
    ))
    reference <- mfrmr_cq_binary_ladder_reference(
      fit, bundle, run_id, nodes
    )
    reference_file <- file.path(
      run_dir, paste0(prefix, "_mfrmr_ladder_reference.csv")
    )
    utils::write.csv(reference, reference_file, row.names = FALSE, na = "")
    wide_file <- file.path(run_dir, paste0(prefix, "_wide.csv"))
    command_file <- file.path(run_dir, paste0(prefix, ".cqc"))
    manifest_rows[[index]] <- data.frame(
      Specification = mfrmr_cq_binary_ladder_specification,
      ContractVersion = mfrmr_cq_binary_ladder_contract,
      RunId = run_id,
      Nodes = nodes,
      IntegrationTier = plan$IntegrationTier[index],
      EvidenceRole = plan$EvidenceRole[index],
      CoreCandidate = plan$CoreCandidate[index],
      ReplicateGroup = plan$ReplicateGroup[index],
      Prefix = prefix,
      RunDirectory = run_id,
      CommandFile = file.path(run_id, basename(command_file)),
      ExpectedLogFile = file.path(
        run_id, paste0(prefix, "_run.log")
      ),
      WideFile = file.path(run_id, basename(wide_file)),
      ReferenceFile = file.path(run_id, basename(reference_file)),
      WideMD5 = unname(tools::md5sum(wide_file)),
      CommandMD5 = unname(tools::md5sum(command_file)),
      MfrmrDeviance = reference$MfrmrDeviance,
      MfrmrTerminalGradientSupNorm =
        reference$MfrmrTerminalGradientSupNorm,
      MfrmrInferenceReady = reference$MfrmrInferenceReady,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }
  manifest <- do.call(rbind, manifest_rows)
  manifest_file <- file.path(
    output_dir, "conquest_binary_ladder_manifest.csv"
  )
  utils::write.csv(manifest, manifest_file, row.names = FALSE, na = "")
  commands <- manifest[, c(
    "RunId", "Nodes", "RunDirectory", "CommandFile", "ExpectedLogFile"
  ), drop = FALSE]
  out <- list(
    specification = mfrmr_cq_binary_ladder_specification,
    contract_version = mfrmr_cq_binary_ladder_contract,
    status = "prepared_external_execution_required",
    confirmation_authorized = FALSE,
    output_dir = output_dir,
    manifest_file = manifest_file,
    plan = plan,
    manifest = manifest,
    commands = commands,
    notes = c(
      "This repository-only helper does not execute ConQuest.",
      "Every run directory contains identifiers and person-level synthetic responses; handle it as a controlled analysis bundle.",
      "Capture the complete ConQuest console stream in ExpectedLogFile before review."
    )
  )
  class(out) <- c("mfrmr_conquest_binary_ladder_preparation", class(out))
  out
}

mfrmr_cq_binary_ladder_file_set <- function(output_dir, manifest_row) {
  run_dir <- file.path(output_dir, manifest_row$RunDirectory)
  prefix <- as.character(manifest_row$Prefix)
  path <- function(suffix) file.path(run_dir, paste0(prefix, suffix))
  list(
    run_dir = run_dir,
    log = path("_run.log"),
    wide = path("_wide.csv"),
    reference = path("_mfrmr_ladder_reference.csv"),
    history = path("_conquest_history.csv"),
    parameter = path("_conquest_parameters.csv"),
    regression = path("_conquest_reg_coefficients.csv"),
    covariance = path("_conquest_covariance.csv"),
    cases = path("_conquest_cases_eap.csv")
  )
}

mfrmr_cq_binary_ladder_empty_result <- function(manifest_row,
                                                 status,
                                                 reason) {
  data.frame(
    Specification = mfrmr_cq_binary_ladder_specification,
    ContractVersion = mfrmr_cq_binary_ladder_contract,
    RunId = as.character(manifest_row$RunId),
    Nodes = as.integer(manifest_row$Nodes),
    IntegrationTier = as.character(manifest_row$IntegrationTier),
    EvidenceRole = as.character(manifest_row$EvidenceRole),
    CoreCandidate = isTRUE(manifest_row$CoreCandidate),
    ExecutionComplete = FALSE,
    DevianceTerminationObserved = FALSE,
    ParameterTerminationObserved = FALSE,
    HigherLikelihoodRetained = FALSE,
    AdapterStatus = status,
    AdapterReason = as.character(reason),
    FinalHistoryObjective = NA_real_,
    ConQuestDeviance = NA_real_,
    MfrmrDeviance = as.numeric(manifest_row$MfrmrDeviance),
    CrossEngineDevianceDifference = NA_real_,
    MaxTransformedParameterAbsDifference = NA_real_,
    HistoryExportMaxAbsDifference = NA_real_,
    HistoryRows = NA_integer_,
    Npar = NA_integer_,
    Persons = NA_integer_,
    ArithmeticEligible = FALSE,
    ComparisonReady = FALSE,
    NativeOutputFingerprint = NA_character_,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_binary_ladder_summarize <- function(results) {
  required <- c(
    "RunId", "Nodes", "CoreCandidate", "AdapterStatus",
    "ConQuestDeviance", "MfrmrDeviance",
    "CrossEngineDevianceDifference",
    "MaxTransformedParameterAbsDifference",
    "NativeOutputFingerprint", "ComparisonReady"
  )
  mfrmr_cq_binary_ladder_assert(
    is.data.frame(results) && all(required %in% names(results)),
    "`results` does not satisfy the ConQuest binary ladder summary contract."
  )
  finite_range <- function(value) {
    value <- suppressWarnings(as.numeric(value))
    value <- value[is.finite(value)]
    if (length(value) == 0L) NA_real_ else diff(range(value))
  }
  finite_max_abs <- function(value) {
    value <- suppressWarnings(as.numeric(value))
    value <- value[is.finite(value)]
    if (length(value) == 0L) NA_real_ else max(abs(value))
  }
  core <- results[results$CoreCandidate %in% TRUE, , drop = FALSE]
  replicate <- results[results$RunId %in% c("q031a", "q031b"), , drop = FALSE]
  q31_byte_identical <- nrow(replicate) == 2L &&
    all(!is.na(replicate$NativeOutputFingerprint)) &&
    length(unique(replicate$NativeOutputFingerprint)) == 1L
  q31_deviance_identical <- nrow(replicate) == 2L &&
    all(is.finite(replicate$ConQuestDeviance)) &&
    identical(
      replicate$ConQuestDeviance[1], replicate$ConQuestDeviance[2]
    )
  data.frame(
    Specification = mfrmr_cq_binary_ladder_specification,
    ContractVersion = mfrmr_cq_binary_ladder_contract,
    Status = "review",
    CoreDistinctNodes = length(unique(core$Nodes)),
    CoreArithmeticAccepted = nrow(core) > 0L &&
      all(core$AdapterStatus == "accepted_arithmetic"),
    CoreConQuestDevianceRange = finite_range(core$ConQuestDeviance),
    CoreMfrmrDevianceRange = finite_range(core$MfrmrDeviance),
    CoreMaxAbsCrossEngineDevianceDifference = finite_max_abs(
      core$CrossEngineDevianceDifference
    ),
    CoreMaxTransformedParameterAbsDifference = finite_max_abs(
      core$MaxTransformedParameterAbsDifference
    ),
    Q31ReplicationByteIdentical = q31_byte_identical,
    Q31ReplicationDevianceIdentical = q31_deviance_identical,
    Q7Rejected = any(
      results$RunId == "q007" & results$AdapterStatus == "rejected"
    ),
    Q15Rejected = any(
      results$RunId == "q015" & results$AdapterStatus == "rejected"
    ),
    AnyComparisonReady = any(results$ComparisonReady %in% TRUE),
    IntegrationStabilityStatus = "review",
    FreezeCriterionStatus = "pilot_required",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_review_conquest_binary_ladder <- function(
    output_dir,
    pkg_dir = ".",
    engine_version = "5.47.5 Demonstration Version",
    run_date = Sys.Date(),
    candidate_id = "working-tree-pilot") {
  mfrmr_cq_binary_ladder_loaded_namespace()
  output_dir <- normalizePath(
    as.character(output_dir)[1], winslash = "/", mustWork = TRUE
  )
  manifest_file <- file.path(
    output_dir, "conquest_binary_ladder_manifest.csv"
  )
  mfrmr_cq_binary_ladder_assert(
    file.exists(manifest_file),
    "The ConQuest binary ladder manifest is missing."
  )
  manifest <- utils::read.csv(
    manifest_file, stringsAsFactors = FALSE, check.names = FALSE
  )
  plan <- mfrmr_cq_binary_ladder_plan()
  mfrmr_cq_binary_ladder_assert(
    identical(as.character(manifest$RunId), plan$RunId) &&
      identical(as.integer(manifest$Nodes), plan$Nodes),
    "The ConQuest binary ladder manifest does not match the draft.9 plan."
  )
  normalizer_file <- file.path(
    normalizePath(pkg_dir, winslash = "/", mustWork = TRUE),
    "inst", "validation", "external-ic-normalizer-0.2.3.R"
  )
  mfrmr_cq_binary_ladder_assert(
    file.exists(normalizer_file),
    "The repository-only external IC normalizer is missing."
  )
  normalizer <- new.env(parent = globalenv())
  sys.source(normalizer_file, envir = normalizer)
  results <- vector("list", nrow(manifest))

  for (index in seq_len(nrow(manifest))) {
    row <- manifest[index, , drop = FALSE]
    files <- mfrmr_cq_binary_ladder_file_set(output_dir, row)
    required_paths <- unlist(
      files[c(
        "log", "wide", "reference", "history", "parameter",
        "regression", "covariance", "cases"
      )],
      use.names = FALSE
    )
    missing <- required_paths[!file.exists(required_paths)]
    if (length(missing) > 0L) {
      results[[index]] <- mfrmr_cq_binary_ladder_empty_result(
        row,
        status = "not_run",
        reason = paste(
          "Missing required external files:",
          paste(basename(missing), collapse = ", ")
        )
      )
      next
    }

    log_lines <- readLines(files$log, warn = FALSE)
    execution_complete <- any(grepl("End of Program", log_lines, fixed = TRUE))
    higher_likelihood <- any(grepl(
      "higher likelihood", log_lines, fixed = TRUE
    ))
    deviance_termination <- any(grepl(
      "Deviance change is less than convergence criterion",
      log_lines,
      fixed = TRUE
    ))
    parameter_termination <- any(grepl(
      "maximum change in the estimates is less than the convergence criterion",
      log_lines,
      ignore.case = TRUE
    ))
    convergence_pass <- execution_complete && !higher_likelihood &&
      (deviance_termination || parameter_termination)
    convergence_evidence_id <- if (higher_likelihood) {
      "conquest_console_higher_likelihood_retained_review"
    } else if (deviance_termination) {
      "conquest_console_deviance_change_termination"
    } else if (parameter_termination) {
      "conquest_console_parameter_change_termination"
    } else {
      NA_character_
    }

    wide <- utils::read.csv(
      files$wide, stringsAsFactors = FALSE, check.names = FALSE
    )
    reference <- utils::read.csv(
      files$reference, stringsAsFactors = FALSE, check.names = FALSE
    )
    history <- utils::read.csv(
      files$history, stringsAsFactors = FALSE, check.names = FALSE
    )
    regression <- utils::read.csv(
      files$regression, stringsAsFactors = FALSE, check.names = FALSE
    )
    covariance <- utils::read.csv(
      files$covariance, stringsAsFactors = FALSE, check.names = FALSE
    )
    parameter <- utils::read.csv(
      files$parameter, stringsAsFactors = FALSE, check.names = FALSE
    )
    exported_vector <- c(
      regression$Estimate, covariance$Covariance, parameter$Estimate
    )
    history_vector <- suppressWarnings(as.numeric(unlist(
      history[nrow(history), seq.int(5L, ncol(history)), drop = FALSE],
      recursive = FALSE,
      use.names = FALSE
    )))
    history_export_difference <- if (
      length(exported_vector) == length(history_vector) &&
      all(is.finite(exported_vector)) && all(is.finite(history_vector))
    ) {
      max(abs(exported_vector - history_vector))
    } else {
      NA_real_
    }
    reference_vector <- suppressWarnings(as.numeric(unlist(
      reference[1, c(
        "Intercept", "Slope", "Variance", paste0("Item", seq_len(5L))
      ), drop = FALSE],
      recursive = FALSE,
      use.names = FALSE
    )))
    native_paths <- unlist(
      files[c("history", "parameter", "regression", "covariance", "cases")],
      use.names = FALSE
    )
    native_fingerprint <- paste(
      unname(tools::md5sum(native_paths)), collapse = ":"
    )
    record <- tryCatch(
      normalizer$mfrmr_external_ic_from_conquest(
        history_file = files$history,
        parameter_file = files$parameter,
        regression_file = files$regression,
        covariance_file = files$covariance,
        case_file = files$cases,
        engine_version = engine_version,
        run_date = run_date,
        run_id = paste0("cq-binary-", row$RunId),
        model_id = "EXT-CQ-BINARY-PILOT",
        quadrature_nodes = row$Nodes,
        expected_person_ids = as.character(wide$Person),
        observation_set_id = paste0(
          "cq-synthetic-wide-md5:", row$WideMD5
        ),
        likelihood_basis_id = "conquest-binary-mml-observed-v1",
        constraint_basis_id = "conquest-default-item-sum-zero-v1",
        integration_comparison_id = "cq-binary-node-ladder-draft9",
        convergence_status = if (convergence_pass) "pass" else "review",
        convergence_evidence_id = convergence_evidence_id,
        integration_stability_status = "review",
        candidate_id = candidate_id
      ),
      error = function(error) error
    )
    final_history_objective <- suppressWarnings(as.numeric(
      history[nrow(history), 4]
    ))
    if (inherits(record, "error")) {
      result <- mfrmr_cq_binary_ladder_empty_result(
        row, "rejected", conditionMessage(record)
      )
      result$ExecutionComplete <- execution_complete
      result$DevianceTerminationObserved <- deviance_termination
      result$ParameterTerminationObserved <- parameter_termination
      result$HigherLikelihoodRetained <- higher_likelihood
      result$FinalHistoryObjective <- final_history_objective
      result$HistoryExportMaxAbsDifference <- history_export_difference
      result$HistoryRows <- nrow(history)
      result$NativeOutputFingerprint <- native_fingerprint
      results[[index]] <- result
      next
    }
    results[[index]] <- data.frame(
      Specification = mfrmr_cq_binary_ladder_specification,
      ContractVersion = mfrmr_cq_binary_ladder_contract,
      RunId = as.character(row$RunId),
      Nodes = as.integer(row$Nodes),
      IntegrationTier = as.character(row$IntegrationTier),
      EvidenceRole = as.character(row$EvidenceRole),
      CoreCandidate = isTRUE(row$CoreCandidate),
      ExecutionComplete = execution_complete,
      DevianceTerminationObserved = deviance_termination,
      ParameterTerminationObserved = parameter_termination,
      HigherLikelihoodRetained = higher_likelihood,
      AdapterStatus = "accepted_arithmetic",
      AdapterReason = as.character(record$record$Reason),
      FinalHistoryObjective = final_history_objective,
      ConQuestDeviance = as.numeric(record$record$Deviance),
      MfrmrDeviance = as.numeric(reference$MfrmrDeviance),
      CrossEngineDevianceDifference = as.numeric(record$record$Deviance) -
        as.numeric(reference$MfrmrDeviance),
      MaxTransformedParameterAbsDifference = max(abs(
        exported_vector - reference_vector
      )),
      HistoryExportMaxAbsDifference = history_export_difference,
      HistoryRows = as.integer(record$audit$HistoryRows),
      Npar = as.integer(record$record$Npar),
      Persons = as.integer(record$record$Persons),
      ArithmeticEligible = isTRUE(record$record$ArithmeticEligible),
      ComparisonReady = isTRUE(record$record$ComparisonReady),
      NativeOutputFingerprint = native_fingerprint,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }

  results <- do.call(rbind, results)
  summary <- mfrmr_cq_binary_ladder_summarize(results)
  out <- list(
    specification = mfrmr_cq_binary_ladder_specification,
    contract_version = mfrmr_cq_binary_ladder_contract,
    status = "review",
    confirmation_authorized = FALSE,
    selection_authorized = FALSE,
    manifest = manifest,
    results = results,
    summary = summary
  )
  class(out) <- c("mfrmr_conquest_binary_ladder_review", class(out))
  out
}
