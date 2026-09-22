# Fixed-calibration API consistency hosted run record for 0.2.4

Date: 2026-08-27

## Decision

GitHub Actions run `32990152654` completed successfully for the API-consistency
production payload at commit `036565f583d441c599d6650391dc0523c36d0210`.
All five required platform cells completed. In each cell, the exact source
package check and repository validation review succeeded.

Run creation was delayed during the GitHub Actions major outage reported on
2026-08-26 UTC. A later empty trigger commit,
`322f1880aabab20724294d0b92d144a24cecc1f3`, did not alter the Git tree. Both
commits resolve to tree `755dc77cd398f12f12438e43bc440b847216c336`.
The hosted evidence therefore applies to the current production payload, while
the run's exact commit identity remains recorded rather than rewritten.

Each job emitted one GitHub-hosted infrastructure annotation that
`actions/checkout@v4` and `actions/upload-artifact@v4` target deprecated Node.js
20 and were forced onto Node.js 24. This was not an R package check warning and
did not alter the successful job conclusions. Updating those action versions is
maintenance work and was not mixed into this validated payload.

This closes the automated API-consistency matrix only. Human review, candidate
metadata, tag creation, publication, and CRAN submission remain incomplete.

## Hosted evidence

| Platform cell | Job ID | Conclusion |
| --- | ---: | --- |
| macOS release prerequisite | `98245566586` | success |
| Windows release | `98247936668` | success |
| Ubuntu devel | `98247936708` | success |
| Ubuntu release (`NOT_CRAN=true`) | `98247936745` | success |
| Ubuntu oldrel-1 | `98247936783` | success |

Run URL:
`https://github.com/Ryuya-dot-com/mfrmr/actions/runs/32990152654`

## Machine-readable disposition

- `WorkflowRunId=32990152654`
- `WorkflowConclusion=success`
- `ValidatedPayloadCommitSHA40=036565f583d441c599d6650391dc0523c36d0210`
- `CurrentHeadSHA40=322f1880aabab20724294d0b92d144a24cecc1f3`
- `ValidatedTreeSHA40=755dc77cd398f12f12438e43bc440b847216c336`
- `CurrentTreeSHA40=755dc77cd398f12f12438e43bc440b847216c336`
- `ProductionPayloadUnchanged=TRUE`
- `GitHubActionsOutageDelayedRunCreation=TRUE`
- `PlatformCells=5`
- `CompletePlatformCells=5`
- `SuccessfulPlatformCells=5`
- `FailedPlatformCells=0`
- `SkippedPlatformCells=0`
- `EachExactSourcePackageCheckPassed=TRUE`
- `EachRepositoryValidationReviewPassed=TRUE`
- `APIConsistencyPayloadValidated=TRUE`
- `InfrastructureDeprecationAnnotations=5`
- `InfrastructureAnnotationsArePackageWarnings=FALSE`
- `CurrentPayloadHostedMatrixComplete=TRUE`
- `HumanSignOffComplete=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `PublicationPerformed=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=hold-for-human-api-review-before-candidate-transition`
