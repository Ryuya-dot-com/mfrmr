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
  pre-fit structural-missingness/connectivity review;
- convergence guidance that treats `maxit` as a prespecified computational
  ceiling, keeps iteration-limited fits review-only, and prevents
  result-driven selection across reruns; and
- a deliberately scoped ConQuest MML comparison workflow for supported
  unidimensional binary, RSM, and PCM designs.

FACETS-style graphics reproduce the relevant visual grammar; no claim of
numerical identity with proprietary software is made.

The documented ConQuest overlap route was also run externally with ConQuest
5.47.5 Demonstration Version using matched 31-node quadrature MML. The
aggregate comparison is recorded in the public source repository's validation
record, which is not installed with the CRAN package. It covers only the stated
binary, item-only, one-covariate case and is not a general equivalence claim.

## Test environment

- macOS Tahoe 26.5.2
- aarch64-apple-darwin23
- R 4.6.1 (2026-06-24)

The final source tarball was built and checked with:

```sh
R CMD build .
_R_CHECK_FORCE_SUGGESTS_=false \
_R_CHECK_CRAN_INCOMING_REMOTE_=false \
_R_CHECK_SYSTEM_CLOCK_=false \
_R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_='^xcrun_db$' \
R CMD check --as-cran --no-manual mfrmr_0.2.2.tar.gz
```

Result: 0 errors, 0 warnings, and 0 notes (`Status: OK`). In the recorded local
check, the installed-package CRAN test selection completed with 385 passes,
no failures or warnings, and 3 intentional skips for longer GPCM coverage.

The local environment could not complete remote CRAN/Bioconductor index and
system-clock probes, so only those external probes were disabled; the local
CRAN incoming checks remained enabled. Apple clang also creates an
environment-only `xcrun_db` directory during compilation, which was excluded
from the final temp-directory detritus check after a separate run confirmed it
as the only NOTE. Package installation, source, compiled-code, help, examples,
tests, and vignette checks were otherwise run under `--as-cran`.

The CRAN selection exercises the public data review -> MML fit -> summary ->
Wright/pathway plot -> export route once, plus lightweight compatibility and
artifact contracts. The complete non-CRAN regression suite was also run
locally from the source tree with `NOT_CRAN=true`, with no failures, warnings,
skips, or errors. The complete suite is also selected on the Linux release job
in GitHub Actions.

## Downstream dependencies

No reverse dependencies were listed for mfrmr on CRAN on 2026-07-24.
