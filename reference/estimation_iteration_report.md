# Build an estimation-iteration report (preferred alias)

Build an estimation-iteration report (preferred alias)

## Usage

``` r
estimation_iteration_report(
  fit,
  max_iter = 20,
  reltol = NULL,
  include_prox = TRUE,
  include_fixed = FALSE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- max_iter:

  Maximum replay iterations (excluding optional initial row).

- reltol:

  Stopping tolerance for replayed max-logit change.

- include_prox:

  If `TRUE`, include an initial pseudo-row labeled `PROX`.

- include_fixed:

  If `TRUE`, include a legacy-compatible fixed-width text block.

## Value

A named list with iteration-report components. Class:
`mfrm_iteration_report`.

## Details

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_iteration_report` (`type = "residual"`, `"logit_change"`,
`"objective"`).

## Interpreting output

- `iterations`: trajectory of convergence indicators by iteration.

- `summary`: final status and stopping diagnostics.

- optional `PROX` row: pseudo-initial reference point when enabled.

## Typical workflow

1.  Run `estimation_iteration_report(fit)`.

2.  Inspect plateau/stability patterns in summary/plot.

3.  Adjust optimization settings if convergence looks weak.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`specifications_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/specifications_report.md),
[`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
out <- estimation_iteration_report(fit, max_iter = 5)
summary(out)
#> mfrmr Iteration Report Summary 
#>   Class: mfrm_iteration_report
#>   Components (3): table, summary, settings
#> 
#> Iteration overview
#>  FinalConverged FinalIterations ReplayRows ConnectedSubset
#>            TRUE              71          6            TRUE
#> 
#> Iteration rows: table
#>  Method Iteration MaxScoreResidualElements MaxScoreResidualPercent
#>    PROX         1                   44.000                1466.667
#>    JMLE         2                   32.372                1079.076
#>    JMLE         3                   17.345                 578.164
#>    JMLE         4                  -19.395                -646.496
#>    JMLE         5                   14.979                 499.290
#>    JMLE         6                   13.019                 433.962
#>  MaxScoreResidualCategories MaxLogitChangeElements MaxLogitChangeSteps
#>                     -39.726                     NA                  NA
#>                     -33.843                  0.226               0.155
#>                      38.014                  0.244               0.443
#>                     -40.558                  0.145               0.582
#>                     -20.843                  0.087               0.138
#>                      27.980                  0.120               0.364
#>  Objective
#>         NA
#>  -1021.913
#>   -982.631
#>   -959.201
#>   -948.673
#>   -930.036
#> 
#> Settings
#>        Setting Value
#>       max_iter     5
#>         reltol 1e-06
#>   include_prox  TRUE
#>    quad_points    31
#>  include_fixed FALSE
#> 
#> Notes
#>  - Legacy-compatible Table 3 replay of estimation iterations.
p_iter <- plot(out, draw = FALSE)
p_iter$data$plot
#> [1] "residual"
```
