# MML quadrature remedy record for mfrmr 0.2.4

Status: `implementation and package regression gate verified; source-tree-only
historical replay bounded`, 2026-09-07. The production behavior was frozen before implementation at
commit `e42e184cbde397acd6ff802e6299e90a77ce1750` and implemented at commit
`f3659d954a9b83ed9435b18bccedfefeffd8ccb5`.

## Implemented boundary

- `mml_quadrature_sensitivity()` now reuses the existing GPCM sensitivity
  machinery for RSM, PCM, and bounded GPCM MML fits.
- The output reports continuous same-data likelihood, identified measurement
  coordinate, fitted-probability, EAP, and posterior-SD movement. Slope and
  population-scale diagnostics remain conditional on their presence.
- Supported fitted two-way facet interactions enter the probability surface;
  they are not silently omitted.
- `gpcm_mml_quadrature_sensitivity()` remains as a GPCM-only public alias.
- Public portable extraction requires the exact highest-grid fit from a
  same-data review whose evaluated fits all completed estimation. The package
  does not select grids, assign a numerical cutoff, or label stability.
- The response-linked review object remains outside the portable artifact, so
  its schema and scoring-grid identity are unchanged.

## Verification

| Check | Result |
| --- | --- |
| RSM/PCM/GPCM quadrature, extraction, lifecycle, guide, example, namespace, and release-scope focused tests | pass |
| Frozen TAM RSM density/release and PCM conditional-stress contract tests | pass |
| Roxygen regeneration | pass |
| Source tarball `R CMD check --no-tests` | `Status: OK` |
| Exact source tarball `R CMD check`, `NOT_CRAN=true` | `Status: OK`; 16,506 package-test expectations passed, 0 failed |
| pkgdown reference, redirects, and executed portable-calibration vignette | pass |
| Initial raw source-tree `devtools::test()` diagnostic | not green: 232 errors/failures, dominated by package-excluded historical and optional research replays |
| Targeted roadmap, calibration, ConQuest/TAM version-boundary, repository-boundary, and G-theory ledger tests | pass |
| Release authorized | `FALSE` |

The raw source-tree diagnostic mixes the current package suite with historical
source-bound and optional research tests that `.Rbuildignore` deliberately
excludes. Stale public-roadmap coupling, version-bound 0.2.3 replays, and slow
G-theory launch checks were reconciled at their test boundaries; the relevant
targeted tests pass. The remaining weak-information G-theory replay requires a
matching `glmmTMB`/`TMB` binary environment and is not a 0.2.4 package gate.
This audit did not reclassify or rewrite its scientific evidence.

## Interpretation

The TAM stress comparison remains part of 0.2.4. Its practical consequence is
now represented in the package without making q181 a default, treating TAM as
truth, or substituting a package-owned decision threshold for user judgment.
The next 0.2.4 task is final diff review followed by the exact-head CI matrix,
not another quadrature feature or a broader estimator.
