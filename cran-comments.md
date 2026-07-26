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
It is descriptive supporting context, not the 0.2.2 release gate; a broader
external-comparison gate remains scheduled for 0.2.3.

## Test environment

- macOS Tahoe 26.5.2
- aarch64-apple-darwin23
- R 4.6.1 (2026-06-24)

The final source tarball was built and checked with:

```sh
R CMD build .
_R_CHECK_TIMINGS_=0 \
R CMD check --as-cran --run-donttest mfrmr_0.2.2.tar.gz
```

Result: 0 errors, 0 warnings, and 0 notes (`Status: OK`). In the recorded local
check, the installed-package CRAN test selection completed with 392 passes,
no failures or warnings, and 3 intentional skips for longer GPCM coverage.

The full-manual check completed in 282.60 seconds of wall time. The CRAN-side
package workload was 153 seconds: examples including `donttest` blocks took
144 seconds, tests took 5 seconds, and vignette rebuilding took 4 seconds.
All timed top-level check components summed to 261 seconds; that broader value
is retained as diagnostic context and is not used as the package-controlled
timing gate. The PDF and HTML manual checks took 8 and 9 seconds. The remote
CRAN incoming feasibility probes were enabled and completed successfully.

The CRAN selection exercises the public data review -> MML fit -> summary ->
Wright/pathway plot -> export route once, plus lightweight compatibility and
artifact contracts. The complete non-CRAN regression suite was also run with
`NOT_CRAN=true`, with no failures or warnings. The complete suite is selected
on the Linux release job in GitHub Actions; the CRAN-time selection above
remains intentionally representative rather than exhaustive.

## Downstream dependencies

No reverse dependencies were listed for mfrmr on CRAN on 2026-07-24.
