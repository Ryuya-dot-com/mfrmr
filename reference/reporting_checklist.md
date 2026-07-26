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
# Minimal checklist example using a JML fit and lightweight diagnostics.
toy <- load_mfrmr_data("example_core")
fit_quick <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                      method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag_quick <- diagnose_mfrm(fit_quick, residual_pca = "none",
                             diagnostic_mode = "legacy")
chk_quick <- reporting_checklist(fit_quick, diagnostics = diag_quick)
head(chk_quick$checklist[, c("Section", "Item", "DraftReady")])
#>          Section                                                      Item
#> 1 Method Section                                       Model specification
#> 2 Method Section                                          Data description
#> 3 Method Section                                           Precision basis
#> 4 Method Section                                               Convergence
#> 5 Method Section                                     Connectivity assessed
#> 6 Method Section Empirical-Bayes shrinkage when small-N facets are present
#>   DraftReady
#> 1       TRUE
#> 2       TRUE
#> 3       TRUE
#> 4      FALSE
#> 5       TRUE
#> 6       TRUE

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 7, maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "both", diagnostic_mode = "both")
chk <- reporting_checklist(fit, diagnostics = diag)
summary(chk)
#> mfrmr Reporting Checklist Summary
#> 
#> Overview
#>  Sections Items Available DraftReady Missing NeedsDraftWork
#>         7    33        29         28       4              5
#> 
#> Section summary
#>                      Section Items Available DraftReady ReadyForAPA Missing
#>  Bias / Interaction Analysis     2         0          0           0       2
#>     Element-Level Statistics     4         4          4           4       0
#>       Facet-Level Statistics     3         3          3           3       0
#>                   Global Fit     3         3          3           3       0
#>               Method Section     8         7          7           7       1
#>     Rating Scale Diagnostics     4         4          4           4       0
#>              Visual Displays     9         8          7           7       1
#>  NeedsDraftWork NeedsAction
#>               2           2
#>               0           0
#>               0           0
#>               0           0
#>               1           1
#>               0           0
#>               2           2
#> 
#> Priority summary
#>  Priority    Severity Items
#>    medium recommended     5
#>     ready    required    12
#>     ready recommended    15
#>     ready    optional     1
#> 
#> Action items (preview)
#>                      Section                          Item Available DraftReady
#>  Bias / Interaction Analysis            Facet pairs tested     FALSE      FALSE
#>  Bias / Interaction Analysis  Screen-positive interactions     FALSE      FALSE
#>               Method Section Hierarchical structure review     FALSE      FALSE
#>              Visual Displays            Bias / DIF visuals     FALSE      FALSE
#>              Visual Displays       Strict marginal visuals      TRUE      FALSE
#>     Severity Priority
#>  recommended   medium
#>  recommended   medium
#>  recommended   medium
#>  recommended   medium
#>  recommended   medium
#>                                                                                                                                 NextAction
#>                                                                    Run bias screening if the manuscript needs interaction-level follow-up.
#>                                                                          Run bias screening before discussing interaction-level anomalies.
#>  Run `analyze_hierarchical_structure(fit)` once per design and pass the result to `reporting_checklist(..., hierarchical_structure = hs)`.
#>                                                                     Run bias or DIF screening before discussing interaction-level visuals.
#>              Treat strict marginal plots as exploratory corroboration screens, then corroborate with design review and legacy diagnostics.
#> 
#> FACETS positioning
#>                                   Topic
#>                    Estimation authority
#>                   Compatibility purpose
#>              External FACETS comparison
#>  Current model and calibration boundary
#>               Reporting source of truth
#>                 Extension beyond FACETS
#>                                                                                                                                  RecommendedWording
#>                                                 The model was estimated with mfrmr; FACETS-style output names are used only to organize the report.
#>                       FACETS-style outputs were generated for handoff or reader familiarity; they are not evidence of FACETS numerical equivalence.
#>                                   When external FACETS output is supplied, compare MnSq first and report df/ZSTD convention sensitivity separately.
#>  Describe mfrmr as a native R RSM/PCM analysis, diagnostic, and reporting environment, not as a general FACETS operational-calibration replacement.
#>                                                          Report estimates, standard errors, fit summaries, and plots from documented mfrmr objects.
#>                                                              Use package-native extensions as additional evidence and label them as mfrmr analyses.
#> 
#> Settings
#>               Setting       Value
#>    include_references        TRUE
#>  diagnostics_supplied        TRUE
#>     bias_result_count           0
#>      bias_error_count           0
#>        precision_tier model_based
#> 
#> Notes
#>  - This summary is a manuscript-preparation guide.
#>  - DraftReady indicates that the corresponding reporting element can be drafted with the package's documented caveats; it does not certify inferential adequacy.
#>  - Detailed FACETS positioning, software scope, and visual scope tables are available in `$facets_positioning`, `$software_scope`, and `$visual_scope`.
# Look for: a high `Ready` / `Total` ratio in the summary block.
#   Sections with `Ready = 0` need follow-up before submitting
#   (typically diagnostic_mode = "both" or a residual-PCA pass).
apa <- build_apa_outputs(fit, diag)
head(chk$checklist[, c("Section", "Item", "DraftReady", "NextAction")])
#>          Section                                                      Item
#> 1 Method Section                                       Model specification
#> 2 Method Section                                          Data description
#> 3 Method Section                                           Precision basis
#> 4 Method Section                                               Convergence
#> 5 Method Section                                     Connectivity assessed
#> 6 Method Section Empirical-Bayes shrinkage when small-N facets are present
#>   DraftReady
#> 1       TRUE
#> 2       TRUE
#> 3       TRUE
#> 4       TRUE
#> 5       TRUE
#> 6       TRUE
#>                                                                                                          NextAction
#> 1                             Available; adapt this evidence into the manuscript draft after methodological review.
#> 2                             Available; adapt this evidence into the manuscript draft after methodological review.
#> 3                                                    Report the precision tier as model-based in the APA narrative.
#> 4                             Available; adapt this evidence into the manuscript draft after methodological review.
#> 5                                           Document the single connected subset before making common-scale claims.
#> 6 Report both the fixed-effects and shrunk estimates; cite Efron & Morris (1973) for the empirical-Bayes rationale.
# Look for: every row where `DraftReady = "yes"` is ready to paste
#   into the manuscript. `"no"` rows include a concrete `NextAction`
#   step (e.g. "run plot_qc_dashboard()") so the gap can be closed
#   without re-reading the methodology guide.
nchar(apa$report_text)
#> [1] 4396
# }
```
