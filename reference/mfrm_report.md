# Build reports from measurement, G/D-study or residual results

`mfrm_report()` connects existing measurement results, G/D-study results
and residual exploration to tables, Markdown and HTML. It does not
refit, recompute diagnostics or create new inferential support. Pass
G/D-study and
[`mfrm_residual_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md)
objects directly. Rater/halo networks and
[`fit_rater_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md)
results also connect directly, retaining definitions, unavailable pairs,
network fit, cluster-bootstrap contrasts and ERGM checks. Attach
previously calculated G/D intervals explicitly. See the dedicated
section below and the editable `templates/gtheory-report.Rmd`.

For an
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
object, it turns the comprehensive first-screen result into a
first-screen table, section plan, claim-readiness table, report-gap
table, report-index table, template-index table, fit-criteria table,
result-specific fit evidence summaries, fit-reporting wording templates,
precision/separation reporting templates, bias/DFF reporting templates,
misfit/pathway reporting templates, linking/anchor reporting templates,
ZSTD-convention table, evidence-boundary table, next-action table, and
optional Markdown or HTML report. For
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
inputs, except for the individual rater sheet, the object and its table
list retain the exact source-fit `fit_readiness*` tables from
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
  interval = NULL,
  intervals = NULL,
  study_context = NULL
)
```

## Arguments

- x:

  An
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  object, a supported G/D-study or network result, or output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
  [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
  or
  [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md).

- style:

  Report emphasis. `"qc"` is the default first-screen report. `"apa"`
  emphasizes manuscript wording, `"validation"` emphasizes the
  validity-argument boundary, `"reviewer"` emphasizes reviewer response
  preparation, and `"technical"` emphasizes appendix/reproducibility
  routes. `"rater"` creates a standalone individual feedback sheet from
  saved native additive RSM/PCM or two-family GPCM MML results; it
  requires `facet` and `rater`.

- output:

  Return format: `"object"` for an `mfrm_report` object
  (`mfrm_rater_feedback` when `style = "rater"`), `"markdown"` for a
  character scalar, `"html"` for a temporary HTML file, or `"tables"`
  for the report's named data-frame list.

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
  `x$facet_intervals` for an additive-model rater sheet, or a saved
  component slope interval in `x$gpcm_inference` for two-family GPCM.
  The attachment must contain the selected individual coefficient, not
  just a difference involving it. A single matching attachment is used
  automatically. Multiple matching attachments require an explicit
  choice. No interval is calculated here.

- intervals:

  For a G/D-study only, saved `confint(x)` output or a list of such
  results. Source, design and target context are checked. `NULL` reports
  point estimates without intervals; logical values do not trigger
  computation. Old component intervals lacking source context must be
  recreated with the current `confint(g)`. This differs from singular
  `interval`, which selects an attachment for an individual rater sheet.

- study_context:

  Optional named character vector of study declarations, for example
  `c(question = "...", rating_unit = "...", score_direction = "Higher means easier to understand", rubric = "1 = very difficult; 9 = very easy", transformation = "None", anchor_source = "...")`.
  Names must be unique; values must be nonmissing and nonblank. The same
  declaration can accompany separate measurement, G/D and feedback
  reports when their meanings match. It is retained in `$study_context`,
  `$tables$study_context`, Markdown, HTML and report appendix export.
  These are user declarations, not model-verified facts: they never
  recode data, reverse parameter signs, validate anchors or change
  eligibility. For a recipient-facing rater sheet, supply only context
  intended for that recipient; text is copied verbatim.

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
interval meanings and supplied predictions/intervals. When saved scores
include a scoring roster, the `scoring_roster` table preserves its rows,
identifiers and omitted scores; testlet `scoring_blocks` separately
summarizes observed blocks. Older results without a roster do not
reconstruct one from calibration rows. It does not supply ordinary
residual diagnostics or fit/APA wording templates; `template_index` is
empty. See the model-specific section in
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
for supported tables and plots. The `Response residuals` row
distinguishes an unsupplied saved
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
result (`not_computed`) from a supplied result with no available
observed-row results (`unavailable`) or results requiring review. If
needed, compute these diagnostics separately for a numerically ready fit
and attach them through
`mfrm_results(fit, response_diagnostics = diagnostics)`. Available
summaries remain descriptive (`caveat`): ordinary-model cutoffs do not
apply, and they do not establish model adequacy. Report creation never
computes the missing diagnostics. Older result bundles can be passed to
`mfrm_report()` again to update the report; previously exported files
retain their original text.

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
`diagnostics$reliability`. `precision_by_facet` preserves every stored
facet row, original values, missing-value reasons and inference flags.
Templates report model and fit-adjusted indices separately for each
facet; they are not confidence bounds. Cross-facet ranges in the
compatibility summary are not an overall reliability coefficient. A
Person separation index computed with EAP/posterior SD is not
posterior-variance EAP reliability; this report does not compute that
different index. `fit_calculation_basis` identifies the recorded target
of the MnSq tables, including EAP plug-in and imported source
definitions. Missing metadata stays unrecorded. Rebuild reports from
saved results to obtain these explanations; no re-estimation is needed.
The `bias_reporting_templates` table is available when the source result
was built with `include = "bias"` and keeps facet-level screens,
interaction-bias contrasts, DFF follow-up, and fairness conclusions in
separate sections. The `misfit_reporting_templates` table is available
when the source result was built with `include = "misfit_review"` and
keeps unexpected responses, displacement, pathway-map evidence, and
case-review actions separate. The `linking_reporting_templates` table is
available when the source result was built with `include = "linking"`
and keeps anchor readiness, drift review, equating-chain review, and
GPCM support boundaries separate. For example, fit and separation are
not collapsed into a single pass/fail statement; bias screens are not
treated as final fairness conclusions; pathway/misfit rows are
case-review prompts; and drift/equating claims require multiple fitted
forms or waves.

## Anchor, bias and model-choice modules

Use `mfrm_report(review_mfrm_anchors(...))` before anchored fitting,
`mfrm_report(build_linking_review(...))` for saved link evidence,
`mfrm_report(estimate_bias(...))` for a prespecified interaction, and
`mfrm_report(build_model_choice_review(...))` for candidate-model roles
and comparability. Reporting does not fit a new model, select new
interaction cells, calculate a missing LRT or test anchor invariance.
Full bias cells and anchor values remain alongside compact summaries;
source objects and unavailable states are preserved. `style = "rater"`
continues to require individual feedback from
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
Supply `study_context` to keep rubric direction, transformations, anchor
provenance and the question with the report. A shared declaration does
not establish equivalence between a raw G-study score and a latent MFRM
measure. See the editable `templates/assessment-review.Rmd` for separate
modules using bundled data and a saved report archive.

## G/D-study and residual-exploration reports

Saved Stan/brms summaries read by
[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md)
also enter this route directly. Reports retain their credible-interval
level, fixed values, priors, model-data identity and sampling review.
They do not calculate new intervals, native MML diagnostics, prior
sensitivity or posterior predictions.

Pass
[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md),
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md)
or
[`mfrm_residual_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md)
output directly, without
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
The non-rater styles all preserve the same complete domain-specific
tables and interpretation notes. Report creation never refits, clusters
or computes intervals. The overall review status asks for substantive
study context; it is not a numerical convergence or formal-inference
assessment.

G/D tables retain observed counts separately from future plans, fixed
score/composite weights, signed covariance components, component policy,
G/Phi, universe/error variances, measurement SEM and unavailable states.
Saved component or plan/contrast intervals retain their methods,
assumptions and any separate interval center. Without supplied intervals
the report explicitly states `not_requested`. Paired-delta comparisons
have their own report, preserving their shared-source covariance and
approximation. These are observed-score studies, not latent-trait fits
or MFRM separation reliability. Brennan (2003) explains why coefficients
should be accompanied by error variances; Jiang et al. (2022) emphasize
uncertainty and studied design conditions. Their findings do not
validate every interval method supplied here.

Use `build_summary_table_bundle(report)` for all numerical and
contextual tables, `apa_table(report, which = "coefficients")` for a
selected D-study table, and
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
for CSV/HTML. `summary(report)` keeps the full evidence tables in
`evidence_tables`; `top_n` does not truncate them. Save the complete
report/source with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html)
for replay. Source archives can contain participant identifiers and
require sharing review. The installed editable template is located by
`system.file("templates", "gtheory-report.Rmd", package = "mfrmr")`.

Residual reports retain all nodes and pairs, overlap, threshold settings
and cluster availability. They support exploratory review; they do not
establish dimensions, rater quality, stable classes or causal
relationships. See
[`mfrm_residual_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md)
for unsupervised learning, validation and the distinct role of
supervised random forests.

## Stored agreement in ordinary-model reports

When diagnostics are present, the narrative and
`tables$interrater_interpretation` distinguish observed agreement from
the fitted-model expected baseline and from separation reliability.
`tables$interrater_summary` retains the stored numerical summary
unchanged. The denominator counts matched-context opportunities across
rater pairs, not independent people. Unavailable values, zero matched
opportunities and an absent stored summary are described explicitly; no
missing agreement statistic is computed during reporting. Reports
without diagnostics retain their existing component-status explanation
rather than inventing values. These summaries share their interpretation
with
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).
See
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
for calculations and matching conventions. Markdown and HTML contain the
same explanation; export with
`export_mfrm_results(res, include = "report")` to retain the summary and
interpretation as CSV files as well. Existing saved APA drafts retain
their original wording until regenerated with
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
and the same saved fit/diagnostics. Regeneration does not refit the
model.

## Two-family GPCM reports

Reports retain all saved non-Person fitted locations, category steps and
component slopes. Locations identify their centering constraint; steps
identify their owner and level and are centered offsets, not standalone
thresholds. Separately computed experimental location/contrast intervals
from
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
may be attached; step intervals remain unavailable. The Markdown view
shows up to 20 rows per table with a notice; complete tables remain in
`$tables` and CSV exports. Report styles do not change inferential
support.

## Corrected JML reports

Results from an explicit `jml_correction_order` have an
estimator-specific report of saved estimates, numerical status and
RootSE interpretation. The report does not contain ordinary fit tests or
structural confidence intervals. The `"rater"` style is unavailable for
this estimator. Saved
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
output adds conditional response means, probabilities and descriptive
residual summaries, with unavailable indices and their reasons retained.
These do not classify rater quality. See
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
and the **Corrected JML** section of
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

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
without updating it for new ratings. `output = "tables"` includes an
`interpretation_notes` table with the overall review, audience-specific
guidance and section explanations. Keep this table with the numerical
tables when saving CSV files or sharing them. These explanations are the
sheet's fixed, recipient-safe text; free-form notes from the source
analysis are not copied. The same table is available in the sheet
object's `$tables`. HTML and Markdown show the explanations beside their
sections, without duplicating them as another table. The `uncertainty`
table retains `Available` and a recipient-safe `Reason`, distinguishing
constraint-fixed values, insufficient independent-cluster information,
unusable variance/bounds and failed numerical/profile checks where the
saved diagnostics identify the cause. If the interval is unavailable,
both bounds are missing in the sheet, even when the analyst's saved
result retains one computed endpoint. This does not mean zero
uncertainty or an unbounded interval. The original saved analysis is
unchanged; unidentified reasons direct the recipient to the analyst.
Printing the sheet also shows interval availability and its explanation.
Recreate sheets from saved `mfrm_results` objects to obtain these
fields; reading an older sheet does not update its contents.

The additive RSM/PCM sheet includes scoring tendency (severity),
exposure, available saved fixed-facet uncertainty, ordinary
Infit/Outfit, category use and selected unexpected ratings. Severity is
oriented so that positive values mean lower expected scores. Its zero is
the fitted model reference, not necessarily the average of the other
raters; custom centering and anchors matter. Model scores and expected
scores stay on the fitted category coding. The category table also shows
the original numeric scores when a mapping exists. Exposure and category
percentages count retained rows without weights; weight sums are
reported separately. Neither is planned-design completion.

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
sheets do not support one-family GPCM, fitted interactions, imported
fits, testlet or shared-random-rater models; use their specific results
and reports because their effects and diagnostics differ.

For two-family GPCM MML, the same entry creates an experimental
descriptive sheet. Select the modeled rater facet explicitly; either
slope owner is supported. It separates the fitted location from the
component slope, retains their distinct centering references, and
reports category use, retained exposure and how many levels of the other
facet were observed. Category-step offsets are shown only when this
facet owns the steps. They are centered offsets, not standalone
thresholds. This individual sheet does not display location or step
intervals; use the analyst report for separately requested location
intervals. A larger slope is not evidence of competence or accuracy.

Attach saved
[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
output from `parm = "slopes"` through `intervals` in
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
to include a matching experimental component-slope interval. `interval`
chooses among named attachments; pointwise/Bonferroni meaning,
profile/log-Wald method and unavailable bounds are retained. No location
interval or test of rater differences is implied. Attach saved
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
output through `response_diagnostics` for same-data posterior residual
summaries and cases. The sheet counts saved, available, unresolved and
not-included rows separately; a summary average is unavailable if any
saved row for that recipient is unresolved. These residuals have no
expectation-one reference or calibrated cutoff, exclude calibration
uncertainty and do not predict independent future ratings. Creating or
reopening a sheet does not fit, integrate, compute intervals or diagnose
new responses. Inspect the complete analyst results before sharing a
sheet; numerical convergence does not qualify feedback decisions.

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

## References

Brennan, R. L. (2003). *Coefficients and indices in generalizability
theory*. CASMA Research Report No. 1, University of Iowa.
<https://education.uiowa.edu/sites/education.uiowa.edu/files/2026-04/casma-research-report-1-archived.pdf>.

Jiang, Z., Raymond, M., DiStefano, C., Shi, D., Liu, R., & Sun, J.
(2022). A Monte Carlo study of confidence interval methods for
generalizability coefficient. *Educational and Psychological
Measurement, 82*, 705–718.
[doi:10.1177/00131644211033899](https://doi.org/10.1177/00131644211033899)
.

## See also

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

## Examples

``` r
# Load the package and example ratings
library(mfrmr)
ratings <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1, rating_max = 4, category_policy = "preserve",
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
report$fit_calculation_basis
#>       Facet  FitBasis
#> 1     Rater saved EAP
#> 7 Criterion saved EAP
#>                                                                                                                                                                                                                                                                                 FitInterpretation
#> 1 Conditional residuals evaluated at saved EAP person measures; descriptive MnSq, not posterior-averaged residual statistics or posterior-predictive residuals. Person and calibration uncertainty are not propagated. Same-response EAP scoring does not establish an expectation-one reference.
#> 7 Conditional residuals evaluated at saved EAP person measures; descriptive MnSq, not posterior-averaged residual statistics or posterior-predictive residuals. Person and calibration uncertainty are not propagated. Same-response EAP scoring does not establish an expectation-one reference.
report$precision_by_facet[, c("Facet", "Levels", "Reliability",
                              "RealReliability", "InputUncertaintyBasis")]
#>       Facet Levels Reliability RealReliability      InputUncertaintyBasis
#> 1 Criterion      3   0.8671839       0.8664954 Observed information (MML)
#> 2    Person     48   0.6639255       0.6143843         Posterior SD (EAP)
#> 3     Rater      6   0.6773715       0.6768246 Observed information (MML)
contextual_report <- mfrm_report(res, study_context = c(
  rating_unit = "One Person by Rater by Criterion rating",
  score_direction = "Higher coded scores indicate more favorable performance",
  rubric = "Synthetic example: permitted scores 1 to 4", transformation = "None"
))
contextual_report$tables$study_context
#>             Field                                                   Value
#> 1     rating_unit                 One Person by Rater by Criterion rating
#> 2 score_direction Higher coded scores indicate more favorable performance
#> 3          rubric              Synthetic example: permitted scores 1 to 4
#> 4  transformation                                                    None
#>                                        Source
#> 1 User declaration; not verified by the model
#> 2 User declaration; not verified by the model
#> 3 User declaration; not verified by the model
#> 4 User declaration; not verified by the model

# Select a recipient explicitly. Missing intervals are explained in the sheet.
recipient <- as.character(fit$prep$levels$Rater[1])
sheet <- mfrm_report(res, style = "rater", facet = "Rater",
                     rater = recipient, output = "html", max_cases = 0)
sheet$path
#> [1] "/tmp/Rtmp9ZqIgh/mfrmr_rater_1cd51e50b7c1.html"
# Review in a browser, then choose a permanent path for continuing work.
recipient_file <- tempfile(fileext = ".html")
stopifnot(file.copy(sheet$path, recipient_file, overwrite = FALSE))
```
