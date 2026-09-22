# mfrmr 0.2.4 candidate hosted validation record

Status: `candidate_exact_source_five_platform_pass`, 2026-08-26.

## Result

Ordinary workflow run `32938822686` completed successfully on exact head
`356d0fd4149ae275f8cfbf23c59928f37d829555`. All five cells passed their exact
source-tarball package check and repository validation review:

| Platform | Job ID | Result | Started (UTC) | Completed (UTC) |
| --- | ---: | --- | --- | --- |
| macOS release prerequisite | 98085368909 | success | 2026-08-26 06:35:39 | 2026-08-26 06:40:24 |
| Ubuntu release | 98086404242 | success | 2026-08-26 06:40:27 | 2026-08-26 07:18:24 |
| Ubuntu devel | 98086404271 | success | 2026-08-26 06:40:27 | 2026-08-26 06:47:13 |
| Ubuntu oldrel-1 | 98086404295 | success | 2026-08-26 06:40:33 | 2026-08-26 06:47:27 |
| Windows release | 98086404330 | success | 2026-08-26 06:40:26 | 2026-08-26 06:47:08 |

The macOS prerequisite passed the source-truth contract and the
lifecycle-aware maintenance bridge before the remaining four cells opened.
The run created no G4 receipt, candidate tag, CRAN submission, or publication.

## Denominator and lineage

Two earlier candidate runs remain failed evidence:

- run `32936425346` passed its macOS package check but failed the legacy
  literal roadmap-phrase predicate; and
- run `32938041192` passed its macOS package check and repaired source-truth
  predicate but failed the development-only maintenance metadata predicate.

Neither failed run is reinterpreted as successful. The package payload checked
by the successful run is unchanged from the locally checked candidate payload;
changes after the candidate metadata commit are limited to source-package-
excluded roadmap, validation, and repository evidence files.

## Exact fields

- `CandidateHostedRunId=32938822686`
- `CandidateHostedHeadSHA40=356d0fd4149ae275f8cfbf23c59928f37d829555`
- `WorkflowName=R-CMD-check`
- `WorkflowConclusion=success`
- `WorkflowCreatedUTC=2026-08-26T06:35:36Z`
- `WorkflowCompletedUTC=2026-08-26T07:18:24Z`
- `PlatformCells=5`
- `CompletePlatformCells=5`
- `SuccessfulPlatformCells=5`
- `FailedPlatformCells=0`
- `SkippedPlatformCells=0`
- `EachExactSourcePackageCheckPassed=TRUE`
- `EachRepositoryValidationReviewPassed=TRUE`
- `SourceTruthOK=TRUE`
- `MaintenanceBridgeComplete=TRUE`
- `CandidateReadyAtHostedHead=TRUE`
- `ProductionPayloadUnchanged=TRUE`
- `FirstFailedRunId=32936425346`
- `SecondFailedRunId=32938041192`
- `FailedRunsRetainedInDenominator=TRUE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `PublicationPerformed=FALSE`
- `FurtherHostedRetryRequired=FALSE`
- `NextAction=hold-for-explicit-human-sign-off-no-submission`
