# Review multiple imputations of scores on assigned ratings

Check several completed versions of a rating table before analyzing
them. Supply these completed data from an imputation model; this
function checks that observed scores, rating assignments and identifiers
are preserved. No person-by-facet grid is constructed. This function
validates supplied imputations; it does not choose or fit an imputation
model.

## Usage

``` r
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

- impute:

  Character vector of event IDs explicitly selecting missing scores on
  assigned ratings. Observed scores cannot be selected.

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

  How to handle assigned missing scores not selected by `impute`:
  `"error"` (default) or explicit `"omit"`. Omitted events remain in the
  roster and every completion, with missing scores, and are excluded
  from each analysis. This choice is not a correction for nonresponse.

- x, object:

  An object returned by `mfrm_response_imputations()`.

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
