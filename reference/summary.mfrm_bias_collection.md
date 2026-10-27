# Summarize all retained bias screens

Summarize all retained bias screens

## Usage

``` r
# S3 method for class 'mfrm_bias_collection'
summary(object, ...)

# S3 method for class 'mfrm_bias_collection'
print(x, digits = 3, ...)

# S3 method for class 'summary.mfrm_bias_collection'
print(x, digits = 3, ...)
```

## Arguments

- object, x:

  A result from
  [`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md).

- ...:

  Reserved; additional arguments are rejected.

- digits:

  Number of significant digits used for printing; calculations and
  returned tables retain their precision.

## Value

[`summary()`](https://rdrr.io/r/base/summary.html) returns a
`summary.mfrm_bias_collection` list: `overview` has one row per
requested interaction, `cells` combines retained cell tables with an
`Interaction` identifier and explicit `PointAvailable`,
`ScreenAvailable` and `ScreenPositive` fields, `errors` lists failed
pairs, and `optimization_failures` retains cell-level optimizer records.
Original cell columns, including facet levels, observed counts, signed
`Bias Size`, conditional `S.E.`, `t` and any GPCM profile status, are
preserved. `settings`, `fit_identity` and `notes` retain provenance and
interpretation. Print methods return their input invisibly.

## Details

No model, diagnostics or cell calculation is repeated. The overview
counts finite bias estimates from successful cell optimizations
separately from cells with a finite screening statistic and positive
finite conditional SE. `ScreenPositive` is missing when no statistic can
be screened, rather than reporting zero. Failed pairs remain visible
even when the original batch used `keep_errors = FALSE`. Older
collections without retained tables are labeled `not_retained`; they are
not recalculated.

A positive bias shift increases expected coded scores conditional on the
fitted model. It does not necessarily mean better performance or unfair
leniency. Baseline calibration and Person uncertainty are held fixed.
Different pairs use overlapping data, so do not add their observed
counts to obtain a study sample size. The overview's mean absolute bias
describes magnitude only; use the signed cell estimates to study
direction. Counts cover retained
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
cells: unobserved combinations and cells omitted by the chosen screening
options are not reconstructed. No multiplicity-adjusted confirmatory
decisions are supplied.

## See also

[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md),
[`plot.mfrm_bias_collection()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bias_collection.md),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("summary.mfrm_bias_collection", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                method = "MML")
screens <- estimate_all_bias(fit)
review <- summary(screens)
review$overview
head(review$cells[, c("Interaction", "Bias Size", "ObsN", "ScreenAvailable")])
} # }
```
