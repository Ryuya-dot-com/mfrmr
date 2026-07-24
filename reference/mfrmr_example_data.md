# Synthetic many-facet rating examples

Compact synthetic many-facet datasets sized to exercise the documented
workflow. Their dimensions are not evidence of sample-size adequacy for
an applied study.

## Format

A data.frame with 6 columns:

- Study:

  Example dataset label (`"OperationalExample"`, `"ExampleCore"`, or
  `"ExampleBias"`).

- Person:

  Person/respondent identifier.

- Rater:

  Rater identifier.

- Criterion:

  Criterion facet label.

- Score:

  Observed category score on a four-category scale (`1`–`4`).

- Group:

  Balanced grouping label (`"A"` / `"B"`). It is neutral in the
  operational and core examples; the bias example has the planted group
  structure described below.

## Source

Synthetic documentation data generated from rating-scale Rasch facet
designs with fixed seeds. Generator scripts are maintained under
`data-raw/` for this release in the public source repository. These are
synthetic examples, not empirical records.

## Details

Available data objects:

- `mfrmr_example_operational`

- `mfrmr_example_operational_design` (documented separately below)

- `mfrmr_example_core`

- `mfrmr_example_bias`

`mfrmr_example_operational` is the primary applied teaching example. It
has a connected but incomplete two-rater assignment, moderately unequal
rater workloads, and six planned criterion-level omissions. Scores are
sampled directly from stated RSM category probabilities. The six
unobserved ratings are absent rows in the long data rather than `NA`
scores. Each group contains 24 persons, and three omissions in each
group leave 141 observed rows for Group A and 141 for Group B. The
balanced `Group` variable has no effect in the generating model; random
observed differences may still occur.

`mfrmr_example_core` is an idealized complete crossing generated from a
single latent trait plus rater and criterion main effects. It is useful
as a fast deterministic example, but it is not representative of routine
incomplete operational assignment.

`mfrmr_example_bias` instead uses a balanced partial two-rater
assignment. Group A and B latent means are -0.1 and 0.1 logits,
respectively, with a common SD of 0.9. It also contains:

- a planted `Group x Criterion` effect (`Group B` is advantaged by 1.2
  logits on `Language`)

- a planted `Rater x Criterion` interaction (`R04 x Accuracy` lowers the
  linear predictor by 1.2 logits)

This lets differential-functioning and bias-analysis help pages
demonstrate non-null findings.

## Data dimensions

|                     |          |             |            |              |            |
|---------------------|----------|-------------|------------|--------------|------------|
| **Dataset**         | **Rows** | **Persons** | **Raters** | **Criteria** | **Groups** |
| example_operational | 282      | 48          | 6          | 3            | 2          |
| example_core        | 768      | 48          | 4          | 4            | 2          |
| example_bias        | 384      | 48          | 4          | 4            | 2          |

## Suggested usage

- Use `mfrmr_example_operational` for the beginner data-to-report
  workflow and for inspecting incomplete but connected assignment.

- Use `mfrmr_example_core` for fast, idealized checks and examples that
  specifically require complete crossing.

- Use `mfrmr_example_bias` for
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
  and
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

All three objects can be loaded either with
[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)
or directly with [`data()`](https://rdrr.io/r/utils/data.html), for
example `data("mfrmr_example_operational", package = "mfrmr")`.

## Examples

``` r
data("mfrmr_example_operational", package = "mfrmr")
table(mfrmr_example_operational$Score)
#> 
#>  1  2  3  4 
#> 62 96 78 46 
table(mfrmr_example_operational$Group)
#> 
#>   A   B 
#> 141 141 
```
