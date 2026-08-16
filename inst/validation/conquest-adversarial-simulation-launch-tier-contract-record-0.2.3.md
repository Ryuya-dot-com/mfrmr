# ConQuest adversarial-simulation launch-tier contract for mfrmr 0.2.3

Status:
`runtime_available_unsandboxed_restricted_route_ineligible`, 2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-launch-tier-contract-v1`
- Contract:
  `mfrmr_conquest_adversarial_simulation_launch_tier_contract_v1`
- Executable: `/Applications/ConQuest/ConQuest`
- Launcher: `/usr/bin/arch -x86_64`

## Decision

The consumed G4M sentinel failure is classified as an execution-tier failure,
not as evidence that the installed ConQuest executable is unusable. The exact
path started and completed the data-free `quit;` command outside the Codex
filesystem sandbox under both an interactive terminal and noninteractive file
standard input. TTY availability and file input are therefore not the block.

The restricted run and both controls used no data file and attempted no model
estimation. This route contrast supports rejecting the restricted filesystem-
sandbox route for future ConQuest work. It does not prove the operating-
system mechanism that caused the startup write to fail, establish numerical
agreement, or reopen the consumed authorization.

## Three-way route contrast

| Observation | Execution tier | Input | Result | Interpretation |
| --- | --- | --- | --- | --- |
| Consumed G4M sentinel | restricted Codex filesystem sandbox | file stdin, `quit;` | `SIGSEGV 11`; no terminal marker | restricted route ineligible |
| isolated control 1 | unsandboxed host | interactive TTY, `quit;` | exit 0; `End of Program` | installed path usable |
| isolated control 2 | unsandboxed host | file stdin, `quit;` | exit 0; `End of Program` | noninteractive file input usable |

Both successful controls reported ConQuest 5.47.5, Demonstration Version,
expiring 1 September 2026. The failed run's crash stack reached
`RegistryCheck → CRegistry::WriteInt → XMLFile::Put → fwrite`. That identifies
the crash locus. It does not, by itself, causally prove which denied path,
registry value, compatibility behavior, or memory state produced the invalid
write. The narrower and defensible conclusion is that execution tier explains
the observed usability contrast; a ConQuest product failure is not inferred.

## Contract correction

The former G4L/G4M contract protected a different boundary: ordinary repository
tests were external-runtime-free. It did not require the live R process itself
to run outside the restricted filesystem sandbox. The preflight therefore
passed 32 gates while leaving the actual host execution tier unbound.

A successor may not replace that missing control with a Boolean such as
`unsandboxed=TRUE`, a file hash, or a path check. Before issuing or consuming a
new run-once authority, the future live R process must run the existing
semantic runtime preflight with only `quit;` and obtain exact semantic success.
The successor must supply its executable path, launcher path, and run window
explicitly; the historical `/Applications` location is not a default for new
work. The resulting token is bound to the current process ID, those explicit
paths, launcher route, date/window, version, edition, expiry, terminal marker,
retained console, and no-model state. Token validation rereads the console, so
later mutation invalidates the token. The successor issuer must consume that
token before its authority can be issued. It must then repeat the already
required fresh sentinel after authority consumption.

This two-stage ordering has distinct purposes:

1. the pre-issue probe prevents a known host-route defect from consuming the
   scientific run-once authority; and
2. the post-consumption sentinel preserves the original guarantee that the
   actual run uses a fresh, current-process runtime observation.

Success of either probe is runtime evidence only. It does not pass a fit,
select a tolerance, or authorize confirmation, evidence promotion, or a public
claim.

## Successor boundary

The following remain unsatisfied and deliberately prevent execution:

- a new immutable successor specification;
- a new canonical target whose final and incomplete paths are absent;
- a new target- and process-bound run-once authority;
- explicit user approval for that new attempt;
- a same-process pre-issue semantic probe executed in the admissible host
  context;
- binding all subsequent ConQuest launches to that proven process context;
- a fresh post-consumption sentinel;
- complete console retention; and
- a live date before the demonstration expiry.

The consumed v1 target and authorization remain quarantined. They may not be
replayed, repaired, renamed into success, or treated as though the later
diagnostic controls had occurred before their consumption.

## Authority state

- `ConQuestPathUsableUnsandboxed=TRUE`
- `RestrictedRouteEligibleForSuccessor=FALSE`
- `TtyRequired=FALSE`
- `FileStdinCompatible=TRUE`
- `RegistryWriteCrashLocusObserved=TRUE`
- `RegistryWriteMechanismCausallyProven=FALSE`
- `ProductFailureInferred=FALSE`
- `ConsumedG4MAuthorizationReopened=FALSE`
- `SuccessorExecutionReady=FALSE`
- `ScientificAgreementInferred=FALSE`
- `PublicClaimAuthorized=FALSE`
