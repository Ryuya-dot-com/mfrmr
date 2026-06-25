# Compute design-weighted precision curves for ordered many-facet fits

Calculates design-weighted score-variance curves across the latent trait
(theta) for a fitted ordered-category `RSM`, `PCM`, or bounded `GPCM`
model. Returns both an overall precision curve (`$tif`) and
per-facet-level contribution curves (`$iif`) based on the realized
observation pattern.

## Usage

``` r
compute_information(fit, theta_range = c(-6, 6), theta_points = 201L)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- theta_range:

  Numeric vector of length 2 giving the range of theta values. Default
  `c(-6, 6)`.

- theta_points:

  Integer number of points at which to evaluate information. Default
  `201`.

## Value

An object of class `mfrm_information` (named list) with:

- `tif`: tibble with columns `Theta`, `Information`, `SE`. The
  `Information` column stores the design-weighted precision value.

- `iif`: tibble with columns `Theta`, `Facet`, `Level`, `Information`,
  and `Exposure`. Here too, `Information` stores a design-weighted
  contribution value retained under that column name for compatibility.

- `theta_range`: the evaluated theta range.

## Details

For `RSM` / `PCM`, the score variance at theta for one observed design
cell is: \$\$I(\theta) = \sum\_{k=0}^{K} P_k(\theta) \left(k -
E(\theta)\right)^2\$\$ where \\P_k\\ is the category probability and
\\E(\theta)\\ is the expected score at theta. In `mfrmr`, these
cell-level variances are then aggregated with weights taken from the
realized observation counts in `fit$prep$data`.

The resulting total curve is therefore a design-weighted precision
screen rather than a pure textbook test-information function for an
abstract fixed item set. The associated standard error summary is still
\\SE(\theta) = 1 / \sqrt{I(\theta)}\\ for positive information values.

In an ordered Rasch-family model, category discrimination is fixed at 1,
so this score-variance representation is the natural conditional
information identity rather than a separate approximation. For binary
data it reduces to the familiar \\p(\theta)\\1 - p(\theta)\\\\ form. For
`PCM`, the package evaluates each observed design cell using the
threshold vector associated with that cell's realized `step_facet`
level. For bounded `GPCM`, the same design-weighted score variance is
scaled by the squared discrimination attached to the realized
`slope_facet` level, which is the \\a_j^2 \cdot \mathrm{Var}(T \mid
\theta)\\ item-information identity that Muraki (1993, Equation 10)
derives by applying Samejima's (1974) polytomous information formula to
the GPCM kernel of Muraki (1992).

## What `tif` and `iif` mean here

In `mfrmr`, this helper supports ordered-category `RSM`, `PCM`, and the
current bounded `GPCM` fit. The total curve (`$tif`) is the sum of
design-weighted cell contributions across all non-person facet levels in
the fitted model. The facet-level contribution curves (`$iif`) keep
those weighted contributions separated, so you can see which observed
rater levels, criteria, or other facet levels are driving precision at
different parts of the scale. For `PCM`, step-facet-specific thresholds
are respected when each observed design cell is evaluated. For bounded
`GPCM`, those same cell-level variances are additionally scaled by the
squared discrimination associated with the realized `slope_facet` level.

## What this quantity does not justify

- It is not a textbook many-facet test-information function for an
  abstract fixed item set.

- It should not be used as if it were design-free evidence about a
  form's precision independent of the realized observation pattern.

- It does not currently extend beyond the ordered-category `RSM` / `PCM`
  / bounded `GPCM` family implemented by
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## When to use this

Use `compute_information()` when you want a design-weighted precision
screen for an `RSM`, `PCM`, or bounded `GPCM` fit along the latent
continuum. In practice:

- start with the total precision curve for overall targeting across the
  realized observation pattern

- inspect facet-level contribution curves when you want to see which
  raters, criteria, or other facet levels account for more of that
  design-weighted precision

- widen `theta_range` if you expect extreme measures and want to inspect
  the tails explicitly

## Choosing the theta grid

The defaults (`theta_range = c(-6, 6)`, `theta_points = 201`) work well
for routine inspection. Expand the range if person or facet measures
extend into the tails, and increase `theta_points` only when you need a
smoother grid for reporting or custom graphics.

## References

The ordered-category probability structures come from Andrich's `RSM`
formulation and Masters' `PCM`. The bounded `GPCM` information identity
\\a_j^2 \cdot \mathrm{Var}(T \mid \theta)\\ is derived in Muraki (1993,
Equation 10) by applying Samejima's (1974) general polytomous
information formula \\I_j(\theta) = \sum_k P\_{jk}(\theta) \[-\partial^2
\ln P\_{jk} / \partial \theta^2\]\\ to the GPCM probability kernel of
Muraki (1992). For the integer scoring function \\T_k = k\\ used by
`mfrmr`, this reduces to \\a_j^2 \cdot \mathrm{Var}(K \mid \theta)\\. In
`mfrmr`, those formulas are applied to the realized many-facet
observation design, so the output should be read as a design-weighted
precision summary rather than as a design-free abstract test function.

- Andrich, D. (1978). *A rating formulation for ordered response
  categories*. Psychometrika, 43(4), 561-573.

- Masters, G. N. (1982). *A Rasch model for partial credit scoring*.
  Psychometrika, 47(2), 149-174.

- Muraki, E. (1992). *A generalized partial credit model: Application of
  an EM algorithm*. Applied Psychological Measurement, 16(2), 159-176.
  [doi:10.1177/014662169201600206](https://doi.org/10.1177/014662169201600206)
  (See Equations 6, 10, and 13 for the probability kernel and the
  \\\partial P_k / \partial \theta = a_j P_k (k - E\[K\])\\ derivative
  used by all GPCM helpers in `mfrmr`.)

- Muraki, E. (1993). *Information functions of the generalized partial
  credit model*. Applied Psychological Measurement, 17(4), 351-363.
  [doi:10.1177/014662169301700403](https://doi.org/10.1177/014662169301700403)
  (Equation 10 derives the item information function for the GPCM,
  \\I_j(\theta) = D^2 a_j^2 \mathrm{Var}(T \mid \theta)\\, by applying
  Samejima's (1974) polytomous information formula to the GPCM kernel;
  this is the canonical reference for `compute_information()` under
  bounded `GPCM`.)

- Samejima, F. (1974). *Normal ogive model on the continuous response
  level in the multidimensional latent space*. Psychometrika, 39,
  111-121. (Source for the general polytomous information formula that
  Muraki 1993 specializes to the GPCM.)

## Interpreting output

- `$tif`: design-weighted precision curve data with theta, Information,
  and SE.

- `$iif`: design-weighted facet-level contribution curves for the fitted
  non-person facets.

- Higher information implies more precise measurement at that theta.

- SE is inversely related to information.

- Peaks in the total curve show the trait region where the realized
  calibration is most informative.

- Facet-level curves help explain *which observed facet levels*
  contribute to those peaks; they are not standalone item-information
  curves and should be read as design contributions.

## How to read the main columns

- `Theta`: point on the latent continuum where the curve is evaluated.

- `Information`: design-weighted precision value at that theta.

- `SE`: approximate `1 / sqrt(Information)` summary for positive values.

- `Exposure`: total realized observation weight contributing to a
  facet-level curve in `$iif`.

## Recommended next step

Compare the precision peak with person/facet locations from a Wright map
or related diagnostics. If you need to decide how strongly SE/CI
language can be used in reporting, follow with
[`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md).

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Run `compute_information(fit)`.

3.  Plot with `plot_information(info, type = "tif")`.

4.  If needed, inspect facet contributions with
    `plot_information(info, type = "iif", facet = "Rater")`.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", model = "RSM", maxit = 30)
info <- compute_information(fit)
head(info$tif)
#> # A tibble: 6 × 3
#>   Theta Information    SE
#>   <dbl>       <dbl> <dbl>
#> 1 -6           7.61 0.363
#> 2 -5.94        8.07 0.352
#> 3 -5.88        8.56 0.342
#> 4 -5.82        9.09 0.332
#> 5 -5.76        9.64 0.322
#> 6 -5.7        10.2  0.313
info$tif$Theta[which.max(info$tif$Information)]
#> [1] -0.06
```
