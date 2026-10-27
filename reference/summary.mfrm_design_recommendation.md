# Review a simulation-based design recommendation

Review a simulation-based design recommendation

## Usage

``` r
# S3 method for class 'mfrm_design_recommendation'
summary(object, ...)

# S3 method for class 'summary.mfrm_design_recommendation'
print(x, ...)

# S3 method for class 'mfrm_design_recommendation'
print(x, ...)
```

## Arguments

- object, x:

  Output from
  [`recommend_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md).

- ...:

  Unused; extra arguments are rejected.

## Value

[`summary()`](https://rdrr.io/r/base/summary.html) returns a
`summary.mfrm_design_recommendation` list containing `target`,
`thresholds`, `checks`, `design_table`, `facet_table`, `recommended`,
and `notes`. Print methods return their input invisibly.

## Details

Recommendations screen the saved simulation aggregates under the
requested criteria. The default targets non-Person facet calibration.
For Person differentiation, request `facets = "Person"` when
recommending the design. Neither target establishes classification
accuracy, inter-rater agreement, a universal minimum sample size or
precision outside the simulated population.

`checks` has one row per design, target facet and criterion, including
unavailable metrics and inactive constraints. `DesignRow` links these
rows to the complete, ranked `design_table`. `Selected` marks the first
passing plan under the stored `prefer` order; it does not establish an
optimum over unevaluated plans. `Pass` and selected plans are reused
without recalculation. Threshold sources are recorded for new results;
older saved results show `not_recorded`. No confidence intervals or
selection-adjusted uncertainty are calculated. Retain the simulation's
generating assumptions and replication evidence with the recommendation.

## See also

[`recommend_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md),
[`plot.mfrm_design_recommendation()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_design_recommendation.md),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)

## Examples

``` r
# Saved synthetic simulation; one replication illustrates structure only.
saved <- readRDS(system.file("examples", "simulation-design.rds",
  package = "mfrmr", mustWork = TRUE))
rec <- recommend_mfrm_design(saved$result, facets = "Person")
summary(rec)
#> Simulation-based design recommendation
#>   Facet                 Target
#>  Person Person differentiation
#>                                                                                   Interpretation
#>  Distinguishing Persons in the simulated population; not classification accuracy at a cut score.
#> 
#>  0 of 2 evaluated designs pass.
#> No evaluated design meets all requested criteria.
#> Use $checks for all criterion outcomes and $thresholds for their source.
#> This screen does not establish agreement, classification accuracy or a universal sample size.
report <- mfrm_report(rec)
report$tables$checks
#>    DesignRow                Facet             Criterion      Value Relation
#> 1          1               Person            Separation  1.1335399       >=
#> 2          2               Person            Separation  1.5524611       >=
#> 3          1               Person           Reliability  0.5623465       >=
#> 4          2               Person           Reliability  0.7067565       >=
#> 5          1               Person          SeverityRMSE  1.2020555       <=
#> 6          2               Person          SeverityRMSE  0.6882577       <=
#> 7          1               Person            MisfitRate  0.1666667       <=
#> 8          2               Person            MisfitRate  0.0000000       <=
#> 9          1               Person           Convergence  0.0000000       >=
#> 10         2               Person           Convergence  1.0000000       >=
#> 11         1 All requested facets        Facet coverage  1.0000000        =
#> 12         2 All requested facets        Facet coverage  1.0000000        =
#> 13         1 All requested facets         Total ratings 32.0000000       <=
#> 14         2 All requested facets         Total ratings 48.0000000       <=
#> 15         1 All requested facets     Ratings per rater 16.0000000       <=
#> 16         2 All requested facets     Ratings per rater 24.0000000       <=
#> 17         1 All requested facets Connected assignments  1.0000000        =
#> 18         2 All requested facets Connected assignments  1.0000000        =
#>    Threshold        Status
#> 1        2.0          fail
#> 2        2.0          fail
#> 3        0.8          fail
#> 4        0.8          fail
#> 5        0.5          fail
#> 6        0.5          fail
#> 7        0.1          fail
#> 8        0.1          pass
#> 9        1.0          fail
#> 10       1.0          pass
#> 11       1.0          pass
#> 12       1.0          pass
#> 13        NA not_requested
#> 14        NA not_requested
#> 15        NA not_requested
#> 16        NA not_requested
#> 17       1.0          pass
#> 18       1.0          pass
```
