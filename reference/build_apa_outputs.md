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

- `report_text`: APA-style Method/Results draft prose

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

- optimization/convergence metrics (`Converged`, `Iterations`, `LogLik`,
  `AIC`, `BIC`)

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
  residual-PCA screening, bias screening). Written in third-person past
  tense following APA 7th edition conventions, but still intended for
  human review.

- `table_figure_notes`: reusable draft note blocks for table/figure
  appendices.

- `table_figure_captions`: draft caption candidates aligned to generated
  outputs.

- active latent-regression fits add a population-model section and Table
  5 notes/captions that distinguish conditional-normal coefficient
  reporting from post hoc regression on EAP/MLE scores.

When bias results or PCA diagnostics are not supplied, those sections
are omitted from the narrative rather than producing placeholder text.

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
# Minimal APA-output example using a JML fit and lightweight diagnostics.
toy <- load_mfrmr_data("example_core")
fit_quick <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag_quick <- diagnose_mfrm(fit_quick,
  residual_pca = "none",
  diagnostic_mode = "legacy"
)
apa_quick <- build_apa_outputs(fit_quick, diag_quick)
nchar(apa_quick$report_text) > 0
#> [1] TRUE

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", quad_points = 7, maxit = 30
)
diag <- diagnose_mfrm(fit, residual_pca = "both", diagnostic_mode = "both")
apa <- build_apa_outputs(
  fit,
  diag,
  context = list(
    assessment = "Toy writing task",
    setting = "Demonstration dataset",
    scale_desc = "0-2 rating scale",
    rater_facet = "Rater"
  )
)
s_apa <- summary(apa)
s_apa$overview
#>   Components NonEmptyComponents TotalCharacters TotalNonEmptyLines Sections
#> 1          3                  3            9634                121        9
#>   AvailableSections ContentChecks ContentChecksPassed DraftContractPass
#> 1                 7             9                   9              TRUE
#>   ReadyForAPA
#> 1        TRUE
# Look for: `SentenceCount` non-zero in every section that the run
#   should support (Method / Results / fit / reliability / bias).
#   Zero counts mean that section's prose is empty and the
#   manuscript will need to fill it manually.
chk <- reporting_checklist(fit, diagnostics = diag)
head(chk$checklist[, c("Section", "Item", "DraftReady", "NextAction")])
#>          Section                                                      Item
#> 1 Method Section                                       Model specification
#> 2 Method Section                                          Data description
#> 3 Method Section                                           Precision basis
#> 4 Method Section                                               Convergence
#> 5 Method Section                                     Connectivity assessed
#> 6 Method Section Empirical-Bayes shrinkage when small-N facets are present
#>   DraftReady
#> 1       TRUE
#> 2       TRUE
#> 3       TRUE
#> 4       TRUE
#> 5       TRUE
#> 6       TRUE
#>                                                                                                          NextAction
#> 1                             Available; adapt this evidence into the manuscript draft after methodological review.
#> 2                             Available; adapt this evidence into the manuscript draft after methodological review.
#> 3                                                    Report the precision tier as model-based in the APA narrative.
#> 4                             Available; adapt this evidence into the manuscript draft after methodological review.
#> 5                                           Document the single connected subset before making common-scale claims.
#> 6 Report both the fixed-effects and shrunk estimates; cite Efron & Morris (1973) for the empirical-Bayes rationale.
# Look for: rows with `DraftReady = "yes"` are ready to paste into
#   the manuscript. `"no"` rows tell you which helper / setting
#   needs to run before that paragraph can be drafted, via
#   `NextAction`. Aim for every Visual Displays / Reliability /
#   Diagnostics row to be `"yes"` before submitting.
cat(apa$report_text)
#> Method.
#> 
#> Design and data.
#> The analysis focused on Toy writing task in Demonstration dataset. A many-facet
#> rating-scale Rasch model was fit to 768 observations from 48 persons scored on a 4-category
#> scale (1-4). The design included facets for Rater (n = 4), Criterion (n = 4). Facet-level
#> sample sizes were strong (smallest level N = 192), though facets were still estimated as
#> fixed effects with sum-to-zero identification; `analyze_hierarchical_structure()` is
#> available for nesting and variance-component follow-up. The rating scale was described as
#> 0-2 rating scale.
#> 
#> Estimation settings.
#> The RSM specification was estimated using MML with mfrmr. Model-based precision summaries
#> were available for this run. Person measures are expected a posteriori (EAP) estimates
#> under the marginal person distribution, and residual-based fit statistics are evaluated at
#> these EAP measures rather than at joint maximum likelihood (JMLE) estimates. Recommended
#> use for this precision profile: Use for primary reporting of SE, CI, and reliability in
#> this package.. Optimization met the package convergence checks after 13 function
#> evaluations and 13 gradient evaluations (LogLik = -903.080, AIC = 1822.161, BIC =
#> 1859.311). Terminal gradient sup-norm = 0.0001 (review threshold = 0.0001). Optimizer
#> returned convergence code 0. Constraint settings: noncenter facet = Person; anchored levels
#> = 0 (facets: none); group anchors = 0 (facets: none); dummy facets = none.
#> 
#> Results.
#> 
#> Scale functioning.
#> Category usage was adequate (unused categories = 0, low-count categories = 0), and
#> thresholds were ordered. Step/threshold summary: 3 step(s); estimate range = -1.30 to 1.35
#> logits; no disordered steps.
#> 
#> Facet measures.
#> Person measures ranged from -2.02 to 2.33 logits (M = 0.03, SD = 1.01). Rater measures
#> ranged from -0.32 to 0.33 logits (M = -0.00, SD = 0.31). Criterion measures ranged from
#> -0.41 to 0.24 logits (M = 0.00, SD = 0.28).
#> 
#> Fit and precision.
#> Overall mean-square fit was within the 0.5-1.5 screening band (infit MnSq = 0.99, outfit
#> MnSq = 1.01). This band is the package's review convention; published mean-square
#> guidelines differ, and band position is screening evidence rather than a model-validity
#> decision. 1 of 56 elements fell outside the 0.5-1.5 mean-square screening band. Largest
#> misfit signals: Person:P023 (|ZSTD| = 2.09); Criterion:Organization (|ZSTD| = 1.69);
#> Person:P018 (|ZSTD| = 1.45). Criterion reliability = 0.91 (separation = 3.21). Person
#> reliability = 0.90 (separation = 3.06). Rater reliability = 0.92 (separation = 3.51). These
#> are Rasch/FACETS-style separation indices (measure spread relative to measurement error),
#> not inter-rater agreement. The Person row uses EAP measures with posterior SDs, which
#> yields a conservative summary that is not numerically comparable to JMLE-based person
#> reliability from FACETS. Observed inter-rater agreement is reported separately from
#> separation reliability: for Rater, exact agreement = 0.36, expected exact agreement = 0.37,
#> adjacent agreement = 0.83. Element-level 95% confidence intervals (Normal approximation)
#> accompany the measures (CI_Lower / CI_Upper); 56 of 56 rows are flagged CIEligible for
#> primary reporting.
#> 
#> Residual structure.
#> Exploratory residual PCA (overall standardized residual matrix) showed PC1 eigenvalue =
#> 2.10 (13.2% variance), with PC2 eigenvalue = 1.79. Facet-specific exploratory residual PCA
#> showed the largest first-component signal in Rater (eigenvalue = 1.55, 38.7% variance).
#> Heuristic reference bands: EV >= 1.4 (critical minimum), >= 1.5 (caution), >= 2.0 (common),
#> >= 3.0 (strong); variance >= 5% (minor), >= 10% (caution), >= 20% (strong). Strict marginal
#> screening was available as a latent-integrated exploratory check (overall RMSD = 0.00,
#> overall max |standardized residual| = 0.48). The largest strict marginal cell involved
#> Criterion: Language | Cat 1 (standardized residual = 2.47, proportion difference = 0.06).
#> Strict pairwise local-dependence follow-up flagged 0 level pair(s) under the
#> latent-integrated agreement screen. The largest strict pairwise signal involved Criterion:
#> Language vs Organization (ExactStdResidual = -1.45, AdjacentStdResidual = 0.39).
#> 
#> Reporting cautions.
#> Fit-basis note: MnSq/ZSTD fit statistics in this run were computed at EAP person measures,
#> which are shrunken toward the population mean; they are therefore not numerically
#> interchangeable with JMLE-based engines such as FACETS. Refit with method = "JML" when a
#> JMLE-style residual basis is required for external comparison.
apa$section_map[, c("SectionId", "Available")]
#>                    SectionId Available
#> 1              method_design      TRUE
#> 2          method_estimation      TRUE
#> 3              results_scale      TRUE
#> 4           results_measures      TRUE
#> 5   results_population_model     FALSE
#> 6      results_fit_precision      TRUE
#> 7 results_residual_structure      TRUE
#> 8     results_bias_screening     FALSE
#> 9           results_cautions      TRUE

# }
```
