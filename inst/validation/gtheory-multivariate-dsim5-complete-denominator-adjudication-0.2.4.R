# Internal blind D-SIM-5 complete-denominator assembly and adjudication.
#
# The executable interpretations below were fixed before opening any D-SIM-5
# scientific value.  Assembly streams immutable checkpoints and preserves every
# planned scalar position; adjudication never replenishes a failed attempt.

mfrmr_gtds5d_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The D-SIM-5 adjudicator requires `digest`.", call. = FALSE)
  }
  digest::digest(
    value, algo = "sha256", serialize = TRUE, serializeVersion = 3L
  )
}

mfrmr_gtds5d_contract <- function() {
  payload <- list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM5-ADJUDICATION-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-09-06",
    ParentFreezeManifestHash =
      "8e8b4b3d4f28a1ac9c94a42fbbdb193aa4979c57bf8a6f2d1a5ecb24ee4d713e",
    ParentLaunchInputHash =
      "e93d5de438a99d89f89d51f24c9dcd58393dc52127b90926133c7e50a0c91071",
    ParentAdmissionManifestHash =
      "8f13db52ad19cbe5adcda0aabb6be6ec8ff949cb555d6043ea1dba0e74972510",
    ParentExecutorContractHash =
      "a64facef158aaf7f4e4463512af9b7367195f708d45183e2cd3d5d63ec9bf6f3",
    ParentTruthSourceManifestHash =
      "ad97f0f48f382bd41c6353dab6ce1405453b6146ce3fd4dfbb4ea04406fb8f8f",
    ExpectedShardCount = 50L,
    ExpectedOuterAttemptCount = 15000L,
    ExpectedPointScalarCount = 65000L,
    ExpectedIntervalScalarCount = 20000L,
    ExpectedInnerAttemptCount = 995000L,
    EvaluationUnit =
      "confirmation_scenario_by_stratum_by_estimand",
    Estimands = c("ABS-PHI", "REL-G"),
    CrossCellPoolingAllowed = FALSE,
    StandardizedBiasDefinition =
      "mean(estimate_minus_truth)/empirical_sd_of_estimates",
    StandardizedBiasMcseDefinition =
      "sd(estimate)/sqrt(N)/empirical_sd_of_estimates",
    BiasLimit = 0.05,
    BiasMcseMultiplier = 2,
    BiasRequiresCompletePlannedCell = TRUE,
    CoverageNominal = 0.95,
    CoverageLimit = 0.03,
    CoverageMcseMultiplier = 2,
    CoverageMcseDefinition = "sqrt(p_hat*(1-p_hat)/planned_N)",
    UnavailableIntervalRule =
      "lower_treats_unavailable_as_noncoverage_upper_as_coverage",
    CoveragePassRule =
      "both_worst_case_bounds_within_limit_plus_two_bound_specific_MCSE",
    BoundaryOrControlBiasApplied = FALSE,
    ReplacementOrReplenishmentAllowed = FALSE,
    ScientificValueMaySelectDefinitionOrThreshold = FALSE,
    Dsim5PassAutomaticallyPromotesPublicSupport = FALSE
  )
  structure(c(payload, list(
    ContractHash = mfrmr_gtds5d_hash(payload)
  )), class = c("mfrmr_gtds5d_contract", "list"))
}

mfrmr_gtds5d_require <- function() {
  required <- c(
    "mfrmr_gtds4_assert_manifest", "mfrmr_gtds3ad_assert_manifest",
    "mfrmr_gtds5i_assert_launch_input", "mfrmr_gtds5a_assert_manifest",
    "mfrmr_gtds5e_job", "mfrmr_gtds5e_assert_job",
    "mfrmr_gtds5e_assert_result", "mfrmr_gtds5e_assert_shard_receipt"
  )
  target <- environment(mfrmr_gtds5d_require)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing)) {
    stop("Source the D-SIM-3/4/5 contracts first: ",
         paste(missing, collapse = ", "), ".", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds5d_assert_identity <- function(expected, observed) {
  expected_fields <- c("AttemptId", "OuterRequestHash", "InnerBlockHash")
  observed_fields <- c(expected_fields, "ResultHash", "TerminalStateCount")
  valid_schema <- is.data.frame(expected) && is.data.frame(observed) &&
    all(expected_fields %in% names(expected)) &&
    all(observed_fields %in% names(observed))
  if (!valid_schema || nrow(expected) != nrow(observed) ||
      anyDuplicated(expected$AttemptId) || anyDuplicated(observed$AttemptId) ||
      !setequal(expected$AttemptId, observed$AttemptId)) {
    stop("The D-SIM-5 result set is missing, duplicated, or foreign.",
         call. = FALSE)
  }
  observed <- observed[match(expected$AttemptId, observed$AttemptId), ]
  valid <- all(vapply(
    expected_fields,
    function(field) identical(expected[[field]], observed[[field]]),
    logical(1L)
  )) && all(observed$TerminalStateCount == 1L) &&
    all(grepl("^[0-9a-f]{64}$", observed$ResultHash))
  if (!valid) {
    stop("The D-SIM-5 result identity was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds5d_truth <- function(truth_manifest, freeze) {
  mfrmr_gtds3ad_assert_manifest(truth_manifest)
  direct <- truth_manifest$DirectTruthScalarRegistry
  truth <- unique(direct[c(
    "ScenarioId", "StratumOrdinal", "Stratum", "EstimandId", "Truth"
  )])
  truth <- truth[truth$ScenarioId %in% freeze$ScenarioRegistry$ScenarioId, ]
  truth <- truth[order(
    match(truth$ScenarioId, freeze$ScenarioRegistry$ScenarioId),
    truth$StratumOrdinal, match(truth$EstimandId, c("ABS-PHI", "REL-G"))
  ), ]
  row.names(truth) <- NULL
  if (nrow(truth) != 26L ||
      anyDuplicated(truth[c("ScenarioId", "Stratum", "EstimandId")]) ||
      any(!is.finite(truth$Truth))) {
    stop("The D-SIM-5 truth join is incomplete or ambiguous.",
         call. = FALSE)
  }
  truth
}

mfrmr_gtds5d_extract_result <- function(result, job, assignment, truth) {
  mfrmr_gtds5e_assert_result(result, job)
  coefficient <- result$PrimaryCoefficientRegistry
  point <- truth[truth$ScenarioId == result$ParentScenarioId, ]
  coefficient_fields <- c(
    "ScenarioId", "Stratum", "G", "Phi", "CoefficientReady",
    "PhiNotGreaterThanG", "ReferenceMaximumError", "AttemptId",
    "ConfirmationScenarioId", "Replicate", "OuterRequestHash"
  )
  if (nrow(coefficient) &&
      (!all(coefficient_fields %in% names(coefficient)) ||
       anyDuplicated(coefficient$Stratum) ||
       !all(coefficient$Stratum %in% point$Stratum) ||
       any(coefficient$ScenarioId != result$ConfirmationScenarioId) ||
       any(coefficient$AttemptId != result$AttemptId) ||
       any(coefficient$ConfirmationScenarioId !=
             result$ConfirmationScenarioId) ||
       any(coefficient$Replicate != result$Replicate) ||
       any(coefficient$OuterRequestHash != result$OuterRequestHash))) {
    stop("A D-SIM-5 primary coefficient registry is malformed.",
         call. = FALSE)
  }
  coefficient_index <- match(point$Stratum, coefficient$Stratum)
  point$AttemptId <- result$AttemptId
  point$ConfirmationScenarioId <- result$ConfirmationScenarioId
  point$Replicate <- result$Replicate
  point$Estimate <- point$ReferenceMaximumError <- NA_real_
  point$EstimateAvailable <- point$PhiNotGreaterThanG <- FALSE
  matched <- which(!is.na(coefficient_index))
  if (length(matched)) {
    index <- coefficient_index[matched]
    point$Estimate[matched] <- ifelse(
      point$EstimandId[matched] == "ABS-PHI",
      coefficient$Phi[index], coefficient$G[index]
    )
    point$EstimateAvailable[matched] <-
      is.finite(point$Estimate[matched]) & coefficient$CoefficientReady[index]
    point$PhiNotGreaterThanG[matched] <-
      coefficient$PhiNotGreaterThanG[index]
    point$ReferenceMaximumError[matched] <-
      coefficient$ReferenceMaximumError[index]
  }
  point$TerminalState <- result$TerminalState

  interval <- point[FALSE, c(
    "ScenarioId", "StratumOrdinal", "Stratum", "EstimandId", "Truth",
    "AttemptId", "ConfirmationScenarioId", "Replicate"
  )]
  interval$IntervalAvailable <- logical()
  interval$Lower <- interval$Upper <- numeric()
  if (isTRUE(assignment$IntervalEligible[[1L]])) {
    observed <- result$IntervalRegistry
    fields <- c(
      "Stratum", "EstimandId", "PlannedBootstrapReplicateCount",
      "IntervalAvailable", "Lower", "Upper", "QuantileType"
    )
    keys <- paste(point$Stratum, point$EstimandId, sep = "\036")
    observed_keys <- if (all(fields %in% names(observed))) {
      paste(observed$Stratum, observed$EstimandId, sep = "\036")
    } else character()
    valid_bounds <- all(fields %in% names(observed)) &&
      !anyNA(observed$IntervalAvailable) &&
      all(observed$PlannedBootstrapReplicateCount == 199L) &&
      all(observed$QuantileType == 7L) &&
      all(!observed$IntervalAvailable |
            (is.finite(observed$Lower) & is.finite(observed$Upper) &
               observed$Lower <= observed$Upper)) &&
      all(observed$IntervalAvailable |
            (is.na(observed$Lower) & is.na(observed$Upper)))
    if (!valid_bounds || nrow(observed) != nrow(point) ||
        anyDuplicated(observed_keys) || !setequal(keys, observed_keys)) {
      stop("A D-SIM-5 interval registry is malformed.", call. = FALSE)
    }
    observed <- observed[match(keys, observed_keys), ]
    interval <- point[c(
      "ScenarioId", "StratumOrdinal", "Stratum", "EstimandId", "Truth",
      "AttemptId", "ConfirmationScenarioId", "Replicate"
    )]
    interval$IntervalAvailable <- observed$IntervalAvailable &
      is.finite(observed$Lower) & is.finite(observed$Upper)
    interval$Lower <- observed$Lower
    interval$Upper <- observed$Upper
  } else if (nrow(result$IntervalRegistry)) {
    stop("A point-only D-SIM-5 attempt contains intervals.", call. = FALSE)
  }
  attempt <- data.frame(
    AttemptId = result$AttemptId,
    OuterRequestHash = result$OuterRequestHash,
    InnerBlockHash = result$InnerBlockHash,
    ResultHash = result$ResultHash,
    TerminalStateCount = result$TerminalStateCount,
    ConfirmationScenarioId = result$ConfirmationScenarioId,
    ParentScenarioId = result$ParentScenarioId,
    Replicate = result$Replicate,
    IntervalEligible = assignment$IntervalEligible[[1L]],
    InnerAttemptCount = nrow(result$InnerReceiptRegistry),
    TerminalState = result$TerminalState,
    ReplacementOrReplenishmentApplied =
      result$ReplacementOrReplenishmentApplied,
    ResultValueUsedForExecutionDecision =
      result$ResultValueUsedForExecutionDecision,
    PublicSupportReady = result$PublicSupportReady,
    stringsAsFactors = FALSE
  )
  list(Attempt = attempt, Point = point, Interval = interval)
}

mfrmr_gtds5d_read_shard <- function(job, receipt, checkpoint_dir, truth) {
  mfrmr_gtds5e_assert_shard_receipt(receipt, job)
  expected <- job$AssignmentRegistry
  paths <- file.path(checkpoint_dir, paste0(expected$AttemptId, ".rds"))
  present <- if (dir.exists(checkpoint_dir)) {
    list.files(checkpoint_dir, pattern = "\\.rds$", full.names = FALSE)
  } else character()
  if (!setequal(basename(paths), present) || length(present) != nrow(expected)) {
    stop("The D-SIM-5 checkpoint directory is partial or foreign.",
         call. = FALSE)
  }
  rows <- lapply(seq_len(nrow(expected)), function(index) {
    mfrmr_gtds5d_extract_result(
      readRDS(paths[[index]]), job, expected[index, , drop = FALSE], truth
    )
  })
  attempts <- do.call(rbind, lapply(rows, `[[`, "Attempt"))
  mfrmr_gtds5d_assert_identity(expected, attempts)
  if (!identical(
    receipt$CompletedRegistry,
    attempts[names(receipt$CompletedRegistry)]
  )) {
    stop("The D-SIM-5 shard receipt and checkpoints differ.",
         call. = FALSE)
  }
  list(
    Attempt = attempts,
    Point = do.call(rbind, lapply(rows, `[[`, "Point")),
    Interval = do.call(rbind, lapply(rows, `[[`, "Interval"))
  )
}

mfrmr_gtds5d_assemble <- function(
    input, admission, freeze, truth_manifest, execution_dir) {
  mfrmr_gtds5d_require()
  contract <- mfrmr_gtds5d_contract()
  mfrmr_gtds5i_assert_launch_input(input)
  mfrmr_gtds5a_assert_manifest(admission, input)
  mfrmr_gtds4_assert_manifest(freeze)
  if (!identical(input$LaunchInputHash, contract$ParentLaunchInputHash) ||
      !identical(admission$ManifestHash,
                 contract$ParentAdmissionManifestHash) ||
      !identical(freeze$ManifestHash, contract$ParentFreezeManifestHash) ||
      !identical(truth_manifest$ManifestHash,
                 contract$ParentTruthSourceManifestHash)) {
    stop("A D-SIM-5 adjudication parent identity changed.", call. = FALSE)
  }
  truth <- mfrmr_gtds5d_truth(truth_manifest, freeze)
  shard_ids <- input$ShardRegistry$ShardId
  rows <- lapply(shard_ids, function(shard_id) {
    expected_job <- mfrmr_gtds5e_job(shard_id, input, admission)
    shard_dir <- file.path(execution_dir, shard_id)
    job <- readRDS(file.path(shard_dir, "job.rds"))
    if (!identical(job, expected_job)) {
      stop("A stored D-SIM-5 job differs from its admitted identity.",
           call. = FALSE)
    }
    mfrmr_gtds5e_assert_job(job, input, admission)
    receipt <- readRDS(file.path(shard_dir, "shard-receipt.rds"))
    mfrmr_gtds5d_read_shard(
      job, receipt, file.path(shard_dir, "outer-checkpoints"), truth
    )
  })
  attempt <- do.call(rbind, lapply(rows, `[[`, "Attempt"))
  point <- do.call(rbind, lapply(rows, `[[`, "Point"))
  interval <- do.call(rbind, lapply(rows, `[[`, "Interval"))
  row.names(attempt) <- row.names(point) <- row.names(interval) <- NULL
  mfrmr_gtds5d_assert_identity(input$AssignmentRegistry, attempt)
  valid <- length(rows) == contract$ExpectedShardCount &&
    nrow(attempt) == contract$ExpectedOuterAttemptCount &&
    nrow(point) == contract$ExpectedPointScalarCount &&
    nrow(interval) == contract$ExpectedIntervalScalarCount &&
    sum(attempt$InnerAttemptCount) == contract$ExpectedInnerAttemptCount &&
    !any(attempt$ReplacementOrReplenishmentApplied) &&
    !any(attempt$ResultValueUsedForExecutionDecision) &&
    !any(attempt$PublicSupportReady)
  if (!valid) {
    stop("The complete D-SIM-5 denominator did not assemble.",
         call. = FALSE)
  }
  payload <- list(
    ContractHash = contract$ContractHash,
    AttemptRegistry = attempt,
    PointRegistry = point,
    IntervalRegistry = interval,
    CompleteDenominator = TRUE,
    ScientificAdjudicationComputed = FALSE,
    PublicSupportReady = FALSE
  )
  structure(c(payload, list(
    AssemblyHash = mfrmr_gtds5d_hash(payload)
  )), class = c("mfrmr_gtds5d_assembly", "list"))
}

mfrmr_gtds5d_bias_row <- function(part, contract = mfrmr_gtds5d_contract()) {
  n <- nrow(part)
  available <- sum(part$EstimateAvailable)
  complete <- n > 1L && available == n
  estimate <- if (complete) mean(part$Estimate) else NA_real_
  empirical_sd <- if (complete) stats::sd(part$Estimate) else NA_real_
  bias <- if (complete) estimate - part$Truth[[1L]] else NA_real_
  standardized <- if (complete && empirical_sd > 0) bias / empirical_sd else
    NA_real_
  raw_mcse <- if (complete) empirical_sd / sqrt(n) else NA_real_
  standardized_mcse <- if (is.finite(standardized))
    raw_mcse / empirical_sd else NA_real_
  limit <- contract$BiasLimit +
    contract$BiasMcseMultiplier * standardized_mcse
  status <- if (!is.finite(standardized)) "indeterminate" else if (
    abs(standardized) <= limit
  ) "pass" else "fail"
  data.frame(
    PlannedCount = n, AvailableCount = available,
    MeanEstimate = estimate, Truth = part$Truth[[1L]], Bias = bias,
    EmpiricalSD = empirical_sd, StandardizedBias = standardized,
    BiasMCSE = raw_mcse, StandardizedBiasMCSE = standardized_mcse,
    AcceptanceLimit = limit, Disposition = status,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds5d_coverage_row <- function(
    part, contract = mfrmr_gtds5d_contract()) {
  n <- nrow(part)
  available <- part$IntervalAvailable
  covered <- available & part$Lower <= part$Truth & part$Truth <= part$Upper
  lower <- sum(covered) / n
  upper <- (sum(covered) + sum(!available)) / n
  lower_mcse <- sqrt(lower * (1 - lower) / n)
  upper_mcse <- sqrt(upper * (1 - upper) / n)
  lower_pass <- abs(lower - contract$CoverageNominal) <=
    contract$CoverageLimit + contract$CoverageMcseMultiplier * lower_mcse
  upper_pass <- abs(upper - contract$CoverageNominal) <=
    contract$CoverageLimit + contract$CoverageMcseMultiplier * upper_mcse
  data.frame(
    PlannedCount = n, AvailableCount = sum(available),
    UnavailableCount = sum(!available), CoveredCount = sum(covered),
    CoverageLower = lower, CoverageUpper = upper,
    CoverageLowerMCSE = lower_mcse, CoverageUpperMCSE = upper_mcse,
    Disposition = if (lower_pass && upper_pass) "pass" else "fail",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds5d_summarize <- function(registry, row_function) {
  key <- interaction(
    registry$ConfirmationScenarioId, registry$Stratum,
    registry$EstimandId, drop = TRUE, lex.order = TRUE
  )
  parts <- split(registry, key)
  rows <- lapply(parts, function(part) cbind(
    part[1L, c(
      "ConfirmationScenarioId", "ScenarioId", "StratumOrdinal", "Stratum",
      "EstimandId"
    )],
    row_function(part)
  ))
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds5d_adjudicate <- function(assembly, freeze) {
  contract <- mfrmr_gtds5d_contract()
  if (!inherits(assembly, "mfrmr_gtds5d_assembly") ||
      !identical(assembly$ContractHash, contract$ContractHash) ||
      !identical(
        assembly$AssemblyHash,
        mfrmr_gtds5d_hash(assembly[names(assembly) != "AssemblyHash"])
      ) || !isTRUE(assembly$CompleteDenominator)) {
    stop("A complete immutable D-SIM-5 assembly is required.",
         call. = FALSE)
  }
  scenarios <- freeze$ScenarioRegistry[c(
    "ConfirmationScenarioId", "RegularInteriorAcceptance",
    "BoundaryOrControlAcceptance"
  )]
  point <- merge(
    assembly$PointRegistry, scenarios,
    by = "ConfirmationScenarioId", sort = FALSE
  )
  interval <- merge(
    assembly$IntervalRegistry, scenarios,
    by = "ConfirmationScenarioId", sort = FALSE
  )
  bias <- mfrmr_gtds5d_summarize(
    point[point$RegularInteriorAcceptance, ], mfrmr_gtds5d_bias_row
  )
  coverage <- mfrmr_gtds5d_summarize(
    interval[interval$RegularInteriorAcceptance, ],
    mfrmr_gtds5d_coverage_row
  )
  boundary <- mfrmr_gtds5d_summarize(
    point[point$BoundaryOrControlAcceptance, ], function(part) data.frame(
      PlannedCount = nrow(part),
      AvailableCount = sum(part$EstimateAvailable),
      UnavailableCount = sum(!part$EstimateAvailable),
      ReferenceTransformPass = all(
        !part$EstimateAvailable |
          (is.finite(part$ReferenceMaximumError) &
             part$ReferenceMaximumError <= 1e-10)
      ),
      PhiNotGreaterThanGPass = all(
        !part$EstimateAvailable | part$PhiNotGreaterThanG %in% TRUE
      ),
      Disposition = if (all(
        !part$EstimateAvailable |
          (is.finite(part$ReferenceMaximumError) &
             part$ReferenceMaximumError <= 1e-10 &
             part$PhiNotGreaterThanG %in% TRUE)
      )) "pass" else "fail",
      stringsAsFactors = FALSE
    )
  )
  estimand <- lapply(contract$Estimands, function(id) {
    dispositions <- c(
      bias$Disposition[bias$EstimandId == id],
      coverage$Disposition[coverage$EstimandId == id],
      boundary$Disposition[boundary$EstimandId == id]
    )
    data.frame(
      EstimandId = id,
      BiasCellCount = sum(bias$EstimandId == id),
      CoverageCellCount = sum(coverage$EstimandId == id),
      BoundaryOrControlCellCount = sum(boundary$EstimandId == id),
      Disposition = if (any(dispositions == "indeterminate")) {
        "indeterminate"
      } else if (all(dispositions == "pass")) "pass" else "fail",
      stringsAsFactors = FALSE
    )
  })
  estimand <- do.call(rbind, estimand)
  attempt_pass <- nrow(assembly$AttemptRegistry) ==
    contract$ExpectedOuterAttemptCount &&
    all(assembly$AttemptRegistry$TerminalStateCount == 1L) &&
    !any(assembly$AttemptRegistry$ReplacementOrReplenishmentApplied) &&
    !any(assembly$AttemptRegistry$ResultValueUsedForExecutionDecision)
  overall <- if (!attempt_pass) "fail" else if (
    any(estimand$Disposition == "indeterminate")
  ) "indeterminate" else if (all(estimand$Disposition == "pass")) {
    "pass"
  } else "fail"
  payload <- list(
    Contract = contract,
    AssemblyHash = assembly$AssemblyHash,
    BiasRegistry = bias,
    CoverageRegistry = coverage,
    BoundaryOrControlRegistry = boundary,
    EstimandDispositionRegistry = estimand,
    AttemptAccountingPassed = attempt_pass,
    OverallDisposition = overall,
    Dsim5ConfirmationPassed = identical(overall, "pass"),
    SimulationValidationReady = FALSE,
    ReferenceValidationReady = FALSE,
    PublicSupportReady = FALSE
  )
  structure(c(payload, list(
    AdjudicationHash = mfrmr_gtds5d_hash(payload)
  )), class = c("mfrmr_gtds5d_adjudication", "list"))
}
