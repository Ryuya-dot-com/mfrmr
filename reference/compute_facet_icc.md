# Compute intra-class correlations for each facet

Fits a random-effects variance-components model
`Score ~ 1 + (1 | Person) + (1 | Facet1) + (1 | Facet2) + ...` using
[`lme4::lmer`](https://rdrr.io/pkg/lme4/man/lmer.html) (in `Suggests`)
and returns the proportion of observed score variance attributable to
each facet. This is a descriptive summary complementary to the
Rasch-metric rater separation/reliability reported elsewhere.

Combines per-facet average cluster size with ICC estimates to return the
Kish-style approximation `Deff = 1 + (m - 1) * rho`, where `m` is the
average number of observations per facet element and `rho` is the ICC
variance share. Each facet is evaluated separately.

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

compute_facet_design_effect(
  data,
  facets,
  icc_table = NULL,
  score = NULL,
  person = NULL,
  missing = c("error", "omit")
)
```

## Arguments

- data:

  Data frame in long format, used to fit the ICC model when `icc_table`
  is `NULL`. With a supplied ICC table, sample sizes come from its
  retained row accounting, not from `data`.

- facets:

  Character vector of facet column names.

- score:

  Score column name; required when `icc_table` is `NULL`.

- person:

  Person column; passed through to compute_facet_icc().

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

  Missing-value policy passed to `compute_facet_icc()` when `icc_table`
  is `NULL`. A supplied table retains its original policy.

- icc_table:

  Output from `compute_facet_icc()` (optional; will be computed on the
  fly when `NULL`). Must retain its `data_usage` attribute. Rerun older
  saved ICC results from their original data and settings before
  calculating design effects; their analysis sample cannot be
  reconstructed from the ICC table alone.

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

A data.frame of class `mfrm_facet_design_effect` with columns `Facet`,
`AvgClusterSize`, `ICC`, `DesignEffect`, `EffectiveN`, `InputRows`,
`UsedRows`, and `ExcludedRows`. Its `data_usage` attribute is retained
from the ICC result. Cluster sizes and effective sample sizes use only
rows included in that model.

## Rows used

Missingness is checked only in the score, facets, and optional person
column. `InputRows`, `UsedRows`, and `ExcludedRows` are included in the
table. `attr(x, "data_usage")` retains these counts, excluded input row
positions, missing columns per row, and observed grouping-level counts
after omission. `compute_facet_design_effect()` uses these retained
counts for its sample sizes. Omission does not impute scores or correct
missing-data bias.

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

- For `person`, the stored labels apply the Koo & Li (2016) bands to the
  point estimate: `< 0.5` Poor, `[0.5, 0.75]` Moderate, `(0.75, 0.9]`
  Good and `> 0.9` Excellent. These are descriptive labels, not
  universal acceptance rules. The share depends on Person heterogeneity
  as well as other sources of variation. It is not automatically the
  reliability of a composite, a mean over ratings or a different design.

- Other facets use package-defined variance-share bands: `Trivial share`
  \< 0.05, `Small share` \< 0.15, `Moderate share` \< 0.30 and
  `Large share` \>= 0.30. These cutoffs are not supplied by Koo & Li. A
  larger rater component describes systematic differences in score
  levels; its practical importance depends on the design and decision.
  Criterion or task variation is not inherently undesirable.

This is a Gaussian random-intercept model of numeric scores, not an
ordinal response model or an automatic selection among standard ICC
forms. State the fitted formula, score coding, target and uncertainty
when reporting.

The `InterpretationScale` column explicitly records which scale applies
to each row, so downstream reporting does not confuse the two. FACETS
(Linacre, 2026) reports rater separation/reliability on the Rasch metric
instead of an ICC; mfrmr surfaces both, with the Rasch-metric version in
`diagnostics$reliability` and this variance-share view here. For
agreement or consistency between specific pairs on common units, use
[`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
instead. A small rater variance share here does not establish pairwise
agreement; residual disagreement can still be large.

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

The formula describes the variance inflation of an unweighted mean under
a single clustering factor with equal cluster sizes, independent
clusters, and common within-cluster correlation. This helper substitutes
the average cluster size and one fitted facet variance share. It does
not calculate the variance of a specified estimator under the full
sampling design.

- `Deff = 1` means this approximation adds no inflation for that facet;
  it does not establish independence of observations or adequate
  precision.

- `Deff > 1` signals potential clustering influence under this
  approximation. `EffectiveN = UsedRows / Deff` is a descriptive
  equivalent row count, not a count of independent Persons or an
  assurance of matching precision.

- Unequal cluster sizes, crossed or nested dependencies, sampling
  weights, and finite-population corrections are not accounted for.
  Per-facet values must not be added or multiplied to obtain an overall
  design effect.

- Reported `ICC` is pulled from `icc_table$ICC` (the variance share);
  interpretation is the same as in `compute_facet_icc()`.

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

3.  Feed into `compute_facet_design_effect()` to convert ICCs and
    average cluster sizes into descriptive, per-facet design-effect
    approximations. These do not estimate the precision of the full
    design.

&nbsp;

1.  Run `compute_facet_icc()` to get the variance-component shares.

2.  Feed the result and the data into
    `compute_facet_design_effect(data, facets, icc_table = icc)`.

3.  Use these values to flag facets for design review. For standard
    errors, sample-size planning, or comparisons of precision, use an
    estimator and variance calculation that represent the actual design.

## References

Koo, T. K., & Li, M. Y. (2016). A guideline of selecting and reporting
intraclass correlation coefficients for reliability research. *Journal
of Chiropractic Medicine, 15*(2), 155-163.

Bates, D., Maechler, M., Bolker, B., & Walker, S. (2015). Fitting linear
mixed-effects models using lme4. *Journal of Statistical Software,
67*(1), 1-48.

Kish, L. (1965). *Survey Sampling*. New York: Wiley.

Park, I., & Lee, H. (2004). Design effects for the weighted mean and
total estimators under complex survey sampling. *Survey Methodology,
30*(2), 183-193.
<https://www150.statcan.gc.ca/n1/pub/12-001-x/2004002/article/7751-eng.pdf>

## See also

`compute_facet_design_effect()`,
[`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md),
[`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md),
[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md).

`compute_facet_icc()`,
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md).

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("compute_facet_icc", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
if (requireNamespace("lme4", quietly = TRUE)) {
  icc <- compute_facet_icc(toy, facets = c("Rater", "Criterion"),
                           score = "Score", person = "Person")
  print(icc)
  # Look for:
  # - Person labels apply Koo & Li bands descriptively to the point.
  #   Check the model, Person heterogeneity and interval before interpreting.
  # - Rater / Criterion ICC reads as variance share, NOT reliability;
  #   small values indicate limited systematic facet differences, and
  #   practical importance is not determined by a universal share cutoff.
  # - `Interpretation` summarises the variance-share band the helper
  #   has assigned to each row.
}
} # }
# Optional workflow; run the example explicitly as shown below.
# example("compute_facet_design_effect", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
if (requireNamespace("lme4", quietly = TRUE)) {
  icc <- compute_facet_icc(toy, facets = c("Rater", "Criterion"),
                           score = "Score", person = "Person")
  deff <- compute_facet_design_effect(toy,
                                      facets = c("Rater", "Criterion"),
                                      icc_table = icc)
  print(deff)
  # Review clustering influence; EffectiveN is a descriptive row count.
}
} # }
```
