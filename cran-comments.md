## Submission

This is an update to mfrmr 0.2.1, the version currently on CRAN. Version
0.2.2 was released as a repository tag but was not submitted to CRAN; this
submission is version 0.2.3.

The principal user-facing changes are:

- a reader-oriented `summary()` workflow for fitted models, with concise,
  FACETS-oriented, and reporting profiles;
- improved native and FACETS-style Wright maps, including score-transition
  labels and explicit handling of displayed versus omitted coordinates;
- an Infit-versus-measure diagnostic pathway with optional person rows;
- a deliberately scoped ConQuest MML comparison workflow for supported
  unidimensional binary, RSM, and PCM designs;
- clearer privacy warnings and provenance metadata for exported result
  bundles; and
- a tighter default relative optimization tolerance for more reliable
  convergence assessment. The diagnostic threshold itself was not relaxed.

Existing native Wright maps remain available and retain their uncertainty
display. FACETS-style graphics reproduce the relevant visual grammar; no
claim of numerical identity with proprietary software is made.

## Test environment

- macOS Tahoe 26.5.2
- aarch64-apple-darwin23
- R 4.6.1 (2026-06-24)

The final source tarball was checked with:

```sh
_R_CHECK_FORCE_SUGGESTS_=false R CMD check --as-cran mfrmr_0.2.3.tar.gz
```

Result: 0 errors, 0 warnings, and 0 notes (`Status: OK`). The installed-package
CRAN test selection completed with 1,385 passes and 3 intentional CRAN skips
for longer GPCM coverage.

The complete non-CRAN regression suite was also run locally with long-running
fit, plotting, export, simulation, and documentation checks enabled. It
completed 1,583 test blocks and 9,963 expectations with 9,963 passes and no
skips, failures, errors, or warnings.

## Downstream dependencies

No reverse dependencies are listed for mfrmr on CRAN.
