# Review response fit and the support for uncertainty summaries

Compute observation residuals, element/overall `Infit` and `Outfit`
(`MnSq` and `ZSTD`), `PTMEA`, model/real SEs, facet
separation/reliability/strata, fixed/random facet chi-square screens,
inter-rater agreement, unexpected responses, fair averages,
displacement, and optional marginal-fit or residual PCA diagnostics for
an ordinary `RSM`/`PCM` or one-family `GPCM`
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
object.

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

# S3 method for class 'mfrm_diagnostics'
summary(
  object,
  digits = 3,
  top_n = 10,
  detail = c("brief", "full"),
  include_person = FALSE,
  ...
)

# S3 method for class 'mfrm_diagnostics'
plot(
  x,
  type = c("marginal_fit", "marginal_pairwise", "bubble", "residual_pca"),
  view = NULL,
  ...
)
```

## Arguments

- fit:

  Ordinary `RSM`, `PCM`, or one-family `GPCM`
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  result (testlet, random-rater, corrected-JML, and two-family GPCM fits
  use
  [`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)).

- interaction_pairs:

  Optional list of length-two facet-name vectors to screen for pairwise
  residual interactions (`NULL` screens all non-Person facet pairs).

- top_n_interactions:

  Maximum number of largest-magnitude interaction rows retained in the
  quick-preview table (`20` default).

- whexact:

  Logical or `"legacy_linear"` controlling the Wilson-Hilferty cube-root
  standardization for `InfitZSTD` and `OutfitZSTD` (`FALSE` = FACETS
  `WHEXACT=YES` with `q/3` mean term; `TRUE` = `WHEXACT=NO`;
  `"legacy_linear"` = unadjusted linear Z).

- fit_df_method:

  Standardization variance/df convention: `"facets"` (default;
  fourth-moment variance `2/q^2` with `ZSTD` capped at `+/-9`),
  `"engine"` (count-based df), or `"both"` (`df < 1` or infinite-primary
  JML proxy rows withhold `ZSTD`).

- diagnostic_mode:

  `"both"` (default: plug-in residual + posterior marginal
  category-count screens), `"legacy"`, or `"marginal_fit"`.

- residual_pca:

  Exploratory residual PCA scope: `"none"` (default), `"overall"`,
  `"facet"`, or `"both"`.

- pca_max_factors:

  Maximum number of principal components extracted when
  `residual_pca != "none"` (`10L` default).

- object:

  Output from `diagnose_mfrm()`.

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of highest-absolute-Z fit rows to keep.

- detail:

  Console detail: `"brief"` (default) prints the first-screen review;
  `"full"` prints the additional structured tables.

- include_person:

  If `TRUE`, person-level identifiers may be printed in fit-review
  tables. The default keeps identifiers out of console output;
  person-level rows remain available in the returned object.

- ...:

  All views accept `draw = FALSE`, `top_n`, and `preset`. Marginal views
  accept `facet`; pairwise plots additionally accept `metric = "exact"`
  or `"adjacent"`. Bubbles accept `fit_stat` (`"Infit"` or `"Outfit"`),
  `bubble_size` (`"SE"`, `"N"`, or `"equal"`), `facets`,
  `include_person = FALSE`, `marginal = c("auto", "histogram", "none")`,
  and the heuristic `fit_range = c(0.5, 1.5)`. PCA accepts `mode`,
  `facet`, and `component`, as described in
  [`plot.mfrm_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md).
  Controls for other views are rejected.

- x:

  An `mfrm_diagnostics` result from `diagnose_mfrm()`.

- type:

  `"marginal_fit"`, `"marginal_pairwise"`, `"bubble"`, or
  `"residual_pca"`.

- view:

  For marginal fit, `"std_residual"` (default) or `"prop_diff"`; for
  bubbles, `"measure"` (default) or `"infit_outfit"`; for PCA,
  `"scree"`, `"parallel_scree"`, `"parallel_excess"`, or `"loadings"`.
  Omit it for `"marginal_pairwise"` and use `metric` instead.

## Value

An `mfrm_diagnostics` object (`calculation_version = 2L`) containing
`obs`, `measures`, `overall_fit`, `fit`, `reliability`,
`precision_profile`, `precision_review`, `parameter_uncertainty`,
`facet_precision`, `facets_chisq`, `interactions`, `interrater`,
`unexpected`, `fair_average`, `displacement`, `marginal_fit`,
`residual_pca_*`, `fit_readiness*`, and `replay_inputs`.

An object of class `summary.mfrm_diagnostics` with:

- `overview`: design-level counts and residual-PCA mode

- `decision`: the same plain-language fit-readiness decision used by
  `summary(fit)`, retained ahead of diagnostic screening results

- `fit_readiness`, `fit_readiness_components`, and
  `fit_readiness_parameters`: readiness provenance inherited from the
  source fit and retained separately from diagnostic-screening status

- `status`: concise front-door status block for quick review

- `key_warnings`: highest-priority warnings to review first

- `next_actions`: recommended follow-up helpers

- `diagnostic_basis`: guide to legacy versus strict diagnostic targets

- `fit_standardization`: guide to the df convention used for fit ZSTD

- `overall_fit`: global fit block

- `precision_profile`: active precision tier and recommended use of the
  available uncertainty calculations

- `precision_review`: separation / reliability / strata review for the
  sample- and population-basis modes (paired with `precision_profile`)

- `reliability`: facet-level separation/reliability summary

- `facets_chisq`: facets-style fixed-effect chi-square heterogeneity
  screen across non-person facets

- `interrater`: inter-rater agreement / pairwise correlation / rater
  separation overview when a Rater facet is present

- `misfit_flagged`: rows flagged by the Infit / Outfit mean-square band

- `fit_screening`: counts of all, classified and unclassified elements
  for the mean-square band and each ZSTD cutoff. Either available
  statistic crossing a cutoff flags the element; otherwise a missing
  statistic leaves it unclassified. Rates require every element to be
  classified. Nonfinite statistics and negative mean squares are
  unavailable, not passing values.

- `misfit_thresholds`: named numeric vector with the misfit `lower` /
  `upper` thresholds used to populate `misfit_flagged`

- `category_usage`: per-category response-frequency summary used to flag
  empty / collapsed categories

- `top_fit`: top maximum `|ZSTD|` rows with both statistics available

- `marginal_coverage`: classified, unclassified and flagged category
  cells, groups and level pairs; counts of available flags do not
  describe missing results

- `marginal_fit`: optional strict marginal-fit overview when requested

- `top_marginal_cells`: largest strict marginal residual cells when
  requested

- `marginal_pairwise`: optional strict pairwise local-dependence
  overview

- `top_marginal_pairs`: largest strict pairwise residual summaries

- `marginal_guidance`: interpretation labels for strict marginal
  diagnostics

- `reporting_map`: manuscript-oriented guide to what is covered here
  versus which companion outputs should be consulted

- `flags`: compact flag counts for major diagnostics

- `notes`: short interpretation notes

- `digits`: numeric-print precision threaded through to
  `print.summary.mfrm_diagnostics()`

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to inspect its tables and notes. The plot does not add unavailable
diagnostics or qualify intervals.

## Details

**Fit, SE, and separation conventions.** MML residuals plug in Person
EAPs; legacy JML residuals use optimizer coordinates
(`PersonMeasureBasis`; variances `<= 1e-10` withhold standardized
residuals, and any unavailable contributing row sets element `MnSq`/`df`
to `NA` via `FitStatus`/`FitReason`).
`RealSE = ModelSE * sqrt(max(Infit, 1))` inflates `ModelSE` for underfit
(`Fixed = TRUE` anchors keep `NA` SEs and suppress aggregate facet
reliability). Wright and Masters (1982) separation indices use sample
`SD` (`n - 1`) and `RMSE` across finite free levels
(`TrueSD = sqrt(max(SD^2 - RMSE^2, 0))`, \\G =
\mathrm{TrueSD}/\mathrm{RMSE}\\, \\R = G^2/(1 + G^2)\\, \\H = (4G +
1)/3\\); rater separation measures severity spread rather than
inter-rater agreement.

Read `decision` and `key_warnings`, then use the tables below to locate
results needing investigation. The summary reuses diagnostics; it does
not refit or promote a restricted source fit to inferential use.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
saved ordinary-model diagnostics

Inspect an existing diagnostic result to locate cells or elements
needing follow-up. The selected display retains unavailable results and
screening limits.

## Interpreting results

- `Infit`/`Outfit` have model-reference value 1. Values above 1 describe
  excess residual variation; values below 1 describe greater
  predictability. `InfitZSTD`/`OutfitZSTD` standardize those mean
  squares; they are not effect sizes or calibrated tests after fitting
  and repeated screening. `top_fit` ranks only rows with both ZSTD
  values available. Its absence of a level does not establish acceptable
  fit; inspect `object$fit` and `FitReason` for unavailable
  standardizations.

- `Reliability`/`Separation` describe how spread out facet measures are
  relative to their estimated error. `RealReliability`/`RealSeparation`
  use fit-inflated SEs, not lower confidence limits. High rater
  separation can indicate severity differences, not agreement. Read
  `ReliabilityBasis`, `ReliabilityUse` and the computation details in
  `diagnose_mfrm()`.

- `fit_screening` distinguishes classified from unclassified elements. A
  known cutoff crossing remains flagged if another statistic is missing;
  missing evidence is not a pass. Flags guide review, not automatic
  deletion.

- `diagnostic_basis` distinguishes EAP plug-in response residuals from
  posterior-integrated category-count screens. They answer different fit
  questions; neither label alone authorizes a hypothesis test.

- In `overview`, `Observations` counts retained rating rows and
  `Persons` counts respondents. Repeated ratings of one Person do not
  create additional independent Persons.

## Choosing a view

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

Marginal fit and pairwise plots require strict marginal diagnostics from
`diagnose_mfrm()` with `diagnostic_mode = "both"` or `"marginal_fit"`
for supported MML RSM/PCM models. Positive residuals indicate more
observed category usage or agreement than expected; negative values
indicate less. Returned `full_table` and `retention` distinguish omitted
and unavailable rows. A flag is a descriptive review rule, not a
calibrated test.

Bubble plots place measures against mean-square fit, or Infit against
Outfit. Bubble size can represent SE or observation count; neither a
review band nor bubble size alone justifies deleting an element.

The PCA convenience route can derive PCA from the diagnostic result. For
repeated PCA displays, first save
[`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
and use its [`plot()`](https://rdrr.io/r/graphics/plot.default.html)
method. Parallel-reference generation remains an analysis step.

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

## References

Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA Press.

Wright, B. D., & Masters, G. N. (1982). *Rating scale analysis*. MESA
Press.

Wright, B. D., & Linacre, J. M. (1994). Reasonable mean-square fit
values. *Rasch Measurement Transactions, 8*(3), 370.

Linacre, J. M. (2002). What do Infit and Outfit, Mean-square and
Standardized mean? *Rasch Measurement Transactions, 16*(2), 878.
<https://www.rasch.org/rmt/rmt162f.htm>

Yen, W. M. (1984). Effects of local item dependence on the fit and
equating performance of the three-parameter logistic model. *Applied
Psychological Measurement, 8*(2), 125–145.
[doi:10.1177/014662168400800201](https://doi.org/10.1177/014662168400800201)

Linacre, J. M. (2026). *A user's guide to Facets Rasch-model computer
programs*. Winsteps.com.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)

[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md)

[`plot.mfrm_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("diagnose_mfrm", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
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
diagnostic_summary <- summary(diagnostics)
diagnostic_summary$decision

diagnostic_summary$key_warnings # Issues to investigate, if present
diagnostic_summary$top_fit      # Most unusual residual-based fit statistics

# Distinguish residual-based checks from marginal model checks
diagnostic_summary$diagnostic_basis[, c("DiagnosticPath", "Status", "Basis")]

# Check each residual's basis and the coverage of aggregate fit statistics
head(diagnostics$obs[, c("PersonMeasureBasis", "ConditionalVariance",
  "PearsonAvailable", "ResponseReason")])
diagnostics$overall_fit[, c("Infit", "Outfit", "FitUnavailableRows", "FitReason")]
} # }
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Check model fit and the support for standard errors and intervals
diagnostics <- example_fit$diagnostics
diagnostic_summary <- summary(diagnostics)
diagnostic_summary$decision
#>               Interpretation FormalInference FitReadiness
#> 1 Ready for formal inference             Yes        ready
#>                                                                                                                                                                                                                                 Why
#> 1 All stored fit-readiness components passed. These checks assess numerical readiness and the requested precision method under the specified model; they do not establish model adequacy or finite-sample coverage for this design.
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
# Long-running workflow; run explicitly when needed.
# example("diagnose_mfrm", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Each row is one bundled example rating; use ordinary JML for this reference
ratings <- load_mfrmr_data("example_core")
jml_fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                     method = "JML", model = "RSM")
jml_diagnostics <- diagnose_mfrm(jml_fit, residual_pca = "none",
                                 diagnostic_mode = "legacy")
head(jml_diagnostics$measures[, c("Facet", "Level", "PTMEA",
     "PTMEAExpected", "PTMEAExpectedN", "PTMEAExpectedStatus")])
# Compare observed PTMEA with its conditional reference; neither is a test
} # }
```
