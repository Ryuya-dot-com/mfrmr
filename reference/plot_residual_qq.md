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
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
p <- plot_residual_qq(fit, draw = FALSE)
head(p$data$data)
#>   Person Theoretical      Sample
#> 1   P023   -2.310991 -0.37283950
#> 2   P002   -1.862732 -0.13615206
#> 3   P032   -1.624981 -0.10420916
#> 4   P005   -1.454408 -0.10222504
#> 5   P008   -1.318011 -0.08837233
#> 6   P004   -1.202508 -0.08278029
# Look for: points hugging the y = x reference line. Heavy upper-
#   right tails indicate persons whose residual aggregates exceed
#   the standard normal expectation; pair with `plot_unexpected()`
#   for case-level follow-up. This is an exploratory screen; do
#   not treat tail behaviour as a definitive normality test.
# }
```
