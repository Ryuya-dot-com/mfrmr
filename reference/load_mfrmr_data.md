# Load a packaged simulation dataset

Load a packaged simulation dataset

## Usage

``` r
load_mfrmr_data(
  name = c("example_core", "example_bias", "example_operational", "study1", "study2",
    "combined", "study1_itercal", "study2_itercal", "combined_itercal")
)
```

## Arguments

- name:

  Dataset key. One of the values from
  [`list_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/list_mfrmr_data.md).
  If omitted, the backward-compatible default is `"example_core"`; new
  code should pass a key explicitly.

## Value

A data.frame in long format.

## Details

`load_mfrmr_data("<key>")` is the canonical loader for the packaged
datasets and the entry point used across the package help and vignettes.
The equivalent base-R alternative
`data("<object-name>", package = "mfrmr")` remains available for users
who prefer the full [`data()`](https://rdrr.io/r/utils/data.html)
spelling; both paths return identical long-format data frames.

All returned datasets include the core long-format columns `Study`,
`Person`, `Rater`, `Criterion`, and `Score`. Some datasets, such as the
packaged documentation examples, also include auxiliary variables like
`Group` for DIF/bias demonstrations.

## Interpreting output

The return value is a plain long-format `data.frame`. The example and
study-specific keys are ready for
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
after checking role and score mappings. The `combined` keys are
design-review objects: overlapping IDs or simple Study-based prefixes do
not establish a common measurement scale, so an explicit identity,
anchor, or linking design is required before a joint fit is
interpretable.

## Typical workflow

1.  list valid names with
    [`list_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/list_mfrmr_data.md).

2.  load one dataset key with `load_mfrmr_data(name)`.

3.  fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and inspect with [`summary()`](https://rdrr.io/r/base/summary.html)
    / [`plot()`](https://rdrr.io/r/graphics/plot.default.html).

## See also

[`list_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/list_mfrmr_data.md),
[ej2021_data](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)

## Examples

``` r
data("mfrmr_example_operational", package = "mfrmr")
head(mfrmr_example_operational)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A

d <- load_mfrmr_data("example_operational")
table(d$Rater)
#> 
#> R01 R02 R03 R04 R05 R06 
#>  47  56  50  47  44  38 
table(d$Criterion, d$Score)
#>               
#>                 1  2  3  4
#>   Content      11 33 34 16
#>   Language     25 29 25 15
#>   Organization 26 34 19 15
```
