# Summarize report/table bundles in a user-friendly format

Summarize report/table bundles in a user-friendly format

## Usage

``` r
# S3 method for class 'mfrm_bundle'
summary(object, digits = 3, top_n = 10, include_person = FALSE, ...)
```

## Arguments

- object:

  Any report bundle produced by `mfrmr` table/report helpers.

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of preview rows shown from the main table component.

- include_person:

  If `TRUE`, person-level identifiers may appear in supported summary
  and preview tables. The default suppresses identifier columns,
  person-facet level labels, and ConQuest case labels from the returned
  summary object and its console output. This does not alter the source
  bundle.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_bundle`.

## Details

This method provides a compact summary for bundle-like outputs (for
example: unexpected-response, fair-average, chi-square, and category
report objects). It extracts:

- object class and available components

- one-row summary table when available

- preview rows from the main data component

- resolved settings/options

Branch-aware summaries are provided for:

- `mfrm_bias_count` (`branch = "original"` / `"facets"`)

- `mfrm_fixed_reports` (`branch = "original"` / `"facets"`)

- `mfrm_visual_summaries` (`branch = "original"` / `"facets"`)

Additional class-aware summaries are provided for:

- `mfrm_unexpected`, `mfrm_fair_average`, `mfrm_displacement`

- `mfrm_interrater`, `mfrm_facets_chisq`, `mfrm_bias_interaction`

- `mfrm_rating_scale`, `mfrm_category_structure`, `mfrm_category_curves`

- `mfrm_measurable`, `mfrm_unexpected_after_bias`, `mfrm_output_bundle`

- `mfrm_residual_pca`, `mfrm_specifications`, `mfrm_data_quality`,
  `mfrm_fit_measures`

- `mfrm_iteration_report`, `mfrm_subset_connectivity`,
  `mfrm_facet_statistics`

- `mfrm_facets_contract_review`, `mfrm_facets_fit_review`,
  `mfrm_facets_fit_df_guide`, `mfrm_reference_benchmark`

## Interpreting output

- `overview`: class, component count, and selected preview component.

- `summary`: one-row aggregate block when supplied by the bundle.

- `preview`: first `top_n` rows from the main table-like component.

- `settings`: resolved option values if available.

- `validation_scope`: package-generated versus independently supplied
  evidence scope when summarizing `mfrm_reference_benchmark`.

- `conquest_command_scope`: ConQuest command-template scope when
  summarizing `mfrm_conquest_overlap_bundle`.

- `conquest_output_contract`: requested ConQuest outputs and review
  handoff when summarizing `mfrm_conquest_overlap_bundle`.

- `mfrmr_fit_status`: actual optimizer controls, MML engine, convergence
  evidence, and inference-readiness state for an
  `mfrm_conquest_overlap_bundle`.

- `normalization_scope`: extracted-table normalization scope when
  summarizing `mfrm_conquest_overlap_tables`.

- `review_scope`: supplied-table review scope when summarizing
  `mfrm_conquest_overlap_review`.

- `conquest_overlap_checks` / `population_policy_checks`: specialized
  benchmark check previews when summarizing `mfrm_reference_benchmark`.

## Typical workflow

1.  Generate a bundle table/report helper output.

2.  Run `summary(bundle)` for compact QA.

3.  Drill into specific components via `$` and visualize with
    `plot(bundle, ...)`.

## See also

[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)

## Examples

``` r
# \donttest{
toy_full <- load_mfrmr_data("example_core")
toy_people <- unique(toy_full$Person)[1:12]
toy <- toy_full[toy_full$Person %in% toy_people, , drop = FALSE]
fit <- suppressWarnings(
  fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
)
t4 <- unexpected_response_table(fit, abs_z_min = 1.5, prob_max = 0.4, top_n = 5)
summary(t4)
#> mfrmr Unexpected Response Summary 
#>   Class: mfrm_unexpected
#>   Components: 3
#> 
#> Threshold summary
#>  TotalObservations UnexpectedN UnexpectedPercent LowProbabilityN LargeResidualN
#>                192           5             2.604               5              5
#>    Rule AbsZThreshold ProbThreshold
#>  either           1.5           0.4
#> 
#> Flagged responses: table
#>  Row Rater    Criterion Weight Score Observed Expected Residual StdResidual
#>  160   R02     Accuracy      1     1        1    3.071   -2.071      -2.816
#>  130   R03     Language      1     1        1    2.966   -1.966      -2.602
#>   55   R01 Organization      1     1        1    2.937   -1.937      -2.548
#>   48   R04      Content      1     1        1    2.697   -1.697      -2.142
#>  181   R04     Accuracy      1     1        1    2.660   -1.660      -2.087
#>  ObsProb MostLikely MostLikelyProb CategoryGap Surprise           Direction
#>    0.020          3          0.513           2    1.704 Lower than expected
#>    0.029          3          0.515           2    1.538 Lower than expected
#>    0.032          3          0.514           2    1.496 Lower than expected
#>    0.066          3          0.478           2    1.181 Lower than expected
#>    0.073          3          0.469           2    1.139 Lower than expected
#>  FlagLowProbability FlagLargeResidual Severity
#>                TRUE              TRUE    5.519
#>                TRUE              TRUE    5.139
#>                TRUE              TRUE    5.045
#>                TRUE              TRUE    4.323
#>                TRUE              TRUE    4.226
#> 
#> Settings
#>    Setting  Value
#>  abs_z_min    1.5
#>   prob_max    0.4
#>       rule either
#> 
#> Notes
#>  - Unexpected-response summary for quick residual screening.
#>  - Person identifiers are suppressed in this summary. Use `include_person =
#>    TRUE` only under appropriate privacy controls.
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
t11 <- bias_count_table(bias, branch = "facets")
summary(t11)
#> mfrmr Bias Count Summary
#> 
#> Overview
#>  InteractionFacets InteractionOrder InteractionMode Branch         Style FacetA
#>  Rater x Criterion                2        pairwise facets facets_manual  Rater
#>     FacetB Cells TotalCount MeanCount MedianCount MinCount MaxCount
#>  Criterion    16        192        12          12       12       12
#>  LowCountCells LowCountPercent
#>              0               0
#> 
#> Count distribution
#>  Min Q1 Median Mean Q3 Max
#>   12 12     12   12 12  12
#> 
#> Thresholds
#>         Setting Value
#>  min_count_warn    10
#> 
#> Notes
#>  - FACETS-style branch: table columns mirror the output-contract naming.
# }
```
