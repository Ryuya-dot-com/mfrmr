# Facet reliability and separation snapshot bar plot

Compact facet-level visual of the Wright & Masters (1982) separation,
strata, and reliability indices that
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
computes. Helpful as a single small figure for "are persons / raters /
criteria distinguishable?" review. These are Rasch/FACETS-style
separation indices on the fitted logit scale, not ICCs; use
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/compute_facet_icc.md)
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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  output. Computed on demand when omitted.

- metric:

  `"reliability"` (default), `"separation"`, or `"strata"`.

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the `ggplot` object.

## Value

Invisibly, a `ggplot` object. `plot_data(p, "table")` is a tidy `Facet`,
`Metric`, `Value` data frame. When present in the supplied diagnostics,
precision tier, reliability use/basis, formal-inference flag and
model-summary notes are retained alongside each plotted value.

## Details

High Person separation reliability indicates distinguishable abilities.
High rater separation reliability indicates distinguishable severities,
**not agreement** between raters. If raters should be interchangeable,
reliable severity differences merit review. Low rater separation
reliability can also reflect imprecise estimates and does not establish
agreement. The index does not test every rater pair or measure the
practical size of severity differences. Examine estimated severities and
their uncertainty, and use
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interrater_agreement_table.md)
for observed agreement.

The separation-reliability formula is shared across facets, but the
facet's role changes its interpretation. Person separation reliability
is analogous to test reliability, not numerically identical to
Cronbach's alpha; MML Person rows using EAP/posterior SD also have the
limitations described in
[mfrmr-package](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr-package.md).
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

## References

Linacre, J. M. Facets documentation, *Reliability - separation -
strata*. <https://www.winsteps.com/facetman/reliability.htm>

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_reliability_snapshot", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "reliability", draw = FALSE)
plot_data(p, "table")
# High Person value: distinguishable abilities.
# High rater value: distinguishable severities, not agreement.
# Low rater value: not proof of agreement; inspect estimation precision.
plot_data(p, "notes")
} # }
```
