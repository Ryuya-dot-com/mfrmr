# Simulated MFRM datasets based on Eckes and Jin (2021)

Synthetic many-facet rating datasets in long format. All datasets
include one row per observed rating.

## Format

A data.frame with 5 columns:

- Study:

  Study label (`"Study1"` or `"Study2"`).

- Person:

  Person/respondent identifier.

- Rater:

  Rater identifier.

- Criterion:

  Criterion facet label.

- Score:

  Observed category score.

## Source

Simulated for this package with design settings informed by Eckes and
Jin (2021). The Eckes & Jin (2021) Method section reports the following
design parameters that motivated the synthetic versions shipped here:
Study 1 had 307 examinees (149 males, 158 females), 18 raters (4 males,
14 females), and 3 criteria (global impression, task fulfillment,
linguistic realization) on a 4-category rating scale (TDN levels
rescored 1-4); Study 2 had 206 examinees (66 males, 140 females), 12
raters (1 male, 11 females), and 9 criteria on the same 4-category
scale. The packaged datasets reproduce these (examinees, raters,
criteria, categories) shapes but use simulated responses, so they are
not the real TestDaF data.

## Details

Available data objects:

- `mfrmr_example_core`

- `mfrmr_example_bias`

- `ej2021_study1`

- `ej2021_study2`

- `ej2021_combined`

- `ej2021_study1_itercal`

- `ej2021_study2_itercal`

- `ej2021_combined_itercal`

Naming convention:

- `study1` / `study2`: separate simulation studies

- `combined`: row-bind of study1 and study2

- `_itercal`: iterative-calibration variant

Use
[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)
for programmatic selection by key.

## Data dimensions

|                  |          |             |            |              |
|------------------|----------|-------------|------------|--------------|
| **Dataset**      | **Rows** | **Persons** | **Raters** | **Criteria** |
| study1           | 1842     | 307         | 18         | 3            |
| study2           | 3287     | 206         | 12         | 9            |
| combined         | 5129     | 307         | 18         | 12           |
| study1_itercal   | 1842     | 307         | 18         | 3            |
| study2_itercal   | 3341     | 206         | 12         | 9            |
| combined_itercal | 5183     | 307         | 18         | 12           |

Score range: 1–4 (four-category rating scale).

## Simulation design

Person ability is drawn from N(0, 1). Rater severity effects span
approximately -0.5 to +0.5 logits. Criterion difficulty effects span
approximately -0.3 to +0.3 logits. Scores are generated from the
resulting linear predictor plus Gaussian noise, then discretized into
four categories. The `_itercal` variants use a second iteration of
calibrated rater severity parameters.

## Interpreting output

Each dataset is already in long format and can be passed directly to
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
after confirming column-role mapping.

## Typical workflow

1.  Inspect available datasets with
    [`list_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/list_mfrmr_data.md).

2.  Load one dataset using
    [`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md).

3.  Fit and diagnose with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

## References

Eckes, T., & Jin, K.-Y. (2021). Measuring rater centrality effects in
writing assessment: A Bayesian facets modeling approach. *Psychological
Test and Assessment Modeling, 63*(1), 65–94.

## Examples

``` r
data("ej2021_study1", package = "mfrmr")
head(ej2021_study1)
#>    Study Person Rater              Criterion Score
#> 1 Study1   P001   R08      Global_Impression     4
#> 2 Study1   P001   R08 Linguistic_Realization     3
#> 3 Study1   P001   R08       Task_Fulfillment     3
#> 4 Study1   P001   R10      Global_Impression     4
#> 5 Study1   P001   R10 Linguistic_Realization     3
#> 6 Study1   P001   R10       Task_Fulfillment     2
table(ej2021_study1$Study)
#> 
#> Study1 
#>   1842 
```
