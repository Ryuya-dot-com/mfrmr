## Submission

This is a focused correction from mfrmr 0.2.3 to 0.2.3.1 in response to the
CRAN Team's 2026-08-25 request concerning the package's Additional issues.
The maintainer, license, public R API, and fitted-model contracts are
unchanged.

## CRAN-requested correction

The CRAN LTO check reported one-definition-rule warnings for `Rboolean` and
`R_UnwindProtect`. One C++ translation unit locally disabled
`HAVE_ENUM_BASE_TYPE`, while the cpp11-generated registration translation unit
used R's configured definition. The obsolete local override has been removed,
so all translation units now use the same R header configuration.

A source contract now rejects `HAVE_ENUM_BASE_TYPE` overrides in compiled
sources and `Makevars` files. A dedicated GCC 15 LTO build with `-flto=10` and
`-Werror=odr` links without warnings.

Four distinct FACETS/Winsteps documentation targets also began failing URL
checks because the upstream TLS certificate had expired. The hyperlinks were
removed while their substantive model distinctions and bibliographic
references were retained.

## Test environment

- Local: macOS Tahoe 26.5.2, arm64, R 4.6.1 (2026-06-24), Apple clang 21
- Dedicated LTO link: GCC 15.2.0, `-flto=10 -Werror=odr`
- Win-builder R-release: Windows Server 2022, R 4.6.1 ucrt, GCC 14.3.0
- Win-builder R-devel: Windows Server 2022, R-devel r90445 ucrt, GCC 14.3.0

## R CMD check results

The exact 0.2.3.1 source tarball completed
`R CMD check --as-cran --run-donttest` with 0 errors, 0 warnings, and 1 note.
The sole note was `Days since last update: 4`, which is expected for this
CRAN-requested correction shortly after publication of 0.2.3. The incoming
check reported no invalid URLs. Package tests, ordinary and `donttest`
examples, vignette rebuilding, and PDF and HTML manual checks completed
successfully.

A separate `NOT_CRAN=true R CMD check --no-manual` of the same tarball ran the
complete included testthat suite and finished with `Status: OK`.

The same source tarball completed both Win-builder R-release and R-devel
checks with 0 errors, 0 warnings, and 1 note. In each case the sole note was
the same expected `Days since last update: 4` incoming-feasibility note.

External proprietary software is not required to install, check, or use the
package.
