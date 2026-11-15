#' mfrmr Linking and DFF Guide
#'
#' @description
#' Package-native guide to checking connectedness, building anchor-based links,
#' monitoring drift, and screening differential facet functioning (DFF) in
#' `mfrmr`.
#'
#' @section Choose the linking task:
#' | Question | Route |
#' | --- | --- |
#' | Do the planned/observed assignments connect the ratings? | [describe_mfrm_data()] (`design_connectivity`, optionally `expected_design`), then [subset_connectivity_report()] |
#' | Which baseline locations can be supplied as anchors? | [make_anchor_table()], then [review_mfrm_anchors()] |
#' | How do I fit new data with baseline locations fixed? | [anchor_to_baseline()] |
#' | Have common elements changed across separately fitted waves? | [detect_anchor_drift()], optionally [build_equating_chain()] and [build_linking_review()] |
#' | Do specific facet levels differ between groups? | [analyze_dff()] and [dif_report()]; see [mfrm_dff_methods] for the distinct MH/logistic inference routes |
#'
#' Select the route needed for the question; these are not compulsory stages.
#' The [linking and DFF article](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.html) contains runnable annual-assessment,
#' two-school/common-recording and assignment-design examples, software
#' constraint comparisons and a saved-analysis migration example.
#'
#' Common Persons, rotating assignments and random assignments describe data
#' collection, not fixed abilities. [build_mfrm_sim_spec()] and
#' [simulate_mfrm_data()] represent supported designs; inspect each realized
#' assignment with [describe_mfrm_data()]. Random allocation need not produce
#' connected or balanced ratings, and an implemented generator does not qualify
#' every estimator for its designs.
#' @section What does an anchor do?:
#' Suppose a previous calibration placed Rater R01 at 0.35 logits. A direct
#' anchor tells the new fit to keep that value exactly; the new ratings do not
#' re-estimate it. This requires the same rater identity, model orientation and
#' a defensible stability assumption, not just the same text label.
#'
#' Keep four ideas separate:
#' - **Common ratings:** overlapping Persons, tasks or raters connect observed
#'   ratings. Their parameter values need not be known or fixed.
#' - **Scale identification:** a constraint such as a zero mean sets an origin
#'   for otherwise interchangeable coordinates. It does not establish invariance.
#' - **Direct anchors:** `Facet`, `Level`, `Anchor` fixes a location. For
#'   example, R01 = 0.35 means exactly 0.35 on the internal logit scale.
#' - **Group anchors:** `Facet`, `Level`, `Group`, `GroupValue` fixes a mean.
#'   For R01 and R02 in a group with target 0.20, their locations must sum to
#'   0.40; neither location is individually fixed unless also directly anchored.
#'   This is an unweighted mean across declared levels, including fixed members.
#'
#' @section What the current implementation supports:
#' Non-Person location constraints are available in supported ordinary MML/JML
#' fits. Person direct/group constraints require JML; MML integrates ability
#' and rejects them. This is an implementation boundary, not a claim that
#' fixed-Person MML is mathematically impossible. Two-family GPCM has separate
#' restrictions; see [gpcm_capability_matrix()].
#'
#' With `centering_scope = "facet"` (the ordinary-fit default), centered facets
#' sum to zero across all levels, including direct anchors and group totals.
#' A single ungrouped remainder therefore balances those totals. Use
#' `centering_scope = "remainder"` to reproduce earlier fits that centered only
#' the levels outside direct/group constraints. Ordinary additive RSM/PCM JML
#' also offers `centering_scope = "anchor_origin"`: direct or group anchors replace
#' their facet's centering, with an unanchored, active noncenter facet.
#' Group targets are repeated arithmetic means, not per-element contributions.
#' The default remains `"facet"`. Read [fit_mfrm()] before linking
#' a cohort with new raters or tasks; population and `noncenter_facet` settings
#' also determine the scale. Contradictory constraints stop before estimation.
#'
#' [anchor_to_baseline()] transfers selected facet locations, not a whole
#' calibration: thresholds/slopes are re-estimated, and most settings must be
#' supplied again. RSM/PCM MML defaults to a fixed standard-normal population;
#' anchoring does not automatically estimate a changed ability distribution.
#' Use [extract_mfrm_calibration()] and [score_mfrm_calibration()] to score against a complete
#' fixed calibration within that separate workflow's supported scope.
#'
#' @section Can I obtain intervals when I use anchors?:
#' For ordinary unit-weight RSM/PCM MML with fixed standard-normal ability and
#' fixed-grid integration, [mfrm_facet_intervals()] can return model-information
#' or cluster-sandwich intervals for free facet locations and contrasts, subject
#' to its checks. These intervals condition on the supplied anchors. A fixed
#' location has SE zero and no inferential bounds; its source uncertainty has
#' not been estimated by the receiving fit.
#'
#' Anchor-origin intervals are also available for supported direct RSM/PCM
#' MML fits with an intercept-only population. Read [mfrm_facet_intervals()]
#' and [mfrm_population_intervals()] for this version's population-SD,
#' integration and anchor restrictions. They condition on supplied anchors
#' unless the documented source-covariance option is requested. A local-rank
#' or convergence check alone does not qualify intervals or establish anchor
#' invariance. Choose the population model substantively, not to obtain an SE.
#'
#' One-family GPCM MML has a separate slope/curve route: [confint.mfrm_fit()]
#' with `parm = "slopes"` and [mfrm_curve_intervals()] can condition on fixed anchors when their
#' own checks pass. Anchored native-location/profile-slope intervals and portable
#' GPCM extraction remain unavailable. An available interval does not certify
#' the separate integration checks required by [predict_mfrm_units()].
#'
#' @section Reusing an analysis saved before the centering change:
#' - **Read the original result:** `readRDS()` preserves its coefficients and
#'   constraints. `summary(fit, compute = "never")$settings_overview` and
#'   [specifications_report()] identify the centering convention. A native fit
#'   without convention metadata uses the legacy `"remainder"` interpretation.
#' - **Repeat the original analysis:** [build_mfrm_replay_script()] embeds its
#'   anchors and retains that convention. Running the script refits the model;
#'   it does not merely read a saved result.
#' - **Adopt whole-facet centering:** refit from the original responses with
#'   `centering_scope = "facet"` and the intended anchor, population, rubric,
#'   uncentered-facet and owner settings. Do not edit `fit$config` or recenter
#'   an output table to convert the fit. Keep the old and new analyses separately.
#' - **Refresh derived output:** recompute interval objects from the unchanged
#'   fit for revised fixed-contrast derivatives or anchor explanations. Rerun
#'   affected [analyze_dff()] subgroup analyses to retain target/Person anchors;
#'   this does require subgroup refitting. Loading old interval/DFF objects
#'   does not update them.
#' - **Keep a frozen calibration:** [load_mfrm_calibration()] preserves its
#'   original labels and values. Re-extract from the source fit, satisfying the
#'   current validation requirements, for explicit centering labels. If only
#'   the fit survives without the required RSM/PCM MML quadrature review,
#'   obtaining that review needs the original data and additional grid fits.
#'   If only
#'   the calibration file survives, do not infer a missing convention or relabel
#'   it; keep its original scoring interpretation. Changing its calibration
#'   requires the source analysis and a new validated, frozen artifact.
#'
#' The linking vignette provides a runnable migration example. Source-anchor
#' uncertainty remains excluded; a new label or file format adds no uncertainty
#' calculation. Older MML analyses containing Person anchors need substantive
#' review: those values were ignored, whereas current fitting rejects them.
#' Merely selecting the legacy centering mode does not repair such an analysis.
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
#' The bounded fixed-SD RSM/PCM anchor-origin route now offers explicit
#' independent-source covariance propagation through [mfrm_facet_intervals()]
#' and [mfrm_population_intervals()]. This does not change drift or chain
#' summaries, correct noninvariant anchors, or handle dependent samples.
#'
#' @section Reading the theoretical background:
#' Uto (2021, pp. 1442--1444) explains fixed common-rater/task linking. Its
#' simulation fixes generated common parameters and removes a redundant rater
#' identification constraint; its Bayesian estimation and constraints differ
#' from mfrmr. It does not validate every centering convention above or provide
#' uncertainty propagation for anchors estimated in a previous mfrmr fit.
#'
#' Robitzsch (2024, pp. 1181--1182, 1187--1188) studies bias and linking error
#' from random uniform DIF in fixed-item 2PL calibration. It separates this
#' issue from sampling Persons and does not provide a variance estimator for
#' the fitted population parameters. It motivates checking anchor invariance,
#' not treating current mfrmr SEs as including every source of linking error.
#' For the distinction between an origin constraint and a fixed external value,
#' see the FACETS centering and element documentation cited below; its constraint
#' convention is not identical to mfrmr's.
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
#' `ScreeningFallback` indicates that preliminary screening retained nothing
#' and the offset instead used all finite differences. `N_Contributing` counts
#' the rows actually entering the final average, which can differ from
#' `N_Retained`. Neither count certifies invariant anchors.
#' Missing offsets/spread are explained by `OffsetStatus`, `OffsetReason`
#' and, for chains, `OffsetSDStatus`. A single retained element has undefined
#' residual sample SD, not zero uncertainty. Drift `FlagBasis` distinguishes
#' the magnitude-only screen from a screen with an available SE ratio.
#'
#' @section Conditions for reuse and interpretation:
#' Common labels alone do not establish common elements or invariance. Match
#' the model, score coding, orientation, population and constraints across runs.
#' [make_anchor_table()] requires a current eligible source by default but does
#' not select invariant elements; `readiness_policy = "review"` permits review-only
#' extraction. [review_mfrm_anchors()] checks syntax and receiving-data support,
#' not substantive stability. Assignment graphs establish observed overlap;
#' agreement, severity-direction and halo networks do not establish a common scale.
#'
#' [analyze_dff()] describes residual differences or linked subgroup fits.
#' Its refit contrasts remain screens conditional on baseline anchors.
#' [mantel_haenszel_table()] and [ordinal_logistic_table()] answer different
#' group-comparison questions under their matching and independence assumptions;
#' see [mfrm_dff_methods] before comparing outputs. Repeated Person-target ratings
#' cannot be treated as independent observations merely by pooling them.
#'
#' The drift/link-review `LinkSupportAdequate` screen checks at least five retained
#' common elements **per linking facet**. Refit DFF instead checks a default total
#' of five anchored levels across non-target linking facets in each subgroup;
#' read `ScaleLinkStatus`, `LinkingThreshold` and the group-specific details.
#' Neither threshold is a universal anchor-count recommendation. Investigate
#' drift flags and dependence on anchor selection before excluding elements.
#' @section Companion guides:
#' - For visual follow-up, see [mfrmr_visual_diagnostics].
#' - For report/table selection, see [mfrmr_reports_and_tables].
#' - For end-to-end routes, see [mfrmr_workflow_methods].
#' - For a longer walkthrough, see
#'   [mfrmr-linking-and-dff](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.html).
#'
#' @references
#' TAM documentation: \href{https://alexanderrobitzsch.github.io/TAM/reference/tam.mml.html}{MML estimation and fixed parameters}
#' and \href{https://alexanderrobitzsch.github.io/TAM/reference/tam.jml.html}{JML and fixed Person parameters}.
#'
#' ACER ConQuest manual: \href{https://conquestmanual.acer.org/s4-00.html}{Command reference},
#' especially `import` (anchor parameter types) and `set` (location and scale
#' constraints). Defaults and supported options depend on the program version.
#'
#' FACETS documentation: \href{https://www.winsteps.com/facetman/centerfacet.htm}{Centering facets}
#' and \href{https://www.winsteps.com/facetman/elements.htm}{Elements and anchors}.
#'
#' Linacre, J. M. (2012). \href{https://www.winsteps.com/a/ftutorial4.pdf}{Facets Tutorial 4: Anchoring},
#' p. 9, discusses rater drift and the assumption involved in fixing a group
#' mean across sessions. It does not establish the common-recording workflow
#' described here or its uncertainty performance.
#'
#' Eckes, T. (2023). *Introduction to Many-Facet Rasch Measurement*,
#' Section 9.1, pp. 151--155, Table 9.1. Peter Lang.
#' ISBN 978-3-631-90305-6.
#'
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
#' # Long-running workflow; run explicitly when needed.
#' # example("mfrmr_linking_and_dff", run.dontrun = TRUE)
#' \dontrun{
#' ratings <- load_mfrmr_data("example_core")
#' people <- unique(ratings$Person)
#' baseline_data <- ratings[ratings$Person %in% people[1:24], , drop = FALSE]
#' new_data <- ratings[ratings$Person %in% people[25:48], , drop = FALSE]
#' baseline <- fit_mfrm(
#'   baseline_data, "Person", c("Rater", "Criterion"), "Score",
#'   method = "MML", rating_min = 1, rating_max = 4,
#'   category_policy = "preserve"
#' )
#' anchors <- make_anchor_table(baseline, facets = "Criterion")
#' review <- review_mfrm_anchors(
#'   new_data, "Person", c("Rater", "Criterion"), "Score", anchors = anchors,
#'   rating_min = 1, rating_max = 4, category_policy = "preserve"
#' )
#' review$issue_counts
#' linked <- anchor_to_baseline(
#'   new_data, baseline, "Person", c("Rater", "Criterion"), "Score",
#'   anchor_facets = "Criterion", anchor_policy = "error",
#'   rating_min = 1, rating_max = 4, category_policy = "preserve"
#' )
#' linked$fit$facets$others
#' # Fixed-anchor differences are zero by construction, not evidence of stability.
#' linked$drift[, c("Facet", "Level", "Drift")]
#'
#' }
#' @name mfrmr_linking_and_dff
NULL
