# JML joint-cone attribution pilot record for mfrmr 0.2.3

Status: repository-only draft.52 calibration evidence, 2026-08-05. This is a
one-replicate PCM/JML computation and cone-attribution study. It changes no
statistical estimator, boundary classification, readiness rule, public API,
public roadmap, or release criterion; authorizes no confirmation; and makes no
FACETS, TAM, immer, JML, or MML superiority claim.

## Change-local question

Draft.51 removed redundant Person-fixed structural target enumeration. The
joint Person-structural audit then became the largest selected JML phase. Its
global cone screen was already present, but its positive branch had not been
separated into cone, target, and certified-target work.

Draft.52 asks three narrower questions:

1. Which fixed routes enter the positive joint-cone branch, and how much LP
   work follows?
2. Does the certified global direction move any selected structural or
   constraint-coupled Person target, or only ordinary free extreme Persons
   already typed by the sufficient-score audit?
3. Can profiling those already typed Person boundaries out produce a useful
   change-local hypothesis without prematurely changing the production audit?

The answer to question 3 is diagnostic only. A quotient-cone result is not a
proof that target enumeration can yet be skipped.

## Fixed 19-route phase rerun

The Draft.50 seven-cell/19-route manifest was rerun as phase schema v6 against
the same installed guarded Draft.51 runtime, data, seeds, 60-iteration ceiling,
seven quadrature points, and `1e-9` relative tolerance. Schema v6 adds joint
prescreen state, cone and target LP calls, evaluated target directions,
certified target directions, and a fail-closed per-route work contract.

All 19 fits succeeded, all 12 JML work contracts passed, ten routes were
inference-ready, and the forced-extreme false-ready count remained zero. Every
semantic-result hash, fit-readiness state, inference-ready flag, numerical
state, boundary state, optimizer method, structural audit state/completeness,
and joint audit state/completeness is identical between v5 and v6.

| Joint branch | JML routes | Phase time | Cone LP calls | Target directions / LP calls | Certified target directions |
| --- | ---: | ---: | ---: | ---: | ---: |
| negative cone | 7 | 13.53 s | 7 | 0 / 0 | 0 |
| positive cone | 5 | 48.99 s | 10 | 346 / 346 | 0 |
| total | 12 | 62.52 s | 17 | 346 / 346 | 0 |

The five positive routes are the automatic and BFGS R12 routes, automatic
C12-E02, and the automatic and BFGS forced-extreme P200-X20 routes. Positive
routes consume 78.36% of the measured joint phase. Every positive cone starts
the complete selected-target enumeration, but all 346 requested directions
end at the first capacity LP with no target-specific certificate.

This establishes workload concentration; by itself it does not explain the
cone or justify a shortcut.

## Cone-to-target attribution

The repository-only
`jml-joint-cone-attribution-pilot-0.2.3.R` re-fits one automatic-JML route for
each distinct positive-cone data cell: R12, C12-E02, and P200-X20. It projects
the stored cone direction through the full expanded target Jacobian, retains
the complete Person-boundary table, and marks which targets were selected by
the production joint audit.

| Data cell | Ordinary free extreme Persons | Nonzero cone Person coordinates | Nonzero structural coordinates | Selected targets | Selected nonzero projections | Target LP calls / certificates |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| R12 | 1 | 1 | 0 | 32 | 0 | 64 / 0 |
| C12-E02 | 2 | 2 | 0 | 63 | 0 | 126 / 0 |
| P200-X20 | 40 | 40 | 0 | 23 | 0 | 46 / 0 |
| total | 43 | 43 | 0 | 118 | 0 | 236 / 0 |

Across all three cells, the set of nonzero expanded-target projections is
exactly the set of ordinary free extreme Persons already classified
`unbounded_low` or `unbounded_high` by the sufficient-score audit. The cone
moves no Rater, Criterion, step, interaction, constraint-coupled extreme
Person, or other selected target. The production target enumeration agrees:
all 236 distinct-cell target directions are negative.

This is a responsibility overlap, not an observed false-readiness defect.
The readiness aggregator already checks whether all joint cone loadings are
Persons typed as ordinary unbounded boundaries. In that case it treats the
joint cone as independent confirmation rather than a new unpropagated
candidate. The v5-to-v6 readiness invariance confirms that guard. The remaining
problems are the misleadingly broad global `certified_recession` state and the
cost of proving 236 or 346 selected directions negative after a known Person-
only ray activates enumeration.

## Diagnostic quotient

For attribution only, the runner constructs a quotient contrast problem by
removing both:

- every ordinary free extreme Person coordinate; and
- every contrast row belonging to those Persons.

Removing only the coordinates would be wrong: an ordinary unconstrained high
or low extreme Person can move in its sufficient-score boundary direction to
compensate its own rows for a retained structural direction. The row-and-
coordinate quotient profiles that already typed one-sided boundary out rather
than fixing it at zero.

The quotient global cone is evaluated with the guarded Draft.51 tolerances
(`1e-10` objective and `1e-7` certificate). It is evaluated and negative with
capacity zero in all three cells. The three original joint phases total 30.16
seconds in this diagnostic refit; the three quotient cone calls total 0.56
seconds. These are one-run, non-equivalent workloads and do not freeze a speed
claim or authorize replacing the audit.

## Adversarial proof boundary

A negative quotient strict cone is necessary evidence but is not sufficient
for a safe enumeration skip. If a retained direction changes a selected target
while leaving every retained contrast exactly zero, an independent excluded
Person boundary ray can supply the strict likelihood improvement in the full
cone. A quotient objective based only on summed retained margins would then be
zero even though the selected target has a flat direction.

The next implementation must therefore compose three geometries rather than
silently substituting one for another:

1. sufficient-score Person boundaries, including the exact distinction among
   free, fixed, and constraint-coupled extreme Persons;
2. retained-target nullspace/estimability, including whether the selected
   target expansion annihilates every quotient-null direction; and
3. strictly improving quotient recession directions.

A safe negative fast path requires both a negative quotient strict cone and a
target-nullspace exclusion under guarded rank tolerances. If either part is
unevaluated, near tolerance, constraint-coupled, or target-changing, the audit
must fail closed or retain the current target enumeration. Ordinary nonextreme
Persons and constraint-coupled extreme Persons must remain in the joint
geometry.

Positive controls must include the existing group-constrained two-Person/two-
Item fixture, in which the relevant joint direction requires both blocks, plus
a new target-changing flat-direction counterexample. Required metamorphic
controls remain sparse/dense, row order, retained rows, anchors, interactions,
RSM/PCM, size limits, injected solver failure, and MML non-reduction. Bounded
GPCM needs a separate statement because its additive audit is conditional on
the fitted positive slope while nonlinear paths remain incomplete.

Only after this semantic decomposition passes should reusable LP models, warm
starts, or alternative solvers be benchmarked. Solver acceleration cannot
repair a duplicated or incorrectly scoped estimand.

## Verification boundary

Both new validation runners parse under R 4.5.1. The joint recession audit
suite, including positive, negative, size-limit, and MML work-counter controls,
and the phase-timing suite pass. The authoritative v6 and attribution-v1 live
runs also pass their own fail-closed completion contracts.

An additional full package-aware `testthat` run was attempted after the local
tests, but did not finish within the 10-minute tool limit and was terminated
with exit code 124 before a summary was emitted. No failed test was reported,
but this is not recorded as a full-suite pass. Draft.51 remains the latest
complete 127-file and exact-tarball check claim. Because Draft.52 changes
repository-only instrumentation, tests, and internal records rather than the
installed core, the incomplete extra run does not alter the v6 semantic-
equivalence evidence; it remains open verification work rather than being
silently promoted.

## Evidence integrity

The authoritative phase bundle is outside the package source tree at
`mfrmr/jml-phase-profile-20260805-v6`. The authoritative attribution bundle is
at `mfrmr/jml-joint-cone-attribution-20260805-v1`. Both were promoted from
incomplete staging directories only after their completion invariants passed.
The attribution marker independently matches all 11 pre-marker artifacts and
all three route contracts.

### Phase v6 identity

| Field | SHA-256 |
| --- | --- |
| Selected 19-route manifest | `f84c2a6bdc0c0de11fdff0521a1cf81b76482cf6cdf41ce38118c590f85c1d87` |
| Loaded guarded Draft.51 runtime | `cbfc1adefe35d7c9bef42717c8c5650bae109fa43bd9ed8fcee10f81683a2758` |
| Phase runner | `d95ab5579ea0bd4d734525b272bcff5351c335ccd83e273fd75c6ed91760e7c4` |
| Runner composite | `63f8615b6cf2a1560a7c7ce3aa82c1a57c0a87cb9eeeb3fd3593e7a18692b903` |
| Instrumentation contract | `8880843b55b3fdff522197cc51181d3e2401174a325f17f2744f4bf02364ac2c` |
| Execution identity | `bb37672ab52645edfdc009b4f70da04ae7b61280d08f85669376123306b5ecf4` |
| Result CSV | `441c56782673669dff97cd189c885b80c7c11c642b54c388fe971362c9ef0e9d` |
| Phase timing CSV | `7464a696c730c040d48263056baaff6ed6ba7b677eddc468cff578b00e929e38` |
| Phase summary CSV | `86fd82eb9aefb5f9327205a9aa055735e0c96a0d25c0de8dde324faa202bb879` |
| Completion marker file | `0a46d5828589979576553f66f61d36195e385952b53cf1aadf4933e04dda553d` |

### Attribution v1 identity

| Field | SHA-256 |
| --- | --- |
| Three-cell manifest | `841bef5532619fca14d5169a87df92a06f258fc3824c865574640b3ecb55f776` |
| Loaded guarded Draft.51 runtime | `cbfc1adefe35d7c9bef42717c8c5650bae109fa43bd9ed8fcee10f81683a2758` |
| Attribution runner | `283bb925dbac3b7ea518e161bfcc73f699bb9d9d716c5e68a6020e397a923b00` |
| Runner composite | `9a6778c71db5037e6d6eb4f80cac9fda06d63a78ad7591ee81e62dd93c8bad2e` |
| Execution identity | `26c8c85902d916f32a75efcc5857c69a7453bad3ecb92a4b1c703184c9752f13` |
| Artifact inventory | `42c21397f6edc09280c476495a42c35bc1487cdf111c7919e13eef0d61abd74a` |
| Result CSV | `2fdd06a4ed476d6ee683eb208cb6e9ad1cce565c304e2122a36bceafe9c2c9a7` |
| Cone loadings CSV | `1e65cae1d4ffa20ed17ff4fa53bdea8801e8884224c11f960f047d7ae3717ce4` |
| Target projections CSV | `85a3f3e56277efad6e9a63ed5c5a13db6ae59273dccf8280ebe42a1bdf5ec7c2` |
| Person status CSV | `ba2457047c198a321c0089c9aa69697d0a8e0730e92fc324e6dc0456c9eb2faf` |
| Run summary CSV | `52e7e484c7919b52010e23791c4d6d172dccce41556a7deb6cafaee60a27fdef` |
| Completion marker file | `26fc42503a269f28782ebb06b815982e590ce82b2effcbbda75fa513d76bb44b` |

The attribution runner and both records remain excluded from the public source
artifact by the repository packaging policy. Public `ROADMAP.md` and `NEWS.md`
are unchanged. Full `--as-cran`, candidate-linked, external, replicated,
recovery, precision, and confirmation gates remain open.
