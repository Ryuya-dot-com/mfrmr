# Target-scale baseline and bridge pilot record for mfrmr 0.2.3

Status: repository-only draft.48 calibration evidence, 2026-08-05. This is a
single-replicate feasibility and attribution run. It freezes no recovery,
runtime, memory, overlap, or diagnostic threshold; estimates no Monte Carlo
operating characteristic; authorizes no confirmation; and makes no FACETS,
TAM, or immer parity claim.

## Decision

Draft.47 mixed target scale with several adversities. Draft.48 separates those
questions by adding complete balanced and clean matched-sparse RSM, PCM, and
GPCM baselines, then a two-Rater PCM common-Person bridge gradient. Every data
cell sends the same generated data through JML and MML. The bridge gradient
uses one common truth hash at 0, 1, 2, 5, 10, 20, and 40 shared Persons so a
change in overlap is not confounded with a change in the generated parameters.

The authoritative v2 bundle contains 13 data cells and 26 estimator routes.
All 13 JML/MML pairs have one data hash. All 26 routes executed, with zero
unexpected failed routes and zero false-ready routes. One zero-overlap JML
route failed closed as expected. Nine routes were inference-ready. These
counts establish runner and contract behavior for the fixed seeds only; they
are not estimates of failure rates or statistical adequacy.

## Fixed design

| Family | Persons | Raters | Criteria | Categories | Rows | Shared Persons | Role |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Complete RSM/PCM/GPCM | 400 | 3 | 4 | 5 | 4,800 | 400 | Balanced scale baseline |
| Matched sparse RSM/PCM/GPCM | 400 | 12 | 12 | 7 | 10,080 | 40 minimum per Rater pair | Clean sparse scale baseline |
| PCM bridge gradient | 400 | 2 | 4 | 5 | 1,600--1,760 | 0, 1, 2, 5, 10, 20, 40 | Weak-link calibration |

The run used R 4.5.1 on `x86_64-w64-mingw32`, the exact checked mfrmr 0.2.3
runtime, `maxit = 180`, and seven MML quadrature points. Residual PCA was not
run because draft.47 exposed an unresolved computability-state contract. The
runner records process-lifetime Windows peak working set and peak pagefile via
`ps`; these are cumulative process high-water values, not per-cell allocation
and not a supported capacity ceiling.

## Balanced and sparse results

| Cell | JML | MML | Main implication |
| --- | --- | --- | --- |
| Complete RSM | blocked at iteration limit; 17.27 s | ready; 0.98 s | A balanced 400-Person design does not guarantee JML convergence under the fixed control. |
| Complete PCM | ready; 15.31 s | ready; 1.33 s | Both routes produce eligible one-seed recovery traces, not validated recovery. |
| Complete GPCM | review; 15.86 s | review; 2.27 s | Both routes retain terminal-gradient/boundary-contract limitations; optimizer log-slope errors are descriptive only. |
| Sparse RSM | blocked at iteration limit; 204.28 s | review; 2.51 s | Sparse target scale sharply separates JML computational behavior from MML. |
| Sparse PCM | blocked at iteration limit; 480.17 s | review; 4.24 s | The slowest route was JML PCM, not free-slope GPCM; family complexity alone does not explain runtime. |
| Sparse GPCM | blocked at iteration limit; 231.51 s | review; 17.02 s | Clean data still leave JML runtime and MML gradient/boundary work open. |

Complete MML centered Rater RMSEs were 0.0260, 0.0131, and 0.0196 for RSM,
PCM, and GPCM. The corresponding JML traces were 0.0519, 0.1053, and 0.0217.
Sparse MML centered Rater RMSEs were 0.1030, 0.1530, and 0.0844, while JML
traces were 0.0454, 0.0520, and 0.0432. These values are deliberately not
ranked as estimator performance: there is one replicate, several fits are not
inference-ready, JML and MML target different Person/population treatments,
and no recovery criterion is frozen.

Total fit time was 1,053.31 seconds and the longest fit was 480.17 seconds.
The process-lifetime peak working set reached 635.85 MB and peak pagefile
659.93 MB. The monotone high-water sequence cannot be attributed to individual
fits. A fresh-process benchmark is required before freezing model-specific
memory or runtime limits.

The earlier v1 and current v2 complete/sparse cells have identical data hashes
and recovery traces. One blocked sparse RSM-JML row differs only in boundary
display (`not_evaluated` versus `has_exclusions`); both runs have the same
iteration-limit decision. This variation prevents treating boundary display
as a deterministic successful audit for that blocked fit and belongs in the
replay/property grid.

## Two-Rater bridge findings

At zero common Persons, JML failed the exact estimability contract before a
usable fit. MML returned `review` with `population_assumption_linked`, so its
numerical completion does not turn population-assumption linkage into an
observed Rater comparison. This is the intended estimand distinction.

For positive overlap, every MML route was ready. Centered Rater RMSE traces at
1, 2, 5, 10, 20, and 40 shared Persons were 0.0421, 0.0613, 0.0258, 0.0048,
0.0312, and 0.0302. JML was `ready_with_exclusions` at 1 and 2 shared Persons
and blocked at 5--40 because of extremes and/or the iteration limit. Its
descriptive RMSE traces were likewise nonmonotone. Consequently:

1. binary connected/disconnected status is insufficient;
2. numerical readiness is not a minimum-overlap rule;
3. a small one-seed RMSE at one overlap level cannot define adequate support;
4. JML and MML require estimator-specific overlap, extreme-score, information,
   failure, and recovery strata; and
5. the next bridge pilot must replicate the common truth design across seeds
   and include group-anchor, interaction, imbalance, and unequal-exposure
   variants without optional stopping on a favorable overlap.

The v1 bridge output is retained only as a superseded seed-confounding
diagnostic: its overlap cells used different truth seeds. It must not be used
to infer an overlap trend. The v2 bridge rows all share truth SHA-256
`bd480d6ce83b3cc3fad357adc2fc9733b850eee066715586473264ed963e591a`.

## Evidence integrity

The authoritative bundle is outside the package source tree at
`mfrmr/archive/artifacts/validation-bundles-0.2.3/target-baseline-bridge-20260805-v2`.
Its completion marker validates in
a fresh session and binds 11 artifacts by relative path, byte size, and hash.

| Field | SHA-256 |
| --- | --- |
| Declared manifest | `285072b049b9046ba9ec9a1dbc8464b8b8425154b37a4c5048c6062aa053f429` |
| Selected manifest | `6650dc16d9be4143df24465a972d5c3f85e608345d0185553f070f6d81d32427` |
| Loaded checked mfrmr runtime | `28d3bb9d2a30c519f0d092be2149a819ab4de2dd03c27fb157c09bf7bf4038f8` |
| Runner composite | `7faedb4d70d50f2361f587cf365231202a2759bee06cf6a38789674120e588a0` |
| Target baseline runner | `6caf66044fff6a1bced6fcdb605bef061143f8115f081a6ea40055ef112637d5` |
| Capability manifest | `773bff591ffaa7c8e0d7f2b03c497b82c97b3f2a00872f523284ae947c41c4ef` |
| Execution identity | `c3057c41358a49d3db9f52ecdd854a08883a9734d6cc35b6fae82af2628ba871` |
| Embedded artifact inventory | `6882c0df3c336bcf544211018325f6b28697efcd379d448df3e884ec4624abf4` |
| Result CSV | `c69d07597b0ecd2814c25e5bf5865601ab15d76aa373c5c687d473c88c37779f` |
| Completion marker | `11b8b2e5f2a44245328cf215aa6d9b1f1ac5a990e73c08f558f6c795826b880e` |

The exact public checked draft.43 package remains unchanged: source tarball
SHA-256 `88EBD28817AD1924A9AE235F56301264D5EC47FD06A9416D6A4BA55C5C59DFA6`,
`R CMD check --as-cran` log SHA-256
`B3956B95ABCB26BDE6D9CBD1A675ED9DE4C5365970B3F86FAEAA0B7FB8AA3D`,
status `OK`. This runner, record, tests, and internal roadmap are excluded from
the source-package payload.

## Roadmap consequence

Draft.48 closes only a target-scale baseline/bridge feasibility slice. It
changes the next priority from adding more mixed-adversity cells to explaining
estimator-specific bottlenecks:

1. profile JML iteration cost against Criteria, Raters, rows, free Person
   parameters, extreme-score handling, and structural design dimensions;
2. resolve MML terminal-gradient and GPCM marginal-boundary contracts before
   widening iteration limits or tolerances;
3. add the fail-closed PCA computability state before another PCA stress run;
4. run replicated common-truth bridge and balanced/sparse recovery pilots with
   prespecified MCSE and failure denominators;
5. benchmark memory in isolated processes and record preallocation/design
   dimensions; and
6. only then admit exactly matched, metric-eligible FACETS 4.5.0, TAM, and
   immer comparisons.

No local observation here justifies a feature expansion, a minimum overlap,
a supported capacity ceiling, or a 0.2.3 release decision.
