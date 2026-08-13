# GPCM JML exponential-balance P2g record (0.2.3)

## Decision

P2g classifies a finite but consequential family of JML GPCM parameter paths
that P2e deliberately leaves in its bounded response-contrast-image branch.
For the identified, unpenalized, fixed-effects JML objective with no finite
parameter box, write the retained adjacent utility in affine free coordinates
as

```text
u_adj(x) = b + A x.
```

Let the free-additive path be a finite exponential sum and the expanded
sum-zero log slopes be affine in the path index `t`. Each category contrast is
then an exact finite exponential sum. P2g adds coefficients with equal
combined exponents before assigning positive, zero, and negative asymptotic
roles and passing the positive flag plus finite base to P2e.

If the declared parameter path escapes every bounded set while every positive
response-contrast exponent cancels, the response-contrast image is bounded.
That path is an explicit witness that the parameter-to-response-contrast map
is not proper. This is a property of the parameterization and retained design;
it does not by itself prove a competitive boundary likelihood or finite-JMLE
nonexistence.

The contract is `mfrmr-jml-gpcm-exponential-balance-0.2.3-v1`. It changes no
readiness, uncertainty, MML, recovery, simulation, confirmation, promotion,
or external-comparison decision.

## Exact exponential expansion

For free-additive center `x_0`, directions `d_h`, and finite real rates `q_h`,

```text
x(t) = x_0 + sum_h exp(q_h t) d_h.
```

For slope level `j`, use the expanded identified log-slope path

```text
log alpha_j(t) = a_j + r_j t,
sum_j a_j = sum_j r_j = 0.
```

After the adjacent utilities are accumulated with category zero fixed at
zero, observation `i`, category `k`, and additive component `h` contribute a
term with combined exponent

```text
r_s(i) + q_h,
```

where the finite affine center, including `b`, has additive exponent zero.
The category contrast is therefore

```text
C_i,k(t) = sum_g exp(lambda_g t) B_i,k,g.
```

P2g performs exact equality grouping on `lambda_g` and sums the corresponding
coefficient matrices before dropping a globally zero group. It then assigns:

- `lambda_g > 0`: a scale-separated divergent P2e contrast-flag stage;
- `lambda_g = 0`: the finite P2e base contrast; and
- `lambda_g < 0`: a uniformly vanishing contrast remainder.

The P2e lexicographic support calculation gives the analytic row and weighted
joint-likelihood limit. A separate finite-index evaluator reconstructs the
original additive and slope parameters, rather than evaluating only the
grouped asymptotic representation.

This ordering matters. Two coordinate directions with the same exponent may
cancel after forward transport, and a growing slope may exactly balance a
vanishing utility. Classifying individual products before aggregation would
produce false divergent stages.

## Affine offset and canonical witness

The constrained additive map is affine, not universally linear. Facet and
Person anchors and nonzero group targets can produce `b != 0` even when every
retained free-additive coordinate is zero. P2g therefore includes `b` in the
finite-center component of both the analytic expansion and direct evaluator.

Production reconstructs `b` by expanding the exact zero optimizer vector
through the current response-kernel design. The canonical certificate is
accepted only when every retained adjacent-utility offset is implementation-
exactly zero. No tolerance, inverse solve, or retained-point subtraction is
used.

When `b = 0`, take every free-additive coordinate identically zero and choose
any nonzero expanded sum-zero log-slope direction. All adjacent utilities,
category utilities, and response contrasts are then identically zero, while
the log-slope parameter path escapes every bounded set. Thus the response
image is the single zero vector along an unbounded path, which proves
nonproperness.

A nonzero anchor fixture gives `b != 0`. Its production state is
`declared_exponential_balance_oracle_available_no_path_declared`, not the
canonical certificate. An explicitly evaluated zero-free-coordinate slope
path retains a positive response exponent and receives no bounded-image or
properness claim. This negative control prevents the unanchored result from
being overstated as universal to every non-unit GPCM design.

## Production surface

Every current non-unit GPCM/JML fit receives
`config$boundary_audit$gpcm_exponential_balance` after P2e and P2f. The audit
records whether the declared-path oracle is workload-admitted and whether the
canonical zero-utility witness is structurally available. It declares no
caller-specific exponential path and performs no path search.

The current-fit wrapper
`mfrmr_jml_gpcm_fit_exponential_balance_limit()` reconstructs the exact sparse
adjacent operator, affine zero-coordinate offset, retained base log slopes,
scores, slope ownership, and weights before classifying a caller-declared
path. Expanded retained log slopes may have a floating summation residual even
though their source expansion is structurally sum-zero; the wrapper records
that structural provenance without recentering the retained values.

PCM, MML, the exact unit-slope reduction, legacy P2e/P2f sources, malformed
offsets, directions, rates, weights, slope maps, and workload excesses fail
closed. A bounded parameter path may have a bounded response image but is not
a properness counterexample.

## What P2g does not prove

Nonproperness blocks the simple P2f strategy of proving finite attainment by
showing that every parameter escape must leave every bounded contrast set.
It does not imply that the likelihood lacks a finite maximizer: an unbounded
parameter sequence may remain inside one response-equivalence class while a
finite representative attains the same response distribution.

P2g classifies only declared finite exponential-sum paths. It does not prove
that every bounded-image escape has this form, search over centers or rates,
maximize the boundary likelihood, compare all response-equivalence classes,
or construct an upper envelope for every escaping sequence. The next gate is
therefore either a proper quotient parameterization by response equivalence or
a complete bounded-image plus divergent-image boundary envelope. P2f finite-
attainment and global-boundary-absence states remain open until that gate is
closed.

## Verification

The P2g test file executes 221 expectations with zero failures, skips,
warnings, or errors. It covers:

- inverse exponential utility decay against a growing slope;
- exact finite-index reconstruction and convergence to the analytic limit;
- equal-exponent aggregation and exact cancellation;
- positive combined exponents passed to the P2e flag oracle;
- divergent additive coordinates balanced by a vanishing slope;
- bounded parameter paths without a boundary claim;
- affine nonzero-offset analytic and direct evaluation;
- malformed dimensions, offsets, directions, rates, maps, weights, and
  workload controls;
- current-fit reconstruction and the unanchored canonical witness;
- production zero-offset properness refutation;
- nonzero-anchor fail-closed production and wrapper behavior; and
- PCM, MML, unit-slope, legacy-source, workload, readiness, and external-
  comparison non-promotion.

Fourteen focused JML GPCM boundary files from P1v through P2g execute 1,567
expectations with zero failures, skips, warnings, or errors. The surrounding
claim-disposition, documentation-terminology, release-readiness, model-
identity, FACETS-role, external-comparison, and core-workflow guards also pass.
The GPCM capability file passes after its installed package-private registries
are explicitly bound into the isolated `test_file()` environment; its three
existing CRAN-only skips remain unchanged.

A source tarball builds successfully with the existing prebuilt vignettes.
Under R 4.5.1 on Windows, the offline
`R CMD check --no-manual --ignore-vignettes` passes installation, static code
analysis, Rd validation, examples, and the CRAN-light test surface with zero
errors and zero warnings. The single NOTE is unchanged: Rd cross-references
name unavailable optional Suggested packages `lme4`, `eRm`, `mirt`, and `TAM`.
Repository-index access warnings are consequences of the offline environment
and do not change the check status.

The complete repository-only non-CRAN regression surface is not a valid
tarball test target because its repository validation inputs are intentionally
excluded from the built artifact. The relevant source-tree P1v--P2g and public-
contract guard surfaces were therefore run directly as reported above.

## FACETS and claim consequence

P2g changes no FACETS comparison role. FACETS PCM/JMLE versus mfrmr PCM/JML
remains the only possible future direct common-estimand lane. Non-unit
GPCM/JML remains truth-first, FACETS PCM remains a deliberately misspecified
control, and FACETS Table 7 discrimination remains diagnostic-only.

A bounded-image parameter escape is internal evidence about mfrmr's GPCM
parameter-to-response map. It creates no shared response model, estimator,
conditioning convention, parameter identity, boundary convention, or output
semantics with FACETS. Numerical agreement with a finite FACETS output cannot
repair open GPCM attainment or properness states. `external_comparison_eligible`
remains false.

## Machine-readable disposition

```text
ExponentialBalanceContract = mfrmr-jml-gpcm-exponential-balance-0.2.3-v1
EstimatorIdentity = unpenalized_fixed_effects_jml_no_finite_box
ObjectiveIdentity = identified_conditional_joint_log_likelihood
AdjacentUtilityMapAffine = TRUE
FiniteExponentialAdditivePathClassified = TRUE
AffineSumZeroLogSlopePathClassified = TRUE
EqualCombinedExponentsAggregatedBeforeClassification = TRUE
PositiveCombinedExponentUsesP2eFlag = TRUE
ZeroCombinedExponentUsesFiniteBase = TRUE
NegativeCombinedExponentVanishes = TRUE
BoundedResponseImageParameterEscapeRefutesProperness = TRUE
CanonicalZeroUtilityWitnessRequiresExactZeroAffineOffset = TRUE
NonzeroAnchorImpliesUniversalNonproperness = FALSE
ProductionPathSearchPerformed = FALSE
CompleteBoundedImageEscapeFamilyClassified = FALSE
CompleteEscapingSequenceBoundaryEnvelopeConstructed = FALSE
FiniteJMLEExistenceCertified = FALSE
GlobalBoundaryAbsenceCertified = FALSE
MMLGeometryClassified = FALSE
ReadinessEffect = none_diagnostic_only
ExternalComparisonAuthorized = FALSE
FACETSComparisonRoleChanged = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
NextGate = response_equivalence_quotient_or_complete_bounded_image_boundary_envelope
```

## Identity

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-exponential-balance.R` | `4826a63e81982a39e9ee47b802c44fb78d9cd29013c231715f5f465688b52bb5` |
| `R/mfrm_core.R` | `1d4960fc6ab93002ef44a55bea1096e2b452290d1a73c8213a39dbcb31cde0cf` |
| `R/api-estimation.R` | `7c758eb529141feb48ef16c0caf1a908dc6ac15bcf54f732e60c5cca5546d63f` |
| `man/fit_mfrm.Rd` | `9c20fb9723ba4f49c4c8e9f5ffa4fb6463a8455e64fe3e7e16124edef95ac9ca` |
| `tests/testthat/test-jml-gpcm-exponential-balance.R` | `f0509d0a01988da22a3332cf9c0a0eeeb1d2b55c6d3811c9f0d8e030533cead9` |
| `NEWS.md` | `1c008e3ae4deca46b9c7acb5360c8880a93a938c2081af7d21363c4e9d0e3220` |
| `ROADMAP.md` | `a056ba8a64b9aeebaf94553f88fd23c3ba3dbdd302f278162d3f5e771d781dcc` |
| `inst/validation/README.md` | `ef31a724b23b9f515bd4e450038d0ad0f4033047b473a260e151c826da83128e` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `e6b9d12dceb05d0888c9730ed8425dce3d57ddadbe03cbca33ebbb12a22d5b4f` |
