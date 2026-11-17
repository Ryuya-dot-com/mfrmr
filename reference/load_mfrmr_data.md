# List packaged ordered-response MFRM datasets

List packaged ordered-response MFRM datasets

Load a packaged ordered-response MFRM dataset

## Usage

``` r
list_mfrmr_data(details = FALSE)

load_mfrmr_data(
  name = c("example_core", "example_bias", "example_operational", "study1", "study2",
    "combined", "study1_itercal", "study2_itercal", "combined_itercal")
)
```

## Arguments

- details:

  If `FALSE` (default), return the backward-compatible character vector
  of dataset keys. If `TRUE`, return a catalog describing the intended
  teaching role and design of each dataset accepted by
  `load_mfrmr_data()`.

- name:

  Dataset key. One of the values from `list_mfrmr_data()`. If omitted,
  the backward-compatible default is `"example_core"`; new code should
  pass a key explicitly.

## Value

A character vector of dataset keys accepted by `load_mfrmr_data()`, or,
when `details = TRUE`, a data.frame with `Key`, `Rows`, `Persons`,
`Raters`, `Criteria`, `CountBasis`, `PrimaryUse`, `Design`, and
`Empirical`.

A data.frame in long format: each row is one rating, not one Person.

## Details

Use this helper when you want to select packaged data programmatically
(e.g., inside scripts, loops, or interactive-application wrappers). For
the separately packaged G-theory and agreement tables loaded with
[`data()`](https://rdrr.io/r/utils/data.html), see
[mfrmr_gtheory_data](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gtheory_data.md)
and
[mfrmr_agreement_data](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_agreement_data.md).
These use different input structures and are not keys for
`load_mfrmr_data()`.

Typical pattern:

1.  call `list_mfrmr_data()` to see available keys.

2.  pass one key to `load_mfrmr_data()`.

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

With `details = FALSE`, returned values are canonical dataset keys
accepted by `load_mfrmr_data()`. With `details = TRUE`, use `PrimaryUse`
and `Design` to distinguish the applied teaching example from idealized,
planted-effect diagnostic, and larger sparse-design datasets.
`CountBasis` states whether person/rater counts use raw labels or
Study-prefixed labels. Every bundled dataset is synthetic rather than
empirical.

The return value is a plain long-format `data.frame`. The example and
study-specific keys are ready for
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
after checking role and score mappings. The `combined` keys are
design-review objects: overlapping IDs or simple Study-based prefixes do
not establish a common measurement scale, so an explicit identity,
anchor, or linking design is required before a joint fit is
interpretable.

## Typical workflow

1.  Capture keys in a script (`keys <- list_mfrmr_data()`).

2.  Select one key by index or name.

3.  Load data via `load_mfrmr_data()` and continue analysis. Treat a
    `combined` key as a design-review object, not as a direct-fit
    example.

&nbsp;

1.  list valid names with `list_mfrmr_data()`.

2.  load one dataset key with `load_mfrmr_data(name)`.

3.  fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and inspect with [`summary()`](https://rdrr.io/r/base/summary.html)
    / [`plot()`](https://rdrr.io/r/graphics/plot.default.html).

## See also

`load_mfrmr_data()`,
[ej2021_data](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)

`list_mfrmr_data()`,
[ej2021_data](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)

## Examples

``` r
library(mfrmr)

# See the names accepted by load_mfrmr_data()
list_mfrmr_data()
#> [1] "example_core"        "example_bias"        "example_operational"
#> [4] "study1"              "study2"              "combined"           
#> [7] "study1_itercal"      "study2_itercal"      "combined_itercal"   

# Compare the purpose and design of the available datasets
catalog <- list_mfrmr_data(details = TRUE)
catalog[, c("Key", "PrimaryUse", "Design")]
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

# Choose one dataset
ratings <- load_mfrmr_data("example_operational")
head(ratings)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A
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
