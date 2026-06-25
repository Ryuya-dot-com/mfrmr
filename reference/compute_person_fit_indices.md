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
  status.

## Value

A data frame of class `mfrm_person_fit_indices` with one row per Person
and columns:

- `Person`:

  Person ID.

- `N`:

  Number of contributing response opportunities.

- `LogLik`:

  Sum of log P(X = x \| theta) under the fitted model. Computed from the
  per-observation category probability `PrObserved` (the model
  probability of the observed category), not from a Gaussian residual
  approximation.

- `lz`:

  Drasgow et al. (1985) standardized log-likelihood, in its proper
  polytomous form.

- `lz_star`:

  Snijders-corrected `lz*` when the source fit used JML/fixed-effect
  person estimates, conditioning on the fitted non-person calibration,
  and the diagnostics include the required derivative terms; otherwise
  `NA`.

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

  The same flags for `lz_star`, returned as `FALSE` when `lz_star` is
  unavailable.

- `ReportIndex`, `ReportValue`, `ReportFlagLevel`, `ReportFlag`,
  `ReviewStatus`, `ReviewReason`, `ReportCaveat`:

  Compact reporting columns. `ReportIndex` prefers `lz_star` when the
  Snijders correction was computed; otherwise it falls back to `lz` with
  an explicit caveat.

Under the conditional-independence assumption of the MFRM, `lz` is
asymptotically standard normal. Practical reporting thresholds: \|lz\|
\> 1.96 flags a person at the 5% level; \|lz\| \> 2.58 at the 1% level.
When `lz_star_status == "computed_jml_conditional_calibration"`,
`lz_star` applies Snijders' estimated-ability correction for JML person
estimates, conditional on the fitted non-person parameters. This does
not propagate non-person calibration uncertainty. For MML/EAP person
scores, use `lz` with its documented caveat rather than treating EAP
scores as if they satisfied the Snijders estimating equation.

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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none",
                      diagnostic_mode = "legacy")
pf <- compute_person_fit_indices(diag, fit = fit)
head(pf)
summary(pf)
# Look for: |lz| > 1.96 (5% level) flags a person whose response
#   pattern is statistically inconsistent with the model; > 2.58 is
#   a 1% flag. lz_star is populated for JML/fixed-effect person
#   estimates and left NA for MML/EAP estimates. Use ReportIndex /
#   ReviewStatus for a compact report-ready reading.
}
```
