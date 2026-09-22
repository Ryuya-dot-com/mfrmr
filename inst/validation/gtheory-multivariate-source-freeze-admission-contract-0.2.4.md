# Draft.85c4d multivariate G-theory source-freeze admission contract

Date: 2026-08-24  
Scope: internal source snapshot and external-anchor request construction  
Public status: unsupported

## Purpose

Draft.85c4d constructs the content-addressed payload that a future external
freeze service or independent authority would need. It does not modify Git,
create a commit, clean the worktree, build an immutable archive, invent an
external timestamp, contact a service, or issue execution authority.

This layer addresses a distinction that c1 deliberately left open: a stable
content hash proves equality of bytes, while a clean source identity and an
independent timestamped receipt establish different facts. None may be inferred
from another.

## Upstream roots

The admission object pins seven distinct roots:

```text
c1 plan
c1 scientific plan core
c2 generator manifest
c3 closed admission manifest
c4a candidate/receipt manifest
c4b capability-isolation evidence
c4c isolation-integration manifest
```

These roots are historical inputs. c4d does not rebuild, supersede, or reopen
them.

## Git identity

The Git observation records the 40-character HEAD commit, committed HEAD tree,
branch, and a porcelain-status registry with separate staged, unstaged, and
untracked counts. It retains relative paths and status codes but no file
content. `Clean` is derived only when Git is available and the status registry
is empty.

`CleanSourceIdentityReady` additionally requires the supplied identity to
match a second live observation of the current repository exactly. A
self-consistent synthetic identity cannot assert the repository's live state.

The committed HEAD tree is not substituted for the current working snapshot.
When the worktree is dirty, `SourceCommit` identifies the base commit only and
`CleanSourceIdentityReady=FALSE`, even if every selected file has a stable
SHA-256 hash.

c4d never runs `git add`, `commit`, `checkout`, `reset`, `clean`, or any other
mutating Git operation.

## Artifact allowlist

The source registry contains exactly 26 relative paths:

- `DESCRIPTION`;
- the c1 through c4d repository controllers and the two standalone workers;
  and
- the eleven corresponding multivariate regression-test files.

Every file must exist, be nonempty, have a unique allowlisted path, and produce
a SHA-256 digest. The candidate source-tree identity hashes path/hash pairs.
The candidate artifact digest then binds that tree, the complete artifact
registry, and all upstream roots.

This digest describes a logical bundle. No tarball, signed archive, immutable
object-store entry, or release artifact is materialized by c4d. Therefore
`ImmutableArtifactMaterialized=FALSE` regardless of worktree cleanliness.

## External anchor request

The constructed payload binds:

- plan and plan-core hashes;
- the c4c manifest;
- upstream-root, source-tree, and candidate-artifact hashes;
- the base Git commit and committed tree; and
- the c1 external-freeze receipt contract identifier.

The following fields are required from an external response and are never
generated internally:

```text
UTCFreezeTimestamp
SignerOrAuthorityId
ExternalRecordId
ExternalAnchorProvider
ExternalAnchorReference
```

Because no immutable artifact or external response exists,
`ExternalAnchorRequestReady`, `ExternalFreezeReady`, and
`PreOutcomeFreezeExternallyAnchored` remain false. A synthetic clean-status
identity remains descriptive request input: it cannot set
`GitIdentityMatchesCurrentRepository`, `CleanSourceIdentityReady`, or any
external state.

## Fail-closed behavior

Unknown or changed Git fields, forged cleanliness, changed source hashes,
changed upstream roots, rehashed request fields, or opened readiness flags are
rejected against a newly reconstructed canonical object. Both caller
authorization values are rejected before the dispatch callback.

## Disposition

```text
SourceArtifactRegistryReady          = TRUE
CandidateSourceSnapshotReady         = TRUE
GitIdentityMatchesCurrentRepository  = environment dependent
CleanSourceIdentityReady             = environment dependent
AnchorPayloadConstructed             = TRUE
ImmutableArtifactMaterialized        = FALSE
ExternalAnchorRequestReady           = FALSE
ExternalFreezeReady                  = FALSE
PreOutcomeFreezeExternallyAnchored   = FALSE
RecoveryDesignFrozen                 = FALSE
C4CManifestSuperseded                = FALSE
BackendQualificationReady            = FALSE
PilotExecutionAuthorized             = FALSE
ConfirmationExecutionAuthorized      = FALSE
NegativeControlExecutionAuthorized   = FALSE
ExecutionGateClosed                  = TRUE
BackendExecutionOccurred             = FALSE
PlannedResponseGenerated             = FALSE
RecoveryExecuted                     = FALSE
RecoveryEvidenceReady                = FALSE
EstimationReady                       = FALSE
InferenceReady                        = FALSE
DecisionReady                         = FALSE
PublicSupportReady                    = FALSE
```

No external anchor, execution authority, estimator, planned seed, or public
multivariate capability is created.
