# mfrmr 0.2.3 repository-only external IC fixture audit

mfrmr_external_ic_audit_specification <- "0.2.3-draft.8"

mfrmr_external_ic_audit_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_external_ic_audit_bool <- function(value) {
  value <- toupper(trimws(as.character(value)[1]))
  if (identical(value, "TRUE")) return(TRUE)
  if (identical(value, "FALSE")) return(FALSE)
  stop("Expected a TRUE/FALSE fixture value.", call. = FALSE)
}

mfrmr_external_ic_audit_numeric <- function(value) {
  value <- suppressWarnings(as.numeric(value)[1])
  if (is.na(value)) NA_real_ else value
}

mfrmr_external_ic_audit_equal <- function(actual,
                                          expected,
                                          tolerance = 1e-10) {
  if (is.na(actual) && is.na(expected)) return(TRUE)
  is.finite(actual) && is.finite(expected) &&
    abs(actual - expected) <= tolerance * max(1, abs(expected))
}

mfrmr_run_external_ic_fixture_audit <- function(pkg_dir = ".") {
  if (!exists("mfrmr_normalize_external_ic", mode = "function")) {
    source(file.path(
      pkg_dir, "inst", "validation", "external-ic-normalizer-0.2.3.R"
    ), local = globalenv())
  }
  fixture_path <- file.path(
    pkg_dir, "inst", "validation", "external-ic-fixtures-0.2.3.csv"
  )
  fixtures <- utils::read.csv(
    fixture_path,
    stringsAsFactors = FALSE,
    na.strings = c("", "NA")
  )
  records <- vector("list", nrow(fixtures))
  names(records) <- fixtures$FixtureId
  for (index in seq_len(nrow(fixtures))) {
    fixture <- fixtures[index, , drop = FALSE]
    complete_identity <- mfrmr_external_ic_audit_bool(
      fixture$CompleteIdentity
    )
    native <- c(
      AIC = mfrmr_external_ic_audit_numeric(fixture$NativeAIC),
      BIC = mfrmr_external_ic_audit_numeric(fixture$NativeBIC),
      aBIC = mfrmr_external_ic_audit_numeric(fixture$NativeABIC),
      SABIC = mfrmr_external_ic_audit_numeric(fixture$NativeSABIC)
    )
    native <- native[!is.na(native)]
    record <- mfrmr_normalize_external_ic(
      engine = fixture$Engine,
      engine_version = "fixture",
      run_id = fixture$FixtureId,
      model_id = fixture$FixtureId,
      method = fixture$Method,
      dimensions = fixture$Dimensions,
      deviance = fixture$Deviance,
      loglik = fixture$LogLik,
      npar = fixture$Npar,
      persons = fixture$Persons,
      native_ic = native,
      native_formula_ids = c(
        AIC = "native_aic",
        BIC = "native_bic",
        aBIC = "tam_deviance_plus_log_n_minus_2_over_24_k",
        SABIC = "sclove_n_plus_2_over_24"
      ),
      native_formula_verified = c(
        AIC = TRUE, BIC = TRUE, aBIC = TRUE, SABIC = TRUE
      ),
      observation_set_id = if (complete_identity) "fixture-observations" else
        NA_character_,
      likelihood_basis_id = "fixture-likelihood",
      constraint_basis_id = "fixture-constraints",
      integration_evaluation_id = paste0(
        tolower(fixture$Engine), "-fixture-evaluation"
      ),
      integration_comparison_id = "fixture-common-integration-review",
      convergence_status = fixture$ConvergenceStatus,
      integration_stability_status = fixture$IntegrationStabilityStatus,
      candidate_id = "fixture-candidate"
    )
    observed <- record$record[1, , drop = FALSE]
    expected_arithmetic <- mfrmr_external_ic_audit_bool(
      fixture$ExpectedArithmeticEligible
    )
    expected_ready <- mfrmr_external_ic_audit_bool(
      fixture$ExpectedComparisonReady
    )
    expected_sabic <- mfrmr_external_ic_audit_bool(
      fixture$ExpectedSABICSelectable
    )
    mfrmr_external_ic_audit_assert(
      identical(observed$ArithmeticEligible[1], expected_arithmetic),
      paste(fixture$FixtureId, "ArithmeticEligible mismatch")
    )
    mfrmr_external_ic_audit_assert(
      identical(observed$ComparisonReady[1], expected_ready),
      paste(fixture$FixtureId, "ComparisonReady mismatch")
    )
    mfrmr_external_ic_audit_assert(
      identical(observed$CommonSABICSelectable[1], expected_sabic),
      paste(fixture$FixtureId, "CommonSABICSelectable mismatch")
    )
    if (expected_arithmetic) {
      deviance <- as.numeric(fixture$Deviance)
      npar <- as.numeric(fixture$Npar)
      persons <- as.numeric(fixture$Persons)
      expected_values <- c(
        CommonAIC = deviance + 2 * npar,
        CommonBIC = deviance + log(persons) * npar,
        CommonSABIC = deviance + log((persons + 2) / 24) * npar
      )
      for (field in names(expected_values)) {
        mfrmr_external_ic_audit_assert(
          mfrmr_external_ic_audit_equal(
            observed[[field]][1], expected_values[[field]]
          ),
          paste(fixture$FixtureId, field, "formula mismatch")
        )
      }
    } else {
      mfrmr_external_ic_audit_assert(
        all(is.na(observed[c("CommonAIC", "CommonBIC", "CommonSABIC")])),
        paste(fixture$FixtureId, "ineligible common panel was not suppressed")
      )
    }
    records[[index]] <- record
  }

  ready_comparison <- mfrmr_compare_external_ic(
    records[["EXTIC-001"]], records[["EXTIC-002"]],
    labels = c("TAM", "mfrmr")
  )
  mfrmr_external_ic_audit_assert(
    isTRUE(ready_comparison$comparable),
    "Complete cross-engine fixture records were not comparable."
  )
  mfrmr_external_ic_audit_assert(
    all(is.finite(ready_comparison$table$DeltaAIC)),
    "Comparable records did not receive common AIC deltas."
  )
  mfrmr_external_ic_audit_assert(
    !mfrmr_external_ic_audit_equal(
      records[["EXTIC-001"]]$record$NativeABIC[1],
      records[["EXTIC-001"]]$record$CommonSABIC[1]
    ),
    "TAM native aBIC was silently equated with common SABIC."
  )

  mismatch <- records[["EXTIC-002"]]
  mismatch$record$IntegrationComparisonId <- "different-integration-review"
  mismatch_comparison <- mfrmr_compare_external_ic(
    records[["EXTIC-001"]], mismatch,
    labels = c("TAM", "mfrmr")
  )
  mfrmr_external_ic_audit_assert(
    !isTRUE(mismatch_comparison$comparable) &&
      all(is.na(mismatch_comparison$table$DeltaAIC)),
    "Integration-comparison mismatch did not fail closed."
  )

  out <- list(
    specification = mfrmr_external_ic_audit_specification,
    contract_version = mfrmr_external_ic_contract,
    fixtures = fixtures,
    records = records,
    ready_comparison = ready_comparison,
    mismatch_comparison = mismatch_comparison,
    status = "ok"
  )
  class(out) <- c("mfrmr_external_ic_fixture_audit", class(out))
  out
}

print.mfrmr_external_ic_fixture_audit <- function(x, ...) {
  cat("mfrmr 0.2.3 external IC fixture audit\n")
  cat("  Specification:", x$specification, "\n")
  cat("  Contract:", x$contract_version, "\n")
  cat("  Fixtures:", nrow(x$fixtures), "\n")
  cat("  Status:", x$status, "\n")
  invisible(x)
}
