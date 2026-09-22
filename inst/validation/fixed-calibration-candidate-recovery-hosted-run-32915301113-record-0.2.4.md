# mfrmr 0.2.4 candidate-recovery hosted workflow record

Status: `development_recovery_five_platform_pass_g6_rebinding_pending`,
2026-08-26.

## Result

The ordinary `R-CMD-check` workflow run `32915301113` completed successfully
against exact development commit
`e39571974f70da0db90444732b5719c187a004d2`. All five required jobs succeeded,
and each job retained its own check artifact. This is a complete fresh matrix;
no cell is borrowed from the invalidated candidate or an earlier run.

| Cell | Job id | Conclusion | Started (UTC) | Completed (UTC) |
| --- | ---: | --- | --- | --- |
| macOS release prerequisite | 98017659754 | success | 2026-08-26 00:29:38 | 2026-08-26 00:35:37 |
| Ubuntu devel | 98018856292 | success | 2026-08-26 00:35:40 | 2026-08-26 00:41:38 |
| Ubuntu release/full | 98018856313 | success | 2026-08-26 00:35:41 | 2026-08-26 01:26:56 |
| Windows release | 98018856356 | success | 2026-08-26 00:35:41 | 2026-08-26 00:44:04 |
| Ubuntu oldrel-1 | 98018856376 | success | 2026-08-26 00:35:40 | 2026-08-26 00:41:28 |

The five unexpired artifacts observed after completion were:

| Artifact | Bytes | Expires (UTC) |
| --- | ---: | --- |
| `r-cmd-check-macos-release` | 18088390 | 2026-11-24 00:29:35 |
| `r-cmd-check-ubuntu-devel` | 18732565 | 2026-11-24 00:29:35 |
| `r-cmd-check-ubuntu-release` | 21390143 | 2026-11-24 00:29:35 |
| `r-cmd-check-windows-release` | 18156555 | 2026-11-24 00:29:35 |
| `r-cmd-check-ubuntu-oldrel-1` | 18710218 | 2026-11-24 00:29:35 |

GitHub's Node.js 20-to-24 runner deprecation annotations are infrastructure
annotations, not R package check warnings, notes, or failures.

## Relationship to the local check and old candidate

The hosted head descends from the locally checked recovery commit
`76b4d65722cf82cc082717750ea14340571918a1`. The four intervening changed paths
are `ROADMAP.md`, the local-check record, the internal HTML roadmap, and the
repository-only G4 evidence test. All four are excluded from the source
package. The hosted workflow therefore exercised the same distributed package
payload as the exact local source check, apart from ordinary build metadata.

This record is evidence input, not a self-authorizing G6 decision. It does not
restore the invalidated candidate, reuse the old transition contract, apply
candidate metadata, create a tag, or authorize submission.

## Exact fields

- `RecoveryHostedRunId=32915301113`
- `RecoveryHostedHeadSHA40=e39571974f70da0db90444732b5719c187a004d2`
- `RecoveryHostedEvent=push`
- `RecoveryHostedStartedUTC=2026-08-26T00:29:35Z`
- `RecoveryHostedCompletedUTC=2026-08-26T01:26:56Z`
- `HostedWorkflowConclusion=success`
- `HostedPlatformCells=5`
- `HostedPassedCells=5`
- `HostedFailedCells=0`
- `CheckArtifactCount=5`
- `ExpiredArtifactCount=0`
- `LocalCheckedAncestorSHA40=76b4d65722cf82cc082717750ea14340571918a1`
- `InterveningSourcePackagePaths=0`
- `OldCandidateInvalidated=TRUE`
- `OldTransitionContractReusable=FALSE`
- `G6Revalidated=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=bind-recovery-g6-and-freeze-new-transition`
