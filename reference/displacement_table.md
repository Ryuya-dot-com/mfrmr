# Compute displacement diagnostics for facet levels

Compute displacement diagnostics for facet levels

## Usage

``` r
displacement_table(
  fit,
  diagnostics = NULL,
  facets = NULL,
  anchored_only = FALSE,
  abs_displacement_warn = 0.5,
  abs_t_warn = 2,
  top_n = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
  for migration of saved diagnostics.

- facets:

  Optional subset of facets.

- anchored_only:

  If `TRUE`, keep only directly/group anchored levels.

- abs_displacement_warn:

  Absolute displacement warning threshold.

- abs_t_warn:

  Absolute displacement t-value warning threshold.

- top_n:

  Optional maximum number of rows to keep after sorting.

## Value

A named list with:

- `table`: displacement diagnostics by level

- `summary`: one-row summary

- `thresholds`: applied thresholds

## Details

Displacement is the facet sign times the weighted sum of observation
score derivatives divided by weighted score information. For
unit-discrimination RSM/PCM these reduce to observed-minus-expected
residuals and conditional score variances. The Person sign is positive;
default severity/difficulty signs are negative. GPCM uses its
slope-aware derivatives and information. This is a conditional one-step
location adjustment with other fitted quantities held fixed, not a joint
unconstrained refit. `DisplacementSE` is inverse square-root
information; it excludes cross-parameter and source-anchor uncertainty.
Nonpositive information gives unavailable values.

## Interpreting output

`Displacement` is the proposed change in the fitted location coordinate.
For a default negatively oriented Rater facet, a positive displacement
means greater severity and lower predicted scores, holding other terms
fixed. This is the opposite score direction to positive `Bias Size` in
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
which is added directly to the score predictor.

`ReleasedEstimate = Estimate + Displacement` is only a one-step
projection; no anchor is actually released or model refitted.
`AnchorGap` subtracts the directly supplied `AnchorValue` from this
projection. A large gap suggests tension with the fitted baseline, not
proof that the anchor changed. `DisplacementT` is a conditional
screening ratio, not a calibrated test. Inspect finite
displacement/information before reading `Flag`: a missing calculation
cannot cross its cutoff and therefore need not produce a flag.

## Typical workflow

1.  Run `displacement_table(fit, anchored_only = TRUE)` for anchor
    checks.

2.  Inspect `summary(disp)` then detailed rows.

3.  Visualize with [plot(x, type =
    "displacement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md).

## Output columns

The `table` data.frame contains:

- Facet, Level:

  Facet name and element label.

- Displacement:

  One-step location change in native ability units; adjacent-logit units
  for RSM/PCM. GPCM's score effect also depends on slopes.

- DisplacementSE:

  Inverse square-root conditional information; excludes uncertainty in
  the other fitted parameters and anchor source.

- DisplacementT:

  `Displacement / DisplacementSE`.

- Estimate, SE:

  Current measure and its diagnostic uncertainty; MML Person SEs are
  posterior SDs. See
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- N, WeightedN:

  Summed response weights for this level in native diagnostics, equal to
  the row count with unit weights; not independent Persons.

- ReleasedEstimate, AnchorGap:

  One-step projected location and its difference from a directly
  supplied anchor, when available.

- AnchorValue, AnchorStatus, AnchorType:

  Anchor metadata.

- Flag:

  TRUE when either finite absolute displacement or its absolute
  screening ratio reaches the corresponding cutoff.

## Saved-result reuse

The returned `fit_identity` records the fitted analysis for reuse with
reports and exports. Recreate older results from the saved fit and
matching diagnostics using the original screening options; no model
refit is needed. See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
for migration instructions.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("displacement_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
disp <- displacement_table(fit, anchored_only = FALSE)
summary(disp)
p_disp <- plot(disp, draw = FALSE)
plot_data(p_disp, "plot")
} # }
```
