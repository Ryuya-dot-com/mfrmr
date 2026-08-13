# GPCM JML response-image simplex-face chart P2j record (0.2.3)

## Decision

P2j lifts the exact P2i four-cell calculation to an arbitrary workload-admitted
fixed zero-offset adjacent-category GPCM operator. It does not yet complete the
general response-image closure. It supplies the algebraic finite-image chart,
the complete necessary simplex-face outer stratification, and an explicit
sufficient first-order lift for reachable proper faces.

The internal contract is
`mfrmr-jml-gpcm-response-image-face-chart-0.2.3-v1`. It:

1. reduces finite response-image membership to one linear feasibility system;
2. compactifies inverse slopes on a simplex and proves that every finite-image
   closure point has a nonnegative face witness;
3. enumerates every nonempty simplex face under a declared owner/face cap;
4. distinguishes strict full-support membership, reachable proper faces,
   outer-only face candidates, and points excluded by the necessary outer
   chart;
5. constructs an exact finite-parameter path for every certified first-order
   lift;
6. reproduces all P2i finite, missing-axis, and outside states; and
7. proves by a three-owner counterexample that a nonnegative face witness is
   not sufficient for closure membership in a general design.

The contract changes no retained optimizer result, primary estimate,
uncertainty, readiness, likelihood comparison, FACETS role, or response family.

## Fixed zero-offset operator

Let:

- `A` be the fixed `m x q` adjacent-category additive design;
- `P` be the `m x G` row-to-slope-owner incidence matrix;
- `beta` be the identified free additive coordinate vector;
- `alpha_g > 0` be the owner slopes with `product(alpha) = 1`; and
- `z` be the complete adjacent-category response-contrast vector.

For a zero affine offset,

```text
z = diag(P alpha) A beta.
```

Writing `w_g = 1 / alpha_g` gives

```text
diag(z) P w = A beta,     w > 0,     product(w) = 1.       (1)
```

Because the offset is zero, any positive solution `(w, beta)` can be multiplied
by a common positive scalar without changing (1). Choosing

```text
lambda = product(w)^(-1/G)
```

restores `product(lambda w) = 1`. Thus the product constraint can be replaced
for membership purposes by `sum(w) = 1`. For a fixed target `z`, finite-image
membership is exactly a linear feasibility question in `w` and `beta`.

The implementation splits each unrestricted additive coordinate into positive
and negative parts and maximizes a common margin `t` subject to

```text
diag(z) P w = A beta,
sum(w) = 1,
w_g >= t for every owner.
```

A residual-checked `t` strictly above the declared certificate tolerance gives
a finite representative. A positive optimum below the tolerance is not called
zero: the result becomes `not_certified_numerical_margin`. Only an
implementation-exact zero optimum or solver infeasibility excludes strict
relative-interior membership. This prevents a near-face finite point from
being mislabeled as a missing boundary.

## Necessary simplex-face closure chart

Consider any finite parameter sequence whose response contrasts `z_n` converge
to a finite `z`. Let `w_n = 1 / alpha_n` and normalize

```text
w_tilde_n = w_n / sum(w_n).
```

The normalized weights lie in the compact `G-1` simplex, so a subsequence
converges to a nonzero `w_star >= 0` with `sum(w_star) = 1`. Moreover,

```text
diag(z_n) P w_tilde_n
```

lies in the finite-dimensional column space of `A`. Its limit

```text
diag(z) P w_star
```

therefore also lies in that closed column space. Hence there is a `beta_star`
such that

```text
diag(z) P w_star = A beta_star.                            (2)
```

Every closure point must have such a nonnegative simplex-face witness. If
`w_star` is strictly positive, the rescaling argument already gives a finite
representative. A missing finite boundary can therefore occur only on a proper
simplex face.

P2j enumerates all `2^G - 1` nonempty supports under the declared face cap. For
each support it fixes inactive weights to zero and maximizes the minimum active
weight. This is a complete necessary outer stratification, not yet an exact
general closure classification.

## Sufficient first-order face lift

Suppose a proper-face witness `(w_star, beta_star)` satisfies (2). Let `I` be
the active owners and `J` the inactive owners. On every row owned by `J`, (2)
implies `(A beta_star)_r = 0`.

P2j searches for positive inactive weights `c_j` and one additive direction
`gamma` satisfying

```text
(A gamma)_r = c_owner(r) z_r,     owner(r) in J.           (3)
```

When (3) holds, define for `epsilon > 0`:

```text
w_g(epsilon) = w_star_g              for g in I,
w_g(epsilon) = epsilon c_g           for g in J,
beta(epsilon) = beta_star + epsilon gamma.
```

All weights are positive. On inactive rows the resulting contrast is exactly
`z_r`; on active rows it is

```text
z_r + epsilon (A gamma)_r / w_star_owner(r),
```

and therefore converges to `z_r`. A common rescaling of `w(epsilon)` and
`beta(epsilon)` restores `product(w) = 1` without changing any contrast. Thus
(3) is an explicit sufficient finite-parameter boundary lift, not a heuristic
direction.

`mfrmr_jml_gpcm_response_image_face_path_at()` evaluates this path at finite
indices, reconstructs product-one inverse slopes and additive coordinates, and
records contrast, equation, and log-slope-sum residuals. It never infers a path
from an optimizer trace.

## Exact recovery of P2i

For the P2i operator,

```text
A = ( 1  0 -1 )
    ( 0  1 -1 )
    ( 1  0  1 )
    ( 0  1  1 ),
owner = (1, 1, 2, 2).
```

Eliminating `beta` from (2) yields

```text
w_1 (z_1 - z_2) = w_2 (z_3 - z_4).
```

Strictly positive `(w_1,w_2)` gives the two same-sign interiors and their
zero-difference intersection. The two singleton supports give exactly the P2i
axes. Both singleton face witnesses satisfy the first-order lift equation, so
the general chart reproduces all five P2i strata. Opposite strict signs admit
no nonnegative face witness and are excluded from the closure outer bound.

The test suite compares six P2i targets directly against
`mfrmr_jml_gpcm_binary_closure_image_state()` and obtains identical finite,
closure, missing-boundary, and outside classifications.

## Why the nonnegative chart is not the closure

Let `A` be the three-row, one-column all-ones matrix and give every row its own
slope owner. Then

```text
z_g = alpha_g beta,     product(alpha) = 1.
```

Every nonzero finite point has all three coordinates with the same strict sign;
the finite-image closure is the union of the nonnegative and nonpositive
orthants. The target

```text
z = (1, -2, 0)
```

is not in that closure. Nevertheless, `w_star = (0, 0, 1)` and
`beta_star = 0` satisfy (2), so the necessary simplex-face chart has a proper
face witness. Its lift would require positive `c_1,c_2` and a scalar `gamma`
such that

```text
gamma = c_1,
gamma = -2 c_2,
```

which is impossible. P2j therefore returns
`outer_boundary_face_candidate_lift_open`, not closure membership. This exact
counterexample rules out replacing the general closure problem by nonnegative
kernel feasibility alone.

For comparison, the target `(1,0,0)` has the active face `{2,3}` and a valid
first-order lift, while `(1,-2,3)` has no nonnegative face witness and is
excluded by the necessary outer chart.

## Numerical and workload controls

The contract requires `lpSolve`, exact zero affine offsets, finite design and
target entries, contiguous owner indices, and explicit caps on rows,
coordinates, owners, faces, LP nonzeros, and solver time. Nonzero offsets fail
closed because common scaling no longer removes the product constraint.

The default maximum of 12 owners permits at most 4,095 nonempty faces. Every
face LP must finish with an optimal or infeasible status. Solver failures,
workload excesses, malformed inputs, and positive margins below the declared
certificate tolerance remain unclassified. The latter behavior is exercised
by a finite P2i point with a very small positive full-support margin: a coarse
tolerance leaves it open and a tighter tolerance reconstructs it as finite.

## Verification

The focused P2j file executes 205 expectations with zero failures, skips, test
warnings, or errors. It covers:

- the finite-image equivalence and product-one reconstruction;
- positive, negative, and equal-difference finite P2i points;
- all six representative P2i finite/axis/outside states;
- both singleton-axis first-order lifts;
- finite path reconstruction and convergence;
- a three-owner rank-one finite point and reachable boundary;
- the nonnegative-face-but-no-lift counterexample;
- a no-face outer exclusion;
- the one-owner reduction to a closed additive column space;
- row permutation, redundant-column, and sparse-design invariance;
- coarse-versus-tight near-face numerical margins; and
- input, offset, dependency-independent workload, solver-cap, source, face,
  index, and contract controls.

All 17 focused `test-jml-gpcm-*` files execute 2,086 expectations with zero
failures, skips, test warnings, or errors. This reproduces the prior 1,881
P1v--P2i expectations and adds the 205 P2j expectations without changing an
earlier result. The separate package-loading warning that `testthat` was built
under R 4.5.3 while verification used R 4.5.1 is environmental and is not a
test warning.

The documentation-terminology, external-comparison-eligibility, and FACETS
GPCM/JML comparison-role guards execute 121 expectations with zero failures,
skips, test warnings, or errors.

A vignette-bearing `mfrmr_0.2.3.tar.gz` built from the implementation and
documentation source passes `R CMD check --no-manual --ignore-vignettes` under
R 4.5.1 with zero errors, zero warnings, and one known optional cross-reference
NOTE for unavailable `lme4`, `eRm`, `mirt`, and `TAM`. The tarball build creates
the vignettes successfully; check-time vignette rebuilding is deliberately
skipped.

The checksum-bound claim-disposition profile then passes its 30 expectations
with zero failures, skips, test warnings, or errors after the revised release
checklist hash is bound.

## FACETS and response-family consequence

P2j changes no FACETS role. FACETS PCM/JMLE versus mfrmr PCM/JML remains the
only possible future direct common-estimand lane. The free GPCM slope-owner
geometry in this chart is not a FACETS PCM estimand, and FACETS Table 7
discrimination remains diagnostic-only.

The target remains the ordered adjacent-category response contrast generated
by ordinary binary or polytomous ordinal rows. The chart adds no nominal
multinomial, grouped-binomial, count, or frequency-response likelihood.

## Machine-readable disposition

```text
ResponseImageFaceContract = mfrmr-jml-gpcm-response-image-face-chart-0.2.3-v1
EstimatorIdentity = unpenalized_fixed_effects_jml_no_finite_box
ObjectiveIdentity = identified_conditional_joint_log_likelihood
ZeroAffineOffsetRequired = TRUE
FiniteImagePositiveInverseSlopeEquivalenceDerived = TRUE
InverseSlopeSimplexCompactificationDerived = TRUE
EveryFiniteClosurePointHasNonnegativeFaceWitness = TRUE
ProperSimplexFaceNecessaryForMissingBoundary = TRUE
AllNonemptySimplexFacesEnumeratedWithinWorkload = TRUE
FirstOrderFaceLiftSufficiencyDerived = TRUE
NonnegativeFaceConditionSufficientForGeneralClosure = FALSE
P2iFiveStrataExactlyRecovered = TRUE
GeneralCounterexampleToNonnegativeFaceSufficiency = TRUE
CompleteGeneralResponseImageClosureStratified = FALSE
CompleteGeneralBoundaryLikelihoodEnvelopeConstructed = FALSE
OptimizerTraceUsed = FALSE
FiniteJMLEExistenceCertified = FALSE
FiniteJMLENonexistenceCertified = FALSE
MMLGeometryClassified = FALSE
ReadinessEffect = none_theorem_only
ExternalComparisonAuthorized = FALSE
FACETSComparisonRoleChanged = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
NextGate = higher_order_face_lifts_and_general_closure_completion
```

## Identity

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-response-image-face-chart.R` | `92fce482bc185039df804986e4de62258472fa13f434beace5305e2c99b7c22c` |
| `R/core-jml-gpcm-binary-closure-envelope.R` | `2e2f79f9f9e32aba334fa4d4dc66b09b369e815b0a50989f122c4580223121d4` |
| `R/api-estimation.R` | `6c7191a11e205f2dfd62e22691503f63d6d0978aaeec391d07f2a81edeb4cfc9` |
| `man/fit_mfrm.Rd` | `ec08f5ba1291e2afee7a019fcf832a4e3ae111a0546cf09214a2d4df0b926683` |
| `tests/testthat/test-jml-gpcm-response-image-face-chart.R` | `1588157f311d229f4f833d27edda5303dd3a9678dcf026dfbc3c0ccc71a54ba7` |
| `tests/testthat/test-jml-gpcm-binary-closure-envelope.R` | `4ae33ddad3d91f9a3c94df61e0e81516406954931a804a556b41c15e4861a621` |
| `NEWS.md` | `3aae3f148f044fd41e0106c0e173ae449d9fd2018f059a0a46828834f5975801` |
| `ROADMAP.md` | `519b1adf193f4a7af67a18d81a8f7896cd122f52fbc90f1766ca128c9baf9989` |
| `inst/validation/README.md` | `a4dac3e9cda0a511fc6d8c51b4582366a90dfe69d30308dc049cc30b73cc2c4b` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `4b1db616d58695d63694326e0f9524f54bff2c2ae8f1d93a50eb8f570b36b262` |
| `inst/validation/claim-disposition-profile-0.2.3.csv` | `545409821e4674a45cc10e3f03483fdbfa87b4762ad5da4521efcafba0f66eff` |
| `inst/validation/claim-disposition-profile-0.2.3.md` | `916b9d5f75535fb525b920c32154c904e0b1644f725b0e691fb29068b92e232d` |
