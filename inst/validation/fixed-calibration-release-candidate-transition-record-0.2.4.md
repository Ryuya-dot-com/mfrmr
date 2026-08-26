# mfrmr 0.2.4 release-candidate transition record

Status: `transition_contract_frozen_candidate_metadata_not_applied`,
2026-08-26.

## Decision

The development-to-candidate change boundary is frozen before release
metadata is edited. The contract binds the G6-validated package payload at
commit `cf20dd0167db3f39224cea7d1c70998b1142f81f` and permits no production,
API, generated-help, vignette, README, test-distribution, compiled-source, or
workflow change to enter the candidate as a release convenience.

The contract itself was committed as
`02c216100b1637036c486c0038625924cdd8a59f`. A read-only review of that clean
commit found the G6 baseline in its ancestry and six changed paths since the
G6 payload: five repository-only evidence paths and `ROADMAP.md`. All six are
excluded from, or have no effect on, the package payload. There were zero
forbidden payload paths.

This record does not apply candidate metadata, create a candidate tag, run
candidate checks, authorize submission, or submit to CRAN.

## Candidate allowlist

The only package-payload paths that may change during the metadata transition
are:

- `DESCRIPTION`, limited to `Version`, `Date`, and
  `Config/mfrmr/release-status`; and
- the first heading of `NEWS.md`.

The candidate must retain
`Config/mfrmr/public-version: 0.2.3.1`. It changes to 0.2.4 only after the CRAN
0.2.4 public artifact exists and the separate released-state baseline is
bound.

The repository-only transition may also change `CITATION.cff` only at
`version` and `date-released`, replace `cran-comments.md`, update the internal
roadmap, and add/update repository-only validation records and their excluded
contract tests. The candidate date must be a valid ISO date and agree between
`DESCRIPTION` and `CITATION.cff`. The remaining CFF content and the complete
NEWS body must be byte-for-byte equivalent to the G6 baseline.

Any other path invalidates candidate preparation. The response is to return
to development, explain the production change, and rerun proportionate
evidence on a new payload—not to widen the allowlist after seeing a failure.

## CRAN handoff requirements

Before candidate readiness can pass, `cran-comments.md` must identify the
0.2.3.1 predecessor and 0.2.4 target, describe the bounded portable-
calibration support for RSM/PCM MML under the fixed-standard-normal basis,
state that GPCM and JML portable routes remain unavailable, and report the
final zero-error, zero-warning, zero-note check result.

The current `cran-comments.md` is still the historical 0.2.3 submission
document. This is expected at contract-freeze time and is one reason candidate
readiness remains false.

## Adversarial fixtures

The repository-only contract test demonstrates that the exact intended
candidate transition passes, then independently rejects:

- a changed DESCRIPTION Title;
- premature change of `Config/mfrmr/public-version` to 0.2.4;
- an appended NEWS feature after G6;
- a changed CFF title;
- incomplete CRAN comments that omit scope/refusal/check facts; and
- mismatched DESCRIPTION and CFF dates.

The path classifier also rejects changes to `R/api-calibration.R`, generated
help, and the operational vignette. A necessary production fix remains
possible, but only by invalidating this transition and reopening development
evidence.

## Clean committed review

- `TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v1`
- `TransitionContractCommitSHA40=02c216100b1637036c486c0038625924cdd8a59f`
- `G6ValidatedCommitSHA40=cf20dd0167db3f39224cea7d1c70998b1142f81f`
- `G6HostedRunId=32906087561`
- `ReviewBranch=development/0.2.4`
- `G6BaselineAncestor=TRUE`
- `WorkingTreeCleanAtReview=TRUE`
- `ChangedPathCount=6`
- `CandidatePackageMetadataPathCount=0`
- `CandidateRepositoryRoadmapPathCount=1`
- `CandidateInternalEvidencePathCount=5`
- `ForbiddenPayloadPathCount=0`
- `ChangedPathsAllowed=TRUE`
- `ProductionPayloadUnchanged=TRUE`
- `MetadataStage=development`
- `DevelopmentMetadataOK=TRUE`
- `DevelopmentTransitionReady=TRUE`
- `CandidateMetadataApplied=FALSE`
- `CandidateReady=FALSE`
- `CandidateTagCreated=FALSE`
- `CandidateChecksRun=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `ReleaseDiffAllowlistFrozen=TRUE`
- `NextAction=apply-0.2.4-candidate-metadata-under-frozen-allowlist`
