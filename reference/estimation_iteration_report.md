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

A named list with iteration-report components and, for bounded `GPCM`, a
`gpcm_boundary` table. Class: `mfrm_iteration_report`.

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

For bounded `GPCM`, this helper replays slope-aware optimization steps
from a reconstructed starting state. It is not the exact optimizer
history from the fitted object and is not an additional convergence
test. Use `summary(fit, profile = "fit", detail = "brief")` for the
recorded convergence result, and read the returned `gpcm_boundary`
before reporting the replay.

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
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", quad_points = 7, maxit = 30
)
out <- estimation_iteration_report(fit, max_iter = 5)
summary(out)
#> mfrmr Iteration Report Summary 
#>   Class: mfrm_iteration_report
#>   Components: 4
#> 
#> Iteration overview
#>  FinalConverged OptimizerCodeZero ConvergenceSeverity FinalIterations
#>            TRUE              TRUE                pass              16
#>  ReplayRows ConnectedSubset
#>           6            TRUE
#> 
#> Iteration rows: table
#>  Method Iteration MaxScoreResidualElements MaxScoreResidualPercent
#>    PROX         1                   16.194                 539.801
#>     MML         2                   -6.883                -229.443
#>     MML         3                   -4.437                -147.905
#>     MML         4                   -3.657                -121.909
#>     MML         5                   -3.285                -109.487
#>     MML         6                   -3.408                -113.614
#>  MaxScoreResidualCategories MaxLogitChangeElements MaxLogitChangeSteps
#>                      -7.704                     NA                  NA
#>                      -4.169                  0.465               0.069
#>                       4.731                  0.218               0.110
#>                       4.761                  0.080               0.017
#>                       5.172                  0.064               0.017
#>                       5.029                  0.031               0.004
#>  Objective
#>         NA
#>   -349.983
#>   -347.977
#>   -347.563
#>   -347.364
#>   -347.291
#> 
#> Settings
#>        Setting Value
#>       max_iter     5
#>         reltol 1e-09
#>   include_prox  TRUE
#>    quad_points     7
#>  include_fixed FALSE
#> 
#> Notes
#>  - Legacy-compatible Table 3 replay of estimation iterations.
p_iter <- plot(out, draw = FALSE)
p_iter$data$plot
#> [1] "residual"
```
