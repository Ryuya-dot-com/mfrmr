# mfrmr 0.2.4 candidate-metadata transition record

Status: `candidate_metadata_applied_clean_transition_ready_submission_unauthorized`,
2026-08-26.

## Decision

The 0.2.4 candidate metadata was applied under the prospectively frozen
release-transition allowlist. Commit
`e1fda8274579d8de6e7931148c3c59fad7d2d469` contains only `DESCRIPTION`,
`NEWS.md`, `CITATION.cff`, and `cran-comments.md` changes. The preceding
repository-only commit
`c729a3946f5f3f5d648c5c8cf5d716870162e862` makes the historical development-
state G4 tests hand current candidate-state ownership to the release-
transition contract without modifying the frozen historical contracts.

A read-only review of the clean metadata commit found that the G6-validated
payload remains in its ancestry, all 11 paths changed since G6 are admitted by
the frozen classifier, the candidate metadata is exact, and the CRAN-comments
semantic requirements are complete. The state is therefore candidate-ready
for the next internal release steps.

This readiness is narrowly defined. It does not mean that the exact 0.2.4
candidate source tarball has been built or checked, that a candidate identity
or tag has been fixed, that a maintainer has signed off, or that submission is
authorized. No CRAN submission was performed.

## Exact metadata transition

The clean commit changes:

- `DESCRIPTION`: `Version` from 0.2.4.9000 to 0.2.4, adds `Date` 2026-08-26,
  and changes `Config/mfrmr/release-status` from `development` to `candidate`;
- `NEWS.md`: only the first heading changes to `# mfrmr 0.2.4`;
- `CITATION.cff`: `version` becomes 0.2.4 and `date-released` becomes
  2026-08-26; and
- `cran-comments.md`: replaces the historical 0.2.3 submission text with the
  bounded 0.2.4 scope, prior payload-check facts, explicit portable GPCM/JML
  refusal, zero reverse-dependency denominator, and a warning that exact-
  candidate checks remain pending.

`Config/mfrmr/public-version` remains 0.2.3.1. It is not changed to 0.2.4
before a public 0.2.4 artifact exists and is independently reconciled.

## Evidence boundary

The five-platform result from workflow run `32906087561` and the local source-
package result apply to the G6-validated production payload at
`cf20dd0167db3f39224cea7d1c70998b1142f81f`. Because the candidate transition
changes release metadata, those results are retained as pre-candidate payload
evidence and are not relabelled as checks of the final 0.2.4 tarball.

The metadata transition does not inherit a final-candidate check result.
Candidate-specific source construction, package checks, public-claim review,
and cross-platform confirmation remain separate prospective steps.

## Clean committed review

- `TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v1`
- `CandidateMetadataCommitSHA40=e1fda8274579d8de6e7931148c3c59fad7d2d469`
- `G6ValidatedCommitSHA40=cf20dd0167db3f39224cea7d1c70998b1142f81f`
- `G6HostedRunId=32906087561`
- `ReviewBranch=development/0.2.4`
- `WorkingTreeCleanAtReview=TRUE`
- `G6BaselineAncestor=TRUE`
- `ChangedPathCount=11`
- `CandidatePackageMetadataPathCount=2`
- `CandidateRepositoryMetadataOrRoadmapPathCount=3`
- `CandidateInternalEvidencePathCount=6`
- `ForbiddenPayloadPathCount=0`
- `ChangedPathsAllowed=TRUE`
- `ProductionPayloadUnchanged=TRUE`
- `MetadataStage=candidate`
- `CandidateVersion=0.2.4`
- `CandidateDate=2026-08-26`
- `CandidateReleaseStatus=candidate`
- `CandidatePublicVersion=0.2.3.1`
- `CandidateCffVersion=0.2.4`
- `CandidateCffDate=2026-08-26`
- `CandidateNewsHeading=# mfrmr 0.2.4`
- `ChangedDescriptionFields=Version,Config/mfrmr/release-status,Date`
- `CandidateMetadataOK=TRUE`
- `CranCommentsReady=TRUE`
- `CandidateReady=TRUE`
- `CandidateTagCreated=FALSE`
- `CandidateChecksRun=FALSE`
- `MaintainerSignOff=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=audit-final-public-claim-diff`
