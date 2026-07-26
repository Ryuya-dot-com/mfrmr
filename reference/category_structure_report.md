# Build a category structure report (preferred alias)

Build a category structure report (preferred alias)

## Usage

``` r
category_structure_report(
  fit,
  diagnostics = NULL,
  theta_range = c(-6, 6),
  theta_points = 241,
  drop_unused = FALSE,
  include_fixed = FALSE,
  fixed_max_rows = 200
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- theta_range:

  Theta/logit range used to derive transition points.

- theta_points:

  Number of grid points used for transition-point search.

- drop_unused:

  If `TRUE`, remove zero-count categories from outputs.

- include_fixed:

  If `TRUE`, include a legacy-compatible fixed-width text block.

- fixed_max_rows:

  Maximum rows per fixed-width section.

## Value

A named list with category-structure components. Class:
`mfrm_category_structure`.

## Details

Preferred high-level API for category-structure diagnostics. This wraps
the legacy-compatible bar/transition export and returns a stable bundle
interface for reporting and plotting.

## Interpreting output

Key components include:

- category usage/fit table (count, expected, infit/outfit, ZSTD)

- threshold ordering and adjacent threshold gaps

- category transition-point table on the requested theta grid

Practical read order:

1.  `summary(out)` for compact warnings and threshold ordering.

2.  `out$category_table` for sparse/misfitting categories.

3.  `out$median_thresholds` for adjacent-threshold caveats when
    zero-count categories are retained.

4.  `plot(out)` for quick visual check.

## Typical workflow

1.  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    -\> model.

2.  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    -\> residual/fit diagnostics (optional argument here).

3.  `category_structure_report()` -\> category health snapshot.

4.  [`summary()`](https://rdrr.io/r/base/summary.html) and
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
    draft-oriented review of category structure.

## See also

[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
[`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
out <- category_structure_report(fit)
summary(out)
#> mfrmr Category Structure Summary 
#>   Class: mfrm_category_structure
#>   Components: 9
#> 
#> Category structure overview
#>  Categories UsedCategories FlaggedStats ModeBoundaries MeanHalfscorePoints
#>           4              4            8              3                   3
#>  DiagnosticMode MarginalFitAvailable MarginalFlaggedCategories
#>            both                FALSE                        NA
#>  MarginalOverallRMSD MarginalMaxAbsStdResidual
#>                   NA                        NA
#> 
#> Category structure rows: category_table
#>  Category Count AvgPersonMeasure ExpectedAverage Infit Outfit MeanResidual
#>         1   139           -0.984           1.864 1.806  1.602       -0.864
#>         2   241           -0.376           2.262 0.613  0.780       -0.262
#>         3   252            0.328           2.734 0.556  0.617        0.266
#>         4   136            1.068           3.145 1.871  1.590        0.855
#>  DF_Infit DF_Outfit Percent InfitZSTD OutfitZSTD ExpectedCount ExpectedPercent
#>    70.957       139  18.099     3.947      4.292       138.998          18.099
#>   138.039       241  31.380    -3.710     -2.586       241.000          31.380
#>   145.307       252  32.812    -4.511     -4.977       252.001          32.813
#>    66.751       136  17.708     4.081      4.176       136.002          17.709
#>  DiffCount DiffPercent LowCount InfitFlag OutfitFlag ZSTDFlag ZeroCount
#>      0.002           0    FALSE      TRUE       TRUE     TRUE     FALSE
#>      0.000           0    FALSE     FALSE      FALSE     TRUE     FALSE
#>     -0.001           0    FALSE     FALSE      FALSE     TRUE     FALSE
#>     -0.002           0    FALSE      TRUE       TRUE     TRUE     FALSE
#>  UnusedCategoryType WeaklyIdentified CategoryCaveat
#>                none            FALSE               
#>                none            FALSE               
#>                none            FALSE               
#>                none            FALSE               
#> 
#> Settings
#>         Setting Value
#>     theta_range -6, 6
#>    theta_points   241
#>     drop_unused FALSE
#>   include_fixed FALSE
#>  fixed_max_rows   200
#> 
#> Notes
#>  - Category-structure diagnostics with mode boundaries and half-score reference
#>    points.
head(out$category_table[, c("Category", "Count", "Infit", "Outfit")])
#>   Category Count     Infit    Outfit
#> 1        1   139 1.8058940 1.6016812
#> 2        2   241 0.6131071 0.7801200
#> 3        3   252 0.5555712 0.6169771
#> 4        4   136 1.8705501 1.5900752
p_cs <- plot(out, draw = FALSE)
p_cs$data$plot
#> [1] "counts"
# }
```
