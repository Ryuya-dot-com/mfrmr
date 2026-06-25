# Purpose-built example datasets for package help pages

Compact synthetic many-facet datasets designed for documentation
examples. Both datasets are large enough to avoid tiny-sample toy
behavior while remaining fast in `R CMD check` examples.

## Format

A data.frame with 6 columns:

- Study:

  Example dataset label (`"ExampleCore"` or `"ExampleBias"`).

- Person:

  Person/respondent identifier.

- Rater:

  Rater identifier.

- Criterion:

  Criterion facet label.

- Score:

  Observed category score on a four-category scale (`1`–`4`).

- Group:

  Balanced grouping variable used in DFF/DIF examples (`"A"` / `"B"`).

## Source

Synthetic documentation data generated from rating-scale Rasch facet
designs with fixed seeds in `data-raw/make-example-data.R`.

## Details

Available data objects:

- `mfrmr_example_core`

- `mfrmr_example_bias`

`mfrmr_example_core` is generated from a single latent trait plus rater
and criterion main effects, making it suitable for general fitting,
plotting, and reporting examples.

`mfrmr_example_bias` starts from the same basic design but adds:

- a known `Group x Criterion` effect (`Group B` is advantaged on
  `Language`)

- a known `Rater x Criterion` interaction (`R04 x Accuracy`)

This lets differential-functioning and bias-analysis help pages
demonstrate non-null findings.

## Data dimensions

|              |          |             |            |              |            |
|--------------|----------|-------------|------------|--------------|------------|
| **Dataset**  | **Rows** | **Persons** | **Raters** | **Criteria** | **Groups** |
| example_core | 768      | 48          | 4          | 4            | 2          |
| example_bias | 384      | 48          | 4          | 4            | 2          |

## Suggested usage

- Use `mfrmr_example_core` for fitting, diagnostics, design-weighted
  precision curves, and generic plots/reports.

- Use `mfrmr_example_bias` for
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
  and
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

Both objects can be loaded either with
[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)
or directly via `data("mfrmr_example_core", package = "mfrmr")` /
`data("mfrmr_example_bias", package = "mfrmr")`.

## Examples

``` r
data("mfrmr_example_core", package = "mfrmr")
table(mfrmr_example_core$Score)
#> 
#>   1   2   3   4 
#> 139 241 252 136 
table(mfrmr_example_core$Group)
#> 
#>   A   B 
#> 384 384 
```
