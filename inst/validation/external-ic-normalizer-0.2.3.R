# mfrmr 0.2.3 repository-only external MML IC normalizer
#
# This pilot helper preserves engine-native criteria and computes the common
# Person-basis AIC/BIC/SABIC panel from deviance, free dimension, and Person
# count. It does not authorize confirmation or infer matched likelihood,
# constraint, observation, or integration identities from shared labels.

mfrmr_external_ic_specification <- "0.2.3-draft.8"
mfrmr_external_ic_contract <- "mfrmr_external_ic_v1"
mfrmr_conquest_ic_contract <- "mfrmr_conquest_ic_handoff_v2"

mfrmr_external_ic_or <- function(value, fallback) {
  if (is.null(value) || length(value) == 0L) fallback else value
}

mfrmr_external_ic_scalar <- function(value) {
  suppressWarnings(as.numeric(value)[1])
}

mfrmr_external_ic_label <- function(value) {
  value <- as.character(value)[1]
  if (is.na(value) || !nzchar(trimws(value))) NA_character_ else trimws(value)
}

mfrmr_external_ic_native_value <- function(native_ic, candidates) {
  if (is.null(native_ic)) return(NA_real_)
  native_ic <- unlist(native_ic, recursive = TRUE, use.names = TRUE)
  hit <- candidates[candidates %in% names(native_ic)][1]
  if (length(hit) == 0L || is.na(hit)) return(NA_real_)
  mfrmr_external_ic_scalar(native_ic[[hit]])
}

mfrmr_external_ic_native_flag <- function(flags, candidates) {
  if (is.null(flags)) return(NA)
  flags <- unlist(flags, recursive = TRUE, use.names = TRUE)
  hit <- candidates[candidates %in% names(flags)][1]
  if (length(hit) == 0L || is.na(hit)) return(NA)
  as.logical(flags[[hit]])[1]
}

mfrmr_external_ic_native_formula <- function(formulas, candidates) {
  if (is.null(formulas)) return(NA_character_)
  formulas <- unlist(formulas, recursive = TRUE, use.names = TRUE)
  hit <- candidates[candidates %in% names(formulas)][1]
  if (length(hit) == 0L || is.na(hit)) return(NA_character_)
  mfrmr_external_ic_label(formulas[[hit]])
}

mfrmr_external_ic_common_panel <- function(deviance, npar, persons) {
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop("Load the mfrmr source package before running this normalizer.",
         call. = FALSE)
  }
  builder <- getFromNamespace("mfrm_ic_common_panel", "mfrmr")
  builder(deviance = deviance, npar = npar, persons = persons)
}

mfrmr_normalize_external_ic <- function(
    engine,
    engine_version,
    run_id,
    model_id,
    method = "MML",
    dimensions = 1L,
    deviance = NA_real_,
    loglik = NA_real_,
    npar,
    persons,
    native_ic = NULL,
    native_formula_ids = NULL,
    native_formula_verified = NULL,
    observation_set_id = NA_character_,
    likelihood_basis_id = NA_character_,
    constraint_basis_id = NA_character_,
    integration_evaluation_id = NA_character_,
    integration_comparison_id = NA_character_,
    convergence_status = c("unverified", "pass", "review", "fail"),
    integration_stability_status = c(
      "not_checked", "pass", "review", "fail"
    ),
    candidate_id = NA_character_,
    evidence_role = c("pilot", "engineering"),
    tolerance = 1e-10) {
  convergence_status <- match.arg(convergence_status)
  integration_stability_status <- match.arg(integration_stability_status)
  evidence_role <- match.arg(evidence_role)
  method <- toupper(as.character(method)[1])
  if (identical(method, "JMLE")) method <- "JML"
  deviance <- mfrmr_external_ic_scalar(deviance)
  loglik <- mfrmr_external_ic_scalar(loglik)
  npar <- mfrmr_external_ic_scalar(npar)
  persons <- mfrmr_external_ic_scalar(persons)
  dimensions <- mfrmr_external_ic_scalar(dimensions)

  if (!is.finite(deviance) && is.finite(loglik)) deviance <- -2 * loglik
  if (!is.finite(loglik) && is.finite(deviance)) loglik <- -deviance / 2
  objective_consistent <- is.finite(deviance) && is.finite(loglik) &&
    abs(deviance + 2 * loglik) <= tolerance * max(1, abs(deviance))

  reasons <- character(0)
  if (!identical(method, "MML")) reasons <- c(reasons, "method_not_mml")
  if (!objective_consistent) {
    reasons <- c(reasons, "loglik_deviance_inconsistent_or_missing")
  }
  if (!is.finite(dimensions) || dimensions < 1 ||
      abs(dimensions - round(dimensions)) > sqrt(.Machine$double.eps)) {
    reasons <- c(reasons, "invalid_dimension_count")
  }

  panel <- if (identical(method, "MML") && objective_consistent) {
    tryCatch(
      mfrmr_external_ic_common_panel(deviance, npar, persons),
      error = function(error) {
        reasons <<- c(reasons, "invalid_npar_or_person_count")
        NULL
      }
    )
  } else {
    NULL
  }
  arithmetic_eligible <- !is.null(panel) && length(reasons) == 0L
  required_ids <- c(
    observation_set_id,
    likelihood_basis_id,
    constraint_basis_id,
    integration_evaluation_id,
    integration_comparison_id
  )
  identity_complete <- all(!is.na(required_ids) & nzchar(trimws(required_ids)))
  if (!identity_complete) reasons <- c(reasons, "comparison_identity_incomplete")
  if (!identical(convergence_status, "pass")) {
    reasons <- c(reasons, paste0("convergence_", convergence_status))
  }
  if (!identical(integration_stability_status, "pass")) {
    reasons <- c(
      reasons,
      paste0("integration_stability_", integration_stability_status)
    )
  }
  comparison_ready <- arithmetic_eligible && identity_complete &&
    identical(convergence_status, "pass") &&
    identical(integration_stability_status, "pass")

  panel_value <- function(name, fallback = NA_real_) {
    if (is.null(panel)) fallback else panel[[name]]
  }
  native_aic <- mfrmr_external_ic_native_value(native_ic, "AIC")
  native_bic <- mfrmr_external_ic_native_value(native_ic, "BIC")
  native_abic <- mfrmr_external_ic_native_value(
    native_ic, c("aBIC", "ABIC", "NativeABIC")
  )
  native_sabic <- mfrmr_external_ic_native_value(
    native_ic, c("SABIC", "saBIC", "NativeSABIC")
  )
  record <- data.frame(
    Specification = mfrmr_external_ic_specification,
    ContractVersion = mfrmr_external_ic_contract,
    EvidenceRole = evidence_role,
    ConfirmationAuthorized = FALSE,
    CandidateId = mfrmr_external_ic_label(candidate_id),
    Engine = mfrmr_external_ic_label(engine),
    EngineVersion = mfrmr_external_ic_label(engine_version),
    RunId = mfrmr_external_ic_label(run_id),
    ModelId = mfrmr_external_ic_label(model_id),
    Method = method,
    Dimensions = if (is.finite(dimensions)) as.integer(round(dimensions)) else
      NA_integer_,
    LogLik = loglik,
    Deviance = deviance,
    Npar = if (is.finite(npar)) as.integer(round(npar)) else NA_integer_,
    Persons = if (is.finite(persons)) as.integer(round(persons)) else
      NA_integer_,
    CommonAIC = panel_value("AIC"),
    CommonBIC = panel_value("BIC"),
    CommonSABIC = panel_value("SABIC"),
    CommonAICFormula = "aic_deviance_plus_2k",
    CommonBICFormula = "bic_person_count",
    CommonSABICFormula = "sclove_n_plus_2_over_24",
    CommonSABICSelectable = comparison_ready && is.finite(persons) &&
      persons > 22,
    NativeAIC = native_aic,
    NativeBIC = native_bic,
    NativeABIC = native_abic,
    NativeSABIC = native_sabic,
    NativeAICFormula = mfrmr_external_ic_native_formula(
      native_formula_ids, "AIC"
    ),
    NativeBICFormula = mfrmr_external_ic_native_formula(
      native_formula_ids, "BIC"
    ),
    NativeABICFormula = mfrmr_external_ic_native_formula(
      native_formula_ids, c("aBIC", "ABIC", "NativeABIC")
    ),
    NativeSABICFormula = mfrmr_external_ic_native_formula(
      native_formula_ids, c("SABIC", "saBIC", "NativeSABIC")
    ),
    NativeAICFormulaVerified = mfrmr_external_ic_native_flag(
      native_formula_verified, "AIC"
    ),
    NativeBICFormulaVerified = mfrmr_external_ic_native_flag(
      native_formula_verified, "BIC"
    ),
    NativeABICFormulaVerified = mfrmr_external_ic_native_flag(
      native_formula_verified, c("aBIC", "ABIC", "NativeABIC")
    ),
    NativeSABICFormulaVerified = mfrmr_external_ic_native_flag(
      native_formula_verified, c("SABIC", "saBIC", "NativeSABIC")
    ),
    ObservationSetId = mfrmr_external_ic_label(observation_set_id),
    LikelihoodBasisId = mfrmr_external_ic_label(likelihood_basis_id),
    ConstraintBasisId = mfrmr_external_ic_label(constraint_basis_id),
    IntegrationEvaluationId = mfrmr_external_ic_label(
      integration_evaluation_id
    ),
    IntegrationComparisonId = mfrmr_external_ic_label(
      integration_comparison_id
    ),
    ConvergenceStatus = convergence_status,
    IntegrationStabilityStatus = integration_stability_status,
    ObjectiveConsistent = objective_consistent,
    ArithmeticEligible = arithmetic_eligible,
    ComparisonIdentityComplete = identity_complete,
    ComparisonReady = comparison_ready,
    Status = if (comparison_ready) "review_ready" else "not_comparable",
    Reason = paste(unique(reasons), collapse = ";"),
    stringsAsFactors = FALSE
  )
  native_values <- unlist(native_ic, recursive = TRUE, use.names = TRUE)
  native <- if (length(native_values) > 0L) {
    data.frame(
      Engine = record$Engine,
      RunId = record$RunId,
      ModelId = record$ModelId,
      NativeName = names(native_values),
      NativeValue = suppressWarnings(as.numeric(native_values)),
      FormulaId = vapply(names(native_values), function(name) {
        mfrmr_external_ic_native_formula(native_formula_ids, name)
      }, character(1)),
      FormulaVerified = vapply(names(native_values), function(name) {
        mfrmr_external_ic_native_flag(native_formula_verified, name)
      }, logical(1)),
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(
      Engine = character(), RunId = character(), ModelId = character(),
      NativeName = character(), NativeValue = numeric(),
      FormulaId = character(),
      FormulaVerified = logical(), stringsAsFactors = FALSE
    )
  }
  out <- list(record = record, native = native)
  class(out) <- c("mfrmr_external_ic_record", class(out))
  out
}

mfrmr_external_ic_from_tam <- function(
    fit,
    run_id,
    model_id,
    observation_set_id = NA_character_,
    likelihood_basis_id = NA_character_,
    constraint_basis_id = NA_character_,
    integration_comparison_id = NA_character_,
    convergence_status = c("unverified", "pass", "review", "fail"),
    integration_stability_status = c(
      "not_checked", "pass", "review", "fail"
    ),
    candidate_id = NA_character_) {
  if (!requireNamespace("TAM", quietly = TRUE)) {
    stop("The TAM adapter requires the TAM package.", call. = FALSE)
  }
  if (!inherits(fit, "tam.mml") || is.null(fit$ic)) {
    stop("`fit` must be a TAM marginal-MML object with an `ic` table.",
         call. = FALSE)
  }
  ic <- as.data.frame(fit$ic, stringsAsFactors = FALSE)
  scalar <- function(names, fallback = NA_real_) {
    hit <- names[names %in% colnames(ic)][1]
    if (length(hit) == 0L || is.na(hit)) return(fallback)
    mfrmr_external_ic_scalar(ic[[hit]][1])
  }
  deviance <- scalar(c("deviance", "Deviance"), fit$deviance)
  loglik <- scalar(c("loglike", "logLik"), -deviance / 2)
  npar <- scalar(c("np", "Npars"))
  persons <- scalar(
    "n",
    nrow(mfrmr_external_ic_or(fit$resp, data.frame()))
  )
  dimensions <- mfrmr_external_ic_scalar(fit$ndim)
  native <- c(
    AIC = scalar("AIC"),
    BIC = scalar("BIC"),
    aBIC = scalar("aBIC"),
    AIC3 = scalar("AIC3"),
    AICc = scalar("AICc"),
    CAIC = scalar("CAIC")
  )
  matches <- function(actual, expected) {
    is.finite(actual) && is.finite(expected) &&
      abs(actual - expected) <= 1e-8 * max(1, abs(expected))
  }
  verified <- c(
    AIC = matches(native[["AIC"]], deviance + 2 * npar),
    BIC = matches(native[["BIC"]], deviance + log(persons) * npar),
    aBIC = matches(
      native[["aBIC"]],
      if (persons > 2) deviance + log((persons - 2) / 24) * npar else
        NA_real_
    )
  )
  qmc <- as.logical(mfrmr_external_ic_or(fit$control$QMC, NA))[1]
  nnodes <- mfrmr_external_ic_scalar(fit$nnodes)
  seed <- mfrmr_external_ic_scalar(fit$control$seed)
  integration_id <- paste0(
    "tam_mml_v1:qmc=", if (is.na(qmc)) "unknown" else tolower(qmc),
    ":nnodes=", if (is.finite(nnodes)) as.integer(nnodes) else "unknown",
    if (isFALSE(qmc)) paste0(
      ":seed=", if (is.finite(seed)) as.integer(seed) else "unknown"
    ) else ""
  )
  mfrmr_normalize_external_ic(
    engine = "TAM",
    engine_version = as.character(utils::packageVersion("TAM")),
    run_id = run_id,
    model_id = model_id,
    method = "MML",
    dimensions = dimensions,
    deviance = deviance,
    loglik = loglik,
    npar = npar,
    persons = persons,
    native_ic = native,
    native_formula_ids = c(
      AIC = "tam_deviance_plus_2k",
      BIC = "tam_deviance_plus_log_n_k",
      aBIC = "tam_deviance_plus_log_n_minus_2_over_24_k",
      AIC3 = "tam_deviance_plus_3k",
      AICc = "tam_native_small_sample_aic",
      CAIC = "tam_deviance_plus_log_n_plus_1_k"
    ),
    native_formula_verified = verified,
    observation_set_id = observation_set_id,
    likelihood_basis_id = likelihood_basis_id,
    constraint_basis_id = constraint_basis_id,
    integration_evaluation_id = integration_id,
    integration_comparison_id = integration_comparison_id,
    convergence_status = match.arg(convergence_status),
    integration_stability_status = match.arg(integration_stability_status),
    candidate_id = candidate_id
  )
}

mfrmr_conquest_external_read_csv <- function(file,
                                              label,
                                              required_columns) {
  file <- as.character(file)[1]
  if (is.na(file) || !nzchar(file) || !file.exists(file)) {
    stop("ConQuest ", label, " CSV does not exist: ", file,
         call. = FALSE)
  }
  table <- tryCatch(
    utils::read.csv(
      file,
      stringsAsFactors = FALSE,
      check.names = FALSE,
      na.strings = c("", "NA")
    ),
    error = function(error) {
      stop("Could not read ConQuest ", label, " CSV: ",
           conditionMessage(error), call. = FALSE)
    }
  )
  missing <- setdiff(required_columns, names(table))
  if (length(missing) > 0L) {
    stop(
      "ConQuest ", label, " CSV is missing required column(s): ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (nrow(table) == 0L) {
    stop("ConQuest ", label, " CSV has no retained rows.", call. = FALSE)
  }
  table
}

mfrmr_conquest_external_numeric <- function(table, column, label) {
  value <- suppressWarnings(as.numeric(table[[column]]))
  if (length(value) != nrow(table) || any(!is.finite(value))) {
    stop("ConQuest ", label, " column `", column,
         "` must contain finite numeric values.", call. = FALSE)
  }
  value
}

mfrmr_conquest_external_integer <- function(value, label, positive = TRUE) {
  tolerance <- sqrt(.Machine$double.eps)
  valid <- is.finite(value) &
    abs(value - round(value)) <= tolerance * pmax(1, abs(value))
  if (positive) valid <- valid & value > 0
  if (!all(valid)) {
    stop("ConQuest ", label, " must contain ",
         if (positive) "positive " else "", "integers.", call. = FALSE)
  }
  as.integer(round(value))
}

mfrmr_conquest_external_unique <- function(value, label) {
  value <- trimws(as.character(value))
  if (anyNA(value) || any(!nzchar(value)) || anyDuplicated(value)) {
    stop("ConQuest ", label,
         " must contain unique, non-empty identifiers.", call. = FALSE)
  }
  value
}

mfrmr_external_ic_from_conquest <- function(
    history_file,
    parameter_file,
    regression_file,
    covariance_file,
    case_file,
    engine_version,
    run_date,
    run_id,
    model_id,
    quadrature_nodes,
    expected_person_ids,
    observation_set_id = NA_character_,
    likelihood_basis_id = NA_character_,
    constraint_basis_id = NA_character_,
    integration_comparison_id = NA_character_,
    convergence_status = c("unverified", "pass", "review", "fail"),
    convergence_evidence_id = NA_character_,
    integration_stability_status = c(
      "not_checked", "pass", "review", "fail"
    ),
    candidate_id = NA_character_,
    handoff_tolerance = 1e-6,
    export_tolerance = NULL) {
  convergence_status <- match.arg(convergence_status)
  integration_stability_status <- match.arg(integration_stability_status)
  engine_version <- mfrmr_external_ic_label(engine_version)
  run_id <- mfrmr_external_ic_label(run_id)
  model_id <- mfrmr_external_ic_label(model_id)
  convergence_evidence_id <- mfrmr_external_ic_label(
    convergence_evidence_id
  )
  if (anyNA(c(engine_version, run_id, model_id))) {
    stop("ConQuest engine version, run ID, and model ID are required.",
         call. = FALSE)
  }
  if (!grepl("^5\\.47\\.5($|[[:space:]])", engine_version)) {
    stop(
      "The ConQuest matrixout IC handoff is currently audited for version 5.47.5 only.",
      call. = FALSE
    )
  }
  run_date <- tryCatch(as.Date(run_date), error = function(error) as.Date(NA))
  if (length(run_date) != 1L || is.na(run_date)) {
    stop("`run_date` must identify the ConQuest execution date.",
         call. = FALSE)
  }
  quadrature_nodes <- mfrmr_external_ic_scalar(quadrature_nodes)
  quadrature_nodes <- mfrmr_conquest_external_integer(
    quadrature_nodes, "quadrature-node count"
  )
  if (!is.null(export_tolerance)) {
    if (!identical(handoff_tolerance, 1e-6)) {
      stop(
        "Supply only `handoff_tolerance`; `export_tolerance` is its deprecated alias.",
        call. = FALSE
      )
    }
    warning(
      "`export_tolerance` is deprecated; use `handoff_tolerance`. It is not an export-resolution or cross-engine tolerance.",
      call. = FALSE
    )
    handoff_tolerance <- export_tolerance
  }
  handoff_tolerance <- mfrmr_external_ic_scalar(handoff_tolerance)
  if (!is.finite(handoff_tolerance) || handoff_tolerance <= 0) {
    stop("`handoff_tolerance` must be a positive finite number.",
         call. = FALSE)
  }
  if (identical(convergence_status, "pass") &&
      is.na(convergence_evidence_id)) {
    stop(
      "`convergence_evidence_id` is required when ConQuest convergence is marked `pass`.",
      call. = FALSE
    )
  }

  history <- mfrmr_conquest_external_read_csv(
    history_file,
    "matrixout history",
    c("RowLabels", "Run Number", "Iteration")
  )
  if (ncol(history) < 5L) {
    stop(
      "ConQuest matrixout history must contain row labels, run, iteration, objective, and at least one estimated parameter.",
      call. = FALSE
    )
  }
  if (!identical(names(history)[1:3],
                 c("RowLabels", "Run Number", "Iteration"))) {
    stop(
      "ConQuest matrixout history must begin with `RowLabels`, `Run Number`, and `Iteration`.",
      call. = FALSE
    )
  }
  objective_native_header <- names(history)[4]
  if (!objective_native_header %in% c("LogLikelihood", "Deviance")) {
    stop(
      "The fourth ConQuest matrixout-history column is not a recognized objective field.",
      call. = FALSE
    )
  }
  run_number <- mfrmr_conquest_external_integer(
    mfrmr_conquest_external_numeric(
      history, "Run Number", "matrixout history"
    ),
    "history run numbers"
  )
  iteration <- mfrmr_conquest_external_integer(
    mfrmr_conquest_external_numeric(
      history, "Iteration", "matrixout history"
    ),
    "history iterations"
  )
  objective <- mfrmr_conquest_external_numeric(
    history, objective_native_header, "matrixout history"
  )
  if (any(objective < 0)) {
    stop(
      "ConQuest matrixout objective is not on the non-negative deviance scale required by this handoff.",
      call. = FALSE
    )
  }
  history_key <- paste(run_number, iteration, sep = ":")
  if (anyDuplicated(history_key) ||
      !identical(order(run_number, iteration), seq_along(run_number))) {
    stop(
      "ConQuest matrixout history must contain unique rows ordered by run and iteration.",
      call. = FALSE
    )
  }

  parameter <- mfrmr_conquest_external_read_csv(
    parameter_file, "parameter", c("P", "Estimate", "Label")
  )
  regression <- mfrmr_conquest_external_read_csv(
    regression_file,
    "regression",
    c("Dimension", "Regressor", "Estimate")
  )
  covariance <- mfrmr_conquest_external_read_csv(
    covariance_file,
    "covariance",
    c("Dim1", "Dim2", "Covariance")
  )
  cases <- mfrmr_conquest_external_read_csv(
    case_file,
    "case-EAP",
    c("SeqNum", "PID", "weight_raw", "weight_scaled")
  )

  parameter_index <- mfrmr_conquest_external_integer(
    mfrmr_conquest_external_numeric(parameter, "P", "parameter"),
    "parameter indices"
  )
  if (anyDuplicated(parameter_index)) {
    stop("ConQuest parameter indices must be unique.", call. = FALSE)
  }
  parameter_estimate <- mfrmr_conquest_external_numeric(
    parameter, "Estimate", "parameter"
  )
  mfrmr_conquest_external_unique(parameter$Label, "parameter labels")
  regression_dimension <- mfrmr_conquest_external_integer(
    mfrmr_conquest_external_numeric(
      regression, "Dimension", "regression"
    ),
    "regression dimensions"
  )
  regression_index <- mfrmr_conquest_external_integer(
    mfrmr_conquest_external_numeric(
      regression, "Regressor", "regression"
    ),
    "regressor indices"
  )
  if (any(regression_dimension != 1L) ||
      anyDuplicated(paste(regression_dimension, regression_index, sep = ":"))) {
    stop(
      "The ConQuest IC adapter supports unique unidimensional regression rows only.",
      call. = FALSE
    )
  }
  regression_estimate <- mfrmr_conquest_external_numeric(
    regression, "Estimate", "regression"
  )
  covariance_dim1 <- mfrmr_conquest_external_integer(
    mfrmr_conquest_external_numeric(covariance, "Dim1", "covariance"),
    "covariance row dimensions"
  )
  covariance_dim2 <- mfrmr_conquest_external_integer(
    mfrmr_conquest_external_numeric(covariance, "Dim2", "covariance"),
    "covariance column dimensions"
  )
  if (nrow(covariance) != 1L || covariance_dim1 != 1L ||
      covariance_dim2 != 1L) {
    stop(
      "The ConQuest IC adapter requires one unidimensional covariance row.",
      call. = FALSE
    )
  }
  covariance_estimate <- mfrmr_conquest_external_numeric(
    covariance, "Covariance", "covariance"
  )
  case_sequence <- mfrmr_conquest_external_integer(
    mfrmr_conquest_external_numeric(cases, "SeqNum", "case-EAP"),
    "case sequence numbers"
  )
  if (anyDuplicated(case_sequence)) {
    stop("ConQuest case sequence numbers must be unique.", call. = FALSE)
  }
  case_ids <- mfrmr_conquest_external_unique(cases$PID, "case PIDs")
  expected_person_ids <- mfrmr_conquest_external_unique(
    expected_person_ids, "expected bundle Person IDs"
  )
  if (!identical(case_ids, expected_person_ids)) {
    stop(
      "ConQuest case PIDs do not exactly match the expected bundle Person IDs.",
      call. = FALSE
    )
  }
  for (weight_column in c("weight_raw", "weight_scaled")) {
    weight <- mfrmr_conquest_external_numeric(
      cases, weight_column, "case-EAP"
    )
    if (any(abs(weight - 1) > handoff_tolerance)) {
      stop(
        "The ConQuest IC adapter currently requires unit case weights.",
        call. = FALSE
      )
    }
  }

  exported_free_vector <- c(
    regression_estimate,
    covariance_estimate,
    parameter_estimate
  )
  npar_exports <- length(exported_free_vector)
  npar_history <- ncol(history) - 4L
  if (npar_history != npar_exports) {
    stop(
      "ConQuest free dimension disagrees between matrixout history and native parameter exports.",
      call. = FALSE
    )
  }
  final_index <- nrow(history)
  history_final_vector <- suppressWarnings(as.numeric(unlist(
    history[final_index, seq.int(5L, ncol(history)), drop = FALSE],
    recursive = FALSE,
    use.names = FALSE
  )))
  if (length(history_final_vector) != npar_exports ||
      any(!is.finite(history_final_vector)) ||
      any(abs(history_final_vector - exported_free_vector) >
          handoff_tolerance * pmax(1, abs(exported_free_vector)))) {
    stop(
      "ConQuest final history vector does not match the regression, covariance, and parameter exports.",
      call. = FALSE
    )
  }

  integration_evaluation_id <- paste0(
    "conquest_mml_v1:quadrature:nodes=", quadrature_nodes,
    ":matrixout_history_csv"
  )
  out <- mfrmr_normalize_external_ic(
    engine = "ConQuest",
    engine_version = engine_version,
    run_id = run_id,
    model_id = model_id,
    method = "MML",
    dimensions = 1L,
    deviance = objective[final_index],
    loglik = -objective[final_index] / 2,
    npar = npar_exports,
    persons = length(expected_person_ids),
    observation_set_id = observation_set_id,
    likelihood_basis_id = likelihood_basis_id,
    constraint_basis_id = constraint_basis_id,
    integration_evaluation_id = integration_evaluation_id,
    integration_comparison_id = integration_comparison_id,
    convergence_status = convergence_status,
    integration_stability_status = integration_stability_status,
    candidate_id = candidate_id
  )
  artifact_files <- c(
    history_file,
    parameter_file,
    regression_file,
    covariance_file,
    case_file
  )
  out$audit <- list(
    ContractVersion = mfrmr_conquest_ic_contract,
    RunDate = format(run_date, "%Y-%m-%d"),
    ObjectiveSource = "estimate_matrixout_history_column_3",
    ObjectiveNativeHeader = objective_native_header,
    ObjectiveInterpretation = paste0(
      "deviance_by_ConQuest_manual_4.9.2; native_5.47.5_CSV_header_",
      objective_native_header
    ),
    InternalHandoffTolerance = handoff_tolerance,
    ObjectiveExportResolution = NA_real_,
    ObjectiveExportResolutionEstablished = FALSE,
    ObjectiveExportRoundingRule = "unknown",
    HandoffToleranceIsCrossEngineTolerance = FALSE,
    HistoryRows = nrow(history),
    FinalRun = run_number[final_index],
    FinalIteration = iteration[final_index],
    NparHistory = npar_history,
    NparExports = npar_exports,
    ParameterRows = nrow(parameter),
    RegressionRows = nrow(regression),
    CovarianceRows = nrow(covariance),
    PersonsCaseExport = nrow(cases),
    PersonsExpected = length(expected_person_ids),
    PersonIdsMatched = TRUE,
    FreeVectorMatched = TRUE,
    ConvergenceEvidenceId = convergence_evidence_id,
    ArtifactFingerprints = data.frame(
      Artifact = basename(as.character(artifact_files)),
      Algorithm = "md5",
      Digest = unname(tools::md5sum(artifact_files)),
      stringsAsFactors = FALSE
    )
  )
  out
}

mfrmr_external_ic_from_mfrmr <- function(
    fit,
    run_id,
    model_id,
    observation_set_id = NA_character_,
    likelihood_basis_id = NA_character_,
    constraint_basis_id = NA_character_,
    integration_comparison_id = NA_character_,
    integration_stability_status = c(
      "not_checked", "pass", "review", "fail"
    ),
    candidate_id = NA_character_) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must inherit from `mfrm_fit`.", call. = FALSE)
  }
  summary_row <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
  if (nrow(summary_row) == 0L) {
    stop("The mfrmr fit has no summary row.", call. = FALSE)
  }
  summary_row <- summary_row[1, , drop = FALSE]
  if (!"ICContractVersion" %in% names(summary_row) ||
      !identical(
        as.character(summary_row$ICContractVersion[1]),
        "mfrmr_ic_person_v2"
      )) {
    stop("The mfrmr fit does not carry the current v2 IC contract.",
         call. = FALSE)
  }
  integration_stability_status <- match.arg(integration_stability_status)
  ic_selectable <- "ICSelectable" %in% names(summary_row) &&
    isTRUE(as.logical(summary_row$ICSelectable[1]))
  if (!ic_selectable && identical(integration_stability_status, "pass")) {
    integration_stability_status <- "review"
  }
  inference_ready <- "InferenceReady" %in% names(summary_row) &&
    isTRUE(as.logical(summary_row$InferenceReady[1]))
  panel <- mfrmr_external_ic_common_panel(
    summary_row$Deviance[1], summary_row$Npar[1], summary_row$Persons[1]
  )
  matches <- function(field) {
    actual <- mfrmr_external_ic_scalar(summary_row[[field]][1])
    expected <- mfrmr_external_ic_scalar(panel[[field]])
    is.finite(actual) && is.finite(expected) &&
      abs(actual - expected) <= 1e-10 * max(1, abs(expected))
  }
  mfrmr_normalize_external_ic(
    engine = "mfrmr",
    engine_version = as.character(utils::packageVersion("mfrmr")),
    run_id = run_id,
    model_id = model_id,
    method = as.character(summary_row$Method[1]),
    dimensions = 1L,
    deviance = summary_row$Deviance[1],
    loglik = summary_row$LogLik[1],
    npar = summary_row$Npar[1],
    persons = summary_row$Persons[1],
    native_ic = c(
      AIC = summary_row$AIC[1],
      BIC = summary_row$BIC[1],
      SABIC = summary_row$SABIC[1]
    ),
    native_formula_ids = c(
      AIC = as.character(summary_row$AICFormula[1]),
      BIC = as.character(summary_row$BICFormula[1]),
      SABIC = as.character(summary_row$SABICFormula[1])
    ),
    native_formula_verified = c(
      AIC = matches("AIC"),
      BIC = matches("BIC"),
      SABIC = matches("SABIC")
    ),
    observation_set_id = observation_set_id,
    likelihood_basis_id = likelihood_basis_id,
    constraint_basis_id = constraint_basis_id,
    integration_evaluation_id = as.character(
      summary_row$IntegrationEvaluationId[1]
    ),
    integration_comparison_id = integration_comparison_id,
    convergence_status = if (inference_ready) "pass" else "review",
    integration_stability_status = integration_stability_status,
    candidate_id = candidate_id
  )
}

mfrmr_compare_external_ic <- function(..., labels = NULL) {
  records <- list(...)
  if (length(records) < 2L) {
    stop("At least two normalized external IC records are required.",
         call. = FALSE)
  }
  valid <- vapply(records, inherits, logical(1), "mfrmr_external_ic_record")
  if (!all(valid)) {
    stop("Every input must be returned by `mfrmr_normalize_external_ic()`.",
         call. = FALSE)
  }
  table <- do.call(rbind, lapply(records, `[[`, "record"))
  rownames(table) <- NULL
  if (is.null(labels)) labels <- table$ModelId
  if (length(labels) != nrow(table) || anyNA(labels) || any(!nzchar(labels))) {
    stop("`labels` must supply one non-empty label per record.", call. = FALSE)
  }
  table$Label <- as.character(labels)
  identity_fields <- c(
    "ObservationSetId", "LikelihoodBasisId", "ConstraintBasisId",
    "IntegrationComparisonId", "CommonAICFormula", "CommonBICFormula",
    "CommonSABICFormula", "Persons"
  )
  identity_checks <- vapply(identity_fields, function(field) {
    values <- table[[field]]
    all(!is.na(values)) && length(unique(values)) == 1L
  }, logical(1))
  comparable <- all(table$ComparisonReady) && all(identity_checks)
  table$Comparable <- comparable
  criteria <- c("AIC", "BIC", "SABIC")
  preferred <- data.frame(
    Criterion = character(), Preferred = character(),
    stringsAsFactors = FALSE
  )
  for (criterion in criteria) {
    value_field <- paste0("Common", criterion)
    delta_field <- paste0("Delta", criterion)
    weight_field <- paste0(criterion, "Weight")
    criterion_ready <- comparable && all(is.finite(table[[value_field]])) &&
      (!identical(criterion, "SABIC") || all(table$CommonSABICSelectable))
    if (criterion_ready) {
      values <- table[[value_field]]
      table[[delta_field]] <- values - min(values)
      raw_weights <- exp(-0.5 * table[[delta_field]])
      table[[weight_field]] <- raw_weights / sum(raw_weights)
      preferred <- rbind(
        preferred,
        data.frame(
          Criterion = criterion,
          Preferred = table$Label[which.min(values)],
          stringsAsFactors = FALSE
        )
      )
    } else {
      table[[delta_field]] <- NA_real_
      table[[weight_field]] <- NA_real_
    }
  }
  reasons <- character(0)
  if (!all(table$ComparisonReady)) reasons <- c(reasons, "record_not_ready")
  failed_identity <- names(identity_checks)[!identity_checks]
  if (length(failed_identity) > 0L) {
    reasons <- c(
      reasons,
      paste0("identity_mismatch:", paste(failed_identity, collapse = ","))
    )
  }
  out <- list(
    specification = mfrmr_external_ic_specification,
    contract_version = mfrmr_external_ic_contract,
    evidence_role = "pilot",
    confirmation_authorized = FALSE,
    table = table,
    identity_checks = identity_checks,
    comparable = comparable,
    preferred = preferred,
    status = "review",
    reason = paste(reasons, collapse = ";")
  )
  class(out) <- c("mfrmr_external_ic_comparison", class(out))
  out
}

print.mfrmr_external_ic_record <- function(x, digits = 6L, ...) {
  cat("mfrmr 0.2.3 external IC normalization record\n")
  display <- x$record[, c(
    "Engine", "EngineVersion", "ModelId", "Method", "Dimensions",
    "Deviance", "Npar", "Persons", "CommonAIC", "CommonBIC",
    "CommonSABIC", "NativeAIC", "NativeBIC", "NativeABIC",
    "ComparisonReady", "Status", "Reason"
  ), drop = FALSE]
  numeric_columns <- vapply(display, is.numeric, logical(1))
  display[numeric_columns] <- lapply(display[numeric_columns], round, digits)
  print(display, row.names = FALSE)
  cat("  Pilot only: confirmation is not authorized.\n")
  invisible(x)
}

print.mfrmr_external_ic_comparison <- function(x, digits = 6L, ...) {
  cat("mfrmr 0.2.3 normalized external IC comparison\n")
  cat("  Comparable within pilot contract:", x$comparable, "\n")
  cat("  Status:", x$status, "\n")
  if (nzchar(x$reason)) cat("  Reason:", x$reason, "\n")
  display <- x$table[, c(
    "Label", "Engine", "ModelId", "Dimensions", "CommonAIC", "CommonBIC",
    "CommonSABIC", "DeltaAIC", "DeltaBIC", "DeltaSABIC", "Comparable"
  ), drop = FALSE]
  numeric_columns <- vapply(display, is.numeric, logical(1))
  display[numeric_columns] <- lapply(display[numeric_columns], round, digits)
  print(display, row.names = FALSE)
  cat("  Native criteria remain separately named in `$table`.\n")
  cat("  Pilot only: confirmation is not authorized.\n")
  invisible(x)
}
