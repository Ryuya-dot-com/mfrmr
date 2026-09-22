# ConQuest calibration-harness P2 generation record for mfrmr 0.2.3

Status:
`ASP_G4C_P2_generation_and_bridge_frozen_integrated_harness_incomplete`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-calibration-harness-v1-p2`
- Contract under construction:
  `mfrmr_conquest_adversarial_simulation_calibration_harness_v1`
- Completed subgate: `ASP-G4C-P2-DETERMINISTIC-GENERATION-AND-BRIDGE`
- Next subgate: `ASP-G4C-P3-ENGINE-ADAPTERS-ARTIFACTS-RESOURCES`

## Decision

Freeze a deterministic tranche-A generation provider and the per-dataset
semantic representation bridge without issuing generation authority or
generating any tranche-A response. G4C remains incomplete and live execution
remains unauthorized.

The provider reuses the already validated G3 DGP and uniform-stream machinery.
This avoids creating a second simulation model whose small implementation
differences could masquerade as engine differences. Reuse alone is not
authority: every request must still match one complete frozen tranche-A seed
row and pass a separate target-bound mutable authority gate.

## Allocation and authority boundary

The allocation binder compares all 26 registered identity, design, workload,
retention, and evidence-use fields against the frozen tranche-A seed registry.
Changing the seed, arm, opened state, tuning permission, confirmation
permission, or public-claim permission fails before the generator is reached.

The future generation authority is a one-dataset, one-time, mutable session
object bound to the exact dataset, seed, harness contract, and absent frozen
output target. It additionally requires a successful fresh ConQuest sentinel
from the same process because the upstream runtime contract places that
sentinel before calibration generation. A consumed, stale, widened, opened,
target-mismatched, or sentinel-free authority fails closed. Sentinel booleans
are explicitly insufficient: a later same-process controller must validate its
fresh token. That validator is intentionally absent in P2, so P2 cannot reach
the DGP by itself. Once that controller exists, consumption will occur before
the DGP call, so a failed generation cannot reuse the token.

P2 defines the authority schema but deliberately provides no function or
record that issues a positive authority. Integrated run-once authorization
consumption remains a later capability.

## Deterministic generation contract

The provider preserves the G3 random-stream contract:

- Mersenne-Twister uniform generation;
- Inversion normal method and Rejection sample method;
- latent uniforms before response uniforms;
- exact frozen seed binding; and
- restoration of the caller's RNG kind and state.

The returned in-memory bundle contains a dataset manifest, typed response
relations, a one-row truth registry, and structural disposition. It carries
the source-generator and calibration-harness contracts separately and keeps
tuning, confirmation, and public use false.

Deterministic replay is a reproducibility guard, not a scientific acceptance
criterion. File-byte identity and cryptographic hashes are not inspected by
P2 and cannot substitute for semantic validation or numeric performance.

## Representation bridge

For every paired-missingness dataset, P2 requires four registered checks:

1. observed response relations agree after typed-key sorting;
2. explicit-missing rows are exactly the frozen design complement, with no
   missing, extra, or duplicate key;
3. canonical typed cell maps agree and are anchored to the frozen design's
   labels, indices, covariates, and observed mask; and
4. planned-absence and explicit-missing forms survive the ConQuest-wide
   semantic round trip identically.

All comparisons are semantic. Byte equality is false and cross-engine numeric
agreement is not inspected. A failed check retains the dataset and assigns the
registered generation/schema terminal and representation-bridge secondary
codes; it does not silently drop a row.

As a non-generative regression test, P2 reads the retained G3 tables and
recomputes all four checks for both paired datasets. All eight checks pass.
Adversarial tests independently reject a changed observed response, a removed
design-complement row, a duplicate typed key, an unregistered representation,
a changed observed mask, and a typed index map detached from the frozen design.

## Deliberate incompleteness

P2 advances the capability audit from six to eight available providers by
adding only deterministic dataset generation and the per-dataset bridge.
Ten capabilities remain missing:

- mfrmr q61/q121 adapter;
- ConQuest q61/q121 adapter and parser;
- fresh-sentinel same-process execution controller;
- complete outcome-ledger finalizer;
- registered artifact inventory and unexpected-file guard;
- per-fit and global resource-abort controller;
- prospective G4N eligibility application;
- conditional and unconditional metric summarizer;
- integrated run-once authorization-record consumer; and
- retained execution reviewer.

## Current state

- `UpstreamAndHarnessCapabilitiesAvailable=8`
- `HarnessCapabilitiesStillMissing=10`
- `DeterministicGenerationImplemented=TRUE`
- `SemanticBridgeImplemented=TRUE`
- `RetainedG3BridgeChecks=8`
- `TrancheAResponsesGenerated=FALSE`
- `PositiveGenerationAuthorityIssued=FALSE`
- `FreshSentinelTokenValidatorImplemented=FALSE`
- `EngineAdaptersImplemented=FALSE`
- `ResponseGenerationAuthorized=FALSE`
- `ExecutionAuthorized=FALSE`
- `FreshTrancheASentinelObserved=FALSE`
- `NumericAgreementInspected=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
