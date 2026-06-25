# Summarize person-fit indices

[`summary()`](https://rdrr.io/r/base/summary.html) for
[`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md)
output gives a compact, report-ready reading order: first the number of
persons and flags, then status counts, then the highest-priority review
rows. The summary keeps `lz_star` availability visible so users do not
silently treat uncorrected `lz` as Snijders-corrected output.

## Usage

``` r
# S3 method for class 'mfrm_person_fit_indices'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md).

- digits:

  Number of digits used when printing numeric columns.

- top_n:

  Number of review rows retained in `top_review`.

- ...:

  Unused.

## Value

An object of class `summary.mfrm_person_fit_indices` with:

- `overview`

- `status_summary`

- `report_index_summary`

- `lz_star_status_summary`

- `top_review`

- `caveats`

- `thresholds`

- `reporting_map`

- `notes`
