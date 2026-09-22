# Apply empirical-Bayes shrinkage to fitted non-person facet estimates

Post-hoc normal-model shrinkage helper that augments an `mfrm_fit` with
descriptive empirical-Bayes adjustments for each non-person facet. The
shrinkage variance \\\hat{\tau}^2\\ is estimated by method of moments
from the facet-level point estimates and their standard errors:
\$\$\hat{\tau}^2 = \max\\\left(0,
\frac{1}{K}\sum\_{j=1}^{K}\hat{\delta}\_j^{2} -
\overline{\mathrm{SE}^2}\right),\$\$ where zero is the chosen shrinkage
target and the moment is calculated on complete finite
estimate/positive-SE pairs. A sum-to-zero identification constraint does
not establish a known population mean or independent errors. The
shrinkage factor is \\B_j = \mathrm{SE}\_j^2 / (\hat{\tau}^2 +
\mathrm{SE}\_j^2)\\, with \\\hat{\delta}\_j^{EB} =
(1-B_j)\hat{\delta}\_j\\ and \\\mathrm{ShrunkSE}\_j =
\sqrt{(1-B_j)\mathrm{SE}\_j^2}\\.

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

`ShrunkSE` is a plug-in normal-model quantity conditional on the
selected prior variance. It omits uncertainty in that variance,
cross-level covariance and the fitted identification/anchor constraints.
It is neither a calibrated SE nor a guaranteed lower bound. Unequal
shrinkage can break the original sum-to-zero constraint. Original
estimates, anchors and predictions are unchanged; this helper does not
refit a hierarchical MFRM.

A zero estimated prior variance fully pools eligible estimates at zero
and gives zero plug-in SE; this does not establish perfect precision.
Optional plot whiskers are descriptive normal bands. Their legacy `CI`
column names do not confer confidence-interval coverage;
`SupportsFormalInference` is false. Invalid estimate/SE pairs retain
their original values with unavailable shrinkage factors. With fewer
than three valid pairs no shrinkage is applied.

The report records complete-pair counts and mean shrinkage over those
pairs. `EffectiveDF` sums retained weights over eligible levels,
conditional on the chosen prior variance; it is not model degrees of
freedom for testing or IC. Reapply this helper to existing fits to
refresh old reports; no MFRM refit is needed. Regenerate previously
saved plots and exports as well. Reapplication replaces the previous
adjustment; `shrink_person = FALSE` removes any previous Person
shrinkage columns. The original fitting inputs remain recorded
separately from the latest post-fit shrinkage settings.
[`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md)
replays the adjustment after fitting, preserving whether diagnostic SEs
were attached by
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
Manually edited SEs or other table edits require their own reproducible
editing steps.

## Typical workflow

1.  Fit the model as usual with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Call `apply_empirical_bayes_shrinkage(fit)` when small-N facets are
    present and zero-centered pooling is substantively defensible (see
    [`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md));
    small counts alone do not require it.

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
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
fit_eb <- apply_empirical_bayes_shrinkage(fit)
fit_eb$shrinkage_report
#>       Facet NLevels NLevelsUsed       Tau2     MeanSE2 MeanShrinkage
#> 1     Rater       4           4 0.06403506 0.009500135     0.1291914
#> 2 Criterion       4           4 0.05259214 0.009500604     0.1530053
#>   EffectiveDF          Method PriorSource Note SupportsFormalInference
#> 1    3.483234 empirical_bayes   empirical <NA>                   FALSE
#> 2    3.387979 empirical_bayes   empirical <NA>                   FALSE
#>                                                                                                                                                             Interpretation
#> 1 Descriptive zero-centered adjustment; plug-in SEs/bands omit prior-variance uncertainty and cross-level covariance. Zero SE after full pooling is not perfect precision.
#> 2 Descriptive zero-centered adjustment; plug-in SEs/bands omit prior-variance uncertainty and cross-level covariance. Zero SE after full pooling is not perfect precision.
# Look for:
# - `Tau2` is the estimated between-level prior variance per facet.
#   `Tau2 = 0` fully pools eligible estimates at zero
#   (`MeanShrinkage = 1`). Zero plug-in SE is not perfect precision.
# - `MeanShrinkage` near 0 = little movement, near 1 = heavy pooling
#   toward the chosen zero target; inspect the SEs and prior variance.
# - `EffectiveDF` sums retained weights over eligible levels, conditional
#   on the chosen prior variance; it is not degrees of freedom for testing.
head(fit_eb$facets$others[, c("Facet", "Level", "Estimate",
                               "ShrunkEstimate", "ShrinkageFactor")])
#>       Facet    Level   Estimate ShrunkEstimate ShrinkageFactor
#> 1     Rater      R01 -0.1957561     -0.1705417       0.1288054
#> 2     Rater      R02 -0.3287963     -0.2861443       0.1297216
#> 3     Rater      R03  0.1910876      0.1665002       0.1286707
#> 4     Rater      R04  0.3334649      0.2902585       0.1295680
#> 5 Criterion Accuracy  0.2487261      0.2106946       0.1529051
#> 6 Criterion  Content -0.4150580     -0.3508239       0.1547593
# Look for: rows where `ShrinkageFactor` is large (close to 1) had
#   their estimates pulled most strongly toward the facet mean (0).
# }
```
