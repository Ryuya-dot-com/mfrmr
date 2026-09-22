# Person fit indices: lz and Snijders-corrected lz\*

Computes person-level fit statistics for an MFRM bundle, extending the
Infit / Outfit / ZSTD columns that `diagnose_mfrm()$measures` already
exposes with the standardized log-likelihood `lz` and, when justified by
the person-estimation method, Snijders' `lz*`.

## Usage

``` r
compute_person_fit_indices(diagnostics, fit = NULL)
```

## Arguments

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- fit:

  Optional `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Required to decide whether the person estimates are JML/fixed-effect
  estimates for which the Snijders (2001) correction is computed.
  MML/EAP person scores return `NA` for `lz_star` with an explanatory
  status. Supplied fit and diagnostics must identify the same analysis.

## Value

A data frame of class `mfrm_person_fit_indices` with one row per Person
and columns:

- `Person`:

  Person ID.

- `TotalN`, `N`, `UnavailableN`:

  Total responses, responses with valid probability and log-likelihood
  moments, and unavailable responses. An incomplete response set does
  not produce a person-fit statistic.

- `LogLik`:

  Sum of log P(X = x \| theta) under the fitted model. Computed from the
  per-observation category probability `PrObserved` (the model
  probability of the observed category), not from a Gaussian residual
  approximation.

- `lz`:

  Drasgow et al. (1985) standardized log-likelihood, in its polytomous
  form, treating each retained response once regardless of calibration
  weights. `lz_status` records computational availability.

- `lz_star`:

  Snijders-corrected `lz*` when the source fit used JML/fixed-effect
  person estimates, conditioning on the fitted non-person calibration,
  and the diagnostics include the required derivative terms. Numerical
  convergence, a finite person estimate and unit observation weights are
  required; otherwise `NA`.

- `lz_star_status`:

  Status string for `lz_star`, such as
  `"computed_jml_conditional_calibration"`, `"fit_required"`,
  `"not_applicable_eap"`, or `"insufficient_information"`.

- `lz_star_c`:

  Estimated Snijders projection coefficient `c_n` for each person, when
  available.

- `lz_star_variance`:

  Corrected variance denominator used for `lz_star`, when available.

- `lz_flag_5pct`, `lz_flag_1pct`:

  Logical flags for practical two-sided `lz` thresholds of `|z| > 1.96`
  and `|z| > 2.58`.

- `lz_star_flag_5pct`, `lz_star_flag_1pct`:

  The same flags for `lz_star`. All index flags, including `ReportFlag`,
  remain `NA` when the corresponding statistic is unavailable.

- `ReportIndex`, `ReportValue`, `ReportFlagLevel`, `ReportFlag`,
  `ReviewStatus`, `ReviewReason`, `ReportCaveat`:

  Compact reporting columns. `ReportIndex` prefers `lz_star` when the
  Snijders correction was computed; otherwise it falls back to `lz` with
  an explicit caveat.

The `5pct` and `1pct` flag names refer to standard-normal reference
cutoffs: \|lz\| \> 1.96 and \|lz\| \> 2.58. Treat them as screening
thresholds, not a guarantee of those false-positive rates for fitted
person scores. Read `ReportCaveat` and `lz_star_status` with every
flagged result. When
`lz_star_status == "computed_jml_conditional_calibration"`, `lz_star`
applies Snijders' estimated-ability correction for JML person estimates,
conditional on the fitted non-person parameters. This does not propagate
non-person calibration uncertainty. For MML/EAP person scores, use `lz`
with its documented caveat rather than treating EAP scores as if they
satisfied the Snijders estimating equation. Positive and negative flags
indicate more and less predictable patterns, respectively; neither alone
establishes invalid responses or justifies exclusion. The implemented
correction does not cover non-unit observation weights, even if
normalized to mean one. No multiple-person error-rate control is
provided.

Small positive probabilities are used without a lower floor. Zero,
invalid or missing observed probabilities make the person statistic
unavailable. Missing derivative information withholds the correction for
the whole person. With the matching fit supplied, older
probability-moment diagnostics are refreshed from that fit without
re-estimation. Otherwise recompute diagnostics first. Older saved
person-fit tables/summaries must be rebuilt.

Note: this implementation reads the model category probabilities
directly from the diagnostics bundle. Earlier mfrmr releases used a
Gaussian-residual approximation \\\log P(X = x) \approx
-\tfrac{1}{2}(R^2/V) - \tfrac{1}{2}\log(2\pi V)\\ as a stand-in for
\\\log P\\, which overstated the per-item variance of \\\log P\\ for
polytomous items, shrinking the reported `lz` toward zero. Numerical
`lz` values are therefore not directly comparable across mfrmr releases;
treat the values returned here as the polytomous statistic and
re-evaluate any historical `|lz| > 1.96` flagging that was based on the
earlier approximation.

## References

- Drasgow, F., Levine, M. V., & Williams, E. A. (1985). Appropriateness
  measurement with polychotomous item response models and standardized
  indices. *British Journal of Mathematical and Statistical Psychology,
  38*(1), 67-86.

- Snijders, T. A. B. (2001). Asymptotic null distribution of person fit
  statistics with estimated person parameter. *Psychometrika, 66*(3),
  331-342.

- Magis, D., Raiche, G., & Beland, S. (2012). A didactic presentation of
  Snijders's lz\* index of person fit with emphasis on response model
  selection and ability estimation. *Journal of Educational and
  Behavioral Statistics, 37*(1), 57-81.

- Sinharay, S. (2016). Asymptotically correct standardization of
  person-fit statistics beyond dichotomous items. *Psychometrika,
  81*(4), 992-1013.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
# \donttest{
# Load the package and example ratings
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# Compute diagnostics once for the following checks
diagnostics <- diagnose_mfrm(fit)

# Screen for unusual person response patterns
person_fit <- compute_person_fit_indices(diagnostics, fit = fit)
head(person_fit[, c("Person", "N", "ReportIndex", "ReportValue", "ReviewStatus")])
#>   Person N ReportIndex ReportValue ReviewStatus
#> 1   P001 5          lz  0.40405734  not_flagged
#> 2   P002 6          lz -0.49464167  not_flagged
#> 3   P003 6          lz -0.48719030  not_flagged
#> 4   P004 6          lz  0.06122145  not_flagged
#> 5   P005 6          lz  1.06480928  not_flagged
#> 6   P006 5          lz  0.59431547  not_flagged

# Inspect flagged persons and the limitations of their reported index
subset(person_fit, ReportFlag,
       c("Person", "ReportValue", "ReviewReason", "ReportCaveat"))
#>    Person ReportValue                                          ReviewReason
#> 12   P012   -2.043880 lz exceeds the absolute normal-reference cutoff 1.96.
#> 25   P025   -2.537499 lz exceeds the absolute normal-reference cutoff 1.96.
#>                                                                                                                     ReportCaveat
#> 12 lz is an uncorrected, unweighted response-pattern screen. The implemented correction does not apply to MML/EAP person scores.
#> 25 lz is an uncorrected, unweighted response-pattern screen. The implemented correction does not apply to MML/EAP person scores.
# With MML/EAP scores, lz_star is unavailable; lz is an uncorrected screening index
# A flag alone does not establish invalid responses or justify excluding a person
# }
```
