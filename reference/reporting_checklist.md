# Build an auto-filled MFRM reporting checklist

Build an auto-filled MFRM reporting checklist

## Usage

``` r
reporting_checklist(
  fit,
  diagnostics = NULL,
  bias_results = NULL,
  hierarchical_structure = NULL,
  include_references = TRUE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When `NULL`, diagnostics are computed with `residual_pca = "none"`.

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  or a named list of such outputs.

- hierarchical_structure:

  Optional output from
  [`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md).
  When supplied, the "Hierarchical structure review" checklist item is
  flipped to `DraftReady = TRUE` and its `Detail` column surfaces the
  number of nested / crossed facet pairs and whether the ICC table is
  available.

- include_references:

  If `TRUE`, include a compact reference table in the returned bundle.

## Value

A named list with checklist tables. Class: `mfrm_reporting_checklist`.

## Details

This helper ports the app-level reporting checklist into a
package-native bundle. It does not try to judge substantive reporting
quality; instead, it checks whether the fitted object and related
diagnostics contain the evidence typically reported in MFRM write-ups.

Checklist items are grouped into seven core sections:

- Method section

- Global fit

- Facet-level statistics

- Element-level statistics

- Rating scale diagnostics

- Bias/interaction analysis

- Visual displays

When a fit uses the latent-regression population-model branch, the
checklist also adds a `Population Model` section covering coefficient
reporting, categorical model-matrix coding, complete-case omissions,
posterior-basis wording, and ConQuest scope wording.

The output is designed for manuscript preparation, reproducibility
records, and reproducible reporting workflows.

## What this checklist means

`reporting_checklist()` is a manuscript-preparation guide. It tells you
which reporting elements are already present in the current analysis
objects and which still need to be generated or documented. The primary
draft-status column is `DraftReady`; `ReadyForAPA` is retained as a
backward-compatible alias.

## What this checklist does not justify

- It is not a single run-level pass/fail decision for publication.

- `DraftReady = TRUE` / `ReadyForAPA = TRUE` does not certify formal
  inferential adequacy.

- Missing bias rows may simply mean `bias_results` were not supplied.

## Interpreting output

- `checklist`: one row per reporting item with `Available = TRUE/FALSE`.
  `DraftReady = TRUE` means the item can be drafted into a report with
  the package's documented caveats. `ReadyForAPA` is a
  backward-compatible alias of the same flag; neither field certifies
  formal inferential adequacy.

- `section_summary`: available items by section.

- The Global Fit section includes a "Fit/separation reporting boundary"
  row that points to
  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md),
  [`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md),
  and
  [`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
  before users phrase fit, ZSTD, separation, or reliability claims.

- `software_scope`: external-software relationship summary for `mfrmr`,
  FACETS, ConQuest, and SPSS-style tabular handoffs.

- `facets_positioning`: report-ready wording that states `mfrmr` is not
  a FACETS numerical clone and separates native estimation from
  FACETS-style handoff or external-table review.

- `visual_scope`: plotting-route summary that separates report-default
  2D figures from exploratory surface/3D-ready data handoffs, including
  a short `InterpretationCheck` for the main user-facing caveat.

- `references`: core background references when requested.

## Recommended next step

Review the rows with `Available = FALSE` or `DraftReady = FALSE`, then
add the missing diagnostics, bias results, or narrative context before
calling
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
for draft text generation. For `RSM` / `PCM` reporting runs, the
preferred route is an `MML` fit plus
`diagnose_mfrm(..., diagnostic_mode = "both")` so the checklist can see
the legacy and strict marginal screens together.

## How this differs from operational review

`reporting_checklist()` is the manuscript/reporting branch of the
package. Use it when the question is "what is still missing from the
report?" rather than "which observations or links need follow-up?" For
operational review:

- Use
  [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
  after
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  when you need ranked misfit cases and grouping views for local
  follow-up.

- Use
  [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
  after anchor/drift/chain helpers when you need operational linking
  triage rather than manuscript-oriented reporting tables.

## Typical workflow

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
    For `RSM` / `PCM` reporting runs, prefer `method = "MML"`.

2.  Compute diagnostics with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
    For `RSM` / `PCM`, prefer `diagnostic_mode = "both"`.

3.  Run `reporting_checklist()` to see which reporting elements are
    already available from the current analysis objects.

4.  If the issue is operational rather than manuscript-facing, branch to
    [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
    or
    [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
    instead of treating `reporting_checklist()` as the single review
    hub.

## See also

[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
[`specifications_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/specifications_report.md),
[`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md),
[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md),
[`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)

## Examples

``` r
if (FALSE) { # interactive()
# Fast smoke run: a JML fit + legacy-only diagnostic produces a
# populated checklist in well under a second.
toy <- load_mfrmr_data("example_core")
fit_quick <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                      method = "JML", maxit = 30)
diag_quick <- diagnose_mfrm(fit_quick, residual_pca = "none",
                             diagnostic_mode = "legacy")
chk_quick <- reporting_checklist(fit_quick, diagnostics = diag_quick)
head(chk_quick$checklist[, c("Section", "Item", "DraftReady")])

if (FALSE) { # \dontrun{
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 7, maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "both", diagnostic_mode = "both")
chk <- reporting_checklist(fit, diagnostics = diag)
summary(chk)
# Look for: a high `Ready` / `Total` ratio in the summary block.
#   Sections with `Ready = 0` need follow-up before submitting
#   (typically diagnostic_mode = "both" or a residual-PCA pass).
apa <- build_apa_outputs(fit, diag)
head(chk$checklist[, c("Section", "Item", "DraftReady", "NextAction")])
# Look for: every row where `DraftReady = "yes"` is ready to paste
#   into the manuscript. `"no"` rows include a concrete `NextAction`
#   step (e.g. "run plot_qc_dashboard()") so the gap can be closed
#   without re-reading the methodology guide.
nchar(apa$report_text)
} # }
}
```
