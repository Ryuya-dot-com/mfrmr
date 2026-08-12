# ConQuest candidate-003 execution handoff for mfrmr 0.2.3

Status: six ordered candidate-003 executions are authorized once, subject to a
mandatory semantic-success gate after every arm, 2026-08-12. The record was
frozen while all 50 expected native and console paths were absent. Comparison
and scientific equivalence remain unauthorized.

## Bound identities

| Field | Value |
| --- | --- |
| Candidate ID | `mfrmr-0.2.3-conquest-six-arm-003` |
| Pre-handoff source commit | `686485da35b325e547786f1b4eb26a53195e572d` |
| Pre-handoff source tree SHA-256 | `564ebcfbf90966f49b4ee7f6fff7afcd3ae689bdf1217f091c9c24c06ca2b8e5` |
| Executable path | `/Applications/ConQuest/ConQuest` |
| Executable SHA-256 | `61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48` |
| Invocation-bundle SHA-256 | `a47873a976ab61e4daee1dbc72591f61d4376b86cd486aaebfd51e12a0ca912c` |
| Candidate binding | `mfrmr_conquest_six_arm_candidate_003_binding_v1` |
| Numerical-reference contract | `mfrmr_conquest_six_arm_candidate_003_reference_v1` |
| Execution-handoff contract | `mfrmr_conquest_six_arm_candidate_003_execution_handoff_v1` |

The executable is the same exact x86_64 ConQuest 5.47.5 demonstration binary
previously probed on this Apple Silicon host. File identity, not the displayed
version or architecture alone, controls this evidence stratum.

## Ordered invocation map

| Order | Arm | working directory | stdin command | console capture | required native outputs |
| ---: | --- | --- | --- | --- | ---: |
| 1 | Binary q31 | `binary/q031a` | `cq_q031a.cqc` | `cq_q031a_run.log` | 6 |
| 2 | Binary q61 | `binary/q061` | `cq_q061.cqc` | `cq_q061_run.log` | 6 |
| 3 | RSM q31 | `additive/rsm_q031` | `cq_additive_rsm_q031.cqc` | `cq_additive_rsm_q031_console.log` | 8 |
| 4 | RSM q61 | `additive/rsm_q061` | `cq_additive_rsm_q061.cqc` | `cq_additive_rsm_q061_console.log` | 8 |
| 5 | PCM q31 | `additive/pcm_q031` | `cq_additive_pcm_q031.cqc` | `cq_additive_pcm_q031_console.log` | 8 |
| 6 | PCM q61 | `additive/pcm_q061` | `cq_additive_pcm_q061.cqc` | `cq_additive_pcm_q061_console.log` | 8 |

Each run receives its command file on standard input and captures standard
output and error together. The next arm may launch only if the preceding arm
meets all of the following conditions:

- host exit status is zero;
- the console contains `End of Program`;
- no frozen semantic-failure pattern is present;
- every arm-specific native output exists and is nonempty.

The failure registry includes unknown commands, regression errors, unavailable
estimation, missing estimated models, compute/print errors, equation-symbol
errors, and a missing data-file declaration. A regression test demonstrates
that the candidate-002 failure text is rejected even when exit status is zero
and `End of Program` is present. This corrects the false-success condition
observed in candidate 002.

## Authorization boundary

| Field | Value |
| --- | --- |
| `CandidateExecutionAuthorized` | `TRUE` |
| `AuthorizedArmCount` | `6` |
| `RunOnce` | `TRUE` |
| `ArmByArmSemanticGateRequired` | `TRUE` |
| `ExistingOutputReuseAuthorized` | `FALSE` |
| `ComparisonAuthorized` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `GPCMExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |

After an arm launches, its run-once authorization is consumed. Semantic
success permits only the next ordered execution; it does not authorize parsing
into the frozen 57-row comparison, equivalence, confirmation, release, sparse
extension, GPCM extension, or simulation.

## Source identities

| Artifact | SHA-256 |
| --- | --- |
| `conquest-six-arm-candidate-003-execution-handoff-0.2.3.R` | `bbb26927721a60f1787ea838e072dd301dceb8353cca0afc2ff79d253c280201` |
| `conquest-six-arm-candidate-003-reference-preflight-0.2.3.R` | `0a6efd41749bc1b144f256a1daf549ee759e453891932ba793668f5c5a574e35` |
| `tests/testthat/test-conquest-six-arm-candidate-003-execution-handoff.R` | `aa7a95a18df51d4a64a9d1874deaba8e1329a712562a3dea6bff9104bbc70d3c` |

