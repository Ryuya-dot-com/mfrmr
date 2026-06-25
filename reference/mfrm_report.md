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
APA/QC/validation/reviewer wording scaffolds while keeping MnSq, ZSTD
standardization, df sensitivity, and separation/reliability in separate
sentences. All reporting-template tables share `EvidenceTable`,
`EvidenceRoute`, `BoundaryType`, `ClaimStrength`, and `RecommendedUse`
columns so each template can be traced back to its evidence and claim
boundary. `template_index` stacks those columns across all template
areas so report authors can review unsupported or caveated wording
before opening the full template text. The
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
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:6], , drop = FALSE]
fit <- fit_mfrm(toy_small, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
res <- mfrm_results(fit, include = c("fit", "diagnostics", "tables"))

report <- mfrm_report(res, style = "qc")
summary(report)
report$first_screen
report$report_index[, c("Area", "Readiness", "PrimaryTable",
                        "TemplateTable", "PlotRoute")]
report$template_index[, c("Area", "Topic", "BoundaryType",
                          "ClaimStrength", "EvidenceRoute")]

# Open detailed evidence only after the index points to it.
fit_primary <- report$report_index$PrimaryTable[
  report$report_index$Area == "Fit"
][1]
report$tables[[fit_primary]]

mfrm_report(res, output = "markdown")
mfrm_report(res, output = "html")
} # }
```
