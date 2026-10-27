# Plot differential facet functioning

Compare saved group contrasts as ordered bars or a heatmap. Read the
analysis method and scale before interpreting the size of a difference.

## Usage

``` r
# S3 method for class 'mfrm_dif'
plot(x, type = c("summary", "heatmap"), ...)
```

## Arguments

- x:

  A result from
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  or
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).

- type:

  `"summary"` for ordered effects or `"heatmap"` for the interaction
  grid.

- ...:

  Named controls described below. Both views accept `draw = FALSE` to
  return plot data without drawing. Controls for the other view are
  rejected.

## Value

An `mfrm_plot_data` object. The summary's `data$data` holds the
displayed contrasts; the heatmap's `data$matrix` holds the plotted
matrix. Both retain source rows in `data$pairs`, response matches (when
available) in `data$cases`, and source settings in
`data$analysis_config`. When supplied to
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
the separate prospective interaction review is retained in
`data$comparison_review`. Its states do not classify the displayed
residual/refit effects; inspect its own model and weights. Retain the
returned notes and unavailable values when exporting; a plot does not
qualify new inference.

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
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)
for the different linking screens.

## Interpreting output

Bars are anchored at zero. Width corresponds to effect size on the
contrast's native scale. For `method = "residual"`, this is the
observed-minus-expected average difference between groups, in score
units. For `method = "refit"`, this is the subgroup parameter difference
on the fitted logit scale when linking support allows a comparable
contrast. Residual differences do not isolate differential functioning.
Linked refit intervals omit estimated-anchor uncertainty and cross-refit
covariance.

## See also

[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)

## Examples

``` r
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
#> [1] "descriptive"
p <- plot(dff, type = "summary", draw = FALSE)
comparisons <- plot_data(p, "pairs")
comparisons[, c("Level", "Group1", "Group2", "Contrast",
                 "N_Group1", "N_Group2", "PlotStatus")]
#>   Level Group1 Group2    Contrast N_Group1 N_Group2 PlotStatus
#> 1   R01      A      B  0.16845853       48       48  Displayed
#> 2   R02      A      B -0.13221860       48       48  Displayed
#> 3   R03      A      B -0.11261117       48       48  Displayed
#> 4   R04      A      B  0.07637118       48       48  Displayed
table(plot_data(p, "cases")$Reason)
#> 
#> included 
#>      384 
plot_data(p, "notes")
#>               Type
#> 1   Interpretation
#> 2         subtitle
#> 3   retention_note
#> 4   Zero reference
#> 5 Group comparison
#>                                                                                                                                                                                                                                                                                      Text
#> 1                                                                                                                                                                               Residual differences do not isolate differential functioning; no test or confidence interval is provided.
#> 2                                                                                                                                                                                                      4 comparisons shown. Residual differences do not isolate differential functioning.
#> 3                                                                                                        4 of 4 source comparisons displayed; 0 unavailable and 0 not selected by top_n. See pairs$PlotStatus and the source comparison conditions; omission does not mean no difference.
#> 4                                                                                                                                                             Zero denotes no difference on the displayed scale. Use the sign convention and contrast basis reported in the source table.
#> 5 Group1 minus Group2 in mean observed-minus-expected scores (score units): a positive contrast means higher residual scores in Group1, not established leniency or favoritism. Residual differences do not isolate differential functioning; no test or confidence interval is provided.
```
