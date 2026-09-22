# Inspect a portable fixed calibration

[`print()`](https://rdrr.io/r/base/print.html) gives a compact lifecycle
and scope overview. [`summary()`](https://rdrr.io/r/base/summary.html)
returns the same identifiers together with coordinate and anchor counts
and the structured validation refusals, if any. Both methods inspect the
stored artifact and do not refit a model or consult training responses.

## Usage

``` r
# S3 method for class 'mfrm_calibration'
summary(object, ...)

# S3 method for class 'mfrm_calibration'
print(x, ...)

# S3 method for class 'summary.mfrm_calibration'
print(x, ...)
```

## Arguments

- object, x:

  An `mfrm_calibration` returned by the portable calibration workflow.

- ...:

  Reserved for generic compatibility.

## Value

[`summary()`](https://rdrr.io/r/base/summary.html) returns a
`summary.mfrm_calibration`.
[`print()`](https://rdrr.io/r/base/print.html) returns its input
invisibly.

## Details

A calibration artifact intentionally has no
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method. Its
coordinate table mixes facet, step, and interaction parameter roles, and
the artifact does not contain calibration-parameter uncertainty. Plot
returned score batches with
[mfrm_calibration_score_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_score_methods.md)
instead; inspect `calibration$parameters$coordinates` when auditing
stored point coordinates.

## See also

[mfrm_calibration_workflow](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md),
[mfrm_calibration_score_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_score_methods.md)
