# ConQuest six-arm candidate-binding record for mfrmr 0.2.3

Status: candidate 001 invalidated; corrected candidate 002 is source-,
model-dimension-, command-, input-, and empty-output-bound before external
execution, 2026-08-12. No ConQuest process was launched and no expected
candidate output existed or was opened.

## Corrected candidate identity

| Field | Value |
| --- | --- |
| Candidate ID | `mfrmr-0.2.3-conquest-six-arm-002` |
| Package version | `0.2.3` |
| Pre-binding source commit | `8ee7958f7af08141df156b333fe1fc732e2b2bc6` |
| Source tree SHA-256 | `d435e745130fd4eaded7898b31504f1fced8af9e6ac12ff13f43a437dfb48bd9` |
| ConQuest executable SHA-256 | `61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48` |
| Tolerance-table SHA-256 | `64ab3338dc5e5144d98a7a8775512b5665f407e4d8778972521ff5bfe8754521` |
| Command-bundle SHA-256 | `bc0a3cce17f536306c09dc2883d30c1c2852cbff636a40bafe32fede36268fd7` |
| Input-bundle SHA-256 | `cd595bc5a914297ea57f13b1f1fc5d8e6d4d9baacd3f7cadcf380a62806fddcb` |
| Model-dimension SHA-256 | `12dafad2ac6e622288717ec60062f1eeb42c159db253dd46757834335b9e40f5` |
| Expected-empty-output SHA-256 | `161488319712d87f720ef6dce8b1a3b5ae1dd0c2e40eea3897189655870d6d8a` |
| Reported-output policy SHA-256 | `e0e80ebd96c48634ddd39231959bb0c5cfcd6c036c39c4e5bf8224e19164fd53` |

The source-tree value is SHA-256 of the newline-terminated canonical output of
`git ls-tree -r --full-tree` at the pre-binding commit. The ignored local
bundle is `validation-results/conquest-six-arm-candidate-002-core`.

## Why candidate 001 is invalid

Candidate `mfrmr-0.2.3-conquest-six-arm-001` passed family-label, node,
file-hash, and empty-output checks,
but those checks did not bind model dimensions. Its observed polytomous model
statements were `model item + step;` and `model item + item*step;`. They have
neither a Rater nor a Criterion facet and therefore cannot evaluate the frozen
RSM/PCM tolerance rows for `rater_severity`, `criterion_difficulty`, shared
steps, or criterion-specific steps. It is now machine-classified as
`rsm_pcm_item_only_model_dimension_mismatch`; CandidateBindingReady,
CandidateExecutionAuthorized, and ScientificEquivalenceInferred are all
`FALSE`. Its files were never executed.

This is an upstream estimand-identity defect, not a numerical discrepancy.
Family names alone are no longer sufficient for candidate authorization.

## Six corrected arms

| Arm | ConQuest model | free dimension | command SHA-256 | input SHA-256 |
| --- | --- | ---: | --- | --- |
| Binary q31 | `item` | 8 | `61a7e9c9c4f8303deb4eff40027c245d66442eb63021a4109f5ec6c69c2bee6a` | `bd61f489075f5db71774933faf951299ef54082ad95535f38a84b3a0795ef01e` |
| Binary q61 | `item` | 8 | `f0a2d1d5f9c8d30114088da3e61c29b6380e02e769513cb951b08296d72c45ea` | `bd61f489075f5db71774933faf951299ef54082ad95535f38a84b3a0795ef01e` |
| RSM q31 | `rater + criterion + step` | 7 | `4b702d767116f139c27aca209b5b137bfc279e7a2c4eefcb728b8062d841517c` | `391687fd8eb4e9a857950fcf232014833b0259a6ac7b483c7b1f898fdf03cf91` |
| RSM q61 | `rater + criterion + step` | 7 | `a62aa3aa65bdaa73e489088206043f46efc11dec48a1c099e0504d2bdb0e1b06` | `391687fd8eb4e9a857950fcf232014833b0259a6ac7b483c7b1f898fdf03cf91` |
| PCM q31 | `rater + criterion + criterion*step` | 9 | `88de0c97e32032e92111fca64cc2e4c202080c661f4bfedbb1c35dd4b2b6956f` | `391687fd8eb4e9a857950fcf232014833b0259a6ac7b483c7b1f898fdf03cf91` |
| PCM q61 | `rater + criterion + criterion*step` | 9 | `e49bcc244cdd2edd8fcaebea800fd0369403ed986197ac2298717858f6df9538` | `391687fd8eb4e9a857950fcf232014833b0259a6ac7b483c7b1f898fdf03cf91` |

The RSM/PCM commands require the literal native declaration
`facets=criterion(2) rater(2)`. The audit also checks the exact model statement,
quadrature node, input-column count, and family-specific estimand set against
the canonical 57-row tolerance registry. All six local arms pass. The 50-path
empty-output manifest includes the native A matrix for every additive arm;
all 50 paths are absent.

## Readiness boundary

The corrected candidate is structurally bound but execution remains held as
`corrected_many_facet_candidate_reference_and_execution_preflight_pending`.
The next step is to generate and validate source-bound mfrmr numerical
references for these exact inputs, then freeze the execution handoff. A
numerical comparison reference may be converged, finite, oracle-checked, and
locally full rank while remaining explicitly non-inferential. Consequently
`InferenceReady = TRUE` is not silently imposed as a prerequisite for
arithmetic comparison, and numerical agreement must not promote inferential
readiness or scientific equivalence.

| Field | Value |
| --- | --- |
| `CandidateBindingReady` | `TRUE` |
| `LocalBundleVerifiedAtBinding` | `TRUE` |
| `ModelDimensionReady` | `TRUE` |
| `ExpectedOutputRows` | `50` |
| `AllExpectedOutputsAbsentAtBinding` | `TRUE` |
| `CandidateCoreStructurallyAuthorizedWithLocalBundle` | `TRUE` |
| `CandidateExecutionAuthorized` | `FALSE` |
| `ExecutionHoldReason` | `corrected_many_facet_candidate_reference_and_execution_preflight_pending` |
| `OpenedCalibrationReclassificationAuthorized` | `FALSE` |
| `HiddenSolutionEquivalenceEligible` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |

## Verification and source identities

The focused binding test completed with 82 expectations and zero failures,
errors, skips, or warnings. The affected additive-design, reference-preflight,
tolerance, six-arm coverage, claim-disposition, and release-readiness slices
also passed. A source tarball passed `R CMD check --no-manual` under R 4.6.1
with `Status: OK`; sandboxed CRAN/Bioconductor index warnings did not become a
check warning or note.

| Artifact | SHA-256 |
| --- | --- |
| `conquest-six-arm-candidate-binding-0.2.3.R` | `48901c758a37abe13fcff74bbb2742aac6c9177f030841e5b7ad8603330253a6` |
| `tests/testthat/test-conquest-six-arm-candidate-binding.R` | `2a7dfbe49d67488d5efeb366e18cc6de5ac6757a741cb898f24f5809d834977a` |
| `conquest-prospective-tolerance-contract-0.2.3.R` | `d00292ede7985ce36c936a38cebe744478fdb0bffee74b75df025b485ca7b605` |
| `conquest-prospective-tolerance-freeze-0.2.3.R` | `23bd8c5e4f439097afd546f3b726964d18b3438c085fb6cbdf549509e9b420b5` |
| `conquest-reported-output-precision-contract-0.2.3.R` | `e0e80ebd96c48634ddd39231959bb0c5cfcd6c036c39c4e5bf8224e19164fd53` |
