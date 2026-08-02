# mfrmr 0.2.3 MML engine-parity pilot record

## Decision boundary

This is a `0.2.3-draft.13` M2 pilot and structural-regression record. It is not
a release-candidate result and does not freeze `NUM-OBJECTIVE-TOL` or
`NUM-PARAMETER-TOL`, authorize confirmation, authorize model selection, or
establish cross-platform engine agreement.

The pilot compares package execution paths and re-evaluates their retained
vectors through a common package likelihood/score contract. It does not
independently reimplement the marginal likelihood. The independent
central-difference derivative check remains the separate draft.12 G1 record,
and external objective agreement remains a separate gate.

## Identity

| Field | Value |
| --- | --- |
| Specification | `0.2.3-draft.13` |
| Contract | `mfrmr_mml_engine_common_vector_audit_v1` |
| Dependency contract | `mfrmr_mml_canonical_score_audit_v1` |
| Runner | `mml-engine-parity-pilot-0.2.3.R` |
| Run date | 2026-07-28 |
| Repository baseline | `10cf3e8e8ff0` plus the uncommitted draft.13 working-tree changes |
| Branch | `agent/refine-0.2.3-roadmap` |
| DESCRIPTION during development | `0.2.2` (the submitted 0.2.2 release remains isolated) |
| R | R 4.6.1, `aarch64-apple-darwin23` |
| Fixture hashing | digest 0.6.39, SHA-256 |
| Evidence status | `review` |
| Objective/parameter tolerance status | `pilot_required` / `pilot_required` |
| Selection/confirmation authorized | No / No |

Because the working tree is not a frozen candidate, the baseline commit is
context only. M3 must replace it with one exact source/tarball manifest before
candidate-linked evidence is run.

## Fixed design and path contract

All four runs use q=31, `maxit = 2000`, `reltol = 1e-12`, L-BFGS-B for the
direct optimization, and the two fixed fixtures introduced in draft.12.

| Fixture | Seed | Persons | Items | Scores | Rows | SHA-256 |
| --- | ---: | ---: | ---: | --- | ---: | --- |
| `binary_fixed` | 20260741 | 60 | 4 | 0--1 | 240 | `acde9c859ad63d8b1b0736f19ae5869c72384734133eafb7602382d97b9b0f21` |
| `polytomous_fixed` | 20260742 | 60 | 4 | 0--3 | 240 | `383979d685be5719d2844476eeb1126dd586d070c7a1926199ac31f89867ae1e` |

The path meanings are fixed as follows:

- `direct` is the public direct MML route;
- `hybrid` is the public two-iteration EM warm start followed by direct
  optimization;
- `em_raw` is the public EM route run to its native relative-likelihood
  stopping rule and retained only as a diagnostic path; and
- `em_plus_common_direct_polish` runs the same direct optimizer from the exact
  retained `em_raw` free vector. The starting-vector and source-EM SHA-256
  values must be identical before the path is admitted.

The mandatory parity set is `direct`, `hybrid`, and
`em_plus_common_direct_polish`. Raw EM cannot satisfy parity through its native
relative-likelihood criterion alone. Every retained vector, including raw EM,
is re-evaluated through the direct, EM, and hybrid fit contexts at the same
quadrature, identification, free-coordinate ordering, objective, and score.

## Path results

All 16 path runs were complete, reported `InferenceReady = TRUE`, and emitted
no warnings. That observed readiness is descriptive pilot evidence; it does
not replace the common-vector or canonical-score rules.

| Run | Direct max score | Hybrid max score | Raw-EM max score | EM-plus-polish max score | Raw-EM iterations | Raw-EM relative change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `binary_rsm` | 6.7907e-8 | 1.0835e-10 | 3.0386e-5 | 2.3380e-5 | 18 | 4.3173e-13 |
| `binary_pcm` | 6.7907e-8 | 1.0835e-10 | 3.0386e-5 | 2.3380e-5 | 18 | 4.3173e-13 |
| `rsm_core` | 3.1179e-5 | 5.7169e-6 | 8.3854e-5 | 5.0585e-5 | 22 | 7.0848e-13 |
| `pcm_core` | 3.9877e-5 | 3.0888e-6 | 1.6214e-5 | 1.6754e-5 | 52 | 6.4532e-13 |

Every hybrid path used two EM warm-start iterations. Its recorded relative
changes ranged from `2.37e-5` to `7.28e-4`, so hybrid is not interpreted as a
separately converged EM result.

## Common-vector evaluator identity

For each of four runs and four retained path vectors, all three evaluator
contexts produced the same objective and coordinate-wise score. The maximum
objective evaluator range and maximum score evaluator range were both exactly
zero across all 16 summaries. Context structure, free-coordinate labels,
quadrature, and model configuration were also identical.

This exact identity is a structural prerequisite for interpreting path
differences. It does not prove that the package objective is externally
correct.

## Mandatory path-pair observations

| Run | Left | Right | Objective difference | Max free-parameter difference | Max expanded-parameter difference |
| --- | --- | --- | ---: | ---: | ---: |
| `binary_rsm` | direct | hybrid | 5.6843e-14 | 2.9489e-9 | 2.9489e-9 |
| `binary_rsm` | direct | EM-plus-polish | 1.6854e-11 | 1.5052e-6 | 1.5052e-6 |
| `binary_rsm` | hybrid | EM-plus-polish | 1.6911e-11 | 1.5022e-6 | 1.5022e-6 |
| `binary_pcm` | direct | hybrid | 5.6843e-14 | 2.9489e-9 | 2.9489e-9 |
| `binary_pcm` | direct | EM-plus-polish | 1.6854e-11 | 1.5052e-6 | 1.5052e-6 |
| `binary_pcm` | hybrid | EM-plus-polish | 1.6911e-11 | 1.5022e-6 | 1.5022e-6 |
| `rsm_core` | direct | hybrid | 1.3870e-11 | 7.8917e-7 | 7.8917e-7 |
| `rsm_core` | direct | EM-plus-polish | 1.0192e-10 | 2.5672e-6 | 2.5672e-6 |
| `rsm_core` | hybrid | EM-plus-polish | 1.1579e-10 | 2.5636e-6 | 2.5636e-6 |
| `pcm_core` | direct | hybrid | 1.4694e-10 | 2.4597e-6 | 3.4338e-6 |
| `pcm_core` | direct | EM-plus-polish | 9.5326e-11 | 5.7284e-6 | 5.7284e-6 |
| `pcm_core` | hybrid | EM-plus-polish | 5.1614e-11 | 3.5800e-6 | 3.5800e-6 |

The observed maxima were `1.4694e-10` for the objective and `5.7284e-6` for
both free and expanded parameters. The maximum mandatory-path common score was
`5.0585e-5`. These are calibration observations, not acceptance thresholds.
Freezing a rule directly from these four fixed runs would be post-result
tuning.

## Engine and fallback boundary

| Requested scope | Used route | Parity status |
| --- | --- | --- |
| Additive RSM/PCM direct, EM, or hybrid | Requested route; no fallback | Included in this pilot |
| GPCM direct | direct | Not applicable: only one supported engine |
| GPCM EM or hybrid | direct fallback | Excluded from engine parity |
| Model-estimated interaction with EM | direct fallback | Excluded from engine parity |
| Latent regression with hybrid | direct fallback | Excluded from engine parity |

Thus draft.13 does not claim three-engine GPCM parity. It records and tests the
current implementation boundary instead of treating a fallback-to-direct run
as independent-engine evidence.

## Fail-closed checks

The repository test file `test-mml-engine-parity-pilot.R` passed 116
expectations in the targeted run. It covers:

- fixed plan and fixture identities with no source-time fitting;
- exact public-engine and fallback routing identities;
- complete retained/start/source-vector fingerprints and exact EM-polish start
  identity;
- rejection of missing paths, duplicate pairs, incomplete evaluator contexts,
  non-finite objective/score/parameter rows, or unauthorized evidence;
- common-vector objective and score identity over all three evaluator
  contexts; and
- the prohibition on promoting raw EM readiness, observed maxima, or GPCM
  fallback rows into a frozen parity decision.

## Line drawn for 0.2.3

Draft.13 takes the following into the 0.2.3 development baseline:

- the repository-only four-run additive RSM/PCM engine-path pilot;
- exact hashed handoff from converged raw EM to common direct polish;
- common-vector re-evaluation through direct, EM, and hybrid contexts;
- free and sum-zero-expanded parameter comparisons; and
- an explicit fail-closed registry for GPCM, interaction, and latent-regression
  fallback scope.

The following remain unresolved M2 work and cannot be presented as release
evidence yet:

- an expanded fixture/model/parameter-class and platform grid;
- reviewed, margin-based frozen absolute/scaled `NUM-OBJECTIVE-TOL` and
  `NUM-PARAMETER-TOL` rules;
- joint use of the separately frozen canonical-score criterion;
- negative iteration-ceiling/readiness propagation checks under the frozen
  rerun policy;
- disjoint confirmation fixtures/seeds tied to one M3 candidate; and
- independent-platform and external-engine replication where required by G5.

No 0.2.2 source package, submitted tarball, or CRAN release assertion is
changed by this repository-only draft.13 record.
