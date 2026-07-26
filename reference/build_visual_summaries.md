# Build warning and narrative summaries for visual outputs

Build warning and narrative summaries for visual outputs

## Usage

``` r
build_visual_summaries(
  fit,
  diagnostics,
  threshold_profile = "standard",
  thresholds = NULL,
  summary_options = NULL,
  whexact = FALSE,
  branch = c("original", "facets")
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- threshold_profile:

  Threshold profile name (`strict`, `standard`, `lenient`).

- thresholds:

  Optional named overrides for profile thresholds.

- summary_options:

  Summary options for `build_visual_summary_map()`.

- whexact:

  Use exact ZSTD transformation.

- branch:

  Output branch: `"facets"` adds FACETS crosswalk metadata for
  manual-aligned reporting; `"original"` keeps package-native summary
  output.

## Value

An object of class `mfrm_visual_summaries` with:

- `warning_map`: visual-level warning text vectors

- `summary_map`: visual-level descriptive text vectors

- `warning_counts`, `summary_counts`: message counts by visual key

- `plot_payloads`: reusable draw-free `mfrm_plot_data` objects for
  `comparison`, `warning_counts`, `summary_counts`, and optionally
  `category_probability_surface`

- `public_plot_routes`: public helper / draw-free route map for
  follow-up

- `crosswalk`: FACETS-reference mapping for main visual keys

- `branch`, `style`, `threshold_profile`: branch metadata

## Details

This function returns visual-keyed text maps to support dashboard/report
rendering without hard-coding narrative strings in UI code.

`thresholds` can override any profile field by name. Common overrides:

- `n_obs_min`, `n_person_min`

- `misfit_ratio_warn`, `zstd2_ratio_warn`, `zstd3_ratio_warn`

- `pca_first_eigen_warn`, `pca_first_prop_warn`

`summary_options` supports:

- `detail`: `"standard"` or `"detailed"`

- `max_facet_ranges`: max facet-range snippets shown in visual summaries

- `top_misfit_n`: number of top misfit entries included

For bounded `GPCM`, this helper returns caveated warning/summary maps
over supported diagnostics, direct tables, and plots. The returned
object includes `gpcm_boundary` so score-side, design-forecasting, DFF,
and linking routes remain visibly separate capability rows.

## Interpreting output

- `warning_map`: rule-triggered warning text by visual key.

- `summary_map`: descriptive narrative text by visual key.

- strict marginal keys appear when
  `diagnose_mfrm(..., diagnostic_mode = "both")` supplies
  latent-integrated first-order and pairwise screening summaries.

- `warning_counts` / `summary_counts`: message-count tables for QA
  checks.

- `plot_payloads`: ready-to-reuse `mfrm_plot_data` objects for the
  bundle's own comparison/count plots and, when step estimates are
  available, the exploratory `category_probability_surface` data from
  `plot(fit, type = "ccc_surface", draw = FALSE)`. The surface data
  carry `category_support`, `interpretation_guide`, and
  `reporting_policy` tables for zero-frequency category and
  reporting-boundary checks.

- `public_plot_routes`: draw-free helper routes for the dedicated public
  plot functions behind each visual family.

## Typical workflow

1.  inspect defaults with
    [`mfrm_threshold_profiles()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_threshold_profiles.md)

2.  choose `threshold_profile` (`strict` / `standard` / `lenient`)

3.  optionally override selected fields via `thresholds`

4.  pass result maps to report/dashboard rendering logic

## See also

[`mfrm_threshold_profiles()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_threshold_profiles.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md),
[`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", model = "RSM", quad_points = 7, maxit = 30
)
diag <- diagnose_mfrm(fit, residual_pca = "both", diagnostic_mode = "both")
vis <- build_visual_summaries(fit, diag, threshold_profile = "strict")
vis2 <- build_visual_summaries(
  fit,
  diag,
  threshold_profile = "standard",
  thresholds = c(misfit_ratio_warn = 0.20, pca_first_eigen_warn = 2.0),
  summary_options = list(detail = "detailed", top_misfit_n = 5)
)
vis_facets <- build_visual_summaries(fit, diag, branch = "facets")
vis_facets$branch
#> [1] "facets"
summary(vis)
#> mfrmr Visual Summary Bundle
#> 
#> Overview
#>    Branch    Style ThresholdProfile WarningVisuals SummaryVisuals
#>  original original           strict             13             13
#> 
#> Warning counts
#>                            Visual Messages
#>              residual_pca_overall        5
#>             residual_pca_by_facet        4
#>               strict_marginal_fit        3
#>  strict_pairwise_local_dependence        2
#>                        wright_map        1
#>                   category_curves        0
#>                facet_distribution        0
#>                   fit_diagnostics        0
#>             fit_zstd_distribution        0
#>                     misfit_levels        0
#>                 observed_expected        0
#>                       pathway_map        0
#>                   step_thresholds        0
#> 
#> Summary counts
#>                            Visual Messages
#>              residual_pca_overall        5
#>               strict_marginal_fit        5
#>             residual_pca_by_facet        4
#>  strict_pairwise_local_dependence        4
#>                        wright_map        4
#>                   category_curves        2
#>             fit_zstd_distribution        2
#>                 observed_expected        2
#>                       pathway_map        2
#>                   step_thresholds        2
#>                facet_distribution        1
#>                   fit_diagnostics        1
#>                     misfit_levels        1
#> 
#> FACETS crosswalk
#>                            Visual
#>                        unexpected
#>                      fair_average
#>                      displacement
#>                        interrater
#>                      facets_chisq
#>               strict_marginal_fit
#>  strict_pairwise_local_dependence
#>              residual_pca_overall
#>             residual_pca_by_facet
#>      category_probability_surface
#>                                                                       FACETS
#>                                                           Table 4 / Table 10
#>                                                                     Table 12
#>                                                                      Table 9
#>                                                          Inter-rater outputs
#>                                                Facet fixed/random chi-square
#>          No direct FACETS equivalent (package-native strict marginal screen)
#>          No direct FACETS equivalent (package-native strict pairwise screen)
#>                                                       Residual PCA (overall)
#>                                                      Residual PCA (by facet)
#>  No direct FACETS equivalent (exploratory category-probability surface data)
#> 
#> Public plot routes
#>                            Visual                  PlotHelper
#>                        comparison          plot.mfrm_bundle()
#>                    warning_counts          plot.mfrm_bundle()
#>                    summary_counts          plot.mfrm_bundle()
#>                        unexpected           plot_unexpected()
#>                      fair_average         plot_fair_average()
#>                      displacement         plot_displacement()
#>                        interrater plot_interrater_agreement()
#>                      facets_chisq         plot_facets_chisq()
#>               strict_marginal_fit         plot_marginal_fit()
#>  strict_pairwise_local_dependence    plot_marginal_pairwise()
#>                                                                                        DrawFreeRoute
#>                                                         plot(vis, type = "comparison", draw = FALSE)
#>                                                     plot(vis, type = "warning_counts", draw = FALSE)
#>                                                     plot(vis, type = "summary_counts", draw = FALSE)
#>             plot_unexpected(unexpected_response_table(fit, diagnostics = diagnostics), draw = FALSE)
#>                  plot_fair_average(fair_average_table(fit, diagnostics = diagnostics), draw = FALSE)
#>                  plot_displacement(displacement_table(fit, diagnostics = diagnostics), draw = FALSE)
#>  plot_interrater_agreement(interrater_agreement_table(fit, diagnostics = diagnostics), draw = FALSE)
#>                  plot_facets_chisq(facets_chisq_table(fit, diagnostics = diagnostics), draw = FALSE)
#>                                                         plot_marginal_fit(diagnostics, draw = FALSE)
#>                                                    plot_marginal_pairwise(diagnostics, draw = FALSE)
#>  PlotReturnClass                         Scope
#>   mfrm_plot_data               bundle overview
#>   mfrm_plot_data               bundle overview
#>   mfrm_plot_data               bundle overview
#>   mfrm_plot_data unexpected-response follow-up
#>   mfrm_plot_data        fair-average follow-up
#>   mfrm_plot_data        displacement follow-up
#>   mfrm_plot_data         inter-rater follow-up
#>   mfrm_plot_data    facet chi-square follow-up
#>   mfrm_plot_data     strict marginal follow-up
#>   mfrm_plot_data     strict pairwise follow-up
#> 
#> Notes
#>  - Original branch keeps package-native warning/summary map organization.
#>  - Reusable draw-free plot data are available in `plot_payloads`: comparison, warning_counts, summary_counts, category_probability_surface.
p <- plot(vis, type = "comparison", draw = FALSE)
p2 <- plot(vis, type = "warning_counts", draw = FALSE)
vis$plot_payloads$comparison$data$plot
#> [1] "comparison"
vis$public_plot_routes[, c("Visual", "PlotHelper", "DrawFreeRoute")]
#> # A tibble: 13 × 3
#>    Visual                           PlotHelper                  DrawFreeRoute   
#>    <chr>                            <chr>                       <chr>           
#>  1 comparison                       plot.mfrm_bundle()          "plot(vis, type…
#>  2 warning_counts                   plot.mfrm_bundle()          "plot(vis, type…
#>  3 summary_counts                   plot.mfrm_bundle()          "plot(vis, type…
#>  4 unexpected                       plot_unexpected()           "plot_unexpecte…
#>  5 fair_average                     plot_fair_average()         "plot_fair_aver…
#>  6 displacement                     plot_displacement()         "plot_displacem…
#>  7 interrater                       plot_interrater_agreement() "plot_interrate…
#>  8 facets_chisq                     plot_facets_chisq()         "plot_facets_ch…
#>  9 strict_marginal_fit              plot_marginal_fit()         "plot_marginal_…
#> 10 strict_pairwise_local_dependence plot_marginal_pairwise()    "plot_marginal_…
#> 11 residual_pca_overall             plot_residual_pca()         "plot_residual_…
#> 12 residual_pca_by_facet            plot_residual_pca()         "plot_residual_…
#> 13 category_probability_surface     plot.mfrm_fit()             "plot(fit, type…
if (interactive()) {
  plot(
    vis,
    type = "comparison",
    draw = TRUE,
    main = "Warning vs Summary Counts (Customized)",
    palette = c(warning = "#cb181d", summary = "#3182bd"),
    label_angle = 45
  )
}
# }
```
