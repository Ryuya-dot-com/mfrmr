# Plot parameter-recovery simulation results

Plot parameter-recovery simulation results

## Usage

``` r
# S3 method for class 'mfrm_recovery_simulation'
plot(
  x,
  y = NULL,
  type = c("summary", "coverage", "errors", "scatter", "replications"),
  metric = c("rmse", "bias", "mae", "correlation", "coverage", "mcse_bias", "mcse_rmse",
    "raw_rmse", "raw_bias", "mean_se", "se_available"),
  parameter_type = NULL,
  facet = NULL,
  comparison = c("aligned", "unaligned"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md).

- y:

  Reserved for S3 generic compatibility.

- type:

  Plot route: `"summary"` draws a metric from `x$recovery_summary`,
  `"coverage"` draws 95% coverage by parameter group, `"errors"` draws
  row-level recovery-error distributions, `"scatter"` draws truth
  against estimated values, and `"replications"` summarizes run status.

- metric:

  Summary metric used when `type = "summary"`. Supported values are
  `"rmse"`, `"bias"`, `"mae"`, `"correlation"`, `"coverage"`,
  `"mcse_bias"`, `"mcse_rmse"`, `"raw_rmse"`, `"raw_bias"`, `"mean_se"`,
  and `"se_available"`.

- parameter_type:

  Optional parameter type filter, such as `"person"`, `"facet"`,
  `"step"`, `"slope"`, or `"population"`.

- facet:

  Optional facet filter.

- comparison:

  Error/estimate scale for row-level routes. `"aligned"` uses
  `EstimateAligned` / `ErrorAligned`; `"unaligned"` uses `Estimate` /
  `ErrorRaw` on the same comparison scale.

- draw:

  If `TRUE`, draw with base graphics. If `FALSE`, return an
  `mfrm_plot_data` object with reusable plot tables and metadata.

- ...:

  Reserved for future extensions.

## Value

An `mfrm_plot_data` object. When `draw = TRUE`, the object is returned
invisibly after drawing.

## Details

These plots are intended as simulation-review graphics. They do not
replace the row-level `x$recovery` table or the ADEMP metadata; they
make the main recovery estimands easier to inspect during
model-development and design checks. Coverage is displayed only for
parameter groups with available standard errors.

## See also

[`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md),
[`summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
if (FALSE) { # \dontrun{
rec <- evaluate_mfrm_recovery(
  n_person = 12,
  n_rater = 2,
  n_criterion = 2,
  reps = 1,
  maxit = 30,
  seed = 123
)
plot(rec, type = "summary", metric = "rmse", draw = FALSE)
} # }
```
