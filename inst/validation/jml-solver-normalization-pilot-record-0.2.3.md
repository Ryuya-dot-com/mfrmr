# JML solver-normalization pilot record for mfrmr 0.2.3

## Decision

Draft.58 qualifies deterministic L1 constraint-row normalization as a bounded
validation candidate. It does not qualify GLPK as a production solver, alter
the `lpSolve` dispatch, authorize a dependency or fallback change, freeze a
runtime criterion, or authorize confirmation.

The distinction is deliberate. Normalization removes all six raw GLPK scale-
ladder failures while preserving the original-scale decision and certificate.
The high-level solver interfaces still do not identify every failure class
with the specificity required in Draft.57. A numerically useful formulation
change is therefore not evidence for a solver replacement.

## Prespecified boundary

The guarded repository-only runner validates the complete Draft.57 evidence
inventory and reads its exact 40 serialized solver problems. It selects the
first positive and first negative target in each of PCM, RSM, and bounded GPCM,
for six source problems. It does not refit or modify package results.

For every source, the runner applies deterministic row factors cycling through
`10^-e`, 1, and `10^e`, for exponents 0, 1, 2, 3, 4, and 6. Each resulting
problem is evaluated with `lpSolve` and GLPK under two formulations:

- `raw`, which sends the scaled rows directly to the solver; and
- `l1_row_normalized`, which divides each nonzero solver constraint row by its
  own original L1 norm.

Only solver constraints are normalized. Box constraints, the selected target,
the strict objective, the theoretical target L1 bound, and the contrast design
used for post-solve verification remain on the original transformed scale.
The source problem, original-scale problem, solver formulation, row factors,
and normalization each receive separate SHA-256 identities. Acceptance still
requires finite solver output, split-variable box validity, objective
reconstruction, the theoretical capacity bound, and an original-scale primal
margin certificate. Raw solver status alone is never sufficient.

This is a deterministic numerical calibration over captured conditional-
additive recession problems. It is not a fit-level statistical validation, a
target-size capacity envelope, a nonlinear GPCM log-slope proof, or a general
claim about arbitrary LPs.

## Scale-ladder result

All 144 formulation-solver rows preserve the required provenance. Results are:

| Formulation | Solver | Qualified | Total |
| --- | --- | ---: | ---: |
| raw | `lpSolve` | 36 | 36 |
| raw | GLPK | 30 | 36 |
| L1 row-normalized | `lpSolve` | 36 | 36 |
| L1 row-normalized | GLPK | 36 | 36 |

The six raw failures are all GLPK status 1 at the capacity stage of positive
joint cones:

| Model and source | Failed exponents | Result |
| --- | --- | --- |
| PCM, problem 10 (`JBP-R12-JML-auto`) | 6 | failed closed |
| RSM, problem 31 (`LP-RSM-TWO-RATER-MISSING`) | 3, 4, 6 | failed closed |
| bounded GPCM, problem 37 (`LP-GPCM-TWO-RATER-IMBALANCED`) | 4, 6 | failed closed |

No raw negative cone or raw `lpSolve` row fails. Every normalized row passes,
including the previously failed positive RSM case. Normalization therefore
eliminates the observed sensitivity monotonically across these three positive
model examples, rather than repairing only the single Draft.57 counterexample.
It does not establish correctness outside the six-source ladder.

## Fresh-process reproduction

The previously failed positive RSM exponent-3 problem is repeated three times
for every formulation-solver pair in independent child processes. All 12 child
results are readable and match their parent expectation:

| Formulation | Solver | Matches | Parent result |
| --- | --- | ---: | --- |
| raw | `lpSolve` | 3/3 | certified capacity 147 |
| raw | GLPK | 3/3 | status 1, failed closed |
| L1 row-normalized | `lpSolve` | 3/3 | certified capacity 147 |
| L1 row-normalized | GLPK | 3/3 | certified capacity 147 |

An initial diagnostic attempt produced only 6/12 readable child results and
was not promoted. The cause was missing explicit `Matrix` namespace loading in
the isolated worker after deserializing `dgCMatrix` objects. The worker now
requires `Matrix` directly; the authoritative run is the later 12/12 bundle.
This correction changes execution support, not a solver outcome or acceptance
rule.

## Actual child-process deadline controls

Each solver receives a successful one-repetition child control and a forced
100,000-repetition control. The parent waits for a worker-created start marker,
then enforces either a 30-second success deadline or a 250-millisecond forced
deadline. The forced control terminates the exact child process tree.

| Solver | Success control | Forced-deadline control |
| --- | --- | --- |
| `lpSolve` | exit 0, valid output | start observed, killed, exit 15, no output |
| GLPK | exit 0, valid output | start observed, killed, exit 15, no output |

All four controls pass. This establishes the repository validation runner's
OS-level lifetime control and exit provenance. It does not show that either
solver has a native time-limit status or distinguish infeasible, unbounded,
numeric, and interrupted solves through its high-level API. Production does
not acquire a timeout from this evidence.

## Adversarial interpretation

The strongest supported conclusion is narrow: deterministic positive row
normalization is mathematically compatible with the captured cone decisions
and empirically removes their observed scale failures while retaining
original-scale verification.

Four broader conclusions are not supported:

1. GLPK is not qualified. Draft.57's failure-status-specificity requirement
   remains unsatisfied, and Draft.58 deliberately sets
   `SolverCandidateQualified` to false.
2. `lpSolve` need not be changed merely because normalization is robust in this
   ladder. A production intervention needs fit-level invariance, broader
   target-scale positive cones, malformed/near-boundary controls, and a clear
   user-level benefit that outweighs new code and evidence invalidation.
3. The conditional-additive bounded-GPCM rows do not prove nonlinear log-slope
   or curved-path recession behavior.
4. Six source geometries and one repeated cell cannot freeze runtime, memory,
   capacity, or supported-sparsity criteria.

The main release spine should therefore stop solver-local expansion here. L1
normalization remains a bounded hardening candidate. Unless broader model-level
evidence demonstrates false failures that materially affect supported fits,
the production solver and formulation remain unchanged while priority returns
to nonlinear GPCM slope recession, topology/exposure-matched target-scale
positive cones, residual-PCA computability, and ADEMP recovery/coverage.

## Evidence identity

The authoritative external bundle is
`mfrmr/archive/artifacts/validation-bundles-0.2.3/jml-solver-normalization-20260806-v1`.

| Artifact | SHA-256 or identity |
| --- | --- |
| Normalization runner | `f5528c65990df48b4e265469f72400d7aa65d78b4e9b5f9108f4c4a11bd7e1b7` |
| Isolated worker | `249f3d1ef746f3654e9d266280c8ca6edb88fee8162df3e3970bbe29da320584` |
| Draft.57 runner | `0ae24b2a7d8a98a451d878f46e0004430355104b60363abf49c5a5740f080cc8` |
| Installed mfrmr content | `ab03e1293272a7e77fe3167e28ff42b639912315ff574a76c304d39b82766103` |
| Prespecification identity | `bca477c24df5a55c51ef8da6fd3ccef47a0cec107b14965becefaade53e96d75` |
| Source-identity object | `e55d3c1e0bab36ac11180f2707cd5719de388461c40a53e6af6909fce58f8775` |
| Capability-manifest identity | `1d067ec7b7c29f9bbf813e7ddb5d0959bbecb2ff04a0d5eac41cbd5333e55472` |
| Draft.57 completion marker | `ed09ebccd20b97197d43e6f7fbfeb77621cf5f991e37ad3ec01263cb6886c24f` |
| Draft.57 serialized problems | `89d6eb8c3f05e42c6bdac9084cd6e7eabecd04596d02ff4f40fe6f4c6c3eb32e` |
| Ladder object | `f273145e0d885660896b96a2dfd2ac816d2f229aaae0b4dafa43b43fbba0d86d` |
| Execution identity | `06116f8aaa6e863bde715be7c15ad0c6d0655b2ce7c4f5678b98d25ae84b17a4` |
| Completion marker file | `7428a7e7b8d20e0e299a4f1d6b64194a738907b6de22b59d61c9446062269e72` |
| Artifact inventory | `9e1279679a6191ca20dd51d949e2264f4b9ec4594caba9d2ce7693eac82c1ea8` |
| Scale ladder CSV | `f11b3b0589f5d663a13eff7487390b18f6fca350724537239db3acb365262515` |
| Fresh-process CSV | `e71ccc17a58c31c39cdf0e97c7594c13d45b6e9575ebadea1927e0e6727202b0` |
| Deadline-controls CSV | `24989bb9f6ba9bdbcff08131a01a6d4567ed43daa53dde6a0bd92e4ee436f911` |
| Run summary CSV | `0189db2457893084b47e8bdba4e2d721fc61ad77f4f485b13be0190cac0f26a2` |
| Pilot RDS | `97c09ab696e2ffc10b55700700ae2da1877387ffd87e98b3321ec4a797504f53` |

The completion marker independently validates all ten listed artifacts.
`Rglpk`, `slam`, and `processx` remain validation-only capabilities outside
`DESCRIPTION`. Public `ROADMAP.md`, `NEWS.md`, APIs, fitted schemas,
likelihoods, readiness decisions, and production dispatch remain unchanged.

## Next controlled decision

The next release-spine work should not be another solver benchmark. It should:

1. extend positive-cone evidence to topology/exposure-matched target-scale RSM
   and bounded-GPCM fits, retaining normalization as a diagnostic comparison;
2. close the distinct nonlinear GPCM log-slope and curved-path obligations;
3. implement and calibrate a residual-PCA computability contract before using
   PCA stress results; and
4. resume replicated ADEMP recovery, standard-error coverage, and failure-
   denominator work across JML/MML and eligible external strata.

A production normalization proposal may be reopened only if those model-level
runs reveal preventable supported-fit failures and can show exact semantic and
readiness invariance under a versioned candidate. Otherwise Draft.58 closes
the solver investigation for 0.2.3 with `lpSolve` retained.
