# ConQuest external-comparison normalizer binding for mfrmr 0.2.3

Status: actual retained ConQuest additive output bound to two explicit
source-precision strata, 2026-08-12. Thirty-six exact reported-decimal rows are
structurally eligible; zero hidden-solution rows are eligible. This is not an
equivalence decision, tolerance, candidate freeze, external-input-identity
closure, or authorization for another ConQuest run.

## Decision

The available ConQuest path is no longer represented only by generic accepted
and rejected fixtures. The repository now constructs a 36-row expected
registry before reading numerical results and binds the retained four-arm
RSM/PCM review to the same contract used for every external metric aggregate.
All 36 expected coordinates were observed and finite. Under the original
hidden-solution scope, all 36 remain rejected with
`source_precision_mismatch`. Under the separately validated exact reported-
decimal scope, all 36 enter the structural ledger with metric
`absolute_difference_to_exact_reported_decimal`.

This result is intentionally stricter than inspecting small printed
differences. The native CSV rounding rule and hidden optimizer precision remain
unestablished. The positive state therefore applies only to the exact decimal
tokens actually written to file. It cannot be used as evidence for the
unprinted optimizer solution. An unfamiliar precision label still becomes
`unknown`, not `match`.

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
source-precision axis is evaluated separately for hidden-solution and exact-
reported-decimal strata.

## Actual retained result

The restricted retained bundle
`validation-results/conquest-additive-native-20260811/` was re-read through the
source-bound native reviewer and then through the new adapter. The outcome was:

| Quantity | Hidden solution | Exact reported decimal |
| --- | ---: | ---: |
| Expected rows | 36 | 36 |
| Observed rows | 36 | 36 |
| Successful external-fit rows | 36 | 36 |
| Finite metric rows | 36 | 36 |
| Eligible rows | 0 | 36 |
| Included rows | 0 | 36 |
| Ineligible included rows | 0 | 0 |
| `source_precision_mismatch` rows | 36 | 0 |

The default hidden-solution decision is
`conquest_binding_complete_numeric_rows_excluded_source_precision`. The
reported-output decision is
`conquest_reported_output_rows_eligible_candidate_tolerance_missing`.
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
- a reported-output policy with a changed token, canonical decimal, file hash,
  coordinate set, or hidden-solution promotion is rejected.

## Source binding

| Artifact | SHA-256 |
| --- | --- |
| `conquest-external-comparison-normalizer-0.2.3.R` | `4ad1d05c4a463e10ca334f2a7512f25389f9bc9dcecffecb8d390e491177a8b4` |
| `conquest-additive-native-four-arm-review-0.2.3.R` | `d02f2ab7b4fe26c02d9bf072dbf066f04263afdc9bdf4daf548e9352cae33640` |
| `test-conquest-external-comparison-normalizer.R` | `dc386fdadd7fb00dfbfa68125339b0df32888d44de9ebde3481d1670739b2ffb` |
| `conquest-reported-output-precision-contract-0.2.3.R` | `e0e80ebd96c48634ddd39231959bb0c5cfcd6c036c39c4e5bf8224e19164fd53` |

## Consequence and next gate

This adapter and the reported-output policy close source precision only for the
exact decimals written to file; checklist row 64 remains `review`. The
successor contracts now freeze reported-output-scale tolerances and the exact
source, commands, inputs, and empty outputs for a disjoint six-arm candidate.
Execution remains held on the polytomous mfrmr reference-readiness mismatch.
Hidden-solution equivalence stays unavailable unless ConQuest supplies a
documented rounding interval or a full-precision export. Broad simulation,
sparse-design expansion, and GPCM owner validation remain downstream.
