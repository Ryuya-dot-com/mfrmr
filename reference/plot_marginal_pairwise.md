# Plot strict pairwise local-dependence follow-up using base R

Plot strict pairwise local-dependence follow-up using base R

## Usage

``` r
plot_marginal_pairwise(
  x,
  diagnostics = NULL,
  metric = c("exact", "adjacent"),
  top_n = 20,
  facet = NULL,
  main = NULL,
  palette = NULL,
  label_angle = 45,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- x:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  when `x` is `mfrm_fit`.

- metric:

  `"exact"` or `"adjacent"`.

- top_n:

  Maximum level pairs shown.

- facet:

  Optional facet name used to keep only matching pairwise rows.

- main:

  Optional custom plot title.

- palette:

  Optional named color overrides. Recognized names: `ok`, `flag`.

- label_angle:

  X-axis label angle.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, draw with base graphics.

## Value

A plotting-data object of class `mfrm_plot_data`.

## Details

This helper visualizes the strict pairwise local-dependence follow-up
derived from posterior-integrated expected exact and adjacent agreement.

The `"exact"` view ranks level pairs by the absolute exact-agreement
standardized residual. The `"adjacent"` view uses the adjacent-agreement
standardized residual instead. Both are exploratory corroboration
screens for strict marginal-fit flags.

## Interpreting output

- Positive bars mean the observed agreement exceeded the
  posterior-expected agreement for that level pair.

- Negative bars mean the observed agreement fell below the
  posterior-expected agreement.

- Red bars indicate the pair exceeded the current strict-warning
  threshold.

## Typical workflow

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    using `method = "MML"` for `RSM` / `PCM`.

2.  Run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    with `diagnostic_mode = "both"`.

3.  Use `plot_marginal_pairwise()` to inspect level pairs behind
    pairwise local-dependence flags.

4.  Corroborate with legacy diagnostics, design review, and substantive
    interpretation before making claims.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  toy,
  "Person",
  c("Rater", "Criterion"),
  "Score",
  method = "MML",
  quad_points = 7,
  maxit = 30
)
diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
p <- plot_marginal_pairwise(diag, draw = FALSE, preset = "publication")
p$data$preset
if (interactive()) {
  plot_marginal_pairwise(
    diag,
    metric = "adjacent",
    draw = TRUE,
    preset = "publication"
  )
}
} # }
```
