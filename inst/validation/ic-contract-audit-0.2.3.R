# mfrmr 0.2.3 information-criterion contract audit
#
# Source from the package repository root:
#
#   source("inst/validation/ic-contract-audit-0.2.3.R")
#   audit <- mfrmr_run_ic_contract_fixture_audit(".")
#   print(audit)
#
# The fixture audit is repository-only planning evidence. It checks exact
# arithmetic and fail-closed policy decisions; it is not an integration pilot
# and does not authorize release confirmation.

mfrmr_ic_contract_version <- "mfrmr_ic_person_v2"

mfrmr_ic_formula_identifiers <- c(
  AIC = "aic_deviance_plus_2k",
  BIC = "bic_person_count",
  SABIC = "sclove_n_plus_2_over_24"
)

mfrmr_ic_fixture_required_columns <- c(
  "FixtureId", "Description", "FormulaGroup", "Method", "WeightPolicy",
  "ContractVersion", "LogLik", "Npar", "Persons", "ResponseRows",
  "WeightedResponseTotal", "ExpectedPanelAvailable", "ExpectedDeviance",
  "ExpectedAIC", "ExpectedBIC", "ExpectedSABIC", "ExpectedICSampleSize",
  "ExpectedICSampleSizeBasis", "ExpectedICEligible",
  "ExpectedSABICSelectable", "ExpectedStatus", "QuadraturePoints",
  "ExpectedICSelectable", "ExpectedIntegrationTier",
  "ExpectedIntegrationStatus", "ExpectedIntegrationSelectable"
)

mfrmr_ic_as_flag <- function(x, field) {
  value <- toupper(trimws(as.character(x)))
  if (length(value) != 1L || is.na(value) || !value %in% c("TRUE", "FALSE")) {
    stop("`", field, "` must contain only TRUE or FALSE.", call. = FALSE)
  }
  identical(value, "TRUE")
}

mfrmr_ic_common_panel <- function(loglik, npar, persons) {
  values <- c(loglik = loglik, npar = npar, persons = persons)
  if (length(values) != 3L || any(!is.finite(values))) {
    stop("`loglik`, `npar`, and `persons` must be finite scalars.", call. = FALSE)
  }
  if (npar < 0 || abs(npar - round(npar)) > sqrt(.Machine$double.eps)) {
    stop("`npar` must be a non-negative integer.", call. = FALSE)
  }
  if (persons < 1 || abs(persons - round(persons)) > sqrt(.Machine$double.eps)) {
    stop("`persons` must be a positive integer.", call. = FALSE)
  }

  deviance <- -2 * loglik
  c(
    Deviance = deviance,
    AIC = deviance + 2 * npar,
    BIC = deviance + log(persons) * npar,
    SABIC = deviance + log((persons + 2) / 24) * npar
  )
}

mfrmr_ic_target_integration <- function(method,
                                        contract_version,
                                        quadrature_points) {
  method <- toupper(trimws(as.character(method)[1]))
  contract_version <- trimws(as.character(contract_version)[1])
  quadrature_points <- suppressWarnings(as.numeric(quadrature_points)[1])
  if (!identical(contract_version, mfrmr_ic_contract_version)) {
    return(list(
      quadrature_points = NA_integer_, tier = "legacy_or_unknown",
      status = "legacy_or_unknown", selectable = FALSE
    ))
  }
  if (!identical(method, "MML")) {
    return(list(
      quadrature_points = NA_integer_, tier = "not_applicable_jml",
      status = "not_applicable_jml", selectable = FALSE
    ))
  }
  integer_tolerance <- sqrt(.Machine$double.eps)
  if (!is.finite(quadrature_points) || quadrature_points < 1 ||
      abs(quadrature_points - round(quadrature_points)) > integer_tolerance) {
    return(list(
      quadrature_points = NA_integer_, tier = "unknown",
      status = "invalid_or_unknown_quadrature", selectable = FALSE
    ))
  }
  quadrature_points <- as.integer(round(quadrature_points))
  if (quadrature_points < 15L) {
    tier <- "coarse_screening"
    status <- "screening_only"
    selectable <- FALSE
  } else if (quadrature_points < 31L) {
    tier <- "intermediate_review"
    status <- "review_only"
    selectable <- FALSE
  } else if (quadrature_points < 61L) {
    tier <- "standard_start"
    status <- "selection_start"
    selectable <- TRUE
  } else {
    tier <- "dense_sensitivity"
    status <- "dense_sensitivity"
    selectable <- TRUE
  }
  list(
    quadrature_points = quadrature_points,
    tier = tier,
    status = status,
    selectable = selectable
  )
}

mfrmr_ic_target_decision <- function(method,
                                     weight_policy,
                                     contract_version,
                                     persons,
                                     quadrature_points) {
  method <- toupper(trimws(as.character(method)[1]))
  weight_policy <- tolower(trimws(as.character(weight_policy)[1]))
  contract_version <- trimws(as.character(contract_version)[1])
  persons <- suppressWarnings(as.numeric(persons)[1])
  integration <- mfrmr_ic_target_integration(
    method = method,
    contract_version = contract_version,
    quadrature_points = quadrature_points
  )
  decision <- function(panel_available,
                       ic_sample_size,
                       ic_sample_size_basis,
                       ic_eligible,
                       status) {
    ic_selectable <- isTRUE(ic_eligible) && isTRUE(integration$selectable)
    list(
      panel_available = panel_available,
      ic_sample_size = ic_sample_size,
      ic_sample_size_basis = ic_sample_size_basis,
      ic_eligible = ic_eligible,
      ic_selectable = ic_selectable,
      sabic_selectable = ic_selectable && is.finite(persons) && persons > 22,
      status = status,
      integration = integration
    )
  }

  if (!identical(contract_version, mfrmr_ic_contract_version)) {
    return(decision(FALSE, NA_real_, "legacy_or_unknown", FALSE,
                    "suppressed_legacy_contract"))
  }
  if (!identical(method, "MML")) {
    return(decision(FALSE, NA_real_, "descriptive_jml", FALSE,
                    "descriptive_jml"))
  }
  if (!weight_policy %in% c("unweighted", "explicit_unit")) {
    return(decision(FALSE, NA_real_, "unsupported_nonunit_weights", FALSE,
                    "suppressed_nonunit_weight"))
  }
  if (!is.finite(persons) || persons < 1) {
    return(decision(FALSE, NA_real_, "invalid_person_count", FALSE,
                    "invalid_person_count"))
  }

  decision(
    TRUE,
    persons,
    "person_count",
    TRUE,
    if (persons > 22) "ok" else "ok_sabic_nonpositive"
  )
}

mfrmr_ic_infer_weight_policy <- function(fit,
                                         tolerance = sqrt(.Machine$double.eps)) {
  data <- fit$prep$data
  if (is.null(data) || !is.data.frame(data) || !"Weight" %in% names(data)) {
    return("unavailable")
  }
  weights <- suppressWarnings(as.numeric(data$Weight))
  if (length(weights) == 0L || any(!is.finite(weights)) || any(weights <= 0)) {
    return("invalid")
  }
  declared <- !is.null(fit$config$weight_col) &&
    length(fit$config$weight_col) > 0L &&
    !is.na(fit$config$weight_col[1]) && nzchar(fit$config$weight_col[1])
  if (all(abs(weights - 1) <= tolerance)) {
    return(if (declared) "explicit_unit" else "unweighted")
  }
  if (!"Person" %in% names(data)) return("nonunit_row_varying")
  person_weights <- split(weights, as.character(data$Person), drop = TRUE)
  constant_within_person <- all(vapply(person_weights, function(x) {
    length(x) > 0L && max(x) - min(x) <= tolerance
  }, logical(1)))
  if (constant_within_person) {
    "nonunit_constant_within_person"
  } else {
    "nonunit_row_varying"
  }
}

mfrmr_ic_numeric_match <- function(actual, expected, tolerance) {
  if (is.na(expected)) return(is.na(actual))
  is.finite(actual) &&
    abs(actual - expected) <= tolerance * max(1, abs(expected))
}

mfrmr_ic_fixture_path <- function(pkg_dir = ".") {
  file.path(
    normalizePath(pkg_dir, winslash = "/", mustWork = FALSE),
    "inst", "validation", "ic-contract-fixtures-0.2.3.csv"
  )
}

mfrmr_run_ic_contract_fixture_audit <- function(pkg_dir = ".",
                                                tolerance = 1e-10) {
  if (!is.numeric(tolerance) || length(tolerance) != 1L ||
      !is.finite(tolerance) || tolerance <= 0) {
    stop("`tolerance` must be one finite positive number.", call. = FALSE)
  }
  path <- mfrmr_ic_fixture_path(pkg_dir)
  if (!file.exists(path)) {
    stop("IC fixture registry not found: ", path, call. = FALSE)
  }
  fixtures <- utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    na.strings = c("", "NA")
  )
  missing_columns <- setdiff(mfrmr_ic_fixture_required_columns, names(fixtures))
  if (length(missing_columns) > 0L) {
    stop(
      "IC fixture registry is missing required column(s): ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }
  if (nrow(fixtures) == 0L || anyNA(fixtures$FixtureId) ||
      any(!nzchar(fixtures$FixtureId)) || anyDuplicated(fixtures$FixtureId)) {
    stop("FixtureId values must be non-empty and unique.", call. = FALSE)
  }
  unknown_methods <- setdiff(unique(toupper(fixtures$Method)), c("MML", "JML"))
  if (length(unknown_methods) > 0L) {
    stop(
      "IC fixture registry contains unknown Method value(s): ",
      paste(unknown_methods, collapse = ", "),
      call. = FALSE
    )
  }
  allowed_weight_policies <- c(
    "unweighted", "explicit_unit", "nonunit_constant_within_person",
    "nonunit_row_varying"
  )
  unknown_weight_policies <- setdiff(
    unique(tolower(fixtures$WeightPolicy)),
    allowed_weight_policies
  )
  if (length(unknown_weight_policies) > 0L) {
    stop(
      "IC fixture registry contains unknown WeightPolicy value(s): ",
      paste(unknown_weight_policies, collapse = ", "),
      call. = FALSE
    )
  }

  numeric_fields <- c(
    "LogLik", "Npar", "Persons", "ResponseRows", "WeightedResponseTotal",
    "ExpectedDeviance", "ExpectedAIC", "ExpectedBIC", "ExpectedSABIC",
    "ExpectedICSampleSize", "QuadraturePoints"
  )
  fixtures[numeric_fields] <- lapply(fixtures[numeric_fields], function(x) {
    suppressWarnings(as.numeric(x))
  })

  rows <- lapply(seq_len(nrow(fixtures)), function(i) {
    fixture <- fixtures[i, , drop = FALSE]
    expected_panel <- mfrmr_ic_as_flag(
      fixture$ExpectedPanelAvailable,
      "ExpectedPanelAvailable"
    )
    expected_eligible <- mfrmr_ic_as_flag(
      fixture$ExpectedICEligible,
      "ExpectedICEligible"
    )
    expected_selectable <- mfrmr_ic_as_flag(
      fixture$ExpectedSABICSelectable,
      "ExpectedSABICSelectable"
    )
    expected_ic_selectable <- mfrmr_ic_as_flag(
      fixture$ExpectedICSelectable,
      "ExpectedICSelectable"
    )
    expected_integration_selectable <- mfrmr_ic_as_flag(
      fixture$ExpectedIntegrationSelectable,
      "ExpectedIntegrationSelectable"
    )
    decision <- mfrmr_ic_target_decision(
      method = fixture$Method,
      weight_policy = fixture$WeightPolicy,
      contract_version = fixture$ContractVersion,
      persons = fixture$Persons,
      quadrature_points = fixture$QuadraturePoints
    )
    calculated <- if (isTRUE(decision$panel_available)) {
      mfrmr_ic_common_panel(
        loglik = fixture$LogLik,
        npar = fixture$Npar,
        persons = fixture$Persons
      )
    } else {
      c(Deviance = NA_real_, AIC = NA_real_, BIC = NA_real_, SABIC = NA_real_)
    }

    integer_tolerance <- sqrt(.Machine$double.eps)
    metadata_checks <- c(
      loglik_finite = is.finite(fixture$LogLik),
      npar_nonnegative_integer = is.finite(fixture$Npar) && fixture$Npar >= 0 &&
        abs(fixture$Npar - round(fixture$Npar)) <= integer_tolerance,
      persons_positive_integer = is.finite(fixture$Persons) && fixture$Persons >= 1 &&
        abs(fixture$Persons - round(fixture$Persons)) <= integer_tolerance,
      response_rows_positive_integer = is.finite(fixture$ResponseRows) &&
        fixture$ResponseRows >= 1 &&
        abs(fixture$ResponseRows - round(fixture$ResponseRows)) <= integer_tolerance,
      quadrature_positive_integer = is.finite(fixture$QuadraturePoints) &&
        fixture$QuadraturePoints >= 1 &&
        abs(fixture$QuadraturePoints - round(fixture$QuadraturePoints)) <=
          integer_tolerance,
      persons_not_above_rows = is.finite(fixture$Persons) &&
        is.finite(fixture$ResponseRows) && fixture$Persons <= fixture$ResponseRows,
      weighted_response_total_positive =
        is.finite(fixture$WeightedResponseTotal) &&
        fixture$WeightedResponseTotal > 0,
      unit_weight_total_matches_rows = if (
        tolower(fixture$WeightPolicy) %in% c("unweighted", "explicit_unit")
      ) {
        mfrmr_ic_numeric_match(
          fixture$WeightedResponseTotal,
          fixture$ResponseRows,
          tolerance
        )
      } else {
        TRUE
      }
    )
    checks <- c(
      metadata_checks,
      panel_available = identical(decision$panel_available, expected_panel),
      deviance = mfrmr_ic_numeric_match(
        calculated[["Deviance"]], fixture$ExpectedDeviance, tolerance
      ),
      aic = mfrmr_ic_numeric_match(
        calculated[["AIC"]], fixture$ExpectedAIC, tolerance
      ),
      bic = mfrmr_ic_numeric_match(
        calculated[["BIC"]], fixture$ExpectedBIC, tolerance
      ),
      sabic = mfrmr_ic_numeric_match(
        calculated[["SABIC"]], fixture$ExpectedSABIC, tolerance
      ),
      ic_sample_size = mfrmr_ic_numeric_match(
        decision$ic_sample_size, fixture$ExpectedICSampleSize, tolerance
      ),
      ic_sample_size_basis = identical(
        decision$ic_sample_size_basis,
        as.character(fixture$ExpectedICSampleSizeBasis)
      ),
      ic_eligible = identical(decision$ic_eligible, expected_eligible),
      ic_selectable = identical(
        decision$ic_selectable,
        expected_ic_selectable
      ),
      sabic_selectable = identical(
        decision$sabic_selectable,
        expected_selectable
      ),
      integration_tier = identical(
        decision$integration$tier,
        as.character(fixture$ExpectedIntegrationTier)
      ),
      integration_status = identical(
        decision$integration$status,
        as.character(fixture$ExpectedIntegrationStatus)
      ),
      integration_selectable = identical(
        decision$integration$selectable,
        expected_integration_selectable
      ),
      status = identical(decision$status, as.character(fixture$ExpectedStatus))
    )

    data.frame(
      FixtureId = fixture$FixtureId,
      FormulaGroup = fixture$FormulaGroup,
      CalculatedDeviance = unname(calculated[["Deviance"]]),
      CalculatedAIC = unname(calculated[["AIC"]]),
      CalculatedBIC = unname(calculated[["BIC"]]),
      CalculatedSABIC = unname(calculated[["SABIC"]]),
      ICSampleSize = decision$ic_sample_size,
      ICSampleSizeBasis = decision$ic_sample_size_basis,
      ICEligible = decision$ic_eligible,
      ICSelectable = decision$ic_selectable,
      SABICSelectable = decision$sabic_selectable,
      ICIntegrationTier = decision$integration$tier,
      ICIntegrationStatus = decision$integration$status,
      ICIntegrationSelectable = decision$integration$selectable,
      DecisionStatus = decision$status,
      FailedChecks = paste(names(checks)[!checks], collapse = ";"),
      Status = if (all(checks)) "ok" else "concern",
      stringsAsFactors = FALSE
    )
  })
  results <- do.call(rbind, rows)

  grouped <- split(
    results[is.finite(results$CalculatedAIC), , drop = FALSE],
    results$FormulaGroup[is.finite(results$CalculatedAIC)]
  )
  group_checks <- lapply(names(grouped), function(group_name) {
    group <- grouped[[group_name]]
    metric_values <- group[c(
      "CalculatedDeviance", "CalculatedAIC", "CalculatedBIC",
      "CalculatedSABIC", "ICSampleSize"
    )]
    stable <- if (nrow(group) < 2L) {
      TRUE
    } else {
      all(vapply(metric_values, function(x) {
        max(x, na.rm = TRUE) - min(x, na.rm = TRUE) <=
          tolerance * max(1, max(abs(x), na.rm = TRUE))
      }, logical(1)))
    }
    data.frame(
      FormulaGroup = group_name,
      Fixtures = nrow(group),
      Status = if (stable) "ok" else "concern",
      stringsAsFactors = FALSE
    )
  })
  group_results <- if (length(group_checks) > 0L) {
    do.call(rbind, group_checks)
  } else {
    data.frame(FormulaGroup = character(), Fixtures = integer(), Status = character())
  }

  overall <- if (all(results$Status == "ok") &&
                 all(group_results$Status == "ok")) "ok" else "concern"
  out <- list(
    specification = "0.2.3-draft.5",
    contract_version = mfrmr_ic_contract_version,
    formula_identifiers = mfrmr_ic_formula_identifiers,
    fixture_path = path,
    tolerance = tolerance,
    results = results,
    group_results = group_results,
    status = overall
  )
  class(out) <- c("mfrmr_ic_contract_fixture_audit", class(out))
  out
}

print.mfrmr_ic_contract_fixture_audit <- function(x, ...) {
  cat("mfrmr 0.2.3 IC contract fixture audit\n")
  cat("  Specification:", x$specification, "\n")
  cat("  Contract:", x$contract_version, "\n")
  cat("  Fixtures:", nrow(x$results), "\n")
  cat("  Status:", x$status, "\n")
  if (any(x$results$Status != "ok")) {
    print(x$results[x$results$Status != "ok", , drop = FALSE], row.names = FALSE)
  }
  invisible(x)
}

mfrmr_audit_fit_ic_contract <- function(fit, tolerance = 1e-10) {
  if (!is.list(fit) || is.null(fit$summary) || !is.data.frame(fit$summary) ||
      nrow(fit$summary) < 1L) {
    stop("`fit` must contain a non-empty data-frame `summary`.", call. = FALSE)
  }
  summary_row <- fit$summary[1, , drop = FALSE]
  required <- c(
    "ICContractVersion", "Deviance", "LogLik", "Npar", "ResponseRows",
    "WeightedResponseTotal", "Persons", "ICSampleSize",
    "ICSampleSizeBasis", "WeightPolicy", "ICEligible", "ICSelectable",
    "ICStatus", "AIC", "BIC", "SABIC", "SABICSelectable", "AICFormula",
    "BICFormula", "SABICFormula", "IntegrationEvaluationId",
    "ICQuadraturePoints", "ICIntegrationTier", "ICIntegrationStatus",
    "ICIntegrationSelectable"
  )
  checks <- list()
  add_check <- function(item, ok, detail) {
    checks[[length(checks) + 1L]] <<- data.frame(
      Item = item,
      Status = if (isTRUE(ok)) "ok" else "concern",
      Detail = detail,
      stringsAsFactors = FALSE
    )
  }

  missing_fields <- setdiff(required, names(summary_row))
  add_check(
    "required_fields",
    length(missing_fields) == 0L,
    if (length(missing_fields) == 0L) "complete" else
      paste("missing", paste(missing_fields, collapse = ", "))
  )

  if ("ICContractVersion" %in% names(summary_row)) {
    add_check(
      "contract_version",
      identical(as.character(summary_row$ICContractVersion[1]),
                mfrmr_ic_contract_version),
      as.character(summary_row$ICContractVersion[1])
    )
  }
  if ("Npar" %in% names(summary_row) && !is.null(fit$opt$par)) {
    stored_npar <- suppressWarnings(as.numeric(summary_row$Npar[1]))
    add_check(
      "retained_parameter_dimension",
      is.finite(stored_npar) && stored_npar == length(fit$opt$par),
      paste("stored", stored_npar, "retained", length(fit$opt$par))
    )
  }
  if ("ResponseRows" %in% names(summary_row) &&
      !is.null(fit$prep$data) && is.data.frame(fit$prep$data)) {
    stored_rows <- suppressWarnings(as.numeric(summary_row$ResponseRows[1]))
    add_check(
      "prepared_response_rows",
      is.finite(stored_rows) && stored_rows == nrow(fit$prep$data),
      paste("stored", stored_rows, "prepared", nrow(fit$prep$data))
    )
  }
  if ("WeightedResponseTotal" %in% names(summary_row) &&
      !is.null(fit$prep$data) && is.data.frame(fit$prep$data) &&
      "Weight" %in% names(fit$prep$data)) {
    stored_weight_total <- suppressWarnings(as.numeric(
      summary_row$WeightedResponseTotal[1]
    ))
    prepared_weight_total <- sum(
      suppressWarnings(as.numeric(fit$prep$data$Weight)),
      na.rm = TRUE
    )
    add_check(
      "prepared_weight_total",
      mfrmr_ic_numeric_match(
        stored_weight_total,
        prepared_weight_total,
        tolerance
      ),
      paste("stored", stored_weight_total, "prepared", prepared_weight_total)
    )
  }
  if ("Persons" %in% names(summary_row) &&
      !is.null(fit$prep$data) && "Person" %in% names(fit$prep$data)) {
    stored_persons <- suppressWarnings(as.numeric(summary_row$Persons[1]))
    prepared_persons <- length(unique(as.character(fit$prep$data$Person)))
    add_check(
      "prepared_person_count",
      is.finite(stored_persons) && stored_persons == prepared_persons,
      paste("stored", stored_persons, "prepared", prepared_persons)
    )
  }

  if (all(c("WeightPolicy", "ICEligible", "ICSelectable", "ICStatus",
            "SABICSelectable", "Persons", "ICSampleSize", "ICSampleSizeBasis",
            "ICQuadraturePoints", "ICIntegrationTier",
            "ICIntegrationStatus", "ICIntegrationSelectable",
            "ICContractVersion") %in% names(summary_row))) {
    inferred_weight_policy <- mfrmr_ic_infer_weight_policy(fit)
    add_check(
      "prepared_weight_policy",
      identical(
        as.character(summary_row$WeightPolicy[1]),
        inferred_weight_policy
      ),
      paste(
        "stored", as.character(summary_row$WeightPolicy[1]),
        "prepared", inferred_weight_policy
      )
    )
    decision <- mfrmr_ic_target_decision(
      method = if ("Method" %in% names(summary_row)) {
        summary_row$Method[1]
      } else if (!is.null(fit$config$method)) {
        fit$config$method[1]
      } else {
        NA_character_
      },
      weight_policy = summary_row$WeightPolicy[1],
      contract_version = summary_row$ICContractVersion[1],
      persons = summary_row$Persons[1],
      quadrature_points = summary_row$ICQuadraturePoints[1]
    )
    stored_eligible <- isTRUE(as.logical(summary_row$ICEligible[1]))
    add_check(
      "eligibility_policy",
      identical(stored_eligible, decision$ic_eligible) &&
        identical(
          isTRUE(as.logical(summary_row$ICSelectable[1])),
          decision$ic_selectable
        ) &&
        identical(
          isTRUE(as.logical(summary_row$SABICSelectable[1])),
          decision$sabic_selectable
        ) && identical(
          as.character(summary_row$ICStatus[1]),
          decision$status
        ),
      paste(
        "stored", stored_eligible,
        isTRUE(as.logical(summary_row$ICSelectable[1])),
        isTRUE(as.logical(summary_row$SABICSelectable[1])),
        as.character(summary_row$ICStatus[1]),
        "expected", decision$ic_eligible, decision$ic_selectable,
        decision$sabic_selectable, decision$status
      )
    )
    add_check(
      "integration_policy",
      identical(
        as.character(summary_row$ICIntegrationTier[1]),
        decision$integration$tier
      ) && identical(
        as.character(summary_row$ICIntegrationStatus[1]),
        decision$integration$status
      ) && identical(
        isTRUE(as.logical(summary_row$ICIntegrationSelectable[1])),
        decision$integration$selectable
      ),
      paste(
        "stored", as.character(summary_row$ICIntegrationTier[1]),
        as.character(summary_row$ICIntegrationStatus[1]),
        isTRUE(as.logical(summary_row$ICIntegrationSelectable[1])),
        "expected", decision$integration$tier,
        decision$integration$status, decision$integration$selectable
      )
    )
    add_check(
      "sample_size_basis",
      identical(
        as.character(summary_row$ICSampleSizeBasis[1]),
        decision$ic_sample_size_basis
      ) && mfrmr_ic_numeric_match(
        suppressWarnings(as.numeric(summary_row$ICSampleSize[1])),
        decision$ic_sample_size,
        tolerance
      ),
      paste(
        "stored",
        as.character(summary_row$ICSampleSizeBasis[1]),
        suppressWarnings(as.numeric(summary_row$ICSampleSize[1])),
        "expected",
        decision$ic_sample_size_basis,
        decision$ic_sample_size
      )
    )
  }

  base_formula_fields <- c("Deviance", "LogLik", "Npar", "Persons")
  if (all(base_formula_fields %in% names(summary_row))) {
    panel <- mfrmr_ic_common_panel(
      loglik = suppressWarnings(as.numeric(summary_row$LogLik[1])),
      npar = suppressWarnings(as.numeric(summary_row$Npar[1])),
      persons = suppressWarnings(as.numeric(summary_row$Persons[1]))
    )
    stored_deviance <- suppressWarnings(as.numeric(summary_row$Deviance[1]))
    add_check(
      "formula_deviance",
      mfrmr_ic_numeric_match(
        stored_deviance,
        unname(panel[["Deviance"]]),
        tolerance
      ),
      paste(
        "stored", stored_deviance,
        "recomputed", unname(panel[["Deviance"]])
      )
    )
    stored_eligible <- "ICEligible" %in% names(summary_row) &&
      isTRUE(as.logical(summary_row$ICEligible[1]))
    if (stored_eligible && all(c("AIC", "BIC", "SABIC") %in% names(summary_row))) {
      for (field in c("AIC", "BIC", "SABIC")) {
        stored <- suppressWarnings(as.numeric(summary_row[[field]][1]))
        add_check(
          paste0("formula_", tolower(field)),
          mfrmr_ic_numeric_match(stored, unname(panel[[field]]), tolerance),
          paste("stored", stored, "recomputed", unname(panel[[field]]))
        )
      }
    } else if (!stored_eligible &&
               all(c("AIC", "BIC", "SABIC") %in% names(summary_row))) {
      canonical_values <- suppressWarnings(as.numeric(
        unlist(summary_row[c("AIC", "BIC", "SABIC")], use.names = FALSE)
      ))
      add_check(
        "ineligible_panel_suppressed",
        all(is.na(canonical_values)),
        paste(c("AIC", "BIC", "SABIC"), canonical_values, collapse = "; ")
      )
    }
  }
  if (all(c("AICFormula", "BICFormula", "SABICFormula") %in%
          names(summary_row))) {
    stored_ids <- c(
      AIC = as.character(summary_row$AICFormula[1]),
      BIC = as.character(summary_row$BICFormula[1]),
      SABIC = as.character(summary_row$SABICFormula[1])
    )
    add_check(
      "formula_identifiers",
      identical(stored_ids, mfrmr_ic_formula_identifiers),
      paste(names(stored_ids), stored_ids, collapse = "; ")
    )
  }
  if ("IntegrationEvaluationId" %in% names(summary_row)) {
    integration_id <- as.character(summary_row$IntegrationEvaluationId[1])
    add_check(
      "integration_evaluation_identity",
      length(integration_id) == 1L && !is.na(integration_id) &&
        nzchar(integration_id),
      integration_id
    )
  }

  result <- if (length(checks) > 0L) {
    do.call(rbind, checks)
  } else {
    data.frame(Item = character(), Status = character(), Detail = character())
  }
  out <- list(
    results = result,
    status = if (nrow(result) > 0L && all(result$Status == "ok")) "ok" else "concern"
  )
  class(out) <- c("mfrmr_fit_ic_contract_audit", class(out))
  out
}

print.mfrmr_fit_ic_contract_audit <- function(x, ...) {
  cat("mfrmr fit IC contract audit\n")
  cat("  Status:", x$status, "\n")
  print(x$results, row.names = FALSE)
  invisible(x)
}
