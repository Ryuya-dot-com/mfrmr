# ConQuest candidate-002 execution handoff for mfrmr 0.2.3

Status: exact six-arm external execution authorized once, 2026-08-12. This
record was frozen while all 50 expected native output paths were absent. It
authorizes execution only; comparison and scientific equivalence remain false.

## Bound identities

| Field | Value |
| --- | --- |
| Candidate ID | `mfrmr-0.2.3-conquest-six-arm-002` |
| Pre-handoff source commit | `af7bbb546195d19159e071b292d087709c9753b3` |
| Pre-handoff source tree SHA-256 | `614bf443b178e4c6104228b2d0b798086cd271fb589ee95ff21ab14b42704982` |
| Executable path | `/Applications/ConQuest/ConQuest` |
| Executable SHA-256 | `61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48` |
| Invocation-bundle SHA-256 | `6a7168df4c782ec9d746977cf6d6fcfd27ed7c8c876996a51c8b3ed9a156d066` |
| Candidate binding | `mfrmr_conquest_six_arm_candidate_binding_v2` |
| Numerical-reference contract | `mfrmr_conquest_six_arm_candidate_reference_v1` |
| Execution-handoff contract | `mfrmr_conquest_six_arm_execution_handoff_v1` |

The executable is an x86_64 Mach-O launched on the current Apple Silicon host
through the operating system's compatibility layer. Its exact file identity,
not architecture alone, controls this evidence stratum.

## Exact invocation map

| Order | Arm | working directory | stdin command | combined console capture |
| ---: | --- | --- | --- | --- |
| 1 | Binary q31 | `binary/q031a` | `cq_q031a.cqc` | `cq_q031a_run.log` |
| 2 | Binary q61 | `binary/q061` | `cq_q061.cqc` | `cq_q061_run.log` |
| 3 | RSM q31 | `additive/rsm_q031` | `cq_additive_rsm_q031.cqc` | `cq_additive_rsm_q031_console.log` |
| 4 | RSM q61 | `additive/rsm_q061` | `cq_additive_rsm_q061.cqc` | `cq_additive_rsm_q061_console.log` |
| 5 | PCM q31 | `additive/pcm_q031` | `cq_additive_pcm_q031.cqc` | `cq_additive_pcm_q031_console.log` |
| 6 | PCM q61 | `additive/pcm_q061` | `cq_additive_pcm_q061.cqc` | `cq_additive_pcm_q061_console.log` |

Each run uses the command file as standard input and captures standard output
and standard error together in the named console file. The handoff requires
exit status zero, one run per arm, exact working-directory isolation, the
candidate command/input/model-dimension hashes, six ready numerical
references, and all expected outputs absent immediately before launch. An
existing console or native export invalidates reuse and requires review rather
than an implicit rerun.

## Authorization boundary

| Field | Value |
| --- | --- |
| `CandidateExecutionAuthorized` | `TRUE` |
| `AuthorizedArmCount` | `6` |
| `RunOnce` | `TRUE` |
| `ExistingOutputReuseAuthorized` | `FALSE` |
| `ComparisonAuthorized` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `GPCMExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |

After launch, `CandidateExecutionAuthorized` is consumed. Outputs must be
reviewed against expected completeness, exit status, terminal log markers,
raw-token rules, native A matrices, model dimensions, and the frozen 57-row
tolerance table. Passing execution does not itself pass any comparison row.

## Verification and source identities

The focused handoff completed with 44 expectations and the complete
ConQuest-labelled slice with 829 expectations; both had zero failures, errors,
skips, or warnings. Claim-disposition and release-readiness slices also pass.

| Artifact | SHA-256 |
| --- | --- |
| `conquest-six-arm-execution-handoff-0.2.3.R` | `f867945504c40e9bc731c4db4d1129327849b6ebe8bbca8d3fcc4170f405aa0f` |
| `conquest-six-arm-candidate-reference-preflight-0.2.3.R` | `094923f1228785f16cb5297bcfe17cb78e9bc7931847f4603e82f03ed024e0f8` |
| `tests/testthat/test-conquest-six-arm-execution-handoff.R` | `6f7ff261a34e3a32d40c83e8fe5f83be4e86a565a20cf17df324f1b4ff61b420` |
