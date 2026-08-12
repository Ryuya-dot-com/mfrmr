# ConQuest six-arm adapter coverage record for mfrmr 0.2.3

Status: deterministic implementation coverage complete, 2026-08-12. No new
ConQuest process was launched. No Binary native output was reconstructed from
the historical prose record. A successor contract freezes a disjoint-future-
candidate table, but no candidate comparison, equivalence, or confirmation is
authorized.

## Decision

The prospective core is `Binary/RSM/PCM x q31/q61`. Before this slice, the
RSM/PCM four-arm path had 36 exact reported-decimal rows, while Binary had only
a historical node-ladder summary. Treating that summary as a retained native
file would erase the provenance distinction the new comparison contract is
meant to enforce.

The Binary adapter therefore defines 18 pre-result rows:

| Coordinate class per arm | Rows over q31/q61 |
| --- | ---: |
| Population intercept, slope, variance | 6 |
| Five free item difficulties | 10 |
| Positive deviance | 2 |
| Total | 18 |

The constrained sixth item is not entered as a ninth free parameter. The row
set matches the eight free coordinates and objective used by the historical
binary likelihood comparison.

## Fail-closed native binding

When a future Binary bundle is supplied, the adapter requires:

- exact q31 (`q031a`) and q61 review identities;
- successful arithmetic handoff with eight free parameters and zero final
  history/export numeric discrepancy;
- equality with the review's five-file native fingerprint over history,
  parameter, regression, covariance, and case-EAP files;
- the audited two-regression, one-covariance, five-item parameter schema and
  item order `I001`--`I005`;
- canonical exact-decimal equality of all eight final history/export tokens;
  and
- a SHA-256-bound mfrmr reference file included in the Binary row-content
  hash.

Without a reported-output policy, all 18 registered rows remain `missing` and
ineligible. A valid policy admits them only to
`absolute_difference_to_exact_reported_decimal`; it never supplies a hidden-
solution interval.

## Six-arm registry

The canonical implementation registry joins 18 Binary, 16 RSM, and 20 PCM
coordinates, for 54 rows and six arms. Normalizer and source-precision
coverage are hashed separately:

| Registry | SHA-256 |
| --- | --- |
| Normalizer coverage | `a966ae0d4feb2ef64c6374a5d176182bcec32245a54a7d4534752491b44d0cfb` |
| Exact reported-decimal coverage | `52907c41026726002dcf04167a4b74f94fcd4aa9ca1ac8162c59661b0759734b` |

All six adapters/parsers are implemented. Retained native calibration evidence
exists for four RSM/PCM arms only. Binary q31/q61 remain unobserved. Candidate
outputs remain absent from this prospective registry.

The prospective tolerance preflight now accepts only these two coverage
hashes. A different but syntactically valid 64-character digest fails closed.

The focused Binary adapter and six-arm coverage tests complete with 37 and 39
passing expectations, respectively. The complete ConQuest-labelled slice
completes with 729 expectations and no failures, errors, skips, or warnings.
A source tarball with rebuilt vignettes passes
`R CMD check --no-manual` with `Status: OK`.

## Source binding

| Artifact | SHA-256 |
| --- | --- |
| `conquest-binary-external-comparison-normalizer-0.2.3.R` | `67cbaaed88bd9afb1249ef5b668bf0a0cffd6b6484b5a426b80e27b4722357c4` |
| `test-conquest-binary-external-comparison-normalizer.R` | `e61312062a33767bec0dfe14ac8aea57bd2e5171e14a15074bfe2b9f21bce3d4` |
| `conquest-six-arm-coverage-contract-0.2.3.R` | `5c24b436b9e5ae16885802d9de77c5c53ebdc874f258faaab9417b9013503dff` |
| `test-conquest-six-arm-coverage-contract.R` | `b63bfbaf2540bd10ecb1508d83e3c6f18b2a8c0149e7ec4b6456c228d20bc894` |

## Machine disposition

| Field | Value |
| --- | --- |
| `CandidateFamilies` | `Binary;RSM;PCM` |
| `CandidateNodes` | `31;61` |
| `RegisteredArms` | `6` |
| `RegisteredCoordinateRows` | `54` |
| `NormalizerImplementationReady` | `TRUE` |
| `SourcePrecisionImplementationReady` | `TRUE` |
| `RetainedNativeCalibrationArms` | `4` |
| `BinaryRetainedNativeEvidenceAvailable` | `FALSE` |
| `FutureCandidateToleranceFrozen` | `TRUE` |
| `SuccessorCandidateBound` | `TRUE` |
| `CandidateExecutionAuthorized` | `FALSE` |
| `ComparisonReady` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
