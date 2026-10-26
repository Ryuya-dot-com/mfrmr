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
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
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

## Details

This helper supports `RSM`, `PCM`, and one-slope-family `GPCM` fits.
Two-slope-family `GPCM` fits are not currently supported. It estimates
an additional cell shift relative to the fitted baseline, holding that
baseline fixed. For joint estimation of main effects and a two-facet
interaction in `RSM` / `PCM`, use the `facet_interactions` argument of
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
For the supported fixed-population RSM/PCM MML route,
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
with `interaction = "FacetA:FacetB"` returns joint-information cell
intervals. They estimate a different target and do not replace or
relabel this fixed-baseline screening result.

**Bias (interaction) in an additive MFRM** refers to a systematic
departure from the main-effects model: a specific rater-criterion (or
higher-order) combination produces scores that are consistently higher
or lower than predicted by the main effects alone. For example, Rater A
might be unexpectedly harsh on Criterion 2 despite being lenient
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
[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md).
Adjustment does not validate the underlying plug-in tail areas or
establish formal family-wise error control.

`iteration` records changes between repeated estimates of the same
conditional cell problems. These passes do not refit person or facet
parameters, and increasing `max_iter` does not turn this screen into a
jointly fitted interaction model.

## Typical workflow

1.  Fit and diagnose model.

2.  Run `estimate_bias(...)` for target interaction facets.

3.  Review `summary(bias)` and `bias$table`.

4.  Visualize/report via [plot(x, type =
    "bias")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
    and
    [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md).

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
"bias")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
to inspect the flagged cells visually, then integrate the result with
DFF, linking, or substantive scoring review before making formal claims
about fairness or invariance. Save the `mfrm_bias` object for repeat
use.
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
adds explicit screening rules without refitting; plotting the saved
report keeps those rules.
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
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
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
for migration instructions.

## See also

[`interaction_effect_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interaction_effect_table.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)

## Examples

``` r
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
s_bias <- summary(bias)
s_bias$overview
#> # A tibble: 1 × 22
#>   FacetPair        InteractionOrder InteractionMode Cells Points ScreenAvailable
#>   <chr>                       <int> <chr>           <int>  <int>           <int>
#> 1 Rater x Criteri…                2 pairwise           16     16              16
#> # ℹ 16 more variables: ScreenUnavailable <int>, MeanAbsBias <dbl>,
#> #   MaxAbsBias <dbl>, ScreenPositive <int>, ScreeningCut <dbl>,
#> #   BonferroniScreenPositive <int>, HolmScreenPositive <int>,
#> #   SupportsFormalInference <lgl>, FormalInferenceEligible <lgl>,
#> #   PrimaryReportingEligible <lgl>, ClassificationSystem <chr>,
#> #   ReportingUse <chr>, Significant <int>, SignificantCut <dbl>,
#> #   BonferroniSignificant <int>, HolmSignificant <int>
# This example uses the default RSM, so Bias Size is also in logit units.
# `Significant` counts cells crossing the screening rule, not proven bias.
# The `BonferroniSignificant` /
#   `HolmSignificant` columns count cells that survive multiple-
#   testing adjustment to screening tail areas. Zero flags do not
#   establish absence of bias or equivalence.
s_bias$top_rows
#> # A tibble: 10 × 19
#>    Pair       Rater Criterion `Bias Size`  S.E.      t   Prob. `Obs-Exp Average`
#>    <chr>      <chr> <chr>           <dbl> <dbl>  <dbl>   <dbl>             <dbl>
#>  1 R04 | Acc… R04   Accuracy       -1.10  0.333 -3.31  0.00306           -0.469 
#>  2 R01 | Acc… R01   Accuracy        0.777 0.308  2.52  0.0191             0.371 
#>  3 R04 | Org… R04   Organiza…       0.683 0.300  2.28  0.0321             0.326 
#>  4 R01 | Org… R01   Organiza…      -0.362 0.293 -1.23  0.229             -0.169 
#>  5 R03 | Org… R03   Organiza…      -0.313 0.296 -1.06  0.301             -0.146 
#>  6 R01 | Con… R01   Content        -0.277 0.301 -0.921 0.367             -0.123 
#>  7 R02 | Acc… R02   Accuracy        0.247 0.288  0.857 0.401              0.124 
#>  8 R04 | Lan… R04   Language        0.234 0.297  0.788 0.439              0.112 
#>  9 R03 | Con… R03   Content         0.247 0.315  0.783 0.442              0.106 
#> 10 R02 | Lan… R02   Language       -0.208 0.294 -0.709 0.485             -0.0992
#> # ℹ 11 more variables: d.f. <dbl>, DFUnrounded <dbl>,
#> #   ProbabilityReference <chr>, ProbabilityStatus <chr>,
#> #   ProbabilityReason <chr>, BiasStatus <chr>, ScreenStatus <chr>,
#> #   ScreenReason <chr>, FitStatus <chr>, FitReason <chr>, AbsT <dbl>
# An illustrative review rule is |t| > 2 and |Bias Size| > 0.5 logits.
# Choose the effect threshold substantively; these cutoffs do not
#   establish statistical reliability;
#   inspect cell counts, uncertainty and substantive consequences.
p_bias <- plot(bias, type = "bias", draw = FALSE)
p_bias$data$plot
#> [1] "scatter"
# Optional finite reporting for extreme cells; this does not refit calibration
extreme_bias <- estimate_bias(fit, diag, "Rater", "Criterion", xtreme = .5)
head(extreme_bias$table[, c("Bias Size", "PrimaryBias", "BiasStatus", "SEBasis")])
#> # A tibble: 6 × 4
#>   `Bias Size` PrimaryBias BiasStatus SEBasis                        
#>         <dbl>       <dbl> <chr>      <chr>                          
#> 1      0.777       0.777  interior   conditional plug-in information
#> 2     -0.277      -0.277  interior   conditional plug-in information
#> 3     -0.184      -0.184  interior   conditional plug-in information
#> 4     -0.362      -0.362  interior   conditional plug-in information
#> 5      0.247       0.247  interior   conditional plug-in information
#> 6     -0.0297     -0.0297 interior   conditional plug-in information
```
