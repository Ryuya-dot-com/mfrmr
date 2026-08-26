# Fixed-calibration score help-index hosted run 32969632558 record

Status: `development_score_help_index_exact_source_five_platform_pass`,
2026-08-26.

## Result

Ordinary workflow run `32969632558` completed successfully on exact head
`0e9dffbca716beb703c01cdeab9146eabd38e07f`. All five cells passed both the
exact source-tarball package check and repository validation review:

| Platform | Job ID | Result | Started (UTC) | Completed (UTC) |
| --- | ---: | --- | --- | --- |
| macOS release prerequisite | 98180063227 | success | 2026-08-26 12:38:19 | 2026-08-26 12:44:29 |
| Ubuntu devel | 98181891498 | success | 2026-08-26 12:44:34 | 2026-08-26 12:50:30 |
| Windows release | 98181891534 | success | 2026-08-26 12:44:34 | 2026-08-26 12:52:26 |
| Ubuntu oldrel-1 | 98181891535 | success | 2026-08-26 12:44:34 | 2026-08-26 12:50:58 |
| Ubuntu release | 98181891573 | success | 2026-08-26 12:44:34 | 2026-08-26 13:39:09 |

This exact head includes direct help aliases for score `print()` and summary
`print()` as well as the previously validated score summary and three plot
routes. The earlier failed run `32961641396` and the earlier successful run
`32962886137` remain in the evidence lineage.

## Subsequent local finding

After this hosted run started, the accessibility audit identified two
reader-facing refinements: the article's primary interval figure needed
semantic alternative text, and the plot subtitle used the mechanical phrase
`review disposition(s)`. The current local payload adds meaningful alternative
text, keeps score/review states distinguishable by shape as well as color, and
uses grammatical singular/plural text. That newer payload passed the exact
source check and public-site pkgdown build locally but requires a new hosted
matrix. This successful run is not reclassified or applied to the newer
payload.

No candidate metadata, tag, CRAN submission, or publication was produced.

## Exact fields

- `ScoreHelpIndexHostedRunId=32969632558`
- `ScoreHelpIndexHostedHeadSHA40=0e9dffbca716beb703c01cdeab9146eabd38e07f`
- `WorkflowName=R-CMD-check`
- `WorkflowConclusion=success`
- `WorkflowCreatedUTC=2026-08-26T12:38:16Z`
- `WorkflowCompletedUTC=2026-08-26T13:39:10Z`
- `PlatformCells=5`
- `CompletePlatformCells=5`
- `SuccessfulPlatformCells=5`
- `FailedPlatformCells=0`
- `SkippedPlatformCells=0`
- `EachExactSourcePackageCheckPassed=TRUE`
- `EachRepositoryValidationReviewPassed=TRUE`
- `SourceTruthOK=TRUE`
- `PriorFailedRunId=32961641396`
- `PriorSuccessfulRunId=32962886137`
- `FailedRunRetainedInDenominator=TRUE`
- `LaterAccessibilityPayloadChange=TRUE`
- `HostedRunAppliesToCurrentWorktree=FALSE`
- `CandidateMetadataApplied=FALSE`
- `HumanSignOffComplete=FALSE`
- `CandidateTagCreated=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `PublicationPerformed=FALSE`
- `NextAction=commit-accessible-visual-payload-and-run-new-five-platform-matrix`
