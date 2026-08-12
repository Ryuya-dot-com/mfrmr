# ConQuest six-arm candidate-003 binding record for mfrmr 0.2.3

Status: corrected candidate 003 is source-, model-dimension-, command-, input-,
and empty-output-bound after the candidate-002 command-preamble incident,
2026-08-12. No candidate-003 ConQuest process has been launched and none of
its 50 expected native or console outputs exists.

## Candidate identity

| Field | Value |
| --- | --- |
| Candidate ID | `mfrmr-0.2.3-conquest-six-arm-003` |
| Package version | `0.2.3` |
| Post-incident source commit | `4f86fa187e010d3c9faff647c88abc38ddcf5b0f` |
| Source tree SHA-256 | `b1b692bd533cce481d87ed75917070691963ba2abf3caceb0c70ec59299d898f` |
| Command-bundle SHA-256 | `dd273c52bf58edc2f9e96253bcdc2694a29d2cb59d2bc4b45759066c35bb2666` |
| Input-bundle SHA-256 | `cd595bc5a914297ea57f13b1f1fc5d8e6d4d9baacd3f7cadcf380a62806fddcb` |
| Model-dimension SHA-256 | `12dafad2ac6e622288717ec60062f1eeb42c159db253dd46757834335b9e40f5` |
| Expected-empty-output SHA-256 | `161488319712d87f720ef6dce8b1a3b5ae1dd0c2e40eea3897189655870d6d8a` |

The source-tree value is SHA-256 of the newline-terminated canonical output of
`git ls-tree -r --full-tree` at the post-incident source commit. The ignored
local bundle is `validation-results/conquest-six-arm-candidate-003-core`.

## Six bound arms

| Arm | ConQuest model | free dimension | command SHA-256 |
| --- | --- | ---: | --- |
| Binary q31 | `item` | 8 | `9212b6bc128fdeb3117bc992d15afeeb88c37143bf76d996ecf7a007f9fb0a8d` |
| Binary q61 | `item` | 8 | `ab343e081469b40370a979a02662d80996ede8ae22ef46e6319a34da97850a7c` |
| RSM q31 | `rater + criterion + step` | 7 | `4b702d767116f139c27aca209b5b137bfc279e7a2c4eefcb728b8062d841517c` |
| RSM q61 | `rater + criterion + step` | 7 | `a62aa3aa65bdaa73e489088206043f46efc11dec48a1c099e0504d2bdb0e1b06` |
| PCM q31 | `rater + criterion + criterion*step` | 9 | `88de0c97e32032e92111fca64cc2e4c202080c661f4bfedbb1c35dd4b2b6956f` |
| PCM q61 | `rater + criterion + criterion*step` | 9 | `e49bcc244cdd2edd8fcaebea800fd0369403ed986197ac2298717858f6df9538` |

The two Binary command hashes differ from candidate 002 because the rejected
C-style prose preamble was removed. Their first nonblank line is now a
`datafile` command. The four additive command identities are unchanged because
they already consisted only of executable ConQuest input. Every command is
also checked for absence of `/*` and `*/`.

The exact model statement, quadrature node count, input schema, and free
dimension remain bound to the canonical 57-row tolerance registry. Candidate
003 uses fresh output paths; all 50 are absent at binding.

## Readiness boundary

This record establishes structural identity only. It does not authorize an
external process. Source-bound mfrmr numerical references must be audited and
frozen in a separate preflight before an execution handoff can be created.

| Field | Value |
| --- | --- |
| `CandidateBindingReady` | `TRUE` |
| `LocalBundleVerifiedAtBinding` | `TRUE` |
| `CandidateCoreStructurallyAuthorizedWithLocalBundle` | `TRUE` |
| `NumericalReferenceReady` | `FALSE` |
| `CandidateExecutionAuthorized` | `FALSE` |
| `ExecutionHoldReason` | `candidate_003_reference_preflight_pending` |
| `ComparisonAuthorized` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |

## Source identities

| Artifact | SHA-256 |
| --- | --- |
| `conquest-six-arm-candidate-003-binding-0.2.3.R` | `968a5ec6685f9051adfa69bddd18a28d312152182b055d117b39e979ec74387e` |
| `tests/testthat/test-conquest-six-arm-candidate-003-binding.R` | `33c1eaed137106a03a5bf288a89d8139bbbfef20fbea0b84146f05c4e8207751` |

