# Repository-only TAM MML calibration for the additive complete-crossing core.
#
# This runner fits the same deterministic RSM/PCM fixture with mfrmr and TAM at
# q=31 and q=61. It records the coordinate transformation required by TAM's
# cases constraint, but freezes no TAM comparison tolerance and binds no release
# candidate. Source the additive design and mfrmr reference preflight first.

mfrmr_tmc_specification <- "0.2.3-wave-c-tam-mml-core-calibration-v1"
mfrmr_tmc_contract <- "mfrmr_tam_mml_core_calibration_v1"
mfrmr_tmc_expected_tam_version <- "4.3.25"
mfrmr_tmc_expected_tam_function_sha256 <-
  "93631641ee114fe0e46ae47b8a1c4788d394ec4e1ca74cfef2b5db4efdce07ca"

mfrmr_tmc_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_tmc_require <- function() {
  for (package in c("TAM", "digest", "mfrmr")) {
    mfrmr_tmc_assert(
      requireNamespace(package, quietly = TRUE),
      paste0("The TAM MML calibration requires `", package, "`.")
    )
  }
  scope <- environment(mfrmr_tmc_require)
  required <- c(
    "mfrmr_cq_additive_fixture", "mfrmr_cq_additive_fit_reference"
  )
  available <- vapply(
    required, exists, logical(1L), envir = scope,
    mode = "function", inherits = TRUE
  )
  mfrmr_tmc_assert(
    all(available),
    paste0(
      "Source the additive ConQuest design and mfrmr reference preflight ",
      "before the TAM MML calibration."
    )
  )
  invisible(TRUE)
}

mfrmr_tmc_function_hash <- function(fun) {
  digest::digest(
    list(formals = formals(fun), body = body(fun)),
    algo = "sha256", serialize = TRUE
  )
}

mfrmr_tmc_runtime_identity <- function() {
  mfrmr_tmc_require()
  observed_version <- as.character(utils::packageVersion("TAM"))
  observed_hash <- mfrmr_tmc_function_hash(TAM::tam.mml.mfr)
  data.frame(
    Engine = "TAM",
    PackageVersion = observed_version,
    ExpectedPackageVersion = mfrmr_tmc_expected_tam_version,
    PrimaryFunction = "TAM::tam.mml.mfr",
    FunctionSHA256 = observed_hash,
    ExpectedFunctionSHA256 = mfrmr_tmc_expected_tam_function_sha256,
    VersionMatch = observed_version == mfrmr_tmc_expected_tam_version,
    FunctionMatch = observed_hash == mfrmr_tmc_expected_tam_function_sha256,
    HelpTopic = "TAM::tam.mml.mfr",
    stringsAsFactors = FALSE
  )
}

mfrmr_tmc_plan <- function() {
  data.frame(
    RunId = c("rsm_q031", "rsm_q061", "pcm_q031", "pcm_q061"),
    Model = c("RSM", "RSM", "PCM", "PCM"),
    Nodes = c(31L, 61L, 31L, 61L),
    FormulaIdentity = c(
      "~ item + rater + step", "~ item + rater + step",
      "~ item + rater + item:step", "~ item + rater + item:step"
    ),
    Constraint = "cases",
    Estimator = "MML",
    SlopeMode = "fixed_unit",
    EvidenceRole = "calibration_only",
    stringsAsFactors = FALSE
  )
}

mfrmr_tmc_formula <- function(model) {
  model <- toupper(as.character(model)[1L])
  mfrmr_tmc_assert(model %in% c("RSM", "PCM"), "Unknown TAM core model.")
  if (model == "RSM") {
    stats::as.formula("~ item + rater + step")
  } else {
    stats::as.formula("~ item + rater + item:step")
  }
}

mfrmr_tmc_prepare <- function(fixture) {
  long <- fixture$long
  grid <- unique(long[c("Person", "Rater", "X")])
  grid <- grid[order(grid$Person, grid$Rater, method = "radix"), , drop = FALSE]
  source_key <- paste(long$Person, long$Rater, long$Criterion, sep = "\r")
  response <- vapply(fixture$criteria, function(criterion) {
    target <- paste(grid$Person, grid$Rater, criterion, sep = "\r")
    as.integer(long$Score[match(target, source_key)])
  }, integer(nrow(grid)))
  response <- as.data.frame(response, stringsAsFactors = FALSE)
  names(response) <- fixture$criteria
  mfrmr_tmc_assert(
    !anyNA(response) && identical(sort(unique(unlist(response))), 0:3) &&
      identical(sort(unique(grid$Person)), fixture$persons) &&
      identical(sort(unique(grid$Rater)), fixture$raters),
    "The TAM complete-crossing input does not match the additive fixture."
  )
  input_hash <- digest::digest(
    list(
      response = response,
      person = as.character(grid$Person),
      rater = as.character(grid$Rater),
      X = as.numeric(grid$X)
    ),
    algo = "sha256", serialize = TRUE
  )
  list(
    response = response,
    facets = data.frame(rater = grid$Rater, stringsAsFactors = FALSE),
    pid = as.character(grid$Person),
    dataY = data.frame(X = as.numeric(grid$X)),
    input_hash = input_hash
  )
}

mfrmr_tmc_fit_tam <- function(prepared, model, nodes) {
  model <- toupper(as.character(model)[1L])
  nodes <- as.integer(nodes)[1L]
  mfrmr_tmc_assert(
    model %in% c("RSM", "PCM") && nodes %in% c(31L, 61L),
    "The TAM core calibration accepts only RSM/PCM at q=31/q=61."
  )
  warnings <- character(0L)
  messages <- character(0L)
  started <- proc.time()[["elapsed"]]
  fit <- withCallingHandlers(
    TAM::tam.mml.mfr(
      resp = prepared$response,
      facets = prepared$facets,
      pid = prepared$pid,
      formulaA = mfrmr_tmc_formula(model),
      formulaY = ~ X,
      dataY = prepared$dataY,
      constraint = "cases",
      est.variance = TRUE,
      control = list(
        nodes = seq(-6, 6, length.out = nodes),
        snodes = 0L,
        QMC = TRUE,
        maxiter = 2000L,
        conv = 1e-12,
        convD = 1e-12,
        convM = 1e-10,
        Msteps = 20L,
        progress = FALSE
      ),
      verbose = FALSE
    ),
    warning = function(condition) {
      warnings <<- c(warnings, conditionMessage(condition))
      invokeRestart("muffleWarning")
    },
    message = function(condition) {
      messages <<- c(messages, conditionMessage(condition))
      invokeRestart("muffleMessage")
    }
  )
  elapsed <- proc.time()[["elapsed"]] - started
  mfrmr_tmc_assert(
    inherits(fit, "tam.mml") && is.finite(fit$deviance) &&
      as.integer(fit$iter) < 2000L,
    paste0("The TAM ", model, " q", nodes, " calibration did not converge.")
  )
  list(
    fit = fit,
    elapsed = elapsed,
    warnings = unique(warnings),
    messages = unique(messages)
  )
}

mfrmr_tmc_tam_parameter_table <- function(fit, model, run_id, nodes) {
  model <- toupper(as.character(model)[1L])
  facets <- as.data.frame(fit$xsi.facets, stringsAsFactors = FALSE)
  item <- facets[facets$facet == "item", , drop = FALSE]
  rater <- facets[facets$facet == "rater", , drop = FALSE]
  step <- facets[facets$facet %in% c("step", "item:step"), , drop = FALSE]
  item_location <- mean(as.numeric(item$xsi))
  population <- data.frame(
    Component = "Population",
    Facet = "Population",
    Level = c("Intercept", "X", "Variance"),
    Estimate = c(
      -item_location,
      unname(as.numeric(fit$beta["Y1", 1L])),
      unname(as.numeric(fit$variance[1L, 1L]))
    ),
    stringsAsFactors = FALSE
  )
  rater_rows <- data.frame(
    Component = "Facet",
    Facet = "Rater",
    Level = sub("^rater", "", as.character(rater$parameter)),
    Estimate = as.numeric(rater$xsi),
    stringsAsFactors = FALSE
  )
  criterion_rows <- data.frame(
    Component = "Facet",
    Facet = "Criterion",
    Level = as.character(item$parameter),
    Estimate = as.numeric(item$xsi) - item_location,
    stringsAsFactors = FALSE
  )
  if (model == "RSM") {
    step_rows <- data.frame(
      Component = "Step", Facet = "Shared",
      Level = sub("^step", "Step", as.character(step$parameter)),
      Estimate = as.numeric(step$xsi), stringsAsFactors = FALSE
    )
  } else {
    step_rows <- data.frame(
      Component = "Step", Facet = "Criterion",
      Level = sub(":step", ":Step", as.character(step$parameter), fixed = TRUE),
      Estimate = as.numeric(step$xsi), stringsAsFactors = FALSE
    )
  }
  out <- rbind(population, rater_rows, criterion_rows, step_rows)
  out$RunId <- run_id
  out$Model <- model
  out$Nodes <- as.integer(nodes)
  out$CoordinateTransform <- ifelse(
    out$Facet == "Population" & out$Level == "Intercept",
    "negative_mean_TAM_item_xsi",
    ifelse(
      out$Facet == "Criterion", "TAM_item_xsi_minus_mean_item_xsi",
      "direct"
    )
  )
  out[, c(
    "RunId", "Model", "Nodes", "Component", "Facet", "Level",
    "CoordinateTransform", "Estimate"
  )]
}

mfrmr_tmc_compare_one <- function(plan_row, fixture, prepared, source_root) {
  model <- as.character(plan_row$Model)
  nodes <- as.integer(plan_row$Nodes)
  run_id <- as.character(plan_row$RunId)
  reference <- mfrmr_cq_additive_fit_reference(
    model, nodes, fixture, source_root, run_id
  )
  tam <- mfrmr_tmc_fit_tam(prepared, model, nodes)
  tam_parameters <- mfrmr_tmc_tam_parameter_table(
    tam$fit, model, run_id, nodes
  )
  reference_parameters <- reference$parameters
  key <- function(table) paste(
    table$Component, table$Facet, table$Level, sep = "\r"
  )
  index <- match(key(reference_parameters), key(tam_parameters))
  mfrmr_tmc_assert(
    !anyNA(index) && nrow(reference_parameters) == nrow(tam_parameters),
    paste0("The TAM and mfrmr ", run_id, " coordinate maps differ.")
  )
  coordinate <- reference_parameters[, c(
    "RunId", "Model", "Nodes", "Component", "Facet", "Level",
    "MfrmrRole", "Orientation", "ConstraintRole"
  )]
  coordinate$CoordinateTransform <- tam_parameters$CoordinateTransform[index]
  coordinate$TAMEstimate <- tam_parameters$Estimate[index]
  coordinate$MfrmrEstimate <- reference_parameters$Estimate
  coordinate$SignedDifference <-
    coordinate$TAMEstimate - coordinate$MfrmrEstimate
  coordinate$AbsoluteDifference <- abs(coordinate$SignedDifference)
  coordinate$EvidenceRole <- "calibration_only"
  summary <- data.frame(
    RunId = run_id,
    Model = model,
    Nodes = nodes,
    InputSHA256 = prepared$input_hash,
    FormulaIdentity = as.character(plan_row$FormulaIdentity),
    TAMIterations = as.integer(tam$fit$iter),
    TAMDeviance = as.numeric(tam$fit$deviance),
    MfrmrDeviance = as.numeric(reference$summary$Deviance),
    DevianceSignedDifference =
      as.numeric(tam$fit$deviance) - as.numeric(reference$summary$Deviance),
    CoordinateRows = nrow(coordinate),
    CoordinateMaximumAbsoluteDifference = max(coordinate$AbsoluteDifference),
    MfrmrOracleLogLikAbsoluteDifference =
      as.numeric(reference$summary$OracleLogLikAbsDifference),
    MfrmrOracleProbabilityMaximumAbsoluteDifference =
      as.numeric(reference$summary$OracleProbabilityMaxAbsDifference),
    WarningCount = length(tam$warnings),
    MessageCount = length(tam$messages),
    ElapsedSeconds = tam$elapsed,
    stringsAsFactors = FALSE
  )
  list(summary = summary, coordinates = coordinate, fit = tam$fit)
}

mfrmr_tmc_integration_rows <- function(coordinates, summaries) {
  coordinate_group <- split(
    seq_len(nrow(coordinates)),
    paste(
      coordinates$Model, coordinates$Component, coordinates$Facet,
      coordinates$Level, sep = "\r"
    )
  )
  coordinate_rows <- do.call(rbind, lapply(coordinate_group, function(index) {
    part <- coordinates[index, , drop = FALSE]
    mfrmr_tmc_assert(
      nrow(part) == 2L && identical(sort(part$Nodes), c(31L, 61L)),
      "A TAM/mfrmr integration coordinate pair is incomplete."
    )
    data.frame(
      Model = part$Model[1L], Component = part$Component[1L],
      Facet = part$Facet[1L], Level = part$Level[1L], Metric = "coordinate",
      TAMQ61MinusQ31 =
        part$TAMEstimate[part$Nodes == 61L] -
        part$TAMEstimate[part$Nodes == 31L],
      MfrmrQ61MinusQ31 =
        part$MfrmrEstimate[part$Nodes == 61L] -
        part$MfrmrEstimate[part$Nodes == 31L],
      stringsAsFactors = FALSE
    )
  }))
  deviance_rows <- do.call(rbind, lapply(
    split(seq_len(nrow(summaries)), summaries$Model), function(index) {
      part <- summaries[index, , drop = FALSE]
      data.frame(
        Model = part$Model[1L], Component = "Objective", Facet = "Model",
        Level = "Deviance", Metric = "deviance",
        TAMQ61MinusQ31 =
          part$TAMDeviance[part$Nodes == 61L] -
          part$TAMDeviance[part$Nodes == 31L],
        MfrmrQ61MinusQ31 =
          part$MfrmrDeviance[part$Nodes == 61L] -
          part$MfrmrDeviance[part$Nodes == 31L],
        stringsAsFactors = FALSE
      )
    }
  ))
  out <- rbind(coordinate_rows, deviance_rows)
  rownames(out) <- NULL
  out$EvidenceRole <- "calibration_only"
  out
}

mfrmr_run_tam_mml_core_calibration <- function(source_root = ".",
                                                retain_fits = FALSE) {
  mfrmr_tmc_require()
  source_root <- normalizePath(
    as.character(source_root)[1L], winslash = "/", mustWork = TRUE
  )
  runtime <- mfrmr_tmc_runtime_identity()
  fixture <- mfrmr_cq_additive_fixture()
  prepared <- mfrmr_tmc_prepare(fixture)
  plan <- mfrmr_tmc_plan()
  runs <- lapply(seq_len(nrow(plan)), function(index) {
    mfrmr_tmc_compare_one(
      plan[index, , drop = FALSE], fixture, prepared, source_root
    )
  })
  summaries <- do.call(rbind, lapply(runs, `[[`, "summary"))
  coordinates <- do.call(rbind, lapply(runs, `[[`, "coordinates"))
  rownames(summaries) <- NULL
  rownames(coordinates) <- NULL
  integration <- mfrmr_tmc_integration_rows(coordinates, summaries)
  complete <- all(runtime$VersionMatch) && all(runtime$FunctionMatch) &&
    nrow(summaries) == 4L && nrow(coordinates) == 46L &&
    nrow(integration) == 25L && all(is.finite(c(
      summaries$TAMDeviance, summaries$MfrmrDeviance,
      coordinates$SignedDifference,
      integration$TAMQ61MinusQ31, integration$MfrmrQ61MinusQ31
    ))) && all(summaries$MfrmrOracleLogLikAbsoluteDifference <= 1e-9) &&
    all(summaries$MfrmrOracleProbabilityMaximumAbsoluteDifference <= 1e-13)
  list(
    specification = mfrmr_tmc_specification,
    contract_version = mfrmr_tmc_contract,
    status = if (complete) {
      "tam_mml_core_calibration_complete_tolerance_candidate_missing"
    } else {
      "tam_mml_core_calibration_incomplete"
    },
    runtime_identity = runtime,
    plan = plan,
    summaries = summaries,
    coordinates = coordinates,
    integration = integration,
    calibration_complete = complete,
    coordinate_rows_observed = nrow(coordinates),
    comparison_tolerance_frozen = FALSE,
    candidate_bound = FALSE,
    comparison_passed = FALSE,
    hidden_solution_equivalence_inferred = FALSE,
    inference_ready = FALSE,
    dff_fit_rank_invariance_evaluated = FALSE,
    sparse_extension_authorized = FALSE,
    gpcm_extension_authorized = FALSE,
    large_simulation_authorized = FALSE,
    release_authorized = FALSE,
    fits = if (isTRUE(retain_fits)) lapply(runs, `[[`, "fit") else NULL
  )
}
