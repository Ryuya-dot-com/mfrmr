# mfrmr Visual Diagnostics Map

Quick guide to choosing the right base-R diagnostic plot in `mfrmr`. Use
this page when you know the analysis question but do not yet know which
plotting helper or
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method to call.

If you are preparing figures for a report, start with
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
and inspect the `"Visual Displays"` rows first. Those rows now map
directly onto the public plotting family covered on this page, so the
checklist can act as a plot-readiness router rather than just a
manuscript checklist.

This guide is primarily written for diagnostics-based `RSM` / `PCM`
workflows. `GPCM` fits also use the residual-based diagnostics stack
through
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
[`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
[`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md),
[`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md),
[`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md),
and
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
plus the posterior-scoring, design-weighted-information path via
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
/
[`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md),
and the Wright / pathway / CCC fit plots. Two `GPCM`-specific caveats
apply when interpreting these residual-based screens:

- The free discrimination parameter means MnSq mean-square screens carry
  weaker invariance evidence than they do under `RSM` / `PCM`. Treat
  MnSq flags from `GPCM` as exploratory pointers to cells that merit
  closer inspection rather than as Rasch-style violations of strict
  invariance.

- FACETS-style fair averages are a Rasch-family measure-to-score
  transformation. Under `GPCM` the fair-average panel of
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
  therefore renders with an explicit "unavailable" status, and the
  broader compatibility-export helpers stay outside the validated `GPCM`
  boundary.

Use
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
for the formal per-helper boundary before choosing a `GPCM` follow-up
plot route.

## Start with the question

- "Do persons and facet levels overlap on the same logit scale?" Use
  `plot(fit, type = "wright")` or
  [`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md).

- "Where do score categories transition across theta?" Use
  `plot(fit, type = "pathway")` and `plot(fit, type = "ccc")`.

- "Is the design linked well enough across subsets or administrations?"
  Use `plot(subset_connectivity_report(...), type = "design_matrix")`,
  [`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md),
  [`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md),
  `plot(..., type = "network")`, and
  [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md).

- "Which responses or levels look locally problematic?" Use
  [`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md)
  and
  [`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md).

- "Which facet/category cells drive strict marginal misfit?" Use
  [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md).

- "Which level pairs drive strict local-dependence follow-up?" Use
  [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md).

- "Do raters agree and do facets separate meaningfully?" Use
  [`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md),
  [`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md),
  and
  [`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md).

- "Do criteria within the same rater move together in a halo-like way?"
  Use
  [`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
  and `plot(..., type = "edge_distribution")`.

- "Is there notable residual structure after the main Rasch dimension?"
  Use
  [`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md).

- "Which interaction cells or facet levels drive bias screening
  results?" Use
  [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md).

- "Which group-by-facet contrasts drive DFF / DIF screening results?"
  Use
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md)
  and
  [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md)
  after
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).

- "Do person response rows follow the expected Guttman-style ordering
  once persons and items are sorted on the logit scale?" Use
  [`plot_guttman_scalogram()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_guttman_scalogram.md)
  as a teaching-oriented screen.

- "Do person-level standardized residuals look Gaussian, or are there
  heavy tails that warrant follow-up?" Use
  [`plot_residual_qq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_qq.md).

- "Is rater severity drifting across waves or training sessions
  (assuming the waves are already on a common anchored scale)?" Use
  [`plot_rater_trajectory()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_trajectory.md)
  together with
  [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md)
  for the linking-scale review.

- "I have many raters and want a compact pairwise agreement /
  correlation overview instead of the bar chart?" Use
  [`plot_rater_agreement_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_agreement_heatmap.md).

- "Do response times suggest rapid responding, slow responding, or
  timing patterns by person, facet, or score category?" Use
  [`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
  and
  [`plot_response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_response_time_review.md)
  as a descriptive QC layer outside the MFRM likelihood.

- "Are there pairs of facet levels whose residuals co-move beyond the
  main-effects MFRM? (Q3-style local-dependence screen)" Use
  [`plot_local_dependence_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_local_dependence_heatmap.md).

- "How distinguishable is each facet on a single page (separation,
  strata, reliability)?" Use
  [`plot_reliability_snapshot()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_reliability_snapshot.md).

- "Where do persons with the largest residual aggregates accumulate
  across facet levels?" Use
  [`plot_residual_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_matrix.md).

- "How much did empirical-Bayes shrinkage move each facet level?" Use
  [`plot_shrinkage_funnel()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_shrinkage_funnel.md)
  on a fit augmented via
  [`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md).

- "I need one compact triage screen first." Use
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
  for `RSM` / `PCM`. The bounded `GPCM` branch can also call
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
  but its fair-average panel reports an explicit unavailability
  indicator because that panel's score-metric semantics have not yet
  been generalized beyond the Rasch-family branch.

- "Which figures are already supported by my current run?" Use
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  and review the `"Visual Displays"` rows before choosing the next plot.

- "Where should this figure go in a paper or appendix?" Use
  [`visual_reporting_template()`](https://ryuya-dot-com.github.io/mfrmr/reference/visual_reporting_template.md)
  for a static reporting-use table, then cross-check run-specific
  availability with `reporting_checklist()$visual_scope`.

- "Do I need a 3D-style category probability surface?" Use
  `plot(fit, type = "ccc_surface", draw = FALSE)` to get
  theta-by-category-by-probability plot data for exploratory teaching or
  downstream interactive rendering. Keep 2D pathway/CCC plots as the
  default reporting figures.

## Recommended visual route

1.  If you are drafting a report, run
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    first and read the `"Visual Displays"` rows as the plot-readiness
    layer.

2.  Start with
    [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
    for one-page triage.

3.  Move to
    [`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
    [`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
    [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md),
    [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md),
    and
    [`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md)
    for flagged local issues.

4.  Use `plot(fit, type = "wright")`, `plot(fit, type = "pathway")`, and
    [`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md)
    for structural interpretation.

5.  Use
    [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md),
    [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
    [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md),
    [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md),
    and
    [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)
    when the checklist or dashboard points to interaction,
    differential-functioning, linking, or precision follow-up.

6.  Use `plot(..., draw = FALSE)` when you want reusable plot data
    instead of immediate graphics.

7.  Use `plot(fit, type = "ccc_surface", draw = FALSE)` only when you
    need 3D-ready category-probability data; `mfrmr` intentionally does
    not add a package-native plotly/rgl renderer for this route.

8.  Use `preset = "publication"` when you want the package's cleaner
    manuscript-oriented styling, or `preset = "monochrome"` when
    journals, accessibility requirements, or print workflows require
    grayscale output.

## Customizing figures

The package's plotting defaults are intended to be safe starting points,
not a closed graphics system. Use `preset = "publication"` for clean
manuscript defaults, or `preset = "monochrome"` for grayscale output
that relies more on line type, point shape, and reference lines than on
color. Use `plot(..., draw = FALSE)` when you want the reusable
`mfrm_plot_data` object instead of immediate base graphics. Then call
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md)
to see available components and
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to extract the long tables used by the plot.

Custom renderers should keep the returned metadata close to the figure:
`reference_lines`, `legend`, `guidance`, `category_support`,
`interpretation_guide`, and any reporting-template rows are part of the
interpretation contract. They let users change colors, labels, panels,
or rendering technology without losing the measurement scale, caveats,
and caption boundary attached to the package-native plot.

## Visual coverage for this release

This release treats the plotting layer as sufficient when the current
run supports all of the following follow-up roles through public
helpers:

- First-pass triage:
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
  or the `"Visual Displays"` rows from
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).

- Structural interpretation: `plot(fit, type = "wright")`,
  `plot(fit, type = "pathway")`, `plot(fit, type = "ccc")`, and
  [`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md).

- Local issue follow-up:
  [`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
  [`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
  [`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md),
  [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md),
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
  and
  [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md).

- Strict marginal follow-up:
  [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md)
  and
  [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)
  for `diagnostic_mode = "both"`.

- Reporting/export handoff:
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
  and `draw = FALSE` routes that return reusable `mfrm_plot_data`
  objects for downstream review and export. When step estimates are
  available,
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
  also exposes `$plot_payloads$category_probability_surface`.

- 3D-ready exploratory handoff:
  `plot(fit, type = "ccc_surface", draw = FALSE)` returns a
  theta-by-category-by-probability `mfrm_plot_data` object. This is not
  a default APA/reporting figure and does not load plotly/rgl.

## 3D and surface data

The package currently treats 3D as an exploratory data handoff, not as a
default plotting layer. The supported route is
`plot(fit, type = "ccc_surface", draw = FALSE)`, which returns
`surface`, `categories`, `category_support`, `groups`, `axis_contract`,
`renderer_contract`, `interpretation_guide`, and `reporting_policy`
tables inside an `mfrm_plot_data` object. These columns can be passed to
an external renderer if needed, while `category_support` and
`interpretation_guide` should be checked before interpreting retained
zero-frequency categories or adjacent threshold ridges.

Do not replace the standard 2D Wright map, pathway map, CCC plot,
heatmap/profile diagnostics, or information curves with 3D figures in
routine reports. In particular, 3D Wright maps are discouraged because
perspective and occlusion obscure the shared-scale comparison that the
Wright map is meant to support.

## Which plot answers which question

- `plot(fit, type = "wright")`:

  Shared logit map of persons, facet levels, and step thresholds. Best
  for targeting and spread.

- `plot(fit, type = "pathway")`:

  Expected score by theta, with dominant-category strips. Best for scale
  progression.

- `plot(fit, type = "ccc")`:

  Category probability curves. Best for checking whether categories peak
  in sequence.

- [`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md):

  Observation-level surprises. Best for case review and local misfit
  triage.

- [`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md):

  Level-wise anchor movement. Best for anchor robustness and residual
  calibration tension.

- [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md):

  Posterior-integrated first-order category residuals. Best for seeing
  which facet/category cells drive strict marginal flags.

- [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md):

  Posterior-integrated exact/adjacent agreement residuals. Best for
  exploratory local-dependence follow-up after strict marginal flags.

- [`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md):

  Exact agreement, expected agreement, pairwise correlation, and
  agreement gaps. Best for rater consistency.

- [`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md):

  Facet variability and chi-square summaries. Best for checking whether
  a facet contributes meaningful spread.

- [`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md):

  Residual structure after the Rasch dimension is removed. Best for
  exploratory residual-structure review, not as a standalone
  unidimensionality test.

- [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md):

  Interaction-bias screening views for cells and facet profiles. Best
  for systematic departure from the additive main-effects model.

- [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md)
  /
  [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md):

  DFF / DIF screening views for facet-level x group contrasts. Best for
  showing which facet and group pair is involved before writing
  substantive interpretations.

- [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md):

  Anchor drift and screened linking-chain visuals. Best for multi-form
  or multi-wave linking review after checking retained common-element
  support.

- [`plot_guttman_scalogram()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_guttman_scalogram.md):

  Person x facet-level response matrix with unexpected-response overlay.
  Best for teaching-oriented scalogram intuition and visual triage of
  where the data depart from the expected ordering.

- [`plot_residual_qq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_qq.md):

  Normal Q-Q plot of person-level standardized residual aggregates. Best
  for checking the tail behavior of residuals as exploratory follow-up
  after a fit screen.

- [`plot_rater_trajectory()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_trajectory.md):

  Per-rater severity trajectory across named waves / occasions. Best for
  rater-training or drift feedback when the supplied fits have already
  been placed on a common anchored scale; the helper itself does not
  perform linking.

- [`plot_rater_agreement_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_agreement_heatmap.md):

  Compact pairwise rater x rater heatmap of exact agreement (default) or
  Pearson-style correlation. Best when the rater count makes the
  bar-chart form of
  [`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md)
  too busy.

- [`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
  /
  [`plot_response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_response_time_review.md):

  Descriptive response-time screening by person, facet, and score
  category. Best for reviewing rapid/slow response patterns alongside
  MFRM diagnostics; it is not a joint speed-accuracy model and does not
  change fitted measures.

- [`plot_local_dependence_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_local_dependence_heatmap.md):

  Yen Q3-style heatmap of pairwise residual correlations between facet
  levels. Best for exploratory local-dependence screening; pairs with
  very strong off-diagonal residual correlation merit content-level
  review.

- [`plot_reliability_snapshot()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_reliability_snapshot.md):

  One-figure facet x reliability / separation / strata bar overview
  built from `diagnostics$reliability`. Best as a single small figure
  for "which facets are statistically distinguishable?".

- [`plot_residual_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_matrix.md):

  Person x facet-level standardized residual heatmap. Best as a
  follow-up to
  [`plot_guttman_scalogram()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_guttman_scalogram.md)
  when the residual sign and magnitude matter, not just the response
  code.

- [`plot_shrinkage_funnel()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_shrinkage_funnel.md):

  Empirical-Bayes shrinkage caterpillar / funnel showing raw versus
  shrunken facet estimates. Best on fits produced via
  [`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md)
  for reviewing how much each level moved under the prior.

## Cross-reference to FACETS / Winsteps tables

For users coming from the standard Rasch-measurement software packages,
the closest mfrmr helper for each table or figure family is summarised
below. The mapping is approximate; mfrmr is designed for many-facet
workflows, so column subsets and column names differ.

- Wright (variable) map:

  `plot(fit, type = "wright")` and
  [`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md)
  correspond to FACETS Table 6 / Winsteps "Person-Item map".

- Pathway / probability curves:

  `plot(fit, type = "pathway")` and `plot(fit, type = "ccc")` correspond
  to Winsteps Table 21 ("Probability category curves") and FACETS
  category-probability curves.

- Test / item information:

  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md) +
  [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)
  correspond to Winsteps Table 17 ("Test characteristic curve, test
  information function").

- Misfit / Infit / Outfit:

  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  and the Largest \|ZSTD\| / MnSq misfit blocks of `summary(diag)`
  correspond to Winsteps Table 10/13/14 (Misfit order) and FACETS Tables
  7/8.

- Bias / interaction:

  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md) +
  [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)
  correspond to FACETS Table 14 ("Bias / Interaction calibration
  report").

- Differential rater / item functioning:

  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  /
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md) +
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md)
  /
  [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md)
  cover the FACETS DIF / bias-by-group route and the Winsteps DIF (Table
  30 group differences) report.

- Inter-rater agreement:

  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md) +
  [`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md)
  /
  [`plot_rater_agreement_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_agreement_heatmap.md)
  correspond to FACETS Table 7-style observed-vs-expected agreement
  reports.

- Anchoring / linking:

  [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md)
  and
  [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)
  cover the FACETS / Winsteps anchored-run review route; full
  equating-chain helpers are exposed via
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md).

## Practical interpretation rules

- Wright map: look for gaps between person density and facet/step
  locations; large gaps indicate weaker targeting.

- Pathway / CCC: look for monotone progression and clear category
  dominance bands; flat or overlapping curves suggest weak category
  separation.

- 3D-ready category surface: use as an exploratory view of the same
  category-probability information, not as a replacement for the 2D
  pathway/CCC figures in reports. Read `category_support` first when a
  retained category has zero observed responses.

- Unexpected / displacement: use as screening tools, not final evidence
  by themselves.

- Strict marginal and pairwise local-dependence plots are exploratory
  follow-up layers for `diagnostic_mode = "both"`, not standalone
  inferential tests.

- Inter-rater agreement and facet variability address different
  questions: agreement concerns scoring consistency, whereas variability
  concerns whether facet elements are statistically distinguishable.

- Residual PCA and bias plots should be interpreted as follow-up layers
  after the main fit screen, not as first-pass diagnostics.

- DFF residual-method plots are screening visuals. ETS A/B/C labels
  should be claimed only for rows whose refit output reports
  `ClassificationSystem == "ETS"`.

## Typical workflow

- Figure-readiness route:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  -\> inspect `"Visual Displays"` rows -\> chosen public plot helper.

- Quick screening:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md).

- Strict marginal follow-up:
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  with `diagnostic_mode = "both"` -\>
  [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md)
  -\>
  [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md).

- Scale and targeting review: `plot(fit, type = "wright")` -\>
  `plot(fit, type = "pathway")` -\> `plot(fit, type = "ccc")`.

- Linking review:
  [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
  -\> `plot(..., type = "design_matrix")` /
  [`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md)
  /
  [`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md)
  / `plot(..., type = "network")` -\>
  [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md).

- Interaction review:
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  -\>
  [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)
  -\>
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).

- DFF / DIF review:
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  -\>
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md)
  /
  [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md)
  -\> inspect the explicit facet, level, and group-pair columns before
  writing interpretation.

## Companion vignette

For a longer, plot-first walkthrough, run
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## See also

[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md),
[gpcm_capability_matrix](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[`visual_reporting_template()`](https://ryuya-dot-com.github.io/mfrmr/reference/visual_reporting_template.md),
[`mfrmr_interval_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_interval_guide.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
[`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
[`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md),
[`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md),
[`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md),
[`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md),
[`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md),
[`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md),
[`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
[`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md),
[`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md),
[`plot_guttman_scalogram()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_guttman_scalogram.md),
[`plot_residual_qq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_qq.md),
[`plot_rater_trajectory()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_trajectory.md),
[`plot_rater_agreement_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_agreement_heatmap.md),
[`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md),
[`plot_response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_response_time_review.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
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
checklist <- reporting_checklist(fit, diagnostics = diag)
visual_reporting_template("manuscript")
subset(
  checklist$checklist,
  Section == "Visual Displays" & Item %in% c("QC / facet dashboard", "Strict marginal visuals"),
  c("Item", "Available", "NextAction")
)

qc <- plot_qc_dashboard(fit, diagnostics = diag, draw = FALSE, preset = "publication")
qc$data$plot

p_marg <- plot_marginal_fit(diag, draw = FALSE, preset = "publication")
p_marg$data$preset

wright <- plot(fit, type = "wright", draw = FALSE, preset = "publication")
wright$data$preset

pca <- analyze_residual_pca(diag, mode = "overall")
scree <- plot_residual_pca(pca, plot_type = "scree", draw = FALSE, preset = "publication")
scree$data$preset
} # }
```
