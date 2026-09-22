# mfrmr 0.2.4 candidate v4 hosted run 33677797489

Status: `candidate_source_check_pass_repository_lifecycle_fail`, 2026-09-03.

## Result

The first hosted run for candidate v4 failed as a complete matrix. The macOS
prerequisite built and checked the exact 0.2.4 source tarball successfully,
then the repository validation review failed because `ROADMAP.md` still
described 0.2.4.9000 as under development while `DESCRIPTION` identified the
source as the 0.2.4 candidate. `SourceTruthOK` and
`RoadmapLifecycleMatches` were false. The remaining four platform cells did
not start after the prerequisite failure and remain in the denominator.

The root cause is repository-only lifecycle text, not package code or a
statistical result. The correction changes only the two current-release
sentences in `ROADMAP.md` from development to candidate wording. The roadmap
is excluded from the source tarball and is an allowed v4 transition path.
Local evaluation after the correction returns `RoadmapLifecycleMatches=TRUE`
and `SourceTruthOK=TRUE`. The failed run is not relabelled or pooled with a
later run.

## Exact fields

- `WorkflowRunId=33677797489`
- `PullRequest=6`
- `HeadBranch=release/0.2.4-candidate-v4`
- `HeadCommitSHA40=05258e1b753892e1902a5be3b9e804bfa0a919b6`
- `WorkflowConclusion=failure`
- `RequiredPlatformCells=5`
- `SuccessfulPlatformCells=0`
- `FailedPlatformCells=1`
- `NotStartedPlatformCells=4`
- `MacOSSourcePackageCheckPassed=TRUE`
- `MacOSRepositoryValidationPassed=FALSE`
- `FailurePredicate=SourceTruthOK`
- `RoadmapLifecycleMatchesBeforeCorrection=FALSE`
- `RoadmapLifecycleMatchesAfterCorrection=TRUE`
- `SourceTruthOKAfterCorrection=TRUE`
- `PackageCodeChangedByCorrection=FALSE`
- `SourceTarballPayloadChangedByCorrection=FALSE`
- `CandidateTransitionReadyBeforeCorrection=TRUE`
- `RepositorySourceTruthBeforeCorrection=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=commit-roadmap-lifecycle-correction-and-run-fresh-five-platform-matrix`
