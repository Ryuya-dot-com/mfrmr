# Plot facet locations with qualified normal uncertainty bands

Ranks the levels of a chosen facet by fitted location and draws
available normal uncertainty bounds around each point estimate. Optional
descriptive bands mark absolute distances of `0.5` and `1.0` logit from
zero; they are display aids, not calibration rules.

## Usage

``` r
plot_rater_severity_profile(
  fit,
  diagnostics = NULL,
  facet = "Rater",
  ci_level = 0.95,
  show_bands = FALSE,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  output. When omitted, `diagnose_mfrm(fit, residual_pca = "none")` is
  run internally. Supplied diagnostics must match the fitted analysis
  and current precision contract; they are reused without covariance
  recomputation.

- facet:

  Facet name to plot (default `"Rater"`). Any non-Person facet name is
  accepted.

- ci_level:

  Confidence level used for the whiskers (default `0.95`). Bounds use
  `+/- z * ModelSE` (or `SE` only when the `ModelSE` column is absent).
  A missing `ModelSE` is not replaced rowwise.

- show_bands:

  Logical, default `FALSE`. Explicit `TRUE` draws neutral gray `+/-0.5`
  and `+/-1.0` logit guides and describes them in the returned
  annotations. These distances are not equivalence bounds.

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the `ggplot` object.

## Value

Invisibly, a `ggplot` object. Its `plot_data(p, "data")` table contains
columns `Level`, `Estimate`, `SE`, `CI_Lower`, `CI_Upper`, and `Band`,
where `Band` contains numerical absolute-location ranges, not judgments
about severity or quality. The ranges remain in the table when hidden.
Other columns include `Fixed`, `IntervalStatus`, `SEColumn`,
`SE_Method`, `PrecisionTier`, `CIUse`, `CIEligible`,
`SupportsFormalInference` and the normal interval method/level. Source
precision labels are retained; missing precision metadata cannot qualify
an interval for inference. The full `plot_data(p)` list retains the
facet, confidence level and plot annotations and diagnostics identity
check (`source_status`); keep these with the table when reporting the
results. Fit readiness and interpretation notes are returned. Titles and
notes are not automatically drawn.

## Interpreting output

Zero is the sum-to-zero reference for the default centered facet;
describe any different constraints or anchors used in the fit. With the
default negative facet orientation, higher estimates reduce expected
coded scores. This means more severe scoring when higher scores
represent better performance; check the rubric direction before using
that substantive interpretation. The axis names the selected facet's
location rather than assuming that lower coded scores are less
favorable. Returned notes state its fitted sign. The optional guides and
numerical `Band` ranges describe distance from zero, not the sign of
severity, operational interchangeability, or a need for training. No
guide bands are drawn by default. Pairwise claims require the
uncertainty of the contrast; check the SE basis in the supplied
diagnostics. Two locations at -0.5 and +0.5 are one logit apart despite
lying in the same range. A changed origin can change these ranges
without changing pairwise differences. Use
[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_facet_equivalence.md)
with a justified practical bound for equivalence; a non-significant
difference does not establish it.

Here "profile" means an ordered display of facet locations, not a
likelihood-profile confidence interval. Ordinary JML bands remain
exploratory; MML fallback, regularized or review-only bands retain their
restrictions. Plotting does not validate normal-approximation coverage.
Fixed values use diamonds without sampling intervals. Crosses show
finite points with unavailable or nonpositive SEs; unavailable estimates
retain labeled rows. The horizontal range includes finite points even
without SEs.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
preserves these states, saved endpoints, guide bands and notes without
fitting a model or recomputing an interval. Older saved plot payloads
can reproduce their stored geometry but cannot acquire missing source or
uncertainty qualifications through conversion. Older saved plots retain
their original colored guides and `Band` labels (`gentle`, `moderate`,
`strict`). Those labels never established equivalence. Regenerate the
plot from the saved fit and matching diagnostics to obtain the neutral
display; this does not require a new fit.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_facet_equivalence.md),
[plot(x, type =
"facet_equivalence")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md).

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_rater_severity_profile", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Use the diagnostics saved with this fit
diagnostics <- example_fit$diagnostics

# Compare signed severity estimates and their intervals
severity <- plot(fit, type = "rater_severity", diagnostics = diagnostics, show_bands = FALSE)
plot_data(severity, "data")[, c("Level", "Estimate", "SE", "CI_Lower", "CI_Upper")]
# Higher estimates mean more severe ratings with this example's default orientation
# The optional magnitude bands are omitted from this first comparison
} # }
```
