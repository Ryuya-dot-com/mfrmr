# JML target-scale positive-cone pilot record for mfrmr 0.2.3

## Decision

Draft.59 does not qualify L1 row normalization at target scale and does not
reopen solver selection. It identifies a more fundamental release-spine issue:
the current two-second native `lpSolve` limit can change additive JML recession
classification across repeated executions of the same large sparse RSM
geometry.

All 64 raw/normalized and `lpSolve`/GLPK comparison rows fail closed safely.
Only 61 preserve the stronger internal provenance relation between the raw
capacity solve and the complete target result. Target-scale normalization is
not qualified, no production need for normalization is observed, and solver
dispatch remains unchanged. `NativeTimeoutInstabilityObserved` and
`RecessionReplayInvestigationRequired` are true. Production change, solver-
branch continuation, runtime-criterion freeze, and confirmation remain false.

This result changes the next priority from solver replacement to deterministic
replay of the existing production recession audit. It does not change public
APIs, fitted schemas, readiness decisions, dependencies, or claims.

## Matched target-scale design

The runner uses three 400-Person designs. RSM and bounded GPCM share one seed,
the exact Person-by-Rater-by-Criterion row order, and the complete exposure
distribution within each design. Response hashes must differ so a shared
topology cannot be produced by relabelling one response vector.

| Design | Rows | Raters | Criteria | Rater exposure | Common Persons |
| --- | ---: | ---: | ---: | --- | ---: |
| complete balanced | 4,800 | 3 | 4 | 1,600 each | 400 |
| sparse balanced | 10,080 | 12 | 12 | 840 each | 40 |
| sparse random | 10,080 | 12 | 12 | 780--900; CV 0.0558 | 40 |

All three RSM/GPCM pairs pass exact topology and exposure hashes, have distinct
response hashes, remain connected, and have zero Rater pairs without a common
Person. This isolates response-model and response-realization differences from
the principal assignment and exposure structure.

Each route runs one ordinary JML fit and one capture JML fit. The capture
wrapper invokes the production function first, returns its result unchanged,
then records the exact LP base, target, tolerances, and result. Both fits
produce fitted objects on all six routes, although all remain blocked under
the fixed optimizer/iteration and boundary contracts. These are numerical
reliability cells, not evidence of statistical adequacy.

## Fit replay result

Five of six ordinary/capture pairs have identical semantic, readiness, and
structural/joint boundary hashes. The exception is random sparse RSM:

| Field | Ordinary fit | Capture fit |
| --- | --- | --- |
| fit readiness | blocked | blocked |
| reason codes | extreme low; boundary audit incomplete; optimizer failure; iteration limit | extreme low; optimizer failure; iteration limit |
| structural state | `none_certified` | `none_certified` |
| joint state | `not_evaluated_solver` | `certified_recession` |

The ordinary fit takes 9.52 seconds and the capture fit 13.07 seconds in this
single ordered execution. This does not prove that instrumentation caused the
difference: the wrapper performs its recording after the production target
call. It proves that two same-session fits on identical data and arguments can
cross the current solver boundary and return different readiness and boundary
content. Runtime values are attribution traces, not frozen thresholds.

Earlier guarded attempts were not promoted. The first incorrectly required a
positive cone in every route and full formulation qualification, thereby
discarding a valid negative result. The second correctly retained safe solver
disagreement but still required six-of-six ordinary/capture equivalence,
thereby treating the discovered replay failure as evidence incompletion. The
final contract separates evidence completion from candidate qualification and
stores both sides of every mismatch. No incomplete directory was promoted.

## Captured recession problems

The authoritative capture contains 16 exact LP problems:

- four certified additive recession directions;
- eleven evaluated negative directions; and
- one RSM joint direction whose capacity is 504 but whose strictness solve did
  not complete under the production limit.

Complete RSM, complete GPCM, and balanced sparse GPCM each contribute one
certified joint direction. Random sparse RSM contributes one certified joint
direction in the capture fit. Balanced sparse RSM contributes the strictness-
failed problem. Random sparse GPCM has no certified additive direction in this
seed. The bounded-GPCM evidence remains conditional-additive and does not
close nonlinear log-slope or curved-path recession.

Every captured problem is rerun under raw and solver-only L1-normalized
constraints with `lpSolve` and GLPK. The target, strict objective, theoretical
box bound, and post-solve certificate remain on the original scale.

| Route | Qualified | Total |
| --- | ---: | ---: |
| raw `lpSolve` | 15 | 16 |
| normalized `lpSolve` | 13 | 16 |
| raw GLPK | 15 | 16 |
| normalized GLPK | 15 | 16 |

All 64 rows have `SafeResult = TRUE`; none converts an unsafe solver return
into a boundary certificate. Normalization is worse rather than better for the
production route in this ordered run, so `TargetNormalizationQualified` is
false. `ProductionNormalizationNeedObserved` is also false: no production
problem is repaired uniquely by normalized `lpSolve`.

## Localized timeout-sensitive cases

Problem 8 is the 427-parameter, 60,907-constraint balanced sparse RSM joint
problem with 929,718 stored nonzeros. The capture fit records capacity 504 and
`linear_program_strictness_failed`. On ordinary two-second replay:

- raw `lpSolve` stops at capacity with status 1 and objective zero;
- normalized `lpSolve` obtains capacity 504, then returns status 1 at
  strictness;
- raw and normalized GLPK both return a certified original-scale direction
  with target change 504 and 144 strict rows.

Problem 13 is the matched random sparse RSM joint problem with 944,274 stored
nonzeros. The capture fit certifies capacity and target change 252. Raw
`lpSolve` reproduces the certificate in the authoritative comparison, while
normalized `lpSolve` reaches capacity 252 and then returns status 1 at the
strictness stage. Both GLPK formulations certify the direction.

Problem 14 is a neighboring negative random sparse RSM target. Normalized
`lpSolve`'s separate raw-capacity check returns status 1 and objective zero,
while the complete target call returns the expected evaluated negative result.
The classification remains safe, but the internal raw/target provenance check
fails. These three rows, together with problems 8 and 13, explain the 61/64
provenance count.

The result is not evidence that GLPK should replace `lpSolve`. Draft.57's
failure-status limitation and scale sensitivity remain unresolved. It is also
not evidence that status 1 should be accepted. A returned nonoptimal status
must not become a certificate unless its actual direction independently
satisfies every original-scale condition.

## Timeout-zero attribution reference

The final prespecification adds a post-failure diagnostic reference. Every
captured problem that is certified, strictness-failed, or has positive recorded
capacity is rerun with raw and normalized `lpSolve` at native timeout zero.
Negative target directions are not selectively re-explored. This produces ten
reference rows over five problems.

All ten reference rows are safe, provenance-consistent, and certified. Seven
match their two-second comparison. Three change outcome:

- problem 8 raw changes from capacity failure to capacity/target change 504;
- problem 8 normalized changes from strictness failure to the same 504
  certificate; and
- problem 13 normalized changes from strictness failure to capacity/target
  change 252.

This localizes the observed changes to the native time-limited execution
contract. It does not authorize timeout zero in production. Unlimited native
execution has no operational upper bound, the reference is one ordered run on
one machine, and negative or harder geometries may behave differently.

## Adversarial interpretation

The current evidence supports five bounded conclusions.

1. Row normalization alone does not repair target-scale production replay and
   is not qualified for 0.2.3 production.
2. Solver replacement remains rejected; GLPK agreement on these cells cannot
   erase its Draft.57 status and scaling failures.
3. The two-second native limit is associated with same-problem capacity and
   strictness transitions, including a fit-level joint-state transition.
4. Safe fail-closed behavior prevents false readiness, but safe nondeterminism
   is still unacceptable as a final numerical reliability contract.
5. No runtime, memory, capacity, sparsity, or supported-scale criterion can be
   frozen from one seed and one ordered execution.

The release spine should therefore pause further target-scale solver or
normalization expansion. The next controlled work is a process-isolated replay
and policy comparison for the captured RSM cases, accompanied by stable
negative and complete-design controls. Nonlinear GPCM, residual-PCA
computability, and ADEMP recovery remain open and resume after the generic JML
replay contract is resolved or explicitly bounded.

## Evidence identity

The authoritative external bundle is
`mfrmr/jml-target-positive-cones-20260806-v1`.

| Artifact | SHA-256 or identity |
| --- | --- |
| Target-cone runner | `912cf60595feebb59f597d3ce78c2d2502e1c344e1e1e7cc967eb55bc4205b7d` |
| Target-scale generator | `6caf66044fff6a1bced6fcdb605bef061143f8115f081a6ea40055ef112637d5` |
| Normalization runner | `f5528c65990df48b4e265469f72400d7aa65d78b4e9b5f9108f4c4a11bd7e1b7` |
| Capture runner | `0ae24b2a7d8a98a451d878f46e0004430355104b60363abf49c5a5740f080cc8` |
| Installed mfrmr content | `ab03e1293272a7e77fe3167e28ff42b639912315ff574a76c304d39b82766103` |
| Prespecification identity | `ba38a23e619f3830dfd7b800cd1e7f87614b5ba1033ec86b972c68de2e59dfc5` |
| Registry identity | `1610c87c177db6c7bb7a19d3026e6b5af6c02377d90d0654311423200e21c740` |
| Source identity | `4aa11e8ccd9730fc11db3add36fb1b0689873e88b7aecb63e506bc0c65ade0a9` |
| Capability identity | `8bd23111c8e614aa099e09364380f229fd38d97a272c67c7c2332dc223f62c2e` |
| Topology-audit identity | `b43687a2a58e82875da120f32173b4ea676b8c36225642133e452a98515e2568` |
| Fit-audit identity | `58c170004dfccd0f61c42c0cde7030410beb13b2ad1043fb0cbb5ed647ec9499` |
| Problem-registry identity | `fcbd881fefbf4585d97e98f7efb1123c2bce177d286fe9d01a1892693596fcea` |
| Comparison identity | `2246ed9916149bb6c9f32437ab9b25f3a9cc9b6ae63aa6019eb72ca8c88f8623` |
| Timeout-reference identity | `e4daee2dc76f38a88e97fa380be70e0aa51a2d1639897c150d8c378f4446f3b9` |
| Execution identity | `7cd2606e4f203cb6afa8f305bafa26a1ea323a20d4bb6408ea615422f111c34d` |
| Completion marker | `a096c9ef574200f72338284e24ede57329dc24d53b917dc1b287fa48cd8c3aff` |
| Artifact inventory | `845b3d0f51bfd39bddb8e104f31bb71682a4584a893a147d8af7f9e1c82800aa` |
| Run summary CSV | `96ad13ff2be60ac4cb2adf0f5798886bdff9878058505bdd4337108e83a8ab2b` |
| Fit audit CSV | `8f0add465a268f255f18a0955e68cf089de79bec304bacf24f3d66a6f570c75d` |
| Formulation comparison CSV | `c8d2b41162000b96f21bb2c48ca8f8dbd671812f47ee8d240d6a60fb77879843` |
| Timeout reference CSV | `42d1c272f287d0d28a52c1357e52a84fad3ee23cb172329ac8e44687f408e627` |
| Serialized problems | `4c22537b99244ed2958985604b4aca3aa2bae3e2aef56bf239e4527b78a536ff` |
| Pilot RDS | `fc15f11503c69cc2e5d48011807016c6f0862c4316e34cfbbbcf27bf302b097d` |

The completion marker independently validates 14 artifacts. `Rglpk` and
`slam` remain validation-only and do not enter `DESCRIPTION`. Public
`ROADMAP.md` and `NEWS.md` remain unchanged.

## Next controlled decision

Draft.60 should use frozen problems 8, 13, and 14 plus stable complete, GPCM,
and negative controls. Each cell should run in fresh processes under a fixed
timeout ladder and a parent OS deadline, recording capacity and strictness
statuses, objectives, returned-solution finiteness, original-scale margins,
target floor, and certificate validity separately.

Candidate policies should include the current two-second route, a bounded
retry after a nonoptimal native status, and an OS-bounded reference. Timeout
zero may be used only as attribution. A policy can advance only if it is
deterministic across prespecified fresh-process repetitions, preserves every
negative control, certifies positive directions only through original-scale
solutions, and has an explicit worst-case bound. A solver switch, silent
acceptance of status 1, or a threshold chosen from the fastest favorable run is
not eligible.
