# Describe fitted response probabilities and residuals

Compute response means, variances and descriptive Infit/Outfit
summaries. Ordinary and extended RSMs and two-family GPCMs integrate
uncertain latent effects; corrected GPCM JML conditions on saved
calibration and reprofiled Person estimates.

## Usage

``` r
mfrm_response_diagnostics(
  fit,
  rows = NULL,
  group_by = NULL,
  quad_points = fit$settings$quad_points %||% fit$config$estimation_control$quad_points
)

# S3 method for class 'mfrm_response_diagnostics'
plot(
  x,
  facet = NULL,
  style = c("paired", "scatter"),
  draw = TRUE,
  palette = c("accessible", "mono"),
  title = NULL,
  caption = NULL,
  show_title = FALSE,
  show_notes = FALSE,
  show_labels = TRUE,
  text_scale = 1,
  point_size = 2.5,
  marginal = c("auto", "histogram", "none"),
  ...
)

# S3 method for class 'mfrm_response_diagnostics'
summary(object, ...)

# S3 method for class 'mfrm_response_diagnostics'
print(x, ...)
```

## Arguments

- fit:

  A numerically ready native RSM MML
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
  [`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm_testlet.md)
  or
  [`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm_random_rater.md)
  result, a converged two-family GPCM fixed-grid EM or adaptive direct
  MML fit, or a shared-owner GPCM fit with an explicit
  `jml_correction_order` and an available point solution.

- rows:

  Distinct original input row numbers to return, or `NULL` for all
  assigned rows. This selects outputs only: every observed source rating
  still informs the joint posterior or saved JML Person profile. Groups
  summarize the selected rows; selection does not refit the model.

- group_by:

  Fitted identifier columns to summarize separately. `NULL` uses all
  Person, testlet/rater and fixed-facet columns. No grouping by score.
  Corrected JML lists the fixed facets first, then Person, so the
  default plot shows the first declared facet.

- quad_points:

  Normal quadrature order, 7 to 121 for testlets or 7 to 241 for
  ordinary RSMs, two-family GPCMs or shared raters. Defaults to the
  saved fit's order. Results are checked at `2 * quad_points + 1`; each
  category probability must change by no more than `1e-7`. Omit this
  argument for corrected JML, which performs no integration.

- x:

  Saved `mfrm_response_diagnostics()` output.

  Also for [`summary()`](https://rdrr.io/r/base/summary.html): A saved
  response-diagnostics result.

- facet:

  One recorded grouping column; default is the first.

- style:

  `"paired"` connects each group's Infit and Outfit on a common axis.
  `"scatter"` plots Infit against Outfit; labels identify groups.

- draw:

  `FALSE` returns plot data without opening a device.

- palette:

  `"accessible"` uses blue circles and orange triangles; `"mono"`
  retains distinct symbols in black. No red/green warning scale.

- title, caption:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- show_title, show_notes:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_labels:

  Show group labels. Unavailable groups keep their labels in the paired
  view; both views retain all rows in
  [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).

- text_scale:

  Positive multiplier for text size.

- point_size:

  Positive point size in ggplot millimetres; base graphics use the
  corresponding relative size (2.5 is the default).

- marginal:

  Marginal histogram display for `style = "scatter"`: `"auto"` (default;
  shown when at least 8 finite pairs exist), `"histogram"`, or `"none"`.

- ...:

  For `summary.mfrm_response_diagnostics()`: Unused.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Unused;
  ordinary-model threshold arguments are not accepted.

- object:

  A saved response-diagnostics result.

## Value

An `mfrm_response_diagnostics` object with `rows`, category
`probabilities`, grouped `measures`, settings and exact source metadata.
Save with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html); attach via
`mfrm_results(fit, response_diagnostics = result, compute = "never")`.
The resulting `mfrm_results` object contains `tables$response_overview`,
distinguishing available standardized residuals, unresolved
calculations, missing scores, zero-variance rows and source rows not
selected. Partial results require review; availability does not
establish model adequacy. No probabilities or residuals are recomputed
for this table. Older saved `mfrm_results` objects without this table
recover the overview and status from retained diagnostic rows when
summarized, reported, exported or opened in a supported results viewer.
The original object is not modified; newly exported results include the
recovered overview and status. Supply two saved outputs to
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/compare_mfrm.md)
for aligned ordinary versus extended RSM comparisons, using the same
selected events and group_by. Corrected-JML and two-family GPCM
comparisons are not supported by that route. Collecting, plotting and
exporting saved results never recomputes integrals.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
extracts selected measures, display settings, notes and alternative
text.

## Details

Calibration is held fixed. For a posterior replicate rating sharing the
original row's latent effects, the target is
\$\$p\_{ik}=E\[P(Y_i^{rep}=k\mid b,\widehat\psi)\mid
Y\_{obs},\widehat\psi\],\$\$ where b includes ability, and for
extensions the local effect or jointly uncertain shared-rater vector.
This uses the same observed data for estimation and checking; it is not
held-out prediction. Define \$\$\mu_i=\sum_k k p\_{ik},\qquad V_i=\sum_k
(k-\mu_i)^2p\_{ik}.\$\$ For these posterior calculations, the mixture
variance includes conditional rating variance and variance of
conditional means. Substituting an ability/rater estimate or averaging
conditional variances alone gives a different quantity.

For selected observed unit-weight rows in a group, descriptive Outfit is
the mean of \\(y_i-\mu_i)^2/V_i\\; descriptive Infit is
\\\sum_i(y_i-\mu_i)^2/\sum_i V_i\\. These summaries have no established
expectation of one. There are no default cutoffs, ZSTD, p-values,
automatic flags or rater-quality classifications. Ordinary plug-in
Infit/Outfit values do not have the same probability definition and must
not be compared directly. No response covariance or calibration
uncertainty is supplied, so these results do not calibrate a formal
goodness-of-fit test.

Ordinary RSMs integrate normal ability by quadrature, retaining every
observed rating of the relevant Person. Supported ordinary fits have
unit weights, additive unanchored severity facets, no interactions or
shrinkage, Person as the noncentered facet, consecutive integer source
categories, and either known N(0,1) or `population_formula = ~1`. The
estimated population mean and variance are both retained. This separate
route does not alter the plug-in indices from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).
Old fits that omitted scores without retaining original row positions
need to be refitted from the complete assigned-score roster.

Testlets use nested normal quadrature. Shared raters use
category-specific Laplace integrals of the complete likelihood times the
replicate category probability, after integrating abilities by
quadrature. Each numerator reoptimizes the joint latent rater mode;
calibration is never refitted. The positive numerator integrals are
normalized across categories. `NormalizationError` records the
unnormalized probability sum minus one. This defect and agreement
between quadrature orders are numerical diagnostics, not bounds on the
Laplace approximation error. In particular, small defects do not certify
accuracy with few raters or sparse ratings. Shared-rater work grows with
requested rows and categories; use `rows` to inspect a subset while
retaining the complete conditioning data.

For these posterior routes, missing scores remain `missing_score`; they
are not imputed. Nonfinite or zero predictive variances and unresolved
integration remain unavailable with a reason. A group containing any
unavailable observed row has no summary, rather than silently dropping
that row. Entirely missing groups have no summary. A fitted zero latent
variance defines the corresponding submodel's predictions; it does not
establish absence of heterogeneity.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
descriptive response residual summaries

Compare residual summaries across selected groups without reference
cutoffs.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): The
response probabilities integrate the latent effects conditional on the
same observed responses and fixed calibration. These are descriptive
summaries, not ordinary plug-in Infit/Outfit. Neither an expectation of
one nor a universal acceptable range is established. No interval,
warning region or statistical test is drawn. Hiding annotations changes
only the display;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
retains the probability definition and limitations. For corrected JML,
probabilities instead condition on corrected calibration and reprofiled
Person point estimates; no latent effects are integrated. The paired
view displays each available index independently, so an available Infit
is retained when zero conditional variance makes Outfit undefined. The
scatter view requires both indices. The caption reports partial
availability, and the saved table retains its reasons.

## Two-family GPCM posterior residuals

Use this route to describe how observed scores differ from the fitted
model's posterior predictions. For example, summarize by a Judge column
with `mfrm_response_diagnostics(fit, group_by = "Judge")`. Both slope
families multiply the complete adjacent-category predictor, as in
fitting. Ability is integrated under the fitted fixed N(0,1) population
and all of the Person's observed ratings; probabilities are not
evaluated at the EAP. Only fitted observed rows are returned, preserving
the original identifiers and incomplete assignment pattern. No
unassigned cell is filled.

The saved solution and point calibration must agree with their fitting
specification. A slope covariance or slope interval is not required.
Fixed-grid EM and adaptive direct MML retain their respective
integration methods. Adaptive grids use the complete Person posterior's
mode and curvature, preserving the original N(0,1) prior through
density-ratio and Jacobian weights. Source likelihood and
engine-specific gradient checks are recomputed before prediction. Stored
convergence flags alone do not establish a usable source. This has the
same scope as the two-family fit: two fixed slope facets, unit weights,
no anchors or covariates, and observed zero-based categories.
`quad_points` checks response integration at the retained parameters; it
does not refit the calibration. If integration is unresolved, increase
it explicitly. The returned probabilities use `2 * quad_points + 1`
points; the lower order supplies the row-wise check. Selecting fewer
output rows does not shorten the posterior's conditioning record or
change its grid. Settings retain the integration method through plots,
reports and exports. Separately use
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mml_quadrature_sensitivity.md)
to examine whether the fitted calibration changes across quadrature
grids.

Inspect `rows` for unavailable predictions before reading `measures`. A
larger descriptive Infit or Outfit is not a calibrated misfit decision;
there is no expectation-one reference. These same-data summaries neither
establish rater quality nor test unidimensionality or local
independence.
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
Q3/PCA, Wright/Pathway maps and model ranking retain their separate
support restrictions. Attach the saved result with
`mfrm_results(fit, include = c("fit", "plots"), compute = "never", response_diagnostics = result)`
for plots, reports and exports. Collection and replay do not refit or
reintegrate the saved probabilities.

## Corrected JML conditional residuals

For an explicit profile-score-adjusted GPCM fit, probabilities are
evaluated at the saved corrected facet/step/slope estimates and the
reprofiled Person abilities:
\\p\_{ik}=P(Y_i=k\mid\widehat\theta_i,\widehat\beta\_{adj})\\. These are
conditional plug-in probabilities, not posterior predictions or held-out
predictions. There is no normal ability prior or quadrature. Calibration
and Person estimation uncertainty are excluded. Residual bias may
remain. Unavailable RootSE does not prevent these point calculations.
The response formula is the same shared-owner GPCM used for fitting.

Only observed fitted rows are available; no unassigned cells are filled
or missing scores imputed. Original row numbers, repeated-event
multiplicity, category labels and facet names are retained. `rows`
selects displayed and summarized events without changing their Person
profiles. Save the result and attach it through
`mfrm_results(fit, response_diagnostics = result)`; the saved
calibration, slopes, Person profiles and source rows must match.

An extreme Person profile has a limiting probability of one at the
minimum or maximum score. Its expected score, zero conditional variance
and raw residual remain available. `StandardizedResidual` is missing
with `Status = "zero_variance"`: the ratio at the saved probabilities is
undefined. No automatic convention replacing `0/0` with zero is applied.
`ProbabilityAvailable` distinguishes this case from a failed probability
calculation. If all selected raw residuals and variances are available
and their total variance is positive, Infit remains available, including
those zero-variance rows. Outfit requires every selected standardized
residual; otherwise it is missing, and the group is
`partially_available` with a reason. The grouped `Available` column
counts rows with finite standardized residuals; Infit can use all
`Observed` rows despite that smaller count. No row is silently
discarded. An all-zero-variance group has neither index. Explicitly
selecting other rows changes the summarized set and must be reported as
such.

These same-data residual summaries have no calibrated expectation-one
reference, uncertainty intervals, p-values, automatic flags or
rater-quality classifications. They do not establish correction of
structural bias or replace
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
which is unavailable for this estimator.
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) offers paired
and scatter views, including
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
conversion. A paired view retains available Infit when Outfit is
missing; a scatter view needs both. Reports and exports preserve the
probability definition and unavailable outcomes. Corrected-JML model
comparison remains unavailable; portable scoring has its own calibration
checks and conditional EAP target.

## References

Tierney, L., & Kadane, J. B. (1986). Accurate approximations for
posterior moments and marginal densities. Journal of the American
Statistical Association, 81(393), 82–86.
[doi:10.1080/01621459.1986.10478240](https://doi.org/10.1080/01621459.1986.10478240)
. This supports the ratio-of-integrals approximation, not universal
accuracy for this rating design.

## See also

`plot.mfrm_response_diagnostics()`,
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_results.md),
[`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/score_mfrm_random_rater.md),
[`predict.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict.mfrm_testlet.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("mfrm_response_diagnostics", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
example <- readRDS(system.file("examples", "extended-models.rds", package = "mfrmr"))
fit <- example$testlet$fit
residuals <- example$testlet$diagnostics
# To recompute the posterior predictive residuals:
# residuals <- mfrm_response_diagnostics(fit, group_by = "Rater")
residuals$measures
plot(residuals)
mfrm_results(fit, response_diagnostics = residuals, compute = "never")
} # }
```
