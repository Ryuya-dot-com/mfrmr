# Unreleased 0.2.4 candidate — not for submission

## Current source and earlier checked artifact

The current source additionally labels exported Bayesian summaries, retains
sampling-review decisions, and connects saved summaries to plots, credible
intervals and shared reports. Its final source-tarball qualification is pending.
The complete local check below applies to the earlier export-repair artifact,
not to these later reporting changes.

Earlier artifact SHA256: `80dc20208abb7fd12ddcbec42900a585735f903d593b2a07de9303242992cdbe`.

This candidate connects measurement, assessment planning and reporting. It
also closes the single-family GPCM and fixed-anchor model-export gaps:
RSM/PCM and single-family GPCM specifications on the fixed N(0,1) scale export
to Stan/brms, retaining supported fixed facet/group and step constraints.
Two-family GPCM remains Stan-only. Export adds explicit Bayesian priors; it
does not introduce a native Bayesian estimator or qualify MML intervals.

The optional ggplot2/Plotly gallery remains website-only, with no new package
installation dependency. Internal roadmaps and retained research results are
not distributed or tracked.

## Local checks and source attribution

The earlier artifact above completes macOS arm64/R 4.6.1 `R CMD check --as-cran
--timings` with **0 errors, 0 warnings and 1 NOTE**. The NOTE is the macOS
`xcrun_db` temporary-file residue. All **14,315** ordinary assertions pass,
with three established CRAN-profile research skips. Examples, vignette
rebuilding and PDF/HTML manuals pass. Remote incoming and system-clock checks
were disabled; unavailable repository-index network requests are not online
dependency qualification.

Check-only elapsed time is **567.239 seconds** (566.739–567.739 seconds under
the logged installation-time rounding). The entire command, including
installation, takes **604.239 seconds**. These are local measurements, not a
Windows timing certificate. No package check timeout was added or extended.

Exporter validation also includes 881 focused passing assertions, independent
response-law/constraint and prior-coordinate checks, compiled Stan/brms
log-density and gradient comparisons, bounded sampling, and fresh-session
moved-folder replay. Density-difference errors are below 4e-13 and gradient
errors below 1.2e-13 in the checked configurations. Short sampler runs test
execution and saved predictions, not posterior recovery or coverage. Fixed
anchors do not propagate uncertainty from an earlier calibration.

The installed anchored single-family help example exports both formats, and
the corresponding pkgdown reference page builds with its example. The two
changed articles were rebuilt; other article sources matched their retained
outputs, with the complete vignette index preserved. The normal check then
rebuilt the packaged vignettes. No complete NOT_CRAN research suite was rerun.

The later reporting changes pass focused regression tests, installed help
examples, saved Stan/brms summary replay, and a fresh-session portable-result
replay without loading either sampling backend. Both base and ggplot figures
were inspected. Likelihoods, priors and sampler settings are unchanged; the
earlier density/gradient checks remain applicable to those unchanged models.

## Dependencies and URLs

The October 26 CRAN source index contains 25,559 packages and lists no reverse
Depends, Imports, LinkingTo, Suggests or Enhances for mfrmr. All 43 distinct
external package dependencies are available; seven further dependencies are
supplied by R. Declared minimum versions are satisfied in the checked local
environment and available package index. Non-CRAN consumers are outside this
reverse-dependency check.

The earlier same-day URL review covered 532 occurrences / 247 distinct references, including 191
HTTP(S) URLs, with HTTP status exclusions disabled. Eighteen URLs were flagged:
one CASMA 404 was repaired and the replacement passed; eleven links point to
new repository/site content awaiting publication. Their local targets exist.
The remaining six findings are two PubMed browser checks (203), two access
refusals (403), and two connection timeouts. These are not a clean automated
URL result; no blanket URL exclusions were added.

## Still required before submission

The export-repair head has successful pkgdown, macOS and three Ubuntu checks.
Its Windows check failed when the R subprocess running the numeric-feature
workflow tests crashed; the underlying cause is unresolved. The current source
adds a failure-only diagnostic replay without dropping those tests or changing
time limits. It needs matching five-environment CI and pkgdown results on the
existing draft PR. Remote incoming checks, hosted links and browser
interaction/layout verification also remain open. No merge into main, site
deployment or CRAN submission/acceptance is claimed by these local results.

The later saved-summary head completed macOS checking with 14,472 passing
assertions, three established skips, and one failure: the exact S3-registration
test still expected the pre-summary method set. All four new methods were
registered; the expectation list is now updated. Windows/Linux did not start
because that macOS prerequisite failed. The same head's pkgdown build stopped
at the new figure's missing alt-text registration; its examples and pages
generated, and the corrected post-reference hook passes locally. These scoped
repairs still require matching remote checks; they do not resolve the earlier
Windows subprocess crash.
