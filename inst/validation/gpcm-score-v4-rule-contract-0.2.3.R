# Prospective no-execution GPCM score v4 rule after the negative v3
# confirmation. V4 changes constructed-boundary classification only; all four
# calibrated numerical comparison rules remain unchanged.

mfrmr_gsv4_contract_version <- "mfrmr_gpcm_score_rule_contract_v4"
mfrmr_gsv4_envelope <- 3
mfrmr_gsv4_unit_roundoff <- .Machine$double.eps / 2
mfrmr_gsv4_constructed_points <- c(
  "coupled_free_probe", "finite_slope_stress_forward",
  "finite_slope_stress_reverse"
)

mfrmr_gsv4_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4_rule_registry <- function() {
  data.frame(
    Rule = c("independent_analytic_score", "finite_difference_score",
             "expanded_log_jacobian", "expanded_slope_jacobian"),
    AbsoluteFloor = c(1e-8, 1e-7, 5e-10, 1e-9),
    RelativeRate = c(1e-10, 5e-7, 1e-9, 1e-9),
    ReferenceSpreadMultiplier = c(0, 10, 0, 0),
    RoundoffMultiplier = c(0, 10, 0, 0),
    ChangedFromV3 = FALSE, ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4_construction_roundoff_bound <- function(expanded_log_slopes) {
  z <- suppressWarnings(as.numeric(expanded_log_slopes))
  mfrmr_gsv4_assert(length(z) >= 2L && all(is.finite(z)),
                    "Expanded log slopes must be finite with at least two levels.")
  free <- z[-length(z)]
  n <- length(free)
  u <- mfrmr_gsv4_unit_roundoff
  gamma_n <- n * u / (1 - n * u)
  input_rounding_bound <- 2 * u * sum(pmax(1, abs(free)))
  summation_bound <- gamma_n * sum(abs(free))
  comparison_bound <- 2 * u * max(1, mfrmr_gsv4_envelope, abs(z))
  data.frame(
    UnitRoundoff = u, FreeCoordinates = n, GammaN = gamma_n,
    InputRoundingBound = input_rounding_bound,
    SummationBound = summation_bound,
    ComparisonBound = comparison_bound,
    TotalBound = input_rounding_bound + summation_bound + comparison_bound,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4_classify_log_slopes <- function(expanded_log_slopes, point) {
  z <- suppressWarnings(as.numeric(expanded_log_slopes))
  point <- as.character(point)[1]
  if (length(z) < 2L || any(!is.finite(z)) || is.na(point)) {
    return(data.frame(Region = "not_evaluable", RawMaximum = NA_real_,
                      RawExcess = NA_real_, Allowance = NA_real_,
                      AllowanceApplied = FALSE, stringsAsFactors = FALSE))
  }
  mfrmr_gsv4_assert(
    point %in% c("retained_solution", mfrmr_gsv4_constructed_points),
    "Unknown v4 point identity."
  )
  raw_maximum <- max(abs(z))
  raw_excess <- max(0, raw_maximum - mfrmr_gsv4_envelope)
  constructed <- point %in% mfrmr_gsv4_constructed_points
  allowance <- if (constructed) {
    mfrmr_gsv4_construction_roundoff_bound(z)$TotalBound
  } else 0
  finite <- raw_maximum <= mfrmr_gsv4_envelope + allowance
  data.frame(
    Region = if (finite) "finite_slope_region" else
      "extreme_slope_review_handoff",
    RawMaximum = raw_maximum, RawExcess = raw_excess,
    Allowance = allowance, AllowanceApplied = constructed && raw_excess > 0,
    Point = point, RetainedSolutionRescued = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4_authorization_schema <- function() {
  data.frame(
    Field = c(
      "Status", "ContractVersion", "RunnerIdentitySHA256", "ManifestSHA256",
      "AuthorizationSHA256", "OutputPath", "ProcessId", "IssuedAtUTC",
      "ExecutionAuthorized", "IssuedNotExecuted", "ConsumedAtUTC"
    ),
    RequiredInSavedResult = TRUE,
    PostHocReconstructionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4_contract <- function() {
  list(
    contract_version = mfrmr_gsv4_contract_version,
    v3_confirmation_status = "rejected_unchanged",
    v3_opened_fixtures_role = "retrospective_calibration_only",
    envelope = mfrmr_gsv4_envelope,
    unit_roundoff = mfrmr_gsv4_unit_roundoff,
    constructed_boundary_allowance = paste0(
      "2*u*sum(max(1,abs(free))) + gamma_n*sum(abs(free)) + ",
      "2*u*max(1,envelope,max(abs(expanded)))"
    ),
    retained_solution_allowance = 0,
    rules = mfrmr_gsv4_rule_registry(),
    authorization_schema = mfrmr_gsv4_authorization_schema(),
    exact_consumed_authorization_must_be_embedded = TRUE,
    result_execution_authorized = FALSE,
    confirmation_authorized = FALSE,
    general_num_score_tol_frozen = FALSE,
    inference_authorized = FALSE
  )
}
