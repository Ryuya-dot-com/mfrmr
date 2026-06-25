# Normalize extracted ConQuest overlap tables to the `mfrmr` review contract

Normalize extracted ConQuest overlap tables to the `mfrmr` review
contract

## Usage

``` r
normalize_conquest_overlap_tables(
  conquest_population,
  conquest_item_estimates,
  conquest_case_eap,
  conquest_population_term = "auto",
  conquest_population_estimate = "auto",
  conquest_item_id = "auto",
  conquest_item_estimate = "auto",
  conquest_case_person = "auto",
  conquest_case_estimate = "auto",
  keep_extra_columns = TRUE
)
```

## Arguments

- conquest_population:

  Extracted ConQuest population-parameter table as a data.frame.

- conquest_item_estimates:

  Extracted ConQuest item-estimate table as a data.frame.

- conquest_case_eap:

  Extracted ConQuest case-level EAP table as a data.frame.

- conquest_population_term:

  Column in `conquest_population` that stores parameter names. `"auto"`
  tries conservative aliases such as `Parameter` and `Term`.

- conquest_population_estimate:

  Column in `conquest_population` that stores parameter estimates.
  `"auto"` tries aliases such as `Estimate` and `Est`.

- conquest_item_id:

  Column in `conquest_item_estimates` that stores the item identifier as
  exported or extracted by the user. `"auto"` tries aliases such as
  `ResponseVar`, `ItemID`, `Item`, and `Label`.

- conquest_item_estimate:

  Column in `conquest_item_estimates` that stores item estimates.
  `"auto"` tries aliases such as `Estimate`, `Est`, and `Facility`.

- conquest_case_person:

  Column in `conquest_case_eap` that stores person IDs. `"auto"` tries
  conservative aliases such as `Person`, `PID`, and `Sequence ID`.

- conquest_case_estimate:

  Column in `conquest_case_eap` that stores case EAP estimates. `"auto"`
  tries conservative aliases such as `Estimate`, `EAP_1`, and `EAP`.

- keep_extra_columns:

  If `TRUE`, keep all remaining columns after the standardized
  identifier and estimate columns.

## Value

A named list with class `mfrm_conquest_overlap_tables`.

## Details

This helper does not parse raw ConQuest text output. It standardizes
already extracted tables to the contract used by
[`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_conquest_overlap.md):

- population parameters become columns `Parameter`, `Estimate`, and
  `EstimateNonNumeric`;

- item estimates become columns `ItemID`, `Estimate`, and
  `EstimateNonNumeric`;

- case summaries become columns `Person`, `Estimate`, and
  `EstimateNonNumeric`.

The resulting object is intentionally conservative. It does not infer
whether item IDs correspond to exported response variables or original
item levels; that matching step remains part of
[`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_conquest_overlap.md),
where the standardized ConQuest tables are compared against a concrete
overlap bundle.

## Output

The returned object has class `mfrm_conquest_overlap_tables` and
includes:

- `summary`: one-row normalization summary

- `conquest_population`: standardized population table

- `conquest_item_estimates`: standardized item table

- `conquest_case_eap`: standardized case table

- `settings`: source-column metadata

- `notes`: interpretation notes

Read `summary(normalized)$normalization_scope` before review to confirm
that the object contains extracted tabular inputs, not parsed raw
ConQuest report text, and to check duplicate-ID / non-numeric-estimate
pre-review flags.

## See also

[`build_conquest_overlap_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md),
[`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_conquest_overlap.md)

## Examples

``` r
normalized <- normalize_conquest_overlap_tables(
  conquest_population = data.frame(
    Term = c("(Intercept)", "GroupB", "sigma2"),
    Est = c(0, 0.2, 1)
  ),
  conquest_item_estimates = data.frame(
    Item = c("I1", "I2"),
    Est = c(-0.2, 0.2)
  ),
  conquest_case_eap = data.frame(
    PID = c("P001", "P002"),
    EAP = c(-0.1, 0.1)
  ),
  conquest_population_term = "Term",
  conquest_population_estimate = "Est",
  conquest_item_id = "Item",
  conquest_item_estimate = "Est",
  conquest_case_person = "PID",
  conquest_case_estimate = "EAP"
)
summary(normalized)$normalization_scope
#>                            Area             Status
#> 1 Extracted table normalization             active
#> 2     Raw ConQuest text parsing      not performed
#> 3               Bundle matching deferred to review
#> 4        Pre-review table check      none detected
#>                                                             Evidence
#> 1                                              7 standardized row(s)
#> 2            already extracted CSV/TSV/TXT or data.frame inputs only
#> 3 review_conquest_overlap() matches rows against the exported bundle
#> 4                  0 duplicate ID(s); 0 non-numeric estimate cell(s)
#>                                                                               Interpretation
#> 1        Population, item, and case tables have been converted to the mfrmr review contract.
#> 2             This object does not prove that raw ConQuest report text was parsed correctly.
#> 3 Identifier matching and numerical comparison are intentionally handled by the review step.
#> 4        Resolve duplicate IDs or non-numeric estimates before treating the review as clean.
```
