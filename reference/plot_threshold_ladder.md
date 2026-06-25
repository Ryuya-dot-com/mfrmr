# Plot RSM/PCM threshold ladders with disorder highlighting

Renders the Rasch-Andrich threshold structure as a vertical ladder per
step-facet level. Each tick is a `tau_k`; lines connecting adjacent
thresholds are coloured to make disordered crossings
(`tau_{k+1} < tau_k`) visually obvious. For RSM there is one ladder; for
PCM (and bounded GPCM) there is one ladder per `step_facet` level.

## Usage

``` r
plot_threshold_ladder(
  fit,
  highlight_disorder = TRUE,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- highlight_disorder:

  Logical. When `TRUE` (default), draw disordered segments with the
  preset's `fail` colour and add a subtitle counting the disordered
  groups.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` object with a `data` slot containing columns
`Group`, `Step`, `Threshold`, `Disordered` for each ladder row.

## Interpreting output

Within each ladder, thresholds should ascend monotonically. A disordered
crossing (highlighted in the fail colour) suggests that the
corresponding category is rarely the most likely response over any logit
interval, and is a common trigger for category-collapsing decisions.

## See also

[`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md),
[`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
(`type = "ccc"`).

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
p <- plot_threshold_ladder(fit, draw = FALSE)
head(p$data$data)
#>    Group  Step  Threshold Disordered
#> 1 Common tau_1 -1.3256307      FALSE
#> 2 Common tau_2 -0.0589816      FALSE
#> 3 Common tau_3  1.3846123      FALSE
```
