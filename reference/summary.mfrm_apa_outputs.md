# Summarize APA report-output bundles

Summarize APA report-output bundles

## Usage

``` r
# S3 method for class 'mfrm_apa_outputs'
summary(object, top_n = 3, preview_chars = 160, ...)
```

## Arguments

- object:

  Output from
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

- top_n:

  Maximum non-empty lines shown in each component preview.

- preview_chars:

  Maximum characters shown in each preview cell.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_apa_outputs`.

## Details

This summary is a diagnostics layer for APA text products, not a
replacement for the full narrative.

It reports component completeness, line/character volume, and a compact
preview for quick QA before manuscript insertion.

## Interpreting output

- `overview`: total coverage across standard text components.

- `decision`: the source-fit decision shown before draft-completeness
  checks; text completeness cannot promote a review or blocked fit.

- `components`: per-component density and mention checks (including
  residual-PCA mentions).

- `sections`: package-native section coverage table.

- `content_checks`: contract-based alignment checks for APA drafting
  readiness.

- `overview$DraftContractPass`: the primary contract-completeness flag
  for draft text components.

- `overview$ReadyForAPA`: a backward-compatible alias of that contract
  flag, not a certification of inferential adequacy.

- `preview`: first non-empty lines for fast visual review.

## Typical workflow

1.  Build outputs via
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

2.  Run `summary(apa)` to screen for empty/short components.

3.  Use `apa$report_text`, `apa$table_figure_notes`, and
    `apa$table_figure_captions` as draft components for final-text
    review.

## See also

[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
apa <- build_apa_outputs(fit, diag)
summary(apa)
#> mfrmr APA Outputs Summary
#> 
#> Overview
#>  Components NonEmptyComponents TotalCharacters TotalNonEmptyLines Sections
#>           3                  3            8329                112        9
#>  AvailableSections ContentChecks ContentChecksPassed DraftContractPass
#>                  7             9                   9              TRUE
#>  ReadyForAPA
#>         TRUE
#> 
#> Decision
#>  - Interpretation: Do not interpret this fit
#>  - Formal inference: No (fit readiness: blocked)
#>  - Why: Numerical convergence failed.
#>  - Next: Resolve the source fit-readiness decision before using the APA draft
#>    for substantive inference.
#> 
#> Component stats
#>              Component NonEmpty Characters Lines NonEmptyLines
#>            report_text     TRUE       3653    61            53
#>     table_figure_notes     TRUE       4009    50            34
#>  table_figure_captions     TRUE        667    41            25
#>  ResidualPCA_Mentions
#>                     2
#>                     2
#>                     2
#> 
#> Sections
#>                   SectionId  Parent                            Heading
#>               method_design  Method                    Design and data
#>           method_estimation  Method                Estimation settings
#>               results_scale Results                  Scale functioning
#>            results_measures Results                     Facet measures
#>    results_population_model Results Latent-regression population model
#>       results_fit_precision Results                  Fit and precision
#>  results_residual_structure Results                 Residual structure
#>      results_bias_screening Results                     Bias screening
#>            results_cautions Results                 Reporting cautions
#>  Available SentenceCount
#>       TRUE             3
#>       TRUE             5
#>       TRUE             2
#>       TRUE             3
#>      FALSE             0
#>       TRUE             6
#>       TRUE             3
#>      FALSE             0
#>       TRUE             1
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Text
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             A many-facet rating-scale Rasch model was fit to 768 observations from 48 persons scored on\na 4-category scale (1-4). The design included facets for Rater (n = 4), Criterion (n = 4).\nFacet-level sample sizes were strong (smallest level N = 192), though facets were still\nestimated as fixed effects with sum-to-zero identification;\n`analyze_hierarchical_structure()` is available for nesting and variance-component\nfollow-up.
#>                                                                                                                                                                                                                                   The RSM specification was estimated using JML with mfrmr. Precision summaries were\nexploratory in this run. Recommended use for this precision profile: Use for screening and\ncalibration triage; confirm formal SE, CI, and reliability with an MML fit.. Optimization\ndid not meet the package convergence checks after 76 function evaluations and 30 gradient\nevaluations (LogLik = -820.949). The canonical MML information-criterion panel was not\neligible (status: descriptive_jml). Legacy descriptive AIC = 1753.898; legacy descriptive\nBIC = 2013.950; neither enters the common MML ranking panel. Terminal gradient sup-norm =\n0.0035 (review threshold = 0.0001). Optimizer reached the iteration limit before the\nterminal gradient became small enough for review-only acceptance. Constraint settings:\nnoncenter facet = Person; anchored levels = 0 (facets: none); group anchors = 0 (facets:\nnone); dummy facets = none.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Category usage was adequate (unused categories = 0, low-count categories = 0), and\nthresholds were ordered. Step/threshold summary: 3 step(s); estimate range = -1.32 to 1.38\nlogits; no disordered steps.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Person measures ranged from -2.18 to 2.68 logits (M = 0.00, SD = 1.10). Rater measures\nranged from -0.33 to 0.33 logits (M = 0.00, SD = 0.31). Criterion measures ranged from\n-0.42 to 0.25 logits (M = 0.00, SD = 0.29).
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
#>  Overall mean-square fit was within the 0.5-1.5 screening band (infit MnSq = 0.99, outfit\nMnSq = 1.02). This band is the package's review convention; published mean-square\nguidelines differ, and band position is screening evidence rather than a model-validity\ndecision. 1 of 56 elements fell outside the 0.5-1.5 mean-square screening band. Largest\nmisfit signals: Person:P023 (|ZSTD| = 3.06); Person:P018 (|ZSTD| = 1.51);\nCriterion:Organization (|ZSTD| = 1.43). Criterion exploratory reliability summary = 0.89\n(separation = 2.78). Person exploratory reliability summary = 0.90 (separation = 3.01).\nRater exploratory reliability summary = 0.90 (separation = 3.05). These are\nRasch/FACETS-style separation indices (measure spread relative to measurement error), not\ninter-rater agreement. Observed inter-rater agreement is reported separately from\nseparation reliability: for Rater, exact agreement = 0.36, expected exact agreement = 0.37,\nadjacent agreement = 0.83. Element-level 95% confidence intervals (Normal approximation)\naccompany the measures (CI_Lower / CI_Upper); 0 of 56 rows are flagged CIEligible for\nprimary reporting.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Exploratory residual PCA (overall standardized residual matrix) showed PC1 eigenvalue =\n2.11 (13.2% variance), with PC2 eigenvalue = 1.83. Facet-specific exploratory residual PCA\nshowed the largest first-component signal in Rater (eigenvalue = 1.72, 43.0% variance).\nHeuristic reference bands: EV >= 1.4 (critical minimum), >= 1.5 (caution), >= 2.0 (common),\n>= 3.0 (strong); variance >= 5% (minor), >= 10% (caution), >= 20% (strong).
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Precision note: this run relies on exploratory precision summaries, so confidence intervals\nand reliability summaries should not be treated as formal inferential quantities.
#> 
#> Content checks
#>                          Check Passed
#>         Method section heading   TRUE
#>        Results section heading   TRUE
#>    Precision caution alignment   TRUE
#>  Bias screening note alignment   TRUE
#>          Residual PCA coverage   TRUE
#>                  Note coverage   TRUE
#>               Caption coverage   TRUE
#>          Core section coverage   TRUE
#>   Interrater summary alignment   TRUE
#>                                                                           Detail
#>                                APA narrative should begin with a Method heading.
#>                                  APA narrative should include a Results heading.
#>               Precision caution should appear in the report text or note blocks.
#>                                                No bias screening block required.
#>     Residual PCA availability should be reflected in prose, notes, and captions.
#>        All note-map entries should be represented in the consolidated note text.
#>  All caption-map entries should be represented in the consolidated caption text.
#>             Core package-native sections should be available in the section map.
#>          Interrater agreement wording should appear in the report text or notes.
#> 
#> Preview
#>              Component
#>            report_text
#>     table_figure_notes
#>  table_figure_captions
#>                                                                                                                                                           Preview
#>                                          Method. | Design and data. | A many-facet rating-scale Rasch model was fit to 768 observations from 48 persons scored on
#>  Table 1. Facet summary | Note. Measures are reported in logits; higher person values indicate higher ability, and higher non-person facet values indicate gre...
#>                                                                                         Table 1 | Facet Summary (Measures, Precision, Fit, Reliability) | Table 2
#> 
#> Notes
#>  - All standard APA text components are populated.Contract-based content checks passed.In this summary, ReadyForAPA/DraftContractPass indicates contract completeness for draft text components; it does not certify formal inferential adequacy.Use object fields directly for full text; summary provides compact diagnostics.
# }
```
