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

## Value

An object of class `mfrm_apa_outputs` with:

- `report_text`: APA-style Method/Results draft prose

- `table_figure_notes`: consolidated draft notes for tables/visuals

- `table_figure_captions`: draft caption candidates without figure
  numbering

- `section_map`: package-native section table for manuscript assembly

- `contract`: structured APA reporting contract used for downstream
  checks

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

For bounded `GPCM`, this helper returns a caveated partial reporting
bundle over supported diagnostics, direct tables, and plots. It also
includes a `gpcm_boundary` table. Treat the output as slope-aware
sensitivity-reporting text, not FACETS score-side equivalence, automatic
operational scoring, or design-forecasting evidence.

By default, `report_text` includes:

- model/data design summary (N, facet counts, scale range)

- optimization/convergence metrics (`Converged`, `Iterations`, `LogLik`,
  `AIC`, `BIC`)

- anchor/constraint summary (`noncenter_facet`, anchored levels, group
  anchors, dummy facets)

- latent-regression population-model wording when `fit` has an active
  `population_formula`

- category/threshold diagnostics (including disordered-step details when
  present)

- overall fit, misfit count, and top misfit levels

- facet reliability/separation, residual PCA summary, and bias-screen
  counts

## Interpreting output

- `report_text`: manuscript-draft narrative covering Method (model
  specification, estimation, convergence) and Results (global fit, facet
  separation/reliability, misfit triage, category diagnostics,
  residual-PCA screening, bias screening). Written in third-person past
  tense following APA 7th edition conventions, but still intended for
  human review.

- `table_figure_notes`: reusable draft note blocks for table/figure
  appendices.

- `table_figure_captions`: draft caption candidates aligned to generated
  outputs.

- active latent-regression fits add a population-model section and Table
  5 notes/captions that distinguish conditional-normal coefficient
  reporting from post hoc regression on EAP/MLE scores.

When bias results or PCA diagnostics are not supplied, those sections
are omitted from the narrative rather than producing placeholder text.

## Typical workflow

1.  Build diagnostics (and optional bias results). For `RSM` / `PCM`
    reporting runs, prefer an `MML` fit and
    `diagnose_mfrm(..., diagnostic_mode = "both")`.

2.  Run `build_apa_outputs(...)`.

3.  Check `summary(apa)` for completeness.

4.  Insert `apa$report_text` and note/caption fields into manuscript
    drafts after checking the listed cautions.

## Context template

A minimal `context` list can include fields such as:

- `assessment`: name of the assessment task

- `setting`: administration context

- `scale_desc`: short description of the score scale

- `rater_facet`: rater facet label used in narrative reliability text

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

## See also

[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)

## Examples

``` r
if (FALSE) { # interactive()
# Fast smoke run: a JML fit and a legacy diagnostic let us build the
# APA bundle and confirm `report_text` is non-empty in well under
# a second.
toy <- load_mfrmr_data("example_core")
fit_quick <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
diag_quick <- diagnose_mfrm(fit_quick,
  residual_pca = "none",
  diagnostic_mode = "legacy"
)
apa_quick <- build_apa_outputs(fit_quick, diag_quick)
nchar(apa_quick$report_text) > 0

if (FALSE) { # \dontrun{
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", quad_points = 7, maxit = 30
)
diag <- diagnose_mfrm(fit, residual_pca = "both", diagnostic_mode = "both")
apa <- build_apa_outputs(
  fit,
  diag,
  context = list(
    assessment = "Toy writing task",
    setting = "Demonstration dataset",
    scale_desc = "0-2 rating scale",
    rater_facet = "Rater"
  )
)
s_apa <- summary(apa)
s_apa$overview
# Look for: `SentenceCount` non-zero in every section that the run
#   should support (Method / Results / fit / reliability / bias).
#   Zero counts mean that section's prose is empty and the
#   manuscript will need to fill it manually.
chk <- reporting_checklist(fit, diagnostics = diag)
head(chk$checklist[, c("Section", "Item", "DraftReady", "NextAction")])
# Look for: rows with `DraftReady = "yes"` are ready to paste into
#   the manuscript. `"no"` rows tell you which helper / setting
#   needs to run before that paragraph can be drafted, via
#   `NextAction`. Aim for every Visual Displays / Reliability /
#   Diagnostics row to be `"yes"` before submitting.
cat(apa$report_text)
apa$section_map[, c("SectionId", "Available")]
} # }
}
```
