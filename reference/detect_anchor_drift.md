# Detect anchor drift across multiple calibrations

Compares facet estimates across two or more calibration waves to
identify elements whose difficulty/severity has shifted beyond supplied
screening thresholds. Useful for monitoring rater drift over time or
checking the stability of item banks.

## Usage

``` r
detect_anchor_drift(
  fits,
  facets = NULL,
  drift_threshold = 0.5,
  flag_se_ratio = 2,
  reference = 1L,
  include_person = FALSE
)

# S3 method for class 'mfrm_anchor_drift'
print(x, ...)

# S3 method for class 'mfrm_anchor_drift'
summary(object, ...)

# S3 method for class 'summary.mfrm_anchor_drift'
print(x, ...)

# S3 method for class 'mfrm_anchor_drift'
plot(x, type = c("drift", "heatmap", "forest"), ...)
```

## Arguments

- fits:

  Named list of `mfrm_fit` objects (e.g.,
  `list(Year1 = fit1, Year2 = fit2)`).

- facets:

  Character vector of facets to compare (default: all non-Person
  facets).

- drift_threshold:

  Absolute screening threshold for flagging (logits, default 0.5). A
  non-negative scalar; `Inf` disables magnitude screening.

- flag_se_ratio:

  Drift/SE ratio screening threshold for flagging (default 2.0). A
  non-negative scalar; `Inf` disables SE-ratio flagging.

- reference:

  Index or name of the reference fit (default: first).

- include_person:

  Include person estimates in comparison. Use only when the person
  identifiers refer to the same persons across fitted waves.

- object:

  An `mfrm_anchor_drift` object (for `summary`).

- ...:

  For `print.mfrm_anchor_drift()`: Ignored.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): `facet`
  optionally selects facets; `ci_level = 0.95` controls forest whiskers
  only; `preset` selects `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`; `draw = FALSE` returns data without drawing.
  Additional base-graphics arguments depend on the selected view.

- x:

  For `print.mfrm_anchor_drift()`: An `mfrm_anchor_drift` object.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): A saved
  result from `detect_anchor_drift()`.

- type:

  `"drift"` for relative changes with screening flags, `"heatmap"` for
  wave-by-element patterns, or `"forest"` for per-wave estimates with
  approximate normal whiskers. A linking chain is a different result:
  use `plot(chain, type = "chain")` after
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md).

## Value

Object of class `mfrm_anchor_drift` with components:

- drift_table:

  Tibble of element-level drift statistics.

- summary:

  Drift summary aggregated by facet and wave.

- common_elements:

  Tibble of pairwise common-element counts.

- common_vs_reference:

  Tibble of common-element counts between each wave and the reference
  wave (i.e., which labels remain available as candidate common
  elements).

- n_common_all_waves:

  Integer count of elements that are common across every wave; used by
  [`summary()`](https://rdrr.io/r/base/summary.html) to gauge how robust
  the chain is to chained linking error.

- common_by_facet:

  Tibble of retained common-element counts by facet.

- config:

  List of analysis configuration.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object carrying the underlying plot payload accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
Drift/heatmap views store `table` (and `matrix` for a heatmap); forest
rows store `data`, including `CI_Lower` and `CI_Upper`.

## Details

Compare each fitted wave with the reference using common facet-level
estimates from
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
and SEs from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
Removing the weighted common-element offset yields residual `Drift`, not
the overall calibration shift. Fewer than five retained common elements
in any linking facet is marked as thin support; this is a package
screening convention, not a universal adequacy threshold.

One `LinkOffset` is pooled across all selected common elements and
facets. If at least one pair has finite positive SEs, only pairs with
such SEs contribute to the inverse-variance weighted offset; rows
without usable SEs can still appear in retained/support counts. If
preliminary residual screening would retain no row, the current
implementation falls back to all finite differences. Use a single
substantively coherent facet when a common shift across facet blocks is
not defensible, and inspect `drift_table` rather than treating
`LinkSupportAdequate` as sufficient evidence. The fallback is recorded
as `ScreeningFallback`, and `Contributing` / `N_Contributing` identify
the elements actually used in the final offset. Retention and
contribution are different: a retained row with a missing SE does not
enter a weighted offset when other rows have usable SEs.

`OffsetStatus` and `OffsetReason` distinguish computed offsets, absent
or nonfinite common differences, and numerical failure. Missing
residuals stay missing. `SERatioStatus` explains unavailable SE ratios;
`FlagBasis` identifies whether the flag used both criteria, only
residual magnitude, or neither. In the magnitude-only case,
`Flag = FALSE` is not a negative SE-ratio screen. Summaries report
unavailable counts, and withhold the complete flagged count when any
residual flag is unavailable.

Matching `Facet` and `Level` labels are treated as common elements; the
helper cannot verify that they have invariant meaning across waves. The
input fits must therefore use compatible model, score, orientation, and
population conventions and must be independently reviewed for fit
readiness. Offset removal aligns coordinates conditionally on those
assumptions; it is not proof of scale equivalence.

This is a relative drift screen. For example, if the selected judges'
estimates all differ from the reference by +0.40 logits, `LinkOffset` is
+0.40 and each residual `Drift` is zero. This does not establish panel
stability. The offset itself also cannot distinguish real panel change
from a change of coordinates. Common recorded performances can provide a
separate reference, but a complete recording-based annual analysis and
its formal difference intervals are not yet verified here. See the
annual assessment example in
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md).

An element is **flagged** when either condition is met: \$\$\|\Delta_e\|
\> \texttt{drift\\threshold}\$\$ \$\$\|\Delta_e / SE\_{\Delta_e}\| \>
\texttt{flag\\se\\ratio}\$\$ The two criteria are joined by `OR`: a
large absolute residual is flagged even when imprecise, while a smaller
residual can be flagged by its SE ratio. The ratio uses only the two
element SEs and omits uncertainty in the estimated `LinkOffset` and any
cross-fit covariance. It is therefore a descriptive screen, not a formal
z test with a calibrated error rate. Residuals share an estimated
offset, and contributing elements also enter that offset. Offset
covariance can either reduce or increase residual uncertainty relative
to the displayed denominator. The ratio is not guaranteed to be
conservative.

When `facets` is `NULL`, all non-Person facets are compared. Providing a
subset (e.g., `facets = "Criterion"`) restricts comparison to those
facets only.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot a
saved anchor-drift review

## Reading the drift review

Supply a named list of fitted waves, for example
`list(Spring = fit_s, Fall = fit_f)`. Read `summary(drift)` before
`drift$drift_table`, then inspect common-element support and flagged or
unavailable rows.

- `drift_table` contains element-by-wave `Facet`, `Level`, `Wave`,
  `Ref_Est`, `Wave_Est`, `LinkOffset`, `Drift`, `SE_Ref`, `SE_Wave`,
  `SE`, `Drift_SE_Ratio`, `LinkSupportAdequate` and `Flag`.

- `summary` aggregates counts and mean/maximum absolute drift by facet
  and wave. `common_elements` records pairwise overlap;
  `common_by_facet` counts retained elements per linking facet.
  `LinkSupportAdequate = FALSE` marks fewer than five in at least one
  facet, not a verdict on all linking assumptions.

- `config` records the analysis settings. Review flags and sensitivity
  to anchor choices with substantive evidence before exclusion or rater
  retraining.

Use
[`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
for raw new data and a baseline fit, or
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
for cumulative offsets across ordered adjacent waves. These are
different starting points, not required extra steps.

## Reading drift plots

Drift and heatmap views reuse saved residuals and screening rules;
changing the display does not recalibrate them. Interpret with the
offset and support review above: unflagged elements do not establish
absence of panel-wide change.

Forest whiskers describe individual wave estimates, not uncertainty in
their differences. They do not include linking-offset uncertainty or
cross-wave covariance, and their overlap is not a test of change.
Missing standard errors produce no whisker, not a zero-width interval.

## See also

[`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md),
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
plot(x),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)

`detect_anchor_drift()`,
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("detect_anchor_drift", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Deliberately linked teaching waves: common labels below represent the
# same rater and criterion identities by construction.
toy <- load_mfrmr_data("example_core")
people <- unique(toy$Person)
# Two balanced 24-Person waves retain every Rater and Criterion.
d1 <- toy[toy$Person %in% people[1:24], , drop = FALSE]
d2 <- toy[toy$Person %in% people[25:48], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", quad_points = 7, maxit = 30)
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", quad_points = 7, maxit = 30)
drift <- detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2))
summary(drift)
head(drift$drift_table[, c("Facet", "Level", "Wave", "Drift", "Flag")])
drift$common_elements
} # }
# Long-running workflow; run explicitly when needed.
# example("plot.mfrm_anchor_drift", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("example_core")
people <- unique(ratings$Person)
d1 <- ratings[ratings$Person %in% people[1:12], , drop = FALSE]
d2 <- ratings[ratings$Person %in% people[13:24], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML")
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML")
# Review convergence and common-element support before interpreting changes.
summary(fit1)
summary(fit2)
drift <- detect_anchor_drift(list(W1 = fit1, W2 = fit2))
drift_plot <- plot(drift, type = "drift", draw = FALSE)
class(drift_plot)
names(plot_data(drift_plot))
chain <- build_equating_chain(list(F1 = fit1, F2 = fit2))
chain_plot <- plot(chain, type = "chain", draw = FALSE)
head(plot_data(chain_plot)$data$table)
if (interactive()) {
  plot(drift, type = "heatmap", preset = "publication")
}
} # }
```
