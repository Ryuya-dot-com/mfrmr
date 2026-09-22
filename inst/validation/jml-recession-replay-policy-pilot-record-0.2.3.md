# JML recession replay-policy pilot record for mfrmr 0.2.3

## Decision

Draft.60 reproduces the current two-second native `lpSolve` instability in
fresh processes and qualifies two bounded policies only for continued
fit-level validation:

- one retry from two seconds to eight seconds after an unaccepted capacity or
  strictness stage; and
- one ten-second native solve per required stage.

Neither policy is selected for production. Both pass the frozen seven-problem
calibration, so this pilot cannot choose between them. Solver selection,
production change, runtime-criterion freeze, replay-blocker closure, and
confirmation remain unauthorized.

The evidence strengthens Draft.59's attribution. The random variation is not
caused by accepting a nonoptimal result: every status 1 attempt fails closed,
and every qualifying final direction comes from a status 0 solution that
passes split-box, primal-margin, objective-reconstruction, target-floor, and
original-scale certificate checks.

## Prespecified policy comparison

Seven exact problems are loaded from the hash-verified Draft.59 bundle. The
selection includes complete and sparse RSM/GPCM positive directions, the
balanced-sparse RSM strictness failure, and random-sparse RSM/GPCM negative
controls.

| Problem | Role | Parameters | Constraints | Stored nonzeros |
| ---: | --- | ---: | ---: | ---: |
| 2 | complete RSM positive | 408 | 19,608 | 231,952 |
| 5 | complete bounded-GPCM positive | 417 | 19,617 | 231,950 |
| 8 | balanced-sparse RSM strictness failure | 427 | 60,907 | 929,718 |
| 10 | balanced-sparse bounded-GPCM positive | 482 | 60,962 | 929,388 |
| 13 | random-sparse RSM positive | 427 | 60,907 | 944,274 |
| 14 | random-sparse RSM negative | 426 | 60,834 | 941,800 |
| 16 | random-sparse bounded-GPCM negative | 482 | 60,962 | 941,400 |

Four policies are run four times for each problem. Every execution uses a new
R process. Policy order rotates across repetitions; problem order rotates and
reverses on even repetitions. This produces 112 unique execution keys.

| Policy | Native timeout per stage | Parent deadline after start | Role |
| --- | --- | ---: | --- |
| `production_2s` | 2 seconds | 15 seconds | current-policy calibration |
| `bounded_retry_2s_8s` | 2, then 8 seconds only after failure | 35 seconds | bounded candidate |
| `bounded_single_10s` | 10 seconds | 30 seconds | bounded candidate |
| `os_bounded_native_zero` | native zero | 30 seconds | attribution reference only |

The parent deadline is independent of the native solver timeout. Native zero
therefore cannot run without a finite external bound. A killed or incomplete
worker remains fail-closed and cannot qualify a policy.

## Stage contract

Capacity and strictness are evaluated separately. A stage is accepted only
when all of the following hold:

1. the solver returns status 0;
2. the complete split solution is finite;
3. positive and negative coordinates satisfy the split box;
4. the reconstructed direction satisfies the original contrast inequalities;
5. the solver objective equals the original-scale reconstruction;
6. capacity remains within its theoretical target bound; and
7. strictness satisfies the original target floor.

A positive direction is certified only after recomputing target change,
minimum contrast margin, total positive margin, and strict-row count on the
unmodified Draft.59 problem. Status 1 is never reinterpreted as success.

The retry policy advances to its eight-second attempt only when the preceding
stage is not accepted. It does not retry a valid negative capacity or a valid
status 0 solution merely because a more favorable classification is desired.

## Execution result

All 112 workers complete without a parent kill. All 112 final results are
fail-closed safe. The bundle contains 198 stage-attempt rows and 28
policy-by-problem cells.

| Result | Count |
| --- | ---: |
| scheduled executions | 112 |
| completed workers | 112 |
| parent kills | 0 |
| safe final results | 112 |
| stage attempts | 198 |
| stable cells | 27 / 28 |
| production-policy stable cells | 6 / 7 |
| production-policy reference matches | 5 / 7 |
| bounded policies qualified for continuation | 2 |

Both random-sparse negative controls remain
`no_target_recession_direction` in all 32 policy/repetition results. Neither
negative problem is ever certified.

## Reproduction of the two-second failure

Problem 8 is the only unstable policy-by-problem cell. Under the current
two-second policy its four fresh processes return:

- one `linear_program_capacity_failed` result with status 1; and
- three `linear_program_strictness_failed` results with capacity 504 and
  strictness status 1.

The same problem is certified in all four repetitions of both bounded
candidates and the OS-bounded reference. Its original-scale certificate has
capacity and target change 504, target floor 0.00504, minimum margin 0,
positive margin 504, and 144 strict rows.

Problem 13 shows why repeatability alone is insufficient. The current policy
is perfectly repeatable but wrong relative to the bounded reference: capacity
252 succeeds four times, while strictness returns status 1 four times. Both
bounded candidates and the reference certify all four repetitions, with
target change 252, target floor 0.00252, minimum margin 0, positive margin 252,
and 72 strict rows.

The retry policy also encounters one two-second capacity failure for problem
10. Its eight-second retry succeeds and all four final outcomes match the
single-ten-second and reference policies.

Across the complete ladder, two two-second capacity attempts and thirteen
two-second strictness attempts return status 1. All seven required retry
attempts at eight seconds return accepted status 0 solutions. Every
single-ten-second and native-zero stage required by these problems returns an
accepted status 0 solution.

## Policy qualification

| Policy | Stable cells | Reference matches | Negative controls | Pilot-qualified |
| --- | ---: | ---: | --- | --- |
| current 2 seconds | 6 / 7 | 5 / 7 | preserved | no |
| retry 2 then 8 seconds | 7 / 7 | 7 / 7 | preserved | yes |
| single 10 seconds | 7 / 7 | 7 / 7 | preserved | yes |
| OS-bounded native zero | 7 / 7 | reference | preserved | attribution only |

Qualification means only that a bounded policy may advance to a fit-level
paired pilot. It is not a production recommendation. The retry policy can add
the cost of a failed first attempt, while the single-ten-second policy grants
every problem the larger limit. Observed total or median time on seven
selected problems cannot establish which policy has the better supported
runtime envelope.

The current policy's stable failure on problem 13 also prevents a weaker rule
such as “accept any four-of-four repeatable outcome.” A valid policy must
remain consistent with an independently bounded original-scale reference.

## Adversarial interpretation

The result supports six bounded conclusions.

1. The native two-second limit is insufficient for the retained target-scale
   RSM problems and is associated with both stochastic stage location and
   stable false-negative boundary classification.
2. Increasing a timeout does not relax the certificate. It permits the solver
   to return a solution that is still tested against the original problem.
3. A retry policy and a single-longer-attempt policy are observationally tied
   on this calibration. Choosing one from elapsed time would be post hoc.
4. The result does not qualify GLPK, L1 normalization, status 1 acceptance, or
   native timeout zero in production.
5. The bounded-GPCM problems validate only the conditional-additive recession
   layer. General nonlinear log-slope and curved paths remain open.
6. Seven frozen problems and four repetitions do not establish the full-fit
   runtime or all-target worst-case envelope.

## Evidence identity

The authoritative external bundle is
`mfrmr/archive/artifacts/validation-bundles-0.2.3/jml-recession-replay-policy-20260806-v1`.

| Artifact or identity | SHA-256 |
| --- | --- |
| Replay runner | `0d28045a3809e5357d499c313edca9c854c236e93cb28f09b00c6a6b0c176ebc` |
| Isolated worker | `72ff1abffa698497f5840fc68d5cbb99ad27dcc015cbec1a341a1a0c0d5eb0eb` |
| Draft.59 runner | `912cf60595feebb59f597d3ce78c2d2502e1c344e1e1e7cc967eb55bc4205b7d` |
| Draft.59 execution | `7cd2606e4f203cb6afa8f305bafa26a1ea323a20d4bb6408ea615422f111c34d` |
| Draft.59 artifact inventory | `845b3d0f51bfd39bddb8e104f31bb71682a4584a893a147d8af7f9e1c82800aa` |
| Draft.59 target problems | `4c22537b99244ed2958985604b4aca3aa2bae3e2aef56bf239e4527b78a536ff` |
| Plan | `8e46f31e7021afb7b054c935dcbd2bc9feb0476891401b17eff1dc0bb8408fa5` |
| Prespecification | `cbfae402fb5274314f32dcc5c0ad796eb028ade6c0b0a80fb977c85e96997273` |
| Problem registry | `096c4397abb052e374d824a26e769c05b08a3176660836d4863722ad8699cba0` |
| Policy registry | `b3d9fd20229d29cc3d90406960cefc4e83b241f576d0df37339409aac0ee3190` |
| Schedule | `1da225b24a599c53db241b7c92955ab0239f412ba56b9f857a90e995aec6b0c5` |
| Source identity | `2c36f181191bdaca73e335a57553de1c05d43a1739a3b64d4ec362134cb61f62` |
| Capability identity | `eab6ba87bda15e576cd091bf9ed90b22f8248b360377c5b398234156e151db2e` |
| Result identity | `a4b06043618122bc084106debfb8ee9c0d9c745d51afc428d0ca86c2b0aae626` |
| Attempt identity | `6f05f03a43f0804f63213660f1599acc6b0b2d8529c0bee8d9006c4e444d187c` |
| Cell-stability identity | `a0e65ff2b6d0645b1aec0d451ab0991eacbc78385c177f3387065b6479d456f0` |
| Policy-summary identity | `3aa00b005510eb5712368954ae800c19f414e6f89fefb2e3c0886f0fbca5feee` |
| Installed mfrmr | `ab03e1293272a7e77fe3167e28ff42b639912315ff574a76c304d39b82766103` |
| Execution | `4153139e7e0588334472c4ee2e89a5548a2b06d5478bb4878365ed5bdf5977af` |
| Artifact inventory | `853be8656a365a163e9a8ebb87b8e890c95135cbe3f72c52ecd7506000e12aca` |
| Completion marker file | `ab75b4e208884b4e5c8e44820eeede3095364f3e0d0e1f7db4d7ac9a806c7395` |
| Run summary file | `aa043e513b24cc79c4554c1fd2da4d0cd2d2dbe54a1f5317a3299cee8b73d317` |
| Replay results file | `5f97d29f0794d491664a43c8a02ddefc2a59ff8d4676c90c8085d0d385bdfa97` |
| Stage-attempt file | `2d580e247b64238913846285a841ce93e0edeb1388bc106a8ce8014391fd1823` |
| Policy-summary file | `555816989de5555d45ff28ca0c27e6f440295e69c5b2b7cf0e6f7a4b4b51a972` |
| Pilot RDS file | `222397af02dddb693f79de8cb3f4de2250359694677a8f1d2795d3e593279368` |

The completion marker independently validates 17 artifacts. The runner also
supports identity-bound checkpoint reuse, but no checkpoint or worker scratch
file enters the promoted bundle. Public `ROADMAP.md`, `NEWS.md`, production
code, dependencies, fitted schemas, and APIs remain unchanged.

## Next controlled decision

Draft.61 should carry both bounded policies into isolated fit-level comparison
without changing production. It should recreate the six Draft.59 RSM/GPCM
routes under exact topology and response hashes, repeat the problematic sparse
RSM routes, and retain complete, bounded-GPCM, and negative controls.

For each candidate it should record the number and stage of every LP call,
full-fit semantic and optimizer invariance, boundary/readiness propagation,
total target calls, parent-deadline behavior, and a finite audit-level
worst-case bound. A policy may be selected only if it preserves every
original-scale certificate and negative control, produces deterministic
fit-level boundary/readiness content, and has a defensible workload rule.

If both remain qualified, selection should be based on a prespecified
fit-level consequence and workload contract, not the fastest observed route.
Only after a single candidate is frozen should production code be changed and
the complete affected regression, target-scale, and package-check evidence be
rerun. Nonlinear GPCM, residual-PCA computability, and ADEMP validation remain
open and resume after this generic JML replay blocker is resolved or bounded.
