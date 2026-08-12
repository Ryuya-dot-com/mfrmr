# ConQuest six-arm candidate-binding record for mfrmr 0.2.3

Status: exact candidate binding and ignored local bundle verified before
external execution, 2026-08-12. No ConQuest process was launched, no expected
output existed or was opened at binding, and candidate execution remains held.

## Candidate identity

| Field | Value |
| --- | --- |
| Candidate ID | `mfrmr-0.2.3-conquest-six-arm-001` |
| Package version | `0.2.3` |
| Source commit | `7a04fd4cde65d4be985aa2a908ab4d8e65fadba5` |
| Source tree SHA-256 | `bcb700d2757afab3aa1e2330210e36add4bc59cdc2f44e458762b445014a4f4b` |
| ConQuest executable SHA-256 | `61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48` |
| Tolerance-table SHA-256 | `64ab3338dc5e5144d98a7a8775512b5665f407e4d8778972521ff5bfe8754521` |
| Command-bundle SHA-256 | `be3127562ea8011b8076b8d1f3a0a5213ba5444803ee567fcbab0941c36874e4` |
| Input-bundle SHA-256 | `a7d30cb32b08ccb3f50b89dfc21f14352241ff648743ba207c2c38fcbb905fa1` |
| Expected-empty-output manifest SHA-256 | `9850792b061b1d9d5dfdfe360e65e5c6b65fd6e35d70aa3dc0a81ae8f126ce43` |
| Reported-output policy SHA-256 | `e0e80ebd96c48634ddd39231959bb0c5cfcd6c036c39c4e5bf8224e19164fd53` |

The source-tree value is SHA-256 of the newline-terminated canonical output of
`git ls-tree -r --full-tree` at the bound commit. It is not the 40-character
Git tree object ID. The local executable hash was checked against
`/Applications/ConQuest/ConQuest`; the absolute path is runtime provenance and
is not stored in the machine binding.

## Six arms and source precision

The binding contains exactly `Binary/RSM/PCM x q31/q61`:

| Arm | Command SHA-256 | Input SHA-256 |
| --- | --- | --- |
| Binary q31 | `61a7e9c9c4f8303deb4eff40027c245d66442eb63021a4109f5ec6c69c2bee6a` | `bd61f489075f5db71774933faf951299ef54082ad95535f38a84b3a0795ef01e` |
| Binary q61 | `f0a2d1d5f9c8d30114088da3e61c29b6380e02e769513cb951b08296d72c45ea` | `bd61f489075f5db71774933faf951299ef54082ad95535f38a84b3a0795ef01e` |
| RSM q31 | `8a28252f97b67adccadf950788375285a926d543de643addd14776e07b03bb1c` | `875106ce5fc501c76229eda00aa37b4a0556d352233c2990347d263d59cce3ce` |
| RSM q61 | `1bf284d2555da1b454d8baa7a81c5af26ffff72e40dd7658d1cfb1c9a80cadfb` | `875106ce5fc501c76229eda00aa37b4a0556d352233c2990347d263d59cce3ce` |
| PCM q31 | `4ae9c62724ff7481e1c7ed29f913ade09d68c3e7ed972a439aa6a7e66ad80232` | `875106ce5fc501c76229eda00aa37b4a0556d352233c2990347d263d59cce3ce` |
| PCM q61 | `47646f249bff4b038d6a4ba63e95423b29f2b532181211e1dde3833623e4b6cb` | `875106ce5fc501c76229eda00aa37b4a0556d352233c2990347d263d59cce3ce` |

The Binary pair uses the existing binary fixture/bundle generator. The
polytomous inputs use the existing fixed-seed fixture and the RSM/PCM command
generator without creating a new model or response generator. The local files
remain under the ignored relative root
`validation-results/conquest-six-arm-candidate-001-core`; Person-level input
is not committed.

The output manifest has 46 unique paths: seven per Binary arm and eight per
polytomous arm because the latter also requests the internal ConQuest log. At
binding, all six command hashes and input hashes matched, and all 46 expected
outputs were absent. The source-precision policy remains
`conquest-reported-decimal-estimand-v1` with scope `exact_reported_decimal`;
hidden optimizer equivalence remains ineligible.

## Why execution remains held

Reusing the full historical node-ladder preparation was rejected. It begins
with q7, and current readiness correctly prevents an out-of-scope coarse arm
from being treated as inference-ready. Filtering the old preparation to the
four q31/q61 polytomous arms revealed a more important contract mismatch: the
old helper requires `MfrmrInferenceReady = TRUE` before it writes a reference,
whereas current v3 readiness retains these fits as `review`.

For the direct RSM q31 check, optimization itself converged with code zero,
terminal gradient sup-norm approximately `4.82e-6`, finite boundary state, and
ready numerical state. The constrained linear adjacent-logit design had rank
8, nullity 0, while the optimizer free dimension was 9 because log population
variance is nonlinear. The observed-pattern marginal score audit spanned all
9 coordinates, and nonlinear local estimability was
`locally_full_rank_sufficient`. Nevertheless, global and continuous-integral
identification remain unclassified by design, so local first-order rank cannot
silently promote the fit to inference-ready.

The same result holds for all four polytomous reference cells. RSM q31/q61
have locally full ranks 9/9 and terminal gradient sup-norms about
`4.82e-6`/`4.84e-6`; PCM q31/q61 have locally full ranks 17/17 and terminal
gradient sup-norms about `3.06e-5`/`3.09e-5`. All four converged, but all four
remain `FitReadiness = review`, `InferenceReady = FALSE`, with reason
`design_rank_not_evaluated`.

The binding therefore records
`polytomous_mfrmr_reference_inference_readiness_unresolved`. This is not a
ConQuest discrepancy and cannot be repaired by executing ConQuest. The next
step is to reconcile the old reference-generator precondition with the current
readiness semantics: either define a numerical-comparison-only reference state
that explicitly remains non-inferential, or establish the stronger
identification evidence required for inference-ready status. That decision
must precede external execution.

## Machine disposition

| Field | Value |
| --- | --- |
| `CandidateBindingReady` | `TRUE` |
| `LocalBundleVerifiedAtBinding` | `TRUE` |
| `ExpectedOutputRows` | `46` |
| `AllExpectedOutputsAbsentAtBinding` | `TRUE` |
| `GenericProspectivePreflightStructurallyReady` | `TRUE` |
| `CandidateCoreStructurallyAuthorizedWithLocalBundle` | `TRUE` |
| `CandidateExecutionAuthorized` | `FALSE` |
| `ExecutionHoldReason` | `polytomous_mfrmr_reference_inference_readiness_unresolved` |
| `OpenedCalibrationReclassificationAuthorized` | `FALSE` |
| `HiddenSolutionEquivalenceEligible` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |

## Verification and source identities

The focused binding test completed with 63 expectations and the complete
ConQuest-labelled slice with 729 expectations. Both had zero failures, errors,
skips, or warnings. The source-loaded claim-disposition, release-readiness,
P1p, and GPCM model-identity slices passed; the P1p stored-result audit had its
one declared opt-in skip. A source tarball with built vignettes passed
`R CMD check --no-manual` under R 4.6.1 with `Status: OK`. Repository network
restrictions prevented refreshing CRAN/Bioconductor indexes, but produced no
check error, warning, or note.

| Artifact | SHA-256 |
| --- | --- |
| `conquest-six-arm-candidate-binding-0.2.3.R` | `cbeca1bef0c2fcc010898b8f986f0a44c1f9c4f53ab43d66858b5302581c1c4d` |
| `tests/testthat/test-conquest-six-arm-candidate-binding.R` | `cef0d0eea14a240b6a590193a2e0e8903a7851e0c0be0c4c8324b2f9bed6be2b` |
| `conquest-prospective-tolerance-contract-0.2.3.R` | `d00292ede7985ce36c936a38cebe744478fdb0bffee74b75df025b485ca7b605` |
| `conquest-prospective-tolerance-freeze-0.2.3.R` | `23bd8c5e4f439097afd546f3b726964d18b3438c085fb6cbdf549509e9b420b5` |
| `conquest-reported-output-precision-contract-0.2.3.R` | `e0e80ebd96c48634ddd39231959bb0c5cfcd6c036c39c4e5bf8224e19164fd53` |
