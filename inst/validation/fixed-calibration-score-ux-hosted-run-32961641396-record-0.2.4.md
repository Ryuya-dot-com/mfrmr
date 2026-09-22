# Fixed-calibration score UX hosted run 32961641396 record

Status: `macos_package_check_ok_source_truth_lifecycle_mismatch`, 2026-08-26.

## Execution result

- Commit: `e51a632478e3142bb28cfb1ee41417022d3dd618`
- GitHub Actions run: `32961641396`
- macOS release prerequisite: `failure_after_exact_package_check`
- Dependent platform matrix: `skipped`

The exact source package passed R CMD check with `Status: OK`. The subsequent
repository validation review stopped because the public roadmap still called
0.2.4 a release candidate while `DESCRIPTION`, `CITATION.cff`, and `NEWS.md`
correctly identified `0.2.4.9000` as a development version. All other
source-truth predicates passed; `RoadmapLifecycleMatches` alone was false.

The correction changes the roadmap lifecycle sentence to match the existing
development metadata and updates the two tests that had retained the stale
candidate sentence. It does not relax or bypass the source-truth parser. The
corrected source-truth status and both affected test files pass locally. A new
commit and a new hosted run are required; this failed run cannot be reclassified
as a successful matrix.

## Disposition

- `WorkflowRunId=32961641396`
- `SourceCommit=e51a632478e3142bb28cfb1ee41417022d3dd618`
- `WorkflowConclusion=failure`
- `ExactSourcePackageCheckStatus=OK`
- `RepositoryValidationReviewPassed=FALSE`
- `SourceTruthOK=FALSE`
- `RoadmapLifecycleMatches=FALSE`
- `DependentPlatformJobsSkipped=TRUE`
- `HostedPlatformMatrixComplete=FALSE`
- `FailureRetainedInDenominator=TRUE`
- `CorrectiveChange=roadmap-development-lifecycle-alignment`
- `ReleaseReadinessParserWeakened=FALSE`
- `CorrectedSourceTruthLocalCheck=TRUE`
- `PreviousCandidateReusable=FALSE`
- `CandidateMetadataApplied=FALSE`
- `HumanSignOffComplete=FALSE`
- `CandidateTagCreated=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=commit-source-truth-correction-and-run-new-five-platform-matrix`
