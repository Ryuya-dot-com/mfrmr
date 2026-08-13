# Minimal diagnostic following the prospective Rater-anchor sparse smoke.
#
# This is deliberately not a generalized framework. It asks only whether the
# complete-design gradient hold responds to the package-default maxit = 400,
# and which observed response patterns create sparse-design extreme Persons.

mfrmr_rasmd_specification <- "0.2.3-draft.1"
mfrmr_rasmd_contract <- "mfrmr_rater_anchor_sparse_smoke_minimal_diagnostic_v1"

mfrmr_rasmd_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_rasmd_require_support <- function() {
  required <- c(
    "mfrmr_rasp_registry", "mfrmr_rasp_execution_manifest",
    "mfrmr_rass_capture", "mfrmr_rass_select_link_persons",
    "mfrmr_rass_readiness", "mfrmr_rass_recovery",
    "mfrmr_rasps_generate_complete", "mfrmr_rasps_apply_design",
    "mfrmr_rasps_build_anchors", "fit_mfrm"
  )
  source_environment <- environment(mfrmr_rasmd_require_support)
  missing <- required[!vapply(
    required, exists, logical(1), envir = source_environment,
    mode = "function", inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Load the prospective contract, pilot helpers, smoke runner, and ",
      "development package before the minimal diagnostic; missing: ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package `digest` is required for diagnostic identities.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_rasmd_named_parameters <- function(fit, anchor_levels) {
  person <- as.data.frame(fit$facets$person %||% data.frame(),
                          stringsAsFactors = FALSE)
  others <- as.data.frame(fit$facets$others %||% data.frame(),
                          stringsAsFactors = FALSE)
  rater <- others[others$Facet == "Rater", c("Level", "Estimate"),
                  drop = FALSE]
  rater <- rater[!as.character(rater$Level) %in% anchor_levels,
                 , drop = FALSE]
  data.frame(
    ParameterId = c(
      paste0("Person:", as.character(person$Person)),
      paste0("FreeRater:", as.character(rater$Level))
    ),
    Block = c(rep("Person", nrow(person)), rep("FreeRater", nrow(rater))),
    Estimate = c(as.numeric(person$Estimate), as.numeric(rater$Estimate)),
    stringsAsFactors = FALSE
  )
}

mfrmr_rasmd_fit_complete <- function(row, generated, maxit) {
  row <- as.list(row)
  designed <- mfrmr_rasps_apply_design(generated, row)
  anchor_info <- mfrmr_rasps_build_anchors(generated$truth, row)
  payload <- anchor_info$anchors[c("Facet", "Level", "Anchor")]
  supplied <- if (nrow(payload) > 0L) payload else NULL
  started <- proc.time()
  captured <- mfrmr_rass_capture(fit_mfrm(
    designed$data, "Person", c("Rater", "Criterion"), "Score",
    rating_min = 1L, rating_max = 4L, keep_original = TRUE,
    model = "PCM", method = "JML", step_facet = "Criterion",
    anchors = supplied, min_common_anchors = 1L, anchor_policy = "warn",
    maxit = as.integer(maxit), reltol = 1e-9
  ))
  elapsed <- unname((proc.time() - started)[["elapsed"]])
  if (inherits(captured$value, "error")) {
    return(list(
      result = data.frame(
        AnchorConfig = row$AnchorConfig, Maxit = as.integer(maxit),
        FitReturned = FALSE, InferenceReady = FALSE,
        Error = conditionMessage(captured$value), LogLik = NA_real_,
        Warnings = paste(captured$warnings, collapse = " | "),
        TerminalGradientSupNorm = NA_real_,
        GradientReviewTolerance = NA_real_, ConvergenceStatus = NA_character_,
        FreeRaterAbsoluteRMSE = NA_real_, PersonAbsoluteRMSE = NA_real_,
        PersonRankSpearman = NA_real_, FitElapsedSeconds = elapsed,
        stringsAsFactors = FALSE
      ),
      parameters = data.frame(), stages = data.frame()
    ))
  }
  fit <- captured$value
  summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
  readiness <- mfrmr_rass_readiness(fit)
  recovery <- mfrmr_rass_recovery(
    fit, generated$truth, as.character(payload$Level)
  )
  stages <- as.data.frame(
    fit$opt$optimizer_polish$Stages %||% data.frame(),
    stringsAsFactors = FALSE
  )
  if (nrow(stages) > 0L) {
    stages$AnchorConfig <- row$AnchorConfig
    stages$Maxit <- as.integer(maxit)
  }
  result <- data.frame(
    AnchorConfig = row$AnchorConfig,
    Maxit = as.integer(maxit),
    FitReturned = TRUE,
    InferenceReady = readiness$InferenceReady,
    Error = NA_character_,
    Warnings = paste(captured$warnings, collapse = " | "),
    LogLik = as.numeric(summary$LogLik[[1L]]),
    TerminalGradientSupNorm = as.numeric(
      summary$TerminalGradientSupNorm[[1L]]
    ),
    GradientReviewTolerance = as.numeric(
      summary$GradientReviewTolerance[[1L]]
    ),
    ConvergenceStatus = as.character(summary$ConvergenceStatus[[1L]]),
    FreeRaterAbsoluteRMSE = recovery$FreeRaterAbsoluteRMSE,
    PersonAbsoluteRMSE = recovery$PersonAbsoluteRMSE,
    PersonRankSpearman = recovery$PersonRankSpearman,
    FitElapsedSeconds = elapsed,
    stringsAsFactors = FALSE
  )
  parameters <- mfrmr_rasmd_named_parameters(
    fit, as.character(payload$Level)
  )
  parameters$AnchorConfig <- row$AnchorConfig
  parameters$Maxit <- as.integer(maxit)
  list(result = result, parameters = parameters, stages = stages)
}

mfrmr_rasmd_indeterminate_comparison <- function(config, low, high, reason) {
  data.frame(
    AnchorConfig = config,
    ComparisonStatus = "indeterminate",
    ComparisonReason = as.character(reason),
    Gradient200 = NA_real_, Gradient400 = NA_real_,
    GradientPass400 = NA,
    LogLikDelta400Minus200 = NA_real_,
    PersonMaxAbsEstimateDelta = NA_real_,
    FreeRaterMaxAbsEstimateDelta = NA_real_,
    FreeRaterRMSEDelta = NA_real_, PersonRMSEDelta = NA_real_,
    PersonRankDelta = NA_real_,
    InferenceReady200 = isTRUE(low$InferenceReady[[1L]]),
    InferenceReady400 = isTRUE(high$InferenceReady[[1L]]),
    stringsAsFactors = FALSE
  )
}

mfrmr_rasmd_compare_budgets <- function(fit_results, parameters) {
  configs <- unique(fit_results$AnchorConfig)
  rows <- lapply(configs, function(config) {
    low <- fit_results[
      fit_results$AnchorConfig == config & fit_results$Maxit == 200L,
      , drop = FALSE
    ]
    high <- fit_results[
      fit_results$AnchorConfig == config & fit_results$Maxit == 400L,
      , drop = FALSE
    ]
    mfrmr_rasmd_assert(
      nrow(low) == 1L && nrow(high) == 1L,
      paste0("Expected one maxit comparison pair for ", config, ".")
    )

    if (!isTRUE(low$FitReturned[[1L]]) || !isTRUE(high$FitReturned[[1L]])) {
      failed <- c(
        if (!isTRUE(low$FitReturned[[1L]])) "maxit_200" else character(0),
        if (!isTRUE(high$FitReturned[[1L]])) "maxit_400" else character(0)
      )
      return(mfrmr_rasmd_indeterminate_comparison(
        config, low, high,
        paste0("fit_not_returned:", paste(failed, collapse = ","))
      ))
    }

    low_par <- parameters[
      parameters$AnchorConfig == config & parameters$Maxit == 200L,
      , drop = FALSE
    ]
    high_par <- parameters[
      parameters$AnchorConfig == config & parameters$Maxit == 400L,
      , drop = FALSE
    ]
    matched <- match(low_par$ParameterId, high_par$ParameterId)
    if (nrow(low_par) == 0L || nrow(high_par) == 0L ||
        anyDuplicated(low_par$ParameterId) ||
        anyDuplicated(high_par$ParameterId) ||
        anyNA(matched) ||
        !all(low_par$Block %in% c("Person", "FreeRater")) ||
        !identical(low_par$Block, high_par$Block[matched])) {
      return(mfrmr_rasmd_indeterminate_comparison(
        config, low, high, "parameter_contract_failed"
      ))
    }
    delta <- high_par$Estimate[matched] - low_par$Estimate
    person <- low_par$Block == "Person"
    rater <- low_par$Block == "FreeRater"
    required_metrics <- c(
      low$TerminalGradientSupNorm, high$TerminalGradientSupNorm,
      high$GradientReviewTolerance, low$LogLik, high$LogLik,
      low$FreeRaterAbsoluteRMSE, high$FreeRaterAbsoluteRMSE,
      low$PersonAbsoluteRMSE, high$PersonAbsoluteRMSE,
      low$PersonRankSpearman, high$PersonRankSpearman,
      delta
    )
    if (!any(person) || !any(rater) || !all(is.finite(required_metrics))) {
      return(mfrmr_rasmd_indeterminate_comparison(
        config, low, high, "comparison_metric_unavailable"
      ))
    }
    data.frame(
      AnchorConfig = config,
      ComparisonStatus = "compared",
      ComparisonReason = NA_character_,
      Gradient200 = low$TerminalGradientSupNorm,
      Gradient400 = high$TerminalGradientSupNorm,
      GradientPass400 = high$TerminalGradientSupNorm <=
        high$GradientReviewTolerance,
      LogLikDelta400Minus200 = high$LogLik - low$LogLik,
      PersonMaxAbsEstimateDelta = max(abs(delta[person]), na.rm = TRUE),
      FreeRaterMaxAbsEstimateDelta = max(abs(delta[rater]), na.rm = TRUE),
      FreeRaterRMSEDelta = high$FreeRaterAbsoluteRMSE -
        low$FreeRaterAbsoluteRMSE,
      PersonRMSEDelta = high$PersonAbsoluteRMSE - low$PersonAbsoluteRMSE,
      PersonRankDelta = high$PersonRankSpearman - low$PersonRankSpearman,
      InferenceReady200 = low$InferenceReady,
      InferenceReady400 = high$InferenceReady,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_rasmd_sparse_patterns <- function(generated, manifest) {
  design_ids <- c("sparse_link05_range", "sparse_pair_cycle")
  detail_rows <- list()
  load_rows <- list()
  summary_rows <- list()
  for (design_id in design_ids) {
    row <- manifest[manifest$DesignId == design_id, , drop = FALSE][1L, ]
    designed <- mfrmr_rasps_apply_design(generated, row)
    data <- designed$data
    people <- unique(as.character(data$Person))
    link <- mfrmr_rass_select_link_persons(
      generated$truth$person, row$LinkPersons, row$LinkSelection
    )
    person_rows <- lapply(people, function(person) {
      x <- data[as.character(data$Person) == person, , drop = FALSE]
      score <- as.numeric(x$Score)
      data.frame(
        DesignId = design_id, Person = person,
        ResponseRows = nrow(x), RaterN = length(unique(x$Rater)),
        LinkPerson = person %in% link,
        ExtremeHigh = all(score == 4), ExtremeLow = all(score == 1),
        ScoreMean = mean(score),
        TrueTheta = as.numeric(generated$truth$person[[person]]),
        stringsAsFactors = FALSE
      )
    })
    detail <- do.call(rbind, person_rows)
    detail$Extreme <- detail$ExtremeHigh | detail$ExtremeLow
    extreme_people <- detail$Person[detail$Extreme]
    assignments <- unique(data[c("Person", "Rater")])
    assignments$Extreme <- as.character(assignments$Person) %in% extreme_people
    load <- stats::aggregate(
      Extreme ~ Rater, data = assignments, FUN = sum
    )
    load$DesignId <- design_id
    summary <- data.frame(
      DesignId = design_id,
      PersonN = nrow(detail),
      ExtremeHighN = sum(detail$ExtremeHigh),
      ExtremeLowN = sum(detail$ExtremeLow),
      ExtremeTotalN = sum(detail$Extreme),
      ExtremeLinkPersonN = sum(detail$Extreme & detail$LinkPerson),
      ExtremeNonlinkPersonN = sum(detail$Extreme & !detail$LinkPerson),
      ExtremeTrueThetaMin = min(detail$TrueTheta[detail$Extreme]),
      ExtremeTrueThetaMax = max(detail$TrueTheta[detail$Extreme]),
      RaterExtremeLoadMin = min(load$Extreme),
      RaterExtremeLoadMax = max(load$Extreme),
      stringsAsFactors = FALSE
    )
    detail_rows[[design_id]] <- detail
    load_rows[[design_id]] <- load
    summary_rows[[design_id]] <- summary
  }
  list(
    summary = do.call(rbind, summary_rows),
    extreme_persons = do.call(rbind, detail_rows)[
      do.call(rbind, detail_rows)$Extreme, , drop = FALSE
    ],
    rater_load = do.call(rbind, load_rows)
  )
}

mfrmr_run_rater_anchor_sparse_smoke_minimal_diagnostic <- function(
    execute = FALSE, progress = interactive()) {
  mfrmr_rasmd_require_support()
  registry <- mfrmr_rasp_registry()
  manifest <- mfrmr_rasp_execution_manifest(registry, "smoke")
  if (!isTRUE(execute)) {
    return(list(
      Specification = mfrmr_rasmd_specification,
      Contract = mfrmr_rasmd_contract,
      PlannedFits = 8L, results = data.frame(), comparison = data.frame(),
      stages = data.frame(), sparse = list(), DiagnosticExecuted = FALSE,
      FeasibilityHandoffAuthorized = FALSE,
      AppropriateAnchorRateSelected = FALSE,
      ConfirmationAuthorized = FALSE
    ))
  }
  generated <- mfrmr_rasps_generate_complete(unique(manifest$DataSeed))
  complete <- manifest[manifest$DesignId == "complete", , drop = FALSE]
  fits <- vector("list", nrow(complete) * 2L)
  cursor <- 0L
  for (i in seq_len(nrow(complete))) {
    for (maxit in c(200L, 400L)) {
      cursor <- cursor + 1L
      if (isTRUE(progress)) {
        message("[", cursor, "/8] ", complete$AnchorConfig[[i]],
                " maxit=", maxit)
      }
      fits[[cursor]] <- mfrmr_rasmd_fit_complete(
        complete[i, ], generated, maxit
      )
    }
  }
  results <- do.call(rbind, lapply(fits, `[[`, "result"))
  parameters <- do.call(rbind, lapply(fits, `[[`, "parameters"))
  stages <- do.call(rbind, lapply(fits, `[[`, "stages"))
  comparison <- mfrmr_rasmd_compare_budgets(results, parameters)
  sparse <- mfrmr_rasmd_sparse_patterns(generated, manifest)
  payload <- list(
    results = results[, setdiff(names(results), "FitElapsedSeconds"),
                      drop = FALSE],
    comparison = comparison, stages = stages[, setdiff(
      names(stages), "ElapsedSeconds"
    ), drop = FALSE], sparse = sparse
  )
  list(
    Specification = mfrmr_rasmd_specification,
    Contract = mfrmr_rasmd_contract,
    RegistrySHA256 = registry$RegistrySHA256,
    ManifestSHA256 = mfrmr_rasp_manifest_hash(manifest),
    PlannedFits = 8L, results = results, comparison = comparison,
    stages = stages, sparse = sparse,
    EvidenceSHA256 = digest::digest(payload, algo = "sha256"),
    DiagnosticExecuted = TRUE,
    FeasibilityHandoffAuthorized = FALSE,
    AppropriateAnchorRateSelected = FALSE,
    ConfirmationAuthorized = FALSE
  )
}
