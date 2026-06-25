# mfrmr Linking and DFF Guide

Package-native guide to checking connectedness, building anchor-based
links, monitoring drift, and screening differential facet functioning
(DFF) in `mfrmr`.

## Start with the linking question

- "Is the design connected enough to support a common scale?" Use
  [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
  and `plot(..., type = "design_matrix")`.

- "Which elements can I export as anchors from an existing fit?" Use
  [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md)
  and
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md).

- "How do I anchor a new administration to a baseline?" Use
  [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md).

- "Have common elements drifted across separately fitted waves?" Use
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  and
  [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md).

- "Can I synthesize anchor review, drift, and chain evidence into one
  review?" Use
  [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md).

- "Do specific facet levels function differently across groups?" Use
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
  and
  [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md).

## Recommended linking route

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and diagnose with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

2.  Check connectedness with
    [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md).

3.  Build or review anchors with
    [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md)
    and
    [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md).

4.  Use
    [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
    when you need to place raw new data onto a baseline scale.

5.  Use
    [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
    only as a screened linking aid across already fitted waves.

6.  Use
    [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
    for stability monitoring on separately fitted waves.

7.  Use
    [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
    when you need one operational synthesis object rather than separate
    anchor/drift/chain tables.

8.  Run
    [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
    only after checking connectivity and common-scale evidence.

## Which helper answers which task

- [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md):

  Summarizes connected subsets, bottleneck facets, and design-matrix
  coverage.

- [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md):

  Extracts reusable anchor candidates from a fit.

- [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md):

  Anchors new raw data to a baseline fit and returns anchored
  diagnostics plus a consistency check against the baseline scale.

- [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md):

  Compares fitted waves directly to flag unstable anchor elements.

- [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md):

  Accumulates screened pairwise links across a series of administrations
  or forms.

- [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md):

  Synthesizes anchor review, drift, and screened-chain evidence into one
  operational review surface.

- [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md):

  Screens differential facet functioning with residual or refit methods,
  using screening-only language unless linking and precision support
  stronger interpretation.

## Practical linking rules

- Check connectedness before interpreting subgroup or wave differences.

- Use DFF outputs as screening results when common-scale linking is
  weak.

- Always name the facet, facet level, and group pair involved in a DFF
  contrast. A generic "DIF exists" statement is not interpretable in a
  many-facet design.

- Residual-method DFF classifications are screening labels. ETS A/B/C
  labels require refit output whose `ClassificationSystem` is `"ETS"`.

- Treat drift flags as prompts for review, not automatic evidence that
  an anchor must be removed.

- Treat `LinkSupportAdequate = FALSE` as a weak-link warning: at least
  one linking facet retained fewer than 5 common elements after
  screening.

- Rebuild anchors from a defensible baseline rather than chaining
  unstable links by hand.

## Typical workflow

- Cross-sectional linkage review:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
  -\> `plot(..., type = "design_matrix")`.

- Baseline placement review:
  [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md)
  -\>
  [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- Multi-wave drift review: fit each wave separately -\>
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  -\>
  [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
  -\>
  [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md).

- Group comparison route:
  [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
  -\>
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  -\>
  [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md)
  -\>
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md)
  /
  [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md).

## Companion guides

- For visual follow-up, see
  [mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md).

- For report/table selection, see
  [mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md).

- For end-to-end routes, see
  [mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md).

- For a longer walkthrough, see
  [`vignette("mfrmr-linking-and-dff", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.md).

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  quad_points = 7,
  maxit = 30
)
diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")

subsets <- subset_connectivity_report(fit, diagnostics = diag)
subsets$summary[, c("Subset", "Observations", "ObservationPercent")]

dff <- analyze_dff(fit, diag, facet = "Rater", group = "Group", data = toy)
head(dff$dif_table[, c("Level", "Group1", "Group2",
                       "Classification", "ClassificationSystem")])
} # }
```
