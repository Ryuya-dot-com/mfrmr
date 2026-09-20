#' Portable fixed-calibration capabilities
#'
#' Returns the model and estimator combinations supported by the portable
#' calibration workflow. This matrix concerns saved calibration artifacts;
#' it does not replace the wider fitted-object capabilities of [fit_mfrm()] or
#' [predict_mfrm_units()].
#'
#' @return A data frame with one row per model, estimator, and scoring-basis
#'   combination. `PortableCalibration` is either `"available"` or
#'   `"unavailable"`.
#' @export
#'
#' @examples
#' mfrm_calibration_capabilities()
mfrm_calibration_capabilities <- function() {
  data.frame(
    Model = c(
      "RSM", "PCM", "RSM/PCM", "bounded GPCM", "RSM/PCM", "bounded GPCM"
    ),
    Estimator = c("MML", "MML", "MML", "MML", "JML", "JML"),
    ScoringBasis = c(
      "fixed standard normal", "fixed standard normal",
      "estimated population or latent regression",
      "fixed or estimated population", "post-hoc scoring prior",
      "post-hoc scoring prior"
    ),
    PortableCalibration = c(
      "available", "available", rep("unavailable", 4L)
    ),
    AnchorSupport = c(
      "stored direct and group facet anchors",
      "stored direct and group facet anchors",
      rep("not available for portable calibration", 4L)
    ),
    InteractionSupport = c(
      "stored two-way facet interactions",
      "stored two-way facet interactions",
      rep("not available for portable calibration", 4L)
    ),
    ExistingAlternative = c(
      "portable artifact or fitted-object scoring",
      "portable artifact or fitted-object scoring",
      "use fitted-object scoring with the fitted population model",
      "use fitted-object bounded-GPCM scoring",
      "use fitted-object scoring with an explicit post-hoc prior",
      "use fitted-object bounded-GPCM scoring with an explicit post-hoc prior"
    ),
    Limitation = c(
      paste(
        "one observed score scale, one latent dimension, known facet levels,",
        "and an explicit same-data quadrature review"
      ),
      paste(
        "one observed score scale, one latent dimension, known facet levels,",
        "and an explicit same-data quadrature review"
      ),
      "population coding and conditional parameters are not stored in the artifact",
      "relative-slope ownership is not stored in the artifact",
      "source JML Person coordinates are excluded from the artifact",
      "relative slopes and a JML scoring prior are not stored in the artifact"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_public_calibration_extraction_error <- function(error) {
  detail <- switch(
    as.character(error$code),
    MODEL_FAMILY_UNSUPPORTED = paste(
      "portable calibration is available only for RSM or PCM fits;",
      "use fitted-object scoring for other model families"
    ),
    MODEL_ESTIMATOR_UNSUPPORTED = paste(
      "portable calibration is available only for MML fits;",
      "use fitted-object scoring for JML fits"
    ),
    SCORING_BASIS_UNSUPPORTED = paste(
      "portable calibration does not store estimated-population or",
      "latent-regression scoring state; use fitted-object scoring"
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
    identical(names(fits), expected_names) &&
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
    reference_arguments <- mfrmr_gqs_refit_arguments(fits[[1L]], NULL, 2L)
    reference_model <- mfrm_checkpoint_objective_components(
      list(), fits[[1L]]$config
    )$model
    all(vapply(seq_along(fits), function(i) {
      candidate <- fits[[i]]
      candidate_nodes <- candidate$config$estimation_control$quad_points
      identical(as.numeric(candidate_nodes), as.numeric(nodes[i])) &&
        identical(mfrmr_gqs_refit_arguments(candidate, NULL, 2L),
                  reference_arguments) &&
        identical(mfrm_checkpoint_objective_components(
          list(), candidate$config
        )$model, reference_model) &&
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
#' These functions implement a strict lifecycle for a saved, versioned
#' calibration. [extract_mfrm_calibration()] creates a draft from an eligible
#' `RSM` or `PCM` MML fit under the fixed standard-normal scoring basis.
#' [validate_mfrm_calibration()] and [freeze_mfrm_calibration()] are separate,
#' fail-closed transitions. Only a frozen artifact can be passed to
#' [score_mfrm_calibration()].
#'
#' The portable 0.2.4 workflow supports one observed score scale, one latent
#' dimension, known non-Person facet levels, and stored two-way facet
#' interactions. Estimated-population or latent-regression MML, JML, and
#' bounded `GPCM` remain available only through their fitted-object routes; see
#' [mfrm_calibration_capabilities()].
#'
#' Before extraction, run [mml_quadrature_sensitivity()] on user-selected grids
#' and inspect its continuous differences. Pass the exact highest-grid fit in
#' that object together with `quadrature_review`. The retained fits must use
#' their recorded grid sizes and the same data, score map and fitting settings,
#' including anchors and integration mode, and must all have converged.
#' This procedural requirement
#' does not declare the fit numerically stable: the package does not choose the
#' application-specific tolerance or decide whether more grids are needed.
#' Archive the review separately when it is part of the audit trail, because
#' response-linked fits are deliberately not embedded in the portable artifact.
#'
#' Posterior EAP estimates, posterior standard deviations, and intervals are
#' conditional on the frozen point calibration and its recorded fixed
#' standard-normal prior. They do not include calibration-parameter
#' uncertainty. Loading validates structure and semantic consistency, but does
#' not authenticate an artifact from an untrusted source.
#' New v2 scoring algorithms invert the continuous posterior CDF for equal-tail
#' intervals. EAP and SD retain the stored quadrature rule. Saved v1 artifacts
#' preserve their discrete grid interval endpoints and carry a note that the
#' continuous posterior mass can differ from the requested interval level.
#'
#' @param fit An eligible `mfrm_fit` produced by [fit_mfrm()].
#' @param calibration_id Optional nonempty calibration identifier.
#' @param source_fit_id Optional nonempty source-fit identifier.
#' @param created_at_utc Optional RFC3339 UTC timestamp. Omit it to use the
#'   current time.
#' @param scoring_quad_points Integer quadrature order of at least 2 used for
#'   later artifact scoring. It is independent of the fit-time quadrature and
#'   defaults to 31. The fixed or adaptive integration mode is inherited from
#'   the source fit and stored in the artifact's scoring algorithm identity.
#'   With adaptive scoring, stored nodes and weights define the base Hermite
#'   rule; their person-specific locations are recomputed for each new batch.
#' @param quadrature_review An `mfrm_quadrature_sensitivity` from
#'   [mml_quadrature_sensitivity()] for the same data and model. `fit` must be
#'   the exact highest-grid fit stored in this object. The package checks this
#'   procedural evidence but leaves acceptable numerical movement to the user.
#' @param calibration An `mfrm_calibration` object.
#' @param validated_at_utc,frozen_at_utc Optional RFC3339 UTC timestamps for
#'   reproducible lifecycle records. Omit them to use the current time.
#' @param record_id A nonempty identifier for a terminal superseded or retired
#'   record. It must differ from the frozen parent identifier.
#' @param superseded_at_utc,retired_at_utc Optional RFC3339 UTC timestamps.
#' @param file A path ending in `.rds`.
#' @param overwrite Whether an existing persistence target may be replaced.
#' @param new_data A data frame of response rows for new Persons.
#' @param person,score,weight,event_id Optional input-column names. Stored
#'   source-column names are used when applicable. `event_id` distinguishes
#'   otherwise duplicate response events.
#' @param facets Optional named character vector mapping stored facet names to
#'   input columns.
#' @param interval_level Central posterior interval level, strictly between 0
#'   and 1.
#' @param missing_response Either `"error"` or `"omit"`.
#' @param adaptive_quad_points Optional vector of at least two distinct integer
#'   orders >= 3, for example `c(31, 61)`, used only by
#'   `score_mfrm_calibration()`. Adds an unrounded `quadrature_review` comparing
#'   stored-grid results with mode/curvature-adapted integration for each Person.
#'   Inspect both fixed/adaptive differences and changes between adaptive orders.
#'   The artifact, reported scores/intervals and readiness are unchanged;
#'   adaptive results are diagnostics conditional on the same point calibration.
#'   Only Persons with scored responses have numerical review rows. `Status =
#'   "computed"` means the calculation finished, not that accuracy is certified;
#'   an unavailable row retains the reason in `Detail`.
#'
#' @return `extract_mfrm_calibration()`, `validate_mfrm_calibration()`,
#'   `freeze_mfrm_calibration()`, `supersede_mfrm_calibration()`,
#'   `retire_mfrm_calibration()`, and `load_mfrm_calibration()` return an
#'   `mfrm_calibration`. `review_mfrm_calibration()` returns a data frame of
#'   structured refusals, with zero rows for an acceptable object.
#'   `save_mfrm_calibration()` invisibly returns the normalized path.
#'   `score_mfrm_calibration()` returns an `mfrm_calibration_score` containing
#'   estimates plus row and Person dispositions and scoring identities.
#'   When requested and scored rows exist, `quadrature_review` contains the
#'   fixed/adaptive comparison; `summary()` preserves it and adds a compact
#'   `quadrature_overview`.
#'
#' @seealso [mml_quadrature_sensitivity()], [mfrm_calibration_score_methods]
#'   for concise review and visualization of returned score batches.
#'
#' @name mfrm_calibration_workflow
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
  mfrmr_validate_calibration_quadrature_review(fit, quadrature_review)
  draft
}

#' @rdname mfrm_calibration_workflow
#' @export
review_mfrm_calibration <- function(calibration) {
  mfrmr_review_calibration(calibration)
}

#' @rdname mfrm_calibration_workflow
#' @export
validate_mfrm_calibration <- function(calibration, validated_at_utc = NULL) {
  mfrmr_validate_calibration_draft(calibration, validated_at_utc)
}

#' @rdname mfrm_calibration_workflow
#' @export
freeze_mfrm_calibration <- function(calibration, frozen_at_utc = NULL) {
  mfrmr_freeze_calibration(calibration, frozen_at_utc)
}

#' @rdname mfrm_calibration_workflow
#' @export
supersede_mfrm_calibration <- function(calibration, record_id,
                                       superseded_at_utc = NULL) {
  mfrmr_supersede_calibration(calibration, record_id, superseded_at_utc)
}

#' @rdname mfrm_calibration_workflow
#' @export
retire_mfrm_calibration <- function(calibration, record_id,
                                    retired_at_utc = NULL) {
  mfrmr_retire_calibration(calibration, record_id, retired_at_utc)
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
                                   adaptive_quad_points = NULL) {
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
    adaptive_quad_points = adaptive_quad_points
  )
}
