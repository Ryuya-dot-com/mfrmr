# Summarize a legacy-compatible workflow run

Summarize a legacy-compatible workflow run

## Usage

``` r
# S3 method for class 'mfrm_facets_run'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md).

- digits:

  Number of digits for numeric rounding in summaries.

- top_n:

  Maximum rows shown in nested preview tables.

- ...:

  Passed through to nested summary methods.

## Value

An object of class `summary.mfrm_facets_run`.

## Details

This method returns a compact cross-object summary that combines:

- model overview (`object$fit$summary`)

- resolved column mapping

- run settings (`run_info`)

- nested summaries of `fit` and `diagnostics`

## Interpreting output

- `overview`: convergence, information criteria, and scale size.

- `mapping`: sanity check for auto/explicit column mapping.

- `fit` / `diagnostics`: drill-down summaries for reporting decisions.

## Typical workflow

1.  Run
    [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
    to execute a one-shot pipeline.

2.  Inspect with `summary(out)` for mapping and convergence checks.

3.  Review nested objects (`out$fit`, `out$diagnostics`) as needed.

## See also

[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[`summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:8], , drop = FALSE]
out <- run_mfrm_facets(
  data = toy_small,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  maxit = 30
)
s <- summary(out)
s$overview[, c("Model", "Method", "Converged")]
s$mapping
}
```
