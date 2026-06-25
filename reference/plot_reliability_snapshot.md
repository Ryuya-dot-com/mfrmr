# Facet reliability and separation snapshot bar plot

Compact facet-level visual of the Wright & Masters (1982) separation,
strata, and reliability indices that
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
computes. Helpful as a single small figure for "are persons / raters /
criteria distinguishable?" review. These are Rasch/FACETS-style
separation indices on the fitted logit scale, not ICCs; use
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
for the complementary observed-score variance-share view.

## Usage

``` r
plot_reliability_snapshot(
  fit,
  diagnostics = NULL,
  metric = c("reliability", "separation", "strata"),
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output. Computed on demand when omitted.

- metric:

  `"reliability"` (default), `"separation"`, or `"strata"`.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` whose `data` slot bundles a tidy `Facet`, `Metric`,
`Value` data frame.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
p <- plot_reliability_snapshot(fit, draw = FALSE)
p$data$table
# Look for (default `metric = "reliability"`):
# - >= 0.9 strong, 0.7-0.9 adequate, < 0.7 weak (Wright & Masters 1982).
# - The Person row is the operative reliability for ability scores.
# - Non-Person rows (Rater / Criterion) report the same index but
#   should be read as "are facet elements distinguishable?"; values
#   close to 1 mean facet means differ reliably from each other.
}
```
