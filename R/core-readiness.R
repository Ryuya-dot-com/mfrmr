# Unified fit-readiness record
# ==============================================================================
#
# Readiness is derived once from the input, estimability, category-support,
# boundary, and numerical component audits.  Downstream code may format the
# stored record, but it must not improve a component state from optimizer text
# or from a finite numerical proxy for an unbounded parameter.

mfrmr_readiness_contract_version <- function() {
  "mfrmr-readiness-0.2.3-v1"
}

mfrmr_readiness_contract_states <- function() {
  list(
    ReadinessScope = c("fit", "parameter", "comparison"),
    InputState = c("pass", "review", "blocked", "legacy_unknown"),
    EstimabilityState = c(
      "identified", "population_assumption_linked", "weak_information",
      "structurally_unidentified", "not_evaluated", "legacy_unknown"
    ),
    CategoryState = c(
      "adequate", "weak_information", "unsupported_coordinate",
      "not_applicable", "not_evaluated", "legacy_unknown"
    ),
    BoundaryState = c(
      "finite", "has_exclusions", "not_applicable", "not_evaluated",
      "legacy_unknown"
    ),
    NumericalState = c(
      "ready", "review", "failed", "not_run", "legacy_unknown"
    ),
    FitReadiness = c(
      "ready", "ready_with_exclusions", "review", "blocked",
      "legacy_unknown"
    ),
    ParameterStatus = c(
      "estimable", "fixed", "weak_information", "unbounded_low",
      "unbounded_high", "aliased", "unsupported", "not_estimated",
      "legacy_unknown"
    ),
    ComparisonEligibility = c(
      "eligible", "ineligible", "missing", "failed", "not_applicable"
    ),
    ExpectedAction = c(
      "return_ready_fit", "return_review_fit", "return_partial_fit",
      "return_blocked_diagnostic", "stop_before_fit", "retain_parameter",
      "label_legacy", "include_metric", "exclude_metric", "report_missing",
      "report_failed"
    ),
    EvidenceRole = c(
      "unit_positive", "unit_negative", "migration",
      "comparison_positive", "comparison_negative"
    )
  )
}

mfrmr_readiness_split_codes <- function(x) {
  x <- as.character(x %||% character(0))
  x <- x[!is.na(x) & nzchar(trimws(x))]
  if (length(x) == 0L) return(character(0))
  codes <- unlist(strsplit(x, ";", fixed = TRUE), use.names = FALSE)
  unique(trimws(codes[nzchar(trimws(codes))]))
}

mfrmr_readiness_merge_codes <- function(...) {
  values <- unlist(list(...), recursive = TRUE, use.names = FALSE)
  paste(mfrmr_readiness_split_codes(values), collapse = ";")
}

mfrmr_readiness_derive_fit <- function(InputState, EstimabilityState,
                                       CategoryState, BoundaryState,
                                       NumericalState) {
  states <- mfrmr_readiness_contract_states()
  values <- list(
    InputState = InputState,
    EstimabilityState = EstimabilityState,
    CategoryState = CategoryState,
    BoundaryState = BoundaryState,
    NumericalState = NumericalState
  )
  for (field in names(values)) {
    value <- values[[field]]
    if (length(value) != 1L || is.na(value) ||
        !value %in% states[[field]]) {
      stop(
        sprintf("Invalid %s: %s", field, paste(value, collapse = ", ")),
        call. = FALSE
      )
    }
  }

  blocked <- InputState == "blocked" ||
    EstimabilityState == "structurally_unidentified" ||
    CategoryState == "unsupported_coordinate" ||
    NumericalState %in% c("failed", "not_run")
  if (blocked) return("blocked")

  legacy <- InputState == "legacy_unknown" ||
    EstimabilityState == "legacy_unknown" ||
    CategoryState == "legacy_unknown" ||
    BoundaryState == "legacy_unknown" ||
    NumericalState == "legacy_unknown"
  if (legacy) return("legacy_unknown")

  review <- InputState == "review" ||
    EstimabilityState %in% c(
      "population_assumption_linked", "weak_information", "not_evaluated"
    ) ||
    CategoryState %in% c("weak_information", "not_evaluated") ||
    BoundaryState == "not_evaluated" ||
    NumericalState == "review"
  if (review) return("review")

  if (BoundaryState == "has_exclusions") {
    return("ready_with_exclusions")
  }
  "ready"
}

mfrmr_readiness_inference_ready <- function(FitReadiness) {
  states <- mfrmr_readiness_contract_states()$FitReadiness
  if (length(FitReadiness) != 1L || is.na(FitReadiness) ||
      !FitReadiness %in% states) {
    stop("`FitReadiness` must be one allowed scalar state.", call. = FALSE)
  }
  identical(FitReadiness, "ready")
}

mfrmr_readiness_component_row <- function(component, state, complete,
                                           reason_codes = "",
                                           audit_state = "",
                                           provenance = "") {
  data.frame(
    Component = as.character(component),
    State = as.character(state),
    Complete = isTRUE(complete),
    ReasonCodes = mfrmr_readiness_merge_codes(reason_codes),
    AuditState = as.character(audit_state %||% ""),
    AuditProvenance = as.character(provenance %||% ""),
    stringsAsFactors = FALSE
  )
}

mfrmr_readiness_input_component <- function(prep, data_review) {
  notes <- as.data.frame(
    prep$preparation_notes %||% data_review$preparation_notes %||% data.frame(),
    stringsAsFactors = FALSE
  )
  review_rows <- if (nrow(notes) > 0L && "Severity" %in% names(notes)) {
    tolower(as.character(notes$Severity)) %in%
      c("review", "warning", "warn", "error")
  } else {
    logical(0)
  }
  review_conditions <- if (length(review_rows) && "Condition" %in% names(notes)) {
    as.character(notes$Condition[review_rows])
  } else {
    character(0)
  }
  review_conditions <- review_conditions[
    !is.na(review_conditions) & nzchar(trimws(review_conditions))
  ]
  status <- as.data.frame(data_review$status %||% data.frame(),
                          stringsAsFactors = FALSE)
  data_status <- if (nrow(status) > 0L &&
                     all(c("Domain", "Status") %in% names(status))) {
    as.character(status$Status[match("Data", status$Domain)])
  } else {
    NA_character_
  }
  review <- length(review_conditions) > 0L ||
    (!is.na(data_status) && !identical(data_status, "pass"))
  duplicate <- "duplicate_person_facet_cells" %in% review_conditions
  other_review <- any(review_conditions != "duplicate_person_facet_cells") ||
    (review && length(review_conditions) == 0L)
  reasons <- c(
    if (duplicate) "duplicate_cell_dependence_unmodelled",
    if (other_review) "input_review_required"
  )
  mfrmr_readiness_component_row(
    "input",
    if (review) "review" else "pass",
    complete = TRUE,
    reason_codes = reasons,
    audit_state = if (is.na(data_status)) "not_recorded" else data_status,
    provenance = "prepare_mfrm_data_preparation_notes_v1"
  )
}

mfrmr_readiness_estimability_component <- function(config, prep) {
  audit <- config$estimability_audit %||% list()
  readiness <- as.data.frame(audit$readiness %||% data.frame(),
                             stringsAsFactors = FALSE)
  state <- if (nrow(readiness) > 0L &&
               "EstimabilityState" %in% names(readiness)) {
    as.character(readiness$EstimabilityState[1])
  } else {
    "not_evaluated"
  }
  reasons <- if (nrow(readiness) > 0L && "ReasonCodes" %in% names(readiness)) {
    as.character(readiness$ReasonCodes[1])
  } else {
    "design_rank_not_evaluated"
  }
  complete <- isTRUE(audit$complete %||%
                     if (nrow(readiness) > 0L && "Complete" %in% names(readiness)) {
                       readiness$Complete[1]
                     } else {
                       FALSE
                     })
  single_level <- as.character(prep$facet_names %||% character(0))[
    vapply(as.character(prep$facet_names %||% character(0)), function(facet) {
      length(prep$levels[[facet]] %||% character(0)) <= 1L
    }, logical(1))
  ]
  if (length(single_level) > 0L) {
    state <- "structurally_unidentified"
    reasons <- mfrmr_readiness_merge_codes(reasons, "single_level_facet")
    complete <- TRUE
  } else if (!complete && state != "structurally_unidentified") {
    state <- "not_evaluated"
    reasons <- mfrmr_readiness_merge_codes(reasons, "design_rank_not_evaluated")
  }
  mfrmr_readiness_component_row(
    "estimability", state, complete, reasons,
    audit_state = if (nrow(readiness)) {
      as.character(readiness$EstimabilityState[1])
    } else {
      "not_evaluated"
    },
    provenance = paste0(
      "constrained_adjacent_design_v1;method=", config$method %||% "unknown",
      ";model=", config$model %||% "unknown"
    )
  )
}

mfrmr_readiness_category_component <- function(config) {
  audit <- config$category_support_audit %||% list()
  readiness <- as.data.frame(audit$readiness %||% data.frame(),
                             stringsAsFactors = FALSE)
  state <- if (nrow(readiness) > 0L && "CategoryState" %in% names(readiness)) {
    as.character(readiness$CategoryState[1])
  } else {
    "not_evaluated"
  }
  reasons <- if (nrow(readiness) > 0L && "ReasonCodes" %in% names(readiness)) {
    as.character(readiness$ReasonCodes[1])
  } else {
    ""
  }
  complete <- isTRUE(audit$complete %||%
                     if (nrow(readiness) > 0L && "Complete" %in% names(readiness)) {
                       readiness$Complete[1]
                     } else {
                       FALSE
                     })
  if (!complete && state != "unsupported_coordinate") {
    state <- "not_evaluated"
  }
  mfrmr_readiness_component_row(
    "category", state, complete, reasons,
    audit_state = state,
    provenance = paste0(
      "declared_category_and_step_support_v1;model=",
      config$model %||% "unknown", ";scale=single_observed_scale"
    )
  )
}

mfrmr_readiness_additive_candidate_unpropagated <- function(
    additive_audit, person_status = data.frame(), joint = FALSE) {
  state <- as.character(additive_audit$state %||% "")
  if (!identical(state, "certified_recession")) return(FALSE)
  targets <- as.data.frame(additive_audit$target_status %||% data.frame(),
                           stringsAsFactors = FALSE)
  candidate_states <- c(
    "unbounded_direction_ambiguous", "unbounded_high", "unbounded_low"
  )
  if (nrow(targets) > 0L && "CandidateStatus" %in% names(targets) &&
      any(as.character(targets$CandidateStatus) %in% candidate_states)) {
    return(TRUE)
  }
  if (!isTRUE(joint)) {
    # A structural certificate without a target-status mapping cannot be
    # dismissed merely because its mapping table is absent.
    return(nrow(targets) == 0L)
  }

  # The joint cone can consist solely of free extreme Person directions that
  # the sufficient-score audit already propagated to typed +/-Inf values.  In
  # that case it supplies independent confirmation, not a new unpropagated
  # structural candidate.
  loadings <- as.data.frame(
    additive_audit$cone_direction_loadings %||% data.frame(),
    stringsAsFactors = FALSE
  )
  person_status <- as.data.frame(person_status, stringsAsFactors = FALSE)
  if (nrow(loadings) == 0L || !"Coordinate" %in% names(loadings) ||
      nrow(person_status) == 0L ||
      !all(c("ParameterId", "ParameterStatus") %in% names(person_status))) {
    return(TRUE)
  }
  coordinate <- as.character(loadings$Coordinate)
  if (!all(startsWith(coordinate, "Person:"))) return(TRUE)
  matched <- match(coordinate, as.character(person_status$ParameterId))
  if (anyNA(matched)) return(TRUE)
  !all(as.character(person_status$ParameterStatus[matched]) %in%
         c("unbounded_low", "unbounded_high"))
}

mfrmr_readiness_boundary_component <- function(config) {
  audit <- config$boundary_audit %||% list()
  person <- as.data.frame(audit$readiness %||% data.frame(),
                          stringsAsFactors = FALSE)
  person_state <- if (nrow(person) > 0L && "BoundaryState" %in% names(person)) {
    as.character(person$BoundaryState[1])
  } else {
    "not_evaluated"
  }
  reasons <- if (nrow(person) > 0L && "ReasonCodes" %in% names(person)) {
    as.character(person$ReasonCodes[1])
  } else {
    ""
  }
  person_complete <- isTRUE(audit$complete %||%
                            if (nrow(person) > 0L && "Complete" %in% names(person)) {
                              person$Complete[1]
                            } else {
                              FALSE
                            })
  method <- as.character(config$method %||% NA_character_)
  model <- as.character(config$model %||% NA_character_)
  structural <- audit$structural_additive %||% list()
  joint <- audit$joint_additive %||% list()
  slope <- audit$gpcm_slope_boundary %||% list()
  person_status <- as.data.frame(audit$parameter_status %||% data.frame(),
                                 stringsAsFactors = FALSE)

  if (!identical(method, "JML")) {
    return(mfrmr_readiness_component_row(
      "boundary", person_state, person_complete, reasons,
      audit_state = paste0("person=", person_state, ";jml=not_applicable"),
      provenance = paste0(
        "person_sufficient_score_v1;method=", method,
        ";model=", model
      )
    ))
  }

  additive_complete <- isTRUE(structural$complete) && isTRUE(joint$complete)
  additive_candidate <-
    mfrmr_readiness_additive_candidate_unpropagated(
      structural, person_status = person_status, joint = FALSE
    ) ||
    mfrmr_readiness_additive_candidate_unpropagated(
      joint, person_status = person_status, joint = TRUE
    )
  slope_targets <- as.data.frame(slope$target_status %||% data.frame(),
                                 stringsAsFactors = FALSE)
  slope_candidate <- identical(
    as.character(slope$state %||% ""),
    "certified_monotone_boundary_path"
  ) && (
    nrow(slope_targets) == 0L ||
      ("CandidateStatus" %in% names(slope_targets) &&
       any(as.character(slope_targets$CandidateStatus) %in%
             c("boundary_path_both", "boundary_path_high",
               "boundary_path_low")))
  )
  nonlinear_complete <- if (identical(model, "GPCM")) {
    isTRUE(slope$structural_identification_complete)
  } else {
    TRUE
  }
  propagated <- !(additive_candidate || slope_candidate)
  complete <- person_complete && additive_complete && nonlinear_complete &&
    propagated
  state <- person_state
  if (additive_candidate || slope_candidate) {
    state <- "not_evaluated"
    reasons <- mfrmr_readiness_merge_codes(
      reasons, "boundary_candidate_not_propagated"
    )
  }
  if (!additive_complete || !nonlinear_complete) {
    state <- "not_evaluated"
    reasons <- mfrmr_readiness_merge_codes(reasons, "boundary_audit_incomplete")
  }
  if (!person_complete && !nzchar(reasons)) {
    reasons <- "boundary_audit_incomplete"
  }
  mfrmr_readiness_component_row(
    "boundary", state, complete, reasons,
    audit_state = paste0(
      "person=", person_state,
      ";structural=", structural$state %||% "missing",
      ";joint=", joint$state %||% "missing",
      ";slope=", slope$state %||% "missing"
    ),
    provenance = paste0(
      "person_and_constrained_recession_v1;method=", method,
      ";model=", model, ";parameter_map=mfrm_free_to_expanded_v1"
    )
  )
}

mfrmr_readiness_numerical_component <- function(opt) {
  diagnostics <- opt$optimizer_diagnostics %||% list()
  severity <- tolower(as.character(
    diagnostics$ConvergenceSeverity %||% ""
  )[1])
  reason <- tolower(as.character(
    diagnostics$ConvergenceReason %||% ""
  )[1])
  status <- tolower(as.character(
    diagnostics$ConvergenceStatus %||% ""
  )[1])
  state <- if (severity %in% c("pass", "ok")) {
    "ready"
  } else if (severity %in% c("review", "warn", "warning")) {
    "review"
  } else if (severity %in% c("fail", "error")) {
    "failed"
  } else {
    "not_run"
  }
  reasons <- character(0)
  if (state == "review") {
    if (grepl("iteration_limit", paste(reason, status))) {
      reasons <- "iteration_limit"
    } else if (grepl("gradient", reason)) {
      reasons <- "terminal_gradient_review"
    } else {
      reasons <- "optimizer_review_required"
    }
  } else if (state == "failed") {
    reasons <- c(
      "optimizer_failed",
      if (grepl("iteration_limit", paste(reason, status))) "iteration_limit"
    )
  } else if (state == "not_run") {
    reasons <- "numerical_not_run"
  }
  mfrmr_readiness_component_row(
    "numerical", state, state != "not_run", reasons,
    audit_state = paste0("severity=", severity, ";status=", status,
                         ";reason=", reason),
    provenance = "common_terminal_gradient_gate_v1"
  )
}

build_mfrm_readiness_record <- function(prep, data_review, config, opt) {
  components <- rbind(
    mfrmr_readiness_input_component(prep, data_review),
    mfrmr_readiness_estimability_component(config, prep),
    mfrmr_readiness_category_component(config),
    mfrmr_readiness_boundary_component(config),
    mfrmr_readiness_numerical_component(opt)
  )
  component_state <- stats::setNames(
    as.character(components$State), components$Component
  )
  fit_state <- mfrmr_readiness_derive_fit(
    component_state[["input"]],
    component_state[["estimability"]],
    component_state[["category"]],
    component_state[["boundary"]],
    component_state[["numerical"]]
  )
  all_reasons <- mfrmr_readiness_merge_codes(components$ReasonCodes)
  provenance <- paste0(
    "fit_readiness_builder_v1;contract=", mfrmr_readiness_contract_version(),
    ";method=", config$method %||% "unknown",
    ";model=", config$model %||% "unknown",
    ";scale=single_observed_scale"
  )
  fit <- data.frame(
    ReadinessContractVersion = mfrmr_readiness_contract_version(),
    ReadinessScope = "fit",
    InputState = unname(component_state[["input"]]),
    EstimabilityState = unname(component_state[["estimability"]]),
    CategoryState = unname(component_state[["category"]]),
    BoundaryState = unname(component_state[["boundary"]]),
    NumericalState = unname(component_state[["numerical"]]),
    FitReadiness = fit_state,
    InferenceReady = mfrmr_readiness_inference_ready(fit_state),
    ReasonCodes = all_reasons,
    AuditProvenance = provenance,
    stringsAsFactors = FALSE
  )
  out <- list(
    contract_version = mfrmr_readiness_contract_version(),
    fit = fit,
    components = components
  )
  class(out) <- c("mfrmr_readiness_record", "list")
  out
}

mfrmr_get_readiness_record <- function(fit) {
  if (inherits(fit, "mfrmr_readiness_record") &&
      is.data.frame(fit$fit) && nrow(fit$fit) == 1L &&
      "ReadinessContractVersion" %in% names(fit$fit) &&
      identical(
        as.character(fit$fit$ReadinessContractVersion[1]),
        mfrmr_readiness_contract_version()
      )) {
    return(fit)
  }
  stored <- if (is.list(fit)) fit$readiness else NULL
  stored_fit <- as.data.frame(stored$fit %||% data.frame(),
                              stringsAsFactors = FALSE)
  if (inherits(stored, "mfrmr_readiness_record") &&
      nrow(stored_fit) == 1L &&
      "ReadinessContractVersion" %in% names(stored_fit) &&
      identical(
        as.character(stored_fit$ReadinessContractVersion[1]),
        mfrmr_readiness_contract_version()
      )) {
    return(stored)
  }

  source_ready <- if (is.list(fit) && is.data.frame(fit$summary) &&
                      nrow(fit$summary) > 0L &&
                      "InferenceReady" %in% names(fit$summary)) {
    as.character(fit$summary$InferenceReady[1])
  } else {
    NA_character_
  }
  legacy_fit <- data.frame(
    ReadinessContractVersion = mfrmr_readiness_contract_version(),
    ReadinessScope = "fit",
    InputState = "legacy_unknown",
    EstimabilityState = "legacy_unknown",
    CategoryState = "legacy_unknown",
    BoundaryState = "legacy_unknown",
    NumericalState = "legacy_unknown",
    FitReadiness = "legacy_unknown",
    InferenceReady = FALSE,
    ReasonCodes = "legacy_contract_missing",
    AuditProvenance = paste0(
      "legacy_adapter_v1;source_inference_ready=", source_ready
    ),
    stringsAsFactors = FALSE
  )
  out <- list(
    contract_version = mfrmr_readiness_contract_version(),
    fit = legacy_fit,
    components = data.frame()
  )
  class(out) <- c("mfrmr_readiness_record", "list")
  out
}
