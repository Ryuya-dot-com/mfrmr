# Estimate bias and interaction screening terms

Estimate bias and interaction screening terms

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

# S3 method for class 'mfrm_bias'
summary(object, digits = 3, top_n = 10, p_cut = 0.05, ...)

# S3 method for class 'mfrm_bias'
plot(
  x,
  type = c("scatter", "ranked", "heatmap", "abs_t_hist", "facet_profile"),
  ...
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).
  Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_compatibility_layer.md)
  for migration of saved diagnostics.

- facet_a:

  First facet name. Provide together with `facet_b` for the classic
  pairwise 2-way interaction. Ignored when `interaction_facets` is
  supplied. The canonical `"Person"` role is accepted explicitly.

- facet_b:

  Second facet name. See `facet_a`.

- interaction_facets:

  Character vector of two or more facets to model as one interaction
  effect. When supplied, this takes precedence over `facet_a`/`facet_b`.
  Use this form (rather than `facet_a`/`facet_b`) whenever you want 3+
  way interactions, since `facet_a/facet_b` is restricted to the
  pairwise case. The canonical `"Person"` role may be supplied
  explicitly; see the Person-screening boundary below.

- max_abs:

  Bound for absolute bias size.

- omit_extreme:

  Omit extreme-only elements. In ordinary additive RSM/PCM JML, directly
  fixed finite anchors are retained even with all-low/all-high
  responses. Their cell bias may still have no finite unconstrained
  optimum.

- max_iter:

  Maximum number of repeated cell-estimation passes recorded in
  `iteration`; the baseline calibration stays fixed throughout.

- tol:

  Between-pass change tolerance for the iteration log. This does not
  control the tolerance of the bounded scalar likelihood optimizer.

- xtreme:

  Default `0` retains bounded extreme-cell estimates with SEs withheld.
  A positive correction (usually `.5` for FACETS bias reporting)
  requests finite total-score extrapolation for ordinary additive
  RSM/PCM JML without group-mean anchors; it must be smaller than the
  score range.

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

## Value

An object of class `mfrm_bias` with:

- `table`: interaction rows with effect size, SE, screening t/p
  metadata, reporting-use flags, fit columns, and `GPCM`
  profile-likelihood columns when available

- `summary`: compact summary statistics

- `chi_sq`: fixed-effect chi-square style screening summary

- `facet_a`, `facet_b`: first two analyzed facet names (legacy
  compatibility)

- `interaction_facets`, `interaction_order`, `interaction_mode`: full
  interaction metadata

- `person_interaction`, `person_source_column`,
  `person_interaction_note`: Person-screening provenance and
  interpretation metadata

- `iteration`: iteration history/metadata

- `orientation_review`: facet-orientation sign-consistency review table

- `mixed_sign`: logical flag indicating whether bias-size signs flip
  across facets in a way that complicates direction interpretation

- `direction_note`: one-line interpretive note describing the dominant
  bias direction (empty when not applicable)

- `recommended_action`: one-line recommended-action label routing the
  user to the appropriate follow-up helper

- `inference_tier`: summary label indicating that the bias rows are
  intended for screening and follow-up review

- `optimization_failures`: per-cell record of any inner-loop optimizer
  failures encountered while estimating the bias parameters; empty when
  every cell converged cleanly

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
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).
Plot agreement across views is not independent evidence of bias. Use
`plot_data(p, "notes")` for the interaction definition, score-direction
caveat, magnitude-only facet-profile interpretation and conditional
uncertainty qualifications outside the figure.

## Details

This helper supports `RSM`, `PCM`, and one-slope-family `GPCM` fits.
Two-slope-family `GPCM` fits are not currently supported. It estimates
an additional cell shift relative to the fitted baseline, holding that
baseline fixed. For joint estimation of main effects and a two-facet
interaction in `RSM` / `PCM`, use the `facet_interactions` argument of
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).
For the supported fixed-population RSM/PCM MML route,
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_facet_intervals.md)
with `interaction = "FacetA:FacetB"` returns joint-information cell
intervals. They estimate a different target and do not replace or
relabel this fixed-baseline screening result.

**Bias (interaction) in an additive MFRM** refers to a systematic
departure from the main-effects model: a specific rater-criterion (or
higher-order) combination produces scores that are consistently higher
or lower than predicted by the main effects alone. For example, Rater A
might be unexpectedly severe on Criterion 2 despite being lenient
overall.

Mathematically, the bias term \\b\_{jc}\\ for rater \\j\\ on criterion
\\c\\ modifies the linear predictor:

\$\$\eta\_{njc} = \theta_n - \delta_j - \beta_c + b\_{jc}\$\$

Here the example uses negatively oriented rater and criterion facets.
The returned `Bias Size` is always an additive shift in the score
predictor: positive values increase expected scores; negative values
decrease them. If the fitted model already contains
`facet_interactions`, those fitted interactions remain part of the fixed
baseline. The new shift is a residual departure from that model, not a
re-estimate of its interaction. Each cell's shift is estimated by
maximizing its conditional likelihood within `[-max_abs, max_abs]`,
holding fitted person measures, facet values, steps and slopes fixed.
For `RSM` / `PCM`, an interior solution satisfies the weighted score
equation:

\$\$\sum_n w\_{njc} \\X\_{njc} - E\_{njc}(b\_{jc})\\ = 0.\$\$

With unit weights, \\w\_{njc}=1\\. The conditional information gives
\\\mathrm{SE}(\hat b) = \[\sum_n w\_{njc} \mathrm{Var}\_{njc}(\hat
b)\]^{-1/2}\\. For `GPCM`, the score and information include the
observation's slope and squared slope, respectively, and conditional
profile-likelihood columns are also returned. `Bias Size` is in the
model's native ability units: in `RSM` / `PCM` it equals the change in
adjacent-category log odds, whereas in `GPCM` that change is \\a b\\ for
an observation with slope \\a\\. The same bias value can therefore imply
different probability changes across observations. All these quantities
are plug-in screening evidence: JML person measures or MML EAP scores
and the calibration parameters are treated as known. Their estimation
uncertainty, including uncertainty in supplied anchors, is not
propagated. A fixed rater severity can therefore have a nonzero cell
bias and positive bias SE: the fixed severity and the cell's additional
shift are different quantities. `BiasStatus` identifies an interior
solution or an optimum at either search bound. A bounded point remains
available, but its `S.E.`, `t`, `Prob.` and GPCM profile-inference
columns are withheld at a boundary. Inspect `ScreenStatus` and
`ScreenReason`: a bound can mean an insufficient search range or an
all-low/all-high cell with no finite unconstrained optimum. Increasing
the range does not resolve the latter.

With `xtreme > 0`, an all-low/all-high cell's weighted total is moved
inward by `xtreme` times its smallest positive weight. A root strictly
inside `[-max_abs, max_abs]` yields `BiasStatus = "extreme_adjusted"`,
finite `Bias Size` and conditional information SE; `PrimaryBias` retains
the infinite cell MLE and `ExtremeAdjustment` records the total
correction. Otherwise the boundary remains unavailable for screening.
Observations involving any unanchored extreme main-effect element are
excluded in this route even when `omit_extreme = FALSE`; finite fixed
anchors remain usable. This prevents main-effect display replacements
from becoming calibration. The default `xtreme = 0` also retains
directly fixed finite anchors in ordinary additive RSM/PCM JML; extreme
cells then keep bounded points with screening SEs and tail areas
withheld. Group-mean constraints are not direct anchors. The native
FACETS `Xtreme = main,bias` has two separate corrections: this
function's `xtreme` corresponds to the second value (normally `.5`), not
the first (normally `.3`). Executed FACETS 4.5.0 Person-by-Rater
examples retain fixed extreme Persons and agree with the conditional
cell calculation on the same main calibration. This does not establish
main-calibration parity. If a low cell's baseline expectation is already
below the inward correction, its adjusted bias can be positive despite a
negative observed-minus-expected score difference (and conversely at the
upper endpoint). Inspect `PrimaryBias`, `ExtremeAdjustment` and
`Obs-Exp Average` together; the adjusted sign describes the amended
total, not a reversal of the observed departure. Extrapolated tail
areas, summaries and pairwise contrasts are reporting conventions, not
regular-MLE inference, coverage guarantees or fairness tests.

`ConditionalInformation` uses every cell row, including small positive
conditional variances; the residual-screening cutoff does not remove
their information. Incomplete/nonpositive information withholds the SE
and screening statistic while retaining a computed point. Infit/Outfit
retain the legacy variance cutoff (`1e-10`) and require all contributing
rows; `FitResponseRows`, `FitAvailableRows`, `FitUnavailableRows`,
`FitStatus` and `FitReason` explain withheld complete-cell fit
summaries.

- For two-way mode, use `facet_a` and `facet_b` (or `interaction_facets`
  with length 2).

- For higher-order mode, provide `interaction_facets` with length \>= 3.

- A Person-involving result is a conditional plug-in likelihood screen.
  It holds fitted JML person measures or MML EAP scores and the other
  fitted parameters fixed; it is not a jointly fitted Person-by-facet
  interaction and does not support formal inference or a cell-level
  fairness decision. The function emits a classed warning when
  `"Person"` is requested.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize an
`mfrm_bias` object in a user-friendly format

For [`summary()`](https://rdrr.io/r/base/summary.html): This method
returns a compact interaction-bias summary:

- interaction facets/order and analyzed cell counts

- effect-size profile (`|bias|` mean/max, screen-positive cell count)

- fixed-effect chi-square block

- iteration-end convergence indicators

- top rows ranked by absolute t

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
saved bias-interaction results

Inspect the pattern of conditional interaction estimates from
`estimate_bias()`. Start with ranked interactions, then use other views
to understand the pattern.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):
Visualization front-end for
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_interaction_report.md)
with multiple views. With `draw = FALSE`, `plot_data(p)` includes
`plot_long`, `plot_annotations`, `flag_summary`, and `plot_settings` in
addition to the view-specific `ranked_table`, `scatter_data`,
`facet_profile`, and heatmap components. Use these fields when
rebuilding the same screening view in plotly, Quarto, or a dashboard.
Saved report thresholds determine flags, reference lines and returned
notes; recreate
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_interaction_report.md)
from the saved bias object to change them. Scatter views attach aligned
marginal histograms when `marginal = "auto"` (with \\n \ge 8\\) or
`"histogram"`. Conditional bounds and their status remain separate from
calibration-inclusive uncertainty.

## What this screening means

`estimate_bias()` summarizes additional cell departures from the fitted
MFRM. It is best read as a targeted screening tool for potentially
noteworthy cells or facet combinations that may merit substantive
review.

## What this screening does not justify

- `t` and `Prob.` are screening metrics, not formal inferential
  quantities.

- A flagged interaction cell is not, by itself, proof of rater bias or
  construct-irrelevant variance.

- Non-flagged cells should not be over-read as evidence that interaction
  effects are absent.

## Interpreting output

Use `summary` for global magnitude, then inspect `table` for cell-level
interaction effects.

Prioritize rows with:

- larger `|Bias Size|`, assessed against a substantively chosen
  threshold in native ability units and its effect on expected scores,
  rather than a universal small/large-effect rule

- larger `|t|` among the screening metrics (the default review rule is
  \\\|t\| \ge 2\\, not a validated fairness decision)

- smaller `Prob.` among the screening metrics

Use `Bias Size` for the direction of the departure from the baseline
model. `Expctd Score` and `Obs-Exp Average` use the main-analysis
expectations, before adding the cell shift. `AfterBiasExpectedScore` and
`AfterBiasObsExpAverage` retain the remaining discrepancy after fitting
it. Cell t reference df uses weighted count minus 1. This matches the
executed FACETS 4.5.0 equal-count binary example; a manual count-minus-2
description is a distinct convention and does not establish version-wide
equivalence. `DFUnrounded` retains count minus one, including
nonpositive values. A nonpositive value withholds `d.f.`, `DFDisplay`
and `Prob.`; a finite point and conditional information SE can remain
available. For positive df, `DFDisplay` rounds to the nearest integer
(halves upward) for RSM/PCM display comparison only. `d.f.` and `Prob.`
use the continuous reference. `ProbabilityReference`,
`ProbabilityStatus` and `ProbabilityReason` identify the reference
distribution and distinguish available conditional or extreme-adjusted
tails from unavailable df, statistics or numerical results. These fields
describe `Prob.`, not the separate GPCM likelihood-ratio tail.

Checked FACETS 4.5.0 fractional-count tails are reproduced by extending
an integer-df finite-sum formula to fractional df. That extension is not
the continuous-df Student distribution and can change a 0.05 screening
flag. mfrmr retains the continuous Student tail, independently checked
by density integration. This explains the checked output behavior
without claiming access to the executable's implementation or general
finite-sample validity. The all-zero `chi_sq` screen sums squared
bias/SE ratios without centering; its df is the number of cells. It
requires at least two cells and complete cell estimates and SEs.
Otherwise its statistic, degrees of freedom and tail area are missing,
with available-cell counts and a reason.

[`summary()`](https://rdrr.io/r/base/summary.html) reports available and
unavailable screening tail-area counts. With none available,
screen-positive counts are `NA`, not zero. Bonferroni/Holm summaries use
the full number of retained cells in this interaction, including
unavailable cells; they do not include omitted or unobserved cells or
other interactions from
[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_all_bias.md).
Adjustment does not validate the underlying plug-in tail areas or
establish formal family-wise error control.

`iteration` records changes between repeated estimates of the same
conditional cell problems. These passes do not refit person or facet
parameters, and increasing `max_iter` does not turn this screen into a
jointly fitted interaction model.

For [`summary()`](https://rdrr.io/r/base/summary.html):

- `overview`: interaction order, analyzed cells, and effect-size
  profile.

- `chi_sq`: fixed-effect test block.

- `final_iteration`: end-of-loop status from the bias routine.

- `top_rows`: strongest bias contrasts by `|t|`; `GPCM` summaries also
  retain the profile-likelihood review columns when present.

Start with `"scatter"` or `"ranked"` for triage, then confirm pattern
shape using `"abs_t_hist"` and `"facet_profile"`.

These views reuse the same estimates and flags. Agreement between views
is not independent corroborating evidence of bias. Review exposure,
calibration uncertainty and substantive explanations before drawing
conclusions about a rater.

## Typical workflow

1.  Fit and diagnose model.

2.  Run `estimate_bias(...)` for target interaction facets.

3.  Review `summary(bias)` and `bias$table`.

4.  Visualize/report via [plot(x, type =
    "bias")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)
    and
    [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_fixed_reports.md).

For [`summary()`](https://rdrr.io/r/base/summary.html):

1.  Estimate interactions with `estimate_bias()`.

2.  Check `summary(bias)` for screen-positive and unstable cells.

3.  Use
    [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_interaction_report.md)
    or [plot(x, type =
    "bias")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)
    for details.

## Interpreting key output columns

In `bias$table`, the most-used columns are:

- `Bias Size`: estimated additional cell shift \\b\_{jc}\\ in native
  ability units; in `GPCM`, adjacent log odds change by \\a b\_{jc}\\

- `t` and `Prob.`: screening metrics, not formal inferential quantities

- `S.E.`: conditional information-based SE of the cell shift, with the
  calibration held fixed

- `Obs-Exp Average`: observed-minus-baseline-expected average on the
  raw-score metric

- for `GPCM`, `LR ChiSq`, `LR Prob.`, and `Profile CI Lower` /
  `Profile CI Upper`: conditional profile-likelihood checks for a single
  additive bias shift, holding the fitted person, facet, step, and slope
  estimates fixed. Calibration uncertainty is not propagated. Check
  `Profile CI Status`: `limited by search range` marks a retained search
  limit, not a computed likelihood-ratio endpoint. These are screening
  approximations, not formal fairness tests.

The `chi_sq` element screens whether all interaction cells equal zero,
using diagonal conditional SEs. It is not a full covariance test.
Recreate older bias results with current diagnostics and
`estimate_bias()`; saved old expected-score and chi-square definitions
are not relabeled.

## Recommended next step

Use [plot(x, type =
"bias")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)
to inspect the flagged cells visually, then integrate the result with
DFF, linking, or substantive scoring review before making formal claims
about fairness or invariance. Save the `mfrm_bias` object for repeat
use.
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_interaction_report.md)
adds explicit screening rules without refitting; plotting the saved
report keeps those rules.
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_results.md)
has a separate bias-screen collection route; saving a standalone bias
result does not automatically attach it there.

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

## Saved-result reuse

The returned `fit_identity` records the fitted analysis for reuse with
reports and exports. Recreate older results from the saved fit and
matching diagnostics using the original screening options; no model
refit is needed. See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_compatibility_layer.md)
for migration instructions.

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

## See also

[`interaction_effect_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interaction_effect_table.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_fixed_reports.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_apa_outputs.md)

`estimate_bias()`,
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_interaction_report.md)

`estimate_bias()`,
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_interaction_report.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
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
p_bias$data$plot
# Optional finite reporting for extreme cells; this does not refit calibration
extreme_bias <- estimate_bias(fit, diag, "Rater", "Criterion", xtreme = .5)
head(extreme_bias$table[, c("Bias Size", "PrimaryBias", "BiasStatus", "SEBasis")])

} # }
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("summary.mfrm_bias", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_bias")
toy <- toy[toy$Person %in% unique(toy$Person)[1:8], ]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 1)
summary(bias)
} # }
# Supplementary workflow: run explicitly to keep routine checks brief.
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
```
