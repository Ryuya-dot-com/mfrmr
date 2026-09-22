# Compute intra-class correlations for each facet

Fits a random-effects variance-components model
`Score ~ 1 + (1 | Person) + (1 | Facet1) + (1 | Facet2) + ...` using
[`lme4::lmer`](https://rdrr.io/pkg/lme4/man/lmer.html) (in `Suggests`)
and returns the proportion of observed score variance attributable to
each facet. This is a descriptive summary complementary to the
Rasch-metric rater separation/reliability reported elsewhere.

## Usage

``` r
compute_facet_icc(
  data,
  facets,
  score,
  person = NULL,
  reml = TRUE,
  ci_method = c("none", "boot"),
  ci_level = 0.95,
  ci_boot_reps = 1000L,
  ci_boot_seed = NULL,
  ci_boot_parallel = c("no", "multicore", "snow"),
  ci_boot_ncpus = 1L,
  missing = c("error", "omit")
)
```

## Arguments

- data:

  Data frame in long format.

- facets:

  Character vector of facet column names.

- score:

  Name of the score column.

- person:

  Optional person column. If supplied it is added as a separate random
  intercept so Person-level variance is partitioned out.

- reml:

  Logical; whether to fit with REML. Default `TRUE`.

- ci_method:

  Confidence-interval method for the ICC column. One of `"none"`
  (default, point estimate only) or `"boot"` (parametric percentile
  bootstrap via
  [`lme4::bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html)). Each
  simulated data set is refitted and its full variance decomposition
  used to calculate the ICC ratios. The former `"profile"` method is no
  longer supported; see Updating saved intervals below.

- ci_level:

  Confidence level when `ci_method != "none"`; default `0.95`. Koo &
  Li (2016) recommend banding the CI rather than the point estimate when
  classifying reliability as Poor / Moderate / Good / Excellent.

- ci_boot_reps:

  Number of bootstrap replicates used when `ci_method = "boot"`. An
  integer of at least 2; default `1000`. Small counts give imprecise
  tail quantiles; choose enough replicates for the precision required in
  the application.

- ci_boot_seed:

  Optional integer seed for the bootstrap path (between 0 and
  `.Machine$integer.max`). `NULL` uses the current random-number state.
  Bootstrap simulation advances that state.

- ci_boot_parallel:

  Parallelisation strategy for the parametric-bootstrap CI path, passed
  through to
  [`lme4::bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html): `"no"`
  (default), `"multicore"` (POSIX `mclapply`), or `"snow"` (PSOCK
  cluster). `"multicore"` does nothing on Windows and falls back to
  serial; use `"snow"` there.

- ci_boot_ncpus:

  Number of CPUs to use for the parallel bootstrap path (ignored when
  `ci_boot_parallel = "no"`). A positive integer. Interactive progress
  is available for serial execution.

- missing:

  How to handle missing scores or selected grouping values: `"error"`
  (default) or explicit complete-case omission with `"omit"`. Numeric
  character/factor score labels retain their numeric values. Nonnumeric
  scores, infinite values, and blank grouping labels are refused.

## Value

A data.frame of class `mfrm_facet_icc` with one row per variance
component (including a `"Residual"` row) and columns:

- `Facet`: the grouping factor name (or `"Residual"`).

- `Variance`: unrounded variance estimate (REML by default, ML if
  `reml = FALSE`); `NA` when the variance shares are undefined.

- `ICC`: variance share (`Variance / sum(Variance)`), in `[0, 1]`.

- `Interpretation`: band label according to the facet's scale.

- `InterpretationScale`: `"Koo-Li reliability"` for the person facet,
  `"Variance share"` for others.

- `ICC_CI_Lower` / `ICC_CI_Upper` / `ICC_CI_Level` / `ICC_CI_Method`: CI
  bounds (unavailable bounds are `NA`), requested level, and method.

- `ICC_CI_Status`: whether intervals are available and, otherwise, why.

- `ICC_CI_NRequested` / `ICC_CI_NReps` / `ICC_CI_NUnavailable`:
  requested bootstrap count, number of converged refits with all ICCs
  finite, and number without such a result (absent for `"none"`). Counts
  are `NA` when the bootstrap aborts without returning its draws.
  Warnings can withhold intervals even when all draws are finite and all
  refits converge.

The `icc_ci` attribute retains the original fit's convergence and
singularity diagnostics and warnings. When bootstrap results are
returned, its `bootstrap` entry contains every draw, per-refit
convergence and singularity indicators, the number of refit errors, and
lme4's message/warning/error tables.

## Rows used

Missingness is checked only in the score, facets, and optional person
column. `InputRows`, `UsedRows`, and `ExcludedRows` are included in the
table. `attr(x, "data_usage")` retains these counts, excluded input row
positions, missing columns per row, and observed grouping-level counts
after omission.
[`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md)
uses these retained counts for its sample sizes. Omission does not
impute scores or correct missing-data bias.

## Score units and zero variation

A small positive variance is not treated as zero using a fixed cutoff.
Multiplying scores by a nonzero constant leaves the variance shares
unchanged, up to fitting precision, while variances change by its
square. Variance estimates are retained without decimal rounding. If all
retained scores are equal, or the fitted total variance is not positive
and finite, variances and ICCs are unavailable (`NA`); numerical fitting
residue is not interpreted as observed variation. A constant-response
bootstrap refit is also unavailable and withholds the interval.

## Interpreting output

The `Interpretation` column uses **two scales** so the same numeric ICC
reads correctly for each facet role:

- For the `person` facet, higher ICC = better. Koo & Li (2016, p. 161)
  bands are applied: `< 0.5` Poor, `[0.5, 0.75]` Moderate, `(0.75, 0.9]`
  Good, `> 0.9` Excellent. The strict `>` boundary at 0.9 follows Koo &
  Li's wording "values greater than 0.90 indicate excellent reliability"
  (so an ICC of exactly 0.9 reads as Good).

- For non-person facets (Rater, Criterion, Task, Region, ...) the same
  numeric value is a **variance share**: how much of the total observed
  score variance sits at that facet. The bands used here are different
  (`Trivial share` \< 0.05, `Small share` \< 0.15, `Moderate share` \<
  0.30, `Large share` \>= 0.30), and a large rater share is generally
  *bad* news (raters disagree about averages), not good news.

The `InterpretationScale` column explicitly records which scale applies
to each row, so downstream reporting does not confuse the two. FACETS
(Linacre, 2026) reports rater separation/reliability on the Rasch metric
instead of an ICC; mfrmr surfaces both, with the Rasch-metric version in
`diagnostics$reliability` and this variance-share view here.

Set `ci_method = "boot"` to request intervals alongside the point
estimates. The `Interpretation` column still uses point estimates. The
bootstrap simulates Gaussian random effects and errors from the fitted
model; it does not correct model misspecification or missing-data bias.
Percentile coverage can be unreliable near zero variance components or
with few grouping levels.

Intervals are withheld if the original fit has convergence problems or
warnings, or if any requested bootstrap refit fails, has convergence
problems or warnings, or produces an undefined ICC. Finite draws are
retained but never silently selected to calculate an interval. Singular
fits (zero random-effect components) are recorded separately and
retained when they converge; they are not automatically treated as
failures. Inspect `ICC_CI_Status` and `attr(x, "icc_ci")` before
reporting intervals.

## Updating saved intervals

The former `ci_method = "profile"` transformed separate
standard-deviation intervals while holding other variance components
fixed. These are not profile-likelihood intervals for the ICC ratio and
should not be reported as ICC confidence intervals. Requests now stop
with an explanation. Rerun `compute_facet_icc()` or
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md)
with the original data and settings, choosing `ci_method = "boot"`
explicitly if intervals are needed. Saved bootstrap results from earlier
versions must also be rerun to obtain complete failure accounting.
Printing, summarizing, or plotting old interval results cannot correct
their calculations.

## Typical workflow

1.  Fit the MFRM model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    for the Rasch-metric separation/reliability.

2.  Call `compute_facet_icc(data, facets, score, person)` to get the
    complementary variance-share summary.

3.  Feed into
    [`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md)
    to convert ICCs and average cluster sizes into descriptive,
    per-facet design-effect approximations. These do not estimate the
    precision of the full design.

## References

Koo, T. K., & Li, M. Y. (2016). A guideline of selecting and reporting
intraclass correlation coefficients for reliability research. *Journal
of Chiropractic Medicine, 15*(2), 155-163.

Bates, D., Maechler, M., Bolker, B., & Walker, S. (2015). Fitting linear
mixed-effects models using lme4. *Journal of Statistical Software,
67*(1), 1-48.

## See also

[`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md),
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md),
[`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md),
[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md).

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
if (requireNamespace("lme4", quietly = TRUE)) {
  icc <- compute_facet_icc(toy, facets = c("Rater", "Criterion"),
                           score = "Score", person = "Person")
  print(icc)
  # Look for:
  # - Person ICC reads as Koo & Li (2016) reliability: < 0.5 poor,
  #   0.5-0.75 moderate, 0.75-0.9 good, > 0.9 excellent.
  # - Rater / Criterion ICC reads as variance share, NOT reliability;
  #   here SMALL values are desirable (raters / items agree), and
  #   shares > 0.10 hint at meaningful systematic facet differences.
  # - `Interpretation` summarises the variance-share band the helper
  #   has assigned to each row.
}
#> mfrm_facet_icc
#>   ICC rows: 768 input, 768 used, 0 excluded.
#>      Facet   Variance    ICC Interpretation InterpretationScale ICC_CI_Lower
#>     Person 0.34626071 0.3511           Poor  Koo-Li reliability           NA
#>      Rater 0.02667343 0.0270  Trivial share      Variance share           NA
#>  Criterion 0.02188365 0.0222  Trivial share      Variance share           NA
#>   Residual 0.59144865 0.5997    Large share      Variance share           NA
#>  ICC_CI_Upper ICC_CI_Level ICC_CI_Method ICC_CI_Status InputRows UsedRows
#>            NA         0.95          none Not requested       768      768
#>            NA         0.95          none Not requested       768      768
#>            NA         0.95          none Not requested       768      768
#>            NA         0.95          none Not requested       768      768
#>  ExcludedRows
#>             0
#>             0
#>             0
#>             0
# }
```
