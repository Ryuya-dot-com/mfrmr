# Estimate bias across multiple facet pairs

Estimate bias across multiple facet pairs

## Usage

``` r
estimate_all_bias(
  fit,
  diagnostics = NULL,
  pairs = NULL,
  include_person = FALSE,
  drop_empty = TRUE,
  keep_errors = TRUE,
  max_abs = 10,
  omit_extreme = TRUE,
  max_iter = 4,
  tol = 0.001
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When `NULL`, diagnostics are computed with `residual_pca = "none"`.

- pairs:

  Optional list of facet specifications. Each element should be a
  character vector of length 2 or more, for example
  `list(c("Rater", "Criterion"), c("Task", "Criterion"))`. When `NULL`,
  all 2-way combinations of modeled facets are used.

- include_person:

  If `TRUE` and `pairs = NULL`, include `"Person"` in the automatically
  generated pair set.

- drop_empty:

  If `TRUE`, omit empty bias tables from `by_pair` while still recording
  them in the summary table.

- keep_errors:

  If `TRUE`, retain per-pair error rows in the returned `errors` table
  instead of failing the whole batch.

- max_abs:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- omit_extreme:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- max_iter:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- tol:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

## Value

A named list with class `mfrm_bias_collection`.

## Details

This function orchestrates repeated calls to
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
across multiple facet pairs and returns a consolidated bundle.

**Bias/interaction** in MFRM refers to a systematic departure from the
additive model for a specific combination of facet elements (e.g., a
particular rater is unexpectedly harsh on a particular criterion). See
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
for the mathematical formulation.

When `pairs = NULL`, the function builds all 2-way combinations of
modelled facets automatically. For a model with facets Rater, Criterion,
and Task, this yields Rater\\\times\\Criterion, Rater\\\times\\Task, and
Criterion\\\times\\Task.

The `summary` table aggregates results across pairs:

- `Rows`: number of interaction cells estimated

- `Significant`: count of cells with \\\|t\| \ge 2\\

- `MeanAbsBias`: average absolute bias magnitude (logits)

Per-pair failures (e.g., insufficient data for a sparse pair) are
captured in `errors` rather than stopping the entire batch.

## Output

The returned object is a bundle-like list with class
`mfrm_bias_collection` and components such as:

- `summary`: one row per requested interaction

- `by_pair`: named list of successful
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  outputs

- `errors`: per-pair error log

- `settings`: resolved execution settings

- `primary`: first successful bias bundle, useful for downstream helpers

## Typical workflow

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and diagnose with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
    For `RSM` / `PCM` reporting runs, prefer `method = "MML"` plus
    `diagnostic_mode = "both"` in the diagnostics call.

2.  Run `estimate_all_bias()` to compute app-style multi-pair
    interactions.

3.  Pass the resulting `by_pair` list into
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    or
    [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md).

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 7, maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
bias_all <- estimate_all_bias(fit, diagnostics = diag)
bias_all$summary[, c("Interaction", "Rows", "Significant")]
} # }
```
