# Build APA text outputs from model results

Build APA text outputs from model results

## Usage

``` r
build_apa_outputs(
  fit,
  diagnostics,
  bias_results = NULL,
  context = list(),
  whexact = FALSE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- context:

  Optional named list for report context.

- whexact:

  Use exact ZSTD transformation.

## Value

An object of class `mfrm_apa_outputs` with:

- `report_text`: APA-oriented Method/Results draft prose

- `decision`: plain-language source-fit interpretation plus the separate
  precision-contract decision; `FormalInference` is `"Yes"` only when
  both fit readiness and `contract$precision$supports_formal_inference`
  support it

- `fit_readiness`, `fit_readiness_components`, and
  `fit_readiness_parameters`: exact source-fit readiness provenance

- `table_figure_notes`: consolidated draft notes for tables/visuals

- `table_figure_captions`: draft caption candidates without figure
  numbering

- `section_map`: package-native section table for manuscript assembly

- `contract`: structured APA reporting contract used for downstream
  checks

## Details

`context` is an optional named list for narrative customization.
Frequently used fields include:

- `assessment`, `setting`, `scale_desc`

- `rater_training`, `raters_per_response`

- `rater_facet` (used for targeted reliability note text)

- `line_width` (optional text wrapping width for `report_text`; default
  = 92)

Output text includes residual-PCA screening commentary if PCA
diagnostics are available in `diagnostics`.

For bounded `GPCM`, this helper returns a caveated partial reporting
bundle over supported diagnostics, direct tables, and plots. It also
includes a `gpcm_boundary` table. Treat the output as slope-aware
sensitivity-reporting text, not FACETS score-side equivalence, automatic
operational scoring, or design-forecasting evidence.

By default, `report_text` includes:

- model/data design summary (N, facet counts, scale range)

- optimization/convergence metrics (`Converged`, `Iterations`, `LogLik`)
  plus the eligible canonical MML AIC/Person-BIC/SABIC panel or its
  explicit ineligibility and legacy-descriptive status; q\<31 MML
  criteria are explicitly labelled screening/review-only rather than
  automatic ranking

- anchor/constraint summary (`noncenter_facet`, anchored levels, group
  anchors, dummy facets)

- latent-regression population-model wording when `fit` has an active
  `population_formula`

- category/threshold diagnostics (including disordered-step details when
  present)

- overall fit, misfit count, and top misfit levels

- facet reliability/separation, residual PCA summary, and bias-screen
  counts

## Interpreting output

- `report_text`: manuscript-draft narrative covering Method (model
  specification, estimation, convergence) and Results (global fit, facet
  separation/reliability, misfit triage, category diagnostics,
  residual-PCA screening, bias screening), organized as an APA-oriented,
  third-person Method/Results draft. It is intended for human review and
  is not a claim of complete APA 7 or JARS compliance.

- `table_figure_notes`: reusable draft note blocks for table/figure
  appendices.

- `table_figure_captions`: draft caption candidates aligned to generated
  outputs.

- active latent-regression fits add a population-model section and Table
  5 notes/captions that distinguish conditional-normal coefficient
  reporting from post hoc regression on EAP/MLE scores.

When bias results or PCA diagnostics are not supplied, those sections
are omitted from the narrative rather than producing placeholder text.
Reporting reuses stored residual PCA results and does not compute
omitted overall or facet-specific analyses. Request the intended scope
with `diagnose_mfrm(..., residual_pca = "overall")`, `"facet"`, or
`"both"` first.

## Typical workflow

1.  Build diagnostics (and optional bias results). For `RSM` / `PCM`
    reporting runs, prefer an `MML` fit and
    `diagnose_mfrm(..., diagnostic_mode = "both")`.

2.  Run `build_apa_outputs(...)`.

3.  Check `summary(apa)` for completeness.

4.  Insert `apa$report_text` and note/caption fields into manuscript
    drafts after checking the listed cautions.

## Context template

A minimal `context` list can include fields such as:

- `assessment`: name of the assessment task

- `setting`: administration context

- `scale_desc`: short description of the score scale

- `rater_facet`: rater facet label used in narrative reliability text

## Input validation

`fit` must be an `mfrm_fit` object from
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
`diagnostics` must be an `mfrm_diagnostics` object from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
`context` must be a list (use `NULL` or
[`list()`](https://rdrr.io/r/base/list.html) for no extra context). If
supplied, `bias_results` must come from
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
or another package-native bias helper that provides a table component.

## See also

[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
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

# Compute diagnostics once for the following checks
diagnostics <- diagnose_mfrm(fit)

# Prepare draft wording from the fitted model and diagnostics
apa <- build_apa_outputs(
  fit,
  diagnostics = diagnostics,
  context = list(
    assessment = "Synthetic writing assessment",
    setting = "Demonstration dataset",
    scale_desc = "1-4 rating scale",
    rater_facet = "Rater"
  )
)

# Check which sections are supported, then read the draft
apa_review <- summary(apa)
apa_review$content_checks
#>                           Check Passed
#> 1        Method section heading   TRUE
#> 2       Results section heading   TRUE
#> 3   Precision caution alignment   TRUE
#> 4 Bias screening note alignment   TRUE
#> 5         Residual PCA coverage   TRUE
#> 6                 Note coverage   TRUE
#> 7              Caption coverage   TRUE
#> 8         Core section coverage   TRUE
#> 9  Interrater summary alignment   TRUE
#>                                                                            Detail
#> 1                               APA narrative should begin with a Method heading.
#> 2                                 APA narrative should include a Results heading.
#> 3                               No extra precision caution required for this run.
#> 4                                               No bias screening block required.
#> 5    Residual PCA availability should be reflected in prose, notes, and captions.
#> 6       All note-map entries should be represented in the consolidated note text.
#> 7 All caption-map entries should be represented in the consolidated caption text.
#> 8            Core package-native sections should be available in the section map.
#> 9         Interrater agreement wording should appear in the report text or notes.
cat(apa$report_text)
#> Method.
#> 
#> Design and data.
#> The analysis focused on Synthetic writing assessment in Demonstration dataset. A many-facet
#> rating-scale Rasch model was fit to 282 observations from 48 persons scored on a 4-category
#> scale (1-4). The design included facets for Rater (n = 6), Criterion (n = 3). Facet-level
#> sample sizes met the package's `standard` band (smallest level N = 38), an mfrmr-specific
#> watermark adapted from Linacre's (1994) 30/100 guidance; facets were nonetheless estimated
#> as fixed effects with sum-to-zero identification (see `facet_small_sample_review()`). The
#> rating scale was described as 1-4 rating scale.
#> 
#> Estimation settings.
#> The RSM specification was estimated using MML with mfrmr. Model-based precision summaries
#> were available for this run. Person measures are expected a posteriori (EAP) estimates
#> under the marginal person distribution, and residual-based fit statistics are evaluated at
#> these EAP measures rather than at joint maximum likelihood (JMLE) estimates. Recommended
#> use for this precision profile: Uncertainty is conditional on the fitted model. Person
#> posterior SDs condition on the fitted calibration; facet standard errors use observed
#> information. Review interval assumptions before reporting.. Optimization met the numerical
#> convergence checks after 28 function evaluations and 28 gradient evaluations (LogLik =
#> -347.240, canonical MML AIC = 712.480, Person-BIC = 729.320, Sclove SABIC = 701.085). MML
#> integration used fixed Gauss-Hermite quadrature (q=31). Terminal gradient sup-norm = 0.0000
#> (review threshold = 0.0001). Constraint settings: noncenter facet = Person; anchored levels
#> = 0 (facets: none); group anchors = 0 (facets: none); dummy facets = none.
#> 
#> Results.
#> 
#> Scale functioning.
#> Category counts were available for all 4 categories: 0 unused and 0 below 10. Counts alone
#> do not establish category adequacy. Adjacent threshold comparisons: 0 decreasing among 2
#> available; 0 of 2 comparisons unavailable. Available estimates range from -1.22 to 1.06
#> logits. Adjacent threshold comparisons: 0 decreasing among 2 available; 0 of 2 comparisons
#> unavailable.
#> 
#> Facet measures.
#> Person measures ranged from -1.72 to 1.51 logits (M = -0.16, SD = 0.82). Rater measures
#> ranged from -0.61 to 0.41 logits (M = -0.00, SD = 0.40). Criterion measures ranged from
#> -0.34 to 0.22 logits (M = 0.00, SD = 0.30).
#> 
#> Fit and precision.
#> Overall mean-square fit was within the 0.5-1.5 screening band (infit MnSq = 0.87, outfit
#> MnSq = 0.86). This band is the package's review convention; published mean-square
#> guidelines differ, and band position is screening evidence rather than a model-validity
#> decision. MnSq outside [0.5, 1.5]: 18 of 57 classified elements flagged; 0 of 57 elements
#> unclassified. Largest misfit signals among 57 elements with complete paired statistics:
#> Person:P026 (|ZSTD| = 2.46); Person:P022 (|ZSTD| = 2.42); Person:P016 (|ZSTD| = 2.08).
#> Criterion reliability = 0.87 (separation = 2.56). Person reliability = 0.66 (separation =
#> 1.41). Rater reliability = 0.68 (separation = 1.45). These are Rasch/FACETS-style
#> separation indices (measure spread relative to measurement error), not inter-rater
#> agreement. The Person row uses EAP measures with posterior SDs, which yields a conservative
#> summary that is not numerically comparable to JMLE-based person reliability from FACETS.
#> Observed inter-rater agreement is reported separately from separation reliability: for
#> Rater, exact agreement = 0.39, expected exact agreement = 0.35, adjacent agreement = 0.86.
#> Element-level 95% approximate intervals (Normal approximation) accompany 57 of 57
#> estimates; 57 of 57 estimates have intervals eligible for primary reporting.
#> 
#> Residual structure.
#> Overall categories: 0 flagged among 4 classified; 0 of 4 unavailable. Step/scale groups: 0
#> flagged among 1 classified; 0 of 1 unavailable. Facet levels: 1 flagged among 9 classified;
#> 0 of 9 unavailable. Level pairs: 1 flagged among 9 classified; 0 of 9 unavailable. Expected
#> counts condition on the same responses through Person posteriors, with fitted calibration
#> held fixed. Residual scales omit cross-response covariance and calibration-parameter
#> uncertainty; thresholds are descriptive, not calibrated tests. Strict marginal screening
#> gives an overall RMSD of 0.01, overall max |standardized residual| = 0.43. The largest
#> strict marginal cell involved Criterion: Content | Cat 4 (standardized residual = -1.53,
#> proportion difference = -0.06). Strict pairwise local-dependence follow-up flagged 1 level
#> pair(s) under the latent-integrated agreement screen. The largest strict pairwise signal
#> involved Rater: R04 vs R05 (exact-agreement standardized residual = 2.09,
#> adjacent-agreement standardized residual = 0.22).
#> 
#> Reporting cautions.
#> Fit-basis note: MnSq/ZSTD fit statistics in this run were computed at EAP person measures,
#> which are shrunken toward the population mean; they are therefore not numerically
#> interchangeable with JMLE-based engines such as FACETS. Refit with method = "JML" when a
#> JMLE-style residual basis is required for external comparison.
# Adapt the text to the study question, design, and evidence before using it
# }
```
