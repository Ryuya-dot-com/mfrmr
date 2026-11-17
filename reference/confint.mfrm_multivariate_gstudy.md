# Sampling uncertainty in G-Study variance and covariance components

Compute standard errors and pointwise confidence intervals for variance
components of one score or fixed composite (in squared score units), or
for between-score covariance components (in score-product units), from
an
[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
object.

Quantify how estimated sources of score variation would vary across
repeated G-studies with the same assignment design. Supports balanced
ANOVA and identifiable MINQUE(0), including incomplete and supported
nested sources.

## Usage

``` r
# S3 method for class 'mfrm_multivariate_gstudy'
confint(
  object,
  parm = NULL,
  level = 0.95,
  score = NULL,
  weights = NULL,
  assumption,
  method = "auto",
  draws = 20000L,
  seed = 20261016L,
  ...
)

# S3 method for class 'mfrm_multivariate_gstudy'
vcov(object, score = NULL, weights = NULL, assumption, ...)
```

## Arguments

- object:

  A result from
  [`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md).

- parm:

  Component names or integer indices (`NULL` selects all).

- level:

  Pointwise confidence level in `(0, 1)` (default `0.95`).

- score:

  One original score, or exactly two distinct original scores for the
  sampling covariance of their between-score component covariances. The
  default selects the first original score.

- weights:

  Optional named weights for one prespecified composite; name every
  original score. Do not also supply `score`.

- assumption:

  Required: `"normal"` asserts independent normal random effects, a
  common mean for each score and constant component covariances.
  Assignment and omissions must preserve that model when conditioning on
  the observed assignment. The assumption is not tested.

- method:

  `"auto"`/`"mls"` for balanced ANOVA variances; `"reml_profile"` for
  experimental normal REML deviance profiles
  (`D - D_min <= qchisq(level, 1)`, `lme4`/`minqa`) on retained ratings;
  `"residual_contrast"` for exact normal-residual chi-square variance
  (or conservative two-score enclosure) using orthonormal `H'Z = 0`
  (`nu = n - rank(Z) > 0`); or, for two-score balanced ANOVA
  covariances, explicit `"gci"` (Wishart Bartlett pivot) or
  `"regression_region"` (conservative `t`/chi-square rectangle).

- draws:

  Pivotal draw count (`>= 1000`, default `20000`) and seed for two-score
  covariance `method = "gci"` (rejected for other methods).

- seed:

  Pivotal draw count (`>= 1000`, default `20000`) and seed for two-score
  covariance `method = "gci"` (rejected for other methods).

- ...:

  Reserved; extra arguments are rejected.

## Value

A `data.frame` with `Source`, `Score` (plus `Score1`, `Score2` for
covariances), `Estimate`, `SE`, `Lower`, `Upper`, `RawLower`,
`RawUpper`, `Level`, `Method`, and `Status` (plus `IntervalCenter`,
`SEStatus`, `CandidateLower/Upper`, `Available`, `Validation` where
applicable) and portable attributes (`weights`, `assumption`,
`source_design`, `mean_products`, `monte_carlo`, `reml_source`,
`residual_projection`, `diagnostics`, `notes`).

A named matrix estimating the sampling covariance of component
estimates. Attribute `summary` is a data frame with `Source`,
`Estimate`, `SamplingVariance`, `SE`, and `SEStatus`. `diagnostics`
retains the moment rank, singular values, entrywise estimability and
matrix PSD check. `score`, `weights`, `assumption`, `source_design`,
`source_rows` and `notes` retain interpretation. Save the full result
using [`saveRDS()`](https://rdrr.io/r/base/readRDS.html). MINQUE
requires its retained grouping assignments, moment equations and
quadratic products; balanced ANOVA uses saved summaries without raw
data.

## Details

**Variance SEs and MLS statuses.** For balanced ANOVA map
`theta = A %*% MS`, unbiased sampling covariance is
`A %*% diag(2 * MS^2 / (df + 2)) %*% t(A)` (urGENOVA SEVC convention).
Ting et al. (1990) MLS intervals retain unrestricted
`RawLower`/`RawUpper` and intersect `Lower`/`Upper` with `[0, Inf)`,
distinguishing `"Available"`, `"Includes zero"`,
`"Empty nonnegative interval"`, `"Degenerate mean squares"`,
`"Numerical interval failure"`, and
`"Variance interval below numeric resolution"`.

**Between-score covariances and incomplete sources.** Signed covariance
intervals are never truncated at zero. For Wishart blocks `nu * S`
(`nu > 1`), elementwise unbiased variance is
`(nu*x*y + (nu - 2)*c^2) / ((nu - 1)*(nu + 2))`; `"gci"` propagates
Bartlett pivots `nu*(c - sqrt(x*y - c^2)*Z / sqrt(U2)) / U1`
(Krishnamoorthy & Xia, 2007), while `"regression_region"` encloses
regression-slope `t` and predictor chi-square pivots at block level
`level^(1/K)` (using Cauchy-Schwarz on `df = 1` or singular blocks).
`"reml_profile"` and `"residual_contrast"` retain original ANOVA/MINQUE
`Estimate` alongside separate `IntervalCenter` (`SE = NA`);
finite-sample interval precision depends on block degrees of freedom and
cell balance.

Rows and columns refer to **estimated components**, such as Person, Task
and Residual. This is neither the covariance matrix between individual
ratings nor the component matrices between score columns in `object`.
Use `attr(result, "summary")` to read the original estimates, sampling
variance estimates, SEs and availability. A component SE has squared
score units; the returned covariance matrix has fourth-power score
units. For a between-score covariance, the SE has the product of the two
score units. These SEs differ from the D-study's measurement SEM in
original score units.

The component estimates are unchanged. This method uses Gaussian product
moments to correct plug-in bias in their estimated sampling covariance.
It does not fit a likelihood, resample data or construct confidence
intervals. In particular, `Estimate +/- 1.96 * SE` is not a generally
justified interval. Use `confint.mfrm_multivariate_gstudy()` for its
separately qualified interval methods. A REML profile's center belongs
to a different estimator; the SE returned here describes the original
ANOVA/MINQUE estimator.

## Calculation

With mean-removing MINQUE quadratic forms \\q_s=y^T A_s y\\,
\\E(q_s)=\theta_s\\ and \\C\_{st}=2\mathrm{tr}(A_s V A_t V)\\, where
\\V=\sum_u\theta_u K_u\\. Let the linear operator P map
\\\mathrm{vec}(\theta\theta^T)\\ to \\\mathrm{vec}(C)\\. The normal
product-moment identity gives
\\E\\\mathrm{vec}(qq^T)\\=(I+P)\mathrm{vec}(\theta\theta^T)\\. Inverting
this moment system gives an unbiased estimator of C for its identifiable
entries. This is a consequence of the cited moment identity, not a claim
that the reference proposes this package's G-theory procedure. The
squared SE, when available, is the corresponding diagonal estimate; the
square root is not itself an unbiased SE estimator.

For two scores, write x and y for their variance-component vectors and c
for their covariance-component vector. On symmetric matrix coordinates,
\\E\\\mathrm{sym}(\hat x\hat y^T)\\=\mathrm{sym}(xy^T)+P(cc^T)\\ and
\\E(\hat c\hat c^T)=(I+P/2)(cc^T)+(P/2)\mathrm{sym}(xy^T)\\. Solve these
coupled equations for the sampling covariance
\\(P/2)\\\mathrm{sym}(xy^T)+cc^T\\\\. Applying only the scalar
correction to a covariance component would be incorrect.

Balanced ANOVA reduces to the existing independent-mean-square result
`A %*% diag(2 * MS^2 / (df + 2)) %*% t(A)` for a variance/fixed
composite, and the Wishart product-moment correction for a between-score
covariance. MINQUE uses the actual observed grouping kernels.
Column-block calculations avoid allocating observation-square matrices,
but time still increases quadratically with the number of observed
ratings. No sampling simulation is performed. Balanced MINQUE uses the
same ANOVA limit.

## Unavailable or negative results

A moment system can fail to identify some sampling-covariance entries
even when point components are identifiable. A contributing balanced
stratum with df one is an example for between-score covariance SEs. An
SVD checks each target entry's estimability; only unidentified entries
become `NA`. Its rank tolerance is `sqrt(.Machine$double.eps)` relative
to the largest singular value, with relative target reconstruction error
below `1e-8`.

An unbiased sampling-variance estimate may be negative. It is retained
in the returned matrix and `SamplingVariance`, while its `SE` is `NA`
and `SEStatus` explains why. The matrix can also be indefinite with
positive diagonal entries. Nothing is clipped or repaired to make it
positive semidefinite. A mathematically unbiased variance estimate does
not ensure a useful SE in a small sample or correct normal-reference
coverage.

## References

- Bates, D., Maechler, M., Bolker, B., & Walker, S. (2015). *J. Stat.
  Softw.*, 67(1), 1–48.
  [doi:10.18637/jss.v067.i01](https://doi.org/10.18637/jss.v067.i01) .

- Brennan, R. L. (2001). *Manual for urGENOVA, Version 2.1*. CASMA.

- Hess, A., & Iyer, H. (2002). *Proceedings of SUGI 27*, Paper 252-27.

- Krishnamoorthy, K., & Xia, Y. (2007). *J. Stat. Plan. Inference*, 137,
  2362–2379.
  [doi:10.1016/j.jspi.2006.08.002](https://doi.org/10.1016/j.jspi.2006.08.002)
  .

- Ting, N., Burdick, R. K., Graybill, F. A., Jeyaratnam, S., & Lu,
  T.-F. C. (1990). *J. Stat. Comput. Simul.*, 35(3–4), 135–143.
  [doi:10.1080/00949659008811240](https://doi.org/10.1080/00949659008811240)
  .

- Wu, H., & Neale, M. C. (2013). *Psychometrika*, 78, 441–463.
  [doi:10.1007/s11336-012-9304-2](https://doi.org/10.1007/s11336-012-9304-2)
  .

Magnus, J. R. (1978). The moments of products of quadratic forms in
normal variables. *Statistica Neerlandica, 32*, 201–210. Lemma 6.2,
p.209.
[doi:10.1111/j.1467-9574.1978.tb01399.x](https://doi.org/10.1111/j.1467-9574.1978.tb01399.x)
.

Rao, C. R. (1971). Estimation of variance and covariance
components–MINQUE theory. *Journal of Multivariate Analysis, 1*,
257–275.
[doi:10.1016/0047-259X(71)90001-7](https://doi.org/10.1016/0047-259X%2871%2990001-7)
.

## See also

[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md),
`vcov.mfrm_multivariate_gstudy()`,
[`plot.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_multivariate_gstudy.md),
[mfrmr_methods_reference](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("confint.mfrm_multivariate_gstudy", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Published synthetic data: 10 persons, 6 common tasks, scores V and W.
tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
g <- mfrm_g_study(tasks, c("V", "W"), rater = NULL)
ci <- confint(g, weights = c(V = .5, W = .5), assumption = "normal")
ci[, c("Source", "Estimate", "SE", "Lower", "Upper", "Status")]
attr(ci, "notes")
# One original score and one component; no new G-study is fitted.
confint(g, parm = "Person", score = "V", assumption = "normal", level = .90)
# Covariance between the two observed scores, retaining its sign.
covariance_ci <- confint(g, score = c("V", "W"), method = "gci",
  assumption = "normal")
covariance_ci[, c("Source", "Estimate", "SE", "Lower", "Upper", "Status")]
attr(covariance_ci, "monte_carlo")$endpoint_bands
# Incomplete ratings: a residual-only interval without likelihood fitting.
observed <- tasks[(tasks$Person + tasks$Task) %% 3 != 0, ]
sparse_g <- mfrm_g_study(observed, c("V", "W"), rater = NULL,
                                   method = "minque0")
residual_ci <- confint(sparse_g, parm = "Residual", score = "V",
  method = "residual_contrast", assumption = "normal")
residual_ci[, c("Estimate", "IntervalCenter", "Lower", "Upper", "Status")]
attr(residual_ci, "residual_projection")$df
# A separate experimental REML model can address other components.
if (requireNamespace("lme4", quietly = TRUE) && requireNamespace("minqa", quietly = TRUE)) {
  profile_ci <- confint(sparse_g, score = "V", method = "reml_profile",
                        assumption = "normal")
  profile_ci[, c("Source", "Estimate", "IntervalCenter", "Lower", "Upper", "SEStatus")]
  attr(profile_ci, "notes")
  # Two scores require a joint model; this is covariance, not correlation.
  joint_ci <- confint(sparse_g, parm = "Person", score = c("V", "W"),
                      method = "reml_profile", assumption = "normal")
  joint_ci[, c("Source", "Estimate", "IntervalCenter", "Lower", "Upper", "Validation")]
}
} # }
# Optional workflow; run the example explicitly as shown below.
# example("vcov.mfrm_multivariate_gstudy", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
data("mfrmr_example_gtheory_crossed", package = "mfrmr")
ratings <- mfrmr_example_gtheory_crossed
# Complete balanced ratings: compute both targets directly.
g <- mfrm_g_study(ratings, c("Content", "Organization"),
                            method = "anova")
sampling <- vcov(g, score = "Content", assumption = "normal")
attr(sampling, "summary") # Component estimates and their sampling SEs.
attr(sampling, "notes")
# Uncertainty in the covariance between two criteria, by source.
cross_score <- vcov(g, score = c("Content", "Organization"),
                    assumption = "normal")
attr(cross_score, "summary")

# Incomplete assignments also work, but their moment calculation is longer.
# These saved results use the same ratings with rows 1, 8 and 23 omitted.
# Omitted ratings are absent observations, never zero scores.
incomplete <- readRDS(system.file("examples", "gstudy-sampling.rds",
                                  package = "mfrmr", mustWork = TRUE))
incomplete$study$design
attr(incomplete$variance, "summary")
attr(incomplete$covariance, "summary")
attr(incomplete$covariance, "notes")
# To repeat the full incomplete-data calculation:
# source(system.file("examples", "gstudy-sampling.R", package = "mfrmr"))
# incomplete <- gstudy_sampling_example()
} # }
```
