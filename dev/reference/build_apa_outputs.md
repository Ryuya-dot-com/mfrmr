# Build APA text outputs from model results

Build APA text outputs from model results

## Usage

``` r
build_apa_outputs(
  fit,
  diagnostics,
  bias_results = NULL,
  context = list(),
  whexact = FALSE
)

# S3 method for class 'mfrm_apa_outputs'
summary(object, top_n = 3, preview_chars = 160, ...)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md).

- context:

  Optional named list for report context.

- whexact:

  Use exact ZSTD transformation.

- object:

  Output from `build_apa_outputs()`.

- top_n:

  Maximum non-empty lines shown in each component preview.

- preview_chars:

  Maximum characters shown in each preview cell.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `mfrm_apa_outputs` with:

- `report_text`: APA-oriented Method/Results draft prose

- `decision`: plain-language source-fit interpretation plus the separate
  precision-contract decision; `FormalInference` is `"Yes"` only when
  both fit readiness and `contract$precision$supports_formal_inference`
  support it

- `fit_readiness`, `fit_readiness_components`, and
  `fit_readiness_parameters`: exact source-fit readiness provenance

- `table_figure_notes`: consolidated draft notes for tables/visuals

- `table_figure_captions`: draft caption candidates without figure
  numbering

- `section_map`: package-native section table for manuscript assembly

- `contract`: structured APA reporting contract used for downstream
  checks

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_apa_outputs`.

## Details

`context` is an optional named list for narrative customization.
Frequently used fields include:

- `assessment`, `setting`, `scale_desc`

- `rater_training`, `raters_per_response`

- `rater_facet` (used for targeted reliability note text)

- `line_width` (optional text wrapping width for `report_text`; default
  = 92)

Output text includes residual-PCA screening commentary if PCA
diagnostics are available in `diagnostics`.

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
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interrater_agreement_table.md)
for the matching, repeated-rating and denominator conventions.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize APA
report-output bundles

For [`summary()`](https://rdrr.io/r/base/summary.html): This summary is
a diagnostics layer for APA text products, not a replacement for the
full narrative.

It reports component completeness, line/character volume, and a compact
preview for quick QA before manuscript insertion.

## Interpreting output

- `report_text`: manuscript-draft narrative covering Method (model
  specification, estimation, convergence) and Results (global fit, facet
  separation/reliability, misfit triage, category diagnostics,
  residual-PCA screening, bias screening), organized as an APA-oriented,
  third-person Method/Results draft. It is intended for human review and
  is not a claim of complete APA 7 or JARS compliance.

- `table_figure_notes`: reusable draft note blocks for table/figure
  appendices.

- `table_figure_captions`: draft caption candidates aligned to generated
  outputs.

- active latent-regression fits add a population-model section and Table
  5 notes/captions that distinguish conditional-normal coefficient
  reporting from post hoc regression on EAP/MLE scores.

When bias results or PCA diagnostics are not supplied, those sections
are omitted from the narrative rather than producing placeholder text.
Reporting reuses stored residual PCA results and does not compute
omitted overall or facet-specific analyses. Request the intended scope
with `diagnose_mfrm(..., residual_pca = "overall")`, `"facet"`, or
`"both"` first.

For [`summary()`](https://rdrr.io/r/base/summary.html):

- `overview`: total coverage across standard text components.

- `decision`: the source-fit decision shown before draft-completeness
  checks; text completeness cannot promote a review or blocked fit.

- `components`: per-component density and mention checks (including
  residual-PCA mentions).

- `sections`: package-native section coverage table.

- `content_checks`: contract-based alignment checks for APA drafting
  readiness.

- `overview$DraftContractPass`: the primary contract-completeness flag
  for draft text components.

- `overview$ReadyForAPA`: a backward-compatible alias of that contract
  flag, not a certification of inferential adequacy.

- `preview`: first non-empty lines for fast visual review.

## Typical workflow

1.  Build diagnostics (and optional bias results). For `RSM` / `PCM`
    reporting runs, prefer an `MML` fit and
    `diagnose_mfrm(..., diagnostic_mode = "both")`.

2.  Run `build_apa_outputs(...)`.

3.  Check `summary(apa)` for completeness.

4.  Insert `apa$report_text` and note/caption fields into manuscript
    drafts after checking the listed cautions.

For [`summary()`](https://rdrr.io/r/base/summary.html):

1.  Build outputs via `build_apa_outputs()`.

2.  Run `summary(apa)` to screen for empty/short components.

3.  Use `apa$report_text`, `apa$table_figure_notes`, and
    `apa$table_figure_captions` as draft components for final-text
    review.

## Context template

A minimal `context` list can include fields such as:

- `assessment`: name of the assessment task

- `setting`: administration context

- `scale_desc`: short description of the score scale

- `rater_facet`: rater facet label used in narrative reliability text

## Input validation

`fit` must be an `mfrm_fit` object from
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).
`diagnostics` must be an `mfrm_diagnostics` object from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).
`context` must be a list (use `NULL` or
[`list()`](https://rdrr.io/r/base/list.html) for no extra context). If
supplied, `bias_results` must come from
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
or another package-native bias helper that provides a table component.

## Saved-result reuse

Supplied screening results must describe this fitted analysis. Results
from another fit or older results without identity metadata are refused.
See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_compatibility_layer.md)
to recreate them from the saved fit and matching diagnostics without
refitting the model.

## See also

[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_visual_summaries.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/reporting_checklist.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_reporting_and_apa.md)

`build_apa_outputs()`,
[`base::summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
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
# Supplementary workflow: run explicitly to keep routine checks brief.
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
