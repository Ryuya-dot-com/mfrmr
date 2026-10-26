# Load a packaged ordered-response MFRM dataset

Load a packaged ordered-response MFRM dataset

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

A data.frame in long format: each row is one rating, not one Person.

## Details

For a first MFRM analysis, run
`ratings <- load_mfrmr_data("example_operational")`. This reads data
already included in mfrmr; no CSV, download or data-generation code is
needed. `ratings` is a name you choose for the returned table. It is not
a second dataset to create. Older examples may name the same object
`toy` or `d`. Start by reading `head(ratings)`, `names(ratings)` and
`table(ratings$Score)`.

`load_mfrmr_data("<key>")` is the canonical loader for packaged
ordered-response MFRM datasets and the entry point used across the
package help and vignettes. The equivalent base-R alternative
`data("<object-name>", package = "mfrmr")` remains available for users
who prefer the full [`data()`](https://rdrr.io/r/utils/data.html)
spelling; both paths return identical long-format data frames.

All returned datasets include the core long-format columns `Study`,
`Person`, `Rater`, `Criterion`, and `Score`. Some datasets, such as the
packaged documentation examples, also include auxiliary variables like
`Group` for DIF/bias demonstrations. The supplied ratings are synthetic
teaching data, not empirical records. For observed-score G-theory
examples with multiple score columns, see
[mfrmr_gtheory_data](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gtheory_data.md);
for agreement examples, see
[mfrmr_agreement_data](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_agreement_data.md).
Those datasets use [`data()`](https://rdrr.io/r/utils/data.html) because
their row/column roles differ from the ordered-response MFRM tables
returned here.

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
library(mfrmr)

# Load synthetic ratings and inspect their columns and score frequencies
ratings <- load_mfrmr_data("example_operational")
head(ratings)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A
names(ratings)
#> [1] "Study"     "Person"    "Rater"     "Criterion" "Score"     "Group"    
table(ratings$Score)
#> 
#>  1  2  3  4 
#> 62 96 78 46 

# Optional: base R's data() loads the same dataset under its full name
data("mfrmr_example_operational", package = "mfrmr")
identical(ratings, mfrmr_example_operational) # TRUE: both contain the same data
#> [1] TRUE
```
