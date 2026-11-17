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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  [`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  or
  [`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
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

- title:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- caption:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- show_title:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_notes:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_labels:

  Show group labels. Unavailable groups keep their labels in the paired
  view; both views retain all rows in
  [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

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
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
for aligned ordinary versus extended RSM comparisons, using the same
selected events and group_by. Corrected-JML and two-family GPCM
comparisons are not supported by that route. Collecting, plotting and
exporting saved results never recomputes integrals.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extracts selected measures, display settings, notes and alternative
text.

## Details

Holding calibration \\\widehat\psi\\ fixed, posterior routes evaluate
\$\$p\_{ik}=E\[P(Y_i^{rep}=k\mid b,\widehat\psi)\mid
Y\_{obs},\widehat\psi\], \qquad \mu_i=\sum_k k p\_{ik},\quad V_i=\sum_k
(k-\mu_i)^2p\_{ik},\$\$ integrating uncertain latent effects \\b\\
across all observed ratings of the Person (quadrature for ordinary RSM
and two-family GPCM; nested quadrature for testlets; category-specific
Laplace numerator integrals with `NormalizationError` for shared random
raters). Profile-score-adjusted GPCM JML instead evaluates conditional
plug-in probabilities
\\p\_{ik}=P(Y_i=k\mid\widehat\theta_i,\widehat\beta\_{adj})\\ without
quadrature; extreme profiles have `Status = "zero_variance"` and
`StandardizedResidual = NA` (`0/0` is never replaced with zero, so Infit
can remain available when total group variance is positive while Outfit
becomes `NA` / `partially_available`).

Grouped descriptive Outfit (mean of \\(y_i-\mu_i)^2/V_i\\) and Infit
(\\\sum_i(y_i-\mu_i)^2/\sum_i V_i\\) have no expectation-one baseline,
ZSTD, or automatic cutoffs, and any unresolved row withholds that
group's summary.

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
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains the probability definition and limitations. For corrected JML,
probabilities instead condition on corrected calibration and reprofiled
Person point estimates; no latent effects are integrated. The paired
view displays each available index independently, so an available Infit
is retained when zero conditional variance makes Outfit undefined. The
scatter view requires both indices. The caption reports partial
availability, and the saved table retains its reasons.

## References

Tierney, L., & Kadane, J. B. (1986). Accurate approximations for
posterior moments and marginal densities. Journal of the American
Statistical Association, 81(393), 82–86.
[doi:10.1080/01621459.1986.10478240](https://doi.org/10.1080/01621459.1986.10478240)
. This supports the ratio-of-integrals approximation, not universal
accuracy for this rating design.

## See also

`plot.mfrm_response_diagnostics()`,
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md),
[`predict.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
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
