# Public documentation surface audit for mfrmr 0.2.4

Status: source and rendered-surface audit complete, 2026-09-06. This is an
internal review record; it is not NEWS content or a user-facing release claim.

## Corrections

- Added the omitted `mfrmr-portable-calibration` article to the README
  vignette list.
- Replaced the stale `planned 0.2.4 portable calibration workflow` wording for
  RSM and PCM in the public roadmap with `0.2.4 development portable
  calibration workflow`.
- Made no change to NEWS: these are development-tree documentation alignments,
  not additional package capabilities.

## Mechanical and rendered checks

| Surface | Result |
| --- | --- |
| `pkgdown::check_pkgdown()` | pass |
| Full `pkgdown::build_site()` | pass in 285 seconds |
| Source vignettes | 8 |
| Rendered article pages, excluding article index | 8 |
| Source vignette represented in article index | 8/8 |
| Source vignette represented in navbar | 8/8 |
| Source vignette represented in README list | 8/8 |
| Rendered reference pages | 281 |
| pkgdown URL, favicon, Open Graph, article metadata, reference metadata checks | pass |
| Internal release-gate vocabulary in README, ROADMAP, NEWS, vignettes, R, or man | none found |

The primary public help pages checked for generated optimizer-review warnings
were `fit_mfrm`, `mfrmr_workflow_methods`, `mfrm_calibration_workflow`,
`mfrm_calibration_methods`, `mfrm_calibration_score_methods`,
`gpcm_capability_matrix`, and `gpcm_runtime_guard_coverage`; none contained the
warning text. The workflow, portable-calibration, and GPCM articles were also
present in both the article index and navbar.

## Semantic alignment

The README, roadmap, help, and vignettes keep these boundaries consistent:

- one latent dimension is distinct from any number of observed facets;
- portable calibration is limited to the documented RSM/PCM MML fixed-basis
  route;
- bounded GPCM fitted-object support does not imply portable GPCM calibration;
- `TAM::tam.mml.mfr()` multifacet estimation does not itself estimate free
  item slopes; `TAM::tam.mml.2pl()` is a separate GPCM/slope route;
- an external TAM import or comparison does not turn a multidimensional or
  unmatched estimand into one mfrmr scale.

## Deliberate non-change

Seventy-two secondary reference pages render an optimizer-readiness warning
from deliberately short examples. The warning is scientifically meaningful:
it tells readers that an iteration-limited toy fit is review-only. Suppressing
it page by page would hide the package's safety contract, while raising every
example ceiling would expand pkgdown runtime substantially. The primary entry
pages are clean, so no 72-file local patch was made. Revisit this only as a
shared example-runtime redesign during API/documentation consolidation, or
earlier if user evidence shows that the secondary-page warnings impede use.
