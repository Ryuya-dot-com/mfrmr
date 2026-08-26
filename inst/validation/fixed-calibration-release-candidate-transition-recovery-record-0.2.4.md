# mfrmr 0.2.4 recovery release-candidate transition record

Status: `recovery_transition_v2_frozen_development_ready`, 2026-08-26.

## Result

The recovery transition contract was reviewed from clean commit
`e49903255fb728bf4cc631ad66077700840c043b` on branch
`development/0.2.4`. It binds the revalidated G6 package payload at
`e39571974f70da0db90444732b5719c187a004d2` and hosted run `32915301113`.

Seven paths differed from that G6 baseline: six internal evidence paths and
the repository-only public roadmap. Every path was admitted by the
prospectively defined recovery allowlist, and every path is excluded from the
source package. There were no candidate metadata paths and no forbidden
package-payload paths. Development metadata remained exact and the review
returned development-transition ready.

This v2 boundary is independent of the invalidated v1 candidate. It does not
reinterpret the failed candidate as passing, widen the old allowlist, or
inherit a candidate check. Candidate metadata has not been applied; therefore
candidate readiness remains false. The contract always reports submission
authorization false and performs no edits, commits, tags, checks, submission,
or publication.

## Frozen transition surface

The only package metadata changes admissible in a later candidate transition
are:

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

- `TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v2_recovery`
- `TransitionContractCommitSHA40=e49903255fb728bf4cc631ad66077700840c043b`
- `ReviewCommitSHA40=e49903255fb728bf4cc631ad66077700840c043b`
- `G6ValidatedCommitSHA40=e39571974f70da0db90444732b5719c187a004d2`
- `G6HostedRunId=32915301113`
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
- `NextAction=apply-0.2.4-candidate-metadata-under-recovery-v2-allowlist`
