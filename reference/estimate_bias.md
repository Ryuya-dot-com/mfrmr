# Screen facet combinations for departures from a fitted model

Estimate conditional plug-in interaction shifts \\b\_{jc}\\ within
`[-max_abs, max_abs]` holding a fitted `RSM`, `PCM`, or one-family
`GPCM` baseline calibration and Person measures fixed (FACETS Table 13
screen; for jointly estimated interactions use `facet_interactions` in
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
and
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)).

`interaction_effect_table()` returns the fixed-effect interaction block
estimated by
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
when `facet_interactions` is supplied. These are model-estimated
deviations from the additive main-effects MFRM, not the residual
screening statistics returned by `estimate_bias()`.

## Usage

``` r
estimate_bias(
  fit,
  diagnostics,
  facet_a = NULL,
  facet_b = NULL,
  interaction_facets = NULL,
  max_abs = 10,
  omit_extreme = TRUE,
  max_iter = 4,
  tol = 0.001,
  xtreme = 0
)

interaction_effect_table(fit, comparison_review = NULL)

# S3 method for class 'mfrm_bias'
summary(object, digits = 3, top_n = 10, p_cut = 0.05, ...)

# S3 method for class 'mfrm_bias'
plot(
  x,
  type = c("scatter", "ranked", "heatmap", "abs_t_hist", "facet_profile"),
  ...
)

bias_count_table(
  bias_results,
  min_count_warn = 10,
  branch = c("original", "facets"),
  fit = NULL
)
```

## Arguments

- fit:

  Optional
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  result used to attach run context metadata.

- diagnostics:

  Matching
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  and
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  outputs.

- facet_a:

  Two facet names (`facet_a`, `facet_b`) or a character vector of `>= 2`
  facets (`interaction_facets` supports 3+ way screens and explicit
  `"Person"` plug-in screens).

- facet_b:

  Two facet names (`facet_a`, `facet_b`) or a character vector of `>= 2`
  facets (`interaction_facets` supports 3+ way screens and explicit
  `"Person"` plug-in screens).

- interaction_facets:

  Two facet names (`facet_a`, `facet_b`) or a character vector of `>= 2`
  facets (`interaction_facets` supports 3+ way screens and explicit
  `"Person"` plug-in screens).

- max_abs:

  Search bound on `|Bias Size|`, extreme-element exclusion toggle,
  iteration-pass log ceiling and tolerance, and optional inward
  extreme-cell total adjustment (`0` default withholds boundary
  SE/tails; `.5` gives `BiasStatus = "extreme_adjusted"` in additive
  RSM/PCM JML without group anchors).

- omit_extreme:

  Search bound on `|Bias Size|`, extreme-element exclusion toggle,
  iteration-pass log ceiling and tolerance, and optional inward
  extreme-cell total adjustment (`0` default withholds boundary
  SE/tails; `.5` gives `BiasStatus = "extreme_adjusted"` in additive
  RSM/PCM JML without group anchors).

- max_iter:

  Search bound on `|Bias Size|`, extreme-element exclusion toggle,
  iteration-pass log ceiling and tolerance, and optional inward
  extreme-cell total adjustment (`0` default withholds boundary
  SE/tails; `.5` gives `BiasStatus = "extreme_adjusted"` in additive
  RSM/PCM JML without group anchors).

- tol:

  Search bound on `|Bias Size|`, extreme-element exclusion toggle,
  iteration-pass log ceiling and tolerance, and optional inward
  extreme-cell total adjustment (`0` default withholds boundary
  SE/tails; `.5` gives `BiasStatus = "extreme_adjusted"` in additive
  RSM/PCM JML without group anchors).

- xtreme:

  Search bound on `|Bias Size|`, extreme-element exclusion toggle,
  iteration-pass log ceiling and tolerance, and optional inward
  extreme-cell total adjustment (`0` default withholds boundary
  SE/tails; `.5` gives `BiasStatus = "extreme_adjusted"` in additive
  RSM/PCM JML without group anchors).

- comparison_review:

  Optional result of
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  with `comparisons`, or its `$comparison_review` component. Returns the
  declared interaction contrasts from a matching joint fit instead of
  individual cells.

- object:

  Output from `estimate_bias()`.

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of strongest bias rows to keep.

- p_cut:

  Tail-area cutoff used for counting screen-positive rows.

- ...:

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Named
  controls below. `draw = FALSE` returns the plot data without drawing.
  Controls do not change the fitted calibration.

  For [`summary()`](https://rdrr.io/r/base/summary.html): Reserved for
  generic compatibility.

- x:

  A result from `estimate_bias()`.

- type:

  `"scatter"`, `"ranked"`, `"heatmap"`, `"abs_t_hist"`, or
  `"facet_profile"`.

- bias_results:

  Output from `estimate_bias()`.

- min_count_warn:

  Minimum count threshold for flagging sparse bias cells.

- branch:

  Output branch: `"facets"` keeps legacy manual-aligned naming,
  `"original"` returns compact QC-oriented names.

## Value

An `mfrm_bias` list with `table`, `summary`, `chi_sq`,
`interaction_facets`, `iteration`, `orientation_review`, `mixed_sign`,
`direction_note`, `recommended_action`, `inference_tier`, and
`optimization_failures`.

A tibble with one row per interaction cell. Returns an empty tibble when
the fit has no model-estimated facet interactions. With
`comparison_review`, one row per requested contrast with availability,
numerical and readiness fields; attributes `comparison_review`,
`fit_checks` and `notes` preserve the prospective question, source
fingerprint and numerical evidence, and interpretation limits.

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_bias` with:

- `overview`: interaction facets/order, cell counts, and effect-size
  profile

- `chi_sq`: fixed-effect chi-square block

- `final_iteration`: end-of-iteration status row

- `top_rows`: highest-`|t|` interaction rows

- `notes`: short interpretation notes

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object carrying view-specific tables, retained screening
rules and interpretation notes accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
Plot agreement across views is not independent evidence of bias. Use
`plot_data(p, "notes")` for the interaction definition, score-direction
caveat, magnitude-only facet-profile interpretation and conditional
uncertainty qualifications outside the figure.

A named list with:

- `table`: cell-level counts with low-count flags

- `by_facet`: named list of counts aggregated by each interaction facet

- `by_facet_a`, `by_facet_b`: first two facet summaries (legacy
  compatibility)

- `summary`: one-row summary

- `thresholds`: applied thresholds

- `branch`, `style`: output branch metadata

- `fit_overview`: optional one-row fit metadata when `fit` is supplied

## Details

For additive predictor \\\eta\_{njc} = \theta_n - \delta_j - \beta_c +
b\_{jc}\\, interior solutions solve \\\sum_n w\_{njc}\\X\_{njc} -
E\_{njc}(b\_{jc})\\ = 0\\ with conditional SE \\\[\sum_n
w\_{njc}\mathrm{Var}\_{njc}(\hat b)\]^{-1/2}\\ (including slope factors
and conditional LR/profile columns in one-family GPCM). Screening `t`
tails use continuous Student `df = weighted_count - 1`
(`ProbabilityStatus`, `ScreenStatus`); calibration uncertainty is not
propagated.

mfrmr supports two-way interactions between non-person facets, for
example `facet_interactions = "Rater:Criterion"`. Each interaction
matrix is identified by zero marginal sums across both participating
facets, so the interaction estimates are separable from the two main
effects. Positive values indicate higher-than-expected scores for the
facet-level combination under the additive model; negative values
indicate lower-than-expected scores.

Use this table for confirmatory model review after specifying the facet
pair of substantive interest. For exploratory screening without adding
parameters to the fitted model, use `estimate_bias()` or
[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md).

With `comparison_review`, first fit the declared model using the
review's `fit_arguments` and the original ratings. The fit must match
the retained responses, origins, score coding, model, constraints, facet
orientation, step owner and population design. Only native, unadjusted
RSM/PCM fits without shrinkage are supported. The contrast is the
declared weighted sum of Group1-minus-Group2 interaction effects, in
logits. Positive means a relative shift toward higher coded scores; it
is not an absolute school effect or evidence of unfairness. Location and
step effects are not added.

This route reevaluates the retained likelihood and full gradient without
optimization. Objective agreement must be within `1e-6` and the gradient
sup norm within `max(1e-4, 10 * reltol)`, matching the ordinary
numerical stopping tolerance. For MML it also evaluates `2 * q + 1`
quadrature nodes, requiring the finer-grid gradient to meet that
tolerance and the absolute negative-log-likelihood change per Person to
be at most `1e-6`. These are numerical checks, not statistical precision
criteria. A failed check retains the row with `Estimate = NA` and an
explanation; the separate `OptimizerEstimate` is a diagnostic trace. No
refit or partial fit is run.

`EstimateStatus = "descriptive_only"` requires full conditional-map
rank, numerical convergence, current readiness information and no
recorded blocking condition or boundary exclusion. It does not certify
finite-MLE existence, global marginal identification or sampling
performance. MML retains `State = "not_evaluated"` for positive
conditional ranks even when a descriptive fitted contrast is available.
`BoundaryState`, `FitReadiness`, `NumericalState` and `QuadratureState`
remain separate. `SE`, `Lower`, `Upper` remain missing and
`FormalInferenceEligible` remains false. A target-only identified
contrast in a rejected full model remains unavailable through this
route. Save the returned table with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) to preserve its
review and checks without recalculation; CSV retains the visible columns
but not the attributes.

For a `mfrm_comparison_fit` created with `fit_scope = "comparisons"`,
omit `comparison_review`: the table already contains the declared
targets and their partial-fit checks. Extraction does not fit again. See
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)
for its likelihood-preserving parameterization, availability
requirements and limits. For full RSM/PCM MML fits,
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
with the same `comparison_review` separately supplies model-information
intervals and supported population-SD standardization; extraction here
stays descriptive. CML comparison fits add conditional-information SEs
and pointwise 95 percent Wald limits for identified targets, with
`conditional_wald` status; unidentified rows remain missing. The
ordinary full-fit route above remains unchanged.

[`summary()`](https://rdrr.io/r/base/summary.html) collects cell
availability, magnitudes and conditional screening results from a saved
bias analysis.

For [`summary()`](https://rdrr.io/r/base/summary.html): Read `overview`,
the conditional all-zero `chi_sq` screen and `final_iteration`;
`top_rows` ranks absolute t and retains GPCM profile columns when
present. These reuse the screening qualifications above, not a formal
bias test. Use
[mfrm_report_bias_interaction](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
for detailed review.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
saved bias-interaction results

Inspect the pattern of conditional interaction estimates from
`estimate_bias()`. Start with ranked interactions, then use other views
to understand the pattern.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):
Visualization front-end for
[mfrm_report_bias_interaction](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
with multiple views. With `draw = FALSE`, `plot_data(p)` includes
`plot_long`, `plot_annotations`, `flag_summary`, and `plot_settings` in
addition to the view-specific `ranked_table`, `scatter_data`,
`facet_profile`, and heatmap components. Use these fields when
rebuilding the same screening view in plotly, Quarto, or a dashboard.
Saved report thresholds determine flags, reference lines and returned
notes; recreate
[mfrm_report_bias_interaction](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
from the saved bias object to change them. Scatter views attach aligned
marginal histograms when `marginal = "auto"` (with \\n \ge 8\\) or
`"histogram"`. Conditional bounds and their status remain separate from
calibration-inclusive uncertainty.

This helper summarizes how many observations contribute to each
bias-cell estimate and flags sparse cells.

Branch behavior:

- `"facets"`: keeps legacy manual-aligned column labels (`Sq`,
  `Observd Count`, `Obs-Exp Average`, `Model S.E.`) for side-by-side
  comparison with external workflows.

- `"original"`: keeps compact field names (`Count`, `BiasSize`, `SE`)
  for custom QC workflows and scripting.

## References

- Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA Press.
  (FACETS Table 13 corresponds to the bias / interaction estimation that
  this helper implements.)

- Eckes, T. (2005). Examining rater effects in TestDaF writing and
  speaking performance assessments: A many-facet Rasch analysis.
  *Language Assessment Quarterly, 2*(3), 197-221.

- Eckes, T. (2015). *Introduction to many-facet Rasch measurement:
  Analyzing and evaluating rater-mediated assessments* (2nd ed.). Peter
  Lang.

- Myford, C. M., & Wolfe, E. W. (2003). Detecting and measuring rater
  effects using many-facet Rasch measurement: Part I. *Journal of
  Applied Measurement, 4*(4), 386-422.

- Myford, C. M., & Wolfe, E. W. (2004). Detecting and measuring rater
  effects using many-facet Rasch measurement: Part II. *Journal of
  Applied Measurement, 5*(2), 189-227.

## Controls

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

- `facet_a`, `facet_b`, or `interaction_facets` identify the
  interaction; `top_n = 40` and `sort_by = "abs_t"` (`"abs_bias"` or
  `"prob"` also accepted) select ranked interactions.

- `abs_t_warn = 2`, `abs_bias_warn = 0.5`, and `p_max = 0.05` set
  screening rules when preparing a report from the bias result. They are
  review aids, not guarantees of a calibrated error rate.

- `show_ci = FALSE` omits whiskers; `ci_level = 0.95` chooses their
  level for scatter/ranked views. GPCM rows retain conditional profile
  bounds, with dashed whiskers for search-limited or unverified bounds.
  Other rows use conditional per-cell SEs. Missing profile bounds are
  not replaced with another method. These intervals omit calibration
  uncertainty; endpoint completion is not evidence of coverage.

- `preset` selects `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`; `palette` overrides named colors (`normal`, `flag`,
  `hist`, `profile`); `label_angle` controls label rotation. `title`
  sets title metadata (`main` is a compatibility alias; supply only
  one).

## Plot types

- `"scatter"` (default):

  Observed-minus-expected score average (x) versus conditional bias size
  in logits (y). Points use the saved flag status; horizontal guides
  show the saved absolute-bias threshold and zero, with a vertical guide
  at zero score difference.

- `"ranked"`:

  Conditional bias size (x) for up to `top_n` saved ranked interactions
  (y). Points are colored by flag status; optional whiskers retain the
  conditional uncertainty and incomplete-bound status. A saved report
  retains the ranking chosen when it was constructed.

- `"heatmap"`:

  Facet A by facet B matrix of signed bias size. Cells retain reusable
  matrix and flag tables for dashboards. This is a Table 13 follow-up
  display: it supports pattern recognition but does not turn screening
  rows into confirmatory tests.

- `"abs_t_hist"`:

  Histogram of absolute screening t-statistics across all interaction
  cells. Dashed reference line at `abs_t_warn`. Use for assessing the
  overall distribution of interaction effect sizes.

- `"facet_profile"`:

  Per-facet-level aggregation showing mean absolute bias and flag rate.
  Useful for identifying which individual facet levels drive systematic
  interaction patterns.

## Reading bias plots

Use scatter/ranked views to locate cells, then histogram/facet profiles
for pattern summaries. They reuse the same estimates and flags, not
independent evidence. Review exposure, calibration uncertainty and
substantive explanations.

## Interpreting output

- `table`: cell-level contribution counts and low-count flags.

- `by_facet`: sparse-cell structure by each interaction facet.

- `summary`: overall low-count prevalence.

- `fit_overview`: optional run context (when `fit` is supplied).

Low-count cells should be interpreted cautiously because bias-size
estimates can become unstable with sparse support.

## Typical workflow

1.  Estimate bias with `estimate_bias()`.

2.  Build `bias_count_table(...)` in desired branch.

3.  Review low-count flags before interpreting bias magnitudes.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## Output columns

The `table` data.frame contains, in the legacy-compatible branch:

- FacetA, FacetB:

  Interaction facet level identifiers; generic names for the two
  interaction facets.

- Sq:

  Sequential row number.

- Observd Count:

  Number of observations for this cell.

- Obs-Exp Average:

  Observed minus expected average for this cell.

- Model S.E.:

  Standard error of the bias estimate.

- Infit, Outfit:

  Fit statistics for this cell.

- LowCountFlag:

  Logical; `TRUE` when count \< `min_count_warn`.

The `summary` data.frame contains:

- InteractionFacets:

  Names of the interaction facets.

- Cells, TotalCount:

  Number of cells and total observations.

- LowCountCells, LowCountPercent:

  Number and share of low-count cells.

## See also

[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md),
`interaction_effect_table()`,
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
`estimate_bias()`,
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)

[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
with `interaction` for supported fixed-population RSM/PCM MML cell
intervals from full joint information.

`estimate_bias()`,
[mfrm_report_bias_interaction](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)

`estimate_bias()`,
[mfrm_report_bias_interaction](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

`estimate_bias()`,
[`unexpected_after_bias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("estimate_bias", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_bias.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "bias-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
s_bias <- summary(bias)
s_bias$overview
# This example uses the default RSM, so Bias Size is also in logit units.
# `Significant` counts cells crossing the screening rule, not proven bias.
# The `BonferroniSignificant` /
#   `HolmSignificant` columns count cells that survive multiple-
#   testing adjustment to screening tail areas. Zero flags do not
#   establish absence of bias or equivalence.
s_bias$top_rows
# An illustrative review rule is |t| > 2 and |Bias Size| > 0.5 logits.
# Choose the effect threshold substantively; these cutoffs do not
#   establish statistical reliability;
#   inspect cell counts, uncertainty and substantive consequences.
p_bias <- plot(bias, type = "bias", draw = FALSE)
plot_data(p_bias, "plot")
# Optional finite reporting for extreme cells; this does not refit calibration
extreme_bias <- estimate_bias(fit, diag, "Rater", "Criterion", xtreme = .5)
head(extreme_bias$table[, c("Bias Size", "PrimaryBias", "BiasStatus", "SEBasis")])

} # }
# Optional workflow; run the example explicitly as shown below.
# example("interaction_effect_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(
  toy, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", method = "MML", model = "RSM",
  facet_interactions = "Rater:Criterion",
  quad_points = 7, maxit = 30
)
head(interaction_effect_table(fit))
} # }
# Optional workflow; run the example explicitly as shown below.
# example("summary.mfrm_bias", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_bias")
toy <- toy[toy$Person %in% unique(toy$Person)[1:8], ]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 1)
summary(bias)
} # }
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_bias", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_bias.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "bias-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diagnostics <- example_fit$diagnostics
bias <- estimate_bias(fit, diagnostics = diagnostics,
  facet_a = "Rater", facet_b = "Criterion")
p <- plot(bias, type = "ranked", preset = "publication", draw = FALSE)
head(plot_data(p, "ranked_table"))
} # }
# Optional workflow; run the example explicitly as shown below.
# example("bias_count_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_bias.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "bias-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
t11 <- bias_count_table(bias)
t11_facets <- bias_count_table(bias, branch = "facets", fit = fit)
summary(t11)
p <- plot(t11, draw = FALSE)
p2 <- plot(t11, type = "lowcount_by_facet", draw = FALSE)
if (interactive()) {
  plot(
    t11,
    type = "cell_counts",
    draw = TRUE,
    main = "Bias Cell Counts (Customized)",
    palette = c(count = "#2b8cbe", low = "#cb181d"),
    label_angle = 45
  )
}
} # }
```
