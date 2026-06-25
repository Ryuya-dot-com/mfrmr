# Fit new data anchored to a baseline calibration

Re-estimates a fitted many-facet model on new data while holding
selected facet parameters fixed at the values from a previous (baseline)
calibration. This is the standard workflow for placing new data onto an
existing scale, linking test forms, or carrying a baseline calibration
across administration windows. For bounded `GPCM`, treat this as direct
exploratory anchor/drift support rather than as the package's formal
linking-synthesis route.

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

  An `mfrm_fit` object from a previous calibration.

- person:

  Character column name for person/examinee.

- facets:

  Character vector of facet column names.

- score:

  Character column name for the rating score.

- anchor_facets:

  Character vector of facets to anchor (default: all non-Person facets).

- include_person:

  If `TRUE`, also anchor person estimates.

- weight:

  Optional character column name for observation weights.

- model:

  Scale model override; defaults to baseline model.

- method:

  Estimation method override; defaults to baseline method.

- anchor_policy:

  How to handle anchor issues: `"warn"`, `"error"`, `"silent"`.

- ...:

  Ignored.

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

4.  Computes element-level differences (new estimate minus baseline
    estimate) for every common element.

The `model` and `method` arguments default to the baseline fit's
settings so the calibration framework remains consistent. Elements
present in the anchor table but absent from the new data are handled
according to `anchor_policy`: `"warn"` (default) emits a message,
`"error"` stops execution, and `"silent"` ignores silently.

The returned `drift` table is best interpreted as an anchored
consistency check. When a facet is fixed through `anchor_facets`, those
anchored levels are constrained in the new run, so their reported
differences are not an independent drift analysis. For genuine
cross-wave drift monitoring, fit the waves separately and use
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
on the resulting fits.

Element-level differences are calculated for every element that appears
in both the baseline and the new calibration: \$\$\Delta_e =
\hat{\delta}\_{e,\text{new}} - \hat{\delta}\_{e,\text{base}}\$\$ An
element is **flagged** when \\\|\Delta_e\| \> 0.5\\ logits or
\\\|\Delta_e / SE\_{\Delta_e}\| \> 2.0\\, where \\SE\_{\Delta_e} =
\sqrt{SE\_{\mathrm{base}}^2 + SE\_{\mathrm{new}}^2}\\.

## Which function should I use?

- Use `anchor_to_baseline()` when you have one new dataset and want to
  place it directly on a baseline scale.

- Use
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  when you already have multiple fitted waves and want to compare their
  stability.

- Use
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  when you need cumulative offsets across an ordered series of waves.

## Interpreting output

- `$drift`: one row per common element with columns `Facet`, `Level`,
  `Baseline`, `New`, `Drift`, `SE_Baseline`, `SE_New`, `SE_Diff`,
  `Drift_SE_Ratio`, and `Flag`. Read this as an anchored consistency
  table. Small absolute differences indicate that the anchored re-fit
  stayed close to the baseline scale. Flagged rows warrant review, but
  they are not a substitute for a separate drift study on unanchored
  common elements.

- `$fit`: the full anchored `mfrm_fit` object, usable with
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
  [`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md),
  etc.

- `$diagnostics`: pre-computed diagnostics for the anchored calibration.

- `$baseline_anchors`: the anchor table fed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  useful for reviewing which elements were constrained.

## Typical workflow

1.  Fit the baseline model: `fit1 <- fit_mfrm(...)`.

2.  Collect new data (e.g., a later administration).

3.  Call `res <- anchor_to_baseline(new_data, fit1, ...)`.

4.  Inspect `summary(res)` to confirm the anchored run remains close to
    the baseline scale.

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
if (FALSE) { # \dontrun{
d1 <- load_mfrmr_data("study1")
keep1 <- unique(d1$Person)[1:15]
d1 <- d1[d1$Person %in% keep1, , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
d2 <- load_mfrmr_data("study2")
keep2 <- unique(d2$Person)[1:15]
d2 <- d2[d2$Person %in% keep2, , drop = FALSE]
res <- anchor_to_baseline(d2, fit1, "Person",
                          c("Rater", "Criterion"), "Score",
                          anchor_facets = "Criterion")
summary(res)
head(res$drift[, c("Facet", "Level", "Drift", "Flag")])
res$baseline_anchors[1:3, ]
} # }
```
