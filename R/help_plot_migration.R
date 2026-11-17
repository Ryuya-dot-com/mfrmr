#' @section Former 0.2.4 plot helper replacements:
#' In 0.3.0, every `plot()` S3 method renders with `ggplot2` and invisibly
#' returns a `ggplot` object (`draw = FALSE` suppresses device output; extract
#' underlying tables and notes with [plot_data()] and [plot_data_components()]).
#' Replace the 33 former `plot_*()` helpers with `plot()` on the corresponding
#' fitted model or analysis result:
#'
#' | Former exported helper | Replacement |
#' | --- | --- |
#' | `plot_anchor_drift()` | `plot(x)` |
#' | `plot_apa_figure_one()` | `plot(x, type = "apa_summary")` |
#' | `plot_bias_interaction()` | `plot(x, type = "bias")` |
#' | `plot_bubble()` | `plot(x, type = "bubble")` |
#' | `plot_compare_mfrm()` | `plot(reference, comparison = comparison)` |
#' | `plot_dif_heatmap()` / `plot_dif_summary()` | `plot(x, type = "heatmap")` / `plot(x, type = "summary")` |
#' | `plot_displacement()` | `plot(x, type = "displacement")` |
#' | `plot_facet_equivalence()` | `plot(x, type = "facet_equivalence")` |
#' | `plot_facet_quality_dashboard()` | `plot(x, type = "facet_dashboard")` |
#' | `plot_facets_chisq()` | `plot(x, type = "facets_chisq")` |
#' | `plot_fair_average()` | `plot(x, type = "fair_average")` |
#' | `plot_guttman_scalogram()` | `plot(x, type = "guttman")` |
#' | `plot_information()` | `plot(x)` |
#' | `plot_interrater_agreement()` | `plot(x, type = "agreement")` |
#' | `plot_local_dependence_heatmap()` | `plot(x, type = "local_dependence")` |
#' | `plot_marginal_fit()` / `plot_marginal_pairwise()` | `plot(x, type = "marginal_fit")` / `type = "marginal_pairwise"` |
#' | `plot_person_fit()` | `plot(x, type = "person_fit")` |
#' | `plot_qc_dashboard()` / `plot_qc_pipeline()` | `plot(x, type = "qc")` / `plot(x)` |
#' | `plot_rater_agreement_heatmap()` | `plot(x, type = "agreement", view = "heatmap")` |
#' | `plot_rater_severity_profile()` | `plot(x, type = "rater_severity")` |
#' | `plot_rater_trajectory()` | `plot(fits[[1L]], type = "trajectory", comparison = fits[-1L], labels = names(fits))` |
#' | `plot_reliability_snapshot()` | `plot(x, type = "reliability")` |
#' | `plot_residual_matrix()` / `plot_residual_pca()` / `plot_residual_qq()` | `plot(x, type = "residual_matrix")` / `"residual_pca"` / `"residual_qq"` |
#' | `plot_response_time_review()` | `plot(x)` |
#' | `plot_shrinkage_funnel()` | `plot(x, type = "shrinkage", view = "funnel")` |
#' | `plot_threshold_ladder()` | `plot(x, type = "thresholds")` |
#' | `plot_unexpected()` | `plot(x, type = "unexpected")` |
#' | `plot_wright_unified()` | `plot(x, type = "wright", view = "unified")` |
#'
#' @aliases mfrmr_plot_migration
#' @rdname mfrmr_api_migration_030
#' @name mfrmr_plot_migration
NULL
