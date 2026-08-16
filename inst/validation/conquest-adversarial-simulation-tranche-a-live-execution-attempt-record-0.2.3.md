# ConQuest tranche-A G4M live-execution attempt record for mfrmr 0.2.3

Status:
`ASP_G4M_consumed_authority_fresh_sentinel_failed_no_generation`,
2026-08-16.

- Attempted source commit: `6e81463` (`Prepare tranche A run-once execution`)
- Authorization issuer commit: `646a09c`
- Specification:
  `0.2.3-conquest-adversarial-simulation-tranche-a-live-execution-v1`
- Frozen final target:
  `validation-results/conquest-adversarial-simulation-calibration-tranche-a-20260816-v1`
- Retained incomplete target:
  `validation-results/conquest-adversarial-simulation-calibration-tranche-a-20260816-v1.incomplete`
- Attempt time: 2026-08-16 13:02:58 +0900

## Decision

Classify the approved G4M run-once attempt as consumed and fail-closed at the
mandatory fresh data-free runtime sentinel. Do not retry, generate a response,
fit either engine, inspect tranche-A numeric agreement, select a threshold, or
promote evidence under this authorization.

The failure precedes every statistical comparison. It is evidence about the
current ConQuest launch environment, not evidence for or against agreement
between mfrmr and ConQuest.

## Exact state transition

The committed G4M runner performed the following prospective steps in one R
process:

1. rechecked the G4L target, source-tree, scope, runtime-path, and date gates;
2. issued the exact mutable run-once authority;
3. consumed it before any sentinel, generation, or fit;
4. created only the exact `.incomplete` staging root;
5. wrote the six-byte data-free command `quit;`; and
6. launched `/usr/bin/arch -x86_64 /Applications/ConQuest/ConQuest` through the
   frozen 30-second sentinel route.

The ConQuest process terminated with `Segmentation fault: 11`. The semantic
assessment therefore did not satisfy the exact runtime-ready contract, and
sentinel-token construction raised
`A sentinel token requires an exact fresh data-free runtime assessment.` The R
process exited nonzero. Because generation authority requires a valid fresh
token, no subsequent step was reachable.

## Retained filesystem evidence

The final target remains absent. The incomplete target contains exactly two
files created at 13:02:58 +0900:

- `runtime_sentinel.cqc`, 6 bytes; and
- `runtime_sentinel_console.log`, 0 bytes.

The zero-byte console is retained as observed. It is not interpreted as a
successful empty transcript. No response, dataset manifest, truth row, attempt
input, engine artifact, fitted value, or numeric metric was created.

The attempted source wrote the authority snapshot only after a successful
sentinel, so the consumed in-memory authority was lost when R exited. This is a
retention defect, not permission to replay the attempt. The successor source
now writes the consumed authority snapshot before launching the sentinel and
writes a zero-fit failure execution summary if the sentinel raises an error.
That hardening applies prospectively only; it does not rewrite the attempted
bundle or retroactively fabricate `ConsumedAt`.

## Native crash evidence

macOS retained
`~/Library/Logs/DiagnosticReports/ConQuest-2026-08-16-130300.ips` at 13:03:00
+0900. Salient fields are:

- incident `424B2038-179B-491E-ACC0-8435D4BE0E2B`;
- executable `/Applications/ConQuest/ConQuest`;
- x86-64 process with `translated=true` on an arm64 host;
- `EXC_BAD_ACCESS`, `KERN_INVALID_ADDRESS at 0x68`, signal `SIGSEGV`, exit code
  11; and
- the triggered startup stack
  `fwrite → MString::fwrite → XMLElement::Show → XMLDataSet::Show →
  XMLFile::Put → CRegistry::WriteInt → RegistryCheck → SetEnvironment → main`.

This is not an isolated model-file crash. The local diagnostic directory
contains eight earlier ConQuest reports from 2026-08-11, 2026-08-12, and
2026-08-15 with the same registry-write startup stack; the approved G4M attempt
is the ninth observed instance. A separate older report reaches model
estimation and has a different stack, demonstrating that these failure classes
must not be pooled.

## Subsequent execution-tier adjudication

The startup crash did not reproduce outside the restricted filesystem sandbox.
Using the same `/Applications/ConQuest/ConQuest` path and
`/usr/bin/arch -x86_64` launcher, a data-free interactive `quit;` control and a
separate noninteractive file-stdin `quit;` control both reported ConQuest
5.47.5 Demonstration Version, printed `End of Program`, and exited zero. The
latter control matches the failed sentinel's input mode, so neither TTY access
nor file standard input explains the G4M failure.

The corrected classification is therefore
`runtime_available_unsandboxed_restricted_route_ineligible`. The crash stack
identifies a registry/settings-write locus but does not prove its precise
operating-system mechanism. In particular, the observed failure must not be
described as a general ConQuest startup or product failure. See
`conquest-adversarial-simulation-launch-tier-contract-record-0.2.3.md`.

This correction changes the diagnosis, not the run-once state. The later
controls cannot be inserted retroactively before authority consumption, and
they do not authorize a rerun or any statistical comparison.

## Scientific and operational disposition

- `UserRunOnceApprovalReceived=TRUE`
- `PositiveAuthorizationIssued=TRUE`
- `AuthorizationConsumed=TRUE`
- `FreshRuntimeSentinelPassed=FALSE`
- `FinalTargetCreated=FALSE`
- `IncompleteTargetRetained=TRUE`
- `TrancheAResponsesGenerated=FALSE`
- `RetainedDatasets=0`
- `FitAttempts=0`
- `MfrmrFitAttempts=0`
- `ConQuestFitAttempts=0`
- `ConQuestModelEstimationAttempted=FALSE`
- `NumericAgreementInspected=FALSE`
- `ThresholdSelected=FALSE`
- `ConfirmationUseAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
- `RerunAuthorized=FALSE`

The data-free route investigation is complete. A successor attempt would
require a new prospective authority contract, an absent new target, a clean
committed source, explicit new user approval, and a successful same-process
pre-issue semantic probe outside the restricted route before authority is
issued or consumed. A second fresh sentinel remains mandatory after
consumption. Neither the approaching demonstration expiry nor prior successful
retained output waives those requirements.
