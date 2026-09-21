## Unreleased 0.2.4 candidate

This update from 0.2.3.1 integrates portable calibration and new-Person scoring,
external-feature clustering and imputation sensitivity, and multivariate
observed-score G/D-studies. The maintainer and license are unchanged.

Portable calibration remains limited to eligible one-scale RSM/PCM MML fits
with a fixed standard-normal scoring basis. Its intervals condition on the
saved calibration and prior. Exploratory feature groups do not provide latent
classes or pooled inference. Multivariate G/D-studies support the documented
crossed and Person-by-(Child-within-Parent) designs; plan-difference intervals
are approximate, pointwise and restricted to explicit normal random effects
with two crossed facets. Missing-row omission does not correct selection bias.

The update also includes ICC, shrinkage/replay and result-availability repairs.
Saved-analysis instructions distinguish reprinting, recomputing, rescoring
and refitting. External proprietary software is not needed to install or use
the package.

## Verification of this integrated source

Selected source archive: `mfrmr_0.2.4.tar.gz`, SHA256
`ae2550a21d3834ddcd42de3e4b985778aad61e2597f2b6a873cd4dd9473b6da5`.
Local environment: arm64 macOS, R 4.6.1.

The initial integrated archive completed examples (including `--run-donttest`),
vignettes and vignette rebuilding. Its standard tests returned 1,901 passes,
one failure, no test warnings and three intentional CRAN skips. The failure
was an outdated expected S3-method inventory, missing the three newly added
plan-comparison methods. The corrected inventory and export check pass all
four expectations against the installed package.

The selected archive differs only in that test file and generated DESCRIPTION
metadata. All executable code, NAMESPACE, help, examples, vignette sources and
outputs, and remaining tests are byte-identical. Their successful checks are
reused. The selected archive's own `R CMD check --no-manual --no-tests
--no-examples --no-vignettes` returns 0 errors, 0 warnings and 0 notes; this is
not reported as a repeated full test/example execution.

The installed portable-calibration public API additionally passes 224
expectations, including saved-calibration scoring in a fresh R process, with
no test failures, warnings or skips. Test transcripts and the initial
failed check are preserved with the archive comparisons in the repository
validation records.

Package-index access was unavailable in this restricted-network environment;
the fetch warnings are retained in the logs. CRAN incoming, current reverse
dependencies, PDF-manual checks and a hosted platform matrix were not rerun
for this archive. This draft does not authorize submission or publication.
