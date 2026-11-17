# Build an explicit simulation specification for MFRM design studies

Define the response model, latent distributions and rating assignment
for
[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md).
This creates a reusable specification; it does not draw responses or fit
a model.

## Usage

``` r
build_mfrm_sim_spec(
  n_person = 50,
  n_rater = 4,
  n_criterion = 4,
  raters_per_person = n_rater,
  design = NULL,
  score_levels = 4,
  theta_sd = 1,
  rater_sd = 0.35,
  criterion_sd = 0.25,
  noise_sd = 0,
  step_span = 1.4,
  thresholds = NULL,
  model = c("RSM", "PCM", "GPCM"),
  step_facet = NULL,
  slope_facet = NULL,
  slopes = NULL,
  facet_names = NULL,
  assignment = c("crossed", "rotating", "sparse_linked", "resampled", "skeleton"),
  latent_distribution = c("normal", "empirical"),
  empirical_person = NULL,
  empirical_rater = NULL,
  empirical_criterion = NULL,
  assignment_profiles = NULL,
  design_skeleton = NULL,
  sparse_controls = NULL,
  group_levels = NULL,
  dif_effects = NULL,
  interaction_effects = NULL,
  population_formula = NULL,
  population_coefficients = NULL,
  population_sigma2 = NULL,
  population_covariates = NULL,
  population_assignment = c("matched", "independent")
)

# S3 method for class 'mfrm_sim_spec'
print(x, ...)

build_peer_review_sim_spec(
  n_submission = 50,
  n_criterion = 4,
  reviewers_per_submission = 3,
  anchor_fraction = 0.1,
  anchor_submissions = NULL,
  anchor_reviewers_per_submission = NULL,
  avoid_self_review = TRUE,
  assignment_mode = c("balanced", "random"),
  seed = NULL,
  score_levels = 4,
  theta_sd = 1,
  reviewer_sd = 0.45,
  criterion_sd = 0.25,
  noise_sd = 0,
  step_span = 1.4,
  model = c("RSM", "PCM", "GPCM"),
  step_facet = "Criterion",
  thresholds = NULL,
  group_levels = NULL,
  dif_effects = NULL,
  interaction_effects = NULL
)

extract_mfrm_sim_spec(
  fit,
  assignment = c("auto", "crossed", "rotating", "resampled", "skeleton"),
  latent_distribution = c("normal", "empirical"),
  source_data = NULL,
  person = NULL,
  group = NULL,
  population_assignment = c("matched", "independent")
)
```

## Arguments

- n_person:

  Number of persons/respondents to generate.

- n_rater:

  Number of rater facet levels to generate.

- n_criterion:

  Number of rubric criteria.

- raters_per_person:

  Number of raters assigned to each person.

- design:

  Optional named design override supplied as a named list, named vector,
  or one-row data frame. Names may use canonical variables (`n_person`,
  `n_rater`, `n_criterion`, `raters_per_person`), current public aliases
  implied by `facet_names` (for example `n_judge`, `n_task`,
  `judge_per_person`), or role keywords (`person`, `rater`, `criterion`,
  `assignment`). The nested named-facet form
  `design$facets = c(person = ..., judge = ..., task = ...)` is also
  accepted for the supported person/rater/criterion design. Do not
  specify the same variable through both `design` and the scalar count
  arguments.

- score_levels:

  Generator settings passed to `build_mfrm_sim_spec()`. `reviewer_sd`
  maps to the standard MFRM rater-severity spread.

- theta_sd:

  Generator settings passed to `build_mfrm_sim_spec()`. `reviewer_sd`
  maps to the standard MFRM rater-severity spread.

- rater_sd:

  Standard deviation of simulated rater severities.

- criterion_sd:

  Generator settings passed to `build_mfrm_sim_spec()`. `reviewer_sd`
  maps to the standard MFRM rater-severity spread.

- noise_sd:

  Generator settings passed to `build_mfrm_sim_spec()`. `reviewer_sd`
  maps to the standard MFRM rater-severity spread.

- step_span:

  Generator settings passed to `build_mfrm_sim_spec()`. `reviewer_sd`
  maps to the standard MFRM rater-severity spread.

- thresholds:

  Measurement-model settings passed to `build_mfrm_sim_spec()`. The
  first public facet is `Reviewer`; the second is `Criterion`.

- model:

  Measurement-model settings passed to `build_mfrm_sim_spec()`. The
  first public facet is `Reviewer`; the second is `Criterion`.

- step_facet:

  Measurement-model settings passed to `build_mfrm_sim_spec()`. The
  first public facet is `Reviewer`; the second is `Criterion`.

- slope_facet:

  Slope facet used when `model = "GPCM"`. The current `GPCM` branch
  requires `slope_facet == step_facet`.

- slopes:

  Optional slope specification for `model = "GPCM"`. Use either a
  numeric vector aligned to the generated slope-facet levels or a data
  frame with columns `SlopeFacet` and `Estimate`. Supplied slopes are
  treated as relative discriminations and normalized to the package's
  geometric-mean- one identification convention on the log scale. When
  omitted, slopes default to 1 for every slope-facet level, giving an
  exact `PCM` reduction. The `GPCM` model form follows Muraki's
  generalized partial credit model; the package's slope-regime labels
  are validation stress labels, not published psychometric cut points.

- facet_names:

  Optional public names for the two simulated non-person facet columns.
  Supply either an unnamed character vector of length 2 in rater-like /
  criterion-like order, or a named vector with names
  `c("rater", "criterion")`.

- assignment:

  Assignment design to record in the returned specification. Use
  `"resampled"` to reuse empirical person-level rater-assignment
  profiles from the fitted data, or `"skeleton"` to reuse the observed
  person-by-facet design skeleton from the fitted data.

- latent_distribution:

  Latent-value generator to record in the returned specification.
  `"normal"` stores spread summaries for parametric draws; `"empirical"`
  additionally activates centered empirical resampling from the fitted
  person/rater/criterion estimates.

- empirical_person:

  Optional numeric support values used when
  `latent_distribution = "empirical"`.

- empirical_rater:

  Optional numeric support values used when
  `latent_distribution = "empirical"`.

- empirical_criterion:

  Optional numeric support values used when
  `latent_distribution = "empirical"`.

- assignment_profiles:

  Optional data frame with columns `TemplatePerson` and the public
  rater-like facet column (optionally `Group`) describing empirical
  person-level rater-assignment profiles used when
  `assignment = "resampled"`. The canonical name `Rater` is also
  accepted.

- design_skeleton:

  Optional data frame with columns `TemplatePerson`, the public
  rater-like facet column, and the public criterion-like facet column
  (optionally `Group`, `Weight`, and `TemplatePersonReuse`) describing
  an observed response skeleton used when `assignment = "skeleton"`. The
  canonical names `Rater` and `Criterion` are also accepted.
  `TemplatePersonReuse = TRUE` asks
  [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)
  to keep the template-person order instead of resampling templates,
  which is used by `build_peer_review_sim_spec()`. This flag must be
  uniform across the skeleton. Every row is retained, including repeated
  Person-by-facet cells. Each generates a separate conditionally
  independent response; `Weight` is carried into fitting and does not
  multiply the number of generated responses.

- sparse_controls:

  Optional named list used when `assignment = "sparse_linked"`.
  Supported entries are `link_fraction` (default `0.1`), `link_persons`
  (overrides `link_fraction`), `link_raters_per_person` (default
  `n_rater`), `assignment_mode` (`"balanced"` or `"random"`), and
  `min_common_persons_per_rater_pair` (diagnostic target, default `1`).

- group_levels:

  Optional signal settings passed to `build_mfrm_sim_spec()`.

- dif_effects:

  Optional signal settings passed to `build_mfrm_sim_spec()`.

- interaction_effects:

  Optional signal settings passed to `build_mfrm_sim_spec()`.

- population_formula:

  Optional one-sided formula describing a person-level latent-regression
  population model used when generating person measures, for example
  `~ X + G`. When supplied, person measures are generated from
  `X %*% beta + e` rather than from `N(0, theta_sd^2)`.

- population_coefficients:

  Optional numeric vector of latent-regression coefficients
  corresponding to the design matrix implied by `population_formula`.

- population_sigma2:

  Optional residual variance for the latent-regression person
  distribution.

- population_covariates:

  Optional template data frame containing one row per template person
  and the background variables referenced by `population_formula`.
  Numeric/logical and categorical factor/character variables are
  expanded through the same
  [`stats::model.matrix()`](https://rdrr.io/r/stats/model.matrix.html)
  contract used by latent-regression fitting. During simulation,
  template rows are resampled with replacement to the requested
  `n_person`. Transformations such as
  [`scale()`](https://rdrr.io/r/base/scale.html),
  [`poly()`](https://rdrr.io/r/stats/poly.html) and splines retain the
  basis learned from the full template; they are not recomputed for each
  simulated sample. Stored factor levels and contrasts also carry
  through the study runners' refits. A resampled cohort can still have a
  rank-deficient design and fail fitting; that trial remains a failure
  rather than being redrawn until it succeeds.

- population_assignment:

  How an active population model is associated with `"resampled"` or
  `"skeleton"` assignments. The default `"matched"` draws one template
  Person jointly for covariates and assignments. Both tables must cover
  the same `TemplatePerson` IDs, with matching `Group` labels if present
  in both. `"independent"` samples covariate rows separately and
  intentionally breaks these associations. In that case both tables
  cannot define `Group`; rename a covariate if it represents a different
  grouping. For other assignment designs this setting has no effect.
  Population-template `Group`, when present, supplies the response
  group; `group_levels` must include all template labels and does not
  rebalance them.

- x:

  An `mfrm_sim_spec` object.

- ...:

  Reserved for generic compatibility.

- n_submission:

  Number of submissions/authors to generate.

- reviewers_per_submission:

  Number of peer reviewers assigned to each ordinary submission.

- anchor_fraction:

  Fraction of submissions treated as common-link anchor submissions when
  `anchor_submissions` is not supplied.

- anchor_submissions:

  Optional number of common-link anchor submissions. Anchor submissions
  receive `anchor_reviewers_per_submission` reviewers.

- anchor_reviewers_per_submission:

  Number of reviewers assigned to each anchor submission. Defaults to
  all eligible peers when anchors are used and self-review is
  disallowed; recorded as 0 when no anchor submissions are requested.

- avoid_self_review:

  Logical; if `TRUE`, a reviewer is never assigned to review their own
  submission.

- assignment_mode:

  Assignment algorithm. `"balanced"` assigns reviewers with the lowest
  current load using deterministic rotating tie-breaks. `"random"`
  samples eligible reviewers without replacement.

- seed:

  Optional seed used only for random peer-review assignment when
  `assignment_mode = "random"`.

- reviewer_sd:

  Generator settings passed to `build_mfrm_sim_spec()`. `reviewer_sd`
  maps to the standard MFRM rater-severity spread.

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- source_data:

  Optional original source data used to recover additional
  non-calibration columns, currently person-level `group` labels, when
  building a fit-derived observed response skeleton.

- person:

  Optional person column name in `source_data`. Defaults to the person
  column recorded in `fit`.

- group:

  Optional group column name in `source_data` to merge into the returned
  `design_skeleton` as person-level metadata.

## Value

An object of class `mfrm_sim_spec`.

`x`, invisibly.

An object of class `mfrm_sim_spec` with `peer_review` metadata and a
fixed peer-review design skeleton.

An object of class `mfrm_sim_spec`.

## Details

Records design counts, normal or empirical latent spreads,
`threshold_table`, optional `GPCM` `slope_table`
(`slope_facet == step_facet`, unit geometric mean; Muraki, 1992,
[doi:10.1177/014662169201600206](https://doi.org/10.1177/014662169201600206)
; validation labels in `slope_regime`), assignment settings
(`"crossed"`, `"rotating"`, `"sparse_linked"`, `"resampled"`,
`"skeleton"`), optional DIF/interaction `signals`, role-based
`planning_scope` / `planning_constraints` / `planning_schema`
(`facet_names` renames the rater-like and criterion-like roles without
enabling arbitrary-facet planning), and optional person
latent-regression generator templates (\\\theta_n = x_n^\top \beta +
\varepsilon_n\\, \\\varepsilon_n \sim N(0, \sigma^2)\\).

The [`print()`](https://rdrr.io/r/base/print.html) method shows the
model, design size, assignment and latent-distribution settings without
printing all stored metadata.

`build_peer_review_sim_spec()` creates a fixed
person-by-reviewer-by-rubric skeleton for peer-assessment or peer-review
studies. Submissions and peer reviewers share the same ID universe
(`P001`, `P002`, ...), so self-review can be structurally excluded and
checked in the generated data. The specification uses the existing
`assignment = "skeleton"` generator and records peer-review metadata; it
does not introduce a new measurement model. MFRM still estimates
person/submission measures, reviewer severity, and criterion difficulty,
while design-network review can inspect whether the peer-review graph is
sufficiently linked.

The common-link anchor controls follow the same logic used in sparse
rater-mediated designs: when most submissions receive only a few peer
reviews, assigning all or many reviewers to a small anchor set can
strengthen links among reviewers. The helper labels these rows as design
diagnostics, not universal adequacy thresholds for fit, separation, or
recovery.

`extract_mfrm_sim_spec()` uses a fitted model as a practical starting
point for later simulation studies. It extracts:

- design counts from the fitted data

- empirical spread of person and facet estimates

- optional empirical support values for semi-parametric draws

- fitted threshold values

- either a simplified assignment summary (`"crossed"` / `"rotating"`),
  empirical resampled assignment profiles (`"resampled"`), or an
  observed response skeleton (`"skeleton"`, optionally carrying
  `Group`/`Weight`)

- when the fit used the latent-regression branch, the fitted
  `population_formula`, coefficient vector, residual variance, and the
  stored person-level covariate table, including model-matrix xlevel and
  contrast provenance for categorical covariates

This is intended as a **fit-derived parametric starting point**, not as
a claim that the fitted object perfectly recovers the true
data-generating mechanism. Users should review and, if necessary, edit
the returned specification before using it for design planning. Observed
skeleton rows retain repeated rating occasions. Remove accidental
duplicate source rows before fitting; the generator cannot distinguish
them from intentional repeated ratings. Covariates and assignment
templates are linked by `TemplatePerson` under
`population_assignment = "matched"`.

Without an active population regression, `theta_sd` is the empirical SD
of the reported Person estimates, including any shrinkage in those
estimates. It is not an estimate of the latent population SD corrected
for measurement error. The empirical option resamples centered estimates
independently of their original IDs; it is not a draw from the source
posterior. With an active population model, its coefficients, residual
variance and fitted transformation basis replace this Person-spread
approximation. Neither route propagates uncertainty in the source fit's
generating parameters.

`GPCM` fits with the same slope and step owner are supported here for
direct data generation and parameter-recovery checks, provided that the
returned simulation specification stores both a threshold table and a
parallel slope table. The same fit-derived specification can feed
caveated role-based design evaluation, population forecasting, and
fit-based report/export bundles. Diagnostic and signal-detection design
screening is available with explicit caveats. This
simulation-specification helper does not perform full FACETS score-side
review, Bayesian posterior predictive checks or MCMC estimation. For
supported Bayesian specifications, see
[`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md);
its scope is separate from this generator.

If you want to carry person-level group labels into a fit-derived
observed response skeleton, provide the original `source_data` together
with `person` and `group`. Group labels are treated as person-level
metadata and are checked for one-label-per-person consistency before
being merged.

## References

- Farrokhi, F., Esfandiari, R., & Schaefer, E. (2012). A many-facet
  Rasch measurement of differential rater severity/leniency in three
  types of assessment. *JALT Journal*, 34(1), 79-102.
  doi:10.37546/JALTJJ34.1-3.

- Uto, M., & Ueno, M. (2020). A generalized many-facet Rasch model and
  its Bayesian estimation using Hamiltonian Monte Carlo.
  *Behaviormetrika*, 47, 469-496. doi:10.1007/s41237-020-00115-7.

- DeMars, C. E., Shapovalov, Y. A., & Hathcoat, J. D. (2023).
  *Many-Facet Rasch Designs: How Should Raters be Assigned to
  Examinees?* NCME presentation.

## Interpreting output

The returned object is a simulation specification, not a prediction
about one future sample. It captures one convenient approximation to the
observed design and estimated spread in the fitted run.

## See also

`extract_mfrm_sim_spec()`,
[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)

[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
[`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md),
`build_mfrm_sim_spec()`

`build_mfrm_sim_spec()`,
[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("build_mfrm_sim_spec", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
spec <- build_mfrm_sim_spec(
  design = list(person = 8, rater = 2, criterion = 2, assignment = 1),
  assignment = "rotating"
)
spec$model
spec$assignment
nrow(spec$threshold_table)
} # }
peer_spec <- build_peer_review_sim_spec(
  n_submission = 12,
  n_criterion = 3,
  reviewers_per_submission = 2,
  anchor_submissions = 2
)
peer_spec$peer_review$overview
#>      Scenario Submissions Reviewers Criteria OrdinaryReviewersPerSubmission
#> 1 peer_review          12        12        3                              2
#>   AnchorSubmissions AnchorReviewersPerSubmission AvoidSelfReview AssignmentMode
#> 1                 2                           11            TRUE       balanced
#>   SkeletonRows OrdinaryRows AnchorRows                              ReviewUse
#> 1          126           60         66 design_diagnostic_not_measurement_gate
toy <- simulate_mfrm_data(
  n_person = 8,
  n_rater = 3,
  n_criterion = 2,
  seed = 123
)
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Category support is retained but requires review: at least one fitted or local scope contains an empty or singleton category/transition cell. The fit may be inspected, but category-information strength has not been certified; inspect `fit$data_review$category_support` before inference.
spec <- extract_mfrm_sim_spec(fit, latent_distribution = "empirical")
spec$assignment
#> [1] "crossed"
spec$model
#> [1] "RSM"
head(spec$threshold_table)
#> # A tibble: 3 × 4
#>   StepFacet StepIndex Step   Estimate
#>   <chr>         <int> <chr>     <dbl>
#> 1 Common            1 Step_1   -2.79 
#> 2 Common            2 Step_2   -0.583
#> 3 Common            3 Step_3    3.37 
```
