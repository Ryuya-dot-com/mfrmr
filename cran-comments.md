## Submission

This is an update to mfrmr 0.2.1, the version currently on CRAN. This
submission is version 0.2.2.

The principal user-facing changes are:

- a reader-oriented `summary()` workflow for fitted models, with concise,
  FACETS-oriented, and reporting profiles;
- improved native and FACETS-style Wright maps, including score-transition
  labels, uncertainty in the native display, and explicit handling of
  displayed versus omitted coordinates;
- an Infit-versus-measure diagnostic pathway with optional person rows;
- a reproducible operational teaching dataset and clearer privacy and
  provenance information, including an explicit planned-assignment roster and
  pre-fit structural-missingness/connectivity review; and
- a deliberately scoped ConQuest MML comparison workflow for supported
  unidimensional binary, RSM, and PCM designs.

FACETS-style graphics reproduce the relevant visual grammar; no claim of
numerical identity with proprietary software is made.

The documented ConQuest overlap route was also run externally with ConQuest
5.47.5 Demonstration Version using matched 31-node quadrature MML. The
aggregate comparison is recorded in the installed validation notes. It covers
only the stated binary, item-only, one-covariate case and is not a general
equivalence claim.

## Test environment

- macOS Tahoe 26.5.2
- aarch64-apple-darwin23
- R 4.6.1 (2026-06-24)

The final source tarball was built and checked with:

```sh
R CMD build .
_R_CHECK_FORCE_SUGGESTS_=false R CMD check --as-cran mfrmr_0.2.2.tar.gz
```

Result: 0 errors, 0 warnings, and 0 notes (`Status: OK`). In the recorded local
check, examples completed in 15 seconds and the installed-package CRAN test
selection completed in 3.963 seconds with 350 passes, no failures or warnings,
and 3 intentional skips for longer GPCM coverage.

The CRAN selection exercises the public data review -> MML fit -> summary ->
Wright/pathway plot -> export route once, plus lightweight compatibility and
artifact contracts. The complete non-CRAN regression suite was also run
locally with `NOT_CRAN=true`: 9,952 passes, no failures or warnings, and 9
intentional skips because source documentation files are unavailable after
package installation. The skipped source-policy checks were run separately
from the source tree with no failures, warnings, or skips. The complete suite
is also selected on the Linux release job in GitHub Actions.

## Downstream dependencies

No reverse dependencies were listed for mfrmr on CRAN on 2026-07-24.
