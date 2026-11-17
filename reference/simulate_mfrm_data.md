# Simulate long-format ordered many-facet data for design studies

Simulate long-format ordered many-facet data for design studies

## Usage

``` r
simulate_mfrm_data(
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
  group_levels = NULL,
  dif_effects = NULL,
  interaction_effects = NULL,
  seed = NULL,
  model = c("RSM", "PCM", "GPCM"),
  step_facet = "Criterion",
  slope_facet = NULL,
  thresholds = NULL,
  slopes = NULL,
  assignment = NULL,
  sparse_controls = NULL,
  sim_spec = NULL
)
```

## Arguments

- n_person:

  Number of persons/respondents.

- n_rater:

  Number of rater facet levels.

- n_criterion:

  Number of criterion/item facet levels.

- raters_per_person:

  Number of raters assigned to each person.

- design:

  Optional named design override supplied as a named list, named vector,
  or one-row data frame. When `sim_spec = NULL`, names may use canonical
  variables (`n_person`, `n_rater`, `n_criterion`, `raters_per_person`)
  or role keywords (`person`, `rater`, `criterion`, `assignment`). A
  nested named-facet form,
  `design$facets = c(person = ..., rater = ..., criterion = ...)`, is
  also accepted for the supported person/rater/criterion design. Do not
  specify the same variable through both `design` and the scalar count
  arguments.

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

  Spread of step thresholds on the logit scale.

- group_levels:

  Optional character vector of group labels. When supplied, a balanced
  `Group` column is added to the simulated data.

- dif_effects:

  Optional data.frame describing true group-linked DIF effects. Must
  include `Group`, at least one design column such as `Criterion`, and
  numeric `Effect`.

- interaction_effects:

  Optional data.frame describing true non-group interaction effects.
  Must include at least one design column such as `Rater` or
  `Criterion`, plus numeric `Effect`.

- seed:

  Optional random seed.

- model:

  Measurement model recorded in the simulation setup. The current public
  generator supports `RSM`, `PCM`, and `GPCM`.

- step_facet:

  Step facet used when `model = "PCM"` and threshold values vary across
  levels. Currently `"Criterion"` and `"Rater"` are supported.

- slope_facet:

  Slope facet used when `model = "GPCM"`. The current `GPCM` branch
  requires `slope_facet == step_facet`.

- thresholds:

  Optional threshold specification. Use a numeric vector of common
  thresholds; a named list such as `list(C01 = c(-1, 0, 1))`; a numeric
  matrix with one row per `StepFacet` and one column per step; or a long
  data frame with columns `StepFacet`, `Step`/`StepIndex`, and
  `Estimate`.

- slopes:

  Optional slope specification used when `model = "GPCM"`. Use either a
  numeric vector aligned to the generated slope-facet levels or a data
  frame with columns `SlopeFacet` and `Estimate`. Supplied slopes are
  treated as relative discriminations and normalized to the package's
  geometric-mean-one identification convention on the log scale. When
  omitted, slopes default to 1 for every slope-facet level, giving an
  exact `PCM` reduction.

- assignment:

  Assignment design. `"crossed"` means every person sees every rater;
  `"rotating"` uses a balanced rotating subset; `"resampled"` reuses
  person-level rater-assignment profiles stored in `sim_spec`;
  `"sparse_linked"` uses an incomplete rating design with optional
  linking persons; `"skeleton"` reuses an observed response skeleton
  stored in `sim_spec`, including optional `Group`/`Weight` columns when
  available. When omitted, the function chooses `"crossed"` if
  `raters_per_person == n_rater`, otherwise `"rotating"`.

- sparse_controls:

  Optional named list used when `assignment = "sparse_linked"`.
  Supported entries are `link_fraction`, `link_persons`,
  `link_raters_per_person`, `assignment_mode`, and
  `min_common_persons_per_rater_pair`. See
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  for the same contract.

- sim_spec:

  Optional output from
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  or
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md).
  When supplied, it defines the generator setup; direct scalar arguments
  are treated as legacy inputs and should generally be left at their
  defaults except for `seed`. Any custom public two-facet names recorded
  in `sim_spec$facet_names` are also carried into the simulated output
  and downstream planning helpers. If `sim_spec` stores an active
  latent-regression population generator, the returned object also
  carries the generated one-row-per-person background-data table needed
  to refit that population model later.

## Value

A long-format `data.frame` with core columns `Study`, `Person`, two
simulated non-person facet columns, and `Score`. By default those facet
columns are `Rater` and `Criterion`; when `sim_spec` records custom
public names, those names are used instead. If group labels are
simulated or reused from an observed response skeleton, a `Group` column
is included. If a weighted response skeleton is reused, a `Weight`
column is also included.

## Details

Draws independent centered normal (or `sim_spec` empirical /
latent-regression `population`) parameters \\\theta_n\\, \\\delta_j\\,
\\\beta_i\\, forms \\\eta = \theta_n - \delta_j - \beta_i + \epsilon\\
(plus optional `dif_effects` and `interaction_effects`, multiplied by
slope in `GPCM` where `slope_facet == step_facet` is normalized to unit
geometric mean), and samples ordered responses under `RSM`, `PCM`, or
`GPCM`.

Supports `"crossed"`, `"rotating"`, `"sparse_linked"` (retaining
coverage and overlap counts in `attr(x, "mfrm_sparse_design")`; Wind et
al., 2023,
[doi:10.1177/01466216231182148](https://doi.org/10.1177/01466216231182148)
), `"resampled"`, and `"skeleton"` assignments (preserving row
multiplicity as conditionally independent draws and passing `Weight`
through). Returned attributes carry `mfrm_truth` (including `signals`
and `slope_table`), `mfrm_simulation_spec`, and optional
`mfrm_population_data` (preserving template `terms`, factor levels, and
contrasts).

## See also

[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("simulate_mfrm_data", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
sim <- simulate_mfrm_data(
  n_person = 40,
  n_rater = 4,
  n_criterion = 4,
  raters_per_person = 2,
  seed = 123
)
head(sim)
names(attr(sim, "mfrm_truth"))
} # }
```
