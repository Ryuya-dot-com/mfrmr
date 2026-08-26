# Fixed-calibration score help-index local validation record for 0.2.4

Date: 2026-08-26

## Decision

Direct help discovery now matches the implemented portable-score S3 surface.
The shared help page registers the score `print()`, score `summary()`, summary
`print()`, and score `plot()` methods. The value section states that `print()`
returns its input invisibly.

The public article's interval figure now carries semantic alternative text
that identifies the blue ready-score circle, orange review triangle, and
zero-logit reference line. The plot subtitle uses grammatical singular and
plural forms instead of `disposition(s)`; the one-review example renders as
`1 review disposition shown`.

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
  `10be1e9432ea9ebd7a7ba5f926663e3029b0e5751e48dce9a4f8cbc4fd13e521`
- `R CMD check --no-manual` log SHA-256:
  `2b35dd3b73ab7f34c8c5596948cdb9918d6859a04663ab77385d48a2a964777d`
- Source check status: `OK`
- Source check errors / warnings / notes: `0 / 0 / 0`
- Fixed-calibration evidence tests: `1237` pass, `0` fail
- Calibration public API tests: `110` pass, `0` fail, `1` expected skip
- ggplot conversion tests: `17` pass, `0` fail
- Rd syntax check: pass
- Full pkgdown build under the public-site `NOT_CRAN=true` mode: complete
- Direct score-print help redirect: generated
- Direct summary-print help redirect: generated
- Desktop shared-method page inspected: yes
- 390 px shared-method page inspected: yes
- 390 px body client / scroll width: `390 / 390`
- 390 px document client / scroll width: `390 / 390`
- Interval-figure semantic alternative text: present
- Interval-figure state distinction by both color and shape: present
- Grammatical review-count subtitle: present

## Machine-readable disposition

- `DevelopmentVersion=0.2.4.9000`
- `ReleaseStatus=development`
- `ScorePrintHelpAliasAvailable=TRUE`
- `ScoreSummaryHelpAliasAvailable=TRUE`
- `ScoreSummaryPrintHelpAliasAvailable=TRUE`
- `ScorePlotHelpAliasAvailable=TRUE`
- `PrintInvisibleReturnDocumented=TRUE`
- `IntervalFigureSemanticAltTextAvailable=TRUE`
- `IntervalFigureUsesColorAndShape=TRUE`
- `ReviewCountSubtitlePluralized=TRUE`
- `ExactSourcePackageCheckStatus=OK`
- `ExactSourcePackageErrors=0`
- `ExactSourcePackageWarnings=0`
- `ExactSourcePackageNotes=0`
- `FreshPkgdownBuildComplete=TRUE`
- `PublicPkgdownExecutionMode=NOT_CRAN-true`
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
