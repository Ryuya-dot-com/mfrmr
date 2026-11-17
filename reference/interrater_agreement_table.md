# Compute Krippendorff's alpha across raters

Estimate observed-score agreement across two or more raters, allowing
unequal numbers of ratings per unit. This is Krippendorff's agreement
coefficient, not Cronbach's internal-consistency alpha or MFRM
separation reliability. No measurement-model fitting is performed.

Compare each pair on its common, complete units using a two-way ANOVA
ICC. No MFRM fit, mixed-model estimation or extra package is required.

Compare observed scores on matched units for every pair of raters, using
quadratic (QWK), linear or unweighted agreement. No model is fitted.

Compute observed-score agreement across two or more raters, with a
declared category universe and quadratic, linear or unweighted
agreement.

## Usage

``` r
krippendorff_alpha_table(
  data,
  rater,
  unit,
  score,
  level = c("nominal", "ordinal", "interval", "ratio"),
  categories = NULL
)

pairwise_icc_table(
  data,
  rater,
  unit,
  score,
  model = c("mixed", "random"),
  definition = c("agreement", "consistency"),
  type = c("single", "average")
)

interrater_agreement_table(
  fit,
  diagnostics = NULL,
  rater_facet = NULL,
  context_facets = NULL,
  exact_warn = 0.5,
  corr_warn = 0.3,
  include_precision = TRUE,
  top_n = NULL
)

pairwise_kappa_table(
  data,
  rater,
  unit,
  score,
  categories,
  weights = c("quadratic", "linear", "unweighted")
)

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

- level:

  Measurement level: `"nominal"` (default), `"ordinal"`, `"interval"` or
  `"ratio"`. Choose on substantive grounds; numeric category codes alone
  do not establish an interval or ratio scale.

- categories:

  Required distinct permitted category values, including unused
  categories, in their substantive order. At least two are required.
  They must have the same numeric/character/logical representation as
  scores. With linear/quadratic weights, numeric values use their actual
  spacing; character/logical values use equally spaced positions in this
  vector. Factor levels never silently determine the order. To treat
  numeric codes as equally spaced ranks, explicitly convert scores and
  categories to character. Choose spacing on substantive grounds.

- model:

  `"mixed"` (default) describes the selected raters. `"random"` assumes
  raters were sampled from a population to which results may generalize.
  Two-way point formulas are identical; their interpretation differs.
  Choosing `"random"` does not establish random sampling.

- definition:

  `"agreement"` (default) includes systematic rater offsets;
  `"consistency"` removes their contribution.

- type:

  `"single"` (default) concerns one rating; `"average"` concerns the
  unweighted mean of the two ratings, not a mean over the full panel.

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- rater_facet:

  Name of the rater facet. If `NULL`, inferred from facet names.

- context_facets:

  Optional context facets used to match observations for agreement. If
  `NULL`, all remaining facets (including `Person`) are used.

- exact_warn:

  Warning threshold for exact agreement.

- corr_warn:

  Warning threshold for pairwise correlation.

- include_precision:

  If `TRUE`, append rater severity spread indices from the facet
  precision summary when available.

- top_n:

  Optional maximum number of pair rows to keep, after ordering by flag,
  exact agreement and correlation. The summary still describes all
  candidate pairs. Leave `NULL` to retain the complete pair audit.

- weights:

  One of `"quadratic"` (default), `"linear"` or `"unweighted"`.
  Agreement weights are 1 minus squared normalized distance, 1 minus
  normalized absolute distance, or the identity matrix, respectively.

## Value

A plain list with `table` (alpha, observed/expected disagreement,
availability and sample counts), `counts` (category values, nonmissing
and pairable counts, plus ordinal positions), `cases` (input rows and
exclusion reasons), `unit_summary` (assignment counts and unit
disagreements), `units` (unique input unit keys), `settings` and
`notes`. `Unit` indexes rows of `units`. Save with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html); export data
frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).
Reopening the saved list performs no calculation.

A plain list containing `table` (one row per rater pair), `anova`
(scaled ANOVA ingredients), `cases` (one row per pair and union of
assigned units, with input-row references and inclusion flags), `units`
(the unique input unit keys in input-column order), `settings` and
`notes`. `Unit` in `cases` is a row index into `units`. Units assigned
to neither member of a pair are outside that pair's audit.
`Missing1`/`Missing2` indicate explicit missing-score rows;
`Assigned1`/`Assigned2` also distinguish absent assignments. Save with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and export data
frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).
Reading saved output performs no calculation.

An `mfrm_interrater` bundle (a named list) with:

- `summary`: one-row inter-rater summary

- `pairs`: pair-level agreement table

- `notes`: interpretation and availability qualifications

- `settings`: applied options and thresholds

Use `summary(ir)` or `ir$summary` to inspect a result and `plot(ir)` for
its saved agreement figure. Save the full bundle with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and reopen with
[`base::readRDS()`](https://rdrr.io/r/base/readRDS.html); export
`ir$pairs` and `ir$summary` separately with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).
Reopening performs no fitting.
`plot(ir, type = "agreement", metric = "correlation")` selects the
correlation view; `metric = "difference"` selects observed-score gaps.
These plots retain the saved flag thresholds. Changing them requires
recreating this result from the existing fit, not fitting a new model.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
converts a saved plot payload without recomputation.

A plain list with `table` (one row per pair), `counts` (nonzero retained
contingency cells, with category indices), `categories` (indices, values
and weighting positions), `weights` (agreement matrix), `cases`,
`units`, `settings` and `notes`. `Unit` indexes `units`. Save with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) or export data
frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).

A plain list with `table` (coefficient, observed/expected agreement,
status and counts), `counts` (category totals and unit-mean
proportions), `categories`, `weights`, `cases` (input rows and their two
inclusion flags), `unit_summary`, `units`, `settings` and `notes`.
`Unit` indexes `units`. Results can be saved with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) without
refitting on reload.

## Details

The coefficient is \\1-D_o/D_e\\. Only units with at least two
nonmissing scores contribute to either disagreement. A unit with m
ratings contributes its ordered rating pairs divided by m-1 to the
coincidence counts, hence contributes m pairable ratings overall. Units
are not equally weighted when m differs. The expected disagreement draws
two distinct observations without replacement from the pooled pairable
ratings, with denominator n(n-1), where n is the number of pairable
ratings. This is not Cohen's kappa chance model or MFRM model-implied
expected agreement.

The squared difference function is 0/1 mismatch for nominal scores,
frequency-based rank distance for ordinal scores, squared numeric
difference for interval scores, and \\((c-k)/(c+k))^2\\ for ratio scores
(0 when both values are zero). Ordinal positions use cumulative
pairable-category counts minus half the category count, divided by n.
The squared difference between these positions is proportional to
Krippendorff's ordinal distance. It is not quadratic weighting of
category numbers or equally spaced category ranks. Unused ranks and
singleton-only categories do not alter pairable distances.

Interval distances are calculated after subtracting `score_offset`,
dividing by `score_half_range`, and dividing by 2, using only pairable
values to set the offset and half-range. Constant pairable values map to
zero. This avoids squaring very large or tiny raw scores. The common
normalization leaves alpha unchanged; reported disagreements are on this
normalized scale, not original squared score units. Ordinal positions
are similarly normalized by n. Nominal and ratio disagreements use their
stated distance directly. Computation avoids a dense
category-by-category matrix. Ratio computation still requires quadratic
time in the number of distinct pairable values.

No rows are imputed and repeated rater-unit cells are rejected,
including repetitions with missing scores. All input rows remain in
`cases`. `unit_summary` distinguishes missing scores on assigned rows
from absent assignments relative to the observed rater roster. Units
with no input rows at all are unknown to the function. Missingness and
selective assignment may affect representativeness; numerical handling
does not correct that bias.

Negative estimates are retained. With no pairable ratings or zero
expected disagreement, alpha is unavailable with a reason rather than
set to 0 or 1. A finite coefficient describes this pooled rating sample,
not each rater's accuracy against a reference or a guarantee of
interchangeable ratings. There are no confidence intervals, tests,
quality cutoffs or bootstrap claims. Dependencies among several tasks
from one person require attention in any subsequent sampling inference.
Circular, bipolar and custom metrics are not implemented.

All observed rater identifiers are paired. Each pair uses only units
with two nonmissing scores. Other raters' missing scores do not exclude
a unit for that pair. Missing-score rows and absent assignments are
distinguished in `cases`. Duplicate rater-unit cells (including
missing-score duplicates) are rejected rather than averaged. Identifiers
must be nonmissing and nonblank. There is no imputation or observation
weighting. Pairs with fewer than two complete units remain in `table`
with an unavailable ICC.

Let R, C and E be the unit, rater and residual ANOVA mean squares on a
complete n-by-2 matrix. Following Koo and Li (2016, Table 3), the
numerator is R-E. The single-rating denominator is R+E for consistency,
or R+E+2(C-E)/n for absolute agreement. The average-rating denominator
is R for consistency, or R+(C-E)/n for agreement. `Form` records
ICC(C,1), ICC(A,1), ICC(C,2) or ICC(A,2); interpret these together with
`Model`. ICC(A,2) denotes an average of two ratings, not Shrout–Fleiss
ICC(2,1). One-way ICCs are not computed.

Negative estimates are retained. A nonpositive denominator makes `ICC`
unavailable and sets `Status = "nonpositive_denominator"`; `RawICC`
retains the algebraic ratio when finite so it cannot masquerade as a
valid reliability estimate. An entirely constant matrix is undefined,
not 1. Internally scores are shifted and scaled to avoid
overflow/underflow. `anova` records scaled mean squares, the
offset/scale, numerator and denominator, so the calculation can be
reconstructed. These scaled mean squares are not variances in the
original score units.

Results describe each pair's retained unit mix. Different pairs can have
different units and score ranges; their ICCs cannot automatically rank
rater quality and should not be averaged into a panel ICC. Restricted
unit variability can lower ICC without larger absolute disagreement.
Inference requires a suitable sampling design and assumptions about
errors and dependence. Treating several tasks from one person as
separate units does not make them independent. No confidence intervals,
hypothesis tests, quality bands or rater-training decisions are
supplied. This is distinct from the component variance shares in
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
MFRM separation reliability and the fitted expected agreement in
`interrater_agreement_table()`.

Computes pairwise rater agreement on matched contexts (`pairs` and
one-row `summary`). Model-implied expected exact agreement is \\\sum_k
P\_{r1}(X=k)P\_{r2}(X=k)\\ evaluated conditionally at saved Person point
estimates (including MML EAPs) and structural parameters, without
posterior integration or calibration-uncertainty propagation. Nonfinite
primary estimates, repeated rater-context cells (whose observed scores
are weight-averaged), or unavailable GPCM slopes set
`ExpectedExact = NA` with explicit `ExpectedReason`
(`primary_estimate_unavailable`, `repeated_ratings`,
`fitted_probabilities_unavailable`, or `no_matched_scores`).

Each matched context with two finite scores contributes one opportunity
per rater pair (\\m\\ judges on one context contribute \\m(m-1)/2\\
opportunities). `Exact`, `Adjacent` (\\\|d\| \le 1\\), `MeanDiff`
(`Rater1 - Rater2`), `MAD`, and `Corr` summarize matched pairs;
`MeanCorr` weights pairwise correlations by `N`. `Flag` marks configured
`exact_warn` / `corr_warn` thresholds (`FlaggedShare = NA` when
classification is incomplete). For two-way ICCs, kappa, AC2, or
Krippendorff's alpha without an MFRM fit, see `pairwise_icc_table()` and
[mfrmr_methods_reference](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md).

For each pair, both observed and expected agreement use only common
complete units. Expected cell proportions are products of the two
rater-specific margins on this same sample. Kappa is
`(observed - expected)/(1 - expected)`. This complete-case convention
differs from the all-available rater margins in Gwet's incomplete-data
Example 4.1. Different pairs may retain different cohorts; comparing or
averaging their kappas does not establish a panel coefficient. At least
two complete units are required, as in the existing QWK score-comparison
interface.

Computation uses the equivalent disagreement ratio, with distances
rescaled to the categories actually present in each retained pair. The
common scale cancels, avoiding loss of the coefficient when an unused
numeric category is very distant. `ScaledObservedDisagreement` and
`ScaledExpectedDisagreement` retain those ingredients; agreement columns
use the declared full-scale weights. Agreement columns can round to 1 at
extreme relative spacings even when kappa is defined. Negative estimates
remain visible; zero expected disagreement returns `NA` with a status.

Duplicate rater-unit cells are rejected before dropping missing scores.
The case audit distinguishes an absent assignment from an explicit
missing score and retains the union of units assigned to either member
of the pair. No imputation, confidence intervals, tests or quality
cutoffs are supplied. Missingness may affect representativeness.
Agreement does not establish reference accuracy or MFRM rater-severity
homogeneity. Storage of the weight matrix requires space quadratic in
the number of declared categories; these are categorical-score
interfaces, not continuous-score ICCs.

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

Krippendorff, K. (2011; literature updated 2013). *Computing
Krippendorff's Alpha-Reliability*. Sections A-E, pp. 1-10.
<https://www.asc.upenn.edu/krippendorffs-alpha-reliability>

Koo, T. K., & Li, M. Y. (2016). A guideline of selecting and reporting
intraclass correlation coefficients for reliability research. *Journal
of Chiropractic Medicine, 15*(2), 155-163.
[doi:10.1016/j.jcm.2016.02.012](https://doi.org/10.1016/j.jcm.2016.02.012)
. Table 3; see also the 2017 erratum,
[doi:10.1016/j.jcm.2017.10.001](https://doi.org/10.1016/j.jcm.2017.10.001)
, correcting the one-way ICC(1,1) formula.

Cohen, J. (1968). Weighted kappa: nominal scale agreement with provision
for scaled disagreement or partial credit. *Psychological Bulletin*, 70,
213-220. [doi:10.1037/h0026256](https://doi.org/10.1037/h0026256) .

Gwet, K. L. *Handbook of Inter-Rater Reliability*, fifth edition, volume
1, chapter 4, pp. 100-110, equations 4.2.4-4.2.6.
<https://www.agreestat.com/assets/cac5-chapter4-excerpt.pdf>

Gwet, K. L. Author implementation of AC1/AC2, `gwet.ac1.raw`, and
linear/quadratic weights, in *irrCAC*.
<https://github.com/kgwet/irrCAC/blob/master/R/agree.coeff3.raw.r>
<https://github.com/kgwet/irrCAC/blob/master/R/weights.gen.r>

## See also

`pairwise_icc_table()`, `interrater_agreement_table()`,
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)

`interrater_agreement_table()`,
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
`krippendorff_alpha_table()`,
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md),
[plot(x, type =
"agreement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
`pairwise_icc_table()`, `pairwise_kappa_table()`, `gwet_ac2_table()`,
`krippendorff_alpha_table()`,
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

`gwet_ac2_table()`, `krippendorff_alpha_table()`,
`pairwise_icc_table()`,
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)

`pairwise_kappa_table()`, `krippendorff_alpha_table()`,
`pairwise_icc_table()`

## Examples

``` r
data("mfrmr_example_agreement", package = "mfrmr")
ratings <- mfrmr_example_agreement
agreement <- krippendorff_alpha_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", level = "ordinal", categories = 0:3)
agreement$table
#>       Alpha   Level    Status ObservedDisagreement ExpectedDisagreement Raters
#> 1 0.5666233 ordinal available           0.06785569            0.1565744      3
#>   Units PairableUnits PairableRatings NonmissingRatings MissingScores
#> 1    12            12              34                34             1
#>   SingletonUnits UnratedUnits
#> 1              0            0
agreement$unit_summary # Each response needs at least two observed ratings.
#>    Unit AssignedRows NonmissingRatings MissingScores AbsentAssignments Included
#> 1     1            3                 3             0                 0     TRUE
#> 2     2            3                 3             0                 0     TRUE
#> 3     3            3                 3             0                 0     TRUE
#> 4     4            2                 2             0                 1     TRUE
#> 5     5            3                 3             0                 0     TRUE
#> 6     6            3                 3             0                 0     TRUE
#> 7     7            3                 3             0                 0     TRUE
#> 8     8            3                 3             0                 0     TRUE
#> 9     9            3                 3             0                 0     TRUE
#> 10   10            3                 3             0                 0     TRUE
#> 11   11            3                 3             0                 0     TRUE
#> 12   12            3                 2             1                 0     TRUE
#>    ObservedDisagreement
#> 1            0.05204729
#> 2            0.07626874
#> 3            0.15844867
#> 4            0.07807093
#> 5            0.07626874
#> 6            0.03243945
#> 7            0.05204729
#> 8            0.07626874
#> 9            0.03243945
#> 10           0.05204729
#> 11           0.07626874
#> 12           0.04865917
agreement$notes
#> [1] "Krippendorff's alpha measures pooled observed-score agreement, not Cronbach's alpha, MFRM separation reliability or criterion-referenced rater accuracy."
#> [2] "Only pairable ratings contribute to observed and expected disagreement; unequal rating counts weight units differently."                                 
#> [3] "Missingness and selective assignment may affect representativeness; no imputation or automatic correction is made."                                      
#> [4] "No confidence intervals, tests or quality cutoffs are supplied; negative estimates are retained."                                                        
#> [5] "Ordinal distances use pairable-category frequencies, not equally spaced ranks or QWK weights."                                                           
# Ordinal alpha uses category ordering; it is not quadratic weighted kappa.
# Optional workflow; run the example explicitly as shown below.
# example("pairwise_icc_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
data("mfrmr_example_agreement", package = "mfrmr")
ratings <- mfrmr_example_agreement
absolute <- pairwise_icc_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", definition = "agreement")
consistent <- pairwise_icc_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", definition = "consistency")
absolute$table
consistent$table
# R1/R2 have perfect consistency, but R2's one-category offset reduces agreement.
# These ICCs treat 0--3 as numeric scores; justify equal score intervals.
} # }
# Optional workflow; run the example explicitly as shown below.
# example("interrater_agreement_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Compare ratings of the same person on the same criterion
agreement <- interrater_agreement_table(fit, rater_facet = "Rater")
agreement$summary
agreement$pairs[, c("Rater1", "Rater2", "N", "Exact", "Corr", "MeanDiff")]
# N is the number of matched ratings; Exact is the fraction with identical scores
# MeanDiff = Rater1 minus Rater2: positive means Rater1 assigned higher scores
# These observed-score comparisons are distinct from fitted rater severity
} # }
# Optional workflow; run the example explicitly as shown below.
# example("pairwise_kappa_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
data("mfrmr_example_agreement", package = "mfrmr")
ratings <- mfrmr_example_agreement
head(ratings) # One rater's score for one Person-Task response.
pairs <- pairwise_kappa_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", categories = 0:3)
pairs$table
pairs$cases # Included marks the shared nonmissing ratings for each pair.
# R2 gives every response one category more than R1: equal rankings do not
# imply agreement. Do not treat two Tasks by the same Person as one response.
} # }
# Optional workflow; run the example explicitly as shown below.
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
