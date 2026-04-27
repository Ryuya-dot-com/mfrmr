# M2 Latent Regression Master Plan

Date: 2026-04-03
Status: active phase-tracking plan; first-wave core implemented, broader ConQuest-gap work remaining
Scope: unidimensional latent regression for ordered many-facet Rasch models under `MML`

## Status note

This document is no longer a pure pre-code implementation plan.

As of 2026-04-10, the first-wave latent-regression branch is already present in
the package. The public API, person-level population scaffold, person-specific
quadrature path, and population-model-aware posterior scoring route are
implemented for the narrow `MML` branch.

Use this file as the phase-tracking plan for what remains between that
first-wave implementation and a stricter ConQuest-overlap benchmark surface.

Current-truth companions:

- `M2_LATENT_REGRESSION_IMPLEMENTATION_STATUS_2026-04-10.md`
- `M2_CONQUEST_OVERLAP_BOUNDARY_2026-04-03.md`
- `M2_LATENT_REGRESSION_STATISTICAL_SPEC_2026-04-03.md`

## 1. Mission

Implement the smallest defensible latent-regression extension that:

- fits naturally on the current ordered-response many-facet Rasch core,
- is documentable against official ConQuest behavior and primary literature,
- does not require Stan or Bayesian sampling machinery,
- and does not weaken the current package's honesty about fixed-calibration approximations.

This milestone is complete only when `mfrmr` can distinguish, in code and in help:

- unconditional `MML` under a fixed standard-normal prior,
- latent regression under a covariate-conditioned population model,
- fixed-calibration post hoc scoring,
- and post hoc regression on estimated scores.

## 2. Source-Backed Target

### 2.1 Official overlap target

For M2, the direct official comparison target is ConQuest rather than FACETS.

Reason:

- ConQuest explicitly documents a population model and a `regression` specification.
- ConQuest explicitly distinguishes EAP estimates, MLE estimates, and latent regression results.
- ConQuest explicitly warns that secondary analyses on EAP or MLE scores are not equivalent to latent regression.

Source basis:

- ACER ConQuest Tutorial: <https://conquestmanual.acer.org/s2-00.html>
- ACER ConQuest Technical Matters: <https://conquestmanual.acer.org/s3-00.html>
- ACER ConQuest Command Reference: <https://conquestmanual.acer.org/s4-00.html>

### 2.2 Primary methodological anchors

The plan should stay within the methodological envelope supported by:

- Bock and Aitkin (1981) for quadrature-based `MML` and EM-style marginal estimation;
- Mislevy (1991) for plausible values as posterior draws under a population model;
- the current Rasch-family ordered-response sources already used by the package.

Source basis:

- Bock, R. D., & Aitkin, M. (1981). *Marginal maximum likelihood estimation of item parameters: Application of an EM algorithm*. *Psychometrika*, 46(4), 443-459.
- Mislevy, R. J. (1991). *Randomization-based inference about latent variables from complex samples*. *Psychometrika*, 56(2), 177-196.

## 3. Hard Scope Boundaries

### 3.1 In scope for the first M2 release

- unidimensional latent regression only;
- ordered-response `RSM` and `PCM` only;
- `MML` only;
- person-level covariates that can be expanded through `stats::model.matrix()`
  into a numeric design matrix, including numeric, logical, factor,
  ordered-factor, and character predictors;
- automatic intercept;
- one residual variance parameter `sigma2` for the latent distribution;
- complete-case background-data policy for the first implementation;
- covariate-aware EAP and plausible values only after the model fit is validated.

### 3.2 Explicitly out of scope for the first M2 release

- `JML` latent regression;
- multidimensional latent regression;
- nominal response;
- `GPCM`;
- random slopes or heteroskedastic residual variance;
- arbitrary imported design specifications or undocumented contrast behavior
  beyond the fitted `stats::model.matrix()` coding contract;
- missing-covariate imputation;
- full empirical-Bayes / MCMC machinery;
- arbitrary population distributions beyond conditional normal.

### 3.3 Why this boundary is necessary

This boundary keeps M2 aligned with:

- the current unidimensional MML implementation,
- the current ordered-response scope,
- and the ConQuest-style population-model overlap that can be implemented without Stan.

If the first latent-regression branch tries to solve multidimensionality,
missing-data imputation, arbitrary imported design specifications, and
plausible-values redesign all at once, the milestone will lose identifiability,
documentation clarity, and validation credibility.

## 4. Target Statistical Model

### 4.1 Response model

Keep the current ordered many-facet Rasch response model unchanged.

For each observation `i` belonging to person `n`, use the current additive predictor:

- person location,
- minus non-person facet effects,
- minus step thresholds on the current `RSM` / `PCM` branch.

M2 must not change the response-model family.

### 4.2 Population model

Add a person-level conditional normal model:

`theta_n = x_n' beta + epsilon_n`, with `epsilon_n ~ N(0, sigma2)`.

Interpretation:

- `beta` controls the conditional latent mean,
- `sigma2` is the residual latent variance around that mean.

This is the smallest defensible latent-regression target because it matches the current unidimensional scale and provides a true population model, not just a post hoc regression on scores.

### 4.3 Posterior quantities

When latent regression is active, posterior scoring must be conditioned on:

- the fitted response model,
- the person's observed responses,
- and the person's covariates through the population model.

That means:

- EAP summaries must change,
- posterior intervals must change,
- plausible values must change.

The current fixed-calibration helpers cannot simply be relabeled. They need a population-model-aware path.

## 5. Key Design Decision

### 5.1 Preserve current `MML` as the default baseline

The current unconditional `MML` path should remain the default when no population model is requested.

This is a non-negotiable engineering decision because it preserves:

- backward compatibility,
- existing tests,
- current numerical behavior,
- and current documentation promises.

### 5.2 Make latent regression opt-in

Latent regression should be activated only when the user explicitly supplies a population-model specification.

Recommended public contract:

- `population_formula = NULL` keeps the current unconditional `MML`;
- a non-NULL formula turns on latent regression;
- `person_data` provides one-row-per-person background variables.

This is preferable to silently reading covariates from the long response table because person-level uniqueness must be auditable.

### 5.3 First-version data policy

For the first M2 implementation:

- require `person_data` when latent regression is requested;
- require one unique row per person;
- require variables referenced by the formula to be usable by
  `stats::model.matrix()`, and require the resulting design matrix to be
  numeric and full rank under the documented policy;
- require complete data for the covariates used in the formula;
- stop with an error or explicit omission policy when those conditions fail.

This aligns with the ConQuest-style emphasis that regressors are person-level numerical variables and keeps the contract testable.

## 6. Recommended Public API

### 6.1 `fit_mfrm()`

The first-wave implementation now exposes the following latent-regression-
facing arguments:

- `population_formula = NULL`
- `person_data = NULL`
- `person_id = NULL`
- `population_policy = c("error", "omit")`

Recommended behavior:

- if `population_formula` is `NULL`, current behavior is unchanged;
- if `population_formula` is non-`NULL`, `method` must be `MML`;
- `person_data` must contain one row per person;
- `person_id` defaults to the `person` argument if names match.

### 6.2 Fit object

Add a new top-level component:

- `population`

Recommended contents:

- `formula`
- `design_matrix`
- `person_table`
- `coefficients`
- `sigma2`
- `converged`
- `logLik_component`
- `notes`
- `posterior_basis`

This isolates the new model layer instead of overloading `config` or `summary`.

### 6.3 Prediction and plausible values

Do not replace the current helpers.

Instead, extend them so they can dispatch on two posterior bases:

- `fixed_calibration`
- `population_model`

Minimum contract:

- current fixed-calibration behavior remains available;
- latent-regression fits produce covariate-aware posterior scoring;
- returned objects declare which posterior basis they used.

## 7. Recommended Computational Strategy

### 7.1 Reuse the existing quadrature rule

Do not replace Gauss-Hermite quadrature.

Instead, retain the current standard-normal base rule and transform nodes personwise:

- `theta_nq = mu_n + sigma * z_q`,
- where `mu_n = x_n' beta`,
- and `(z_q, w_q)` are the current standard-normal nodes and weights.

Why this is the right first strategy:

- it stays inside the current MML architecture,
- it avoids a full rewrite of the quadrature machinery,
- it keeps the mathematical meaning transparent,
- and it gives a clean path for posterior scoring.

### 7.2 Reuse current likelihood structure

The existing MML loops already compute:

- per-observation log probabilities at each node,
- per-person aggregation,
- posterior weights.

M2 should modify only the part that maps person `n` and quadrature node `q` to `theta_nq`.

### 7.3 Gradient strategy

Phase the optimization strategy in two steps:

1. prove correctness with a stable optimization path, even if slightly slower;
2. optimize only after recovery and reduction checks pass.

The first implementation may use:

- analytic gradients where the extension is straightforward,
- and targeted numeric fallback for the new population parameters only if required temporarily.

But the target end state for M2 should still be a documented analytic or clearly justified hybrid gradient path.

## 8. Implementation Sequence

Implementation status summary:

- phases `M2-A` through `M2-E` are now implemented in first-wave form;
- phases `M2-F` and `M2-G` remain the main open bridge between the current
  branch and a stronger ConQuest-overlap claim.

### Phase M2-A. Specification freeze

Current status:

- completed in first-wave form.

Deliverables:

- exact model equation;
- exact data contract;
- exact fit-object contract;
- exact validation plan;
- exact help-page language boundary.

Stop/go gate:

- no code starts until these are written and reviewed against the audit note.

### Phase M2-B. Data and object scaffolding

Current status:

- completed in first-wave form.

Deliverables:

- `fit_mfrm()` accepts a latent-regression specification;
- person-level covariates are validated and stored;
- fit objects can hold a `population` component;
- current non-latent code path remains unchanged.

Validation:

- new tests for uniqueness, complete-case policy, model-matrix design
  construction, categorical coding provenance, and backward compatibility.

Stop/go gate:

- if unconditional `MML` output changes unexpectedly, stop and fix before proceeding.

### Phase M2-C. Core latent-regression estimation

Current status:

- completed in first-wave form for the narrow `MML` branch.

Deliverables:

- latent-regression log-likelihood under `MML`;
- estimation of `beta` and `sigma2`;
- convergence diagnostics for the population model;
- reduction to current unconditional `MML` when latent regression is not requested.

Validation:

- synthetic parameter recovery for `beta`;
- synthetic recovery for `sigma2`;
- sign and scale checks under centered covariates;
- convergence behavior checks across `RSM` and `PCM`.

Stop/go gate:

- if the branch cannot recover simple simulated cases, do not continue to posterior features.

### Phase M2-D. Population-model-aware scoring

Current status:

- completed in first-wave form.

Deliverables:

- covariate-aware EAP scoring;
- covariate-aware posterior intervals;
- posterior basis labels in output objects.

Validation:

- test that changing covariates changes posterior summaries when responses are held fixed;
- test that latent-regression fits and unconditional fits are distinguished in notes and summaries.

Stop/go gate:

- if scoring outputs cannot explain their posterior basis clearly, stop before plausible values.

### Phase M2-E. Population-model-aware plausible values

Current status:

- completed in first-wave form.

Deliverables:

- plausible values conditioned on the latent regression model;
- explicit separation from current fixed-calibration approximate plausible values.

Validation:

- draw-level checks against posterior moments;
- invariance of draw count and labeling;
- regression-aware notes and help pages.

Stop/go gate:

- no claim of “proper plausible values” unless the population-model dependency is explicit in code, docs, and tests.

### Phase M2-F. Simulation and forecasting extensions

Current status:

- first-version implementation is present.
- The package now has latent-regression-aware simulation specifications,
  scenario forecasting, fit-derived simulation extraction, and replayable
  categorical coding under the documented `MML` branch.
- Remaining work is external benchmarkability, beginner-facing documentation,
  and clearer separation between forecast helpers and the estimator itself.

Deliverables:

- latent-regression-aware simulation specification fields,
- person covariate generation for simulation,
- fitted `xlevels` / contrast reuse for categorical covariates,
- optional regression-parameter recovery workflows.

Validation:

- ADEMP-style recovery scripts,
- internal benchmark snapshots,
- synthetic examples only at first.

Stop/go gate:

- do not retrofit latent regression into every planning helper before the core fit and scoring path is stable.

### Phase M2-G. Export, replay, and documentation completion

Current status:

- partially open.
- replay/export support, categorical coding provenance, and documentation have
  advanced, but the remaining work is to complete the narrow reproducible
  overlap contract and keep public wording synchronized with the implemented
  boundary.

Deliverables:

- replay/export support for population-model arguments and fitted outputs;
- updated examples;
- updated workflow map;
- updated comparison language against ConQuest.

Validation:

- replay round-trip for a latent-regression fit;
- help-page cross-link checks;
- summary/print consistency checks.

## 9. Validation Matrix

### 9.1 Required validation classes

Every M2 stage must be supported by at least one of:

- parameter recovery,
- nested reduction,
- posterior-behavior sanity checks,
- export/replay round-trip,
- external overlap benchmark when defensible.

### 9.2 Minimum recovery design

Use synthetic data with:

- known `beta`,
- known `sigma2`,
- at least one centered continuous covariate,
- at least one dummy-coded categorical covariate,
- both `RSM` and `PCM` scenarios.

Report:

- bias,
- RMSE,
- empirical coverage where intervals are produced,
- convergence rate,
- and failure modes.

### 9.3 External overlap rule

External benchmarking against ConQuest is allowed only when:

- the model family is exactly overlapping,
- the coding and constraints are matched,
- and the comparison can be described honestly.

If exact overlap cannot be established, the benchmark remains synthetic and internal only.

## 10. Documentation Plan

### 10.1 Help pages that must change

At minimum:

- `fit_mfrm`
- `mfrmr-package`
- `mfrmr_workflow_methods`
- `predict_mfrm_units`
- `sample_mfrm_plausible_values`
- `predict_mfrm_population`
- `build_mfrm_sim_spec`
- replay/export help pages

### 10.2 Required wording distinctions

The documentation must explicitly separate:

- `predict_mfrm_population()` as scenario forecast from `sim_spec`,
- latent regression as an estimated person-level population model,
- fixed-calibration plausible values,
- and population-model-aware plausible values.

### 10.3 Documentation stop rule

If a help page cannot explain in one paragraph why a given output depends on:

- no population model,
- a fixed-calibration approximation,
- or an estimated population model,

then the implementation is not ready to ship.

### 10.4 Beginner-facing reporting checklist

The next documentation pass should reduce first-use friction before expanding
the model family. Add or strengthen checklist items for:

- which `fit_mfrm()` arguments are required for latent regression;
- how to structure `person_data` and choose `person_id`;
- how formula terms become model-matrix columns, including categorical
  predictors and stored `xlevels` / contrasts;
- how `population_policy = "error"` and `"omit"` affect persons and response
  rows;
- what `summary(fit)` should show first for active population-model fits;
- how to report population coefficients and residual variance in a manuscript;
- which tables belong in Methods, Results, diagnostics, and appendix sections;
- which plots are descriptive diagnostics versus support for stronger
  psychometric claims;
- and which ConQuest-overlap claims remain unsafe until the external benchmark
  is run.

## 11. Performance Plan

### 11.1 Low-risk optimization only

Until M2 core recovery passes, only low-risk performance work is allowed.

Examples:

- reusing person-level covariate matrices,
- caching `mu_n`,
- caching person-level transformed quadrature nodes,
- keeping current vectorized per-node likelihood structure.

### 11.2 Performance work that must wait

Defer until correctness is established:

- aggressive refactoring of likelihood loops,
- changing the optimizer strategy globally,
- parallel execution changes,
- and multidimensional quadrature generalization.

## 12. Risk Register

### R1. Scope inflation

Risk:

- latent regression turns into multidimensional or nominal work.

Response:

- treat any such request as M3/M4 and defer it.

### R2. Backward-compatibility break

Risk:

- current `MML` outputs change when latent regression is added.

Response:

- keep unconditional `MML` as the untouched default branch.

### R3. Documentation ambiguity

Risk:

- users confuse scenario forecasting with population modeling.

Response:

- sharpen `predict_mfrm_population()` help before or during M2.

### R4. Validation gap

Risk:

- the model runs, but no one can show that `beta` and `sigma2` are recovered.

Response:

- recovery scripts are a milestone requirement, not an optional add-on.

## 13. Immediate Next Deliverable

The next deliverable is no longer the statistical specification itself. That
specification is already in place.

The next deliverable should be a narrow reproducible-overlap package around the
implemented branch, with:

- a benchmarkable exact-overlap case,
- replay/export material that records the active population-model contract,
- recovery evidence for the implemented `beta` / `sigma2` branch,
- and documentation that clearly separates current overlap from future
  expansion targets.

The statistical specification remains the design anchor for that work.

Current status:

- this role is now filled by
  `inst/references/M2_LATENT_REGRESSION_STATISTICAL_SPEC_2026-04-03.md`

## 14. Short Checklist

- [x] Freeze the latent-regression statistical specification.
- [x] Freeze the public API and data contract.
- [x] Freeze the fit-object schema.
- [x] Add data-contract tests before estimation changes.
- [x] Implement latent-regression `MML` core.
- [x] Add recovery studies for `beta` and `sigma2`.
- [x] Extend EAP scoring to the population-model posterior.
- [x] Extend plausible values to the population-model posterior.
- [x] Extend replay/export.
- [x] Update help pages and examples.
- [x] Add scenario-level simulation / planning support for latent-regression
      `MML` workflows.
- [x] Preserve `stats::model.matrix()` categorical coding provenance across
      fitting, scoring, simulation, fit-derived simulation extraction, and
      package-native export metadata.
- [x] Run internal benchmarks.
- [x] Add a minimal exact-overlap external-comparison bundle for that narrow
      ConQuest overlap case.
- [x] Claim ConQuest overlap only where model and coding match exactly.
- [x] Add a package-native ConQuest-overlap dry-run benchmark harness for the
      current `RSM` / `PCM` latent-regression branch. This validates the
      bundle/normalization/audit contract and remains separate from actual
      external ConQuest execution.
- [x] Add a complete-case omission fixture to the reference benchmark surface
      via `synthetic_latent_regression_omit`.
- [ ] Execute the narrow external ConQuest-overlap benchmark with real extracted
      ConQuest output tables and retain the non-parity caveat in the results.
- [x] Add beginner-facing `summary(fit)` output for active population-model
      fits: status, posterior basis, covariates, coding, omission audit,
      category caveats, and next-step helpers.
- [x] Add beginner-facing help examples using one continuous and one
      categorical person covariate.
- [x] Add manuscript reporting guidance for latent-regression coefficients,
      residual variance, posterior scoring, plausible values, and ConQuest
      non-parity caveats.
- [x] Add table-shell guidance for Methods, Results, diagnostics, and appendix
      outputs.
- [ ] Add plot-interpretation guidance after the benchmark surface is stable.
- [x] Route latent-regression reporting tasks through `reporting_checklist()`
      and summary-table bundles.
