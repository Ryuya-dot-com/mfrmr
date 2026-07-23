## Submission

This is an update to mfrmr 0.2.1, the version currently on CRAN. Version
0.2.2 was released as a repository tag but was not submitted to CRAN; this
submission is version 0.2.3.

The principal user-facing changes are:

- a reader-oriented `summary()` workflow for fitted models, with concise,
  FACETS-oriented, and reporting profiles;
- improved native and FACETS-style Wright maps, including score-transition
  labels, uncertainty in the native display, and explicit handling of
  displayed versus omitted coordinates;
- an Infit-versus-measure diagnostic pathway with optional person rows;
- a reproducible operational teaching dataset and clearer privacy and
  provenance information; and
- a deliberately scoped ConQuest MML comparison workflow for supported
  unidimensional binary, RSM, and PCM designs.

FACETS-style graphics reproduce the relevant visual grammar; no claim of
numerical identity with proprietary software is made.

## Test environment

- macOS Tahoe 26.5.2
- aarch64-apple-darwin23
- R 4.6.1 (2026-06-24)

The final source tarball was built and checked with:

```sh
R CMD build .
_R_CHECK_FORCE_SUGGESTS_=false R CMD check --as-cran mfrmr_0.2.3.tar.gz
```

Result: 0 errors, 0 warnings, and 0 notes (`Status: OK`). Examples completed
in 12 seconds and the installed-package test selection completed in 25.53
seconds, with 1,385 passes, no failures or warnings, and 3 intentional skips
for longer GPCM coverage.

As an additional example-level check, all 127 active help topics were run
individually. Their combined elapsed time was 3.967 seconds, the slowest topic
took 0.784 seconds, and none produced an error or warning.

The complete non-CRAN regression suite was also run locally. It completed in
667.10 seconds with 9,747 passes, no failures or warnings, and 9 skips for
source-only documentation checks that are unavailable after package
installation. Those source-only checks were run separately without skips.
The complete suite is also selected on the Linux release job in GitHub
Actions by setting `NOT_CRAN=true`; it is not run during CRAN checks.

## Downstream dependencies

No reverse dependencies were listed for mfrmr on CRAN on 2026-07-24.
