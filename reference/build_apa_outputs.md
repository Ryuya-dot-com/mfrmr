# Build APA text outputs from model results

Build APA text outputs from model results

Print APA narrative text with preserved line breaks

## Usage

``` r
build_apa_outputs(
  fit,
  diagnostics,
  bias_results = NULL,
  context = list(),
  whexact = FALSE
)

# S3 method for class 'mfrm_apa_text'
print(x, ...)

# S3 method for class 'mfrm_apa_outputs'
summary(object, top_n = 3, preview_chars = 160, ...)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- context:

  Optional named list for report context.

- whexact:

  Use exact ZSTD transformation.

- x:

  Character text object from `build_apa_outputs()$report_text`.

- ...:

  Reserved for generic compatibility.

- object:

  Output from `build_apa_outputs()`.

- top_n:

  Maximum non-empty lines shown in each component preview.

- preview_chars:

  Maximum characters shown in each preview cell.

## Value

An object of class `mfrm_apa_outputs` with:

- `report_text`: APA-oriented Method/Results draft prose

- `decision`: plain-language source-fit interpretation plus the separate
  uncertainty assessment; `FormalInference` is `"Yes"` only when both
  fit readiness and `contract$precision$supports_formal_inference`
  support it

- `fit_readiness`, `fit_readiness_components`, and
  `fit_readiness_parameters`: exact source-fit readiness provenance

- `table_figure_notes`: consolidated draft notes for tables/visuals

- `table_figure_captions`: draft caption candidates without figure
  numbering

- `section_map`: package-native section table for manuscript assembly

- `contract`: draft content, uncertainty basis and source-fit checks

The input object (invisibly).

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_apa_outputs`.

## Details

Use `context` to supply study information for the draft:

- `assessment`, `setting`, `scale_desc`: assessment name, administration
  context and score scale.

- `rater_training`, `raters_per_response`: training and assignment
  details.

- `rater_facet`: facet label for reliability wording, subject to the
  agreement-summary restriction below.

- `line_width`: text wrapping width for `report_text` (default 92).

For `GPCM`, this helper returns a caveated partial reporting bundle over
supported diagnostics, direct tables, and plots. It also includes a
`gpcm_boundary` table. Treat the output as slope-aware
sensitivity-reporting text, not FACETS score-side equivalence, automatic
operational scoring, or design-forecasting evidence.

By default, `report_text` includes:

- model/data design summary (N, facet counts, scale range)

- optimization/convergence metrics (`Converged`, `Iterations`, `LogLik`)
  plus the eligible canonical MML AIC/Person-BIC/SABIC panel or its
  explicit ineligibility and legacy-descriptive status; q\<31 MML
  criteria are explicitly labelled screening/review-only rather than
  automatic ranking

- anchor/constraint summary (`noncenter_facet`, centering convention,
  anchored levels, group anchors, dummy facets)

- latent-regression population-model wording when `fit` has an active
  `population_formula`

- category/threshold diagnostics (including disordered-step details when
  present)

- overall fit, misfit count, and top misfit levels

- facet reliability/separation, residual PCA summary, and bias-screen
  counts

- stored inter-rater agreement, its matched-opportunity denominator and
  unavailable outcomes, separately from separation reliability

Agreement wording uses the rater facet in the stored diagnostics
summary; `context$rater_facet` does not recalculate or relabel that
summary. The model-expected baseline uses fitted category probabilities
with calibration fixed, not marginal-frequency chance agreement.
Adjacent agreement includes exact matches and differences of at most 1
on the compared score scale. Missing expected values remain explicit,
including the stored number of opportunities without valid
probabilities. An absent summary does not establish agreement. See
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
for the matching, repeated-rating and denominator conventions.

Prints APA narrative text with preserved paragraph breaks using
[`cat()`](https://rdrr.io/r/base/cat.html). This is preferred over bare
[`print()`](https://rdrr.io/r/base/print.html) when you want readable
multi-line report output in the console.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize APA
report-output bundles

For [`summary()`](https://rdrr.io/r/base/summary.html): Inspect
component coverage, line/character counts and previews before reading
the full draft.

## Reviewing the draft

`report_text` is a third-person Method/Results draft;
`table_figure_notes` and `table_figure_captions` provide matching notes
and captions. Review them against the study record before manuscript
use; these are not certifications of APA 7 or JARS compliance. Active
latent-regression fits add a population section and Table 5
notes/captions distinguishing conditional-normal coefficients from post
hoc regression on EAP/MLE scores.

Missing bias or PCA inputs cause those sections to be omitted. Reporting
does not compute omitted PCA analyses: choose
`residual_pca = "overall"`, `"facet"` or `"both"` in
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
first. For supported MML fits, `diagnostic_mode = "both"` retains
plug-in and marginal diagnostics with different interpretations. Use
`summary(apa)$content_checks` to check the draft against the supplied
results, then read the full text.

## Input validation

`fit` must be an `mfrm_fit` object from
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
`diagnostics` must be an `mfrm_diagnostics` object from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
`context` must be a list (use `NULL` or
[`list()`](https://rdrr.io/r/base/list.html) for no extra context). If
supplied, `bias_results` must come from
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
or another package-native bias helper that provides a table component.

## Saved-result reuse

Supplied screening results must describe this fitted analysis. Results
from another fit or older results without identity metadata are refused.
See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
to recreate them from the saved fit and matching diagnostics without
refitting the model.

## Interpreting output

The printed text is the same content stored in
`build_apa_outputs(...)$report_text`, but with explicit paragraph
breaks.

For [`summary()`](https://rdrr.io/r/base/summary.html):

- `overview`: total coverage across standard text components.

- `decision`: the source-fit decision shown before draft-completeness
  checks; text completeness cannot promote a review or blocked fit.

- `components`: per-component density and mention checks (including
  residual-PCA mentions).

- `sections`: package-native section coverage table.

- `content_checks`: checks that draft text agrees with the supplied
  results.

- `overview$DraftContractPass`: whether the expected information is
  present in draft text components.

- `overview$ReadyForAPA`: a backward-compatible alias of that
  completeness flag, not a certification of inferential adequacy.

- `preview`: first non-empty lines for fast visual review.

## Typical workflow

1.  Generate `apa <- build_apa_outputs(...)`.

2.  Print readable narrative with `apa$report_text`.

3.  Use `summary(apa)` to check completeness before manuscript use.

## See also

[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[mfrm_report_checklist](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

`build_apa_outputs()`,
[`base::summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("build_apa_outputs", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Use the diagnostics saved with this fit
diagnostics <- example_fit$diagnostics

# Prepare draft wording from the fitted model and diagnostics
apa <- build_apa_outputs(
  fit,
  diagnostics = diagnostics,
  context = list(
    assessment = "Synthetic writing assessment",
    setting = "Demonstration dataset",
    scale_desc = "1-4 rating scale",
    rater_facet = "Rater"
  )
)

# Check which sections are supported, then read the draft
apa_review <- summary(apa)
apa_review$content_checks
cat(apa$report_text)
# Adapt the text to the study question, design, and evidence before using it
} # }
# Optional workflow; run the example explicitly as shown below.
# example("print.mfrm_apa_text", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
apa <- build_apa_outputs(fit, diag)
apa$report_text
} # }
# Optional workflow; run the example explicitly as shown below.
# example("summary.mfrm_apa_outputs", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
apa <- build_apa_outputs(fit, diag)
summary(apa)
} # }
```
