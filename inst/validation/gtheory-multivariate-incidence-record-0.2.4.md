# Draft.85b0 multivariate G-theory incidence preflight record

Date: 2026-08-24
Scope: repository-only long-form identity and overlap audit
Result: structural incidence preflight passed; estimation remains absent

## Outcome

The future multivariate route now distinguishes a mathematically valid
supplied covariance matrix from data that could support a later covariance
estimator. The new preflight binds ordered strata, globally linked objects,
explicit global-versus-local condition identities, missing-stratum patterns,
direct pairwise overlap, graph connectivity, and canonical data/omission
hashes.

The focused suite passes five tests and 56 expectations without failure,
warning, or skip. No model was fitted, no covariance was estimated, and no
public function, help page, vignette, or NEWS entry changed.

## Positive controls

A balanced two-stratum fixture with four common objects, two common raters,
and two common items passes the incidence gate. Every object has pattern
`A|B`; object overlap is complete; both condition facets are classified
`observed_common`; and row reversal reproduces all scientific hashes.

A rater fixture with one of two levels shared is classified
`observed_partial`. Under global scope its one shared level fails the declared
minimum of two and blocks incidence. Declaring the rater labels
`stratum_local` changes the semantic target rather than the data: the audit
classifies the support as `structurally_disjoint_by_scope` and records the
cross-stratum target as `structural_zero_by_scope`.

## Negative controls

The three-stratum fixture has direct A--B and B--C object overlap but none for
A--C. Its overlap graph is connected, while complete pairwise overlap is
false and the unrestricted A--C covariance is blocked. This prevents graph
connectivity from being promoted to full covariance identification.

The input boundary also rejects:

- incomplete or unknown condition-scope maps;
- undeclared strata;
- missing object, stratum, or condition identities;
- infinite and `NaN` scores; and
- non-integer minimum-overlap controls.

A declared-complete dataset with an omitted score retains the omission hashes
but fails the incidence gate.

## Readiness disposition

`IncidenceReady=TRUE` means only `incidence_ready_for_matched_backend_preflight`.
Every result retains `EstimationReady=FALSE`, `InferenceReady=FALSE`,
`CoefficientEligible=FALSE`, and `DecisionReady=FALSE`.

The next multivariate artifact is Draft.85b1: a typed component/effect map,
observation-pair identity, and exactly matched `lme4`/`glmmTMB` Gaussian
random-slope covariance adapter. Recovery, intervals, D-study stability, and
public support remain later gates.
