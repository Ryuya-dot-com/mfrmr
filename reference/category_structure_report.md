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

  Optional matching output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  Reuses stored uncertainty and marginal-fit results; omitted
  diagnostics do not trigger a covariance calculation.

- theta_range:

  Theta/logit range used to derive transition points.

- theta_points:

  Number of grid points used for transition-point search.

- drop_unused:

  If `TRUE`, remove zero-count rows from the global category display.
  Owner-specific counts and their denominators remain complete.

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

- category usage and descriptive residual table; category ZSTD and fit
  flags are unavailable because outcome-selected residuals lack a unit
  baseline

- threshold ordering and adjacent threshold gaps

- category transition-point table on the requested theta grid

Practical read order:

1.  `summary(out)` for compact warnings and threshold ordering.

2.  `out$category_table` for sparse/misfitting categories.

3.  `out$median_thresholds` for cumulative 50% boundaries and their
    range status; `AndrichThreshold` separately retains
    adjacent-category steps.

4.  `plot(out)` for quick visual check.

`owner_category_table`, `threshold_table`, `model_context` and `notes`
follow
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
including source checks and uncertainty status. The global usage display
does not replace owner-specific counts. `curve_profiles` maps each
`CurveGroup` to its step/slope owners and levels. Curves use zero
additive facet locations. `MedianThreshold` now solves a cumulative 50%
boundary, replacing the old mislabeled adjacent-category step. Recreate
saved category structure reports; no calibration refit is needed.
Half-score crossings outside `theta_range` are NA with an explicit
status. Mode peaks describe the finite grid, not an unbounded global
maximum. Stored step SEs are reported only in `threshold_table`, not
transferred to modal, half-score or cumulative boundaries. Two-family
GPCM remains unsupported by this helper. Counts support
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md);
modal-boundary and half-score views require the base renderer or
explicitly grouped custom graphics from
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

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
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
out <- category_structure_report(fit)
summary(out)
#> mfrmr Category Structure Summary
#> 
#> Category coverage
#>  Categories Displayed Used Counts available Counts unavailable Flags
#>           4         4    4                4                  0     0
#>  Decisions available Decisions unavailable
#>                    4                     0
#> 
#> Category rows
#>  Category Count Percent Expected count Infit Outfit Infit ZSTD Outfit ZSTD
#>         1   139  18.099            139 1.806  1.602         NA          NA
#>         2   241  31.380            241 0.613  0.780         NA          NA
#>         3   252  32.812            252 0.556  0.617         NA          NA
#>         4   136  17.708            136 1.871  1.590         NA          NA
#>   Category-structure diagnostics with mode boundaries and half-score reference
#>   points.
#>   Step owner: Common; selection: not_applicable.
#>   A Step describes the transition between adjacent score categories, not a
#>   learning stage or a pass/fail cut. At the corresponding predictor value, the
#>   two categories have equal probability, not necessarily probability 0.5 each.
#>   Stored step offsets and full ability-axis crossings differ when other facet
#>   effects or interactions are included; check the reference profile and step
#>   owner.
#>   Category counts are observed ratings, not independent Persons. Owner
#>   percentages use each owner's total weight; no-exposure percentages are
#>   unavailable.
#>   An unobserved category does not establish structural absence. Review the
#>   rating plan and rubric before merging categories.
#>   Step SEs describe the stored step offsets, not full ability-axis crossings,
#>   adjacent-step gaps or decision cuts. No additional covariance calculation is
#>   requested.
#>   Legacy step uncertainty without full source identity is retained for review;
#>   inspect SE_Status, CIUse and UncertaintySourceStatus.
#>   Curves use zero-additive-facet reference profiles. MedianThreshold is a
#>   cumulative 50% boundary; AndrichThreshold is an adjacent-category step.
#>   MeanBoundaryTheta is unavailable outside theta_range. PeakTheta is a
#>   finite-grid peak.
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
```
