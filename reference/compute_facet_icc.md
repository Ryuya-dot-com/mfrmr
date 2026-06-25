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
  ci_method = c("none", "profile", "boot"),
  ci_level = 0.95,
  ci_boot_reps = 1000L,
  ci_boot_seed = NULL,
  ci_boot_parallel = c("no", "multicore", "snow"),
  ci_boot_ncpus = 1L
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
  (default, point estimate only), `"profile"` (a **first-order
  approximation**: marginal likelihood-profile bounds for each
  variance-component SD via
  [`lme4::confint.merMod()`](https://rdrr.io/pkg/lme4/man/confint.merMod.html)
  with `method = "profile"`, squared to variances, then plugged into the
  ICC ratio while holding the other components at their point estimate;
  fast and deterministic, the default recommendation for reporting), or
  `"boot"` (parametric bootstrap via
  [`lme4::bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html); slower
  but robust to non-normal ICC sampling distributions because each
  bootstrap replicate resamples the full variance decomposition
  jointly).

- ci_level:

  Confidence level when `ci_method != "none"`; default `0.95`. Koo &
  Li (2016) recommend banding the CI rather than the point estimate when
  classifying reliability as Poor / Moderate / Good / Excellent.

- ci_boot_reps:

  Number of bootstrap replicates used when `ci_method = "boot"`. Default
  `1000`.

- ci_boot_seed:

  Optional integer seed for the bootstrap path (`NULL` leaves the RNG
  state untouched).

- ci_boot_parallel:

  Parallelisation strategy for the parametric-bootstrap CI path, passed
  through to
  [`lme4::bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html): `"no"`
  (default), `"multicore"` (POSIX `mclapply`), or `"snow"` (PSOCK
  cluster). `"multicore"` does nothing on Windows and falls back to
  serial; in that case use `"snow"` with
  [`parallel::makeCluster()`](https://rdrr.io/r/parallel/makeCluster.html)
  in scope.

- ci_boot_ncpus:

  Number of CPUs to use for the parallel bootstrap path (ignored when
  `ci_boot_parallel = "no"`). The per-replicate progress bar is
  suppressed under parallel execution because worker processes cannot
  push updates to the parent's cli console.

## Value

A data.frame of class `mfrm_facet_icc` with one row per variance
component (including a `"Residual"` row) and columns:

- `Facet`: the grouping factor name (or `"Residual"`).

- `Variance`: REML variance estimate.

- `ICC`: variance share (`Variance / sum(Variance)`), in `[0, 1]`.

- `Interpretation`: band label according to the facet's scale.

- `InterpretationScale`: `"Koo-Li reliability"` for the person facet,
  `"Variance share"` for others.

- `ICC_CI_Lower` / `ICC_CI_Upper` / `ICC_CI_Level` / `ICC_CI_Method`: CI
  bounds, level, and method (populated when `ci_method != "none"`;
  `NA_real_` otherwise).

- `ICC_CI_NReps`: bootstrap replicate count when `ci_method = "boot"`
  (absent otherwise).

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

Note: Koo & Li (2016) recommend applying the reliability bands to the
**95% confidence interval** of the ICC rather than to the point estimate
alone. Set `ci_method = "profile"` (default `"none"`) to obtain
likelihood-profile CI bounds alongside the point estimate, or
`ci_method = "boot"` for a parametric bootstrap with `ci_boot_reps`
replicates. The returned data frame gains `ICC_CI_Lower` /
`ICC_CI_Upper` columns so downstream reporting can apply the band to the
CI rather than the point estimate. The `Interpretation` column still
uses the point estimate so callers who want CI-aware banding can
implement it externally from the supplied bounds.

## Typical workflow

1.  Fit the MFRM model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    for the Rasch-metric separation/reliability.

2.  Call `compute_facet_icc(data, facets, score, person)` to get the
    complementary variance-share summary.

3.  Feed into
    [`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md)
    to convert ICCs and average cluster sizes into Kish (1965) design
    effects.

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
if (FALSE) { # \dontrun{
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
} # }
```
