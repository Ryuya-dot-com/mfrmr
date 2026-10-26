# Plot a saved anchor-drift review

Inspect relative changes after the common-element offset used by
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md).
Read `summary(x)` and link support alongside the plot.

## Usage

``` r
# S3 method for class 'mfrm_anchor_drift'
plot(x, type = c("drift", "heatmap", "forest"), ...)
```

## Arguments

- x:

  A saved result from
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md).

- type:

  `"drift"` for relative changes with screening flags, `"heatmap"` for
  wave-by-element patterns, or `"forest"` for per-wave estimates with
  approximate normal whiskers. A linking chain is a different result:
  use `plot(chain, type = "chain")` after
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md).

- ...:

  `facet` optionally selects facets; `ci_level = 0.95` controls forest
  whiskers only; `preset` selects `"standard"`, `"publication"`,
  `"compact"`, or `"monochrome"`; `draw = FALSE` returns data without
  drawing. Additional base-graphics arguments depend on the selected
  view.

## Value

An `mfrm_plot_data` object, or `NULL` when no drift rows remain.
Drift/heatmap data use `data$table` (and `data$matrix` for a heatmap);
forest rows use `data$data`, including `CI_Lower` and `CI_Upper`.

## Interpretation

Drift and heatmap views show the saved relative drift. Flags use the
screening rules chosen during analysis; changing the display does not
recalibrate these rules. Subtracting the common-element offset can
remove a panel-wide shift, so unflagged elements do not establish
absence of annual drift.

Forest whiskers describe individual wave estimates, not uncertainty in
their differences. They do not include linking-offset uncertainty or
cross-wave covariance, and their overlap is not a test of change.
Missing standard errors produce no whisker, not a zero-width interval.

## See also

[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_core")
people <- unique(ratings$Person)
d1 <- ratings[ratings$Person %in% people[1:12], , drop = FALSE]
d2 <- ratings[ratings$Person %in% people[13:24], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML")
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML")
# Review convergence and common-element support before interpreting changes.
summary(fit1)
#> Many-Facet Measurement Model Summary
#>   Model: RSM | Method: JML | N: 192 | Persons: 12 | Facets: 2 | Categories: 4
#> 
#> Decision
#>  - Interpretation: Fit-readiness requirements satisfied; formal precision
#>    review required
#>  - Formal inference: No
#>  - Why: Formal precision support has not been evaluated.
#>  - Next: Run `diagnose_mfrm()` and pass its result as `diagnostics =` to
#>    evaluate formal precision support; fit readiness alone is not a
#>    formal-inference decision.
#>   JML uses observed scores without an extreme-score adjustment or finite-item
#>   bias correction. Independently free Person measures are infinite for
#>   all-minimum/all-maximum responses; finite optimizer values are computational
#>   traces. JML SEs and normal bands remain exploratory.
#>   Centering: whole declared facet, including anchors and group totals.
#> 
#> Visual workflow (in order)
#>  Priority                   Visual Required Available
#>         1 mfrmr Wright map with SE     TRUE      TRUE
#>         2  FACETS-style Wright map    FALSE      TRUE
#>         3            Infit pathway    FALSE     FALSE
#>                       Interpretation
#>  Diagnostic interpretation available
#>  Diagnostic interpretation available
#>                          Unavailable
#>   Plot commands are stored in `$required_visual$Route`.
#> 
#> Status
#>  - Overall status: Fit completed; review diagnostics before reporting
#>  - Convergence: converged (severity: pass, maximum absolute gradient: 1.86e-05)
#>  - Estimation path: RSM / JML
#>  - Reporting readiness: Fit available for diagnostic review; inferential
#>    strength depends on the estimator and convergence evidence
#> 
#> Workflow readiness
#>       Domain                                         Status
#>          Fit                                  Checks passed
#>    Numerical                                  Checks passed
#>         Data                                  Checks passed
#>       Design                           Connectivity checked
#>    Stability                                  Checks passed
#>  Diagnostics                                   Not assessed
#>    Reporting Review the stored result before interpretation
#> 
#> Key warnings
#>  - None.
#> 
#> Next actions
#>  - Run `diagnose_mfrm()` and pass its result as `diagnostics =` to evaluate
#>    formal precision support; fit readiness alone is not a formal-inference
#>    decision.
#>  - After reviewing convergence, run `review <- summary(fit, profile = "facets",
#>    detail = "brief")` for the comprehensive measurement review; FACETS software
#>    is not required.
#>  - Then draw the complete native Wright map with `plot(fit, type = "wright",
#>    show_ci = TRUE, top_n = Inf, preset = "publication")`.
#>  - MML provides marginal diagnostics; review the resulting fit and uncertainty
#>    assumptions before using its SEs or intervals.
#>  - Reuse `review$results$diagnostics`; call `diagnose_mfrm()` again only for
#>    residual PCA or other custom settings.
#>  - Use `reporting_checklist(fit, diagnostics = review$results$diagnostics)` for
#>    reporting readiness.
#> 
#> Fit overview
#>   LogLik: -203.282 | Information-criterion ranking is unavailable for JML.
#>   Optimizer code 0: Yes | Status: converged | Fn evals: 66 | Gr evals: 28
#>   Terminal gradient: maximum absolute = 1.86e-05 | RMS = 7.58e-06 | Review tolerance = 0.0001
#>   Optimization note: Optimizer returned convergence code 0.
#> 
#> Population basis
#>   JML estimates Person measures jointly with calibration parameters; it does
#>   not estimate a normal population distribution.
#> 
#> Facet overview
#>      Facet Levels MeanEstimate SDEstimate MinEstimate MaxEstimate  Span
#>  Criterion      4            0      0.309      -0.458       0.217 0.675
#>      Rater      4            0      0.216      -0.216       0.253 0.470
#> 
#> Person measure distribution
#>  Persons DistributionN ReviewExcludedExtremeEAPs  Mean    SD Median    Min
#>       12            12                         0 0.261 1.089  0.669 -1.673
#>    Max  Span                               Interpretation
#>  1.695 3.368 Subject to the fit's interpretation decision
#> 
#> Targeting (Person vs facet means; sum-to-zero ID makes Targeting = Person mean)
#>      Facet PersonMean FacetMean Targeting PersonSD FacetSD SpreadRatio
#>  Criterion      0.261         0     0.261    1.089   0.309       3.523
#>      Rater      0.261         0     0.261    1.089   0.216       5.052
#> 
#> Step parameter summary
#>  Steps    Min   Max  Span Monotonic
#>      3 -1.305 1.469 2.774      TRUE
#> 
#> Estimation settings
#>  StepFacet SlopeFacet NoncenterFacet WeightColumn RatingMin RatingMax
#>       <NA>       <NA>         Person         <NA>         1         4
#>  CategoryPolicy ScoreRecoded DummyFacets PositiveFacets FacetInteractions
#>        collapse        FALSE                                             
#>  UnusedScoreCategories UnusedScoreCategoryCount
#>                                               0
#>   RSM uses one shared set of rating-scale thresholds.
#>   Full fitting settings are retained in `$settings_overview`.
#> 
#> Most extreme facet levels (|estimate|)
#>      Facet        Level Estimate
#>  Criterion      Content   -0.458
#>      Rater          R04    0.253
#>  Criterion     Accuracy    0.217
#>      Rater          R02   -0.216
#>  Criterion Organization    0.140
#> 
#> Paper reporting map
#>                                Area CoveredHere
#>  Model identification / convergence         yes
#>        Data structure / missingness          no
#>    Reliability / fit / residual PCA          no
#>                Category functioning     partial
#>     Bias / DIF / interaction checks          no
#>         Draft reporting / checklist          no
#>                                                                CompanionOutput
#>                                                                   summary(fit)
#>                                               summary(describe_mfrm_data(...))
#>                                                    summary(diagnose_mfrm(fit))
#>  rating_scale_table() / category_structure_report() / category_curves_report()
#>         summary(estimate_bias(...)) / analyze_dff() / related bundle summaries
#>                        reporting_checklist() / summary(build_apa_outputs(...))
summary(fit2)
#> Many-Facet Measurement Model Summary
#>   Model: RSM | Method: JML | N: 192 | Persons: 12 | Facets: 2 | Categories: 4
#> 
#> Decision
#>  - Interpretation: Fit-readiness requirements satisfied; formal precision
#>    review required
#>  - Formal inference: No
#>  - Why: Formal precision support has not been evaluated.
#>  - Next: Run `diagnose_mfrm()` and pass its result as `diagnostics =` to
#>    evaluate formal precision support; fit readiness alone is not a
#>    formal-inference decision.
#>   JML uses observed scores without an extreme-score adjustment or finite-item
#>   bias correction. Independently free Person measures are infinite for
#>   all-minimum/all-maximum responses; finite optimizer values are computational
#>   traces. JML SEs and normal bands remain exploratory.
#>   Centering: whole declared facet, including anchors and group totals.
#> 
#> Visual workflow (in order)
#>  Priority                   Visual Required Available
#>         1 mfrmr Wright map with SE     TRUE      TRUE
#>         2  FACETS-style Wright map    FALSE      TRUE
#>         3            Infit pathway    FALSE     FALSE
#>                       Interpretation
#>  Diagnostic interpretation available
#>  Diagnostic interpretation available
#>                          Unavailable
#>   Plot commands are stored in `$required_visual$Route`.
#> 
#> Status
#>  - Overall status: Fit completed; review diagnostics before reporting
#>  - Convergence: converged (severity: pass, maximum absolute gradient: 7.02e-06)
#>  - Estimation path: RSM / JML
#>  - Reporting readiness: Fit available for diagnostic review; inferential
#>    strength depends on the estimator and convergence evidence
#> 
#> Workflow readiness
#>       Domain                                         Status
#>          Fit                                  Checks passed
#>    Numerical                                  Checks passed
#>         Data                                  Checks passed
#>       Design                           Connectivity checked
#>    Stability                                  Checks passed
#>  Diagnostics                                   Not assessed
#>    Reporting Review the stored result before interpretation
#> 
#> Key warnings
#>  - None.
#> 
#> Next actions
#>  - Run `diagnose_mfrm()` and pass its result as `diagnostics =` to evaluate
#>    formal precision support; fit readiness alone is not a formal-inference
#>    decision.
#>  - After reviewing convergence, run `review <- summary(fit, profile = "facets",
#>    detail = "brief")` for the comprehensive measurement review; FACETS software
#>    is not required.
#>  - Then draw the complete native Wright map with `plot(fit, type = "wright",
#>    show_ci = TRUE, top_n = Inf, preset = "publication")`.
#>  - MML provides marginal diagnostics; review the resulting fit and uncertainty
#>    assumptions before using its SEs or intervals.
#>  - Reuse `review$results$diagnostics`; call `diagnose_mfrm()` again only for
#>    residual PCA or other custom settings.
#>  - Use `reporting_checklist(fit, diagnostics = review$results$diagnostics)` for
#>    reporting readiness.
#> 
#> Fit overview
#>   LogLik: -191.617 | Information-criterion ranking is unavailable for JML.
#>   Optimizer code 0: Yes | Status: converged | Fn evals: 131 | Gr evals: 44
#>   Terminal gradient: maximum absolute = 7.02e-06 | RMS = 2.99e-06 | Review tolerance = 0.0001
#>   Optimization note: Optimizer returned convergence code 0.
#> 
#> Population basis
#>   JML estimates Person measures jointly with calibration parameters; it does
#>   not estimate a normal population distribution.
#> 
#> Facet overview
#>      Facet Levels MeanEstimate SDEstimate MinEstimate MaxEstimate  Span
#>  Criterion      4            0      0.409      -0.612       0.232 0.844
#>      Rater      4            0      0.389      -0.397       0.354 0.751
#> 
#> Person measure distribution
#>  Persons DistributionN ReviewExcludedExtremeEAPs  Mean    SD Median    Min
#>       12            12                         0 0.428 1.387  0.443 -2.372
#>    Max  Span                               Interpretation
#>  2.715 5.087 Subject to the fit's interpretation decision
#> 
#> Targeting (Person vs facet means; sum-to-zero ID makes Targeting = Person mean)
#>      Facet PersonMean FacetMean Targeting PersonSD FacetSD SpreadRatio
#>  Criterion      0.428         0     0.428    1.387   0.409       3.394
#>      Rater      0.428         0     0.428    1.387   0.389       3.569
#> 
#> Step parameter summary
#>  Steps    Min   Max  Span Monotonic
#>      3 -1.611 1.314 2.925      TRUE
#> 
#> Estimation settings
#>  StepFacet SlopeFacet NoncenterFacet WeightColumn RatingMin RatingMax
#>       <NA>       <NA>         Person         <NA>         1         4
#>  CategoryPolicy ScoreRecoded DummyFacets PositiveFacets FacetInteractions
#>        collapse        FALSE                                             
#>  UnusedScoreCategories UnusedScoreCategoryCount
#>                                               0
#>   RSM uses one shared set of rating-scale thresholds.
#>   Full fitting settings are retained in `$settings_overview`.
#> 
#> Most extreme facet levels (|estimate|)
#>      Facet   Level Estimate
#>  Criterion Content   -0.612
#>      Rater     R01   -0.397
#>      Rater     R03    0.354
#>      Rater     R04    0.313
#>      Rater     R02   -0.269
#> 
#> Paper reporting map
#>                                Area CoveredHere
#>  Model identification / convergence         yes
#>        Data structure / missingness          no
#>    Reliability / fit / residual PCA          no
#>                Category functioning     partial
#>     Bias / DIF / interaction checks          no
#>         Draft reporting / checklist          no
#>                                                                CompanionOutput
#>                                                                   summary(fit)
#>                                               summary(describe_mfrm_data(...))
#>                                                    summary(diagnose_mfrm(fit))
#>  rating_scale_table() / category_structure_report() / category_curves_report()
#>         summary(estimate_bias(...)) / analyze_dff() / related bundle summaries
#>                        reporting_checklist() / summary(build_apa_outputs(...))
drift <- detect_anchor_drift(list(W1 = fit1, W2 = fit2))
#> Warning: Thin linking support between 'W1' and 'W2': fewer than 5 retained common elements in Criterion, Rater.
drift_plot <- plot(drift, type = "drift", draw = FALSE)
class(drift_plot)
#> [1] "mfrm_plot_data" "list"          
names(drift_plot$data)
#> [1] "plot"            "table"           "title"           "subtitle"       
#> [5] "legend"          "reference_lines" "preset"          "plot_name"      
#> [9] "notes"          
chain <- build_equating_chain(list(F1 = fit1, F2 = fit2))
#> Warning: Thin linking support between 'F1' and 'F2': fewer than 5 retained common elements in Criterion, Rater.
chain_plot <- plot(chain, type = "chain", draw = FALSE)
head(chain_plot$data$table)
#> # A tibble: 2 × 4
#>   Wave  Cumulative_Offset Status   Reason
#>   <chr>             <dbl> <chr>    <chr> 
#> 1 F1              0       computed NA    
#> 2 F2              0.00211 computed NA    
if (interactive()) {
  plot(drift, type = "heatmap", preset = "publication")
}
```
