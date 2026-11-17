# Compute design-weighted precision curves for ordered many-facet fits

Calculates design-weighted score-variance curves across the latent trait
(theta) for a fitted ordered-category `RSM`, `PCM`, or `GPCM` model.
Returns both an overall precision curve (`$tif`) and per-facet-level
contribution curves (`$iif`) based on the realized observation pattern,
or an explicit rating plan for one Person.

## Usage

``` r
compute_information(
  fit,
  theta_range = c(-6, 6),
  theta_points = 201L,
  rating_plan = NULL
)

# S3 method for class 'mfrm_information'
plot(
  x,
  type = c("tif", "iif", "se", "sem", "csem", "both"),
  facet = NULL,
  draw = TRUE,
  ...
)
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

- rating_plan:

  Optional data frame with every non-Person facet column and `Count`: a
  positive integer number of conditionally independent ratings in each
  unique context for one Person. Use fitted facet levels; omit Person
  IDs, responses and estimation weights. `NULL` retains the
  observed-exposure calculation. `Count` and `ObservedContext` are
  reserved names and cannot name facets in this mode.

- x:

  Output from `compute_information()`.

- type:

  `"tif"` for the overall precision curve (default), `"iif"` for
  facet-level contribution curves, `"se"` / `"sem"` / `"csem"` for the
  conditional standard error of measurement implied by that curve, or
  `"both"` for precision and conditional SEM in separate panels.

- facet:

  For `type = "iif"`, which facet to plot. If `NULL`, the first facet is
  used.

- draw:

  If `TRUE`, print the plot. Otherwise return it without drawing.

- ...:

  Additional arguments for the selected view.

## Value

An object of class `mfrm_information` (named list) with:

- `tif`: tibble with columns `Theta`, `Information`, `SE`. The
  `Information` column stores the design-weighted precision value.

- `iif`: tibble with columns `Theta`, `Facet`, `Level`, `Information`,
  and `Exposure` (observed weight or planned rating count).

- `conditional_sem`, `information_long`, `summary`: plotting series and
  grid-specific extrema. `theta_range` records the evaluated range.

- With an explicit plan, `rating_plan`, `settings` and `notes` retain
  its counts, observed/unobserved crossings and interpretation limits.
  These are also available from the returned plot via
  [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object carrying the underlying plot data (inspect via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)).

## Details

For a rating context, information is \$\$I(\theta) = a^2 \sum\_{k=0}^{K}
P_k(\theta)\\k-E(K\mid\theta)\\^2.\$\$ Here \\a=1\\ for RSM/PCM;
one-family GPCM uses the fitted `slope_facet` discrimination. PCM/GPCM
use the context's `step_facet` thresholds. This is Muraki's (1993,
Equation 10) conditional information identity, with logistic scaling
constant 1. For binary Rasch responses it reduces to \\p(1-p)\\.
Variance is computed about the category mean to avoid cancellation near
endpoints; floating-point underflow remains possible.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
design-weighted information or conditional precision

Plot a saved `compute_information()` result to see where the observed
assessment design provides more or less precision across ability.

## Observed exposure or one Person's plan

With `rating_plan = NULL`, each context is weighted by its total
observed response weight in `fit$prep$data`, across all Persons.
Duplicating that dataset doubles information at fixed calibration. This
is an observed-design precision screen, not one Person's test
information or EAP uncertainty.

With an explicit `rating_plan`, each context is weighted by `Count` for
one Person. Supported sources are converged native additive MML RSM/PCM
and one-family GPCM fits without known nonfinite maxima or
limiting-model reductions. Unknown facet levels are refused; unobserved
crossings of known levels have `ObservedContext = FALSE` and represent
model extrapolation. Zero-weight rows do not qualify a context as
observed in calibration. `Count` assumes conditionally independent
ratings: copying a response, or adding correlated ratings, does not
provide this amount of information.

Compare plans on the same calibration and ability scale. Equal rating
counts need not provide equal information across ability. GPCM working
coordinates remain usable for conditional exploration when primary slope
estimates are unavailable; `settings$ParameterBasis` and `notes`
identify this limitation. A finite curve does not certify
identification, model fit or plan suitability.

## Interpretation and limits

- `$tif` sums context information. Within each facet, `$iif`
  contributions sum to that total; summing across facets counts
  responses repeatedly.

- `SE` is \\1/\sqrt{I(\theta)}\\ when information is positive; otherwise
  it is `NA`. It is a conditional information-based SEM, not an EAP
  posterior SD or a finite-sample confidence interval. Calibration
  uncertainty is not propagated.

- The calculation uses additive facet locations. In the default
  observed-exposure mode, interaction fits give an additive reference
  profile, not information under the full predictor; explicit plans
  refuse them. Two-family GPCM is unsupported in both modes.

- G-Study/D-Study targets observed-score G/Phi. Neither that target nor
  an optimal allocation follows from this conditional information
  calculation.

## References

- Andrich, D. (1978). A rating formulation for ordered response
  categories. Psychometrika, 43, 561-573.

- Masters, G. N. (1982). A Rasch model for partial credit scoring.
  Psychometrika, 47, 149-174.

- Muraki, E. (1992). A generalized partial credit model: Application of
  an EM algorithm. Applied Psychological Measurement, 16, 159-176.
  [doi:10.1177/014662169201600206](https://doi.org/10.1177/014662169201600206)
  . Probability kernel and score derivative.

- Muraki, E. (1993). Information functions of the generalized partial
  credit model. Applied Psychological Measurement, 17, 351-363.
  [doi:10.1177/014662169301700403](https://doi.org/10.1177/014662169301700403)
  . Equation 10 gives the information identity.

- Samejima, F. (1974). Normal ogive model on the continuous response
  level in the multidimensional latent space. Psychometrika, 39,
  111-121. General information formula specialized to GPCM by Muraki
  (1993).

## Plot types

- `"tif"`: overall design-weighted precision across theta.

- `"se"` / `"sem"` / `"csem"`: conditional SEM across theta.

- `"both"`: precision and conditional SEM together, useful for
  presentations.

- `"iif"`: facet-level contribution curves for one selected facet in a
  supported `RSM`, `PCM`, or `GPCM` fit.

## Returned data when draw = FALSE

`draw = FALSE` returns the reusable `ggplot` without printing it.
`plot_data(p)` exposes the underlying `plot`, `information_long`,
`conditional_sem`, `summary` and `settings` payloads. The overall curve
comes from `x$tif`; facet contributions come from `x$iif` filtered to
the selected facet. For an explicit plan, `rating_plan`, `plan_settings`
and `notes` retain its counts, calibration basis and interpretation
limits.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
plot(x)

`compute_information()`,
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("compute_information", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", model = "RSM",
                 quad_points = 7, maxit = 30)
info <- compute_information(fit)
head(info$tif)
info$tif$Theta[which.max(info$tif$Information)]
} # }
# One rating per selected rater and criterion, using a saved calibration.
fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))$fit
plan <- unique(fit$prep$data[c("Rater", "Criterion")])
plan$Count <- 1L
planned <- compute_information(fit, rating_plan = plan)
head(planned$tif)
#> # A tibble: 6 × 3
#>   Theta Information    SE
#>   <dbl>       <dbl> <dbl>
#> 1 -6          0.166  2.45
#> 2 -5.94       0.176  2.38
#> 3 -5.88       0.187  2.31
#> 4 -5.82       0.198  2.25
#> 5 -5.76       0.210  2.18
#> 6 -5.7        0.223  2.12
plot(planned, type = "both", draw = FALSE)
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_information", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", model = "RSM",
                 quad_points = 7, maxit = 30)
info <- compute_information(fit)
  tif_data <- plot(info, type = "tif", draw = FALSE)
  head(plot_data(tif_data, "plot"))
  iif_data <- plot(info, type = "iif", facet = "Rater", draw = FALSE)
  head(plot_data(iif_data, "plot"))
} # }
```
