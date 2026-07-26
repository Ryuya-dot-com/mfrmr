# Build legacy-compatible fixed-width text reports

Build legacy-compatible fixed-width text reports

## Usage

``` r
build_fixed_reports(
  bias_results,
  target_facet = NULL,
  branch = c("facets", "original")
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
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
and
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).
Use `build_fixed_reports()` when a fixed-width text artifact is
specifically required for a compatibility handoff.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
fixed <- build_fixed_reports(bias)
fixed_original <- build_fixed_reports(bias, branch = "original")
summary(fixed)
#> mfrmr Fixed-Report Bundle
#> 
#> Overview
#>  Branch         Style       Interaction PairwiseRows BiasTextLines
#>  facets facets_manual Rater x Criterion           24            26
#>  PairwiseTextLines
#>                 27
#> 
#> Pairwise preview
#>  Target Target N Target Measure Target S.E. Context1 Context1 N Local Measure1
#>     R01        1         -0.867       0.152 Accuracy          1         -0.090
#>     R01        1         -0.867       0.152 Accuracy          1         -0.090
#>     R01        1         -0.867       0.152 Accuracy          1         -0.090
#>     R01        1         -0.867       0.152  Content          2         -1.144
#>     R01        1         -0.867       0.152  Content          2         -1.144
#>     R01        1         -0.867       0.152 Language          3         -1.050
#>     R02        2          0.007       0.147 Accuracy          1          0.253
#>     R02        2          0.007       0.147 Accuracy          1          0.253
#>     R02        2          0.007       0.147 Accuracy          1          0.253
#>     R02        2          0.007       0.147  Content          2         -0.023
#>    SE1 Obs-Exp Avg1 Count1 ObsN1     Context2 Context2 N Local Measure2   SE2
#>  0.344            0     24    24      Content          2         -1.144 0.337
#>  0.344            0     24    24     Language          3         -1.050 0.344
#>  0.344            0     24    24 Organization          4         -1.229 0.330
#>  0.337            0     24    24     Language          3         -1.050 0.344
#>  0.337            0     24    24 Organization          4         -1.229 0.330
#>  0.344            0     24    24 Organization          4         -1.229 0.330
#>  0.323            0     24    24      Content          2         -0.023 0.330
#>  0.323            0     24    24     Language          3         -0.202 0.328
#>  0.323            0     24    24 Organization          4         -0.016 0.327
#>  0.330            0     24    24     Language          3         -0.202 0.328
#>  Obs-Exp Avg2 Count2 ObsN2 Contrast    SE      t   d.f. Prob. InferenceTier
#>             0     24    24    1.054 0.431  2.447 45.976 0.018     screening
#>             0     24    24    0.961 0.436  2.204 46.000 0.033     screening
#>             0     24    24    1.139 0.425  2.678 45.886 0.010     screening
#>             0     24    24   -0.094 0.431 -0.217 45.976 0.829     screening
#>             0     24    24    0.085 0.420  0.202 45.966 0.841     screening
#>             0     24    24    0.178 0.425  0.419 45.886 0.677     screening
#>             0     24    24    0.276 0.413  0.670 45.969 0.506     screening
#>             0     24    24    0.455 0.411  1.106 45.981 0.274     screening
#>             0     24    24    0.269 0.410  0.656 45.990 0.515     screening
#>             0     24    24    0.179 0.417  0.429 45.998 0.670     screening
#>  SupportsFormalInference FormalInferenceEligible PrimaryReportingEligible
#>                    FALSE                   FALSE                    FALSE
#>                    FALSE                   FALSE                    FALSE
#>                    FALSE                   FALSE                    FALSE
#>                    FALSE                   FALSE                    FALSE
#>                    FALSE                   FALSE                    FALSE
#>                    FALSE                   FALSE                    FALSE
#>                    FALSE                   FALSE                    FALSE
#>                    FALSE                   FALSE                    FALSE
#>                    FALSE                   FALSE                    FALSE
#>                    FALSE                   FALSE                    FALSE
#>    ReportingUse
#>  screening_only
#>  screening_only
#>  screening_only
#>  screening_only
#>  screening_only
#>  screening_only
#>  screening_only
#>  screening_only
#>  screening_only
#>  screening_only
#>                                                                                      ContrastBasis
#>  difference between local target measures across contexts (target term cancels to a bias contrast)
#>  difference between local target measures across contexts (target term cancels to a bias contrast)
#>  difference between local target measures across contexts (target term cancels to a bias contrast)
#>  difference between local target measures across contexts (target term cancels to a bias contrast)
#>  difference between local target measures across contexts (target term cancels to a bias contrast)
#>  difference between local target measures across contexts (target term cancels to a bias contrast)
#>  difference between local target measures across contexts (target term cancels to a bias contrast)
#>  difference between local target measures across contexts (target term cancels to a bias contrast)
#>  difference between local target measures across contexts (target term cancels to a bias contrast)
#>  difference between local target measures across contexts (target term cancels to a bias contrast)
#>                                         SEBasis                  StatisticLabel
#>  combined context-specific bias standard errors Bias-contrast Welch screening t
#>  combined context-specific bias standard errors Bias-contrast Welch screening t
#>  combined context-specific bias standard errors Bias-contrast Welch screening t
#>  combined context-specific bias standard errors Bias-contrast Welch screening t
#>  combined context-specific bias standard errors Bias-contrast Welch screening t
#>  combined context-specific bias standard errors Bias-contrast Welch screening t
#>  combined context-specific bias standard errors Bias-contrast Welch screening t
#>  combined context-specific bias standard errors Bias-contrast Welch screening t
#>  combined context-specific bias standard errors Bias-contrast Welch screening t
#>  combined context-specific bias standard errors Bias-contrast Welch screening t
#>    ProbabilityMetric                           DFBasis
#>  screening tail area Welch-Satterthwaite approximation
#>  screening tail area Welch-Satterthwaite approximation
#>  screening tail area Welch-Satterthwaite approximation
#>  screening tail area Welch-Satterthwaite approximation
#>  screening tail area Welch-Satterthwaite approximation
#>  screening tail area Welch-Satterthwaite approximation
#>  screening tail area Welch-Satterthwaite approximation
#>  screening tail area Welch-Satterthwaite approximation
#>  screening tail area Welch-Satterthwaite approximation
#>  screening tail area Welch-Satterthwaite approximation
#> 
#> Notes
#>  - Legacy-compatible branch: fixed-width text follows the compatibility layout.
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
# }
```
