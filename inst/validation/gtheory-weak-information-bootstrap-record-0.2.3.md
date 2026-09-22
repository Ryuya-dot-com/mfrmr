# Draft.83d2b2b1b exact-design bootstrap-mechanics record

Date: 2026-08-09
Scope: fitted-reduced-model parametric-bootstrap mechanics on the already
viewed three-cell schema
Result: exact accounting, backend-native simulation, response identity, refit,
and failure-bound mechanics pass; inferential calibration remains absent

## Outcome

Draft.83d2b2b1b implements only the middle layer of the corrected weak-
information plan: exact-observed-design plug-in parametric-bootstrap mechanics.
It does not execute the 3,000-row resolution-feasibility phase and does not
estimate bootstrap size or power.

The contract, manifest, and execution identities are:

- contract: `1fcde5612a1951dc42f144be7492d9781ffd5487630ded2bfc4cb88055f0b1be`;
- manifest: `0fee3a5089c05d47b52258374db4675949cfdb135323c69887ac936613ae3292`;
- execution: `8d13cf4b51e44e1f1a54b000f699cd1c16765ca1c3ad457dea78ce54e60e8ce9`.

The execution identity reproduced exactly in an independent second run.

## Mathematical and computational boundary

The procedure fits the full and Rater-reduced model on identical rows and
fixed effects. For each route, it simulates from the fitted reduced model,
including new random effects and residual errors, and refits the same full and
reduced route. lme4 uses its unconditional `re.form = NA` simulation route;
glmmTMB uses its backend-native simulation method, which resamples random
effects from their fitted distribution.

“Exact design” means that row order, covariates, factor levels, incidence,
missingness, fixed-effect design, and non-target random-effect terms are held
fixed. It does not mean an exact finite-sample test: nuisance components and
residual scale are plug-in estimates. The procedure is not Guedon, Baey, and
Kuhn's shrinked parametric bootstrap, and its validity is not inferred from
successful optimization.

The raw statistic remains

\[
  2\{\ell(M_F)-\ell(M_0)\}
\]

without truncation. A bootstrap refit is available only if both likelihoods,
row identity, one-parameter likelihood-df difference, optimizer checks, and
the frozen -1e-6 negative numerical tolerance pass.

For planned `B`, exceedances `E`, and failures `F`, the implementation records

\[
  p_L=(1+E)/(B+1),\qquad p_U=(1+E+F)/(B+1).
\]

It creates a point value only when `F=0`. Simulation/identity failure and
bootstrap-refit failure are different stages. If simulation succeeded but the
refit failed, the generated response and design hashes are retained while the
failed statistic remains in the planned denominator.

## Viewed mechanics schema

The frozen schema contains the baseline complete-design exact-zero,
numerical-near-zero, and variance-0.12 reference datasets at outer replicate 2,
all four lme4/glmmTMB ML/REML routes, and `B=3`.

| Quantity | Result |
| --- | ---: |
| observed routes planned/returned | 12 / 12 |
| bootstrap pairs planned/returned | 36 / 36 |
| full/reduced backend fits | 96 |
| available bootstrap statistics | 36 |
| unavailable/failed bootstrap statistics | 0 |
| exact observed-design checks | 36 / 36 |
| generated-response hashes unique | 36 / 36 |
| generated-data hashes unique and distinct from parent | 36 / 36 |
| materially negative raw drops below -1e-6 | 0 |
| small negative raw drops retained | 16 |
| observed routes with a nuisance boundary | 0 / 12 |
| bootstrap pairs with a nuisance boundary | 8 / 36 |

The 12 computational plus-one values were:

| Truth cell | lme4 REML | glmmTMB REML | lme4 ML | glmmTMB ML |
| --- | ---: | ---: | ---: | ---: |
| exact zero | 0.50 | 0.50 | 0.50 | 0.25 |
| numerical near zero | 0.50 | 0.75 | 0.50 | 1.00 |
| variance 0.12 reference | 0.50 | 1.00 | 0.25 | 1.00 |

All failure counts were zero, so lower and upper bounds coincide in this
schema. The grid width is 0.25. These values are deliberately recorded as
mechanics output, not p-value evidence: `B=3`, one viewed outer dataset per
cell, and backend-native unpaired simulations cannot estimate size, power, or
a useful threshold. In particular, the apparent backend and likelihood
differences are not comparisons of calibrated operating characteristics.

The nuisance-boundary count is itself informative. Although no observed route
had a non-target component under the 1e-8 boundary tolerance, eight fitted-null
bootstrap pairs did. A future bootstrap validation must therefore stratify or
otherwise address nuisance-boundary state; completing all refits does not
remove the nonregularity.

## Workload firewall

The next three computations remain separate:

1. resolution-score feasibility: 30 cells x 25 outer replicates x four methods
   = 3,000 diagnostic rows and 6,000 full/reduced fits, without inner
   bootstrap p-values;
2. production-bootstrap method selection and runtime design; and
3. independent outer calibration of size, power, indeterminate rate, failure,
   nuisance-boundary frequency, and Monte Carlo uncertainty.

A naive nested plan with all 3,000 rows and `B=199` would require 1,200,000
backend fits. It is not authorized. Production `B`, outer-cell subset,
checkpointing, and precision targets must follow measured runtime evidence and
a separate mathematical choice between plain, shrinked, or another justified
bootstrap method.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| lme4 | 2.0.6 |
| glmmTMB | 1.1.14 |
| TMB | 1.9.23 |

## Test and artifact evidence

Six focused tests and 75 expectations pass with the explicit 96-fit schema
tier enabled. They cover the three-layer firewall, exact route/seed
accounting, plus-one failure bounds, source/nonclaim text, deterministic
backend-native simulation, factor/design preservation, data-identity
separation, all 12 observed and 36 bootstrap rows, and fail-closed readiness.

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-weak-information-bootstrap-contract-0.2.3.md` | `f0bdfcf73dac6325c4bf8561833a89605863b01089a1049210de3ba0baeb77e1` |
| `gtheory-weak-information-bootstrap-prototype-0.2.3.R` | `ef1f09f2619b827820bbea4ac457a373bd675bee8295125842ab1bc525076e4e` |
| `test-gtheory-weak-information-bootstrap-prototype.R` | `48f939803f803b3897bc40c96a6b463210f8cb9acb71c2986a276aba8e128892` |

The record's own hash is omitted because recording it would change the file.

## Readiness and next gate

`ResolutionFeasibilityAuthorized`,
`BootstrapOperatingCharacteristicsReady`, `FeasibilityEvidenceReady`,
`CalibrationEvidenceReady`, `ThresholdFrozen`, `ConfirmationAuthorized`,
`InferenceReady`, `CoefficientEligible`, and `DecisionReady` remain false.

The next slice must freeze the replacement 3,000-row resolution-feasibility
manifest without inner bootstrap, estimate observed fit runtimes by method and
boundary state, and use those measurements to design a tractable outer
bootstrap calibration. It must not interpret this schema's 12 values as a
threshold search. Positive-component recovery, interval behavior, and D-study
decision stability remain separate gates.
