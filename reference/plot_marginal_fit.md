# Plot strict marginal-fit follow-up cells using base R

Plot strict marginal-fit follow-up cells using base R

## Usage

``` r
plot_marginal_fit(
  x,
  diagnostics = NULL,
  plot_type = c("std_residual", "prop_diff"),
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

- plot_type:

  `"std_residual"` or `"prop_diff"`.

- top_n:

  Maximum cells shown.

- facet:

  Optional facet name used to keep only matching facet-level rows. When
  `NULL`, the plot uses the mixed top-cell table returned by the strict
  marginal screen.

- main:

  Optional custom plot title.

- palette:

  Optional named color overrides. Recognized names: `positive`,
  `negative`, `flag`.

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

This helper visualizes the largest first-order strict marginal-fit cells
from `diagnose_mfrm(..., diagnostic_mode = "both")` or
`diagnostic_mode = "marginal_fit"`.

The `"std_residual"` view ranks cells by the absolute standardized
residual from posterior-integrated expected category counts. The
`"prop_diff"` view ranks the same cells by the signed
observed-minus-expected proportion gap.

Use this plot after `summary(diagnostics)` indicates strict marginal
flags. The display is exploratory: it highlights which facet/category
cells deserve follow-up, but it is not a standalone inferential test.

## Interpreting output

- Positive bars mean the observed category usage exceeded the posterior-
  expected marginal usage for that cell.

- Negative bars mean the observed usage fell below the
  posterior-expected marginal usage.

- Red bars indicate the current strict marginal warning rule was
  triggered by `|StdResidual| >= abs_z_warn`.

## Typical workflow

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    using `method = "MML"` for `RSM` / `PCM`.

2.  Run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    with `diagnostic_mode = "both"`.

3.  Use `plot_marginal_fit()` to inspect the largest strict marginal
    cells.

4.  Follow up with
    [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md)
    or substantive design review.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
[`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md),
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
p <- plot_marginal_fit(diag, draw = FALSE, preset = "publication")
p$data$preset
if (interactive()) {
  plot_marginal_fit(
    diag,
    plot_type = "prop_diff",
    draw = TRUE,
    preset = "publication"
  )
}
} # }
```
