# ConQuest external-comparison normalizer binding for mfrmr 0.2.3

Status: actual retained ConQuest additive output bound to the generic
metric-specific eligibility ledger; zero numerical rows eligible, 2026-08-11.
This is a fail-closed normalization result, not an equivalence decision,
tolerance, candidate freeze, external-input-identity closure, or authorization
for another ConQuest run.

## Decision

The available ConQuest path is no longer represented only by generic accepted
and rejected fixtures. The repository now constructs a 36-row expected
registry before reading numerical results and binds the retained four-arm
RSM/PCM review to the same contract used for every external metric aggregate.
All 36 expected coordinates were observed and finite, but all 36 were rejected
with `source_precision_mismatch`. Zero rows entered an aggregate.

This result is intentionally stricter than inspecting small printed
differences. The native CSV tokens are retained, but their rounding rule is
unestablished. The adapter therefore has no positive full-precision state in
version 1: an unfamiliar or newly asserted precision label becomes `unknown`,
not `match`. A future positive precision state requires a new audited contract.

## Pre-result registry

The registry is derived only from the sealed additive plan and its free
parameter maps. It contains the following rows before the review object or any
numeric difference is read:

| Family and integration arm | Expected coordinates |
| --- | ---: |
| RSM, q=31 | 8 |
| RSM, q=61 | 8 |
| PCM, q=31 | 10 |
| PCM, q=61 | 10 |
| Total | 36 |

Each row fixes `Program = ConQuest`, family, `Estimator = MML`, no correction,
no statistical penalty, no finite parameter box, the parameter class, and the
metric `absolute_coordinate_difference`. The result ledger cannot invent a
missing expected row. Missing, failed, and unexpected outputs keep their own
denominators and never become eligible through row omission.

## Cross-manifest identity repair

Before binding, the four-arm reviewer was tightened. It had already verified
individual command, input, native-output, A-matrix, and source-reference file
hashes, but it compared the native and mfrmr reference manifests only by run
ID. It now requires exact equality of `RunId`, model, quadrature nodes, free
dimension, and input SHA-256 across both manifests. The retained evidence
passes this stronger invariant.

Only after that check does the normalizer mark observation, weight, facet,
orientation, category, step-dimension, constraint, coordinate,
identification, and conditioning axes as matched. Anchors and JML-style
boundary output are explicitly not applicable in this MML microcase. The
source-precision axis remains mismatched.

## Actual retained result

The restricted retained bundle
`validation-results/conquest-additive-native-20260811/` was re-read through the
source-bound native reviewer and then through the new adapter. The outcome was:

| Quantity | Result |
| --- | ---: |
| Expected rows | 36 |
| Observed rows | 36 |
| Successful external-fit rows | 36 |
| Finite metric rows | 36 |
| Eligible rows | 0 |
| Included rows | 0 |
| Ineligible included rows | 0 |
| `source_precision_mismatch` rows | 36 |

The binding decision is
`conquest_binding_complete_numeric_rows_excluded_source_precision`.
The historical evidence also remains `CandidateBound = FALSE` and
`ComparisonReady = FALSE`. Those states are reported by the adapter but are
governed independently by the candidate and external-input identity gates.

## Negative controls

Deterministic tests establish that:

- reversing numerical-result order leaves rows, denominators, and reason
  counts identical;
- a missing expected coordinate remains `missing`;
- a completed arm without the terminal ConQuest transcript remains `failed`;
- an extra native coordinate remains `unexpected`;
- duplicate run/coordinate rows and run/model contradictions stop the
  normalizer;
- a cross-manifest input mismatch produces observation and weight rejection;
  and
- an unrecognized precision claim produces `source_precision_unknown` rather
  than eligibility.

## Source binding

| Artifact | SHA-256 |
| --- | --- |
| `conquest-external-comparison-normalizer-0.2.3.R` | `f78d4003d90cec18b3e7e94d0dc648d523f24f1ecdce80a610f6d2770b0919d1` |
| `conquest-additive-native-four-arm-review-0.2.3.R` | `d02f2ab7b4fe26c02d9bf072dbf066f04263afdc9bdf4daf548e9352cae33640` |
| `test-conquest-external-comparison-normalizer.R` | `dc386fdadd7fb00dfbfa68125339b0df32888d44de9ebde3481d1670739b2ffb` |

## Consequence and next gate

This adapter completes the first actual-program plumbing slice, but checklist
row 64 remains `review`: there is deliberately no eligible ConQuest numerical
row. The next step is the already-declared independent numeric-resolution and
prospective-tolerance adjudication, followed by a newly generated,
candidate-bound small core. The ConQuest executable/version/parser/generator
identity remains governed by the separate external-input identity gate. Broad
simulation, sparse-design expansion, and GPCM owner validation cannot repair a
missing precision rule or candidate identity and therefore remain downstream.
