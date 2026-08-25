# Draft.85c4b multivariate G-theory capability-isolation record

Date: 2026-08-24  
Scope: macOS default-deny worker boundary and six live controls  
Result: runtime-bound process capability isolation ready; execution closed

## Outcome

One c2 nonreserved candidate fixture completed the normal c4a receipt path
inside the generated macOS profile. Five capability-negative invocations each
returned a typed result while the protected action remained unsuccessful.

Nine focused tests and 76 expectations pass without failure, error, warning,
or skip when `MFRMR_RUN_C4B_MACOS_SANDBOX=true`. The ordinary test route keeps
the four live evidence blocks opt-in because a nested sandbox cannot be created
on every host.

The combined Draft.85a0 through c4b suite passes 82 tests and 1,090
expectations across nine files with no failure, error, warning, or skip.

No c1 planned seed was opened, no planned response was generated, and no
backend was called. ConQuest at `/Applications/ConQuest` was not launched.

## Bound runtime

The live observation records:

```text
OS          Darwin 25.5.0
Machine     arm64
R           4.6.1 (2026-06-24)
```

The runtime identity additionally binds the exact `sandbox-exec`, `env`,
direct R executable, Apple `system.sb`, digest version/path, c4a candidate
worker, and c4b capability worker. R is launched directly under `env -i`; the
Rscript wrapper is not part of the sandboxed process chain.

The first attempt to nest `sandbox-exec` inside the managed Codex sandbox was
rejected by the outer host with `sandbox_apply: Operation not permitted`.
Therefore the final live test was run outside that parent sandbox, with the
target c4b profile still active. This is a host-nesting limitation, not a
relaxation of the target worker profile.

## Control observation

| Mode | Sandbox status | Action succeeded | Parent secret visible | Denial class |
| --- | ---: | --- | --- | --- |
| normal | 0 | true | false | `normal_candidate_receipt` |
| probe_vault_read | 0 | false | false | `sandbox_operation_denied` |
| probe_source_read | 0 | false | false | `sandbox_operation_denied` |
| probe_outside_write | 0 | false | false | `sandbox_operation_denied` |
| probe_parent_environment | 0 | false | false | `parent_environment_absent` |
| probe_unlisted_exec | 0 | false | false | `sandbox_operation_denied` |

All six typed output receipts existed, all six control assertions passed, and
the forbidden output file was not created. The deterministic staging content
was removed after the run.

The profile audit also confirms default deny, absence of `allow default`, no
c4b-added network allow, and exclusion of the vault, repository, and forbidden
output paths. Apple `system.sb` itself permits local syslog and selected system
IPC; the result is therefore an external-network policy-closure claim, not a
zero-IPC claim. The exact imported profile hash prevents that distinction from
being hidden by a future OS change.

## Replay identities

```text
PlanHash                       51f6d05a596cf05157b7599f48f29c144038e23b89cad045c47d8560d370cac2
GeneratorManifestHash          1bc7f3dd126803ab7d6165a8c81e6fe1a9e8ad7fa0e13ebdd5f7c4993f718308
RuntimeIdentityHash            613952e3d05276f230edf012cbeb41a4c0ebe72b3f5ea804548b2eed789b0386
ProfileHash                    f5147e747945eaa4bd0c9ab9868ba1a0431996c22c4f7f68eae26662dc9a2d60
ProfileSemanticHash            35a33e747284d764cb4902228e22770596b7a71c41a3f4dcfe33d409b6f59186
PolicyAuditHash                85e58d259726c244d840bfbb18929821a7cd5c5effbe51595a84c2a8e9c50a50
ControlRegistryHash            84acb606d6f4b7829ca1899b926888155c6af3ef7235d6ccfd72f8649e413cfa
NormalCandidateReceiptHash     77b7b1310ba2a432b8f9cf77f4c41ee3280f6a7eea56f2e6586837f10b387221
ReferenceVaultHash             7a9d9eec673d0423b5585c4c48d2050bd6f2cf67b7fdde712cdbd79131628f73
ImplementationIdentityHash     6d63572d6a62ba651c7d5cba42b06fb02bde4d3d3d136d331389ed7b23ed9bf1
EvidenceHash                   f93584a4e4f3b8275c25ac5d8a31fd6eb9ccb5583dc8c6ced167da4598b1fb8c
```

The concrete profile hash includes the deterministic staging path. The
semantic profile hash replaces that path with a stable placeholder. Both are
bound so a replay can distinguish policy meaning from run-local identity.
The reference-vault hash binds the exact one-fixture truth-side object used by
the denied-read control while retaining none of its fields in evidence.

## Disposition

`ProcessCapabilityIsolationReady` and
`TruthBlindProcessBoundaryReady` are true for this exact one-fixture c4b
worker path and runtime. c3 remains a historical closed admission record; it
is not retroactively rewritten.

External content/source freezing, a clean-source receipt, ABI-consistent
four-route backend qualification, an independently fixed accuracy rule, and
lane-specific authority remain false. Consequently pilot and confirmation
execution, recovery evidence, inference, decisions, and public support all
remain closed.

Draft.85c4b adds no export, help topic, vignette, NEWS entry, or public-roadmap
claim. Multivariate G-theory remains unsupported publicly.
