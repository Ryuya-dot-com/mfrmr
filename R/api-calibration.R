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
      "one observed score scale, one latent dimension, and known facet levels",
      "one observed score scale, one latent dimension, and known facet levels",
      "population coding and conditional parameters are not stored in the artifact",
      "relative-slope ownership is not stored in the artifact",
      "source JML Person coordinates are excluded from the artifact",
      "both relative-slope ownership and a portable JML scoring-prior contract are absent"
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
#' Posterior EAP estimates, posterior standard deviations, and intervals are
#' conditional on the frozen point calibration and its recorded fixed
#' standard-normal prior. They do not include calibration-parameter
#' uncertainty. Loading validates structure and semantic consistency, but does
#' not authenticate an artifact from an untrusted source.
#'
#' @param fit An eligible `mfrm_fit` produced by [fit_mfrm()].
#' @param calibration_id Optional nonempty calibration identifier.
#' @param source_fit_id Optional nonempty source-fit identifier.
#' @param created_at_utc Optional RFC3339 UTC timestamp. Omit it to use the
#'   current time.
#' @param scoring_quad_points Integer quadrature order of at least 2 used for
#'   later artifact scoring. It is independent of the fit-time quadrature and
#'   defaults to 31.
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
#'
#' @return `extract_mfrm_calibration()`, `validate_mfrm_calibration()`,
#'   `freeze_mfrm_calibration()`, `supersede_mfrm_calibration()`,
#'   `retire_mfrm_calibration()`, and `load_mfrm_calibration()` return an
#'   `mfrm_calibration`. `review_mfrm_calibration()` returns a data frame of
#'   structured refusals, with zero rows for an acceptable object.
#'   `save_mfrm_calibration()` invisibly returns the normalized path.
#'   `score_mfrm_calibration()` returns an `mfrm_calibration_score` containing
#'   estimates plus row and Person dispositions and scoring identities.
#'
#' @name mfrm_calibration_workflow
NULL

#' @rdname mfrm_calibration_workflow
#' @export
extract_mfrm_calibration <- function(fit, calibration_id = NULL,
                                     source_fit_id = NULL,
                                     created_at_utc = NULL,
                                     scoring_quad_points = 31L) {
  tryCatch(
    mfrmr_extract_calibration_draft(
      fit = fit,
      calibration_id = calibration_id,
      source_fit_id = source_fit_id,
      created_at_utc = created_at_utc,
      scoring_quad_points = scoring_quad_points
    ),
    mfrm_calibration_error = mfrmr_public_calibration_extraction_error
  )
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
                                   event_id = NULL) {
  mfrmr_score_calibration(
    calibration = calibration,
    new_data = new_data,
    person = person,
    facets = facets,
    score = score,
    weight = weight,
    interval_level = interval_level,
    missing_response = missing_response,
    event_id = event_id
  )
}
