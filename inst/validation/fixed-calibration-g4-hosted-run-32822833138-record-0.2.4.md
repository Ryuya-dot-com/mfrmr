# Fixed-calibration G4 hosted run 32822833138 record

Status: `four_receipts_complete_ubuntu_full_suite_failed_before_worker`,
2026-08-25.

## Candidate and retained execution

- Commit: `d37434ecfb2c3dd73704f542b6a7518988a41dd6`
- GitHub Actions run: `32822833138`
- macOS release prerequisite: `success`, 7m47s
- Windows release: `success`, 9m02s
- Ubuntu devel: `success`, 10m50s
- Ubuntu oldrel-1: `success`, 9m14s
- Ubuntu release full suite: `failure_before_worker`, 53m13s
- Five-receipt aggregation: `skipped`

The four completed cells each passed the exact source-tarball check, the
installed-package static evidence, all 49 current v4 cells, and all three
resource scales. Their independently downloaded receipts had valid canonical
hashes and one common production-boundary and support identity. Platform-built
tarball and manifest hashes were allowed to differ; the portable semantic
registries were required to match and did match.

The Ubuntu release cell enabled the complete `NOT_CRAN=true` package suite. It
stopped during R CMD check before the static evidence and G4 worker. The suite
reported 15,706 passes, two errors, 42 warnings, and 43 skips. Both errors came
from the latent-regression branch of `reference_case_benchmark()`: its source
fit had readiness `review`, while its posterior-shift helper attempted ordinary
fitted-object scoring. The newly hardened scorer correctly refused that call.
No Ubuntu release receipt was created, so the matrix aggregator correctly did
not run.

This is a production-boundary integration failure, not a failed numerical G4
cell and not permission to bypass readiness with a review-only score labelled
as a pass. The benchmark must leave posterior shift unevaluated when its source
fit is not scoring-ready. Because that repair changes evaluated production
code after four v4 results were opened, the v4 identities are consumed and a
new disjoint v5 confirmation is required. None of the four passing receipts is
pooled into v5.

## Retained portable identities and receipts

- Production registry SHA-256:
  `ae146d61a89f4ec141d6a0551c424c6cf5a61a7382852b45a69c9f686456ff04`
- Support registry SHA-256:
  `a769dce2726553cc260f6028a43ce1eb9c7e9f6e43af28e5d317f332655130d9`
- macOS release receipt:
  `ef69a3440d2be64fbfe83345a83f02458e6fb59c53e9b8dd4f805283a8c397c8`
- Windows release receipt:
  `f974430fea8f77e747a260aad3ee1297a392257903fb2978b4b0a5d2e230c767`
- Ubuntu devel receipt:
  `8024b898090d4b95799b267c656e5f040fa59642721f9cd650b669db57ffebc4`
- Ubuntu oldrel-1 receipt:
  `00a18977d5942d8b0c1b2cfa8768b63a38b4eb7831d9d892691e697a2c8ff26a`

- `CompletedHostedCellReceipts=4`
- `CompletedHostedCellsPassed49Of49=4`
- `CompletedHostedCellsPassedResources3Of3=4`
- `PortableProductionIdentityMatched=TRUE`
- `PortableSupportIdentityMatched=TRUE`
- `UbuntuReleasePackageSuitePassed=FALSE`
- `UbuntuReleaseWorkerInvoked=FALSE`
- `UbuntuReleaseCellReceiptCreated=FALSE`
- `HostedPlatformMatrixComplete=FALSE`
- `V4ConfirmationIdentityConsumed=TRUE`
- `V4ReceiptsReusableForV5=FALSE`
- `CORE05Complete=FALSE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `G6Authorized=FALSE`
- `PublicAPIAuthorized=FALSE`
- `NextGate=reference-benchmark-readiness-boundary-and-disjoint-v5`
