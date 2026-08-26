# Fixed-calibration score UX local validation record for 0.2.4

Date: 2026-08-26

## Decision

The portable score review surface is locally complete for the current
development payload. The result now has a concise print method, a structured
summary, and interval, precision, and quadrature edge-mass plots. Review rows
are prioritised, Persons without a score coordinate remain explicitly
unplotted, and every uncertainty display states that calibration-parameter
uncertainty is excluded.

The dedicated help page, output guide, visual-diagnostics guide, README, and
portable-calibration article were rebuilt together. The article and help page
were inspected at desktop and 390 px widths. Browser DOM measurements at
390 px gave `body.scrollWidth == body.clientWidth == 390` and
`documentElement.scrollWidth == documentElement.clientWidth == 390` for the
article, help page, and reference index. Code blocks retain their own intended
horizontal scrolling.

This closes the local UX repair only. The previous candidate is still not
reusable. A fresh hosted matrix, a new candidate transition, and human release
sign-off remain required. No tag was created and no CRAN submission was
performed.

## Public surface

- `print.mfrm_calibration_score()` gives the batch disposition without dumping
  the full stored result.
- `summary.mfrm_calibration_score()` separates estimates, review/not-scored
  Persons, response-row disposition, settings, and interpretation boundaries.
- `plot.mfrm_calibration_score()` supports `interval`, `precision`, and
  `edge_mass`, including draw-free `mfrm_plot_data` and optional ggplot2
  conversion.
- `mfrm_calibration_score_methods` is present in the portable-calibration
  reference group.
- The portable-calibration article demonstrates artifact-only scoring, a
  concise review summary, and a rendered review-disposition interval figure.

## Local evidence

- R: `4.6.1` on `aarch64-apple-darwin23`
- pkgdown: `2.2.1`
- Fresh pkgdown build with installed development package: complete
- Desktop article render inspected: yes
- 390 px article render inspected: yes
- Desktop help render inspected: yes
- 390 px help render inspected: yes
- 390 px whole-page horizontal overflow: none on article, help, or reference
  index
- Targeted calibration, plot conversion, documentation, lifecycle, namespace,
  and G4 evidence tests: pass
- Exact source tarball: `mfrmr_0.2.4.9000.tar.gz`
- Source tarball SHA-256:
  `72cb885e525af14bb27d017210d06624d4a7722b11f50b69545c33b56c10c849`
- `R CMD check --no-manual` log SHA-256:
  `754c9796a4681bc4ee5de18bad11d967b98ef613320d8d40cf269e441577d5e2`
- Source check status: `OK`
- Source check errors / warnings / notes: `0 / 0 / 0`
- Packaged testthat expectations: `15866` pass, `0` fail, `43` skip,
  `42` expected warnings

The repository-wide monolithic development test command was also allowed to
finish. It is not a package gate: it deliberately includes `.Rbuildignore`d
historical research contracts pinned to the 0.2.3 namespace, prior receipts,
and optional backend ABIs. That run did not pass. Its failures included the
expected 0.2.3 namespace mismatch after loading 0.2.4.9000, exact historical
roadmap/receipt assumptions, and the pre-existing local glmmTMB/TMB ABI
mismatch. The exact source package check above is the distribution boundary;
the research contracts remain separately closed rather than being weakened to
manufacture a pass.

## Machine-readable disposition

- `DevelopmentVersion=0.2.4.9000`
- `ReleaseStatus=development`
- `PortableScorePrintAvailable=TRUE`
- `PortableScoreSummaryAvailable=TRUE`
- `PortableScoreIntervalPlotAvailable=TRUE`
- `PortableScorePrecisionPlotAvailable=TRUE`
- `PortableScoreEdgeMassPlotAvailable=TRUE`
- `DrawFreePlotDataAvailable=TRUE`
- `NotScoredDispositionRetained=TRUE`
- `CalibrationParameterUncertaintyExcludedAndDisclosed=TRUE`
- `FreshPkgdownBuildComplete=TRUE`
- `DesktopArticleRenderInspected=TRUE`
- `NarrowArticleRenderInspected=TRUE`
- `DesktopHelpRenderInspected=TRUE`
- `NarrowHelpRenderInspected=TRUE`
- `NarrowWholePageOverflowDetected=FALSE`
- `ExactSourcePackageCheckStatus=OK`
- `ExactSourcePackageErrors=0`
- `ExactSourcePackageWarnings=0`
- `ExactSourcePackageNotes=0`
- `PackagedTestsPassed=15866`
- `PackagedTestsFailed=0`
- `PackagedTestsSkipped=43`
- `RepositoryWideResearchSuitePassed=FALSE`
- `PreviousCandidateReusable=FALSE`
- `FreshHostedMatrixComplete=FALSE`
- `HumanSignOffComplete=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=commit-development-payload-and-run-fresh-five-platform-matrix`
