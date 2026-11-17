#' GPCM Workflow, Identification, and Score Availability
#'
#' @description
#' Reference for one-family and provisional two-family `GPCM` support in
#' `mfrmr`. Call `mfrmr_output_guide("gpcm_capabilities")` (`view = "workflows"`,
#' `"scores"`, or `"unavailable"`) to inspect route-level availability,
#' interpretive boundaries, and recommended alternatives.
#'
#' @details
#' Workflow `Status` values in `mfrmr_output_guide("gpcm_capabilities")`:
#' - `supported`: available within the stated `Boundary`;
#' - `supported_with_caveat`: runs with restricted interpretation in `Boundary`;
#' - `blocked`: intentionally stops for a `GPCM` fit;
#' - `deferred`: not currently implemented in `mfrmr` (follow `RecommendedRoute`).
#'
#' Score-view (`view = "scores"`) statuses distinguish `available_with_caveat`,
#' `supporting_route`, and `unavailable`.
#'
#' **One-family vs two-family scope.** One-family `GPCM` estimates positive
#' relative discriminations (geometric mean `1`) on `slope_facet`; MML permits
#' `slope_facet != step_facet` and defaults to `gpcm_mml_identification =
#' "free_population"` (estimating population SD \eqn{\sigma}, so standardized
#' unit-variance slopes are \eqn{a_i = \sigma\alpha_i}), whereas JML requires
#' `slope_facet == step_facet` and offers exploratory location SEs without
#' structural slope intervals. Provisional two-family `GPCM` requires fixed
#' \eqn{N(0,1)} MML (`"em"` fixed-grid or `"direct"` adaptive) on zero-based
#' unweighted integer scores (`0:rating_max`). When extreme responses occur on
#' one non-reference facet, `fit$point_limit` records any supported
#' limiting-likelihood refit (`PrimaryEstimate` vs working `OptimizerEstimate`,
#' or `neutral_boundary_reference` when full optimization is skipped).
#'
#' @section Intervals, model comparison, and software alignment:
#' | Target | Entry and requirement |
#' | --- | --- |
#' | Relative / standardized slope intervals | [confint.mfrm_fit()] (`parm = "slopes"`): joint observed information (or Person/cluster sandwich, or 1-parameter `"profile"`); inspect `CIEligible` and `CoverageQualified` |
#' | Facet locations, steps, and curves | [mfrm_facet_intervals()], `confint(fit, parm = "steps")` (two-family), [mfrm_curve_intervals()] |
#' | IC ranking and nested equal-slope LRT | [compare_mfrm()] (`ICSelectable`, `ICFitEligible`, `ICComparable`; `nested = TRUE` requires matched population and step constraints) |
#' | Conditional Person scoring | [predict_mfrm_units()] and [extract_mfrm_calibration()] (fixed calibration + normal prior; excludes calibration uncertainty) |
#'
#' Because `mfrmr` multiplies the complete adjacent-category predictor
#' \eqn{\alpha_g(\theta_n - \delta_j - \beta_i - \tau_{h,k})} by the slope,
#' comparisons with `TAM` or ConQuest must match slope placement, population SD,
#' and centering constraints. Worked derivations and empirical examples appear
#' on the package website
#' (<https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.html>).
#'
#' @references
#' Muraki, E. (1992). A generalized partial credit model: Application of an EM
#' algorithm. *Applied Psychological Measurement, 16*(2), 159--176.
#' \doi{10.1177/014662169201600206}
#'
#' Masters, G. N. (1982). A Rasch model for partial credit scoring.
#' *Psychometrika, 47*(2), 149--174. \doi{10.1007/BF02296272}
#'
#' Bock, R. D., & Aitkin, M. (1981). Marginal maximum likelihood estimation of
#' item parameters: Application of an EM algorithm. *Psychometrika, 46*(4),
#' 443--459. \doi{10.1007/BF02293801}
#'
#' @seealso [mfrmr_output_guide()], [fit_mfrm()], [fit_mfrm_technical_details],
#'   [confint.mfrm_fit()], [mfrm_curve_intervals()], [compare_mfrm()]
#' @examples
#' mfrmr_output_guide("gpcm_capabilities")
#' mfrmr_output_guide("gpcm_capabilities", "supported")
#' mfrmr_output_guide("gpcm_capabilities", view = "scores")
#' mfrmr_output_guide("gpcm_capabilities", view = "unavailable")
#' @concept GPCM boundaries
#' @concept route selection
#' @name mfrmr_gpcm_scope
NULL

#' @noRd
gpcm_capability_matrix <- function(status = "all", view = c("workflows", "scores", "unavailable")) {
  view <- match.arg(view)
  if (view == "scores") return(.gpcm_score_capabilities(status))
  status <- match.arg(status, c("all", "supported", "supported_with_caveat", "blocked", "deferred"))
  if (view == "unavailable") {
    out <- .mfrmr_const_.gpcm_unavailable_routes
    if (status != "all") out <- out[out$Status == status, , drop = FALSE]
    rownames(out) <- NULL
    return(out)
  }
  out <- .gpcm_capability_registry(status)
  out <- out[, c(
    "Area", "Helpers", "Status", "Boundary", "RecommendedRoute"
  ), drop = FALSE]
  out$Helpers[out$Status == "deferred"] <- NA_character_
  rownames(out) <- NULL
  class(out) <- c("mfrmr_gpcm_capabilities", "data.frame")
  out
}

#' @export
#' @method print mfrmr_gpcm_capabilities
#' @noRd
print.mfrmr_gpcm_capabilities <- function(x, ...) {
  status_levels <- c(
    "supported", "supported_with_caveat", "blocked", "deferred"
  )
  counts <- table(factor(x$Status, levels = status_levels))
  status_summary <- data.frame(
    Status = names(counts),
    Routes = as.integer(counts),
    stringsAsFactors = FALSE
  )
  status_summary <- status_summary[status_summary$Routes > 0L, , drop = FALSE]

  cat("mfrmr GPCM workflow availability\n")
  cat("Most rows describe one slope family; two-family MML has a separate provisional scope.\n")
  cat("MML IC comparison and PCM/GPCM tests have separate checks; relative-slope intervals use separate MML checks.\n\n")
  print.data.frame(status_summary, row.names = FALSE)

  max_rows <- min(nrow(x), 8L)
  if (max_rows > 0L) {
    cat("\nRoute preview\n")
    preview <- x[seq_len(max_rows), c("Area", "Status"), drop = FALSE]
    print.data.frame(preview, row.names = FALSE)
  }
  if (nrow(x) > max_rows) {
    cat("\n... ", nrow(x) - max_rows, " more route(s).\n", sep = "")
  }
  cat(
    "\nFilter by status, for example ",
    "mfrmr_output_guide(\"gpcm_capabilities\", \"supported_with_caveat\").\n",
    "Read Boundary and RecommendedRoute before interpreting a caveated or ",
    "unavailable route.\n",
    sep = ""
  )
  invisible(x)
}

.gpcm_capability_registry <- function(status = c("all", "supported", "supported_with_caveat", "blocked", "deferred")) {
  status <- match.arg(status)

  out <- .mfrmr_table_.gpcm_capability_registry_out

  out <- rbind(out,.mfrmr_table_.gpcm_capability_registry_data)
  if (!identical(status, "all")) {
    out <- out[out$Status == status, , drop = FALSE]
  }

  rownames(out) <- NULL
  out
}

.gpcm_score_capabilities <- function(status = "all") {
  status <- as.character(status[1])
  public_status <- c(
    "all", "available_with_caveat", "supporting_route", "unavailable"
  )
  legacy_status <- c(
    "implemented_with_caveat", "required_for_full_facets_review",
    "validated_dependency"
  )
  if (is.na(status) || !nzchar(status) ||
      !status %in% c(public_status, legacy_status)) {
    stop(
      "`status` must be one of: ",
      paste(sprintf('"%s"', public_status), collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  registry <- .gpcm_score_side_contract_registry
  if (status %in% legacy_status) {
    registry <- registry[
      registry$CompatibilityStatus == status, , drop = FALSE
    ]
  } else if (!identical(status, "all")) {
    registry <- registry[registry$PublicStatus == status, , drop = FALSE]
  }
  out <- registry[, c(
    "Capability", "PublicStatus", "Limitation", "Alternative"
  ), drop = FALSE]
  names(out)[names(out) == "PublicStatus"] <- "Status"
  rownames(out) <- NULL
  out
}

.gpcm_score_side_contract_registry <- .mfrmr_table_.gpcm_score_side_contract_registry_data

.gpcm_runtime_guard_registry <- function() {
  matrix <- .gpcm_capability_registry()
  guard <- data.frame(
    CapabilityID = c(
      "facets_score_review",
      "mcmc_backends",
      "corrected_jml_inference"
    ),
    Helper = c(
      "facets_output_contract_review()",
      NA_character_,
      NA_character_
    ),
    AvailabilityMode = c(
      "structured_error",
      "no_public_helper",
      "no_public_helper"
    ),
    ConditionClass = c(
      "mfrmr_gpcm_scope_error",
      NA_character_,
      NA_character_
    ),
    stringsAsFactors = FALSE
  )

  idx <- match(guard$CapabilityID, matrix$CapabilityID)
  guard$Area <- matrix$Area[idx]
  guard$Status <- matrix$Status[idx]
  guard$RecommendedRoute <- matrix$RecommendedRoute[idx]
  guard <- guard[, c(
    "CapabilityID", "Area", "Helper", "Status", "AvailabilityMode",
    "ConditionClass", "RecommendedRoute"
  )]
  rownames(guard) <- NULL
  guard
}
