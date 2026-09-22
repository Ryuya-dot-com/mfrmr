# mfrmr 0.2.4 public-language release-candidate transition record

Status: `public_language_transition_v3_frozen_development_ready`, 2026-08-26.

## Result

The public-language transition contract was reviewed from clean commit
`fd21f8e81a92a3481e688c049697420097fa6f1d` on branch
`development/0.2.4`. It binds the revalidated package payload at
`0dd03dd9830371dd13159db68f00d14ada0cb0ba` and hosted run `32923607662`.

Seven paths differed from that G6 baseline: six internal evidence paths and
the public repository roadmap. Every path was admitted by the prospectively
defined v3 allowlist, and every path is excluded from the source package. There
were no candidate package-metadata paths and no forbidden package-payload
paths. Development metadata remained exact and the review returned
development-transition ready.

The rewritten public roadmap contains user-facing release direction, model
scope, GPCM limitations, future multivariate G-theory direction, anchor-design
principles, and compatibility policy. It contains no internal gate, candidate,
preflight, denominator, submission, or evidence-record terminology.

This v3 boundary is independent of the invalidated v1 and v2 transitions. It
does not reinterpret either earlier candidate as passing or inherit their
checks. Candidate metadata has not been applied; therefore candidate readiness
remains false. The contract always reports submission authorization false and
performs no edits, commits, tags, checks, submission, or publication.

## Frozen transition surface

The only package metadata changes admissible in a possible later candidate
transition are:

- `DESCRIPTION`: `Version`, `Date`, and
  `Config/mfrmr/release-status` only;
- `NEWS.md`: the first heading only;
- `CITATION.cff`: `version` and `date-released` only; and
- a bounded `cran-comments.md` plus repository-only roadmap/evidence records.

`Config/mfrmr/public-version` must remain `0.2.3.1`. Any production code,
distributed test, help, vignette, data, schema, scorer, or other package
payload change invalidates this boundary and requires another return to
development.

## Exact fields

- `TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v3_public_language`
- `TransitionContractCommitSHA40=fd21f8e81a92a3481e688c049697420097fa6f1d`
- `ReviewCommitSHA40=fd21f8e81a92a3481e688c049697420097fa6f1d`
- `G6ValidatedCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba`
- `G6HostedRunId=32923607662`
- `ReviewBranch=development/0.2.4`
- `G6BaselineAncestor=TRUE`
- `WorkingTreeCleanAtReview=TRUE`
- `ChangedPathCount=7`
- `CandidatePackageMetadataPathCount=0`
- `CandidateRepositoryRoadmapPathCount=1`
- `CandidateInternalEvidencePathCount=6`
- `ForbiddenPayloadPathCount=0`
- `ChangedPathsAllowed=TRUE`
- `ProductionPayloadUnchanged=TRUE`
- `MetadataStage=development`
- `DevelopmentMetadataOK=TRUE`
- `G6DecisionBound=TRUE`
- `DevelopmentTransitionReady=TRUE`
- `PriorCandidateReusable=FALSE`
- `PriorTransitionContractReusable=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateReady=FALSE`
- `CandidateTagCreated=FALSE`
- `CandidateChecksRun=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `ReleaseDiffAllowlistFrozen=TRUE`
- `NextAction=hold-candidate-metadata-pending-explicit-decision`
