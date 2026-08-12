# Repository-only audit of external MML algorithms, coordinate correlations,
# and log-domain stability for mfrmr 0.2.3.
#
# Source the candidate-003 numerical-review stack, the additive mfrmr
# reference preflight, and the TAM MML calibration before this file. The audit
# reuses their bound observations; it does not launch ConQuest, freeze a new
# comparison tolerance, or promote a calibration result to release evidence.

mfrmr_emaca_specification <-
  "0.2.3-external-mml-algorithm-correlation-audit-v1"
mfrmr_emaca_contract <- "mfrmr_external_mml_algorithm_correlation_audit_v1"
mfrmr_emaca_expected_tam_algorithm_hashes <- c(
  "tam.mml.mfr" =
    "93631641ee114fe0e46ae47b8a1c4788d394ec4e1ca74cfef2b5db4efdce07ca",
  tam_mml_calc_prob =
    "d7b27595814bb00b825f68d3531533dbd170372dd0fba7ffe73978a9ecf99129",
  tam_mml_mstep_regression =
    "136055dcbb031e53855b473c4c32fd89b2e7e31dfdbf5ba9c44a1a2549383960",
  tam_mml_mstep_intercept =
    "360258694fed48ee7d310729953bbfe2eeb1a21ee62b37697a2bfd85445bfb26",
  tam_mml_mstep_xsi =
    "f655eef576ca68624dc2f6b4cedc01aeed3272f9e45ab98c868a086fccf77ab8",
  tam_mml_compute_deviance =
    "bb75ec07c014cb3f65e6086a46a34cf7d192f38a1940286c7ce797671109040b",
  tam_acceleration_inits =
    "5c83c02cf11c6636eed22fc7f5f336a5a3fc1d11b9f1afb624e037d3ec5506ea"
)

mfrmr_emaca_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_emaca_require <- function() {
  required_functions <- c(
    "mfrmr_cq_c3nr_coordinate_rows",
    "mfrmr_run_tam_mml_core_calibration"
  )
  scope <- environment(mfrmr_emaca_require)
  present <- vapply(
    required_functions, exists, logical(1L), envir = scope,
    mode = "function", inherits = TRUE
  )
  mfrmr_emaca_assert(
    all(present),
    paste0(
      "Source the candidate-003 numerical review and TAM MML calibration ",
      "before this audit."
    )
  )
  for (package in c("mfrmr", "TAM", "immer", "digest")) {
    mfrmr_emaca_assert(
      requireNamespace(package, quietly = TRUE),
      paste0("The external MML audit requires `", package, "`.")
    )
  }
  invisible(TRUE)
}

mfrmr_emaca_tam_algorithm_identity <- function() {
  namespace <- asNamespace("TAM")
  names_expected <- names(mfrmr_emaca_expected_tam_algorithm_hashes)
  observed <- vapply(names_expected, function(name) {
    fun <- get(name, envir = namespace, inherits = FALSE)
    digest::digest(
      list(formals = formals(fun), body = body(fun)),
      algo = "sha256", serialize = TRUE
    )
  }, character(1L))
  data.frame(
    Package = "TAM",
    Version = as.character(utils::packageVersion("TAM")),
    Function = names_expected,
    SHA256 = unname(observed),
    ExpectedSHA256 = unname(mfrmr_emaca_expected_tam_algorithm_hashes),
    IdentityMatch = unname(observed) ==
      unname(mfrmr_emaca_expected_tam_algorithm_hashes),
    stringsAsFactors = FALSE
  )
}

mfrmr_emaca_metric_row <- function(external, mfrmr, comparison,
                                    family, nodes) {
  external <- as.numeric(external)
  mfrmr <- as.numeric(mfrmr)
  mfrmr_emaca_assert(
    length(external) == length(mfrmr) && length(external) >= 2L &&
      all(is.finite(external)) && all(is.finite(mfrmr)),
    "A correlation metric received incomplete or non-finite coordinates."
  )
  affine <- stats::lm(external ~ mfrmr)
  correlation <- stats::cor(external, mfrmr, method = "pearson")
  difference <- external - mfrmr
  data.frame(
    Comparison = comparison,
    Family = family,
    Nodes = as.integer(nodes),
    CoordinateRows = length(external),
    PearsonCorrelation = correlation,
    PearsonDistanceFromOne = 1 - correlation,
    RMSE = sqrt(mean(difference^2)),
    MaximumAbsoluteDifference = max(abs(difference)),
    AffineIntercept = unname(stats::coef(affine)[1L]),
    AffineSlope = unname(stats::coef(affine)[2L]),
    EvidenceRole = "descriptive_not_acceptance",
    stringsAsFactors = FALSE
  )
}

mfrmr_emaca_group_metrics <- function(rows, external_column, mfrmr_column,
                                       comparison) {
  groups <- split(
    seq_len(nrow(rows)), paste(rows$Family, rows$Nodes, sep = "\r")
  )
  out <- lapply(groups, function(index) {
    part <- rows[index, , drop = FALSE]
    mfrmr_emaca_metric_row(
      part[[external_column]], part[[mfrmr_column]], comparison,
      part$Family[1L], part$Nodes[1L]
    )
  })
  out[[length(out) + 1L]] <- mfrmr_emaca_metric_row(
    rows[[external_column]], rows[[mfrmr_column]], comparison,
    "ALL", NA_integer_
  )
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result
}

mfrmr_emaca_tam_coordinate_name <- function(facet, level) {
  facet <- as.character(facet)
  level <- as.character(level)
  population <- c(
    Intercept = "population_intercept",
    X = "population_slope",
    Variance = "population_variance"
  )
  out <- level
  is_population <- facet == "Population"
  out[is_population] <- unname(population[level[is_population]])
  mfrmr_emaca_assert(
    !anyNA(out), "The TAM-to-common coordinate map is incomplete."
  )
  out
}

mfrmr_emaca_coordinate_audit <- function(conquest_rows, tam_result) {
  conquest_parameters <- conquest_rows[
    conquest_rows$ParameterClass != "objective", , drop = FALSE
  ]
  mfrmr_emaca_assert(
    nrow(conquest_parameters) == 48L,
    "The ConQuest parameter-only ledger must contain 48 rows."
  )
  conquest_metrics <- mfrmr_emaca_group_metrics(
    conquest_parameters, "NativeValue", "MfrmrReferenceValue",
    "ConQuest_exact_reported_decimal_vs_mfrmr"
  )

  tam_free <- tam_result$coordinates[
    tam_result$coordinates$ConstraintRole == "free", , drop = FALSE
  ]
  mfrmr_emaca_assert(
    nrow(tam_free) == 32L,
    "The TAM calibration must contain 32 independent free-coordinate rows."
  )
  names(tam_free)[names(tam_free) == "Model"] <- "Family"
  tam_metrics <- mfrmr_emaca_group_metrics(
    tam_free, "TAMEstimate", "MfrmrEstimate", "TAM_vs_mfrmr"
  )

  tam_free$Coordinate <- mfrmr_emaca_tam_coordinate_name(
    tam_free$Facet, tam_free$Level
  )
  conquest_common <- conquest_parameters[
    conquest_parameters$Family %in% c("RSM", "PCM"), , drop = FALSE
  ]
  conquest_key <- paste(
    conquest_common$Family, conquest_common$Nodes,
    conquest_common$Coordinate, sep = "\r"
  )
  tam_key <- paste(
    tam_free$Family, tam_free$Nodes, tam_free$Coordinate, sep = "\r"
  )
  index <- match(conquest_key, tam_key)
  mfrmr_emaca_assert(
    nrow(conquest_common) == 32L && !anyNA(index) &&
      !anyDuplicated(conquest_key) && !anyDuplicated(tam_key),
    "The ConQuest/TAM free-coordinate map is not one-to-one."
  )
  conquest_tam <- data.frame(
    Family = conquest_common$Family,
    Nodes = conquest_common$Nodes,
    Coordinate = conquest_common$Coordinate,
    ConQuestValue = conquest_common$NativeValue,
    TAMValue = tam_free$TAMEstimate[index],
    MfrmrValue = conquest_common$MfrmrReferenceValue,
    stringsAsFactors = FALSE
  )
  conquest_tam_metrics <- mfrmr_emaca_group_metrics(
    conquest_tam, "ConQuestValue", "TAMValue",
    "ConQuest_exact_reported_decimal_vs_TAM"
  )

  list(
    metrics = rbind(conquest_metrics, tam_metrics, conquest_tam_metrics),
    conquest_parameters = conquest_parameters,
    tam_free_coordinates = tam_free,
    conquest_tam_coordinates = conquest_tam
  )
}

mfrmr_emaca_objective_audit <- function(conquest_rows, tam_result) {
  conquest <- conquest_rows[
    conquest_rows$ParameterClass == "objective", , drop = FALSE
  ]
  conquest_mfrmr <- data.frame(
    Comparison = "ConQuest_exact_reported_decimal_vs_mfrmr",
    Family = conquest$Family,
    Nodes = conquest$Nodes,
    ExternalDeviance = conquest$NativeValue,
    MfrmrDeviance = conquest$MfrmrReferenceValue,
    SignedDifference = conquest$NativeValue - conquest$MfrmrReferenceValue,
    SourcePrecision = "exact_reported_decimal",
    stringsAsFactors = FALSE
  )
  tam_mfrmr <- data.frame(
    Comparison = "TAM_vs_mfrmr",
    Family = tam_result$summaries$Model,
    Nodes = tam_result$summaries$Nodes,
    ExternalDeviance = tam_result$summaries$TAMDeviance,
    MfrmrDeviance = tam_result$summaries$MfrmrDeviance,
    SignedDifference = tam_result$summaries$DevianceSignedDifference,
    SourcePrecision = "binary64_runtime",
    stringsAsFactors = FALSE
  )
  key_conquest <- paste(conquest$Family, conquest$Nodes, sep = "\r")
  key_tam <- paste(
    tam_result$summaries$Model, tam_result$summaries$Nodes, sep = "\r"
  )
  common <- conquest$Family %in% c("RSM", "PCM")
  index <- match(key_conquest[common], key_tam)
  mfrmr_emaca_assert(!anyNA(index), "The objective map is incomplete.")
  conquest_tam <- data.frame(
    Comparison = "ConQuest_exact_reported_decimal_vs_TAM",
    Family = conquest$Family[common],
    Nodes = conquest$Nodes[common],
    ExternalDeviance = conquest$NativeValue[common],
    MfrmrDeviance = tam_result$summaries$TAMDeviance[index],
    SignedDifference =
      conquest$NativeValue[common] - tam_result$summaries$TAMDeviance[index],
    SourcePrecision = "mixed_exact_decimal_and_binary64",
    stringsAsFactors = FALSE
  )
  out <- rbind(conquest_mfrmr, tam_mfrmr, conquest_tam)
  out$EvidenceRole <- "objective_check_not_correlation"
  rownames(out) <- NULL
  out
}

mfrmr_emaca_algorithm_ledger <- function() {
  data.frame(
    EngineRoute = c(
      "ConQuest method=quadrature", "TAM tam.mml.mfr",
      "TAM tam.mml.2pl GPCM", "mfrmr MML direct",
      "immer CML", "immer CCML", "immer JML"
    ),
    Version = c(
      "5.47.5 Demonstration", rep(as.character(utils::packageVersion("TAM")), 2L),
      as.character(utils::packageVersion("mfrmr")),
      rep(as.character(utils::packageVersion("immer")), 3L)
    ),
    Objective = c(
      "full marginal likelihood", "full marginal likelihood",
      "full marginal likelihood", "full marginal likelihood",
      "person-score conditional likelihood",
      "pairwise composite conditional likelihood", "joint likelihood"
    ),
    Integration = c(
      "fixed theta grid; candidate uses q=31/61 over documented default range",
      "fixed theta grid set to seq(-6,6,length=q)",
      "fixed or stochastic nodes under TAM controls",
      "transformed standard-normal Gauss-Hermite q=31/61",
      "conditioning; no latent-distribution quadrature",
      "pair-score conditioning; no latent-distribution quadrature",
      "none"
    ),
    Optimization = c(
      "EM; Newton-Raphson item M-step and population updates",
      "EM with controlled inner M-steps",
      "EM-family TAM implementation with slope updates",
      "analytic-gradient L-BFGS-B by default; BFGS fallback/polish",
      "conditional-likelihood optimization",
      "composite-conditional optimization",
      "joint sufficient-statistic updates with declared correction mode"
    ),
    MatchedCurrentMfrmrEstimand = c(
      "yes for the bound Binary/RSM/PCM core",
      "yes for the bound fixed-slope RSM/PCM calibration",
      "item-only free-slope neighbour; not faceted tam.mml.mfr",
      "self",
      "structural Rasch contrasts only",
      "structural Rasch contrasts only",
      "mode-specific PCM structural surface only"
    ),
    AlgorithmIdentityToConQuest = c(
      "self", "broad EM/MML family only; exact identity not established",
      "not established", "no: independent direct optimizer and quadrature rule",
      "no: different objective", "no: different composite objective",
      "no: different objective"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_emaca_log_domain_stress <- function(probability = 0.01,
                                           observations = 200L) {
  probability <- as.numeric(probability)[1L]
  observations <- as.integer(observations)[1L]
  mfrmr_emaca_assert(
    is.finite(probability) && probability > 0 && probability < 1 &&
      observations > 0L,
    "The log-domain stress case is invalid."
  )
  person_bundle <- get(
    "mfrm_mml_person_bundle", envir = asNamespace("mfrmr"), inherits = FALSE
  )
  naive <- log(probability^observations)
  analytic <- observations * log(probability)
  evaluated <- person_bundle(
    log_prob_mat = matrix(rep(log(probability), observations), ncol = 1L),
    person_int = rep(1L, observations),
    quad_basis = list(log_weights = matrix(0, nrow = 1L, ncol = 1L)),
    include_posterior = TRUE
  )
  source <- paste(deparse(body(person_bundle)), collapse = "\n")
  data.frame(
    Probability = probability,
    Observations = observations,
    NaiveLogProduct = naive,
    AnalyticSumOfLogs = analytic,
    MfrmrPersonLogMarginal = as.numeric(evaluated$log_marginal),
    MfrmrMinusAnalytic = as.numeric(evaluated$log_marginal) - analytic,
    NaiveFinite = is.finite(naive),
    MfrmrFinite = is.finite(evaluated$log_marginal),
    PersonAggregatorUsesLogProbabilitySum =
      grepl("rowsum(log_prob_mat", source, fixed = TRUE),
    PersonIntegratorUsesShiftedLogSumExp =
      grepl("rowSums(exp(log_joint - row_max))", source, fixed = TRUE),
    PersonAggregatorContainsProduct = grepl("prod(", source, fixed = TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_emaca_source_stability <- function(source_root) {
  source_root <- normalizePath(
    as.character(source_root)[1L], winslash = "/", mustWork = TRUE
  )
  paths <- file.path(source_root, c(
    "R/mfrm_core.R", "R/core-category-probabilities.R", "src/mml_backend.cpp"
  ))
  mfrmr_emaca_assert(all(file.exists(paths)), "Likelihood sources are missing.")
  text <- lapply(paths, readLines, warn = FALSE)
  names(text) <- basename(paths)
  combined <- paste(unlist(text, use.names = FALSE), collapse = "\n")
  data.frame(
    RCategoryKernelUsesShiftedLogSumExp = grepl(
      "rowSums(exp(log_num - row_max))", combined, fixed = TRUE
    ),
    RPersonKernelUsesLogProbabilityRowsum = grepl(
      "rowsum(log_prob_mat, person_int", combined, fixed = TRUE
    ),
    RPersonKernelUsesShiftedLogSumExp = grepl(
      "rowSums(exp(log_joint - row_max))", combined, fixed = TRUE
    ),
    CppCategoryKernelUsesShiftedExponentials = grepl(
      "std::exp(log_num[static_cast<size_t>(k)] - row_max)",
      combined, fixed = TRUE
    ),
    NaiveLogOfProductPatternFound = grepl(
      "log[[:space:]]*\\([[:space:]]*prod[[:space:]]*\\(",
      combined, perl = TRUE
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_run_external_mml_algorithm_correlation_audit <- function(
    source_root = ".", candidate_root) {
  mfrmr_emaca_require()
  source_root <- normalizePath(
    as.character(source_root)[1L], winslash = "/", mustWork = TRUE
  )
  candidate_root <- normalizePath(
    as.character(candidate_root)[1L], winslash = "/", mustWork = TRUE
  )
  conquest_rows <- mfrmr_cq_c3nr_coordinate_rows(candidate_root)$rows
  tam_result <- mfrmr_run_tam_mml_core_calibration(source_root)
  coordinates <- mfrmr_emaca_coordinate_audit(conquest_rows, tam_result)
  objectives <- mfrmr_emaca_objective_audit(conquest_rows, tam_result)
  stress <- mfrmr_emaca_log_domain_stress()
  stability <- mfrmr_emaca_source_stability(source_root)
  tam_algorithm_identity <- mfrmr_emaca_tam_algorithm_identity()
  complete <- nrow(coordinates$metrics) == 17L &&
    nrow(objectives) == 14L &&
    all(is.finite(coordinates$metrics$PearsonCorrelation)) &&
    is.finite(stress$MfrmrPersonLogMarginal) && !stress$NaiveFinite &&
    abs(stress$MfrmrMinusAnalytic) <= 1e-10 &&
    stress$PersonAggregatorUsesLogProbabilitySum &&
    stress$PersonIntegratorUsesShiftedLogSumExp &&
    !stress$PersonAggregatorContainsProduct &&
    all(unlist(stability[1L, c(
      "RCategoryKernelUsesShiftedLogSumExp",
      "RPersonKernelUsesLogProbabilityRowsum",
      "RPersonKernelUsesShiftedLogSumExp",
      "CppCategoryKernelUsesShiftedExponentials"
    )])) && !stability$NaiveLogOfProductPatternFound &&
    nrow(tam_algorithm_identity) == 7L &&
    all(tam_algorithm_identity$IdentityMatch)
  list(
    specification = mfrmr_emaca_specification,
    contract_version = mfrmr_emaca_contract,
    status = if (complete) {
      "external_mml_algorithm_correlation_and_log_domain_audit_complete"
    } else {
      "external_mml_algorithm_correlation_and_log_domain_audit_incomplete"
    },
    algorithm_ledger = mfrmr_emaca_algorithm_ledger(),
    tam_algorithm_identity = tam_algorithm_identity,
    correlation_metrics = coordinates$metrics,
    objective_audit = objectives,
    log_domain_stress = stress,
    source_stability = stability,
    audit_complete = complete,
    same_algorithm_required = FALSE,
    same_objective_and_coordinate_map_required = TRUE,
    correlation_is_acceptance_rule = FALSE,
    numerical_difference_is_floating_point_only = FALSE,
    integration_approximation_difference_present = TRUE,
    dff_fit_person_rater_rank_invariance_evaluated = FALSE,
    scientific_equivalence_inferred = FALSE,
    release_authorized = FALSE
  )
}
