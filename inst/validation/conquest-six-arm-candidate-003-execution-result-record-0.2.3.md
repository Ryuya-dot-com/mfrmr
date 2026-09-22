# ConQuest candidate-003 execution-result binding for mfrmr 0.2.3

Status: all six ordered executions completed their semantic-success gates and
all 50 expected outputs are bound, 2026-08-12. The execution handoff is
consumed; rerun is prohibited. Formal 57-row numerical adjudication remains
pending in this record.

## Result identity

| Field | Value |
| --- | --- |
| Candidate ID | `mfrmr-0.2.3-conquest-six-arm-003` |
| Execution-result contract | `mfrmr_conquest_six_arm_candidate_003_execution_result_v1` |
| Output-bundle SHA-256 | `efef3f3b18a503b1a70f8bc8667be3655754d2f976e95cf8761a26028a6a0c6a` |
| Execution-summary SHA-256 | `f7bc74ce4cf4fa121333c4de101f37c4d2446d88f30d666ec8f781bdcf58fdc7` |
| Expected outputs | `50` |
| Present and nonempty outputs | `50` |

The output-bundle identity is the SHA-256 of the canonical 50-row ledger of
arm, output role, relative path, pre-execution absence requirement, observed
file SHA-256, and byte count. Thus a later replacement, truncation, or path
substitution fails closed before numerical adjudication.

## Semantic execution summary

| Order | Arm | host status | forbidden patterns | native outputs | console SHA-256 |
| ---: | --- | ---: | ---: | ---: | --- |
| 1 | Binary q31 | 0 | 0 | 6/6 | `fe3cb8c001c2cc0299404fc12427d4898c93119ac53a86fb58db283dae190cae` |
| 2 | Binary q61 | 0 | 0 | 6/6 | `cc5ec33e91d293977b62fc1fc898e7d00b743f81324912162c35ef883f86a776` |
| 3 | RSM q31 | 0 | 0 | 8/8 | `32312497505108a0a68116c4ce5ca36633510048ca8d9b7ae6e4c8884a91174b` |
| 4 | RSM q61 | 0 | 0 | 8/8 | `9c0d4bcf74d3469d1850d138495f025d0e4c3598fe0f99a1bee458efc1e99583` |
| 5 | PCM q31 | 0 | 0 | 8/8 | `a9a64f936c1745c3c51cfea8eee14bd8514acb800ba3ee41caf10958a9610bb5` |
| 6 | PCM q61 | 0 | 0 | 8/8 | `31d2d713cc46fc91aefb45474257f004c80365da050bfc07295be8e7f6fcd656` |

Every console contains `End of Program`; all Binary arms report deviance-
change termination at iteration 132, both RSM arms at iteration 96, and both
PCM arms at iteration 95. The terminal marker and status zero are necessary
but not sufficient: the semantic gate also confirms that none of the eight
frozen failure patterns occurs and that every native output is nonempty.

## Disposition

| Field | Value |
| --- | --- |
| `ExecutionComplete` | `TRUE` |
| `ExecutionHandoffConsumed` | `TRUE` |
| `RerunAuthorized` | `FALSE` |
| `NumericalComparisonReviewAuthorized` | `TRUE` |
| `ComparisonPassed` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `InferenceReady` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `GPCMExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |

The next layer may read the bound native tokens, verify the exact A matrices
and coordinate maps, and apply the already frozen reported-decimal tolerances.
Execution completion alone does not pass a comparison row.

## Source identities

| Artifact | SHA-256 |
| --- | --- |
| `conquest-six-arm-candidate-003-execution-result-0.2.3.R` | `cd450342e1ccec8ca5393f95be3f7a069d7b805a54b3f26da400efa879bb20c3` |
| `conquest-six-arm-candidate-003-execution-handoff-0.2.3.R` | `bbb26927721a60f1787ea838e072dd301dceb8353cca0afc2ff79d253c280201` |
| `tests/testthat/test-conquest-six-arm-candidate-003-execution-result.R` | `52bc5fa99e02ced6438070249b512ceb069db4a88797e455eef14e80eb4892f9` |

