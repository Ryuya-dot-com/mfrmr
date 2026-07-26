# Summarize a reporting-checklist bundle for manuscript work

Summarize a reporting-checklist bundle for manuscript work

## Usage

``` r
# S3 method for class 'mfrm_reporting_checklist'
summary(object, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).

- top_n:

  Maximum number of draft-action rows shown in the compact action table.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_reporting_checklist` with:

- `overview`: run-level counts of available and draft-ready items

- `section_summary`: section-level checklist coverage

- `software_scope`: external-software relationship summary

- `facets_positioning`: report-ready FACETS relationship wording

- `visual_scope`: plotting-route and 3D-ready data-handoff summary,
  including the main `InterpretationCheck` caveat for each visual family

- `priority_summary`: counts by priority/severity

- `action_items`: highest-priority rows that still need draft work

- `settings`: checklist settings rendered as a compact table

- `notes`: interpretation notes

## See also

[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[summary.mfrm_apa_outputs](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_apa_outputs.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 7, maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "both", diagnostic_mode = "both")
chk <- reporting_checklist(fit, diagnostics = diag)
summary(chk)
#> mfrmr Reporting Checklist Summary
#> 
#> Overview
#>  Sections Items Available DraftReady Missing NeedsDraftWork
#>         7    33        29         28       4              5
#> 
#> Section summary
#>                      Section Items Available DraftReady ReadyForAPA Missing
#>  Bias / Interaction Analysis     2         0          0           0       2
#>     Element-Level Statistics     4         4          4           4       0
#>       Facet-Level Statistics     3         3          3           3       0
#>                   Global Fit     3         3          3           3       0
#>               Method Section     8         7          7           7       1
#>     Rating Scale Diagnostics     4         4          4           4       0
#>              Visual Displays     9         8          7           7       1
#>  NeedsDraftWork NeedsAction
#>               2           2
#>               0           0
#>               0           0
#>               0           0
#>               1           1
#>               0           0
#>               2           2
#> 
#> Priority summary
#>  Priority    Severity Items
#>    medium recommended     5
#>     ready    required    12
#>     ready recommended    15
#>     ready    optional     1
#> 
#> Action items (preview)
#>                      Section                          Item Available DraftReady
#>  Bias / Interaction Analysis            Facet pairs tested     FALSE      FALSE
#>  Bias / Interaction Analysis  Screen-positive interactions     FALSE      FALSE
#>               Method Section Hierarchical structure review     FALSE      FALSE
#>              Visual Displays            Bias / DIF visuals     FALSE      FALSE
#>              Visual Displays       Strict marginal visuals      TRUE      FALSE
#>     Severity Priority
#>  recommended   medium
#>  recommended   medium
#>  recommended   medium
#>  recommended   medium
#>  recommended   medium
#>                                                                                                                                 NextAction
#>                                                                    Run bias screening if the manuscript needs interaction-level follow-up.
#>                                                                          Run bias screening before discussing interaction-level anomalies.
#>  Run `analyze_hierarchical_structure(fit)` once per design and pass the result to `reporting_checklist(..., hierarchical_structure = hs)`.
#>                                                                     Run bias or DIF screening before discussing interaction-level visuals.
#>              Treat strict marginal plots as exploratory corroboration screens, then corroborate with design review and legacy diagnostics.
#> 
#> FACETS positioning
#>                                   Topic
#>                    Estimation authority
#>                   Compatibility purpose
#>              External FACETS comparison
#>  Current model and calibration boundary
#>               Reporting source of truth
#>                 Extension beyond FACETS
#>                                                                                                                                  RecommendedWording
#>                                                 The model was estimated with mfrmr; FACETS-style output names are used only to organize the report.
#>                       FACETS-style outputs were generated for handoff or reader familiarity; they are not evidence of FACETS numerical equivalence.
#>                                   When external FACETS output is supplied, compare MnSq first and report df/ZSTD convention sensitivity separately.
#>  Describe mfrmr as a native R RSM/PCM analysis, diagnostic, and reporting environment, not as a general FACETS operational-calibration replacement.
#>                                                          Report estimates, standard errors, fit summaries, and plots from documented mfrmr objects.
#>                                                              Use package-native extensions as additional evidence and label them as mfrmr analyses.
#> 
#> Settings
#>               Setting       Value
#>    include_references        TRUE
#>  diagnostics_supplied        TRUE
#>     bias_result_count           0
#>      bias_error_count           0
#>        precision_tier model_based
#> 
#> Notes
#>  - This summary is a manuscript-preparation guide.
#>  - DraftReady indicates that the corresponding reporting element can be drafted with the package's documented caveats; it does not certify inferential adequacy.
#>  - Detailed FACETS positioning, software scope, and visual scope tables are available in `$facets_positioning`, `$software_scope`, and `$visual_scope`.
# }
```
