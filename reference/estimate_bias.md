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
  tol = 0.001
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

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

  Omit extreme-only elements.

- max_iter:

  Iteration cap.

- tol:

  Convergence tolerance.

## Value

An object of class `mfrm_bias` with:

- `table`: interaction rows with effect size, SE, screening t/p
  metadata, reporting-use flags, fit columns, and bounded-`GPCM`
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

**Bias (interaction) in MFRM** refers to a systematic departure from the
additive model: a specific rater-criterion (or higher-order) combination
produces scores that are consistently higher or lower than predicted by
the main effects alone. For example, Rater A might be unexpectedly harsh
on Criterion 2 despite being lenient overall.

Mathematically, the bias term \\b\_{jc}\\ for rater \\j\\ on criterion
\\c\\ modifies the linear predictor:

\$\$\eta\_{njc} = \theta_n - \delta_j - \beta_c - b\_{jc}\$\$

For `RSM` / `PCM`, the function estimates \\b\_{jc}\\ from the residuals
of the fitted additive model using an iterative recalibration screen
aligned with the many-facet bias literature (Myford & Wolfe, 2003,
2004):

\$\$b\_{jc} = \frac{\sum_n (X\_{njc} - E\_{njc})} {\sum_n
\mathrm{Var}\_{njc}}\$\$

Each iteration updates expected scores using the current bias estimates,
then re-computes the bias. Convergence is reached when the maximum
absolute change in bias estimates falls below `tol`. For bounded `GPCM`,
the same additive-bias idea is evaluated with the slope-aware GPCM
kernel and conditional profile-likelihood follow-up columns; those
quantities remain screening evidence because theta, facet, step, and
slope estimates are held fixed.

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

`estimate_bias()` summarizes interaction departures from the additive
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

- larger `|Bias Size|` (effect on logit scale; \\\> 0.5\\ logits is
  typically noteworthy, \\\> 1.0\\ is large)

- larger `|t|` among the screening metrics (\\\|t\| \ge 2\\ suggests a
  screen-positive interaction cell)

- smaller `Prob.` among the screening metrics

A positive `Obs-Exp Average` means the cell produced *higher* scores
than the additive model predicts (unexpected leniency); negative means
unexpected harshness.

`iteration` helps verify whether iterative recalibration stabilized. If
the maximum change on the final iteration is still above `tol`, consider
increasing `max_iter`.

## Typical workflow

1.  Fit and diagnose model.

2.  Run `estimate_bias(...)` for target interaction facets.

3.  Review `summary(bias)` and `bias$table`.

4.  Visualize/report via
    [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)
    and
    [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md).

## Interpreting key output columns

In `bias$table`, the most-used columns are:

- `Bias Size`: estimated interaction effect \\b\_{jc}\\ (logit scale)

- `t` and `Prob.`: screening metrics, not formal inferential quantities

- `Obs-Exp Average`: direction and practical size of
  observed-vs-expected gap on the raw-score metric

- for bounded `GPCM`, `LR ChiSq`, `LR Prob.`, and `Profile CI Lower` /
  `Profile CI Upper`: conditional profile-likelihood checks for a single
  additive bias shift, holding the fitted person, facet, step, and slope
  estimates fixed

The `chi_sq` element provides a fixed-effect heterogeneity screen across
all interaction cells.

## Recommended next step

Use
[`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)
to inspect the flagged cells visually, then integrate the result with
DFF, linking, or substantive scoring review before making formal claims
about fairness or invariance.

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

## See also

[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
s_bias <- summary(bias)
s_bias$overview
#> # A tibble: 1 × 19
#>   FacetPair        InteractionOrder InteractionMode Cells MeanAbsBias MaxAbsBias
#>   <chr>                       <int> <chr>           <int>       <dbl>      <dbl>
#> 1 Rater x Criteri…                2 pairwise           16       0.310       1.10
#> # ℹ 13 more variables: ScreenPositive <int>, ScreeningCut <dbl>,
#> #   BonferroniScreenPositive <int>, HolmScreenPositive <int>,
#> #   SupportsFormalInference <lgl>, FormalInferenceEligible <lgl>,
#> #   PrimaryReportingEligible <lgl>, ClassificationSystem <chr>,
#> #   ReportingUse <chr>, Significant <int>, SignificantCut <dbl>,
#> #   BonferroniSignificant <int>, HolmSignificant <int>
# Look for: `MaxAbsBias` < ~0.5 logits and `Significant = 0` mean
#   no cell exceeded the screen. The `BonferroniSignificant` /
#   `HolmSignificant` columns count cells that survive multiple-
#   testing correction; both being 0 is a stronger "no bias"
#   signal than the raw screen-positive count alone.
s_bias$top_rows
#> # A tibble: 10 × 9
#>    Pair       Rater Criterion `Bias Size`  S.E.      t   Prob. `Obs-Exp Average`
#>    <chr>      <chr> <chr>           <dbl> <dbl>  <dbl>   <dbl>             <dbl>
#>  1 R04 | Acc… R04   Accuracy       -1.10  0.333 -3.31  0.00306       0.00000109 
#>  2 R01 | Acc… R01   Accuracy        0.777 0.308  2.52  0.0191        0.00000218 
#>  3 R04 | Org… R04   Organiza…       0.683 0.299  2.28  0.0321        0.00000703 
#>  4 R01 | Org… R01   Organiza…      -0.362 0.293 -1.24  0.229        -0.000000172
#>  5 R03 | Org… R03   Organiza…      -0.313 0.296 -1.06  0.301         0.00000167 
#>  6 R01 | Con… R01   Content        -0.277 0.301 -0.921 0.367        -0.000000866
#>  7 R02 | Acc… R02   Accuracy        0.247 0.288  0.856 0.401         0.00000166 
#>  8 R04 | Lan… R04   Language        0.234 0.297  0.788 0.439        -0.00000794 
#>  9 R03 | Con… R03   Content         0.247 0.315  0.783 0.442         0.000000986
#> 10 R02 | Lan… R02   Language       -0.208 0.294 -0.709 0.485         0.00000302 
#> # ℹ 1 more variable: AbsT <dbl>
# Look for: rows with `|t|` > 2 and |Bias Size| > 0.5 logits warrant
#   review (large effect AND statistically reliable). Rows with only
#   one of those triggered are usually small-cell artefacts.
p_bias <- plot_bias_interaction(bias, draw = FALSE)
p_bias$data$plot
#> [1] "scatter"

# }
```
