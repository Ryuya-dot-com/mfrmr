# Normal quantile-quantile plot of person standardized residuals

Produces a Q-Q plot of per-person standardized residuals. Under the
fitted Rasch-family model the residuals are approximately N(0, 1), so
deviations from the reference line diagnose distributional misfit that
mean-square summaries may miss.

## Usage

``` r
plot_residual_qq(
  fit,
  diagnostics = NULL,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit`.

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output; required entries are generated internally when absent.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` object with a `data` slot containing `Person`,
`Theoretical`, `Sample` columns.

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
p <- plot_residual_qq(fit, draw = FALSE)
head(p$data$data)
# Look for: points hugging the y = x reference line. Heavy upper-
#   right tails indicate persons whose residual aggregates exceed
#   the standard normal expectation; pair with `plot_unexpected()`
#   for case-level follow-up. This is an exploratory screen; do
#   not treat tail behaviour as a definitive normality test.
}
```
