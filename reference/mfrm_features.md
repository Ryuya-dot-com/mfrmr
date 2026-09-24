# Prepare external features for exploratory grouping

Keep one row per Person, rater, or other entity, review feature
availability, and optionally attach user-supplied reasons for missing
values.

## Usage

``` r
mfrm_features(data, id, features, missing_reasons = NULL)

# S3 method for class 'mfrm_features'
print(x, ...)

# S3 method for class 'mfrm_features'
summary(object, ...)
```

## Arguments

- data:

  A data frame with one row per entity. Repeated rating rows must be
  summarized or joined to an entity-level table before calling this
  function.

- id:

  Name of the unique, nonmissing identifier column. Character, factor,
  or finite numeric identifiers are stored as character strings without
  trimming.

- features:

  Explicit character vector of feature column names, excluding the
  identifier. Numeric, character, factor, ordered factor, and logical
  columns are supported. Character columns become nominal factors;
  logical columns represent symmetric binary features. Ordered factor
  levels retain their declared order. Dates, lists, and matrices must be
  converted explicitly.

- missing_reasons:

  Optional data frame with columns `ID`, `Feature`, and `Reason`, one
  row per annotated missing cell. IDs refer to `id`; features must be
  selected columns. Reasons for observed or unknown cells are refused.
  Unannotated missing cells are labelled "Not supplied". Reasons are
  supplied by the user, not inferred missing-data mechanisms.

- x, object:

  An object returned by the corresponding function.

- ...:

  Reserved for method compatibility.

## Value

An `mfrm_features` object containing `data`, `id`, `features`, a
`feature_summary`, a `row_summary`, and `missing` (all missing cells and
their reasons). No values are imputed or rows discarded.

## Details

Numeric `NA` and `NaN` are missing. Infinite numeric values and blank
categorical labels are refused; replace missing markers with `NA`
explicitly. Constant and entirely missing features remain available for
review but cannot be used by
[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md).
IDs and unselected columns do not enter distances. These functions are
intended for external attributes such as training, experience, or
specialization. They do not propagate uncertainty from estimated
ability, severity, or fit statistics. See
[`vignette("mfrmr-external-features")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-external-features.md)
for a complete rater-attribute example including missingness review and
multiple imputation.

## See also

[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md),
[`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_imputed.md),
[`mfrm_cluster_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_compare.md),
[`mfrm_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md),
[`mfrm_cluster_kmeans()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_kmeans.md)

## Examples

``` r
# Fictional rater attributes; experience is measured in completed years.
raters <- data.frame(
  Rater = paste0("R", 1:6),
  ExperienceYears = c(1, NA, 3, 12, 13, 14),
  Specialty = c("Language", "Language", "Language", "Science", "Science", "Science")
)
reasons <- data.frame(ID = "R2", Feature = "ExperienceYears", Reason = "Not recorded")
features <- mfrm_features(raters, "Rater", c("ExperienceYears", "Specialty"),
                          missing_reasons = reasons)
summary(features)
#>           Feature    Type Observed Missing Distinct
#> 1 ExperienceYears Numeric        5       1        5
#> 2       Specialty Nominal        6       0        2
features$missing
#>   ID         Feature       Reason
#> 1 R2 ExperienceYears Not recorded
features$row_summary
#>   ID MissingFeatures Complete
#> 1 R1               0     TRUE
#> 2 R2               1    FALSE
#> 3 R3               0     TRUE
#> 4 R4               0     TRUE
#> 5 R5               0     TRUE
#> 6 R6               0     TRUE
```
