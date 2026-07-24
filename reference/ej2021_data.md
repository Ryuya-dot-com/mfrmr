# Legacy synthetic MFRM datasets inspired by Eckes and Jin (2021)

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

- `ej2021_study1`

- `ej2021_study2`

- `ej2021_combined`

- `ej2021_study1_itercal`

- `ej2021_study2_itercal`

- `ej2021_combined_itercal`

Naming convention:

- `study1` / `study2`: separate simulation studies

- `combined`: row-bind of study1 and study2

- `_itercal`: legacy synthetic sensitivity variant. These objects can
  differ in observed rows as well as scores and should not be
  interpreted as a controlled one-parameter recalibration.

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

For the combined rows, `Persons` and `Raters` count unique raw labels.
Treating the two Study labels as distinct namespaces would instead give
513 person labels and 30 rater labels, but would leave two unlinked
components.

## Provenance and limits

These are legacy synthetic datasets whose stored responses reproduce the
dimensions described above. The exact response-generation code and
random seed are not available, so the objects must not be used as
parameter-recovery evidence or as evidence for a particular generating
distribution. The separately stored `_itercal` objects can differ in
observed rows as well as scores; they are legacy variants, not empirical
calibration standards or a controlled one-parameter recalibration.

## Combined-data caution

The `combined` objects reuse `P001`–`P206` and `R01`–`R12` across the
two study labels. A combined analysis is meaningful only when those
labels encode an intended cross-study identity and an explicit anchor or
linking design establishes a common scale. Prefixing `Person` and
`Rater` by `Study` removes accidental label collisions, but it creates
disconnected study components and does not by itself establish a common
scale. Analyze the studies separately unless the linking design has been
specified and reviewed. The combined datasets are not beginner workflow
examples or direct-fit examples.

## Interpreting output

The study-specific datasets are in long format and can be passed to
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
after confirming column-role mapping. The `combined` objects require a
reviewed identity and anchor/linking design before a joint fit;
row-binding or prefixing identifiers alone does not create a common
scale.

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
