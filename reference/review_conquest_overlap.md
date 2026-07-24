# Review a ConQuest comparison within the documented `mfrmr` overlap scope

Review a ConQuest comparison within the documented `mfrmr` overlap scope

## Usage

``` r
review_conquest_overlap(
  bundle,
  conquest_population = NULL,
  conquest_item_estimates = NULL,
  conquest_case_eap = NULL,
  conquest_population_term = "auto",
  conquest_population_estimate = "auto",
  conquest_item_id = "auto",
  conquest_item_estimate = "auto",
  item_id_source = c("auto", "response_var", "level"),
  conquest_case_person = "auto",
  conquest_case_estimate = "auto"
)
```

## Arguments

- bundle:

  Output from
  [`build_conquest_overlap_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md).

- conquest_population:

  Normalized ConQuest population-parameter table as a data.frame, or
  output from
  [`normalize_conquest_overlap_exports()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_exports.md),
  [`normalize_conquest_overlap_files()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_files.md),
  or
  [`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_tables.md).

- conquest_item_estimates:

  Normalized ConQuest item-estimate table as a data.frame. Leave `NULL`
  when `conquest_population` is an object from one of the ConQuest
  normalization helpers.

- conquest_case_eap:

  Normalized ConQuest case-level EAP table as a data.frame. Leave `NULL`
  when `conquest_population` is an object from one of the ConQuest
  normalization helpers.

- conquest_population_term:

  Column in `conquest_population` that stores parameter names. `"auto"`
  tries conservative aliases such as `Parameter` and `Term`.

- conquest_population_estimate:

  Column in `conquest_population` that stores parameter estimates.
  `"auto"` tries aliases such as `Estimate` and `Est`.

- conquest_item_id:

  Column in `conquest_item_estimates` that stores the item identifier.
  This may be the exported response variable (for example `I001`) or the
  original item/facet level. `"auto"` tries aliases such as
  `ResponseVar`, `ItemID`, `Item`, and `Label`.

- conquest_item_estimate:

  Column in `conquest_item_estimates` that stores the item estimate.
  `"auto"` tries aliases such as `Estimate`, `Est`, and `Facility`.

- item_id_source:

  How `conquest_item_id` should be matched. `"auto"` chooses the larger
  overlap between exported response variables and original item levels,
  with ties resolved toward exported response variables.

- conquest_case_person:

  Column in `conquest_case_eap` that stores person IDs. `"auto"` tries
  conservative aliases such as `Person`, `PID`, and `Sequence ID`.

- conquest_case_estimate:

  Column in `conquest_case_eap` that stores case EAP estimates. `"auto"`
  tries conservative aliases such as `Estimate`, `EAP_1`, and `EAP`.

## Value

A named list with class `mfrm_conquest_overlap_review`.

## Details

This helper compares normalized ConQuest output tables against the
exact- overlap bundle produced by
[`build_conquest_overlap_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md).
It is intentionally conservative:

- it does **not** parse raw ConQuest text output automatically;

- its primary route expects output from
  [`normalize_conquest_overlap_exports()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_exports.md),
  which reads the four native CSV files requested by the generated
  command; custom extracted tables may use
  [`normalize_conquest_overlap_files()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_files.md)
  or
  [`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_tables.md);

- and it reports numerical differences and missing elements without
  claiming that any fixed tolerance implies software equivalence.

This is the package's external-table review path. It is distinct from
`reference_case_benchmark(cases = "synthetic_conquest_overlap_dry_run")`,
which only round-trips package-native tables through the same
normalization and review contract without executing ConQuest.

The intended workflow is:

1.  export a bundle for the documented comparison scope with
    [`build_conquest_overlap_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md);

2.  run the narrow matching case in ConQuest;

3.  normalize the four requested CSV files with
    [`normalize_conquest_overlap_exports()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_exports.md);

4.  pass those tables here to inspect direct differences, centered item
    agreement, and case-level EAP agreement.

## Output

The returned object has class `mfrm_conquest_overlap_review` and
includes:

- `overall`: one-row comparison summary with
  missing/duplicate/non-numeric attention-item counts and worst-row
  labels

- `population_comparison`: parameter-by-parameter comparison table

- `item_comparison`: centered item-estimate comparison table

- `case_comparison`: case-level EAP comparison table

- `attention_items`: missing, malformed, or unmatched elements

- `settings`: review settings

- `notes`: interpretation notes

## Interpretation

- Read `summary(review)$review_scope` first to confirm that the result
  is a supplied-table review, not raw ConQuest text parsing or a
  software- equivalence claim.

- Population slopes and `sigma2` are intended for direct comparison.

- Item estimates should be interpreted after centering.

- Case estimates should be interpreted as posterior EAP summaries under
  the fitted population model.

- The `overall` table reports both mean and maximum absolute differences
  for compared population, centered item, and case rows. The
  `PopulationMaxAbsParameter`, `ItemCenteredMaxAbsItem`, and
  `CaseMaxAbsPerson` columns identify the row where each maximum
  absolute difference occurs.

- Missing or non-numeric rows in `attention_items` indicate that the
  external tables do not align cleanly with the exported overlap bundle.

## See also

[`build_conquest_overlap_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md),
[`normalize_conquest_overlap_files()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_files.md),
[`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_tables.md),
[`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_benchmark.md)

## Examples

``` r
if (FALSE) { # \dontrun{
bundle <- build_conquest_overlap_bundle()
normalized <- normalize_conquest_overlap_exports(
  bundle,
  parameter_file = "conquest_overlap_conquest_parameters.csv",
  regression_file = "conquest_overlap_conquest_reg_coefficients.csv",
  covariance_file = "conquest_overlap_conquest_covariance.csv",
  case_file = "conquest_overlap_conquest_cases_eap.csv"
)
review <- review_conquest_overlap(bundle, normalized)
summary(review)$summary
} # }
```
