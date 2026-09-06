# MML quadrature remedy contract for mfrmr 0.2.4

Status: prospectively frozen before production implementation, 2026-09-06.
This contract responds to the retained RSM and PCM TAM stress results. It is a
software behavior contract, not a scientific decision rule.

## User-level diagnostic

`mml_quadrature_sensitivity()` will refit the same response data and the same
stored model specification at two or more user-selected quadrature orders. It
will support the package's ordered MML families (`RSM`, `PCM`, and bounded
`GPCM`) and preserve the existing `gpcm_mml_quadrature_sensitivity()` entry
point as a compatible GPCM-specific wrapper.

The result will report continuous, aligned differences relative to the source
fit in at least:

- negative log likelihood per Person;
- identified measurement coordinates and category probabilities;
- same-Person EAP and posterior SD;
- GPCM slopes and raw diagnostic SEs when present; and
- population scale when present.

It will retain refit conditions, convergence/readiness fields, the evaluated
grid orders, and the exact same-prepared-data check. It will not label a result
stable/unstable, choose a practical tolerance, change inference readiness, or
select a model. Additive and currently supported two-way facet-interaction
fits must be evaluated without silently dropping the interaction term.

## Portable extraction

The public `extract_mfrm_calibration()` route will require an explicit
`mfrm_quadrature_sensitivity` object. The selected source fit must be exactly
one of its same-data fits, use the highest quadrature order evaluated in that
object, and all evaluated fits must have completed estimation. This is a
procedural fail-closed boundary: it prevents a low-grid source fit from being
silently relabelled as a reviewed portable calibration, while leaving the
choice of evaluated grids and acceptable numerical movement to the user.

The diagnostic object is not embedded in the portable artifact: it contains
source fits and response-linked state that the artifact intentionally excludes.
Users must archive the diagnostic separately when an audit trail is needed.
The portable artifact's existing schema and scoring-grid identity therefore do
not change. The internal draft constructor remains available only to package
validation code; the public wrapper enforces this new prerequisite.

## Acceptance checks

- RSM and PCM same-data refits expose finite objective, coordinate,
  probability, EAP, and posterior-SD movement without an automatic verdict.
- The existing GPCM public behavior and S3/APA routes remain compatible.
- Changed response rows, model families, or unmatched source fits fail closed.
- Public portable extraction refuses a missing review, a non-sensitivity
  object, a non-highest-grid source fit, or a review with incomplete
  estimation.
- The full package tests, installed help, vignette, and pkgdown-facing wording
  describe the user-owned choice and contain no internal gate vocabulary.

This remedy does not implement adaptive quadrature, make q181 a default,
certify every possible dataset, or promote estimated-population portable
calibration.

