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
if (FALSE) { # \dontrun{
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
summary(vis)
p <- plot(vis, type = "comparison", draw = FALSE)
p2 <- plot(vis, type = "warning_counts", draw = FALSE)
vis$plot_payloads$comparison$data$plot
vis$public_plot_routes[, c("Visual", "PlotHelper", "DrawFreeRoute")]
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
} # }
```
