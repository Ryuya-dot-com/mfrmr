# Compute displacement diagnostics for facet levels

Compute displacement diagnostics for facet levels

## Usage

``` r
displacement_table(
  fit,
  diagnostics = NULL,
  facets = NULL,
  anchored_only = FALSE,
  abs_displacement_warn = 0.5,
  abs_t_warn = 2,
  top_n = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- facets:

  Optional subset of facets.

- anchored_only:

  If `TRUE`, keep only directly/group anchored levels.

- abs_displacement_warn:

  Absolute displacement warning threshold.

- abs_t_warn:

  Absolute displacement t-value warning threshold.

- top_n:

  Optional maximum number of rows to keep after sorting.

## Value

A named list with:

- `table`: displacement diagnostics by level

- `summary`: one-row summary

- `thresholds`: applied thresholds

## Details

Displacement is computed as a one-step Newton update:
`sum(residual) / sum(information)` for each facet level. This
approximates how much a level would move if constraints were relaxed.

## Interpreting output

- `table`: level-wise displacement and flag indicators.

- `summary`: count/share of flagged levels.

- `thresholds`: displacement and t-value cutoffs.

Large absolute displacement in anchored levels suggests potential
instability in anchor assumptions.

## Typical workflow

1.  Run `displacement_table(fit, anchored_only = TRUE)` for anchor
    checks.

2.  Inspect `summary(disp)` then detailed rows.

3.  Visualize with
    [`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md).

## Output columns

The `table` data.frame contains:

- Facet, Level:

  Facet name and element label.

- Displacement:

  One-step Newton displacement estimate (logits).

- DisplacementSE:

  Standard error of the displacement.

- DisplacementT:

  Displacement / SE ratio.

- Estimate, SE:

  Current measure estimate and its standard error.

- N:

  Number of observations involving this level.

- AnchorValue, AnchorStatus, AnchorType:

  Anchor metadata.

- Flag:

  Logical; `TRUE` when displacement exceeds thresholds.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
disp <- displacement_table(fit, anchored_only = FALSE)
summary(disp)
#> mfrmr Displacement Summary 
#>   Class: mfrm_displacement
#>   Components: 3
#> 
#> Displacement summary
#>  Levels AnchoredLevels FlaggedLevels FlaggedAnchoredLevels MaxAbsDisplacement
#>      56              0             0                     0                  0
#>  MaxAbsDisplacementT AbsDisplacementThreshold AbsTThreshold
#>                0.001                      0.5             2
#> 
#> Displacement rows: table
#>   Facet        Level WeightedN ResidualSum Information Displacement
#>  Person <suppressed>        16      -0.002       9.452            0
#>  Person <suppressed>        16      -0.002       9.452            0
#>  Person <suppressed>        16      -0.002      10.333            0
#>  Person <suppressed>        16       0.001       6.760            0
#>  Person <suppressed>        16       0.001       4.966            0
#>  Person <suppressed>        16      -0.001       3.461            0
#>  Person <suppressed>        16       0.001       9.182            0
#>  Person <suppressed>        16      -0.001       4.840            0
#>  Person <suppressed>        16      -0.001       9.205            0
#>  Person <suppressed>        16      -0.001       9.205            0
#>  DisplacementSE DisplacementT Estimate    SE  N AnchorValue AnchorStatus
#>           0.325        -0.001    0.684 0.325 16          NA             
#>           0.325        -0.001    0.684 0.325 16          NA             
#>           0.311        -0.001   -0.015 0.311 16          NA             
#>           0.385         0.000   -1.665 0.385 16          NA             
#>           0.449         0.000   -2.178 0.449 16          NA             
#>           0.538         0.000    2.684 0.538 16          NA             
#>           0.330         0.000   -0.918 0.330 16          NA             
#>           0.455         0.000    2.200 0.455 16          NA             
#>           0.330         0.000    0.791 0.330 16          NA             
#>           0.330         0.000    0.791 0.330 16          NA             
#>  AnchorType ReleasedEstimate AnchorGap FlagDisplacement FlagT  Flag
#>        Free            0.684        NA            FALSE FALSE FALSE
#>        Free            0.684        NA            FALSE FALSE FALSE
#>        Free           -0.016        NA            FALSE FALSE FALSE
#>        Free           -1.665        NA            FALSE FALSE FALSE
#>        Free           -2.178        NA            FALSE FALSE FALSE
#>        Free            2.684        NA            FALSE FALSE FALSE
#>        Free           -0.918        NA            FALSE FALSE FALSE
#>        Free            2.199        NA            FALSE FALSE FALSE
#>        Free            0.791        NA            FALSE FALSE FALSE
#>        Free            0.791        NA            FALSE FALSE FALSE
#> 
#> Settings
#>                Setting Value
#>  abs_displacement_warn   0.5
#>             abs_t_warn     2
#> 
#> Notes
#>  - Displacement summary for anchor drift and baseline drift checks.
#>  - Person identifiers are suppressed in this summary. Use `include_person =
#>    TRUE` only under appropriate privacy controls.
p_disp <- plot(disp, draw = FALSE)
p_disp$data$plot
#> [1] "lollipop"
# }
```
