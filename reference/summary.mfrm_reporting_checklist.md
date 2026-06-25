# Summarize a reporting-checklist bundle for manuscript work

Summarize a reporting-checklist bundle for manuscript work

## Usage

``` r
# S3 method for class 'mfrm_reporting_checklist'
summary(object, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).

- top_n:

  Maximum number of draft-action rows shown in the compact action table.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_reporting_checklist` with:

- `overview`: run-level counts of available and draft-ready items

- `section_summary`: section-level checklist coverage

- `software_scope`: external-software relationship summary

- `facets_positioning`: report-ready FACETS relationship wording

- `visual_scope`: plotting-route and 3D-ready data-handoff summary,
  including the main `InterpretationCheck` caveat for each visual family

- `priority_summary`: counts by priority/severity

- `action_items`: highest-priority rows that still need draft work

- `settings`: checklist settings rendered as a compact table

- `notes`: interpretation notes

## See also

[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[summary.mfrm_apa_outputs](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_apa_outputs.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 7, maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "both", diagnostic_mode = "both")
chk <- reporting_checklist(fit, diagnostics = diag)
summary(chk)
} # }
```
