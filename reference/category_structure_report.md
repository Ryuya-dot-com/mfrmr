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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
out <- category_structure_report(fit)
summary(out)
head(out$category_table[, c("Category", "Count", "Infit", "Outfit")])
p_cs <- plot(out, draw = FALSE)
p_cs$data$plot
}
```
