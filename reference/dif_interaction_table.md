# Compute interaction table between a facet and a grouping variable

Produces a cell-level interaction table showing Obs-Exp differences,
scaled residuals, and absolute residual mean comparisons for each
facet-level x group-value cell.

## Usage

``` r
dif_interaction_table(
  fit,
  diagnostics,
  facet,
  group,
  data = NULL,
  min_obs = 10,
  p_adjust = "holm",
  abs_t_warn = 2,
  abs_bias_warn = 0.5
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- facet:

  Character scalar naming the facet.

- group:

  Character scalar naming the grouping column.

- data:

  Optional data frame with the group column. If `NULL` (default), the
  data stored in `fit$prep$data` is used, but it must contain the
  `group` column.

- min_obs:

  Minimum observations per cell. Cells with fewer than this many
  observations are marked sparse; scaled residuals and magnitude flags
  are `NA`. Observed and expected score summaries remain available.

- p_adjust:

  Retained for compatibility; unused because no p-values are reported.
  Default `"holm"`.

- abs_t_warn:

  Retained for compatibility; unused because scaled residuals are not t
  statistics. `flag_t` is `NA`.

- abs_bias_warn:

  Threshold for marking the absolute observed-minus-expected average, in
  score units. Default `0.5`. This is a descriptive magnitude rule.

## Value

Object of class `mfrm_dif_interaction` with:

- `table`: tibble with per-cell statistics and flags.

- `summary`: tibble summarizing flagged and sparse cell counts.

- `gpcm_boundary`: for `GPCM` fits, a capability-boundary table.

- `config`: list of analysis parameters.

## Details

This function uses observation-level residuals computed from the fitted
model rather than re-estimating it. For each facet-level x group-value
cell, it computes:

- N: number of observations in the cell

- ObsScore: sum of observed scores

- ExpScore: sum of expected scores

- ObsExpAvg: mean observed-minus-expected difference

- Var_sum: sum of model variances

- StdResidual: (ObsScore - ExpScore) / sqrt(Var_sum)

- t, df, p_value, p_adjusted, flag_t: `NA`, retained for compatibility

## When to use this instead of analyze_dff()

Use `dif_interaction_table()` when you want cell-level screening for a
single facet-by-group table. Use
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
when you want group-pair comparisons. Neither residual output tests
differential functioning.

## Further guidance

For plot selection and follow-up diagnostics, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md).

## Interpreting output

- `$table`: the full interaction table with one row per cell.

- `$summary`: overview counts of flagged and sparse cells.

- `$config`: analysis configuration parameters.

- `$gpcm_boundary`: for `GPCM` fits, a capability-boundary table marking
  the table as caveated DFF screening evidence.

- `flag_bias` records `|ObsExpAvg| > abs_bias_warn` in score units. It
  does not establish differential functioning. `flag_t` is unavailable.

- Sparse cells (N \< min_obs) have `sparse = TRUE` and unavailable
  scaled residuals and magnitude flags. The score means and counts are
  retained.

## GPCM boundary

For `GPCM`, the interaction table uses the fitted slope-aware
expected-score/residual scale and should be reported as screening
evidence, not as a standalone fairness, invariance, or operational
subgroup decision.

Residual means can differ even when response parameters are the same
between groups. These summaries provide no p-values or t-based
decisions. Recompute older saved tables with this function using the
fitted model; no refit is needed.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Run
    `dif_interaction_table(fit, diag, facet = "Rater", group = "Gender", data = df)`.

3.  Inspect `$table` for flagged cells.

4.  Visualize with
    [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md).

## See also

[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
[`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_bias")

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", model = "RSM", maxit = 300)
diag <- diagnose_mfrm(fit, residual_pca = "none")
int <- dif_interaction_table(fit, diag, facet = "Rater",
                             group = "Group", data = toy, min_obs = 2)
int$summary
#> # A tibble: 3 × 2
#>   Metric                                 Count
#>   <chr>                                  <int>
#> 1 Total cells                                8
#> 2 Sparse cells (N < min_obs)                 0
#> 3 Above absolute residual mean threshold     0
head(int$table[, c("Level", "GroupValue", "ObsExpAvg", "flag_bias")])
#> # A tibble: 6 × 4
#>   Level GroupValue ObsExpAvg flag_bias
#>   <chr> <chr>          <dbl> <lgl>    
#> 1 R01   A             0.0842 FALSE    
#> 2 R01   B            -0.0842 FALSE    
#> 3 R02   A            -0.0661 FALSE    
#> 4 R02   B             0.0661 FALSE    
#> 5 R03   A            -0.0563 FALSE    
#> 6 R03   B             0.0563 FALSE    
# }
```
