# Build a facet statistics report (preferred alias)

Build a facet statistics report (preferred alias)

## Usage

``` r
facet_statistics_report(
  fit,
  diagnostics = NULL,
  metrics = c("Estimate", "Infit", "Outfit", "SE"),
  ruler_width = 41,
  distribution_basis = c("both", "sample", "population"),
  se_mode = c("both", "model", "fit_adjusted")
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  for the same `fit`. Mismatched or outdated diagnostics are rejected.
  Recompute diagnostics after refitting; the model itself does not need
  to be fitted again.

- metrics:

  Numeric columns in `diagnostics$measures` to summarize.

- ruler_width:

  Width of the fixed-width ruler used for `M/S/Q/X` marks.

- distribution_basis:

  Which distribution basis to keep in the appended precision summary:
  `"both"` (default), `"sample"`, or `"population"`.

- se_mode:

  Which standard-error mode to keep in the appended precision summary:
  `"both"` (default), `"model"`, or `"fit_adjusted"`.

## Value

A named list with facet-statistics components. Class:
`mfrm_facet_statistics`.

## Details

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_facet_statistics` (`type = "means"`, `"sds"`, `"ranges"`).

## Interpreting output

- facet-level means/SD/ranges of selected metrics (`Estimate`, fit
  indices, `SE`).

- fixed-width ruler rows (`M/S/Q/X`) for compact profile scanning.

## Typical workflow

1.  Run `facet_statistics_report(fit)`.

2.  Inspect summary/ranges for anomalous facets.

3.  Cross-check flagged facets with fit and chi-square diagnostics. The
    returned bundle now includes:

- `precision_summary`: facet precision/separation indices by
  `DistributionBasis` and `SEMode`

- `variability_tests`: fixed/random variability tests by facet

- `se_modes`: compact list of available SE modes by facet

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/summary.mfrm_fit.md),
[plot(x, type =
"facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_reports_and_tables.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("facet_statistics_report", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
out <- facet_statistics_report(fit)
summary(out)
p_fs <- plot(out, draw = FALSE)
p_fs$data$plot
} # }
```
