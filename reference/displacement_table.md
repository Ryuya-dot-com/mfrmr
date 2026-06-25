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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
disp <- displacement_table(fit, anchored_only = FALSE)
summary(disp)
p_disp <- plot(disp, draw = FALSE)
p_disp$data$plot
}
```
