## Submission summary (`mfrmr` 0.3.0)

This feature release (`0.3.0`) updates `0.2.4` ahead of the 2026-11-24 deadline,
resolving all CRAN post-publication issues reported for `0.2.4` while slimming
the distributed documentation, vignette rebuild and ordinary CRAN test footprint.

### Fixes for CRAN additional issues

- **BLAS-portable numerical comparisons (`MKL` / `OpenBLAS`):** Replaced fragile
  exact or near-machine-epsilon floating-point assertions in matrix-factorization
  and optimization tests with scale-appropriate numerical tolerances while
  preserving model likelihood, gradient, Hessian and boundary-LP tolerances.
- **`mice` (>= 3.20.0) compatibility:** Updated imputed-feature validation tests
  for the logical-class restoration in `mice`, verified locally against
  development `mice` 3.19.16 (`151` passes, `0` failures, `0` warnings).
- **External URL and link hygiene:** Removed non-essential lecture and
  personal-page URLs that caused intermittent TLS certificate notes on Windows,
  replaced relative repository links in `README.md` with verified URLs, and
  retained `\alias{mfrmRFacets}` on `mfrmr_api_migration_030.Rd` for continuity
  with the `0.2.4` Rd cross-reference index.

### Package slimming and check-time management in 0.3.0

- **Vignettes (`inst/doc`, 1.9 MB):** Distributed tutorials are focused on five
  core workflows (`workflow`, `model-choice`, `gtheory`, `visual-diagnostics`,
  `reporting-and-apa`); specialized guides and case studies live on the package
  website outside the source tarball.
- **Reference manual (`man/`, 131 `.Rd` files, 1.9 MB installed help):**
  Consolidated related S3 methods and `mfrm_report()` component pages into
  shared parent topics while preserving all `513` help aliases, offline
  equations, identification constraints, unavailable-result states and short
  runnable examples (maximum single-example elapsed time `< 2.0 s` on Windows).
- **Ordinary CRAN test selection (`49` serial files):** Retains representative
  estimation across supported models (MML, JML, corrected JML, CML, GPCM),
  independent numerical checks, boundary-LP checks and saved-posterior checksum
  rejection regressions (`6,363` passes, `22` skips on Windows), while keeping
  the full `143`-file verification suite available under `NOT_CRAN=true`.
- **Static internal schemas:** Stored fixed reporting contracts, plot-view
  specifications and design-review registries as top-level package tables
  (`R/aaa-static-tables.R`) rather than rebuilding them via separate closures.

## Test environments and R CMD check results

1. **win-builder Windows Server 2022 x64, R 4.6.2 (R-release):**
   https://win-builder.r-project.org/5m5V76KBgwJd
   - **Status: `0 errors | 0 warnings | 1 note`**
   - Installation: `118 s`; Check time: `840 s` (`14 min 00 s`: R code check
     `299 s`, examples `58 s`, tests `239 s`, PDF/HTML manual `49 s` / `69 s`).
2. **win-builder Windows Server 2022 x64, R Under development (2026-11-16 r90914 ucrt):**
   https://win-builder.r-project.org/fvSxSASa6oBR
   - **Status: `0 errors | 0 warnings | 2 notes`**
   - Installation: `123 s`; Check time: `927 s` (`15 min 27 s`: R code check
     `331 s`, examples `62 s`, tests `234 s`, vignettes `26 s`, PDF/HTML manual
     `49 s` / `31 s`).
3. **Local macOS arm64 (`aarch64-apple-darwin23`), R 4.6.1, `cpp11` 0.5.4:**
   `R CMD check --as-cran --timings`
   - **Status: `OK (0 errors | 0 warnings | 0 notes)`** (`241.7 s` total
     including `35 s` installation; `6,365` passes, `21` skips).

### Notes and scope of final revision

- **`Suggests: cmdstanr` (`Additional_repositories`):** Expected CRAN incoming
  note; `cmdstanr` is verified available from `https://stan-dev.r-universe.dev`
  and all optional Stan tests/examples guard on `cmdstanr` availability.
- **Documentation-only delta after win-builder runs:** Relative to the archive
  checked in the two win-builder runs above, the submitted archive updates only
  `README.md` (replacing the three flagged relative repository file links and
  aligning release prose), `NEWS.md`, and `11` `.Rd` help pages (retaining
  `\alias{mfrmRFacets}` flagged by the R-devel cross-reference check against
  published `0.2.4` and adding primary literature references). All `230` parsed
  R code ASTs, C++ sources, data, vignettes and tests are unchanged, and the
  final archive passed `R CMD check --as-cran` locally with `Status: OK`.
- The check duration (`840 s` on Windows R-release, matching the published
  `0.2.4` R-release check time while covering the expanded `0.3.0` model scope)
  still exceeds 10 minutes; we hope this runtime remains acceptable.
- The terms "G-Study" and "D-Study" in `DESCRIPTION` refer to generalizability
  theory studies.

## Reverse dependencies

There are currently no reverse dependencies on CRAN.
