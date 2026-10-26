# Plotting after the 0.2.4 API consolidation

Use [`plot()`](https://rdrr.io/r/graphics/plot.default.html) on a fitted
model or an analysis result. The 33 former drawing helpers are no longer
exported in 0.2.4. This is a breaking API change: replace old `plot_*()`
calls using the table below. Their numerical/drawing implementations
remain internal; do not depend on `mfrmr:::` access. The public data
accessors
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
and
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md)
remain.

## Choosing an input

Use a fitted ordinary model for fit-level views. Use saved G/D studies,
information, DIF/DFF, bias, QC or PCA results for their own
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods. Their
public help pages explain the view controls, returned tables and
interpretation:
[`plot.mfrm_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_information.md),
[`plot.mfrm_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_dif.md),
[`plot.mfrm_dif_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_dif_interaction.md),
[`plot.mfrm_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_anchor_drift.md),
[`plot.mfrm_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_qc_pipeline.md),
[`plot.mfrm_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bias.md),
[`plot.mfrm_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_residual_pca.md)
and
[`plot.mfrm_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_diagnostics.md).
[`plot.mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_population_intervals.md)
adds saved latent-regression coefficients and contrasts. Start with
these pages for saved results. A common function name does not make
every view available for every model. Two-family GPCM and corrected JML
retain their separate supported result routes. Plotting does not add
intervals, repair unavailable values or equate scales. Use original
result objects rather than unclassed lists or CSV tables.

## Single-fit views

`plot(fit)` still draws the ordinary Wright map. New `type` choices
include `reliability`, `agreement`, `person_fit`, `rater_severity`,
`thresholds`, `residual_qq`, `residual_matrix`, `residual_pca`,
`local_dependence`, `marginal_fit`, `marginal_pairwise`, `fair_average`,
`displacement`, `facets_chisq`, `bubble`, `guttman`, `unexpected`, `qc`,
`apa_summary`, `bias`, `facet_equivalence` and `facet_dashboard`.

Use `metric` for the quantity and `view` for a display variant.
Reliability accepts `reliability`, `separation` or `strata`. Agreement
accepts `exact` or `correlation`, with `view = "pairs"` (default) or
`"heatmap"`; `metric = "difference"` applies only to pairs. Severity
separation is not agreement. The former `plot_type` argument becomes
`view` for marginal fit, fair averages, displacement, facet chi-square,
unexpected ratings and facet dashboards. Keep other named controls from
the legacy parameter help.

Explicit controls are passed only to the chosen renderer; omitted
controls retain that renderer's defaults. Inapplicable and conflicting
controls are rejected. Supply matching saved `diagnostics` for repeated
fit-level views. Some legacy fit-level convenience routes compute
diagnostics when omitted; this does not imply model refitting.
Saved-result plots reuse their results.

## Replacement table

In the table, `x` is the former first argument, including its original
result class. For paired models use `reference` and `comparison`. For an
ordered trajectory, `fits` is the existing named list of fitted models.

|  |  |
|----|----|
| Former exported helper | Replacement |
| [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md) | `plot(x)` |
| [`plot_apa_figure_one()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_apa_figure_one.md) | `plot(x, type = "apa_summary")` |
| [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md) | `plot(x, type = "bias")` |
| [`plot_bubble()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bubble.md) | `plot(x, type = "bubble")` |
| [`plot_compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_compare_mfrm.md) | `plot(reference, comparison = comparison)` |
| [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md) | `plot(x, type = "heatmap")` |
| [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md) | `plot(x, type = "summary")` |
| [`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md) | `plot(x, type = "displacement")` |
| [`plot_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_equivalence.md) | `plot(x, type = "facet_equivalence")` |
| [`plot_facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_quality_dashboard.md) | `plot(x, type = "facet_dashboard")` |
| [`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md) | `plot(x, type = "facets_chisq")` |
| [`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md) | `plot(x, type = "fair_average")` |
| [`plot_guttman_scalogram()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_guttman_scalogram.md) | `plot(x, type = "guttman")` |
| [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md) | `plot(x)` |
| [`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md) | `plot(x, type = "agreement")` |
| [`plot_local_dependence_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_local_dependence_heatmap.md) | `plot(x, type = "local_dependence")` |
| [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md) | `plot(x, type = "marginal_fit")` |
| [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md) | `plot(x, type = "marginal_pairwise")` |
| [`plot_person_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_person_fit.md) | `plot(x, type = "person_fit")` |
| [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md) | `plot(x, type = "qc")` |
| [`plot_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_pipeline.md) | `plot(x)` |
| [`plot_rater_agreement_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_agreement_heatmap.md) | `plot(x, type = "agreement", view = "heatmap")` |
| [`plot_rater_severity_profile()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_severity_profile.md) | `plot(x, type = "rater_severity")` |
| [`plot_rater_trajectory()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_trajectory.md) | `plot((fits)[[1L]], type = "trajectory", comparison = (fits)[-1L], labels = names(fits))` |
| [`plot_reliability_snapshot()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_reliability_snapshot.md) | `plot(x, type = "reliability")` |
| [`plot_residual_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_matrix.md) | `plot(x, type = "residual_matrix")` |
| [`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md) | `plot(x, type = "residual_pca")` |
| [`plot_residual_qq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_qq.md) | `plot(x, type = "residual_qq")` |
| [`plot_response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_response_time_review.md) | `plot(x)` |
| [`plot_shrinkage_funnel()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_shrinkage_funnel.md) | `plot(x, type = "shrinkage", view = "funnel")` |
| [`plot_threshold_ladder()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_threshold_ladder.md) | `plot(x, type = "thresholds")` |
| [`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md) | `plot(x, type = "unexpected")` |
| [`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md) | `plot(x, type = "wright", view = "unified")` |

For result objects the object determines the target: for example
`plot(info, type = "iif", facet = "Rater")` or
`plot(dif, type = "heatmap", metric = "contrast")`. For the fit
convenience routes, rename the old bias `plot` argument to `view`;
rename the old equivalence `type` to `view`. For residual PCA rename
`plot_type` to `view` with `type = "residual_pca"`, or use
`plot(pca, type = "loadings")` directly on a saved PCA result.

## Multiple models and occasions

Use `plot(reference, comparison = other, type = "ccc")` or
`type = "wright"` for paired displays; `view = "difference"` shows
differences without adding difference SEs or model-selection tests. For
trajectories use
`plot(fits[[1]], type = "trajectory", comparison = fits[-1], labels = names(fits))`.
Labels include the first model, and the supplied order is retained.
Models must already be placed on an interpretable common scale; plotting
performs no linking.

## Returned data and appearance

Use `draw = FALSE` to obtain the existing payload without drawing. Most
routes return `mfrm_plot_data`; the QC pipeline retains its
verdict-table return, and native interval routes retain their existing
ggplot results. Return classes have not been homogenized. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for supported payloads and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
only for supported conversions. Unsupported conversions do not become
available through this API change. Titles and cautions stay outside
figures by default; keep returned notes when exporting. G/D plots retain
their existing color, monochrome, score and facet-panel controls. Save
full result objects for later plotting.

## See also

[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)
