# JML bottleneck decomposition pilot record for mfrmr 0.2.3

Status: repository-only draft.49 calibration evidence, 2026-08-05. This is a
single-replicate PCM computation profile under a fixed 60-iteration ceiling.
It freezes no optimizer rule, runtime or memory envelope, recovery criterion,
supported design size, or release decision; estimates no operating
characteristic; authorizes no confirmation; and makes no FACETS, TAM, immer,
JML, or MML superiority claim.

## Question and design

Draft.48 showed that clean 400-Person, 12-Rater, 12-Criterion JML fits could
take hundreds of seconds and remain iteration-limited. Draft.49 asks which
components reproduce that behavior without immediately increasing the wider
mixed-adversity grid. Fourteen PCM data cells and 34 fit routes separate five
bounded contrasts:

| Contrast | Levels | Fixed component | Remaining confounding |
| --- | --- | --- | --- |
| Person and rows | 50, 100, 200, 400 Persons; 600--4,800 rows | 3 Raters, 4 Criteria, 17 structural parameters | Person parameters and rows change together; auto optimizer also switches. |
| Rater panel/topology | 3, 6, 12 Raters; 2,400 rows | 200 Persons, 4 Criteria, 3 Raters observed per Person | Element exposure and zero-common-Person pair topology change with panel size. |
| Criterion/step panel | 4, 8, 12 Criteria; 2,400 rows | 200 Persons, 3 Raters, 4 Criteria observed per Person | Per-Criterion exposure falls and step dimension rises together. |
| Row exposure | 1,200, 2,400, 4,800, 7,200 rows | 200 Persons, 3 Raters, 12 Criteria, 249 JML free parameters | Sparse exposure changes conditioning and can create extreme Persons. |
| Forced extremes | baseline versus 20 low and 20 high Persons | Same P200 truth, 2,400 rows, 217 JML free parameters | Forced outcomes are an adversarial misspecification, not model-generated recovery data. |

Every data cell is passed unchanged to JML-auto and MML-auto. P200 also uses
explicit BFGS and L-BFGS-B; P400, R12, C12-E04, and forced-extreme P200 add an
explicit BFGS control. The same master truth is retained within each contrast.
All 14 cell-level route groups have one data hash and one cell-truth hash.

The runner records observed rows, support topology, extreme counts, total and
Person/structural parameter dimensions, optimizer request and actual method,
reported function/gradient evaluations, terminal gradient, constrained-design
dimension/rank/nonzeros, total fit time, R heap proxies, and process-lifetime
Windows memory. `TotalElapsedPerReportedFunctionEvaluationProxy` is explicitly
a proxy: total fit time includes preprocessing and post-fit design, boundary,
and readiness audits and is not optimizer-objective evaluation time.

## Execution result

The authoritative v3 executed all 34 routes with zero unexpected failed routes
and zero false-ready routes. Two forced-extreme JML routes were prespecified as
must-not-be-inference-ready and both remained blocked. Eighteen routes were
inference-ready. Total fit time was 300.76 seconds; the maximum single fit was
50.86 seconds. Process-lifetime peak working set was 510.11 MB and peak
pagefile 532.97 MB. These cumulative high-water values are not per-cell memory
and do not define a capacity limit.

### Person count and optimizer dispatch

| Cell | Rows | JML free parameters | Auto method | Auto result/time | Explicit BFGS result/time |
| --- | ---: | ---: | --- | --- | --- |
| P050 | 600 | 67 | BFGS | ready; 1.98 s | same auto route |
| P100 | 1,200 | 117 | BFGS | ready; 3.71 s | same auto route |
| P200 | 2,400 | 217 | L-BFGS-B | blocked; 6.83 s | ready; 6.81 s |
| P400 | 4,800 | 417 | L-BFGS-B | blocked; 14.92 s | ready; 15.11 s |

At P200 and P400 the explicit BFGS controls reached terminal-gradient sup norms
of about `3.28e-05` and `4.57e-05`; the L-BFGS-B routes remained at about
`7.68e-03` and `1.22`. P200 explicit L-BFGS-B reproduced the auto result. This
is direct one-seed evidence that the current auto optimizer threshold at 200 parameters
can create a readiness discontinuity for this plain complete PCM Person-size
path. It is not evidence to globally raise the threshold: BFGS has different
memory/scaling properties, only one seed/family/control was used, and the
controls below do not show a universal BFGS solution.

### Panel structure and step dimension

With 2,400 rows fixed, JML-auto times for R03, R06, and R12 were 6.64, 7.61,
and 18.97 seconds. Free dimensions changed only from 217 to 226. However,
zero-common-Person Rater pairs changed from 0 to 3 to 42 and R12 contained one
extreme-low Person. The R12 BFGS control also remained blocked. The increase
therefore cannot be attributed to Rater parameter count alone; panel topology,
element support, boundary work, and optimizer behavior remain entangled.

With rows fixed at 2,400, C04, C08, and C12 JML-auto times were 6.63, 11.11,
and 15.32 seconds as structural parameters increased from 17 to 33 to 49.
The C12 BFGS control remained blocked with a terminal gradient near `2.31e-02`.
This makes Criterion/step block size and support plausible work drivers, but
the runner lacks internal phase timing and per-Criterion exposure also falls.
No causal complexity formula or supported maximum is frozen.

### Row exposure and extremes

At the fixed 249-parameter C12 design, JML-auto times at 1,200, 2,400, 4,800,
and 7,200 rows were 18.16, 15.32, 32.39, and 50.86 seconds. The 1,200-row cell
was slower than the 2,400-row cell, had two extreme-low Persons, and had a
design condition index around 16.7. The 7,200-row cell was the only ready JML
route in this path despite being the slowest. Thus neither smaller data nor
larger data has a monotone readiness interpretation; row count, support, and
conditioning must be stratified.

Forcing 20 low and 20 high Persons while retaining the P200 truth, rows, and
parameter dimension increased JML-auto time from 6.83 to 14.13 seconds and
left both auto L-BFGS-B and explicit BFGS blocked. BFGS therefore fixes the
complete nonextreme Person-size control but does not fix the separation case.
The result supports separate optimizer-dispatch and boundary/extreme lanes.

### MML control route

Thirteen of 14 MML controls were ready in 0.46--1.83 seconds. C12-E08 was
review-only because of `terminal_gradient_review`, while C12-E12 was ready.
MML is therefore a useful fast same-data control here, but a one-seed PCM
profile neither establishes MML maturity nor explains draft.48 GPCM marginal-
boundary behavior. The nonmonotone MML state also argues against a simple row-
count rule.

## Adversarial conclusions

1. Draft.48's hundreds-of-seconds sparse JML result is not reproduced by any
   single-axis draft.49 cell; the largest draft.49 fit is about 51 seconds.
   The draft.48 bottleneck is likely a compound interaction among 400 free
   Persons, 12 Raters, 12 Criteria/step ladders, 10,080 rows, topology,
   extremes, audits, and optimizer behavior.
2. The auto optimizer threshold is an actionable algorithm hypothesis for the
   complete Person-size path, not a globally validated fix.
3. Rater-panel size cannot be separated from topology in the current ring
   contrast. A future pure panel-dimension control needs constant local
   overlap/information, not merely constant rows.
4. Criterion/step growth and rows both raise time in supported portions of the
   grid, but internal phase timing is required to distinguish preprocessing,
   sparse rank, recession/boundary audits, objective/gradient construction,
   and optimizer work.
5. Extreme Persons approximately doubled total JML fit time in the matched
   P200 contrast and defeated both optimizers. This is a computational finding,
   not a recovery or bias result.
6. No elapsed-time ratio is treated as hardware-independent. No result may be
   converted into a public capacity claim or FACETS comparison.

## Evidence integrity

The authoritative bundle is outside the package source tree at
`mfrmr/archive/artifacts/validation-bundles-0.2.3/jml-bottleneck-profile-20260805-v3`.
Its completion marker validates 12
artifacts in a fresh session. v1 is superseded because its elapsed/evaluation
field name was too strong and it lacked the wider BFGS controls. v2 contains
the final controls but is superseded because its Rater axis label incorrectly
suggested a pure dimension contrast. Excluding time/memory and the corrected
axis labels, all 88 stable result columns are identical between v2 and v3;
the common 30-route v1/v2 comparison likewise had zero stable-field
differences.

| Field | SHA-256 |
| --- | --- |
| Declared 34-route manifest | `5517a5e5a456b02eb7cd1c5e7eea2dbaaec222d995e14f0a235d5d781589efb0` |
| Loaded checked mfrmr runtime | `28d3bb9d2a30c519f0d092be2149a819ab4de2dd03c27fb157c09bf7bf4038f8` |
| Runner composite | `ce687cee7754fecbe903dd5056fdf9c8dc32ced847922bfda4d11ce3f49496ff` |
| JML profile runner | `fd8e11b52d09815d19a714090b02bbf76373a4748128b078a1fdc7a30e2f8ba5` |
| Capability manifest | `773bff591ffaa7c8e0d7f2b03c497b82c97b3f2a00872f523284ae947c41c4ef` |
| Execution identity | `36c1c81440827f11089e22b8e20a2dfb1677ad5d07c9d081140d5964167f29a9` |
| Embedded artifact inventory | `3f7256ccea3e4bcd7cc663f6df985338f9b04383a947877bb20d5d0a43553cb4` |
| Result CSV | `c035b0bf0ce93fc42f5252c6d036787a6c0cd5a041c8a2b2f1a277961dd51019` |
| Completion marker | `e4d490cf0b88e563a2eaa9adcb73f5a45f38d27dd4344d59a78a02551d65d023` |

The exact public checked draft.43 package remains unchanged: source tarball
SHA-256 `88EBD28817AD1924A9AE235F56301264D5EC47FD06A9416D6A4BA55C5C59DFA6`,
`R CMD check --as-cran` log SHA-256
`B3956B95ABCB26BDE6D9CBD1A675ED9DE4C5365970B3F86FAEAA0B7FB8AA3D`,
status `OK`. The runner, record, tests, and internal roadmap are excluded from
the source-package payload.

## Next corrective slice

Draft.49 changes the next implementation order:

1. add phase timing/counters around preparation, constrained sparse-design
   construction/rank, Person and structural boundary audits, optimizer, and
   readiness assembly;
2. run a small replicated optimizer-dispatch grid around 180--260 parameters
   for RSM/PCM and controlled GPCM, recording memory as well as readiness;
3. construct topology-matched Rater-panel controls and exposure-matched
   Criterion/step controls;
4. retain explicit extreme/nonextreme strata and do not let adjusted finite
   displays enter primary recovery;
5. only after phase attribution, test targeted implementation changes against
   the same frozen cells; and
6. then return to replicated recovery/MCSE and matched external comparisons.

Changing the global auto threshold, increasing `maxit`, or weakening the
terminal-gradient gate before these controls would be premature.
