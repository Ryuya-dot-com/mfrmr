# Fixed-calibration score help-index local validation record for 0.2.4

Date: 2026-08-26

## Decision

Direct help discovery now matches the implemented portable-score S3 surface.
The shared help page registers the score `print()`, score `summary()`, summary
`print()`, and score `plot()` methods. The value section states that `print()`
returns its input invisibly.

The source package was rebuilt from the updated worktree and passed
`R CMD check --no-manual` with `Status: OK`. The complete pkgdown site was then
rebuilt. It generated redirects for both print aliases to the shared method
page. The shared page was inspected at desktop and 390 px widths. At 390 px,
the browser reported body and document client/scroll widths of 390 px, so no
whole-page horizontal overflow was present.

This is local evidence only. The prior five-platform success applies to its
older exact head and is not reused for this changed source payload. No release
or submission action was performed.

## Local evidence

- R: `4.6.1` on `aarch64-apple-darwin23`
- Exact source tarball: `mfrmr_0.2.4.9000.tar.gz`
- Source tarball SHA-256:
  `fe6efc23c0cead67af7d3570c4423dc4aec5ae3e7445579bf845fcbfc037e823`
- `R CMD check --no-manual` log SHA-256:
  `244760d1030f77ae9033f48eddc1a2e1f048688352a75d387a968391a95a75de`
- Source check status: `OK`
- Source check errors / warnings / notes: `0 / 0 / 0`
- Fixed-calibration evidence tests: `1236` pass, `0` fail
- Calibration public API tests: `109` pass, `0` fail, `1` expected skip
- ggplot conversion tests: `17` pass, `0` fail
- Rd syntax check: pass
- Full pkgdown build: complete
- Direct score-print help redirect: generated
- Direct summary-print help redirect: generated
- Desktop shared-method page inspected: yes
- 390 px shared-method page inspected: yes
- 390 px body client / scroll width: `390 / 390`
- 390 px document client / scroll width: `390 / 390`

## Machine-readable disposition

- `DevelopmentVersion=0.2.4.9000`
- `ReleaseStatus=development`
- `ScorePrintHelpAliasAvailable=TRUE`
- `ScoreSummaryHelpAliasAvailable=TRUE`
- `ScoreSummaryPrintHelpAliasAvailable=TRUE`
- `ScorePlotHelpAliasAvailable=TRUE`
- `PrintInvisibleReturnDocumented=TRUE`
- `ExactSourcePackageCheckStatus=OK`
- `ExactSourcePackageErrors=0`
- `ExactSourcePackageWarnings=0`
- `ExactSourcePackageNotes=0`
- `FreshPkgdownBuildComplete=TRUE`
- `DesktopHelpRenderInspected=TRUE`
- `NarrowHelpRenderInspected=TRUE`
- `NarrowWholePageOverflowDetected=FALSE`
- `PreviousHostedRunAppliesToCurrentPayload=FALSE`
- `FreshHostedMatrixComplete=FALSE`
- `HumanSignOffComplete=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=commit-help-index-payload-and-run-new-five-platform-matrix`
