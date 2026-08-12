# ConQuest prospective tolerance-freeze contract record for 0.2.3

Status: generic validator implemented and successor canonical table frozen,
2026-08-12. The generic template remains empty, no candidate is bound, no
ConQuest process is launched, and no scientific-equivalence or confirmation
claim is authorized.

## Decision

The opened additive four-arm calibration cannot supply a threshold and then be
declared to pass that threshold. This record first established the prospective
freeze validator. Its successor basis/freeze layer now supplies a separate
canonical table for a disjoint future candidate; it does not choose a value
that retroactively passes the opened result.

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
  an unhashed or wrong-identity normalizer/precision coverage registry;
- a freeze made after candidate execution;
- candidate outputs already present or opened at freeze; and
- any attempt to make the opened calibration pass the new rule.

Even a structurally complete future preflight authorizes only the six-arm
candidate core. It leaves scientific equivalence, confirmation, sparse
extension, and large simulation false.

## Current result

The generic repository template still has 57 missing numerical rules and
therefore remains a fail-closed fixture. The successor basis/freeze contract
now supplies a separate canonical table with all 57 future-candidate-only
rules ready and SHA-256
`64ab3338dc5e5144d98a7a8775512b5665f407e4d8778972521ff5bfe8754521`.
Its current decision is `tolerance_frozen_candidate_binding_required` because
no exact candidate is bound. Neither the generic synthetic positive fixture
nor the opened calibration is current passing ConQuest evidence.

This slice closes the missing validation mechanism but does not close release
rows `conquest_binary_core`, `conquest_rsm_core`, or `conquest_pcm_core`. Their
evidence status remains `review`.

The Binary adapter and canonical coverage registries are now implemented.
Their 54 rows cover 18 Binary, 16 RSM, and 20 PCM coordinates. The prospective
binding accepts only normalizer registry SHA-256
`a966ae0d4feb2ef64c6374a5d176182bcec32245a54a7d4534752491b44d0cfb`
and source-precision registry SHA-256
`52907c41026726002dcf04167a4b74f94fcd4aa9ca1ac8162c59661b0759734b`.
This closes implementation coverage, not result coverage: retained native
calibration files exist for four RSM/PCM arms and not for Binary q31/q61.

## Verification and identities

The focused test completed with 65 passing expectations, zero failures, and
zero skips. It covers the exact registry, default fail closure, a structurally
complete future fixture, opened-calibration rejection, candidate-output timing,
tolerance-hash binding, exact coverage-registry identities, registry drift,
and unsupported source paths/types. The complete ConQuest-labelled test slice
then completed with 666 expectations,
zero failures, zero errors, zero skips, and zero warnings. A CRAN-light package
check completed with zero errors, zero warnings, and zero notes.

| Artifact | SHA-256 |
| --- | --- |
| `conquest-prospective-tolerance-contract-0.2.3.R` | `d00292ede7985ce36c936a38cebe744478fdb0bffee74b75df025b485ca7b605` |
| `tests/testthat/test-conquest-prospective-tolerance-contract.R` | `ff4dbfad26faa9dea98792cdf56cee35cea691c5f7640623558b31ee02fd1699` |
| `conquest-reported-output-precision-contract-0.2.3.R` | `e0e80ebd96c48634ddd39231959bb0c5cfcd6c036c39c4e5bf8224e19164fd53` |
| `conquest-prospective-tolerance-basis-0.2.3.md` | `9b4c76add31061dcee532fcf2528e2614bd151dca75d3792fbde5364361279bd` |
| `conquest-prospective-tolerance-freeze-0.2.3.R` | `23bd8c5e4f439097afd546f3b726964d18b3438c085fb6cbdf549509e9b420b5` |
| `tests/testthat/test-conquest-prospective-tolerance-freeze.R` | `8641877be59b82e7d3bde9b5f5837e9a6a81c790a2040e73808453d830362681` |
| `conquest-additive-tolerance-adjudication-0.2.3.md` | `d40fa4d4341819bf09a1a0db57943f437c69b10f884568b3e570ca1271ac16d4` |
| `conquest-additive-native-four-arm-record-0.2.3.md` | `c83d344920be0fd4c08db7e6931afb2bdc4f52a0d187bd51434c6cc0d1ef7cdd` |

## Machine disposition

| Field | Value |
| --- | --- |
| `ProspectiveToleranceValidatorImplemented` | `TRUE` |
| `RequiredToleranceRows` | `57` |
| `RequiredCandidateFamilies` | `Binary;RSM;PCM` |
| `RequiredCandidateNodes` | `31;61` |
| `RequiredCandidateArms` | `6` |
| `CurrentToleranceValuesFrozen` | `TRUE` |
| `CurrentToleranceTableSHA256` | `64ab3338dc5e5144d98a7a8775512b5665f407e4d8778972521ff5bfe8754521` |
| `CurrentCandidateBound` | `FALSE` |
| `CurrentReportedOutputPrecisionPolicyFrozen` | `TRUE` |
| `CurrentHiddenSolutionPrecisionPolicyFrozen` | `FALSE` |
| `CurrentBinaryReportedOutputNormalizerReady` | `TRUE` |
| `CurrentSixArmNormalizerImplementationReady` | `TRUE` |
| `CurrentSixArmSourcePrecisionImplementationReady` | `TRUE` |
| `CurrentRetainedNativeCalibrationArms` | `4` |
| `CurrentBinaryRetainedNativeEvidenceAvailable` | `FALSE` |
| `OpenedCalibrationReclassificationAuthorized` | `FALSE` |
| `CurrentCandidateCoreStructurallyAuthorized` | `FALSE` |
| `CurrentCandidateCoreRunAuthorized` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |
