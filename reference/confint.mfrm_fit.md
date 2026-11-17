# Confidence intervals for native fit coefficients and GPCM slopes

Compute pointwise Wald intervals for free `coef(object)` coordinates in
native MML/CML fits (`parm = NULL`), positive GPCM discriminations and
slope contrasts (`parm = "slopes"`), or two-family GPCM step offsets
(`parm = "steps"`). Inspect `attr(ci, "diagnostics")` (`CIEligible`,
`CoverageQualified`, `InferenceReview`) alongside returned bounds.

## Usage

``` r
# S3 method for class 'mfrm_fit'
confint(
  object,
  parm = NULL,
  level = 0.95,
  scale = c("relative", "standardized"),
  contrasts = NULL,
  contrast_scale = c("ratio", "difference"),
  method = c("model", "sandwich", "profile"),
  clusters = NULL,
  adjust = FALSE,
  simultaneous = c("none", "bonferroni"),
  ...,
  slope = NULL,
  profile_control = list()
)

# S3 method for class 'mfrm_cml_fit'
confint(object, parm = NULL, level = 0.95, ...)

# S3 method for class 'mfrm_comparison_fit'
confint(object, parm = NULL, level = 0.95, ...)
```

## Arguments

- object:

  Native MML or CML
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  result (JML structural intervals are unsupported).

- parm:

  `NULL` (free `coef(object)` coordinates), character/integer subset,
  `"slopes"` (GPCM discriminations), or `"steps"` (two-family GPCM
  within-level step offsets).

- level:

  Confidence level in `(0, 1)` (default `0.95`).

- scale:

  For `parm = "slopes"`: `"relative"` (one-family default, geometric
  mean `1`) or `"standardized"` (population SD times slope, including
  estimated-SD covariance; required default for two-family fits).

- contrasts:

  Optional named zero-sum contrast matrix across slope levels and scale
  (`"ratio"` exponentiating log contrasts or `"difference"` via delta
  method).

- contrast_scale:

  Optional named zero-sum contrast matrix across slope levels and scale
  (`"ratio"` exponentiating log contrasts or `"difference"` via delta
  method).

- method:

  `"model"` (inverse full joint observed information), `"sandwich"`
  (Person/cluster marginal-likelihood score sandwich for one-family
  GPCM), or experimental `"profile"` (chi-square(1) deviance profile
  reoptimizing all nuisance parameters for one `slope`).

- clusters:

  Optional Person-to-Cluster `data.frame` and `G/(G - 1)` factor
  (`FALSE` default) for `method = "sandwich"`.

- adjust:

  Optional Person-to-Cluster `data.frame` and `G/(G - 1)` factor
  (`FALSE` default) for `method = "sandwich"`.

- simultaneous:

  `"none"` (pointwise default) or `"bonferroni"` across rows in the
  current call.

- ...:

  Unused; additional arguments are rejected.

- slope:

  Required target level for `method = "profile"` (e.g., `"R01"` or named
  `c(Task = "t1")` in two-family fits) and search budget list
  (`maxit = 400`, `max_steps = 8`, `initial_step = 0.5`).

- profile_control:

  Required target level for `method = "profile"` (e.g., `"R01"` or named
  `c(Task = "t1")` in two-family fits) and search budget list
  (`maxit = 400`, `max_steps = 8`, `initial_step = 0.5`).

## Value

Numeric `Lower`/`Upper` matrix (class `mfrm_slope_intervals` for
`parm = "slopes"`, or `mfrm_facet_intervals` for two-family
`parm = "steps"`) with `diagnostics`, `checks`, and `method` attributes.

## Details

**Free coefficients and GPCM slopes.** Default coefficient intervals use
\\\hat b_j \pm z\_{(1+\mathrm{level})/2}\sqrt{V\_{jj}}\\ from qualified
`vcov(object)`. For `parm = "slopes"`, free log-slope covariance
\\V\_\eta\\ from the **full joint** observed information expands via \\J
V\_\eta J^\top\\ to `G` sum-zero log slopes with bounds \\\exp(\log \hat
a_g \pm z\\\mathrm{SE}(\log \hat a_g))\\ (requiring `quad_points >= 31`,
unit weights, positive unregularized curvature, and no marginal
response-dimension rank deficit; dense Hessian allocation respects
`options(mfrmr.max_information_bytes = 256 * 1024^2)`).

**Two-family and profile checks.** Two-family log-Wald and `"steps"`
intervals differentiate the fitted fixed-grid EM or moving-node adaptive
marginal objective, verifying SE-scaled score length
`\sqrt{g'Vg} <= 0.01` and `2*q - 1` quadrature stability (`CIEligible`
vs `CoverageQualified = FALSE`). Profile intervals verify agreement of
retained and neutral starts (`<= 1e-5` NLL), positive-definite nuisance
Hessians at both quadrature orders, and endpoint LR residuals `<= 1e-4`,
storing scans in `attr(ci, "profile")` and Wald comparisons in
`attr(ci, "wald")`.

## References

- Fischer, S. M., & Lewis, M. A. (2021). *Statistics and Computing*,
  31, 38.
  [doi:10.1007/s11222-021-10012-y](https://doi.org/10.1007/s11222-021-10012-y)
  .

- Zeileis, A., Koell, S., & Graham, N. (2020). *J. Stat. Softw.*, 95(1),
  1–36.
  [doi:10.18637/jss.v095.i01](https://doi.org/10.18637/jss.v095.i01) .

## See also

[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md),
[`bootstrap_mfrm_gpcm()`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("confint.mfrm_fit", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Compare intervals for free coefficients and relative discriminations.
# Reuse the synthetic GPCM fit; estimation uses 61 quadrature points.
# Full regeneration recipe: examples/measurement-fits.R in the package.
fit <- readRDS(system.file("examples", "measurement-fits.rds",
  package = "mfrmr", mustWork = TRUE))$gpcm
# The default matches coef(fit): steps, locations and log slopes.
coefficients_ci <- confint(fit, level = 0.95)
head(cbind(Estimate = coef(fit), coefficients_ci))
attr(coefficients_ci, "diagnostics") # Availability and interpretation
# Missing bounds do not erase retained points; report the reason too.
# Explicitly request positive relative slopes for rater comparison:
intervals <- confint(fit, parm = "slopes", level = 0.95)
intervals
attr(intervals, "diagnostics")[, c("SlopeFacet", "Estimate",
  "CIEligible", "InferenceReview")]
# Relative slopes have geometric mean one. A value above one means a
# steeper response curve, not greater severity or better rater quality.
# Missing bounds need the saved reason; availability is not a coverage test.
plot(intervals)
file <- tempfile(fileext = ".rds")
saveRDS(intervals, file) # Use a lasting path for your analysis
saved <- readRDS(file)
apa_table(saved) # Reuse the intervals without fitting again

# A separate, prespecified profile calculation can be requested with
# confint(fit, parm = "slopes", method = "profile", slope = chosen_rater).
# Choose chosen_rater from fit$slopes$SlopeFacet; see the profile section.
} # }
```
