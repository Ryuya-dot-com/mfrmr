# M2 Latent Regression Readiness Audit

Date: 2026-04-03  
Package target: `mfrmr` 0.1.5 development line  
Audit mode: local code audit + help-page audit + official-source audit

## Historical status note

This document is a pre-implementation baseline.

It intentionally describes the package before the first latent-regression
implementation wave. It should not be used as the current truth for the code
base on or after 2026-04-10.

Use these notes instead for the current boundary:

- `M2_CONQUEST_OVERLAP_BOUNDARY_2026-04-03.md`
- `M2_LATENT_REGRESSION_IMPLEMENTATION_STATUS_2026-04-10.md`

## 1. Purpose

This note fixes the pre-implementation baseline for latent regression work.

It answers five questions:

1. What is already implemented?
2. What is not implemented?
3. Which existing components can be reused for latent regression?
4. Are current help pages clear and internally consistent?
5. What must be true before M2 implementation starts?

The goal is to prevent two common failures:

- treating existing fixed-calibration scoring as if it were already a population model;
- starting implementation before the current M1/M2 boundary is explicit.

## 2. Evidence Base

### Local code and help pages audited

- `R/api-estimation.R`
- `R/mfrm_core.R`
- `R/api-prediction.R`
- `R/api-simulation-spec.R`
- `R/api-export-bundles.R`
- `R/mfrmr-package.R`
- `R/help_workflow_methods.R`
- `man/fit_mfrm.Rd`
- `man/predict_mfrm_population.Rd`
- `man/predict_mfrm_units.Rd`
- `man/sample_mfrm_plausible_values.Rd`
- `man/build_mfrm_sim_spec.Rd`
- `man/summary.mfrm_population_prediction.Rd`
- `man/summary.mfrm_unit_prediction.Rd`
- `man/summary.mfrm_plausible_values.Rd`
- `tests/testthat/test-prediction.R`
- `tests/testthat/test-simulation-design.R`
- `tests/testthat/test-output-stability.R`

### Official and primary sources audited

- ACER ConQuest Manual index: <https://conquestmanual.acer.org/index.html>
- ACER ConQuest Technical Matters: <https://conquestmanual.acer.org/s3-00.html>
- ACER ConQuest Command Reference: <https://conquestmanual.acer.org/s4-00.html>
- FACETS overview: <https://www.winsteps.com/facets.htm>
- FACETS Rasch models help: <https://www.winsteps.com/facetman64/raschmodels.htm>
- FACETS fair average notes: <https://www.winsteps.com/facetman/fairaverage.htm>
- FACETS bias analysis notes: <https://www.winsteps.com/facetman/biasanalysis.htm>
- Bock, R. D., & Aitkin, M. (1981). *Marginal maximum likelihood estimation of item parameters: Application of an EM algorithm*. *Psychometrika*, 46(4), 443-459.
- Mislevy, R. J. (1991). *Randomization-based inference about latent variables from complex samples*. *Psychometrika*, 56(2), 177-196.

### Agent coverage

Three parallel sub-audits were used:

- official/primary-source audit,
- code-path and fit-object audit,
- help-page and test-consistency audit.

## 3. Executive Summary

Current `mfrmr` does **not** implement latent regression.

What it does implement is:

- ordered-response many-facet Rasch estimation under `RSM` and `PCM`,
- unidimensional `MML` with a common normal quadrature prior,
- `JML`,
- fixed-calibration unit scoring,
- approximate fixed-calibration plausible-value-style draws,
- scenario-level design forecasting via Monte Carlo simulation.

What it does **not** implement is the ConQuest-style coupling of:

- an item/facet response model, and
- a person-level population model with predictors.

That missing layer is exactly what latent regression requires.

Therefore:

- `predict_mfrm_units()` is **not** latent regression,
- `sample_mfrm_plausible_values()` is **not** population-model-aware plausible values,
- `predict_mfrm_population()` is **not** a population model,
- and current `MML` is unconditional rather than covariate-conditional.

## 4. What Is Already Implemented

### 4.1 Response-model scope

Implemented now:

- ordered categorical many-facet Rasch models;
- binary as the ordered two-category special case;
- `RSM`;
- `PCM`;
- unidimensional person scale.

This scope is clearly stated in the package help and fits the ordered-response overlap with FACETS and ConQuest.

### 4.2 Estimation methods

Implemented now:

- `MML` using Gauss-Hermite quadrature;
- `JML` / `JMLE`;
- post hoc EAP person summaries for `MML`;
- post hoc fixed-calibration EAP scoring for future/partially observed persons.

The existing MML core is built around one shared quadrature rule:

- `gauss_hermite_normal()` returns one-dimensional quadrature nodes and weights;
- `mfrm_loglik_mml()` and `mfrm_grad_mml_core()` use the same prior weights for every person;
- `compute_person_eap()` computes posterior summaries from that common prior.

This is a coherent unconditional MML implementation, but it is not yet latent regression.

### 4.3 Prediction and plausible-value layer

Implemented now:

- `predict_mfrm_units()` for fixed-calibration EAP scoring;
- `sample_mfrm_plausible_values()` for posterior-draw summaries on the quadrature grid;
- `predict_mfrm_population()` for scenario-level Monte Carlo forecasting from `sim_spec`.

Current help pages are explicit that:

- `JML` scoring adds a reference prior only at the post hoc scoring stage;
- the current plausible values are approximate fixed-calibration summaries;
- these helpers are not a substitute for a full population model.

### 4.4 Planning and simulation layer

Implemented now:

- `build_mfrm_sim_spec()`;
- `extract_mfrm_sim_spec()`;
- `simulate_mfrm_data()`;
- `evaluate_mfrm_design()`;
- `evaluate_mfrm_signal_detection()`;
- `predict_mfrm_population()`.

This layer is useful for design planning, ADEMP-style workflow support, and scenario comparison, but it is not a fitted person-level regression model.

## 5. What Is Not Implemented

### 5.1 No latent regression interface

There is currently no public API for:

- person-level covariates,
- a regression formula,
- a design matrix for the population model,
- regression coefficients,
- residual variance or covariance for the latent distribution,
- covariate-aware posterior scoring,
- or latent-regression-specific summaries.

`fit_mfrm()` has no argument corresponding to ConQuest's `regression` specification.

### 5.2 No covariate retention in data preparation

`prepare_mfrm_data()` standardizes and keeps:

- person,
- non-person facets,
- score,
- optional weight.

It does not preserve background variables for later modeling.

This is the largest structural blocker before coding M2, because latent regression needs person-level predictors to survive preprocessing and enter the fit object.

### 5.3 No conditional prior

Current MML assumes one shared prior across persons.

Latent regression would require:

- a person-specific latent mean, typically `X_n beta`,
- and a residual variance or covariance structure.

That means the current common quadrature weights must become person-conditional weights or an equivalent conditional-prior representation.

### 5.4 No population-model-aware plausible values

ConQuest documents plausible values from the posterior conditioned on:

- responses,
- and the population model with background variables.

Current `mfrmr` plausible values are not that.

They are fixed-calibration posterior draws under:

- the fitted `MML` calibration, or
- a `JML` calibration plus a reference prior introduced only for scoring.

This boundary is already correctly stated in the current help pages and must be preserved until M2 is implemented.

### 5.5 No latent-regression fit outputs

Current fit objects return:

- `summary`,
- `facets`,
- `steps`,
- `config`,
- `prep`,
- `opt`.

They do not store the objects a population model would need, such as:

- `covariate_spec`,
- `X`,
- `beta`,
- `sigma2` or `Sigma`,
- population-model log-likelihood pieces,
- posterior basis metadata.

### 5.6 No latent-regression replay/export path

`build_mfrm_replay_script()` and export helpers currently serialize the existing calibration workflow only.

There is no replay support yet for:

- covariate formulas,
- design matrices,
- regression coefficients,
- or population covariance parameters.

### 5.7 No latent-regression tests

Current tests cover:

- estimation stability,
- fixed-calibration scoring,
- plausible-value approximations,
- design forecasting.

They do not cover:

- covariate preprocessing,
- conditional priors,
- regression parameter recovery,
- population-model-aware plausible values,
- or latent-regression fit summaries.

## 6. What Current Official Sources Imply

### 6.1 ConQuest

The ConQuest technical and command documentation is explicit that the fitted framework contains:

- an item response model,
- and a population model.

In the official command reference, the `regression` command specifies the independent variables used in the population model. The examples explicitly interpret this as regressing latent ability on background variables. A blank `regression;` statement corresponds to a mean-only population model.

The technical chapter also presents plausible values as draws from a posterior that depends on:

- the response model,
- and the population model `f_theta(theta_n; Y_n, gamma, Sigma)`.

That means ConQuest-style latent regression is not just "MML + EAP". It is a joint item-response plus population-model framework.

### 6.2 FACETS

The FACETS materials audited here document:

- ordered Rasch-family models,
- many-facet operational workflows,
- fair average,
- bias/interaction analysis,
- and related reporting utilities.

Those are appropriate comparison targets for the current ordered many-facet part of `mfrmr`.

In the official FACETS materials reviewed for this audit, latent regression was not the relevant reference target. For M2, ConQuest is the direct official comparison point for population-model work.

## 7. Reusable Implementation Seams

### 7.1 API boundary

Natural front-door insertion points:

- `fit_mfrm()`
- `prepare_mfrm_data()`

These are the first places where a covariate specification and person-level predictor retention must be introduced.

### 7.2 Core estimation

Natural M2 core insertion points:

- `build_estimation_config()`
- `run_mfrm_optimization()`
- `mfrm_loglik_mml_cached()`
- `mfrm_grad_mml_core()`
- `compute_person_eap()`

These already hold the unconditional MML path and can be generalized to a conditional population model.

### 7.3 Posterior scoring

Natural posterior-layer seams:

- `compute_person_posterior_summary()`
- `predict_mfrm_units()`
- `sample_mfrm_plausible_values()`

These functions already expose posterior summaries and draws. After M2 they should consume a covariate-aware posterior basis instead of the current common prior.

### 7.4 Simulation/specification

Natural simulation-side seams:

- `build_mfrm_sim_spec()`
- `extract_mfrm_sim_spec()`

These can later be extended with:

- person covariates,
- regression coefficients,
- residual variance,
- and covariate generators.

## 8. Help-Page Consistency Audit

### 8.1 What is already consistent

The following message is currently consistent across package-level and function-level help:

- ordered responses only;
- binary is the ordered two-category case;
- no nominal/multinomial response model yet;
- `JML` prediction is a post hoc reference-prior scoring approximation;
- current plausible values are approximate fixed-calibration draws;
- current prediction helpers are not full population-model procedures.

This is the right boundary and should not be weakened.

### 8.2 Main wording risk before M2

The main wording risk is not contradiction. It is boundary visibility.

The current help for `predict_mfrm_population()` correctly describes design-level scenario forecasting, but it does not say as directly as it should that this helper:

- does not estimate a latent regression,
- does not fit a covariate population model,
- and should not be read as a ConQuest-style population-model analogue.

Related wording in `build_mfrm_sim_spec()` can also sound more population-model-like than intended because of terms such as `latent_distribution` without an explicit contrast against fitted latent regression.

### 8.3 Secondary documentation risks

Secondary risks identified by the help-page audit:

- high-level workflow help does not strongly cross-link readers from forecast helpers to the limitation pages;
- summary pages are locally coherent but do not point readers back to the broader forecast/scoring boundary;
- runnable examples under-show the exact M2 boundary because the fixed-calibration examples are mostly `MML` examples and the forecast example is only hand-built `sim_spec`.

### 8.4 Conclusion on help clarity

Current help is mostly consistent and mostly safe.

The most important pre-M2 documentation action is not to rewrite the package story, but to sharpen the distinction between:

- scenario forecasting from a simulation specification, and
- an estimated population model with predictors.

## 9. Claims That Must Remain Prohibited Before M2

Do not claim any of the following until implementation and validation are complete:

- "`mfrmr` supports latent regression"
- "`predict_mfrm_population()` is a population model"
- "current plausible values are ConQuest-style plausible values"
- "`JML` plus reference prior is a substitute for latent regression"
- "background variables are already incorporated in posterior scoring"
- "regression coefficients or latent residual variance are estimated"

## 10. Pre-Implementation Checklist for M2

Latent regression work should not begin until the following are written down.

### M2-R1. Statistical specification

- exact model parameterization;
- unidimensional only vs multidimensional later;
- intercept handling;
- residual variance parameterization;
- identification and centering rules;
- missing-data policy for covariates;
- categorical-covariate coding policy;
- whether estimation is full EM, quasi-EM, or direct optimization over a profiled population model.

### M2-R2. Data contract

- person-level covariate interface for `fit_mfrm()`;
- how person-level uniqueness is checked;
- whether covariates are accepted from the long response table or from a separate person table;
- how covariates are preserved in `prep` and `config`.

### M2-R3. Output contract

- where `beta`, `sigma2` / `Sigma`, and covariate metadata live in the fit object;
- how summaries expose them;
- how replay/export recreates them;
- how prediction and plausible values detect whether they are fixed-calibration or population-model-aware.

### M2-R4. Validation contract

- parameter recovery under known `beta` and `sigma2`;
- nested-reduction check against the current mean-only population model;
- posterior-scoring checks against known covariate shifts;
- help-page checks that the new output is not confused with the old fixed-calibration helpers.

## 11. Recommended Immediate Next Step

The next step should be specification, not coding.

Produce one source-backed M2 specification note that fixes:

- the latent regression model equation,
- the data interface,
- the fit-object contract,
- the validation design,
- and the exact help-page language needed to distinguish
  `predict_mfrm_population()` from a true population model.

Only after that should code changes begin.
