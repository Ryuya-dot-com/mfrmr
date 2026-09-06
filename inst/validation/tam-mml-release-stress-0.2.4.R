# Repository-only bounded TAM MML release stress for mfrmr 0.2.4.

mfrmr_tms_specification <- "0.2.4-tam-mml-release-stress-v1"
mfrmr_tms_contract <- "mfrmr_tam_mml_release_stress_v1"
mfrmr_tms_expected_tam_version <- "4.3.25"
mfrmr_tms_expected_tam_hashes <- c(
  tam.mml = "9a3cd55d02641dc6d6ca8a500a8e881edcb2278a301cda31b1d2fbdc05d04775",
  tam.mml.mfr = "93631641ee114fe0e46ae47b8a1c4788d394ec4e1ca74cfef2b5db4efdce07ca"
)
mfrmr_tms_pair_tolerance <- 1e-4
mfrmr_tms_integration_tolerance <- 1e-3

mfrmr_tms_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_tms_require <- function(source_root = ".") {
  for (package in c("TAM", "digest", "mfrmr")) {
    mfrmr_tms_assert(
      requireNamespace(package, quietly = TRUE),
      paste0("The TAM MML release stress requires `", package, "`.")
    )
  }
  source_root <- normalizePath(source_root, winslash = "/", mustWork = TRUE)
  source_version <- unname(read.dcf(
    file.path(source_root, "DESCRIPTION"), fields = "Version"
  )[1L, 1L])
  namespace_path <- normalizePath(
    getNamespaceInfo(asNamespace("mfrmr"), "path"),
    winslash = "/", mustWork = TRUE
  )
  mfrmr_tms_assert(
    identical(namespace_path, source_root) && startsWith(source_version, "0.2.4") &&
      identical(as.character(utils::packageVersion("mfrmr")), source_version),
    "Load the 0.2.4 source tree with `pkgload::load_all(source_root)`."
  )
  invisible(source_root)
}

mfrmr_tms_function_hash <- function(fun) {
  digest::digest(
    list(formals = formals(fun), body = body(fun)),
    algo = "sha256", serialize = TRUE
  )
}

mfrmr_tms_runtime_identity <- function(source_root = ".") {
  source_root <- mfrmr_tms_require(source_root)
  functions <- c("tam.mml", "tam.mml.mfr")
  observed_hashes <- vapply(functions, function(name) {
    mfrmr_tms_function_hash(get(name, envir = asNamespace("TAM")))
  }, character(1L))
  version <- as.character(utils::packageVersion("TAM"))
  data.frame(
    Engine = c("mfrmr", rep("TAM", 2L)),
    Version = c(as.character(utils::packageVersion("mfrmr")), rep(version, 2L)),
    PrimaryFunction = c("fit_mfrm", functions),
    FunctionSHA256 = c(
      mfrmr_tms_function_hash(mfrmr::fit_mfrm), unname(observed_hashes)
    ),
    ExpectedFunctionSHA256 = c(
      NA_character_, unname(mfrmr_tms_expected_tam_hashes[functions])
    ),
    IdentityMatch = c(
      TRUE,
      version == mfrmr_tms_expected_tam_version &
        observed_hashes == mfrmr_tms_expected_tam_hashes[functions]
    ),
    SourceRoot = source_root,
    stringsAsFactors = FALSE
  )
}

mfrmr_tms_overlap_contract <- function() {
  data.frame(
    Layer = c("MeasurementSpec", "EstimationSpec", "ScoringSpec"),
    Matched = c(
      "unidimensional RSM; unit slope; Criterion and Rater facets; four ordered categories; common steps; identical observed rows",
      "person-pattern MML; matched fixed or estimated normal population; item/rater/step sum constraints; unit weights",
      "same-person EAP and posterior SD under the matched population basis"
    ),
    DeliberateDifference = c(
      "TAM uses Criterion-by-Rater pseudo-items",
      "TAM M-step/equally spaced nodes versus mfrmr direct optimization/Gauss-Hermite nodes",
      "engine-native posterior integration grids"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_tms_plan <- function() {
  profiles <- data.frame(
    ProfileId = c(
      "BASELINE", "SPARSE_RATER", "MCAR_20", "EXTREME_10", "WEAK_EXPOSURE"
    ),
    Persons = 80L,
    Criteria = 6L,
    Raters = 5L,
    RatersPerPerson = c(5L, 2L, 5L, 5L, 1L),
    MissingRate = c(0, 0, 0.20, 0, 0),
    ExtremeFraction = c(0, 0, 0, 0.10, 0),
    EstimatedPopulationIncluded = c(TRUE, FALSE, FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )
  datasets <- do.call(rbind, lapply(seq_len(nrow(profiles)), function(index) {
    out <- profiles[rep(index, 3L), , drop = FALSE]
    out$Replicate <- seq_len(3L)
    out$Seed <- 246000L + index * 100L + out$Replicate
    out
  }))
  modes <- do.call(rbind, lapply(seq_len(nrow(datasets)), function(index) {
    row <- datasets[index, , drop = FALSE]
    mode <- "fixed_standard_normal"
    if (isTRUE(row$EstimatedPopulationIncluded)) {
      mode <- c(mode, "estimated_intercept_only")
    }
    row <- row[rep(1L, length(mode)), , drop = FALSE]
    row$PopulationMode <- mode
    row
  }))
  plan <- modes[rep(seq_len(nrow(modes)), each = 2L), , drop = FALSE]
  plan$Nodes <- rep(c(31L, 61L), times = nrow(modes))
  plan$DatasetId <- sprintf(
    "TMS-%s-%s-R%02d",
    ifelse(plan$PopulationMode == "fixed_standard_normal", "FIX", "EST"),
    plan$ProfileId, plan$Replicate
  )
  plan$FitId <- sprintf("%s-Q%03d", plan$DatasetId, plan$Nodes)
  plan$Model <- "RSM"
  plan$Categories <- 4L
  plan$Assignment <- ifelse(plan$RatersPerPerson == plan$Raters,
                            "crossed", "rotating")
  plan$PairTolerance <- mfrmr_tms_pair_tolerance
  plan$IntegrationTolerance <- mfrmr_tms_integration_tolerance
  plan$EvidenceRole <- "0.2.4_release_stress_only"
  rownames(plan) <- NULL
  plan[, c(
    "FitId", "DatasetId", "ProfileId", "PopulationMode", "Replicate",
    "Seed", "Model", "Persons", "Criteria", "Raters", "RatersPerPerson",
    "Categories", "Assignment", "MissingRate", "ExtremeFraction", "Nodes",
    "PairTolerance", "IntegrationTolerance", "EvidenceRole"
  )]
}

mfrmr_tms_capture <- function(expression) {
  warnings <- character(0L)
  messages <- character(0L)
  started <- proc.time()[["elapsed"]]
  value <- withCallingHandlers(
    expression,
    warning = function(condition) {
      warnings <<- c(warnings, conditionMessage(condition))
      invokeRestart("muffleWarning")
    },
    message = function(condition) {
      messages <<- c(messages, conditionMessage(condition))
      invokeRestart("muffleMessage")
    }
  )
  list(
    value = value,
    warnings = unique(warnings),
    messages = unique(messages),
    elapsed = proc.time()[["elapsed"]] - started
  )
}

mfrmr_tms_restore_seed <- function(had_seed, old_seed) {
  if (had_seed) {
    assign(".Random.seed", old_seed, envir = .GlobalEnv)
  } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    rm(".Random.seed", envir = .GlobalEnv)
  }
  invisible(NULL)
}

mfrmr_tms_generate <- function(plan_row) {
  row <- plan_row[1L, , drop = FALSE]
  data <- mfrmr::simulate_mfrm_data(
    n_person = as.integer(row$Persons),
    n_rater = as.integer(row$Raters),
    n_criterion = as.integer(row$Criteria),
    raters_per_person = as.integer(row$RatersPerPerson),
    assignment = as.character(row$Assignment),
    score_levels = as.integer(row$Categories),
    model = "RSM",
    seed = as.integer(row$Seed)
  )
  truth <- attr(data, "mfrm_truth")
  persons <- sort(unique(as.character(data$Person)))
  if (row$ExtremeFraction > 0) {
    each_tail <- floor(length(persons) * row$ExtremeFraction / 2)
    data$Score[as.character(data$Person) %in% persons[seq_len(each_tail)]] <- 1L
    high <- persons[seq.int(each_tail + 1L, length.out = each_tail)]
    data$Score[as.character(data$Person) %in% high] <- as.integer(row$Categories)
  }
  if (row$MissingRate > 0) {
    had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
    on.exit(mfrmr_tms_restore_seed(had_seed, old_seed), add = TRUE)
    set.seed(as.integer(row$Seed) + 17L)
    remove <- sample.int(nrow(data), floor(nrow(data) * row$MissingRate))
    data <- data[-remove, , drop = FALSE]
  }
  data <- data[order(data$Person, data$Rater, data$Criterion), , drop = FALSE]
  rownames(data) <- NULL
  attr(data, "mfrm_truth") <- truth
  mfrmr_tms_assert(
    length(unique(data$Person)) == row$Persons &&
      length(unique(data$Rater)) == row$Raters &&
      length(unique(data$Criterion)) == row$Criteria &&
      all(data$Score %in% seq_len(row$Categories)),
    paste0("Generated data violate the frozen profile: ", row$DatasetId)
  )
  data
}

mfrmr_tms_prepare_tam <- function(data) {
  persons <- sort(unique(as.character(data$Person)))
  raters <- sort(unique(as.character(data$Rater)))
  criteria <- sort(unique(as.character(data$Criterion)))
  grid <- unique(data.frame(
    Person = as.character(data$Person),
    Rater = as.character(data$Rater),
    stringsAsFactors = FALSE
  ))
  grid <- grid[order(grid$Person, grid$Rater), , drop = FALSE]
  source_key <- paste(data$Person, data$Rater, data$Criterion, sep = "\r")
  response <- vapply(criteria, function(criterion) {
    target <- paste(grid$Person, grid$Rater, criterion, sep = "\r")
    index <- match(target, source_key)
    value <- rep(NA_integer_, nrow(grid))
    keep <- !is.na(index)
    value[keep] <- as.integer(data$Score[index[keep]]) - 1L
    value
  }, integer(nrow(grid)))
  response <- as.data.frame(response, stringsAsFactors = FALSE)
  names(response) <- criteria
  keep <- rowSums(!is.na(response)) > 0L
  grid <- grid[keep, , drop = FALSE]
  response <- response[keep, , drop = FALSE]
  design <- mfrmr_tms_capture(TAM::tam.mml.mfr(
    resp = response,
    facets = data.frame(rater = grid$Rater, stringsAsFactors = FALSE),
    pid = grid$Person,
    formulaA = ~ item + rater + step,
    constraint = "items",
    est.variance = FALSE,
    control = list(maxiter = 2L, progress = FALSE),
    verbose = FALSE
  ))
  item_map <- expand.grid(
    Rater = raters, Criterion = criteria,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  item_names <- dimnames(design$value$A)[[1L]]
  observed_raters <- sub("^.*-rater", "", item_names)
  mfrmr_tms_assert(
    identical(dim(design$value$A)[1L], nrow(item_map)) &&
      identical(observed_raters, item_map$Rater) &&
      identical(nrow(design$value$resp), length(persons)),
    "TAM pseudo-item design order does not match the frozen facet map."
  )
  list(
    resp = design$value$resp,
    A = design$value$A,
    item_map = item_map,
    persons = persons,
    design_warnings = design$warnings,
    design_messages = design$messages,
    input_hash = digest::digest(
      data[c("Person", "Rater", "Criterion", "Score")],
      algo = "sha256", serialize = TRUE
    )
  )
}

mfrmr_tms_fit_mfrmr <- function(data, row) {
  arguments <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1L,
    rating_max = as.integer(row$Categories),
    method = "MML",
    model = "RSM",
    quad_points = as.integer(row$Nodes),
    maxit = 1000L,
    reltol = 1e-12,
    mml_engine = "direct"
  )
  if (identical(as.character(row$PopulationMode), "estimated_intercept_only")) {
    arguments$population_formula <- stats::as.formula("~ 1")
    arguments$person_data <- data.frame(
      Person = sort(unique(as.character(data$Person))),
      stringsAsFactors = FALSE
    )
    arguments$person_id <- "Person"
  }
  mfrmr_tms_capture(do.call(mfrmr::fit_mfrm, arguments))
}

mfrmr_tms_fit_tam <- function(prepared, row) {
  estimated <- identical(
    as.character(row$PopulationMode), "estimated_intercept_only"
  )
  arguments <- list(
    resp = prepared$resp,
    A = prepared$A,
    beta.fixed = if (estimated) FALSE else cbind(1, 1, 0),
    est.variance = estimated,
    control = list(
      nodes = seq(-6, 6, length.out = as.integer(row$Nodes)),
      snodes = 0L,
      QMC = TRUE,
      maxiter = 1000L,
      conv = 1e-8,
      convD = 1e-8,
      convM = 1e-8,
      Msteps = 20L,
      progress = FALSE
    ),
    verbose = FALSE
  )
  mfrmr_tms_capture(do.call(TAM::tam.mml, arguments))
}

mfrmr_tms_mfrmr_surface <- function(fit, item_map) {
  facets <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
  rater <- facets[facets$Facet == "Rater", , drop = FALSE]
  criterion <- facets[facets$Facet == "Criterion", , drop = FALSE]
  rater <- stats::setNames(as.numeric(rater$Estimate), as.character(rater$Level))
  criterion <- stats::setNames(
    as.numeric(criterion$Estimate), as.character(criterion$Level)
  )
  steps <- as.numeric(fit$steps$Estimate[order(
    as.integer(sub("Step_", "", fit$steps$Step, fixed = TRUE))
  )])
  do.call(rbind, lapply(seq_len(nrow(item_map)), function(index) {
    k <- seq_along(steps)
    data.frame(
      Criterion = item_map$Criterion[index],
      Rater = item_map$Rater[index],
      Category = k,
      MfrmrEstimate = k * (
        criterion[item_map$Criterion[index]] + rater[item_map$Rater[index]]
      ) + cumsum(steps),
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_tms_surface_table <- function(mfrmr_fit, tam_fit, prepared, row) {
  out <- mfrmr_tms_mfrmr_surface(mfrmr_fit, prepared$item_map)
  tam <- -as.matrix(tam_fit$AXsi)[, -1L, drop = FALSE]
  mfrmr_tms_assert(
    nrow(tam) == nrow(prepared$item_map) && ncol(tam) == 3L &&
      nrow(out) == length(tam),
    "TAM and mfrmr cumulative-difficulty surfaces do not align."
  )
  out$TAMEstimate <- as.numeric(t(tam))
  out$SignedDifference <- out$TAMEstimate - out$MfrmrEstimate
  out$AbsoluteDifference <- abs(out$SignedDifference)
  out$FitId <- as.character(row$FitId)
  out$DatasetId <- as.character(row$DatasetId)
  out$ProfileId <- as.character(row$ProfileId)
  out$PopulationMode <- as.character(row$PopulationMode)
  out$Replicate <- as.integer(row$Replicate)
  out$Nodes <- as.integer(row$Nodes)
  out[, c(
    "FitId", "DatasetId", "ProfileId", "PopulationMode", "Replicate",
    "Nodes", "Criterion", "Rater", "Category", "TAMEstimate",
    "MfrmrEstimate", "SignedDifference", "AbsoluteDifference"
  )]
}

mfrmr_tms_population <- function(mfrmr_fit, tam_fit, mode) {
  if (identical(mode, "fixed_standard_normal")) {
    return(c(MfrmrMean = 0, TAMMean = 0, MfrmrVariance = 1, TAMVariance = 1))
  }
  c(
    MfrmrMean = as.numeric(mfrmr_fit$population$coefficients["(Intercept)"]),
    TAMMean = as.numeric(tam_fit$beta[1L, 1L]),
    MfrmrVariance = as.numeric(mfrmr_fit$population$sigma2),
    TAMVariance = as.numeric(tam_fit$variance[1L, 1L])
  )
}

mfrmr_tms_score_table <- function(mfrmr_fit, tam_fit, data, prepared, row) {
  scored <- mfrmr::predict_mfrm_units(
    mfrmr_fit, data,
    scoring_quad_points = as.integer(row$Nodes),
    readiness_policy = "review"
  )$estimates
  index <- match(prepared$persons, as.character(scored$Person))
  mfrmr_tms_assert(
    !anyNA(index) && nrow(tam_fit$person) == length(prepared$persons),
    "TAM and mfrmr scored-person rows do not align."
  )
  out <- data.frame(
    FitId = as.character(row$FitId),
    DatasetId = as.character(row$DatasetId),
    ProfileId = as.character(row$ProfileId),
    PopulationMode = as.character(row$PopulationMode),
    Replicate = as.integer(row$Replicate),
    Nodes = as.integer(row$Nodes),
    Person = prepared$persons,
    TAMEAP = as.numeric(tam_fit$person$EAP),
    MfrmrEAP = as.numeric(scored$Estimate[index]),
    TAMPosteriorSD = as.numeric(tam_fit$person$SD.EAP),
    MfrmrPosteriorSD = as.numeric(scored$SD[index]),
    stringsAsFactors = FALSE
  )
  out$EAPDifference <- out$TAMEAP - out$MfrmrEAP
  out$PosteriorSDDifference <- out$TAMPosteriorSD - out$MfrmrPosteriorSD
  out
}

mfrmr_tms_compare_one <- function(row, data, prepared) {
  mfrmr_run <- mfrmr_tms_fit_mfrmr(data, row)
  tam_run <- mfrmr_tms_fit_tam(prepared, row)
  mfrmr_fit <- mfrmr_run$value
  tam_fit <- tam_run$value
  surface <- mfrmr_tms_surface_table(mfrmr_fit, tam_fit, prepared, row)
  scores <- mfrmr_tms_score_table(
    mfrmr_fit, tam_fit, data, prepared, row
  )
  population <- mfrmr_tms_population(
    mfrmr_fit, tam_fit, as.character(row$PopulationMode)
  )
  fit_summary <- as.data.frame(mfrmr_fit$summary, stringsAsFactors = FALSE)[1L, ]
  summary <- data.frame(
    FitId = as.character(row$FitId),
    DatasetId = as.character(row$DatasetId),
    ProfileId = as.character(row$ProfileId),
    PopulationMode = as.character(row$PopulationMode),
    Replicate = as.integer(row$Replicate),
    Seed = as.integer(row$Seed),
    Nodes = as.integer(row$Nodes),
    InputSHA256 = prepared$input_hash,
    ResponseRows = nrow(data),
    Persons = length(prepared$persons),
    MfrmrConvergenceStatus = as.character(fit_summary$ConvergenceStatus),
    MfrmrTerminalGradientSupNorm = as.numeric(
      fit_summary$TerminalGradientSupNorm
    ),
    MfrmrInferenceReady = isTRUE(fit_summary$InferenceReady),
    MfrmrReadinessReasonCodes = as.character(fit_summary$ReadinessReasonCodes),
    TAMIterations = as.integer(tam_fit$iter),
    MfrmrDeviance = as.numeric(fit_summary$Deviance),
    TAMDeviance = as.numeric(tam_fit$deviance),
    DevianceAbsoluteDifference = abs(
      as.numeric(tam_fit$deviance) - as.numeric(fit_summary$Deviance)
    ),
    SurfaceMaximumAbsoluteDifference = max(surface$AbsoluteDifference),
    EAPMaximumAbsoluteDifference = max(abs(scores$EAPDifference)),
    EAPRMSEDifference = sqrt(mean(scores$EAPDifference^2)),
    PosteriorSDMaximumAbsoluteDifference = max(
      abs(scores$PosteriorSDDifference)
    ),
    MfrmrPopulationMean = unname(population["MfrmrMean"]),
    TAMPopulationMean = unname(population["TAMMean"]),
    PopulationMeanAbsoluteDifference = abs(
      unname(population["TAMMean"] - population["MfrmrMean"])
    ),
    MfrmrPopulationVariance = unname(population["MfrmrVariance"]),
    TAMPopulationVariance = unname(population["TAMVariance"]),
    PopulationVarianceAbsoluteDifference = abs(
      unname(population["TAMVariance"] - population["MfrmrVariance"])
    ),
    MfrmrWarningCount = length(mfrmr_run$warnings),
    TAMWarningCount = length(c(prepared$design_warnings, tam_run$warnings)),
    MfrmrMessageCount = length(mfrmr_run$messages),
    TAMMessageCount = length(c(prepared$design_messages, tam_run$messages)),
    MfrmrElapsedSeconds = mfrmr_run$elapsed,
    TAMElapsedSeconds = tam_run$elapsed,
    Error = "",
    stringsAsFactors = FALSE
  )
  numeric_pair <- c(
    summary$DevianceAbsoluteDifference,
    summary$SurfaceMaximumAbsoluteDifference,
    summary$EAPMaximumAbsoluteDifference,
    summary$PosteriorSDMaximumAbsoluteDifference,
    summary$PopulationMeanAbsoluteDifference,
    summary$PopulationVarianceAbsoluteDifference
  )
  summary$PairPassed <-
    all(is.finite(numeric_pair)) &&
    identical(summary$MfrmrConvergenceStatus, "converged") &&
    is.finite(summary$TAMIterations) && summary$TAMIterations < 1000L &&
    all(numeric_pair <= mfrmr_tms_pair_tolerance) &&
    summary$MfrmrWarningCount == 0L && summary$TAMWarningCount == 0L
  list(summary = summary, surface = surface, scores = scores)
}

mfrmr_tms_failed_comparison <- function(row, data, prepared, message) {
  summary <- data.frame(
    FitId = as.character(row$FitId),
    DatasetId = as.character(row$DatasetId),
    ProfileId = as.character(row$ProfileId),
    PopulationMode = as.character(row$PopulationMode),
    Replicate = as.integer(row$Replicate),
    Seed = as.integer(row$Seed),
    Nodes = as.integer(row$Nodes),
    InputSHA256 = if (is.null(prepared)) NA_character_ else prepared$input_hash,
    ResponseRows = if (is.null(data)) NA_integer_ else nrow(data),
    Persons = if (is.null(data)) NA_integer_ else length(unique(data$Person)),
    MfrmrConvergenceStatus = "error",
    MfrmrTerminalGradientSupNorm = NA_real_,
    MfrmrInferenceReady = FALSE,
    MfrmrReadinessReasonCodes = "execution_error",
    TAMIterations = NA_integer_,
    MfrmrDeviance = NA_real_,
    TAMDeviance = NA_real_,
    DevianceAbsoluteDifference = NA_real_,
    SurfaceMaximumAbsoluteDifference = NA_real_,
    EAPMaximumAbsoluteDifference = NA_real_,
    EAPRMSEDifference = NA_real_,
    PosteriorSDMaximumAbsoluteDifference = NA_real_,
    MfrmrPopulationMean = NA_real_,
    TAMPopulationMean = NA_real_,
    PopulationMeanAbsoluteDifference = NA_real_,
    MfrmrPopulationVariance = NA_real_,
    TAMPopulationVariance = NA_real_,
    PopulationVarianceAbsoluteDifference = NA_real_,
    MfrmrWarningCount = NA_integer_,
    TAMWarningCount = NA_integer_,
    MfrmrMessageCount = NA_integer_,
    TAMMessageCount = NA_integer_,
    MfrmrElapsedSeconds = NA_real_,
    TAMElapsedSeconds = NA_real_,
    Error = as.character(message)[1L],
    PairPassed = FALSE,
    stringsAsFactors = FALSE
  )
  list(
    summary = summary,
    surface = data.frame(
      FitId = character(), DatasetId = character(), ProfileId = character(),
      PopulationMode = character(), Replicate = integer(), Nodes = integer(),
      Criterion = character(), Rater = character(), Category = integer(),
      TAMEstimate = numeric(), MfrmrEstimate = numeric(),
      SignedDifference = numeric(), AbsoluteDifference = numeric(),
      stringsAsFactors = FALSE
    ),
    scores = data.frame(
      FitId = character(), DatasetId = character(), ProfileId = character(),
      PopulationMode = character(), Replicate = integer(), Nodes = integer(),
      Person = character(), TAMEAP = numeric(), MfrmrEAP = numeric(),
      TAMPosteriorSD = numeric(), MfrmrPosteriorSD = numeric(),
      EAPDifference = numeric(), PosteriorSDDifference = numeric(),
      stringsAsFactors = FALSE
    )
  )
}

mfrmr_tms_maximum_movement <- function(q31, q61, key, value) {
  if (nrow(q31) == 0L || nrow(q61) == 0L) return(NA_real_)
  index <- match(key(q31), key(q61))
  if (anyNA(index) || length(index) != nrow(q61)) return(NA_real_)
  max(abs(q61[[value]][index] - q31[[value]]))
}

mfrmr_tms_integration_rows <- function(summaries, surfaces, scores) {
  groups <- split(seq_len(nrow(summaries)), summaries$DatasetId)
  do.call(rbind, lapply(groups, function(index) {
    summary <- summaries[index, , drop = FALSE]
    mfrmr_tms_assert(
      nrow(summary) == 2L && identical(sort(summary$Nodes), c(31L, 61L)),
      "Each release-stress dataset requires q31 and q61."
    )
    q31 <- summary$FitId[summary$Nodes == 31L]
    q61 <- summary$FitId[summary$Nodes == 61L]
    surface31 <- surfaces[surfaces$FitId == q31, , drop = FALSE]
    surface61 <- surfaces[surfaces$FitId == q61, , drop = FALSE]
    score31 <- scores[scores$FitId == q31, , drop = FALSE]
    score61 <- scores[scores$FitId == q61, , drop = FALSE]
    surface_key <- function(x) paste(x$Criterion, x$Rater, x$Category, sep = "\r")
    score_key <- function(x) x$Person
    row31 <- summary[summary$Nodes == 31L, , drop = FALSE]
    row61 <- summary[summary$Nodes == 61L, , drop = FALSE]
    out <- data.frame(
      DatasetId = row31$DatasetId,
      ProfileId = row31$ProfileId,
      PopulationMode = row31$PopulationMode,
      Replicate = row31$Replicate,
      InputSHA256 = row31$InputSHA256,
      MfrmrDevianceMovement = abs(
        row61$MfrmrDeviance - row31$MfrmrDeviance
      ),
      TAMDevianceMovement = abs(row61$TAMDeviance - row31$TAMDeviance),
      MfrmrSurfaceMaximumMovement = mfrmr_tms_maximum_movement(
        surface31, surface61, surface_key, "MfrmrEstimate"
      ),
      TAMSurfaceMaximumMovement = mfrmr_tms_maximum_movement(
        surface31, surface61, surface_key, "TAMEstimate"
      ),
      MfrmrEAPMaximumMovement = mfrmr_tms_maximum_movement(
        score31, score61, score_key, "MfrmrEAP"
      ),
      TAMEAPMaximumMovement = mfrmr_tms_maximum_movement(
        score31, score61, score_key, "TAMEAP"
      ),
      MfrmrPosteriorSDMaximumMovement = mfrmr_tms_maximum_movement(
        score31, score61, score_key, "MfrmrPosteriorSD"
      ),
      TAMPosteriorSDMaximumMovement = mfrmr_tms_maximum_movement(
        score31, score61, score_key, "TAMPosteriorSD"
      ),
      MfrmrPopulationMeanMovement = abs(
        row61$MfrmrPopulationMean - row31$MfrmrPopulationMean
      ),
      TAMPopulationMeanMovement = abs(
        row61$TAMPopulationMean - row31$TAMPopulationMean
      ),
      MfrmrPopulationVarianceMovement = abs(
        row61$MfrmrPopulationVariance - row31$MfrmrPopulationVariance
      ),
      TAMPopulationVarianceMovement = abs(
        row61$TAMPopulationVariance - row31$TAMPopulationVariance
      ),
      stringsAsFactors = FALSE
    )
    movement <- unlist(out[grepl("Movement$", names(out))], use.names = FALSE)
    out$IntegrationPassed <- all(is.finite(movement)) &&
      all(movement <= mfrmr_tms_integration_tolerance)
    out
  }))
}

mfrmr_run_tam_mml_release_stress <- function(source_root = ".") {
  runtime <- mfrmr_tms_runtime_identity(source_root)
  plan <- mfrmr_tms_plan()
  dataset_plan <- plan[!duplicated(plan$DatasetId), , drop = FALSE]
  data_cache <- lapply(seq_len(nrow(dataset_plan)), function(index) {
    data <- NULL
    tryCatch({
      data <- mfrmr_tms_generate(dataset_plan[index, , drop = FALSE])
      list(data = data, prepared = mfrmr_tms_prepare_tam(data), error = "")
    }, error = function(condition) {
      list(data = data, prepared = NULL, error = conditionMessage(condition))
    })
  })
  names(data_cache) <- dataset_plan$DatasetId
  runs <- lapply(seq_len(nrow(plan)), function(index) {
    row <- plan[index, , drop = FALSE]
    cached <- data_cache[[as.character(row$DatasetId)]]
    if (nzchar(cached$error)) {
      return(mfrmr_tms_failed_comparison(
        row, cached$data, cached$prepared, cached$error
      ))
    }
    tryCatch(
      mfrmr_tms_compare_one(row, cached$data, cached$prepared),
      error = function(condition) mfrmr_tms_failed_comparison(
        row, cached$data, cached$prepared, conditionMessage(condition)
      )
    )
  })
  summaries <- do.call(rbind, lapply(runs, `[[`, "summary"))
  surfaces <- do.call(rbind, lapply(runs, `[[`, "surface"))
  scores <- do.call(rbind, lapply(runs, `[[`, "scores"))
  rownames(summaries) <- rownames(surfaces) <- rownames(scores) <- NULL
  integration <- mfrmr_tms_integration_rows(summaries, surfaces, scores)
  rownames(integration) <- NULL
  complete <- nrow(summaries) == 42L && nrow(integration) == 21L &&
    all(runtime$IdentityMatch) && all(summaries$PairPassed) &&
    all(integration$IntegrationPassed)
  list(
    specification = mfrmr_tms_specification,
    contract_version = mfrmr_tms_contract,
    status = if (complete) {
      "bounded_tam_mml_release_stress_passed"
    } else {
      "bounded_tam_mml_release_stress_requires_review"
    },
    runtime_identity = runtime,
    overlap_contract = mfrmr_tms_overlap_contract(),
    plan = plan,
    summaries = summaries,
    surfaces = surfaces,
    scores = scores,
    integration = integration,
    release_stress_complete = complete,
    tam_parity_established = FALSE,
    multidimensional_evidence = FALSE,
    free_slope_multifacet_gpcm_evidence = FALSE,
    portable_scope_broadened = FALSE,
    release_authorized = FALSE
  )
}

mfrmr_write_tam_mml_release_stress <- function(result, output_dir) {
  mfrmr_tms_assert(
    is.list(result) && identical(result$contract_version, mfrmr_tms_contract),
    "`result` is not a TAM MML release-stress result."
  )
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  tables <- c(
    runtime = "runtime_identity", plan = "plan", summary = "summaries",
    surface = "surfaces", score = "scores", integration = "integration"
  )
  paths <- vapply(names(tables), function(name) {
    path <- file.path(
      output_dir, paste0("tam-mml-release-stress-", name, "-0.2.4.csv")
    )
    utils::write.csv(result[[tables[[name]]]], path, row.names = FALSE, na = "")
    path
  }, character(1L))
  invisible(paths)
}
