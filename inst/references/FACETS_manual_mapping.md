# FACETS Manual Mapping

This package documents a FACETS-style reporting and handoff surface while
keeping a native R implementation. The mapping is a package-output contract
reference, not evidence that FACETS was executed or that numerical FACETS
equivalence has been established. mfrmr estimates, diagnostics, plot payloads,
and report bundles remain the source of truth unless external FACETS output is
explicitly supplied for comparison.

Reviewed against the 0.2.4 development routes on October 14, 2026. Use
`facets_feature_coverage()` for current route-level limits and
`help("mfrmr_methods_reference")` for calculation assumptions and literature.
The ordinary diagnostic/report routes below are not automatically available
for two-family GPCM or corrected JML merely because they share `mfrm_fit`.
Consult `gpcm_capability_matrix()` and the model-specific result help.
Plotting uses `plot()` on fitted models or saved analysis results in 0.2.4.
See `help("mfrmr_plot_migration")` for replacements of the former drawing helpers.

## Manual References Used
- Output table index (64-bit): <https://www.winsteps.com/facetman64/outputtableindex.htm>
- Output table index (32-bit archive): <https://www.winsteps.com/facetman/outputtableindex.htm>
- Table 5 measurable data summary: <https://www.winsteps.com/facetman/table5.htm>
- Table 7 measurement report: <https://www.winsteps.com/facetman/table7.htm>
- Table 7 reliability/chi-square notes: <https://www.winsteps.com/facetman/table7summarystatistics.htm>
- Table 7 agreement notes: <https://www.winsteps.com/facetman/table7agreementstatistics.htm>
- Table 8.1 rating scale report: <https://www.winsteps.com/facetman/table8_1ratingscale.htm>
- Table 8 bar-chart report: <https://www.winsteps.com/facetman/table8barchart.htm>
- Table 8 probability-curves report: <https://www.winsteps.com/facetman/table8curves.htm>
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
- Table 4-style unexpected responses: `unexpected_response_table()`, `plot(fit, type = "unexpected")`
- Table 5-style measurable summary bundle: `measurable_summary_table()`
- Table 6.0.0-style subset/disjoint listing: `subset_connectivity_report()`
- Table 6.2-style facet-statistics graphic summary: `facet_statistics_report()`
- Table 7-style facet/person measures and fit summary: `diagnose_mfrm()` + `summary.mfrm_fit()`
- Table 7 reliability + facet chi-square style summaries: `diagnose_mfrm()$reliability`, `diagnose_mfrm()$facets_chisq`, `facets_chisq_table()`, `plot(fit, type = "facets_chisq")`
- Table 7 agreement style summaries: `diagnose_mfrm()$interrater`, `interrater_agreement_table()`, `rater_network_analysis()`, `rater_halo_network_analysis()`, `plot(fit, type = "agreement")`
- Table 6-style Wright/variable-map visual display:
  `plot(fit, type = "wright", view = "unified", renderer = "facets")` provides the shared
  logit ruler, person-frequency asterisks, signed facet columns, and labeled
  score-transition lines; `renderer = "native"` retains the package-native
  facet SE/CI display. Both routes expose editable draw-free data.
- Fit-oriented pathway display:
  `plot(fit, type = "fit_pathway", fit_stat = "Infit", include_person = TRUE, top_n_person = 12)`
  places Infit/Outfit on the x-axis and measure logits on the y-axis without
  changing the existing expected-score `type = "pathway"` contract.
- Table 8.1-style rating scale bundle: `rating_scale_table()`
- Table 8-style bar-chart and curves exporters: `category_structure_report()`,
  `category_curves_report()`, including cumulative probability, total
  information, and category-specific information curve data
- Output-file emulation (`GRAPH=` / `SCORE=` style): `facets_output_file_bundle()`
- Standalone residual and subset handoff files:
  `write_mfrm_residual_file()` and `write_mfrm_subset_file()`
- FACETS fit/score-file import: `read_facets_fit_table()` /
  `import_facets_fit_table()` for delimited and fixed-field score-file extracts
- Fair-average measurement summaries: `fair_average_table()`, `plot(fit, type = "fair_average")`.
  The package's column-contract CSV retains a legacy `Table 12` identifier
  for this bundle. It is not the FACETS Table 12, which is the
  [bias summary report](https://www.winsteps.com/facetman64/table12.htm).
- Displacement diagnostics (FACETS-style anchor drift check): `displacement_table()`, `plot(fit, type = "displacement")`
- Bias re-estimation iteration (Table 9 workflow): `estimate_bias()` / `estimate_bias_interaction()`
- Table 10-style unexpected-after-bias output: `unexpected_after_bias_table()`
- Table 11-style bias-count report: `bias_count_table()`
- Table 12/13/14 style bias outputs:
  - summary/detail: `estimate_bias()` result (`summary`, `table`, `chi_sq`)
  - higher-order mode (3+ facets): `estimate_bias(..., interaction_facets = c(...))`
  - pairwise: `bias_pairwise_report()` for structured review and
    `build_fixed_reports()` (`pairwise_table`, `pairwise_fixed`) for 2-way
    fixed-report handoff
  - Table 13 plot export: `bias_interaction_report()` → `plot(result, type = "bias")` (including `view = "facet_profile"`)
- Fixed-width report generation: `build_fixed_reports()`
- APA narrative/table helpers: `build_apa_outputs()`, `apa_table()`
- Residual PCA checks (overall + by facet): `analyze_residual_pca()` → `plot(result, type = "scree")` (use `mode = "facet"` and `facet` for a facet-specific view)
- QC dashboard (base graphics): `plot(fit, type = "qc")`
- Anchor workflow: `review_mfrm_anchors()`, `make_anchor_table()`
- Data packaging/loading helpers: `list_mfrmr_data()`, `load_mfrmr_data()`
- FACETS feature coverage boundary: `facets_feature_coverage()`
- FACETS output-contract review:
  `facets_output_contract_review()` checks the documented package columns and
  metrics. A numerical comparison still requires output from a separately run,
  documented FACETS version under aligned settings.

## Capabilities, Limitations, and Alternatives

### Wright and variable maps

- Capability: `plot(fit, type = "wright", view = "unified", renderer = "facets")` provides the shared
  ruler, person-frequency asterisks, signed facet columns, and labelled score
  transitions. The native renderer adds SE/CI information.
- Limitation: visual correspondence does not establish pixel identity or
  numerical equivalence across software versions.
- Alternative: retain the native uncertainty-aware map for analysis. When
  numerical comparison is required, supply aligned external FACETS output to
  `facets_fit_review()`.

### Specification, data, iteration, and measurement tables

- Capability: `specifications_report()`, `data_quality_report()`,
  `estimation_iteration_report()`, `measurable_summary_table()`, and
  `fit_measures_table()` provide structured R tables.
- Limitation: column order, fixed-width layout, and the complete FACETS
  iteration trace are not reproduced.
- Alternative: use the structured tables for analysis and export; use FACETS
  externally when its exact report layout is required.

### Rating-scale tables and curves

- Capability: `rating_scale_table()`, `category_structure_report()`, and
  `category_curves_report()` provide category, threshold, expected-score, and
  information-curve data.
- Limitation: FACETS printer artwork, graph-window behavior, and every legacy
  column option are not reproduced.
- Alternative: use package plot data for custom R graphics, or use FACETS
  externally for its program-specific display.

### Graph, score, residual, and subset handoff

- Capability: `facets_output_file_bundle()`,
  `write_mfrm_residual_file()`, and `write_mfrm_subset_file()` provide
  documented CSV/TSV or fixed-width handoff routes.
- Limitation: these are package-native contracts rather than complete FACETS
  command-file or fixed-field compatibility.
- Alternative: use the package files for reproducible R workflows; use FACETS
  externally when a downstream system requires its exact syntax.

### Bias and pairwise contrasts

- Capability: two-way bias runs provide structured pairwise output through
  `bias_pairwise_report()` and `build_fixed_reports()`.
- Limitation: FACETS layout and options are broader, and higher-order runs omit
  the pairwise section.
- Alternative: report the available structured contrasts and their screening
  boundary; redesign the contrast or use FACETS externally if a missing
  FACETS-specific report is required.

Package bias screens condition on the supplied calibration. Re-estimating a
bias cell does not propagate the joint uncertainty of all calibration
parameters. The accompanying intervals and pairwise summaries are not
full-covariance structural tests.

### Separation, agreement and assessment planning

High rater separation reliability indicates distinguishable severities,
not high observed agreement. Low separation can also result from imprecise
measures. Strata describes hypothetical distinguishable levels, not discovered
groups. See the [FACETS interpretation](https://www.winsteps.com/facetman64/reliability.htm)
and the estimator-specific formulas in `help("diagnose_mfrm")`.

The [FACETS G-theory menu](https://www.winsteps.com/facetman64/gtheory.htm)
launches the external R package `gtheory`. mfrmr's own
`mfrm_multivariate_gstudy()` / `mfrm_multivariate_d_study()` route handles
supported univariate or multivariate observed-score designs, interactions,
composites and future complete plans. Its component/covariance plots and
D-study curves retain negative components and unavailable metrics. For balanced
ANOVA, `confint(g, assumption = "normal")` supplies component SEs and intervals
for one score or a fixed composite. Two-score covariance intervals now have
explicit generalized and conservative choices with signed bounds. Scalar
component `reml_profile` intervals also accept identifiable MINQUE(0) sources,
retaining original points and separate REML centers but not supplying sampling
SEs. Explicit joint `reml_profile` also supplies signed two-score covariance
intervals for identifiable incomplete sources. This is experimental, has no
sampling SE and does not establish finite-sample coverage or a default method.
Separately, `vcov(g, assumption = "normal")` provides sampling covariance and
SEs for the original ANOVA/MINQUE component estimates, including incomplete
sources. Product-moment correction retains negative or unidentified sampling
variances; it does not describe the separate REML estimator or validate
normal-reference confidence intervals.
For individual G/Phi in balanced two-crossed-facet sources, the default is
approximate MLS null inversion. Undefined MLS widths are conservatively
retained and flagged separately from numerical availability; small-source
intervals may be very wide. This is normal-model approximate inference,
not a transfer of FACETS intervals or a uniform-coverage guarantee.
Balanced crossed G also offers an explicit experimental `score` interval,
using expected information and extended nuisance mean-square expectations.
It preserves original points and distinguishes empty numerical confidence
sets from calculation failures; this does not supply Phi or paired differences.
For G/Phi and SEM, explicit experimental
`reml_profile` accepts balanced or identifiable incomplete sources under
normal effects. Its separate REML fit preserves the original points and uses
approximate likelihood-ratio calibration, without a finite-sample or boundary
coverage guarantee. SEM profiles constrain error variance directly and report
the interval around the REML center without enumerating remote disconnected
accepted regions. With `reference`, one-facet plans or nested plans with a
common future child count have shared-profile G/Phi/SEM difference intervals,
including incomplete sources. These preserve interior extrema, original
points and the base approximation; nonproportional future errors remain
outside this transformation. `mfrm_multivariate_d_compare()` has a separate
normal-theory paired-plan scope. The older `mfrm_generalizability()` /
`mfrm_d_study()` adapter uses a simpler main-effects model and an explicit
residual-scaling rule. These decompositions are not interchangeable. Follow
`vignette("mfrmr-gtheory", package = "mfrmr")`; no MFRM fit is needed for the
multivariate route, and none of these coefficients is MFRM separation reliability.

## Unsupported or External-Only FACETS Surfaces

The public `facets_feature_coverage()` table is the canonical capability
reference. Its `Capability`, `Limitation`, and `Alternative` columns describe
the appropriate route for each surface. External-only areas include:

- FACETS binomial-trial and Poisson-specific reports; use the package's
  two-category ordered-score route only when that model is appropriate.
- Complete FACETS line-printer report emulation; use structured package tables
  or run FACETS for the exact report.
- Arbitrary FACETS R/Web/Excel menu plots; use `plot_data()` with an R graphics
  system or run FACETS for those menu outputs.
- The FACETS/gtheory interface itself; use the package-native observed-score
  G/D routes above for their documented designs.
- FACETS network-menu output; use `subset_connectivity_report()`,
  `mfrm_network_analysis()`, `rater_network_analysis()`, or
  `rater_halo_network_analysis()` for reusable R node and edge tables.
- Winsteps control/data-file export; use Winsteps externally when that format
  is required.
- Arbitrary FACETS command-file and raw-report parsing; provide supported
  delimited or fixed-field fit extracts to `read_facets_fit_table()` instead.

## Anchoring Rules Encoded
- Direct anchors (`Facet`, `Level`, `Anchor`) are fixed.
- Group anchors (`Facet`, `Level`, `Group`, `GroupValue`) constrain group means.
- If a level appears in both tables, direct anchor takes precedence.
- Missing `GroupValue` is treated as 0.
- Default review thresholds (not universal adequacy or identification rules):
  - common anchors per linking facet: `>= 5`
  - observations per element: `>= 30`
  - observations per score category: `>= 10`
