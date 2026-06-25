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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
out <- category_curves_report(fit, theta_points = 101)
summary(out)
head(out$probabilities[, c("CurveGroup", "Theta", "Category", "Probability")])
p_overview <- plot(out, draw = FALSE)
p_overview$data$plot
p_cum <- plot(out, type = "cumulative", draw = FALSE)
head(p_cum$data$cumulative_boundaries)
p_info <- plot(out, type = "category_information", draw = FALSE)
head(p_info$data$category_information)
curve_long <- plot_data(out, component = "plot_long")
head(curve_long[, c("PlotType", "Theta", "Series", "Value")])
}
```
