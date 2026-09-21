# D-SIM-3 v4 separate-univariate semantics audit record

Status: upstream truth/estimand revision required before the execution bridge
Date: 2026-08-31
Scope: internal validation only; no public support promotion

## Decision

Do not implement the 42 `separate_univariate` candidate route units against
the current D-SIM-3 truth binding. The backend is no longer the principal
blocker. `lme4` with REML can be frozen as the nonpooling comparator, but two
upstream semantic problems must be corrected first:

1. in nested profiles, generated `Rater` and `Object:Rater` effects induce the
   same grouping partition while the truth registry assigns them different
   error roles; and
2. in partially crossed and nested profiles, the existing global-condition
   allocation operator does not represent the registered number of conditions
   sampled for each object.

The current disposition is
`no_go_truth_estimand_and_incidence_operator_revision_required`.

## Frozen audit identity

| field | value |
|---|---|
| contract | `MFRMR-GTHEORY-MV-DSIM3-SEPARATE-UNIVARIATE-SEMANTICS-V1` |
| contract hash | `ed0eda8a02cd4ea4dc46084f56f6683ac967da0705c08e8fb4f804cf6ed94adf` |
| manifest hash | `815d29f76640f2886b572ffda418582a02135d51cd50dadbab5ff6e4308bbb2f` |
| audit source SHA-256 | `6348356bd2222802edeee5a1a883f16abd30ad07d5043d94086a39820f00dc35` |
| parent unopened execution plan | `b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7` |
| parent compiler contract | `67cb6077c0b0fb083362c0b7bae498be6695e61a0f84d1636f992479ef79f666` |
| parent binding contract | `293dd2af3e8f13282ae545efa6063306f4cf59d4d7bf1027dca57de9376ae1c4` |

## Denominator-preserving result

| audit unit | total | currently semantic-ready |
|---|---:|---:|
| scenario profiles | 21 | 10 |
| separate-univariate route units | 42 | 20 |
| per-stratum fit partitions | 94 | 42 |
| readiness gates | 10 | 5 |

The 10 currently coherent profiles are the fully crossed profiles. Five
partially crossed profiles have recoverable current truth roles but require an
incidence-aware prospective allocation operator. Six nested profiles require a
truth-model revision before either G or Phi recovery can be judged. Partial
execution is not authorized, and all rows remain in their frozen denominators.

## Backend and output semantics now frozen

- Backend: `lme4`.
- Estimation criterion: REML.
- Gaussian responses: model-matched linear mixed-model comparator.
- Heavy-tailed responses: Gaussian working-likelihood robustness stress.
- Ordinal aggregates: continuous-score working approximation, not an ordinal
  response-model support claim.
- One fit is performed per registered stratum. The route coordinate carries a
  named vector of per-stratum G or Phi values.
- No scalar pooling, cross-stratum covariance recovery, independent-dataset
  count, or cross-route vote is permitted.
- A recovery pass is conjunctive over every registered stratum.

These semantics only resolve what a future request would mean. No exact
backend request has been compiled or authorized.

## Component identification rule

For fully and partially crossed profiles, the prospective per-stratum model
uses object and condition random intercepts. With registered repeats it also
uses an Object-by-Condition random intercept; without repeats that interaction
and the event residual are intentionally represented by one combined residual.
Both unseparated terms have the same relative-error role, so G/Phi remain
coefficient-identifiable in principle.

Nested profiles differ. Their `ConditionId` contains `ObjectId`, so the
generated condition partition and generated Object-by-Condition partition are
one-to-one aliases. The current generator then labels the former
`absolute_only` and the latter `relative_error`. No estimator or backend can
recover that decomposition from the response data. A convergence result would
therefore not repair the estimand.

The replacement truth contract must collapse this duplicated nested partition
and assign the combined nested-condition variance to relative error (and hence
also to absolute error). It must not preserve two differently labelled
variance components merely to keep the current four-component table shape.

## Prospective allocation rule

The D-study target is defined from the registered structural assignments,
before structural or stochastic missingness. Within each stratum:

1. give equal weight to the registered conditions for each object;
2. form that object's condition-weight outer product; and
3. average the result over registered objects.

For the scalar separate-univariate diagonal this gives the average of
`1 / conditions-per-object`. It equals the existing global-condition operator
for fully crossed profiles. In partially crossed profiles the existing
operator is too small by a factor of two. In nested profiles it is too small by
the number of registered objects in the stratum. Observed post-missingness
counts must not silently redefine the prospective allocation.

## Why this precedes the worker

Writing a fit worker now would optimize the executable surface while leaving
the scientific target internally inconsistent. The audit therefore moves the
next task upstream. The frozen 855 plan remains unopened and unchanged; it is
evidence of what was planned, not a contract that must be preserved after a
semantic defect is found.

## Ordered next work

1. Issue a design-dependent truth-component contract that removes the nested
   alias with incompatible error roles.
2. Implement and independently oracle-test the object-incidence-averaged
   prospective allocation operator.
3. Issue new binding and unopened execution-plan identities that supersede,
   rather than mutate, the current hashes while retaining every denominator.
4. Only then implement the identity-bound lme4/REML stratum worker and vector
   G/Phi adapter, and qualify them on nonreserved shadow fixtures.
5. Re-run launch-readiness reconciliation before reconsidering the 855 band.

No RNG initialization, response generation, backend call, fit, empirical
metric, or reserved exploratory execution occurred in this audit.
