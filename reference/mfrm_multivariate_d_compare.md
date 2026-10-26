# Compare prespecified multivariate D-study plans

Estimate how much G, Phi or SEM changes from a reference plan, including
the dependence between plans estimated from the same G-study. This first
interval method requires two common random facets and an explicit normal
random-effects assumption.

## Usage

``` r
mfrm_multivariate_d_compare(
  x,
  reference = 1L,
  score = NULL,
  composite = NULL,
  assumption,
  level = 0.95
)

# S3 method for class 'mfrm_multivariate_d_comparison'
summary(object, ...)

# S3 method for class 'mfrm_multivariate_d_comparison'
print(x, digits = NULL, row.names = FALSE, ...)
```

## Arguments

- x :

  A result from
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  with at least two plans. It must retain `negative_components = "raw"`;
  this inference does not describe GENOVA-adjusted component estimators.
  For population plan-difference intervals alongside GENOVA-adjusted
  points, use the supported `reference` methods in
  [`confint.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md).

- reference :

  Row number of the reference plan in `x$design_grid`.

- score :

  One original score name. With no selection, use the sole composite, or
  the first original score if there is no composite.

- composite :

  One named composite, or `"Composite"` for vector weights. Select
  either `score` or `composite`. Several composites require selection.

- assumption :

  Required: `"normal"` asserts independent, normally distributed
  random-effect vectors with constant component covariances. This
  assumption is not tested by the function.

- level :

  Pointwise confidence level between zero and one, default .95.

- object :

  A result from `mfrm_multivariate_d_compare()`.

- ... :

  Further table-printing arguments for
  [`print()`](https://rdrr.io/r/base/print.html); unused arguments to
  [`summary()`](https://rdrr.io/r/base/summary.html) are rejected.

- digits :

  Display precision passed to the printed tables; `NULL` uses R's
  current setting. Stored estimates are unchanged.

- row.names :

  Logical; print table row names? Defaults to `FALSE`.

## Value

An `mfrm_multivariate_d_comparison` list with `comparisons` (one row per
comparison plan and metric), `covariance` (joint sampling covariance of
those differences), `design_grid`, `reference`, selected score/composite
and weights, `level`, `method`, and component/sampling-covariance
diagnostics. `source_design` and `source_rows` retain the source method,
observed level counts, completeness, score convention and row-use
totals, without raw ratings or identifiers.
[`print()`](https://rdrr.io/r/base/print.html) displays these separately
from the future plans and includes composite weights. Save the full
comparison with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html); a
CSV of [`summary()`](https://rdrr.io/r/base/summary.html) alone does not
retain this context or the confidence level and approximation
assumptions. Earlier saved comparisons without source context remain
readable and say it is absent.
[`print()`](https://rdrr.io/r/base/print.html) returns the same
comparison invisibly without recomputation.
[`summary()`](https://rdrr.io/r/base/summary.html) returns the
comparison table. `Status` describes interval availability; point
differences can remain available without an interval.

## Details

Use this comparison when choosing between plans specified before
inspecting their estimates. For example, compare two raters and six
tasks with three raters and four tasks. A positive G/Phi difference
favors the comparison plan; a negative SEM difference favors it. An
interval containing zero means the direction is uncertain, not that the
plans are equivalent. Equal rating counts do not establish equal
examinee burden or cost.

The current scope is two common random facets, complete balanced ANOVA
or identifiable incomplete crossed MINQUE(0), and future complete
crossed plans. Persons and both facets are sampled from their stated
populations. The source assignments are held fixed and must preserve the
random-effect distributions. One-facet, nested, fixed-facet,
nonnormal-robust and informative-missingness intervals are not provided.
Ordinal score labels alone do not justify normal effects. Incomplete
source designs can have much weaker information than complete designs
with the same numbers of observed levels. For G/Phi differences from a
complete balanced one-facet ANOVA source, use
[`confint.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md)
with `parm = "G"` or `"Phi"` and `reference`. Those methods map an F or
generalized confidence set, respectively; Phi retains approximate
coverage. Neither uses this delta approximation. The same generic
supports one-facet `"RelativeSEM"` and `"AbsoluteSEM"` differences by
mapping a common error-SD interval. Relative SEM retains exact
positive-variance normal-model coverage; absolute SEM uses approximate
MLS. For general balanced crossed/nested two-facet plans, that generic
also accepts explicit `method = "mean_square_region"` with `reference`
for conservative G/Phi/SEM difference enclosures from shared source
uncertainty. These are not paired-delta intervals or tight joint
difference images; they can be wide. The delta method in this function
keeps its crossed scope.

The method uses raw estimated components in the Gaussian covariance of
quadratic-form estimates, then the delta method for paired differences
and a normal critical value. It uses the gradient of the difference, not
a sum of independent marginal variances. For a complete source design
this agrees with mean-square variances `2 * MS^2 / df`. These are
approximate intervals, not exact finite-sample guarantees. Small facet
pools, uneven assignments and estimates near boundaries can impair the
approximation. In a bounded assessment, a skewed-effect condition
reduced nominal 95% coverage to about 92%; this method must not be
described as distribution robust.

Negative components are retained and flagged. No components, differences
or interval endpoints are clipped. An unavailable point projection,
boundary derivative or nonpositive estimated difference variance leaves
that interval unavailable with a reason. Identical plans have an exact
zero difference when their point projections are available. Component
and sampling-covariance diagnostics do not establish model fit or
interval accuracy.

Intervals are pointwise for each prespecified comparison. They do not
support choosing the largest observed improvement, simultaneous claims
over all rows, or comparisons between adaptively selected score weights.
SEM is measurement error in score units; `SE` here is sampling
uncertainty in the *difference*.

Point projections are recomputed from the stored G-study using current
rules; no G-study is refitted and `x` is not modified. The G-study must
retain its analyzed data. For incomplete sources, covariance computation
processes blocks of rows to avoid a full observation-by-observation
matrix; its running time is still quadratic in the number of observed
ratings.

## Calculation and source of the approximation

For one selected score or fixed composite, write its observed values as
the vector \\z\\. Its seven raw component estimates can be written as
\\\hat\theta_s = z' A_s z\\, where each symmetric \\A_s\\ is fixed by
the observed design and removes the common mean: \\A_s 1 = 0\\. For
MINQUE(0), let \\K_s\\ indicate shared levels for component \\s\\, \\H =
I - 11'/N\\, \\B_s = H K_s H\\, and \\S\_{st} = \mathrm{tr}(B_s B_t)\\.
Then \\A_s = \sum_t (S^{-1})\_{st} B_t\\. These are the moment equations
described in
[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
and the MINQUE framework of Rao (1971).

Under the stated Gaussian model with covariance \\V = \sum_s \theta_s
K_s\\, the quadratic-form identity is \$\$C\_{st} =
\mathrm{Cov}(\hat\theta_s,\hat\theta_t) = 2\mathrm{tr}(A_s V A_t V).\$\$
This follows from the product moment in Magnus (1978, p. 209),
subtracting the product of the expectations. The mean term vanishes
because each \\A_s\\ removes the intercept. The identity concerns the
**true** covariance; this function substitutes raw estimated components
into \\V\\.

For a metric \\f\\ and plans \\a\\ and \\b\\, define \\h(\theta) =
f_b(\theta) - f_a(\theta)\\ and \\g = \nabla f_b - \nabla f_a\\,
evaluated at the component estimates. The first-order delta
approximation (Oehlert, 1992) gives \$\$\widehat{\mathrm{SE}}(\hat h) =
\sqrt{g'\hat C g}.\$\$ The interval is \\\hat h \pm
z\_{1-\alpha/2}\widehat{\mathrm{SE}}(\hat h)\\, where \\\alpha = 1 -
\mathrm{level}\\. Stacking the difference gradients in \\J\\ gives the
returned joint covariance \\J\hat C J'\\.

Thus there are distinct steps: a Gaussian component-covariance identity,
substitution of estimates, linearization of the nonlinear metric, and a
normal reference interval. Only the first is an exact model identity.
The current balanced implementation uses the plug-in `2 * MS^2 / df`,
not the alternative `df + 2` moment correction. The references support
the G/D targets and these mathematical steps; none validates this entire
package procedure for every supported design. This is not an
implementation of all GENOVA-family interval methods.

## References

Brennan, R. L. (2001). *Generalizability theory*. Springer.
[doi:10.1007/978-1-4757-3456-0](https://doi.org/10.1007/978-1-4757-3456-0)
. G/D targets and sampling variability.

Rao, C. R. (1971). Estimation of variance and covariance
components–MINQUE theory. *Journal of Multivariate Analysis, 1*,
257–275.
[doi:10.1016/0047-259X(71)90001-7](https://doi.org/10.1016/0047-259X%2871%2990001-7)
. Component moment estimation.

Magnus, J. R. (1978). The moments of products of quadratic forms in
normal variables. *Statistica Neerlandica, 32*(4), 201–210.
[doi:10.1111/j.1467-9574.1978.tb01399.x](https://doi.org/10.1111/j.1467-9574.1978.tb01399.x)
. Gaussian product moments; see p. 209. [Author's
copy](https://www.janmagnus.nl/papers/JRM003.pdf).

Oehlert, G. W. (1992). A note on the delta method. *The American
Statistician, 46*(1), 27–29.
[doi:10.1080/00031305.1992.10475842](https://doi.org/10.1080/00031305.1992.10475842)
. Taylor/moment approximation framework.

## See also

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`plot.mfrm_multivariate_d_comparison()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_multivariate_d_comparison.md)

## Examples

``` r
# Existing fictional ratings: one row per Person-Rater-Task, two scores.
data("mfrmr_example_gtheory_crossed", package = "mfrmr")
ratings <- mfrmr_example_gtheory_crossed
head(ratings)
#>   Person Rater Task Organization    Content
#> 1      1     1    1    0.5045747  0.5475769
#> 2      2     1    1    1.3440571 -0.9615514
#> 3      3     1    1   -0.4715306  3.7099968
#> 4      4     1    1   -0.5425612  0.5795908
#> 5      5     1    1   -0.3337672  2.8174334
#> 6      6     1    1    1.6440213  0.1798085
g <- mfrm_g_study(ratings, c("Content", "Organization"))
d <- mfrm_d_study(g,
  data.frame(Raters = c(2, 3, 4), Tasks = c(6, 4, 3)),
  weights = c(Content = .5, Organization = .5))
comparison <- mfrm_multivariate_d_compare(d, reference = 1,
  assumption = "normal")
summary(comparison)
#>   Reference Scenario      Kind     Score      Metric ReferenceValue     Value
#> 1         1        2 Composite Composite           G      0.5607879 0.5947792
#> 2         1        2 Composite Composite         Phi      0.3646152 0.3915712
#> 3         1        2 Composite Composite RelativeSEM      0.5774748 0.5385960
#> 4         1        2 Composite Composite AbsoluteSEM      0.8613827 0.8133822
#> 5         1        3 Composite Composite           G      0.5607879 0.5993499
#> 6         1        3 Composite Composite         Phi      0.3646152 0.3910704
#> 7         1        3 Composite Composite RelativeSEM      0.5774748 0.5335039
#> 8         1        3 Composite Composite AbsoluteSEM      0.8613827 0.8142378
#>    Difference    Status          SE       Lower       Upper
#> 1  0.03399130 Available 0.005947269  0.02233487  0.04564774
#> 2  0.02695599 Available 0.020683397 -0.01358272  0.06749470
#> 3 -0.03887873 Available 0.006955045 -0.05251036 -0.02524709
#> 4 -0.04800055 Available 0.038102461 -0.12268000  0.02667890
#> 5  0.03856203 Available 0.010405112  0.01816839  0.05895568
#> 6  0.02645516 Available 0.037138595 -0.04633515  0.09924547
#> 7 -0.04397091 Available 0.011934932 -0.06736295 -0.02057887
#> 8 -0.04714496 Available 0.066016840 -0.17653559  0.08224567
plot(comparison) # G/Phi for each plan, including the reference.

plot(comparison, type = "sem")

plot(comparison, view = "differences") # Paired difference intervals.
```
