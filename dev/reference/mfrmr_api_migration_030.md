# Fewer public entry points and unified ggplot2 graphics in 0.3.0

Related operations now use arguments or standard S3 methods, and all
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods render
and return `ggplot2` objects directly. Because 28 overlapping entry
points are no longer exported and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns a
`ggplot` object rather than `mfrm_plot_data` / base graphics, the target
release is versioned as 0.3.0 under semantic versioning: update old
scripts before installing this development version. Existing saved
result classes retain their
[`summary()`](https://rdrr.io/r/base/summary.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md),
and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
methods.

## Replacements

|  |  |
|----|----|
| Former entry | Current call |
| [`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_positioning_guide.md) | `facets_guide("positioning")` |
| [`facets_term_crosswalk()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_term_crosswalk.md) | `facets_guide("terms")` |
| [`facets_visual_contract()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_visual_contract.md) | `facets_guide("visuals")` |
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
| `read_facets_fit_table(file, ...)` | `read_facets_results(file, ...)` (pass directly to [`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_fit_review.md)) |
| `import_mirt_fit(fit, model, ...)` | `import_irt_fit(fit, model, ..., source = "mirt")` (or `source = "auto"`) |
| `import_tam_fit(fit, model, ...)` | `import_irt_fit(fit, model, ..., source = "tam")` (or `source = "auto"`) |
| `import_erm_fit(fit, model, ...)` | `import_irt_fit(fit, model, ..., source = "erm")` (or `source = "auto"`) |
| `mfrmr_interval_guide(scope)` | `mfrmr_output_guide("intervals", scope)` |
| `visual_reporting_template(scope)` | `mfrmr_output_guide("visual_templates", scope)` |
| `gpcm_capability_matrix(status, view)` | `mfrmr_output_guide("gpcm_capabilities", status = status, view = view)` |
| `mfrm_calibration_capabilities()` | `mfrmr_output_guide("calibration_capabilities")` |
| `anchor_review(fit)` | `fit$config$anchor_review` or `review_mfrm_anchors(...)` |
| `precision_review(diagnostics)` | `diagnostics$precision_review` or `precision_review_report(fit, diagnostics)` |
| `analyze_dif(...)` | `analyze_dff(...)` |
| `mfrm_response_imputations(..., impute = ids)` | `review_mfrm_imputations(..., impute_ids = ids)` |

Keep named clustering controls such as `linkage` or `seed`. They apply
only to the chosen method; unsupported controls fail instead of being
ignored. The default is still PAM, including the original third and
fourth positional arguments `weights` and `missing`. For PCA k-means
input, set scaling, weights and missingness when constructing the PCA,
as before.

For calibration transitions, rename a named `calibration` argument to
`object` and the state-specific timestamp argument to `at_utc`.
Transitions still return a new object; they do not edit the input or a
saved file. A draft must be validated before it can be frozen.
Superseding or retiring requires a distinct `record_id`;
[`update()`](https://rdrr.io/r/stats/update.html) cannot thaw or rewrite
a frozen calibration.
[`review_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_calibration_workflow.md)
remains a non-mutating review.

For file normalization, rename named `population_file`, `item_file` and
`case_file` to `conquest_population`, `conquest_item_estimates` and
`conquest_case_eap`. Keep delimiter and column-mapping controls by name.
Raw ConQuest exports remain a separate bundle-dependent contract,
handled by
[`normalize_conquest_overlap_exports()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/normalize_conquest_overlap_exports.md).
Do not feed them to the extracted table route. The common
quadrature-sensitivity entry also accepts RSM/PCM; code that
specifically requires GPCM should check the model it supplies.

Imputation pooling, comparison of partitions, model fitting and result
extraction remain distinct operations. Similar names do not imply the
same statistical target.

## Unified ggplot2 return contract

All [`plot()`](https://rdrr.io/r/graphics/plot.default.html) S3 methods
now render with `ggplot2` (`ggplot2 (>= 3.4.0)` in `Imports`) and
invisibly return a `ggplot` object (`inherits(p, "ggplot")`). Setting
`draw = FALSE` constructs and returns the `ggplot` object without
printing it or opening a graphics device.

Update scripts that previously indexed `p$data$...` on a returned
`mfrm_plot_data` list to call
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
(`plot_data(p)` for the full payload list,
`plot_data(p, component = ...)` for a named table/matrix, or
`plot_data(p, "notes")` for descriptions and cautions) and
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data_components.md)
to inspect available components.

Saved plot payloads from `0.2.x` (`mfrm_plot_data`,
`mfrm_design_evaluation_plot_data`, and
`mfrm_signal_detection_plot_data`) remain compatible with both
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
and
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md),
and calling `as_ggplot(p)` on a `0.3.0` `ggplot` return value is
idempotent. Two-continuous-variable scatterplots (including the new
`plot(dif, type = "scatter")` route after
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_dff.md),
model comparisons, fit pathway, fair average, bias, PCA scores, and
recovery scatterplots) add aligned X/Y marginal histograms via
`marginal = c("auto", "histogram", "none")`. These changes do not add
support for previously unsupported models or uncertainty calculations.

## Structured fit_mfrm() signature and shared spec

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
now exposes a focused 19-argument signature (`data`, 15 common
model/design arguments, `spec = NULL`, `control = list()`, and `...`)
that partitions all 55 canonical arguments into `data` (1), `spec` (33
model, scale, identification, anchor, interaction, and population keys),
and `control` (21 quadrature, optimizer, shrinkage, JML correction, and
runtime keys).

- **Full-name flat arguments remain supported**: Supply the complete
  names of the 55 canonical arguments directly to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
  or in the named list passed to `do.call(fit_mfrm, ...)`. Their
  defaults and statistical meaning are unchanged. Only the first four
  positional arguments (`data`, `person`, `facets`, `score`) retain
  their old positions; name all later arguments. Abbreviations for
  arguments now routed through `...` are rejected. For example, replace
  `quad_point = 15` with `quad_points = 15` or
  `control = list(quad_points = 15)`.

- **Shared 4-entrypoint `spec`**: One named `spec = list(...)` can be
  passed unchanged to
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/describe_mfrm_data.md),
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/review_mfrm_anchors.md),
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
  and
  [`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/export_mfrm_model.md)
  (`data = ..., spec = spec`) within each function's supported scope. A
  valid native fit specification is not necessarily exportable: ordinary
  RSM/PCM export requires a fixed standard-normal population; estimated
  intercept-only normal populations are supported only for one-family
  GPCM in Stan. Explicit top-level arguments override entries in `spec`;
  misplaced or duplicated keys fail with actionable guidance.

- **Technical reference page**: Specialist equations, identification
  rules, JML polish-ladder details, and return-object provenance now
  live in
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm_technical_details.md)
  (linked from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)).
  Use `mfrmr_output_guide("core_workflow")` for the five-step onboarding
  map.

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
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm_technical_details.md),
[`facets_guide()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_guide.md),
[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_cluster.md),
[mfrm_calibration_workflow](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_calibration_workflow.md),
[`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/normalize_conquest_overlap_tables.md),
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mml_quadrature_sensitivity.md),
[`read_facets_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/read_facets_results.md),
[`import_irt_fit()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/import_irt_fit.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_output_guide.md),
[mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_gpcm_scope.md)
