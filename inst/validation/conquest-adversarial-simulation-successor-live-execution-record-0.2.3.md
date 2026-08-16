# ConQuest tranche-A G4O successor execution freeze for mfrmr 0.2.3

Status: `successor_frozen_unsandboxed_live_preissue_required`, 2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-successor-live-execution-v2`
- Authority:
  `mfrmr_conquest_adversarial_simulation_tranche_a_live_authorization_freeze_v2`
- New final target:
  `validation-results/conquest-adversarial-simulation-calibration-tranche-a-20260816-v2`
- Pre-issue target: `<new-final-target>.preissue`
- Incomplete target: `<new-final-target>.incomplete`
- Executable: `/Applications/ConQuest/ConQuest`
- Launcher: `/usr/bin/arch -x86_64`
- Run no later than: 2026-08-31
- Approval identity:
  `user-2026-08-16-unsandboxed-conquest-successor-run`

## Decision

The user's 2026-08-16 instruction to continue by running ConQuest without the
restricted sandbox is the explicit new approval for this successor only. It
does not reopen the consumed v1 target or its authority.

The successor is deliberately a thin execution-boundary adapter. It reuses the
already frozen 90-dataset, 230-outcome, 190-attempt calibration plan and all
generation, engine, accounting, and resource contracts. It changes only the
target identity, issuer identity, and launch ordering needed to exclude the
observed restricted route.

In the future live R process, the successor must:

1. verify that the v2 final, incomplete, and pre-issue targets are absent;
2. create the retained pre-issue directory;
3. run only `quit;` through the exact launcher and executable;
4. require version 5.47.5 Demo, expiry 2026-09-01, terminal marker, exit zero,
   and no model attempt;
5. bind the successful token to the current R PID, route, date, console, and
   run window;
6. consume that token before issuing the new run-once authority;
7. consume the new authority before the existing fresh sentinel;
8. retain the pre-issue console and every subsequent external console; and
9. make no automatic retry after any opened launch.

Source review and ordinary tests launch no external process. The live path
still requires both the exact approval identity and `authorize=TRUE`. The
calibration remains exploratory: it may estimate failure, variability,
runtime, and storage only. It cannot set a threshold, support confirmation,
promote evidence, establish scientific equivalence, or authorize a public
claim.

The retained reviewer compares nonnumeric fields exactly. For double-valued
CSV round trips it uses a scale-aware bound of
`64 * .Machine$double.eps * max(1, abs(left), abs(right))`. This is an artifact
reconstruction rule, not a scientific agreement threshold. It accepts only the
floating-point reaggregation drift observed in the same retained byte ledger;
it does not round parameter estimates, alter metric values, or authorize a
substantive comparison.

## Frozen state

- `NewSuccessorSpecificationFrozen=TRUE`
- `NewAbsentTargetFrozen=TRUE`
- `NewRunOnceAuthorityFrozen=TRUE`
- `ExplicitNewUserApprovalReceived=TRUE`
- `RestrictedRouteEligible=FALSE`
- `SameProcessPreissueProbeRequired=TRUE`
- `PreissueTokenConsumedBeforeAuthorityIssue=TRUE`
- `PostconsumptionFreshSentinelRequired=TRUE`
- `AutomaticRetryPermitted=FALSE`
- `LiveExecutionPerformedByThisRecord=FALSE`
- `ScientificAgreementInferred=FALSE`
- `PublicClaimAuthorized=FALSE`
