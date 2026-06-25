# Build a screened linking chain across ordered calibrations

Links a series of calibration waves by computing mean offsets between
adjacent pairs of fits. Common linking elements (e.g., raters or items
that appear in consecutive administrations) are used to estimate the
scale shift. Cumulative offsets place all waves on a common metric
anchored to the first wave. The procedure is intended as a practical
screened linking aid, not as a full general-purpose equating framework.

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
  type = c("common_anchors", "graph", "chain"),
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
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

  Threshold for flagging large residuals in links.

- x:

  An `mfrm_equating_chain` object.

- ...:

  Ignored.

- y:

  Unused (S3 plot signature requirement).

- type:

  One of `"graph"` (bipartite Wave x anchor-element graph; requires the
  `igraph` package), `"common_anchors"` (default; bar chart of
  common-anchor counts per wave pair), or `"chain"`.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw the plot with base graphics.

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

## Details

The screened linking chain uses a screened link-offset method. For each
pair of adjacent waves \\(A, B)\\, the function:

1.  Identifies common linking elements (facet levels present in both
    fits).

2.  Computes per-element differences: \$\$d_e = \hat{\delta}\_{e,B} -
    \hat{\delta}\_{e,A}\$\$

3.  Computes a preliminary link offset using the inverse-variance
    weighted mean of these differences when standard errors are
    available (otherwise an unweighted mean).

4.  Screens out elements whose residual from that preliminary offset
    exceeds `drift_threshold`, then recomputes the final offset on the
    retained set.

5.  Records `Offset_SD` (standard deviation of retained residuals) and
    `Max_Residual` (maximum absolute deviation from the mean) as
    indicators of link quality.

6.  Flags links with fewer than 5 retained common elements in any
    linking facet as having thin support.

Cumulative offsets are computed by chaining link offsets from Wave 1
forward, placing all waves onto the metric of the first wave.

Elements whose per-link residual exceeds `drift_threshold` are flagged
in `$element_detail$Flag`. A high `Offset_SD`, many flagged elements, or
a thin retained anchor set signals an unstable link that may compromise
the resulting scale placement.

## Which function should I use?

- Use
  [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  for a single new wave anchored to a known baseline.

- Use
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  when you want direct comparison against one reference wave.

- Use `build_equating_chain()` when no single wave should dominate and
  you want ordered, adjacent links across the series.

## Interpreting output

- `$links`: one row per adjacent pair with `From`, `To`, `N_Common`,
  `N_Retained`, `Offset_Prelim`, `Offset`, `Offset_SD`, and
  `Max_Residual`. Small `Offset_SD` relative to the offset indicates a
  consistent shift across elements. `LinkSupportAdequate = FALSE` means
  at least one linking facet retained fewer than 5 common elements after
  screening.

- `$cumulative`: one row per wave with its cumulative offset from
  Wave 1. Wave 1 always has offset 0.

- `$element_detail`: per-element linking statistics (estimate in each
  wave, difference, residual from mean offset, and flag status). Flagged
  elements may indicate DIF or rater re-training effects.

- `$common_by_facet`: retained common-element counts by linking facet
  for each adjacent link.

- `$config`: records wave names and analysis parameters.

- Read `links` before `cumulative`: weak adjacent links can make later
  cumulative offsets less trustworthy.

## Typical workflow

1.  Fit each administration wave separately: `fit_a <- fit_mfrm(...)`.

2.  Combine into an ordered named list:
    `fits <- list(Spring23 = fit_s, Fall23 = fit_f, Spring24 = fit_s2)`.

3.  Call `chain <- build_equating_chain(fits)`.

4.  Review `summary(chain)` for link quality.

5.  Visualize with `plot_anchor_drift(chain, type = "chain")`.

6.  For problematic links, investigate flagged elements in
    `chain$element_detail` and consider removing them from the anchor
    set.

## See also

[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
[`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md),
[`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
people <- unique(toy$Person)
d1 <- toy[toy$Person %in% people[1:12], , drop = FALSE]
d2 <- toy[toy$Person %in% people[13:24], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
chain <- build_equating_chain(list(Form1 = fit1, Form2 = fit2))
summary(chain)
chain$cumulative
} # }
```
