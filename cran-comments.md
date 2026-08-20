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
- `R CMD check --as-cran --run-donttest`

The exact source at commit `f839df9` completed with 0 errors, 0 warnings, and
0 notes. CRAN incoming feasibility, ordinary and `donttest` examples, package
tests, vignette rebuilding, and PDF and HTML manual checks all completed. The
release-readiness review classified all 14 current distribution-first gates as
`ok`; its package-controlled CRAN workload was 134 seconds against the
unchanged 600-second gate.

External proprietary software is not required to install, check, or use the
package.

GitHub Actions run 32334840726 passed on all five configured jobs for the same
commit `f839df9`: Windows release, macOS release, Ubuntu oldrel-1, Ubuntu devel,
and Ubuntu release with the full `NOT_CRAN=true` test path. The R-devel CRAN
workload was 450 seconds and the full Ubuntu workload was 573 seconds, both
against the unchanged 600-second gate. This matrix checks the package across
those environments; it is not evidence for external-software equivalence.

Win-builder and submission remain separate actions. Local and cross-platform
package checks do not establish external-software equivalence.
