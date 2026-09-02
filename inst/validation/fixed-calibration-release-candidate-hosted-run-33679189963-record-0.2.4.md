# mfrmr 0.2.4 candidate v4 hosted run 33679189963

Status: `candidate_exact_source_five_platform_pass_final_signoff_pending`,
2026-09-03.

## Result

GitHub Actions run `33679189963` completed successfully for exact candidate
head `17b6b3af047bd0a95230ec531769fc44fec12504` on draft pull request 6.
All five required platform cells completed. Each cell passed both the exact
source-tarball `R CMD check` and the repository validation review.

The candidate source is rooted at metadata commit
`84035cb0976bbd69fbd6f4929fe5d77c2d7f04c9`. Later commits add only
source-package-excluded validation evidence and the candidate lifecycle wording
in the source-package-excluded public roadmap. The v4 transition review remains
candidate-ready and submission authorization remains false.

The earlier run `33677797489` remains a failed complete matrix: its macOS
source-package check passed, its repository lifecycle review failed, and the
other four cells did not start. It is not pooled with this fresh successful
run. No tag, merge, publication, final release sign-off, or CRAN submission was
performed.

## Platform denominator

| Platform cell | Job ID | Conclusion |
| --- | ---: | --- |
| macOS release prerequisite | `100411345830` | success |
| Windows release | `100413511896` | success |
| Ubuntu devel | `100413511662` | success |
| Ubuntu release/full | `100413511658` | success |
| Ubuntu oldrel-1 | `100413511745` | success |

Exactly five unexpired check artifacts were retained:

- `r-cmd-check-macos-release`
- `r-cmd-check-windows-release`
- `r-cmd-check-ubuntu-devel`
- `r-cmd-check-ubuntu-release`
- `r-cmd-check-ubuntu-oldrel-1`

## Decision fields

- `WorkflowRunId=33679189963`
- `PullRequest=6`
- `HeadBranch=release/0.2.4-candidate-v4`
- `HeadCommitSHA40=17b6b3af047bd0a95230ec531769fc44fec12504`
- `CandidateMetadataCommitSHA40=84035cb0976bbd69fbd6f4929fe5d77c2d7f04c9`
- `TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v4_api_consistency`
- `WorkflowConclusion=success`
- `RequiredPlatformCells=5`
- `SuccessfulPlatformCells=5`
- `FailedPlatformCells=0`
- `SkippedPlatformCells=0`
- `EachExactSourcePackageCheckPassed=TRUE`
- `EachRepositoryValidationReviewPassed=TRUE`
- `CheckArtifactCount=5`
- `ExpiredCheckArtifactCount=0`
- `PriorFailedRunId=33677797489`
- `PriorFailedRunRetained=TRUE`
- `CandidateReady=TRUE`
- `HumanApiReviewComplete=TRUE`
- `FinalReleaseSignOff=FALSE`
- `CandidateTagCreated=FALSE`
- `PullRequestMerged=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=obtain-final-release-sign-off-no-submission`
