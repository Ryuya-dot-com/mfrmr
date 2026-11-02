# Build a bias-interaction plot-data bundle (FACETS Table 13: ranked bias list)

Bundles the **ranked flagged-cells** view of a bias-interaction run for
downstream printing and plotting. The three sibling reports in this
family are intentionally distinct:

- `bias_interaction_report()` (this one) = FACETS Table 13: a ranked
  list of interaction cells with `t`, `bias size`, and screening tail
  area – use when reviewing which `(facet_a, facet_b)` cells deserve
  follow-up.

- [`bias_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_iteration_report.md)
  = iteration history / convergence trace for the bias recalibration
  (FACETS Table 9 territory) – use when diagnosing whether the bias run
  itself stabilised.

- [`bias_pairwise_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_pairwise_report.md)
  = pairwise contrast table for a target facet (FACETS Table 14
  territory) – use when comparing levels within a facet while
  controlling for the other.

## Usage

``` r
bias_interaction_report(
  x,
  diagnostics = NULL,
  facet_a = NULL,
  facet_b = NULL,
  interaction_facets = NULL,
  max_abs = 10,
  omit_extreme = TRUE,
  max_iter = 4,
  tol = 0.001,
  top_n = 50,
  abs_t_warn = 2,
  abs_bias_warn = 0.5,
  p_max = 0.05,
  sort_by = c("abs_t", "abs_bias", "prob")
)
```

## Arguments

- x:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  (used when `x` is fit).

- facet_a:

  First facet name (required when `x` is fit and `interaction_facets` is
  not supplied).

- facet_b:

  Second facet name (required when `x` is fit and `interaction_facets`
  is not supplied).

- interaction_facets:

  Character vector of two or more facets.

- max_abs:

  Bound for absolute bias size when estimating from fit.

- omit_extreme:

  Omit extreme-only elements when estimating from fit.

- max_iter:

  Iteration cap for bias estimation when `x` is fit.

- tol:

  Convergence tolerance for bias estimation when `x` is fit.

- top_n:

  Maximum number of ranked rows to keep.

- abs_t_warn:

  Warning cutoff for absolute t statistics.

- abs_bias_warn:

  Warning cutoff for absolute bias size.

- p_max:

  Warning cutoff for p-values.

- sort_by:

  Ranking key: `"abs_t"`, `"abs_bias"`, or `"prob"`.

## Value

A named list with bias-interaction plotting/report components. Class:
`mfrm_bias_interaction`.

## Details

Preferred bundle API for interaction-bias diagnostics. The function can:

- use a precomputed bias object from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md),
  or

- estimate internally from `mfrm_fit` + facet specification.

Save the complete result with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html);
`plot(out, type = "scatter")` and `type = "ranked"` reuse its flags and
thresholds. Rebuild the report from the saved bias estimates to change
screening rules; conflicting plotting-time thresholds are rejected. Both
views support
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md),
including conditional bounds requested with `show_ci = TRUE`. Heatmaps,
histograms and facet profiles use base graphics or custom
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
graphics. Export the bundle's data frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).

## Interpreting output

Focus on ranked rows where multiple screening criteria converge:

- large absolute t statistic

- large absolute bias size

- small screening tail area

The bundle is optimized for downstream
[`summary()`](https://rdrr.io/r/base/summary.html) and [plot(x, type =
"bias")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)
views.

## Typical workflow

1.  Run
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
    (or provide `mfrm_fit` here).

2.  Build `bias_interaction_report(...)`.

3.  Review `summary(out)` and visualize with [plot(x, type =
    "bias")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md).

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_fixed_reports.md),
[plot(x, type =
"bias")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("bias_interaction_report", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_bias.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "bias-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
out <- bias_interaction_report(bias, top_n = 10)
summary(out)
p_bi <- plot(out, draw = FALSE)
p_bi$data$plot
} # }
```
