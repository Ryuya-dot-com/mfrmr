# Differential facet functioning (DFF) screening

Screen group differences on a selected measurement `facet` using either
baseline-model residuals (`method = "residual"`) or anchor-linked
subgroup refits (`method = "refit"`).

The former `analyze_dif()` name is no longer exported. Use
`analyze_dff()`; the calculation and saved result class are unchanged.

[`summary()`](https://rdrr.io/r/base/summary.html) returns the contrast,
cell, summary, and configuration tables without refitting. A summary
from `analyze_dff()` keeps its DFF label when printed; a saved
`mfrm_dif` summary keeps its DIF label.

Compare saved group contrasts as ordered bars, a heatmap, or a paired
two-group scatterplot with optional marginal histograms. Read the
analysis method and scale before interpreting the size of a difference.

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
  p_adjust = "holm",
  comparison_review = NULL
)

# S3 method for class 'mfrm_dif'
summary(object, ...)

# S3 method for class 'mfrm_dff'
summary(object, ...)

# S3 method for class 'summary.mfrm_dif'
print(x, ...)

# S3 method for class 'summary.mfrm_dff'
print(x, ...)

# S3 method for class 'mfrm_dif'
print(x, ...)

# S3 method for class 'mfrm_dff'
print(x, ...)

# S3 method for class 'mfrm_dif'
plot(x, type = c("summary", "heatmap", "scatter"), ...)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  and (required for `"refit"`) matching
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- diagnostics:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  and (required for `"refit"`) matching
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- facet:

  Target facet column, grouping column in `data` (recovered from
  `fit$prep$data` when present), optional source `data.frame`, and
  optional focal group vector (`NULL` compares all pairs).

- group:

  Target facet column, grouping column in `data` (recovered from
  `fit$prep$data` when present), optional source `data.frame`, and
  optional focal group vector (`NULL` compares all pairs).

- data:

  Target facet column, grouping column in `data` (recovered from
  `fit$prep$data` when present), optional source `data.frame`, and
  optional focal group vector (`NULL` compares all pairs).

- focal:

  Target facet column, grouping column in `data` (recovered from
  `fit$prep$data` when present), optional source `data.frame`, and
  optional focal group vector (`NULL` compares all pairs).

- method:

  `"residual"` (default: aggregates observed-minus-expected cell scores
  with descriptive \\z = \sum(X\_{\mathrm{obs}} - E\_{\mathrm{exp}}) /
  \sqrt{\sum \mathrm{Var}}\\ and `NA` test columns) or `"refit"`
  (re-estimates each subgroup anchoring non-target facets to baseline,
  reporting linked contrasts and conditional plug-in Welch screens \\t =
  (\hat\delta_1 - \hat\delta_2)/\sqrt{\mathrm{SE}\_1^2 +
  \mathrm{SE}\_2^2}\\ when disjoint-Person and linking checks pass;
  omits baseline-anchor covariance so `FormalInferenceEligible = FALSE`
  and no ETS A/B/C labels are assigned).

- min_obs:

  Minimum cell count (`10` default; sparse cells withhold screening
  statistics while retaining refit points) and
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method
  (`"holm"` default) for refit screening tails.

- p_adjust:

  Minimum cell count (`10` default; sparse cells withhold screening
  statistics while retaining refit points) and
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method
  (`"holm"` default) for refit screening tails.

- comparison_review:

  Optional prospective
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  `comparison_review` preserved alongside residual/refit screens.

- object:

  An `mfrm_dff` or `mfrm_dif` result, or its summary.

- ...:

  Named controls described below. All views accept `draw = FALSE` to
  return the `ggplot` object without printing. Controls for other views
  are rejected.

- x:

  A result from `analyze_dff()`.

- type:

  `"summary"` for ordered effects, `"heatmap"` for the interaction grid,
  or `"scatter"` for a paired two-group scatterplot with marginal
  histograms (`groups`, `metric`,
  `marginal = c("auto", "histogram", "none")`, `ci_level`,
  `show_labels`).

## Value

An `mfrm_dff` (and `mfrm_dif`) list with `dif_table` (`Fixed1`,
`Fixed2`, `ScaleLinkStatus`, `ComparisonStatus`), `cell_table`,
`summary`, `group_fits`, `gpcm_boundary`, and `config`.

[`summary()`](https://rdrr.io/r/base/summary.html) returns a structured
differential-functioning summary.
[`print()`](https://rdrr.io/r/base/print.html) returns its input
invisibly.

Invisibly, a `ggplot` object carrying the underlying plot payload
accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
The summary's `data` component holds the displayed contrasts; the
heatmap's `matrix` holds the plotted matrix; the scatterplot's `table`
holds paired group values (`X`, `Y`) and `marginal_histograms` records
bin counts when marginal histograms are shown. Views retain source rows
in `pairs`, response matches (when available) in `cases`, and source
settings in `analysis_config`. When supplied to `analyze_dff()`, the
separate prospective interaction review is retained in
`comparison_review`. Its states do not classify the displayed
residual/refit effects; inspect its own model and weights. Retain the
returned notes and unavailable values when exporting; a plot does not
qualify new inference.

## Details

Residual matching pairs `data` rows against `fit$prep$data` (`$cases`
records `InputRow`, `FitRow`, `Included`, and `Reason`). For inferential
group-by-score tests under explicit matching strata, see
[`mantel_haenszel_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mantel_haenszel_table.md)
and
[`ordinal_logistic_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/ordinal_logistic_table.md).

## Summary controls

- `top_n = 30` limits displayed contrasts; `sort_by` is `"abs_effect"`
  (default), `"effect"`, or `"classification"`.

- `ci_level = NULL` omits intervals. A level such as `0.95` requests
  approximate normal intervals from available linked-refit standard
  errors; residual comparisons require `NULL`.

- `effect_thresholds` adds symmetric effect-size guide lines, not
  classification boundaries. `effect_axis_label` overrides the axis
  label.

- `preset` is `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`.

## Heatmap controls

- `metric = "obs_exp"` shows cell mean observed-minus-expected scores;
  `"t"` shows a descriptive scaled residual, not a t-test. These require
  the cell table from `method = "residual"`. `"contrast"` shows the
  saved pairwise group contrasts, on the analysis method's scale.

## Heatmap appearance

- `show_values = TRUE` labels cells; `value_digits = 2` controls
  rounding.

- `flag_threshold = NULL` adds no flags. A non-negative value outlines
  cells at or above that absolute value; `flag_color = "black"` sets the
  border.

- `scale_limit = NULL` uses the observed range. A positive value fixes
  symmetric color limits for comparing plots. It does not change saved
  values.

## Interpreting output

Bars are anchored at zero. Width corresponds to effect size on the
contrast's native scale. For `method = "residual"`, this is the
observed-minus-expected average difference between groups, in score
units. For `method = "refit"`, this is the subgroup parameter difference
on the fitted logit scale when linking support allows a comparable
contrast. Residual differences do not isolate differential functioning.
Linked refit intervals omit estimated-anchor uncertainty and cross-refit
covariance.

## Read the figure with its source table

Summary labels follow `Level | Group1 | Group2`. Both summary bars and
contrast heatmaps use **Group1 minus Group2**. A positive residual
contrast means higher mean residual scores in Group1; a positive refit
contrast means a larger facet location in Group1. With the usual
difficulty/severity orientation, the latter means harder for Group1.
Check the model's facet signs and rubric coding before interpreting
either as favorable treatment.

`plot_data(p, "pairs")` retains the source rows, counts and analysis
conditions. For summaries, `PlotStatus` distinguishes displayed rows,
finite contrasts omitted by `top_n`, and unavailable contrasts. The last
two do not mean zero or no differential functioning. If all contrasts
are unavailable, the summary cannot draw points; inspect `x$dif_table`
or a contrast heatmap. Heatmap cells with missing values remain missing.
An observed-minus-expected cell mean can still be shown when its cell is
below `min_obs`; inspect `sparse`. The scaled-residual and
pairwise-contrast routes withhold such values.

`N_Group1` and `N_Group2` count retained response rows. Residual results
also give distinct-Person counts, which need not be independent
observations. `plot_data(p, "cases")` preserves residual response
matches and exclusion reasons; it is `NULL` for refit results, which
have no such response audit. Refit source rows instead report
`ScaleLinkStatus`, `ContrastComparable`, fixed-target flags and subgroup
linking details. A finite point or an adequate linking screen does not
establish formal DFF inference. See
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
for the different linking screens.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
[`mantel_haenszel_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mantel_haenszel_table.md),
[`ordinal_logistic_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/ordinal_logistic_table.md),
[`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)

`analyze_dff()`

`analyze_dff()`,
[`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("analyze_dff", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_bias")

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", model = "RSM", quad_points = 7, maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
dff <- analyze_dff(fit, diag, facet = "Rater", group = "Group", data = toy)
dff$summary
# Read the residual mean difference and the number of observations per group.
head(dff$dif_table[, c("Level", "Group1", "Group2", "Contrast",
                       "N_Group1", "N_Group2")])
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
# "linked" records that the implemented linking checks passed.
# It does not establish anchor invariance or valid inferential uncertainty.
# Review all comparison reasons, including any "demoted_*" status.
} # }
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_dif", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_bias.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "bias-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
# Group labels from the same synthetic data used for the saved fit.
ratings <- load_mfrmr_data(example_fit$dataset)
dff <- analyze_dff(fit, diagnostics = diag,
                   facet = "Rater", group = "Group", data = ratings)
unique(dff$dif_table$ClassificationSystem)
p <- plot(dff, type = "summary", draw = FALSE)
comparisons <- plot_data(p, "pairs")
comparisons[, c("Level", "Group1", "Group2", "Contrast",
                 "N_Group1", "N_Group2", "PlotStatus")]
table(plot_data(p, "cases")$Reason)
plot_data(p, "notes")
p_scatter <- plot(dff, type = "scatter", draw = FALSE)
head(plot_data(p_scatter, "data"))
} # }
```
