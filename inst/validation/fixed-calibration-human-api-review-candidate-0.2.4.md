# mfrmr 0.2.4 human API review decision

Status: `approved_exact_payload_candidate_transition_only`, 2026-09-03.

## Decision

The maintainer's interactive instruction to continue is recorded as
`approve_exact_validated_payload`. This authorizes a new metadata-only
candidate transition for the exact validated payload below. It does not
authorize a tag, publication, CRAN submission, or later source changes.

The review target is implementation commit
`036565f583d441c599d6650391dc0523c36d0210`, Git tree
`755dc77cd398f12f12438e43bc440b847216c336`, and development source tarball
`mfrmr_0.2.4.9000.tar.gz` with SHA-256
`b4b7fc0699b25b4803f4cae9a6cd45cd983beb8aa0383147db58de379f525b34`.
GitHub Actions run `32990152654` passed all 5/5 required platform cells for
that payload. Commit `322f1880aabab20724294d0b92d144a24cecc1f3` has the same
Git tree; commit `511cbdd00702aeb9376dcbf545b2a6eb2ae50b78` adds only
repository validation evidence and excluded roadmap/test bookkeeping relative
to the validated implementation.

The separate development working tree, including ongoing D-SIM-5 work, is not
the review target and must not enter this candidate branch.

## Approved public boundary

- Portable artifact scoring is limited to eligible one-scale RSM/PCM MML fits
  under the fixed N(0,1) basis.
- Estimated-population MML, latent-regression calibration, bounded-GPCM
  calibration, and JML portable calibration remain outside this release.
- Portable score `print()`, `summary()`, base plots, ggplot2 plots, method help,
  and narrow-screen documentation form the reviewed public workflow.
- Score intervals remain conditional on calibration parameters.
- Omitting a raw parameter plot for the mixed-role calibration artifact is an
  intentional safety boundary.
- `Config/mfrmr/public-version` remains `0.2.3.1` until a public 0.2.4 artifact
  is independently reconciled.

## Decision fields

- `ReviewTargetCommitSHA40=036565f583d441c599d6650391dc0523c36d0210`
- `ValidatedPayloadCommitSHA40=036565f583d441c599d6650391dc0523c36d0210`
- `ReviewTargetTreeSHA40=755dc77cd398f12f12438e43bc440b847216c336`
- `ReviewTargetTarballSHA256=b4b7fc0699b25b4803f4cae9a6cd45cd983beb8aa0383147db58de379f525b34`
- `HostedRunId=32990152654`
- `HostedWorkflowConclusion=success`
- `HostedPassedCells=5`
- `HostedFailedCells=0`
- `Decision=approve_exact_validated_payload`
- `Reviewer=maintainer_interactive_instruction`
- `ReviewedAt=2026-09-03`
- `HumanSignOffComplete=TRUE`
- `G6ExitComplete=TRUE`
- `PublicAPIAuthorizedForRelease=TRUE`
- `CandidateTransitionAuthorized=TRUE`
- `CandidateMetadataApplied=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=freeze-api-consistency-transition-boundary-v4`
