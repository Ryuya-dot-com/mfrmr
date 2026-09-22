# Fixed-calibration G6 release decision for mfrmr 0.2.4

Status: `g6_complete_bounded_public_api_authorized`, 2026-08-26.

## Decision

The deliberately bounded portable-calibration API is authorized to enter the
final 0.2.4 release-candidate preparation stage. Authorization applies only to
one-scale RSM/PCM MML fits under the fixed standard-normal scoring basis, with
preservation of stored direct and group facet anchors and artifact-only
scoring of new Persons. Public construction of step anchors, estimated-
population or latent-regression calibration, JML calibration, and bounded-
GPCM calibration remain unavailable.

This decision does not submit 0.2.4 to CRAN, change the development version,
or widen the support matrix. The branch remains 0.2.4.9000 until final release
metadata and a release candidate are prepared separately.

## Exact validated payload

The successful ordinary five-platform workflow was run against exact commit
`cf20dd0167db3f39224cea7d1c70998b1142f81f`. Local source-package construction
from the same payload produced
`mfrmr_0.2.4.9000.tar.gz` with SHA-256
`c93983d677739d8658b7c64c37b4da3062ed4ca8a5dc9884d37cf3d5bd788963`.
Its ordinary `R CMD check --no-manual` completed with `Status: OK`, and its
installed-package public-surface test passed 76 of 76 expectations in the
fresh installed-library context.

After adding this append-only decision record, the package was rebuilt and
both source tarballs were extracted for a recursive comparison. Their only
content difference was the automatically generated `DESCRIPTION` `Packaged`
timestamp. `ROADMAP.md`, `inst/validation`, and the repository-only G4/G6
evidence test were absent from both tarballs under `.Rbuildignore`. Thus this
decision commit records the result without changing the validated package
payload.

GitHub Actions run `32906087561` completed successfully. Its five cells were:

| Cell | Conclusion | Started (UTC) | Completed (UTC) |
| --- | --- | --- | --- |
| macOS release | success | 2026-08-25 22:25:41 | 2026-08-25 22:30:09 |
| Windows release | success | 2026-08-25 22:30:12 | 2026-08-25 22:38:19 |
| Ubuntu devel | success | 2026-08-25 22:30:13 | 2026-08-25 22:37:20 |
| Ubuntu release/full | success | 2026-08-25 22:30:14 | 2026-08-25 23:24:47 |
| Ubuntu oldrel-1 | success | 2026-08-25 22:30:12 | 2026-08-25 22:37:08 |

Exactly five check artifacts were retained:

- `r-cmd-check-macos-release`
- `r-cmd-check-windows-release`
- `r-cmd-check-ubuntu-devel`
- `r-cmd-check-ubuntu-release`
- `r-cmd-check-ubuntu-oldrel-1`

No G4 receipt or evidence artifact was issued. That absence is required:
routine check receipts verify the current package but do not self-authorize
or rewrite the source-bound G4 decision. The Node.js 20-to-24 deprecation
annotations attached to some GitHub Actions steps concern runner
infrastructure and are not package-check warnings or failures.

## Retained corrective history

Two earlier runs are retained as failed whole matrices and are not pooled
with the successful run:

1. Run `32894811905` passed four cells but failed Ubuntu release/full because
   a distributed source-package test required repository-only `_pkgdown.yml`,
   which `.Rbuildignore` correctly excludes. Commit
   `240a7025d239fad03724215e9b9a7a5a0308e86e` separated that repository check.
2. Run `32900730800` again passed four cells but failed Ubuntu release/full
   because the remaining public-surface paths were resolved relative to the
   test working directory. Commit
   `cf20dd0167db3f39224cea7d1c70998b1142f81f` changed the distributed check to
   resolve the installed package with `find.package("mfrmr")` and retained the
   complete repository-only filesystem audit separately.

These failures changed test portability, not the calibration schema, scoring
kernel, capability matrix, or supported statistical envelope. The third,
fresh matrix is the sole hosted basis for this G6 decision.

## Public predecessor and downstream surface

The public predecessor is CRAN 0.2.3.1. The CRAN source tarball reviewed on
2026-08-26 matched the maintenance addendum exactly:

- SHA-256:
  `d3d2b00638fcbd8407dfabd5206eb670b2a3470e0e30e0079ca64a2e7a77b67a`
- MD5: `626a948a1b338e004c85b3c691be71e5`

The current CRAN `PACKAGES` dependency index reported zero packages in each
reverse relationship: Depends, Imports, LinkingTo, Suggests, and Enhances.
Accordingly there was no reverse-dependent package suite to execute. This is
a complete zero-denominator review, not a skipped downstream assessment.

The maintenance bridge also passed its source review: the public baseline was
matched, both maintenance integration commits were ancestors of the validated
payload, the compiled-header override was absent, documentation targets were
valid, and release metadata still described 0.2.4.9000 development over
public predecessor 0.2.3.1.

## Scope and no-go review

The final no-go audit found no unresolved condition inside the promoted
RSM/PCM MML fixed-standard-normal lane. Unknown schema versions, fields,
levels, scores, maps, and invalid weights fail closed; scoring requires a
frozen eligible artifact, performs no refit, and remains independent of the
source fit and training data. Save/load, fresh-process scoring, uncertainty,
row order, chunking, locale/encoding, and the already bound G4 evidence remain
consistent with the public claim.

The following routes remain expressly outside portable calibration in 0.2.4:

- estimated-population and latent-regression MML;
- bounded GPCM MML;
- RSM/PCM JML with a post-hoc scoring prior;
- bounded GPCM JML; and
- public construction of shared or owner-specific step anchors.

Their existing fitted-object routes remain available under their documented
conditions. Internal support for typed step coordinates is not represented as
a public construction capability.

## Decision fields

- `ValidatedPayloadCommitSHA40=cf20dd0167db3f39224cea7d1c70998b1142f81f`
- `HostedRunId=32906087561`
- `HostedWorkflowConclusion=success`
- `HostedPlatformCells=5`
- `HostedPassedCells=5`
- `HostedFailedCells=0`
- `CheckArtifactCount=5`
- `UnexpectedG4ArtifactCount=0`
- `PriorFailedHostedRuns=2`
- `PriorFailedHostedRunIds=32894811905,32900730800`
- `LocalSourceTarballSHA256=c93983d677739d8658b7c64c37b4da3062ed4ca8a5dc9884d37cf3d5bd788963`
- `LocalSourceCheckStatus=OK`
- `InstalledSurfaceExpectationsPassed=76`
- `RepositoryDecisionExpectationsPassed=530`
- `DecisionFilesRbuildExcluded=TRUE`
- `PostDecisionPayloadDiff=DESCRIPTION_PACKAGED_TIMESTAMP_ONLY`
- `PublicPredecessorVersion=0.2.3.1`
- `PublicPredecessorSHA256=d3d2b00638fcbd8407dfabd5206eb670b2a3470e0e30e0079ca64a2e7a77b67a`
- `PublicPredecessorMD5=626a948a1b338e004c85b3c691be71e5`
- `ReverseDepends=0`
- `ReverseImports=0`
- `ReverseLinkingTo=0`
- `ReverseSuggests=0`
- `ReverseEnhances=0`
- `ReverseDependencyReviewComplete=TRUE`
- `NoGoAuditComplete=TRUE`
- `CORE07Complete=TRUE`
- `CORE08Complete=TRUE`
- `G6ExitComplete=TRUE`
- `PublicAPIAuthorizedForRelease=TRUE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=prepare-final-0.2.4-release-metadata-and-candidate`
