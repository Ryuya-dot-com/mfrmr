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
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
out <- category_structure_report(fit)
summary(out)
#> mfrmr Category Structure Summary
#> 
#> Category coverage
#>  Categories Displayed Used Counts available Counts unavailable Flags
#>           4         4    4                4                  0     8
#>  Decisions available Decisions unavailable
#>                   16                     0
#> 
#> Category rows
#>  Category Count Percent Expected count Infit Outfit Infit ZSTD Outfit ZSTD
#>         1   139  18.099            139 1.806  1.602      3.947       4.292
#>         2   241  31.380            241 0.613  0.780     -3.711      -2.587
#>         3   252  32.812            252 0.556  0.617     -4.511      -4.978
#>         4   136  17.708            136 1.871  1.590      4.081       4.176
#>   Category-structure diagnostics with mode boundaries and half-score reference
#>   points.
#>   Category counts were available for all 4 categories: 0 unused and 0 below 10.
#>   Counts alone do not establish category adequacy.
#>   Flag counts describe available decisions in the displayed rows; unavailable
#>   decisions do not indicate an absence of warnings.
head(out$category_table[, c("Category", "Count", "Infit", "Outfit")])
#>   Category Count     Infit    Outfit
#> 1        1   139 1.8058056 1.6016256
#> 2        2   241 0.6130391 0.7800174
#> 3        3   252 0.5555312 0.6169201
#> 4        4   136 1.8705483 1.5900860
p_cs <- plot(out, draw = FALSE)
p_cs$data$plot
#> [1] "counts"
# }
```
