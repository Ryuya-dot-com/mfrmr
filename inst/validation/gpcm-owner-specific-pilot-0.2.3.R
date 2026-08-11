# Repository-only owner-specific GPCM pilot for mfrmr 0.2.3.
#
# This runner is the Draft.66 pre-pilot execution slice. It keeps the implemented
# likelihood fixed and crosses the two currently representable aligned owners
# (Criterion and Rater) with JML/MML and support controls. It is calibration
# instrumentation only: it freezes no threshold and cannot authorize
# confirmation or a substantive "rater consistency" interpretation.

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

mfrmr_gpcm_owner_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("gpcm-owner-specific-pilot-0\\.2\\.3\\.R$", files)]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path("inst", "validation", "gpcm-owner-specific-pilot-0.2.3.R"),
    "gpcm-owner-specific-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_gpcm_owner_require_support <- function() {
  target_env <- environment(mfrmr_gpcm_owner_require_support)
  required <- c(
    "mfrmr_gpcm_stress_fun", "mfrmr_gpcm_stress_capture",
    "mfrmr_gpcm_stress_support", "mfrmr_gpcm_stress_thresholds",
    "mfrmr_gpcm_stress_slopes",
    "mfrmr_gpcm_repilot_hash_object",
    "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_runtime_package_identity",
    "mfrmr_gpcm_repilot_atomic_save_rds",
    "mfrmr_gpcm_repilot_wilson"
  )
  if (all(vapply(required, exists, logical(1), envir = target_env,
                 mode = "function", inherits = TRUE))) {
    return(invisible(TRUE))
  }
  files <- c(
    "gpcm-stress-covering-grid-0.2.3.R",
    "gpcm-attribution-replicated-pilot-0.2.3.R"
  )
  candidates <- lapply(files, function(file) {
    c(
      if (!is.na(mfrmr_gpcm_owner_source_dir)) {
        file.path(mfrmr_gpcm_owner_source_dir, file)
      } else character(0),
      file.path("inst", "validation", file), file
    )
  })
  for (i in seq_along(files)) {
    path <- candidates[[i]][file.exists(candidates[[i]])][1L]
    if (is.na(path)) {
      stop("Cannot locate owner-specific support file: ", files[[i]],
           call. = FALSE)
    }
    sys.source(path, envir = target_env)
  }
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("Owner-specific GPCM support did not load completely.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gpcm_owner_contract <- function() {
  if (is.na(mfrmr_gpcm_owner_source_dir)) {
    stop("Cannot identify the owner-specific validation directory.",
         call. = FALSE)
  }
  path <- file.path(
    mfrmr_gpcm_owner_source_dir,
    "gpcm-model-identity-contract-0.2.3.csv"
  )
  if (!file.exists(path)) {
    stop("Cannot locate the Draft.63 GPCM model-identity contract.",
         call. = FALSE)
  }
  out <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  required <- c(
    "ModelStratum", "ScenarioId", "SlopeOwner", "StepOwner",
    "SlopeComposition", "LatentDimensionCount", "Estimator",
    "AbilityScaleContract", "ImplementationStatus", "EvidenceStatus",
    "ClaimUse"
  )
  if (!all(required %in% names(out))) {
    stop("The Draft.63 GPCM model-identity contract is incomplete.",
         call. = FALSE)
  }
  out[out$ScenarioId %in% c(
    "NUM-GPCM-ALIGN-CRITERION", "NUM-GPCM-ALIGN-RATER"
  ), required, drop = FALSE]
}

mfrmr_gpcm_owner_execution_policy <- function(
    profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  data.frame(
    Schema = "mfrmr-gpcm-owner-execution-v1",
    SpecificationId = "0.2.3-draft.66",
    Profile = profile,
    PlannedDesignCells = if (identical(profile, "pilot")) 24L else 16L,
    ReplicatesPerCell = if (identical(profile, "pilot")) 5L else 1L,
    PlannedRows = if (identical(profile, "pilot")) 120L else 16L,
    PlannedMaxit = if (identical(profile, "pilot")) 400L else 50L,
    PlannedQuadPoints = if (identical(profile, "pilot")) 31L else 5L,
    BernoulliDenominator = "all_planned_manifest_rows",
    NumericDenominator = "finite_values_with_counts_disclosed",
    BernoulliInterval = "two_sided_95_percent_Wilson",
    NumericMCSE = "SD_over_sqrt_finite_count_when_count_ge_2",
    OutcomeAdaptiveStopping = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_owner_execution_contract_path <- function() {
  if (is.na(mfrmr_gpcm_owner_source_dir)) {
    stop("Cannot identify the owner-specific validation directory.",
         call. = FALSE)
  }
  path <- file.path(
    mfrmr_gpcm_owner_source_dir,
    "gpcm-owner-specific-execution-contract-0.2.3.md"
  )
  if (!file.exists(path)) {
    stop("Cannot locate the Draft.66 owner execution contract.",
         call. = FALSE)
  }
  path
}

mfrmr_gpcm_owner_designs <- function(profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  designs <- data.frame(
    DesignId = c(
      "core", "weak_bridge", "zero_shared", "internal_zero",
      "workload_imbalance", "range_restricted"
    ),
    DesignScenarioId = c(
      "REC-STANDARD-CORE", "DES-WEAK-BRIDGE",
      "DES-RATER-NO-COMMON-PERSON", "DES-GPCM-RATER-CATEGORY",
      "DES-GPCM-RATER-CATEGORY", "DES-GPCM-RATER-CATEGORY"
    ),
    ExpectedFitState = c(
      "review_recovery", "review_recovery",
      "must_not_be_false_ready", "must_not_be_false_ready",
      "review_recovery", "review_recovery"
    ),
    stringsAsFactors = FALSE
  )
  if (identical(profile, "smoke")) {
    designs <- designs[designs$DesignId %in% c(
      "core", "weak_bridge", "zero_shared", "internal_zero"
    ), , drop = FALSE]
  }
  row.names(designs) <- NULL
  designs
}

mfrmr_gpcm_owner_manifest <- function(profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  mfrmr_gpcm_owner_require_support()
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package `digest` is required for owner-specific manifests.",
         call. = FALSE)
  }
  contract <- mfrmr_gpcm_owner_contract()
  designs <- mfrmr_gpcm_owner_designs(profile)
  base <- merge(contract, designs, all = TRUE)
  base <- base[order(
    match(base$SlopeOwner, c("Criterion", "Rater")),
    match(base$Estimator, c("JML", "MML")),
    match(base$DesignId, designs$DesignId)
  ), , drop = FALSE]
  replicates <- if (identical(profile, "smoke")) 1L else 5L
  out <- merge(
    base,
    data.frame(Replicate = seq_len(replicates), stringsAsFactors = FALSE),
    all = TRUE
  )
  out <- out[order(
    match(out$SlopeOwner, c("Criterion", "Rater")),
    match(out$Estimator, c("JML", "MML")),
    match(out$DesignId, designs$DesignId),
    out$Replicate
  ), , drop = FALSE]
  row.names(out) <- NULL
  out$Profile <- profile
  out$Phase <- profile
  out$DesignCellId <- sprintf(
    "GPCM-OWNER-%s-%s-%s",
    ifelse(out$SlopeOwner == "Criterion", "C", "R"),
    out$Estimator,
    toupper(gsub("_", "-", out$DesignId, fixed = TRUE))
  )
  out$ScenarioId <- if (identical(profile, "smoke")) {
    out$DesignCellId
  } else {
    paste0(out$DesignCellId, sprintf("-R%03d", out$Replicate))
  }
  out$GateScenarioId <- ifelse(
    out$SlopeOwner == "Criterion",
    "NUM-GPCM-ALIGN-CRITERION", "NUM-GPCM-ALIGN-RATER"
  )
  out$NPersons <- if (identical(profile, "smoke")) 24L else 120L
  out$NRaters <- if (identical(profile, "smoke")) 3L else 6L
  out$NCriteria <- if (identical(profile, "smoke")) 3L else 6L
  out$NCategories <- 4L
  seed_base <- if (identical(profile, "smoke")) 1460000L else 2460000L
  out$Seed <- seed_base + seq_len(nrow(out))
  out$ReplicatesPlanned <- replicates
  out$ConfirmationAuthorized <- FALSE
  out$ConfirmationEvidence <- FALSE
  out$ThresholdStatus <- "pilot_required_not_frozen"
  out$ReleaseUse <- "calibration_only"
  out$RuntimeIdentityRequired <- TRUE

  runtime <- mfrmr_gpcm_repilot_runtime_package_identity()
  runner_path <- file.path(
    mfrmr_gpcm_owner_source_dir, "gpcm-owner-specific-pilot-0.2.3.R"
  )
  contract_path <- file.path(
    mfrmr_gpcm_owner_source_dir,
    "gpcm-model-identity-contract-0.2.3.csv"
  )
  out$RuntimeIdentity <- runtime$PackageSHA256
  out$RuntimePackageVersion <- runtime$Version
  out$RunnerSHA256 <- mfrmr_gpcm_repilot_hash_file(runner_path)
  out$IdentityContractSHA256 <-
    mfrmr_gpcm_repilot_hash_file(contract_path)
  out$ExecutionContractSHA256 <- mfrmr_gpcm_repilot_hash_file(
    mfrmr_gpcm_owner_execution_contract_path()
  )
  canonical <- out
  canonical$ManifestHash <- NULL
  out$ManifestHash <- mfrmr_gpcm_repilot_hash_object(canonical)
  out
}

mfrmr_gpcm_owner_execution_identity <- function(
    declared_manifest, maxit = NULL, quad_points = NULL) {
  mfrmr_gpcm_owner_require_support()
  if (!is.data.frame(declared_manifest) || nrow(declared_manifest) < 1L) {
    stop("`declared_manifest` must contain at least one row.", call. = FALSE)
  }
  scalar <- function(name) {
    value <- unique(as.character(declared_manifest[[name]]))
    if (length(value) != 1L || is.na(value) || !nzchar(value)) {
      stop("Declared manifest has a non-scalar identity field: ", name,
           call. = FALSE)
    }
    value
  }
  profile <- scalar("Profile")
  policy <- mfrmr_gpcm_owner_execution_policy(profile)
  maxit <- as.integer(maxit %||% policy$PlannedMaxit)
  quad_points <- as.integer(quad_points %||% policy$PlannedQuadPoints)
  if (length(maxit) != 1L || is.na(maxit) || maxit < 1L ||
      length(quad_points) != 1L || is.na(quad_points) || quad_points < 3L) {
    stop("Owner execution controls are invalid.", call. = FALSE)
  }
  if (identical(profile, "pilot") &&
      (maxit != policy$PlannedMaxit ||
       quad_points != policy$PlannedQuadPoints)) {
    stop(
      "Pilot optimizer and quadrature controls are frozen by Draft.66.",
      call. = FALSE
    )
  }
  replicate_counts <- unique(as.integer(declared_manifest$ReplicatesPlanned))
  if (length(replicate_counts) != 1L || is.na(replicate_counts)) {
    stop("Declared manifest has inconsistent replicate counts.",
         call. = FALSE)
  }
  observed_cells <- length(unique(declared_manifest$DesignCellId))
  per_cell <- table(declared_manifest$DesignCellId)
  if (nrow(declared_manifest) != policy$PlannedRows ||
      observed_cells != policy$PlannedDesignCells ||
      replicate_counts != policy$ReplicatesPerCell ||
      any(per_cell != policy$ReplicatesPerCell) ||
      anyDuplicated(declared_manifest$ScenarioId) ||
      anyDuplicated(declared_manifest$Seed)) {
    stop("Declared manifest violates the owner execution policy.",
         call. = FALSE)
  }
  execution <- data.frame(
    Schema = as.character(policy$Schema),
    SpecificationId = as.character(policy$SpecificationId),
    Profile = profile,
    DeclaredRows = nrow(declared_manifest),
    DeclaredDesignCells = observed_cells,
    ReplicatesPerCell = replicate_counts,
    Maxit = maxit,
    QuadPoints = quad_points,
    DeclaredManifestSHA256 = mfrmr_gpcm_repilot_hash_object(
      declared_manifest
    ),
    RuntimeIdentity = scalar("RuntimeIdentity"),
    RunnerSHA256 = scalar("RunnerSHA256"),
    IdentityContractSHA256 = scalar("IdentityContractSHA256"),
    ExecutionContractSHA256 = scalar("ExecutionContractSHA256"),
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(execution)
  execution
}

mfrmr_gpcm_owner_select_shard <- function(manifest, shard_index = 1L,
                                           shard_count = 1L) {
  shard_index <- as.integer(shard_index)
  shard_count <- as.integer(shard_count)
  if (length(shard_count) != 1L || is.na(shard_count) || shard_count < 1L) {
    stop("`shard_count` must be one positive integer.", call. = FALSE)
  }
  if (length(shard_index) != 1L || is.na(shard_index) ||
      shard_index < 1L || shard_index > shard_count) {
    stop("`shard_index` must be between one and `shard_count`.",
         call. = FALSE)
  }
  if (nrow(manifest) < 1L) {
    stop("Cannot shard an empty owner-specific manifest.", call. = FALSE)
  }
  if (shard_count > nrow(manifest)) {
    stop("`shard_count` cannot exceed the manifest row count.",
         call. = FALSE)
  }
  keep <- 1L + ((seq_len(nrow(manifest)) - 1L) %% shard_count) == shard_index
  out <- manifest[keep, , drop = FALSE]
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_owner_build <- function(row) {
  mfrmr_gpcm_owner_require_support()
  row <- as.list(row)
  owner <- as.character(row$SlopeOwner)
  n_person <- as.integer(row$NPersons)
  n_rater <- as.integer(row$NRaters)
  n_criterion <- as.integer(row$NCriteria)
  n_categories <- as.integer(row$NCategories)
  raters <- sprintf("R%02d", seq_len(n_rater))
  criteria <- sprintf("C%02d", seq_len(n_criterion))
  owner_levels <- if (identical(owner, "Rater")) raters else criteria
  assignment <- if (identical(row$DesignId, "weak_bridge")) {
    "sparse_linked"
  } else if (identical(row$DesignId, "zero_shared")) {
    "rotating"
  } else {
    "crossed"
  }
  raters_per_person <- if (identical(assignment, "crossed")) n_rater else 1L
  sparse_controls <- if (identical(assignment, "sparse_linked")) {
    list(
      link_persons = 1L,
      link_raters_per_person = n_rater,
      assignment_mode = "balanced",
      min_common_persons_per_rater_pair = 1L
    )
  } else {
    NULL
  }
  build_spec <- mfrmr_gpcm_stress_fun("build_mfrm_sim_spec")
  simulate <- mfrmr_gpcm_stress_fun("simulate_mfrm_data")
  spec <- build_spec(
    n_person = n_person,
    n_rater = n_rater,
    n_criterion = n_criterion,
    raters_per_person = raters_per_person,
    score_levels = n_categories,
    theta_sd = 1,
    rater_sd = 0.55,
    criterion_sd = 0.35,
    thresholds = mfrmr_gpcm_stress_thresholds(
      owner_levels, n_categories
    ),
    slopes = mfrmr_gpcm_stress_slopes(owner_levels, "mild"),
    model = "GPCM",
    step_facet = owner,
    slope_facet = owner,
    assignment = assignment,
    sparse_controls = sparse_controls
  )
  data <- simulate(sim_spec = spec, seed = as.integer(row$Seed))
  truth <- attr(data, "mfrm_truth")
  set.seed(as.integer(row$Seed) + 10000L)
  if (identical(row$DesignId, "internal_zero")) {
    middle <- 2L
    data <- data[data$Score != middle, , drop = FALSE]
  } else if (identical(row$DesignId, "workload_imbalance")) {
    rater_rank <- match(data$Rater, sort(unique(data$Rater)))
    probability <- pmax(0.20, 1 - 0.70 * (rater_rank - 1L) /
                          max(1L, n_rater - 1L))
    data <- data[stats::runif(nrow(data)) < probability, , drop = FALSE]
  } else if (identical(row$DesignId, "range_restricted")) {
    ability <- truth$person[as.character(data$Person)]
    cutoff <- stats::quantile(abs(truth$person), 0.55, names = FALSE)
    data <- data[abs(ability) <= cutoff, , drop = FALSE]
  }
  row.names(data) <- NULL
  attr(data, "mfrm_truth") <- truth
  attr(data, "mfrm_simulation_spec") <- spec
  list(data = data, truth = truth, spec = spec)
}

mfrmr_gpcm_owner_support <- function(data, row) {
  base <- mfrmr_gpcm_stress_support(data, as.integer(row$NCategories))
  owner <- as.character(row$SlopeOwner)
  owner_levels <- sort(unique(as.character(data[[owner]])))
  counts <- table(
    factor(as.character(data[[owner]]), levels = owner_levels),
    factor(as.integer(data$Score), levels = seq_len(as.integer(row$NCategories)))
  )
  cbind(
    base,
    data.frame(
      OwnerLevelCount = length(owner_levels),
      OwnerCategoryZeroCells = sum(counts == 0L),
      MinOwnerCategoryCount = min(counts),
      stringsAsFactors = FALSE
    )
  )
}

mfrmr_gpcm_owner_merge_codes <- function(...) {
  values <- unlist(list(...), use.names = FALSE)
  values <- values[!is.na(values) & nzchar(values)]
  codes <- unique(unlist(strsplit(values, ";", fixed = TRUE),
                         use.names = FALSE))
  paste(trimws(codes[nzchar(trimws(codes))]), collapse = ";")
}

mfrmr_gpcm_owner_empty_result <- function(row, state,
                                           error = NA_character_) {
  data.frame(
    ScenarioId = as.character(row$ScenarioId),
    DesignCellId = as.character(row$DesignCellId),
    Replicate = as.integer(row$Replicate),
    GateScenarioId = as.character(row$GateScenarioId),
    DesignScenarioId = as.character(row$DesignScenarioId),
    Profile = as.character(row$Profile),
    SlopeOwner = as.character(row$SlopeOwner),
    StepOwner = as.character(row$StepOwner),
    SlopeComposition = as.character(row$SlopeComposition),
    LatentDimensionCount = as.character(row$LatentDimensionCount),
    Estimator = as.character(row$Estimator),
    AbilityScaleContract = as.character(row$AbilityScaleContract),
    RuntimeIdentity = as.character(row$RuntimeIdentity),
    RunnerSHA256 = as.character(row$RunnerSHA256),
    IdentityContractSHA256 = as.character(row$IdentityContractSHA256),
    ExecutionContractSHA256 = as.character(row$ExecutionContractSHA256),
    ManifestHash = as.character(row$ManifestHash),
    DesignId = as.character(row$DesignId),
    ExpectedFitState = as.character(row$ExpectedFitState),
    Executed = FALSE,
    FitSucceeded = FALSE,
    RunState = as.character(state),
    Error = as.character(error),
    Warnings = NA_character_,
    Rows = NA_integer_, PositiveWeightRows = NA_integer_,
    Persons = NA_integer_, Raters = NA_integer_, Criteria = NA_integer_,
    ObservedCategories = NA_integer_, ZeroCategories = NA_integer_,
    MinCategoryCount = NA_integer_, MaxCategoryFraction = NA_real_,
    NormalizedCategoryEntropy = NA_real_, MinCommonPersons = NA_integer_,
    ZeroCommonRaterPairs = NA_integer_, ExactCellDuplicates = NA_integer_,
    DistinguishedCellDuplicates = NA_integer_, RetainedDataHash = NA_character_,
    OwnerLevelCount = NA_integer_, OwnerCategoryZeroCells = NA_integer_,
    MinOwnerCategoryCount = NA_integer_,
    FitIdentityMatch = NA, RawFitReadiness = NA_character_,
    RawInferenceReady = FALSE, EvidenceFitReadiness = "blocked",
    EvidenceInferenceReady = FALSE, EvidenceReasonCodes = NA_character_,
    RawFalseReady = FALSE, UpstreamReadyBlocked = FALSE,
    FalseReady = FALSE, SlopeN = 0L, SlopeLogRMSE = NA_real_,
    ThresholdStatus = as.character(row$ThresholdStatus),
    ReleaseUse = as.character(row$ReleaseUse),
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_owner_readiness <- function(fit) {
  readiness <- as.data.frame(fit$readiness$fit %||% data.frame(),
                             stringsAsFactors = FALSE)
  summary <- as.data.frame(fit$summary %||% data.frame(),
                           stringsAsFactors = FALSE)
  scalar <- function(table, name, default) {
    if (nrow(table) == 1L && name %in% names(table)) table[[name]][1L]
    else default
  }
  if (nrow(readiness) == 1L) {
    list(
      state = as.character(scalar(readiness, "FitReadiness", "legacy_unknown")),
      ready = isTRUE(scalar(readiness, "InferenceReady", FALSE)),
      reasons = as.character(scalar(readiness, "ReasonCodes", ""))
    )
  } else {
    list(
      state = as.character(scalar(summary, "FitReadiness", "legacy_unknown")),
      ready = isTRUE(scalar(summary, "InferenceReady", FALSE)),
      reasons = as.character(scalar(
        summary, "ReadinessReasonCodes",
        scalar(summary, "BoundaryReasonCodes", "legacy_contract_missing")
      ))
    )
  }
}

mfrmr_gpcm_owner_slope_recovery <- function(fit, truth) {
  fitted <- as.data.frame(fit$slopes %||% data.frame(),
                          stringsAsFactors = FALSE)
  target <- as.data.frame(truth$slope_table %||% data.frame(),
                          stringsAsFactors = FALSE)
  fit_column <- if ("OptimizerEstimate" %in% names(fitted)) {
    "OptimizerEstimate"
  } else if ("Estimate" %in% names(fitted)) {
    "Estimate"
  } else {
    NA_character_
  }
  if (is.na(fit_column) || nrow(fitted) == 0L || nrow(target) == 0L ||
      !all(c("SlopeFacet", "Estimate") %in% names(target)) ||
      !"SlopeFacet" %in% names(fitted)) {
    return(c(N = 0, LogRMSE = NA_real_))
  }
  fitted_values <- data.frame(
    SlopeFacet = as.character(fitted$SlopeFacet),
    FitEstimate = as.numeric(fitted[[fit_column]]),
    stringsAsFactors = FALSE
  )
  target_values <- data.frame(
    SlopeFacet = as.character(target$SlopeFacet),
    TruthEstimate = as.numeric(target$Estimate),
    stringsAsFactors = FALSE
  )
  joined <- merge(fitted_values, target_values, by = "SlopeFacet")
  fit_value <- joined$FitEstimate
  truth_value <- joined$TruthEstimate
  ok <- is.finite(fit_value) & fit_value > 0 &
    is.finite(truth_value) & truth_value > 0
  if (!any(ok)) return(c(N = 0, LogRMSE = NA_real_))
  fit_log <- log(fit_value[ok]) - mean(log(fit_value[ok]))
  truth_log <- log(truth_value[ok]) - mean(log(truth_value[ok]))
  c(N = sum(ok), LogRMSE = sqrt(mean((fit_log - truth_log)^2)))
}

mfrmr_gpcm_owner_run_one <- function(row, maxit = 50L, quad_points = 5L) {
  built <- mfrmr_gpcm_stress_capture(mfrmr_gpcm_owner_build(row))
  if (inherits(built$value, "error")) {
    out <- mfrmr_gpcm_owner_empty_result(
      row, "generation_failed", conditionMessage(built$value)
    )
    out$Executed <- TRUE
    return(out)
  }
  retained <- built$value
  data <- retained$data
  supported <- mfrmr_gpcm_stress_capture(
    mfrmr_gpcm_owner_support(data, row)
  )
  if (inherits(supported$value, "error")) {
    out <- mfrmr_gpcm_owner_empty_result(
      row, "support_audit_failed", conditionMessage(supported$value)
    )
    out$Executed <- TRUE
    out$Warnings <- paste(unique(c(built$warnings, supported$warnings)),
                          collapse = " | ")
    return(out)
  }
  support <- supported$value
  fit_args <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    keep_original = TRUE,
    model = "GPCM",
    method = as.character(row$Estimator),
    step_facet = as.character(row$StepOwner),
    slope_facet = as.character(row$SlopeOwner),
    rating_min = 1L,
    rating_max = as.integer(row$NCategories),
    maxit = as.integer(maxit)
  )
  if (identical(as.character(row$Estimator), "MML")) {
    fit_args$quad_points <- as.integer(quad_points)
  }
  fitted <- mfrmr_gpcm_stress_capture(
    do.call(mfrmr_gpcm_stress_fun("fit_mfrm"), fit_args)
  )
  warnings <- unique(c(
    built$warnings, supported$warnings, fitted$warnings
  ))
  if (inherits(fitted$value, "error")) {
    state <- if (identical(as.character(row$ExpectedFitState),
                           "must_not_be_false_ready")) {
      "expected_fail_closed"
    } else {
      "fit_failed"
    }
    out <- mfrmr_gpcm_owner_empty_result(
      row, state, conditionMessage(fitted$value)
    )
    out$Executed <- TRUE
    out$Warnings <- paste(warnings, collapse = " | ")
    out[names(support)] <- support
    return(out)
  }

  fit <- fitted$value
  raw <- mfrmr_gpcm_owner_readiness(fit)
  identity_match <- identical(
    as.character(fit$config$slope_facet %||% NA_character_),
    as.character(row$SlopeOwner)
  ) && identical(
    as.character(fit$config$step_facet %||% NA_character_),
    as.character(row$StepOwner)
  )
  prespecified_negative <- identical(
    as.character(row$ExpectedFitState), "must_not_be_false_ready"
  )
  support_guard <- prespecified_negative || !identity_match
  guard_codes <- c(
    if (!identity_match) "model_identity_mismatch",
    if (identical(row$DesignId, "zero_shared")) "zero_common_person_support",
    if (identical(row$DesignId, "internal_zero")) {
      "declared_internal_category_unobserved"
    }
  )
  evidence_state <- if (support_guard) "blocked" else raw$state
  evidence_ready <- isTRUE(raw$ready) && !support_guard &&
    identical(evidence_state, "ready")
  raw_false_ready <- prespecified_negative &&
    (isTRUE(raw$ready) || identical(raw$state, "ready"))
  false_ready <- prespecified_negative && evidence_ready
  recovery <- mfrmr_gpcm_owner_slope_recovery(fit, retained$truth)

  out <- mfrmr_gpcm_owner_empty_result(
    row,
    if (prespecified_negative) "guarded_negative_control" else "fitted"
  )
  out$Executed <- TRUE
  out$FitSucceeded <- TRUE
  out$Warnings <- paste(warnings, collapse = " | ")
  out[names(support)] <- support
  out$FitIdentityMatch <- identity_match
  out$RawFitReadiness <- raw$state
  out$RawInferenceReady <- raw$ready
  out$EvidenceFitReadiness <- evidence_state
  out$EvidenceInferenceReady <- evidence_ready
  out$EvidenceReasonCodes <- mfrmr_gpcm_owner_merge_codes(
    raw$reasons, guard_codes
  )
  out$RawFalseReady <- raw_false_ready
  out$UpstreamReadyBlocked <- raw_false_ready && !evidence_ready
  out$FalseReady <- false_ready
  out$SlopeN <- as.integer(recovery[["N"]])
  out$SlopeLogRMSE <- as.numeric(recovery[["LogRMSE"]])
  out
}

mfrmr_gpcm_owner_bind <- function(rows) {
  if (length(rows) == 0L) return(data.frame())
  all_names <- unique(unlist(lapply(rows, names), use.names = FALSE))
  rows <- lapply(rows, function(row) {
    missing <- setdiff(all_names, names(row))
    for (name in missing) row[[name]] <- NA
    row[, all_names, drop = FALSE]
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_owner_rate_row <- function(data) {
  mfrmr_gpcm_owner_require_support()
  planned <- nrow(data)
  summarize <- function(value) {
    value <- as.logical(value)
    value[is.na(value)] <- FALSE
    count <- sum(value)
    rate <- if (planned > 0L) count / planned else NA_real_
    interval <- mfrmr_gpcm_repilot_wilson(count, planned)
    c(
      Count = count,
      Rate = rate,
      BernoulliMCSE = if (planned > 0L) {
        sqrt(rate * (1 - rate) / planned)
      } else NA_real_,
      WilsonLower = interval[["Lower"]],
      WilsonUpper = interval[["Upper"]]
    )
  }
  metrics <- c(
    "Executed", "FitSucceeded", "RawInferenceReady",
    "EvidenceInferenceReady", "RawFalseReady", "UpstreamReadyBlocked",
    "FalseReady"
  )
  out <- data.frame(Planned = planned, stringsAsFactors = FALSE)
  for (metric in metrics) {
    values <- summarize(data[[metric]])
    for (suffix in names(values)) {
      out[[paste0(metric, suffix)]] <- as.numeric(values[[suffix]])
    }
  }
  out
}

mfrmr_gpcm_owner_rate_summary <- function(results) {
  if (!is.data.frame(results) || nrow(results) < 1L) return(data.frame())
  keys <- interaction(
    results$SlopeOwner, results$Estimator, results$DesignId,
    drop = TRUE, lex.order = TRUE
  )
  groups <- split(seq_len(nrow(results)), keys)
  rows <- lapply(groups, function(index) {
    data <- results[index, , drop = FALSE]
    cbind(
      data[1L, c("SlopeOwner", "Estimator", "DesignId", "DesignCellId"),
           drop = FALSE],
      mfrmr_gpcm_owner_rate_row(data)
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out[order(
    match(out$SlopeOwner, c("Criterion", "Rater")),
    match(out$Estimator, c("JML", "MML")), out$DesignId
  ), , drop = FALSE]
}

mfrmr_gpcm_owner_numeric_summary <- function(results) {
  if (!is.data.frame(results) || nrow(results) < 1L) return(data.frame())
  keys <- interaction(
    results$SlopeOwner, results$Estimator, results$DesignId,
    drop = TRUE, lex.order = TRUE
  )
  groups <- split(seq_len(nrow(results)), keys)
  rows <- lapply(groups, function(index) {
    data <- results[index, , drop = FALSE]
    value <- as.numeric(data$SlopeLogRMSE)
    finite <- is.finite(value)
    count <- sum(finite)
    standard_deviation <- if (count >= 2L) stats::sd(value[finite]) else NA_real_
    data.frame(
      data[1L, c("SlopeOwner", "Estimator", "DesignId", "DesignCellId"),
           drop = FALSE],
      Metric = "SlopeLogRMSE",
      Planned = nrow(data),
      Finite = count,
      MissingOrIneligible = nrow(data) - count,
      FitFailures = sum(!(data$FitSucceeded %in% TRUE)),
      EvidenceReady = sum(data$EvidenceInferenceReady %in% TRUE),
      Mean = if (count > 0L) mean(value[finite]) else NA_real_,
      SD = standard_deviation,
      MCSE = if (count >= 2L) standard_deviation / sqrt(count) else NA_real_,
      Minimum = if (count > 0L) min(value[finite]) else NA_real_,
      Maximum = if (count > 0L) max(value[finite]) else NA_real_,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out[order(
    match(out$SlopeOwner, c("Criterion", "Rater")),
    match(out$Estimator, c("JML", "MML")), out$DesignId
  ), , drop = FALSE]
}

mfrmr_gpcm_owner_checkpoint_schema <- function() {
  "mfrmr-gpcm-owner-checkpoint-v1"
}

mfrmr_gpcm_owner_completion_schema <- function() {
  "mfrmr-gpcm-owner-completion-v1"
}

mfrmr_gpcm_owner_checkpoint_path <- function(checkpoint_dir, scenario_id) {
  if (length(scenario_id) != 1L || is.na(scenario_id) ||
      !grepl("^[A-Za-z0-9._-]+$", scenario_id)) {
    stop("Unsafe owner-specific checkpoint scenario identifier.",
         call. = FALSE)
  }
  file.path(checkpoint_dir, paste0(scenario_id, ".rds"))
}

mfrmr_gpcm_owner_checkpoint <- function(row_manifest, result,
                                         execution_sha256) {
  row_manifest <- as.data.frame(row_manifest, stringsAsFactors = FALSE)
  row.names(row_manifest) <- NULL
  structure(
    list(
      schema = mfrmr_gpcm_owner_checkpoint_schema(),
      execution_sha256 = as.character(execution_sha256),
      scenario_id = as.character(row_manifest$ScenarioId),
      design_cell_id = as.character(row_manifest$DesignCellId),
      row_manifest_sha256 = mfrmr_gpcm_repilot_hash_object(row_manifest),
      result_sha256 = mfrmr_gpcm_repilot_hash_object(result),
      row_manifest = row_manifest,
      result = result,
      completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ),
    class = "mfrmr_gpcm_owner_checkpoint"
  )
}

mfrmr_gpcm_owner_validate_checkpoint <- function(
    checkpoint, row_manifest, execution_sha256) {
  fail <- function(message) {
    stop(paste0("Owner checkpoint validation failed: ", message),
         call. = FALSE)
  }
  if (!inherits(checkpoint, "mfrmr_gpcm_owner_checkpoint")) {
    fail("unexpected object class")
  }
  if (!identical(checkpoint$schema, mfrmr_gpcm_owner_checkpoint_schema())) {
    fail("schema mismatch")
  }
  if (!identical(as.character(checkpoint$execution_sha256),
                 as.character(execution_sha256))) {
    fail("execution identity mismatch")
  }
  if (!is.data.frame(row_manifest) || nrow(row_manifest) != 1L) {
    fail("expected exactly one manifest row")
  }
  row_manifest <- as.data.frame(row_manifest, stringsAsFactors = FALSE)
  row.names(row_manifest) <- NULL
  scenario_id <- as.character(row_manifest$ScenarioId)
  design_cell_id <- as.character(row_manifest$DesignCellId)
  if (!identical(as.character(checkpoint$scenario_id), scenario_id)) {
    fail("scenario identity mismatch")
  }
  if (!identical(as.character(checkpoint$design_cell_id), design_cell_id)) {
    fail("design-cell identity mismatch")
  }
  if (!identical(
    as.character(checkpoint$row_manifest_sha256),
    mfrmr_gpcm_repilot_hash_object(row_manifest)
  )) {
    fail("manifest-row hash mismatch")
  }
  result <- checkpoint$result
  if (!is.data.frame(result) || nrow(result) != 1L ||
      !all(c(
        "ScenarioId", "DesignCellId", "ManifestHash", "RuntimeIdentity",
        "RunnerSHA256", "IdentityContractSHA256", "ExecutionContractSHA256"
      ) %in% names(result))) {
    fail("result schema mismatch")
  }
  if (!identical(as.character(checkpoint$result_sha256),
                 mfrmr_gpcm_repilot_hash_object(result))) {
    fail("result payload hash mismatch")
  }
  if (!identical(as.character(result$ScenarioId), scenario_id) ||
      !identical(as.character(result$DesignCellId), design_cell_id)) {
    fail("result identity mismatch")
  }
  identity_fields <- c(
    "ManifestHash", "RuntimeIdentity", "RunnerSHA256",
    "IdentityContractSHA256", "ExecutionContractSHA256"
  )
  for (field in identity_fields) {
    if (!identical(as.character(result[[field]]),
                   as.character(row_manifest[[field]]))) {
      fail(paste0("result ", field, " mismatch"))
    }
  }
  invisible(TRUE)
}

mfrmr_gpcm_owner_read_checkpoint <- function(
    path, row_manifest, execution_sha256) {
  checkpoint <- tryCatch(readRDS(path), error = function(error) error)
  if (inherits(checkpoint, "error")) {
    stop(
      sprintf("Owner checkpoint validation failed: unreadable file %s (%s)",
              basename(path), conditionMessage(checkpoint)),
      call. = FALSE
    )
  }
  mfrmr_gpcm_owner_validate_checkpoint(
    checkpoint, row_manifest, execution_sha256
  )
  checkpoint
}

mfrmr_gpcm_owner_interruption <- function(new_rows) {
  structure(
    list(
      message = sprintf(
        "Intentional owner checkpoint interruption after %d new row(s).",
        new_rows
      ),
      call = NULL
    ),
    class = c("mfrmr_gpcm_owner_interruption", "error", "condition")
  )
}

mfrmr_gpcm_owner_build_run <- function(
    manifest, declared_manifest, execution_identity, maxit, quad_points,
    progress, checkpoint_dir = NULL, resume = FALSE,
    interrupt_after_rows = NULL) {
  execution_sha256 <- as.character(execution_identity$ExecutionSHA256)
  all_paths <- if (is.null(checkpoint_dir)) character(0) else {
    vapply(
      as.character(declared_manifest$ScenarioId),
      function(id) mfrmr_gpcm_owner_checkpoint_path(checkpoint_dir, id),
      character(1), USE.NAMES = FALSE
    )
  }
  if (!is.null(checkpoint_dir)) {
    dir.create(checkpoint_dir, recursive = TRUE, showWarnings = FALSE)
    existing <- list.files(
      checkpoint_dir, full.names = TRUE, all.files = TRUE, no.. = TRUE
    )
    unexpected <- setdiff(basename(existing), basename(all_paths))
    if (length(unexpected) > 0L) {
      stop(
        paste0(
          "Owner checkpoint directory contains unexpected RDS files: ",
          paste(unexpected, collapse = ", ")
        ),
        call. = FALSE
      )
    }
    if (!isTRUE(resume) && length(existing) > 0L) {
      stop(
        "Existing owner checkpoints require `resume = TRUE`; refusing to mix runs.",
        call. = FALSE
      )
    }
    if (isTRUE(resume) && length(existing) > 0L) {
      existing_ids <- sub("[.]rds$", "", basename(existing))
      for (existing_index in seq_along(existing)) {
        declared_index <- match(
          existing_ids[[existing_index]], declared_manifest$ScenarioId
        )
        mfrmr_gpcm_owner_read_checkpoint(
          existing[[existing_index]],
          declared_manifest[declared_index, , drop = FALSE],
          execution_sha256
        )
      }
    }
  } else if (isTRUE(resume)) {
    stop("`resume = TRUE` requires a checkpoint directory.", call. = FALSE)
  }
  if (!is.null(interrupt_after_rows) && is.null(checkpoint_dir)) {
    stop("Intentional interruption requires a checkpoint directory.",
         call. = FALSE)
  }

  rows <- vector("list", nrow(manifest))
  ledger <- vector("list", nrow(manifest))
  new_rows <- 0L
  for (i in seq_len(nrow(manifest))) {
    row_manifest <- manifest[i, , drop = FALSE]
    scenario_id <- as.character(row_manifest$ScenarioId)
    checkpoint_path <- if (is.null(checkpoint_dir)) NA_character_ else {
      mfrmr_gpcm_owner_checkpoint_path(checkpoint_dir, scenario_id)
    }
    resumed <- !is.na(checkpoint_path) && file.exists(checkpoint_path)
    if (resumed) {
      checkpoint <- mfrmr_gpcm_owner_read_checkpoint(
        checkpoint_path, row_manifest, execution_sha256
      )
      result <- checkpoint$result
      if (isTRUE(progress)) {
        message(sprintf("[gpcm-owner %d/%d] %s (resumed)",
                        i, nrow(manifest), scenario_id))
      }
    } else {
      if (isTRUE(progress)) {
        message(sprintf("[gpcm-owner %d/%d] %s",
                        i, nrow(manifest), scenario_id))
      }
      result <- mfrmr_gpcm_owner_run_one(
        row_manifest, maxit = maxit, quad_points = quad_points
      )
      checkpoint <- mfrmr_gpcm_owner_checkpoint(
        row_manifest, result, execution_sha256
      )
      mfrmr_gpcm_owner_validate_checkpoint(
        checkpoint, row_manifest, execution_sha256
      )
      if (!is.null(checkpoint_dir)) {
        mfrmr_gpcm_repilot_atomic_save_rds(checkpoint, checkpoint_path)
      }
      new_rows <- new_rows + 1L
    }
    rows[[i]] <- result
    ledger[[i]] <- data.frame(
      ScenarioId = scenario_id,
      DesignCellId = as.character(row_manifest$DesignCellId),
      Source = if (resumed) "resumed_checkpoint" else "executed",
      ResultRows = nrow(result),
      ExecutionSHA256 = execution_sha256,
      CheckpointFile = if (is.na(checkpoint_path)) NA_character_ else {
        basename(checkpoint_path)
      },
      CheckpointSHA256 = if (is.na(checkpoint_path)) NA_character_ else {
        mfrmr_gpcm_repilot_hash_file(checkpoint_path)
      },
      stringsAsFactors = FALSE
    )
    if (!is.null(interrupt_after_rows) && new_rows >= interrupt_after_rows) {
      stop(mfrmr_gpcm_owner_interruption(new_rows))
    }
  }
  results <- mfrmr_gpcm_owner_bind(rows)
  results <- results[match(manifest$ScenarioId, results$ScenarioId),
                     , drop = FALSE]
  row.names(results) <- NULL
  list(
    results = results,
    checkpoint_ledger = do.call(rbind, ledger),
    new_rows = new_rows,
    resumed_rows = sum(vapply(
      ledger, function(x) identical(x$Source, "resumed_checkpoint"),
      logical(1)
    ))
  )
}

mfrmr_gpcm_owner_summary <- function(results, profile, declared_rows,
                                      shard_index, shard_count) {
  data.frame(
    Profile = profile,
    DeclaredManifestRows = as.integer(declared_rows),
    ManifestRows = nrow(results),
    ExecutedRows = sum(results$Executed %in% TRUE),
    FitSucceededRows = sum(results$FitSucceeded %in% TRUE),
    IdentityViolations = sum(results$FitIdentityMatch %in% FALSE,
                             na.rm = TRUE),
    RawFalseReadyRows = sum(results$RawFalseReady %in% TRUE, na.rm = TRUE),
    UpstreamReadyBlockedRows = sum(
      results$UpstreamReadyBlocked %in% TRUE, na.rm = TRUE
    ),
    FalseReadyRows = sum(results$FalseReady %in% TRUE, na.rm = TRUE),
    ShardIndex = as.integer(shard_index),
    ShardCount = as.integer(shard_count),
    OutcomeAdaptiveStopping = FALSE,
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "pilot_required_not_frozen",
    ReleaseUse = "calibration_only",
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_owner_validate_completion <- function(
    output_dir, expected_execution_sha256 = NULL) {
  marker_path <- file.path(output_dir, "run-complete.rds")
  marker <- tryCatch(readRDS(marker_path), error = function(error) error)
  if (inherits(marker, "error")) {
    stop(sprintf("Owner completion marker is unreadable: %s",
                 conditionMessage(marker)), call. = FALSE)
  }
  if (!inherits(marker, "mfrmr_gpcm_owner_completion") ||
      !identical(marker$schema, mfrmr_gpcm_owner_completion_schema())) {
    stop("Owner completion marker schema mismatch.", call. = FALSE)
  }
  if (!is.null(expected_execution_sha256) &&
      !identical(as.character(marker$execution_sha256),
                 as.character(expected_execution_sha256))) {
    stop("Owner completion marker execution identity mismatch.",
         call. = FALSE)
  }
  inventory <- marker$artifacts
  if (!is.data.frame(inventory) ||
      !all(c("File", "SHA256") %in% names(inventory)) ||
      nrow(inventory) < 1L || anyDuplicated(inventory$File)) {
    stop("Owner completion artifact inventory schema mismatch.",
         call. = FALSE)
  }
  if (!identical(
    as.character(marker$artifact_inventory_sha256),
    mfrmr_gpcm_repilot_hash_object(inventory)
  )) {
    stop("Owner completion artifact inventory hash mismatch.",
         call. = FALSE)
  }
  relative <- gsub("\\\\", "/", as.character(inventory$File))
  unsafe <- !nzchar(relative) |
    grepl("^(?:[A-Za-z]:|/)", relative, perl = TRUE) |
    grepl("(?:^|/)\\.\\.(?:/|$)", relative, perl = TRUE)
  if (any(unsafe)) {
    stop("Owner completion inventory contains an unsafe path.",
         call. = FALSE)
  }
  paths <- file.path(output_dir, relative)
  if (any(!file.exists(paths))) {
    stop(
      paste0(
        "Owner completion marker references missing artifacts: ",
        paste(relative[!file.exists(paths)], collapse = ", ")
      ),
      call. = FALSE
    )
  }
  observed <- vapply(paths, mfrmr_gpcm_repilot_hash_file, character(1))
  mismatch <- observed != as.character(inventory$SHA256)
  if (any(mismatch)) {
    stop(
      paste0(
        "Owner completion artifact hash mismatch: ",
        paste(relative[mismatch], collapse = ", ")
      ),
      call. = FALSE
    )
  }
  final_path <- file.path(output_dir, "gpcm-owner-specific-pilot.rds")
  final <- tryCatch(readRDS(final_path), error = function(error) error)
  if (inherits(final, "error") ||
      !inherits(final, "mfrmr_gpcm_owner_specific_pilot")) {
    stop("Owner completion aggregate is unreadable or has the wrong class.",
         call. = FALSE)
  }
  execution_sha256 <- as.character(final$execution_identity$ExecutionSHA256)
  if (!identical(execution_sha256,
                 as.character(marker$execution_sha256))) {
    stop("Owner completion aggregate execution identity mismatch.",
         call. = FALSE)
  }
  declared <- final$declared_manifest
  results <- final$results
  if (!is.data.frame(declared) || !is.data.frame(results) ||
      anyDuplicated(results$ScenarioId) ||
      !identical(as.character(results$ScenarioId),
                 as.character(declared$ScenarioId)) ||
      !all(results$Executed %in% TRUE)) {
    stop("Owner completion aggregate does not cover the declared manifest.",
         call. = FALSE)
  }
  base_artifacts <- c(
    "declared-manifest.csv", "scenario-manifest.csv", "run-results.csv",
    "summary.csv", "rate-summary.csv", "numeric-summary.csv",
    "execution-identity.csv", "execution-policy.csv",
    "checkpoint-ledger.csv", "gpcm-owner-specific-pilot.rds"
  )
  checkpoint_relative <- file.path(
    "checkpoints", paste0(declared$ScenarioId, ".rds")
  )
  checkpoint_relative <- gsub("\\\\", "/", checkpoint_relative)
  expected_artifacts <- c(base_artifacts, checkpoint_relative)
  if (!identical(sort(relative), sort(expected_artifacts))) {
    stop("Owner completion inventory has missing or extra artifacts.",
         call. = FALSE)
  }
  for (i in seq_len(nrow(declared))) {
    checkpoint_path <- file.path(output_dir, checkpoint_relative[[i]])
    mfrmr_gpcm_owner_read_checkpoint(
      checkpoint_path, declared[i, , drop = FALSE], execution_sha256
    )
  }
  invisible(marker)
}

mfrmr_gpcm_owner_write <- function(x, output_dir) {
  if (!inherits(x, "mfrmr_gpcm_owner_specific_pilot") ||
      !is.data.frame(x$declared_manifest) || !is.data.frame(x$results)) {
    stop("`x` must be a completed owner-specific pilot result.",
         call. = FALSE)
  }
  declared <- x$declared_manifest
  if (!identical(as.character(x$manifest$ScenarioId),
                 as.character(declared$ScenarioId)) ||
      !identical(as.character(x$results$ScenarioId),
                 as.character(declared$ScenarioId)) ||
      !all(x$results$Executed %in% TRUE) ||
      !is.data.frame(x$checkpoint_ledger) ||
      !identical(as.character(x$checkpoint_ledger$ScenarioId),
                 as.character(declared$ScenarioId))) {
    stop("Completion requires every declared owner-specific manifest row.",
         call. = FALSE)
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  if (file.exists(file.path(output_dir, "run-complete.rds"))) {
    mfrmr_gpcm_owner_validate_completion(
      output_dir, x$execution_identity$ExecutionSHA256
    )
    stop("Output directory already contains a valid owner completion marker.",
         call. = FALSE)
  }
  checkpoint_dir <- file.path(output_dir, "checkpoints")
  expected_checkpoint_files <- paste0(declared$ScenarioId, ".rds")
  observed_checkpoint_files <- list.files(
    checkpoint_dir, pattern = "[.]rds$", full.names = FALSE
  )
  if (!identical(sort(observed_checkpoint_files),
                 sort(expected_checkpoint_files))) {
    stop("Completion requires exactly one checkpoint per declared row.",
         call. = FALSE)
  }
  execution_sha256 <- as.character(x$execution_identity$ExecutionSHA256)
  for (i in seq_len(nrow(declared))) {
    mfrmr_gpcm_owner_read_checkpoint(
      file.path(checkpoint_dir, expected_checkpoint_files[[i]]),
      declared[i, , drop = FALSE], execution_sha256
    )
  }
  artifact_names <- c(
    "declared-manifest.csv", "scenario-manifest.csv", "run-results.csv",
    "summary.csv", "rate-summary.csv", "numeric-summary.csv",
    "execution-identity.csv", "execution-policy.csv",
    "checkpoint-ledger.csv", "gpcm-owner-specific-pilot.rds"
  )
  if (any(file.exists(file.path(output_dir, artifact_names)))) {
    stop("Refusing to replace existing owner aggregate artifacts.",
         call. = FALSE)
  }
  utils::write.csv(declared, file.path(output_dir, "declared-manifest.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$manifest, file.path(output_dir, "scenario-manifest.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$results, file.path(output_dir, "run-results.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$summary, file.path(output_dir, "summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$rate_summary, file.path(output_dir, "rate-summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$numeric_summary,
                   file.path(output_dir, "numeric-summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$execution_identity,
                   file.path(output_dir, "execution-identity.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$execution_policy,
                   file.path(output_dir, "execution-policy.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$checkpoint_ledger,
                   file.path(output_dir, "checkpoint-ledger.csv"),
                   row.names = FALSE, na = "")
  saveRDS(x, file.path(output_dir, "gpcm-owner-specific-pilot.rds"))

  checkpoint_paths <- file.path(checkpoint_dir, expected_checkpoint_files)
  paths <- c(file.path(output_dir, artifact_names), checkpoint_paths)
  relative <- c(
    artifact_names,
    gsub("\\\\", "/", file.path("checkpoints", expected_checkpoint_files))
  )
  inventory <- data.frame(
    File = relative,
    SHA256 = unname(vapply(
      paths, mfrmr_gpcm_repilot_hash_file, character(1)
    )),
    stringsAsFactors = FALSE
  )
  marker <- structure(
    list(
      schema = mfrmr_gpcm_owner_completion_schema(),
      execution_sha256 = execution_sha256,
      declared_rows = nrow(declared),
      artifacts = inventory,
      artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
      completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ),
    class = "mfrmr_gpcm_owner_completion"
  )
  mfrmr_gpcm_repilot_atomic_save_rds(
    marker, file.path(output_dir, "run-complete.rds")
  )
  mfrmr_gpcm_owner_validate_completion(output_dir, execution_sha256)
  invisible(x)
}

mfrmr_run_gpcm_owner_specific_pilot <- function(
    profile = c("smoke", "pilot"),
    scenario_ids = NULL,
    dry_run = FALSE,
    authorize = FALSE,
    maxit = NULL,
    quad_points = NULL,
    output_dir = NULL,
    checkpoint_dir = NULL,
    resume = FALSE,
    shard_index = 1L,
    shard_count = 1L,
    interrupt_after_rows = NULL,
    progress = interactive()) {
  profile <- match.arg(profile)
  execution_policy <- mfrmr_gpcm_owner_execution_policy(profile)
  maxit <- as.integer(maxit %||% execution_policy$PlannedMaxit)
  quad_points <- as.integer(
    quad_points %||% execution_policy$PlannedQuadPoints
  )
  if (!identical(profile, "smoke") && !isTRUE(dry_run) &&
      !isTRUE(authorize)) {
    stop("The owner-specific pilot is resource-significant; set authorize = TRUE.",
         call. = FALSE)
  }
  if (length(maxit) != 1L || is.na(maxit) || maxit < 1L) {
    stop("`maxit` must be one positive integer.", call. = FALSE)
  }
  if (length(quad_points) != 1L || is.na(quad_points) || quad_points < 3L) {
    stop("`quad_points` must be one integer >= 3.", call. = FALSE)
  }
  shard_index <- as.integer(shard_index)
  shard_count <- as.integer(shard_count)
  if (length(shard_count) != 1L || is.na(shard_count) || shard_count < 1L) {
    stop("`shard_count` must be one positive integer.", call. = FALSE)
  }
  if (length(shard_index) != 1L || is.na(shard_index) ||
      shard_index < 1L || shard_index > shard_count) {
    stop("`shard_index` must be between one and `shard_count`.",
         call. = FALSE)
  }
  if (!is.null(scenario_ids) && shard_count > 1L) {
    stop("`scenario_ids` cannot be combined with more than one shard.",
         call. = FALSE)
  }
  if (!is.null(interrupt_after_rows)) {
    interrupt_after_rows <- as.integer(interrupt_after_rows)
    if (length(interrupt_after_rows) != 1L ||
        is.na(interrupt_after_rows) || interrupt_after_rows < 1L) {
      stop("`interrupt_after_rows` must be one positive integer.",
           call. = FALSE)
    }
  }
  declared_manifest <- mfrmr_gpcm_owner_manifest(profile)
  execution_identity <- mfrmr_gpcm_owner_execution_identity(
    declared_manifest, maxit = as.integer(maxit),
    quad_points = as.integer(quad_points)
  )
  manifest <- declared_manifest
  if (!is.null(scenario_ids)) {
    unknown <- setdiff(as.character(scenario_ids), manifest$ScenarioId)
    if (length(unknown) > 0L) {
      stop("Unknown owner-specific scenario: ", paste(unknown, collapse = ", "),
           call. = FALSE)
    }
    manifest <- manifest[
      manifest$ScenarioId %in% as.character(scenario_ids), , drop = FALSE
    ]
    if (nrow(manifest) < 1L) {
      stop("`scenario_ids` must select at least one scenario.",
           call. = FALSE)
    }
  }
  manifest <- mfrmr_gpcm_owner_select_shard(
    manifest, shard_index = shard_index, shard_count = shard_count
  )
  selected_manifest_sha256 <- mfrmr_gpcm_repilot_hash_object(manifest)
  if (isTRUE(dry_run)) {
    return(structure(
      list(
        declared_manifest = declared_manifest,
        manifest = manifest,
        results = data.frame(),
        rate_summary = data.frame(),
        numeric_summary = data.frame(),
        execution_identity = execution_identity,
        execution_policy = execution_policy,
        selected_manifest_sha256 = selected_manifest_sha256,
        checkpoint_ledger = data.frame(),
        summary = data.frame(
          Profile = profile,
          DeclaredManifestRows = nrow(declared_manifest),
          ManifestRows = nrow(manifest),
          ExecutedRows = 0L,
          FalseReadyRows = 0L,
          ShardIndex = shard_index,
          ShardCount = shard_count,
          ConfirmationAuthorized = FALSE,
          stringsAsFactors = FALSE
        )
      ),
      class = c("mfrmr_gpcm_owner_specific_pilot", "list")
    ))
  }
  if (!is.null(output_dir)) {
    default_checkpoint_dir <- file.path(output_dir, "checkpoints")
    if (is.null(checkpoint_dir)) {
      checkpoint_dir <- default_checkpoint_dir
    } else {
      requested <- tolower(normalizePath(
        checkpoint_dir, winslash = "/", mustWork = FALSE
      ))
      expected <- tolower(normalizePath(
        default_checkpoint_dir, winslash = "/", mustWork = FALSE
      ))
      if (!identical(requested, expected)) {
        stop(
          "When `output_dir` is set, checkpoints must use its `checkpoints` directory.",
          call. = FALSE
        )
      }
    }
  }
  if (!is.null(output_dir) &&
      file.exists(file.path(output_dir, "run-complete.rds"))) {
    mfrmr_gpcm_owner_validate_completion(
      output_dir, execution_identity$ExecutionSHA256
    )
    stop("Output directory already contains a valid completed owner run.",
         call. = FALSE)
  }
  execution <- mfrmr_gpcm_owner_build_run(
    manifest = manifest,
    declared_manifest = declared_manifest,
    execution_identity = execution_identity,
    maxit = as.integer(maxit),
    quad_points = as.integer(quad_points),
    progress = progress,
    checkpoint_dir = checkpoint_dir,
    resume = resume,
    interrupt_after_rows = interrupt_after_rows
  )
  results <- execution$results
  out <- structure(
    list(
      declared_manifest = declared_manifest,
      manifest = manifest,
      results = results,
      summary = mfrmr_gpcm_owner_summary(
        results, profile, nrow(declared_manifest), shard_index, shard_count
      ),
      rate_summary = mfrmr_gpcm_owner_rate_summary(results),
      numeric_summary = mfrmr_gpcm_owner_numeric_summary(results),
      execution_identity = execution_identity,
      execution_policy = execution_policy,
      selected_manifest_sha256 = selected_manifest_sha256,
      checkpoint_ledger = execution$checkpoint_ledger,
      checkpoint_summary = data.frame(
        NewRows = execution$new_rows,
        ResumedRows = execution$resumed_rows,
        SelectedRows = nrow(manifest),
        stringsAsFactors = FALSE
      ),
      confirmation_authorized = FALSE,
      session_info = utils::sessionInfo()
    ),
    class = c("mfrmr_gpcm_owner_specific_pilot", "list")
  )
  full_run <- identical(as.character(manifest$ScenarioId),
                        as.character(declared_manifest$ScenarioId))
  if (!is.null(output_dir) && full_run) {
    mfrmr_gpcm_owner_write(out, output_dir)
  }
  out
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  profile <- if (length(args) > 0L) args[[1L]] else "smoke"
  result <- mfrmr_run_gpcm_owner_specific_pilot(
    profile = profile,
    authorize = identical(profile, "pilot"),
    progress = TRUE
  )
  print(result$summary)
}
