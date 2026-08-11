# mfrmr 0.2.3 source-bound reference preflight for the additive ConQuest case
#
# Source conquest-additive-mfrm-design-0.2.3.R first, load the working tree with
# pkgload::load_all("."), and prepare a fresh design directory. This file fits
# mfrmr only. It never launches ConQuest or authorizes an external comparison.

mfrmr_cq_additive_reference_specification <-
  "0.2.3-wave-c-additive-reference-v1"
mfrmr_cq_additive_reference_contract <-
  "mfrmr_conquest_additive_reference_v1"

mfrmr_cq_additive_reference_requirements <- function() {
  required <- c(
    "mfrmr_cq_additive_assert",
    "mfrmr_cq_additive_fixture",
    "mfrmr_cq_additive_plan",
    "mfrmr_cq_additive_parameter_map",
    "mfrmr_cq_additive_probability",
    "mfrmr_cq_additive_hash_file",
    "mfrmr_validate_conquest_additive_design"
  )
  scope <- environment(mfrmr_cq_additive_reference_requirements)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = scope,
    mode = "function", inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source `conquest-additive-mfrm-design-0.2.3.R` before the reference preflight.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_cq_additive_reference_namespace <- function(source_root = ".") {
  mfrmr_cq_additive_reference_requirements()
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop("Load the mfrmr 0.2.3 working tree before this preflight.", call. = FALSE)
  }
  source_root <- normalizePath(
    as.character(source_root)[1], winslash = "/", mustWork = TRUE
  )
  namespace <- asNamespace("mfrmr")
  namespace_path <- normalizePath(
    getNamespaceInfo(namespace, "path"), winslash = "/", mustWork = TRUE
  )
  required_internal <- c(
    "category_prob_rsm", "category_prob_pcm", "fit_mfrm"
  )
  available <- vapply(
    required_internal, exists, logical(1L), envir = namespace, inherits = FALSE
  )
  mfrmr_cq_additive_assert(
    identical(namespace_path, source_root) && all(available) &&
      identical(as.character(utils::packageVersion("mfrmr")), "0.2.3"),
    paste0(
      "The loaded mfrmr namespace is not the requested 0.2.3 source root; ",
      "use `pkgload::load_all(source_root)`."
    )
  )
  namespace
}

mfrmr_cq_additive_source_manifest <- function(source_root = ".") {
  mfrmr_cq_additive_reference_namespace(source_root)
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The source-bound preflight requires the suggested `digest` package.",
         call. = FALSE)
  }
  source_root <- normalizePath(
    as.character(source_root)[1], winslash = "/", mustWork = TRUE
  )
  relative <- c(
    "DESCRIPTION", "NAMESPACE",
    file.path("R", sort(list.files(
      file.path(source_root, "R"), pattern = "[.]R$", full.names = FALSE
    ))),
    file.path(
      "inst", "validation", "conquest-additive-mfrm-design-0.2.3.R"
    ),
    file.path(
      "inst", "validation",
      "conquest-additive-mfrm-reference-preflight-0.2.3.R"
    )
  )
  path <- file.path(source_root, relative)
  mfrmr_cq_additive_assert(
    all(file.exists(path)), "The source-bound manifest is incomplete."
  )
  hash <- vapply(path, mfrmr_cq_additive_hash_file, character(1L))
  tree_hash <- unname(digest::digest(
    paste(relative, hash, sep = "=", collapse = "\n"),
    algo = "sha256", serialize = FALSE
  ))
  data.frame(
    Specification = mfrmr_cq_additive_reference_specification,
    ContractVersion = mfrmr_cq_additive_reference_contract,
    SourceRoot = source_root,
    RelativePath = relative,
    SHA256 = unname(hash),
    SourceTreeSHA256 = tree_hash,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_additive_gh_normal <- function(nodes) {
  nodes <- suppressWarnings(as.integer(nodes)[1])
  mfrmr_cq_additive_assert(
    is.finite(nodes) && nodes >= 1L, "`nodes` must be one positive integer."
  )
  if (nodes == 1L) return(list(nodes = 0, weights = 1))
  index <- seq_len(nodes - 1L)
  jacobi <- matrix(0, nrow = nodes, ncol = nodes)
  off_diagonal <- sqrt(index / 2)
  jacobi[cbind(index, index + 1L)] <- off_diagonal
  jacobi[cbind(index + 1L, index)] <- off_diagonal
  decomposition <- eigen(jacobi, symmetric = TRUE)
  list(
    nodes = sqrt(2) * decomposition$values,
    weights = decomposition$vectors[1, ]^2
  )
}

mfrmr_cq_additive_coordinates <- function(fit, model, fixture) {
  model <- toupper(as.character(model)[1])
  summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)[1, , drop = FALSE]
  facet <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
  estimate_facet <- function(name, levels) {
    table <- facet[facet$Facet == name, , drop = FALSE]
    value <- as.numeric(table$Estimate[match(levels, table$Level)])
    mfrmr_cq_additive_assert(
      length(value) == length(levels) && all(is.finite(value)),
      paste0("The fitted ", name, " coordinates are incomplete.")
    )
    stats::setNames(value, levels)
  }
  rater <- estimate_facet("Rater", fixture$raters)
  criterion <- estimate_facet("Criterion", fixture$criteria)
  step_table <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
  if (identical(model, "RSM")) {
    step <- as.numeric(step_table$Estimate[match(
      paste0("Step_", 1:3), step_table$Step
    )])
    steps <- matrix(
      rep(step, times = length(fixture$criteria)),
      nrow = length(fixture$criteria), byrow = TRUE,
      dimnames = list(fixture$criteria, paste0("Step", 1:3))
    )
  } else {
    key <- paste(step_table$StepFacet, step_table$Step, sep = "\r")
    steps <- t(vapply(fixture$criteria, function(criterion_level) {
      as.numeric(step_table$Estimate[match(
        paste(criterion_level, paste0("Step_", 1:3), sep = "\r"), key
      )])
    }, numeric(3L)))
    rownames(steps) <- fixture$criteria
    colnames(steps) <- paste0("Step", 1:3)
  }
  beta <- as.numeric(fit$population$coefficients[c("(Intercept)", "X")])
  names(beta) <- c("Intercept", "X")
  sigma2 <- as.numeric(fit$population$sigma2)
  mfrmr_cq_additive_assert(
    all(is.finite(c(beta, sigma2, rater, criterion, steps))) && sigma2 > 0 &&
      abs(sum(rater)) < 1e-8 && abs(sum(criterion)) < 1e-8 &&
      all(abs(rowSums(steps)) < 1e-8),
    "The fitted additive coordinates violate finiteness or sum-zero constraints."
  )
  list(
    summary = summary,
    beta = beta,
    sigma2 = sigma2,
    rater = rater,
    criterion = criterion,
    steps = steps
  )
}

mfrmr_cq_additive_oracle_loglik <- function(
    fit, model, nodes, fixture, namespace) {
  coordinate <- mfrmr_cq_additive_coordinates(fit, model, fixture)
  quadrature <- mfrmr_cq_additive_gh_normal(nodes)
  long <- fixture$long
  person_index <- match(long$Person, fixture$persons)
  criterion_index <- match(long$Criterion, fixture$criteria)
  mu <- coordinate$beta["Intercept"] + coordinate$beta["X"] * fixture$wide$X
  log_probability <- matrix(
    NA_real_, nrow = nrow(long), ncol = length(quadrature$nodes)
  )
  maximum_probability_difference <- 0
  internal_rsm <- get("category_prob_rsm", envir = namespace, inherits = FALSE)
  internal_pcm <- get("category_prob_pcm", envir = namespace, inherits = FALSE)
  for (node_index in seq_along(quadrature$nodes)) {
    theta <- mu + sqrt(coordinate$sigma2) * quadrature$nodes[node_index]
    theta_observed <- theta[person_index]
    eta <- theta_observed - coordinate$rater[long$Rater] -
      coordinate$criterion[long$Criterion]
    oracle <- matrix(NA_real_, nrow = nrow(long), ncol = 4L)
    for (criterion_level in fixture$criteria) {
      rows <- which(long$Criterion == criterion_level)
      oracle[rows, ] <- mfrmr_cq_additive_probability(
        theta = theta_observed[rows],
        rater_severity = coordinate$rater[long$Rater[rows]],
        criterion_difficulty = coordinate$criterion[long$Criterion[rows]],
        steps = coordinate$steps[criterion_level, ]
      )
    }
    internal <- if (identical(model, "RSM")) {
      internal_rsm(eta, c(0, cumsum(coordinate$steps[1, ])))
    } else {
      cumulative_step <- t(apply(
        coordinate$steps, 1L, function(value) c(0, cumsum(value))
      ))
      internal_pcm(eta, cumulative_step, criterion_index)
    }
    maximum_probability_difference <- max(
      maximum_probability_difference, abs(oracle - internal)
    )
    log_probability[, node_index] <- log(oracle[cbind(
      seq_len(nrow(long)), long$Score + 1L
    )])
  }
  person_log_probability <- rowsum(
    log_probability, person_index, reorder = FALSE
  )
  log_joint <- sweep(
    person_log_probability, 2L, log(quadrature$weights), "+"
  )
  row_maximum <- apply(log_joint, 1L, max)
  log_likelihood <- sum(
    row_maximum + log(rowSums(exp(log_joint - row_maximum)))
  )
  list(
    log_likelihood = log_likelihood,
    maximum_probability_difference = maximum_probability_difference,
    weight_sum_difference = abs(sum(quadrature$weights) - 1)
  )
}

mfrmr_cq_additive_reference_parameter_table <- function(
    coordinate, model, run_id, nodes) {
  map <- mfrmr_cq_additive_parameter_map(model)
  estimate <- vapply(seq_len(nrow(map)), function(index) {
    component <- map$Component[index]
    facet <- map$Facet[index]
    level <- map$Level[index]
    if (facet == "Population") {
      if (level == "Intercept") coordinate$beta["Intercept"] else
        if (level == "X") coordinate$beta["X"] else coordinate$sigma2
    } else if (facet == "Rater") {
      coordinate$rater[level]
    } else if (component == "Facet" && facet == "Criterion") {
      coordinate$criterion[level]
    } else if (facet == "Shared") {
      coordinate$steps[1, as.integer(sub("Step", "", level, fixed = TRUE))]
    } else {
      part <- strsplit(level, ":Step", fixed = TRUE)[[1]]
      coordinate$steps[part[1], as.integer(part[2])]
    }
  }, numeric(1L))
  data.frame(
    Specification = mfrmr_cq_additive_reference_specification,
    ContractVersion = mfrmr_cq_additive_reference_contract,
    RunId = run_id,
    Nodes = as.integer(nodes),
    map,
    Estimate = unname(estimate),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_additive_fit_reference <- function(
    model, nodes, fixture, source_root = ".", run_id = NULL) {
  namespace <- mfrmr_cq_additive_reference_namespace(source_root)
  model <- toupper(as.character(model)[1])
  nodes <- suppressWarnings(as.integer(nodes)[1])
  mfrmr_cq_additive_assert(
    model %in% c("RSM", "PCM") && nodes %in% c(31L, 61L),
    "The sealed source preflight permits only RSM/PCM at q=31/q=61."
  )
  if (is.null(run_id)) run_id <- paste0(tolower(model), "_q", nodes)
  run_id <- as.character(run_id)[1]
  fit_arguments <- list(
    data = fixture$long,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 0,
    rating_max = 3,
    method = "MML",
    model = model,
    population_formula = ~ X,
    person_data = fixture$wide[c("Person", "X")],
    quad_points = nodes,
    maxit = 2000L,
    reltol = 1e-12,
    mml_engine = "direct"
  )
  if (identical(model, "PCM")) fit_arguments$step_facet <- "Criterion"
  fit <- suppressWarnings(do.call(
    get("fit_mfrm", envir = namespace, inherits = FALSE), fit_arguments
  ))
  coordinate <- mfrmr_cq_additive_coordinates(fit, model, fixture)
  oracle <- mfrmr_cq_additive_oracle_loglik(
    fit, model, nodes, fixture, namespace
  )
  summary <- coordinate$summary
  all_pattern <- fit$config$estimability_audit$mml_all_pattern_information
  expected_npar <- if (identical(model, "RSM")) 7L else 9L
  observed_log_likelihood <- as.numeric(summary$LogLik)
  mfrmr_cq_additive_assert(
    as.integer(summary$Npar) == expected_npar &&
      identical(as.character(summary$ConvergenceStatus), "converged") &&
      is.finite(as.numeric(summary$TerminalGradientSupNorm)) &&
      identical(
        as.character(all_pattern$status),
        "evaluated_all_patterns_local_diagnostic_only"
      ) && as.integer(all_pattern$evaluated_response_patterns) == 512L &&
      as.integer(all_pattern$local_rank) == expected_npar &&
      as.integer(all_pattern$local_nullity) == 0L &&
      !isTRUE(all_pattern$tolerance_sensitive) &&
      is.finite(oracle$log_likelihood) &&
      abs(observed_log_likelihood - oracle$log_likelihood) <= 1e-9 &&
      oracle$maximum_probability_difference <= 1e-13 &&
      oracle$weight_sum_difference <= 1e-13,
    paste0("The source-bound ", run_id, " reference did not pass its oracle/rank contract.")
  )
  reference_summary <- data.frame(
    Specification = mfrmr_cq_additive_reference_specification,
    ContractVersion = mfrmr_cq_additive_reference_contract,
    RunId = run_id,
    Model = model,
    Nodes = nodes,
    Npar = as.integer(summary$Npar),
    LogLik = observed_log_likelihood,
    Deviance = as.numeric(summary$Deviance),
    ConvergenceStatus = as.character(summary$ConvergenceStatus),
    TerminalGradientSupNorm = as.numeric(summary$TerminalGradientSupNorm),
    AllPatternStatus = as.character(all_pattern$status),
    EvaluatedPatternDesigns = as.integer(all_pattern$evaluated_response_patterns),
    LocalRank = as.integer(all_pattern$local_rank),
    LocalNullity = as.integer(all_pattern$local_nullity),
    RankToleranceSensitive = isTRUE(all_pattern$tolerance_sensitive),
    OracleLogLik = oracle$log_likelihood,
    OracleLogLikAbsDifference = abs(
      observed_log_likelihood - oracle$log_likelihood
    ),
    OracleProbabilityMaxAbsDifference =
      oracle$maximum_probability_difference,
    QuadratureWeightSumDifference = oracle$weight_sum_difference,
    InferenceReady = isTRUE(summary$InferenceReady),
    ReadinessReasonCodes = as.character(summary$ReadinessReasonCodes),
    CandidateBound = FALSE,
    ExternalExecutionAuthorized = FALSE,
    ComparisonReady = FALSE,
    stringsAsFactors = FALSE
  )
  list(
    fit = fit,
    summary = reference_summary,
    parameters = mfrmr_cq_additive_reference_parameter_table(
      coordinate, model, run_id, nodes
    )
  )
}

mfrmr_run_conquest_additive_reference_preflight <- function(
    design_dir, source_root = ".") {
  mfrmr_cq_additive_reference_requirements()
  design_dir <- normalizePath(
    as.character(design_dir)[1], winslash = "/", mustWork = TRUE
  )
  design_review <- mfrmr_validate_conquest_additive_design(design_dir)
  mfrmr_cq_additive_assert(
    isTRUE(design_review$DesignReady) &&
      identical(design_review$Decision, "no_go_design_only"),
    "The prepared additive design did not pass its sealed no-fit validation."
  )
  reference_dir <- file.path(design_dir, "mfrmr_reference")
  mfrmr_cq_additive_assert(
    !dir.exists(reference_dir),
    "The mfrmr reference directory already exists; preserve it and use a fresh design."
  )
  dir.create(reference_dir, recursive = FALSE, showWarnings = FALSE)
  source_manifest <- mfrmr_cq_additive_source_manifest(source_root)
  source_manifest_file <- file.path(reference_dir, "source_manifest.csv")
  utils::write.csv(source_manifest, source_manifest_file, row.names = FALSE, na = "")
  source_manifest_hash <- mfrmr_cq_additive_hash_file(source_manifest_file)
  fixture <- mfrmr_cq_additive_fixture()
  plan <- mfrmr_cq_additive_plan()
  rows <- vector("list", nrow(plan))
  summaries <- vector("list", nrow(plan))
  for (index in seq_len(nrow(plan))) {
    arm <- plan[index, , drop = FALSE]
    reference <- mfrmr_cq_additive_fit_reference(
      arm$Model, arm$Nodes, fixture, source_root, arm$RunId
    )
    summary_file <- file.path(
      reference_dir, paste0(arm$RunId, "_mfrmr_reference_summary.csv")
    )
    parameter_file <- file.path(
      reference_dir, paste0(arm$RunId, "_mfrmr_reference_parameters.csv")
    )
    utils::write.csv(reference$summary, summary_file, row.names = FALSE, na = "")
    utils::write.csv(reference$parameters, parameter_file, row.names = FALSE, na = "")
    summaries[[index]] <- reference$summary
    rows[[index]] <- data.frame(
      Specification = mfrmr_cq_additive_reference_specification,
      ContractVersion = mfrmr_cq_additive_reference_contract,
      RunId = arm$RunId,
      Model = arm$Model,
      Nodes = arm$Nodes,
      ExpectedNpar = arm$ExpectedNpar,
      SourceTreeSHA256 = source_manifest$SourceTreeSHA256[1],
      SourceManifestSHA256 = source_manifest_hash,
      WideSHA256 = mfrmr_cq_additive_hash_file(file.path(
        design_dir, arm$RunId,
        paste0("cq_additive_", arm$RunId, "_wide.csv")
      )),
      SummaryFile = basename(summary_file),
      SummarySHA256 = mfrmr_cq_additive_hash_file(summary_file),
      ParameterFile = basename(parameter_file),
      ParameterSHA256 = mfrmr_cq_additive_hash_file(parameter_file),
      CandidateBound = FALSE,
      ExternalExecutionAuthorized = FALSE,
      ComparisonReady = FALSE,
      stringsAsFactors = FALSE
    )
  }
  summary_table <- do.call(rbind, summaries)
  manifest <- do.call(rbind, rows)
  q_sensitivity <- do.call(rbind, lapply(c("RSM", "PCM"), function(model) {
    value <- summary_table$Deviance[summary_table$Model == model]
    data.frame(
      Model = model,
      Q31Q61DevianceAbsoluteDifference = abs(diff(value)),
      PrespecifiedAcceptanceThreshold = NA_real_,
      AcceptanceDecision = "not_set_observation_only",
      stringsAsFactors = FALSE
    )
  }))
  q_file <- file.path(reference_dir, "q31_q61_sensitivity.csv")
  utils::write.csv(q_sensitivity, q_file, row.names = FALSE, na = "")
  manifest$QSensitivitySHA256 <- mfrmr_cq_additive_hash_file(q_file)
  manifest_file <- file.path(reference_dir, "reference_manifest.csv")
  utils::write.csv(manifest, manifest_file, row.names = FALSE, na = "")
  out <- list(
    specification = mfrmr_cq_additive_reference_specification,
    contract_version = mfrmr_cq_additive_reference_contract,
    status = "mfrmr_reference_ready_candidate_unbound",
    design_dir = design_dir,
    reference_dir = reference_dir,
    source_manifest = source_manifest,
    manifest = manifest,
    summary = summary_table,
    q_sensitivity = q_sensitivity,
    candidate_bound = FALSE,
    external_execution_authorized = FALSE,
    comparison_ready = FALSE
  )
  class(out) <- c("mfrmr_conquest_additive_reference", class(out))
  out
}

mfrmr_validate_conquest_additive_reference_preflight <- function(design_dir) {
  design_dir <- normalizePath(
    as.character(design_dir)[1], winslash = "/", mustWork = TRUE
  )
  mfrmr_validate_conquest_additive_design(design_dir)
  reference_dir <- file.path(design_dir, "mfrmr_reference")
  manifest_file <- file.path(reference_dir, "reference_manifest.csv")
  source_file <- file.path(reference_dir, "source_manifest.csv")
  q_file <- file.path(reference_dir, "q31_q61_sensitivity.csv")
  mfrmr_cq_additive_assert(
    all(file.exists(c(manifest_file, source_file, q_file))),
    "The source-bound reference artifact set is incomplete."
  )
  manifest <- utils::read.csv(
    manifest_file, stringsAsFactors = FALSE, check.names = FALSE
  )
  plan <- mfrmr_cq_additive_plan()
  mfrmr_cq_additive_assert(
    identical(as.character(manifest$RunId), plan$RunId) &&
      identical(as.character(manifest$Model), plan$Model) &&
      identical(as.integer(manifest$Nodes), plan$Nodes) &&
      identical(as.integer(manifest$ExpectedNpar), plan$ExpectedNpar) &&
      length(unique(manifest$SourceTreeSHA256)) == 1L &&
      length(unique(manifest$SourceManifestSHA256)) == 1L &&
      identical(
        mfrmr_cq_additive_hash_file(source_file),
        unique(manifest$SourceManifestSHA256)
      ) &&
      length(unique(manifest$QSensitivitySHA256)) == 1L &&
      identical(
        mfrmr_cq_additive_hash_file(q_file),
        unique(manifest$QSensitivitySHA256)
      ) &&
      length(unique(manifest$WideSHA256)) == 1L &&
      all(!as.logical(manifest$CandidateBound)) &&
      all(!as.logical(manifest$ExternalExecutionAuthorized)) &&
      all(!as.logical(manifest$ComparisonReady)),
    "The source-bound reference manifest does not match the sealed plan."
  )
  summaries <- vector("list", nrow(manifest))
  for (index in seq_len(nrow(manifest))) {
    row <- manifest[index, , drop = FALSE]
    summary_path <- file.path(reference_dir, row$SummaryFile)
    parameter_path <- file.path(reference_dir, row$ParameterFile)
    mfrmr_cq_additive_assert(
      all(file.exists(c(summary_path, parameter_path))) &&
        identical(mfrmr_cq_additive_hash_file(summary_path), row$SummarySHA256) &&
        identical(mfrmr_cq_additive_hash_file(parameter_path), row$ParameterSHA256),
      paste0("The source-bound reference artifact identity failed for `",
             row$RunId, "`.")
    )
    summary <- utils::read.csv(
      summary_path, stringsAsFactors = FALSE, check.names = FALSE
    )
    parameter <- utils::read.csv(
      parameter_path, stringsAsFactors = FALSE, check.names = FALSE
    )
    mfrmr_cq_additive_assert(
      nrow(summary) == 1L && summary$Npar == row$ExpectedNpar &&
        summary$ConvergenceStatus == "converged" &&
        summary$AllPatternStatus ==
          "evaluated_all_patterns_local_diagnostic_only" &&
        summary$EvaluatedPatternDesigns == 512L &&
        summary$LocalRank == row$ExpectedNpar && summary$LocalNullity == 0L &&
        !summary$RankToleranceSensitive &&
        summary$OracleLogLikAbsDifference <= 1e-9 &&
        summary$OracleProbabilityMaxAbsDifference <= 1e-13 &&
        summary$QuadratureWeightSumDifference <= 1e-13 &&
        sum(!is.na(parameter$FreeOrder)) == row$ExpectedNpar &&
        all(is.finite(parameter$Estimate)) &&
        all(!parameter$ComparisonEligible),
      paste0("The source-bound numeric/rank contract failed for `",
             row$RunId, "`.")
    )
    summaries[[index]] <- summary
  }
  q_sensitivity <- utils::read.csv(
    q_file, stringsAsFactors = FALSE, check.names = FALSE
  )
  mfrmr_cq_additive_assert(
    identical(as.character(q_sensitivity$Model), c("RSM", "PCM")) &&
      all(is.finite(q_sensitivity$Q31Q61DevianceAbsoluteDifference)) &&
      all(is.na(q_sensitivity$PrespecifiedAcceptanceThreshold)) &&
      all(q_sensitivity$AcceptanceDecision == "not_set_observation_only"),
    "The q31/q61 observation does not retain its non-decisional contract."
  )
  summary_table <- do.call(rbind, summaries)
  data.frame(
    Specification = mfrmr_cq_additive_reference_specification,
    ContractVersion = mfrmr_cq_additive_reference_contract,
    MfrmrReferenceObserved = TRUE,
    FourArmsComplete = nrow(summary_table) == 4L,
    NumericalAndOracleReady = TRUE,
    AllPatternLocalRankFull = TRUE,
    InferenceReady = all(as.logical(summary_table$InferenceReady)),
    InferenceReadinessInterpretation =
      "review_by_policy_not_a_cross_engine_objective_failure",
    IntegrationSensitivityObserved = TRUE,
    IntegrationSensitivityAccepted = NA,
    NativeDesignMatrixObserved = FALSE,
    CandidateBound = FALSE,
    ExternalExecutionAuthorized = FALSE,
    ComparisonReady = FALSE,
    Decision = "no_go_native_matrix_and_candidate_missing",
    stringsAsFactors = FALSE
  )
}
