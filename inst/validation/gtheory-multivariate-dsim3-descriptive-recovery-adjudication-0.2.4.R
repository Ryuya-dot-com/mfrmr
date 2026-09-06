# Internal D-SIM-3 descriptive recovery and failure-denominator adjudication.
#
# This layer reads the immutable bounded-launch evidence. It never regenerates
# a response or refits a model. Direct truth comparisons are limited to the
# 42 routes whose frozen plan declares the separate-univariate truth metric
# directly applicable. The eight multivariate routes enter only a labelled
# within-backend parity description, not an independent-reference claim.

mfrmr_gtds3ad_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3ac_assert_manifest",
    "mfrmr_gtds3_assert_manifest", "mfrmr_gtds3m_assert_manifest",
    "mfrmr_gtds3p_assert_plan"
  )
  target <- environment(mfrmr_gtds3ad_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 launch, truth-metric, and plan chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3ad_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3ad_file_hash <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The descriptive adjudication requires `digest`.", call. = FALSE)
  }
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) stop("An evidence file is required.", call. = FALSE)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtds3ad_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-DESCRIPTIVE-RECOVERY-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentLaunchContractHash =
      "5ea53cc09a1261b1b73eac3d72f433273a454aaa1ae7ee6302921c278dd7a642",
    ParentLaunchInputHash =
      "b3df6175d1ec82e54b97be466a08a8dc16f115a1aa1cbca2425d5f4ed29679b4",
    ParentLaunchManifestHash =
      "84b89383d974f7a3a40df738b0ce618f86324d3b1ea54ea99ea2ed20a4019aea",
    ParentCompletionHash =
      "fddce2750f0d873ff9394dce5a1d565988ecf33aef255f739a3fcbd7509d8b9f",
    ParentPlanHash =
      "58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a",
    ParentCoverageManifestHash =
      "4c6958f00aac7598d777387ec113cd43474031430492e83e6183d19dcedf7197",
    ParentTruthMetricContractHash =
      "d73dd72c8bc849597dd68342a3608b1f34b315e7f1fd1ad52a87a9e26d963cb8",
    ParentTruthMetricManifestHash =
      "969afca1d3fb23a68d58500cd6959152b385b0e9b2e64c25cc75a3cd79feb37c",
    LaunchInputFileSHA256 =
      "6eeea2a9a71236ea4bc05ad1f300a8787803719d19d1f2e87cf95c647569ba1a",
    LaunchResultFileSHA256 =
      "67ac964b910a4a136c53d1959a6f9d22b326a77c9e3cdb9eeb52c69a7e842224",
    CompletionFileSHA256 =
      "84e858bb7695aadfed06c1a8219566222c75a9cfccf3a35cfcee8ad354aeda96"
  )
}

mfrmr_gtds3ad_contract <- function() {
  mfrmr_gtds3ad_require_primitives()
  identity <- mfrmr_gtds3ad_identity()
  payload <- c(identity, list(
    ExpectedEvidenceFileCount = 3L,
    ExpectedDatasetAttemptCount = 42L,
    ExpectedCandidateRouteCount = 50L,
    ExpectedMetricRequestCount = 100L,
    ExpectedTerminalReceiptCount = 92L,
    ExpectedFrozenNoCallRouteCount = 160L,
    ExpectedCoordinateCount = 420L,
    ExpectedScenarioCount = 21L,
    ExpectedScenarioRoleCount = 4L,
    ExpectedDirectTruthRouteCount = 42L,
    ExpectedDirectTruthMetricCount = 84L,
    ExpectedDirectTruthRouteStratumCount = 94L,
    ExpectedDirectTruthScalarCount = 188L,
    ExpectedAvailableDirectTruthScalarCount = 184L,
    ExpectedParityRoutePairCount = 8L,
    ExpectedParityScalarCount = 40L,
    ParityDescriptionTolerance = 1e-6,
    ImmutableEvidenceReadOnly = TRUE,
    ResponseGenerationAllowed = FALSE,
    BackendCallAllowed = FALSE,
    RefitAllowed = FALSE,
    ReplacementSeedAllowed = FALSE,
    FailureExclusionAllowed = FALSE,
    RouteVotingAllowed = FALSE,
    DirectTruthLimitedToQualifiedSeparateUnivariateRoutes = TRUE,
    MultivariateParityIsIndependentReference = FALSE,
    StandardizedBiasAcceptanceMayBeEvaluated = FALSE,
    CoverageAcceptanceMayBeEvaluated = FALSE,
    RecoveryEvidenceMayBeComputed = TRUE,
    ConfirmationAuthorizationAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3ad_hash(payload)
  )), class = c("mfrmr_gtds3ad_contract", "list"))
}

mfrmr_gtds3ad_validate_contract <- function(
    contract = mfrmr_gtds3ad_contract()) {
  canonical <- mfrmr_gtds3ad_contract()
  valid <- inherits(contract, "mfrmr_gtds3ad_contract") &&
    identical(contract, canonical) &&
    identical(contract$ExpectedDirectTruthRouteCount, 42L) &&
    identical(contract$ExpectedDirectTruthScalarCount, 188L) &&
    identical(contract$ExpectedAvailableDirectTruthScalarCount, 184L) &&
    identical(contract$ExpectedParityScalarCount, 40L) &&
    isTRUE(contract$ImmutableEvidenceReadOnly) &&
    !isTRUE(contract$ResponseGenerationAllowed) &&
    !isTRUE(contract$BackendCallAllowed) && !isTRUE(contract$RefitAllowed) &&
    !isTRUE(contract$ReplacementSeedAllowed) &&
    !isTRUE(contract$FailureExclusionAllowed) &&
    !isTRUE(contract$RouteVotingAllowed) &&
    isTRUE(contract$DirectTruthLimitedToQualifiedSeparateUnivariateRoutes) &&
    !isTRUE(contract$MultivariateParityIsIndependentReference) &&
    !isTRUE(contract$StandardizedBiasAcceptanceMayBeEvaluated) &&
    !isTRUE(contract$CoverageAcceptanceMayBeEvaluated) &&
    isTRUE(contract$RecoveryEvidenceMayBeComputed) &&
    !isTRUE(contract$ConfirmationAuthorizationAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The descriptive D-SIM-3 recovery contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3ad_evidence_files <- function(
    input_path, result_path, completion_path, contract) {
  paths <- c(
    launch_input = input_path, launch_result = result_path,
    run_completion = completion_path
  )
  expected <- c(
    contract$LaunchInputFileSHA256, contract$LaunchResultFileSHA256,
    contract$CompletionFileSHA256
  )
  observed <- vapply(paths, mfrmr_gtds3ad_file_hash, character(1L))
  data.frame(
    EvidenceFileOrdinal = seq_along(paths),
    EvidenceFileId = names(paths),
    EvidenceBasename = basename(paths),
    ExpectedSHA256 = expected,
    ObservedSHA256 = observed,
    ExactIdentityMatch = observed == expected,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ad_load_launch <- function(
    input_path, result_path, completion_path,
    contract = mfrmr_gtds3ad_contract()) {
  files <- mfrmr_gtds3ad_evidence_files(
    input_path, result_path, completion_path, contract
  )
  if (!all(files$ExactIdentityMatch)) {
    stop("A bounded-launch evidence file changed.", call. = FALSE)
  }
  input <- readRDS(input_path)
  result <- readRDS(result_path)
  completion <- readRDS(completion_path)
  mfrmr_gtds3ac_assert_manifest(result, input)
  valid_completion <- inherits(
    completion, "mfrmr_gtds3ac_completion"
  ) && identical(completion$ContractHash, contract$ParentLaunchContractHash) &&
    identical(completion$LaunchInputHash, contract$ParentLaunchInputHash) &&
    identical(completion$ManifestHash, contract$ParentLaunchManifestHash) &&
    identical(completion$CompletionHash, contract$ParentCompletionHash) &&
    identical(completion$NewCheckpointCount, 42L) &&
    identical(completion$ResumedCheckpointCount, 0L) &&
    identical(completion$ParentFailureCheckpointCount, 0L)
  if (!valid_completion ||
      !identical(input$LaunchInputHash, contract$ParentLaunchInputHash) ||
      !identical(result$Contract$ContractHash,
                 contract$ParentLaunchContractHash) ||
      !identical(result$ManifestHash, contract$ParentLaunchManifestHash)) {
    stop("The bounded-launch parent identity changed.", call. = FALSE)
  }
  list(
    EvidenceFileRegistry = files, LaunchInput = input,
    LaunchManifest = result, Completion = completion
  )
}

mfrmr_gtds3ad_scalar_value <- function(
    coefficients, backend_request_id, stratum, estimand_id) {
  row <- coefficients[
    coefficients$BackendRequestId == backend_request_id &
      coefficients$Stratum == stratum, , drop = FALSE
  ]
  if (nrow(row) != 1L) return(NA_real_)
  value <- if (identical(estimand_id, "ABS-PHI")) row$Phi else row$G
  as.numeric(value[[1L]])
}

mfrmr_gtds3ad_direct_truth_registry <- function(
    launch, truth_manifest, plan, contract) {
  routes <- plan$RouteUnitRegistry
  routes <- routes[
    routes$PlannedDisposition == "qualification_candidate" &
      routes$TruthMetricDirectlyApplicable, , drop = FALSE
  ]
  routes <- routes[order(routes$RouteUnitOrdinal, method = "radix"), ]
  truth <- truth_manifest$StratumTruthCoefficientRegistry
  fits <- launch$FitResultRegistry
  metrics <- launch$MetricResultRegistry
  coefficients <- launch$FittedCoefficientRegistry
  rows <- list(); cursor <- 0L
  for (route_index in seq_len(nrow(routes))) {
    route <- routes[route_index, , drop = FALSE]
    fit <- fits[fits$RouteUnitId == route$RouteUnitId[[1L]], , drop = FALSE]
    if (nrow(fit) != 1L) {
      stop("A direct-truth route lacks one fit result.", call. = FALSE)
    }
    strata <- truth[truth$ScenarioId == route$ScenarioId[[1L]], ,
                    drop = FALSE]
    strata <- strata[order(strata$StratumOrdinal, method = "radix"), ]
    for (stratum_index in seq_len(nrow(strata))) {
      truth_row <- strata[stratum_index, , drop = FALSE]
      for (estimand in c("ABS-PHI", "REL-G")) {
        cursor <- cursor + 1L
        metric <- metrics[
          metrics$RouteUnitId == route$RouteUnitId[[1L]] &
            metrics$EstimandId == estimand, , drop = FALSE
        ]
        if (nrow(metric) != 1L) {
          stop("A direct-truth route lacks one metric result.", call. = FALSE)
        }
        estimate <- mfrmr_gtds3ad_scalar_value(
          coefficients, fit$BackendRequestId[[1L]],
          truth_row$Stratum[[1L]], estimand
        )
        truth_value <- if (identical(estimand, "ABS-PHI")) {
          truth_row$Phi[[1L]]
        } else truth_row$G[[1L]]
        available <- isTRUE(metric$MetricComputed[[1L]]) &&
          is.finite(estimate) && is.finite(truth_value)
        error <- if (available) estimate - truth_value else NA_real_
        payload <- list(
          RouteUnitId = route$RouteUnitId[[1L]],
          Stratum = truth_row$Stratum[[1L]], EstimandId = estimand,
          Estimate = estimate, Truth = truth_value,
          ComparisonAvailable = available
        )
        rows[[cursor]] <- data.frame(
          ComparisonOrdinal = cursor,
          ComparisonId = paste0(
            "D3AD-DT-", sprintf("%03d", cursor), "-",
            substr(mfrmr_gtds3ad_hash(payload), 1L, 16L)
          ),
          BackendRequestId = fit$BackendRequestId[[1L]],
          RouteUnitId = route$RouteUnitId[[1L]],
          DatasetId = route$DatasetId[[1L]],
          ScenarioId = route$ScenarioId[[1L]],
          Replicate = route$Replicate[[1L]],
          RouteId = route$RouteId[[1L]],
          StratumOrdinal = truth_row$StratumOrdinal[[1L]],
          Stratum = truth_row$Stratum[[1L]], EstimandId = estimand,
          MetricRequestId = metric$MetricRequestId[[1L]],
          RouteTerminalState = fit$TerminalState[[1L]],
          MetricTerminalState = metric$TerminalState[[1L]],
          Estimate = estimate, Truth = truth_value, Error = error,
          AbsoluteError = abs(error), SquaredError = error^2,
          FitHadSingular = fit$SingularFitCallCount[[1L]] > 0L,
          FitHadConvergenceMessage =
            fit$ConvergenceMessageFitCallCount[[1L]] > 0L,
          DirectTruthQualified = TRUE,
          CountsInPlannedDenominator = TRUE,
          ComparisonAvailable = available,
          FailureExcluded = FALSE,
          AcceptanceThresholdApplied = FALSE,
          DescriptiveRecoveryComputed = available,
          ComparisonHash = mfrmr_gtds3ad_hash(payload),
          stringsAsFactors = FALSE
        )
      }
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3ad_summary_values <- function(values) {
  values <- values[is.finite(values)]
  if (!length(values)) {
    return(c(
      MeanError = NA_real_, MeanAbsoluteError = NA_real_,
      RootMeanSquaredError = NA_real_, MedianAbsoluteError = NA_real_,
      MaximumAbsoluteError = NA_real_
    ))
  }
  c(
    MeanError = mean(values), MeanAbsoluteError = mean(abs(values)),
    RootMeanSquaredError = sqrt(mean(values^2)),
    MedianAbsoluteError = stats::median(abs(values)),
    MaximumAbsoluteError = max(abs(values))
  )
}

mfrmr_gtds3ad_estimand_summary <- function(direct) {
  rows <- lapply(c("ABS-PHI", "REL-G"), function(estimand) {
    part <- direct[direct$EstimandId == estimand, , drop = FALSE]
    values <- mfrmr_gtds3ad_summary_values(part$Error)
    data.frame(
      EstimandId = estimand,
      PlannedScalarCount = nrow(part),
      AvailableScalarCount = sum(part$ComparisonAvailable),
      UnavailableScalarCount = sum(!part$ComparisonAvailable),
      MeanError = unname(values[["MeanError"]]),
      MeanAbsoluteError = unname(values[["MeanAbsoluteError"]]),
      RootMeanSquaredError = unname(values[["RootMeanSquaredError"]]),
      MedianAbsoluteError = unname(values[["MedianAbsoluteError"]]),
      MaximumAbsoluteError = unname(values[["MaximumAbsoluteError"]]),
      StandardizedBiasComputed = FALSE,
      MonteCarloStandardErrorComputed = FALSE,
      AcceptanceThresholdApplied = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  output$SummaryOrdinal <- seq_len(nrow(output))
  output <- output[c("SummaryOrdinal", setdiff(names(output),
                                               "SummaryOrdinal"))]
  row.names(output) <- NULL
  output
}

mfrmr_gtds3ad_profile_summary <- function(direct, coverage) {
  scenarios <- coverage$ScenarioRegistry
  keys <- unique(direct[c("ScenarioId", "EstimandId")])
  keys <- keys[order(keys$ScenarioId, keys$EstimandId, method = "radix"), ]
  rows <- lapply(seq_len(nrow(keys)), function(index) {
    key <- keys[index, , drop = FALSE]
    scenario <- scenarios[
      scenarios$ScenarioId == key$ScenarioId[[1L]], , drop = FALSE
    ]
    if (nrow(scenario) != 1L) {
      stop("A recovery profile is absent from the coverage manifest.",
           call. = FALSE)
    }
    part <- direct[
      direct$ScenarioId == key$ScenarioId[[1L]] &
        direct$EstimandId == key$EstimandId[[1L]], , drop = FALSE
    ]
    values <- mfrmr_gtds3ad_summary_values(part$Error)
    data.frame(
      ProfileSummaryOrdinal = index,
      ScenarioId = key$ScenarioId[[1L]],
      EstimandId = key$EstimandId[[1L]],
      ScenarioRole = scenario$ScenarioRole[[1L]],
      stratum_count = scenario$stratum_count[[1L]],
      condition_sharing = scenario$condition_sharing[[1L]],
      observation_event = scenario$observation_event[[1L]],
      crossing = scenario$crossing[[1L]],
      balance = scenario$balance[[1L]],
      missingness = scenario$missingness[[1L]],
      object_count = scenario$object_count[[1L]],
      rater_count = scenario$rater_count[[1L]],
      repeat_count = scenario$repeat_count[[1L]],
      variance_regime = scenario$variance_regime[[1L]],
      cross_stratum_covariance =
        scenario$cross_stratum_covariance[[1L]],
      response_distribution = scenario$response_distribution[[1L]],
      PlannedScalarCount = nrow(part),
      AvailableScalarCount = sum(part$ComparisonAvailable),
      UnavailableScalarCount = sum(!part$ComparisonAvailable),
      MeanError = unname(values[["MeanError"]]),
      MeanAbsoluteError = unname(values[["MeanAbsoluteError"]]),
      RootMeanSquaredError = unname(values[["RootMeanSquaredError"]]),
      MaximumAbsoluteError = unname(values[["MaximumAbsoluteError"]]),
      AcceptanceThresholdApplied = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3ad_scenario_role_summary <- function(direct, coverage) {
  scenarios <- coverage$ScenarioRegistry
  role <- scenarios$ScenarioRole[match(direct$ScenarioId,
                                       scenarios$ScenarioId)]
  if (anyNA(role)) stop("A recovery scalar lacks a scenario role.",
                        call. = FALSE)
  roles <- sort(unique(scenarios$ScenarioRole), method = "radix")
  keys <- expand.grid(
    ScenarioRole = roles, EstimandId = c("ABS-PHI", "REL-G"),
    stringsAsFactors = FALSE
  )
  rows <- lapply(seq_len(nrow(keys)), function(index) {
    key <- keys[index, , drop = FALSE]
    part <- direct[
      role == key$ScenarioRole[[1L]] &
        direct$EstimandId == key$EstimandId[[1L]], , drop = FALSE
    ]
    values <- mfrmr_gtds3ad_summary_values(part$Error)
    data.frame(
      ScenarioRoleSummaryOrdinal = index,
      ScenarioRole = key$ScenarioRole[[1L]],
      EstimandId = key$EstimandId[[1L]],
      ScenarioCount = length(unique(part$ScenarioId)),
      PlannedScalarCount = nrow(part),
      AvailableScalarCount = sum(part$ComparisonAvailable),
      UnavailableScalarCount = sum(!part$ComparisonAvailable),
      MeanError = unname(values[["MeanError"]]),
      MeanAbsoluteError = unname(values[["MeanAbsoluteError"]]),
      RootMeanSquaredError = unname(values[["RootMeanSquaredError"]]),
      MaximumAbsoluteError = unname(values[["MaximumAbsoluteError"]]),
      AcceptanceThresholdApplied = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3ad_diagnostic_summary <- function(direct) {
  group <- ifelse(
    direct$FitHadSingular | direct$FitHadConvergenceMessage,
    "singular_or_convergence_message", "no_singular_or_convergence_message"
  )
  keys <- expand.grid(
    DiagnosticGroup = c(
      "no_singular_or_convergence_message",
      "singular_or_convergence_message"
    ),
    EstimandId = c("ABS-PHI", "REL-G"),
    stringsAsFactors = FALSE
  )
  rows <- lapply(seq_len(nrow(keys)), function(index) {
    key <- keys[index, , drop = FALSE]
    part <- direct[
      group == key$DiagnosticGroup[[1L]] &
        direct$EstimandId == key$EstimandId[[1L]], , drop = FALSE
    ]
    values <- mfrmr_gtds3ad_summary_values(part$Error)
    data.frame(
      DiagnosticSummaryOrdinal = index,
      DiagnosticGroup = key$DiagnosticGroup[[1L]],
      EstimandId = key$EstimandId[[1L]],
      PlannedScalarCount = nrow(part),
      AvailableScalarCount = sum(part$ComparisonAvailable),
      UnavailableScalarCount = sum(!part$ComparisonAvailable),
      MeanError = unname(values[["MeanError"]]),
      MeanAbsoluteError = unname(values[["MeanAbsoluteError"]]),
      RootMeanSquaredError = unname(values[["RootMeanSquaredError"]]),
      MaximumAbsoluteError = unname(values[["MaximumAbsoluteError"]]),
      CausalDiagnosticInterpretationAllowed = FALSE,
      ExcludedFromOverallSummary = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3ad_parity_registry <- function(launch, truth_manifest, plan,
                                           contract) {
  routes <- plan$RouteUnitRegistry
  multi <- routes[
    routes$PlannedDisposition == "qualification_candidate" &
      routes$RouteId == "multivariate_lme4_restricted", , drop = FALSE
  ]
  multi <- multi[order(multi$RouteUnitOrdinal, method = "radix"), ]
  separate <- routes[
    routes$PlannedDisposition == "qualification_candidate" &
      routes$RouteId == "separate_univariate", , drop = FALSE
  ]
  fits <- launch$FitResultRegistry
  coefficients <- launch$FittedCoefficientRegistry
  truth <- truth_manifest$StratumTruthCoefficientRegistry
  rows <- list(); cursor <- 0L
  for (route_index in seq_len(nrow(multi))) {
    left_route <- multi[route_index, , drop = FALSE]
    right_route <- separate[
      separate$DatasetId == left_route$DatasetId[[1L]], , drop = FALSE
    ]
    if (nrow(right_route) != 1L) {
      stop("A multivariate route lacks one paired separate route.",
           call. = FALSE)
    }
    left_fit <- fits[fits$RouteUnitId == left_route$RouteUnitId[[1L]], ]
    right_fit <- fits[fits$RouteUnitId == right_route$RouteUnitId[[1L]], ]
    strata <- truth[truth$ScenarioId == left_route$ScenarioId[[1L]], ]
    strata <- strata[order(strata$StratumOrdinal, method = "radix"), ]
    for (stratum_index in seq_len(nrow(strata))) {
      stratum <- strata$Stratum[[stratum_index]]
      for (estimand in c("ABS-PHI", "REL-G")) {
        cursor <- cursor + 1L
        left <- mfrmr_gtds3ad_scalar_value(
          coefficients, left_fit$BackendRequestId[[1L]], stratum, estimand
        )
        right <- mfrmr_gtds3ad_scalar_value(
          coefficients, right_fit$BackendRequestId[[1L]], stratum, estimand
        )
        available <- is.finite(left) && is.finite(right)
        difference <- if (available) left - right else NA_real_
        payload <- list(
          DatasetId = left_route$DatasetId[[1L]], Stratum = stratum,
          EstimandId = estimand, MultivariateEstimate = left,
          SeparateEstimate = right
        )
        rows[[cursor]] <- data.frame(
          ParityOrdinal = cursor,
          ParityId = paste0(
            "D3AD-WP-", sprintf("%02d", cursor), "-",
            substr(mfrmr_gtds3ad_hash(payload), 1L, 16L)
          ),
          DatasetId = left_route$DatasetId[[1L]],
          ScenarioId = left_route$ScenarioId[[1L]],
          Replicate = left_route$Replicate[[1L]],
          MultivariateRouteUnitId = left_route$RouteUnitId[[1L]],
          SeparateRouteUnitId = right_route$RouteUnitId[[1L]],
          Stratum = stratum, EstimandId = estimand,
          MultivariateEstimate = left, SeparateEstimate = right,
          Difference = difference, AbsoluteDifference = abs(difference),
          ComparisonAvailable = available,
          WithinTolerance = available &&
            abs(difference) <= contract$ParityDescriptionTolerance,
          IndependentReference = FALSE,
          AcceptanceThresholdApplied = FALSE,
          CountsInPlannedParityDenominator = TRUE,
          ParityHash = mfrmr_gtds3ad_hash(payload),
          stringsAsFactors = FALSE
        )
      }
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3ad_parity_summary <- function(parity, contract) {
  rows <- lapply(c("ABS-PHI", "REL-G"), function(estimand) {
    part <- parity[parity$EstimandId == estimand, , drop = FALSE]
    data.frame(
      EstimandId = estimand,
      PlannedComparisonCount = nrow(part),
      AvailableComparisonCount = sum(part$ComparisonAvailable),
      UnavailableComparisonCount = sum(!part$ComparisonAvailable),
      WithinToleranceCount = sum(part$WithinTolerance),
      MeanDifference = mean(part$Difference, na.rm = TRUE),
      MeanAbsoluteDifference = mean(part$AbsoluteDifference, na.rm = TRUE),
      MaximumAbsoluteDifference = max(part$AbsoluteDifference, na.rm = TRUE),
      DescriptiveTolerance = contract$ParityDescriptionTolerance,
      IndependentReference = FALSE,
      AcceptanceThresholdApplied = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  output$ParitySummaryOrdinal <- seq_len(nrow(output))
  output <- output[c("ParitySummaryOrdinal", setdiff(names(output),
                                                     "ParitySummaryOrdinal"))]
  row.names(output) <- NULL
  output
}

mfrmr_gtds3ad_coordinate_registry <- function(launch, plan) {
  output <- launch$CoordinateDispositionRegistry
  planned <- plan$RouteEstimandCoordinateRegistry
  index <- match(output$CoordinateId, planned$CoordinateId)
  if (anyNA(index)) stop("A coordinate is absent from the frozen plan.",
                         call. = FALSE)
  output$DirectTruthMetricBindingRequired <-
    planned$DirectTruthMetricBindingRequired[index]
  output$DescriptiveDisposition <- ifelse(
    output$FrozenNoCallCoordinate, "frozen_no_call_preserved",
    ifelse(
      output$DirectTruthMetricBindingRequired & output$MetricComputed,
      "direct_truth_compared",
      ifelse(
        output$DirectTruthMetricBindingRequired,
        "direct_truth_metric_failure", "scenario_reference_parity_only"
      )
    )
  )
  output$DescriptiveRecoveryComputed <-
    output$DescriptiveDisposition == "direct_truth_compared"
  output$IndependentReferenceCompared <-
    output$DescriptiveRecoveryComputed
  output$ConfirmationEvidence <- FALSE
  output$SimulationValidationEvidence <- FALSE
  output
}

mfrmr_gtds3ad_outcome_registry <- function(launch, direct, parity,
                                            coordinates) {
  data.frame(
    OutcomeOrdinal = 1:8,
    OutcomeClass = c(
      "dataset_generation", "candidate_route", "metric_request",
      "terminal_receipt", "frozen_no_call_route",
      "direct_truth_scalar", "within_backend_parity_scalar",
      "route_estimand_coordinate"
    ),
    PlannedCount = c(42L, 50L, 100L, 92L, 160L, 188L, 40L, 420L),
    AvailableOrPreservedCount = c(
      launch$Summary$DatasetGenerationCompleteCount,
      launch$Summary$CandidateRouteCompleteCount,
      launch$Summary$ComputedMetricRequestCount,
      launch$Summary$TerminalReceiptCount,
      nrow(launch$FrozenNoCallRouteRegistry),
      sum(direct$ComparisonAvailable), sum(parity$ComparisonAvailable),
      sum(coordinates$CountsInCoordinateDenominator)
    ),
    NoncompleteOrUnavailableCount = c(
      0L, launch$Summary$CandidateRouteFailureCount,
      launch$Summary$MetricRequestCount -
        launch$Summary$ComputedMetricRequestCount,
      0L, 0L, sum(!direct$ComparisonAvailable),
      sum(!parity$ComparisonAvailable), 0L
    ),
    FailureExcluded = FALSE,
    DenominatorPreserved = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ad_resource_summary <- function(launch) {
  process <- launch$ProcessReceiptRegistry
  data.frame(
    ProcessCount = nrow(process),
    SuccessfulProcessCount = sum(process$Outcome == "success"),
    TotalElapsedSeconds = sum(process$ElapsedSeconds),
    MedianElapsedSeconds = stats::median(process$ElapsedSeconds),
    MaximumElapsedSeconds = max(process$ElapsedSeconds),
    MaximumPeakRssMiB = max(process$PeakRssMiB, na.rm = TRUE),
    MemoryObservedProcessCount = sum(process$MemoryObserved),
    PostOutcomeResourceExclusionApplied = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ad_canonical_code <- function(value) {
  paste(
    deparse(
      value, width.cutoff = 500L,
      control = c("keepNA", "keepInteger", "niceNames")
    ),
    collapse = "\n"
  )
}

mfrmr_gtds3ad_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3ad_require_primitives", "mfrmr_gtds3ad_hash",
    "mfrmr_gtds3ad_file_hash", "mfrmr_gtds3ad_identity",
    "mfrmr_gtds3ad_contract", "mfrmr_gtds3ad_validate_contract",
    "mfrmr_gtds3ad_evidence_files", "mfrmr_gtds3ad_load_launch",
    "mfrmr_gtds3ad_scalar_value", "mfrmr_gtds3ad_direct_truth_registry",
    "mfrmr_gtds3ad_summary_values", "mfrmr_gtds3ad_estimand_summary",
    "mfrmr_gtds3ad_profile_summary",
    "mfrmr_gtds3ad_scenario_role_summary",
    "mfrmr_gtds3ad_diagnostic_summary",
    "mfrmr_gtds3ad_parity_registry", "mfrmr_gtds3ad_parity_summary",
    "mfrmr_gtds3ad_coordinate_registry", "mfrmr_gtds3ad_outcome_registry",
    "mfrmr_gtds3ad_resource_summary", "mfrmr_gtds3ad_canonical_code",
    "mfrmr_gtds3ad_implementation_identity",
    "mfrmr_gtds3ad_manifest_fields", "mfrmr_gtds3ad_manifest",
    "mfrmr_gtds3ad_assert_manifest"
  )
  target <- environment(mfrmr_gtds3ad_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3ad_hash(list(
        Formals = mfrmr_gtds3ad_canonical_code(formals(fun)),
        Body = mfrmr_gtds3ad_canonical_code(body(fun))
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3ad_manifest_fields <- function() {
  c(
    "Contract", "EvidenceFileRegistry", "ParentLaunchInputHash",
    "ParentLaunchManifestHash", "ParentCompletionHash", "ParentPlanHash",
    "ParentCoverageManifestHash", "ParentTruthMetricManifestHash",
    "RequestOutcomeRegistry",
    "CoordinateAdjudicationRegistry", "DirectTruthScalarRegistry",
    "EstimandRecoverySummaryRegistry", "ProfileRecoverySummaryRegistry",
    "ScenarioRoleRecoverySummaryRegistry",
    "DiagnosticRecoverySummaryRegistry", "WithinBackendParityScalarRegistry",
    "WithinBackendParitySummaryRegistry", "ResourceSummaryRegistry",
    "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3ad_manifest <- function(
    input_path, result_path, completion_path, coverage, truth_manifest, plan,
    contract = mfrmr_gtds3ad_contract()) {
  mfrmr_gtds3ad_validate_contract(contract)
  mfrmr_gtds3_assert_manifest(coverage)
  mfrmr_gtds3m_assert_manifest(truth_manifest)
  mfrmr_gtds3p_assert_plan(plan)
  if (!identical(coverage$ManifestHash,
                 contract$ParentCoverageManifestHash) ||
      !identical(truth_manifest$Contract$ContractHash,
                 contract$ParentTruthMetricContractHash) ||
      !identical(truth_manifest$ManifestHash,
                 contract$ParentTruthMetricManifestHash) ||
      !identical(plan$PlanHash, contract$ParentPlanHash)) {
    stop("A descriptive-recovery reference identity changed.", call. = FALSE)
  }
  loaded <- mfrmr_gtds3ad_load_launch(
    input_path, result_path, completion_path, contract
  )
  launch <- loaded$LaunchManifest
  direct <- mfrmr_gtds3ad_direct_truth_registry(
    launch, truth_manifest, plan, contract
  )
  estimand <- mfrmr_gtds3ad_estimand_summary(direct)
  profile <- mfrmr_gtds3ad_profile_summary(direct, coverage)
  scenario_role <- mfrmr_gtds3ad_scenario_role_summary(direct, coverage)
  diagnostic <- mfrmr_gtds3ad_diagnostic_summary(direct)
  parity <- mfrmr_gtds3ad_parity_registry(
    launch, truth_manifest, plan, contract
  )
  parity_summary <- mfrmr_gtds3ad_parity_summary(parity, contract)
  coordinates <- mfrmr_gtds3ad_coordinate_registry(launch, plan)
  outcomes <- mfrmr_gtds3ad_outcome_registry(
    launch, direct, parity, coordinates
  )
  resource <- mfrmr_gtds3ad_resource_summary(launch)
  implementation <- mfrmr_gtds3ad_implementation_identity()
  disposition_counts <- table(factor(
    coordinates$DescriptiveDisposition,
    levels = c(
      "direct_truth_compared", "direct_truth_metric_failure",
      "scenario_reference_parity_only", "frozen_no_call_preserved"
    )
  ))
  summary <- list(
    EvidenceFileCount = nrow(loaded$EvidenceFileRegistry),
    ExactEvidenceFileCount = sum(
      loaded$EvidenceFileRegistry$ExactIdentityMatch
    ),
    DatasetAttemptCount = launch$Summary$DatasetAttemptCount,
    CandidateRouteCount = launch$Summary$CandidateRouteAttemptCount,
    CompleteCandidateRouteCount =
      launch$Summary$CandidateRouteCompleteCount,
    FailedCandidateRouteCount = launch$Summary$CandidateRouteFailureCount,
    MetricRequestCount = launch$Summary$MetricRequestCount,
    ComputedMetricRequestCount = launch$Summary$ComputedMetricRequestCount,
    TerminalReceiptCount = launch$Summary$TerminalReceiptCount,
    DirectTruthRouteCount = length(unique(direct$RouteUnitId)),
    DirectTruthMetricCount = length(unique(direct$MetricRequestId)),
    DirectTruthScalarCount = nrow(direct),
    AvailableDirectTruthScalarCount = sum(direct$ComparisonAvailable),
    UnavailableDirectTruthScalarCount = sum(!direct$ComparisonAvailable),
    ParityRoutePairCount = length(unique(parity$MultivariateRouteUnitId)),
    ParityScalarCount = nrow(parity),
    AvailableParityScalarCount = sum(parity$ComparisonAvailable),
    DirectTruthComparedCoordinateCount = unname(disposition_counts[[1L]]),
    DirectTruthMetricFailureCoordinateCount =
      unname(disposition_counts[[2L]]),
    ScenarioReferenceParityOnlyCoordinateCount =
      unname(disposition_counts[[3L]]),
    FrozenNoCallCoordinateCount = unname(disposition_counts[[4L]]),
    DescriptiveRecoveryComputed = TRUE,
    StandardizedBiasComputed = FALSE,
    IntervalCoverageComputed = FALSE,
    MonteCarloAcceptanceEvaluated = FALSE,
    IndependentReferenceValidationComputed = FALSE,
    FailureDenominatorPreserved = TRUE,
    RerunPerformed = FALSE,
    FailureExcluded = FALSE,
    RouteVotingApplied = FALSE,
    ConfirmationAuthorized = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    CurrentDisposition =
      "bounded_exploratory_descriptive_recovery_complete_nonconfirmatory",
    NextAction = paste(
      "review profile-level descriptive error and preserved failures;",
      "only if a confirmation study is scientifically warranted freeze a",
      "separate outcome-independent D-SIM-4 contract"
    )
  )
  payload <- list(
    Contract = contract,
    EvidenceFileRegistry = loaded$EvidenceFileRegistry,
    ParentLaunchInputHash = contract$ParentLaunchInputHash,
    ParentLaunchManifestHash = contract$ParentLaunchManifestHash,
    ParentCompletionHash = contract$ParentCompletionHash,
    ParentPlanHash = contract$ParentPlanHash,
    ParentCoverageManifestHash = contract$ParentCoverageManifestHash,
    ParentTruthMetricManifestHash = contract$ParentTruthMetricManifestHash,
    RequestOutcomeRegistry = outcomes,
    CoordinateAdjudicationRegistry = coordinates,
    DirectTruthScalarRegistry = direct,
    EstimandRecoverySummaryRegistry = estimand,
    ProfileRecoverySummaryRegistry = profile,
    ScenarioRoleRecoverySummaryRegistry = scenario_role,
    DiagnosticRecoverySummaryRegistry = diagnostic,
    WithinBackendParityScalarRegistry = parity,
    WithinBackendParitySummaryRegistry = parity_summary,
    ResourceSummaryRegistry = resource,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3ad_hash(payload)
  )), class = c("mfrmr_gtds3ad_manifest", "list"))
  mfrmr_gtds3ad_assert_manifest(manifest)
  manifest
}

mfrmr_gtds3ad_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds3ad_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3ad_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 descriptive-recovery manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  files <- manifest$EvidenceFileRegistry
  outcomes <- manifest$RequestOutcomeRegistry
  coordinates <- manifest$CoordinateAdjudicationRegistry
  direct <- manifest$DirectTruthScalarRegistry
  estimand <- manifest$EstimandRecoverySummaryRegistry
  profile <- manifest$ProfileRecoverySummaryRegistry
  scenario_role <- manifest$ScenarioRoleRecoverySummaryRegistry
  diagnostic <- manifest$DiagnosticRecoverySummaryRegistry
  parity <- manifest$WithinBackendParityScalarRegistry
  parity_summary <- manifest$WithinBackendParitySummaryRegistry
  resource <- manifest$ResourceSummaryRegistry
  summary <- manifest$Summary
  disposition_counts <- table(factor(
    coordinates$DescriptiveDisposition,
    levels = c(
      "direct_truth_compared", "direct_truth_metric_failure",
      "scenario_reference_parity_only", "frozen_no_call_preserved"
    )
  ))
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3ad_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds3ad_contract()) &&
    identical(manifest$ParentLaunchInputHash,
              contract$ParentLaunchInputHash) &&
    identical(manifest$ParentLaunchManifestHash,
              contract$ParentLaunchManifestHash) &&
    identical(manifest$ParentCompletionHash,
              contract$ParentCompletionHash) &&
    identical(manifest$ParentPlanHash, contract$ParentPlanHash) &&
    identical(manifest$ParentCoverageManifestHash,
              contract$ParentCoverageManifestHash) &&
    identical(manifest$ParentTruthMetricManifestHash,
              contract$ParentTruthMetricManifestHash) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds3ad_implementation_identity()) &&
    identical(nrow(files), 3L) && all(files$ExactIdentityMatch) &&
    identical(nrow(outcomes), 8L) &&
    all(outcomes$DenominatorPreserved) &&
    all(!outcomes$FailureExcluded) &&
    identical(nrow(coordinates), 420L) &&
    all(coordinates$CountsInCoordinateDenominator) &&
    identical(unname(as.integer(disposition_counts)),
              c(82L, 2L, 16L, 320L)) &&
    identical(nrow(direct), 188L) &&
    !anyDuplicated(direct$ComparisonId) &&
    identical(length(unique(direct$RouteUnitId)), 42L) &&
    identical(length(unique(direct$MetricRequestId)), 84L) &&
    identical(sum(direct$ComparisonAvailable), 184L) &&
    all(direct$DirectTruthQualified) &&
    all(direct$CountsInPlannedDenominator) &&
    all(!direct$FailureExcluded) &&
    all(!direct$AcceptanceThresholdApplied) &&
    identical(nrow(estimand), 2L) &&
    identical(estimand$PlannedScalarCount, c(94L, 94L)) &&
    identical(estimand$AvailableScalarCount, c(92L, 92L)) &&
    identical(nrow(profile), 42L) &&
    identical(nrow(scenario_role), 8L) &&
    identical(length(unique(scenario_role$ScenarioRole)), 4L) &&
    all(!scenario_role$AcceptanceThresholdApplied) &&
    identical(nrow(diagnostic), 4L) &&
    all(!diagnostic$ExcludedFromOverallSummary) &&
    identical(nrow(parity), 40L) &&
    !anyDuplicated(parity$ParityId) &&
    all(parity$ComparisonAvailable) &&
    all(!parity$IndependentReference) &&
    all(!parity$AcceptanceThresholdApplied) &&
    identical(nrow(parity_summary), 2L) &&
    all(!parity_summary$IndependentReference) &&
    identical(nrow(resource), 1L) &&
    !isTRUE(resource$PostOutcomeResourceExclusionApplied[[1L]]) &&
    identical(summary$DatasetAttemptCount, 42L) &&
    identical(summary$CandidateRouteCount, 50L) &&
    identical(summary$CompleteCandidateRouteCount, 49L) &&
    identical(summary$FailedCandidateRouteCount, 1L) &&
    identical(summary$MetricRequestCount, 100L) &&
    identical(summary$ComputedMetricRequestCount, 98L) &&
    identical(summary$TerminalReceiptCount, 92L) &&
    identical(summary$DirectTruthScalarCount, 188L) &&
    identical(summary$AvailableDirectTruthScalarCount, 184L) &&
    identical(summary$UnavailableDirectTruthScalarCount, 4L) &&
    identical(summary$ParityScalarCount, 40L) &&
    identical(summary$AvailableParityScalarCount, 40L) &&
    isTRUE(summary$DescriptiveRecoveryComputed) &&
    !isTRUE(summary$StandardizedBiasComputed) &&
    !isTRUE(summary$IntervalCoverageComputed) &&
    !isTRUE(summary$MonteCarloAcceptanceEvaluated) &&
    !isTRUE(summary$IndependentReferenceValidationComputed) &&
    isTRUE(summary$FailureDenominatorPreserved) &&
    !isTRUE(summary$RerunPerformed) && !isTRUE(summary$FailureExcluded) &&
    !isTRUE(summary$RouteVotingApplied) &&
    !isTRUE(summary$ConfirmationAuthorized) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$PublicSupportReady) &&
    identical(summary$FeatureMaturity, "specified") &&
    identical(
      summary$CurrentDisposition,
      "bounded_exploratory_descriptive_recovery_complete_nonconfirmatory"
    )
  if (!valid) {
    stop("The D-SIM-3 descriptive-recovery manifest was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
