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
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
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
