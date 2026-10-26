# Plot common-plan expected-score intervals

Plot common-plan expected-score intervals

## Usage

``` r
# S3 method for class 'mfrm_fair_intervals'
plot(x, draw = TRUE, show_title = FALSE, show_notes = FALSE, ...)
```

## Arguments

- x:

  Saved output of
  [`confint.mfrm_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fair_average.md).

- draw:

  Logical; draw with base graphics when true.

- show_title, show_notes:

  Logical; display title/cautions, off by default.

- ...:

  Must be empty.

## Value

Invisibly an `mfrm_plot_data` object. Its `data$data` retains all result
rows and uncertainty labels; `data$notes` retains interpretation.

## Details

Points are common-plan expected scores or declared paired differences.
Bars show only available pointwise bounds under the saved method.
Missing bars are not zero uncertainty. Plotting never recalculates the
fit or removes unresolved rows from the saved result. For refit results
the bars show the empirical interval; endpoint Monte Carlo enclosures
are retained in the returned table and `data$monte_carlo`, not drawn as
sampling intervals. See
[`confint.mfrm_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fair_average.md)
for the estimand, assumptions and finite-sample limitations.

## Examples

``` r
# Continue the confint.mfrm_fair_average() example:
# plot(ci)
# p <- plot(ci, draw = FALSE)
# p$data$notes
```
