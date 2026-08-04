# mfrmr 0.2.3 internal readiness contract

Status: `WP0-READINESS-CONTRACT` structural contract, 2026-08-03.

Contract version: `mfrmr-readiness-0.2.3-v2`.

This is a repository-only maintainer contract. It freezes the vocabulary and
derivation rules that WP1--WP5 must implement. It is not a public API promise,
does not itself change fitting behavior, and provides no evidence that a
statistical release gate has passed.

## Decision summary

Readiness is not one Boolean. The 0.2.3 implementation has three scopes:

1. a fit record says whether the fitted statistical system is usable at all;
2. a parameter record says which displayed or fixed coordinates are
   estimable, fixed, weak, unbounded, aliased, unsupported, or absent; and
3. a comparison record decides eligibility separately for each external
   metric and parameter class.

The existing `InferenceReady` field is retained only as a conservative first-
screen compatibility value. It is `TRUE` only when `FitReadiness == "ready"`.
It is `FALSE` for `ready_with_exclusions`, `review`, `blocked`, and
`legacy_unknown`. This deliberately prevents an old Boolean consumer from
treating a partial, uncertain, failed, or unaudited result as wholly ready.
New code must use the scoped records rather than discarding all otherwise
estimable facet parameters merely because one JML Person is unbounded.

## Why the current implementation is insufficient

The pre-WP0 source inventory found five independent interpretations:

| Surface | Current source | Current meaning | Correction owner |
| --- | --- | --- | --- |
| Fit scalar | `mfrm_estimate()` summary record | optimizer convergence severity only | WP4 |
| Fit review | `build_mfrm_data_review()` and `summary.mfrm_fit()` | preparation notes, graph linkage, simple stability, diagnostics, and reporting recombined at display time | WP1--WP4 |
| Parameter output | parameter tables and JML extreme flags | finite values and ad hoc flags without one status vocabulary | WP2--WP4 |
| External comparison | FACETS/ConQuest pilots and normalizers | scalar readiness plus adapter-specific filters | WP5 |
| Plot/report/export | plotting, report, bundle, and replay helpers | several consumers reconstruct readiness from partial fields | WP4 |

The current graph review is useful as a screen, but it is not the constrained
free-parameter rank audit. A connected graph can still contain an exact alias.
A globally consecutive category range is also not proof that every PCM
`step_facet` ladder has estimable coordinates. Finally, optimizer-dependent
large finite JML values are not a substitute for typed unbounded states.

## Normative fit record

Every newly fitted 0.2.3 object will eventually store one immutable readiness
record with at least:

```text
ReadinessContractVersion
ReadinessScope = "fit"
InputState
EstimabilityState
CategoryState
BoundaryState
NumericalState
FitReadiness
InferenceReady
ReasonCodes
AuditProvenance
```

`AuditProvenance` must identify the contract version and the estimator/model
parameter map used by the audit. Later implementation may add fields without
changing the meaning of the frozen fields. Formatting code may not recompute
or improve these states.

### Component states

| Field | Allowed states | Meaning |
| --- | --- | --- |
| `InputState` | `pass`, `review`, `blocked`, `legacy_unknown` | semantic/input validity, including unmodelled repeated-cell dependence |
| `EstimabilityState` | `identified`, `population_assumption_linked`, `weak_information`, `structurally_unidentified`, `not_evaluated`, `legacy_unknown` | estimator-specific structural and fitted-information result |
| `CategoryState` | `adequate`, `weak_information`, `unsupported_coordinate`, `not_applicable`, `not_evaluated`, `legacy_unknown` | model- and scale-scope category/step support |
| `BoundaryState` | `finite`, `has_exclusions`, `not_applicable`, `not_evaluated`, `legacy_unknown` | aggregate presence of typed parameter exclusions |
| `NumericalState` | `ready`, `review`, `failed`, `not_run`, `legacy_unknown` | terminal numerical assessment, never a statistical override |

`population_assumption_linked` is specific to a marginal model whose rater or
panel linkage rests on a common latent-population assumption rather than
shared Persons. It is not interchangeable with JML identification and cannot
be silently labelled `identified`.

### Derived `FitReadiness`

The derivation is deterministic and follows this precedence:

1. `blocked` if input is blocked, the fitted parameterization is structurally
   unidentified, a free category/step coordinate is unsupported, or numerical
   optimization failed or was correctly not run after a pre-fit blocker;
2. `legacy_unknown` if no blocker is present but any component lacks a current
   contract because the object predates it;
3. `review` if no worse state is present but input, population linkage, weak
   information, an unevaluated audit, or numerical diagnostics require review;
4. `ready_with_exclusions` if all other components pass and one or more typed
   parameter boundaries are excluded; otherwise
5. `ready`.

This order is intentionally conservative. Known, localized boundary
exclusions do not erase an unresolved weak-information review; equally, a
successful optimizer cannot improve a structural or category blocker.
Multiple `ReasonCodes` are retained even though one first-screen state is
shown.

## Normative parameter record

Every coordinate that can be printed, exported, fixed, anchored, or compared
must resolve to one parameter row. A row contains its stable element and
coordinate identity, parameter class, primary value where defined, status,
reason codes, and the contract/audit identity.

| `ParameterStatus` | Primary value rule | Comparison default |
| --- | --- | --- |
| `estimable` | finite estimate with applicable uncertainty fields | may be eligible |
| `fixed` | declared fixed/anchor value, identified as fixed rather than estimated | only fixed-value or constraint comparisons |
| `weak_information` | finite value retained with explicit review status | ineligible for blocking recovery until a frozen weak-information rule permits it |
| `unbounded_low` | primary estimate is negative infinity or an explicit typed boundary, never an optimizer proxy | ineligible for ordinary numeric MAE/RMSE |
| `unbounded_high` | primary estimate is positive infinity or an explicit typed boundary, never an optimizer proxy | ineligible for ordinary numeric MAE/RMSE |
| `unbounded_both` | certified paths approach both boundaries, so no unique scalar primary estimate exists | ineligible for ordinary numeric MAE/RMSE |
| `aliased` | no unique primary estimate | ineligible |
| `unsupported` | no data-estimated coordinate | ineligible |
| `not_estimated` | coordinate not part of this fitted contract | not applicable or ineligible as specified by the metric |
| `not_evaluated` | an applicable parameter-level audit is incomplete; an optimizer value may be retained only as a numerical trace | ineligible |
| `legacy_unknown` | preserve legacy display only; do not infer current status | ineligible |

Boundary logic is estimator-specific. An unanchored extreme JML element can be
unbounded. An anchored extreme element is `fixed`. An MML/EAP Person can be a
finite population/prior-regularized estimate and is not relabelled as JML-
unbounded merely because its raw response pattern is extreme. Response
extremity alone does not downgrade an MML parameter: precision and recovery
evidence determine whether it is `estimable` or `weak_information`.

A fit with localized `unbounded_low` or `unbounded_high` rows can be
`ready_with_exclusions`. Estimable non-Person facets remain explicitly
available; the legacy scalar remains `FALSE` so old consumers cannot omit the
exclusion silently.

## Normative comparison record

External comparison is a property of a named metric and parameter class, not
of an executable run as a whole. Each expected metric has one row with:

```text
ReadinessScope = "comparison"
Comparator and version identity
Scenario and metric identity
Parameter class and expected denominator
ComparisonEligibility
ReasonCodes
Expected, eligible, rejected, missing, and failed counts
Normalization/coordinate-transform identity
```

Allowed eligibility states are `eligible`, `ineligible`, `missing`, `failed`,
and `not_applicable`. `missing` means an expected result is absent; `failed`
means the external execution or parser failed. Neither is converted to an
ordinary rejection or removed from a denominator.

Eligibility must fail closed on response-family, estimator, observation-set,
weight, active-facet, orientation, category-map, retained/free step dimension,
anchor/constraint, coordinate-transform, parameter-status, and extreme-
convention mismatches. Thus one scenario may permit nonextreme Person MAE
while rejecting extreme Person MAE and PCM step MAE. FACETS 4.5.0 is an
independent comparator, not the truth source for mfrmr's estimand.

## Stable reason-code policy

The controlled catalog is defined by
`mfrmr_readiness_reason_codes()` in `readiness-contract-0.2.3.R`. Codes are
lower-case snake case, append-only within contract v2, and scoped to fit,
parameter, comparison, or an explicit combination. Display prose may be
translated; stored codes may not be translated, concatenated into an
unparseable message, or replaced by optimizer text.

Draft.37 appends `boundary_candidate_not_propagated`,
`boundary_audit_incomplete`, and `optimizer_review_required`. The first two
prevent a positive but not yet primary-value-propagated recession candidate,
or an incomplete applicable boundary audit, from being labelled finite. The
third distinguishes a general optimizer review from the narrower terminal-
gradient and iteration-limit causes.

A consumer must retain all causal codes. It may choose one first-screen state
using the frozen precedence, but cannot retain only the most severe reason.
New semantics require a new code. A spelling change or changed meaning
requires a new readiness contract version. Contract v2 adds the GPCM-specific
one-sided, two-sided, estimator-specific unevaluated, and fixed-unit-slope
states needed to keep conditional JML path evidence separate from joint JML
and marginal MML claims.

## Condition and runtime policy

Future runtime conditions inherit from `mfrmr_readiness_condition`. The class
registry is fixed by `mfrmr_readiness_condition_classes()`.

- invalid input, exact structural nonidentification, and unsupported free
  category/step coordinates stop before optimization with a typed error and a
  structured preflight readiness payload;
- boundary exclusions remain on a partial fit and warn at first inferential
  use rather than preventing inspection of all estimable coordinates;
- numerical review/failure remains stored on the returned diagnostic fit and
  cannot be upgraded by print, plot, export, or replay code; and
- legacy objects warn at inferential use and remain `legacy_unknown` unless an
  explicit re-audit or refit creates a new provenance-bearing record.

Stopping before fit is not permission to lose the audit. The error condition
must carry component states, reason codes, affected coordinates, and audit
provenance so tests and applications can inspect the failure programmatically.
No public `allow_unidentified = TRUE` bypass is introduced in 0.2.3.

## Legacy-object migration

A saved object without `ReadinessContractVersion` is never upgraded from its
old `InferenceReady` value. Whether that scalar was `TRUE`, `FALSE`, or absent,
the compatibility adapter returns:

```text
FitReadiness = "legacy_unknown"
InferenceReady = FALSE
ReasonCode = "legacy_contract_missing"
```

Legacy estimates may still be displayed as legacy descriptive values. They
cannot enter a 0.2.3 blocking recovery result, external agreement aggregate,
or manuscript-ready export. Explicit re-audit is permitted only if all data,
model, parameterization, constraints, weights, and estimator provenance needed
by the current contract are present. Otherwise a refit is required. Re-audit
and refit produce new records; they do not mutate historical evidence.

## Adversarial fixture registry

`readiness-contract-fixtures-0.2.3.csv` is the machine-readable WP0 registry.
It contains positive and negative fit, parameter, migration, and external-
comparison expectations. The minimum controls include:

- balanced JML and MML fits;
- duplicate-cell dependence review;
- two-rater zero-common-Person JML nonidentification versus MML population-
  assumption linkage;
- disconnected design;
- unsupported and rare PCM steps plus locally absent RSM categories;
- generalized JML unbounded, anchored-extreme, and MML/EAP extreme behavior;
- weak links, iteration limit, and optimizer failure;
- a saved 0.2.2 object without the contract; and
- FACETS category/step-dimension, constraint, and extreme-display mismatches,
  plus eligible, missing, and failed external metrics.

The repository-only validator checks vocabulary, derivation, scalar mapping,
reason scopes, unique target keys, required scenarios, and schema version. WP1
through WP5 must turn the relevant expectations into failing-before and
passing-after runtime tests. Editing an expected state after observing a
runtime result requires a recorded contract revision; runtime output is not
allowed to define its own expected answer.

## Non-goals and downstream sequence

WP0 does not claim that current package code produces these records. It does
not freeze weak-information numeric thresholds, external agreement tolerances,
FACETS parity, or supported sparse-design scale. It also does not add multiple
observed scales, mixed response families, threshold anchors, frozen
calibration, or within-cell dependence models.

Implementation order remains:

```text
WP1 constrained estimability
WP2 category and step support
WP3 JML boundary states
WP4 one-source propagation and legacy migration
WP5 metric-specific comparison eligibility
WP6 invariance and sparse performance
WP7 new-seed FACETS 4.5.0 repilot and gate freeze
```

No new FACETS tolerance is calibrated until WP1--WP6 satisfy this contract.
