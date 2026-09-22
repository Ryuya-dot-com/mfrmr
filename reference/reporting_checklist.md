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

This helper builds a package-native reporting checklist. It does not try
to judge substantive reporting quality; instead, it checks whether the
fitted object and related diagnostics contain the evidence typically
reported in MFRM write-ups.

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

- Study questions, recruitment, rater training, the assignment process,
  missingness reasons, ethics, and substantive interpretation require
  the author's study record. Available output does not verify those
  facts. The "Manuscript coverage map" in
  [`vignette("mfrmr-reporting-and-apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-reporting-and-apa.md)
  pairs reporting topics with numerical evidence and information to
  supply manually.

## Interpreting output

- `checklist`: one row per reporting item with `Available = TRUE/FALSE`.
  `DraftReady = TRUE` means the item can be drafted into a report with
  the package's documented caveats. `ReadyForAPA` is a
  backward-compatible alias of the same flag; neither field certifies
  formal inferential adequacy.

- `fit_readiness`, `fit_readiness_components`, and
  `fit_readiness_parameters`: exact source-fit v3 readiness provenance;
  these fields are not re-derived from checklist completeness.

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

- `references`: abbreviated background citations and topics when
  requested, not a complete bibliography. Verify full records for the
  methods used; use `citation("mfrmr")` for the installed software's
  citation.

## Recommended next step

Review the rows with `Available = FALSE` or `DraftReady = FALSE`, then
add the missing diagnostics, bias results, or narrative context before
calling
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
for draft text generation. For `RSM` / `PCM` reporting runs where the
MML population assumptions are defensible, the most complete
package-native route is an `MML` fit plus
`diagnose_mfrm(..., diagnostic_mode = "both")` so the checklist can see
the legacy and strict marginal screens together. A JML route remains
available when its estimand and incidental-parameter limitations better
match the analysis purpose.

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

# Compute diagnostics once for the following checks
diagnostics <- diagnose_mfrm(fit)

# Which reporting items still need evidence or explanation?
checklist <- reporting_checklist(fit, diagnostics = diagnostics)
checklist$section_summary
#>                       Section Items Available DraftReady ReadyForAPA Missing
#> 1 Bias / Interaction Analysis     2         0          0           0       2
#> 2    Element-Level Statistics     4         4          4           4       0
#> 3      Facet-Level Statistics     3         3          3           3       0
#> 4                  Global Fit     3         2          2           2       1
#> 5              Method Section     8         7          7           7       1
#> 6    Rating Scale Diagnostics     4         4          4           4       0
#> 7             Visual Displays     9         7          6           6       2
#>   NeedsDraftWork NeedsAction
#> 1              2           2
#> 2              0           0
#> 3              0           0
#> 4              1           1
#> 5              1           1
#> 6              0           0
#> 7              3           3

# Review the missing items and their suggested next actions
subset(checklist$checklist, !DraftReady,
       c("Section", "Item", "DraftReady", "NextAction"))
#>                        Section                          Item DraftReady
#> 8               Method Section Hierarchical structure review      FALSE
#> 10                  Global Fit              PCA of residuals      FALSE
#> 23 Bias / Interaction Analysis            Facet pairs tested      FALSE
#> 24 Bias / Interaction Analysis  Screen-positive interactions      FALSE
#> 27             Visual Displays          Residual PCA visuals      FALSE
#> 30             Visual Displays       Strict marginal visuals      FALSE
#> 31             Visual Displays            Bias / DIF visuals      FALSE
#>                                                                                                                                   NextAction
#> 8  Run `analyze_hierarchical_structure(fit)` once per design and pass the result to `reporting_checklist(..., hierarchical_structure = hs)`.
#> 10                                                                Run residual PCA if you want to comment on unexplained residual structure.
#> 23                                                                   Run bias screening if the manuscript needs interaction-level follow-up.
#> 24                                                                         Run bias screening before discussing interaction-level anomalies.
#> 27                                                     Run residual PCA if you want scree/loadings visuals for residual-structure follow-up.
#> 30             Treat strict marginal plots as exploratory corroboration screens, then corroborate with design review and legacy diagnostics.
#> 31                                                                    Run bias or DIF screening before discussing interaction-level visuals.
# DraftReady is TRUE/FALSE; TRUE means draft material is available with caveats
# Choose follow-up analyses for your question, not merely to make every row TRUE
# }
```
