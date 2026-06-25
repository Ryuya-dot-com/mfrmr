# mfrmr Compatibility Layer Map

Guide to the legacy-compatible wrappers and text/file exports in
`mfrmr`. Use this page when you need continuity with older
compatibility-oriented workflows, fixed-width reports, or graph/score
file style outputs.

This compatibility layer currently applies mainly to diagnostics-based
`RSM` / `PCM` workflows. First-release `GPCM` fits now also support
graph-only compatibility-style exports, while scorefile and
diagnostics-driven compatibility outputs remain limited to `RSM` /
`PCM`. Treat this layer as a presentation/contract surface, not as a
claim of FACETS or ConQuest numerical equivalence.

SPSS is treated differently from FACETS and ConQuest: `mfrmr` currently
supports table/data-frame/CSV handoff for SPSS-oriented reporting
workflows, but it does not generate SPSS syntax, write native SPSS
system files, execute SPSS estimators, or claim SPSS numerical
equivalence.

## When to use this layer

- You are reproducing an older workflow that expects one-shot wrappers.

- You need fixed-width text blocks for console, logs, or archival
  handoff.

- You need graphfile or scorefile style outputs for downstream legacy
  tools.

- You are checking column coverage and metric consistency against a
  FACETS-style output contract.

## When not to use this layer

- For standard estimation, use
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  plus
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- For report bundles, use
  [mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md).

- For manuscript text, use
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  and
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).

- For visual follow-up, use
  [mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md).

## Compatibility map

- [`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_positioning_guide.md):

  User-facing wording for the package's relationship to FACETS. Use
  before describing compatibility outputs in a report or migration note.

- [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md):

  One-shot legacy-compatible wrapper that fits, diagnoses, and returns
  key tables in one object.

- [`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md):

  Alias for
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  kept for continuity.

- [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md):

  Fixed-width interaction and pairwise text blocks. Best when a
  text-only compatibility artifact is required.

- [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md):

  Graphfile/scorefile style CSV and fixed-width exports for legacy
  pipelines.

- [`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md):

  Package-native observation-level residual CSV/TSV export for reviewer,
  spreadsheet, or external QC handoff.

- [`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_subset_file.md):

  Package-native connected-subset summary and node-membership CSV/TSV
  export for linking review handoff.

- [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md):

  Column and metric review against the FACETS-style output-contract
  specification. Use only when an explicit output-contract review is
  part of the task; it checks the package output contract and does not
  imply external FACETS equivalence.

## Preferred replacements

- Instead of
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
  prefer:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).

- Instead of
  [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
  prefer:
  [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
  -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

- Instead of
  [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md),
  prefer:
  [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md)
  or
  [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md)
  plus
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md).

- For residual or subset handoff, prefer
  [`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md)
  and
  [`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_subset_file.md)
  over reusing graph/score compatibility exports.

- Instead of
  [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md)
  for routine QA, prefer:
  [`reference_case_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_review.md)
  for package-native completeness review or
  [`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_benchmark.md)
  for packaged benchmark cases.

## Practical migration rules

- Start FACETS-facing reports with
  [`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_positioning_guide.md)
  when readers might otherwise assume FACETS numerical reproduction.

- Keep compatibility wrappers only where a downstream consumer truly
  needs the old layout or fixed-width format.

- For new scripts, start from package-native bundles and add
  compatibility outputs only at the export boundary.

- Treat compatibility outputs as presentation contracts, not as the
  primary analysis objects.

- Use
  [`compatibility_alias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/compatibility_alias_table.md)
  when you need to check which aliases are still retained and which
  package-native names should be used in new code.

- Use `reporting_checklist(fit)$software_scope` to review the current
  FACETS, ConQuest, and SPSS relationship wording for a fitted analysis.

## Retained table-field names

- `row_review` is the data-quality table field used to document row
  filtering. FACETS-style column and metric contract results are exposed
  as `column_review` and `metric_checks`.

- Prediction outputs expose row-preparation and person-omission
  traceability as `row_review` and `population_review`.

- `hierarchical_review`, `shrinkage_review`, and `nesting_review` are
  manifest or model-comparison traceability fields. They are not
  callable helper names; user-facing helper names use review/check
  terminology.

## Typical workflow

- Legacy handoff:
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  -\>
  [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md)
  -\>
  [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md)
  plus
  [`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md)
  /
  [`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_subset_file.md)
  only when those standalone files are needed.

- Mixed workflow: `RSM` / `PCM`:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  -\> compatibility export only if required. bounded `GPCM`:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  -\> graph-only compatibility export only when a legacy handoff truly
  requires it.

- FACETS output-contract review:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md).

## Companion guides

- For FACETS coverage and boundary wording, see
  [`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_positioning_guide.md)
  and
  [`facets_feature_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_feature_coverage.md).

- For standard reports/tables, see
  [mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md).

- For manuscript-draft reporting, see
  [mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md).

- For visual diagnostics, see
  [mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md).

- For linking and DFF workflows, see
  [mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md).

- For end-to-end routes, see
  [mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md).

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]

run <- run_mfrm_facets(
  data = toy_small,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  maxit = 30
)
summary(run)
compatibility_alias_table("functions")

fixed <- build_fixed_reports(
  estimate_bias(
    run$fit,
    run$diagnostics,
    facet_a = "Rater",
    facet_b = "Criterion",
    max_iter = 1
  ),
  branch = "original"
)
names(fixed)
} # }
```
