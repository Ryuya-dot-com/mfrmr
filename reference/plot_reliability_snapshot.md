# Facet reliability and separation snapshot bar plot

Compact facet-level visual of the Wright & Masters (1982) separation,
strata, and reliability indices that
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
computes. Helpful as a single small figure for "are persons / raters /
criteria distinguishable?" review. These are Rasch/FACETS-style
separation indices on the fitted logit scale, not ICCs; use
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
for the complementary observed-score variance-share view.

## Usage

``` r
plot_reliability_snapshot(
  fit,
  diagnostics = NULL,
  metric = c("reliability", "separation", "strata"),
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output. Computed on demand when omitted.

- metric:

  `"reliability"` (default), `"separation"`, or `"strata"`.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` whose `data` slot bundles a tidy `Facet`, `Metric`,
`Value` data frame. When present in the supplied diagnostics, precision
tier, reliability use/basis, formal-inference flag and model-summary
notes are retained alongside each plotted value.

## Details

High Person separation reliability indicates distinguishable abilities.
High rater separation reliability indicates distinguishable severities,
**not agreement** between raters. If raters should be interchangeable,
reliable severity differences merit review. Low rater separation
reliability can also reflect imprecise estimates and does not establish
agreement. The index does not test every rater pair or measure the
practical size of severity differences. Examine estimated severities and
their uncertainty, and use
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
for observed agreement.

The separation-reliability formula is shared across facets, but the
facet's role changes its interpretation. Person separation reliability
is analogous to test reliability, not numerically identical to
Cronbach's alpha; MML Person rows using EAP/posterior SD also have the
limitations described in
[mfrmr-package](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md).
No universal adequate/strong reference lines are drawn. Reliability,
separation and Strata use approximate marginal-SE variance subtraction
and do not propagate covariance among estimates, even when the SEs come
from joint information. Model and fit-adjusted indices are not
confidence limits; Strata does not identify actual groups. Ordinary JML
uses exploratory location precision; these indices are screening
summaries, not structural confidence intervals. Corrected-JML `RootSE`
is not an input to these indices. Corrected JML and two-family GPCM are
unavailable here, including when diagnostics are supplied. The returned
plot retains interpretation notes for saved reuse.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## Session plot defaults

Set `options(mfrmr.plot_preset = "publication")` to choose a session
default for plotting functions that expose the common `preset` argument.
The supported values are `"standard"`, `"publication"`, `"compact"` and
`"monochrome"`. Precedence is an explicit call argument, then the
session option, then `"standard"`. For example, `preset = "standard"`
overrides a session set to `"monochrome"`. Explicit `preset = NULL`
retains the earlier package-default behavior; it does not read the
session option. Invalid session values cause an error only when that
option is needed.

The category-curve, data-quality, fit-review, connectivity and network
routes of [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
report bundles use the same option through `...`. Plots without a common
`preset` argument, including extended-model plots with their own
`palette` controls, keep their own settings. This option selects a
preset, not a universal theme or a guarantee that all renderers
implement every appearance control identically.

New plot payloads retain the resolved preset for supported saved-data
rendering. Converting an existing payload with
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
uses its saved appearance, even after the session option changes. A call
that creates a new plot from a fit or statistical result uses the
current default. For a reproducible script, supply `preset` explicitly
or set the option in that script. Saving only the fitted model does not
save a session option. No global ggplot theme is changed.

Restore previous settings with
`old <- options(mfrmr.plot_preset = "monochrome")` followed by
`options(old)`. Use `options(mfrmr.plot_preset = NULL)` to remove the
option. The preset changes appearance, not estimates, confidence levels
or diagnostic thresholds.

## References

Linacre, J. M. Facets documentation, *Reliability - separation -
strata*. <https://www.winsteps.com/facetman/reliability.htm>

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "reliability", draw = FALSE)
p$data$table
#>       Facet      Metric     Value PrecisionTier ReliabilityUse
#> 1     Rater reliability 0.9031009   exploratory screening_only
#> 2    Person reliability 0.9005676   exploratory screening_only
#> 3 Criterion reliability 0.8852451   exploratory screening_only
#>                                                          ReliabilityBasis
#> 1 Approximate marginal-SE variance subtraction; covariance not propagated
#> 2 Approximate marginal-SE variance subtraction; covariance not propagated
#> 3 Approximate marginal-SE variance subtraction; covariance not propagated
#>   SupportsFormalInference
#> 1                   FALSE
#> 2                   FALSE
#> 3                   FALSE
#>                                               ModelSummaryNote
#> 1   Computed over 4 of 4 levels with finite estimates and SEs.
#> 2 Computed over 48 of 48 levels with finite estimates and SEs.
#> 3   Computed over 4 of 4 levels with finite estimates and SEs.
# High Person value: distinguishable abilities.
# High rater value: distinguishable severities, not agreement.
# Low rater value: not proof of agreement; inspect estimation precision.
p$data$notes
#>             Type
#> 1 interpretation
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Text
#> 1 Separation reliability describes differences among facet locations relative to their estimation errors. High Person values indicate distinguishable abilities; high rater values indicate distinguishable severities, not inter-rater agreement. Low rater values can also reflect imprecision and do not establish agreement. The index does not test every rater pair or quantify the practical size of severity differences. Reliability, separation and Strata are approximate compatibility indices using marginal SEs; joint-information SEs do not validate this variance decomposition. They do not account for covariance among estimates. EAP-based separation is not posterior-variance EAP reliability. Model and fit-adjusted values are companion indices, not confidence limits. Strata describes hypothetical distinguishable strata, not discovered groups. Facet heterogeneity chi-square summaries use diagonal SE weights, not full-covariance joint tests. Ordinary JML uses exploratory location precision; these indices are screening summaries, not structural confidence intervals.
```
