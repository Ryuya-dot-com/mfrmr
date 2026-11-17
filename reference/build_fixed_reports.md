# Build legacy-compatible fixed-width text reports

Build legacy-compatible fixed-width text reports

## Usage

``` r
build_fixed_reports(
  bias_results,
  target_facet = NULL,
  branch = c("facets", "original"),
  df_method = c("facets", "classical")
)
```

## Arguments

- bias_results:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- target_facet:

  Optional target facet for pairwise contrast table.

- branch:

  Output branch: `"facets"` keeps the legacy-compatible fixed-width
  layout; `"original"` returns compact sectioned fixed-width text for
  report drafts.

- df_method:

  Pairwise df convention: `"facets"` (modified Rasch-Welch, integer
  part, matching FACETS 4.5.0) or `"classical"` (former continuous df).

## Value

A named list with class `mfrm_fixed_reports` (and a branch-specific
subclass `mfrm_fixed_reports_<branch>`):

- `bias_fixed`: fixed-width interaction table text

- `pairwise_fixed`: fixed-width pairwise contrast text

- `pairwise_table`: underlying pairwise data.frame

- `branch`: character scalar `"original"` or `"facets"` echoing which
  fixed-width style was rendered

- `style`: character scalar carrying the resolved style preset used when
  building the text artifact

- `interaction_label`: human-readable label for the interaction that
  drove the bias run (`"Rater x Criterion"`-style); `NA` when no bias
  rows are available

- `target_facet`: character scalar identifying which facet was used as
  the target facet for pairwise contrasts; `NA` when no pairwise
  contrasts were requested or available

## Details

This function generates plain-text, fixed-width output intended to be
read in console/log environments or exported into text reports.

The pairwise section (Table 14 style) is only generated for 2-way bias
runs. For higher-order interactions (`interaction_facets` length \>= 3),
the function returns the bias table text and a note explaining why
pairwise contrasts were skipped.

## Pairwise calculation

Local contrasts are Context1 minus Context2 using the saved target-facet
orientation. Their SEs condition on baseline calibration and omit
calibration uncertainty and cross-cell covariance; these remain
screening statistics. Unavailable orientation or precision leaves
comparisons unavailable. See "Pairwise calculation" in
[mfrm_report_bias_pairwise](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
for the local-measure and SE formulas, weighted-count df conventions,
availability conditions and the scope of the FACETS comparison.

## Saved pairwise results

Current tables use `CalculationVersion = 3`. Older tables must be
rebuilt, not relabelled. See "Saved pairwise results" in
[mfrm_report_bias_pairwise](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
for when the underlying bias result also needs regeneration; no main
calibration refit is required.

## Interpreting output

- `bias_fixed`: fixed-width table of interaction effects.

- `pairwise_fixed`: pairwise contrast text (2-way only).

- `pairwise_table`: structured contrast table.

- `interaction_label`: facets used for the bias run.

## Typical workflow

1.  Run
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

2.  Build text bundle with `build_fixed_reports(...)`.

3.  Use
    [`summary()`](https://rdrr.io/r/base/summary.html)/[`plot()`](https://rdrr.io/r/graphics/plot.default.html)
    for quick checks, then export text blocks.

## Preferred route for new analyses

For new reporting workflows, prefer
[mfrm_report_bias_interaction](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).
Use `build_fixed_reports()` when a fixed-width text artifact is
specifically required for a compatibility handoff.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[mfrm_report_bias_interaction](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("build_fixed_reports", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_bias.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "bias-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
fixed <- build_fixed_reports(bias)
fixed_original <- build_fixed_reports(bias, branch = "original")
summary(fixed)
p <- plot(fixed, draw = FALSE)
p2 <- plot(fixed, type = "pvalue", draw = FALSE)
if (interactive()) {
  plot(
    fixed,
    type = "contrast",
    draw = TRUE,
    main = "Pairwise Contrasts (Customized)",
    palette = c(pos = "#1b9e77", neg = "#d95f02"),
    label_angle = 45
  )
}
} # }
```
