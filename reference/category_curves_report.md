# Build a category curve export bundle (preferred alias)

Build a category curve export bundle (preferred alias)

## Usage

``` r
category_curves_report(
  fit,
  theta_range = c(-6, 6),
  theta_points = 241,
  digits = 4,
  include_fixed = FALSE,
  fixed_max_rows = 400
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- theta_range:

  Theta/logit range for curve coordinates.

- theta_points:

  Number of points on the theta grid.

- digits:

  Rounding digits for numeric graph output.

- include_fixed:

  If `TRUE`, include a legacy-compatible fixed-width text block.

- fixed_max_rows:

  Maximum rows shown in fixed-width graph tables.

## Value

A named list with category-curve components. Class:
`mfrm_category_curves`.

## Details

Preferred high-level API for category-probability curve exports. Returns
tidy curve coordinates and summary metadata for quick plotting/report
integration without calling low-level helpers directly. The
expected-score table also carries the per-curve score variance and
information function. For `GPCM`, the information column follows the
Muraki/Samejima identity \\a^2 \mathrm{Var}(X \mid \theta)\\; for `RSM`
/ `PCM`, this reduces to the usual score variance because discrimination
is fixed at one. The `category_information` table decomposes that total
into category-level contributions, \\a^2 P_k(\theta)(k - E\[X \mid
\theta\])^2\\, whose sum equals the reported information at the same
theta value. The `cumulative_probabilities` table follows the FACETS /
Winsteps graph convention of accumulating modeled probabilities across
ordered categories (`P(X <= k)` by default, with `P(X >= k)` also
returned for flipped curves). `cumulative_boundaries` reports
approximate theta values where `P(X <= k) = .5`, with `BoundaryStatus`
and `CrossingCount` to avoid over-interpreting boundaries outside the
requested theta range or with multiple crossings.

These are reference-profile curves. Estimated step parameters and, for
`GPCM`, each step-facet group's estimated slope are retained, while
additive facet main effects and fitted interactions are fixed at zero.
The `CurveBasis` and `PredictorOffset` columns, and the corresponding
entries in `settings`, make that conditioning explicit. Thus the curves
do not represent an arbitrary observed Person-by-facet cell.

## Interpreting output

Use this report to inspect:

- where each category has highest probability across theta

- where cumulative category probabilities cross .5

- whether adjacent categories cross in expected order

- whether probability bands look compressed (often sparse categories)

Recommended read order:

1.  `summary(out)` for compact diagnostics.

2.  `out$probabilities`, `out$expected_ogive`, and
    `out$category_information` for custom graphics.

3.  `plot(out)` for a default visual check, or
    `plot(out, type = "cumulative")` to inspect cumulative
    probabilities. `plot(out, type = "information")` to inspect
    curve-level information. Use
    `plot(out, type = "category_information")` when category-level
    contributions are needed.

## References

Category response curves follow Andrich's rating-scale formulation,
Masters' partial-credit model, and Muraki's generalized partial-credit
model. The `Information` column for bounded `GPCM` uses Muraki's
item-information result obtained from Samejima's general polytomous
information formula.

- Andrich, D. (1978). *A rating formulation for ordered response
  categories*. Psychometrika, 43(4), 561-573.

- Masters, G. N. (1982). *A Rasch model for partial credit scoring*.
  Psychometrika, 47(2), 149-174.

- Muraki, E. (1992). *A generalized partial credit model: Application of
  an EM algorithm*. Applied Psychological Measurement, 16(2), 159-176.
  [doi:10.1177/014662169201600206](https://doi.org/10.1177/014662169201600206)

- Muraki, E. (1993). *Information functions of the generalized partial
  credit model*. Applied Psychological Measurement, 17(4), 351-363.
  [doi:10.1177/014662169301700403](https://doi.org/10.1177/014662169301700403)

## Typical workflow

1.  Fit model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Run `category_curves_report()` with suitable `theta_points`.

3.  Use [`summary()`](https://rdrr.io/r/base/summary.html) and
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html); export
    tables for manuscripts/dashboard use. `plot(out)` gives a four-panel
    overview. Use `preset = "monochrome"` for grayscale/line-type output
    and `boundary_status = "none"` when cumulative `.5` boundary lines
    should be suppressed. `plot(out, type = "category_probability")` and
    `plot(out, type = "conditional_probability")` are explicit aliases
    for the same category-probability curves as `type = "ccc"`. Use
    `plot_data(out, component = "plot_long")` when rebuilding the curves
    with ggplot2, plotly, or another R graphics system.

## See also

[`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md),
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
out <- category_curves_report(fit, theta_points = 101)
summary(out)
#> mfrmr Category Curves Summary 
#>   Class: mfrm_category_curves
#>   Components: 8
#> 
#> Curve grid summary
#>                                 Metric   Value
#>                           curve_groups   1.000
#>                           theta_points 101.000
#>                             categories   4.000
#>                      legacy_graph_rows 101.000
#>                    expected_ogive_rows 101.000
#>                       probability_rows 404.000
#>                    probability_columns   4.000
#>            cumulative_probability_rows 808.000
#>               cumulative_boundary_rows   3.000
#>              category_information_rows 404.000
#>           boundary_rows_needing_review   0.000
#>      boundary_rows_outside_theta_range   0.000
#>  boundary_rows_with_multiple_crossings   0.000
#>                  max_total_information   0.661
#>               max_category_information   0.283
#> 
#> Boundary / curve rows: cumulative_boundaries
#>  CurveGroup BoundaryOrder LowerOrEqualCategory AboveCategory ThresholdCategory
#>      Common             1                    1             2                 2
#>      Common             2                    2             3                 3
#>      Common             3                    3             4                 4
#>  CumulativeDirection TargetProbability ThurstonianThreshold InThetaRange
#>          at_or_below               0.5               -1.540         TRUE
#>          at_or_below               0.5               -0.034         TRUE
#>          at_or_below               0.5                1.572         TRUE
#>  CrossingCount BoundaryStatus   BoundaryLabel
#>              1       in_range P(X <= 1) = 0.5
#>              1       in_range P(X <= 2) = 0.5
#>              1       in_range P(X <= 3) = 0.5
#> 
#> Settings
#>                  Setting
#>              theta_range
#>             theta_points
#>                   digits
#>              curve_basis
#>         predictor_offset
#>  curve_basis_description
#>            include_fixed
#>           fixed_max_rows
#>                   scales
#>                                                                                                                                Value
#>                                                                                                                                -6, 6
#>                                                                                                                                  101
#>                                                                                                                                    4
#>                                                                                                          zero_additive_facet_profile
#>                                                                                                                                    0
#>  Estimated step and, for GPCM, slope parameters are retained; additive facet main effects and fitted interactions are fixed at zero.
#>                                                                                                                                FALSE
#>                                                                                                                                  400
#>                                                                                                                          <table 1x2>
#> 
#> Notes
#>  - Category-curve bundle with probabilities, cumulative probabilities, total
#>    information, and category-specific information.
#>  - Category-specific information contributions sum to total information at the
#>    same curve and theta point.
#>  - Cumulative .5 boundary rows are in range with a single crossing where
#>    reported.
head(out$probabilities[, c("CurveGroup", "Theta", "Category", "Probability")])
#>   CurveGroup Theta Category Probability
#> 1     Common -6.00        1      0.9907
#> 2     Common -5.88        1      0.9896
#> 3     Common -5.76        1      0.9882
#> 4     Common -5.64        1      0.9868
#> 5     Common -5.52        1      0.9851
#> 6     Common -5.40        1      0.9832
p_overview <- plot(out, draw = FALSE)
p_overview$data$plot
#> [1] "overview"
p_cum <- plot(out, type = "cumulative", draw = FALSE)
head(p_cum$data$cumulative_boundaries)
#>   CurveGroup BoundaryOrder LowerOrEqualCategory AboveCategory ThresholdCategory
#> 1     Common             1                    1             2                 2
#> 2     Common             2                    2             3                 3
#> 3     Common             3                    3             4                 4
#>   CumulativeDirection TargetProbability ThurstonianThreshold InThetaRange
#> 1         at_or_below               0.5              -1.5400         TRUE
#> 2         at_or_below               0.5              -0.0335         TRUE
#> 3         at_or_below               0.5               1.5722         TRUE
#>   CrossingCount BoundaryStatus   BoundaryLabel
#> 1             1       in_range P(X <= 1) = 0.5
#> 2             1       in_range P(X <= 2) = 0.5
#> 3             1       in_range P(X <= 3) = 0.5
p_info <- plot(out, type = "category_information", draw = FALSE)
head(p_info$data$category_information)
#>   CurveGroup Theta Category Probability ExpectedScore ScoreVariance Information
#> 1     Common -6.00        1      0.9907        1.0093        0.0092      0.0092
#> 2     Common -5.88        1      0.9896        1.0105        0.0104      0.0104
#> 3     Common -5.76        1      0.9882        1.0118        0.0117      0.0117
#> 4     Common -5.64        1      0.9868        1.0133        0.0132      0.0132
#> 5     Common -5.52        1      0.9851        1.0150        0.0149      0.0149
#> 6     Common -5.40        1      0.9832        1.0169        0.0167      0.0167
#>   CategoryInformation CategoryInformationShare Slope Model
#> 1               1e-04                   0.0092     1   RSM
#> 2               1e-04                   0.0104     1   RSM
#> 3               1e-04                   0.0117     1   RSM
#> 4               2e-04                   0.0132     1   RSM
#> 5               2e-04                   0.0148     1   RSM
#> 6               3e-04                   0.0167     1   RSM
#>                    CurveBasis PredictorOffset
#> 1 zero_additive_facet_profile               0
#> 2 zero_additive_facet_profile               0
#> 3 zero_additive_facet_profile               0
#> 4 zero_additive_facet_profile               0
#> 5 zero_additive_facet_profile               0
#> 6 zero_additive_facet_profile               0
curve_long <- plot_data(out, component = "plot_long")
head(curve_long[, c("PlotType", "Theta", "Series", "Value")])
#>   PlotType Theta Series  Value
#> 1    ogive -6.00 Common 1.0093
#> 2    ogive -5.88 Common 1.0105
#> 3    ogive -5.76 Common 1.0118
#> 4    ogive -5.64 Common 1.0133
#> 5    ogive -5.52 Common 1.0150
#> 6    ogive -5.40 Common 1.0169
# }
```
