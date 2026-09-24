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
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
diag <- diagnose_mfrm(fit, residual_pca = "none")
apa <- build_apa_outputs(fit, diag)
summary(apa)
#> mfrmr APA Outputs Summary
#> 
#> Overview
#>  Components NonEmptyComponents TotalCharacters TotalNonEmptyLines Sections
#>           3                  3            8343                108        9
#>  AvailableSections ContentChecks ContentChecksPassed DraftContractPass
#>                  6             9                   9              TRUE
#>  ReadyForAPA
#>         TRUE
#> 
#> Decision
#>  - Interpretation: Fit-readiness requirements satisfied; formal inference is
#>    not supported
#>  - Formal inference: No
#>  - Why: The precision contract does not support formal inference (exploratory
#>    precision).
#>  - Next: The fit-readiness requirements were satisfied, but the precision
#>    contract does not support formal inference; keep the draft exploratory and
#>    review `precision_review_report()` before substantive use.
#> 
#> Component stats
#>              Component NonEmpty Characters Lines NonEmptyLines
#>            report_text     TRUE       3432    56            49
#>     table_figure_notes     TRUE       4244    50            34
#>  table_figure_captions     TRUE        667    41            25
#>  ResidualPCA_Mentions
#>                     0
#>                     4
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
#>      FALSE             0
#>      FALSE             0
#>       TRUE             1
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Text
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             A many-facet rating-scale Rasch model was fit to 768 observations from 48 persons scored on\na 4-category scale (1-4). The design included facets for Rater (n = 4), Criterion (n = 4).\nFacet-level sample sizes were strong (smallest level N = 192), though facets were still\nestimated as fixed effects with sum-to-zero identification;\n`analyze_hierarchical_structure()` is available for nesting and variance-component\nfollow-up.
#>                                                                                                                                                                                                                                                                                                 The RSM specification was estimated using JML with mfrmr. Precision summaries were\nexploratory in this run. Recommended use for this precision profile: JML standard errors\nand normal bands are exploratory approximations. Changing to MML does not by itself\nestablish valid uncertainty; review the fitted model and its uncertainty assumptions..\nOptimization met the numerical convergence checks after 203 function evaluations and 53\ngradient evaluations (LogLik = -820.949). MML model-comparison criteria are unavailable for\nthis fit; numerical completion alone does not establish comparability. Legacy descriptive\nAIC = 1753.898; legacy descriptive BIC = 2013.950; neither enters the common MML ranking\npanel. Terminal gradient sup-norm = 0.0001 (review threshold = 0.0001). Constraint\nsettings: noncenter facet = Person; anchored levels = 0 (facets: none); group anchors = 0\n(facets: none); dummy facets = none.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   Category counts were available for all 4 categories: 0 unused and 0 below 10. Counts alone\ndo not establish category adequacy. Adjacent threshold comparisons: 0 decreasing among 2\navailable; 0 of 2 comparisons unavailable. Available estimates range from -1.32 to 1.38\nlogits. Adjacent threshold comparisons: 0 decreasing among 2 available; 0 of 2 comparisons\nunavailable.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Person measures ranged from -2.18 to 2.68 logits (M = 0.00, SD = 1.10). Rater measures\nranged from -0.33 to 0.33 logits (M = 0.00, SD = 0.31). Criterion measures ranged from\n-0.42 to 0.25 logits (M = 0.00, SD = 0.29).
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
#>  Overall mean-square fit was within the 0.5-1.5 screening band (infit MnSq = 0.99, outfit\nMnSq = 1.02). This band is the package's review convention; published mean-square\nguidelines differ, and band position is screening evidence rather than a model-validity\ndecision. MnSq outside [0.5, 1.5]: 1 of 56 classified elements flagged; 0 of 56 elements\nunclassified. Largest misfit signals among 56 elements with complete paired statistics:\nPerson:P023 (|ZSTD| = 3.06); Person:P018 (|ZSTD| = 1.51); Criterion:Organization (|ZSTD| =\n1.43). Criterion exploratory reliability summary = 0.89 (separation = 2.78). Person\nexploratory reliability summary = 0.90 (separation = 3.01). Rater exploratory reliability\nsummary = 0.90 (separation = 3.05). These are Rasch/FACETS-style separation indices\n(measure spread relative to measurement error), not inter-rater agreement. Observed\ninter-rater agreement is reported separately from separation reliability: for Rater, exact\nagreement = 0.36, expected exact agreement = 0.37, adjacent agreement = 0.83. Element-level\n95% approximate intervals (Normal approximation) accompany 56 of 56 estimates; 0 of 56\nestimates have intervals eligible for primary reporting.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Precision note: this run relies on exploratory precision summaries, so confidence intervals\nand reliability summaries should not be treated as formal inferential quantities.
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
