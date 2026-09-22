# Draft.83d2b2b1a weak-information diagnostic-refit record

Date: 2026-08-09
Scope: source-audited boundary inference contract and viewed-schema refits
Result: mathematical contract and 24 diagnostic pairs pass; the old
feasibility authorization is superseded and no feasibility seed was generated

## Outcome

Draft.83d2b2b1a corrects the weak-information plan before the authorized
25-replicate feasibility phase is run. The correction is prospective: no seed
in 101--125, 201--300, or 501--700 was generated or viewed.

The historical Draft.83d2b2b0 plan remains reproducible under identity
`427addf42c73047e184857f52e9aa126e6d5eb346ab105827d14b3affef38cbd`,
but its feasibility execution is superseded. The new inference-contract
identity is:

`aac91ac4bddffb14186ecb9e042d40744b42c2fd257a1b85a83037f3aab909bd`.

The contract withdraws `target_relative_se_profiled` and both registered rule
families that require it. lme4's profiled relative-SD coordinate and glmmTMB's
joint log-SD coordinate are retained only as separately labelled validation
diagnostics. They are not component standard errors and cannot share a
threshold.

The raw full/reduced likelihood difference is retained separately for ML and
REML. It has no ordinary one-degree chi-square reference, universal 50:50
mixture reference, p-value, or interval. `RLRsim` is not used because its exact
one-random-effect contract does not equal the present model with five
additional nuisance random components.

## Source audit

The mathematical audit is grounded in Self and Liang (1987), Crainiceanu and
Ruppert (2004), Greven et al. (2008), Scheipl et al. (2008), the lme4 and
glmmTMB computational papers, and current backend/RLRsim documentation. The
local Zotero library contained the Jiang et al. (2020) multivariate G-theory
mixed-model article under three duplicate keys but did not return the boundary
likelihood sources. No Zotero record was changed.

The audit fixes four distinct claims:

1. a nonnegative point estimate is not a test of zero;
2. a zero-component test is not precision or positive-component recovery;
3. a backend-coordinate local quadratic approximation is not a common
   variance-component standard error; and
4. none of the preceding claims establishes D-study decision stability.

The future null-testing route is a custom parametric bootstrap from the fitted
reduced model on the exact observed design, using the same full/reduced backend
pipeline and retaining fit failures in the denominator. It remains separate
from positive-control bias, RMSE, coverage, and D-study stability.

## Viewed-schema execution

Only the already viewed schema datasets at replicates 2--3 were refitted. Each
of 24 method rows contains one full and one reduced fit, for 48 backend fits.
The execution identity is:

`c39180ec3618957b261ff84313f5f770be7e5ecdfbfa383a996160d822f5db2d`.

| Quantity | Result |
| --- | ---: |
| diagnostic pairs planned/returned | 24 / 24 |
| full/reduced backend fits | 48 |
| raw likelihood diagnostics available | 24 |
| backend-coordinate local diagnostics available | 20 |
| small negative raw likelihood drops retained | 4 |
| materially negative drops below -1e-6 | 0 |
| identical row-count checks | 24 / 24 |
| likelihood df differences equal to one | 24 / 24 |
| p-values or intervals produced | 0 |

The four negative values were glmmTMB numerical differences between
approximately -3.6e-7 and -5.7e-7. They are inside the frozen -1e-6 numerical
tolerance and remain in the output rather than being set to zero.

Across the two replicates, the raw likelihood-drop ranges were:

| Truth cell | ML range across backends | REML range across backends |
| --- | ---: | ---: |
| exact zero | 0.163--0.494 | 0.209--0.546 |
| numerical near zero | approximately 0--1.280 | approximately 0--1.504 |
| variance 0.12 reference | approximately 0--4.342 | approximately 0--4.896 |

These are six viewed datasets, not operating-characteristic estimates. The
exact-zero and positive-cell score overlap is itself a schema warning against
selecting a likelihood threshold from these results.

All eight exact-zero fits estimated a positive target component under the
1e-8 boundary tolerance and supplied a local coordinate diagnostic. By
contrast, one near-zero dataset and one positive-reference dataset reached the
lme4 target boundary under ML and REML; their profiled Hessians were
unavailable, giving four explicitly missing local diagnostics. glmmTMB returned
finite log-SD scales for these fits, but some local scales exceeded 900. This
does not make glmmTMB boundary inference regular: scientific zero is at
log-SD minus infinity.

The schema therefore demonstrates why “a local scale was computed,” “the
estimated variance is positive,” and “the component is resolved” must remain
different states.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| testthat | 3.3.2 |
| digest | 0.6.39 |
| lme4 | 2.0.6 |
| glmmTMB | 1.1.14 |
| TMB | 1.9.23 |
| Matrix | 1.7.6 |
| reformulas | 0.4.4 |
| Platform | aarch64-apple-darwin23 |

## Test and artifact evidence

Six focused tests and 64 expectations pass when the explicit schema tier is
enabled. They cover the source claims, superseding rule state, exact reduced
formula, named lme4 coordinate mapping, fitted glmmTMB parameter mapping, raw
ML/REML likelihood identities, all 24 schema rows, and fail-closed readiness.

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-weak-information-inference-audit-0.2.3.md` | `fdab895ae7aff8c83119ecaa48f2caa3c8523a1812d194358a4ee1feec576765` |
| `gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R` | `12c65b56d57f3da315136342adeea7ab60a0262ef6b0c255679693cb7689e051` |
| `test-gtheory-weak-information-diagnostic-refit-prototype.R` | `ae353fb8261a8b1a683e5ee9cf36d7718fa49be225047b4755f7fa726378f227` |

The record's own hash is omitted because recording it would change the file.

## Readiness and next gate

`FeasibilityEvidenceReady`, `CalibrationEvidenceReady`, `ThresholdFrozen`,
`ConfirmationAuthorized`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` remain false.

The next specification must replace, rather than execute, the historical
feasibility manifest. It must first register the exact null-bootstrap
simulation/refit unit, number of bootstrap draws, Monte Carlo uncertainty,
failure denominator, nuisance-boundary handling, and ML/REML/backend scope. A
small viewed bootstrap-schema tier may validate mechanics. Only then may a new
25-replicate feasibility identity be authorized. Positive-control recovery and
D-study stability must remain co-primary checks so that a rule cannot appear
successful merely by blocking every component.
