# Approximate confidence intervals and comparisons for GPCM slopes

Compute confidence intervals for relative or standardized
discriminations and specified slope comparisons in a native GPCM MML
fit, without refitting. The default is a pointwise model-based interval
for each relative slope. A relative slope above one means a steeper
response curve than the geometric-average slope; it is not a measure of
rater agreement or a recommended scoring weight.

## Usage

``` r
# S3 method for class 'mfrm_fit'
confint(
  object,
  parm = "slopes",
  level = 0.95,
  scale = c("relative", "standardized"),
  contrasts = NULL,
  contrast_scale = c("ratio", "difference"),
  method = c("model", "sandwich"),
  clusters = NULL,
  adjust = FALSE,
  simultaneous = c("none", "bonferroni"),
  ...
)
```

## Arguments

- object:

  A GPCM MML result from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- parm:

  Must be `"slopes"`; other parameter families are not included.

- level:

  Nominal confidence level strictly between zero and one.

- scale:

  `"relative"` (default) keeps geometric mean one. `"standardized"`
  reports population-SD times slope, including uncertainty in estimated
  SD. With covariates, this SD is the residual population SD.

- contrasts:

  Optional numeric matrix: one named comparison per row, all slope
  levels as named columns, finite nonzero rows summing to zero. For A
  versus B use coefficients 1 and -1, and zero for other levels.

- contrast_scale:

  `"ratio"` exponentiates log-slope contrasts (A/B); `"difference"`
  contrasts positive slopes (A-B) by the delta method.

- method:

  `"model"` uses joint observed information; `"sandwich"` uses Person
  marginal-likelihood scores, optionally grouped into larger clusters.

- clusters:

  Optional data frame mapping each fitted `Person` once to a nonmissing
  `Cluster`, as in
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).
  Persons are independent units by default. Shared random effects across
  clusters are not supported.

- adjust:

  For sandwich covariance only, multiply by G/(G-1) for G clusters;
  default FALSE. This is not a small-sample accuracy guarantee.

- simultaneous:

  `"none"` (default) gives pointwise intervals; `"bonferroni"` adjusts
  for all rows requested in this call. It does not adjust for other
  analyses or post-selection of targets.

- ...:

  Unused.

## Value

A matrix of class `mfrm_slope_intervals` with columns `Lower` and
`Upper`, named by slope level. Printing shows estimates, bounds and any
unavailability reasons without displaying internal diagnostic fields.
Attributes `level`, `method`, `target`, and `diagnostics` describe the
result. The diagnostics table includes estimates, log-scale and
positive- scale SEs, `CIEligible`, `CIUse`, and an `InferenceReview`
explaining availability. Unavailable intervals have missing bounds.

## Details

Relative slopes have geometric mean one. If \\\eta\\ denotes the G-1
free log-slope coordinates and \\J\\ expands them to G sum-zero log
slopes, their covariance is \\J V\_{\eta} J^T\\. Here \\V\_{\eta}\\ is
the slope block of the inverse **full joint** observed information,
including estimated population parameters, rather than the inverse of
the slope information block alone. Each interval is \\\exp(\log(a_g)
\mathbin{\pm} z SE(\log(a_g)))\\.

The current likelihood, gradient and joint information must pass the MML
solution checks. The fit also needs supported score categories,
consistent likelihood metadata, unit observation weights, and at least
31 quadrature points. Regularized, singular, nonconverged or mismatched
results do not receive intervals. Positive curvature is a local check,
not a proof of a global maximum or accurate integration. Use
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
and different starts for consequential results. A positive but
ill-conditioned information matrix can be used with a warning when two
refined numerical Hessians agree, inversion without regularization is
accurate and a curvature-scaled gradient is small. Failure of any check
keeps inference unavailable. Passing these numerical checks does not
resolve weak information in the data: an interval may still be extremely
wide or unreliable near a boundary. Warnings are saved in the `cautions`
attribute and `InferenceReview`, and follow printing, default plot
subtitles and reports.

Model intervals are asymptotic. Standardized slopes use the full
Jacobian for `log(slope) + log(sigma2)/2`, including cross-covariances.
Ratio contrasts cancel a common population scale. Difference contrasts
use the full joint positive-slope covariance. Extra output includes
`PValue` for zero log contrast (ratio one) or difference zero;
Bonferroni applies to these p-values too. Containment of one for an
individual relative slope is not a pairwise test. The matched
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
LRT tests all relative slopes equal jointly.

Sandwich inference concerns the working model's limiting parameter; it
does not correct bias, informative assignment or a wrong population
model. It needs many independent clusters. Rank-deficient cluster scores
withhold intervals. Scores aggregate complete Person response vectors,
including population-parameter derivatives and the fitted quadrature
method. Small, incomplete correctly specified samples already showed
undercoverage and extremely wide model intervals; see the GPCM scope
vignette. The added methods do not imply universal finite-sample
coverage. For an explicit model-based refit alternative use
[`bootstrap_mfrm_gpcm()`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md).
Reanalysis of saved fits also evaluates standardized slope differences;
it must not be confused with the earlier relative-difference evidence or
with refitting all datasets under the current estimator. See the GPCM
scope vignette for these distinct targets and the observed limits of
approximation.

Joint-information calculation is shared with IC/LRT qualification.
Option `mfrmr.max_information_bytes` (default 256 MiB) budgets eight
dense p-by-p matrices before allocation, or twenty when weak-information
refinement is needed. The extra budget is checked before refinement.
This workspace estimate excludes response data, quadrature and other
allocations and is not a process memory guarantee. A budget refusal
retains unavailable results and a reason. There is no separate
80-parameter inference cutoff. Computation still grows with p.

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
returns the default relative/model 95% calculation in
`parameter_uncertainty$slopes`; `fit_mfrm(attach_diagnostics = TRUE)`
attaches it to `fit$slopes`. `CIEligible` is output-specific and does
not promote the fit's global boundary certificate or other parameter
intervals. This method recomputes uncertainty for saved fits; it does
not trust old interval flags or alter the supplied object.

## References

Zeileis, A. (2006). Object-Oriented Computation of Sandwich Estimators.
Journal of Statistical Software, 16(9), 1–16.
[doi:10.18637/jss.v016.i09](https://doi.org/10.18637/jss.v016.i09) .

Zeileis, A., Koll, S., and Graham, N. (2020). Various Versatile
Variances: An Object-Oriented Implementation of Clustered Covariances in
R. Journal of Statistical Software, 95(1), 1–36.
[doi:10.18637/jss.v095.i01](https://doi.org/10.18637/jss.v095.i01) .

## See also

[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)

## Examples

``` r
# After fitting a GPCM with method = "MML":
# intervals <- confint(fit, parm = "slopes", level = 0.95)
# attr(intervals, "diagnostics")[, c("SlopeFacet", "Estimate",
#   "CIEligible", "InferenceReview")]
```
