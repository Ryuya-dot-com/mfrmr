# Repository-only maxit ceiling and rerun-selection contract for mfrmr 0.2.3.
#
# This validator records analysis attempts; it does not fit models, select a
# model, or authorize confirmation. A study may declare a different positive,
# strictly increasing ceiling sequence before fitting. The public default
# example is c(400L, 800L, 1600L).

mfrmr_maxit_contract_id <- "mfrmr-maxit-ceiling-0.2.3-v1"
mfrmr_maxit_default_sequence <- c(400L, 800L, 1600L)

mfrmr_maxit_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_maxit_validate_sequence <- function(sequence) {
  raw <- suppressWarnings(as.numeric(sequence))
  mfrmr_maxit_assert(
    length(raw) > 0L && all(is.finite(raw)) && all(raw > 0) &&
      all(raw == floor(raw)) && !anyDuplicated(raw) &&
      (length(raw) == 1L || all(diff(raw) > 0)),
    "The declared maxit sequence must contain unique, strictly increasing positive integers."
  )
  as.integer(raw)
}

mfrmr_maxit_attempt_table <- function(maxit,
                                      specification_hash,
                                      fit_readiness,
                                      inference_ready,
                                      numerical_state,
                                      convergence_status,
                                      selected = FALSE) {
  lengths <- vapply(
    list(
      maxit,
      specification_hash,
      fit_readiness,
      inference_ready,
      numerical_state,
      convergence_status,
      selected
    ),
    length,
    integer(1L)
  )
  mfrmr_maxit_assert(
    length(unique(lengths)) == 1L && lengths[1] > 0L,
    "Every attempt field must have the same positive length."
  )
  data.frame(
    Attempt = seq_len(lengths[1]),
    Maxit = as.integer(maxit),
    SpecificationHash = as.character(specification_hash),
    FitReadiness = as.character(fit_readiness),
    InferenceReady = as.logical(inference_ready),
    NumericalState = as.character(numerical_state),
    ConvergenceStatus = as.character(convergence_status),
    Selected = as.logical(selected),
    stringsAsFactors = FALSE
  )
}

mfrmr_maxit_attempts_from_fits <- function(fits,
                                           specification_hash,
                                           selected = rep(FALSE, length(fits))) {
  mfrmr_maxit_assert(
    is.list(fits) && length(fits) > 0L &&
      all(vapply(fits, inherits, logical(1L), "mfrm_fit")),
    "`fits` must be a non-empty list of mfrm_fit objects."
  )
  specification_hash <- as.character(specification_hash)
  if (length(specification_hash) == 1L) {
    specification_hash <- rep(specification_hash, length(fits))
  }
  mfrmr_maxit_assert(
    length(specification_hash) == length(fits) &&
      length(selected) == length(fits),
    "Fit hashes and selection flags must align with `fits`."
  )
  one <- function(fit, hash, selected_value) {
    readiness <- fit$readiness$fit
    summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)[
      1L, , drop = FALSE
    ]
    mfrmr_maxit_assert(
      is.data.frame(readiness) && nrow(readiness) == 1L,
      "Every fit must retain one current readiness record."
    )
    mfrmr_maxit_attempt_table(
      maxit = fit$config$estimation_control$maxit,
      specification_hash = hash,
      fit_readiness = readiness$FitReadiness,
      inference_ready = readiness$InferenceReady,
      numerical_state = readiness$NumericalState,
      convergence_status = summary$ConvergenceStatus,
      selected = selected_value
    )
  }
  rows <- Map(one, fits, specification_hash, as.logical(selected))
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out$Attempt <- seq_len(nrow(out))
  out
}

mfrmr_review_maxit_attempts <- function(attempts,
                                        declared_sequence =
                                          mfrmr_maxit_default_sequence,
                                        require_selection = TRUE) {
  required <- c(
    "Attempt", "Maxit", "SpecificationHash", "FitReadiness",
    "InferenceReady", "NumericalState", "ConvergenceStatus", "Selected"
  )
  mfrmr_maxit_assert(
    is.data.frame(attempts) && nrow(attempts) > 0L &&
      all(required %in% names(attempts)),
    "`attempts` must be a non-empty maxit attempt table."
  )
  declared_sequence <- mfrmr_maxit_validate_sequence(declared_sequence)
  attempts <- attempts[, required, drop = FALSE]
  mfrmr_maxit_assert(
    all(!is.na(attempts$Attempt)) &&
      identical(as.integer(attempts$Attempt), seq_len(nrow(attempts))) &&
      all(!is.na(attempts$Maxit)) &&
      all(!is.na(attempts$SpecificationHash)) &&
      all(nzchar(attempts$SpecificationHash)) &&
      all(grepl("^[0-9a-f]{64}$", attempts$SpecificationHash)) &&
      all(!is.na(attempts$FitReadiness)) &&
      all(attempts$FitReadiness %in%
        c("ready", "review", "blocked", "legacy_unknown")) &&
      all(!is.na(attempts$InferenceReady)) &&
      all(!is.na(attempts$NumericalState)) &&
      all(attempts$NumericalState %in% c("ready", "review", "failed")) &&
      all(!is.na(attempts$ConvergenceStatus)) &&
      all(nzchar(attempts$ConvergenceStatus)) &&
      all(!is.na(attempts$Selected)),
    "The maxit attempt table contains malformed identity or readiness fields."
  )

  registered_prefix <- nrow(attempts) <= length(declared_sequence) &&
    identical(
      as.integer(attempts$Maxit),
      declared_sequence[seq_len(nrow(attempts))]
    )
  specification_fixed <- length(unique(attempts$SpecificationHash)) == 1L
  state_consistent <- all(
    !attempts$InferenceReady |
      (
        attempts$FitReadiness == "ready" &
          attempts$NumericalState == "ready" &
          attempts$ConvergenceStatus != "iteration_limit"
      )
  ) && all(
    attempts$FitReadiness != "ready" |
      (
        attempts$InferenceReady &
          attempts$NumericalState == "ready" &
          attempts$ConvergenceStatus != "iteration_limit"
      )
  )
  eligible <- attempts$FitReadiness == "ready" &
    attempts$InferenceReady &
    attempts$NumericalState == "ready" &
    attempts$ConvergenceStatus != "iteration_limit"
  first_eligible <- if (any(eligible)) which(eligible)[1L] else NA_integer_
  selected_index <- which(attempts$Selected)
  selection_count_valid <- length(selected_index) <= 1L
  selection_matches_first <- if (length(selected_index) == 1L) {
    !is.na(first_eligible) && identical(selected_index, first_eligible)
  } else {
    !isTRUE(require_selection) || is.na(first_eligible)
  }
  contract_pass <- registered_prefix && specification_fixed &&
    state_consistent && selection_count_valid && selection_matches_first

  reasons <- character(0)
  if (!registered_prefix) reasons <- c(reasons, "unregistered_ceiling_sequence")
  if (!specification_fixed) reasons <- c(reasons, "specification_changed")
  if (!state_consistent) reasons <- c(reasons, "readiness_state_inconsistent")
  if (!selection_count_valid) reasons <- c(reasons, "multiple_runs_selected")
  if (!selection_matches_first) {
    reasons <- c(
      reasons,
      if (length(selected_index) == 0L) {
        "first_eligible_run_not_selected"
      } else {
        "selected_run_not_first_eligible"
      }
    )
  }

  attempts$RegisteredCeiling <- seq_len(nrow(attempts)) <=
    length(declared_sequence) & attempts$Maxit ==
    declared_sequence[pmin(seq_len(nrow(attempts)), length(declared_sequence))]
  attempts$Eligible <- eligible
  attempts$FirstEligible <- seq_len(nrow(attempts)) == first_eligible

  list(
    contract_id = mfrmr_maxit_contract_id,
    declared_sequence = declared_sequence,
    attempts = attempts,
    summary = data.frame(
      ContractPass = contract_pass,
      RegisteredPrefix = registered_prefix,
      SpecificationFixed = specification_fixed,
      ReadinessStateConsistent = state_consistent,
      SelectionCountValid = selection_count_valid,
      SelectionMatchesFirstEligible = selection_matches_first,
      FirstEligibleAttempt = first_eligible,
      SelectedAttempt = if (length(selected_index) == 1L) {
        selected_index
      } else {
        NA_integer_
      },
      ReasonCodes = paste(reasons, collapse = ";"),
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  )
}
