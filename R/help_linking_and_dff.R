#' mfrmr Linking and DFF Guide
#'
#' @description
#' Package-native guide to checking connectedness, building anchor-based links,
#' monitoring drift, and screening differential facet functioning (DFF) in
#' `mfrmr`.
#'
#' @section Start with the linking question:
#' - "Is the design connected enough to support a common scale?"
#'   Use [subset_connectivity_report()] and `plot(..., type = "design_matrix")`.
#' - "Which elements can I export as anchors from an existing fit?"
#'   Use [make_anchor_table()] and [review_mfrm_anchors()].
#' - "How do I anchor a new administration to a baseline?"
#'   Use [anchor_to_baseline()].
#' - "Have common elements drifted across separately fitted waves?"
#'   Use [detect_anchor_drift()] and [plot_anchor_drift()].
#' - "Can I synthesize anchor review, drift, and chain evidence into one review?"
#'   Use [build_linking_review()].
#' - "Do specific facet levels function differently across groups?"
#'   Use [analyze_dff()], [plot_dif_heatmap()], and [plot_dif_summary()].
#'
#' @section Recommended linking route:
#' 1. Fit with [fit_mfrm()] and diagnose with [diagnose_mfrm()].
#' 2. Check connectedness with [subset_connectivity_report()].
#' 3. Build or review anchors with [make_anchor_table()] and
#'    [review_mfrm_anchors()].
#' 4. Use [anchor_to_baseline()] when you need to place raw new data onto a
#'    baseline scale.
#' 5. Use [build_equating_chain()] only as a screened linking aid across
#'    already fitted waves.
#' 6. Use [detect_anchor_drift()] for stability monitoring on separately fitted
#'    waves.
#' 7. Use [build_linking_review()] when you need one operational synthesis
#'    object rather than separate anchor/drift/chain tables.
#' 8. Run [analyze_dff()] only after checking connectivity and common-scale
#'    evidence.
#'
#' @section Keep anchor roles separate:
#' - A common-element or common-rating link is observed overlap in the design.
#' - `anchors` are direct equality constraints on selected parameter values.
#' - `group_anchors` constrain declared group means and require an externally
#'   defensible target or equal-mean assumption.
#' - [make_anchor_table()] exports candidate direct constraints mechanically;
#'   by default it requires a current inference-ready source fit, but it does
#'   not select invariant elements. `readiness_policy = "review"` is for
#'   review-only extraction, not anchor reuse.
#'
#' Constraint-based coordinate transfer does not create empirical overlap.
#' Before reuse, also verify consistent model/score/orientation/population
#' conventions, cross-run element identity, and the relevant assignment
#' connectedness. [review_mfrm_anchors()] checks syntax and receiving-data
#' support, not those substantive assumptions.
#'
#' @section Design the link, not only the anchor count:
#' There is no universal adequate anchor count or percentage. Linking quality
#' also depends on where overlap occurs, whether links are distributed or rely
#' on one critical bridge, the rating workload and coverage, and model--data
#' fit within the linking set. Inspect both Rater-centered and Person/task-
#' centered assignment graphs when the design is sparse. The package's
#' five-element `LinkSupportAdequate` screen is therefore a local warning, not
#' a design recommendation or proof of a common scale.
#'
#' Fixed anchor values also carry uncertainty from their source calibration.
#' Current anchor, drift, and chain summaries do not propagate all source-fit,
#' offset, or cross-fit covariance. Compare substantively defensible anchor
#' sets and report sensitivity when conclusions depend on the selected set.
#'
#' @section Drift and chain inference boundary:
#' [detect_anchor_drift()] and [build_equating_chain()] currently estimate one
#' pooled offset across all selected common elements and facets. Their
#' element-level SE ratios omit estimated-offset uncertainty and cross-fit
#' covariance, and chain output does not propagate uncertainty across adjacent
#' links. `Offset_SD` is residual spread, not an offset SE. Treat flags,
#' support counts, and cumulative offsets as review screens; when a common
#' shift across facet blocks is not defensible, analyze one coherent linking
#' facet at a time.
#'
#' @section Which helper answers which task:
#' \describe{
#'   \item{[subset_connectivity_report()]}{Summarizes connected subsets,
#'   bottleneck facets, and design-matrix coverage.}
#'   \item{[make_anchor_table()]}{Extracts candidate direct-anchor values from a
#'   fit without certifying them for reuse.}
#'   \item{[anchor_to_baseline()]}{Anchors new raw data to a baseline fit and
#'   returns anchored diagnostics plus a consistency check against the baseline
#'   scale.}
#'   \item{[detect_anchor_drift()]}{Compares fitted waves directly to flag
#'   unstable anchor elements.}
#'   \item{[build_equating_chain()]}{Accumulates screened pairwise links across
#'   a series of administrations or forms.}
#'   \item{[build_linking_review()]}{Synthesizes anchor review, drift, and
#'   screened-chain evidence into one operational review surface.}
#'   \item{[analyze_dff()]}{Screens differential facet functioning with residual
#'   or refit methods. Linked refit point contrasts remain screening-only
#'   because their uncertainty is conditional on baseline anchors.}
#' }
#'
#' @section Practical linking rules:
#' - Check connectedness before interpreting subgroup or wave differences.
#' - Use [mfrm_network_analysis()] for assignment/co-observation connectedness.
#'   Agreement, severity-direction, and halo networks describe score relations;
#'   they do not establish an empirical link or a common measurement scale.
#' - Use residual and refit DFF outputs as screening results. Even with an
#'   adequate link, refit SEs condition on baseline anchors and omit their
#'   uncertainty and cross-refit covariance; formal inference remains unavailable.
#' - Always name the facet, facet level, and group pair involved in a DFF
#'   contrast. A generic "DIF exists" statement is not interpretable in a
#'   many-facet design.
#' - Residual and refit DFF classifications are currently screening labels;
#'   current refit output does not assign ETS A/B/C labels.
#' - Treat drift flags as prompts for review, not automatic evidence that an
#'   anchor must be removed.
#' - Treat `LinkSupportAdequate = FALSE` as a weak-link warning: at least one
#'   linking facet retained fewer than 5 common elements after screening.
#' - Rebuild anchors from a defensible baseline rather than chaining unstable
#'   links by hand.
#'
#' @section Typical workflow:
#' - Cross-sectional linkage review:
#'   [fit_mfrm()] -> [diagnose_mfrm()] -> [subset_connectivity_report()] ->
#'   `plot(..., type = "design_matrix")`.
#' - Baseline placement review:
#'   [make_anchor_table()] -> [anchor_to_baseline()] -> [diagnose_mfrm()].
#' - Multi-wave drift review:
#'   fit each wave separately -> [detect_anchor_drift()] ->
#'   [build_linking_review()] -> [plot_anchor_drift()].
#' - Group comparison route:
#'   [subset_connectivity_report()] -> [analyze_dff()] ->
#'   [dif_report()] -> [plot_dif_heatmap()] / [plot_dif_summary()].
#'
#' @section Companion guides:
#' - For visual follow-up, see [mfrmr_visual_diagnostics].
#' - For report/table selection, see [mfrmr_reports_and_tables].
#' - For end-to-end routes, see [mfrmr_workflow_methods].
#' - For a longer walkthrough, see
#'   `vignette("mfrmr-linking-and-dff", package = "mfrmr")`.
#'
#' @references
#' Myford, C. M., & Wolfe, E. W. (2000). Strengthening the ties that bind:
#' Improving the linking network in sparsely connected rating designs.
#' *ETS Research Report Series*, 2000(1).
#' \doi{10.1002/j.2333-8504.2000.tb01832.x}
#'
#' Uto, M. (2021). Accuracy of performance-test linking based on a many-facet
#' Rasch model. *Behavior Research Methods*, 53(4), 1440--1454.
#' \doi{10.3758/s13428-020-01498-x}
#'
#' Wind, S. A., & Jones, E. (2018). The stabilizing influences of linking set
#' size and model--data fit in sparse rater-mediated assessment networks.
#' *Educational and Psychological Measurement*, 78(4), 679--707.
#' \doi{10.1177/0013164417703733}
#'
#' Robitzsch, A. (2024). Bias and linking error in fixed item parameter
#' calibration. *AppliedMath*, 4(3), 1181--1191.
#' \doi{10.3390/appliedmath4030063}
#'
#' @examples
#' \donttest{
#' toy <- load_mfrmr_data("example_bias")
#' fit <- fit_mfrm(
#'   toy,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   method = "MML",
#'   quad_points = 7,
#'   maxit = 30
#' )
#' diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
#'
#' subsets <- subset_connectivity_report(fit, diagnostics = diag)
#' subsets$summary[, c("Subset", "Observations", "ObservationPercent")]
#'
#' dff <- analyze_dff(fit, diag, facet = "Rater", group = "Group", data = toy)
#' head(dff$dif_table[, c("Level", "Group1", "Group2",
#'                        "Classification", "ClassificationSystem")])
#' }
#'
#' @name mfrmr_linking_and_dff
NULL
