# Build a screened linking chain across ordered calibrations

Links a series of calibration waves by computing mean offsets between
adjacent pairs of fits. Common linking elements (e.g., raters or items
that appear in consecutive administrations) are used to estimate the
scale shift. Cumulative offsets express all waves relative to the first
wave, conditional on the common-element assumptions. The procedure is a
practical screened linking aid, not a full general-purpose equating
framework or proof of common-scale comparability.

## Usage

``` r
build_equating_chain(
  fits,
  anchor_facets = NULL,
  include_person = FALSE,
  drift_threshold = 0.5
)

# S3 method for class 'mfrm_equating_chain'
print(x, ...)

# S3 method for class 'mfrm_equating_chain'
plot(
  x,
  y = NULL,
  type = c("common_anchors", "graph", "chain", "links", "anchor_removal",
    "offset_sensitivity"),
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  show_title = FALSE,
  show_notes = FALSE,
  ...
)

# S3 method for class 'mfrm_equating_chain'
summary(object, ...)

# S3 method for class 'summary.mfrm_equating_chain'
print(x, ...)
```

## Arguments

- fits:

  Named list of `mfrm_fit` objects in chain order.

- anchor_facets:

  Character vector of facets to use as linking elements.

- include_person:

  Include person estimates in linking.

- drift_threshold:

  Non-negative scalar threshold for screening and flagging large
  residuals in links. `Inf` retains all finite differences and disables
  magnitude flagging.

- x:

  An `mfrm_equating_chain` object.

- y:

  Unused (S3 plot signature requirement).

- type:

  One of `"graph"` (bipartite wave x link-specific common-element
  graph), `"common_anchors"` (default; bar chart of common-anchor counts
  per wave pair), `"chain"` (cumulative offsets), `"links"` (recorded
  wave comparisons), or `"anchor_removal"` (newly disconnected wave
  pairs after deleting each common element), or `"offset_sensitivity"`
  (conditional rescreened linking-offset changes).

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the `ggplot` object to the active device.

- show_title:

  Logical; display the main title.

- show_notes:

  Logical; display graph/topology interpretation footers. Returned notes
  and ordinary R warnings are unaffected. Axes, legends and data labels
  remain visible; other chain views have no interpretation footer.

- ...:

  Ignored.

- object:

  An `mfrm_equating_chain` object (for `summary`).

## Value

Object of class `mfrm_equating_chain` with components:

- links:

  Tibble of link-level statistics (offset, SD, etc.).

- cumulative:

  Tibble of cumulative offsets per wave.

- element_detail:

  Tibble of element-level linking details.

- common_by_facet:

  Tibble of retained common-element counts by facet.

- config:

  List of analysis configuration.

Invisibly, a `ggplot` object carrying its saved plot payload for
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

## Details

For each adjacent wave pair \\(A, B)\\, identifies common levels across
`anchor_facets`, computes \$\$d_e = \hat{\delta}\_{e,B} -
\hat{\delta}\_{e,A},\$\$ forms a preliminary inverse-variance weighted
(or unweighted) mean offset, screens elements with residual exceeding
`drift_threshold` (falling back to all finite differences in
`ScreeningFallback` if all rows would be removed), and chains `Offset`
forward from Wave 1 (`cumulative`). Links with fewer than 5 retained
elements in any facet set `LinkSupportAdequate = FALSE`; `Offset_SD` is
retained-element residual spread (not an offset SE, and `NA` for fewer
than two elements via `OffsetSDStatus`), and unavailable links keep
downstream cumulative offsets `NA` (`OffsetStatus`, `N_Contributing`).

**Plot views (`plot(chain, type = ...)`)**: `"chain"` plots cumulative
offsets; `"graph"` draws wave/link-element incidence; `"links"`
summarizes retained common counts; `"anchor_removal"` counts newly
disconnected wave pairs (`removal`, `lost_links`, `lost_pairs`,
`components_after` in `plot_data(p, "data")`); and
`"offset_sensitivity"` recomputes conditional offsets after deleting
each `(Facet, Level)` identity while holding wave calibrations fixed
(`baseline_*`, `removal`, `retention_changes`).

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## See also

[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
[`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
[plot(x)](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("build_equating_chain", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
people <- unique(toy$Person)
d1 <- toy[toy$Person %in% people[1:24], , drop = FALSE]
d2 <- toy[toy$Person %in% people[25:48], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML")
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML")
# Check convergence before using the estimates for linking.
summary(fit1)
summary(fit2)
# The four shared levels per facet trigger a thin-support warning.
# Inspect that warning; matching labels alone do not establish a common scale.
chain <- build_equating_chain(list(Form1 = fit1, Form2 = fit2))
summary(chain)
chain$cumulative
} # }
```
