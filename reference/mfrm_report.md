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
table, and optional Markdown or HTML report. Except for the individual
rater sheet described below, the object and its table list retain the
exact source-fit `fit_readiness*` tables from
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md);
report synthesis does not reinterpret or upgrade them. The `decision`
table translates that same record into interpretation, formal-inference,
reason, and next-action text.

## Usage

``` r
mfrm_report(
  x,
  style = c("qc", "apa", "validation", "reviewer", "technical", "rater"),
  output = c("object", "markdown", "html", "tables"),
  facet = NULL,
  rater = NULL,
  audience = c("rater", "researcher"),
  label = NULL,
  max_cases = 5,
  interval = NULL
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
  routes. `"rater"` creates a standalone individual feedback sheet from
  saved native additive RSM/PCM results; it requires `facet` and
  `rater`.

- output:

  Return format: `"object"` for an `mfrm_report` object, `"markdown"`
  for a character scalar, `"html"` for a temporary HTML file, or
  `"tables"` for the report's named data-frame list.

- facet:

  For `style = "rater"`, the fitted non-Person facet representing
  raters, for example `"Rater"`. It is not inferred from the column
  name.

- rater:

  For `style = "rater"`, one character level of `facet`.

- audience:

  For a rater sheet, `"rater"` gives plain-language guidance;
  `"researcher"` adds the model, estimator and diagnostic basis. Both
  use the same saved numerical values and omit source identifiers.

- label:

  Optional recipient-facing label for a rater sheet. The default is
  `"Selected rater"`; even the selected source identifier is not copied.
  Any identifying information explicitly supplied here will be
  displayed.

- max_cases:

  Maximum number of saved unexpected ratings in a rater sheet, ordered
  by absolute standardized residual. Default 5; use 0 to omit individual
  cases. This is not a misfit threshold.

- interval:

  Optional name of a saved fixed-facet interval attachment in
  `x$facet_intervals` for a rater sheet. The attachment must contain the
  selected individual coefficient, not just a difference involving it. A
  single matching attachment is used automatically. Multiple matching
  attachments require an explicit choice. No interval is calculated
  here.

## Value

Depending on `output`, an `mfrm_report` object, a Markdown character
scalar, an `mfrm_report_html` object, or a named list of data frames.
For `style = "rater"`, object output has class `mfrm_rater_feedback` and
contains `title`, `label`, `audience`, `review`, `guidance`, `notes`,
`tables` and `markdown`. It does not contain the original result object.

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

Report rows deliberately distinguish evidence from claims. The testlet
and random-rater route is a smaller stored-result report: all supported
styles (excluding `"rater"`) retain numerical checks, data usage,
interval meanings and supplied predictions/intervals. It does not supply
ordinary residual diagnostics or fit/APA wording templates;
`template_index` is empty. See the model-specific section in
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
for supported tables and plots.

For ordinary models, the `first_screen` table is the compact entry
point: it gives an overall row and one row per major evidence area with
status, readiness, main issue, next action, and primary route. The
`summary.mfrm_report` method summarizes that first screen into immediate
actions, optional not-requested sections, claim-readiness counts, report
gaps, and template-boundary rows without introducing a new pass/fail
decision. The default print method follows the same short reading order
and does not print every detailed evidence table. HTML output places the
same reader guidance and report-summary tables before the full Markdown
text so the browser view starts from the first-screen route. The
`report_index` table is the detailed evidence-route index: it lists the
major report areas, evidence status, readiness label, review-signal
count, and the primary/template tables, evidence routes, template
routes, plot routes, export route, and `mfrm_results(include = ...)`
preset to inspect next. In ordinary use, open detailed tables through
the `PrimaryTable` and `TemplateTable` columns rather than scanning
every element of `report$tables`. The `template_index` table then stacks
all fit, precision, bias, misfit, and linking wording templates into a
single boundary/claim-strength index before users drill into the
area-specific template tables. The `claim_readiness` table marks which
report claims are ready, caveated, unavailable, or require additional
requested sections. The `report_gaps` table turns those statuses into
follow-up actions. The fit-specific tables keep multiple MnSq threshold
profiles, observed fit-status counts, and engine-vs-FACETS-style ZSTD
conventions visible, including the small-df/capping boundary used for
FACETS-style ZSTD review. They summarize the stored `fit_measures`
component from
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
and fairness conclusions in separate sections. The
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

## Individual rater sheets

Use
`mfrm_report(res, style = "rater", facet = "Rater", rater = "R01", output = "html")`
to create a temporary HTML sheet. Open its `$path`, review it, and copy
that file to a permanent location for distribution. HTML is
self-contained, includes print styling and category-use bars with
numerical tables, and does not load external resources. Page count
depends on content and browser print settings; this is not a PDF export
API. After reviewing the sheet, use
`file.copy(sheet$path, recipient_file)` to keep it at a chosen HTML
path. To prepare sheets in a later session, save the complete `res` with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and reload it
with [`base::readRDS()`](https://rdrr.io/r/base/readRDS.html). The RDS
file retains fitted data and identifiers for the analyst; it is not the
recipient's sheet. Reloading and reporting reuse the saved analysis
without updating it for new ratings.

The sheet includes scoring tendency (severity), exposure, available
saved fixed-facet uncertainty, ordinary Infit/Outfit, category use and
selected unexpected ratings. Severity is oriented so that positive
values mean lower expected scores. Its zero is the fitted model
reference, not necessarily the average of the other raters; custom
centering and anchors matter. Model scores and expected scores stay on
the fitted category coding. The category table also shows the original
numeric scores when a mapping exists. Exposure and category percentages
count retained rows without weights; weight sums are reported
separately. Neither is planned-design completion.

Supply matching
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
output to
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
to include fit and unexpected ratings. Attach
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
output through `intervals = list(raters = ci)` for supported MML
fixed-facet intervals. JML sheets can show saved descriptive diagnostics
but do not gain formal fixed-facet intervals. Inspect the complete saved
interval result and its numerical cautions before sharing; free-form
cautions are not copied into the recipient's sheet. Missing sections
explain the missing input. Ineligible source fits retain a prominent
review notice. Severity is not rater quality, and no automatic misfit
cutoff, exclusion decision or diagnostic accuracy claim is added. These
sheets do not support GPCM, fitted interactions, imported fits, testlet
or shared-random-rater models; use their specific results and reports
because their effects and diagnostics differ.

All four output formats use only selected numeric summaries and fixed
explanatory text. They omit the source fit, Person identifiers, other
rater identifiers, original row numbers, task labels and free-form
source notes. Case numbers refer only to the displayed ordering. This
prevents copying those identifier fields; it is not a guarantee against
recognition from rating patterns, small groups or an explicitly supplied
`label`. Review the content before sharing, and use `max_cases = 0` when
cases are unnecessary. Distribute the standalone sheet, not the
comprehensive results/export bundle, which retains the original
analysis. Rater-specific arguments are rejected with other report
styles, even when explicitly supplied as `NULL`.

## See also

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

## Examples

``` r
# \donttest{
# Load the package and example ratings
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# Build results, then turn them into a report
res <- mfrm_results(fit)
report <- mfrm_report(res)

# Read the report and the issues to address
summary(report, view = "reader")
#> mfrmr Report Summary
#> 
#> Overview
#>  Style OverallStatus     FirstAction ReviewAreas NotComputedAreas CaveatAreas
#>     qc        review Start with Fit.           1                0           0
#>  OptionalAreas UnavailableAreas OkAreas
#>              3                0       1
#>                                                      SourceInclude
#>  fit, diagnostics, tables, precision, reporting, categories, plots
#> 
#> Decision
#>  - Interpretation: Ready for formal inference
#>  - Formal inference: Yes
#>  - Why: All stored fit-readiness components passed.
#>  - Next: Read the compact results summary.
#> 
#> First screen
#>               Area            Status         Readiness
#>            Overall            review            review
#>                Fit            review            review
#>         Bias / DFF request_if_needed request_if_needed
#>  Linking / anchors request_if_needed request_if_needed
#>   Misfit / pathway request_if_needed request_if_needed
#>          Precision                ok             ready
#>                                                                      MainIssue
#>  ok=1; review=1; caveat=0; request_if_needed=3; not_computed=0; unavailable=0.
#>                   ReviewSignalCount = 9; underfit=0; overfit=0; df_sensitive=9
#>                                                    Evidence was not requested.
#>                                                    Evidence was not requested.
#>                                                    Evidence was not requested.
#>                                                No report-index review signals.
#>                                                                NextAction
#>                                                           Start with Fit.
#>  Inspect the primary evidence table and template boundary before writing.
#>                        Request this evidence only if the claim is needed.
#>                        Request this evidence only if the claim is needed.
#>                        Request this evidence only if the claim is needed.
#>                   Use the listed template route if this area is reported.
#>                                  PrimaryRoute
#>    report$report_index; report$template_index
#>                   report$fit_evidence_summary
#>           mfrm_results(fit, include = "bias")
#>        mfrm_results(fit, include = "linking")
#>  mfrm_results(fit, include = "misfit_review")
#>             report$precision_evidence_summary
#> 
#> Claim readiness
#>                Readiness Claims                    ExampleClaim
#>  needs_requested_section      5       APA-style manuscript text
#>        write_with_caveat      1      Fit and precision evidence
#>                    ready      4 Appendix or reviewer supplement
#> 
#> Immediate actions
#>  Area Status                                                    MainIssue
#>   Fit review ReviewSignalCount = 9; underfit=0; overfit=0; df_sensitive=9
#>                                                                NextAction
#>  Inspect the primary evidence table and template boundary before writing.
#>                 PrimaryRoute                  TemplateRoute
#>  report$fit_evidence_summary report$fit_reporting_templates
#> 
#> Report gaps
#>  Priority           GapType                        Section
#>         3     not_requested     APA and manuscript wording
#>         3     not_requested            Anchors and linking
#>         3     not_requested                 Bias screening
#>         3     not_requested      Misfit and pathway review
#>         3     not_requested       Network and connectivity
#>         3     not_requested               Response-time QC
#>         4 caveated_evidence Fit, separation, and precision
#>                                                                                                   RecommendedAction
#>                   Rebuild the result with mfrm_results(fit, include = "publication") before using APA-style output.
#>                Rebuild the result with mfrm_results(fit, include = "linking") before writing anchor-readiness text.
#>            Rebuild the result with mfrm_results(fit, include = "bias") before writing bias or fairness-screen text.
#>  Rebuild the result with mfrm_results(fit, include = "misfit_review") before writing observation-level misfit text.
#>                    Rebuild the result with mfrm_results(fit, include = "network") before writing connectivity text.
#>          Request the relevant mfrm_results() section or call the route-specific helper before reporting this claim.
#>                             Write only a caveated claim and inspect the route-specific table before manuscript use.
#>                                                                                                                           Route
#>                                                                 mfrm_results(fit, include = "publication"); build_apa_outputs()
#>                                                             mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#>                                                 mfrm_results(fit, include = "bias"); estimate_bias(); bias_interaction_report()
#>                                                       mfrm_results(fit, include = "misfit_review"); plot(res, type = "pathway")
#>                                                             mfrm_results(fit, include = "network"); build_mfrm_network_review()
#>  mfrm_results(fit, include = "response_time", response_time = ..., response_time_data = ...); plot(res, type = "response_time")
#>                                             summary(res$components$precision_review); precision_review_report(fit, diagnostics)
report$first_screen[, c("Area", "Status", "MainIssue", "NextAction")]
#>                Area            Status
#> 1           Overall            review
#> 2               Fit            review
#> 3        Bias / DFF request_if_needed
#> 4 Linking / anchors request_if_needed
#> 5  Misfit / pathway request_if_needed
#> 6         Precision                ok
#>                                                                       MainIssue
#> 1 ok=1; review=1; caveat=0; request_if_needed=3; not_computed=0; unavailable=0.
#> 2                  ReviewSignalCount = 9; underfit=0; overfit=0; df_sensitive=9
#> 3                                                   Evidence was not requested.
#> 4                                                   Evidence was not requested.
#> 5                                                   Evidence was not requested.
#> 6                                               No report-index review signals.
#>                                                                 NextAction
#> 1                                                          Start with Fit.
#> 2 Inspect the primary evidence table and template boundary before writing.
#> 3                       Request this evidence only if the claim is needed.
#> 4                       Request this evidence only if the claim is needed.
#> 5                       Request this evidence only if the claim is needed.
#> 6                  Use the listed template route if this area is reported.

# Select a recipient explicitly. Missing intervals are explained in the sheet.
recipient <- as.character(fit$prep$levels$Rater[1])
sheet <- mfrm_report(res, style = "rater", facet = "Rater",
                     rater = recipient, output = "html", max_cases = 0)
sheet$path
#> [1] "/tmp/RtmpkdbPhC/mfrmr_rater_1ade7ea0ec8d.html"
# Review in a browser, then choose a permanent path for continuing work.
recipient_file <- tempfile(fileext = ".html")
stopifnot(file.copy(sheet$path, recipient_file, overwrite = FALSE))
# }
```
