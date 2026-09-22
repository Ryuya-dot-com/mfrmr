# Draft.83d2b2b1g3 no-refit, multi-axis glmmTMB numerical adjudication.
#
# Repository-internal only. It does not select a numerical threshold, refit a
# model, authorize the full manifest, or form inferential statistics.

mfrmr_gtwsx_require_primitives <- function() {
  required <- c("mfrmr_gta_hash", "mfrmr_gtwy_function_hash")
  audit_environment <- environment(mfrmr_gtwsx_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.83d2b2b1g2 validation chain before b1g3: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwsx_validate_alignment <- function(alignment_contract,
                                             alignment_execution,
                                             comparison) {
  inherits(alignment_contract, "mfrmr_gtwsw_contract") &&
    inherits(alignment_execution, "mfrmr_gtwsw_execution") &&
    inherits(comparison, "mfrmr_gtwsw_comparison") &&
    identical(
      alignment_contract$RunnerContractHash,
      "7632a74709576c78d4e89b9fd015952dbde5be98313b99ed380af7c5436e1177"
    ) &&
    identical(
      alignment_execution$ExecutionHash,
      "e2716a4ae71784e218d15f2509ed8c15326c1b7c6bc9acf78826a81822581482"
    ) &&
    identical(
      comparison$ComparisonHash,
      "651b6f07cb7977b7d1245b1048e0b7b905c4999f8da43bfbcd30180d9581d435"
    ) &&
    mfrmr_gtwsx_alignment_execution_hash_valid(alignment_execution) &&
    mfrmr_gtwsx_comparison_hash_valid(comparison) &&
    identical(alignment_execution$RunnerContractHash,
              alignment_contract$RunnerContractHash) &&
    identical(comparison$AlignmentExecutionHash,
              alignment_execution$ExecutionHash) &&
    isTRUE(alignment_execution$ExactAccountingPassed) &&
    isTRUE(alignment_execution$AlignmentMechanicsReady) &&
    isTRUE(comparison$FullDenominatorComparisonReady) &&
    identical(alignment_execution$PlannedPairs, 120L) &&
    identical(alignment_execution$PairReturnCount, 120L) &&
    is.data.frame(alignment_execution$AtomicRows) &&
    nrow(alignment_execution$AtomicRows) == 120L &&
    !anyDuplicated(alignment_execution$AtomicRows$StabilizationRouteId) &&
    !isTRUE(alignment_execution$FullExecutionAuthorized) &&
    !isTRUE(alignment_execution$NumericalStabilizationReady) &&
    !isTRUE(alignment_execution$NumericalSensitivityEvidenceReady) &&
    !isTRUE(alignment_execution$CalibrationEvidenceReady) &&
    !isTRUE(alignment_execution$ThresholdFrozen) &&
    !isTRUE(alignment_execution$InferenceReady) &&
    !isTRUE(alignment_execution$DecisionReady)
}

mfrmr_gtwsx_alignment_execution_hash_valid <- function(execution) {
  fields <- c(
    "Contract", "RunnerContractHash", "UpstreamRunnerContractHash",
    "UpstreamExecutionHash", "UnderlyingExecutionHash",
    "StabilizationContractHash", "StabilizationManifestHash", "AtomicRows",
    "BaseRouteCheckpointHashes", "DatasetMarkerHashes", "Summaries",
    "AlignmentSummary"
  )
  all(fields %in% names(execution)) && identical(
    execution$ExecutionHash, mfrmr_gta_hash(execution[fields])
  )
}

mfrmr_gtwsx_comparison_hash_valid <- function(comparison) {
  fields <- c(
    "Contract", "UpstreamExecutionHash", "AlignmentExecutionHash",
    "PairedRows", "Summary"
  )
  all(fields %in% names(comparison)) && identical(
    comparison$ComparisonHash, mfrmr_gta_hash(comparison[fields])
  )
}

mfrmr_gtwsx_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwsx_validate_alignment",
    "mfrmr_gtwsx_alignment_execution_hash_valid",
    "mfrmr_gtwsx_comparison_hash_valid", "mfrmr_gtwsx_optimizer_state",
    "mfrmr_gtwsx_objective_state", "mfrmr_gtwsx_reported_state",
    "mfrmr_gtwsx_curvature_state", "mfrmr_gtwsx_gradient_state",
    "mfrmr_gtwsx_order_state", "mfrmr_gtwsx_atomic_rows",
    "mfrmr_gtwsx_choose_envelope", "mfrmr_gtwsx_envelopes",
    "mfrmr_gtwsx_summaries", "mfrmr_gtwsx_contract",
    "mfrmr_gtwsx_adjudicate"
  )
  audit_environment <- environment(mfrmr_gtwsx_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwy_function_hash(get(
      name, envir = audit_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwsx_optimizer_state <- function(full, reduced) {
  if (is.na(full) || is.na(reduced)) return("not_evaluable")
  if (full == 0L && reduced == 0L) return("both_reported_success")
  if (full != 0L && reduced != 0L) return("both_nonzero")
  if (full != 0L) "full_nonzero" else "reduced_nonzero"
}

mfrmr_gtwsx_objective_state <- function(full, reduced) {
  full <- is.finite(full)
  reduced <- is.finite(reduced)
  if (full && reduced) return("both_finite")
  if (!full && !reduced) return("both_nonfinite")
  if (!full) "full_nonfinite" else "reduced_nonfinite"
}

mfrmr_gtwsx_reported_state <- function(full_loglik, reduced_loglik,
                                         full_objective,
                                         reduced_objective,
                                         full_pd, reduced_pd) {
  full_finite <- is.finite(full_loglik)
  reduced_finite <- is.finite(reduced_loglik)
  if (full_finite && reduced_finite) return("both_reported")
  full_mask <- !full_finite && is.finite(full_objective) && !isTRUE(full_pd)
  reduced_mask <- !reduced_finite && is.finite(reduced_objective) &&
    !isTRUE(reduced_pd)
  if ((!full_finite && !full_mask) ||
      (!reduced_finite && !reduced_mask)) return("unexplained_nonfinite")
  if (full_mask && reduced_mask) return("both_curvature_masked")
  if (full_mask) "full_curvature_masked" else "reduced_curvature_masked"
}

mfrmr_gtwsx_curvature_state <- function(full_sdr_pd, reduced_sdr_pd,
                                          full_rich_available,
                                          reduced_rich_available,
                                          full_rich_pd,
                                          reduced_rich_pd) {
  if (!isTRUE(full_rich_available) || !isTRUE(reduced_rich_available)) {
    return("richardson_unavailable")
  }
  if (!identical(isTRUE(full_sdr_pd), isTRUE(full_rich_pd)) ||
      !identical(isTRUE(reduced_sdr_pd), isTRUE(reduced_rich_pd))) {
    return("diagnostic_disagreement")
  }
  full <- isTRUE(full_sdr_pd) && isTRUE(full_rich_pd)
  reduced <- isTRUE(reduced_sdr_pd) && isTRUE(reduced_rich_pd)
  if (full && reduced) return("both_pd_agree")
  if (!full && !reduced) return("neither_pd_agree")
  if (!full) "reduced_only_pd_agree" else "full_only_pd_agree"
}

mfrmr_gtwsx_gradient_state <- function(full_outer, full_sd,
                                         reduced_outer, reduced_sd) {
  full <- isTRUE(full_outer) && isTRUE(full_sd)
  reduced <- isTRUE(reduced_outer) && isTRUE(reduced_sd)
  if (full && reduced) return("both_surfaces_available")
  if (!full && !reduced) return("neither_model_complete")
  if (!full) "full_model_incomplete" else "reduced_model_incomplete"
}

mfrmr_gtwsx_order_state <- function(value, tolerance) {
  if (!is.finite(value)) return("not_evaluable")
  if (value < -tolerance) return("material_negative")
  if (value < 0) return("small_negative")
  if (value == 0) return("exact_zero")
  "positive"
}

mfrmr_gtwsx_atomic_rows <- function(rows, contract) {
  required <- c(
    "StabilizationRouteId", "RouteId", "DatasetId", "DesignId",
    "VarianceId", "MethodId", "Likelihood", "ProfileId",
    "PairReturned", "FullReturned", "ReducedReturned", "SameRows",
    "LikelihoodDfDifference", "FullOptimizerCode", "ReducedOptimizerCode",
    "FullObjective", "ReducedObjective", "FullLogLikelihood",
    "ReducedLogLikelihood", "RawLikelihoodDrop",
    "FullSdreportPositiveDefiniteHessian",
    "ReducedSdreportPositiveDefiniteHessian",
    "FullRichardsonAvailable", "ReducedRichardsonAvailable",
    "FullRichardsonPositiveDefinite", "ReducedRichardsonPositiveDefinite",
    "FullOuterGradientAvailable", "ReducedOuterGradientAvailable",
    "FullSdGradientAvailable", "ReducedSdGradientAvailable",
    "FullOuterGradientHash", "ReducedOuterGradientHash",
    "FullSdGradientHash", "ReducedSdGradientHash",
    "FullOuterGradientMaximumAbsolute",
    "ReducedOuterGradientMaximumAbsolute",
    "FullSdGradientMaximumAbsolute", "ReducedSdGradientMaximumAbsolute"
  )
  if (!is.data.frame(rows) || nrow(rows) != 120L ||
      anyDuplicated(rows$StabilizationRouteId) ||
      !all(required %in% names(rows))) {
    stop("The exact 120-row b1g2 scalar/hash ledger is required.",
         call. = FALSE)
  }
  atomic <- lapply(seq_len(nrow(rows)), function(index) {
    row <- rows[index, , drop = FALSE]
    objective_drop <- 2 * (-row$FullObjective + row$ReducedObjective)
    reported_drop_evaluable <- is.finite(row$RawLikelihoodDrop)
    payload <- list(
      StabilizationRouteId = row$StabilizationRouteId[[1L]],
      RouteId = row$RouteId[[1L]], DatasetId = row$DatasetId[[1L]],
      DesignId = row$DesignId[[1L]], VarianceId = row$VarianceId[[1L]],
      MethodId = row$MethodId[[1L]], Likelihood = row$Likelihood[[1L]],
      ProfileId = row$ProfileId[[1L]],
      PairReturned = isTRUE(row$PairReturned[[1L]]),
      SameRows = isTRUE(row$SameRows[[1L]]),
      LikelihoodDfDifferenceOne =
        identical(row$LikelihoodDfDifference[[1L]], 1L),
      OptimizerState = mfrmr_gtwsx_optimizer_state(
        row$FullOptimizerCode[[1L]], row$ReducedOptimizerCode[[1L]]
      ),
      ObjectiveState = mfrmr_gtwsx_objective_state(
        row$FullObjective[[1L]], row$ReducedObjective[[1L]]
      ),
      ReportedLikelihoodState = mfrmr_gtwsx_reported_state(
        row$FullLogLikelihood[[1L]], row$ReducedLogLikelihood[[1L]],
        row$FullObjective[[1L]], row$ReducedObjective[[1L]],
        row$FullSdreportPositiveDefiniteHessian[[1L]],
        row$ReducedSdreportPositiveDefiniteHessian[[1L]]
      ),
      FullReportedObjectiveIdentityEvaluable =
        is.finite(row$FullLogLikelihood[[1L]]),
      FullReportedObjectiveIdentityExact =
        is.finite(row$FullLogLikelihood[[1L]]) && identical(
          row$FullLogLikelihood[[1L]], -row$FullObjective[[1L]]
        ),
      ReducedReportedObjectiveIdentityEvaluable =
        is.finite(row$ReducedLogLikelihood[[1L]]),
      ReducedReportedObjectiveIdentityExact =
        is.finite(row$ReducedLogLikelihood[[1L]]) && identical(
          row$ReducedLogLikelihood[[1L]], -row$ReducedObjective[[1L]]
        ),
      CurvatureState = mfrmr_gtwsx_curvature_state(
        row$FullSdreportPositiveDefiniteHessian[[1L]],
        row$ReducedSdreportPositiveDefiniteHessian[[1L]],
        row$FullRichardsonAvailable[[1L]],
        row$ReducedRichardsonAvailable[[1L]],
        row$FullRichardsonPositiveDefinite[[1L]],
        row$ReducedRichardsonPositiveDefinite[[1L]]
      ),
      FullCurvatureEligible =
        isTRUE(row$FullSdreportPositiveDefiniteHessian[[1L]]) &&
          isTRUE(row$FullRichardsonAvailable[[1L]]) &&
          isTRUE(row$FullRichardsonPositiveDefinite[[1L]]),
      ReducedCurvatureEligible =
        isTRUE(row$ReducedSdreportPositiveDefiniteHessian[[1L]]) &&
          isTRUE(row$ReducedRichardsonAvailable[[1L]]) &&
          isTRUE(row$ReducedRichardsonPositiveDefinite[[1L]]),
      GradientAvailabilityState = mfrmr_gtwsx_gradient_state(
        row$FullOuterGradientAvailable[[1L]],
        row$FullSdGradientAvailable[[1L]],
        row$ReducedOuterGradientAvailable[[1L]],
        row$ReducedSdGradientAvailable[[1L]]
      ),
      FullGradientSurfaceHashExact = identical(
        row$FullOuterGradientHash[[1L]], row$FullSdGradientHash[[1L]]
      ),
      ReducedGradientSurfaceHashExact = identical(
        row$ReducedOuterGradientHash[[1L]],
        row$ReducedSdGradientHash[[1L]]
      ),
      FullOuterGradientMaximumAbsolute =
        row$FullOuterGradientMaximumAbsolute[[1L]],
      ReducedOuterGradientMaximumAbsolute =
        row$ReducedOuterGradientMaximumAbsolute[[1L]],
      FullSdGradientMaximumAbsolute =
        row$FullSdGradientMaximumAbsolute[[1L]],
      ReducedSdGradientMaximumAbsolute =
        row$ReducedSdGradientMaximumAbsolute[[1L]],
      StationarityState = "not_calibrated",
      ObjectiveLikelihoodDrop = objective_drop,
      ObjectiveOrderState = mfrmr_gtwsx_order_state(
        objective_drop, contract$DescriptiveNegativeTolerance
      ),
      ReportedDropIdentityEvaluable = reported_drop_evaluable,
      ReportedDropIdentityExact = reported_drop_evaluable && identical(
        row$RawLikelihoodDrop[[1L]], objective_drop
      ),
      ReportedLikelihoodDrop = row$RawLikelihoodDrop[[1L]],
      PairDecisionEligible = FALSE, NoRefit = TRUE,
      CalibrationUse = FALSE, ThresholdSelectionUse = FALSE
    )
    identity <- list(
      Contract = "glmmtmb_numerical_adjudication_pair_draft83d2b2b1g3_v1",
      AdjudicationContractHash = contract$AdjudicationContractHash,
      Payload = payload
    )
    data.frame(
      payload, PairAdjudicationHash = mfrmr_gta_hash(identity),
      stringsAsFactors = FALSE, check.names = FALSE
    )
  })
  out <- do.call(rbind, atomic)
  row.names(out) <- NULL
  out
}

mfrmr_gtwsx_choose_envelope <- function(values, eligible, profile_id,
                                          profile_order) {
  candidates <- which(eligible %in% TRUE & is.finite(values))
  if (length(candidates) == 0L) {
    return(list(
      Available = FALSE, Value = NA_real_, ProfileId = "none",
      ProfileIndex = NA_integer_
    ))
  }
  best <- min(values[candidates])
  tied <- candidates[values[candidates] == best]
  index <- tied[which.min(match(profile_id[tied], profile_order))]
  list(
    Available = TRUE, Value = values[[index]],
    ProfileId = profile_id[[index]], ProfileIndex = index
  )
}

mfrmr_gtwsx_envelopes <- function(source_rows, atomic_rows, contract) {
  groups <- split(seq_len(nrow(source_rows)), source_rows$RouteId)
  envelopes <- lapply(groups, function(index) {
    source <- source_rows[index, , drop = FALSE]
    atomic <- atomic_rows[index, , drop = FALSE]
    if (nrow(source) != 6L || anyDuplicated(source$ProfileId) ||
        !setequal(source$ProfileId, contract$ProfileOrder)) {
      stop("Every envelope requires the exact six frozen profiles.",
           call. = FALSE)
    }
    full_raw <- mfrmr_gtwsx_choose_envelope(
      source$FullObjective, rep(TRUE, nrow(source)), source$ProfileId,
      contract$ProfileOrder
    )
    reduced_raw <- mfrmr_gtwsx_choose_envelope(
      source$ReducedObjective, rep(TRUE, nrow(source)), source$ProfileId,
      contract$ProfileOrder
    )
    full_pd <- mfrmr_gtwsx_choose_envelope(
      source$FullObjective, atomic$FullCurvatureEligible,
      source$ProfileId, contract$ProfileOrder
    )
    reduced_pd <- mfrmr_gtwsx_choose_envelope(
      source$ReducedObjective, atomic$ReducedCurvatureEligible,
      source$ProfileId, contract$ProfileOrder
    )
    raw_drop <- if (full_raw$Available && reduced_raw$Available) {
      2 * (-full_raw$Value + reduced_raw$Value)
    } else NA_real_
    pd_drop <- if (full_pd$Available && reduced_pd$Available) {
      2 * (-full_pd$Value + reduced_pd$Value)
    } else NA_real_
    payload <- list(
      RouteId = source$RouteId[[1L]], DatasetId = source$DatasetId[[1L]],
      DesignId = source$DesignId[[1L]],
      VarianceId = source$VarianceId[[1L]],
      MethodId = source$MethodId[[1L]],
      Likelihood = source$Likelihood[[1L]], ProfileCount = nrow(source),
      ProfileObjectiveHash = mfrmr_gta_hash(data.frame(
        ProfileId = source$ProfileId,
        FullObjective = source$FullObjective,
        ReducedObjective = source$ReducedObjective,
        FullCurvatureEligible = atomic$FullCurvatureEligible,
        ReducedCurvatureEligible = atomic$ReducedCurvatureEligible,
        stringsAsFactors = FALSE
      )),
      RawFullEnvelopeProfileId = full_raw$ProfileId,
      RawReducedEnvelopeProfileId = reduced_raw$ProfileId,
      RawEnvelopeSameProfile = identical(
        full_raw$ProfileId, reduced_raw$ProfileId
      ),
      RawEnvelopeDrop = raw_drop,
      RawEnvelopeOrderState = mfrmr_gtwsx_order_state(
        raw_drop, contract$DescriptiveNegativeTolerance
      ),
      PdfullEnvelopeProfileId = full_pd$ProfileId,
      PdreducedEnvelopeProfileId = reduced_pd$ProfileId,
      PdEnvelopeSameProfile = identical(
        full_pd$ProfileId, reduced_pd$ProfileId
      ),
      PdEnvelopeDrop = pd_drop,
      PdEnvelopeOrderState = mfrmr_gtwsx_order_state(
        pd_drop, contract$DescriptiveNegativeTolerance
      ),
      EnvelopeType = "best_observed_six_profile",
      GlobalOptimumClaim = FALSE, OptimizerSelected = FALSE,
      CalibrationUse = FALSE, DecisionUse = FALSE
    )
    identity <- list(
      Contract =
        "glmmtmb_numerical_adjudication_envelope_draft83d2b2b1g3_v1",
      AdjudicationContractHash = contract$AdjudicationContractHash,
      Payload = payload
    )
    data.frame(
      payload, EnvelopeHash = mfrmr_gta_hash(identity),
      stringsAsFactors = FALSE, check.names = FALSE
    )
  })
  out <- do.call(rbind, envelopes)
  row.names(out) <- NULL
  route_order <- unique(source_rows$RouteId)
  out <- out[match(route_order, out$RouteId), , drop = FALSE]
  row.names(out) <- NULL
  out
}

mfrmr_gtwsx_summaries <- function(rows, envelopes) {
  counted <- function(value, levels) {
    table(factor(value, levels = levels))
  }
  list(
    OptimizerStateCounts = counted(rows$OptimizerState, c(
      "both_reported_success", "full_nonzero", "reduced_nonzero",
      "both_nonzero", "not_evaluable"
    )),
    ObjectiveStateCounts = counted(rows$ObjectiveState, c(
      "both_finite", "full_nonfinite", "reduced_nonfinite",
      "both_nonfinite"
    )),
    ReportedLikelihoodStateCounts = counted(
      rows$ReportedLikelihoodState, c(
        "both_reported", "full_curvature_masked",
        "reduced_curvature_masked", "both_curvature_masked",
        "unexplained_nonfinite"
      )
    ),
    CurvatureStateCounts = counted(rows$CurvatureState, c(
      "both_pd_agree", "full_only_pd_agree", "reduced_only_pd_agree",
      "neither_pd_agree", "diagnostic_disagreement",
      "richardson_unavailable"
    )),
    GradientAvailabilityStateCounts = counted(
      rows$GradientAvailabilityState, c(
        "both_surfaces_available", "full_model_incomplete",
        "reduced_model_incomplete", "neither_model_complete"
      )
    ),
    ObjectiveOrderStateCounts = counted(rows$ObjectiveOrderState, c(
      "positive", "exact_zero", "small_negative", "material_negative",
      "not_evaluable"
    )),
    RawEnvelopeOrderStateCounts = counted(envelopes$RawEnvelopeOrderState, c(
      "positive", "exact_zero", "small_negative", "material_negative",
      "not_evaluable"
    )),
    PdEnvelopeOrderStateCounts = counted(envelopes$PdEnvelopeOrderState, c(
      "positive", "exact_zero", "small_negative", "material_negative",
      "not_evaluable"
    )),
    FullReportedObjectiveIdentityEvaluableN =
      sum(rows$FullReportedObjectiveIdentityEvaluable),
    FullReportedObjectiveIdentityExactN =
      sum(rows$FullReportedObjectiveIdentityExact),
    ReducedReportedObjectiveIdentityEvaluableN =
      sum(rows$ReducedReportedObjectiveIdentityEvaluable),
    ReducedReportedObjectiveIdentityExactN =
      sum(rows$ReducedReportedObjectiveIdentityExact),
    ReportedDropIdentityEvaluableN =
      sum(rows$ReportedDropIdentityEvaluable),
    ReportedDropIdentityExactN = sum(rows$ReportedDropIdentityExact),
    FullGradientSurfaceHashMismatchN =
      sum(!rows$FullGradientSurfaceHashExact),
    ReducedGradientSurfaceHashMismatchN =
      sum(!rows$ReducedGradientSurfaceHashExact),
    MaximumObservedFullOuterGradient =
      max(rows$FullOuterGradientMaximumAbsolute, na.rm = TRUE),
    MaximumObservedReducedOuterGradient =
      max(rows$ReducedOuterGradientMaximumAbsolute, na.rm = TRUE),
    StationarityThresholdFrozen = FALSE,
    ThresholdSelected = FALSE, OptimizerSelected = FALSE,
    CalibrationDataGenerated = FALSE
  )
}

mfrmr_gtwsx_contract <- function(alignment_contract, alignment_execution,
                                   comparison) {
  mfrmr_gtwsx_require_primitives()
  if (!mfrmr_gtwsx_validate_alignment(
    alignment_contract, alignment_execution, comparison
  )) {
    stop("The exact b1g2 contract, execution, and comparison are required.",
         call. = FALSE)
  }
  loglik_function <- getFromNamespace("logLik.glmmTMB", "glmmTMB")
  loglik_hash <- mfrmr_gtwy_function_hash(loglik_function)
  if (!identical(
    loglik_hash,
    "c3f49676ea6fd8b6e2f4f70e775fd62387b808fd6a93388e17b280c45c4efbfd"
  ) || !identical(as.character(utils::packageVersion("glmmTMB")),
                  "1.1.14")) {
    stop("The installed glmmTMB logLik masking contract changed.",
         call. = FALSE)
  }
  sources <- data.frame(
    SourceId = c(
      "glmmtmb_troubleshooting_current", "glmmtmb_diagnose_current",
      "glmmtmb_methods_source_current", "r_optim_current"
    ),
    Locator = c(
      "https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html",
      "https://glmmtmb.github.io/glmmTMB/reference/diagnose.html",
      "https://github.com/glmmTMB/glmmTMB/blob/master/glmmTMB/R/methods.R",
      "https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html"
    ),
    Role = c(
      "separate_gradient_hessian_restart_optimizer_checks",
      "experimental_diagnostic_defaults_not_release_thresholds",
      "reported_loglik_pdHess_mask",
      "optimizer_code_zero_semantics_only"
    ),
    stringsAsFactors = FALSE
  )
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_numerical_",
      "adjudication_draft83d2b2b1g3_v1"
    ),
    ContractArtifact = paste0(
      "gtheory-weak-information-glmmtmb-numerical-",
      "adjudication-contract-0.2.3.md"
    ),
    AlignmentRunnerContractHash = alignment_contract$RunnerContractHash,
    AlignmentExecutionHash = alignment_execution$ExecutionHash,
    AlignmentComparisonHash = comparison$ComparisonHash,
    AlignmentRowIdentity =
      alignment_execution$AtomicRows$StabilizationRouteId,
    ProfileOrder = alignment_contract$Profiles$ProfileId,
    PairCount = 120L, EnvelopeCount = 20L, ProfilesPerEnvelope = 6L,
    DescriptiveNegativeTolerance =
      alignment_contract$NegativeLikelihoodTolerance,
    DescriptiveToleranceRole =
      "inherited_partition_only_not_pass_or_inference",
    LogLikFunctionHash = loglik_hash,
    LogLikMask = "pdHess_true_returns_negative_objective_else_NA",
    PackageVersions = c(
      glmmTMB = as.character(utils::packageVersion("glmmTMB")),
      TMB = as.character(utils::packageVersion("TMB")),
      numDeriv = as.character(utils::packageVersion("numDeriv")),
      R = as.character(getRversion())
    ),
    Sources = sources, NoRefit = TRUE, FitObjectAccessPermitted = FALSE,
    RawGradientReconstructionPermitted = FALSE,
    ThresholdSelectionPermitted = FALSE,
    OptimizerSelectionPermitted = FALSE,
    CalibrationDataGenerationPermitted = FALSE,
    GlobalOptimumClaimPermitted = FALSE,
    FunctionHashes = mfrmr_gtwsx_function_hashes()
  )
  structure(c(identity, list(
    AdjudicationContractHash = mfrmr_gta_hash(identity),
    AdjudicatorImplemented = TRUE, NoRefitAdjudicationAuthorized = TRUE,
    FullExecutionAuthorized = FALSE,
    StationarityThresholdFrozen = FALSE,
    NumericalEligibilitySufficientRuleFrozen = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwsx_contract")
}

mfrmr_gtwsx_adjudicate <- function(contract, alignment_execution) {
  if (!inherits(contract, "mfrmr_gtwsx_contract") ||
      !isTRUE(contract$NoRefitAdjudicationAuthorized) ||
      !isTRUE(contract$NoRefit) || isTRUE(contract$FitObjectAccessPermitted) ||
      isTRUE(contract$RawGradientReconstructionPermitted) ||
      isTRUE(contract$ThresholdSelectionPermitted) ||
      isTRUE(contract$OptimizerSelectionPermitted) ||
      isTRUE(contract$CalibrationDataGenerationPermitted) ||
      isTRUE(contract$GlobalOptimumClaimPermitted) ||
      !inherits(alignment_execution, "mfrmr_gtwsw_execution") ||
      !identical(contract$AlignmentExecutionHash,
                 alignment_execution$ExecutionHash) ||
      !mfrmr_gtwsx_alignment_execution_hash_valid(alignment_execution)) {
    stop("The exact no-refit b1g3 adjudication is not authorized.",
         call. = FALSE)
  }
  source_rows <- alignment_execution$AtomicRows
  if (!identical(
    as.character(source_rows$StabilizationRouteId),
    as.character(contract$AlignmentRowIdentity)
  )) {
    stop("The ordered b1g2 denominator changed.", call. = FALSE)
  }
  atomic <- mfrmr_gtwsx_atomic_rows(source_rows, contract)
  envelopes <- mfrmr_gtwsx_envelopes(source_rows, atomic, contract)
  summaries <- mfrmr_gtwsx_summaries(atomic, envelopes)
  exact <- nrow(atomic) == contract$PairCount &&
    nrow(envelopes) == contract$EnvelopeCount &&
    !anyDuplicated(atomic$StabilizationRouteId) &&
    !anyDuplicated(envelopes$RouteId) &&
    identical(
      as.character(atomic$StabilizationRouteId),
      as.character(contract$AlignmentRowIdentity)
    ) && all(atomic$NoRefit %in% TRUE) &&
    all(!(atomic$PairDecisionEligible %in% TRUE)) &&
    all(table(atomic$RouteId) == contract$ProfilesPerEnvelope)
  if (!exact) stop("The b1g3 accounting failed.", call. = FALSE)
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_numerical_",
      "adjudication_result_draft83d2b2b1g3_v1"
    ),
    AdjudicationContractHash = contract$AdjudicationContractHash,
    AlignmentExecutionHash = alignment_execution$ExecutionHash,
    AtomicRows = atomic, EnvelopeRows = envelopes, Summaries = summaries
  )
  structure(c(identity, list(
    ResultHash = mfrmr_gta_hash(identity), ExactAccountingPassed = exact,
    PairCount = nrow(atomic), EnvelopeCount = nrow(envelopes),
    AdjudicationSchemaReady = TRUE, NoRefitLedgerReady = TRUE,
    ObjectiveLikelihoodSeparationReady = TRUE,
    CurvatureNecessaryConditionSpecified = TRUE,
    StationarityCriterionReady = FALSE,
    NumericalEligibilitySufficientRuleFrozen = FALSE,
    FullExecutionAuthorized = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwsx_adjudication")
}
