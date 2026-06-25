# Summarize a future arbitrary-facet planning active branch

Summarize a future arbitrary-facet planning active branch

## Usage

``` r
# S3 method for class 'mfrm_future_branch_active_branch'
summary(object, digits = 3, top_n = 8, ...)
```

## Arguments

- object:

  Output from the future-branch active planning scaffold stored in
  `planning_schema$future_branch_active_branch`.

- digits:

  Number of digits used in numeric summaries.

- top_n:

  Maximum number of recommendation rows to print in the preview.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_future_branch_active_branch`.

## Details

This summary is intentionally conservative. It aggregates only
deterministic branch-side quantities already validated in the
schema-first arbitrary-facet planning scaffold: observation bookkeeping,
load/balance, coverage, guardrails, structural readiness, and
conservative recommendation ranking. It also exposes the same
manuscript-facing table/appendix metadata used by
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
so the future branch can be reviewed directly without first routing
through planning summaries. In addition to bundle-level appendix presets
and section counts, it includes export-like appendix selection summaries
by preset, reporting role, manuscript section, bundle-aware handoff
summaries, preset-specific table surface, and a table-level handoff
crosswalk, plus direct `role_summary` / `table_profile` surfaces for
table-shape review. It does not report psychometric recovery or Monte
Carlo performance.

## See also

[`summary.mfrm_design_evaluation()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md),
[`plot.mfrm_future_branch_active_branch()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_future_branch_active_branch.md)

## Examples

``` r
if (FALSE) { # \dontrun{
spec <- build_mfrm_sim_spec(
  design = list(person = 16, rater = 3, criterion = 2, assignment = 2),
  assignment = "rotating"
)
active <- spec$planning_schema$future_branch_active_branch
summary(active)
} # }
```
