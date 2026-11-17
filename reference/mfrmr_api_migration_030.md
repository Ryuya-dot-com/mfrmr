# Fewer public entry points and unified ggplot2 graphics in 0.3.0

Related operations now use arguments or standard S3 methods, and all
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods render
and return `ggplot2` objects directly. Because overlapping entry points
are no longer exported and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns a
`ggplot` object rather than `mfrm_plot_data` / base graphics, version
0.3.0 uses a minor-version increment under semantic versioning: review
existing 0.2.x scripts when updating to 0.3.0. Existing saved result
classes retain their [`summary()`](https://rdrr.io/r/base/summary.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
methods.

## Usage

``` r
compatibility_alias_table(
  scope = c("all", "functions", "arguments", "fields", "columns", "plot_metrics")
)
```

## Arguments

- scope:

  Which alias surface to return in `compatibility_alias_table()`:
  `"all"`, `"functions"`, `"arguments"`, `"fields"`, `"columns"`, or
  `"plot_metrics"`.

## Value

`compatibility_alias_table()` returns a `data.frame` with columns
`Alias`, `PreferredName`, `Surface`, `Lifecycle` (`"retained_alias"` or
`"removed_export"`), `RetainedFor`, `RemovalPlan`, and `Notes`.

## Default route guide

[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)
now returns the five central routes, matching `scope = "core_workflow"`.
Use `mfrmr_output_guide("all")` where a script needs the former full
catalogue. Explicit scopes, including the six-row `"public"` and
`"beginner"` routes, retain their meanings and columns.

## Replacements

|  |  |
|----|----|
| Former entry | Current call |
| `automated_scoring_table(automated, human, ...)` | `score_comparison_table(scores, reference, ..., screen = "williamson2012")` |
| `facet_statistics_report(fit, ...)` | `mfrm_report(fit, type = "facet_statistics", ...)` |
| `precision_review_report(fit, ...)` | `mfrm_report(fit, type = "precision", ...)` |
| `bias_iteration_report(x, ...)` | `mfrm_report(x, type = "bias_iterations", ...)` |
| `bias_pairwise_report(x, ...)` | `mfrm_report(x, type = "bias_pairwise", ...)` |
| `dif_report(dif_result)` | `mfrm_report(dif_result, type = "dff")` |
| `reporting_checklist(fit, ...)` | `mfrm_report(fit, type = "checklist", ...)` |
| `reference_case_review(fit, ...)` | `mfrm_report(fit, type = "reference_review", ...)` |
| `estimation_iteration_report(fit, ...)` | `mfrm_report(fit, type = "iterations", ...)` |
| `bias_interaction_report(x, ...)` | `mfrm_report(x, type = "bias_interaction", ...)` |
| `mfrm_multivariate_d_compare(d, ...)` | `compare_mfrm(d, ...)` |
| `specifications_report(fit, ...)` | `mfrm_report(fit, type = "specifications", ...)` |
| `data_quality_report(fit, ...)` | `mfrm_report(fit, type = "data_quality", ...)` |
| `category_structure_report(fit, ...)` | `mfrm_report(fit, type = "category_structure", ...)` |
| `category_curves_report(fit, ...)` | `mfrm_report(fit, type = "category_curves", ...)` |
| [`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_guide.md) | `facets_guide("positioning")` |
| [`facets_term_crosswalk()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_guide.md) | `facets_guide("terms")` |
| [`facets_visual_contract()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_guide.md) | `facets_guide("visuals")` |
| `facets_feature_coverage(status)` | `facets_guide("coverage", status = status)` |
| `facets_fit_df_guide(include_references)` | `facets_guide("fit_df", include_references = include_references)` |
| `mfrmRFacets(...)` | `run_mfrm_facets(...)` |
| `mfrm_cluster_pam(x, k)` | `mfrm_cluster(x, k, method = "pam")` |
| `mfrm_cluster_hierarchical(x, k)` | `mfrm_cluster(x, k, method = "hierarchical")` |
| `mfrm_cluster_kmeans(x, k)` | `mfrm_cluster(x, k, method = "kmeans")` |
| `validate_mfrm_calibration(x)` | `update(x, status = "validated")` |
| `freeze_mfrm_calibration(x)` | `update(x, status = "frozen")` |
| `supersede_mfrm_calibration(x, record_id)` | `update(x, status = "superseded", record_id = record_id)` |
| `retire_mfrm_calibration(x, record_id)` | `update(x, status = "retired", record_id = record_id)` |
| `normalize_conquest_overlap_files(pop, items, cases)` | `normalize_conquest_overlap_tables(pop, items, cases, input = "files")` |
| `gpcm_mml_quadrature_sensitivity(fit, data)` | `mml_quadrature_sensitivity(fit, data)` |
| `import_facets_fit_table(file)` | `read_facets_results(file)` |
| `read_facets_fit_table(file, ...)` | `read_facets_results(file, ...)` (pass directly to [`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)) |
| `import_mirt_fit(fit, model, ...)` | `import_irt_fit(fit, model, ..., source = "mirt")` (or `source = "auto"`) |
| `import_tam_fit(fit, model, ...)` | `import_irt_fit(fit, model, ..., source = "tam")` (or `source = "auto"`) |
| `import_erm_fit(fit, model, ...)` | `import_irt_fit(fit, model, ..., source = "erm")` (or `source = "auto"`) |
| `mfrmr_interval_guide(scope)` | `mfrmr_output_guide("intervals", scope)` |
| `visual_reporting_template(scope)` | `mfrmr_output_guide("visual_templates", scope)` |
| `gpcm_capability_matrix(status, view)` | `mfrmr_output_guide("gpcm_capabilities", status = status, view = view)` |
| `mfrm_calibration_capabilities()` | `mfrmr_output_guide("calibration_capabilities")` |
| `anchor_review(fit)` | `fit$config$anchor_review` or `review_mfrm_anchors(...)` |
| `precision_review(diagnostics)` | `diagnostics$precision_review` or `mfrm_report(type = "precision", fit, diagnostics = diagnostics)` |
| `analyze_dif(...)` | `analyze_dff(...)` |
| `mfrm_response_imputations(..., impute = ids)` | `review_mfrm_imputations(..., impute_ids = ids)` |

Argument and saved-result migration notes:

- **Reports
  ([`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md))**:
  Rename `fit`/`dif_result` to `x` and pass full `type` names
  (`"iterations"` vs `"bias_iterations"`).

- **Clustering
  ([`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md))**:
  Pass method-specific controls (`linkage`, `seed`, etc.) by name;
  unsupported controls fail closed.

- **Calibration ([`update()`](https://rdrr.io/r/stats/update.html))**:
  Rename `calibration` to `object` and state-specific timestamps to
  `at_utc` (`validated` -\> `frozen`; `superseded` / `retired` require a
  distinct `record_id`).

- **ConQuest files
  (`normalize_conquest_overlap_tables(..., input = "files")`)**: Rename
  `population_file`, `item_file`, and `case_file` to
  `conquest_population`, `conquest_item_estimates`, and
  `conquest_case_eap`.

## Score-comparison columns

The former automated-scoring interface now uses
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md).
Keep `categories`, supply continuous scores' explicit
`score_categories`, and choose `screen = "williamson2012"` to retain the
earlier thresholds. Without that choice the generic default applies no
thresholds. Rename `smd = "human"` to `smd = "reference"`, including
`SMDBasis` and `settings$smd`; the corresponding `criteria$Basis` suffix
is now `_smd_reference`. These are naming changes, not different
denominators.

|                                |                                        |
|--------------------------------|----------------------------------------|
| Former table column            | Current table column                   |
| `HumanReferenceSupplied`       | `Reference2Supplied`                   |
| `MeanAutomated`, `MeanHuman`   | `MeanScore`, `MeanReference`           |
| `SDAutomated`, `SDHuman`       | `SDScore`, `SDReference`               |
| `HumanQWK`, `HumanCorrelation` | `ReferenceQWK`, `ReferenceCorrelation` |
| `SMDHuman`                     | `SMDReference`                         |

In `cases`, rename `MissingAutomated` to `MissingScore`, `MissingHuman`
to `MissingReference`, `MissingAutomatedCategory` to
`MissingScoreCategory`, and `MissingHumanReference` to
`MissingReference2`. In `counts`, rename `automated_human`/`human_human`
to `scores_reference`/`reference2_reference`; the second dimension is
now named `Reference` rather than `Human`. Saved earlier lists keep
their original names and can be reopened with
[`readRDS()`](https://rdrr.io/r/base/readRDS.html) without a model
refit.

## Unified ggplot2 return contract

All [`plot()`](https://rdrr.io/r/graphics/plot.default.html) S3 methods
now render with `ggplot2` (`ggplot2 (>= 3.4.0)` in `Imports`) and
invisibly return a `ggplot` object (`inherits(p, "ggplot")`). Setting
`draw = FALSE` constructs and returns the `ggplot` object without
printing it or opening a graphics device.

Update scripts that previously indexed `p$data$...` on a returned
`mfrm_plot_data` list to call
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
(`plot_data(p)` for the full payload list,
`plot_data(p, component = ...)` for a named table/matrix, or
`plot_data(p, "notes")` for descriptions and cautions) and
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to inspect available components.

Saved plot payloads from `0.2.x` (`mfrm_plot_data`,
`mfrm_design_evaluation_plot_data`, and
`mfrm_signal_detection_plot_data`) remain compatible with both
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md),
and calling `as_ggplot(p)` on a `0.3.0` `ggplot` return value is
idempotent. Two-continuous-variable scatterplots (including the new
`plot(dif, type = "scatter")` route after
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
model comparisons, fit pathway, fair average, bias, PCA scores, and
recovery scatterplots) add aligned X/Y marginal histograms via
`marginal = c("auto", "histogram", "none")`. These changes do not add
support for previously unsupported models or uncertainty calculations.

## Structured fit_mfrm() signature and shared spec

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
now exposes a focused 19-argument signature (`data`, 15 common
model/design arguments, `spec = NULL`, `control = list()`, and `...`)
that partitions all 55 canonical arguments into `data` (1), `spec` (33
model, scale, identification, anchor, interaction, and population keys),
and `control` (21 quadrature, optimizer, shrinkage, JML correction, and
runtime keys).

- **Full-name flat arguments remain supported**: Supply the complete
  names of the 55 canonical arguments directly to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or in the named list passed to `do.call(fit_mfrm, ...)`. Their
  defaults and statistical meaning are unchanged. Only the first four
  positional arguments (`data`, `person`, `facets`, `score`) retain
  their old positions; name all later arguments. Abbreviations for
  arguments now routed through `...` are rejected. For example, replace
  `quad_point = 15` with `quad_points = 15` or
  `control = list(quad_points = 15)`.

- **Shared 4-entrypoint `spec`**: One named `spec = list(...)` can be
  passed unchanged to
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  and
  [`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md)
  (`data = ..., spec = spec`) within each function's supported scope. A
  valid native fit specification is not necessarily exportable: ordinary
  RSM/PCM export requires a fixed standard-normal population; estimated
  intercept-only normal populations are supported only for one-family
  GPCM in Stan. Explicit top-level arguments override entries in `spec`;
  misplaced or duplicated keys fail with actionable guidance.

- **Technical reference page**: Specialist equations, identification
  rules, JML polish-ladder details, and return-object provenance now
  live in
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)
  (linked from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)).
  Use `mfrmr_output_guide("core_workflow")` for the purpose-based
  analysis map.

For an existing rating table `ratings` with scores 1–4, these calls show
how to migrate partial names and positional arguments. Run only the
current form:

    # Old: fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    #               1, 4, method = "MML", model = "RSM", quad_point = 15)
    fit <- fit_mfrm(
      ratings, person = "Person", facets = c("Rater", "Criterion"),
      score = "Score", rating_min = 1, rating_max = 4,
      method = "MML", model = "RSM",
      control = list(quad_points = 15)
    )

The example preserves the old default model constraints. Migration does
not establish that those constraints are suitable for a particular
assessment; review the population and location assumptions in
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## Saved-analysis refresh and compatibility surface

Installing an update does not recalculate saved objects on disk. Check
`summary(fit)$decision` first: if an early saved fit lacks current
terminal-gradient or category-support checks, refit from the original
data and settings; otherwise regenerate affected
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
or
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
outputs from the saved fit before rebuilding reports or CSV exports.
Saved `0.2.x` G-Study/D-Study and plot payloads (`mfrm_plot_data`) work
directly with [`summary()`](https://rdrr.io/r/base/summary.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md).

Legacy FACETS-oriented wrappers
([`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
[`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md),
[`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md),
[`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md))
are presentation and handoff contracts, not claims of FACETS, ConQuest,
or SPSS numerical equivalence.

## Former 0.2.4 plot helper replacements

In 0.3.0, every [`plot()`](https://rdrr.io/r/graphics/plot.default.html)
S3 method renders with `ggplot2` and invisibly returns a `ggplot` object
(`draw = FALSE` suppresses device output; extract underlying tables and
notes with
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
and
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)).
Replace the 33 former `plot_*()` helpers with
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) on the
corresponding fitted model or analysis result:

|  |  |
|----|----|
| Former exported helper | Replacement |
| `plot_anchor_drift()` | `plot(x)` |
| `plot_apa_figure_one()` | `plot(x, type = "apa_summary")` |
| `plot_bias_interaction()` | `plot(x, type = "bias")` |
| `plot_bubble()` | `plot(x, type = "bubble")` |
| `plot_compare_mfrm()` | `plot(reference, comparison = comparison)` |
| `plot_dif_heatmap()` / `plot_dif_summary()` | `plot(x, type = "heatmap")` / `plot(x, type = "summary")` |
| `plot_displacement()` | `plot(x, type = "displacement")` |
| `plot_facet_equivalence()` | `plot(x, type = "facet_equivalence")` |
| `plot_facet_quality_dashboard()` | `plot(x, type = "facet_dashboard")` |
| `plot_facets_chisq()` | `plot(x, type = "facets_chisq")` |
| `plot_fair_average()` | `plot(x, type = "fair_average")` |
| `plot_guttman_scalogram()` | `plot(x, type = "guttman")` |
| `plot_information()` | `plot(x)` |
| `plot_interrater_agreement()` | `plot(x, type = "agreement")` |
| `plot_local_dependence_heatmap()` | `plot(x, type = "local_dependence")` |
| `plot_marginal_fit()` / `plot_marginal_pairwise()` | `plot(x, type = "marginal_fit")` / `type = "marginal_pairwise"` |
| `plot_person_fit()` | `plot(x, type = "person_fit")` |
| `plot_qc_dashboard()` / `plot_qc_pipeline()` | `plot(x, type = "qc")` / `plot(x)` |
| `plot_rater_agreement_heatmap()` | `plot(x, type = "agreement", view = "heatmap")` |
| `plot_rater_severity_profile()` | `plot(x, type = "rater_severity")` |
| `plot_rater_trajectory()` | `plot(fits[[1L]], type = "trajectory", comparison = fits[-1L], labels = names(fits))` |
| `plot_reliability_snapshot()` | `plot(x, type = "reliability")` |
| `plot_residual_matrix()` / `plot_residual_pca()` / `plot_residual_qq()` | `plot(x, type = "residual_matrix")` / `"residual_pca"` / `"residual_qq"` |
| `plot_response_time_review()` | `plot(x)` |
| `plot_shrinkage_funnel()` | `plot(x, type = "shrinkage", view = "funnel")` |
| `plot_threshold_ladder()` | `plot(x, type = "thresholds")` |
| `plot_unexpected()` | `plot(x, type = "unexpected")` |
| `plot_wright_unified()` | `plot(x, type = "wright", view = "unified")` |

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md),
[`facets_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_guide.md),
[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md),
[mfrm_calibration_workflow](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md),
[`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md),
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md),
[`read_facets_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_results.md),
[`import_irt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_irt_fit.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md)

## Examples

``` r
compatibility_alias_table("functions")
#>                            Alias           PreferredName  Surface
#> 1                    mfrmRFacets         run_mfrm_facets function
#> 2                    analyze_dif             analyze_dff function
#> 3               mfrm_cluster_pam            mfrm_cluster function
#> 4      mfrm_response_imputations review_mfrm_imputations function
#> 6                import_mirt_fit          import_irt_fit function
#> 7                 import_tam_fit          import_irt_fit function
#> 8                 import_erm_fit          import_irt_fit function
#> 9          read_facets_fit_table     read_facets_results function
#> 10          mfrmr_interval_guide      mfrmr_output_guide function
#> 11     visual_reporting_template      mfrmr_output_guide function
#> 12        gpcm_capability_matrix      mfrmr_output_guide function
#> 13 mfrm_calibration_capabilities      mfrmr_output_guide function
#> 14                 anchor_review     review_mfrm_anchors function
#> 15              precision_review             mfrm_report function
#>         Lifecycle                                                 RetainedFor
#> 1  removed_export                                      older workflow scripts
#> 2  removed_export                           earlier DIF-oriented package code
#> 3  removed_export        earlier feature-clustering scripts and saved results
#> 4  removed_export earlier assigned-score imputation scripts and saved results
#> 6  removed_export                            external mirt fit import scripts
#> 7  removed_export                             external TAM fit import scripts
#> 8  removed_export                             external eRm fit import scripts
#> 9  removed_export                    external FACETS fit-table import scripts
#> 10 removed_export                    confidence-interval route lookup scripts
#> 11 removed_export                    figure-reporting template lookup scripts
#> 12 removed_export               GPCM workflow/score capability lookup scripts
#> 13 removed_export              portable calibration capability lookup scripts
#> 14 removed_export                       fitted anchor-review field extraction
#> 15 removed_export               diagnostics precision-review field extraction
#>                                                                           RemovalPlan
#> 1                     Removed in the 0.3.0 development series; use run_mfrm_facets().
#> 2  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 3  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 4  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 6  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 7  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 8  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 9  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 10 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 11 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 12 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 13 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 14 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 15 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#>                                                                                                                       Notes
#> 1                                                        Use run_mfrm_facets(); the former workflow alias has been removed.
#> 2                                                            Use analyze_dff(); the former DIF alias is no longer exported.
#> 3                                           Use mfrm_cluster(method = 'pam'); the underlying Gower/PAM result is unchanged.
#> 4                            Same supplied-completion checks and result class; this function does not generate imputations.
#> 6  Use import_irt_fit(fit, model, ..., source = 'mirt') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.
#> 7   Use import_irt_fit(fit, model, ..., source = 'tam') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.
#> 8   Use import_irt_fit(fit, model, ..., source = 'erm') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.
#> 9                      Use read_facets_results(file, ...) and pass it directly to facets_fit_review(fit, facets_fit = ...).
#> 10                               Use mfrmr_output_guide('intervals', category); returned interval-guide table is unchanged.
#> 11                       Use mfrmr_output_guide('visual_templates', category); returned figure-template table is unchanged.
#> 12     Use mfrmr_output_guide('gpcm_capabilities', status = ..., view = ...); returned GPCM capability matrix is unchanged.
#> 13        Use mfrmr_output_guide('calibration_capabilities'); returned portable-calibration capability matrix is unchanged.
#> 14                                    Read fit$config$anchor_review directly, or call review_mfrm_anchors() before fitting.
#> 15     Read diagnostics$precision_review directly, or call mfrm_report(type = 'precision', fit, diagnostics = diagnostics).
```
