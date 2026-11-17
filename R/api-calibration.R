#' @noRd
mfrm_calibration_capabilities <- function() {
  .mfrmr_table_mfrm_calibration_capabilities_data
}

mfrmr_public_calibration_extraction_error <- function(error) {
  detail <- switch(
    as.character(error$code),
    MODEL_FAMILY_UNSUPPORTED = paste(
      "portable calibration is available only for RSM, PCM or GPCM fits;",
      "use fitted-object scoring for other model families"
    ),
    MODEL_ESTIMATOR_UNSUPPORTED = paste(
      "portable calibration supports the documented MML and JML models;",
      "check model and method compatibility before portable or fitted-object scoring"
    ),
    SCORING_BASIS_UNSUPPORTED = paste(
      "portable calibration supports fixed-normal RSM/PCM and two-family GPCM,",
      "or intercept-only estimated-normal one-family GPCM; use fitted-object scoring for other population models"
    ),
    NULL
  )
  if (is.null(detail)) stop(error)
  mfrmr_calibration_abort(error$code, error$field_path, detail)
}

mfrmr_validate_calibration_quadrature_review <- function(fit, review) {
  if (is.null(review)) {
    mfrmr_calibration_abort(
      "QUADRATURE_REVIEW_REQUIRED", "quadrature_review",
      paste(
        "run `mml_quadrature_sensitivity()` on the source data, inspect its",
        "continuous differences, and pass the review with its highest-grid fit"
      )
    )
  }
  if (!inherits(review, "mfrm_quadrature_sensitivity")) {
    mfrmr_calibration_abort(
      "QUADRATURE_REVIEW_INVALID", "quadrature_review",
      "the review must come from `mml_quadrature_sensitivity()`"
    )
  }
  nodes <- as.integer(review$settings$quad_points %||% integer())
  fits <- review$fits %||% list()
  runs <- as.data.frame(review$runs %||% data.frame(),
                        stringsAsFactors = FALSE)
  expected_names <- paste0("q", nodes)
  valid_shape <- length(nodes) >= 2L && !anyNA(nodes) &&
    identical(nodes, sort(unique(nodes))) &&
    length(fits) == length(nodes) && !anyDuplicated(names(fits)) &&
    setequal(names(fits), expected_names) &&
    nrow(runs) == length(nodes) &&
    all(c("Nodes", "EstimationConverged") %in% names(runs)) &&
    identical(as.integer(runs$Nodes), nodes) &&
    all(vapply(fits, inherits, logical(1L), what = "mfrm_fit"))
  if (!valid_shape) {
    mfrmr_calibration_abort(
      "QUADRATURE_REVIEW_INVALID", "quadrature_review",
      "the review must retain one fitted model and run record for every evaluated quadrature order"
    )
  }
  fits <- fits[expected_names]
  model <- toupper(as.character(fit$config$model %||% "")[1L])
  if (!identical(as.character(review$settings$model %||% ""), model)) {
    mfrmr_calibration_abort(
      "QUADRATURE_REVIEW_INVALID", "quadrature_review.settings.model",
      "the review model does not match the selected source fit"
    )
  }
  if (!all(vapply(fits, function(candidate) {
    identical(toupper(as.character(candidate$config$model %||% "")[1L]), model) &&
      identical(public_mfrm_method_label(candidate$config$method %||% ""),
                "MML") &&
      isTRUE(tryCatch(
        mfrmr_gqs_same_prepared_data(fits[[1L]], candidate),
        error = function(condition) FALSE
      ))
  }, logical(1L)))) {
    mfrmr_calibration_abort(
      "QUADRATURE_REVIEW_INVALID", "quadrature_review.fits",
      "the reviewed fits do not share one model and prepared response dataset"
    )
  }
  same_settings <- tryCatch({
    comparison_model <- function(candidate) {
      model <- mfrm_checkpoint_objective_components(list(), candidate$config)$model
      if (identical(candidate$config$model, "GPCM")) {
        # Population estimates vary across grids by design. Compare their
        # specification, while convergence and the exact selected fit are
        # checked separately below.
        model$population_spec[c("coefficients", "sigma2", "source", "notes")] <- NULL
      }
      model
    }
    reference_arguments <- mfrmr_gqs_refit_arguments(fits[[1L]], NULL, 2L)
    reference_model <- comparison_model(fits[[1L]])
    all(vapply(seq_along(fits), function(i) {
      candidate <- fits[[i]]
      candidate_nodes <- candidate$config$estimation_control$quad_points
      identical(as.numeric(candidate_nodes), as.numeric(nodes[i])) &&
        identical(mfrmr_gqs_refit_arguments(candidate, NULL, 2L),
                  reference_arguments) &&
        identical(comparison_model(candidate), reference_model) &&
        identical(candidate$prep$score_map, fits[[1L]]$prep$score_map)
    }, logical(1L)))
  }, error = function(condition) FALSE)
  if (!isTRUE(same_settings)) {
    mfrmr_calibration_abort(
      "QUADRATURE_REVIEW_INVALID", "quadrature_review.fits",
      paste(
        "each reviewed fit must use its recorded quadrature order and the same",
        "score map, model, anchors, integration mode and fitting settings"
      )
    )
  }
  if (!isTRUE(all(as.logical(runs$EstimationConverged))) ||
      !all(vapply(fits, function(candidate) {
        identical(as.integer(candidate$opt$convergence), 0L)
      }, logical(1L)))) {
    mfrmr_calibration_abort(
      "QUADRATURE_REVIEW_INCOMPLETE", "quadrature_review.runs",
      "every evaluated quadrature fit must complete estimation"
    )
  }
  source_nodes <- as.integer(
    fit$config$estimation_control$quad_points %||%
      fit$config$quad_points %||% NA_integer_
  )[1L]
  source_name <- paste0("q", source_nodes)
  if (!identical(source_nodes, max(nodes)) ||
      !source_name %in% names(fits) || !identical(fit, fits[[source_name]])) {
    mfrmr_calibration_abort(
      "QUADRATURE_SOURCE_NOT_HIGHEST", "fit",
      paste(
        "select the exact highest-grid fit stored in the reviewed object;",
        "the package does not choose a numerical tolerance for you"
      )
    )
  }
  invisible(TRUE)
}

#' Create and use a portable fixed calibration
#'
#' @description
#' Manage a fail-closed, versioned portable calibration lifecycle (`draft` ->
#' `"validated"` -> `"frozen"` -> `"superseded"` / `"retired"`) for scoring new
#' response rows without training data or an executable fit object. Only a
#' `"frozen"` artifact can be passed to [score_mfrm_calibration()].
#'
#' @details
#' **Supported formats and source checks.**
#' - **Format 1**: ordinary RSM/PCM MML (`N(0, 1)` prior, retaining anchors and
#'   two-way interactions; requires `quadrature_review` from
#'   [mml_quadrature_sensitivity()] with `fit` equal to the highest-grid fit).
#' - **Format 2**: one-family GPCM MML (unit weights, no anchors/interactions,
#'   intercept-only normal population; checks local likelihood, gradient,
#'   unregularized Hessian, and source/batch integration).
#' - **Format 3 / Format 4**: unit-weight unanchored RSM/PCM JML (format 3) and
#'   shared-owner GPCM JML (format 4, checking positive-definite joint curvature
#'   with reciprocal condition `> 1e-10`), scored under a post-hoc `N(0, 1)`
#'   reference prior.
#' - **Format 5**: experimental corrected GPCM JML (`jml_correction_order`),
#'   checking mean-equation residual `<= 1e-7` and Newton step `<= 1e-5`.
#' - **Formats 6 & 7**: experimental two-family GPCM MML (`N(0, 1)` prior, two
#'   slope owners, plus extended named `slope_reference`/`noncenter_facet` roles
#'   in format 7; `row_dispositions$ObservedContext` flags novel facet combinations).
#'
#' New v2 artifacts invert the continuous posterior CDF for equal-tail intervals
#' while retaining stored quadrature for EAP and `SD` (conditional on the frozen
#' point calibration and prior, excluding calibration/anchor uncertainty;
#' Bock & Mislevy, 1982, \doi{10.1177/014662168200600405}; Muraki, 1992,
#' \doi{10.1177/014662169201600206}). See
#' `mfrmr_output_guide("calibration_capabilities")`.
#'
#' @param fit Eligible `mfrm_fit` from [fit_mfrm()].
#' @param calibration_id Optional identifiers and
#'   RFC3339 UTC timestamp.
#' @param source_fit_id Optional identifiers and
#'   RFC3339 UTC timestamp.
#' @param created_at_utc Optional identifiers and
#'   RFC3339 UTC timestamp.
#' @param scoring_quad_points Quadrature order (`>= 2`, default `31`) stored for
#'   artifact scoring (inherits fixed vs adaptive mode from `fit`).
#' @param quadrature_review Required `mfrm_quadrature_sensitivity` object for
#'   RSM/PCM MML (`fit` must be its highest-grid fit); optional for GPCM MML.
#' @param calibration An `mfrm_calibration` object (`object` in
#'   `update()`, `summary()`, `print()`, or `mfrm_calibration_score` in score
#'   methods).
#' @param object An `mfrm_calibration` object (`object` in
#'   `update()`, `summary()`, `print()`, or `mfrm_calibration_score` in score
#'   methods).
#' @param status Target lifecycle state in `update()`
#'   (`"validated"`, `"frozen"`, `"superseded"`, `"retired"`), optional RFC3339
#'   timestamp, and distinct terminal `record_id`.
#' @param at_utc Target lifecycle state in `update()`
#'   (`"validated"`, `"frozen"`, `"superseded"`, `"retired"`), optional RFC3339
#'   timestamp, and distinct terminal `record_id`.
#' @param record_id Target lifecycle state in `update()`
#'   (`"validated"`, `"frozen"`, `"superseded"`, `"retired"`), optional RFC3339
#'   timestamp, and distinct terminal `record_id`.
#' @param ... Additional arguments (rejected in `update()`, forwarded in S3
#'   print/plot methods where documented).
#' @param file `.rds` file path and replacement logical.
#' @param overwrite `.rds` file path and replacement logical.
#' @param new_data New-Person response
#'   `data.frame` and optional column/facet mappings (`event_id` distinguishes
#'   repeated events where supported).
#' @param person New-Person response
#'   `data.frame` and optional column/facet mappings (`event_id` distinguishes
#'   repeated events where supported).
#' @param score New-Person response
#'   `data.frame` and optional column/facet mappings (`event_id` distinguishes
#'   repeated events where supported).
#' @param weight New-Person response
#'   `data.frame` and optional column/facet mappings (`event_id` distinguishes
#'   repeated events where supported).
#' @param event_id New-Person response
#'   `data.frame` and optional column/facet mappings (`event_id` distinguishes
#'   repeated events where supported).
#' @param facets New-Person response
#'   `data.frame` and optional column/facet mappings (`event_id` distinguishes
#'   repeated events where supported).
#' @param interval_level Central posterior interval level in
#'   `(0, 1)` and missing-score policy (`"error"` or `"omit"`).
#' @param missing_response Central posterior interval level in
#'   `(0, 1)` and missing-score policy (`"error"` or `"omit"`).
#' @param adaptive_quad_points Optional adaptive
#'   reference orders (`>= 2` integers `>= 3`), shared normal prior override
#'   `list(mean = ..., sd = ...)`, and strictly increasing ability `cut_scores`
#'   (unit-weight continuous-posterior RSM/PCM only).
#' @param scoring_prior Optional adaptive
#'   reference orders (`>= 2` integers `>= 3`), shared normal prior override
#'   `list(mean = ..., sd = ...)`, and strictly increasing ability `cut_scores`
#'   (unit-weight continuous-posterior RSM/PCM only).
#' @param cut_scores Optional adaptive
#'   reference orders (`>= 2` integers `>= 3`), shared normal prior override
#'   `list(mean = ..., sd = ...)`, and strictly increasing ability `cut_scores`
#'   (unit-weight continuous-posterior RSM/PCM only).
#'
#' @return `extract_mfrm_calibration()`, `update()`, and
#'   `load_mfrm_calibration()` return `mfrm_calibration`;
#'   `review_mfrm_calibration()` returns a refusal `data.frame` (`0` rows when
#'   valid); `save_mfrm_calibration()` invisibly returns the path;
#'   `score_mfrm_calibration()` returns `mfrm_calibration_score` (`estimates`,
#'   `decisions`, `quadrature_review`, row/Person dispositions).
#' @seealso [mml_quadrature_sensitivity()], [predict_mfrm_units()],
#'   [mfrmr_output_guide()]
#' @name mfrm_calibration_workflow
#' @aliases validate_mfrm_calibration freeze_mfrm_calibration supersede_mfrm_calibration retire_mfrm_calibration
NULL

#' @rdname mfrm_calibration_workflow
#' @export
extract_mfrm_calibration <- function(fit, calibration_id = NULL,
                                     source_fit_id = NULL,
                                     created_at_utc = NULL,
                                     scoring_quad_points = 31L,
                                     quadrature_review = NULL) {
  draft <- tryCatch(
    mfrmr_extract_calibration_draft(
      fit = fit,
      calibration_id = calibration_id,
      source_fit_id = source_fit_id,
      created_at_utc = created_at_utc,
      scoring_quad_points = scoring_quad_points
    ),
    mfrm_calibration_error = mfrmr_public_calibration_extraction_error
  )
  if (mfrm_has_product_slopes(fit)) {
    if (!is.null(quadrature_review)) stop("Two-family extraction uses its own source identity, convergence and finer-integration checks; quadrature_review is not accepted.", call. = FALSE)
  } else if (identical(fit$config$method, "JML")) {
    if (!is.null(quadrature_review)) stop("JML extraction does not use an MML quadrature review; scoring integration is checked for each new batch.", call. = FALSE)
  } else if (!identical(fit$config$model, "GPCM") || !is.null(quadrature_review)) {
    mfrmr_validate_calibration_quadrature_review(fit, quadrature_review)
  }
  draft
}

#' @rdname mfrm_calibration_workflow
#' @export
review_mfrm_calibration <- function(calibration) {
  mfrmr_review_calibration(calibration)
}

#' @rdname mfrm_calibration_workflow
#' @importFrom stats update
#' @export
update.mfrm_calibration <- function(object, status, record_id = NULL,
                                     at_utc = NULL, ...) {
  if (length(list(...))) stop("Unused arguments to update.mfrm_calibration().", call. = FALSE)
  status <- match.arg(status, c("validated", "frozen", "superseded", "retired"))
  if (status %in% c("validated", "frozen") && !is.null(record_id)) {
    stop("`record_id` is only used for superseded or retired calibrations.", call. = FALSE)
  }
  switch(status,
    validated = mfrmr_validate_calibration_draft(object, at_utc),
    frozen = mfrmr_freeze_calibration(object, at_utc),
    superseded = mfrmr_supersede_calibration(object, record_id, at_utc),
    retired = mfrmr_retire_calibration(object, record_id, at_utc))
}

#' @rdname mfrm_calibration_workflow
#' @export
save_mfrm_calibration <- function(calibration, file, overwrite = FALSE) {
  mfrmr_save_calibration(calibration, file, overwrite)
}

#' @rdname mfrm_calibration_workflow
#' @export
load_mfrm_calibration <- function(file) {
  mfrmr_load_calibration(file)
}

#' @rdname mfrm_calibration_workflow
#' @export
score_mfrm_calibration <- function(calibration,
                                   new_data,
                                   person = NULL,
                                   facets = NULL,
                                   score = NULL,
                                   weight = NULL,
                                   interval_level = 0.95,
                                   missing_response = "error",
                                   event_id = NULL,
                                   adaptive_quad_points = NULL,
                                   scoring_prior = NULL,
                                   cut_scores = NULL) {
  mfrmr_score_calibration(
    calibration = calibration,
    new_data = new_data,
    person = person,
    facets = facets,
    score = score,
    weight = weight,
    interval_level = interval_level,
    missing_response = missing_response,
    event_id = event_id,
    adaptive_quad_points = adaptive_quad_points,
    scoring_prior = scoring_prior,
    cut_scores = cut_scores
  )
}
