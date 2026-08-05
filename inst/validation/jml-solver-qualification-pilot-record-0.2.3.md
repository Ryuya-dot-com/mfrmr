# JML solver-qualification pilot record for mfrmr 0.2.3

## Decision

Draft.57 does not qualify GLPK as a solver candidate and does not authorize a
solver abstraction, fallback, dependency, or dispatch change. The production
solver remains `lpSolve`. No runtime or memory criterion is frozen, and
confirmation remains unauthorized.

This is a negative but informative result. GLPK reproduces every untransformed
Draft.56 target across seven alternating-order replicates and is faster in the
observed calibration run. It nevertheless fails one mathematically equivalent
RSM row-scaling property and its high-level status interface does not preserve
the failure distinctions required by the prespecification. Speed cannot
override either failure.

## Evidence boundary

The guarded repository-only runner first reacquires the exact LP targets from
ordinary package fits. Temporary wrappers observe the input and production
result of `mfrmr_jml_recession_target_lp()` and are restored after every fit.
They do not replace a result or alter readiness. Reacquisition must reproduce
the authoritative Draft.56 v3 ledger before solver qualification begins.

The runner then separates four questions:

1. Do the solvers reproduce the 40 recorded target decisions under balanced
   alternating order and seven included repetitions?
2. Do they preserve positive/negative decisions under row, column, scale,
   target-scale, and tolerance transformations?
3. Are optimal and failure results accepted or rejected safely, and are
   failure classes specific enough for dispatch diagnostics?
4. Can each solver complete the largest captured PCM, RSM, and bounded-GPCM
   problem in a fresh process with process-lifetime peak memory recorded?

Candidate qualification and evidence completion are different. A safely
recorded failed metamorphic property completes the evidence bundle but prevents
candidate qualification. This distinction was added after the first guarded
calibration correctly found a failed property; the failed property and original
bounds were not removed or narrowed.

## Reacquired problem set

All 12 fixed JML fits and four RSM/GPCM controls succeed. The fixed semantic,
readiness, boundary, and target-status fields match Draft.56. The 40 captured
targets match its scenario, scope, base identity, parameter count, constraint
count, classification, and certification ledger exactly.

There are 28 unique problem identities among the 40 captured targets. Repeated
PCM identities arise from deliberate optimizer-route and matched-geometry
controls. They are useful paired timing observations but are not 40 independent
geometries.

The problem set covers:

- PCM structural and joint additive cones;
- two-Rater missing, weighted, and imbalanced RSM;
- Rater-by-Criterion interaction RSM;
- two-Rater strongly imbalanced bounded GPCM; and
- an eight-Rater sparse-panel bounded GPCM.

As in Draft.56, GPCM evidence covers the conditional-additive LP only. It does
not close nonlinear log-slope or curved-path recession.

## Alternating replicated comparison

Each of 40 targets receives one excluded warm-up per solver and seven included
replicates per solver. Problem and replicate parity determine which solver runs
first. Each solver therefore has 140 first-position and 140 second-position
calls.

| Result | `lpSolve` | GLPK |
| --- | ---: | ---: |
| included calls | 280 | 280 |
| expected classification/capacity matches | 280 | 280 |
| bounded and certificate-safe results | 280 | 280 |
| total elapsed time | 60.05 s | 13.32 s |
| median target time | 0.14 s | 0.03 s |
| 90th percentile target time | 0.53 s | 0.13 s |
| first-position calls | 140 | 140 |
| second-position calls | 140 | 140 |

All 280 paired comparisons agree. First/second position means are also close
within each solver: `lpSolve` records 0.2119 and 0.2170 seconds, while GLPK
records 0.0488 and 0.0464 seconds. This reduces one obvious order confound but
does not make the totals a release speed claim. The portfolio contains repeated
problems, uses one R session and one machine, has no between-session or thermal
replication, and measures complete target calls rather than an implemented
production dispatch. No speed or runtime threshold is frozen.

## Generated metamorphic properties

The property source rule selects the first positive and first negative target
within each of PCM, RSM, and GPCM. Each source is evaluated under eight frozen
transformations with both solvers:

- identity;
- reversed contrast-row order;
- rotated parameter columns with the target permuted identically;
- deterministic positive contrast-row scaling from `1e-3` through `1e3`;
- target scaling by `1e-3` and `1e3`; and
- objective/certificate tolerances of `1e-9` and `1e-5`.

Ninety-four of 96 solver-property rows pass. Both failed rows refer to the same
RSM positive joint cone under the frozen row scaling:

| Solver | Raw status | Result | Capacity |
| --- | ---: | --- | ---: |
| `lpSolve` | 0 | certified additive recession | 147 |
| GLPK | 1 | capacity LP failed closed | not returned |

The source problem is `LP-RSM-TWO-RATER-MISSING`, problem 31. The original and
scaled problems are mathematically cone-equivalent because every contrast row
is multiplied by a positive constant. `lpSolve` returns the expected capacity
147 and an original-scale post-solve certificate with 42 strict rows, minimum
margin zero, and positive-margin sum 63,049.035. GLPK returns nonoptimal status
1 at the capacity stage. Both results are handled safely, but they are not
equivalent. The same property failure appeared in the diagnostic and
authoritative executions; the property layer itself is one execution per
solver, separate from the seven replicated ordinary-target timing layer.

This is sufficient to reject an immediate GLPK dispatch proposal. It does not
show that GLPK is generally incorrect; it localizes an unresolved interaction
among row scaling, the Rglpk/GLPK formulation, and numeric preprocessing.

## Failure-status controls

Twelve controls cover actual optimal, infeasible, unbounded, and nonfinite-
input problems for both solvers, plus injected timeout and numeric-failure
mapper states. All unsafe results are rejected. However, neither solver
satisfies the prespecified requirement for specific classification of every
failure class:

- `lpSolve` returns status 2 for the infeasible fixture, but the unbounded
  fixture returns status 0 with objective and solution `1e30`; only the absence
  of a verified bound prevents false acceptance.
- `lpSolve` rejects the nonfinite objective as an input error. Timeout status 7
  and numeric-failure status 5 are mapper-only controls, not observed live
  timeout or numeric-failure solves.
- Rglpk returns status 1 for both infeasible and unbounded fixtures, so its
  high-level result is an undifferentiated nonoptimal state.
- Rglpk returns status 0 with an `NA` objective for the nonfinite-input fixture;
  the numeric-result check rejects it.

For the actual mfrmr recession LP, nonnegative split variables, explicit box
constraints, the target L1 upper bound, and the original-scale margin
certificate provide the missing acceptance contract. Raw status 0 alone is
not sufficient for either solver.

Actual timeout semantics remain open. They should be tested by applying an OS-
level deadline to an isolated worker so that only the child process can be
terminated. A synthetic raw status is not evidence that a solver obeys its
declared time limit.

## Isolated-process memory calibration

The largest captured problem by constraint count within each model is run
three times per solver in a fresh process. `ps` records process-lifetime Windows
working-set peaks after the runtime and problem have been loaded.

| Model | Solver | Initial peak MB | Final peak MB | Increase MB | Median target s |
| --- | --- | ---: | ---: | ---: | ---: |
| PCM | `lpSolve` | 141.64 | 219.64 | 77.99 | 0.77 |
| PCM | GLPK | 141.81 | 229.79 | 87.98 | 0.27 |
| RSM | `lpSolve` | 132.05 | 278.75 | 146.70 | 0.12 |
| RSM | GLPK | 132.11 | 262.24 | 130.13 | 0.02 |
| GPCM | `lpSolve` | 132.08 | 276.36 | 144.28 | 0.14 |
| GPCM | GLPK | 132.09 | 262.88 | 130.79 | 0.03 |

All six workers exit normally and reproduce safe target results. These values
are not solver-only allocation measurements: package loading, problem
deserialization, sparse conversion, native allocation visibility, and retained
working memory contribute to the process peak. There is one process per
model-solver cell and no frozen memory envelope.

## Evidence identity

The authoritative bundle is
`mfrmr/jml-solver-qualification-20260806-v1`.

| Artifact | SHA-256 or identity |
| --- | --- |
| Qualification runner | `0ae24b2a7d8a98a451d878f46e0004430355104b60363abf49c5a5740f080cc8` |
| Isolated worker | `973ffdf64c968883344d5383c218380cee3d41710111c2764c38010b29406f1f` |
| Draft.56 runner | `801a748e69f505a41c332980e5488804cbdfcbecfc6b7c22c7a920b1f964390f` |
| Installed mfrmr content | `ab03e1293272a7e77fe3167e28ff42b639912315ff574a76c304d39b82766103` |
| Prespecification identity | `87cf3fbf655d2ec935127c8d31c139cded0d5e17c210a174f16cb00f7eef02b8` |
| Problem-registry identity | `b9f8980a1b1e40534a503026f78355c087a3cddb8ab2630e617288aaa407f3a4` |
| Capability-manifest identity | `828ccabe20f377aa7d5d653531b512acfb9f1b626d1ffec72324c68294f27c6d` |
| Execution identity | `820f7d3b6d3361d8b8bd0b4636130ec8750d63bc3f5ecec3de4d9442f17d2197` |
| Completion marker | `ed09ebccd20b97197d43e6f7fbfeb77621cf5f991e37ad3ec01263cb6886c24f` |
| Artifact inventory | `d659336e33d09fe7cdbd5c41e43846452d14581ed5cc6318fdef4a8107c075fb` |
| Run summary CSV | `1e73cb13588dd74a8864a005e2be556e7f0347f17be26c9d7f95ab5b04cb11a0` |
| Problem registry CSV | `264aea6a9150aa9b3af44c6d972e708c3d6e7a7c563c5c397f42faa06f651903` |
| Pair audit CSV | `94bede6b65d70eb44545f84721ccb05cea39fb1b181841ea47f837f4f3aa1969` |
| Property controls CSV | `ec678ebaa3b3e4f596f011348c8957c4344b5a48cde7e1c835cd6eb99b8dc79a` |
| Status controls CSV | `0f8765800a753e4451ccb4337e17db5f5a971805cd0fee54aef72c38a5f73fe2` |
| Isolated memory CSV | `304e98f37451541249fece52f353054105b5bff52c20c4d8ba9adcd9969c88d8` |

The marker inventory independently revalidates all 18 artifacts. The installed
`Rglpk`, `slam`, and `ps` capabilities remain outside the package source and do
not enter `DESCRIPTION`.

## Next controlled decision

Draft.58 should investigate solver-neutral numeric normalization rather than
switch solvers. A candidate formulation should normalize only solver
constraint rows by positive deterministic factors, retain original contrast
rows for the strict objective and post-solve certificate, and bind both
original and solver-form identities. It must run a finer fixed scale ladder,
repeat the failed RSM cell in fresh processes, and include PCM/RSM/GPCM positive
and negative cones before any performance comparison is reconsidered.

Draft.58 should also replace synthetic timeout evidence with an isolated child-
process deadline and record raw API status, process exit reason, primal/objective
validity, theoretical box bound, and original-scale certificate separately.
Failure-class specificity may be relaxed only through an explicit diagnostic
contract revision, not because a candidate is fast.

If normalization and status provenance do not pass, retain `lpSolve` and move
the critical path back to model-level obligations: nonlinear GPCM slope
recession, target-scale RSM/GPCM positive cones, PCA computability, and ADEMP
recovery/coverage. Public `ROADMAP.md` and `NEWS.md` remain unchanged.
