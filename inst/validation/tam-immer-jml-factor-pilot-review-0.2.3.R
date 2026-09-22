# Draft.77 descriptive review of the completed factor-structured JML pilot.

mfrmr_tif_review_require <- function() {
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("The factor-pilot review requires `dplyr`.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_tif_review_validate <- function(result) {
  required <- c(
    "Manifest", "Datasets", "DesignAudit", "Modes", "Metrics",
    "CheckpointLedger", "ContractPassed", "EvidenceReady"
  )
  if (!is.list(result) || !all(required %in% names(result))) {
    stop("Not a complete factor-stress result object.", call. = FALSE)
  }
  if (!identical(nrow(result$Manifest), 290L) ||
      !identical(as.character(result$Tier), "pilot")) {
    stop("The review requires the declared 290-dataset pilot.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_tif_bias_correction_comparison <- function(
    result, raw_mode, corrected_mode, require_original_raw = TRUE) {
  modes <- result$Modes
  ids <- modes$DatasetId[
    modes$ModeId == raw_mode & modes$FitReturned &
      (!require_original_raw | modes$OriginalRawEligible)
  ]
  values <- result$Metrics |>
    dplyr::filter(
      .data$DatasetId %in% ids,
      .data$Facet == "CumulativeDifficultySurface",
      .data$Metric %in% c("Bias", "RMSE"),
      .data$Eligible,
      is.finite(.data$Value),
      .data$ModeId %in% c(raw_mode, corrected_mode)
    ) |>
    dplyr::select(
      "DatasetId", "Metric", "ModeId", "Value"
    )
  raw <- values |>
    dplyr::filter(.data$ModeId == raw_mode) |>
    dplyr::transmute(
      .data$DatasetId, .data$Metric, RawValue = .data$Value
    )
  corrected <- values |>
    dplyr::filter(.data$ModeId == corrected_mode) |>
    dplyr::transmute(
      .data$DatasetId, .data$Metric, CorrectedValue = .data$Value
    )
  dplyr::inner_join(raw, corrected, by = c("DatasetId", "Metric")) |>
    dplyr::mutate(
      Improved = dplyr::if_else(
        .data$Metric == "Bias",
        abs(.data$CorrectedValue) < abs(.data$RawValue),
        .data$CorrectedValue < .data$RawValue
      )
    ) |>
    dplyr::group_by(.data$Metric) |>
    dplyr::summarise(
      Pair = paste(raw_mode, corrected_mode, sep = " -> "),
      OriginalRawRequired = require_original_raw,
      CommonDatasets = dplyr::n(),
      RawMean = mean(.data$RawValue),
      CorrectedMean = mean(.data$CorrectedValue),
      ImprovedFraction = mean(.data$Improved),
      .groups = "drop"
    ) |>
    dplyr::select(
      "Pair", "Metric", "OriginalRawRequired", "CommonDatasets",
      "RawMean", "CorrectedMean", "ImprovedFraction"
    )
}

mfrmr_tif_pilot_review <- function(result) {
  mfrmr_tif_review_require()
  mfrmr_tif_review_validate(result)

  dataset_accounting <- as.data.frame(
    table(
      ExpectedDatasetState = result$Datasets$ExpectedDatasetState,
      ObservedDatasetState = result$Datasets$ObservedDatasetState
    ),
    stringsAsFactors = FALSE
  ) |>
    dplyr::filter(.data$Freq > 0)

  mode_accounting <- result$Modes |>
    dplyr::group_by(.data$ModeId) |>
    dplyr::summarise(
      Attempted = dplyr::n(),
      FitReturned = sum(.data$FitReturned),
      FiniteSurface = sum(.data$FiniteSurface),
      OriginalRawEligible = sum(.data$OriginalRawEligible),
      ExtremeDatasets = sum(.data$ActualExtremeN > 0),
      MedianElapsedSeconds = stats::median(.data$ElapsedSeconds, na.rm = TRUE),
      TotalElapsedSeconds = sum(.data$ElapsedSeconds, na.rm = TRUE),
      .groups = "drop"
    )
  fit_metrics <- result$Metrics |>
    dplyr::filter(
      .data$Metric %in% c(
        "NumericalConvergenceRate", "IterationCeilingAvoidedRate",
        "EvidenceEligibleRate"
      )
    ) |>
    dplyr::group_by(.data$ModeId, .data$Metric) |>
    dplyr::summarise(
      EligibleRows = sum(.data$Eligible),
      PositiveRows = sum(.data$Value == 1, na.rm = TRUE),
      .groups = "drop"
    )
  mode_accounting <- dplyr::left_join(
    mode_accounting,
    fit_metrics |>
      dplyr::filter(.data$Metric == "NumericalConvergenceRate") |>
      dplyr::select(
        "ModeId", NumericalConvergence = "PositiveRows"
      ),
    by = "ModeId"
  ) |>
    dplyr::left_join(
      fit_metrics |>
        dplyr::filter(.data$Metric == "EvidenceEligibleRate") |>
        dplyr::select(
          "ModeId", EvidenceEligible = "PositiveRows"
        ),
      by = "ModeId"
    )

  metric_eligibility <- result$Metrics |>
    dplyr::group_by(.data$Metric) |>
    dplyr::summarise(
      PlannedRows = dplyr::n(),
      EligibleRows = sum(.data$Eligible),
      FiniteEligibleRows = sum(.data$Eligible & is.finite(.data$Value)),
      .groups = "drop"
    )

  profile_metric_summary <- result$Metrics |>
    dplyr::filter(.data$Eligible, is.finite(.data$Value)) |>
    dplyr::group_by(
      .data$Model, .data$ProfileId, .data$FactorBlock,
      .data$ModeId, .data$Facet, .data$Metric
    ) |>
    dplyr::summarise(
      Replicates = dplyr::n(),
      Mean = mean(.data$Value),
      SD = if (dplyr::n() > 1L) stats::sd(.data$Value) else NA_real_,
      Median = stats::median(.data$Value),
      Minimum = min(.data$Value),
      Maximum = max(.data$Value),
      .groups = "drop"
    )

  rmse_means <- profile_metric_summary |>
    dplyr::filter(.data$Metric == "RMSE") |>
    dplyr::select(
      "Model", "ProfileId", "FactorBlock", "ModeId", "Facet",
      ProfileMeanRMSE = "Mean", "Replicates"
    )
  reference <- rmse_means |>
    dplyr::filter(.data$ProfileId == "REFERENCE") |>
    dplyr::select(
      "Model", "ModeId", "Facet",
      ReferenceMeanRMSE = "ProfileMeanRMSE"
    )
  rmse_reference_ratios <- dplyr::inner_join(
    rmse_means, reference, by = c("Model", "ModeId", "Facet")
  ) |>
    dplyr::mutate(
      RMSEReferenceRatio = .data$ProfileMeanRMSE /
        .data$ReferenceMeanRMSE
    )
  rmse_profile_summary <- rmse_reference_ratios |>
    dplyr::group_by(.data$ProfileId, .data$FactorBlock, .data$Facet) |>
    dplyr::summarise(
      MethodModelCells = dplyr::n(),
      MedianMethodSpecificRatio = stats::median(.data$RMSEReferenceRatio),
      MinimumMethodSpecificRatio = min(.data$RMSEReferenceRatio),
      MaximumMethodSpecificRatio = max(.data$RMSEReferenceRatio),
      .groups = "drop"
    )

  rank_separation_profile_summary <- profile_metric_summary |>
    dplyr::filter(
      .data$Metric %in% c(
        "SpearmanRankRecovery", "PairwiseOrderRecovery",
        "RecoverySeparation"
      )
    ) |>
    dplyr::group_by(
      .data$ProfileId, .data$FactorBlock, .data$Facet, .data$Metric
    ) |>
    dplyr::summarise(
      MethodModelCells = dplyr::n(),
      MedianMethodSpecificMean = stats::median(.data$Mean),
      MinimumMethodSpecificMean = min(.data$Mean),
      MaximumMethodSpecificMean = max(.data$Mean),
      .groups = "drop"
    )

  correction_comparison <- dplyr::bind_rows(
    mfrmr_tif_bias_correction_comparison(
      result, "TAM_RAW", "TAM_BC", require_original_raw = TRUE
    ),
    mfrmr_tif_bias_correction_comparison(
      result, "IMMER_JML", "IMMER_BC", require_original_raw = TRUE
    ),
    mfrmr_tif_bias_correction_comparison(
      result, "TAM_ADJ", "TAM_BC_ADJ", require_original_raw = FALSE
    )
  )

  list(
    ContractVersion = "mfrmr-tam-immer-jml-factor-pilot-review-v1",
    ResultSHA256 = if (exists("mfrmr_tif_result_hash", mode = "function")) {
      mfrmr_tif_result_hash(result)
    } else {
      NA_character_
    },
    DatasetAccounting = dataset_accounting,
    ModeAccounting = mode_accounting,
    MetricEligibility = metric_eligibility,
    ProfileMetricSummary = profile_metric_summary,
    RMSEReferenceRatios = rmse_reference_ratios,
    RMSEProfileSummary = rmse_profile_summary,
    RankSeparationProfileSummary = rank_separation_profile_summary,
    BiasCorrectionComparison = correction_comparison,
    EvidenceReady = FALSE,
    Prohibitions = c(
      "Five replicates do not calibrate coverage or rare failure rates.",
      "Median method-specific ratios are not a pooled estimand or ranking.",
      "Local-dependence and MNAR profiles are misspecification robustness.",
      "RecoverySeparation is not reported Rasch/FACETS facet separation.",
      "A bias-corrected point estimate is not the original JML maximizer."
    )
  )
}
