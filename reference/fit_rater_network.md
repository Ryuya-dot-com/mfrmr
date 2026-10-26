# Fit an ERGM to a declared binary rater network

Model network configurations and rater covariates after examining shared
rating coverage with
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md)
or
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md).
Estimation uses the optional `ergm` package.

## Usage

``` r
fit_rater_network(
  x,
  terms,
  threshold,
  relation = c("greater", "less"),
  node_data = NULL,
  missing = c("error", "model"),
  control = NULL,
  gof = NULL,
  gof_control = NULL,
  seed = NULL
)

# S3 method for class 'mfrm_network_ergm'
summary(object, ...)

# S3 method for class 'mfrm_network_ergm'
coef(object, ...)

# S3 method for class 'mfrm_network_ergm'
vcov(object, ...)

# S3 method for class 'mfrm_network_ergm'
confint(object, parm = NULL, level = 0.95, ...)
```

## Arguments

- x:

  A rater or halo network result. All eligible pair metrics are used,
  before graph/plot filtering; missing comparisons never become zero
  ties.

- terms:

  One-sided ERGM formula, for example `~ edges + mutual` for a directed
  network, or `~ edges + nodecov("Experience")`. See
  [`ergm::ergmTerm`](https://rdrr.io/pkg/ergm/man/ergmTerm.html) for
  terms appropriate to the declared graph.

- threshold:

  Required finite cutoff for the chosen pair metric.

- relation:

  `"greater"` makes a tie when the metric is strictly greater than the
  threshold; `"less"` makes one when strictly smaller. Equal values are
  observed non-ties. Negative alpha is not automatically a positive tie.

- node_data:

  Optional data frame with `Node` IDs and complete node covariates. IDs
  must match all nodes exactly; order is matched by ID.

- missing:

  `"error"` requires all dyads to be observed. `"model"` explicitly
  permits unobserved dyads, represented by `NA`, using ergm's
  observed-data likelihood under an ignorable missingness assumption.

- control:

  Optional
  [`ergm::control.ergm()`](https://rdrr.io/pkg/ergm/man/control.ergm.html)
  object.

- gof:

  Optional one-sided formula for simulation-based model checks, e.g.
  `~ degree + distance` for an undirected graph. See
  [`ergm::gof.ergm`](https://rdrr.io/pkg/ergm/man/gof.html).

- gof_control:

  Optional
  [`ergm::control.gof.ergm()`](https://rdrr.io/pkg/ergm/man/control.gof.html)
  object.

- seed:

  Optional integer seed; the caller's RNG state is restored.

- object:

  An `mfrm_network_ergm` result.

- ...:

  Unused; unexpected arguments are rejected by extractors.

- parm:

  Coefficient names or positive integer positions; NULL selects all.

- level:

  Confidence level strictly between zero and one.

## Value

An `mfrm_network_ergm` object with the backend `fit`, binary `network`,
complete `dyads`, `nodes`, coefficient/diagnostic/settings tables,
backend warnings and optional `gof` with long-form simulation tables.
[`summary()`](https://rdrr.io/r/base/summary.html) retains model
settings and diagnostic cautions.
[`coef()`](https://rdrr.io/r/stats/coef.html) and
[`vcov()`](https://rdrr.io/r/stats/vcov.html) extract backend
coefficient coordinates;
[`confint()`](https://rdrr.io/r/stats/confint.html) returns approximate
pointwise normal intervals without refitting.
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) uses the
originally stored 95% intervals or saved simulation GOF. Use
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
for stored reporting.

## Details

This is a binary ERGM, not a valued/signed ERGM or a rating-response
model. A coefficient is a conditional network log-odds coefficient for
its change statistic; it is not an MFRM severity, a causal rater effect
or an independent rating-level regression. Thresholds, sampling of
raters, overlap and node covariates define the question. Prespecify them
and assess sensitivity by refitting at substantively plausible
thresholds; do not select a threshold for significance. Different
thresholds define different response networks: their AIC values do not
select a best threshold.

A missing dyad includes insufficient overlap and an undefined
association. Such missingness need not be ignorable (e.g. constant
scores or assignment related to rater characteristics).
`missing = "model"` asserts an assumption, not a correction for
informative missingness. Self-ties are excluded. Unobserved dyads are
not structural zeroes. For structural constraints or valued ERGMs, use
the returned `network` with
[`ergm::ergm()`](https://rdrr.io/pkg/ergm/man/ergm.html) explicitly.

Estimation requests MLE. For dyad-independent terms MPLE is also the
MLE; dependent terms require MCMC. A returned fit is not proof of
convergence or model adequacy. Inspect
`ergm::mcmc.diagnostics(result$fit)` and the saved `gof` object; review
warnings, degeneracy, effective sample size and mixing. GOF tail areas
are simulation diagnostics, not tests of halo. Intervals in the
coefficient table are approximate pointwise normal intervals,
conditional on the chosen network model and adequate estimation. Small
rater networks may not support complex models. Neither mfrmr nor this
wrapper validates arbitrary ERGM specifications or corrects
estimated-edge uncertainty.

[`confint()`](https://rdrr.io/r/stats/confint.html) preserves
unavailable coefficients as missing bounds. Its matrix attributes retain
`level`, `method`, `diagnostics` and `notes`. These intervals remain
conditional on the selected binary network and model; they do not
propagate estimated-edge or model-selection uncertainty. Changing
`level` does not change the fitted object or its stored plot.

## References

Lamprianou, I. (2018). Investigation of rater effects using social
network analysis and exponential random graph models. Educational and
Psychological Measurement, 78, 430–459. doi:10.1177/0013164416689696.

## See also

[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md),
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md),
[`plot.mfrm_network_ergm()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_network_ergm.md)

## Examples

``` r
if (requireNamespace("ergm", quietly = TRUE) &&
    requireNamespace("igraph", quietly = TRUE)) {
  ratings <- load_mfrmr_data("example_core")
  fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    method = "JML", maxit = 300)
  rn <- rater_network_analysis(fit, weight_metric = "KrippendorffAlpha")
  # Four synthetic raters: illustrate the handoff, not a complex ERGM.
  # Tie = pairwise interval alpha strictly above the declared 0.35 cutoff.
  model <- fit_rater_network(rn, ~ edges, threshold = 0.35, seed = 41)
  model$dyads
  summary(model)$diagnostics
  confint(model, level = 0.90) # Approximate, conditional on this binary network
  mfrm_report(model)$tables$coefficients
  plot(model, draw = FALSE)
}
#> Registered S3 methods overwritten by 'ergm':
#>   method               from
#>   simulate.formula     lme4
#>   simulate.formula_lhs lme4
#> Starting maximum pseudolikelihood estimation (MPLE):
#> Obtaining the responsible dyads.
#> Evaluating the predictor and response matrix.
#> Maximizing the pseudolikelihood.
#> Finished MPLE.
#> Evaluating log-likelihood at the estimate. 
#> 
```
