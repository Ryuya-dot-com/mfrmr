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

# S3 method for class 'mfrm_dif_interaction'
plot(x, type = "heatmap", ...)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).

- facet:

  Character scalar naming the facet.

- group:

  Character scalar naming the grouping column.

- data:

  Optional data frame with the group column. If `NULL` (default), the
  data stored in `fit$prep$data` is used, but it must contain the
  `group` column. All fitted response columns, including the weight
  column if used, are required. Subsets and repeated responses follow
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_dff.md)'s
  response-matching contract; unmatched rows remain visible in `$cases`.

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

- x:

  A result from `dif_interaction_table()`.

- type:

  The sole view, `"heatmap"`.

- ...:

  Heatmap controls below, plus `draw = FALSE` to return data without
  drawing. This input accepts `metric = "obs_exp"` or `"t"`;
  `"contrast"` requires a result from
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_dff.md).

## Value

Object of class `mfrm_dif_interaction` with:

- `table`: tibble with per-cell statistics and flags.

- `cases`: requested-row matching and exclusion audit.

- `summary`: tibble summarizing flagged and sparse cell counts.

- `gpcm_boundary`: for `GPCM` fits, a capability-boundary table.

- `config`: list of analysis parameters.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object carrying `matrix`, `pairs`, the selected metric and
retained interpretation notes. Use `plot_data(p, "matrix")` to extract
the matrix from a saved plot `p`.

## Details

This function uses observation-level residuals computed from the fitted
model rather than re-estimating it. For each facet-level x group-value
cell, it computes:

- N: number of observations in the cell

- NPersons: number of distinct Persons in the cell, not an independence
  certificate

- ObsScore: sum of observed scores

- ExpScore: sum of expected scores

- ObsExpAvg: mean observed-minus-expected difference

- Var_sum: sum of model variances

- StdResidual: (ObsScore - ExpScore) / sqrt(Var_sum)

- t, df, p_value, p_adjusted, flag_t: `NA`, retained for compatibility

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot a
differential-functioning interaction grid

Display saved residual means by facet level and group. This is a
descriptive screen for follow-up; residual differences do not isolate
differential functioning.

## When to use this instead of analyze_dff()

Use `dif_interaction_table()` when you want cell-level screening for a
single facet-by-group table. Use
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_dff.md)
when you want group-pair comparisons. Neither residual output tests
differential functioning.

## Further guidance

For plot selection and follow-up diagnostics, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md).

## Interpreting output

- `$table`: the full interaction table with one row per cell.

- `$cases`: requested-row matching and exclusion audit, also kept by
  [`summary()`](https://rdrr.io/r/base/summary.html).

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
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

2.  Run
    `dif_interaction_table(fit, diag, facet = "Rater", group = "Gender", data = df)`.

3.  Inspect `$table` for flagged cells.

4.  Visualize with [plot(x, type =
    "heatmap")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_dif.md).

## Interpretation

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

Positive `"obs_exp"` values mean observed scores exceed model
expectations; negative values mean they fall below expectations. These
values are in score units, not logits. The `"t"` metric is a scaled
residual without a calibrated test or p-value. Color and optional
threshold outlines are descriptive; an unavailable cell is not a zero
residual.

## Heatmap appearance

- `show_values = TRUE` labels cells; `value_digits = 2` controls
  rounding.

- `flag_threshold = NULL` adds no flags. A non-negative value outlines
  cells at or above that absolute value; `flag_color = "black"` sets the
  border.

- `scale_limit = NULL` uses the observed range. A positive value fixes
  symmetric color limits for comparing plots. It does not change saved
  values.

## See also

[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_dff.md),
[plot(x, type =
"heatmap")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_dif.md),
[`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/dif_report.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)

`dif_interaction_table()`,
[`plot.mfrm_dif()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_dif.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("dif_interaction_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_bias")

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", model = "RSM", maxit = 300)
diag <- diagnose_mfrm(fit, residual_pca = "none")
int <- dif_interaction_table(fit, diag, facet = "Rater",
                             group = "Group", data = toy, min_obs = 2)
int$summary
head(int$table[, c("Level", "GroupValue", "ObsExpAvg", "flag_bias")])
} # }
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot.mfrm_dif_interaction", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("example_bias")

fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", model = "RSM", maxit = 300)
diag <- diagnose_mfrm(fit, residual_pca = "none")
int <- dif_interaction_table(fit, diag, facet = "Rater",
                             group = "Group", data = ratings, min_obs = 2)
heat <- plot(int, type = "heatmap", metric = "obs_exp", draw = FALSE)
dim(plot_data(heat, "matrix"))
# Obs-Exp is in score units, not logits. A scaled residual
# (metric = "t") is descriptive, not a calibrated t-test.
} # }
```
