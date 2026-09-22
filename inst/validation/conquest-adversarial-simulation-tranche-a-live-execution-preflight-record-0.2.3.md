# ConQuest tranche-A G4M live-execution preflight record for mfrmr 0.2.3

Status:
`ASP_G4M_same_process_execution_ready_explicit_opt_in_approved_not_yet_consumed`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-tranche-a-live-execution-v1`
- Contract:
  `mfrmr_conquest_adversarial_simulation_tranche_a_live_execution_and_retained_reconstruction_v1`
- Current gate: `ASP-G4M-SAME-PROCESS-ISSUE-CONSUME-SENTINEL-AND-RUN`
- Frozen target:
  `validation-results/conquest-adversarial-simulation-calibration-tranche-a-20260816-v1`

## Decision

The G4M runner is ready for the already approved run-once execution, subject to
a clean committed source tree immediately before authority issue. This record
does not itself issue or consume authority, run ConQuest, generate a tranche-A
response, fit a model, or inspect tranche-A numeric agreement.

The runner contains no top-level execution. Its positive route requires an
explicit `authorize=TRUE`, then performs G4L issue and P4 consumption in the
same R process. It retains the exact 90-dataset, 230-outcome, 190-attempt plan,
including all structural negatives, ordinary failures, and any registered
global-abort rows. No result may alter attempt order, trigger a retry, suppress
a peer, select a threshold, or authorize confirmation or a public claim.

## Adversarial corrections made before consuming authority

The preflight did not accept earlier harness-completeness claims at face value.
It found and corrected four execution-blocking semantic defects:

1. The retained P4 reviewer referred to `authority_snapshot` as though it were
   one of the 14 schema tables. It now reads the separately registered
   `authority_snapshot.csv` explicitly before checking one-run consumption.
2. The old sentinel contract required its root to exist, while generation
   authority required the final calibration target not to exist. G4M now uses
   the exact `<target>.incomplete` staging root for the data-free `quit;`
   sentinel, binds the resulting same-process token to the still-absent final
   target, generates while that target remains absent, and performs one rename
   only after the complete prepared bundle exists.
3. The prospective allowed-path registry lacked the detailed numeric evidence
   ledger needed for retained reconstruction. It now registers
   `numeric_observation_detail.csv`, increasing the exact allowed namespace
   from 1,909 to 1,910 paths without weakening the unexpected-file guard.
4. Numeric extraction was made explicit for successful mfrmr and ConQuest
   outputs. RSM and PCM free coordinates are expanded to their complete
   sum-zero rater, criterion, and step coordinates before any truth, pair, or
   sensitivity comparison. Missing pair IDs are excluded explicitly, and
   names inherited from R indexing cannot silently change coordinate identity.

The absent canonical path is normalized through its existing parent. This
avoids treating a relative nonexistent target as a different identity from its
absolute frozen target.

## Numeric evidence contract

Nine scalar reductions are fixed, each with retained companion detail:

- maximum absolute probability error on the frozen
  theta-by-rater-by-criterion-by-category grid;
- absolute difference between reported deviance and the fitted-coordinate
  continuous oracle, with the oracle's declared numerical error bound;
- mean signed full-coordinate truth error;
- full-coordinate root mean square truth error;
- maximum absolute full-coordinate cross-engine difference;
- maximum absolute full-coordinate q61/q121 difference, with deviance retained
  separately;
- maximum absolute full-coordinate representation difference, with deviance
  retained separately;
- elapsed seconds for each attempted fit; and
- bytes for every one of the 1,511 registered artifacts, including absent
  conditional artifacts as explicit zero-byte units.

Numeric observations are emitted only for G4N diagnostic-eligible units. The
unconditional denominator and failure rows remain in the P4 accounting ledger.
A missing eligible-unit value makes numeric coverage incomplete; it is not
replaced with zero or removed from the denominator. No pooled primary estimate,
threshold, confirmation use, evidence promotion, public claim, or scientific
equivalence decision is authorized.

## Pre-execution verification

- the G4M dry review passed all 32 G4L fatal gates when clean-tree state was
  attested, while issuing no authority and creating no output;
- synthetic RSM and PCM ConQuest exports expanded to the exact 13- and
  19-coordinate full identities with the required sum-zero blocks;
- retained G4X mfrmr and ConQuest RSM exports both parsed to the same exact
  13-coordinate identity with finite values;
- retained G4X mfrmr and ConQuest PCM exports both parsed to the same exact
  19-coordinate identity, with step-block sums zero to floating-point
  precision;
- a stubbed sentinel proved that execution occurs in the exact incomplete
  staging directory while its token is valid only for the absent final target;
- the new G4M tests passed 46 assertions; and
- the related P3, P4, and G4L tests passed 119, 88, and 66 assertions,
  respectively, without launching ConQuest or generating tranche-A responses.

These checks establish execution-contract readiness, not agreement. File-byte
or digest equality is not used as a scientific acceptance criterion.

## State at this record

- `UserRunOnceApprovalReceived=TRUE`
- `AllThirtyTwoG4LGatesPassUnderCleanAttestation=TRUE`
- `PositiveAuthorizationIssued=FALSE`
- `AuthorizationConsumed=FALSE`
- `FreshRuntimeSentinelObserved=FALSE`
- `TrancheAResponsesGenerated=FALSE`
- `FitAttempts=0`
- `ConQuestExecutionAttempted=FALSE`
- `NumericAgreementInspected=FALSE`
- `ThresholdSelected=FALSE`
- `ConfirmationUseAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`

The next step is one clean-tree same-process execution. After output becomes
visible, the run is consumed even if an ordinary fit fails or the retained
review holds; no repair or result-driven rerun is implied.

## Subsequent outcome

The approved attempt was opened later on 2026-08-16 and failed closed at the
fresh data-free ConQuest sentinel before generation or fitting. See
`conquest-adversarial-simulation-tranche-a-live-execution-attempt-record-0.2.3.md`.
This preflight record remains the prospective state at commit `6e81463`; it is
not evidence that the later sentinel passed.
