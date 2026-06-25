# Read a FACETS fit table for fit review

Read a FACETS fit table for fit review

## Usage

``` r
read_facets_fit_table(
  file,
  facet = NULL,
  facet_map = NULL,
  format = c("auto", "delimited", "scorefile"),
  facet_col = NULL,
  level_col = NULL,
  delimiter = NULL,
  encoding = "UTF-8"
)

import_facets_fit_table(
  file,
  facet = NULL,
  facet_map = NULL,
  format = c("auto", "delimited", "scorefile"),
  facet_col = NULL,
  level_col = NULL,
  delimiter = NULL,
  encoding = "UTF-8"
)
```

## Arguments

- file:

  Path to a FACETS-derived fit table. A character vector of files is
  accepted. A directory containing `score.N.txt` files is also accepted.

- facet:

  Optional facet name to assign when the file does not contain a facet
  column. Use this for one-facet CSV exports.

- facet_map:

  Optional character vector mapping FACETS score-file numbers to facet
  names, for example `c("1" = "Person", "2" = "Rater")`. If unnamed,
  positions are used as score-file numbers.

- format:

  File format. `"auto"` detects FACETS `score.N.txt` files from their
  name/header; `"delimited"` reads a CSV/TSV/semicolon table; and
  `"scorefile"` reads a FACETS score-file table.

- facet_col, level_col:

  Optional explicit column names for delimited tables when automatic
  detection is not sufficient. For score files, `level_col` can override
  the column immediately before `F-Number`.

- delimiter:

  Optional delimiter for delimited tables. If omitted, comma, tab, and
  semicolon are detected from the header line.

- encoding:

  File encoding passed to
  [`readLines()`](https://rdrr.io/r/base/readLines.html).

## Value

A tibble with standardized fit-table columns suitable for
`facets_fit_review(fit, facets_fit = read_facets_fit_table(...))`.

## Details

This helper does not run FACETS. It reads FACETS output that already
exists on disk and normalizes it to columns that
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
can consume: `Facet`, `Level`, `Estimate`, `SE`, `N`, `Infit`, `Outfit`,
`InfitZSTD`, `OutfitZSTD`, `DF_Infit`, and `DF_Outfit`.

Two common workflows are supported:

- a FACETS score file such as `score.2.txt`, where the facet name is
  supplied by `facet_map` or inferred as `Facet2`. Both comma-delimited
  score files with field names and fixed-field score files using the
  FACETS manual column positions are supported;

- a CSV/TSV table already exported from FACETS or a harmonization
  script, with FACETS-style column names such as `Infit MnSq`,
  `Outfit ZStd`, and `T.Count`.

After import, pass the table to
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md).
Inspect `review$external_table_quality` first when the FACETS export is
partial, duplicated, or missing MnSq/df columns. Then inspect
`review$external_comparison` for supplied FACETS-vs-mfrmr differences
and `review$df_sensitivity` / `review$df_sensitive` for
engine-vs-FACETS-style df/ZSTD convention sensitivity. Use
`plot(review, type = "df_sensitivity")` for a quick visual check of the
largest ZSTD shifts caused by df convention.

## See also

[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
path <- tempfile(fileext = ".csv")
write.csv(
  data.frame(
    Facet = "Rater", Level = "R1", Infit = 1.02, Outfit = 0.98,
    InfitZSTD = 0.3, OutfitZSTD = -0.2, DF_Infit = 12, DF_Outfit = 13
  ),
  path,
  row.names = FALSE
)
read_facets_fit_table(path)
#> # A tibble: 1 × 12
#>   Facet Level Estimate    SE     N Infit Outfit InfitZSTD OutfitZSTD DF_Infit
#>   <chr> <chr>    <dbl> <dbl> <dbl> <dbl>  <dbl>     <dbl>      <dbl>    <dbl>
#> 1 Rater R1          NA    NA    NA  1.02   0.98       0.3       -0.2       12
#> # ℹ 2 more variables: DF_Outfit <dbl>, Source <chr>
```
