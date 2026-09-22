# Fixed-calibration G6 candidate-recovery decision for mfrmr 0.2.4

Status: `g6_revalidated_after_candidate_invalidation_bounded_api_authorized`,
2026-08-26.

## Decision

G6 is revalidated for exact development payload
`e39571974f70da0db90444732b5719c187a004d2` after the failed candidate-metadata
dry run. The deliberately bounded public scope remains one observed RSM/PCM
scale, MML, a fixed standard-normal scoring basis, stored direct/group facet
anchors, and artifact-only scoring of new Persons. No support lane is added.

This decision authorizes only the construction of a new, independently frozen
release-candidate transition boundary. It does not revive candidate commit
`93d92604ed96bf7ea098b6ff52042106f44acd6b`, reuse transition contract v1,
apply candidate metadata, create a tag, authorize submission, or submit to
CRAN.

## Delta from the prior G6 payload

Relative to the prior G6 payload
`cf20dd0167db3f39224cea7d1c70998b1142f81f`, Git reports 11 changed repository
paths. Ten are release records, internal roadmaps, source-inventory evidence,
or the repository-only G4 evidence test and are excluded from the source
package. The sole changed distributed path is
`tests/testthat/test-vignette-artifacts.R`.

That test now distinguishes exact development provenance from a metadata-only
release transition. Version 0.2.4.9000 still accepts only artifacts generated
with 0.2.4.9000. Release 0.2.4 accepts 0.2.4 or the matching 0.2.4.9000
development identity, while rejecting every other release line. The manifest
continues to state its truthful 0.2.4.9000 generation identity.

No R or compiled production code, calibration schema, scoring kernel, model
likelihood, optimizer, public help, vignette source, README, NEWS body, or
precomputed artifact changed. The prior statistical G4 evidence therefore
continues to address the same implementation and estimand; no new G4 receipt
is issued or inferred from routine package checks.

## Fresh recovery denominator

The exact source-package check at recovery commit
`76b4d65722cf82cc082717750ea14340571918a1` completed with zero errors, zero
warnings, and zero notes. It passed 435 distributed expectations and retained
three explicit CRAN skips for bounded-GPCM design evaluation. The later hosted
head changes only four source-package-excluded paths from that local-check
commit.

Ordinary GitHub Actions run `32915301113` then passed all five fresh cells on
the exact hosted head: macOS release, Windows release, Ubuntu devel, Ubuntu
release/full, and Ubuntu oldrel-1. Exactly five corresponding, unexpired check
artifacts were retained. No failed or missing cell was removed from the
denominator.

## Adversarial disposition

- Treating the manifest as if it had been generated under 0.2.4 would be a
  provenance falsification and remains forbidden.
- Treating the successful matrix as restoration of the old candidate would
  violate the frozen v1 boundary and remains forbidden.
- Re-running the full statistical G4 program would add cost without changing
  the falsifier because statistical executable code and estimands did not
  change.
- Skipping the fresh source and five-platform checks would have left the
  corrected release-boundary test unverified in its distributed context; both
  fresh denominators were therefore required and are now complete.

## Decision fields

- `RecoveryG6DecisionId=mfrmr_fixed_calibration_g6_recovery_0_2_4_v1`
- `PriorG6ValidatedCommitSHA40=cf20dd0167db3f39224cea7d1c70998b1142f81f`
- `PriorG6HostedRunId=32906087561`
- `RecoveryValidatedPayloadCommitSHA40=e39571974f70da0db90444732b5719c187a004d2`
- `ValidatedPayloadCommitSHA40=e39571974f70da0db90444732b5719c187a004d2`
- `HostedRunId=32915301113`
- `HostedWorkflowConclusion=success`
- `HostedPlatformCells=5`
- `HostedPassedCells=5`
- `HostedFailedCells=0`
- `CheckArtifactCount=5`
- `LocalCheckedCommitSHA40=76b4d65722cf82cc082717750ea14340571918a1`
- `LocalSourceCheckStatus=OK`
- `LocalErrors=0`
- `LocalWarnings=0`
- `LocalNotes=0`
- `PathsChangedFromPriorG6=11`
- `DistributedPackageChangedPaths=1`
- `DistributedPackageChangedPath=tests/testthat/test-vignette-artifacts.R`
- `ProductionCodeChanged=FALSE`
- `CalibrationSchemaChanged=FALSE`
- `ScoringKernelChanged=FALSE`
- `StatisticalModelChanged=FALSE`
- `PublicClaimChanged=FALSE`
- `G4Reissued=FALSE`
- `G4StatisticalEvidenceStillApplicable=TRUE`
- `OldCandidateInvalidated=TRUE`
- `OldTransitionContractReusable=FALSE`
- `G6Revalidated=TRUE`
- `G6ExitComplete=TRUE`
- `PublicAPIAuthorizedForRelease=TRUE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=freeze-recovery-transition-boundary`
