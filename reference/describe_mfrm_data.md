# Check rating data before fitting an MFRM

Audit row retention, missingness, score category support, duplicate
Person-by-facet cells, Person-facet graph connectivity, optional
observed agreement, and optional prospective interaction contrast
identifiability before calling
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## Usage

``` r
describe_mfrm_data(
  data,
  person = NULL,
  facets = NULL,
  score = NULL,
  weight = NULL,
  rating_min = NULL,
  rating_max = NULL,
  keep_original = FALSE,
  missing_codes = NULL,
  include_person_facet = FALSE,
  include_agreement = TRUE,
  rater_facet = NULL,
  context_facets = NULL,
  agreement_top_n = NULL,
  expected_design = NULL,
  min_linking_persons = 2L,
  category_policy = NULL,
  repeated_ratings = c("review", "independent"),
  comparisons = NULL,
  spec = NULL
)

# S3 method for class 'mfrm_data_description'
summary(object, digits = 3, top_n = 10, ...)

# S3 method for class 'mfrm_data_description'
plot(
  x,
  y = NULL,
  type = c("score_distribution", "facet_levels", "missing"),
  main = NULL,
  palette = NULL,
  label_angle = 45,
  draw = TRUE,
  ...
)
```

## Arguments

- data:

  Long-format rating `data.frame` (one row per rating event).

- person:

  Data column names, rubric bounds, category handling (`"collapse"` vs
  `"preserve"`), duplicate-cell policy (`"review"` vs `"independent"`),
  and sentinel recoding; shared with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  via `spec` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- facets:

  Data column names, rubric bounds, category handling (`"collapse"` vs
  `"preserve"`), duplicate-cell policy (`"review"` vs `"independent"`),
  and sentinel recoding; shared with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  via `spec` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- score:

  Data column names, rubric bounds, category handling (`"collapse"` vs
  `"preserve"`), duplicate-cell policy (`"review"` vs `"independent"`),
  and sentinel recoding; shared with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  via `spec` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- weight:

  Data column names, rubric bounds, category handling (`"collapse"` vs
  `"preserve"`), duplicate-cell policy (`"review"` vs `"independent"`),
  and sentinel recoding; shared with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  via `spec` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- rating_min:

  Data column names, rubric bounds, category handling (`"collapse"` vs
  `"preserve"`), duplicate-cell policy (`"review"` vs `"independent"`),
  and sentinel recoding; shared with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  via `spec` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- rating_max:

  Data column names, rubric bounds, category handling (`"collapse"` vs
  `"preserve"`), duplicate-cell policy (`"review"` vs `"independent"`),
  and sentinel recoding; shared with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  via `spec` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- keep_original:

  Data column names, rubric bounds, category handling (`"collapse"` vs
  `"preserve"`), duplicate-cell policy (`"review"` vs `"independent"`),
  and sentinel recoding; shared with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  via `spec` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- missing_codes:

  Data column names, rubric bounds, category handling (`"collapse"` vs
  `"preserve"`), duplicate-cell policy (`"review"` vs `"independent"`),
  and sentinel recoding; shared with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  via `spec` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- include_person_facet:

  Controls for including Person rows in `facet_level_summary` and
  computing observed scorer agreement across matched `context_facets`.

- include_agreement:

  Controls for including Person rows in `facet_level_summary` and
  computing observed scorer agreement across matched `context_facets`.

- rater_facet:

  Controls for including Person rows in `facet_level_summary` and
  computing observed scorer agreement across matched `context_facets`.

- context_facets:

  Controls for including Person rows in `facet_level_summary` and
  computing observed scorer agreement across matched `context_facets`.

- agreement_top_n:

  Controls for including Person rows in `facet_level_summary` and
  computing observed scorer agreement across matched `context_facets`.

- expected_design:

  Optional planned assignment roster `data.frame` (for
  `structural_missingness`) and sparse-link Person count flag
  (`linkage_summary$SparseLevels`).

- min_linking_persons:

  Optional planned assignment roster `data.frame` (for
  `structural_missingness`) and sparse-link Person count flag
  (`linkage_summary$SparseLevels`).

- category_policy:

  Data column names, rubric bounds, category handling (`"collapse"` vs
  `"preserve"`), duplicate-cell policy (`"review"` vs `"independent"`),
  and sentinel recoding; shared with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  via `spec` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- repeated_ratings:

  Data column names, rubric bounds, category handling (`"collapse"` vs
  `"preserve"`), duplicate-cell policy (`"review"` vs `"independent"`),
  and sentinel recoding; shared with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  via `spec` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- comparisons:

  Optional
  `list(facet = ..., group = ..., groups = c("A", "B"), contrasts = W, model = ..., method = ...)`
  reviewing prospective facet-by-origin interaction contrasts
  (`IdentificationBasis`: `free_person_response_model`,
  `population_restriction`, `conditional_support`, `unidentified`,
  `not_evaluated`, `unsupported`) for
  `fit_mfrm(fit_scope = "comparisons", comparison_review = ...)`.

- spec:

  Optional shared model-specification `list` accepted by
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
  and
  [`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md).

- object:

  Output from `describe_mfrm_data()`.

- digits:

  Number of digits for numeric rounding.

- top_n:

  Maximum rows shown in preview blocks.

- ...:

  Reserved for generic compatibility.

- x:

  Output from `describe_mfrm_data()`.

- y:

  Reserved for generic compatibility.

- type:

  Plot type: `"score_distribution"`, `"facet_levels"`, or `"missing"`.

- main:

  Optional title override.

- palette:

  Optional named colors (`score`, `facet`, `missing`).

- label_angle:

  X-axis label angle for bar plots.

- draw:

  If `TRUE`, display the returned ggplot.

## Value

An `mfrm_data_description` list
([`summary()`](https://rdrr.io/r/base/summary.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)) with
`overview` (`CategoryPolicy`, `ScoreRecoded`), `missing_by_column`,
`missing_rate_summary`, `score_descriptives`, `weight_descriptives`,
`score_distribution`, `facet_level_summary`, `facet_crosstabs`,
`linkage_summary`, `structural_missingness`, `design_connectivity`,
`design_components`, `duplicate_cell_summary`, `duplicate_cell_detail`,
`agreement`, `row_retention`, `preparation_notes`, `missing_recoding`,
`score_support`, and optional `comparison_review`.

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_data_description`.

- `overview`: design/sample counts

- `missing`: top columns by missingness

- `score_distribution`: compact score-usage table, including zero-count
  categories retained by the prepared score support

- `facet_overview`: facet-level coverage summary

- `structural_missingness`: declared assignment coverage summary; status
  is `"not_declared"` when no assignment roster was supplied

- `structural_level_coverage`: expected versus observed level counts

- `design_connectivity`: Person-facet component counts for observed and
  declared-expected designs

- `design_components`: component sizes and facet-level labels; person
  labels are suppressed unless explicitly requested in
  `describe_mfrm_data()`

- `linkage_summary`: sparse-support and shared-person counts by facet

- `duplicate_cell_summary`: aggregate duplicate-cell counts

- `agreement`: selected-facet agreement summary when available

- `agreement_settings`: selected scorer facet, matching context, and
  status

- `row_retention`: row counts before and after preparation filters

- `preparation_notes`: structured preparation notes retained from
  `describe_mfrm_data()`

- `reporting_map`: manuscript-oriented guide to what is covered here
  versus which companion outputs should be consulted

- `caveats`: structured warning/review rows for score-support issues;
  `print(summary(ds))` shows a compact `Caveats` block when rows are
  present

- `notes`: plain-language explanations of missingness, preparation,
  score support, and design-review findings

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): A `ggplot`
object (invisibly), with underlying plot tables accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

## Details

[`summary()`](https://rdrr.io/r/base/summary.html) provides compact
previews; the reading order and field differences are described under
"Reading the data review".

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot a
data-description object

## Reading data-review plots

- `"score_distribution"` plots `WeightedN`, the sum of weights per
  category. Sparse categories limit threshold information, but
  uniformity/unimodality is not required. Read floor/ceiling
  concentrations against rubric, assignments and target population; this
  is not a sample-adequacy test.

- `"facet_levels"` shows distinct levels per facet. Check expected
  levels, ratings per level and crossings: more levels increase
  parameter dimension, while more optimizer iterations cannot repair
  missing identification.

- `"missing"` plots input missing counts. Investigate them using the
  tables above; missing scores/Persons/facet IDs cause row exclusions in
  fitting.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md),
[`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md),
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)

`describe_mfrm_data()`,
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md)

`describe_mfrm_data()`,
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)

## Examples

``` r
library(mfrmr)
ratings <- load_mfrmr_data("example_operational")
head(ratings)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A

# Check the data before fitting; the intended score categories are 1 to 4
data_review <- describe_mfrm_data(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1,
  rating_max = 4,
  category_policy = "preserve"
)
data_review$row_retention       # Input and retained rows; check DroppedRows
#>                             Stage Rows DroppedRows
#> 1          input_selected_columns  282           0
#> 2 after_missing_and_weight_filter  282           0
#>                            DroppedReason
#> 1                                       
#> 2 missing values or non-positive weights
data_review$missing_by_column   # Missing input values in each model column
#> # A tibble: 4 × 2
#>   Column    Missing
#>   <chr>       <int>
#> 1 Person          0
#> 2 Rater           0
#> 3 Criterion       0
#> 4 Score           0
data_review$score_distribution  # RawN is the number of ratings per category
#> # A tibble: 4 × 4
#>   Score  RawN WeightedN Percent
#>   <int> <int>     <dbl>   <dbl>
#> 1     1    62        62    22.0
#> 2     2    96        96    34.0
#> 3     3    78        78    27.7
#> 4     4    46        46    16.3
data_review$design_connectivity # Components = 1 means connected for that facet
#>      Basis     Facet PersonNodes FacetLevelNodes Edges Components
#> 1 observed     Rater          48               6    96          1
#> 2 observed Criterion          48               3   144          1
#>   LargestComponentPersons LargestComponentLevels LargestComponentPercent
#> 1                      48                      6                     100
#> 2                      48                      3                     100
#>   Connected
#> 1      TRUE
#> 2      TRUE
# Here all 282 rows are retained, and all four categories have observations

# Save a compact summary when you want the overview and review notes
review <- summary(data_review)
review$overview
#>   Observations TotalWeight Persons Facets Categories RatingMin RatingMax
#> 1          282         282      48      2          4         1         4
#>   RatingRangeSource RatingMinSource RatingMaxSource CategoryPolicy ScoreRecoded
#> 1          declared        declared        declared       preserve        FALSE
review$notes
#> [1] "No missing values were detected in selected input columns."                                                                                                  
#> [2] "Structural missingness was not assessed because `expected_design` was not supplied. Absent rows cannot be distinguished from cells that were never assigned."
# For the next fit, use data = ratings; data_review is a set of checks, not ratings
# Optional workflow; run the example explicitly as shown below.
# example("summary.mfrm_data_description", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)
ratings <- load_mfrmr_data("example_operational")

# Demonstrate two missing scores in a copy of the example data
ratings$Score[1:2] <- NA
data_review <- describe_mfrm_data(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1,
  rating_max = 4,
  category_policy = "preserve"
)
review <- summary(data_review)
review$row_retention # 282 input rows, 280 retained rows
review$missing       # Score has 2 missing input values
review$overview      # Counts describe the retained ratings
review$notes         # Explanations to read before fitting

# The original description retains the full missingness table
data_review$missing_by_column
# Investigate missingness before using ratings in fit_mfrm()
} # }
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_data_description", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
ds <- describe_mfrm_data(toy, "Person", c("Rater", "Criterion"), "Score")
p <- plot(ds, draw = FALSE)
} # }
```
