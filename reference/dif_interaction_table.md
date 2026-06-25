# Compute interaction table between a facet and a grouping variable

Produces a cell-level interaction table showing Obs-Exp differences,
standardized residuals, and screening statistics for each facet-level x
group-value cell.

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
  observations are flagged as sparse and their test statistics set to
  `NA`. Default `10`.

- p_adjust:

  P-value adjustment method, passed to
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html). Default
  `"holm"`.

- abs_t_warn:

  Threshold for flagging cells by absolute t-value. Default `2`.

- abs_bias_warn:

  Threshold for flagging cells by absolute Obs-Exp average (in logits).
  Default `0.5`.

## Value

Object of class `mfrm_dif_interaction` with:

- `table`: tibble with per-cell statistics and flags.

- `summary`: tibble summarizing flagged and sparse cell counts.

- `gpcm_boundary`: for bounded `GPCM` fits, a capability-boundary table.

- `config`: list of analysis parameters.

## Details

This function uses the fitted model's observation-level residuals (from
the internal `compute_obs_table()` function) rather than re-estimating
the model. For each facet-level x group-value cell, it computes:

- N: number of observations in the cell

- ObsScore: sum of observed scores

- ExpScore: sum of expected scores

- ObsExpAvg: mean observed-minus-expected difference

- Var_sum: sum of model variances

- StdResidual: (ObsScore - ExpScore) / sqrt(Var_sum)

- t: approximate t-statistic (equal to StdResidual)

- df: N - 1

- p_value: two-tailed p-value from the t-distribution

## When to use this instead of analyze_dff()

Use `dif_interaction_table()` when you want cell-level screening for a
single facet-by-group table. Use
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
when you want group-pair contrasts summarized into
differential-functioning effect sizes and method-appropriate
classifications.

## Further guidance

For plot selection and follow-up diagnostics, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md).

## Interpreting output

- `$table`: the full interaction table with one row per cell.

- `$summary`: overview counts of flagged and sparse cells.

- `$config`: analysis configuration parameters.

- `$gpcm_boundary`: for bounded `GPCM` fits, a capability-boundary table
  marking the table as caveated DFF screening evidence.

- Cells with `|t| > abs_t_warn` or `|ObsExpAvg| > abs_bias_warn` are
  flagged in the `flag_t` and `flag_bias` columns.

- Sparse cells (N \< min_obs) have `sparse = TRUE` and NA statistics.

## GPCM boundary

For bounded `GPCM`, the interaction table uses the fitted slope-aware
expected-score/residual scale and should be reported as screening
evidence, not as a standalone fairness, invariance, or operational
subgroup decision.

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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_bias")

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", model = "RSM", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
int <- dif_interaction_table(fit, diag, facet = "Rater",
                             group = "Group", data = toy, min_obs = 2)
int$summary
head(int$table[, c("Level", "GroupValue", "ObsExpAvg", "flag_bias")])
}
```
