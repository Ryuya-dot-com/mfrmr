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

- ...:

  Ignored.

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

  If `TRUE`, draw the plot with base graphics.

- show_title:

  Logical; display the main title.

- show_notes:

  Logical; display graph/topology interpretation footers. Returned notes
  and ordinary R warnings are unaffected. Axes, legends and data labels
  remain visible; other chain views have no interpretation footer.

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

The five-element rule is a package screening convention, not a universal
adequacy threshold. Matching labels are assumed to identify the same
invariant elements, and input fits are assumed to use compatible model,
score, orientation, and population conventions. The helper does not
verify those assumptions or source-fit readiness. In particular,
adjacent label overlap and a finite offset do not by themselves
establish a common scale.

Each adjacent `Offset` is one value pooled across all selected facets.
When any common rows have finite positive SEs, only those rows
contribute to the inverse-variance weighted offset; retained/support
counts can still include rows without usable SEs. If preliminary
screening would remove every row, the implementation falls back to all
finite differences. Prefer one substantively coherent `anchor_facets`
block unless a common shift across facets is justified.

Cumulative offsets are computed by chaining link offsets from Wave 1
forward, placing all waves onto the metric of the first wave.
`Offset_SD` is retained-element residual spread, not the standard error
of `Offset`. No offset SE, confidence interval, cross-fit covariance, or
cumulative uncertainty propagation is currently returned, so uncertainty
can compound along the chain without appearing in `cumulative`.

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

- `OffsetStatus` / `OffsetReason` explain unavailable link offsets.
  `ScreeningFallback` records use of all finite differences when no row
  passed preliminary screening. `N_Contributing` and the element-level
  `Contributing` flag identify the rows actually used in the final
  average; retained rows without usable SEs may not contribute.

- `OffsetSDStatus` distinguishes available residual spread from fewer
  than two retained elements, unavailable offsets, or a numerical
  failure. A singleton has an undefined sample SD, not an estimated SD
  of zero. Unavailable `Max_Residual` and flagged counts stay missing
  rather than representing no drift. Summaries also give the unavailable
  count and the flagged count among available elements.

- `cumulative$Status` / `Reason` distinguish unavailable preceding links
  from an unrepresentable cumulative sum. Later offsets do not become
  zero when a link is unavailable.

- Read `links` before `cumulative`: weak adjacent links can make later
  cumulative offsets less trustworthy.

## Common-element graph

`plot(chain, type = "graph")` displays waves as squares and common
elements as circles, including waves without retained connections. Each
element node belongs to one reviewed link: `[L1]` refers to link 1 in
the returned links table. The same element can have different screening
results in different comparisons, so it is repeated per link. Solid
lines denote retained, unflagged elements; dot-dash denotes retained
elements with a drift flag or an unavailable flag; dashed denotes
excluded elements; dotted denotes unknown retention. These distinctions
also apply in monochrome.

This is a graph of screened common-element comparisons, not an inventory
of fixed anchors or an all-pairs assessment. Retention does not
guarantee positive weight in the offset, invariance, adequate support or
precision. New chains store positional `FromID`/`ToID` in `links` and
`LinkID` in `element_detail`; display names may repeat or contain
punctuation. Older chains are matched by their complete link labels;
ambiguous references require rebuilding the chain.

With `draw = FALSE`, the plot returns an `mfrm_plot_data` object. Its
`$data$data` contains `nodes`, `edges`, `links`, `elements`, `n_waves`,
`n_anchors` (unique facet/level identities), and `n_element_nodes`
(link-specific nodes). Edge `from`/`to` refer to node `NodeId`;
`AnchorId` identifies the same facet/level across links. `Retained`,
`Flag`, `Status` and `Reason` preserve screening information.
`RetainedDegree` counts retained incidences, not statistical
information. Interpretation notes remain in `$data$notes` and in
[`print()`](https://rdrr.io/r/base/print.html) even when
`show_notes = FALSE`. Full labels remain in the node table if the device
is too narrow. Base graphics are sufficient; no optional graph package
is needed.

## Wave links and common-element removal

`plot(chain, type = "links")` summarizes the recorded wave-to-wave
comparisons. Numbers count common elements with `Retained = TRUE`,
including flagged retained elements. A dotted comparison has no recorded
retained element; this is not proof that the original rating design is
disconnected. Missing retention is counted separately. Dot-dash
connections have flagged retained elements or inadequate/unknown
recorded link support.

`plot(chain, type = "anchor_removal")` removes each facet/level
identity, one at a time, from all recorded comparisons. Other retention
decisions stay fixed. The horizontal axis counts newly disconnected
unordered wave pairs, including indirect paths. Pairs already
disconnected at baseline are not counted. Losing a direct link need not
disconnect its endpoints if another path remains. Zero means no new
graph disconnection, not negligible impact on estimates or adequate
linking support. No screening, offsets, estimates, SEs or confidence
intervals are recomputed by either view.

Both views return `$data$data$nodes`, `links`, `elements` and `summary`.
The removal view additionally returns `removal` (one row per
common-element identity), `lost_links` (recorded comparisons losing
their last retained element), `lost_pairs` (newly disconnected wave
pairs), and `components_after` (baseline and post-removal membership for
every wave). Use `AnchorId` to join the removal table to these details;
`FromID`/`ToID` and `WaveID` identify waves independently of display
labels. Component numbers are local to each partition: compare
membership relations, not numeric labels across Before, After or
different removal scenarios. Removal counts include
`RetainedOccurrences`, `UnknownOccurrences`, `LostLinks`,
`ComponentsAfter` and `NewlyDisconnectedPairs`.

These calculations reuse the recorded common-element graph; they do not
search for new links or assess statistical influence. The full lost-pair
table can be large for chains with many waves and common elements.
Compact plots abbreviate long labels and warn when IDs or a larger
device are needed; full identities and interpretation notes remain in
the returned tables.

## Conditional offset sensitivity

`plot(chain, type = "offset_sensitivity")` removes each common
`(Facet, Level)` identity from every adjacent link, then reruns the
existing offset calculation with its recorded drift threshold.
Preliminary offsets, screening, final weighted/unweighted offsets and
cumulative offsets are recomputed. The source wave estimates and SEs
remain fixed: this is a conditional linking sensitivity calculation, not
a refit of item, rater or person parameters or a new uncertainty
estimate.

The view requires an ordered adjacent chain with the recorded method,
threshold, support guideline, source estimate/SE columns and offsets.
Recomputed baseline offsets must agree with recorded offsets within
`1e-8 * max(1, abs(recorded_offset))`; inconsistent or incomplete source
records require rebuilding the chain. Numerical overflow/underflow that
prevents a finite preliminary offset is reported as a numerical failure.

The figure shows each deletion's maximum absolute cumulative offset
change over finite comparisons, excluding the fixed-zero first wave.
Shapes distinguish complete comparisons, partial comparisons and no
finite comparison. An unavailable comparison remains `NA`, not zero. If
one link becomes unavailable, later cumulative offsets also become
unavailable. Read the detailed tables when a figure marks an incomplete
comparison.

The `$data$data` payload contains `settings`, `baseline_links`,
`baseline_cumulative`, `baseline_elements`, `removal`, `links`,
`cumulative`, `retention_changes` and `common_by_facet`. Join
`RemovedAnchorId` in scenario tables to `removal$AnchorId`. Signed
`Change` is recalculated minus baseline offset. `Status` distinguishes
`computed`, `no_common`, `no_finite_differences` and
`numerical_failure`. `N_Contributing` and element `Contributing`
identify positive finite weight contributors (or retained rows in an
unweighted offset). `retention_changes` records other elements whose
retention, contribution or residual flag changes; the deliberately
removed element is omitted. Facets whose last element is removed remain
in support tables with zero counts. No support failure is converted into
a statement of readiness.

`ScreeningFallback` identifies the existing rule that restores all
finite differences if preliminary screening would remove every one. SEs
may be missing, in which case the existing unweighted fallback is used.
No offset SE, confidence interval, cross-fit covariance, or uncertainty
propagation is supplied. A small conditional change is not evidence of
anchor invariance or negligible change under a full model refit. Notes
remain available when figure titles and footers are omitted.

## Typical workflow

1.  Fit each administration wave separately: `fit_a <- fit_mfrm(...)`.

2.  Combine into an ordered named list:
    `fits <- list(Spring23 = fit_s, Fall23 = fit_f, Spring24 = fit_s2)`.

3.  Call `chain <- build_equating_chain(fits)`.

4.  Review `summary(chain)` for link quality.

5.  Visualize with `plot(chain, type = "chain")`.

6.  For problematic links, investigate flagged elements in
    `chain$element_detail` and consider removing them from the anchor
    set.

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

[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
[`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md),
[plot(x)](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_anchor_drift.md)

## Examples

``` r
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
#> Many-Facet Measurement Model Summary
#>   Model: RSM | Method: JML | N: 384 | Persons: 24 | Facets: 2 | Categories: 4
#> 
#> Decision
#>  - Interpretation: Fit-readiness requirements satisfied; formal precision
#>    review required
#>  - Formal inference: No
#>  - Why: Formal precision support has not been evaluated.
#>  - Next: Run `diagnose_mfrm()` and pass its result as `diagnostics =` to
#>    evaluate formal precision support; fit readiness alone is not a
#>    formal-inference decision.
#>   JML uses observed scores without an extreme-score adjustment or finite-item
#>   bias correction. Independently free Person measures are infinite for
#>   all-minimum/all-maximum responses; finite optimizer values are computational
#>   traces. JML SEs and normal bands remain exploratory.
#>   Centering: whole declared facet, including anchors and group totals.
#> 
#> Visual workflow (in order)
#>  Priority                   Visual Required Available
#>         1 mfrmr Wright map with SE     TRUE      TRUE
#>         2  FACETS-style Wright map    FALSE      TRUE
#>         3            Infit pathway    FALSE     FALSE
#>                       Interpretation
#>  Diagnostic interpretation available
#>  Diagnostic interpretation available
#>                          Unavailable
#>   Plot commands are stored in `$required_visual$Route`.
#> 
#> Status
#>  - Overall status: Fit completed; review diagnostics before reporting
#>  - Convergence: converged (severity: pass, maximum absolute gradient: 2.25e-05)
#>  - Estimation path: RSM / JML
#>  - Reporting readiness: Fit available for diagnostic review; inferential
#>    strength depends on the estimator and convergence evidence
#> 
#> Workflow readiness
#>       Domain                                         Status
#>          Fit                                  Checks passed
#>    Numerical                                  Checks passed
#>         Data                                  Checks passed
#>       Design                           Connectivity checked
#>    Stability                                  Checks passed
#>  Diagnostics                                   Not assessed
#>    Reporting Review the stored result before interpretation
#> 
#> Key warnings
#>  - None.
#> 
#> Next actions
#>  - Run `diagnose_mfrm()` and pass its result as `diagnostics =` to evaluate
#>    formal precision support; fit readiness alone is not a formal-inference
#>    decision.
#>  - After reviewing convergence, run `review <- summary(fit, profile = "facets",
#>    detail = "brief")` for the comprehensive measurement review; FACETS software
#>    is not required.
#>  - Then draw the complete native Wright map with `plot(fit, type = "wright",
#>    show_ci = TRUE, top_n = Inf, preset = "publication")`.
#>  - MML provides marginal diagnostics; review the resulting fit and uncertainty
#>    assumptions before using its SEs or intervals.
#>  - Reuse `review$results$diagnostics`; call `diagnose_mfrm()` again only for
#>    residual PCA or other custom settings.
#>  - Use `reporting_checklist(fit, diagnostics = review$results$diagnostics)` for
#>    reporting readiness.
#> 
#> Fit overview
#>   LogLik: -399.287 | Information-criterion ranking is unavailable for JML.
#>   Optimizer code 0: Yes | Status: converged | Fn evals: 176 | Gr evals: 51
#>   Terminal gradient: maximum absolute = 2.25e-05 | RMS = 7.3e-06 | Review tolerance = 0.0001
#>   Optimization note: Optimizer returned convergence code 0.
#> 
#> Population basis
#>   JML estimates Person measures jointly with calibration parameters; it does
#>   not estimate a normal population distribution.
#> 
#> Facet overview
#>      Facet Levels MeanEstimate SDEstimate MinEstimate MaxEstimate  Span
#>  Criterion      4            0      0.351      -0.525       0.220 0.745
#>      Rater      4            0      0.233      -0.239       0.277 0.516
#> 
#> Person measure distribution
#>  Persons DistributionN ReviewExcludedExtremeEAPs  Mean   SD Median    Min   Max
#>       24            24                         0 0.341 1.21  0.569 -2.241 2.692
#>   Span                               Interpretation
#>  4.933 Subject to the fit's interpretation decision
#> 
#> Targeting (Person vs facet means; sum-to-zero ID makes Targeting = Person mean)
#>      Facet PersonMean FacetMean Targeting PersonSD FacetSD SpreadRatio
#>  Criterion      0.341         0     0.341     1.21   0.351       3.443
#>      Rater      0.341         0     0.341     1.21   0.233       5.188
#> 
#> Step parameter summary
#>  Steps    Min   Max  Span Monotonic
#>      3 -1.436 1.379 2.815      TRUE
#> 
#> Estimation settings
#>  StepFacet SlopeFacet NoncenterFacet WeightColumn RatingMin RatingMax
#>       <NA>       <NA>         Person         <NA>         1         4
#>  CategoryPolicy ScoreRecoded DummyFacets PositiveFacets FacetInteractions
#>        collapse        FALSE                                             
#>  UnusedScoreCategories UnusedScoreCategoryCount
#>                                               0
#>   RSM uses one shared set of rating-scale thresholds.
#>   Full fitting settings are retained in `$settings_overview`.
#> 
#> Most extreme facet levels (|estimate|)
#>      Facet        Level Estimate
#>  Criterion      Content   -0.525
#>      Rater          R04    0.277
#>      Rater          R02   -0.239
#>  Criterion     Accuracy    0.220
#>  Criterion Organization    0.162
#> 
#> Paper reporting map
#>                                Area CoveredHere
#>  Model identification / convergence         yes
#>        Data structure / missingness          no
#>    Reliability / fit / residual PCA          no
#>                Category functioning     partial
#>     Bias / DIF / interaction checks          no
#>         Draft reporting / checklist          no
#>                                                                CompanionOutput
#>                                                                   summary(fit)
#>                                               summary(describe_mfrm_data(...))
#>                                                    summary(diagnose_mfrm(fit))
#>  rating_scale_table() / category_structure_report() / category_curves_report()
#>         summary(estimate_bias(...)) / analyze_dff() / related bundle summaries
#>                        reporting_checklist() / summary(build_apa_outputs(...))
summary(fit2)
#> Many-Facet Measurement Model Summary
#>   Model: RSM | Method: JML | N: 384 | Persons: 24 | Facets: 2 | Categories: 4
#> 
#> Decision
#>  - Interpretation: Fit-readiness requirements satisfied; formal precision
#>    review required
#>  - Formal inference: No
#>  - Why: Formal precision support has not been evaluated.
#>  - Next: Run `diagnose_mfrm()` and pass its result as `diagnostics =` to
#>    evaluate formal precision support; fit readiness alone is not a
#>    formal-inference decision.
#>   JML uses observed scores without an extreme-score adjustment or finite-item
#>   bias correction. Independently free Person measures are infinite for
#>   all-minimum/all-maximum responses; finite optimizer values are computational
#>   traces. JML SEs and normal bands remain exploratory.
#>   Centering: whole declared facet, including anchors and group totals.
#> 
#> Visual workflow (in order)
#>  Priority                   Visual Required Available
#>         1 mfrmr Wright map with SE     TRUE      TRUE
#>         2  FACETS-style Wright map    FALSE      TRUE
#>         3            Infit pathway    FALSE     FALSE
#>                       Interpretation
#>  Diagnostic interpretation available
#>  Diagnostic interpretation available
#>                          Unavailable
#>   Plot commands are stored in `$required_visual$Route`.
#> 
#> Status
#>  - Overall status: Fit completed; review diagnostics before reporting
#>  - Convergence: converged (severity: pass, maximum absolute gradient: 2e-05)
#>  - Estimation path: RSM / JML
#>  - Reporting readiness: Fit available for diagnostic review; inferential
#>    strength depends on the estimator and convergence evidence
#> 
#> Workflow readiness
#>       Domain                                         Status
#>          Fit                                  Checks passed
#>    Numerical                                  Checks passed
#>         Data                                  Checks passed
#>       Design                           Connectivity checked
#>    Stability                                  Checks passed
#>  Diagnostics                                   Not assessed
#>    Reporting Review the stored result before interpretation
#> 
#> Key warnings
#>  - None.
#> 
#> Next actions
#>  - Run `diagnose_mfrm()` and pass its result as `diagnostics =` to evaluate
#>    formal precision support; fit readiness alone is not a formal-inference
#>    decision.
#>  - After reviewing convergence, run `review <- summary(fit, profile = "facets",
#>    detail = "brief")` for the comprehensive measurement review; FACETS software
#>    is not required.
#>  - Then draw the complete native Wright map with `plot(fit, type = "wright",
#>    show_ci = TRUE, top_n = Inf, preset = "publication")`.
#>  - MML provides marginal diagnostics; review the resulting fit and uncertainty
#>    assumptions before using its SEs or intervals.
#>  - Reuse `review$results$diagnostics`; call `diagnose_mfrm()` again only for
#>    residual PCA or other custom settings.
#>  - Use `reporting_checklist(fit, diagnostics = review$results$diagnostics)` for
#>    reporting readiness.
#> 
#> Fit overview
#>   LogLik: -418.879 | Information-criterion ranking is unavailable for JML.
#>   Optimizer code 0: Yes | Status: converged | Fn evals: 151 | Gr evals: 47
#>   Terminal gradient: maximum absolute = 2e-05 | RMS = 6.46e-06 | Review tolerance = 0.0001
#>   Optimization note: Optimizer returned convergence code 0.
#> 
#> Population basis
#>   JML estimates Person measures jointly with calibration parameters; it does
#>   not estimate a normal population distribution.
#> 
#> Facet overview
#>      Facet Levels MeanEstimate SDEstimate MinEstimate MaxEstimate  Span
#>  Criterion      4            0      0.250      -0.323       0.281 0.604
#>      Rater      4            0      0.392      -0.413       0.388 0.801
#> 
#> Person measure distribution
#>  Persons DistributionN ReviewExcludedExtremeEAPs   Mean    SD Median    Min
#>       24            24                         0 -0.338 0.921 -0.431 -1.824
#>    Max  Span                               Interpretation
#>  1.854 3.678 Subject to the fit's interpretation decision
#> 
#> Targeting (Person vs facet means; sum-to-zero ID makes Targeting = Person mean)
#>      Facet PersonMean FacetMean Targeting PersonSD FacetSD SpreadRatio
#>  Criterion     -0.338         0    -0.338    0.921   0.250       3.689
#>      Rater     -0.338         0    -0.338    0.921   0.392       2.351
#> 
#> Step parameter summary
#>  Steps    Min   Max  Span Monotonic
#>      3 -1.283 1.439 2.722      TRUE
#> 
#> Estimation settings
#>  StepFacet SlopeFacet NoncenterFacet WeightColumn RatingMin RatingMax
#>       <NA>       <NA>         Person         <NA>         1         4
#>  CategoryPolicy ScoreRecoded DummyFacets PositiveFacets FacetInteractions
#>        collapse        FALSE                                             
#>  UnusedScoreCategories UnusedScoreCategoryCount
#>                                               0
#>   RSM uses one shared set of rating-scale thresholds.
#>   Full fitting settings are retained in `$settings_overview`.
#> 
#> Most extreme facet levels (|estimate|)
#>      Facet    Level Estimate
#>      Rater      R02   -0.413
#>      Rater      R04    0.388
#>  Criterion  Content   -0.323
#>  Criterion Accuracy    0.281
#>      Rater      R03    0.275
#> 
#> Paper reporting map
#>                                Area CoveredHere
#>  Model identification / convergence         yes
#>        Data structure / missingness          no
#>    Reliability / fit / residual PCA          no
#>                Category functioning     partial
#>     Bias / DIF / interaction checks          no
#>         Draft reporting / checklist          no
#>                                                                CompanionOutput
#>                                                                   summary(fit)
#>                                               summary(describe_mfrm_data(...))
#>                                                    summary(diagnose_mfrm(fit))
#>  rating_scale_table() / category_structure_report() / category_curves_report()
#>         summary(estimate_bias(...)) / analyze_dff() / related bundle summaries
#>                        reporting_checklist() / summary(build_apa_outputs(...))
# The four shared levels per facet trigger a thin-support warning.
# Inspect that warning; matching labels alone do not establish a common scale.
chain <- build_equating_chain(list(Form1 = fit1, Form2 = fit2))
#> Warning: Thin linking support between 'Form1' and 'Form2': fewer than 5 retained common elements in Criterion, Rater.
summary(chain)
#> --- Screened Linking Chain ---
#>   Linking flags are review screens, not tests of anchor invariance.
#>   Source-parameter, estimated-offset and cross-fit covariance are not fully
#>   propagated. A sufficient element count alone does not establish a common
#>   scale.
#>   Offset_SD is residual spread, not the SE of the estimated offset; cumulative
#>   offsets omit uncertainty across links.
#> Links: 1 | Waves: Form1 -> Form2 
#> 
#> Link details:
#>  Link FromID ToID  From    To N_Common N_Retained Min_Common_Per_Facet
#>     1      1    2 Form1 Form2        8          8                    4
#>  Min_Retained_Per_Facet Offset_Prelim   Offset Offset_SD OffsetSDStatus
#>                       4      -0.00131 -0.00131     0.155      available
#>  OffsetStatus OffsetReason N_Contributing ScreeningFallback Max_Residual
#>      computed         <NA>              8             FALSE        0.203
#>  LinkSupportAdequate    Offset_Method
#>                FALSE inverse_variance
#> 
#> Retained common elements by facet:
#>  Link  From    To     Facet N_Common N_Retained GuidelineMinCommon
#>     1 Form1 Form2 Criterion        4          4                  5
#>     1 Form1 Form2     Rater        4          4                  5
#>  LinkSupportAdequate
#>                FALSE
#>                FALSE
#> 
#> Cumulative offsets:
#>   Wave Cumulative_Offset   Status Reason
#>  Form1           0.00000 computed   <NA>
#>  Form2          -0.00131 computed   <NA>
chain$cumulative
#> # A tibble: 2 × 4
#>   Wave  Cumulative_Offset Status   Reason
#>   <chr>             <dbl> <chr>    <chr> 
#> 1 Form1           0       computed NA    
#> 2 Form2          -0.00131 computed NA    
```
