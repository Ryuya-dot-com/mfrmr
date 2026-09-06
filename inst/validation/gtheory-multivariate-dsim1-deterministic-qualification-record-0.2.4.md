# D-SIM-1 v4 deterministic qualification record

Status: 7/7 deterministic criteria pass; D-SIM-2 subsequently completed
Date: 2026-08-30
Qualification: `MFRMR-GTHEORY-MV-DSIM1-DETERMINISTIC-V1`
Parent D-SIM-0 hash: `9b68d194e13625ec73992f314a9494e29c36f77838e0da19a15020f2af74a214`
Qualification hash: `6fd89f49fe6238a56bb5621fa07cfb2f7ddb4aba4d3323b69246a99620b937db`

## Scope

D-SIM-1 integrates existing independent algebra and incidence foundations into
the v4 package-capability roadmap. It creates deterministic structural
fixtures only. It does not generate a stochastic response, fit a model, open a
planned seed, estimate a Monte Carlo operating characteristic, or change
public support.

Five canonical designs are registered:

1. `U1-CLOSURE`: one-stratum reduction to the documented univariate formulas;
2. `S2-DISJOINT-DISTINCT`: disjoint conditions and distinct observation events;
3. `S2-SHARED-LINKED`: shared conditions and one event yielding linked scores;
4. `S3-PARTIAL-MIXED`: partial incidence with an explicit mixed event map; and
5. `S2-DISCONNECTED-NEGATIVE`: structural nonidentification control.

These are grammar anchors and controls, not a claim that five scenarios cover
the full 14-axis D-SIM-0 multiverse.

## Deterministic evidence

All seven registered criteria pass:

| Criterion | Evidence rows | Result |
|---|---:|---|
| deterministic algebra | 5 | pass |
| univariate closure | 4 | pass |
| label invariance | 5 | pass |
| PSD validity | 2 | pass |
| incidence identity | 4 | pass |
| observation-event identity | 3 | pass |
| backend eligibility | 20 | pass |

The table contains 43 criterion-to-evidence assignments. Because the four
univariate-closure checks are also a subset of the five deterministic-algebra
checks, the underlying evidence tables contain 39 unique rows. Both counts are
reported explicitly by the qualification result.

The one-stratum fixture independently reconstructs universe variance 1.2,
relative error `0.6 / 4`, absolute error `0.6 / 4 + 0.3 / 2`,
`G = 1.2 / 1.35`, and `Phi = 1.2 / 1.5`. A package-loaded regression test also
matches these coefficients to `mfrm_d_study()` under the corresponding two
items by two replicates design. Relabeling the two-stratum fixture preserves
all quadratic variances and both coefficients. A rank-deficient PSD matrix is
accepted and an indefinite negative control is rejected.

The incidence audit accepts the disjoint/local, shared/global, and
partial-explicit anchors and rejects the disconnected object graph. Event maps
are classified independently as distinct, one-event/multiple-score, or mixed.

## Backend boundary

The 20 design-by-route rows retain these distinctions:

- the public univariate formula is the closure oracle or a nonpooling
  comparator, never a cross-stratum covariance estimator;
- `glmmTMB` is only a conditional candidate for standard diagonal or linked
  event representations;
- `lme4` is a conditional sensitivity for distinct-event diagonal residuals
  and is ineligible when linked scores require correlated level-1 residuals;
- explicit masks require a separate custom covariance contract; and
- the disconnected design is rejected by every route.

Every row retains `ExecutionAllowed = FALSE` and `PublicSupportReady = FALSE`.

## Transition

`Dsim1Satisfied = TRUE` and `Dsim2Allowed = TRUE`. D-SIM-2 was limited to one
nonreserved fixture through generator, fit, metric, and terminal-state
plumbing and subsequently completed that bounded route. It opened no planned
RNG stream and produced no simulation-validation or public-support evidence.
The overall feature maturity remains `specified`; only the narrow internal
plumbing route is implemented. D-SIM-3 subsequently froze 21 outcome-blind
design cells covering 44/44 declared levels and 603/603 feasible dataset-axis
pairs. Its later execution contract froze 42 dataset attempts, 210 route units,
and 420 nonvoting coordinates without opening the 855 seed band. Exploratory
execution still needs a shared full-profile semantic substrate, as the
subsequent pre-execution qualification audit established.
