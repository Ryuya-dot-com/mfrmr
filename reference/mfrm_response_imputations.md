# Review multiple imputations of scores on assigned ratings

Check several completed versions of a rating table before analyzing
them. Supply these completed data from an imputation model; this
function checks that observed scores, rating assignments and identifiers
are preserved. No person-by-facet grid is constructed. This function
validates supplied imputations; it does not choose or fit an imputation
model. Start with `review_mfrm_imputations()`, then use
[`fit_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_imputed.md)
and
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md)
for eligible fixed-facet analyses. The older name
`mfrm_response_imputations()` is retained with its original `impute`
argument.

## Usage

``` r
review_mfrm_imputations(
  data,
  completed,
  person,
  facets,
  score,
  event_id,
  impute_ids,
  categories,
  assigned = NULL,
  imputation_model = NULL,
  missing = c("error", "omit")
)

mfrm_response_imputations(
  data,
  completed,
  person,
  facets,
  score,
  event_id,
  impute,
  categories,
  assigned = NULL,
  imputation_model = NULL,
  missing = c("error", "omit")
)

# S3 method for class 'mfrm_response_imputations'
print(x, ...)

# S3 method for class 'mfrm_response_imputations'
summary(object, ...)
```

## Arguments

- data:

  Original long-format rating roster, including missing scores.

- completed:

  A list of at least two completed data frames, or a `mids` object from
  [`mice::mice()`](https://amices.org/mice/reference/mice.html) fitted
  to the long-format roster. Each completion must contain all original
  columns and rows. Row order may differ; rows are matched by
  `event_id`.

- person, score, event_id:

  Column names. `event_id` uniquely identifies a rating event, including
  repeated ratings of the same person and facets.

- facets:

  Nonempty character vector of facet column names.

- impute_ids:

  Character vector of event IDs explicitly selecting missing scores on
  assigned ratings. Observed scores cannot be selected. These are values
  from the `event_id` column, not a column name or a logical switch. For
  example, `c("E2", "E7")` selects those two rating events.

- categories:

  The full intended contiguous integer category vector, for example
  `0:4`. It is preserved across all completed analyses.

- assigned:

  Optional name of a complete logical column: `TRUE` denotes an assigned
  rating and `FALSE` an unassigned combination. Without this column
  every supplied row is declared assigned. Unassigned rows must have
  missing scores in the original and every completion.

- imputation_model:

  For a list of completions, the saved model or a nonempty list
  containing its specification, settings and diagnostics. Required so
  that the provenance is retained. For a `mids` input, that object is
  retained automatically; omit this argument.

- missing:

  How to handle assigned missing scores not selected by `impute_ids`:
  `"error"` (default) or explicit `"omit"`. Omitted events remain in the
  roster and every completion, with missing scores, and are excluded
  from each analysis. This choice is not a correction for nonresponse.

- impute:

  Compatibility name for `impute_ids`, used only by
  `mfrm_response_imputations()`. Supply one selection, not both argument
  names.

- x, object:

  An object returned by `review_mfrm_imputations()` or its compatibility
  wrapper `mfrm_response_imputations()`.

- ...:

  Unused for print and summary methods.

## Value

An `mfrm_response_imputations` object containing the original `data`,
aligned `completed` data sets, `imputation_model`, an `events` table
with assignment/observation/imputation/omission status, a `support`
table counting original observed and imputed scores by person/facet
level, and `settings`. No imputations or failed analyses are silently
discarded.

## Details

The score must contain numeric integer category labels (numeric vectors,
or character/factor labels such as `"0"`, `"1"`). Recoded sentinel
missing values must already be `NA`. Identifiers, assignment indicators
and observed values must not change. Only selected scores may be filled;
missing auxiliary predictors may also be completed. For a `mids` input,
its original data and score `where` selection must agree with this
review.

A sparse assignment and a missing assigned score are different events.
Neither absent roster rows nor explicit unassigned rows are imputed. An
entirely imputed person or facet level is visible in `support`; its
analysis depends on the imputation model, not on observed ratings for
that level. Imputed links do not establish empirical connectedness.

Proper multiple imputation must include uncertainty about missing values
and imputation parameters, reflect the ordinal score support and the
person/facet dependence, and be compatible with the intended analysis.
Include relevant observed predictors of nonresponse. An MAR analysis
requires an adequate conditional model; informative missingness beyond
observed predictors requires sensitivity analysis. Passing these
software checks does not establish MAR, model adequacy or interval
coverage.

For a wide-format or multilevel imputation model, reshape each
completion back to the original long roster using event identities and
supply the resulting list with the saved model. Do not average completed
scores. See
[`vignette("mfrmr-response-imputation", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-response-imputation.md)
for a joint RSM example with supplied posterior predictive completions,
shared Person draws, sampling diagnostics, direct observed-score
inference and a separate lower-score sensitivity analysis. The
accompanying R/Stan script regenerates that example; it is not a general
imputation engine. Under the same score model and ignorable missingness,
observed-score MML can directly estimate the fixed-facet target without
completing scores. MI does not create additional observed information.

## See also

[`fit_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_imputed.md),
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md),
[`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_imputed.md)

## Examples

``` r
# Small supplied completions to illustrate input checks, not a fitted imputer.
ratings <- data.frame(Event = paste0("E", 1:4), Person = c("P1", "P1", "P2", "P2"),
  Rater = c("A", "B", "A", "B"), Score = c(0, NA, 1, 2))
first <- second <- ratings
first$Score[2] <- 1
second$Score[2] <- 2
reviewed <- review_mfrm_imputations(ratings, list(first, second),
  person = "Person", facets = "Rater", score = "Score", event_id = "Event",
  impute_ids = "E2", categories = 0:2,
  imputation_model = list(method = "Illustrative supplied completions"))
reviewed$events  # Only E2 is imputed; the three observed scores are retained.
#>   ID Assigned Observed Imputed Omitted
#> 1 E1     TRUE     TRUE   FALSE   FALSE
#> 2 E2     TRUE    FALSE    TRUE   FALSE
#> 3 E3     TRUE     TRUE   FALSE   FALSE
#> 4 E4     TRUE     TRUE   FALSE   FALSE
summary(reviewed)  # Original observed support and imputation counts per level.
#>    Facet Level Assigned Observed Imputed Omitted
#> 1 Person    P1        2        1       1       0
#> 2 Person    P2        2        2       0       0
#> 3  Rater     A        2        2       0       0
#> 4  Rater     B        2        1       1       0
```
