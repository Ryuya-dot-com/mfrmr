# Create and use a portable fixed calibration

These functions implement a strict lifecycle for a saved, versioned
calibration. `extract_mfrm_calibration()` creates a draft from an
eligible `RSM` or `PCM` MML fit under the fixed standard-normal scoring
basis. `validate_mfrm_calibration()` and `freeze_mfrm_calibration()` are
separate, fail-closed transitions. Only a frozen artifact can be passed
to `score_mfrm_calibration()`.

## Usage

``` r
extract_mfrm_calibration(
  fit,
  calibration_id = NULL,
  source_fit_id = NULL,
  created_at_utc = NULL,
  scoring_quad_points = 31L,
  quadrature_review = NULL
)

review_mfrm_calibration(calibration)

validate_mfrm_calibration(calibration, validated_at_utc = NULL)

freeze_mfrm_calibration(calibration, frozen_at_utc = NULL)

supersede_mfrm_calibration(calibration, record_id, superseded_at_utc = NULL)

retire_mfrm_calibration(calibration, record_id, retired_at_utc = NULL)

save_mfrm_calibration(calibration, file, overwrite = FALSE)

load_mfrm_calibration(file)

score_mfrm_calibration(
  calibration,
  new_data,
  person = NULL,
  facets = NULL,
  score = NULL,
  weight = NULL,
  interval_level = 0.95,
  missing_response = "error",
  event_id = NULL,
  adaptive_quad_points = NULL
)
```

## Arguments

- fit:

  An eligible `mfrm_fit` produced by
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- calibration_id:

  Optional nonempty calibration identifier.

- source_fit_id:

  Optional nonempty source-fit identifier.

- created_at_utc:

  Optional RFC3339 UTC timestamp. Omit it to use the current time.

- scoring_quad_points:

  Integer quadrature order of at least 2 used for later artifact
  scoring. It is independent of the fit-time quadrature and defaults
  to 31. The fixed or adaptive integration mode is inherited from the
  source fit and stored in the artifact's scoring algorithm identity.
  With adaptive scoring, stored nodes and weights define the base
  Hermite rule; their person-specific locations are recomputed for each
  new batch.

- quadrature_review:

  An `mfrm_quadrature_sensitivity` from
  [`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
  for the same data and model. `fit` must be the exact highest-grid fit
  stored in this object. The package checks this procedural evidence but
  leaves acceptable numerical movement to the user.

- calibration:

  An `mfrm_calibration` object.

- validated_at_utc, frozen_at_utc:

  Optional RFC3339 UTC timestamps for reproducible lifecycle records.
  Omit them to use the current time.

- record_id:

  A nonempty identifier for a terminal superseded or retired record. It
  must differ from the frozen parent identifier.

- superseded_at_utc, retired_at_utc:

  Optional RFC3339 UTC timestamps.

- file:

  A path ending in `.rds`.

- overwrite:

  Whether an existing persistence target may be replaced.

- new_data:

  A data frame of response rows for new Persons.

- person, score, weight, event_id:

  Optional input-column names. Stored source-column names are used when
  applicable. `event_id` distinguishes otherwise duplicate response
  events.

- facets:

  Optional named character vector mapping stored facet names to input
  columns.

- interval_level:

  Central posterior interval level, strictly between 0 and 1.

- missing_response:

  Either `"error"` or `"omit"`.

- adaptive_quad_points:

  Optional vector of at least two distinct integer orders \>= 3, for
  example `c(31, 61)`, used only by `score_mfrm_calibration()`. Adds an
  unrounded `quadrature_review` comparing stored-grid results with
  mode/curvature-adapted integration for each Person. Inspect both
  fixed/adaptive differences and changes between adaptive orders. The
  artifact, reported scores/intervals and readiness are unchanged;
  adaptive results are diagnostics conditional on the same point
  calibration. Only Persons with scored responses have numerical review
  rows. `Status = "computed"` means the calculation finished, not that
  accuracy is certified; an unavailable row retains the reason in
  `Detail`.

## Value

`extract_mfrm_calibration()`, `validate_mfrm_calibration()`,
`freeze_mfrm_calibration()`, `supersede_mfrm_calibration()`,
`retire_mfrm_calibration()`, and `load_mfrm_calibration()` return an
`mfrm_calibration`. `review_mfrm_calibration()` returns a data frame of
structured refusals, with zero rows for an acceptable object.
`save_mfrm_calibration()` invisibly returns the normalized path.
`score_mfrm_calibration()` returns an `mfrm_calibration_score`
containing estimates plus row and Person dispositions and scoring
identities. When requested and scored rows exist, `quadrature_review`
contains the fixed/adaptive comparison;
[`summary()`](https://rdrr.io/r/base/summary.html) preserves it and adds
a compact `quadrature_overview`.

## Details

The portable 0.2.4 workflow supports one observed score scale, one
latent dimension, known non-Person facet levels, and stored two-way
facet interactions. Estimated-population or latent-regression MML, JML,
and `GPCM` remain available only through their fitted-object routes; see
[`mfrm_calibration_capabilities()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_capabilities.md).

Before extraction, run
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
on user-selected grids and inspect its continuous differences. Pass the
exact highest-grid fit in that object together with `quadrature_review`.
The retained fits must use their recorded grid sizes and the same data,
score map and fitting settings, including anchors and integration mode,
and must all have converged. This procedural requirement does not
declare the fit numerically stable: the package does not choose the
application-specific tolerance or decide whether more grids are needed.
Archive the review separately when it is part of the audit trail,
because response-linked fits are deliberately not embedded in the
portable artifact.

Posterior EAP estimates, posterior standard deviations, and intervals
are conditional on the frozen point calibration and its recorded fixed
standard-normal prior. They do not include calibration-parameter
uncertainty. Loading validates structure and semantic consistency, but
does not authenticate an artifact from an untrusted source. New v2
scoring algorithms invert the continuous posterior CDF for equal-tail
intervals. EAP and SD retain the stored quadrature rule. Saved v1
artifacts preserve their discrete grid interval endpoints and carry a
note that the continuous posterior mass can differ from the requested
interval level.

## See also

[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md),
[mfrm_calibration_score_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_score_methods.md)
for concise review and visualization of returned score batches.
