# Apply empirical-Bayes shrinkage to fitted non-person facet estimates

Post-hoc shrinkage helper that augments an `mfrm_fit` with James-Stein /
empirical-Bayes shrunk estimates for each non-person facet. The
shrinkage variance \\\hat{\tau}^2\\ is estimated by method of moments
from the facet-level point estimates and their standard errors:
\$\$\hat{\tau}^2 = \max\\\left(0,
\frac{1}{K}\sum\_{j=1}^{K}\hat{\delta}\_j^{2} -
\overline{\mathrm{SE}^2}\right),\$\$ where the first term is the
population variance of the facet point estimates around their *known*
mean of zero (the mfrmr sum-to-zero identification pins the facet mean
exactly at 0, so no degree of freedom is consumed by mean estimation).
The shrinkage factor is \\B_j = \mathrm{SE}\_j^2 / (\hat{\tau}^2 +
\mathrm{SE}\_j^2)\\, and the shrunk point / standard error are
\\\hat{\delta}\_j^{EB} = (1 - B_j)\hat{\delta}\_j\\ and
\\\mathrm{SE}\_j^{EB} = \sqrt{(1 - B_j)\mathrm{SE}\_j^2}\\. The
posterior SE form treats \\\hat{\tau}^2\\ as known; it omits the Morris
(1983, eqs. 4.1-4.2, p. 51) confidence-interval correction \\v \cdot
\hat{\delta}\_j^{2}\\ with \\v = 2 B_j^2 / (K - r - 2)\\, where \\r\\ is
the number of regression coefficients used to model the prior mean
(under mfrmr's sum-to-zero pinning, \\r = 0\\, so the divisor is \\K -
2\\). This correction adds variance proportional to the squared
deviation \\\hat{\delta}\_j^{2}\\, accounting for uncertainty in
\\\hat{\tau}^2\\. Under the equal-variance assumption
\\\hat{\delta}\_j^{2} \approx \hat{\tau}^2\\, the omitted variance is on
the order of \\2 / (K - 2)\\ times the reported posterior variance
\\V(1 - B_j)\\, so the true SE is approximately \\\sqrt{1 + 2/(K - 2)}\\
times the reported `ShrunkSE`. Magnitudes: SE understated by ~73\\ at
\\K = 8\\, ~7\\ `ShrunkSE` as a lower bound rather than a calibrated
posterior SE.

## Usage

``` r
apply_empirical_bayes_shrinkage(
  fit,
  facet_prior_sd = NULL,
  shrink_person = FALSE
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  with a non-empty `facets$others` table.

- facet_prior_sd:

  Optional numeric scalar. When supplied, the shrinkage variance is
  fixed at `facet_prior_sd^2` instead of being estimated from the data.
  Useful when a prior is elicited from expert knowledge or a previous
  fit.

- shrink_person:

  Logical. When `TRUE`, the same empirical-Bayes shrinkage is also
  applied to `fit$facets$person`. Default `FALSE`, since MML person
  estimates already reflect a N(0, sigma^2) prior.

## Value

The same `mfrm_fit`, with augmented columns and a new `shrinkage_report`
list entry, and with `fit$config$facet_shrinkage` set to
`"empirical_bayes"`.

## Details

`fit$facets$others` gains `ShrunkEstimate`, `ShrunkSE`, and
`ShrinkageFactor` columns, and `fit$shrinkage_report` records the
per-facet \\\hat{\tau}^2\\, mean shrinkage, and effective degrees of
freedom (\\\mathrm{EffectiveDF}\_f = \sum_j (1 - B_j)\\, which matches
the "effective number of parameters" defined by Efron & Morris, 1973).
The original `Estimate` / `SE` columns are preserved.

## Typical workflow

1.  Fit the model as usual with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Call `apply_empirical_bayes_shrinkage(fit)` when small-N facets are
    present (see
    [`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md)).

3.  Report both the original and shrunk estimates in the manuscript,
    citing Efron & Morris (1973).
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
    will add the sentence automatically when
    `fit$config$facet_shrinkage` is set.

## References

Efron, B., & Morris, C. (1973). Combining possibly related estimation
problems. *Journal of the Royal Statistical Society: Series B, 35*(3),
379-402.

Efron, B. (2021). *Empirical Bayes: Concepts and methods* (Technical
report). Department of Statistics, Stanford University.
<https://efron.ckirby.su.domains/papers/2021EB-concepts-methods.pdf>

Morris, C. N. (1983). Parametric empirical Bayes inference: Theory and
applications. *Journal of the American Statistical Association,
78*(381), 47-55.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
(which accepts `facet_shrinkage` directly),
[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md).

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
fit_eb <- apply_empirical_bayes_shrinkage(fit)
fit_eb$shrinkage_report
# Look for:
# - `Tau2` is the estimated between-level prior variance per facet.
#   `Tau2 = 0` means the data did not justify any pooling and the
#   shrunken estimates equal the raw estimates (`MeanShrinkage = 0`).
# - `MeanShrinkage` near 0 = little movement, near 1 = heavy pooling
#   toward 0. Small-N facets typically pull values further than
#   well-identified ones.
# - `EffectiveDF` is the implied "effective number of parameters"
#   (Efron & Morris 1973); EffectiveDF much smaller than the row
#   count of the facet means most levels were pooled together.
head(fit_eb$facets$others[, c("Facet", "Level", "Estimate",
                               "ShrunkEstimate", "ShrinkageFactor")])
# Look for: rows where `ShrinkageFactor` is large (close to 1) had
#   their estimates pulled most strongly toward the facet mean (0).
}
```
