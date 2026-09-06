# MML quadrature remedy record for mfrmr 0.2.4

Status: `implementation scope verified; repository-wide regression baseline
open`, 2026-09-07. The production behavior was frozen before implementation at
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
| pkgdown reference, redirects, and executed portable-calibration vignette | pass |
| Full test suite on the current host | not green: 130 failing tests across 48 files before final documentation/test-only adjustments |
| Release authorized | `FALSE` |

The full-suite failures are concentrated in older content-hashed ConQuest,
fixed-calibration roadmap, G-theory D-SIM, and weak-information stationarity
evidence chains. Representative D-SIM-3 launch-readiness, D-SIM-3 final-launch,
and stationarity-authorization failures were reproduced from a clean archive
of the pre-implementation `HEAD`; they are not evidence of a quadrature API
regression. This audit did not reclassify or rewrite their scientific evidence.
The exact implementation commit therefore passes its affected surface and
package-documentation checks, but the frozen contract's repository-wide
full-test requirement remains open until the inherited validation baseline is
reconciled.

## Interpretation

The TAM stress comparison remains part of 0.2.4. Its practical consequence is
now represented in the package without making q181 a default, treating TAM as
truth, or substituting a package-owned decision threshold for user judgment.
The next 0.2.4 task is repository validation-integrity repair and an exact-head
full-suite rerun, not another quadrature feature or a broader estimator.

