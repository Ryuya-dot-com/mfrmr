# Build an explicit simulation specification for MFRM design studies

Build an explicit simulation specification for MFRM design studies

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
  population_covariates = NULL
)
```

## Arguments

- n_person:

  Number of persons/respondents to generate.

- n_rater:

  Number of rater facet levels to generate.

- n_criterion:

  Number of criterion/item facet levels to generate.

- raters_per_person:

  Number of raters assigned to each person.

- design:

  Optional named design override supplied as a named list, named vector,
  or one-row data frame. Names may use canonical variables (`n_person`,
  `n_rater`, `n_criterion`, `raters_per_person`), current public aliases
  implied by `facet_names` (for example `n_judge`, `n_task`,
  `judge_per_person`), or role keywords (`person`, `rater`, `criterion`,
  `assignment`). The schema-only future branch input
  `design$facets = c(person = ..., judge = ..., task = ...)` is also
  accepted for the currently exposed facet keys. Do not specify the same
  variable through both `design` and the scalar count arguments.

- score_levels:

  Number of ordered score categories.

- theta_sd:

  Standard deviation of simulated person measures.

- rater_sd:

  Standard deviation of simulated rater severities.

- criterion_sd:

  Standard deviation of simulated criterion difficulties.

- noise_sd:

  Optional observation-level noise added to the linear predictor.

- step_span:

  Spread used to generate equally spaced thresholds when
  `thresholds = NULL`.

- thresholds:

  Optional threshold specification. Use a numeric vector of common
  thresholds; a named list such as `list(C01 = c(-1, 0, 1))`; a numeric
  matrix with one row per `StepFacet` and one column per step; or a long
  data frame with columns `StepFacet`, `Step`/`StepIndex`, and
  `Estimate`.

- model:

  Measurement model recorded in the simulation specification.

- step_facet:

  Step facet used when `model = "PCM"` and threshold values vary across
  levels.

- slope_facet:

  Slope facet used when `model = "GPCM"`. The current bounded `GPCM`
  branch requires `slope_facet == step_facet`.

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

  Assignment design. `"crossed"` means every person sees every rater;
  `"rotating"` uses a balanced rotating subset; `"sparse_linked"` uses
  an incomplete rating design with optional linking persons;
  `"resampled"` reuses empirical person-level rater-assignment profiles;
  `"skeleton"` reuses an observed person-by-facet design skeleton.

- latent_distribution:

  Latent-value generator. `"normal"` samples from centered normal
  distributions using the supplied standard deviations. `"empirical"`
  resamples centered support values from
  `empirical_person`/`empirical_rater`/`empirical_criterion`.

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
  which is used by
  [`build_peer_review_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_peer_review_sim_spec.md).

- sparse_controls:

  Optional named list used when `assignment = "sparse_linked"`.
  Supported entries are `link_fraction` (default `0.1`), `link_persons`
  (overrides `link_fraction`), `link_raters_per_person` (default
  `n_rater`), `assignment_mode` (`"balanced"` or `"random"`), and
  `min_common_persons_per_rater_pair` (diagnostic target, default `1`).

- group_levels:

  Optional character vector of group labels.

- dif_effects:

  Optional data frame of true group-linked DIF effects.

- interaction_effects:

  Optional data frame of true interaction effects.

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
  template rows are resampled to the requested `n_person`.

## Value

An object of class `mfrm_sim_spec`.

## Details

`build_mfrm_sim_spec()` creates an explicit, portable simulation
specification that can be passed to
[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md).
The goal is to make the data-generating mechanism inspectable and
reusable rather than relying only on ad hoc scalar arguments.

The resulting object records:

- design counts (`n_person`, `n_rater`, `n_criterion`,
  `raters_per_person`)

- latent spread assumptions (`theta_sd`, `rater_sd`, `criterion_sd`)

- optional empirical latent support values for semi-parametric
  simulation

- threshold structure (`threshold_table`)

- optional discrimination structure for bounded `GPCM` (`slope_table`)
  and its identified log-slope spread label (`slope_regime`)

- assignment design (`assignment`)

- optional sparse linked-design controls (`sparse_controls`) when
  `assignment = "sparse_linked"`

- optional empirical assignment profiles (`assignment_profiles`) with
  optional person-level `Group` labels

- optional observed response skeleton (`design_skeleton`) with optional
  person-level `Group` labels and observation-level `Weight` values

- optional person-level latent-regression population metadata including
  `population_formula`, `population_coefficients`, `population_sigma2`,
  and a reusable template of person-level covariates, including
  model-matrix xlevel/contrast provenance for categorical covariates

- `planning_scope`, an explicit record that the current
  planning/forecasting helpers target the role-based person x rater-like
  x criterion-like design contract rather than a fully arbitrary-facet
  planner

- `planning_constraints`, an explicit record of which design variables
  can currently be changed from that specification without rebuilding it

- `planning_schema`, a combined schema contract bundling the role
  descriptor, scope boundary, current mutability map, a
  `facet_manifest`, a schema-only `future_facet_table`, and a matching
  `future_design_template`, plus a nested `future_branch_schema`
  scaffold for a future arbitrary-facet planning branch

- the current `design$facets(...)` parser now normalizes nested
  facet-count input through that bundled `future_branch_schema`, whose
  nested `design_schema` is now the authoritative schema-only branch
  object

- optional signal tables for DIF and interaction bias

The current generator targets the package's standard person x rater x
criterion workflow, but the public output names for those two facet
roles can now be customized with `facet_names`. This naming layer
improves public ergonomics; it does not yet turn the generator into a
fully arbitrary-facet simulator. Internally, helper objects keep
canonical role mappings so that planning functions can treat the first
non-person facet as rater-like and the second as criterion-like. When
threshold values are provided by `StepFacet`, the supported step facets
are the generated levels of the chosen public rater-like or
criterion-like column. For convenience, step-facet-specific thresholds
can be supplied as a named list or as a numeric matrix whose row names
are `StepFacet` labels. When `model = "GPCM"`, the same public facet
naming rules apply to the slope table; the current bounded branch keeps
`slope_facet` equal to `step_facet`. The `slope_regime` field summarizes
the centered log-slope spread so recovery simulations can be read
against the intended generator stress level. Its labels (`unit_slopes`,
`near_flat`, `moderate`, and `high_dispersion`) are package validation
labels; they are not model-fit decisions and should not be interpreted
as literature-derived adequacy thresholds. The GPCM data-generating form
follows Muraki (1992, doi:10.1177/014662169201600206), while
information-function interpretation follows Muraki (1993,
doi:10.1177/014662169301700403). The explicit simulation-specification
metadata is intended to support ADEMP-style simulation reporting as
described by Morris, White, and Crowther (2019, doi:10.1002/sim.8086).

The `assignment = "sparse_linked"` branch follows sparse rater-mediated
assessment work in treating incomplete rater assignment as planned
missingness rather than incidental nonresponse. Its `link_persons` and
`link_raters_per_person` controls emulate a common linking set so users
can inspect rater-pair common-person counts before using the generated
data in recovery or design studies. This is a design generator and
diagnostic metadata layer; it does not impose a universal
minimum-linking cutoff. Sparse-design motivation follows Wind, Jones,
and Grajeda (2023, doi:10.1177/01466216231182148), Wind and Jones (2018,
doi:10.1177/0013164417703733), and DeMars, Shapovalov, and Hathcoat
(2023).

If `population_formula` is supplied, the simulation specification
carries a first-version person-level latent-regression generator. This
affects only the person distribution. The current implementation keeps
the non-person facets in the existing many-facet Rasch generator and
resamples rows from `population_covariates` to the requested design size
before computing \\\theta_n = x_n^\top \beta + \varepsilon_n\\ with
\\\varepsilon_n \sim N(0, \sigma^2)\\.

## Interpreting output

This object does not contain simulated data. It is a data-generating
specification that tells
[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)
how to generate them.

## See also

[`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md),
[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
spec <- build_mfrm_sim_spec(
  design = list(person = 8, rater = 2, criterion = 2, assignment = 1),
  assignment = "rotating"
)
spec$model
spec$assignment
nrow(spec$threshold_table)
} # }
```
