# Fit new data anchored to a baseline calibration

Re-estimates a fitted many-facet model on new data while holding
selected facet parameters fixed at the values from a previous (baseline)
calibration. This transfers baseline coordinates into a new fit through
direct equality constraints. Common-scale interpretation is conditional
on a defensible baseline and invariant cross-run element identity. For
`GPCM`, treat this as direct exploratory anchor/drift support rather
than as the package's formal linking-synthesis route.

## Usage

``` r
anchor_to_baseline(
  new_data,
  baseline_fit,
  person,
  facets,
  score,
  anchor_facets = NULL,
  include_person = FALSE,
  weight = NULL,
  model = NULL,
  method = NULL,
  anchor_policy = "warn",
  mml_integration = NULL,
  centering_scope = NULL,
  ...
)

# S3 method for class 'mfrm_anchored_fit'
print(x, ...)

# S3 method for class 'mfrm_anchored_fit'
summary(object, ...)

# S3 method for class 'summary.mfrm_anchored_fit'
print(x, ...)
```

## Arguments

- new_data:

  Data frame in long format (one row per rating).

- baseline_fit:

  An inference-ready `mfrm_fit` object from a previous calibration under
  the current readiness contract.

- person:

  Character column name for person/examinee.

- facets:

  Character vector of facet column names.

- score:

  Character column name for the rating score.

- anchor_facets:

  Character vector of facets to anchor (default: all non-Person facets).

- include_person:

  If `TRUE`, also export Person values for a receiving JML fit. MML
  rejects Person anchors. Use only when constant ability for the same
  Persons is substantively intended; shared Persons need not be fixed.

- weight:

  Optional character column name for observation weights.

- model:

  Scale model override; defaults to baseline model.

- method:

  Estimation method override; defaults to baseline method.

- anchor_policy:

  How to handle anchor issues: `"warn"`, `"error"`, `"silent"`.

- mml_integration:

  MML integration mode passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  `NULL` inherits the baseline fit's mode for MML; JML uses `"fixed"`.

- centering_scope:

  `NULL` inherits the baseline's convention. Older fits without this
  setting retain `"remainder"`. Supply `"facet"` or `"remainder"`
  explicitly only when that constraint system is intended; see
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- ...:

  For `anchor_to_baseline()`, additional arguments passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Ignored by the S3 print and summary methods on this page.

- x:

  An `mfrm_anchored_fit` object.

- object:

  An `mfrm_anchored_fit` object (for `summary`).

## Value

Object of class `mfrm_anchored_fit` with components:

- fit:

  The anchored `mfrm_fit` object.

- diagnostics:

  Output of
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  on the anchored fit.

- baseline_anchors:

  Anchor table extracted from the baseline.

- drift:

  Tibble of element-level drift statistics.

## Details

This function automates the baseline-anchored calibration workflow:

1.  Extracts anchor values from the baseline fit using
    [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md).

2.  Re-estimates the model on `new_data` with those anchors fixed via
    `fit_mfrm(..., anchors = anchor_table)`.

3.  Runs
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    on the anchored fit.

4.  Compares the fixed non-Person anchor values in the new fit with
    their supplied values. This checks constraint consistency, not
    invariance.

The helper refuses a baseline unless its current readiness record has
`InferenceReady = TRUE`. Also confirm compatible model, score coding,
orientation, and population conventions, and document that anchor labels
denote the same elements with invariant meaning. The function checks
object shape and receiving-data anchor compatibility, but does not
establish those substantive conditions. Fixing parameters can identify
coordinates; it does not create observed common-rating links.

Only `model`, `method`, the centering convention and MML integration
mode inherit baseline settings automatically. Supply other settings
explicitly through `...`, including rubric bounds, category policy,
facet orientation, PCM/GPCM facet roles and any population model.
RSM/PCM MML without a population model uses a fixed standard-normal
ability distribution; anchors do not automatically estimate a new
cohort's mean or variance.

The table fixes locations only: thresholds and GPCM slopes are
re-estimated. Use
[`extract_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
and
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
when the question is scoring against a complete fixed calibration.
Partial anchors retain the centering restrictions described in
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md);
this is not an unrestricted fixed-common-parameter linking
implementation for arbitrary new levels. Elements present in the anchor
table but absent from the new data are handled according to
`anchor_policy`: `"warn"` (default) emits a message, `"error"` stops
execution, and `"silent"` ignores silently.

The returned `drift` table contains only non-Person anchor rows that
match the new data. Unanchored common levels and Person levels are
absent. The compared values are fixed by construction, so zero
differences do not show that raters or tasks remained stable. For
separate cross-wave screening, fit the waves independently and use
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
retaining its offset and uncertainty limitations.

Differences compare each retained fixed value to the supplied anchor:
\$\$\Delta_e = \hat{\delta}\_{e,\text{new}} -
\hat{\delta}\_{e,\text{base}}\$\$ An element is **flagged** when
\\\|\Delta_e\| \> 0.5\\ logits or \\\|\Delta_e / SE\_{\Delta_e}\| \>
2.0\\, where \\SE\_{\Delta_e} = \sqrt{SE\_{\mathrm{base}}^2 +
SE\_{\mathrm{new}}^2}\\. `SE_Diff` is a plug-in independence
calculation. It does not propagate baseline-anchor uncertainty or
cross-fit covariance, and anchored estimates in the new fit are
constrained rather than independently re-estimated. Consequently,
`Drift_SE_Ratio` and `Flag` are descriptive consistency screens, not
formal z tests or calibrated error-rate decisions.

## Which function should I use?

- Use `anchor_to_baseline()` when you have one new dataset and want to
  place it on baseline coordinates within the documented constraint
  system.

- Use
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  when you already have multiple fitted waves and want to compare their
  stability.

- Use
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  when you need cumulative offsets across an ordered series of waves.

## Interpreting output

- `$drift`: one row per retained non-Person anchor with columns `Facet`,
  `Level`, `Baseline`, `New`, `Drift`, `SE_Baseline`, `SE_New`,
  `SE_Diff`, `Drift_SE_Ratio`, and `Flag`. Read this as a
  constraint-consistency table. Zero differences are expected by
  construction and provide no independent evidence of stability.

- `$fit`: the full anchored `mfrm_fit` object, usable with
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
  [`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md),
  etc.

- `$diagnostics`: pre-computed diagnostics for the anchored calibration.

- `$baseline_anchors`: the candidate table fed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Some rows may be excluded when `anchor_policy` permits unmatched IDs.
  Inspect `$fit$config$anchor_review$anchors` for the retained direct
  constraints.

## Typical workflow

1.  Fit the baseline model: `fit1 <- fit_mfrm(...)`.

2.  Collect new data (e.g., a later administration).

3.  Call `res <- anchor_to_baseline(new_data, fit1, ...)`.

4.  Inspect `summary(res)` for numerical readiness and fixed-value
    consistency; neither establishes anchor invariance or a successful
    substantive link.

5.  For multi-wave drift monitoring, fit waves separately and pass the
    fits to
    [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
    or
    [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md).

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md),
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("anchor_to_baseline", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Packaged synthetic teaching data; no data-generation code is needed.
ratings <- load_mfrmr_data("example_core")
people <- unique(ratings$Person)
# Two balanced 24-Person waves retain every Rater and Criterion.
d1 <- ratings[ratings$Person %in% people[1:24], , drop = FALSE]
d2 <- ratings[ratings$Person %in% people[25:48], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", rating_min = 1, rating_max = 4,
                 category_policy = "preserve")
res <- anchor_to_baseline(d2, fit1, "Person",
                          c("Rater", "Criterion"), "Score",
                          anchor_facets = "Criterion", anchor_policy = "error",
                          rating_min = 1, rating_max = 4,
                          category_policy = "preserve")
summary(res)
# These fixed-value differences are not a test of Criterion stability.
head(res$drift[, c("Facet", "Level", "Drift", "Flag")])
res$baseline_anchors[1:3, ]
} # }
```
