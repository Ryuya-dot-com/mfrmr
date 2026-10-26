# Compute diagnostics for an `mfrm_fit` object

Compute diagnostics for an `mfrm_fit` object

## Usage

``` r
diagnose_mfrm(
  fit,
  interaction_pairs = NULL,
  top_n_interactions = 20,
  whexact = FALSE,
  fit_df_method = "facets",
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

  ZSTD transformation. `FALSE` (default) uses Wilson-Hilferty with the
  q/3 term (FACETS `WHEXACT=YES`); `TRUE` omits that term (FACETS
  `WHEXACT=NO`), where q = sqrt(2/df). The historical logical names are
  retained. `"legacy_linear"` explicitly requests the former TRUE
  calculation, (MnSq - 1) \* sqrt(df/2), which is not FACETS WHEXACT=NO.

- fit_df_method:

  Degrees-of-freedom convention used for fit ZSTD. `"facets"` (default)
  uses the Wright-Masters fourth-moment approximation `df = 2 / q^2` and
  caps reported ZSTD at +/-9. `"engine"` retains
  `DF_Infit = sum(Var * Weight)` and `DF_Outfit = sum(Weight)`. `"both"`
  uses engine primary columns and adds `*_FACETS` companions. Engine
  transformations require df \>= 1; the FACETS route admits df \> 0.

- diagnostic_mode:

  Diagnostic basis to compute: `"both"` (the current default) computes
  both the residual/EAP-based stack and the strict latent-integrated
  first-order marginal-fit companion; `"legacy"` keeps the
  residual/EAP-based stack only; `"marginal_fit"` returns only the
  marginal-fit companion. The `"both"` path adds a posterior-integrated
  pass that typically doubles to quintuples wall-clock time relative to
  `"legacy"`; pass `"legacy"` explicitly when iterating on large designs
  and only the residual stack is needed. Use `"both"` for RSM/PCM
  reporting fits because it enables [plot(x, type =
  "marginal_fit")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
  and [plot(x, type =
  "marginal_pairwise")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
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
  `CI_Method`). `Fixed = TRUE` identifies location values fixed by
  anchors or identification constraints. Their sampling SEs and normal
  intervals are `NA` (not estimated, not a numerical failure). Free
  levels retain their estimator-specific SEs. Aggregate
  reliability/separation and facet variability tests are unavailable for
  facets containing fixed values; response-fit diagnostics remain
  available. This convention differs from
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md),
  which represents a fixed target's conditional covariance as zero, also
  without an interval. Neither route propagates uncertainty in supplied
  anchor values.

- `overall_fit`: overall fit summary

- `fit`: element-level fit diagnostics

- `reliability`: facet-level model/real separation and reliability

- `precision_profile`: one-row summary of the active precision tier and
  its recommended use

- `precision_review`: package-native checks for SE, CI, and reliability

- `parameter_uncertainty`: MML observed-information uncertainty for
  structural parameters when available (`steps`, and `GPCM` `slopes` on
  both log and positive scales), plus covariance status metadata. Step
  `CIEligible` and `CIUse` retain the source fit's restrictions;
  non-unit observation-weight bands are diagnostic only. GPCM MML
  relative slopes use the separate
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
  checks and pointwise log-Wald approximation; inspect `CIEligible`,
  `CIUse` and `InferenceReview`.

- `facet_precision`: facet-level precision summary by distribution basis
  and SE mode

- `facets_chisq`: fixed/random facet variability summary

- `interactions`: top interaction diagnostics

- `interrater`: inter-rater agreement bundle (`summary`, `pairs`)
  including agreement and rater-severity spread indices

- `unexpected`: unexpected-response bundle

- `fair_average`: adjusted-score reference bundle (reported as
  unavailable for `GPCM`)

- `displacement`: displacement diagnostics bundle

- `approximation_notes`: method notes for SE/CI/reliability summaries

- `diagnostic_basis`: guide to the statistical target of each diagnostic
  path

- `fit_standardization`: guide to the df convention behind fit ZSTD
  values

- `fit_readiness`, `fit_readiness_components`, and
  `fit_readiness_parameters`: the source fit's versioned readiness
  decision; diagnostic computation does not override global fit
  readiness. GPCM slope parameter rows additionally retain the
  output-specific interval decision

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

**Legacy response calculations.** Saved MML EAPs are matched to
responses by Person identifier. JML retains optimizer-coordinate
probabilities for compatibility diagnostics. In `obs`, `PersonMeasure`
records the ability used, `PrimaryPersonMeasure` records the primary
estimate (possibly infinite), and `PersonMeasureBasis` identifies the
calculation. A finite JML optimizer value is not a finite primary
estimate at a boundary. For supported ordinary fits,
[fitted()](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_responses.md)
instead uses primary JML limits. The posterior/corrected-JML targets
have their own documented routes in
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md).

`obs$ConditionalVariance` retains the actual conditional variance.
Legacy `Var`, `StdResidual` and `StdSq` are withheld when that variance
is at or below `1e-10`. A positive value below this cutoff is a
diagnostic screening convention, not a mathematically undefined Pearson
residual; [residuals(fit,
"pearson")](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_responses.md)
retains representable positive variances within its supported scope. A
zero variance makes the Pearson residual undefined. Expected ratings and
raw residuals can remain available in either case. `PearsonAvailable`,
`ResponseStatus` and `ResponseReason` explain each row, and are retained
in score/residual file tables.

Overall and element-level mean squares require every contributing row's
standardized residual, variance and positive weight. If any is
unavailable, the aggregate and its degrees of freedom remain `NA`;
missing residuals are not counted as zero misfit or silently excluded.
`FitResponseRows`, `FitAvailableRows` and `FitUnavailableRows` count
rows (not weight totals), while `FitStatus` and `FitReason` explain
availability. These fields accompany `overall_fit`, `fit` and
`measures`. FACETS-style degrees of freedom also require complete fourth
moments. Regenerate older diagnostics and exports from the saved fit to
obtain these explanations; model refitting is not required.

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
  `RSM`, `PCM`, and `GPCM` fits.

For `GPCM`, the same generalized partial credit kernel now drives both
the residual/probability tables and the strict marginal category-fit
companion. Residual-based MnSq summaries should still be read as
exploratory screening tools rather than strict Rasch-style invariance
tests because discrimination is free, and the strict marginal companion
should likewise be treated as a slope-aware screen rather than a
finalized inferential test family.

**Key fit statistics computed for each element:**

- **Infit MnSq**: information-weighted mean-square residual; sensitive
  to on-target misfitting patterns. Expected value = 1.0.

- **Outfit MnSq**: unweighted mean-square residual; sensitive to
  off-target outliers. Expected value = 1.0.

- **ZSTD**: Wilson-Hilferty cube-root transformation of MnSq to an
  approximate standard normal deviate.

- **PTMEA**: within-element point-measure correlation between observed
  scores and the oriented sum of model measures (`obs$MeasureSum`),
  including Person rows. A positive value is directionally consistent
  with the fitted orientation; it is not a confirmatory test.

The MnSq values and the ZSTD values should be read separately. `mfrmr`
keeps the fourth-moment df convention by default. The former engine
convention remains explicit. This changes some ZSTD screening decisions,
not the underlying MnSq. MML residual diagnostics remain EAP plug-in
quantities; this standardization does not make them posterior-integrated
fit tests. Use `fit_df_method = "both"` to review these two
standardization conventions side by side, using engine primary columns
and FACETS companion columns.

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
ConQuest MML parameter fit also has a different target: residuals are
aggregated through the response design for each parameter, then averaged
over posterior ability distributions. Its Infit averages a ratio, rather
than dividing separately averaged residual sums and variances. Posterior
integration of row residuals alone does not reproduce that statistic.
Native marginal category-count diagnostics are another target. See the
[ConQuest technical manual](https://conquestmanual.acer.org/s3-00.html).

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

## Saved diagnostic definitions

New diagnostics carry `calculation_version = 2L`. Recreate older
diagnostics with `diagnose_mfrm(fit)` before using current reports; no
refit is needed. For historical ZSTD use `fit_df_method = "engine"` and,
if applicable, `whexact = "legacy_linear"`. PTMEA, displacement,
eligible chi-square df, fair scores and unexpected-response defaults use
the corrected definitions.

## Reading key components

Practical interpretation often starts with:

- `overall_fit`: global infit/outfit and degrees of freedom.

- `reliability`: facet-level model/real separation and reliability.
  `MML` uses model-based `ModelSE` values where available; `JML` keeps
  these quantities as exploratory approximations.

- `fit`: element-level misfit scan (`Infit`, `Outfit`, `ZSTD`).

- `unexpected`, `fair_average`, `displacement`: targeted QC bundles. For
  `GPCM`, `fair_average` is retained with an unavailable status because
  that compatibility calculation is outside the documented
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
uncertainty prevent a facet summary from supporting formal reporting. A
facet containing fixed values also has no aggregate reliability,
separation or strata: a fixed anchor's zero conditional variance is not
evidence of perfect measurement. Fixing a group mean alone does not fix
each group member. For EAP Persons, this separation-based index is
distinct from posterior-variance EAP reliability. High rater separation
means distinguishable rater measures, not high rater agreement.

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

## Expected point-measure correlation under ordinary JML

For ordinary additive RSM/PCM JML without group-mean anchors,
`measures$PTMEAExpected` adds a conditional reference beside observed
`PTMEA`. Let `x` be the oriented generating measure, `e` the expected
score, `v` its conditional model variance, and `N` the sum of frequency
weights within the element. The reference is
\$\$\frac{\operatorname{Cov}\_w(x,e)}{
\sqrt{\operatorname{Var}\_w(x)\\\operatorname{Var}\_w(e)+(N-2)\bar
v_w/N\\}}.\$\$ Weighted moments use the same observations and normalized
frequency weights. `PTMEAExpectedAsymptotic` omits the `(N-2)/N`
adjustment. The correction is Linacre's published finite-count reporting
approximation; it is not an exact expectation of the sample correlation,
a significance test or a confidence interval. Calibration is held fixed.
Different administered PCM scales are retained when calculating each
observation's expectation and variance.

`PTMEAExpectedN`, `PTMEAExpectedFactor`, `PTMEAExpectedStatus` and
`PTMEAExpectedReason` identify the calculation and unavailable states.
At `N = 2` the variance term vanishes; this does not establish perfect
measurement or fit. Below `N = 2`, the corrected reference is
unavailable (FACETS 4.5.0 can instead display a boundary value). The
asymptotic reference remains available if its moments exist. Arbitrarily
normalizing weights changes the corrected reference: use replication
semantics for comparison. Constant predictors, invalid moments, or
observations involving unanchored extreme main effects withhold the
complete element's expected reference; they are not silently dropped.
Fixed finite anchors remain usable.

FACETS 4.5.0 fixed-calibration PCM checks cover missing assignments and
unit, integer, fractional and unequal replication weights. These checks
establish a reporting convention within that scope, not general
diagnostic calibration. Observed `PTMEA` retains its existing
definition. MML, corrected JML, GPCM, fitted interactions and group-mean
anchors do not receive the new expected-correlation columns. Recreate
older diagnostics from the saved fit to obtain them; old saved results
are not relabeled or silently recalculated. See Linacre (2008), *The
Expected Value of a Point-Biserial (or Similar) Correlation*, Rasch
Measurement Transactions, 22:1, 1154, including its later finite-count
note: <https://www.rasch.org/rmt/rmt221e.htm>.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)

## Examples

``` r
# Load the package and example ratings
library(mfrmr)
ratings <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1, rating_max = 4, category_policy = "preserve",
  method = "MML",
  model = "RSM"
)

# Check model fit and the support for standard errors and intervals
diagnostics <- diagnose_mfrm(fit)
# Check each residual's basis and the coverage of aggregate fit statistics
head(diagnostics$obs[, c("PersonMeasureBasis", "ConditionalVariance",
  "PearsonAvailable", "ResponseReason")])
#>   PersonMeasureBasis ConditionalVariance PearsonAvailable
#> 1          saved EAP           0.6713656             TRUE
#> 2          saved EAP           0.6916274             TRUE
#> 3          saved EAP           0.6130873             TRUE
#> 4          saved EAP           0.7109476             TRUE
#> 5          saved EAP           0.7234085             TRUE
#> 6          saved EAP           0.4352147             TRUE
#>                                                                    ResponseReason
#> 1 Conditional point calculation; calibration and Person uncertainty are excluded.
#> 2 Conditional point calculation; calibration and Person uncertainty are excluded.
#> 3 Conditional point calculation; calibration and Person uncertainty are excluded.
#> 4 Conditional point calculation; calibration and Person uncertainty are excluded.
#> 5 Conditional point calculation; calibration and Person uncertainty are excluded.
#> 6 Conditional point calculation; calibration and Person uncertainty are excluded.
diagnostics$overall_fit[, c("Infit", "Outfit", "FitUnavailableRows", "FitReason")]
#> # A tibble: 1 × 4
#>   Infit Outfit FitUnavailableRows FitReason                                     
#>   <dbl>  <dbl>              <int> <chr>                                         
#> 1 0.866  0.857                  0 Descriptive mean squares; their calculation d…
diagnostic_summary <- summary(diagnostics)
diagnostic_summary$decision
#>               Interpretation FormalInference FitReadiness
#> 1 Ready for formal inference             Yes        ready
#>                                           Why
#> 1 All stored fit-readiness components passed.
#>                                                                                            NextAction
#> 1 Inspect `diagnostic_basis` before comparing legacy residual evidence with strict marginal evidence.

diagnostic_summary$key_warnings # Issues to investigate, if present
#> [1] "Unexpected responses flagged: 1."                                                                                                  
#> [2] "Flagged displacement levels: 1."                                                                                                   
#> [3] "MnSq screening flagged 18 element(s) outside the configured 0.5-1.5 band."                                                         
#> [4] "Person-level fit warnings: 18 row(s); identifiers suppressed. Use `include_person = TRUE` only under appropriate privacy controls."
#> [5] "Strict marginal fit flagged 1 group-level summaries."                                                                              
diagnostic_summary$top_fit      # Most unusual residual-based fit statistics
#> # A tibble: 10 × 13
#>    Facet     Level   Infit Outfit InfitZSTD OutfitZSTD DF_Infit DF_Outfit
#>    <chr>     <fct>   <dbl>  <dbl>     <dbl>      <dbl>    <dbl>     <dbl>
#>  1 Person    P022    0.126  0.123     -2.86      -2.88     8.20      8.17
#>  2 Person    P026    0.126  0.117     -2.78      -2.84     7.75      7.71
#>  3 Criterion Content 0.730  0.743     -2.27      -2.09   119.      113.  
#>  4 Person    P035    0.239  0.237     -2.24      -2.25     8.90      8.91
#>  5 Person    P016    2.66   2.53       2.19       2.06     5.95      5.85
#>  6 Person    P008    0.251  0.250     -2.16      -2.17     8.79      8.79
#>  7 Person    P025    2.22   2.18       2.09       2.03     8.94      8.92
#>  8 Rater     R05     0.648  0.640     -1.98      -1.97    51.5      48.5 
#>  9 Person    P012    2.01   2.17       1.72       1.91     7.85      7.78
#> 10 Person    P017    0.265  0.285     -1.90      -1.79     7.42      7.33
#> # ℹ 5 more variables: InfitZSTD_FACETS <dbl>, OutfitZSTD_FACETS <dbl>,
#> #   DF_Infit_FACETS <dbl>, DF_Outfit_FACETS <dbl>, AbsZ <dbl>

# Distinguish residual-based checks from marginal model checks
diagnostic_summary$diagnostic_basis[, c("DiagnosticPath", "Status", "Basis")]
#> # A tibble: 4 × 3
#>   DiagnosticPath                   Status        Basis                          
#>   <chr>                            <chr>         <chr>                          
#> 1 legacy_residual_fit              computed      plugin_residuals_and_eap_tables
#> 2 strict_marginal_fit              computed      latent_integrated_first_order_…
#> 3 strict_pairwise_local_dependence computed      latent_integrated_second_order…
#> 4 posterior_predictive_follow_up   not_available posterior_predictive_replicati…
# Each row is one bundled example rating; use ordinary JML for this reference
ratings <- load_mfrmr_data("example_core")
jml_fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                     method = "JML", model = "RSM")
jml_diagnostics <- diagnose_mfrm(jml_fit, residual_pca = "none",
                                 diagnostic_mode = "legacy")
head(jml_diagnostics$measures[, c("Facet", "Level", "PTMEA",
     "PTMEAExpected", "PTMEAExpectedN", "PTMEAExpectedStatus")])
#> # A tibble: 6 × 6
#>   Facet  Level   PTMEA PTMEAExpected PTMEAExpectedN PTMEAExpectedStatus  
#>   <chr>  <chr>   <dbl>         <dbl>          <dbl> <chr>                
#> 1 Person P001   0.123          0.287             16 available_conditional
#> 2 Person P002  -0.0905         0.238             16 available_conditional
#> 3 Person P003   0.355          0.262             16 available_conditional
#> 4 Person P004  -0.0554         0.279             16 available_conditional
#> 5 Person P005  -0.215          0.279             16 available_conditional
#> 6 Person P006   0.196          0.263             16 available_conditional
# Compare observed PTMEA with its conditional reference; neither is a test
```
