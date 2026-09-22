# Recode common missing-value sentinels to `NA`

Convenience helper that replaces the standard non-`NA` missing-code
sentinels used in SPSS / SAS / FACETS exports (`99`, `999`, `-1`, `"N"`,
`"NA"`, `"n/a"`, `"."`, `""`) with `NA` across the columns you select.
It is useful before calling
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
on data exported with those conventions. A sentinel is a value used to
mean "missing" instead of an actual score. Only recode values that your
data documentation defines as missing. For custom score markers, specify
both `columns = "Score"` and `codes`; this preserves a person or rater
identifier such as `99`.

## Usage

``` r
recode_missing_codes(
  data,
  columns = NULL,
  codes = c("99", "999", "-1", "N", "NA", "n/a", ".", ""),
  numeric_codes = TRUE,
  verbose = FALSE
)
```

## Arguments

- data:

  A data frame.

- columns:

  Character vector of column names to recode. Defaults to `NULL`, in
  which case all columns are scanned.

- codes:

  Character vector of code values to convert to `NA`. Defaults to the
  FACETS / SPSS / SAS conventions; override when your instrument uses
  different sentinels.

- numeric_codes:

  Logical; if `TRUE` (default), numeric columns are also compared
  against the numeric conversion of `codes`.

- verbose:

  Logical; if `TRUE`, emits a
  [`message()`](https://rdrr.io/r/base/message.html) summary of
  per-column replacement counts.

## Value

The input `data` with the specified missing sentinels replaced by `NA`.
A `mfrm_missing_recoding` attribute records the per-column replacement
counts for traceability logs.

## Details

Save the returned data, for example
`cleaned <- recode_missing_codes(...)`. The original object is
unchanged. This helper replaces cells and retains every row; later,
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
and
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
exclude rating rows with missing scores or required identifiers. Inspect
the replacement counts with `attr(cleaned, "mfrm_missing_recoding")`,
then review and fit `cleaned`.

The defaults differ across entry points: this helper scans all columns
when `columns` is omitted. In
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
and
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
`missing_codes = TRUE` uses the conventional code set on the score
column only; an explicit `missing_codes` vector applies to the person,
facet, and score columns. Use this helper with an explicit score column
when your custom code could also be a legitimate identifier.

## See also

[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## Examples

``` r
library(mfrmr)

# A small input example: 99 and . mean missing only in the Score column
ratings <- data.frame(
  Person = c("001", "001", "002", "002"),
  Rater = c("R1", "99", "R1", "99"),
  Score = c("3", "99", ".", "2")
)
cleaned <- recode_missing_codes(
  ratings,
  columns = "Score",
  codes = c("99", ".")
)
cleaned # Two scores become NA; rater ID 99 and all four rows remain
#>   Person Rater Score
#> 1    001    R1     3
#> 2    001    99  <NA>
#> 3    002    R1  <NA>
#> 4    002    99     2
attr(cleaned, "mfrm_missing_recoding") # Score: Replaced = 2
#>   Column Replaced
#> 1  Score        2
# Use the returned cleaned data for subsequent data review and fitting
```
