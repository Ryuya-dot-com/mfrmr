# Recode common missing-value sentinels to `NA`

Convenience helper that replaces the standard non-`NA` missing-code
sentinels used in SPSS / SAS / FACETS exports (`99`, `999`, `-1`, `"N"`,
`"NA"`, `"n/a"`, `"."`, `""`) with `NA` across the columns you select.
This is the R counterpart of the preprocessing UI in the companion
Streamlit app and is useful before calling
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
on data exported with those conventions.

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

## See also

[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## Examples

``` r
dat <- data.frame(
  Person = paste0("P", 1:5),
  Rater = c("R1", "R1", "R2", "R2", "R2"),
  Score = c(1, 99, 2, -1, 3)
)
cleaned <- recode_missing_codes(dat, columns = "Score")
cleaned$Score
#> [1]  1 NA  2 NA  3
attr(cleaned, "mfrm_missing_recoding")
#>   Column Replaced
#> 1  Score        2
```
