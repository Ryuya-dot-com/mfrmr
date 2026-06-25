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
  or role keywords (`person`, `rater`, `criterion`, `assignment`). For
  the currently exposed facet keys, the schema-only future branch input
  `design$facets = c(person = ..., rater = ..., criterion = ...)` is
  also accepted. Do not specify the same variable through both `design`
  and the scalar count arguments.

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
  generator supports `RSM`, `PCM`, and bounded `GPCM`.

- step_facet:

  Step facet used when `model = "PCM"` and threshold values vary across
  levels. Currently `"Criterion"` and `"Rater"` are supported.

- slope_facet:

  Slope facet used when `model = "GPCM"`. The current bounded `GPCM`
  branch requires `slope_facet == step_facet`.

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
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md).
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

This function generates synthetic ordered many-facet data under `RSM`,
`PCM`, or the package's bounded `GPCM` branch. The data-generating
process is:

1.  Draw person abilities: \\\theta_n \sim N(0, \texttt{theta\\sd}^2)\\

2.  Draw rater severities: \\\delta_j \sim N(0, \texttt{rater\\sd}^2)\\

3.  Draw criterion difficulties: \\\beta_i \sim N(0,
    \texttt{criterion\\sd}^2)\\

4.  Generate evenly-spaced step thresholds spanning \\\pm\\`step_span/2`

5.  For each observation, compute the linear predictor \\\eta =
    \theta_n - \delta_j - \beta_i + \epsilon\\ where \\\epsilon \sim
    N(0, \texttt{noise\\sd}^2)\\ (optional)

6.  Compute category probabilities under the recorded measurement model
    (`RSM`, `PCM`, or bounded `GPCM`) and sample the response

Latent-value generation is explicit:

- `latent_distribution = "normal"` draws centered normal person/rater/
  criterion values using the supplied standard deviations

- `latent_distribution = "empirical"` resamples centered support values
  recorded in `sim_spec$empirical_support`

- if `sim_spec$population$active = TRUE`, person measures are generated
  from the stored latent-regression population model and template person
  covariates rather than from `theta_sd`

When `dif_effects` is supplied, the specified logit shift is added to
\\\eta\\ for the focal group on the target facet level, creating a known
DIF signal. Similarly, `interaction_effects` injects a known bias into
specific facet-level combinations.

The generator targets the common two-facet rating design (persons
\\\times\\ raters \\\times\\ criteria). `raters_per_person` controls the
incomplete-block structure: when less than `n_rater`, each person is
assigned a rotating subset of raters to keep coverage balanced and
reproducible.

Threshold handling is intentionally explicit:

- if `thresholds = NULL`, common equally spaced thresholds are generated
  from `step_span`

- if `thresholds` is a numeric vector, it is used as one common
  threshold set

- if `thresholds` is a named list, numeric matrix, or data frame,
  threshold values may vary by `StepFacet` (currently `Criterion` or
  `Rater`)

For bounded `GPCM`, the generator now requires an explicit slope
contract in parallel with the threshold table. The current public branch
keeps `slope_facet == step_facet`, normalizes supplied slopes to the
same geometric-mean-one log-slope identification used by
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
and uses the internal `category_prob_gpcm()` helper for response
sampling. Broader arbitrary-facet planning remains restricted until that
slope-aware contract is generalized beyond the current role-based
design, population-forecasting, diagnostic-screening, and
signal-detection helpers.

Assignment handling is also explicit:

- `"crossed"` uses the full person x rater x criterion design

- `"rotating"` assigns a deterministic rotating subset of raters per
  person

- `"sparse_linked"` assigns most persons to an incomplete rater subset
  and assigns a configurable set of linking persons to a larger rater
  set

- `"resampled"` reuses empirical person-level rater profiles stored in
  `sim_spec$assignment_profiles`, optionally carrying over person-level
  `Group`

- `"skeleton"` reuses an observed person-by-rater-by-criterion response
  skeleton stored in `sim_spec$design_skeleton`, optionally carrying
  over `Group` and `Weight`

Sparse linked simulation is intended for planned-missing rating designs
in which connectivity is maintained through common linking persons. The
returned `mfrm_sparse_design` attribute summarizes design density,
planned missingness, rater coverage, and rater-pair common-person
counts. These summaries are design diagnostics, not model-fit statistics
or universal adequacy thresholds. This branch follows sparse
rater-mediated assessment design work by Wind, Jones, and Grajeda (2023,
doi:10.1177/01466216231182148), Wind and Jones (2018,
doi:10.1177/0013164417703733), and DeMars, Shapovalov, and Hathcoat
(2023).

For more controlled workflows, build a reusable simulation specification
first via
[`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
or derive one from an observed fit with
[`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md),
then pass it through `sim_spec`.

Returned data include attributes:

- `mfrm_truth`: simulated true parameters (for parameter-recovery
  checks)

- `mfrm_truth$signals`: injected DIF and interaction signal tables

- `mfrm_truth$slope_table`: simulated discrimination table for bounded
  `GPCM`

- `mfrm_population_data`: generated one-row-per-person background data
  when the simulation specification stores an active latent-regression
  generator, including model-matrix xlevel and contrast provenance for
  categorical covariates

- `mfrm_simulation_spec`: generation settings (for reproducibility)

- `mfrm_sparse_design`: sparse-design diagnostics when
  `assignment = "sparse_linked"`, including design density, planned
  missing rate, rater coverage, and rater-pair common-person counts

## Interpreting output

- Higher `theta` values in `mfrm_truth$person` indicate higher person
  measures.

- Higher values in `mfrm_truth$facets$Rater` indicate more severe
  raters.

- Higher values in `mfrm_truth$facets$Criterion` indicate more difficult
  criteria.

- `mfrm_truth$signals$dif_effects` and
  `mfrm_truth$signals$interaction_effects` record any injected detection
  targets.

## Typical workflow

1.  Generate one design with `simulate_mfrm_data()`.

2.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and diagnose with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

3.  For repeated design studies, use
    [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md).

## See also

[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
sim <- simulate_mfrm_data(
  n_person = 40,
  n_rater = 4,
  n_criterion = 4,
  raters_per_person = 2,
  seed = 123
)
head(sim)
#>             Study Person Rater Criterion Score
#> 1 SimulatedDesign   P001   R01       C01     2
#> 2 SimulatedDesign   P001   R02       C01     2
#> 3 SimulatedDesign   P001   R01       C02     3
#> 4 SimulatedDesign   P001   R02       C02     3
#> 5 SimulatedDesign   P001   R01       C03     3
#> 6 SimulatedDesign   P001   R02       C03     2
names(attr(sim, "mfrm_truth"))
#>  [1] "person"      "facets"      "steps"       "step_table"  "slopes"     
#>  [6] "slope_table" "population"  "groups"      "signals"     "design"     
```
