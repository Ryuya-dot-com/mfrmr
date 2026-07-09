# Load a packaged simulation dataset

Load a packaged simulation dataset

## Usage

``` r
load_mfrmr_data(
  name = c("example_core", "example_bias", "study1", "study2", "combined",
    "study1_itercal", "study2_itercal", "combined_itercal")
)
```

## Arguments

- name:

  Dataset key. One of values from
  [`list_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/list_mfrmr_data.md).

## Value

A data.frame in long format.

## Details

`load_mfrmr_data("<key>")` is the canonical loader for the packaged
datasets and the entry point used across the package help and vignettes.
The equivalent base-R alternative
`data("mfrmr_<key>", package = "mfrmr")` remains available for users who
prefer the full [`data()`](https://rdrr.io/r/utils/data.html) spelling;
both paths return identical long-format data frames and are supported
long-term.

All returned datasets include the core long-format columns `Study`,
`Person`, `Rater`, `Criterion`, and `Score`. Some datasets, such as the
packaged documentation examples, also include auxiliary variables like
`Group` for DIF/bias demonstrations.

## Interpreting output

The return value is a plain long-format `data.frame`, ready for direct
use in
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
without additional reshaping.

## Typical workflow

1.  list valid names with
    [`list_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/list_mfrmr_data.md).

2.  load one dataset key with `load_mfrmr_data(name)`.

3.  fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and inspect with [`summary()`](https://rdrr.io/r/base/summary.html)
    / [`plot()`](https://rdrr.io/r/graphics/plot.default.html).

## See also

[`list_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/list_mfrmr_data.md),
[ej2021_data](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)

## Examples

``` r
data("mfrmr_example_core", package = "mfrmr")
head(mfrmr_example_core)
#>         Study Person Rater Criterion Score Group
#> 1 ExampleCore   P001   R01   Content     3     A
#> 2 ExampleCore   P002   R01   Content     3     A
#> 3 ExampleCore   P003   R01   Content     4     A
#> 4 ExampleCore   P004   R01   Content     3     A
#> 5 ExampleCore   P005   R01   Content     2     A
#> 6 ExampleCore   P006   R01   Content     3     A

d <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  data = d,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "JML",
  maxit = 30
)
summary(fit)
#> Many-Facet Rasch Model Summary
#>   Model: RSM | Method: JML | N: 768 | Persons: 48 | Facets: 2 | Categories: 4
#> 
#> Status
#>  - Overall status: usable_fit
#>  - Convergence: converged (severity: pass, sup-norm: 0.033)
#>  - Estimation path: RSM / JML
#>  - Reporting readiness: exploratory_fit_ready_for_diagnostics
#> 
#> Key warnings
#>  - None.
#> 
#> Next actions
#>  - If formal SE/CI or strict marginal diagnostics are needed, re-fit with `method = "MML"`.
#>  - Run `diagnose_mfrm(fit, diagnostic_mode = "both")` for element-level fit review.
#>  - Use `plot(fit, type = "wright", preset = "publication")` for targeting and scale review.
#>  - After diagnostics, use `reporting_checklist(fit, diagnostics = diagnostics)` for reporting readiness.
#> 
#> Fit overview
#>   LogLik: -820.949 | AIC: 1753.898 | BIC: 2013.95
#>   Converged: Yes | Status: converged | Basis: optimizer_gradient | Fn evals: 71 | Gr evals: 24
#>   Terminal gradient: sup-norm = 0.033 | RMS = 0.008 | Review tol = 0
#>   Optimization note: Optimizer returned convergence code 0.
#> 
#> Population basis
#>  PopulationModel PosteriorBasis Formula PersonRows DesignColumns
#>            FALSE     legacy_mml    <NA>         NA            NA
#>  CodingVariables ContrastVariables Policy ResidualVariance OmittedPersons
#>                                      <NA>               NA              0
#>  OmittedRows
#>            0
#> 
#> Facet overview
#>      Facet Levels MeanEstimate SDEstimate MinEstimate MaxEstimate  Span
#>  Criterion      4            0      0.288      -0.415       0.249 0.664
#>      Rater      4            0      0.313      -0.329       0.334 0.662
#> 
#> Person measure distribution
#>  Persons  Mean  SD Median    Min   Max  Span
#>       48 0.001 1.1  0.082 -2.179 2.683 4.863
#> 
#> Targeting (Person vs facet means; sum-to-zero ID makes Targeting = Person mean)
#>      Facet PersonMean FacetMean Targeting PersonSD FacetSD SpreadRatio
#>  Criterion      0.001         0     0.001      1.1   0.288       3.823
#>      Rater      0.001         0     0.001      1.1   0.313       3.512
#> 
#> Step parameter summary
#>  Steps    Min   Max Span Monotonic
#>      3 -1.326 1.385 2.71      TRUE
#> 
#> Estimation settings
#>  StepFacet SlopeFacet NoncenterFacet WeightColumn QuadPoints RatingMin
#>       <NA>       <NA>         Person         <NA>         31         1
#>  RatingMax RatingRangeSource RatingMinSource RatingMaxSource DummyFacets
#>          4          observed        observed        observed            
#>  PositiveFacets FacetInteractions UnusedScoreCategories
#>                                                        
#>  UnusedScoreCategoryCount UnusedScoreCategoryType
#>                         0                    none
#> 
#> Most extreme facet levels (|estimate|)
#>      Facet    Level Estimate
#>  Criterion  Content   -0.415
#>      Rater      R04    0.334
#>      Rater      R02   -0.329
#>  Criterion Accuracy    0.249
#>      Rater      R01   -0.196
#> 
#> Highest person measures
#>  Person Estimate SE Extreme
#>    P023    2.683 NA    none
#>    P024    2.201 NA    none
#>    P036    1.832 NA    none
#>    P002    1.673 NA    none
#>    P003    1.258 NA    none
#> 
#> Lowest person measures
#>  Person Estimate SE Extreme
#>    P015   -2.179 NA    none
#>    P045   -1.821 NA    none
#>    P008   -1.665 NA    none
#>    P006   -1.524 NA    none
#>    P026   -1.524 NA    none
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
```
