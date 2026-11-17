#' @section Linking and DFF route map:
#' | Question | Route |
#' | --- | --- |
#' | Do planned/observed assignments connect ratings? | [describe_mfrm_data()] (`design_connectivity`), [subset_connectivity_report()] |
#' | Which baseline locations can serve as anchors? | [make_anchor_table()], [review_mfrm_anchors()] |
#' | How do I fit new data with baseline locations fixed? | [anchor_to_baseline()] |
#' | Have common elements shifted across waves? | [detect_anchor_drift()], [build_equating_chain()], [build_linking_review()] |
#' | Do facet levels differ between groups? | [analyze_dff()] (`mfrm_report(x, type = "dff")`); see [mantel_haenszel_table()] and [ordinal_logistic_table()] |
#'
#' Keep four concepts distinct: **common ratings** (observed overlap), **scale
#' identification** (e.g., sum-to-zero centering), **direct anchors** (`Facet`,
#' `Level`, `Anchor` fixing internal logit coordinates), and **group anchors**
#' (`Facet`, `Level`, `Group`, `GroupValue` fixing an unweighted arithmetic
#' group mean). With `centering_scope = "facet"` (default), centered facets sum
#' to zero across all levels including anchors/groups; `"remainder"` centers
#' unconstrained levels only; `"anchor_origin"` (additive RSM/PCM JML) lets
#' anchors replace centering on their facet when an active unanchored
#' `noncenter_facet` is selected.
#'
#' [detect_anchor_drift()] and [build_equating_chain()] estimate one pooled
#' offset per link (`Offset_SD` is residual spread across retained elements,
#' not an offset SE; `LinkSupportAdequate` is a local 5-element count screen,
#' not proof of invariance). Source-anchor covariance is excluded unless
#' explicitly requested via `anchor_covariance` and `independent_anchors = TRUE`
#' in [mfrm_facet_intervals()] (intercept-only RSM/PCM anchor-origin MML).
#'
#' @aliases mfrmr_linking_and_dff
#' @rdname build_linking_review
#' @name mfrmr_linking_and_dff
NULL
