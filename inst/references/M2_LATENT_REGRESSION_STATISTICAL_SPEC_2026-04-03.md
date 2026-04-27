# M2 Latent Regression Statistical Specification

Date: 2026-04-03  
Status: living implementation specification  
Applies to: `mfrmr` ordered many-facet Rasch branch only

## 1. Purpose

This note freezes the exact specification for the first latent-regression implementation.

It is the final pre-code contract for:

- the statistical model,
- the public interface,
- the fit-object structure,
- the validation plan,
- and the documentation boundary.

It should be read together with:

- `inst/references/M2_LATENT_REGRESSION_READINESS_AUDIT_2026-04-03.md`
- `inst/references/M2_LATENT_REGRESSION_MASTER_PLAN_2026-04-03.md`

## 2. Design Principles

### 2.1 Preserve the current package truthfully

The current package already supports:

- ordered-response `RSM` / `PCM`,
- unconditional `MML`,
- `JML`,
- fixed-calibration scoring,
- approximate fixed-calibration plausible values.

Latent regression must be added without relabeling any existing helper as if it already were a population model.

### 2.2 Prefer the smallest defensible extension

The first implementation is intentionally narrow:

- unidimensional only,
- `MML` only,
- numeric person-level covariates only,
- conditional normal population model only.

### 2.3 Match theory, not internal vendor mechanics

The comparison target is the documented ConQuest model family and interpretation, not ConQuest's exact internal optimizer.

That means:

- the model,
- the posterior interpretation,
- and the output semantics

must overlap where claimed.

The package does not need to reproduce ConQuest's exact iteration path.

## 3. Statistical Model

### 3.1 Response model

Keep the current ordered many-facet Rasch response model unchanged.

For observation `i` from person `n`, let:

- `X_ni` be the observed ordered score,
- `theta_n` be the person location,
- `xi` denote the non-person facet and step parameters already used by `mfrmr`.

Then:

`P(X_ni = x | theta_n, xi)`

is exactly the current `RSM` or `PCM` probability model.

No slope parameters are introduced in M2.

### 3.2 Population model

When latent regression is requested, define the person-level population model as:

`theta_n = mu_n + epsilon_n`

with

`mu_n = x_n' beta`

and

`epsilon_n ~ N(0, sigma2)`.

Where:

- `x_n` is the person-level design vector including an intercept,
- `beta` is the regression coefficient vector,
- `sigma2 > 0` is the residual latent variance.

### 3.3 Marginal likelihood

For person `n`, let `X_n` denote all responses belonging to that person.

The latent-regression marginal likelihood is:

`L_n(xi, beta, sigma2) = integral P(X_n | theta, xi) f(theta | x_n, beta, sigma2) dtheta`

with

`f(theta | x_n, beta, sigma2) = Normal(theta; x_n' beta, sigma2)`.

The full log-likelihood is:

`log L = sum_n log L_n`.

This is the model-defining difference between:

- latent regression,
- and the current unconditional `MML`, which uses one common standard-normal prior for all persons.

### 3.4 Quadrature implementation target

The first implementation will reuse the current standard-normal Gauss-Hermite rule.

Let `(z_q, w_q)` denote the current quadrature nodes and weights for the standard normal scale.

For person `n`, define transformed nodes:

`theta_nq = mu_n + sigma z_q`

where

- `mu_n = x_n' beta`,
- `sigma = sqrt(sigma2)`.

Then the person-level marginal likelihood approximation is:

`L_n approx sum_q w_q P(X_n | theta_nq, xi)`.

This keeps the existing likelihood structure while making the prior person-specific.

### 3.5 Posterior quantities

For latent-regression fits, posterior scoring must use:

`p(theta_n | X_n, x_n, xi, beta, sigma2)`

which is proportional to:

`P(X_n | theta_n, xi) f(theta_n | x_n, beta, sigma2)`.

From that posterior, M2 will derive:

- EAP means,
- posterior SD,
- posterior intervals,
- plausible values.

### 3.6 Interpretation boundary

This model is fundamentally different from:

- regressing EAP scores on covariates after fitting,
- regressing MLE or JML scores on covariates after fitting,
- or scoring new persons under a fixed calibration with a reference prior.

ConQuest explicitly warns that secondary analyses on EAP or MLE scores are not equivalent to latent regression. `mfrmr` must mirror that distinction in help pages and examples.

Sources:

- ACER ConQuest Tutorial: <https://conquestmanual.acer.org/s2-00.html>
- ACER ConQuest Command Reference: <https://conquestmanual.acer.org/s4-00.html>

## 4. Identification Rules

### 4.1 Response-model identification

Keep the current facet-constraint system unchanged:

- non-person facets remain centered unless explicitly handled otherwise by the existing anchor/constraint machinery;
- no new slope identification issues are introduced because M2 stays in the Rasch family.

### 4.2 Population-model identification

For the latent-regression branch:

- the intercept is included in the design matrix;
- `sigma2` is estimated on the residual latent scale;
- non-person facet centering remains the main response-model location constraint.

### 4.3 Relationship to current unconditional `MML`

Current `mfrmr` unconditional `MML` uses a fixed standard-normal prior.

The latent-regression branch is different:

- it estimates regression coefficients,
- and it estimates residual latent variance.

Therefore:

- `population_formula = NULL` must continue to call the legacy unconditional `MML` branch;
- `population_formula = ~ 1` is a mean-only latent-regression branch and should be treated as a different model from the legacy fixed `N(0,1)` branch.

This distinction is essential for backward compatibility and honest documentation.

## 5. Public API Contract

### 5.1 `fit_mfrm()`

Add the following arguments:

- `population_formula = NULL`
- `person_data = NULL`
- `person_id = NULL`
- `population_policy = c("error", "omit")`

Behavior:

- if `population_formula` is `NULL`, current behavior is unchanged;
- if `population_formula` is not `NULL`, `method` must be `MML`;
- `person_data` becomes required;
- `person_id` identifies the person column in `person_data`;
- the resulting design matrix must be numeric and full-rank enough for fitting;
- missing covariate values are handled by `population_policy`.

### 5.2 First-version data rules

For the first implementation:

- `person_data` must contain exactly one row per person;
- duplicate person rows are an error;
- regressors must be numeric after model-matrix construction;
- character/factor inputs are allowed only if the resulting model matrix is explicit and documented;
- `population_policy = "error"` is the safest default;
- `population_policy = "omit"` may be offered only if omissions are audited and reported.

### 5.3 Why `person_data` is separate

Using a separate person table is preferable to silently reading covariates from the long response table because:

- person uniqueness can be audited directly,
- covariates are person-level rather than observation-level by construction,
- and the design matrix contract becomes reproducible.

## 6. Fit-Object Contract

### 6.1 New top-level component

Add:

- `population`

### 6.2 Required `population` contents

Minimum required fields:

- `active`: logical flag
- `formula`: stored formula
- `person_id`: person key used for merge
- `person_table`: cleaned one-row-per-person table used for fitting
- `design_matrix`: numeric model matrix actually used
- `coefficients`: regression coefficients
- `sigma2`: residual latent variance
- `converged`: population-model convergence flag
- `posterior_basis`: one of `legacy_mml`, `fixed_calibration`, `population_model`
- `policy`: missing-data policy used
- `notes`: interpretation notes

### 6.3 Summary contract

`summary(fit)` for latent-regression fits must expose:

- that the population model is active,
- the formula,
- coefficient estimates,
- residual variance,
- and a note distinguishing the result from post hoc regression on scores.

### 6.4 Replay/export contract

Replay/export must store enough information to recreate:

- the formula,
- the person table or a reproducible reference to it,
- the design matrix construction logic,
- the coefficient estimates,
- and `sigma2`.

## 7. Computation Contract

### 7.1 Estimation basis

The package remains a marginal-likelihood estimator.

M2 does not require an EM implementation specifically.

What is required is:

- correct maximization of the latent-regression marginal likelihood,
- documented numerical behavior,
- and validation evidence.

### 7.2 First implementation preference

Preferred first implementation:

- extend the current direct-optimization `MML` branch,
- reuse existing likelihood code,
- add population parameters to the optimized parameter vector or a clearly separated optimization layer,
- and document any temporary numeric-gradient fallback if used.

### 7.3 Numerical caution

Do not change the legacy unconditional `MML` path to force both branches through one shared code path before the latent-regression branch is validated.

That refactor can wait.

## 8. Prediction and Plausible-Values Contract

### 8.1 `predict_mfrm_units()`

For latent-regression fits, unit scoring must use the population-model posterior if person covariates for the scored units are available.

The output must state:

- whether scoring used a fixed calibration,
- or a fitted population model.

### 8.2 `sample_mfrm_plausible_values()`

For latent-regression fits, plausible values must be drawn from the posterior implied by:

- the fitted response model,
- the fitted population model,
- the person's covariates,
- and the observed response pattern.

### 8.3 Compatibility rule

Current fixed-calibration approximations remain supported.

They must not be silently replaced.

Instead, the returned object should carry an explicit `posterior_basis` note.

### 8.4 `predict_mfrm_population()`

This helper remains a scenario-forecast function from `sim_spec`.

It is not a latent-regression estimator.

When M2 lands, its help page must say this even more clearly than it does now.

## 9. Validation Contract

### 9.1 Minimum synthetic designs

Before release, recovery studies must cover:

- one centered continuous covariate,
- one dummy-coded categorical covariate,
- one `RSM` case,
- one `PCM` case,
- one mean-only latent-regression case `~ 1`,
- one null-effect predictor case.

### 9.2 Minimum reported metrics

Report at least:

- bias of `beta`,
- RMSE of `beta`,
- bias of `sigma2`,
- RMSE of `sigma2`,
- convergence rate,
- and posterior-moment checks for EAP / plausible values.

### 9.3 Required contrast checks

The following distinctions must be demonstrated empirically:

- latent regression versus post hoc regression on EAP,
- latent regression versus post hoc regression on JML scores,
- latent-regression plausible values versus fixed-calibration approximate draws.

### 9.4 Backward-compatibility checks

The following must stay unchanged unless explicitly documented:

- legacy unconditional `MML`,
- current `JML`,
- current fixed-calibration scoring on legacy fits,
- current non-latent help-page promises.

## 10. Documentation Contract

### 10.1 Help pages that must be updated

At minimum:

- `fit_mfrm`
- `mfrmr-package`
- `mfrmr_workflow_methods`
- `predict_mfrm_units`
- `sample_mfrm_plausible_values`
- `predict_mfrm_population`
- relevant replay/export pages

### 10.2 Required wording

The docs must distinguish:

- `legacy_mml`: fixed common prior, no population model;
- `fixed_calibration`: post hoc scoring under an existing calibration;
- `population_model`: fitted latent regression with covariate-conditioned posterior.

### 10.3 Forbidden wording before full implementation

Do not use any of the following until the implementation and validation are complete:

- "equivalent to ConQuest latent regression"
- "full plausible values procedure"
- "population model" for `predict_mfrm_population()`
- "latent regression" for any fixed-calibration helper

## 11. Stop Rules

Stop and defer if any of the following becomes necessary for the first version:

- multidimensional quadrature,
- missing-covariate imputation,
- nominal response support,
- random slopes,
- or a documentation story that relies on users not noticing the difference between fixed-calibration and population-model outputs.

## 12. Immediate Execution Order

1. Add API/data-contract scaffolding only. Completed.
2. Add fit-object scaffolding only. Completed.
3. Add data-contract tests before any likelihood changes. Completed.
4. Implement the latent-regression marginal likelihood. Completed.
5. Validate recovery before extending prediction. Completed via the package-native
   recovery baseline and targeted regression tests after the first prediction
   implementation pass.
6. Extend posterior scoring. Completed.
7. Extend plausible values. Completed.
8. Extend replay/export. Completed.
9. Update help pages. Completed.

## 13. Source Notes

The most important external constraints used in this specification are:

- ConQuest documents latent regression as a population model specified via `regression`, not as a secondary regression on score estimates.
- ConQuest documents that EAP estimates change when the population model changes.
- Bock and Aitkin (1981) justify quadrature-based marginal estimation as the core estimation basis.
- Mislevy (1991) motivates plausible values as posterior draws tied to a population model.

Sources:

- <https://conquestmanual.acer.org/s2-00.html>
- <https://conquestmanual.acer.org/s3-00.html>
- <https://conquestmanual.acer.org/s4-00.html>
- Bock, R. D., & Aitkin, M. (1981). *Psychometrika*, 46(4), 443-459.
- Mislevy, R. J. (1991). *Psychometrika*, 56(2), 177-196.
