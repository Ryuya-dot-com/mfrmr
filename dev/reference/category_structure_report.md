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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional matching output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).
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
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/rating_scale_table.md),
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
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md);
modal-boundary and half-score views require the base renderer or
explicitly grouped custom graphics from
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).

## Typical workflow

1.  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
    -\> model.

2.  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
    -\> residual/fit diagnostics (optional argument here).

3.  `category_structure_report()` -\> category health snapshot.

4.  [`summary()`](https://rdrr.io/r/base/summary.html) and
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
    draft-oriented review of category structure.

## See also

[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/rating_scale_table.md),
[`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/category_curves_report.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_reports_and_tables.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("category_structure_report", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
out <- category_structure_report(fit)
summary(out)
head(out$category_table[, c("Category", "Count", "Infit", "Outfit")])
p_cs <- plot(out, draw = FALSE)
p_cs$data$plot
} # }
```
