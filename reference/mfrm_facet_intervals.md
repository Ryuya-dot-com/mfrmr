# Pointwise intervals for fixed facet estimates and contrasts

Quantify uncertainty in fixed non-Person facet locations, two-way
interaction cells, or prespecified linear contrasts from a supported
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
result. Inspect `Estimate`, `Status`, `CIEligible`, `CoverageQualified`,
and `InferenceReview` together in `summary(intervals)`: missing bounds
do not imply zero uncertainty, and `Status = "fixed"` marks
constraint-pinned targets without inferential intervals.

## Usage

``` r
mfrm_facet_intervals(
  fit,
  facet = NULL,
  contrasts = NULL,
  method = c("model", "sandwich", "profile"),
  clusters = NULL,
  adjust = FALSE,
  level = 0.95,
  scale = c("native", "standardized"),
  comparison_review = NULL,
  anchor_covariance = NULL,
  independent_anchors = FALSE,
  interaction = NULL,
  profile_control = list()
)

# S3 method for class 'mfrm_facet_intervals'
print(x, ...)

# S3 method for class 'mfrm_facet_intervals'
summary(object, ...)

# S3 method for class 'mfrm_facet_intervals'
confint(object, parm = NULL, level = object$settings$level, ...)

# S3 method for class 'mfrm_facet_intervals'
vcov(object, ...)

# S3 method for class 'mfrm_facet_intervals'
plot(
  x,
  comparison = TRUE,
  draw = TRUE,
  preset = "standard",
  title = paste(x$settings$facet, if (identical(x$settings$target,
    "category_step_offsets")) "step offsets" else "estimates and contrasts"),
  subtitle = paste0(format(100 * x$settings$level, trim = TRUE), if
    (identical(x$settings$method, "profile")) "% connected profile interval | " else
    "% pointwise normal intervals | ", if (identical(x$settings$method, "profile"))
    "Profile likelihood" else if (x$settings$method == "sandwich") paste0("Sandwich | ",
    x$settings$clusters, " independent clusters assumed") else if
(identical(x$settings$procedure, "cml_conditional_information"))
    "Conditional information" else if (identical(x$settings$uncertainty,
    "independent_anchor_delta")) "Information + anchor source" else
    "Observed information"),
  caption = if (any(!is.finite(x$table$Estimate)))
    paste0("Not estimated: no point or interval | ",
    "Crosses: estimated points with unavailable intervals") else if (any(x$table$Status
    != "available"))
    "Open diamonds: fixed targets | Crosses: unavailable selected intervals" else NULL,
  reference = 0,
  show_legend = TRUE,
  ...
)
```

## Arguments

- fit:

  Supported
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  result (ordinary or estimated-population RSM/PCM MML, one- or
  two-family GPCM MML, or native full/comparison-only RSM/PCM CML; JML
  structural intervals are unsupported).

- facet:

  Non-Person facet name (e.g., `"Rater"`); omit when selecting
  `interaction`, `comparison_review`, or a CML comparison-only fit.

- contrasts:

  Optional named numeric matrix with columns matching all levels of
  `facet` (or all interaction `Target` cells).

- method:

  `"model"` (default: inverse full joint observed marginal or
  conditional information), `"sandwich"` (independent-Person or cluster
  marginal-score sandwich `H^{-1} (sum_g s_g s_g') H^{-1}` for ordinary
  fixed-\\N(0,1)\\ RSM/PCM MML), or experimental `"profile"`
  (reoptimizes one pairwise `+1/-1` contrast over residual variance
  `>= 0` in unanchored estimated-normal direct RSM/PCM MML).

- clusters:

  Optional one-row-per-Person `data.frame` (`Person`, `Cluster`) and
  `G/(G - 1)` finite-cluster multiplier (`FALSE` default) for
  `method = "sandwich"`.

- adjust:

  Optional one-row-per-Person `data.frame` (`Person`, `Cluster`) and
  `G/(G - 1)` finite-cluster multiplier (`FALSE` default) for
  `method = "sandwich"`.

- level:

  Pointwise confidence level in `(0, 1)` (default `0.95`).

- scale:

  `"native"` (default logit ability units) or `"standardized"` (divides
  zero-sum contrasts or `comparison_review` interaction contrasts by the
  same fit's population SD \\\sigma\\ under `method = "model"` and
  fixed-\\N(0,1)\\ or intercept-only normal MML).

- comparison_review:

  Optional
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  review supplying identifiable facet-by-origin interaction contrasts in
  full RSM/PCM MML.

- anchor_covariance:

  Optional full source-anchor sampling covariance matrix (matching all
  direct anchors on the noncentered facet) and explicit
  independent-sample declaration (`FALSE` default) for direct
  intercept-only RSM/PCM anchor-origin MML.

- independent_anchors:

  Optional full source-anchor sampling covariance matrix (matching all
  direct anchors on the noncentered facet) and explicit
  independent-sample declaration (`FALSE` default) for direct
  intercept-only RSM/PCM anchor-origin MML.

- interaction:

  Optional fitted two-way interaction name (e.g., `"Rater:Criterion"`)
  in full single-interaction RSM/PCM MML (`method = "model"`,
  `scale = "native"`).

- profile_control:

  Named list for `method = "profile"`: `quad_points` (default `81`) and
  `max_quad_points` (`321`), checked against `2*q - 1`.

- x:

  Output from `mfrm_facet_intervals()` or two-family
  `confint(fit, parm = "steps")`. The latter displays within-level step
  offsets. See
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
  for the target and qualification.

  Also for [`print()`](https://rdrr.io/r/base/print.html): An object
  returned by `mfrm_facet_intervals()`.

- ...:

  For `print.mfrm_facet_intervals()`: Unused by print and summary
  methods.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Unused.

- object:

  An object returned by `mfrm_facet_intervals()` or two-family
  `confint(fit, parm = "steps")`.

- parm:

  For [`confint()`](https://rdrr.io/r/stats/confint.html), optional
  distinct target names from `object$table$Target`. Extracts the stored
  limits without recalculation; `level` must match the saved level. Use
  `mfrm_facet_intervals()` to calculate a different level, or
  `confint(fit, parm = "steps")` for step offsets. Unavailable limits
  remain `NA`; inspect `summary(object)` for their eligibility and
  reasons.

- comparison:

  Logical. With a sandwich result, also show its ordinary model-based
  interval. With source-propagated anchors, show the separate
  conditional-on-anchors interval. Both use the same point estimate.

- draw:

  Logical; `FALSE` returns exact plotted data without opening a device.

- preset:

  A package plot preset, for example `"standard"` or `"monochrome"`.

- title:

  Optional returned text; `NULL` omits it. Defaults describe the facet,
  exact confidence level, method and fixed/unavailable symbols. This
  text is not drawn; use `plot_data(p, "notes")` and
  `plot_data(p, "title")` to retrieve it.

- subtitle:

  Optional returned text; `NULL` omits it. Defaults describe the facet,
  exact confidence level, method and fixed/unavailable symbols. This
  text is not drawn; use `plot_data(p, "notes")` and
  `plot_data(p, "title")` to retrieve it.

- caption:

  Optional returned text; `NULL` omits it. Defaults describe the facet,
  exact confidence level, method and fixed/unavailable symbols. This
  text is not drawn; use `plot_data(p, "notes")` and
  `plot_data(p, "title")` to retrieve it.

- reference:

  Optional finite vertical reference; default zero. Use `NULL` to omit
  it. This is not a rater-quality threshold.

- show_legend:

  Logical; show the method legend (default `TRUE`).

## Value

An `mfrm_facet_intervals` object
([`summary()`](https://rdrr.io/r/base/summary.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`vcov()`](https://rdrr.io/r/stats/vcov.html),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md))
with `table`, `covariance`/`model_covariance`, `parameter_covariance`,
`person_scores`/`cluster_scores` (sandwich), `anchor_uncertainty` (when
supplied), `profile`/`profile_attempts` (profile), `checks`,
`numerical_checks`, and `settings`.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains the `table`, contrast coefficients, settings and labels, and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
remains idempotent on the returned object.

## Details

**Covariance propagation and constraints.** For constrained locations
\\b = b_0 + J\eta\\ and contrast matrix \\C\\, target covariance is \\C
J V\_\eta J^\top C^\top\\, where \\V\_\eta\\ is extracted after
inverting the **full joint** information across all free structural,
step, interaction, slope, and population coordinates
(`Status = "information_unavailable"` if singular;
`Status = "insufficient_cluster_rank"` withholds sandwich bounds while
retaining `Model*` columns).

**Standardized contrasts.** With `scale = "standardized"`, native
contrast \\d\\ and log-variance \\\lambda = \log(\sigma^2)\\ define \\t
= d/\sigma\\ with full delta-method variance:
\$\$\widehat{\mathrm{Var}}(\widehat t) =
\frac{\widehat{\mathrm{Var}}(\widehat d) + \widehat
d^2\widehat{\mathrm{Var}}(\widehat\lambda)/4 - \widehat
d\\\widehat{\mathrm{Cov}}(\widehat d,\widehat\lambda)}
{\widehat\sigma^2}.\$\$

**Anchor-source propagation.** With `anchor_covariance` and
`independent_anchors = TRUE`, implicit differentiation \\S =
-H\_{uu}^{-1}H\_{ua}\\ yields source derivative \\D = t_u S + t_a\\ and
total covariance \\t_u V\_{\mathrm{cond}} t_u^\top + D
V\_{\mathrm{anchor}} D^\top\\, retaining conditional bounds in
`Conditional*` and reusable by
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md).

**CML and profile contrasts.** Full CML uses unregularized inverse
conditional information (`scale = "native"`); comparison-only CML reuses
saved subspace covariances without refitting. Profile contrasts report
`ProfileEstimate` alongside `SourceEstimate` without Wald
`SE`/[`vcov()`](https://rdrr.io/r/stats/vcov.html). Worked examples and
bounded coverage evaluations appear on the package website
(<https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-facet-intervals.html>).

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
fixed-facet interval methods

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Fixed
targets use open diamonds without inferential intervals. A conditionally
fixed anchor can have a source-propagated interval; the comparison
displays its conditional fixed value separately. Method labels
distinguish source propagation from conditional observed information.
Unavailable intervals in either displayed method use crosses; an
ordinary comparison interval does not substitute for a missing sandwich
interval. The zero line is a reference, not a threshold of practical
importance or a rater-quality rule. No fit or covariance is
recalculated. Target order is preserved. Weak-information cautions
remain in the returned data and appear in the default subtitle. Custom
or omitted subtitles change display only. For experimental two-family
GPCM locations, the axis uses fixed-N(0,1) ability units and the default
subtitle states the location reference and the lack of established
coverage, with a deficient Person-score rank caution when applicable.
These are not uniform expected-rating differences. Standardized contrast
axes use population SD units; returned notes identify whether SD
uncertainty is estimated or the known SD is one. Reviewed interaction
contrasts retain group direction, panel weights and scale in their
source result; returned labels distinguish them from facet locations.
Native CML intervals are labeled conditional information. Their returned
notes describe asymptotic validity without implying weak information or
an estimated ability population SD. When a comparison has no estimate,
its row is labeled "not estimated" and has no point or interval. An
empty display range is only an axis placeholder; it does not assign a
value to unavailable targets. Joint interaction-cell results retain cell
identities, counts and sparse flags in
`plot_data(p, "interaction_cells")`. Their axis uses additive predictor
shifts; row labels show the two level names in fitted facet order. Units
follow the fixed N(0,1) ability scale. Positive effects raise expected
coded scores relative to the jointly fitted main effects. These
pointwise intervals are not fixed-baseline bias screens or fairness
labels.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## References

- White, H. (1982). *Econometrica*, 50(1), 1–25.

- Zeileis, A. (2006). *Journal of Statistical Software*, 16(9), 1–16.
  [doi:10.18637/jss.v016.i09](https://doi.org/10.18637/jss.v016.i09) .

- Zeileis, A., Koell, S., & Graham, N. (2020). *Journal of Statistical
  Software*, 95(1), 1–36.
  [doi:10.18637/jss.v095.i01](https://doi.org/10.18637/jss.v095.i01) .

## See also

[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md),
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md),
`plot.mfrm_facet_intervals()`,
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("mfrm_facet_intervals", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
  model = "RSM", method = "MML", rating_min = 1, rating_max = 4,
  category_policy = "preserve")
intervals <- mfrm_facet_intervals(fit, "Rater", method = "sandwich")
summary(intervals)[, c("Target", "Estimate", "SE", "Lower", "Upper",
  "Status", "CIEligible", "InferenceReview")]
# Keep all rows: a missing interval does not imply a missing point.
plot(intervals) # Crosses mark retained estimates with unavailable intervals.

# Compare two selected raters, rather than each rater against the origin.
# Here choose the first two example labels; prespecify your own comparison.
raters <- unique(as.character(ratings$Rater))
contrast <- matrix(0, 1, length(raters), dimnames = list(
  paste(raters[1], "minus", raters[2]), raters))
contrast[1, 1:2] <- c(1, -1)
difference <- mfrm_facet_intervals(fit, "Rater", contrasts = contrast)
summary(difference)[, c("Target", "Estimate", "SE", "Lower", "Upper", "Status")]
# With the default negative rater sign, a positive contrast means the first
# rater is more severe. Units are native logits. An interval containing zero
# leaves the direction uncertain; it does not establish equivalence.

# Estimate the population SD in this same model before standardizing.
# Even an intercept-only population model needs one row per person.
persons <- unique(ratings["Person"])
population_fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"),
  "Score", model = "RSM", method = "MML", population_formula = ~ 1,
  person_data = persons, person_id = "Person",
  rating_min = 1, rating_max = 4, category_policy = "preserve", quad_points = 61)
standardized <- mfrm_facet_intervals(population_fit, "Rater",
  contrasts = contrast, scale = "standardized")
summary(standardized)
# Estimate is now in fitted ability-population SD units; its delta-method
# interval includes uncertainty in that SD. It is not a Wald z statistic.

# CML estimates the native contrast without an ability distribution.
if (requireNamespace("lpSolve", quietly = TRUE)) {
  cml_fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    model = "RSM", method = "CML", rating_min = 1, rating_max = 4,
    category_policy = "preserve")
  cml_ci <- mfrm_facet_intervals(cml_fit, "Rater", contrasts = contrast)
  summary(cml_ci)
  apa_table(cml_ci)
  file <- tempfile(fileext = ".rds") # Choose a lasting path for your analysis
  saveRDS(cml_ci, file)
  saved <- readRDS(file)
  summary(saved) # Same conditional-information result, without refitting
  # Use plot(saved) for a figure; ordinary mfrm_results() does not accept CML.
}
} # }
```
