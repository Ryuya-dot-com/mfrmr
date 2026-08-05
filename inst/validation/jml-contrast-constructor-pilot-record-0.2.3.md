# JML observed-contrast constructor pilot record for mfrmr 0.2.3

Date: 2026-08-06

Status: Draft.55 change-local equivalence and performance calibration complete;
no runtime, memory, capacity, release, or confirmation criterion is frozen.

## Purpose and decision boundary

Draft.54 showed that observed-category contrast construction consumed 10.28
of 21.03 exclusive JML recession-component seconds in the fixed 19-route
profile. The former constructor repeatedly extended three triplet vectors
inside observation, alternative-category, and transition loops. Draft.55 asks
whether that pure construction cost can be removed without changing the
observed-versus-alternative contrast matrix, recession audits, fitted object,
or MML route.

The production default now builds one transition template for each possible
observed score, computes the exact stored-entry count, allocates the triplet
vectors once, and fills one contiguous block per observation. The former
algorithm remains available only as an internal `implementation = "reference"`
path for exact comparison. Both paths construct the same sparse contrast
operator and use the same sparse matrix product. There is no public API,
fitted-object schema, readiness, boundary, solver, or likelihood change.

## Adversarial equality controls

The package test `test-jml-contrast-preallocation.R` supplies 977 passing
expectations and zero failures, warnings, or skips. It compares `dgCMatrix`
objects with `identical()`, rather than a numeric tolerance, across:

- 1, 2, 4, 7, and 10 steps; 1, 2, 17, and 101 observations;
- zero, sparse, moderately sparse, and fully dense adjacent designs;
- all-low, all-high, alternating-extreme, balanced, random, and lower-skewed
  category outcomes;
- zero optimizer columns and malformed score, dimension, missing, and range
  inputs;
- permuted observation order;
- a two-Rater criterion-step PCM with lower-category imbalance, missing scores,
  zero/nonuniform weights, a direct Rater anchor, and a Criterion group anchor;
- an interaction RSM; and
- a bounded GPCM with the supported common Criterion step/slope facet.

For each fitted-model control, the production and reference constructors also
produce identical full shared-geometry objects. Existing Draft.54 tests retain
whole structural/joint audit identity and construction-failure fallback.

## Constructor calibration

The guarded repository-only runner executes five deterministic cases, seven
alternating-order timing replicates per implementation, exact output identity,
and one `Rprofmem()` pass per implementation. Its final v3 bundle passes every
identity and completion contract and is independently reproducible from the
promoted directory.

| Case | Preallocated median seconds | Reference median seconds | Time change | Preallocated cumulative R allocation | Reference cumulative R allocation | Allocation change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| category 10, lower-skewed | 0.0100 | 1.1250 | -99.1% | 6,122,680 | 4,372,834,576 | -99.86% |
| dense small | 0.0007 | 0.0047 | -85.7% | 185,592 | 2,784,304 | -93.33% |
| PCM-shaped medium | 0.0033 | 0.1367 | -97.6% | 987,216 | 372,301,832 | -99.73% |
| target sparse | 0.0100 | 2.9200 | -99.7% | 4,905,664 | 11,654,022,984 | -99.96% |
| two-Rater-shaped sparse | 0.0010 | 0.0120 | -91.7% | 248,288 | 21,238,696 | -98.83% |

The allocation measure is cumulative R allocation reported by `Rprofmem()`;
it is not peak resident memory, total C-level allocation, or an isolated-
process capacity result. The smallest timing cells approach the elapsed-clock
resolution. These values demonstrate attribution and feasibility only and do
not define a supported-size envelope.

The v1 bundle is superseded because staging-directory path names leaked into
artifact-inventory row names and prevented post-promotion `identical()`
verification even though all file names, sizes, and hashes matched. v2 removed
those row names. v3 additionally uses the established Draft.49--54 installed-
runtime file set and hash convention, so the constructor and component bundles
resolve to one package identity.

## Fixed 19-route fit comparison

The unchanged Draft.54 component profiler was rerun against the same canonical
Draft.53 semantic baseline with the installed Draft.55 runtime. All 19 fits,
19 phase contracts, 19 component contracts, 19 baseline comparisons, and 19
false-ready checks pass; false-ready count is zero. MML makes no shared-
geometry or contrast-constructor call.

Against the same-day Draft.54 component bundle:

| Measure | Draft.54 | Draft.55 | Change |
| --- | ---: | ---: | ---: |
| observed-contrast exclusive seconds | 10.28 | 0.11 | -98.9% |
| structural recession phase seconds | 14.47 | 4.26 | -70.6% |
| joint recession phase seconds | 6.60 | 6.38 | -3.3% |
| structural plus joint phase seconds | 21.07 | 10.64 | -49.5% |
| JML outer-fit seconds | 31.71 | 21.34 | -32.7% |
| MML outer-fit seconds | 7.49 | 7.39 | -1.3% |

All 12 JML routes reduce combined structural/joint time, with route changes
from -16.7% to -69.5%. The small MML difference is timing noise on an
unaffected route. At the new component boundary, LP solver calls consume 8.01
of 10.60 exclusive seconds (75.6%); target mapping and adjacent-design
construction consume 1.12 and 1.06 seconds, while contrast construction now
consumes 0.11 seconds. LP work is therefore the next measured remainder, not
an automatically authorized solver change.

## Critical limitations and next decision

The fixed fit profile remains one PCM calibration replicate on one Windows
machine. The RSM, GPCM, anchor, interaction, two-Rater, missing, weighting, and
category-imbalance controls establish exact change-local equality, not general
target-scale performance. There is no isolated-process peak-memory result,
replicated fit-level timing distribution, target-scale positive-cone RSM/GPCM
profile, independent LP solver parity, FACETS/TAM/immer comparison, recovery,
coverage, candidate, or confirmation evidence.

Draft.56 should first attribute the 8.01 solver seconds by LP formulation,
status, dimensions, repeated objective/constraint reuse, and model/target
state. It must establish independent solver parity and fail-closed behavior
before considering reusable LP models, warm starts, or solver dispatch. A
favorable timing result alone cannot authorize such a change.

## Evidence identity

Final constructor bundle:
`mfrmr/jml-contrast-constructor-20260806-v3`

Final fixed-route component bundle:
`mfrmr/jml-recession-component-20260806-d55-v1`

| Field | SHA-256 |
| --- | --- |
| Installed Draft.55 runtime, established runtime-content schema | `ab03e1293272a7e77fe3167e28ff42b639912315ff574a76c304d39b82766103` |
| Core source | `d98801ea281ebade76d11678264966148d400c5ad1b6dc8cc0e485a4a0adb61d` |
| Change-local test | `6ddc34e92dded6a3b29fabb1653c97ef5ff8467d6c6abe5fb952d7d46af3309e` |
| Constructor runner | `c77dd91092e88f67cf7de7e001640676a388864be39404d111c652a4d1ef99cd` |
| Constructor execution identity | `b04a2559aa5d5dd613a2a316070cedfb619e79c93574cd1f5e34b2e85c8f493f` |
| Constructor artifact inventory | `67f89101501bd357e7281372cfb58c2955a6419f2c0c9d71d880db7008482069` |
| Constructor completion marker file | `e39f56abac785231d0bae7572d8ab1a77755aec0d67cdf8c0fac2da11f3d837d` |
| Constructor summary CSV | `0af26a4907f433821c44358b049bd00185350a18a0817c16777ccc02283c440d` |
| Constructor timings CSV | `0fa5bfa27810688f51d219a93a0b5933c659dacb883dd8598b44837e8cabd9fd` |
| Constructor memory CSV | `45498a69f87888ef391c362ee5bb3838335da1c3aedabad2e32b5c193b04e1cd` |
| Constructor output-identity CSV | `231d205bbb2f49b53583a06fe21d7e092e4a95ad41b7321a9e57d92e6755b440` |
| Component runner | `26219e45d9691ea168174ba6cd0bed986c65dfbfc6b467bd25c475f7c1650131` |
| Component execution identity | `cb0a4230e310c2ed5fe3ff0a890b1a938907e672826ce5a6e5fb1d5831881777` |
| Component artifact inventory | `8560cf7f08724a685d2f979999d2412352a7eb366c160531c3af7ad6838a6673` |
| Component completion marker file | `a467b6955264379639d9817024b978578cfffa696485fc3d7376486595ee4088` |
| Component result CSV | `bff2804948bb7210a0903e401dd94f05bdd8f30ee4ea23d870ffab266feaadde` |
| Component call CSV | `1ee04953c1e05f71b4c61c9e365a163b194ba07a8b63dae39355168dc72a001b` |
| Component summary CSV | `7faa879a831e89a2e4d974d630228cfebafe9e596576188a7ef59e5b30ae2486` |
| Canonical baseline comparison CSV | `8bc19e93b593ce782c7e3a530c5502101acc856eb6caa2df539a82d2bfa7111f` |

A clean exact local source package contains 493 tar entries and passes
`R CMD check --no-manual` with `Status: OK`, including installation, static and
documentation checks, examples, the CRAN-light test path, and vignette
rebuilding. That standard path records 397 passing expectations, three skips,
and zero failures or warnings. It does not exercise the repository's complete
`NOT_CRAN=true` regression inventory.

The same fixed tarball and its installed package were therefore checked against
all 126 test files from the check-expanded source tree in 10 deterministic,
non-overlapping shards. An aggregate validator verified the common runner and
tarball identities, exact one-time file coverage, and every test-file SHA-256.
The shards record 1,726 tests, 11,945 passing expectations, 83 skips, 38
allowlisted expected/category-support/display warnings, and zero failures,
errors, or unexpected warnings. The aggregate marker SHA-256 is
`8146e45e8c2b5e42c841eca904b59c6e417a0b1468b5594a2b0e0c6c474e7675`;
the summary and exact file manifest SHA-256 values are
`c6df5208163126608ab10df3c7541cfd7d9e9342fd8d7ca4235abfd593462ab0`
and
`49622b703d0794fe056cb561c82907154086804769687307991f4d50c844b12e`.
A monolithic `NOT_CRAN=true` attempt reached the 30-minute execution ceiling
while still in tests and is not recorded as a pass or failure. The successful
sharded regression is separate from, and does not upgrade, the standard
`R CMD check` result.

Tarball, standard-check, and full-regression identities are stored outside the
package source in
`mfrmr/.check-draft55-standard-no-manual-v1/verification-receipt.txt`.

Public `ROADMAP.md` and `NEWS.md` remain unchanged. `--as-cran`, full-manual,
`--run-donttest`, dependency-present external, candidate-linked, and
confirmation evidence remain separate gates for this source change.
