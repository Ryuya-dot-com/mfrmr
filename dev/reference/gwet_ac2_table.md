# Compute Gwet's AC2 or unweighted AC1

Compute observed-score agreement across two or more raters, with a
declared category universe and quadratic, linear or unweighted
agreement.

## Usage

``` r
gwet_ac2_table(
  data,
  rater,
  unit,
  score,
  categories,
  weights = c("quadratic", "linear", "unweighted")
)
```

## Arguments

- data:

  Long-format ratings with at most one row per rater and unit.

- rater:

  Name of the rater identifier column.

- unit:

  Names of columns jointly identifying a rated unit, such as
  `c("Person", "Task")`.

- score:

  Name of the score column. Values may be numeric, character, factor or
  logical, with `NA` for missing scores. Factors use their labels.

- categories:

  Required distinct permitted category values, including unused
  categories, in their substantive order. At least two are required.
  They must have the same numeric/character/logical representation as
  scores. With linear/quadratic weights, numeric values use their actual
  spacing; character/logical values use equally spaced positions in this
  vector. Factor levels never silently determine the order. To treat
  numeric codes as equally spaced ranks, explicitly convert scores and
  categories to character. Choose spacing on substantive grounds.

- weights:

  One of `"quadratic"` (default), `"linear"` or `"unweighted"`.
  Agreement weights are 1 minus squared normalized distance, 1 minus
  normalized absolute distance, or the identity matrix, respectively.

## Value

A plain list with `table` (coefficient, observed/expected agreement,
status and counts), `counts` (category totals and unit-mean
proportions), `categories`, `weights`, `cases` (input rows and their two
inclusion flags), `unit_summary`, `units`, `settings` and `notes`.
`Unit` indexes `units`. Results can be saved with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) without
refitting on reload.

## Details

Observed agreement is the equally weighted mean of within-unit weighted
agreement over distinct ordered rating pairs, using only units with at
least two nonmissing ratings. Category proportions are the equally
weighted mean of within-unit category proportions over all units with at
least one rating. Thus singletons contribute to expected agreement but
not observed agreement; units with no ratings contribute to neither.
This is Gwet's raw-rating convention, not Krippendorff's pairable-rating
margins or Cohen's separate rater margins. Unequal rating counts do not
give units greater weight.

With q declared categories, agreement matrix W and mean category
proportions pi, expected agreement is
`sum(W) * sum(pi * (1 - pi)) / (q * (q - 1))`. AC is
`(observed - expected)/(1 - expected)`. Quadratic/linear weights give
AC2; identity weights give AC1. At two categories the supplied linear
and quadratic weights equal identity weights, so the numerical results
coincide. The complete category universe is required: adding unused
categories can change expected agreement and AC. It must not be selected
to improve a result.

Negative estimates are retained. No pairable units or a nonpositive
chance denominator gives `NA` with a status. With all raters always
using the same category, AC can be 1 when the declared universe has at
least two categories; this does not establish discrimination, validity
or reference accuracy. Unlike kappa, its chance model does not become
undefined in that case.

Repeated rater-unit cells are rejected, even when scores are missing.
Audits distinguish explicit missing scores from absent assignments
relative to the observed rater roster. Units with no input rows are
unknown. Missingness and assignment may still bias interpretation.
Results are descriptive point estimates: no confidence intervals, tests,
quality bands or invariance to prevalence are claimed. Different chance
models answer different questions; AC2 is not an automatic replacement
or correction for kappa. Dense weight storage is quadratic in the
declared category count. Custom weights and circular, bipolar, radical
and ratio weights are not implemented.

## References

Gwet, K. L. Author implementation of AC1/AC2, `gwet.ac1.raw`, and
linear/quadratic weights, in *irrCAC*.
<https://github.com/kgwet/irrCAC/blob/master/R/agree.coeff3.raw.r>
<https://github.com/kgwet/irrCAC/blob/master/R/weights.gen.r>

## See also

[`pairwise_kappa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/pairwise_kappa_table.md),
[`krippendorff_alpha_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/krippendorff_alpha_table.md),
[`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/pairwise_icc_table.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("gwet_ac2_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
data("mfrmr_example_agreement", package = "mfrmr")
ratings <- mfrmr_example_agreement
ac <- gwet_ac2_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", categories = 0:3)
ac$table
ac$unit_summary # Number of observed ratings and pairability for each response.
ac$notes # Read the panel coefficient together with its assumptions.
} # }
```
