# List packaged simulation datasets

List packaged simulation datasets

## Usage

``` r
list_mfrmr_data()
```

## Value

Character vector of dataset keys accepted by
[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md).

## Details

Use this helper when you want to select packaged data programmatically
(e.g., inside scripts, loops, or shiny/streamlit wrappers).

Typical pattern:

1.  call `list_mfrmr_data()` to see available keys.

2.  pass one key to
    [`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md).

## Interpreting output

Returned values are canonical dataset keys accepted by
[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md).

## Typical workflow

1.  Capture keys in a script (`keys <- list_mfrmr_data()`).

2.  Select one key by index or name.

3.  Load data via
    [`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)
    and continue analysis.

## See also

[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md),
[ej2021_data](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)

## Examples

``` r
keys <- list_mfrmr_data()
keys
#> [1] "example_core"     "example_bias"     "study1"           "study2"          
#> [5] "combined"         "study1_itercal"   "study2_itercal"   "combined_itercal"
d <- load_mfrmr_data(keys[1])
head(d)
#>         Study Person Rater Criterion Score Group
#> 1 ExampleCore   P001   R01   Content     3     A
#> 2 ExampleCore   P002   R01   Content     3     A
#> 3 ExampleCore   P003   R01   Content     4     A
#> 4 ExampleCore   P004   R01   Content     3     A
#> 5 ExampleCore   P005   R01   Content     2     A
#> 6 ExampleCore   P006   R01   Content     3     A
```
