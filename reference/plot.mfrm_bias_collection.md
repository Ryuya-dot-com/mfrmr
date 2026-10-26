# Explore bias across facet pairs

Explore bias across facet pairs

## Usage

``` r
# S3 method for class 'mfrm_bias_collection'
plot(
  x,
  pair = NULL,
  type = c("overview", "scatter", "ranked", "heatmap", "abs_t_hist", "facet_profile"),
  draw = TRUE,
  preset = "standard",
  ...
)
```

## Arguments

- x :

  A result from
  [`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md).

- pair :

  An exact `Interaction` label from `summary(x)$overview`, or its row
  number. `NULL` (default) shows all requested pairs.

- type :

  `"overview"` shows signed cell estimates grouped by pair. With `pair`
  supplied, the default becomes `"heatmap"`; `"scatter"`, `"ranked"`,
  `"abs_t_hist"` and `"facet_profile"` select the corresponding
  [`plot.mfrm_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bias.md)
  view.

- draw :

  Draw the figure. `FALSE` returns its data without opening a device.

- preset :

  A package plot preset, for example `"standard"` or `"monochrome"`.

- ... :

  With `pair`, additional arguments to
  [`plot.mfrm_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bias.md),
  such as `top_n` or `sort_by`. The overview rejects additional
  arguments.

## Value

Invisibly, an `mfrm_plot_data` object. For the overview,
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
provides `table` (all combined cells, including unavailable rows),
`overview`, `errors`, `optimization_failures`, `fit_identity`,
`settings`, axis labels and notes.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
reproduces the overview. A selected pair returns the ordinary bias plot
with `collection_pair` and `fit_identity` provenance added.

## Details

The overview plots every finite retained bias estimate, without ranking
or a significance cutoff. Positive shifts increase expected coded scores
under the fitted model; score meaning depends on the rubric. Vertical
spreading only separates cells visually and has no statistical meaning.

Filled circles have a usable conditional screening statistic; open
circles retain a point without one. These symbols indicate availability,
not whether a cell is flagged. Pair labels report usable statistics /
retained cells and the range of observed row counts per cell (`n`), not
independent Person counts. Pairs share observations. Empty, failed and
unavailable pairs remain labeled, without substituting a point at zero.
The vertical zero line means no conditional shift, not a threshold for
practical importance.

No model or diagnostics are recalculated. The overview supplies no
intervals, multiplicity correction or formal bias test. Review the
individual cell counts, optimizer status and subject-matter
explanations; selecting a pair after this overview does not make its
subsequent analysis confirmatory. Titles and interpretation notes are
returned outside the figure.

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

## See also

[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md),
[`summary.mfrm_bias_collection()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_bias_collection.md),
[`plot.mfrm_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bias.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                method = "MML")
screens <- estimate_all_bias(fit)
p <- plot(screens)

plot_data(p, "overview")
#>         Interaction Order            Facets Rows ScreenPositive Significant
#> 1 Rater x Criterion     2 Rater x Criterion   16              3           3
#>    MaxAbsT MeanAbsBias SupportsFormalInference FormalInferenceEligible
#> 1 2.594645   0.2641805                   FALSE                   FALSE
#>   PrimaryReportingEligible ClassificationSystem   ReportingUse Kept Error
#> 1                    FALSE            screening screening_only TRUE      
#>   ScreenUnavailable ScreenAvailable Points    Status
#> 1                 0              16     16 available
plot(screens, pair = "Rater x Criterion", type = "ranked")
```
