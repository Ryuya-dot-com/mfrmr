# Differential facet functioning analysis

Tests whether the difficulty of facet levels differs across a grouping
variable (e.g., whether rater severity differs for male vs. female
examinees, or whether item difficulty differs across rater subgroups).

`analyze_dif()` is retained for compatibility with earlier package
versions. In many-facet workflows, prefer `analyze_dff()` as the primary
entry point.

## Usage

``` r
analyze_dff(
  fit,
  diagnostics,
  facet,
  group,
  data = NULL,
  focal = NULL,
  method = c("residual", "refit"),
  min_obs = 10,
  p_adjust = "holm"
)

analyze_dif(...)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- facet:

  Character scalar naming the facet whose elements are tested for
  differential functioning (for example, `"Criterion"` or `"Rater"`).

- group:

  Character scalar naming the column in the data that defines the
  grouping variable (e.g., `"Gender"`, `"Site"`).

- data:

  Optional data frame containing at least the group column and the same
  person/facet/score columns used to fit the model. If `NULL` (default),
  mfrmr tries to recover the data from `fit$prep$data`. That slot only
  holds the columns that
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  actually modelled; if the grouping column was not among them (common
  for DIF screening), pass the original data frame via `data = <df>`
  explicitly. The same applies when the fit object has been serialized
  without the prep slot.

- focal:

  Optional character vector of group levels to treat as focal. If `NULL`
  (default), all pairwise group comparisons are performed.

- method:

  Analysis method: `"residual"` (default) uses the fitted model's
  residuals without re-estimation; `"refit"` re-estimates the model
  within each group subset. The residual method is faster and avoids
  convergence issues with small subsets.

- min_obs:

  Minimum number of observations per cell (facet-level x group). Cells
  below this threshold are flagged as sparse and their statistics set to
  `NA`. Default `10`.

- p_adjust:

  Method for multiple-comparison adjustment, passed to
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html). Default
  is `"holm"`.

- ...:

  Passed directly to `analyze_dff()`.

## Value

An object of class `mfrm_dff` (with compatibility class `mfrm_dif`)
with:

- `dif_table`: data.frame of differential-functioning contrasts.

- `cell_table`: (residual method) per-cell detail table.

- `summary`: counts by method-appropriate screening classification.

- `group_fits`: (refit method) per-group facet estimates.

- `gpcm_boundary`: for bounded `GPCM` fits, a capability-boundary table.

- `config`: list with facet, group, method, min_obs, p_adjust settings.

## Details

**Differential facet functioning (DFF)** occurs when the difficulty or
severity of a facet element differs across subgroups of the population,
after controlling for overall ability. In an MFRM context this
generalises classical DIF (which applies to items) to any facet: raters,
criteria, tasks, etc.

Differential functioning is a threat to measurement fairness: if
Criterion 1 is harder for Group A than Group B at the same ability
level, the measurement scale is no longer group-invariant.

Two methods are available:

**Residual method** (`method = "residual"`): Uses the existing fitted
model's observation-level residuals. For each facet-level \\\times\\
group cell, the observed and expected score sums are aggregated and a
standardized residual is computed as: \$\$z = \frac{\sum (X\_{obs} -
E\_{exp})}{\sqrt{\sum \mathrm{Var}}}\$\$ Pairwise contrasts between
groups compare the mean observed-minus-expected difference for each
facet level, with uncertainty summarized by a Welch/Satterthwaite
approximation. This method is fast, stable with small subsets, and does
not require re-estimation. Because the resulting contrast is not a
logit-scale parameter difference, the residual method is treated as a
screening procedure rather than an ETS-style classifier.

**Refit method** (`method = "refit"`): Subsets the data by group, refits
the MFRM model within each subset, anchors all non-target facets back to
the baseline calibration when possible, and compares the resulting
facet-level estimates. When linking, convergence, model-based MML
precision, and sparsity screens all pass, a conditional plug-in Welch
statistic is also shown: \$\$t = \frac{\hat{\delta}\_1 -
\hat{\delta}\_2} {\sqrt{SE_1^2 + SE_2^2}}\$\$ This provides
group-specific point estimates on a common scale when linking anchors
are available. However, the plug-in standard error conditions on the
baseline anchors and omits baseline-anchor uncertainty and cross-refit
covariance. Refit statistics therefore remain screening evidence and set
`FormalInferenceEligible`, `SupportsFormalInference`,
`PrimaryReportingEligible`, and `ETS_Eligible` to `FALSE`.

When `facet` refers to an item-like facet (for example `Criterion`),
this recovers the familiar DIF case. When `facet` refers to raters or
prompts/tasks, the same machinery supports DRF/DPF-style analyses.

Refit contrasts are not assigned ETS A/B/C labels. Even when subgroup
point estimates share a linked logit scale, a validated joint,
bootstrap, or replicate covariance contract is required before formal
refit inference.

Multiple comparisons are adjusted using Holm's step-down procedure by
default, which controls the family-wise error rate without assuming
independence. Alternative methods (e.g., `"BH"` for false discovery
rate) can be specified via `p_adjust`.

## Choosing a method

In most first-pass DFF screening, start with `method = "residual"`. It
is faster, reuses the fitted model, and is less fragile in smaller
subsets. Use `method = "refit"` when you specifically want
group-specific parameter estimates and can tolerate extra computation.
Both methods should yield similar conclusions when sample sizes are
adequate (\\N \ge 100\\ per group is a useful guideline for stable
differential-functioning detection).

## Interpreting output

- `$dif_table`: one row per facet-level x group-pair with contrast, SE,
  t-statistic, p-value, adjusted p-value, effect metric, and
  method-appropriate classification. Includes `Method`, `N_Group1`,
  `N_Group2`, `EffectMetric`, `ClassificationSystem`, `ContrastBasis`,
  `SEBasis`, `StatisticLabel`, `ProbabilityMetric`, `DFBasis`,
  `ReportingUse`, `PrimaryReportingEligible`, and `sparse` columns.

- `$cell_table`: (residual method only) per-cell detail with N,
  ObsScore, ExpScore, ObsExpAvg, StdResidual.

- `$summary`: counts by screening result (`method = "residual"`) or
  linked- screening and insufficient-linking rows (`method = "refit"`).

- `$group_fits`: (refit method only) list of per-group facet estimates
  and subgroup linking diagnostics.

- `$gpcm_boundary`: for bounded `GPCM` fits, a capability-boundary table
  marking the DFF/DIF output as caveated screening evidence.

## GPCM boundary

For bounded `GPCM`, DFF/DIF rows are available as slope-aware screening
evidence over the fitted expected-score and residual scale. Keep
residual-method contrasts and interaction cells in screening language.
Refit contrasts require explicit subgroup linking and precision support
for conditional screening, but remain in screening language.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
    For `RSM` / `PCM` fairness review, prefer `method = "MML"`.

2.  Run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    and, for `RSM` / `PCM`, prefer `diagnostic_mode = "both"` so legacy
    and strict marginal screens remain visible together.

3.  Run
    `analyze_dff(fit, diagnostics, facet = "Criterion", group = "Gender", data = my_data)`.

4.  Inspect `$dif_table` for flagged levels and `$summary` for counts.

5.  Use
    [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md)
    when you need cell-level diagnostics.

6.  Use
    [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md)
    or
    [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md)
    for communication.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
[`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
[`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md),
[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_bias")

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", model = "RSM", quad_points = 7, maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
dff <- analyze_dff(fit, diag, facet = "Rater", group = "Group", data = toy)
dff$summary
# Look for: a small `FlaggedPairs` count relative to `Pairs`. Under
#   method = "residual", `ClassificationSystem` is "screening", not
#   ETS. "Screen positive" rows are prompts for substantive review.
head(dff$dif_table[, c("Level", "Group1", "Group2", "Contrast",
                       "Classification", "ClassificationSystem")])
# The residual contrast is an observed-minus-expected average contrast
# between groups. It is useful for screening, but it is not an ETS
# A/B/C logit-delta classification.
dff_refit <- analyze_dff(fit, diag, facet = "Rater", group = "Group",
                         data = toy, method = "refit")
unique(dff_refit$dif_table$ClassificationSystem)
# Look for: "descriptive". Linked refit contrasts remain screening-only
#   because their plug-in uncertainty omits anchor uncertainty and
#   cross-refit covariance.
sc <- subset_connectivity_report(fit, diagnostics = diag)
plot(sc, type = "design_matrix", draw = FALSE)
if ("ScaleLinkStatus" %in% names(dff_refit$dif_table)) {
  unique(dff_refit$dif_table$ScaleLinkStatus)
}
# Look for: "linked" in `ScaleLinkStatus` confirms the focal and
#   reference groups share enough common elements for a comparable
#   contrast; "demoted_*" rows lose linking under the refit branch
#   and should be read as exploratory.
} # }
```
