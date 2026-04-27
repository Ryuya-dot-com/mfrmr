# M2 Latent Regression Implementation Status

Date: 2026-04-10
Status: current implementation note
Scope: public-truth snapshot plus next-step roadmap

## 1. Purpose

This note replaces the old binary question of "implemented or not" with a more
useful statement:

- what is already implemented now;
- what boundary should be claimed publicly;
- what still blocks ConQuest-level coverage;
- what order of work is technically defensible next.

This is the current-truth companion to:

- `M2_CONQUEST_OVERLAP_BOUNDARY_2026-04-03.md`
- `M2_LATENT_REGRESSION_MASTER_PLAN_2026-04-03.md`

The older `M2_LATENT_REGRESSION_READINESS_AUDIT_2026-04-03.md` remains useful
only as a pre-implementation baseline.

## 2. Executive summary

`mfrmr` now implements a first-version latent-regression branch.

It is not accurate to say "latent regression is not implemented." It is also
not accurate to say "`mfrmr` has ConQuest parity."

The current truth is:

- latent regression is implemented for a narrow `MML` route;
- the supported overlap is ordered-response `RSM` / `PCM`, one latent
  dimension, a conditional-normal person population model, and person-level
  covariates from an explicit one-row-per-person table expanded through
  `stats::model.matrix()`;
- posterior scoring and plausible-value draws can now condition on the fitted
  population model;
- the broader ConQuest feature surface is still out of scope.

## 3. Implemented now

### 3.1 Public fit interface

`fit_mfrm()` now exposes:

- `population_formula`
- `person_data`
- `person_id`
- `population_policy`

This means latent regression is a public branch of the fitting interface rather
than an internal experiment.

### 3.2 Population-model scaffold

The current branch already implements:

- person-level covariate intake from a one-row-per-person table;
- model-matrix construction for the requested population formula;
- omission auditing for the documented data policy;
- a complete-case estimation table plus an observed-person-aligned
  `person_table_replay` table for replay/export provenance;
- fitted population coefficients and residual variance in `fit$population`;
- stored categorical `xlevels` and contrast provenance when formula terms are
  expanded through `stats::model.matrix()`;
- explicit `posterior_basis` metadata distinguishing ordinary `MML` from
  population-model scoring.

### 3.3 Person-specific quadrature

The key first-version statistical change is present:

- the quadrature basis can be resolved personwise through the fitted
  conditional-normal population model rather than one shared unconditional
  prior;
- posterior summaries for active latent-regression fits are therefore based on
  the fitted person-level population model, not merely on a post hoc regression
  of estimated scores.

### 3.4 Downstream scoring

`predict_mfrm_units()` and `sample_mfrm_plausible_values()` already support the
population-model posterior basis for active latent-regression fits, provided
that scored units also supply the required one-row-per-person background data.

### 3.5 Categorical coding and simulation provenance

The branch now also preserves the model-matrix coding contract across:

- fitting;
- population-model-aware scoring;
- plausible-value sampling;
- manual latent-regression simulation specifications;
- `simulate_mfrm_data()` generated person data;
- `extract_mfrm_sim_spec()` from active latent-regression fits;
- package-native replay/export metadata;
- export manifests and reference benchmark summaries;
- the complete-case omission benchmark fixture
  `reference_case_benchmark(cases = "synthetic_latent_regression_omit")`;
- the package-native ConQuest-overlap dry-run benchmark harness in
  `reference_case_benchmark(cases = "synthetic_conquest_overlap_dry_run")`.

This means factor/character predictors are no longer merely ad hoc user-side
preprocessing. Their fitted levels and contrasts are part of the package
contract for replay and scoring. The exact-overlap ConQuest export remains
more conservative where the external bundle requires one raw numeric person
covariate column.

### 3.6 ConQuest-overlap benchmark harness

`reference_case_benchmark(cases = "synthetic_conquest_overlap_dry_run")` now
builds the narrow overlap bundle, round-trips package-native tables through the
ConQuest table-normalization contract, and audits the result. This is a
regression harness for the export/audit surface, not evidence that an external
ConQuest run has been executed.

`reference_case_benchmark(cases = "synthetic_latent_regression_omit")` now also
keeps the complete-case omission contract visible in the reference benchmark
surface: the omitted person count, omitted response-row count, retained-row
count, active person-estimate exclusion, and replay-provenance preservation are
checked explicitly.

## 4. Current public boundary

Safe public phrasing:

- "`mfrmr` includes a first-version latent-regression `MML` branch."
- "Current overlap with ConQuest is limited to unidimensional
  conditional-normal population modeling for ordered-response `RSM` / `PCM`,
  with covariates represented through the fitted model-matrix contract."
- "Posterior scoring for active latent-regression fits uses the fitted
  population model."

Unsafe public phrasing:

- "`mfrmr` is equivalent to ConQuest."
- "`mfrmr` reproduces the ConQuest latent-regression feature set."
- "`mfrmr` already supports arbitrary ConQuest-style regression design
  specifications."

## 5. What is still not implemented

The current branch should still be treated as incomplete relative to the full
ConQuest feature family.

Not yet implemented or not yet validated:

- `JML` latent regression;
- multidimensional latent regression;
- bounded `GPCM` latent regression;
- richer imported or arbitrary design-spec interfaces;
- arbitrary factor-coding and contrast management beyond the fitted
  `stats::model.matrix()` contract;
- broad ConQuest-style replay/export automation beyond the current package-native
  replay script and exact-overlap bundle;
- full ConQuest-style plausible-values workflow;
- true external ConQuest execution and broad benchmark coverage against external
  reference cases beyond the current dry-run harness.
- beginner-facing summary, table, manuscript, and plot-interpretation guidance
  that is strong enough for non-expert users.

## 6. Practical gap to ConQuest-level coverage

The remaining gap is no longer "add latent regression." That part has started.

The real gap is now fourfold:

1. stabilize the current narrow branch so it is fully testable and explainable;
2. make the population-model contract easier to inspect, report, and reproduce;
3. build benchmarkable overlap cases against the narrow ConQuest target;
4. only then expand dimensionality or model family.

That ordering matters. Expanding the model space before the current branch is
fully benchmarked would make the package harder to trust and harder to
document honestly.

## 7. Recommended roadmap

### Stage 1. Harden the implemented branch

Target:

- keep the current scope exactly as it is now;
- close correctness and documentation gaps before any expansion.

Concrete work:

- keep the focused parameter-recovery tests for population coefficients,
  intercepts, and residual variance green as the optimizer changes;
- keep regression-aware scoring, plausible-values, replay/export, and
  overlap-audit regression tests in the standard hardening path;
- continue surfacing `fit$population`, `posterior_basis`, and scoring-time
  `person_data` semantics clearly in public help;
- keep the ConQuest-overlap wording conservative everywhere.

### Stage 2. Complete the minimal reproducible overlap

Target:

- make the current branch externally benchmarkable and reproducible.

Concrete work:

- keep replay/export support for `population_formula`, replay-ready person data,
  person-level design metadata, and fitted population parameters aligned with
  the current narrow scope;
- maintain a narrow benchmark bundle that matches one exact ConQuest overlap
  case;
- keep the package-native ConQuest-overlap dry-run harness green;
- keep the complete-case omission fixture green so missing background data remain
  auditable in benchmark summaries;
- add a true external ConQuest run only when extracted output tables can be
  compared without weakening the broader software-equivalence caveat.

### Stage 3. Harden the model-matrix contract and reporting surface

Target:

- make the current model-matrix path easier to audit and report without
  overstating ConQuest parity.

Concrete work:

- keep the explicit policy for factor coding and contrasts synchronized across
  help pages, replay/export metadata, and summaries;
- make omission and complete-case behavior auditable in summaries and exports;
- decide whether weighted population models are in scope before implementation.

### Stage 4. Strengthen population-model reporting for beginners

Target:

- make latent-regression fits first-class reporting objects rather than merely
  hidden fit branches.

Concrete work:

- add dedicated summaries for coefficients, residual variance, and population
  design metadata;
- state clearly when posterior outputs are fixed-calibration versus
  population-model-based;
- add first-use guidance for the key `fit_mfrm()` arguments:
  `population_formula`, `person_data`, `person_id`, and `population_policy`;
- add table shells for Methods, Results, diagnostics, and appendix sections;
- add plot-interpretation guidance that distinguishes descriptive displays
  from evidence for stronger psychometric claims;
- avoid manuscript-ready shortcuts that imply ConQuest parity before the
  benchmark surface is mature.

### Stage 5. Expand the model space only after stages 1-4 are stable

Possible future directions:

- multidimensional latent regression;
- richer covariance structures;
- bounded `GPCM` latent regression;
- broader imported design specifications.

These are valid future targets, but they should not be the next step. The next
step is to make the implemented narrow branch robust enough to carry serious
benchmarking and documentation claims.

## 8. Recommended wording in public docs

When writing README/help text, the shortest accurate description is:

"`mfrmr` includes a first-version latent-regression `MML` branch for ordered
`RSM` / `PCM` many-facet models. Current overlap with ConQuest is limited to a
unidimensional conditional-normal population model with person-level covariates
from an explicit one-row-per-person table, expanded through the fitted
`stats::model.matrix()` contract."

## 9. Beginner-facing TODO checklist

These tasks are intentionally downstream of the core computational hardening.
They should reduce user friction without widening model claims prematurely.

- [x] Add a short "latent regression quick start" path to the README or a
      vignette: data shape, required arguments, continuous and categorical
      covariate example, and the first summary call to inspect. Current
      completion: README quick-start plus `fit_mfrm()` help; a longer vignette
      remains optional.
- [x] Expand `fit_mfrm()` help so beginners can answer: "What is the outcome
      variable?", "Where do covariates go?", "Why must `method = 'MML'` be
      used?", and "What happens when background data are missing?"
- [x] Expand `summary(fit)` for active population-model fits so the printed
      display shows model status, posterior basis, coefficients, residual
      variance, categorical coding variables, omitted persons/rows, zero-count
      category caveats, and recommended next functions.
- [x] Add a compact manuscript table shell for population coefficients and
      residual variance, with coding and scale notes.
- [x] Add a compact diagnostics/appendix table shell for person omission,
      category usage, posterior basis, and scoring-data requirements.
- [x] Add prose guidance for reporting in papers: Methods wording, Results
      wording, plausible-value wording, and wording to avoid when ConQuest
      parity has not been externally benchmarked. Current completion:
      `reporting_checklist()` plus `build_apa_outputs()` Table 5 population
      model prose, note, caption, and contract checks.
- [ ] Add plot interpretation guidance only after the benchmark surface is
      stable: coefficient plots, covariate-stratified latent distributions,
      posterior/PV distributions, observed-vs-predicted summaries, and
      ConQuest-overlap audit plots.
- [x] Route the same tasks through `reporting_checklist()` so users can see
      unresolved reporting actions without reading this reference note.

When writing roadmap text, prefer:

"The next latent-regression objective is not to rename the current branch as
ConQuest-equivalent, but to harden and benchmark the implemented overlap before
expanding dimensionality or model family."
