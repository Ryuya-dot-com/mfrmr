#' Fewer public entry points and unified ggplot2 graphics in 0.3.0
#'
#' Related operations now use arguments or standard S3 methods, and all `plot()`
#' methods render and return `ggplot2` objects directly. Because overlapping
#' entry points are no longer exported and `plot()` returns a `ggplot` object
#' rather than `mfrm_plot_data` / base graphics, version 0.3.0 uses a
#' minor-version increment under semantic versioning: review existing 0.2.x
#' scripts when updating to 0.3.0. Existing saved result classes retain
#' their `summary()`, `plot()`, `plot_data()`, and `as_ggplot()` methods.
#'
#' @section Default route guide:
#' [mfrmr_output_guide()] now returns the five central routes, matching
#' `scope = "core_workflow"`. Use `mfrmr_output_guide("all")` where a script
#' needs the former full catalogue. Explicit scopes, including the six-row
#' `"public"` and `"beginner"` routes, retain their meanings and columns.
#'
#' @section Replacements:
#' | Former entry | Current call |
#' | --- | --- |
#' | `automated_scoring_table(automated, human, ...)` | `score_comparison_table(scores, reference, ..., screen = "williamson2012")` |
#' | `facet_statistics_report(fit, ...)` | `mfrm_report(fit, type = "facet_statistics", ...)` |
#' | `precision_review_report(fit, ...)` | `mfrm_report(fit, type = "precision", ...)` |
#' | `bias_iteration_report(x, ...)` | `mfrm_report(x, type = "bias_iterations", ...)` |
#' | `bias_pairwise_report(x, ...)` | `mfrm_report(x, type = "bias_pairwise", ...)` |
#' | `dif_report(dif_result)` | `mfrm_report(dif_result, type = "dff")` |
#' | `reporting_checklist(fit, ...)` | `mfrm_report(fit, type = "checklist", ...)` |
#' | `reference_case_review(fit, ...)` | `mfrm_report(fit, type = "reference_review", ...)` |
#' | `estimation_iteration_report(fit, ...)` | `mfrm_report(fit, type = "iterations", ...)` |
#' | `bias_interaction_report(x, ...)` | `mfrm_report(x, type = "bias_interaction", ...)` |
#' | `mfrm_multivariate_d_compare(d, ...)` | `compare_mfrm(d, ...)` |
#' | `specifications_report(fit, ...)` | `mfrm_report(fit, type = "specifications", ...)` |
#' | `data_quality_report(fit, ...)` | `mfrm_report(fit, type = "data_quality", ...)` |
#' | `category_structure_report(fit, ...)` | `mfrm_report(fit, type = "category_structure", ...)` |
#' | `category_curves_report(fit, ...)` | `mfrm_report(fit, type = "category_curves", ...)` |
#' | `facets_positioning_guide()` | `facets_guide("positioning")` |
#' | `facets_term_crosswalk()` | `facets_guide("terms")` |
#' | `facets_visual_contract()` | `facets_guide("visuals")` |
#' | `facets_feature_coverage(status)` | `facets_guide("coverage", status = status)` |
#' | `facets_fit_df_guide(include_references)` | `facets_guide("fit_df", include_references = include_references)` |
#' | `mfrmRFacets(...)` | `run_mfrm_facets(...)` |
#' | `mfrm_cluster_pam(x, k)` | `mfrm_cluster(x, k, method = "pam")` |
#' | `mfrm_cluster_hierarchical(x, k)` | `mfrm_cluster(x, k, method = "hierarchical")` |
#' | `mfrm_cluster_kmeans(x, k)` | `mfrm_cluster(x, k, method = "kmeans")` |
#' | `validate_mfrm_calibration(x)` | `update(x, status = "validated")` |
#' | `freeze_mfrm_calibration(x)` | `update(x, status = "frozen")` |
#' | `supersede_mfrm_calibration(x, record_id)` | `update(x, status = "superseded", record_id = record_id)` |
#' | `retire_mfrm_calibration(x, record_id)` | `update(x, status = "retired", record_id = record_id)` |
#' | `normalize_conquest_overlap_files(pop, items, cases)` | `normalize_conquest_overlap_tables(pop, items, cases, input = "files")` |
#' | `gpcm_mml_quadrature_sensitivity(fit, data)` | `mml_quadrature_sensitivity(fit, data)` |
#' | `import_facets_fit_table(file)` | `read_facets_results(file)` |
#' | `read_facets_fit_table(file, ...)` | `read_facets_results(file, ...)` (pass directly to `facets_fit_review()`) |
#' | `import_mirt_fit(fit, model, ...)` | `import_irt_fit(fit, model, ..., source = "mirt")` (or `source = "auto"`) |
#' | `import_tam_fit(fit, model, ...)` | `import_irt_fit(fit, model, ..., source = "tam")` (or `source = "auto"`) |
#' | `import_erm_fit(fit, model, ...)` | `import_irt_fit(fit, model, ..., source = "erm")` (or `source = "auto"`) |
#' | `mfrmr_interval_guide(scope)` | `mfrmr_output_guide("intervals", scope)` |
#' | `visual_reporting_template(scope)` | `mfrmr_output_guide("visual_templates", scope)` |
#' | `gpcm_capability_matrix(status, view)` | `mfrmr_output_guide("gpcm_capabilities", status = status, view = view)` |
#' | `mfrm_calibration_capabilities()` | `mfrmr_output_guide("calibration_capabilities")` |
#' | `anchor_review(fit)` | `fit$config$anchor_review` or `review_mfrm_anchors(...)` |
#' | `precision_review(diagnostics)` | `diagnostics$precision_review` or `mfrm_report(type = "precision", fit, diagnostics = diagnostics)` |
#' | `analyze_dif(...)` | `analyze_dff(...)` |
#' | `mfrm_response_imputations(..., impute = ids)` | `review_mfrm_imputations(..., impute_ids = ids)` |
#'
#' Argument and saved-result migration notes:
#' - **Reports (`mfrm_report()`)**: Rename `fit`/`dif_result` to `x` and pass
#'   full `type` names (`"iterations"` vs `"bias_iterations"`).
#' - **Clustering (`mfrm_cluster()`)**: Pass method-specific controls (`linkage`,
#'   `seed`, etc.) by name; unsupported controls fail closed.
#' - **Calibration (`update()`)**: Rename `calibration` to `object` and
#'   state-specific timestamps to `at_utc` (`validated` -> `frozen`; `superseded` /
#'   `retired` require a distinct `record_id`).
#' - **ConQuest files (`normalize_conquest_overlap_tables(..., input = "files")`)**:
#'   Rename `population_file`, `item_file`, and `case_file` to
#'   `conquest_population`, `conquest_item_estimates`, and `conquest_case_eap`.
#'
#' @section Score-comparison columns:
#' The former automated-scoring interface now uses [score_comparison_table()].
#' Keep `categories`, supply continuous scores' explicit `score_categories`,
#' and choose `screen = "williamson2012"` to retain the earlier thresholds.
#' Without that choice the generic default applies no thresholds. Rename
#' `smd = "human"` to `smd = "reference"`, including `SMDBasis` and
#' `settings$smd`; the corresponding `criteria$Basis` suffix is now
#' `_smd_reference`. These are naming changes, not different denominators.
#'
#' | Former table column | Current table column |
#' | --- | --- |
#' | `HumanReferenceSupplied` | `Reference2Supplied` |
#' | `MeanAutomated`, `MeanHuman` | `MeanScore`, `MeanReference` |
#' | `SDAutomated`, `SDHuman` | `SDScore`, `SDReference` |
#' | `HumanQWK`, `HumanCorrelation` | `ReferenceQWK`, `ReferenceCorrelation` |
#' | `SMDHuman` | `SMDReference` |
#'
#' In `cases`, rename `MissingAutomated` to `MissingScore`, `MissingHuman`
#' to `MissingReference`, `MissingAutomatedCategory` to `MissingScoreCategory`,
#' and `MissingHumanReference` to `MissingReference2`.
#' In `counts`, rename `automated_human`/`human_human`
#' to `scores_reference`/`reference2_reference`; the second dimension is now
#' named `Reference` rather than `Human`. Saved earlier lists keep their
#' original names and can be reopened with `readRDS()` without a model refit.
#'
#' @section Unified ggplot2 return contract:
#' All `plot()` S3 methods now render with `ggplot2` (`ggplot2 (>= 3.4.0)` in
#' `Imports`) and invisibly return a `ggplot` object (`inherits(p, "ggplot")`).
#' Setting `draw = FALSE` constructs and returns the `ggplot` object without
#' printing it or opening a graphics device.
#'
#' Update scripts that previously indexed `p$data$...` on a returned
#' `mfrm_plot_data` list to call [plot_data()] (`plot_data(p)` for the full
#' payload list, `plot_data(p, component = ...)` for a named table/matrix, or
#' `plot_data(p, "notes")` for descriptions and cautions) and
#' [plot_data_components()] to inspect available components.
#'
#' Saved plot payloads from `0.2.x` (`mfrm_plot_data`,
#' `mfrm_design_evaluation_plot_data`, and `mfrm_signal_detection_plot_data`)
#' remain compatible with both [plot_data()] and [as_ggplot()], and calling
#' `as_ggplot(p)` on a `0.3.0` `ggplot` return value is idempotent.
#' Two-continuous-variable scatterplots (including the new
#' `plot(dif, type = "scatter")` route after [analyze_dff()], model comparisons,
#' fit pathway, fair average, bias, PCA scores, and recovery scatterplots) add
#' aligned X/Y marginal histograms via `marginal = c("auto", "histogram", "none")`.
#' These changes do not add support for previously unsupported models or
#' uncertainty calculations.
#'
#' @section Structured fit_mfrm() signature and shared spec:
#' [fit_mfrm()] now exposes a focused 19-argument signature (`data`, 15 common
#' model/design arguments, `spec = NULL`, `control = list()`, and `...`) that
#' partitions all 55 canonical arguments into `data` (1), `spec` (33 model,
#' scale, identification, anchor, interaction, and population keys), and
#' `control` (21 quadrature, optimizer, shrinkage, JML correction, and runtime
#' keys).
#'
#' - **Full-name flat arguments remain supported**: Supply the complete names
#'   of the 55 canonical arguments directly to [fit_mfrm()] or in the named list
#'   passed to `do.call(fit_mfrm, ...)`. Their defaults and statistical meaning
#'   are unchanged. Only the first four positional arguments (`data`, `person`,
#'   `facets`, `score`) retain their old positions; name all later arguments.
#'   Abbreviations for arguments now routed through `...` are rejected. For
#'   example, replace `quad_point = 15` with `quad_points = 15` or
#'   `control = list(quad_points = 15)`.
#' - **Shared 4-entrypoint `spec`**: One named `spec = list(...)` can be passed
#'   unchanged to [describe_mfrm_data()], [review_mfrm_anchors()], [fit_mfrm()],
#'   and [export_mfrm_model()] (`data = ..., spec = spec`) within each function's
#'   supported scope. A valid native fit specification is not necessarily
#'   exportable: ordinary RSM/PCM export requires a fixed standard-normal
#'   population; estimated intercept-only normal populations are supported only
#'   for one-family GPCM in Stan. Explicit top-level arguments override entries
#'   in `spec`; misplaced or duplicated keys fail with actionable guidance.
#' - **Technical reference page**: Specialist equations, identification rules,
#'   JML polish-ladder details, and return-object provenance now live in
#'   [fit_mfrm_technical_details] (linked from [fit_mfrm()]). Use
#'   `mfrmr_output_guide("core_workflow")` for the purpose-based analysis map.
#'
#' For an existing rating table `ratings` with scores 1--4, these calls show how to
#' migrate partial names and positional arguments. Run only the current form:
#'
#' ```r
#' # Old: fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
#' #               1, 4, method = "MML", model = "RSM", quad_point = 15)
#' fit <- fit_mfrm(
#'   ratings, person = "Person", facets = c("Rater", "Criterion"),
#'   score = "Score", rating_min = 1, rating_max = 4,
#'   method = "MML", model = "RSM",
#'   control = list(quad_points = 15)
#' )
#' ```
#'
#' The example preserves the old default model constraints. Migration does not
#' establish that those constraints are suitable for a particular assessment;
#' review the population and location assumptions in [fit_mfrm()].
#'
#' @seealso [fit_mfrm()], [fit_mfrm_technical_details], [facets_guide()],
#'   [mfrm_cluster()], [mfrm_calibration_workflow],
#'   [normalize_conquest_overlap_tables()], [mml_quadrature_sensitivity()],
#'   [read_facets_results()], [import_irt_fit()], [mfrmr_output_guide()],
#'   [mfrmr_gpcm_scope]
#' @aliases mfrmr_api_migration_025
#' @aliases import_facets_fit_table read_facets_fit_table
#' @aliases import_mirt_fit import_tam_fit import_erm_fit
#' @aliases mfrmr_interval_guide visual_reporting_template
#' @aliases gpcm_capability_matrix mfrm_calibration_capabilities
#' @aliases anchor_review precision_review review_accessors mfrmRFacets
#' @name mfrmr_api_migration_030
NULL
