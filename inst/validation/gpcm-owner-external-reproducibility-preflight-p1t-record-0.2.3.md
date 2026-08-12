# GPCM owner external-reproducibility preflight P1t record (0.2.3)

## Decision

P1t completes a no-fit, source/version-bound external-reproducibility
preflight for the admitted P1s denominator. The eight Criterion/Rater
source-owner, fit-owner, and JML/MML routes were crossed with ConQuest, TAM,
immer, and sirt, producing 32 required route-by-program decisions.

No current external route has an established exact full-model identity for
P1s. This is not a negative numerical result: no external fit was run. It is a
prior model/estimator-identity decision that prevents a nearby PCM, item-only
GPCM, product-slope model, or unsupported estimator from being called a P1s
reproduction because its estimates happen to be close.

## Bound denominator and result

The preflight accepts only the admitted P1s manifest SHA-256
`c7e51e7e166286dc690593921e661827f049252ec5859ea8928b129ab1e34f4f`.
It retains all eight route identities and all four source/version identities.

| Program | Unsupported | No exact route established | Reduction only | Non-equivalent | Exact full P1s |
| --- | ---: | ---: | ---: | ---: | ---: |
| ConQuest 5.47.5 | 4 | 4 | 0 | 0 | 0 |
| TAM 4.3-25 | 0 | 4 | 4 | 0 | 0 |
| immer 1.5-13 | 4 | 0 | 4 | 0 | 0 |
| sirt 4.2-133 | 4 | 0 | 0 | 4 | 0 |
| Total | 12 | 8 | 8 | 4 | 0 |

The classifications apply identically to both source-owner datasets and both
fit owners; they concern the requested fitted model, not whether the data were
generated under the aligned or alternate owner.

## Why the full routes are not admitted

### ConQuest

ConQuest `scoresfree` GPCM has an exact item-only MML likelihood and coordinate
map to current mfrmr GPCM. That result does not transport automatically to the
P1s many-facet model. Standard multifacet scoring attaches scores to
generalized items formed from active facet combinations and has not
established the one Criterion- or Rater-owned slope multiplying the complete
mfrmr adjacent-category predictor. The four P1s MML routes are therefore
`no_exact_route_established`, not failed numerical comparisons.

ConQuest documents that JML cannot estimate item scores. Consequently its four
P1s JML cells are unsupported rather than external nonconvergence evidence.
See the official [GPCM tutorial](https://conquestmanual.acer.org/s2-00.html)
and [command reference](https://conquestmanual.acer.org/s4-00.html).

### TAM

TAM supplies nonfaceted MML GPCM through `tam.mml.2pl()`, but its documented
many-facet fitting route does not estimate slopes. `tam.jml()` supplies a
unit-slope PCM reference rather than the free-slope P1s GPCM. The MML cells
therefore lack an exact combined facet-plus-slope route, while the JML cells
are retained only as lower-dimensional PCM reductions. See the official
[TAM manual](https://cran.r-project.org/web/packages/TAM/TAM.pdf).

### immer

`immer_jml()` estimates PCM designs and keeps its raw, extreme-adjusted, and
bias-corrected modes distinct. It is a useful JML reduction/reference but does
not reproduce a free-slope P1s GPCM. No matching immer MML route is registered.
See the official [immer JML help](https://search.r-project.org/CRAN/refmans/immer/html/immer_jml.html).

### sirt

`sirt::rm.facets()` is an MML near-neighbour. Its documented free-slope kernel
places the product of item and rater slopes on the trait term, retains rater
severity separately, and uses finite default slope bounds. That is not
mfrmr's selected-owner slope on the complete adjacent-category predictor.
The four MML routes are non-equivalent and the four JML routes are unsupported.
See the official [sirt help](https://search.r-project.org/CRAN/refmans/sirt/html/rm.facets.html).

## Separate projection registry

Five lower-dimensional or near-neighbour lanes remain scientifically useful,
but none is labelled P1s reproduction:

| Projection | Structural status | Existing numerical evidence |
| --- | --- | --- |
| ConQuest item-only intercept-population MML | Exact coordinate map established | One covariate microcase; review-only and not P1s |
| TAM item-only MML | Candidate requiring coordinate audit | None on P1s data |
| immer unit-slope PCM JML | Reduction only | Separate PCM pilots, not P1s |
| sirt equal-discrimination facets MML | Reduction only | None on P1s data |
| sirt item-only GPCM MML | Near-neighbour with finite-box difference | None on P1s data |

The exact ConQuest item-only map is a model statement. Its retained live
microcase did not freeze a prospective cross-engine tolerance, was not the
P1s intercept-only many-facet design, and used rounded native exports.
Accordingly it remains review evidence rather than an accepted external
candidate.

## Portfolio consequence

The result narrows external work rather than expanding it:

1. Do not run the 32 full route-by-program cells; none currently has an exact
   full-model admission path.
2. Do not use external optimizer completion to override mfrmr's zero-of-eight
   P1s inference-readiness result; readiness is a separate software contract.
3. Keep nonlinear estimability, slope/joint-boundary completeness, and fixed-
   objective stability as the next GPCM foundation blockers.
4. If a bounded external numerical lane is opened later, begin with a new
   item-only ConQuest or TAM MML projection. Freeze the coordinate map,
   retained rows, category map, quadrature ladder, stopping rules, raw numeric
   precision, and acceptance tolerance before execution.
5. Treat immer and equal-discrimination sirt results as Rasch/PCM reduction
   evidence, and general free-slope sirt results as sensitivity evidence.

No broad simulation is needed to reach these decisions. A future custom
ConQuest design or re-expression may change an `unproved` classification only
after probability-level and free-dimension identity is demonstrated; numerical
closeness alone cannot change it.

## Machine-readable disposition

```text
PlannedP1sRoutes = 8
Programs = 4
PlannedFullRouteProgramPairs = 32
FullP1sExactRoutes = 0
ProjectionOrNearNeighbourLanes = 5
ExternalFitsRun = 0
NoFitPreflightComplete = TRUE
P1sReproducedExternally = FALSE
ExternalExecutionAuthorized = FALSE
NumericComparisonAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

## Identity and tests

The ConQuest/TAM/immer versions and loaded-source audit are retained in
`conquest-tam-immer-tolerance-source-audit-0.2.3.md`, SHA-256
`b5fea18b3a38dfc7459815e0a5b9c1665406fad65f1e7f6a42e2dc5a4b1ced66`.
The installed sirt 4.2-133 source/default audit is retained in
`external-comparison-eligibility-contract-record-0.2.3.md`, SHA-256
`ec774da52390ee8bfa948347971e59bbe52a9362e2f73218fa7a43fdbb186adc`.
The locally installed ConQuest executable remains SHA-256
`61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48`.

| Artifact | SHA-256 |
| --- | --- |
| `gpcm-owner-external-reproducibility-preflight-p1t-0.2.3.R` | `6c4502051016bb12c3935b411b3ce92b8271e194918a585df8f3057ab7160882` |
| `test-gpcm-owner-external-reproducibility-preflight-p1t.R` | `1396c4098d541214c3770b0fb8caea8268dbd1c8ac2007b336ef61b1124de0db` |

Focused tests cover the exact 8-by-4 denominator, disposition counts, strict
separation of projection lanes, admitted-manifest binding, and fail-closed
owner, estimator-scale, runtime, and authority mutation.
