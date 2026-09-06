# mfrmr 0.2.4 human API review candidate

Status: `unsigned_exact_payload_review_candidate`, 2026-09-03.

## Decision boundary

This packet asks for one human product decision: whether the exact validated
0.2.4 development payload below may enter a new candidate-metadata transition.
It is not a sign-off, candidate commit, tag, publication, or CRAN submission.

The review target is the implementation commit
`036565f583d441c599d6650391dc0523c36d0210`, Git tree
`755dc77cd398f12f12438e43bc440b847216c336`, and development source tarball
`mfrmr_0.2.4.9000.tar.gz` with SHA-256
`b4b7fc0699b25b4803f4cae9a6cd45cd983beb8aa0383147db58de379f525b34`.
GitHub Actions run `32990152654` passed all 5/5 required platform cells for
that payload. Commit `322f1880aabab20724294d0b92d144a24cecc1f3` has the same
Git tree; commit `511cbdd00702aeb9376dcbf545b2a6eb2ae50b78` adds only
repository validation evidence and roadmap/test bookkeeping relative to the
validated implementation.

The current working tree is not the review target. It contains ongoing D-SIM-5
and other development work and must not be used to form the candidate. After
approval, candidate metadata must be applied from a clean tree based on this
validated payload, then assigned its own commit and tarball identities.

## Human review surface

Approve only if all statements are acceptable:

- The 0.2.4 public addition remains portable artifact scoring for eligible
  one-scale RSM/PCM MML fits under the fixed N(0,1) basis.
- Estimated-population MML, latent-regression calibration, bounded-GPCM
  calibration, and JML portable calibration remain outside this release.
- Portable score `print()`, `summary()`, base plots, ggplot2 plots, method help,
  and narrow-screen documentation are adequate for the public workflow.
- Score intervals are clearly labelled as conditional on calibration
  parameters; calibration-parameter uncertainty is not implied.
- Omitting a raw parameter plot for the mixed-role calibration artifact is an
  intentional safety boundary, not a missing advertised feature.
- The package remains version `0.2.4.9000`, release status `development`, and
  public version `0.2.3.1` until a separately checked candidate is formed.

## Allowed dispositions

- `approve_exact_validated_payload`: permit a metadata-only candidate
  transition from the bound payload; do not authorize submission.
- `request_change`: return to development and rerun proportionate evidence on
  the changed payload.
- `defer`: leave the release state unchanged.

## Unsigned fields

- `ReviewTargetCommitSHA40=036565f583d441c599d6650391dc0523c36d0210`
- `ReviewTargetTreeSHA40=755dc77cd398f12f12438e43bc440b847216c336`
- `ReviewTargetTarballSHA256=b4b7fc0699b25b4803f4cae9a6cd45cd983beb8aa0383147db58de379f525b34`
- `HostedRunId=32990152654`
- `HostedPassedCells=5`
- `HostedFailedCells=0`
- `Decision=UNSIGNED`
- `Reviewer=UNSET`
- `ReviewedAt=UNSET`
- `CandidateTransitionAuthorized=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=obtain-explicit-human-api-review`
