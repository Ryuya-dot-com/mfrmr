# List packaged simulation datasets

List packaged simulation datasets

## Usage

``` r
list_mfrmr_data(details = FALSE)
```

## Arguments

- details:

  If `FALSE` (default), return the backward-compatible character vector
  of dataset keys. If `TRUE`, return a catalog describing the intended
  teaching role and design of every dataset.

## Value

A character vector of dataset keys accepted by
[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md),
or, when `details = TRUE`, a data.frame with `Key`, `Rows`, `Persons`,
`Raters`, `Criteria`, `CountBasis`, `PrimaryUse`, `Design`, and
`Empirical`.

## Details

Use this helper when you want to select packaged data programmatically
(e.g., inside scripts, loops, or interactive-application wrappers).

Typical pattern:

1.  call `list_mfrmr_data()` to see available keys.

2.  pass one key to
    [`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md).

## Interpreting output

With `details = FALSE`, returned values are canonical dataset keys
accepted by
[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md).
With `details = TRUE`, use `PrimaryUse` and `Design` to distinguish the
applied teaching example from idealized, planted-effect diagnostic, and
larger sparse-design datasets. `CountBasis` states whether person/rater
counts use raw labels or Study-prefixed labels. Every bundled dataset is
synthetic rather than empirical.

## Typical workflow

1.  Capture keys in a script (`keys <- list_mfrmr_data()`).

2.  Select one key by index or name.

3.  Load data via
    [`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)
    and continue analysis. Treat a `combined` key as a design-review
    object, not as a direct-fit example.

## See also

[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md),
[ej2021_data](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)

## Examples

``` r
keys <- list_mfrmr_data()
keys
#> [1] "example_core"        "example_bias"        "example_operational"
#> [4] "study1"              "study2"              "combined"           
#> [7] "study1_itercal"      "study2_itercal"      "combined_itercal"   
list_mfrmr_data(details = TRUE)[, c(
  "Key", "PrimaryUse", "Design", "CountBasis"
)]
#>                   Key                                          PrimaryUse
#> 1        example_core                             Idealized fast examples
#> 2        example_bias    DFF and bias demonstrations with planted effects
#> 3 example_operational                           Beginner applied workflow
#> 4              study1               Unequal-workload sparse-design review
#> 5              study2                         Larger sparse-design review
#> 6            combined      Identity/linking design review; not direct fit
#> 7      study1_itercal                     Legacy synthetic variant review
#> 8      study2_itercal                     Legacy synthetic variant review
#> 9    combined_itercal Identity/linking sensitivity review; not direct fit
#>                                                                  Design
#> 1                               Complete crossing; no planned omissions
#> 2               Balanced two-rater assignment; planted non-null effects
#> 3                 Connected two-rater assignment; six planned omissions
#> 4                 Two raters per person; highly unequal rater workloads
#> 5                  Two raters per person; incomplete criterion coverage
#> 6 Overlapping IDs; requires explicit anchors/linking for a common scale
#> 7                    Legacy Study 1 variant; rows and scores can differ
#> 8                    Legacy Study 2 variant; rows and scores can differ
#> 9 Overlapping IDs; requires explicit anchors/linking for a common scale
#>                                                  CountBasis
#> 1                                             unique labels
#> 2                                             unique labels
#> 3                                             unique labels
#> 4                                             unique labels
#> 5                                             unique labels
#> 6 raw labels; 513 persons and 30 raters when Study-prefixed
#> 7                                             unique labels
#> 8                                             unique labels
#> 9 raw labels; 513 persons and 30 raters when Study-prefixed
d <- load_mfrmr_data("example_operational")
head(d)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A
```
