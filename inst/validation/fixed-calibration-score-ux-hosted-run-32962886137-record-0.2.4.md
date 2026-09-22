# Fixed-calibration score UX hosted run 32962886137 record

Status: `development_score_ux_exact_source_five_platform_pass`, 2026-08-26.

## Result

Ordinary workflow run `32962886137` completed successfully on exact head
`ae3b8b8912722452bb6460f53ccbd81a477531fe`. All five cells passed both the
exact source-tarball package check and the repository validation review:

| Platform | Job ID | Result | Started (UTC) | Completed (UTC) |
| --- | ---: | --- | --- | --- |
| macOS release prerequisite | 98158930201 | success | 2026-08-26 11:21:14 | 2026-08-26 11:25:46 |
| Windows release | 98160112454 | success | 2026-08-26 11:25:50 | 2026-08-26 11:33:50 |
| Ubuntu devel | 98160112472 | success | 2026-08-26 11:25:50 | 2026-08-26 11:33:28 |
| Ubuntu release | 98160112489 | success | 2026-08-26 11:25:50 | 2026-08-26 12:08:08 |
| Ubuntu oldrel-1 | 98160112554 | success | 2026-08-26 11:25:50 | 2026-08-26 11:32:45 |

The run validates the portable-score print, summary, three review plots,
draw-free payload, help article, public lifecycle wording, and source-truth
repair present at that exact head. The earlier run `32961641396` remains a
failed run in the denominator.

## Subsequent local finding

After this hosted run completed, a help-entry audit found that the generated
page described `print()` but did not register `print.mfrm_calibration_score`
or `print.summary.mfrm_calibration_score` as aliases. The methods themselves
were present and tested; the defect affected direct help discovery. The aliases
and the documented invisible return value were added, then the exact source
package and pkgdown site passed locally. Because those changes alter the source
package, this successful hosted run is retained as evidence for its exact head
but is not promoted to evidence for the newer help-index payload.

No candidate metadata, tag, CRAN submission, or publication was produced.

## Exact fields

- `ScoreUXHostedRunId=32962886137`
- `ScoreUXHostedHeadSHA40=ae3b8b8912722452bb6460f53ccbd81a477531fe`
- `WorkflowName=R-CMD-check`
- `WorkflowConclusion=success`
- `WorkflowCreatedUTC=2026-08-26T11:21:11Z`
- `WorkflowCompletedUTC=2026-08-26T12:08:09Z`
- `PlatformCells=5`
- `CompletePlatformCells=5`
- `SuccessfulPlatformCells=5`
- `FailedPlatformCells=0`
- `SkippedPlatformCells=0`
- `EachExactSourcePackageCheckPassed=TRUE`
- `EachRepositoryValidationReviewPassed=TRUE`
- `SourceTruthOK=TRUE`
- `PriorFailedRunId=32961641396`
- `FailedRunRetainedInDenominator=TRUE`
- `LaterHelpAliasPayloadChange=TRUE`
- `HostedRunAppliesToCurrentWorktree=FALSE`
- `CandidateMetadataApplied=FALSE`
- `HumanSignOffComplete=FALSE`
- `CandidateTagCreated=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `PublicationPerformed=FALSE`
- `NextAction=commit-help-index-payload-and-run-new-five-platform-matrix`
