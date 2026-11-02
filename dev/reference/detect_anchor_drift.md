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
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_equating_chain.md).

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
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).
Drift/heatmap views store `table` (and `matrix` for a heatmap); forest
rows store `data`, including `CI_Lower` and `CI_Upper`.

## Details

For each non-reference wave, the function extracts facet-level estimates
using
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/make_anchor_table.md)
and computes the element-by-element difference against the reference
wave. Standard errors are obtained from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
applied to each fit. Only elements common to both the reference and a
comparison wave are included. Before reporting drift, the function
removes the weighted common-element link offset between the two waves so
that `Drift` represents residual instability rather than the overall
shift between calibrations. The function also records how many common
elements survive the screening step within each linking facet and treats
fewer than 5 retained common elements per facet as thin support. This
count is a package screening convention, not a universal adequacy
threshold.

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
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_linking_and_dff.md).

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

Inspect relative changes after the common-element offset used by
`detect_anchor_drift()`. Read `summary(x)` and link support alongside
the plot.

## Which function should I use?

- Use
  [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/anchor_to_baseline.md)
  when your starting point is raw new data plus a single baseline fit.

- Use `detect_anchor_drift()` when you already have multiple fitted
  waves and want a reference-versus-wave comparison.

- Use
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_equating_chain.md)
  when the waves form a sequence and you need cumulative linking
  offsets.

## Interpreting output

- `$drift_table`: one row per element x wave combination, with columns
  `Facet`, `Level`, `Wave`, `Ref_Est`, `Wave_Est`, `LinkOffset`,
  `Drift`, `SE_Ref`, `SE_Wave`, `SE`, `Drift_SE_Ratio`,
  `LinkSupportAdequate`, and `Flag`. Large drift signals instability
  after alignment to the common-element link.

- `$summary`: aggregated statistics by facet and wave: number of
  elements, mean/max absolute drift, and count of flagged elements.

- `$common_elements`: pairwise common-element counts in tidy table form.
  Small overlap weakens the comparison and results should be interpreted
  cautiously.

- `$common_by_facet`: retained common-element counts by linking facet
  for each reference-vs-wave comparison. `LinkSupportAdequate = FALSE`
  means the link rests on fewer than 5 retained common elements in at
  least one facet.

- `$config`: records the analysis parameters for reproducibility.

- A practical reading order is `summary(drift)` first, then
  `drift$drift_table`, then `drift$common_by_facet` if overlap looks
  thin.

## Typical workflow

1.  Fit separate models for each administration wave.

2.  Combine into a named list:
    `fits <- list(Spring = fit_s, Fall = fit_f)`.

3.  Call `drift <- detect_anchor_drift(fits)`.

4.  Review `summary(drift)` and `plot(drift)`.

5.  Flagged elements may need to be removed from anchor sets or
    investigated for substantive causes (e.g., rater re-training).

## Interpretation

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

Drift and heatmap views show the saved relative drift. Flags use the
screening rules chosen during analysis; changing the display does not
recalibrate these rules. Subtracting the common-element offset can
remove a panel-wide shift, so unflagged elements do not establish
absence of annual drift.

Forest whiskers describe individual wave estimates, not uncertainty in
their differences. They do not include linking-offset uncertainty or
cross-wave covariance, and their overlap is not a test of change.
Missing standard errors produce no whisker, not a zero-width interval.

## See also

[`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/anchor_to_baseline.md),
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_equating_chain.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/make_anchor_table.md),
plot(x),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_linking_and_dff.md)

`detect_anchor_drift()`,
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md)

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
