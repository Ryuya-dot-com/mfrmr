# Summarize an `mfrm_bias` object in a user-friendly format

Summarize an `mfrm_bias` object in a user-friendly format

## Usage

``` r
# S3 method for class 'mfrm_bias'
summary(object, digits = 3, top_n = 10, p_cut = 0.05, ...)
```

## Arguments

- object:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of strongest bias rows to keep.

- p_cut:

  Significance cutoff used for counting flagged rows.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_bias` with:

- `overview`: interaction facets/order, cell counts, and effect-size
  profile

- `chi_sq`: fixed-effect chi-square block

- `final_iteration`: end-of-iteration status row

- `top_rows`: highest-`|t|` interaction rows

- `notes`: short interpretation notes

## Details

This method returns a compact interaction-bias summary:

- interaction facets/order and analyzed cell counts

- effect-size profile (`|bias|` mean/max, significant cell count)

- fixed-effect chi-square block

- iteration-end convergence indicators

- top rows ranked by absolute t

## Interpreting output

- `overview`: interaction order, analyzed cells, and effect-size
  profile.

- `chi_sq`: fixed-effect test block.

- `final_iteration`: end-of-loop status from the bias routine.

- `top_rows`: strongest bias contrasts by `|t|`; bounded `GPCM`
  summaries also retain the profile-likelihood review columns when
  present.

## Typical workflow

1.  Estimate interactions with
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

2.  Check `summary(bias)` for screen-positive and unstable cells.

3.  Use
    [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
    or
    [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)
    for details.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_bias")
toy <- toy[toy$Person %in% unique(toy$Person)[1:8], ]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 1)
summary(bias)
}
```
