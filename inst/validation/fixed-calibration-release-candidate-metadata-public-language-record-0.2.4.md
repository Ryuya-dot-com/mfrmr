# mfrmr 0.2.4 public-language candidate-metadata record

Status: `candidate_metadata_v3_applied_local_check_pass_hosted_running`,
2026-08-26.

## Result

The 0.2.4 candidate metadata was applied under the frozen v3 transition
contract. Clean commit `8b408083c0277dabe7c71450bd8b53dcbde0853e`
contains changes only to `DESCRIPTION`, the first `NEWS.md` heading,
`CITATION.cff`, and `cran-comments.md`.

A clean read-only v3 review found the G6-validated payload in the commit's
ancestry, 12 allowed changed paths, zero forbidden package-payload path, exact
candidate metadata, and complete CRAN-comments semantic requirements. The
review returned candidate-ready and submission authorization false.

The exact candidate source tarball was then built with complete vignette
rebuilding and checked locally with `R CMD check --no-manual` under R 4.6.1 on
arm64 macOS. The check completed with `Status: OK`: zero errors, zero warnings,
zero notes, 435 distributed expectations passed, and three explicit
bounded-GPCM design skips were retained.

## Exact source-package comparison

The candidate tarball was expanded and compared recursively with the exact
G6-validated development tarball. Only `DESCRIPTION` and `NEWS.md` differed.
The `DESCRIPTION` delta was limited to Version 0.2.4, Date 2026-08-26,
candidate release status, and the automatically generated `Packaged` time.
The `NEWS.md` delta was limited to the first heading. R sources, help,
vignettes, tests, data, compiled sources, namespace, and every other tarball
member were identical.

The candidate tarball contains no internal validation directory, root
roadmap, or repository evidence test. A direct source scan found no blocked
development-stage phrase or GPCM boundary code in public documentation and R
messages.

## Candidate metadata

- `DESCRIPTION`: Version 0.2.4, Date 2026-08-26, candidate release status;
- `NEWS.md`: first heading `# mfrmr 0.2.4`;
- `CITATION.cff`: version 0.2.4 and date-released 2026-08-26; and
- `cran-comments.md`: current bounded scope and check facts in reader-facing
  language.

`Config/mfrmr/public-version` remains `0.2.3.1`.

Ordinary five-platform workflow run `32936425346` is running on the exact
candidate commit. This record does not infer its result. No candidate tag was
created and no CRAN submission was authorized or performed.

## Exact fields

- `TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v3_public_language`
- `CandidateMetadataCommitSHA40=8b408083c0277dabe7c71450bd8b53dcbde0853e`
- `G6ValidatedCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba`
- `G6HostedRunId=32923607662`
- `ReviewBranch=development/0.2.4`
- `WorkingTreeCleanAtReview=TRUE`
- `G6BaselineAncestor=TRUE`
- `ChangedPathCount=12`
- `CandidatePackageMetadataPathCount=2`
- `CandidateRepositoryMetadataOrRoadmapPathCount=3`
- `CandidateInternalEvidencePathCount=7`
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
- `CandidateSourcePackageChangedPaths=2`
- `CandidateSourcePackageChangedPath1=DESCRIPTION`
- `CandidateSourcePackageChangedPath2=NEWS.md`
- `CandidateSourceTarballSHA256=6570b98e0335de3862a5c2f12355b59c2e681dc5f3ed31d03238bc6c730836a5`
- `CandidateCheckLogSHA256=8574d99765e1b29a74dc4a435f099c33e032835e39c86576176eb6963deedd33`
- `CandidateLocalSourceCheckStatus=OK`
- `CandidateLocalErrors=0`
- `CandidateLocalWarnings=0`
- `CandidateLocalNotes=0`
- `CandidateDistributedTestsPassed=435`
- `CandidateDistributedTestsSkipped=3`
- `PublicDocumentationBlockedPhraseHits=0`
- `PublicRuntimeBoundaryCodeHits=0`
- `CandidateHostedRunId=32936425346`
- `CandidateHostedRunComplete=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=complete-exact-candidate-five-platform-matrix`
