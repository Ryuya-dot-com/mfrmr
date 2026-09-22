# mfrmr 0.2.4 API-consistency candidate record

Status: `candidate_v4_exact_source_local_check_pass_submission_unauthorized`,
2026-09-03.

## Decision

Candidate metadata was applied on the independently isolated
`release/0.2.4-candidate-v4` branch after the exact-payload human API review.
Commit `84035cb0976bbd69fbd6f4929fe5d77c2d7f04c9` changes only
`DESCRIPTION`, `NEWS.md`, and `CITATION.cff` within transition contract
`mfrmr_release_candidate_transition_0_2_4_v4_api_consistency`.

The clean transition review returns candidate-ready and submission
authorization false. The exact candidate source tarball was then built and
checked locally. `R CMD check --no-manual` completed with `Status: OK`, zero
errors, zero warnings, and zero notes. Repository-only validation files were
absent from the tarball as required.

This record does not create a tag, reuse an earlier candidate identity,
authorize publication or submission, or represent the earlier development
matrix as a check of this metadata-changed tarball. A fresh hosted matrix on
the exact candidate head remains required.

## Exact identities

- `TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v4_api_consistency`
- `TransitionBoundaryCommitSHA40=6c4679cf772720655e8b5feb9067dfff5964d477`
- `ValidatedDevelopmentCommitSHA40=036565f583d441c599d6650391dc0523c36d0210`
- `ValidatedDevelopmentTreeSHA40=755dc77cd398f12f12438e43bc440b847216c336`
- `DevelopmentHostedRunId=32990152654`
- `CandidateMetadataCommitSHA40=84035cb0976bbd69fbd6f4929fe5d77c2d7f04c9`
- `CandidateSourceTarball=mfrmr_0.2.4.tar.gz`
- `CandidateSourceTarballSHA256=9b51e3ede1eda893a6724faddb3fe07c01aa40366cab2c9e1b420ea2e1a0e2ac`
- `CandidateCheckLogSHA256=b5865fec9830611a43f1ff42bbda04ea413f11aa354cd488f753187ca8ed63d2`
- `CandidateVersion=0.2.4`
- `CandidateDate=2026-09-03`
- `CandidateReleaseStatus=candidate`
- `CandidatePublicVersion=0.2.3.1`
- `CandidateReady=TRUE`
- `HumanApiReviewComplete=TRUE`
- `LocalSourceCheckStatus=OK`
- `LocalErrors=0`
- `LocalWarnings=0`
- `LocalNotes=0`
- `CandidateHostedMatrixComplete=FALSE`
- `FinalReleaseSignOff=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=run-exact-candidate-five-platform-matrix`
