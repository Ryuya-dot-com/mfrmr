# GPCM JML boundary compactification P1z record (0.2.3)

## Decision

P1z implements a structural compactification audit for the identified,
unpenalized, no-finite-box JML GPCM parameter space. Every fit retains the
result at `config$boundary_audit$gpcm_boundary_compactification`.

The audit proves that every unbounded finite-dimensional parameter sequence
has a subsequence with a convergent normalized direction. It then partitions
every nonzero limiting expanded sum-zero log-slope direction into positive
(`P`), zero (`Z`), leading-negative (`L`), and deeper-negative (`D`) roles.
This closes a structural enumeration question only. It does not evaluate the
likelihood along an arbitrary sequence, require the complete normalized
sequence to converge, or establish a common likelihood limit across different
accumulation directions.

Zero primary-rate coordinates and the sector in which the complete primary
log-slope direction is zero can retain slower divergent scales. P1z records
that secondary hierarchy as required and unclassified. Therefore the new
audit has no global-boundary, finite-maximum, boundary-absence, uncertainty,
readiness, recovery, simulation, external-comparison, or FACETS consequence.

## Compactification theorem

Let `x_n - x_0` be any unbounded sequence of identified free-additive and
expanded sum-zero log-slope displacements, and set

```text
s_n = ||x_n - x_0||_2,
u_n = (x_n - x_0) / s_n.
```

The `u_n` lie on a unit sphere in a finite-dimensional Euclidean subspace.
Compactness supplies a subsequence `u_nk -> u = (d,q)`. Because every expanded
log-slope displacement has sum zero, `sum(q)=0`.

If `q` is nonzero, it contains at least one positive and one negative
coordinate. P1z assigns:

- `P` to every positive coordinate;
- `Z` to every zero coordinate;
- `L` to the negative coordinates closest to zero; and
- `D` to every more-negative coordinate.

Only the signs, zero set, and first negative tier enter the existing P1x
sufficient asymptotic conditions. Every role pattern therefore has a
canonical sum-zero representative with equal positive rates, `-1` for `L`,
and `-2` for `D`. This does not say that the original rate vector equals that
representative or that its sublinear residual is covered by P1y.

For `J` slope levels, the exact number of primary patterns containing at least
one `P` and one `L` is

```text
4^J - 2*3^J + 2^J.
```

The zero-free count is `3^J - 2*2^J + 1`; the difference contains at least one
`Z`. The ordered-pair count remains `J(J-1)`. The production audit records all
counts separately from whether the workload-bounded P1x LP search completed.

| Slope levels | All primary patterns | Zero-free | Contains Z | Ordered pairs | Beyond pairs |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 2 | 2 | 2 | 0 | 2 | 0 |
| 3 | 18 | 12 | 6 | 6 | 12 |
| 4 | 110 | 50 | 60 | 12 | 98 |
| 5 | 570 | 180 | 390 | 20 | 550 |
| 6 | 2,702 | 602 | 2,100 | 30 | 2,672 |

## Nonconvergent-direction construction

The sum-zero rate sequence alternates between scalar multiples of

```text
q_A = (1,-1,0),
q_B = (0,1,-1).
```

Its complete normalized sequence does not converge. The odd and even
subsequences are constant after normalization and converge to
`q_A/sqrt(2)` and `q_B/sqrt(2)`, respectively. This directly checks the exact
role of compactness: it reduces a nonconvergent sequence to accumulation
directions but supplies neither a unique direction nor a common likelihood
limit.

## Zero-primary-rate secondary hierarchy

The explicit sum-zero path

```text
ell(t) = t*(1,-1,0) + sqrt(t)*(-0.5,-0.5,1)
```

satisfies `ell(t)/t -> (1,-1,0)`. The third coordinate therefore has primary
role `Z`, but after subtracting the primary term the residual norm grows as
`sqrt(t)` and its normalized direction is constant. This proves that a finite
primary P/Z/L/D role partition cannot by itself classify every unbounded
path. The same issue occurs when the complete primary slope direction is
zero relative to a faster additive scale.

P1z deliberately does not assert that repeated compactification terminates at
a particular depth, preserves one likelihood limit, or fits inside P1y's
vanishing-residual neighborhood.

## Production contract

The applicable state is
`primary_subsequence_partitioned_secondary_hierarchy_open`. It records:

- finite-dimensional unit-sphere compactness and convergent normalized
  subsequences;
- complete finite primary role enumeration for every nonzero limiting slope
  direction;
- exact total, zero-free, zero-containing, pair, and beyond-pair counts;
- the upstream fixed-objective classifier and P1y transport identities; and
- an explicit open secondary hierarchy for zero primary-rate coordinates.

Unit-slope GPCM returns `not_required_unit_slope`. MML and non-GPCM models
return estimator/model-specific non-applicable states. Invalid dimensions or
controls fail closed. Upstream contract mismatch is recorded but does not
erase the standalone finite-dimensional topology theorem; it cannot create a
boundary-likelihood claim.

All states keep `secondary_hierarchy_classified`,
`finite_secondary_hierarchy_depth_certified`,
`nonconvergent_normalized_rate_boundary_classified`,
`arbitrary_nonvanishing_residual_boundary_classified`,
`general_curved_path_classified`, `global_boundary_classified`,
`global_finite_maximum_certified`, `global_boundary_absence_certified`,
uncertainty eligibility, and external-comparison eligibility false.
`readiness_effect` is `none_diagnostic_only`; the numerical zero-role
tolerance is implementation-only and not frozen for scientific claims.

## Verification

Seven focused files pass 536 expectations with zero failures, skips, warnings,
or errors:

| Test surface | Expectations |
| --- | ---: |
| P1z boundary compactification | 107 |
| P1y asymptotically-affine transport | 60 |
| P1x general constant-rate boundary | 54 |
| JML GPCM joint boundary | 74 |
| P1v/v2 fixed-objective classifier | 60 |
| P1w terminal-gradient stability | 83 |
| JML GPCM slope-only boundary | 98 |

The P1z file covers exact combinatorial counts, role assignment, canonical
representatives, permutation invariance, combined additive/slope
normalization, alternating accumulation directions, the divergent
zero-primary secondary scale, a three-level production fit, source-contract
mismatch, unit-slope reduction, invalid dimension/control, and non-reuse for
MML or PCM.

Eight additional release/readiness/scope/documentation guard files pass 1,084
expectations with zero failures, warnings, or errors. Three expected skips
remain: two require the uninstalled optional `diffobj` package and one is the
separately opt-in P1p stored-result pilot. The checklist remains 106 rows; the
joint-boundary row stays `review` with `pilot_required` criteria. The existing
local `testthat` R-version build warning is unchanged.

No FACETS executable, external fit, tolerance, recovery study, broad
simulation, or confirmation run is part of P1z.

## FACETS and claim consequence

P1z changes no FACETS role. FACETS PCM/JMLE versus mfrmr PCM/JML remains the
only possible future direct common-estimand FACETS lane. Non-unit GPCM/JML
remains truth-first, FACETS PCM remains a deliberately misspecified control,
and FACETS Table 7 discrimination remains diagnostic-only. Normalized-
subsequence compactness cannot create a common FACETS estimand or authorize an
external numerical comparison.

## Machine-readable disposition

```text
BoundaryCompactificationImplemented = TRUE
CompactificationContract = mfrmr-jml-gpcm-boundary-compactification-0.2.3-v1
FiniteDimensionalUnitSphereCompactnessApplied = TRUE
UnboundedSequenceHasConvergentNormalizedSubsequence = TRUE
WholeSequenceRateConvergenceRequired = FALSE
CanonicalPrimaryRolePartitionComplete = TRUE
ZeroPrimaryRateSecondaryHierarchyRequired = TRUE
SecondaryHierarchyClassified = FALSE
FiniteSecondaryHierarchyDepthCertified = FALSE
NonconvergentNormalizedRateBoundaryClassified = FALSE
ArbitraryNonvanishingResidualBoundaryClassified = FALSE
GeneralCurvedPathClassified = FALSE
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
| `R/core-jml-gpcm-boundary-compactification.R` | `36825fa1777956ae67770f2096d05db1f6124eb794f6970d7df6d30e4718df32` |
| `R/mfrm_core.R` | `631711adf43c49cd9d6cadd9632a023efb25025da1173ddc26dcc7b328b43236` |
| `R/api-estimation.R` | `66944364d3a2b9f472de8062d9f7d162f7bc2d34d0267b02e2e583faefef9c0b` |
| `man/fit_mfrm.Rd` | `92dc77f02a12db6999abfc30d048e65aae0343da576451024e60620dfcb9e421` |
| `tests/testthat/test-jml-gpcm-boundary-compactification.R` | `68dc1501d3fb8e695de602c514237d68d031928f41d3ded158587443de99e51f` |
| `NEWS.md` | `5e61a53a3a2b2373d21ca3d6e30e380ca481b89eda2acfa7d2cc349299667415` |
| `ROADMAP.md` | `ab9fcd0eb2cda0896ca9a55c3a01895621558538015d9d71508b819961aa58bf` |
| `inst/validation/README.md` | `d971af6d7f6afd6f2067fc9c2352118d51a6b81f79afb28a5cf8142e54ab7de7` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `71daceb1e447b948e69568a9f411b6b74da3b1714e7acc428df3b832711bfa7d` |
