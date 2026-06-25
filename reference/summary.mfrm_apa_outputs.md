# Summarize APA report-output bundles

Summarize APA report-output bundles

## Usage

``` r
# S3 method for class 'mfrm_apa_outputs'
summary(object, top_n = 3, preview_chars = 160, ...)
```

## Arguments

- object:

  Output from
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

- top_n:

  Maximum non-empty lines shown in each component preview.

- preview_chars:

  Maximum characters shown in each preview cell.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_apa_outputs`.

## Details

This summary is a diagnostics layer for APA text products, not a
replacement for the full narrative.

It reports component completeness, line/character volume, and a compact
preview for quick QA before manuscript insertion.

## Interpreting output

- `overview`: total coverage across standard text components.

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

1.  Build outputs via
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

2.  Run `summary(apa)` to screen for empty/short components.

3.  Use `apa$report_text`, `apa$table_figure_notes`, and
    `apa$table_figure_captions` as draft components for final-text
    review.

## See also

[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
apa <- build_apa_outputs(fit, diag)
summary(apa)
}
```
