# Build report-ready output from `mfrm_results()`

`mfrm_report()` is a report-synthesis layer for an existing
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
object. It does not refit the model, recompute diagnostics, or add new
validity rules. Instead, it turns the comprehensive first-screen result
into a first-screen table, section plan, claim-readiness table,
report-gap table, report-index table, template-index table, fit-criteria
table, result-specific fit evidence summaries, fit-reporting wording
templates, precision/separation reporting templates, bias/DFF reporting
templates, misfit/pathway reporting templates, linking/anchor reporting
templates, ZSTD-convention table, evidence-boundary table, next-action
table, and optional Markdown or HTML report.

## Usage

``` r
mfrm_report(
  x,
  style = c("qc", "apa", "validation", "reviewer", "technical"),
  output = c("object", "markdown", "html", "tables")
)
```

## Arguments

- x:

  An
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  object.

- style:

  Report emphasis. `"qc"` is the default first-screen report. `"apa"`
  emphasizes manuscript wording, `"validation"` emphasizes the
  validity-argument boundary, `"reviewer"` emphasizes reviewer response
  preparation, and `"technical"` emphasizes appendix/reproducibility
  routes.

- output:

  Return format: `"object"` for an `mfrm_report` object, `"markdown"`
  for a character scalar, `"html"` for a temporary HTML file, or
  `"tables"` for the report's named data-frame list.

## Value

Depending on `output`, an `mfrm_report` object, a Markdown character
scalar, an `mfrm_report_html` object, or a named list of data frames.

## Details

The intended workflow is:

1.  Create `res <- mfrm_results(fit, include = ...)`.

2.  Inspect `summary(res)$triage` and `summary(res)$next_actions`.

3.  Create `report <- mfrm_report(res, style = "qc")`.

4.  Read `summary(report)` and `report$first_screen` before opening
    detailed report tables.

5.  Use `report$report_index` to choose the next `PrimaryTable`,
    `TemplateTable`, plot route, or export route.

6.  Use `report$template_index` before copying APA/QC/validation
    wording.

7.  Use `style = "apa"`, `"validation"`, `"reviewer"`, or `"technical"`
    only when that reporting question is needed.

Report rows deliberately distinguish evidence from claims. The
`first_screen` table is the compact entry point: it gives an overall row
and one row per major evidence area with status, readiness, main issue,
next action, and primary route. The `summary.mfrm_report` method
summarizes that first screen into immediate actions, optional
not-requested sections, claim-readiness counts, report gaps, and
template-boundary rows without introducing a new pass/fail decision. The
default print method follows the same short reading order and does not
print every detailed evidence table. HTML output places the same reader
guidance and report-summary tables before the full Markdown text so the
browser view starts from the first-screen route. The `report_index`
table is the detailed evidence-route index: it lists the major report
areas, evidence status, readiness label, review-signal count, and the
primary/template tables, evidence routes, template routes, plot routes,
export route, and `mfrm_results(include = ...)` preset to inspect next.
In ordinary use, open detailed tables through the `PrimaryTable` and
`TemplateTable` columns rather than scanning every element of
`report$tables`. The `template_index` table then stacks all fit,
precision, bias, misfit, and linking wording templates into a single
boundary/claim-strength index before users drill into the area-specific
template tables. The `claim_readiness` table marks which report claims
are ready, caveated, unavailable, or require additional requested
sections. The `report_gaps` table turns those statuses into follow-up
actions. The fit-specific tables keep multiple MnSq threshold profiles,
observed fit-status counts, and engine-vs-FACETS-style ZSTD conventions
visible, including the small-df/capping boundary used for FACETS-style
ZSTD review. They summarize the stored `fit_measures` component from
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md);
`mfrm_report()` itself does not recompute diagnostics. The
`fit_reporting_templates` table turns those counts into cautious
reporting language while keeping MnSq, ZSTD standardization, df
sensitivity, and separation/reliability in separate sentences. All
reporting-template tables share `EvidenceTable`, `EvidenceRoute`,
`BoundaryType`, `ClaimStrength`, and `RecommendedUse` columns so each
template can be traced back to its evidence and claim boundary. The
default `RecommendedUse` is `"report_with_context"`; more restrictive
rows request evidence, identify a methods or appendix caveat, or require
targeted follow-up. `template_index` stacks those columns across all
template areas so report authors can review unsupported or caveated
wording before opening the full template text. The
`precision_reporting_templates` table does the same for separation,
reliability, and strata using the stored precision review and
`diagnostics$reliability`. The `bias_reporting_templates` table is
available when the source result was built with `include = "bias"` and
keeps facet-level screens, interaction-bias contrasts, DFF follow-up,
and fairness conclusions in separate lanes. The
`misfit_reporting_templates` table is available when the source result
was built with `include = "misfit_review"` and keeps unexpected
responses, displacement, pathway-map evidence, and case-review actions
separate. The `linking_reporting_templates` table is available when the
source result was built with `include = "linking"` and keeps anchor
readiness, drift review, equating-chain review, and GPCM support
boundaries separate. For example, fit and separation are not collapsed
into a single pass/fail statement; bias screens are not treated as final
fairness conclusions; pathway/misfit rows are case-review prompts; and
drift/equating claims require multiple fitted forms or waves.

## See also

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:6], , drop = FALSE]
fit <- fit_mfrm(toy_small, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
res <- mfrm_results(fit, include = c("fit", "diagnostics", "tables"))

report <- mfrm_report(res, style = "qc")
summary(report)
#> mfrmr Report Summary
#> 
#> Overview
#>  Style OverallStatus     FirstAction ReviewAreas NotComputedAreas CaveatAreas
#>     qc        review Start with Fit.           1                0           1
#>  OptionalAreas UnavailableAreas OkAreas            SourceInclude
#>              3                0       0 fit, diagnostics, tables
#> 
#> First screen
#>               Area            Status         Readiness
#>            Overall            review            review
#>                Fit            review            review
#>          Precision            caveat write_with_caveat
#>         Bias / DFF request_if_needed request_if_needed
#>  Linking / anchors request_if_needed request_if_needed
#>   Misfit / pathway request_if_needed request_if_needed
#>                                                                      MainIssue
#>  ok=0; review=1; caveat=1; request_if_needed=3; not_computed=0; unavailable=0.
#>                   ReviewSignalCount = 8; underfit=0; overfit=0; df_sensitive=8
#>             ReviewSignalCount = 4; tier=NA; review_warn=NA; reliability_rows=3
#>                                                    Evidence was not requested.
#>                                                    Evidence was not requested.
#>                                                    Evidence was not requested.
#>                                                                NextAction
#>                                                           Start with Fit.
#>  Inspect the primary evidence table and template boundary before writing.
#>             Use caveated wording and inspect the boundary before writing.
#>                        Request this evidence only if the claim is needed.
#>                        Request this evidence only if the claim is needed.
#>                        Request this evidence only if the claim is needed.
#>                                  PrimaryRoute
#>    report$report_index; report$template_index
#>                   report$fit_evidence_summary
#>             report$precision_evidence_summary
#>           mfrm_results(fit, include = "bias")
#>        mfrm_results(fit, include = "linking")
#>  mfrm_results(fit, include = "misfit_review")
#> 
#> Immediate actions
#>       Area Status
#>        Fit review
#>  Precision caveat
#>                                                           MainIssue
#>        ReviewSignalCount = 8; underfit=0; overfit=0; df_sensitive=8
#>  ReviewSignalCount = 4; tier=NA; review_warn=NA; reliability_rows=3
#>                                                                NextAction
#>  Inspect the primary evidence table and template boundary before writing.
#>             Use caveated wording and inspect the boundary before writing.
#>                       PrimaryRoute                        TemplateRoute
#>        report$fit_evidence_summary       report$fit_reporting_templates
#>  report$precision_evidence_summary report$precision_reporting_templates
#> 
#> Optional sections not requested
#>               Area            Status                   MainIssue
#>         Bias / DFF request_if_needed Evidence was not requested.
#>  Linking / anchors request_if_needed Evidence was not requested.
#>   Misfit / pathway request_if_needed Evidence was not requested.
#>                                          NextAction
#>  Request this evidence only if the claim is needed.
#>  Request this evidence only if the claim is needed.
#>  Request this evidence only if the claim is needed.
#>                                  PrimaryRoute
#>           mfrm_results(fit, include = "bias")
#>        mfrm_results(fit, include = "linking")
#>  mfrm_results(fit, include = "misfit_review")
#> 
#> Claim readiness
#>                Readiness Claims                    ExampleClaim
#>  needs_requested_section      6       APA-style manuscript text
#>                    ready      4 Appendix or reviewer supplement
#> 
#> Report gaps
#>  Priority       GapType                        Section
#>         3 not_requested     APA and manuscript wording
#>         3 not_requested            Anchors and linking
#>         3 not_requested                 Bias screening
#>         3 not_requested Fit, separation, and precision
#>         3 not_requested      Misfit and pathway review
#>         3 not_requested       Network and connectivity
#>         3 not_requested               Response-time QC
#>                                                                                                   RecommendedAction
#>                   Rebuild the result with mfrm_results(fit, include = "publication") before using APA-style output.
#>                Rebuild the result with mfrm_results(fit, include = "linking") before writing anchor-readiness text.
#>            Rebuild the result with mfrm_results(fit, include = "bias") before writing bias or fairness-screen text.
#>          Request the relevant mfrm_results() section or call the route-specific helper before reporting this claim.
#>  Rebuild the result with mfrm_results(fit, include = "misfit_review") before writing observation-level misfit text.
#>                    Rebuild the result with mfrm_results(fit, include = "network") before writing connectivity text.
#>          Request the relevant mfrm_results() section or call the route-specific helper before reporting this claim.
#>                                                                                                                           Route
#>                                                                 mfrm_results(fit, include = "publication"); build_apa_outputs()
#>                                                             mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#>                                                 mfrm_results(fit, include = "bias"); estimate_bias(); bias_interaction_report()
#>                                             summary(res$components$precision_review); precision_review_report(fit, diagnostics)
#>                                                       mfrm_results(fit, include = "misfit_review"); plot(res, type = "pathway")
#>                                                             mfrm_results(fit, include = "network"); build_mfrm_network_review()
#>  mfrm_results(fit, include = "response_time", response_time = ..., response_time_data = ...); plot(res, type = "response_time")
#> 
#> Boundary index
#>               Area                           Topic                 BoundaryType
#>         Bias / DFF Bias/DFF evidence not requested screen_not_fairness_decision
#>  Linking / anchors  Linking evidence not requested     anchor_not_drift_absence
#>                Fit              Fit-status wording             fit_not_validity
#>                Fit                Boundary wording             fit_not_validity
#>          Precision          Precision-tier wording      precision_not_agreement
#>          Precision              Separation wording      precision_not_agreement
#>          Precision             Reliability wording      precision_not_agreement
#>          Precision                  Strata wording      precision_not_agreement
#>                   ClaimStrength                  RecommendedUse
#>  not_supported_without_followup  targeted_followup_before_claim
#>  not_supported_without_followup request_evidence_before_writing
#>                descriptive_only             report_with_context
#>                descriptive_only             reporting_guardrail
#>                descriptive_only             report_with_context
#>                descriptive_only             report_with_context
#>                descriptive_only             report_with_context
#>                descriptive_only             report_with_context
#>                      EvidenceRoute
#>       report$bias_evidence_summary
#>    report$linking_evidence_summary
#>        report$fit_evidence_summary
#>         report$fit_decision_policy
#>  report$precision_evidence_summary
#>        res$diagnostics$reliability
#>        res$diagnostics$reliability
#>             report$precision_basis
report$first_screen
#>                Area            Status         Readiness
#> 1           Overall            review            review
#> 2               Fit            review            review
#> 3         Precision            caveat write_with_caveat
#> 4        Bias / DFF request_if_needed request_if_needed
#> 5 Linking / anchors request_if_needed request_if_needed
#> 6  Misfit / pathway request_if_needed request_if_needed
#>                                                                       MainIssue
#> 1 ok=0; review=1; caveat=1; request_if_needed=3; not_computed=0; unavailable=0.
#> 2                  ReviewSignalCount = 8; underfit=0; overfit=0; df_sensitive=8
#> 3            ReviewSignalCount = 4; tier=NA; review_warn=NA; reliability_rows=3
#> 4                                                   Evidence was not requested.
#> 5                                                   Evidence was not requested.
#> 6                                                   Evidence was not requested.
#>                                                                 NextAction
#> 1                                                          Start with Fit.
#> 2 Inspect the primary evidence table and template boundary before writing.
#> 3            Use caveated wording and inspect the boundary before writing.
#> 4                       Request this evidence only if the claim is needed.
#> 5                       Request this evidence only if the claim is needed.
#> 6                       Request this evidence only if the claim is needed.
#>                                   PrimaryRoute
#> 1   report$report_index; report$template_index
#> 2                  report$fit_evidence_summary
#> 3            report$precision_evidence_summary
#> 4          mfrm_results(fit, include = "bias")
#> 5       mfrm_results(fit, include = "linking")
#> 6 mfrm_results(fit, include = "misfit_review")
#>                          TemplateRoute                   PlotRoute
#> 1                report$template_index                            
#> 2       report$fit_reporting_templates      plot(res, type = 'qc')
#> 3 report$precision_reporting_templates      plot(res, type = 'qc')
#> 4      report$bias_reporting_templates  plot(res, type = 'tables')
#> 5   report$linking_reporting_templates plot(res, type = "anchors")
#> 6    report$misfit_reporting_templates plot(res, type = 'pathway')
#>                   BoundaryType
#> 1         first_screen_summary
#> 2             fit_not_validity
#> 3      precision_not_agreement
#> 4 screen_not_fairness_decision
#> 5     anchor_not_drift_absence
#> 6    misfit_not_exclusion_rule
report$report_index[, c("Area", "Readiness", "PrimaryTable",
                        "TemplateTable", "PlotRoute")]
#>                Area         Readiness               PrimaryTable
#> 1               Fit            review       fit_evidence_summary
#> 2         Precision write_with_caveat precision_evidence_summary
#> 3        Bias / DFF request_if_needed      bias_evidence_summary
#> 4  Misfit / pathway request_if_needed    misfit_evidence_summary
#> 5 Linking / anchors request_if_needed   linking_evidence_summary
#>                   TemplateTable                   PlotRoute
#> 1       fit_reporting_templates      plot(res, type = 'qc')
#> 2 precision_reporting_templates      plot(res, type = 'qc')
#> 3      bias_reporting_templates  plot(res, type = 'tables')
#> 4    misfit_reporting_templates plot(res, type = 'pathway')
#> 5   linking_reporting_templates plot(res, type = "anchors")
report$template_index[, c("Area", "Topic", "BoundaryType",
                          "ClaimStrength", "EvidenceRoute")]
#>                 Area                                 Topic
#> 1         Bias / DFF       Bias/DFF evidence not requested
#> 2  Linking / anchors        Linking evidence not requested
#> 3                Fit             Threshold-profile wording
#> 4                Fit               ZSTD-convention wording
#> 5                Fit           DF/ZSTD sensitivity wording
#> 6   Misfit / pathway Misfit/pathway evidence not requested
#> 7                Fit                    Fit-status wording
#> 8                Fit                      Boundary wording
#> 9          Precision                Precision-tier wording
#> 10         Precision                    Separation wording
#> 11         Precision                   Reliability wording
#> 12         Precision                        Strata wording
#> 13         Precision                      Boundary wording
#>                    BoundaryType                  ClaimStrength
#> 1  screen_not_fairness_decision not_supported_without_followup
#> 2      anchor_not_drift_absence not_supported_without_followup
#> 3              fit_not_validity              write_with_caveat
#> 4              fit_not_validity              write_with_caveat
#> 5              fit_not_validity              write_with_caveat
#> 6     misfit_not_exclusion_rule              write_with_caveat
#> 7              fit_not_validity               descriptive_only
#> 8              fit_not_validity               descriptive_only
#> 9       precision_not_agreement               descriptive_only
#> 10      precision_not_agreement               descriptive_only
#> 11      precision_not_agreement               descriptive_only
#> 12      precision_not_agreement               descriptive_only
#> 13      precision_not_agreement               descriptive_only
#>                        EvidenceRoute
#> 1       report$bias_evidence_summary
#> 2    report$linking_evidence_summary
#> 3   report$fit_threshold_sensitivity
#> 4            report$zstd_conventions
#> 5  report$fit_df_sensitivity_summary
#> 6     report$misfit_evidence_summary
#> 7        report$fit_evidence_summary
#> 8         report$fit_decision_policy
#> 9  report$precision_evidence_summary
#> 10       res$diagnostics$reliability
#> 11       res$diagnostics$reliability
#> 12            report$precision_basis
#> 13            report$precision_basis

# Open detailed evidence only after the index points to it.
fit_primary <- report$report_index$PrimaryTable[
  report$report_index$Area == "Fit"
][1]
report$tables[[fit_primary]]
#>      Status Rows DisplayedRows UnderfitRows OverfitRows MixedRows
#> 1 available    8             8            0           0         0
#>   WithinBandRows NotAvailableRows DfComparedRows DfSensitiveRows
#> 1              8                0              8               8
#>   FlagChangedByDfRows LargeZSTDShiftRows DfConventionDifferenceRows FitDfMethod
#> 1                   0                  1                          7        both
#>   ThresholdProfiles FacetsCompanionAvailable                      Source
#> 1               all                     TRUE res$components$fit_measures
#>                                 Route
#> 1 res$components$fit_measures$summary
#>                                                                                                                                                         Boundary
#> 1 Counts summarize the stored fit-measures component. Interpret MnSq status, df-sensitive ZSTD shifts, separation, and reliability as separate evidence streams.

mfrm_report(res, output = "markdown")
#> [1] "# mfrmr QC Report\n\n## Narrative\n- Quality-control triage before manuscript, appendix, or reviewer handoff. The report is generated from an existing mfrm_results object and does not refit the model.\n- The source result uses model RSM with method JML and 96 observations.\n- Highest-priority first-screen signals: Diagnostics=review (diagnostic_warnings_present); Data review=ok (data_readiness_pass); Design / connectivity=ok (design_linked).\n- Use the section plan and evidence-boundary table to decide what can be written now, what needs a targeted follow-up helper, and what should remain caveated.\n\n## First Screen\n| Area | Status | Readiness | MainIssue | NextAction | PrimaryRoute | TemplateRoute | PlotRoute | BoundaryType |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| Overall | review | review | ok=0; review=1; caveat=1; request_if_needed=3; not_computed=0; unavailable=0. | Start with Fit. | report$report_index; report$template_index | report$template_index |  | first_screen_summary |\n| Fit | review | review | ReviewSignalCount = 8; underfit=0; overfit=0; df_sensitive=8 | Inspect the primary evidence table and template boundary before writing. | report$fit_evidence_summary | report$fit_reporting_templates | plot(res, type = 'qc') | fit_not_validity |\n| Precision | caveat | write_with_caveat | ReviewSignalCount = 4; tier=NA; review_warn=NA; reliability_rows=3 | Use caveated wording and inspect the boundary before writing. | report$precision_evidence_summary | report$precision_reporting_templates | plot(res, type = 'qc') | precision_not_agreement |\n| Bias / DFF | request_if_needed | request_if_needed | Evidence was not requested. | Request this evidence only if the claim is needed. | mfrm_results(fit, include = \"bias\") | report$bias_reporting_templates | plot(res, type = 'tables') | screen_not_fairness_decision |\n| Linking / anchors | request_if_needed | request_if_needed | Evidence was not requested. | Request this evidence only if the claim is needed. | mfrm_results(fit, include = \"linking\") | report$linking_reporting_templates | plot(res, type = \"anchors\") | anchor_not_drift_absence |\n| Misfit / pathway | request_if_needed | request_if_needed | Evidence was not requested. | Request this evidence only if the claim is needed. | mfrm_results(fit, include = \"misfit_review\") | report$misfit_reporting_templates | plot(res, type = 'pathway') | misfit_not_exclusion_rule |\n\n## Report Index\n| Area | Section | SectionStatus | EvidenceStatus | Readiness | ReviewSignalCount | EvidenceDetail | PrimaryTable | TemplateTable | Route | EvidenceRoute | TemplateRoute | PlotRoute | ExportRoute | IncludePreset | Boundary |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| Fit | Fit, separation, and precision | not_requested | available | review | 8 | underfit=0; overfit=0; df_sensitive=8 | fit_evidence_summary | fit_reporting_templates | report$fit_evidence_summary; report$fit_reporting_templates | report$fit_evidence_summary | report$fit_reporting_templates | plot(res, type = 'qc') | export_mfrm_results(res, include = \"report\") | mfrm_results(fit, include = c(\"fit\", \"diagnostics\", \"precision\", \"reporting\")) | Counts summarize the stored fit-measures component. Interpret MnSq status, df-sensitive ZSTD shifts, separation, and reliability as separate evidence streams. |\n| Precision | Fit, separation, and precision | not_requested | available_without_precision_review | write_with_caveat | 4 | tier=NA; review_warn=NA; reliability_rows=3 | precision_evidence_summary | precision_reporting_templates | report$precision_evidence_summary; report$precision_reporting_templates | report$precision_evidence_summary | report$precision_reporting_templates | plot(res, type = 'qc') | export_mfrm_results(res, include = \"report\") | mfrm_results(fit, include = c(\"fit\", \"diagnostics\", \"precision\", \"reporting\")) | Separation, reliability, and strata summarize spread relative to measurement error. They are not inter-rater agreement, model fit, or standalone validity evidence. |\n| Bias / DFF | Bias screening | not_requested | not_requested | request_if_needed | NA | screen_rows=NA; residual_screen=NA; chi_sq_screen=NA | bias_evidence_summary | bias_reporting_templates | report$bias_evidence_summary; report$bias_reporting_templates | report$bias_evidence_summary | report$bias_reporting_templates | plot(res, type = 'tables') | export_mfrm_results(res, include = \"report\") | mfrm_results(fit, include = \"bias\") | Bias/DFF wording requires the bias preset or an explicit bias/DFF helper call. Do not infer fairness conclusions from omitted sections. |\n| Misfit / pathway | Misfit and pathway review | not_requested | not_requested | request_if_needed | NA | unexpected=NA; displacement=NA; pathway=FALSE | misfit_evidence_summary | misfit_reporting_templates | report$misfit_evidence_summary; report$misfit_reporting_templates | report$misfit_evidence_summary | report$misfit_reporting_templates | plot(res, type = 'pathway') | export_mfrm_results(res, include = \"report\") | mfrm_results(fit, include = \"misfit_review\") | Misfit/pathway wording requires the misfit_review preset or explicit unexpected-response, displacement, and pathway helper calls. |\n| Linking / anchors | Anchors and linking | not_requested | not_requested | request_if_needed | NA | review_status=not_requested; drift=not_requested; chain=not_requested | linking_evidence_summary | linking_reporting_templates | report$linking_evidence_summary; report$linking_reporting_templates | report$linking_evidence_summary | report$linking_reporting_templates | plot(res, type = \"anchors\") | export_mfrm_results(res, include = \"report\") | mfrm_results(fit, include = \"linking\") | Linking/anchor wording requires the linking preset or explicit anchor, drift, or equating-chain helper calls. |\n\n## Template Index\n| Area | TemplateTable | TemplateRow | Topic | BoundaryType | ClaimStrength | RecommendedUse | EvidenceTable | EvidenceRoute | Route | Caveat |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| Bias / DFF | bias_reporting_templates | 1 | Bias/DFF evidence not requested | screen_not_fairness_decision | not_supported_without_followup | targeted_followup_before_claim | bias_evidence_summary | report$bias_evidence_summary | mfrm_results(fit, include = \"bias\"); estimate_bias(); analyze_dff() | Request the bias preset or run an explicit bias/DFF helper before writing fairness language. |\n| Linking / anchors | linking_reporting_templates | 1 | Linking evidence not requested | anchor_not_drift_absence | not_supported_without_followup | request_evidence_before_writing | linking_evidence_summary | report$linking_evidence_summary | mfrm_results(fit, include = \"linking\"); review_mfrm_anchors(); detect_anchor_drift(); build_equating_chain() | Request the linking preset or run explicit anchor, drift, or equating-chain helpers before writing linking claims. |\n| Fit | fit_reporting_templates | 2 | Threshold-profile wording | fit_not_validity | write_with_caveat | methods_or_appendix_caveat | fit_threshold_sensitivity | report$fit_threshold_sensitivity | report$fit_threshold_sensitivity | Use profile disagreement as sensitivity evidence; do not silently mix fit bands across reports. |\n| Fit | fit_reporting_templates | 3 | ZSTD-convention wording | fit_not_validity | write_with_caveat | methods_or_appendix_caveat | zstd_conventions | report$zstd_conventions | report$zstd_conventions | Read MnSq size first; use ZSTD to explain standardization, not as independent residual evidence. |\n| Fit | fit_reporting_templates | 4 | DF/ZSTD sensitivity wording | fit_not_validity | write_with_caveat | methods_or_appendix_caveat | fit_df_sensitivity_summary | report$fit_df_sensitivity_summary | report$fit_df_sensitivity_summary; report$fit_df_sensitive_rows | A df-sensitive ZSTD result is a convention-sensitive review prompt, not a different MnSq fit signal. |\n| Misfit / pathway | misfit_reporting_templates | 1 | Misfit/pathway evidence not requested | misfit_not_exclusion_rule | write_with_caveat | request_evidence_before_writing | misfit_evidence_summary | report$misfit_evidence_summary | mfrm_results(fit, include = \"misfit_review\"); build_misfit_casebook() | Request the misfit_review preset or run the local misfit helpers before writing case-review language. |\n| Fit | fit_reporting_templates | 1 | Fit-status wording | fit_not_validity | descriptive_only | report_with_context | fit_evidence_summary | report$fit_evidence_summary | report$fit_evidence_summary | This sentence reports a screening table, not a global model-validity decision. |\n| Fit | fit_reporting_templates | 5 | Boundary wording | fit_not_validity | descriptive_only | reporting_guardrail | fit_decision_policy | report$fit_decision_policy | report$fit_decision_policy | This boundary is intentionally conservative because published MnSq bands and ZSTD conventions differ. |\n| Precision | precision_reporting_templates | 1 | Precision-tier wording | precision_not_agreement | descriptive_only | report_with_context | precision_evidence_summary | report$precision_evidence_summary | report$precision_evidence_summary | A favorable precision tier does not override misfit, convergence, linking, or design problems. |\n| Precision | precision_reporting_templates | 2 | Separation wording | precision_not_agreement | descriptive_only | report_with_context | diagnostics | res$diagnostics$reliability | res$diagnostics$reliability | Do not describe separation as observed rater agreement or as proof of construct validity. |\n| Precision | precision_reporting_templates | 3 | Reliability wording | precision_not_agreement | descriptive_only | report_with_context | diagnostics | res$diagnostics$reliability | res$diagnostics$reliability | This is Rasch/FACETS-style separation reliability, not classical inter-rater agreement. |\n| Precision | precision_reporting_templates | 4 | Strata wording | precision_not_agreement | descriptive_only | report_with_context | diagnostics | report$precision_basis | report$precision_basis | Use strata as a precision-spread summary; do not turn it into an independent quality gate. |\n| Precision | precision_reporting_templates | 5 | Boundary wording | precision_not_agreement | descriptive_only | reporting_guardrail | precision_basis | report$precision_basis | report$precision_basis; report$fit_decision_policy | Do not use high reliability to excuse misfit, and do not use good fit to imply high precision. |\n\n## Section Plan\n| Section | Status | Evidence | Route | ReportUse | Boundary | Focus |\n| --- | --- | --- | --- | --- | --- | --- |\n| Model and data setup | available | Model = RSM; method = JML; N = 96; categories = 4. | summary(res)$overview; specifications_report(fit) | Use for method and analysis-setup wording. | Confirm scoring, column roles, missing-data handling, anchoring, and estimation settings in the analysis script. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n| First-screen diagnostics | available | Diagnostics object and triage rows are available. | summary(res)$triage; summary(res$diagnostics) | Use for QC ordering and report-readiness checks. | Diagnostics are evidence for follow-up and wording strength, not a standalone validity decision. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n| Fit, separation, and precision | not_requested | Precision review keeps fit size, standardized fit, separation, and reliability in separate lanes. | summary(res$components$precision_review); precision_review_report(fit, diagnostics) | Use for cautious wording about fit, precision, and separation. | Do not collapse fit, separation, reliability, and ZSTD into one pass/fail rule. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n| Category functioning | available | Rating-scale/category tables or curves are available when collected by mfrm_results(). | rating_scale_table(fit, diagnostics); category_structure_report(fit) | Use for score-scale interpretation and category-functioning prose. | Category evidence supports score-scale review; it does not by itself establish validity. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n| Bias screening | not_requested | Facet-level bias screening is available only when requested in mfrm_results(). | mfrm_results(fit, include = \"bias\"); estimate_bias(); bias_interaction_report() | Use for screening language and targeted follow-up contrasts. | Treat positive screens as prompts for substantive review, not final fairness conclusions. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n| Misfit and pathway review | not_requested | Unexpected-response, displacement, and pathway-map surfaces can localize observations for review. | mfrm_results(fit, include = \"misfit_review\"); plot(res, type = \"pathway\") | Use for case-review notes and reviewer-facing diagnostic follow-up. | Observation-level misfit is not an automatic exclusion or bias decision. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n| Anchors and linking | not_requested | Anchor-readiness is available from stored fit metadata when the linking preset is requested. | mfrm_results(fit, include = \"linking\"); plot(res, type = \"anchors\") | Use for operational scale-maintenance checks. | Drift and equating require multiple fitted forms or waves; they are not inferred from one fit. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n| Response-time QC | not_requested | Response-time summaries are available only when timing metadata are explicitly supplied to mfrm_results(). | mfrm_results(fit, include = \"response_time\", response_time = ..., response_time_data = ...); plot(res, type = \"response_time\") | Use for descriptive timing context, rapid/slow-response screening, and QC appendices. | Response-time review does not alter MFRM estimates, fit speed parameters, or define automatic exclusion rules. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n| Network and connectivity | not_requested | Network review describes design connectivity and overlap structure. | mfrm_results(fit, include = \"network\"); build_mfrm_network_review() | Use for design and sparseness documentation. | Connectivity evidence does not replace model fit, precision, or bias diagnostics. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n| APA and manuscript wording | not_requested | APA output assembly is available for supported RSM/PCM manuscript routes. | mfrm_results(fit, include = \"publication\"); build_apa_outputs() | Use as draft wording and table/caption templates. | APA text must be edited against the actual study design, model choice, and validation argument. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n| Tables, plots, and handoff | available | 87 table(s) and 7 plot route(s) were indexed. | build_summary_table_bundle(res); export_mfrm_results(res) | Use for appendix, reviewer supplement, or reproducible handoff. | Exported tables preserve evidence surfaces; they do not add new analyses. | Quality-control triage before manuscript, appendix, or reviewer handoff. |\n\n## Claim Readiness\n| Claim | Section | CurrentStatus | Readiness | EvidenceNeeded | SuggestedWording | FollowUp | Boundary | Style |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| APA-style manuscript text | APA and manuscript wording | not_requested | needs_requested_section | Supported APA output object or a manually edited report template. | Treat generated APA-style text as a draft and edit against the study design. | Use mfrm_results(fit, include = \"publication\") or build_apa_outputs(). | Generated prose is not a substitute for study-specific reporting judgment. | qc |\n| Anchor, linking, or drift claim | Anchors and linking | not_requested | needs_requested_section | Anchor-readiness output for one fit; multiple fitted waves/forms for drift or equating. | Report anchor readiness separately from drift or equating claims. | Use mfrm_results(fit, include = \"linking\"); for drift/equating use detect_anchor_drift() or build_equating_chain(). | Do not infer drift or equating from a single fitted object. | qc |\n| Bias or DFF screening | Bias screening | not_requested | needs_requested_section | Facet-level bias table and any explicitly selected interaction or DFF contrast. | Use screening language unless a targeted contrast and substantive review have been completed. | Use mfrm_results(fit, include = \"bias\") and then estimate_bias() for explicit facet pairs. | Do not present screen positives as final fairness conclusions. | qc |\n| Design connectivity | Network and connectivity | not_requested | needs_requested_section | Network/connectivity review and design overlap evidence. | Use connectivity language to describe design support and sparseness, not model fit. | Use mfrm_results(fit, include = \"network\") and build_mfrm_network_review(). | Connectivity evidence does not replace fit, precision, or bias diagnostics. | qc |\n| Fit and precision evidence | Fit, separation, and precision | not_requested | needs_requested_section | Selected MnSq threshold profile, observed fit-status counts, ZSTD convention, fit df, df-sensitivity rows, separation, reliability, strata, and uncertainty/context notes. | Report MnSq fit, ZSTD standardization, separation, and reliability as separate evidence streams with the selected threshold profile stated. | Use report$fit_evidence_summary, report$fit_threshold_sensitivity, report$fit_df_sensitivity_summary, precision_review_report(), and facets_fit_df_guide(). | Do not reduce these indices to one pass/fail claim, and do not interpret a df-sensitive ZSTD flag without MnSq and context. | qc |\n| Misfit case review | Misfit and pathway review | not_requested | needs_requested_section | Unexpected-response rows, displacement evidence, and pathway-map context. | Frame misfit rows as case-review prompts and report the follow-up basis. | Use mfrm_results(fit, include = \"misfit_review\") and build_misfit_casebook() when needed. | Do not use observation-level misfit as an automatic exclusion rule. | qc |\n| Appendix or reviewer supplement | Tables, plots, and handoff | available | ready | Collected result tables, plot routes, replay code, and a written-files manifest if exported. | Provide tables and replay routes so readers can inspect the evidence surface. | Use build_summary_table_bundle(res), export_mfrm_results(res), or mfrm_report(res, output = \"html\"). | Appendix files preserve evidence; they do not add new analyses. | qc |\n| Category functioning | Category functioning | available | ready | Rating-scale, category-structure, or category-curve evidence. | Describe whether score categories behaved as intended and identify any category-level caveats. | Use rating_scale_table(), category_structure_report(), and category_curves_report(). | Category evidence supports score-scale review but not a standalone validity claim. | qc |\n| Diagnostic review completed | First-screen diagnostics | available | ready | A diagnostics object, triage rows, and any key warning text. | State that diagnostics were inspected, then report only the specific supported findings. | Inspect summary(res)$triage and summary(res$diagnostics)$key_warnings. | Diagnostic availability is a starting point, not a global quality guarantee. | qc |\n| Model specification | Model and data setup | available | ready | Model, method, facets, score coding, categories, sample size, and missing-data handling. | Report the fitted MFRM specification, estimation method, scoring scale, and facet roles explicitly. | Use specifications_report(fit) and the analysis script for final methods wording. | This documents the analysis setup; it is not validity evidence by itself. | qc |\n\n## Report Gaps\n| Priority | GapType | Section | CurrentStatus | RecommendedAction | Route | Reason |\n| --- | --- | --- | --- | --- | --- | --- |\n| 3 | not_requested | APA and manuscript wording | not_requested | Rebuild the result with mfrm_results(fit, include = \"publication\") before using APA-style output. | mfrm_results(fit, include = \"publication\"); build_apa_outputs() | APA text must be edited against the actual study design, model choice, and validation argument. |\n| 3 | not_requested | Anchors and linking | not_requested | Rebuild the result with mfrm_results(fit, include = \"linking\") before writing anchor-readiness text. | mfrm_results(fit, include = \"linking\"); plot(res, type = \"anchors\") | Drift and equating require multiple fitted forms or waves; they are not inferred from one fit. |\n| 3 | not_requested | Bias screening | not_requested | Rebuild the result with mfrm_results(fit, include = \"bias\") before writing bias or fairness-screen text. | mfrm_results(fit, include = \"bias\"); estimate_bias(); bias_interaction_report() | Treat positive screens as prompts for substantive review, not final fairness conclusions. |\n| 3 | not_requested | Fit, separation, and precision | not_requested | Request the relevant mfrm_results() section or call the route-specific helper before reporting this claim. | summary(res$components$precision_review); precision_review_report(fit, diagnostics) | Do not collapse fit, separation, reliability, and ZSTD into one pass/fail rule. |\n| 3 | not_requested | Misfit and pathway review | not_requested | Rebuild the result with mfrm_results(fit, include = \"misfit_review\") before writing observation-level misfit text. | mfrm_results(fit, include = \"misfit_review\"); plot(res, type = \"pathway\") | Observation-level misfit is not an automatic exclusion or bias decision. |\n| 3 | not_requested | Network and connectivity | not_requested | Rebuild the result with mfrm_results(fit, include = \"network\") before writing connectivity text. | mfrm_results(fit, include = \"network\"); build_mfrm_network_review() | Connectivity evidence does not replace model fit, precision, or bias diagnostics. |\n| 3 | not_requested | Response-time QC | not_requested | Request the relevant mfrm_results() section or call the route-specific helper before reporting this claim. | mfrm_results(fit, include = \"response_time\", response_time = ..., response_time_data = ...); plot(res, type = \"response_time\") | Response-time review does not alter MFRM estimates, fit speed parameters, or define automatic exclusion rules. |\n\n## Fit Criteria\n| Profile | ProfileLabel | Metric | Lower | Upper | ZSTDCut | Source | SuggestedUse | DecisionRole | ReportBoundary | Route |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| active | Active review band | Infit/Outfit MnSq | 0.5 | 1.5 | 2 | Current call/options | The band used for the main fit-measures table | main_report_screen | Use as a screening band. Report the selected profile and do not treat a different published band as a contradiction unless it changes the substantive conclusion. | fit_measures_table(fit, threshold_profiles = \"all\", fit_df_method = \"both\") |\n| linacre_productive | Productive measurement | Infit/Outfit MnSq | 0.5 | 1.5 | 2 | Linacre (2002); Bond & Fox (2015) | Broad screening band for productive measurement | sensitivity_or_context | Use as a screening band. Report the selected profile and do not treat a different published band as a contradiction unless it changes the substantive conclusion. | fit_measures_table(fit, threshold_profiles = \"all\", fit_df_method = \"both\") |\n| wright_linacre_high_stakes_mcq | High-stakes multiple-choice | Infit/Outfit MnSq | 0.8 | 1.2 | 2 | Wright & Linacre (1994) | High-stakes selected-response tests | sensitivity_or_context | Use as a screening band. Report the selected profile and do not treat a different published band as a contradiction unless it changes the substantive conclusion. | fit_measures_table(fit, threshold_profiles = \"all\", fit_df_method = \"both\") |\n| wright_linacre_routine_mcq | Routine multiple-choice | Infit/Outfit MnSq | 0.7 | 1.3 | 2 | Wright & Linacre (1994) | Routine selected-response tests | sensitivity_or_context | Use as a screening band. Report the selected profile and do not treat a different published band as a contradiction unless it changes the substantive conclusion. | fit_measures_table(fit, threshold_profiles = \"all\", fit_df_method = \"both\") |\n| wright_linacre_rating_scale | Rating-scale surveys | Infit/Outfit MnSq | 0.6 | 1.4 | 2 | Wright & Linacre (1994) | Rating-scale surveys and questionnaires | sensitivity_or_context | Use as a screening band. Report the selected profile and do not treat a different published band as a contradiction unless it changes the substantive conclusion. | fit_measures_table(fit, threshold_profiles = \"all\", fit_df_method = \"both\") |\n| wright_linacre_clinical_observation | Clinical observation | Infit/Outfit MnSq | 0.5 | 1.7 | 2 | Wright & Linacre (1994) | Clinical observation ratings | sensitivity_or_context | Use as a screening band. Report the selected profile and do not treat a different published band as a contradiction unless it changes the substantive conclusion. | fit_measures_table(fit, threshold_profiles = \"all\", fit_df_method = \"both\") |\n| wright_linacre_judged_performance | Judged performance | Infit/Outfit MnSq | 0.4 | 1.2 | 2 | Wright & Linacre (1994) | Judged performance ratings | sensitivity_or_context | Use as a screening band. Report the selected profile and do not treat a different published band as a contradiction unless it changes the substantive conclusion. | fit_measures_table(fit, threshold_profiles = \"all\", fit_df_method = \"both\") |\n\n## Fit Evidence Summary\n| Status | Rows | DisplayedRows | UnderfitRows | OverfitRows | MixedRows | WithinBandRows | NotAvailableRows | DfComparedRows | DfSensitiveRows | FlagChangedByDfRows | LargeZSTDShiftRows | DfConventionDifferenceRows | FitDfMethod | ThresholdProfiles | FacetsCompanionAvailable | Source | Route | Boundary |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| available | 8 | 8 | 0 | 0 | 0 | 8 | 0 | 8 | 8 | 0 | 1 | 7 | both | all | TRUE | res$components$fit_measures | res$components$fit_measures$summary | Counts summarize the stored fit-measures component. Interpret MnSq status, df-sensitive ZSTD shifts, separation, and reliability as separate evidence streams. |\n\n## Fit Threshold Sensitivity\n| Status | Profile | ProfileLabel | Lower | Upper | Facet | Rows | AvailableRows | UnderfitRate | OverfitRate | MixedRate | AnyFlagRate | Source | Route | ReportBoundary |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| available | active | Active review band | 0.5 | 1.5 | All facets | 8 | 8 | 0 | 0 | 0 | 0 | res$components$fit_measures | res$components$fit_measures$profile_summary_overall | Use profile disagreement as sensitivity evidence. Do not present one published MnSq band as universal. |\n| available | linacre_productive | Productive measurement | 0.5 | 1.5 | All facets | 8 | 8 | 0 | 0 | 0 | 0 | res$components$fit_measures | res$components$fit_measures$profile_summary_overall | Use profile disagreement as sensitivity evidence. Do not present one published MnSq band as universal. |\n| available | wright_linacre_high_stakes_mcq | High-stakes multiple-choice | 0.8 | 1.2 | All facets | 8 | 8 | 0.125 | 0.125 | 0 | 0.25 | res$components$fit_measures | res$components$fit_measures$profile_summary_overall | Use profile disagreement as sensitivity evidence. Do not present one published MnSq band as universal. |\n| available | wright_linacre_routine_mcq | Routine multiple-choice | 0.7 | 1.3 | All facets | 8 | 8 | 0 | 0.125 | 0 | 0.125 | res$components$fit_measures | res$components$fit_measures$profile_summary_overall | Use profile disagreement as sensitivity evidence. Do not present one published MnSq band as universal. |\n| available | wright_linacre_rating_scale | Rating-scale surveys | 0.6 | 1.4 | All facets | 8 | 8 | 0 | 0 | 0 | 0 | res$components$fit_measures | res$components$fit_measures$profile_summary_overall | Use profile disagreement as sensitivity evidence. Do not present one published MnSq band as universal. |\n| available | wright_linacre_clinical_observation | Clinical observation | 0.5 | 1.7 | All facets | 8 | 8 | 0 | 0 | 0 | 0 | res$components$fit_measures | res$components$fit_measures$profile_summary_overall | Use profile disagreement as sensitivity evidence. Do not present one published MnSq band as universal. |\n| available | wright_linacre_judged_performance | Judged performance | 0.4 | 1.2 | All facets | 8 | 8 | 0.125 | 0 | 0 | 0.125 | res$components$fit_measures | res$components$fit_measures$profile_summary_overall | Use profile disagreement as sensitivity evidence. Do not present one published MnSq band as universal. |\n\n## Fit Reporting Templates\n| Audience | Topic | Template | EvidenceUsed | Caveat | Route | Style | EvidenceTable | EvidenceRoute | BoundaryType | ClaimStrength | RecommendedUse |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| QC report | Fit-status wording | Use as first-screen QC wording before manuscript or reviewer handoff. Element fit was screened for 8 facet-element row(s) using the stored mean-square profile set (all); 0 row(s) were flagged for underfit, 0 for overfit, 0 as mixed, and 8 remained within the selected band. | fit_evidence_summary | This sentence reports a screening table, not a global model-validity decision. | report$fit_evidence_summary | qc | fit_evidence_summary | report$fit_evidence_summary | fit_not_validity | descriptive_only | report_with_context |\n| QC report | Threshold-profile wording | Across the stored mean-square threshold profiles, any-flag rates ranged from 0.0% to 25.0%. The active profile rate was 0.0%. | fit_threshold_sensitivity | Use profile disagreement as sensitivity evidence; do not silently mix fit bands across reports. | report$fit_threshold_sensitivity | qc | fit_threshold_sensitivity | report$fit_threshold_sensitivity | fit_not_validity | write_with_caveat | methods_or_appendix_caveat |\n| QC report | ZSTD-convention wording | ZSTD values were treated as df-dependent standardizations of the same MnSq values. Engine and FACETS-style companion df/ZSTD columns were available under fit_df_method = \"both\". | zstd_conventions; fit_evidence_summary | Read MnSq size first; use ZSTD to explain standardization, not as independent residual evidence. | report$zstd_conventions | qc | zstd_conventions | report$zstd_conventions | fit_not_validity | write_with_caveat | methods_or_appendix_caveat |\n| QC report | DF/ZSTD sensitivity wording | Engine-vs-FACETS-style df comparison covered 8 row(s): 8 row(s) were df-sensitive, 0 changed the \\|ZSTD\\| flag status, 1 had a large ZSTD shift without necessarily changing flag status, and 7 showed a df-convention difference. | fit_df_sensitivity_summary | A df-sensitive ZSTD result is a convention-sensitive review prompt, not a different MnSq fit signal. | report$fit_df_sensitivity_summary; report$fit_df_sensitive_rows | qc | fit_df_sensitivity_summary | report$fit_df_sensitivity_summary | fit_not_validity | write_with_caveat | methods_or_appendix_caveat |\n| QC report | Boundary wording | Report fit, ZSTD standardization, separation/reliability, and local case review in separate sentences. Avoid wording such as 'the model passed fit' unless the stated threshold profile, df convention, and follow-up review all support that narrower claim. | fit_decision_policy | This boundary is intentionally conservative because published MnSq bands and ZSTD conventions differ. | report$fit_decision_policy | qc | fit_decision_policy | report$fit_decision_policy | fit_not_validity | descriptive_only | reporting_guardrail |\n\n## Precision Evidence Summary\n| Status | PrecisionTier | SupportsFormalInference | ReliabilityRows | ReviewOrWarnChecks | MinSeparation | MaxSeparation | MinReliability | MaxReliability | MinStrata | MaxStrata | ZeroSeparationRows | ZeroReliabilityRows | ReliabilityUse | Source | Route | Boundary |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| available_without_precision_review | NA | FALSE | 3 | NA | 0 | 3.07935640921313 | 0 | 0.904602326213069 | 0.333333333333333 | 4.43914187895084 | 2 | 2 | screening_only | res$diagnostics$reliability | report$precision_evidence_summary; res$components$precision_review; res$diagnostics$reliability | Separation, reliability, and strata summarize spread relative to measurement error. They are not inter-rater agreement, model fit, or standalone validity evidence. |\n\n## Precision Basis\n| Topic | SourceBasis | PackageSurface | Interpretation | ValidationUse | Availability | Source |\n| --- | --- | --- | --- | --- | --- | --- |\n| Separation reliability and strata | Wright & Masters G/R/H convention | diagnostics$reliability; precision_review_report() | Precision review was not stored in this mfrm_results object. | Rebuild with include = \"precision\" before using source-grounded precision wording. | not_requested | not_available |\n\n## Precision Reporting Templates\n| Audience | Topic | Template | EvidenceUsed | Caveat | Route | Style | EvidenceTable | EvidenceRoute | BoundaryType | ClaimStrength | RecommendedUse |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| QC report | Precision-tier wording | Use as first-screen precision wording before stronger report claims. The precision review classified the run as NA; formal inference support was not supported, and NA precision check(s) were marked review/warn. | precision_evidence_summary; precision_review_report()$profile | A favorable precision tier does not override misfit, convergence, linking, or design problems. | report$precision_evidence_summary | qc | precision_evidence_summary | report$precision_evidence_summary | precision_not_agreement | descriptive_only | report_with_context |\n| QC report | Separation wording | Facet separation was available for 3 facet row(s), ranging from 0.00 to 3.08. Interpret separation as spread relative to average measurement error. | diagnostics$reliability$Separation | Do not describe separation as observed rater agreement or as proof of construct validity. | res$diagnostics$reliability | qc | diagnostics | res$diagnostics$reliability | precision_not_agreement | descriptive_only | report_with_context |\n| QC report | Reliability wording | Facet separation reliability ranged from 0.00 to 0.90; reliability-use labels were: screening_only. | diagnostics$reliability$Reliability | This is Rasch/FACETS-style separation reliability, not classical inter-rater agreement. | res$diagnostics$reliability | qc | diagnostics | res$diagnostics$reliability | precision_not_agreement | descriptive_only | report_with_context |\n| QC report | Strata wording | Facet strata ranged from 0.33 to 4.44 under the Wright/Masters G/R/H convention. | diagnostics$reliability$Strata; precision_basis | Use strata as a precision-spread summary; do not turn it into an independent quality gate. | report$precision_basis | qc | diagnostics | report$precision_basis | precision_not_agreement | descriptive_only | report_with_context |\n| QC report | Boundary wording | State the precision tier and source convention before interpreting separation, reliability, or strata. Source basis: Wright & Masters G/R/H convention. | precision_basis | Do not use high reliability to excuse misfit, and do not use good fit to imply high precision. | report$precision_basis; report$fit_decision_policy | qc | precision_basis | report$precision_basis | precision_not_agreement | descriptive_only | reporting_guardrail |\n\n## Bias Evidence Summary\n| Status | Rows | Facets | NonPersonFacets | MaxAbsBias | MaxAbsStdResidual | ResidualTScreenPositiveRows | ChiSqScreenPositiveRows | ExplicitInteractionSelected | InteractionStatus | Source | Route | Boundary |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| not_requested | NA | NA | NA | NA | NA | NA | NA | FALSE | not_requested | not_requested | mfrm_results(fit, include = \"bias\") | Bias/DFF wording requires the bias preset or an explicit bias/DFF helper call. Do not infer fairness conclusions from omitted sections. |\n\n## Bias Reporting Templates\n| Audience | Topic | Template | EvidenceUsed | Caveat | Route | Style | EvidenceTable | EvidenceRoute | BoundaryType | ClaimStrength | RecommendedUse |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| QC report | Bias/DFF evidence not requested | Bias, DFF, or fairness-screen wording was not generated because the mfrm_results object was not built with include = \"bias\". | bias_evidence_summary | Request the bias preset or run an explicit bias/DFF helper before writing fairness language. | mfrm_results(fit, include = \"bias\"); estimate_bias(); analyze_dff() | qc | bias_evidence_summary | report$bias_evidence_summary | screen_not_fairness_decision | not_supported_without_followup | targeted_followup_before_claim |\n\n## Misfit Evidence Summary\n| Status | UnexpectedRows | DisplacementRows | PathwayFitRows | PathwayStatusRows | CurveFitStatusRows | UnexpectedScreenPositiveRows | DisplacementFlaggedRows | MaxAbsStdResidual | MaxAbsDisplacement | MaxAbsDisplacementT | PathwayAvailable | Source | Route | Boundary |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| not_requested | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | FALSE | not_requested | mfrm_results(fit, include = \"misfit_review\") | Misfit/pathway wording requires the misfit_review preset or explicit unexpected-response, displacement, and pathway helper calls. |\n\n## Misfit Reporting Templates\n| Audience | Topic | Template | EvidenceUsed | Caveat | Route | Style | EvidenceTable | EvidenceRoute | BoundaryType | ClaimStrength | RecommendedUse |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| QC report | Misfit/pathway evidence not requested | Misfit/pathway wording was not generated because the mfrm_results object was not built with include = \"misfit_review\". | misfit_evidence_summary | Request the misfit_review preset or run the local misfit helpers before writing case-review language. | mfrm_results(fit, include = \"misfit_review\"); build_misfit_casebook() | qc | misfit_evidence_summary | report$misfit_evidence_summary | misfit_not_exclusion_rule | write_with_caveat | request_evidence_before_writing |\n\n## Linking Evidence Summary\n| Status | AnchorReviewAvailable | DriftAvailable | ChainAvailable | ReviewStatus | TopRiskRows | AnchorRiskRows | DriftRiskRows | ChainRiskRows | GroupViews | AnchorFacetRows | AnchoredLevels | GroupAnchoredLevels | OverlapLevels | AnchorIssueTypes | AnchorIssueRows | LowObservationLevels | LowCategoryRows | DriftReviewStatus | EquatingChainStatus | GPCMSupport | SourceModels | Source | Route | Boundary |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| not_requested | FALSE | FALSE | FALSE | not_requested | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | not_requested | not_requested | NA | NA | not_requested | mfrm_results(fit, include = \"linking\") | Linking/anchor wording requires the linking preset or explicit anchor, drift, or equating-chain helper calls. |\n\n## Linking Reporting Templates\n| Audience | Topic | Template | EvidenceUsed | Caveat | Route | Style | EvidenceTable | EvidenceRoute | BoundaryType | ClaimStrength | RecommendedUse |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| QC report | Linking evidence not requested | Anchor/linking wording was not generated because the mfrm_results object was not built with include = \"linking\". | linking_evidence_summary | Request the linking preset or run explicit anchor, drift, or equating-chain helpers before writing linking claims. | mfrm_results(fit, include = \"linking\"); review_mfrm_anchors(); detect_anchor_drift(); build_equating_chain() | qc | linking_evidence_summary | report$linking_evidence_summary | anchor_not_drift_absence | not_supported_without_followup | request_evidence_before_writing |\n\n## ZSTD Conventions\n| Convention | FormulaOrRule | PackageConstraint | ReportingImplication | SourceBasis | Route |\n| --- | --- | --- | --- | --- | --- |\n| engine df | Infit df = sum(Var * Weight); Outfit df = sum(Weight). | zstd_from_mnsq() returns NA when df < 1 to avoid unstable Wilson-Hilferty signs. | Routine mfrmr diagnostics are conservative for very small df cells. | Package-native numerical guard for Wilson-Hilferty stability. | diagnose_mfrm(fit_df_method = \"engine\") |\n| FACETS-style df | Fourth-moment Wright-Masters-style df: 2 * numerator^2 / denominator; package columns DF_*_FACETS. | zstd_from_mnsq_facets() allows positive df below 1 and caps reported ZSTD at +/-9. | This option applies the documented fourth-moment df/ZSTD convention; agreement with external FACETS output must be checked separately. | FACETS/Winsteps fit-standardization documentation and Wright-Masters fourth-moment df convention. | diagnose_mfrm(fit_df_method = \"facets\") |\n| Wilson-Hilferty ZSTD | (MnSq^(1/3) - (1 - 2 / (9 * df))) / sqrt(2 / (9 * df)). | Requires finite positive MnSq and usable df; small df can dominate the transformation. | ZSTD is a standardization of MnSq, not a separate residual-fit statistic. | Wilson-Hilferty cube-root approximation used in Rasch fit standardization. | fit_measures_table(..., fit_df_method = \"engine\" or \"facets\") |\n| WHEXACT / linear approximation | (MnSq - 1) * sqrt(df / 2) when whexact = TRUE. | Still requires usable df; use only when the analysis intentionally follows that convention. | State the transformation setting before interpreting ZSTD. | Winsteps/FACETS WHEXACT documentation. | diagnose_mfrm(..., whexact = TRUE) |\n| Report comparison route | Keep engine and FACETS-style columns side by side with fit_df_method = \"both\". | Compare MnSq first, then df, then ZSTD; classify flag changes as convention-sensitive. | Do not explain fit decisions from ZSTD alone when MnSq, df, or threshold profile differs. | facets_fit_df_guide(); facets_fit_review(); fit_measures_table(). | fit_measures_table(..., fit_df_method = \"both\") |\n\n## Fit Decision Policy\n| Step | Rule | Rationale | RecommendedRoute | ReportBoundary |\n| --- | --- | --- | --- | --- |\n| 1 | Choose and state the MnSq band | Published bands differ by setting; the active band and sensitivity profiles should both be visible. | fit_measures_table(threshold_profiles = \"all\") | Do not silently mix bands across reports. |\n| 2 | Read MnSq before ZSTD | MnSq is the size of the fit signal; ZSTD is a df-dependent standardization of that signal. | fit_measures_table()$table[, c(\"Infit\", \"Outfit\", \"FitStatus\")] | Do not treat ZSTD as independent evidence from MnSq. |\n| 3 | Keep ZSTD convention visible | FACETS-style df can change \\|ZSTD\\| flags even when MnSq is unchanged. | fit_measures_table(fit_df_method = \"both\")$df_sensitivity | Do not call a df-sensitive ZSTD change a substantive fit change without MnSq/context evidence. |\n| 4 | Separate fit from precision | Fit, separation, reliability, and strata answer different questions. | precision_review_report()$fit_separation_basis | Do not use high reliability to excuse misfit or good fit to imply high precision. |\n| 5 | Treat profile disagreement as sensitivity evidence | A row can be flagged under one defensible band and not another; report this as a review sensitivity. | fit_measures_table()$profile_summary_by_facet | Do not present one threshold profile as universal. |\n| 6 | Use local review before action | Element fit flags are prompts for inspecting responses, raters, items, categories, or design links. | unexpected_response_table(); displacement_table(); plot(res, type = \"pathway\") | Do not remove levels or observations from fit flags alone. |\n\n## Fit DF Sensitivity\n| Status | ComparedRows | SameOrRoundingRows | FlagChangedByDfRows | LargeZSTDShiftRows | DfConventionDifferenceRows | DfSensitiveRows | FitDfMethod | Source | Route | ReportBoundary |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| review | 8 | 0 | 0 | 1 | 7 | 8 | both | res$components$fit_measures | res$components$fit_measures$df_sensitivity_summary | A df-sensitive row means the ZSTD interpretation changed or moved materially under engine-vs-FACETS-style standardization; it is not a different MnSq fit statistic. |\n\n## Fit DF Sensitive Rows\n| Status | Facet | Level | DfSensitivityStatus | FlagChangedByDf | MaxAbsZSTDDiff_FACETS_vs_ENGINE | MaxDFRelativeDifference_ENGINE_vs_FACETS | InfitZSTD_ENGINE | InfitZSTD_FACETS | OutfitZSTD_ENGINE | OutfitZSTD_FACETS | Interpretation | Source | Route | ReportBoundary |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n| review | Criterion | Organization | large_zstd_shift | FALSE | 0.61636171683901 | 0.567215745928674 | -0.960552825831941 | -1.57691454267095 | -1.48973774937019 | -1.62145753703411 | The FACETS-style df changes ZSTD substantially; interpret ZSTD only with the df convention stated. | res$components$fit_measures | res$components$fit_measures$df_sensitive | Inspect the row context before using a ZSTD-only flag in report text; MnSq size and substantive role remain primary. |\n| review | Criterion | Accuracy | df_convention_difference | FALSE | 0.23891837089197 | 0.56241264380073 | 0.690341151331195 | 0.929259522223165 | 0.778498925319008 | 0.826268598283153 | The df convention differs enough to affect ZSTD interpretation even if the flag status is unchanged. | res$components$fit_measures | res$components$fit_measures$df_sensitive | Inspect the row context before using a ZSTD-only flag in report text; MnSq size and substantive role remain primary. |\n| review | Rater | R04 | df_convention_difference | FALSE | 0.154323977580657 | 0.557657027367327 | -0.0843712677061883 | -0.238695245286846 | -0.306869512177568 | -0.348131137135136 | The df convention differs enough to affect ZSTD interpretation even if the flag status is unchanged. | res$components$fit_measures | res$components$fit_measures$df_sensitive | Inspect the row context before using a ZSTD-only flag in report text; MnSq size and substantive role remain primary. |\n| review | Rater | R03 | df_convention_difference | FALSE | 0.112065122500992 | 0.586323661034455 | 0.0288601387772102 | -0.0832049837237821 | -0.0351160873336413 | -0.0483415827394094 | The df convention differs enough to affect ZSTD interpretation even if the flag status is unchanged. | res$components$fit_measures | res$components$fit_measures$df_sensitive | Inspect the row context before using a ZSTD-only flag in report text; MnSq size and substantive role remain primary. |\n| review | Rater | R01 | df_convention_difference | FALSE | 0.0896803733539769 | 0.577599521514167 | 0.393528355989861 | 0.483208729343838 | 0.507834788300319 | 0.531757208368787 | The df convention differs enough to affect ZSTD interpretation even if the flag status is unchanged. | res$components$fit_measures | res$components$fit_measures$df_sensitive | Inspect the row context before using a ZSTD-only flag in report text; MnSq size and substantive role remain primary. |\n| review | Rater | R02 | df_convention_difference | FALSE | 0.0612010421870001 | 0.557657006155333 | 0.100558313821056 | 0.0393572716340563 | -0.0793289698850662 | -0.101502932492101 | The df convention differs enough to affect ZSTD interpretation even if the flag status is unchanged. | res$components$fit_measures | res$components$fit_measures$df_sensitive | Inspect the row context before using a ZSTD-only flag in report text; MnSq size and substantive role remain primary. |\n| review | Criterion | Language | df_convention_difference | FALSE | 0.0220601020333296 | 0.567215766637269 | 0.26701052360377 | 0.289070625637099 | 0.329980070053908 | 0.341345692986484 | The df convention differs enough to affect ZSTD interpretation even if the flag status is unchanged. | res$components$fit_measures | res$components$fit_measures$df_sensitive | Inspect the row context before using a ZSTD-only flag in report text; MnSq size and substantive role remain primary. |\n| review | Criterion | Content | df_convention_difference | FALSE | 0.0123803495389581 | 0.580922036496649 | 0.252021787965132 | 0.26440213750409 | 0.222012409266447 | 0.224254826085049 | The df convention differs enough to affect ZSTD interpretation even if the flag status is unchanged. | res$components$fit_measures | res$components$fit_measures$df_sensitive | Inspect the row context before using a ZSTD-only flag in report text; MnSq size and substantive role remain primary. |\n\n## Evidence Boundary\n| EvidenceSource | Use | DoNotUseAs | RecommendedRoute |\n| --- | --- | --- | --- |\n| Model setup and convergence | Document estimation settings, data roles, and run stability. | Proof that the construct interpretation is valid. | summary(res)$overview; specifications_report(fit) |\n| Fit, separation, and precision | Separate fit-size, standardized fit, separation, reliability, and uncertainty evidence. | A single pass/fail psychometric rule. | summary(res$components$precision_review); precision_review_report() |\n| Category functioning | Describe how score categories function and where thresholds or curves need review. | Standalone validity evidence. | rating_scale_table(); category_structure_report(); category_curves_report() |\n| Bias and DFF screening | Identify candidate contrasts for follow-up fairness or interaction review. | Final fairness, bias, or invariance conclusion. | mfrm_results(fit, include = \"bias\"); estimate_bias(); bias_interaction_report() |\n| Misfit and pathway maps | Localize unexpected observations for case review and substantive interpretation. | Automatic exclusion rule for persons, raters, items, or observations. | mfrm_results(fit, include = \"misfit_review\"); unexpected_response_table(); plot(res, type = \"pathway\") |\n| Anchors, linking, and drift | Assess anchor readiness and operational scale-maintenance workflow. | Single-fit evidence of drift or completed equating. | mfrm_results(fit, include = \"linking\"); review_mfrm_anchors(); detect_anchor_drift(); build_equating_chain() |\n| Network and connectivity | Describe design overlap, sparseness, and connectedness. | A replacement for fit, precision, or bias diagnostics. | mfrm_results(fit, include = \"network\"); build_mfrm_network_review() |\n| Response-time QC | Describe rapid/slow-response timing patterns as separate QC context. | A fitted speed parameter, speed-accuracy model, or automatic exclusion rule. | mfrm_results(fit, include = \"response_time\", response_time = ..., response_time_data = ...); response_time_review() |\n| GPCM helper coverage | State which GPCM summaries are supported and which are caveated. | A claim that every RSM/PCM report pathway has an equivalent GPCM route. | gpcm_capability_matrix(); mfrmr_output_guide(\"gpcm\") |\n| APA-style wording | Draft report prose, captions, and section maps. | Final manuscript text without study-specific editing. | mfrm_report(res, style = \"apa\"); build_apa_outputs() |\n\n## Next Actions\n| Priority | Area | Action | Route | Reason | ReportDecision |\n| --- | --- | --- | --- | --- | --- |\n| 1 | Overview | Read the compact results summary. | summary(res) | Confirms input mode, model, method, section status, table coverage, and available figures. | Clear QC blockers before report export or reviewer handoff. |\n| 2 | Triage | Read the first-screen triage before branching. | summary(res)$triage | Triage orders unavailable, review, information, and OK signals across diagnostics, tables, plots, and reporting outputs. | Clear QC blockers before report export or reviewer handoff. |\n| 2 | Wright map | Create and inspect the required shared-logit scale map. | plot(res, type = \"wright\", preset = \"publication\", show_ci = TRUE, top_n = Inf) | The Wright map is the primary fitted-scale figure: compare person targeting with facet levels and step thresholds before branching into diagnostics. | Clear QC blockers before report export or reviewer handoff. |\n| 3 | Diagnostics | Review diagnostic key warnings before report drafting. | summary(res$diagnostics)$key_warnings | Diagnostic warnings identify the highest-priority fit, precision, residual, or category follow-up checks. | Clear QC blockers before report export or reviewer handoff. |\n| 4 | Visual diagnostics | Open the QC dashboard after reviewing the Wright map. | plot(res, type = \"qc\", preset = \"publication\") | The QC dashboard gives a focused follow-up view of fit, residual, and category summaries. | Clear QC blockers before report export or reviewer handoff. |\n| 5 | Fit pathway | Review Infit against measure, including selected person rows when useful. | plot(res, type = \"fit_pathway\", fit_stat = \"Infit\", include_person = TRUE, top_n_person = 12, person_labels = \"none\", facet_labels = \"flagged\", preset = \"publication\") | This follow-up separates measure uncertainty from fit displacement while keeping person inclusion explicit. | Clear QC blockers before report export or reviewer handoff. |\n| 11 | Tables | Create an appendix-ready summary-table bundle. | build_summary_table_bundle(res) | The bundle exposes table roles, plot readiness, and conservative appendix presets. | Clear QC blockers before report export or reviewer handoff. |"
mfrm_report(res, output = "html")
#> mfrmr Report HTML
#>   Path: /tmp/RtmpIbcapd/mfrmr_report_2e7f4be392ac.html
# }
```
