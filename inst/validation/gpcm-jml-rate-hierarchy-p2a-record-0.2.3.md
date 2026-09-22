# GPCM JML finite-depth rate hierarchy P2a record (0.2.3)

## Decision

P2a implements a structural lexicographic rate-hierarchy audit for expanded
sum-zero JML GPCM log slopes. Every applicable fit retains the scope result at
`config$boundary_audit$gpcm_rate_hierarchy`; declared path coefficient
families can be classified directly with
`mfrmr_jml_gpcm_rate_hierarchy()` inside the package.

The implementation closes the finite-coordinate depth question left open by
P1z. At stage `h`, only slope levels whose coefficients were zero at every
faster stage remain active. The first nonzero expanded sum-zero vector resolves
at least two levels, and each later nonzero stage resolves at least one active
level. A hierarchy for `J` slope levels therefore has at most `J-1` nonzero
stages. A five-level construction attains this bound.

This is not an arbitrary-path likelihood classifier. Each complete coefficient
vector must obey the global sum-zero identification, but the vector restricted
to still-active levels need not sum to zero: slower compensation can occur in
levels already resolved at a faster scale. Additive-coordinate hierarchies,
bounded remainders, tied utilities, extraction of scales from a finite
optimizer trace, and agreement between different accumulation subsequences
remain outside P2a.

## Lexicographic recursion

For strictly separated scales

```text
s_1(t) >> s_2(t) >> ... >> s_H(t),
```

write the expanded log-slope displacement as

```text
ell(t) - ell_0 = sum_h s_h(t) q_h + remainder(t),
sum_j q_hj = 0 for every h.
```

Initially every slope level is active. At stage `h`, P2a reads only
`q_h` on the active set:

- a positive coefficient resolves that level as `P`;
- a zero coefficient remains `Z` and proceeds to the next stage;
- the negative coefficient tier closest to zero resolves as `L`; and
- more-negative coefficients resolve as `D`.

Coordinates resolved at an earlier stage are shown as `.` in later role
signatures. Their slower coefficients are ignored for growth-order resolution
but remain available to make the complete `q_h` sum to zero.

The first nonzero global sum-zero stage has at least one positive and one
negative coordinate, resolving at least two levels. If levels remain, every
usable later stage resolves at least one. Hence

```text
H <= 1 + (J - 2) = J - 1.
```

An explicit sharp construction for five levels is

```text
q_1 = ( 1,-1, 0, 0, 0)
q_2 = (-1, 0, 1, 0, 0)
q_3 = (-1, 0, 0, 1, 0)
q_4 = (-1, 0, 0, 0, 1).
```

The role signatures are `PLZZZ`, `..PZZ`, `...PZ`, and `....P`. All four
vectors are globally sum-zero, although stages two through four have a
positive-only restriction on the active coordinates. This is why requiring
the active restriction itself to be sum-zero would incorrectly reject valid
secondary hierarchies.

## Common-primary different-limit construction

Both paths have primary rate

```text
q_1 = (1,-1,0).
```

The secondary choices are

```text
q_2+ = (-0.5,-0.5, 1),
q_2- = ( 0.5, 0.5,-1).
```

For `ell(t)=t*q_1+sqrt(t)*q_2`, the third slope has primary role `Z`.
Under `q_2+` it tends to infinity; under `q_2-` it tends to zero. For a binary
observation whose unscaled cumulative utility is `(0,1)` and whose observed
category is the top category, the log probabilities at `t=25,100,400` are

| Secondary direction | 25 | 100 | 400 | Limit |
| --- | ---: | ---: | ---: | ---: |
| `q_2+` | `-3.5073892e-65` | `0` | `0` | `0` |
| `q_2-` | `-0.6897838820` | `-0.6931244809` | `-0.6931471795` | `-log(2)` |

Thus the same primary compactification can contain different secondary roles
and different likelihood limits. Even a structurally complete slope-rate
hierarchy cannot certify a common likelihood limit without the compatible
additive hierarchy and response-specific conditions.

## Production states

The fit-level applicable state is
`finite_coordinate_rate_hierarchy_available_likelihood_open`. It records the
`J-1` theorem and exposes the P1z source identity, but it does not fabricate a
path hierarchy from the retained optimizer vector.

The direct declared-family helper returns:

| State | Meaning |
| --- | --- |
| `complete_finite_rate_hierarchy` | Every slope level has a first nonzero stage in the declared ordered family. |
| `declared_depth_exhausted` | Some levels remain zero after all declared stages. |
| `incomplete_zero_active_loading` | A declared stage is globally valid but zero on every still-active level. |
| `not_evaluated_rate_matrix` | Dimensions or finite numeric values are invalid. |
| `not_evaluated_levels` | Level identities are missing, duplicated, or dimension-mismatched. |
| `not_evaluated_scale_order` | Supplied exponents are not positive and strictly decreasing. |
| `not_evaluated_identification` | At least one complete coefficient vector violates sum-zero identification. |
| `not_evaluated_control` | The implementation zero tolerance is invalid. |

The fit-level audit also has explicit unit-slope, MML, non-GPCM, and invalid-
dimension states. Upstream compactification mismatch is recorded without
erasing the standalone finite-coordinate theorem and cannot create a
likelihood claim.

All states keep arbitrary-fit path extraction, arbitrary-sequence likelihood
classification, a common accumulation-direction likelihood limit, additive
hierarchy classification, global boundary classification, finite-global-
maximum and boundary-absence certification, uncertainty eligibility,
readiness effect, and external-comparison eligibility false.

## Verification

Eight focused files pass 671 expectations with zero failures, skips, warnings,
or errors:

| Test surface | Expectations |
| --- | ---: |
| P2a finite-depth rate hierarchy | 135 |
| P1z boundary compactification | 107 |
| P1y asymptotically-affine transport | 60 |
| P1x general constant-rate boundary | 54 |
| JML GPCM joint boundary | 74 |
| P1v/v2 fixed-objective classifier | 60 |
| P1w terminal-gradient stability | 83 |
| JML GPCM slope-only boundary | 98 |

The P2a file covers the two-stage secondary resolution, the sharp five-level
`J-1` construction, permutation invariance, exhausted/stalled/unused stages,
scale ordering, global sum-zero identification, malformed inputs, the common-
primary different-limit example, production attachment, source mismatch,
unit-slope reduction, and non-reuse for MML or PCM.

Eight additional release/readiness/scope/documentation guard files pass 1,084
expectations with zero failures, warnings, or errors. Three expected skips
remain: two require the uninstalled optional `diffobj` package and one is the
separately opt-in P1p stored-result pilot. The checklist remains 106 rows; the
joint-boundary row stays `review` with `pilot_required` criteria. The existing
local `testthat` R-version build warning is unchanged.

No FACETS executable, external fit, tolerance, recovery study, broad
simulation, or confirmation run is part of P2a.

## FACETS and claim consequence

P2a changes no FACETS role. FACETS PCM/JMLE versus mfrmr PCM/JML remains the
only possible future direct common-estimand FACETS lane. Non-unit GPCM/JML
remains truth-first, FACETS PCM remains a deliberately misspecified control,
and FACETS Table 7 discrimination remains diagnostic-only. A finite slope-rate
hierarchy cannot manufacture an estimator or model identity shared with
FACETS.

## Machine-readable disposition

```text
RateHierarchyImplemented = TRUE
RateHierarchyContract = mfrmr-jml-gpcm-rate-hierarchy-0.2.3-v1
GlobalCoefficientSumZeroRequired = TRUE
ActiveRestrictionSumZeroRequired = FALSE
MaximumNonzeroSlopeHierarchyStages = J-1
SharpDepthConstructionVerified = TRUE
PathwiseHierarchyExtractionAvailable = TRUE
ArbitraryFitPathHierarchyComputed = FALSE
SecondaryHierarchyStructurallyBounded = TRUE
SecondaryHierarchyLikelihoodClassified = FALSE
CommonAccumulationDirectionLikelihoodLimitCertified = FALSE
AdditiveHierarchyClassified = FALSE
GlobalBoundaryClassified = FALSE
GlobalFiniteMaximumCertified = FALSE
GlobalBoundaryAbsenceCertified = FALSE
ReadinessEffect = none_diagnostic_only
ExternalComparisonAuthorized = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

## Identity and verification

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-rate-hierarchy.R` | `76f628b4f8ef224a75b9e289d8b06ee6e785f95832132f9e3b34842fbbef16a0` |
| `R/core-jml-gpcm-boundary-compactification.R` | `36825fa1777956ae67770f2096d05db1f6124eb794f6970d7df6d30e4718df32` |
| `R/mfrm_core.R` | `ef2747cc9d62c0d359cca30f60f3539a0e92825ca3b2a6c09f7f202cf3979027` |
| `R/api-estimation.R` | `c8cbebc7af809de71d592cdd840059db005534ce20d977d10ae5e65aaaf7352f` |
| `man/fit_mfrm.Rd` | `e953d731d6e4c63bc3d63641d8ae5d270a6948db4427a1965e041647a5566a10` |
| `tests/testthat/test-jml-gpcm-rate-hierarchy.R` | `3b3e3168e4c7b148f2423bd7b6d9eb98a1add377df212d9e6aca704e8f2bfd43` |
| `NEWS.md` | `4429dc2fac1f7ae0230bce36a2b61eb11b60e0be4edc495a23001205f3ac286c` |
| `ROADMAP.md` | `c736cd8d6cf61788e7d13373801ba5e8b89e4d589028b5749088b4baf08d0eff` |
| `inst/validation/README.md` | `5f131443ac2fa9360a9a25eb53c760b94c6753a8aee59990e005a6b92d6462a1` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `6550c969504a7a626be71cecdebdf98f21eb10aa8b4eba99692d3df3f1838b42` |
