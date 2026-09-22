# Review differential-functioning results

[`summary()`](https://rdrr.io/r/base/summary.html) returns the contrast,
cell, summary, and configuration tables without refitting. A summary
from
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
keeps its DFF label when printed; a summary from
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
keeps its DIF label.

## Usage

``` r
# S3 method for class 'mfrm_dif'
summary(object, ...)

# S3 method for class 'mfrm_dff'
summary(object, ...)

# S3 method for class 'summary.mfrm_dif'
print(x, ...)

# S3 method for class 'summary.mfrm_dff'
print(x, ...)

# S3 method for class 'mfrm_dif'
print(x, ...)

# S3 method for class 'mfrm_dff'
print(x, ...)
```

## Arguments

- object, x:

  An `mfrm_dff` or `mfrm_dif` result, or its summary.

- ...:

  Reserved for generic compatibility.

## Value

[`summary()`](https://rdrr.io/r/base/summary.html) returns a structured
differential-functioning summary.
[`print()`](https://rdrr.io/r/base/print.html) returns its input
invisibly.

## See also

[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
