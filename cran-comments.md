## Submission

This is an update from mfrmr 0.2.2 to 0.2.3. The maintainer and license are
unchanged.

The release strengthens numerical diagnostics, fail-closed inference
readiness, extreme-score handling, and the bounded generalized partial-credit
workflow. It does not claim unrestricted GPCM, general cross-software
equivalence, native multidimensional estimation, or new production
G-theory/D-study extensions.

## R CMD check

Local environment:

- macOS Tahoe 26.5.2, arm64
- R 4.6.1 (2026-06-24)
- `R CMD check --as-cran`

Current post-hardening local preflight: 0 errors, 0 warnings, 2 notes.

- One timing NOTE reported `diagnose_mfrm` at about 2 CPU seconds and 37.5
  elapsed seconds in the restricted local environment. An isolated replay of
  the complete documented example against the checked installation took 2.20
  elapsed seconds (2.18 CPU seconds), so the delay was not reproducible.
- One macOS toolchain NOTE reported the temporary `xcrun_db` cache.

The check included ordinary examples, `--run-donttest`, package tests,
vignette rebuilding, and PDF and HTML manual checks. External proprietary
software is not required to install, check, or use the package.

GitHub Actions run 32137294307 passed on all five configured jobs for committed
source e737e9b: Windows release, macOS release, Ubuntu oldrel-1, Ubuntu devel,
and Ubuntu release with the full `NOT_CRAN=true` test path. The R-devel CRAN
workload was 533 seconds against the unchanged 600-second gate. This matrix
checks the package across those environments; it is not evidence for external-
software equivalence.

The local execution environment could not perform remote CRAN incoming
lookups. Those lookups, Win-builder, and submission remain separate actions;
the cross-platform result does not erase or reclassify the two explained local
environmental NOTEs.
