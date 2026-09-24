# Compute diagnostics for an `mfrm_fit` object

Compute diagnostics for an `mfrm_fit` object

## Usage

``` r
diagnose_mfrm(
  fit,
  interaction_pairs = NULL,
  top_n_interactions = 20,
  whexact = FALSE,
  fit_df_method = c("engine", "facets", "both"),
  diagnostic_mode = c("both", "legacy", "marginal_fit"),
  residual_pca = c("none", "overall", "facet", "both"),
  pca_max_factors = 10L
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- interaction_pairs:

  Optional list of facet pairs.

- top_n_interactions:

  Number of top interactions.

- whexact:

  Logical controlling the ZSTD standardisation of mean-square fit
  statistics. `FALSE` (default) applies the Wilson-Hilferty cube-root
  transformation \\(\mathrm{MnSq}^{1/3} - (1 -
  2/(9\\\mathit{df})))/\sqrt{2/(9\\\mathit{df})}\\ (recommended; the
  Winsteps/FACETS convention for `WHEXACT=Y`). `TRUE` uses the simpler
  linear-normal standardisation \\(\mathrm{MnSq} -
  1)\sqrt{\mathit{df}/2}\\, which is kept for backward compatibility
  with earlier mfrmr summaries and with FACETS' `WHEXACT=N` mode.

- fit_df_method:

  Degrees-of-freedom convention used for fit ZSTD. `"engine"` (default)
  keeps the package-native convention `DF_Infit = sum(Var * Weight)` and
  `DF_Outfit = sum(Weight)`. `"facets"` uses the FACETS/Wright-Masters
  fourth-moment approximation `df = 2 / q^2` as the primary `InfitZSTD`
  / `OutfitZSTD` basis and caps reported ZSTD values at +/-9. `"both"`
  keeps the engine convention as the primary columns and adds `*_FACETS`
  companion columns for comparison.

- diagnostic_mode:

  Diagnostic basis to compute: `"both"` (the current default) computes
  both the residual/EAP-based stack and the strict latent-integrated
  first-order marginal-fit companion; `"legacy"` keeps the
  residual/EAP-based stack only; `"marginal_fit"` returns only the
  marginal-fit companion. The `"both"` path adds a posterior-integrated
  pass that typically doubles to quintuples wall-clock time relative to
  `"legacy"`; pass `"legacy"` explicitly when iterating on large designs
  and only the residual stack is needed. Use `"both"` for RSM/PCM
  reporting fits because it enables
  [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md)
  and
  [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)
  follow-up.

- residual_pca:

  Residual PCA mode: `"none"`, `"overall"`, `"facet"`, or `"both"`.

- pca_max_factors:

  Maximum number of PCA factors to retain per matrix.

## Value

An object of class `mfrm_diagnostics` including:

- `obs`: observed/expected/residual-level table

- `measures`: facet/person fit table (`Infit`, `Outfit`, `ZSTD`,
  `PTMEA`, `ModelSE`, `RealSE`, `CI_Lower`, `CI_Upper`, `CI_Level`,
  `CI_Method`)

- `overall_fit`: overall fit summary

- `fit`: element-level fit diagnostics

- `reliability`: facet-level model/real separation and reliability

- `precision_profile`: one-row summary of the active precision tier and
  its recommended use

- `precision_review`: package-native checks for SE, CI, and reliability

- `parameter_uncertainty`: MML observed-information uncertainty for
  structural parameters when available (`steps`, and bounded-`GPCM`
  `slopes` on both log and positive scales), plus covariance status
  metadata. Step `CIEligible` and `CIUse` retain the source fit's
  restrictions; non-unit observation-weight bands are diagnostic only.

- `facet_precision`: facet-level precision summary by distribution basis
  and SE mode

- `facets_chisq`: fixed/random facet variability summary

- `interactions`: top interaction diagnostics

- `interrater`: inter-rater agreement bundle (`summary`, `pairs`)
  including agreement and rater-severity spread indices

- `unexpected`: unexpected-response bundle

- `fair_average`: adjusted-score reference bundle (reported as
  unavailable for bounded `GPCM`)

- `displacement`: displacement diagnostics bundle

- `approximation_notes`: method notes for SE/CI/reliability summaries

- `diagnostic_basis`: guide to the statistical target of each diagnostic
  path

- `fit_standardization`: guide to the df convention behind fit ZSTD
  values

- `fit_readiness`, `fit_readiness_components`, and
  `fit_readiness_parameters`: the source fit's versioned readiness
  decision; diagnostic computation does not override a blocked or
  review-only fit

- `marginal_fit`: optional strict marginal-fit companion based on
  posterior-expected first-order category counts, with classification
  coverage

- `residual_pca_overall`: optional overall PCA object

- `residual_pca_by_facet`: optional facet PCA objects

- `replay_inputs`: diagnostic settings retained for reproducible export,
  including fit standardization, interaction selection, and PCA limits

## Details

This function computes a diagnostic bundle used by downstream reporting.
It calculates element-level fit statistics, approximate facet
separation/reliability summaries, residual-based QC diagnostics, and
optionally residual PCA for exploratory residual-structure screening.

`diagnostic_mode` keeps the legacy residual fit path explicit rather
than silently replacing it. The legacy path is a compatibility-oriented
residual/EAP stack, whereas the strict marginal path targets
latent-integrated first-order category counts. When
`diagnostic_mode = "both"`, the output includes a `diagnostic_basis`
guide so downstream tables and summaries can distinguish these targets.

Marginal expected counts integrate over each Person's posterior
conditioned on the same observed responses, holding fitted calibration
fixed. They are not expectations from an independent replication or a
prior-only population margin. First-order residual scales use
`sum(w^2 * p * (1-p))`; pairwise scales use the analogous formula with
products of row weights. These scales omit cross-response/opportunity
covariance and calibration-parameter uncertainty. They are descriptive
screens, not calibrated residual tests.

Missing/invalid contributing probabilities, scores or weights withhold
the affected complete-scope aggregate rather than selecting usable rows.
Missing standardized residuals and flags remain `NA`. A known cutoff
crossing stays flagged when a companion rule is unavailable.
`marginal_fit$coverage` records classified/unclassified cells, groups
and level pairs. Row/opportunity counts remain visible; zero-weight
opportunities contribute no information. Available maxima are
accompanied by classification/residual counts; they are not maxima over
unavailable values. RMSDs require the complete scope. In PCM and GPCM,
step-group summaries retain the declared `step_facet`. Regenerate older
marginal diagnostics and downstream summaries/plots/exports from the
existing fit and original diagnostic settings; no model refit is
required.

Choosing `diagnostic_mode`:

- `"legacy"`: use when continuity with historical residual-based
  workflows is the priority.

- `"marginal_fit"`: use when you want the strict latent-integrated
  screen without the extra legacy bundle.

- `"both"`: recommended when you want continuity with the legacy
  residual stack while making the strict marginal path explicit for
  `RSM`, `PCM`, and bounded `GPCM` fits.

For bounded `GPCM`, the same generalized partial credit kernel now
drives both the residual/probability tables and the strict marginal
category-fit companion. Residual-based MnSq summaries should still be
read as exploratory screening tools rather than strict Rasch-style
invariance tests because discrimination is free, and the strict marginal
companion should likewise be treated as a slope-aware screen rather than
a finalized inferential test family.

**Key fit statistics computed for each element:**

- **Infit MnSq**: information-weighted mean-square residual; sensitive
  to on-target misfitting patterns. Expected value = 1.0.

- **Outfit MnSq**: unweighted mean-square residual; sensitive to
  off-target outliers. Expected value = 1.0.

- **ZSTD**: Wilson-Hilferty cube-root transformation of MnSq to an
  approximate standard normal deviate.

- **PTMEA**: within-element point-measure correlation between observed
  scores and fitted person measures. A positive value is directionally
  consistent with the fitted orientation; it is not a confirmatory test.

The MnSq values and the ZSTD values should be read separately. `mfrmr`
keeps the package-native engine df convention by default because it is
the basis used by the fitted observation-level diagnostics. FACETS
reports closely related MnSq values but standardizes them with a
Wright-Masters fourth-moment df approximation (`df = 2 / q^2`) and caps
reported ZSTD values. Use `fit_df_method = "both"` to review these two
standardization conventions side by side without changing the primary
`InfitZSTD` / `OutfitZSTD` columns.

**Residual basis under MML.** For `method = "MML"` fits, residuals,
MnSq, and ZSTD are computed at the EAP person measures from the marginal
model. EAP measures are shrunken toward the population mean, so expected
scores – and therefore fit statistics – differ systematically from
JMLE-based engines such as FACETS, especially for persons with extreme
raw scores. The df conventions above do not remove this difference: it
is a residual-basis difference, not a standardization difference. Refit
with `method = "JML"` when an external FACETS fit comparison requires a
JMLE-style residual basis (see
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)).

**Heuristic misfit-screening guidelines (Bond & Fox, 2015):**

- MnSq \< 0.5: overfit (too predictable; may inflate reliability)

- MnSq 0.5–1.5: productive for measurement

- MnSq \> 1.5: underfit (noise degrades measurement)

- \\\|\mathrm{ZSTD}\| \ge 2\\: package convention for the
  approximate-normal review flag; not a calibrated 5\\ and repeated
  screening across elements

When Infit and Outfit disagree, Infit is generally more informative
because it downweights extreme observations. Large Outfit with
acceptable Infit typically indicates a few outlying responses rather
than systematic misfit.

`interaction_pairs` controls which facet interactions are summarized.
Each element can be:

- a length-2 character vector such as `c("Rater", "Criterion")`, or

- omitted (`NULL`) to let the function select top interactions
  automatically.

Residual PCA behavior:

- `"none"`: skip PCA (fastest; recommended for initial exploration)

- `"overall"`: compute overall residual PCA across all facets

- `"facet"`: compute facet-specific residual PCA for each facet

- `"both"`: compute both overall and facet-specific PCA

Overall PCA examines the person \\\times\\ combined-facet residual
matrix; facet-specific PCA examines person \\\times\\ facet-level
matrices. These summaries are exploratory screens for residual
structure, not standalone proofs for or against unidimensionality.
Facet-specific PCA can help localise where a stronger residual signal is
concentrated.

These residual-PCA summaries are not a DIMTEST/UNIDIM implementation.
DIMTEST-style essential-unidimensionality tests work at an item-response
layer and require an explicit decision about how many-facet rating data
are collapsed, conditioned, or adjusted for rater/task/facet effects.
For manuscripts, combine global/element fit, residual PCA, and
local-dependence screens, and use limited wording such as "evidence
consistent with essential unidimensionality under the specified facet
structure" rather than "unidimensionality was established."

## Reading key components

Practical interpretation often starts with:

- `overall_fit`: global infit/outfit and degrees of freedom.

- `reliability`: facet-level model/real separation and reliability.
  `MML` uses model-based `ModelSE` values where available; `JML` keeps
  these quantities as exploratory approximations.

- `fit`: element-level misfit scan (`Infit`, `Outfit`, `ZSTD`).

- `unexpected`, `fair_average`, `displacement`: targeted QC bundles. For
  bounded `GPCM`, `fair_average` is retained with an unavailable status
  because that compatibility calculation is outside the documented
  generalized-model contract.

- `approximation_notes`: method notes for SE/CI/reliability summaries.

## Interpreting output

Testlet and shared-rater fits use
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
instead of this ordinary-model route. Their same-data posterior
predictive residual summaries do not inherit ordinary fit cutoffs, ZSTD
or p-values.

Start with `overall_fit` and `reliability`, then move to element-level
diagnostics (`fit`) and targeted bundles (`unexpected`, `displacement`,
`interrater`, `facets_chisq`). Treat `fair_average` as available only
for the `RSM` / `PCM` branch.

Consistent signals across multiple components are typically more robust
than a single isolated warning. For example, an element flagged for both
high Outfit and high displacement is more concerning than one flagged on
a single criterion.

`SE` is kept as a compatibility alias for `ModelSE`. `RealSE` is a
fit-adjusted companion defined as `ModelSE * sqrt(max(Infit, 1))`.
Reliability tables report model and fit-adjusted indices from observed
variance minus mean squared SE, truncated at zero. Fit-adjusted values
are not confidence bounds; `JML` entries remain exploratory. Separation,
strata, and reliability follow the Wright & Masters (1982) conventions:
\\G = \mathrm{TrueSD}/\mathrm{RMSE}\\, \\R = G^2 / (1 + G^2)\\, and \\H
= (4G + 1) / 3\\.

Tables record finite-estimate counts and the available SEs on those same
levels. Non-finite estimates are excluded from the spread and SE
summaries. If any finite estimate lacks a valid SE, reliability,
separation, strata and error-adjusted spread are unavailable, rather
than combining different sets of levels. Excluded levels or incomplete
uncertainty prevent a facet summary from supporting formal reporting.
For EAP Persons, this separation-based index is distinct from
posterior-variance EAP reliability. High rater separation means
distinguishable rater measures, not high rater agreement.

Facet SEs from a regularized information matrix or an observation-table
fallback remain diagnostic approximations. They are labelled explicitly
and cannot authorize ordinary confidence-interval reporting. Numerical
convergence is reviewed separately from support for inference; switching
from JML to MML does not by itself establish valid SEs or intervals.
Recompute older diagnostic objects with `diagnose_mfrm(fit)` before
reporting; the existing fit can be used without refitting the model.

## Typical workflow

1.  Start with
    `diagnose_mfrm(fit, diagnostic_mode = "both", residual_pca = "none")`.

2.  Inspect `summary(diag)` and use `diagnostic_basis` to separate
    legacy residual evidence from strict marginal evidence.

3.  If needed, rerun with residual PCA (`"overall"` or `"both"`).

## References

- Wright, B. D., & Masters, G. N. (1982). *Rating scale analysis*. MESA
  Press. (G/R/H separation, reliability, and strata formulas summarized
  in `s_diag$reliability` follow this convention.)

- Wright, B. D., & Linacre, J. M. (1994). Reasonable mean-square fit
  values. *Rasch Measurement Transactions, 8*(3), 370. (Source for the
  0.5-1.5 Infit / Outfit heuristic review interval that
  `s_diag$key_warnings` and `misfit_thresholds` apply.)

- Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA Press.
  (FACETS Tables 6 + 7 correspond to the per-facet element measures,
  fit, and chi-square heterogeneity screen exposed via
  `s_diag$reliability` and `s_diag$facets_chisq`.)

- Bond, T. G., & Fox, C. M. (2015). *Applying the Rasch model:
  Fundamental measurement in the human sciences* (3rd ed.). Routledge.
  (Reference text for the Rasch-family fit conventions exposed by this
  helper.)

- Linacre, J. M. (2002). What do Infit and Outfit, Mean-square and
  Standardized mean? *Rasch Measurement Transactions, 16*(2), 878.

- Linacre, J. M. (2026). *A user's guide to Facets Rasch-model computer
  programs*. Winsteps.com. (WHEXACT / FACETS standardized fit df notes.)

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)

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

# Check model fit and the support for standard errors and intervals
diagnostics <- diagnose_mfrm(fit)
diagnostic_summary <- summary(diagnostics)
diagnostic_summary$decision
#>               Interpretation FormalInference FitReadiness
#> 1 Ready for formal inference             Yes        ready
#>                                           Why
#> 1 All stored fit-readiness components passed.
#>                                                                                            NextAction
#> 1 Inspect `diagnostic_basis` before comparing legacy residual evidence with strict marginal evidence.

diagnostic_summary$key_warnings # Issues to investigate, if present
#> [1] "Unexpected responses flagged: 60."                                                                                                 
#> [2] "Flagged displacement levels: 1."                                                                                                   
#> [3] "MnSq screening flagged 18 element(s) outside the configured 0.5-1.5 band."                                                         
#> [4] "Person-level fit warnings: 18 row(s); identifiers suppressed. Use `include_person = TRUE` only under appropriate privacy controls."
#> [5] "Strict marginal fit flagged 1 group-level summaries."                                                                              
diagnostic_summary$top_fit      # Most unusual residual-based fit statistics
#> # A tibble: 10 × 9
#>    Facet     Level   Infit Outfit InfitZSTD OutfitZSTD DF_Infit DF_Outfit  AbsZ
#>    <chr>     <fct>   <dbl>  <dbl>     <dbl>      <dbl>    <dbl>     <dbl> <dbl>
#>  1 Person    P026    0.126  0.117     -1.90      -2.46     4.06         6  2.46
#>  2 Person    P022    0.126  0.123     -1.94      -2.42     4.23         6  2.42
#>  3 Person    P016    2.66   2.53       1.68       2.08     2.94         6  2.08
#>  4 Criterion Content 0.730  0.743     -1.56      -1.89    58.5         94  1.89
#>  5 Rater     R05     0.648  0.640     -1.34      -1.87    25.1         44  1.87
#>  6 Person    P035    0.239  0.237     -1.45      -1.79     4.36         6  1.79
#>  7 Person    P008    0.251  0.250     -1.40      -1.73     4.34         6  1.73
#>  8 Person    P025    2.22   2.18       1.55       1.73     4.18         6  1.73
#>  9 Person    P012    2.01   2.17       1.35       1.72     4.05         6  1.72
#> 10 Person    P017    0.265  0.285     -1.25      -1.59     3.85         6  1.59

# Distinguish residual-based checks from marginal model checks
diagnostic_summary$diagnostic_basis[, c("DiagnosticPath", "Status", "Basis")]
#> # A tibble: 4 × 3
#>   DiagnosticPath                   Status        Basis                          
#>   <chr>                            <chr>         <chr>                          
#> 1 legacy_residual_fit              computed      plugin_residuals_and_eap_tables
#> 2 strict_marginal_fit              computed      latent_integrated_first_order_…
#> 3 strict_pairwise_local_dependence computed      latent_integrated_second_order…
#> 4 posterior_predictive_follow_up   not_available posterior_predictive_replicati…
# }
```
