# FACETS Manual Mapping

This package documents a FACETS-style reporting and handoff surface while
keeping a native R implementation. The mapping is a package-output contract
reference, not evidence that FACETS was executed or that numerical FACETS
equivalence has been established. mfrmr estimates, diagnostics, plot payloads,
and report bundles remain the source of truth unless external FACETS output is
explicitly supplied for comparison.

## Manual References Used
- FACETS overview and model flexibility:
  <https://www.winsteps.com/facets.htm>
- Output table index (64-bit): <https://www.winsteps.com/facetman64/outputtableindex.htm>
- Output table index (32-bit archive): <https://www.winsteps.com/facetman/outputtableindex.htm>
- Table 5 measurable data summary: <https://www.winsteps.com/facetman/table5.htm>
- Table 5 measurable data summary (64-bit): <https://www.winsteps.com/facetman64/table5.htm>
- Table 7 measurement report: <https://www.winsteps.com/facetman/table7.htm>
- Table 7 reliability/chi-square notes: <https://www.winsteps.com/facetman/table7summarystatistics.htm>
- Table 7 agreement notes: <https://www.winsteps.com/facetman/table7agreementstatistics.htm>
- Table 8.1 dichotomy/binomial/Poisson report:
  <https://www.winsteps.com/facetman64/table8_1dichotomy.htm>
- Table 8.1 rating scale report: <https://www.winsteps.com/facetman/table8_1ratingscale.htm>
- Table 8 bar-chart report: <https://www.winsteps.com/facetman/table8barchart.htm>
- Table 8 probability-curves report: <https://www.winsteps.com/facetman/table8curves.htm>
- Model statement and partial-credit scale codes:
  <https://www.winsteps.com/facetman/models.htm>
- Model statement and response-family scale codes (64-bit):
  <https://www.winsteps.com/facetman64/models.htm>
- Rating scale / Specific partial-credit scale structures:
  <https://www.winsteps.com/facetman/ratingscale.htm>
- Rating scale / General-Specific / recoding examples (64-bit):
  <https://www.winsteps.com/facetman64/ratingscale.htm>
- Labels element, group, weight, and target-element fields:
  <https://www.winsteps.com/facetman64/elements.htm>
- Anchor output file:
  <https://www.winsteps.com/facetman64/anchoroutputfile.htm>
- Output dialog external file routes:
  <https://www.winsteps.com/facetman64/output_dialog_box.htm>
- Graph output (`Graphfile=`): <https://www.winsteps.com/facetman/graphoutputfile.htm>
- Table 9 bias-iteration report: <https://www.winsteps.com/facetman/table9.htm>
- Table 10 unexpected-after-bias report: <https://www.winsteps.com/facetman/table10.htm>
- Table 11 bias-calculation counts report: <https://www.winsteps.com/facetman/table11.htm>
- Table 12 DIF/bias summary report: <https://www.winsteps.com/facetman/table12.htm>
- Table 13 DIF/bias detail report: <https://www.winsteps.com/facetman/table13.htm>
- Table 14 pairwise bias report: <https://www.winsteps.com/facetman/table14.htm>
- Score file fixed-field columns: <https://www.winsteps.com/facetman64/scorefileinvisible.htm>

## Implemented (Direct or Close Compatibility Surface)
- Core multifacet estimation (RSM/PCM, MML/JML): `fit_mfrm()` / `mfrm_estimate()`
- Diagnostics core bundle (obs, fit, reliability, interactions, subsets): `diagnose_mfrm()`
- Table 1-style specification summary: `specifications_report()`
- Table 2-style data summary report: `data_quality_report()`
- Table 3-style iteration report (replayed): `estimation_iteration_report()`
- Table 4-style unexpected responses: `unexpected_response_table()`, `plot_unexpected()`
- Table 5-style measurable summary bundle: `measurable_summary_table()`
- Table 6.0.0-style subset/disjoint listing: `subset_connectivity_report()`
- Table 6.2-style facet-statistics graphic summary: `facet_statistics_report()`
- Table 7-style facet/person measures and fit summary: `diagnose_mfrm()` + `summary.mfrm_fit()`
- Table 7 reliability + facet chi-square style summaries: `diagnose_mfrm()$reliability`, `diagnose_mfrm()$facets_chisq`, `facets_chisq_table()`, `plot_facets_chisq()`
- Table 7 agreement style summaries: `diagnose_mfrm()$interrater`, `interrater_agreement_table()`, `rater_network_analysis()`, `rater_halo_network_analysis()`, `plot_interrater_agreement()`
- FACETS terminology crosswalk: `facets_term_crosswalk()` maps common FACETS
  table, column, command, file, and graph terms such as `Measure`, `S.E.`,
  `ZSTD`, `Rating Scale=`, `Graphfile`, and `Anchorfile=` to the closest
  mfrmr route and records the interpretation boundary.
- Wright/variable-map visual display: `plot(fit, type = "wright")`,
  `plot_wright_unified()`, and `plot_data(type = "wright")`
- FACETS visual surface contract: `facets_visual_contract()` maps Table 6,
  Table 8, Graphs-menu curves, DIF/bias Excel plots, Graphfile output, and
  R/Web plot menus to package-native plot, plot-data, and `as_ggplot()` routes.
  It separates the FACETS expectation, first `mfrmr` route, editable data
  route, report use, migration note, and claim boundary.
- Table 8.1-style rating scale bundle: `rating_scale_table()`
- FACETS partial-credit rating-scale structures:
  `fit_mfrm(model = "PCM", step_facet = ...)` estimates threshold structures
  by the designated step facet. The clearest rater-analysis example is
  `step_facet = "Rater"`, where each rater receives their own category-use
  thresholds under a FACETS partial-credit or `Specific` scale structure.
  `step_facet = "Item"` and `step_facet = "Criterion"` are the corresponding
  item- and criterion-specific routes. Design-matrix packages may describe
  these threshold blocks as `rater:step`, `item:step`, or `criterion:step`;
  mfrmr records those only as external comparison metadata in
  `fit$config$design_spec`.
- Table 8-style bar-chart and curves exporters: `category_structure_report()`,
  `category_curves_report()`, including cumulative probability, total
  information, and category-specific information curve data
- Output-file emulation (`GRAPH=` / `SCORE=` style): `facets_output_file_bundle()`
- Standalone residual and subset handoff files:
  `write_mfrm_residual_file()` and `write_mfrm_subset_file()`
- FACETS fit/score-file import: `read_facets_fit_table()` /
  `import_facets_fit_table()` for delimited and fixed-field score-file extracts
- Table 12 fair-average style output bundle: `fair_average_table()`, `plot_fair_average()`
- Displacement diagnostics (FACETS-style anchor drift check): `displacement_table()`, `plot_displacement()`
- Bias re-estimation iteration (Table 9 workflow): `estimate_bias()` / `estimate_bias_interaction()`
- Table 10-style unexpected-after-bias output: `unexpected_after_bias_table()`
- Table 11-style bias-count report: `bias_count_table()`
- Table 12/13/14 style bias outputs:
  - summary/detail: `estimate_bias()` result (`summary`, `table`, `chi_sq`)
  - higher-order mode (3+ facets): `estimate_bias(..., interaction_facets = c(...))`
  - pairwise: `bias_pairwise_report()` for structured review and
    `build_fixed_reports()` (`pairwise_table`, `pairwise_fixed`) for 2-way
    fixed-report handoff
  - Table 13 plot export: `bias_interaction_report()`, `plot_bias_interaction()` (including `facet_profile` mode)
- Fixed-width report generation: `build_fixed_reports()`
- APA narrative/table helpers: `build_apa_outputs()`, `apa_table()`
- Residual PCA checks (overall + by facet): `analyze_residual_pca()`, `plot_residual_pca()`
- QC dashboard (base graphics): `plot_qc_dashboard()`
- Anchor workflow: `review_mfrm_anchors()`, `make_anchor_table()`
- Anchor/linking contract: `anchor_linking_contract()` separates candidate
  anchors, anchors used in the current fit, group anchors, displacement review,
  R-native replay metadata, and unsupported FACETS `Labels=` / `Anchorfile=`
  command-file surfaces.
- Data packaging/loading helpers: `list_mfrmr_data()`, `load_mfrmr_data()`
- FACETS feature coverage boundary: `facets_feature_coverage()`
- Automated FACETS output-contract reviews (columns + core metrics):
  `facets_output_contract_review()`, `tests/testthat/test-facets-column-contract.R`,
  `tests/testthat/test-facets-metric-contract.R`,
  `inst/references/facets_column_contract.csv`

## Partial (Implemented Concept, Not Exact FACETS Output)
- Design policy:
  - structured tables and visualization APIs are primary deliverables
  - fixed-width / line-printer text is optional and secondary (traceability/log use)
  - exact FACETS line-printer emulation is intentionally out of scope
  - FACETS-style routes are transition and reporting aids, not claims that
    FACETS produced or numerically determined the estimates
  - legacy numbered `table*` names are internal and not exported
- Table 1/2/3 reports:
  - current: `specifications_report()`, `data_quality_report()`, `estimation_iteration_report()` with structured output and optional fixed-width text
  - gap: FACETS fixed-width text layout and exact optimizer-internal iteration path are not yet 1:1
- Table 5 measurable data summary:
  - current: `measurable_summary_table()` and `describe_mfrm_data()`
    (including observed inter-rater agreement bundle). `measurable_summary_table()`
    now includes Table 5-style residual moment rows, raw-score error variance,
    explained-variance approximation, and an approximate global Pearson
    chi-square review.
  - gap: FACETS column-by-column fixed-width textual layout and exact
    command-output wording are not reproduced 1:1; the variance and Pearson
    rows are package-native approximations.
- Table 8.1 rating-scale report:
  - current: `rating_scale_table()` plus CCC/pathway visualization (`plot.mfrm_fit`, QC category panel)
  - gap: FACETS text layout and all legacy columns/order are not yet 1:1
- Table 8 bar-chart / probability-curves exporters:
  - current: `category_structure_report()` and `category_curves_report()` including Graphfile-style wide output, total information curves, category-specific information contributions, and optional fixed-width text mirrors
  - gap: exact FACETS line-printer artwork/fixed-column matching is intentionally not targeted
- Table 6.2 graphical facet-statistics report:
  - current: `facet_statistics_report()` with fixed-width `M/S/Q/X` rulers
  - gap: FACETS native table layout and printer-graph formatting are not yet 1:1
- FACETS visual surface:
  - current: `facets_visual_contract()` is the release-scoped handoff table for
    FACETS visual expectations, with routes to `plot(fit, type = "wright")`,
    `plot(fit, type = "pathway")`, `plot(fit, type = "ccc")`,
    `category_curves_report()`, `compute_information()`, `plot_information()`,
    `plot_bias_interaction()`, `facets_output_file_bundle(include = "graph")`,
    `plot_data()`, and `as_ggplot()` when a route returns `mfrm_plot_data`
  - current: the table exposes `FirstMfrmrRoute`, `EditableDataRoute`,
    `GgplotRoute`, `MigrationNote`, and `ClaimBoundary` so a FACETS user can
    distinguish the first inspection route from a custom figure route
  - gap: mfrmr does not reproduce FACETS graph-window interaction, clickable
    Webpage plots, Excel workbook bias plots, or line-printer visual artwork
- Output-file emulation (`GRAPH=` / `SCORE=`):
  - current: `facets_output_file_bundle()` with graph coordinates, observation-level modeled score export, optional fixed-width mirrors, and optional file writing
  - gap: FACETS command-level options, score-file field selection,
    one-file-per-facet fixed-field layout, and fixed-column file-writing
    compatibility are not yet 1:1
- Anchorfile-style output:
  - current: `make_anchor_table()`, `anchor_linking_contract()`, and
    `export_mfrm_bundle(include = "anchors")` export reusable R-native anchor
    tables, anchor-contract CSVs, and replay metadata from fitted estimates
  - gap: mfrmr does not write a complete FACETS `Anchorfile=` specification
    file with final measures, scale calibrations, current settings, optional
    embedded data, and `,A` anchor flags
- Standalone residual/subset handoff:
  - current: `write_mfrm_residual_file()` exports observation-level residual rows; `write_mfrm_subset_file()` exports connected-subset summary and node-membership tables
  - gap: these are package-native CSV/TSV review files, not exact FACETS fixed-field command files
- Table 14 pairwise contrast report:
  - current: available for 2-way bias runs via `build_fixed_reports()`
  - gap: FACETS native layout and options are broader; higher-order runs intentionally omit pairwise section

## FACETS Command/Model Surface Boundary

The FACETS help does not only define output tables. It also defines a command
language and model surface that can change the estimand. These rows should not
be presented as implemented merely because `mfrmr` has similarly named output
helpers.

| FACETS surface | mfrmr status | Current route | Boundary |
| --- | --- | --- | --- |
| Multiple simultaneous `Model=` statements and heterogeneous response families | Not implemented | Separate explicit `fit_mfrm()` calls | FACETS can assign observations to different model statements in one analysis; mfrmr fits one response-model family per call. |
| `Model=` matching/control characters (`?`, `#`, ranges, `@`, `-?`, `X`, `0`) | Partial | `model`, `step_facet`, `positive_facets`, `dummy_facets` | Common roles and constraints are explicit R arguments, not a FACETS command parser. |
| `B` interaction terms in `Model=` | Partial | `facet_interactions`, `estimate_bias()`, `bias_interaction_report()` | Two-way interaction/bias routes exist, but not FACETS `B` syntax or arbitrary higher-order model dispatch. |
| Dichotomy and `Dn` dichotomization | Partial | Ordered two-category scores in `fit_mfrm()` | Binary Rasch scoring is supported; FACETS `Dn` dichotomization syntax is not. |
| `M` model-code missingness | Partial | `missing_codes`, `recode_missing_codes()` | Sentinel recoding is data-level; FACETS row-matching `Model=M` behavior is not parsed. |
| `Bn`, `B100`, and `P` response families | Not implemented | none | Binomial/Bernoulli trial, percentage-as-binomial, and Poisson likelihoods are outside the current release. |
| Model-statement weights and `R`-prefixed data replication | Partial | `weight_col` | mfrmr accepts observation weights but does not parse FACETS model-statement weights, zero-weight residual semantics, SE adjustment, or replication syntax. |
| Named `Rating Scale=` blocks, `General`, and `Specific` | Partial | `RSM`; `PCM` with `step_facet = "Rater"` or another facet; `fit$config$design_spec` | The threshold structures are available, but named scale blocks and per-model-statement dispatch are not. |
| Category labels, recoding/collapsing, and anchored step values in `Rating Scale=` | Partial | `rating_min`, `rating_max`, `keep_original`, `score_map`, anchor tables | mfrmr supports integer category support and observed-gap recoding, not FACETS category-label/recode grammar or rating-scale step anchors. |
| `Labels=` element numbers, groups, weights, and target elements | Partial | `anchors`, `group_anchors`, `review_mfrm_anchors()`, `anchor_linking_contract()` | Anchor tables are R-native. FACETS element-number management and label-file rewrite are not implemented. |
| `Anchorfile=` complete specification rewrite | Partial | `make_anchor_table()`, `anchor_linking_contract()`, `export_mfrm_bundle(include = "anchors")` | Exports reusable R-native anchor tables, contract CSVs, and replay metadata, not a full FACETS specification file with `,A` flags and final scale blocks. |
| Output dialog Webpage/SPSS/Excel/Word/Rdata/field-selection routes | Not targeted | `export_mfrm_results()`, `export_mfrm_bundle()`, `plot_data()` | Package-native tabular and plot-data exports are supported; FACETS UI-driven external-application output is not a release goal. |

## Not Yet Implemented or Not Targeted from Output Index Scope

The public helper `facets_term_crosswalk()` is the terminology index for
FACETS-facing readers. `facets_feature_coverage()` is the canonical feature
coverage boundary for the current release. Main FACETS surfaces that are not
fully implemented include:

- FACETS binomial-trial and Poisson-specific dichotomous reports.
- Multiple simultaneous FACETS `Model=` statements in one analysis.
- FACETS command-character parsing and row-level model dispatch.
- FACETS `Dn`, `M`, `Bn`, `B100`, `P`, model-statement weight, and
  `R`-replication syntax.
- Named `Rating Scale=` block parsing, category-label/recode grammar, and
  rating-scale step-anchor specification.
- Full `Labels=` / `Anchorfile=` command-file rewrite with final estimates,
  scale calibrations, current settings, embedded data, and `,A` flags.
- Exact FACETS line-printer report emulation across the full output stack.
- Arbitrary FACETS R/Web/Excel menu plots.
- FACETS Output Dialog routes to Webpage, SPSS `.sav`, Excel, Word, Rdata,
  and user-selected field sets.
- Exact FACETS/gtheory user-interface reproduction; package-native
  `mfrm_generalizability()` / `mfrm_d_study()` cover observed G-study and
  D-study planning evidence.
- Exact FACETS-style network-graph menu output; package-native
  `subset_connectivity_report()` / `mfrm_network_analysis()` /
  `rater_network_analysis()` / `rater_halo_network_analysis()` /
  `plot(..., type = "network")` provide the R graph route, reusable node/edge
  tables, design-network vulnerability diagnostics, rater
  agreement/disagreement/severity-direction networks, and rater-by-criterion
  halo-network screening.
- Winsteps control/data-file export.
- Exact fixed-field FACETS residual-file and subset command-file syntax.
- Exact FACETS graph-window rendering of cumulative probability curves; the
  package-native curve data and base-R plot route are implemented.
- Arbitrary FACETS command-file parsing.

Most high-priority measurement outputs used in ordinary MFRM reporting are
covered by structured R routes; remaining gaps are mostly external-program,
menu-output, or exact-format compatibility surfaces.

## Anchoring Rules Encoded
- Direct anchors (`Facet`, `Level`, `Anchor`) are fixed.
- Group anchors (`Facet`, `Level`, `Group`, `GroupValue`) constrain group means.
- If a level appears in both tables, direct anchor takes precedence.
- Missing `GroupValue` is treated as 0.
- `anchor_linking_contract()` is the release-scoped machine-readable handoff
  table for these rules and for the FACETS `Anchorfile=` non-goal.
- Default recommendation thresholds:
  - common anchors per linking facet: `>= 5`
  - observations per element: `>= 30`
  - observations per score category: `>= 10`

## Pre-release Status (Current)
- Core estimation and diagnostics: available in the current branch
- New inter-rater and facet-chi-square APIs: implemented and tested
- Remaining work for closer FACETS-format compatibility is mostly
  report-format completeness, not model-estimation correctness
