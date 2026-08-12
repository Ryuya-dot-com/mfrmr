# ConQuest prospective tolerance-freeze contract record for 0.2.3

Status: deterministic contract implemented, 2026-08-12. No tolerance value is
frozen, no candidate is bound, no ConQuest process is launched, and no
scientific-equivalence or confirmation claim is authorized.

## Decision

The opened additive four-arm calibration cannot supply a threshold and then be
declared to pass that threshold. The next reusable step is therefore a
prospective freeze validator, not another fit and not a numerical value chosen
from the observed maximum difference.

`conquest-prospective-tolerance-contract-0.2.3.R` implements that validator. Its
default tolerance and candidate-binding templates deliberately fail with
`pilot_required`. A future record becomes structurally ready only after every
required estimand row has a finite, source-bound, frozen rule and the exact
six-arm `Binary/RSM/PCM x q31/q61` candidate is bound before any candidate
output exists or is opened.

## Complete estimand registry

The registry contains 57 unique rows:

| Criterion | Engines | Families | Estimand classes per family | Rows |
| --- | --- | --- | ---: | ---: |
| `EXT-CQ-TOL` | cross-engine | Binary, RSM, PCM | 5 / 7 / 7 | 19 |
| `IC-INTEGRATION-TOL` | ConQuest, mfrmr | Binary, RSM, PCM | 5 / 7 / 7 | 38 |

The Binary classes are population intercept, population slope, population
variance, item difficulty, and positive deviance. The RSM classes are
population intercept, population slope, population
variance, Rater severity, Criterion difficulty, shared step, and positive
deviance. PCM replaces the shared step with the Criterion-specific step. This
prevents an objective-only or pooled maximum from standing in for a failed
parameter class.

For `EXT-CQ-TOL`, signed differences are defined as

`ConQuest - mfrmr`.

For `IC-INTEGRATION-TOL`, signed differences are defined separately within
each engine as

`q61 - q31`.

Each future row must freeze a signed lower bound, signed upper bound, and
absolute tolerance. A later evaluator may pass a retained difference `d` only
if both

`SignedLower <= d <= SignedUpper`

and

`abs(d) <= AbsoluteTolerance`.

The present contract validates the freeze; it does not evaluate or choose the
bounds.

## Admissible rationale and source identity

Every row must use exactly one of three typed bases:

1. `scientific_decision_rule`;
2. `independent_numerical_reference`; or
3. `opened_calibration_future_candidate_only`.

The third type acknowledges that the opened calibration may inform an
engineering error budget for a new candidate. It simultaneously requires
`OpenedCalibrationEligible = FALSE`, so the calibration cannot be
retroactively promoted. Optimizer stopping thresholds, printed decimal units,
absolute paths, parent-directory paths, missing source hashes, and untyped
rationales do not satisfy the contract.

## Candidate timing and identity

The one-row binding requires the package version, Git commit, source-tree
SHA-256, ConQuest 5.47.5 executable SHA-256, command bundle, input bundle,
expected-empty-output manifest, the independently frozen
`conquest-reported-decimal-estimand-v1` policy with scope
`exact_reported_decimal`, and canonical tolerance-table SHA-256. The binding
also requires `HiddenSolutionEquivalenceEligible = FALSE`. The
preflight rejects:

- a tolerance hash mismatch;
- a different or unbound executable;
- a missing, unhashed, not-ready, or candidate-output-informed source-precision
  policy;
- any family, node, arm-count, normalizer-coverage, or source-precision-
  coverage declaration smaller than `Binary;RSM;PCM x 31;61` (six arms), or
  an unhashed normalizer/precision coverage registry;
- a freeze made after candidate execution;
- candidate outputs already present or opened at freeze; and
- any attempt to make the opened calibration pass the new rule.

Even a structurally complete future preflight authorizes only the six-arm
candidate core. It leaves scientific equivalence, confirmation, sparse
extension, and large simulation false.

## Current result

The repository template has 57 missing numerical rules and an unbound
candidate. Its controlling decision is therefore
`hold_tolerance_or_candidate_binding_incomplete`. The synthetic positive test
only proves that a complete future record can be parsed and hash-bound; it is
not current ConQuest evidence.

This slice closes the missing validation mechanism but does not close release
rows `conquest_binary_core`, `conquest_rsm_core`, or `conquest_pcm_core`. Their
evidence status remains `review`.

## Verification and identities

The focused test completed with 62 passing expectations, zero failures, and
zero skips. It covers the exact registry, default fail closure, a structurally
complete future fixture, opened-calibration rejection, candidate-output timing,
tolerance-hash binding, registry drift, and unsupported source paths/types.
The complete ConQuest-labelled test slice then completed with 515 expectations,
zero failures, zero errors, zero skips, and zero warnings. A CRAN-light package
check completed with zero errors, zero warnings, and zero notes.

| Artifact | SHA-256 |
| --- | --- |
| `conquest-prospective-tolerance-contract-0.2.3.R` | `5b9ae8c169348ffe8ab319fcc755c61fa1442e050e85d5e2295c1fe0f2ef318f` |
| `tests/testthat/test-conquest-prospective-tolerance-contract.R` | `ca6d6e58c7dc40bf43571d335cc7f5ec644979cd03ef8186b39242b0a13de3af` |
| `conquest-reported-output-precision-contract-0.2.3.R` | `e0e80ebd96c48634ddd39231959bb0c5cfcd6c036c39c4e5bf8224e19164fd53` |
| `conquest-additive-tolerance-adjudication-0.2.3.md` | `a81bf01a1b654e5b4b6c2254fa16e98f17e8e16264f137fd7bd35e8145813efa` |
| `conquest-additive-native-four-arm-record-0.2.3.md` | `c83d344920be0fd4c08db7e6931afb2bdc4f52a0d187bd51434c6cc0d1ef7cdd` |

## Machine disposition

| Field | Value |
| --- | --- |
| `ProspectiveToleranceValidatorImplemented` | `TRUE` |
| `RequiredToleranceRows` | `57` |
| `RequiredCandidateFamilies` | `Binary;RSM;PCM` |
| `RequiredCandidateNodes` | `31;61` |
| `RequiredCandidateArms` | `6` |
| `CurrentToleranceValuesFrozen` | `FALSE` |
| `CurrentCandidateBound` | `FALSE` |
| `CurrentReportedOutputPrecisionPolicyFrozen` | `TRUE` |
| `CurrentHiddenSolutionPrecisionPolicyFrozen` | `FALSE` |
| `CurrentBinaryReportedOutputNormalizerReady` | `FALSE` |
| `OpenedCalibrationReclassificationAuthorized` | `FALSE` |
| `CurrentCandidateCoreRunAuthorized` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |
