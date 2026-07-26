# Normalize extracted ConQuest overlap files to the `mfrmr` review contract

Normalize extracted ConQuest overlap files to the `mfrmr` review
contract

## Usage

``` r
normalize_conquest_overlap_files(
  population_file,
  item_file,
  case_file,
  population_delimiter = c("auto", "comma", "tab", "semicolon", ",", "\t", ";"),
  item_delimiter = c("auto", "comma", "tab", "semicolon", ",", "\t", ";"),
  case_delimiter = c("auto", "comma", "tab", "semicolon", ",", "\t", ";"),
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

- population_file:

  Path to an extracted ConQuest population-parameter table in
  CSV/TSV/TXT form.

- item_file:

  Path to an extracted ConQuest item-estimate table in CSV/TSV/TXT form.

- case_file:

  Path to an extracted ConQuest case-level EAP table in CSV/TSV/TXT
  form.

- population_delimiter:

  Delimiter for `population_file`. `"auto"` chooses comma, tab, or
  semicolon from the file extension/header line.

- item_delimiter:

  Delimiter for `item_file`. `"auto"` chooses from the file
  extension/header line.

- case_delimiter:

  Delimiter for `case_file`. `"auto"` chooses from the file
  extension/header line.

- conquest_population_term:

  Column in `population_file` that stores parameter names. `"auto"`
  tries conservative aliases such as `Parameter` and `Term`.

- conquest_population_estimate:

  Column in `population_file` that stores parameter estimates. `"auto"`
  tries aliases such as `Estimate` and `Est`.

- conquest_item_id:

  Column in `item_file` that stores the item identifier as extracted by
  the user. `"auto"` tries aliases such as `ResponseVar`, `ItemID`,
  `Item`, and `Label`.

- conquest_item_estimate:

  Column in `item_file` that stores item estimates. `"auto"` tries
  aliases such as `Estimate`, `Est`, and `Facility`.

- conquest_case_person:

  Column in `case_file` that stores person IDs. `"auto"` tries
  conservative aliases such as `Person`, `PID`, and `Sequence ID`.

- conquest_case_estimate:

  Column in `case_file` that stores case EAP estimates. `"auto"` tries
  conservative aliases such as `Estimate`, `EAP_1`, and `EAP`.

- keep_extra_columns:

  If `TRUE`, keep all remaining columns after the standardized
  identifier and estimate columns.

## Value

A named list with class `mfrm_conquest_overlap_tables`.

## Details

This helper is a thin file-wrapper around
[`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_tables.md).
It is intentionally limited to already extracted tabular files and does
not parse raw ConQuest report text.

The recommended workflow is:

1.  export a bundle for the documented comparison scope with
    [`build_conquest_overlap_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md);

2.  extract the relevant ConQuest tables to CSV/TSV/TXT files;

3.  call `normalize_conquest_overlap_files()` on those files;

4.  pass the result to
    [`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_conquest_overlap.md).

Read `summary(normalized)$normalization_scope` before review to confirm
that the files were treated as extracted tables, not raw ConQuest report
text, and to check duplicate-ID / non-numeric-estimate pre-review flags.

## See also

[`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_tables.md),
[`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_conquest_overlap.md)

## Examples

``` r
# \donttest{
bundle <- build_conquest_overlap_bundle()
tmp_dir <- tempdir()
pop_path <- file.path(tmp_dir, "cq_pop.csv")
item_path <- file.path(tmp_dir, "cq_item.tsv")
case_path <- file.path(tmp_dir, "cq_case.csv")
utils::write.csv(
  data.frame(
    Term = bundle$mfrmr_population$Parameter,
    Est = bundle$mfrmr_population$Estimate
  ),
  pop_path,
  row.names = FALSE
)
utils::write.table(
  data.frame(
    Item = bundle$mfrmr_item_estimates$ResponseVar,
    Est = bundle$mfrmr_item_estimates$Estimate
  ),
  item_path,
  sep = "\t",
  row.names = FALSE
)
utils::write.csv(
  data.frame(
    PID = bundle$mfrmr_case_eap$Person,
    EAP = bundle$mfrmr_case_eap$Estimate
  ),
  case_path,
  row.names = FALSE
)
normalized <- normalize_conquest_overlap_files(
  population_file = pop_path,
  item_file = item_path,
  case_file = case_path,
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
#> 1                                             69 standardized row(s)
#> 2            already extracted CSV/TSV/TXT or data.frame inputs only
#> 3 review_conquest_overlap() matches rows against the exported bundle
#> 4                  0 duplicate ID(s); 0 non-numeric estimate cell(s)
#>                                                                               Interpretation
#> 1        Population, item, and case tables have been converted to the mfrmr review contract.
#> 2             This object does not prove that raw ConQuest report text was parsed correctly.
#> 3 Identifier matching and numerical comparison are intentionally handled by the review step.
#> 4        Resolve duplicate IDs or non-numeric estimates before treating the review as clean.
review <- review_conquest_overlap(bundle, normalized)
summary(review)$summary
#>   PopulationParametersExpected PopulationParametersCompared PopulationMae
#> 1                            3                            2  3.330669e-16
#>   PopulationMaxAbsDifference PopulationMaxAbsParameter ItemRowsExpected
#> 1               4.440892e-16                         X                6
#>   ItemRowsCompared ItemCenteredCorrelation ItemCenteredMae
#> 1                6                       1    1.122944e-15
#>   ItemCenteredMaxAbsDifference ItemCenteredMaxAbsItem CaseRowsExpected
#> 1                 3.330669e-15                   I006               60
#>   CaseRowsCompared CaseCorrelation      CaseMae CaseMaxAbsDifference
#> 1               60               1 9.641882e-16         4.884981e-15
#>   AttentionItems AttentionMissing AttentionDuplicate AttentionNonNumeric
#> 1              0                0                  0                   0
# }
```
