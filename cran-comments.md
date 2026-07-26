## Submission

This is an update to mfrmr 0.2.1, the version currently on CRAN. This
submission is version 0.2.2. The maintainer and license are unchanged.

The principal user-facing changes are:

- reader-oriented `summary()` profiles for concise fit review,
  FACETS-oriented review, and reporting;
- improved native and FACETS-style Wright maps, an Infit-versus-measure
  pathway, and reusable draw-free plot data;
- convergence guidance that treats `maxit` as a prespecified computational
  ceiling and withholds interpretation from iteration-limited fits;
- `JML` as the canonical joint maximum likelihood label, with `JMLE` retained
  as a backward-compatible input alias;
- corrected bounded-GPCM score-side delta-method uncertainty, with explicit
  capability limits for unsupported score-side workflows; and
- reproducible data-review, diagnostic, export, replay, and reporting
  workflows, including a scoped ConQuest overlap route for supported
  unidimensional binary, RSM, and PCM designs.

FACETS-style graphics reproduce the relevant visual grammar; no claim of
numerical identity with proprietary software is made. ConQuest is not required
to install or check the package. The two examples that require separately
generated ConQuest files remain under `dontrun`.

## R CMD check results

The exact source tarball intended for submission was checked with:

```sh
R CMD check --as-cran --run-donttest mfrmr_0.2.2.tar.gz
```

Local environment:

- macOS Tahoe 26.5.2
- aarch64-apple-darwin23
- R 4.6.1 (2026-06-24)

Result: 0 errors, 0 warnings, and 0 notes (`Status: OK`). The CRAN incoming
feasibility checks, PDF manual, and HTML manual all completed successfully.
Examples, including `donttest` blocks, took 147 seconds; no individual example
exceeded 4.71 seconds. The installed-package CRAN test selection completed
with 392 passes, no failures or warnings, and 3 intentional skips for longer
GPCM coverage.

The same tagged source tree also passed GitHub Actions on macOS release,
Windows release, Ubuntu release, Ubuntu oldrel-1, and Ubuntu R-devel. The
complete `NOT_CRAN=true` regression suite ran separately on Ubuntu release
with 10,127 passes, 8 source-package-context skips, no failures, and no
warnings.

Official Win-builder R-devel also returned `Status: OK` on Windows Server
2022 x64 with R Under development (2026-07-25 r90301 ucrt). Installation took
55 seconds and the check took 335 seconds. Its CRAN test selection likewise
reported 392 passes, 3 intentional skips, no failures, and no warnings.

## Current CRAN status and downstream dependencies

The CRAN check page for mfrmr 0.2.1 showed all 13 listed flavors as `OK` when
reviewed on 2026-07-27. No reverse dependencies are listed on the CRAN package
page for mfrmr.
