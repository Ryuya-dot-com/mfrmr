# GPCM JML higher-order response-image face lifts P2k record (0.2.3)

## Decision

P2k completes targetwise response-image closure membership for a fixed,
workload-admitted, zero-affine-offset JML GPCM operator whenever every ordered
owner-rate hierarchy is enumerated and numerically decided. It resolves the
P2j gap between a necessary nonnegative simplex-face witness and its sufficient
first-order lift.

The internal contract is
`mfrmr-jml-gpcm-higher-order-face-lifts-0.2.3-v1`. It:

1. reduces arbitrary zero-offset boundary approaches to finite ordered owner-
   rate hierarchies using semialgebraic curve selection and leading Puiseux
   terms;
2. enumerates every ordered partition of inactive slope owners into distinct
   positive rate stages;
3. expresses the necessary leading-coefficient conditions for each hierarchy
   as a sparse linear program;
4. turns every feasible hierarchy into an explicit finite product-one
   parameter path;
5. classifies the target outside the closure only when every admitted
   hierarchy is strictly excluded;
6. retains any earlier P2j finite-path certificate even when a coarser P2k
   numerical margin remains open; and
7. leaves likelihood envelopes, finite-JMLE adjudication, readiness, inference,
   MML, and comparison unchanged.

P2k is targetwise. It is not yet a symbolic decomposition of the entire
response-image closure as a set of globally parameterized strata.

## Higher-order inverse-slope paths

Use the P2j notation:

- `A` is the fixed adjacent-category additive design;
- `P` maps every adjacent row to one of `G` slope owners;
- `z` is the finite target response-contrast vector;
- `w_g = 1 / alpha_g` is the inverse slope; and
- `beta` is the free additive coordinate vector.

Finite image points satisfy

```text
diag(z) P w = A beta,     w > 0.
```

P2j normalizes `w` to the simplex and enumerates its limiting faces. For a
fixed proper face, P2k assigns every inactive owner a positive integer rate
`r_g`; active owners have rate zero. Rates use only their ordering: if the
distinct positive exponents are rational, multiply by their common
denominator; if they are arbitrary real leading exponents, an order-preserving
replacement by `1, ..., K` leaves the linear leading-coefficient conditions
unchanged.

For positive coefficients `c_g`, define

```text
w_g(epsilon) = c_g epsilon^(r_g),
beta(epsilon) = beta_0 + epsilon beta_1 + ... +
                epsilon^K beta_K,
K = max_g r_g.
```

On a row owned by `g`, finite convergence to `z_r` requires

```text
(A beta_k)_r = 0                       for k < r_g,
(A beta_r_g)_r = c_g z_r.              at k = r_g.          (1)
```

Terms with `k > r_g` vanish after division by `w_g(epsilon)`. P2k sets all
higher unused coefficients to zero, so (1) is sufficient as well as the exact
leading-order necessity for the declared hierarchy. The unrestricted
`beta_k` are split into positive and negative LP variables; `sum(c)=1` removes
common scale, and the objective maximizes the smallest `c_g`.

A residual-checked margin above the certificate tolerance yields a hierarchy
certificate. An exact-zero optimum or LP infeasibility strictly excludes that
hierarchy. A positive optimum at or below tolerance remains numerically open.

## Completeness of ordered hierarchies

The defining finite-image relation is semialgebraic. If `z` lies in its
Euclidean closure, semialgebraic curve selection supplies a real-analytic, or
after a finite reparameterization Puiseux, curve of finite parameter points
approaching `z`. Normalize inverse slopes as in P2j. Every nonzero owner
coordinate then has a positive leading coefficient and a nonnegative rational
leading exponent. Zero-exponent owners form the limiting simplex face;
positive exponents order the inactive owners into finitely many tied stages.

Compressing the distinct positive exponents to consecutive integers preserves
all equations in (1). Therefore one of P2k's ordered owner-rate hierarchies is
necessary for every closure curve. Conversely, a feasible hierarchy gives the
explicit polynomial path above. Exhaustive hierarchy feasibility is therefore
a targetwise closure membership decision for the zero-offset operator.

For `n` inactive owners, the hierarchy count is the ordered Bell number

```text
sum_(k=1)^n k! S(n,k),
```

where `S(n,k)` is a Stirling number of the second kind. Counts for one through
seven inactive owners are `1, 3, 13, 75, 541, 4683, 47293`. The implementation
precomputes this exact count and refuses an incomplete stage cap or hierarchy
workload.

## P2i recovery and P2j refinement

Both missing P2i axes have one inactive owner, hence exactly one hierarchy.
P2k reproduces the P2j/P2i first-order path and closure membership. P2i finite
points and targets without any P2j nonnegative face short-circuit without an
unnecessary hierarchy search.

For the three-owner, one-column all-ones operator,

```text
z_g = alpha_g beta,     product(alpha) = 1.
```

the target `(1,0,0)` has several compatible limiting faces. P2k enumerates
seven hierarchies in total. Three are feasible:

```text
rates = (1,0,0),
rates = (2,0,1),
rates = (2,1,0).
```

The first is the P2j lift from active face `{2,3}`. The latter two are genuinely
higher-order lifts from singleton active faces whose P2j first-order systems
were infeasible. For example, `rates=(2,0,1)` gives finite contrasts of the
form

```text
(1, epsilon^2, epsilon),
```

up to the positive LP coefficient normalization, and converges to `(1,0,0)`.
The explicit evaluator reconstructs product-one inverse slopes, additive
coordinates, and response contrasts at every finite index.

For the P2j counterexample `z=(1,-2,0)`, the only compatible face has two
inactive owners. P2k enumerates exactly

```text
rates = (1,1,0), (1,2,0), (2,1,0).
```

All three LPs are strictly infeasible. The target is therefore outside the
finite response-image closure, despite having a necessary nonnegative P2j face
witness. This closes that targetwise ambiguity without claiming that
nonnegative feasibility is sufficient in general.

## Numerical precedence and fail-closed behavior

P2k never weakens a P2j certificate. If P2j already supplies a finite
representative or an explicit first-order finite path, closure membership is
retained. A coarse P2k tolerance can leave the hierarchy proof numerically
open, but cannot relabel the point outside the closure.

For the rank-one target `(1, 10^6, 0)`, the best positive hierarchy coefficient
is about `10^-6`. With tolerance `10^-5`, P2k records
`source_closure_certified_hierarchy_numerical_margin_open`; with tolerance
`10^-8`, it certifies the hierarchy. Both results preserve the P2j first-order
closure certificate.

Malformed controls or sources, incomplete stage caps, hierarchy-count excess,
equation or sparse-LP caps, solver failures, invalid path sources, unknown or
infeasible hierarchy IDs, excessive path indices, and exponent spans fail
closed. No optimizer trace is searched or promoted.

## Verification

The focused P2k file executes 212 expectations with zero failures, skips, test
warnings, or errors. It covers:

- ordered Bell counts and exact surjection generation through seven owners;
- finite and simplex-outer-excluded P2j source short circuits;
- both P2i missing axes and their product-one finite paths;
- all seven rank-one `(1,0,0)` hierarchies;
- two genuinely higher-order lifts missed by the corresponding P2j faces;
- direct higher-order path convergence and parameter reconstruction;
- exhaustive exclusion of all three `(1,-2,0)` hierarchies;
- coarse-versus-tight numerical hierarchy margins with P2j precedence;
- response-row permutation invariance; and
- control, source, dependency-independent workload, solver, hierarchy, index,
  and exponent-span guards.

All 18 focused `test-jml-gpcm-*` files execute 2,298 expectations with zero
failures, skips, test warnings, or errors. This reproduces the prior 2,086
P1v--P2j expectations and adds the 212 P2k expectations without changing an
earlier result. The contiguous P2j/P2k pair executes 417 expectations. The
separate package-loading warning that `testthat` was built under R 4.5.3 while
verification used R 4.5.1 is environmental and is not a test warning.

The documentation-terminology, external-comparison-eligibility, and FACETS
GPCM/JML comparison-role guards execute 121 expectations with zero failures,
skips, test warnings, or errors.

A vignette-bearing `mfrmr_0.2.3.tar.gz` built from the final implementation and
documentation source passes `R CMD check --no-manual --ignore-vignettes` under
R 4.5.1 with zero errors, zero warnings, and one known optional cross-reference
NOTE for unavailable `lme4`, `eRm`, `mirt`, and `TAM`. The tarball build creates
the vignettes successfully; check-time vignette rebuilding is deliberately
skipped.

The checksum-bound claim-disposition profile then passes its 30 expectations
with zero failures, skips, test warnings, or errors after the revised release
checklist hash is bound.

## FACETS and response-family consequence

P2k changes no FACETS role. FACETS PCM/JMLE versus mfrmr PCM/JML remains the
only possible future direct common-estimand lane. These free GPCM slope-rate
hierarchies are not a FACETS PCM estimand, and FACETS Table 7 discrimination
remains diagnostic-only.

The response remains ordered binary or polytomous adjacent-category data.
P2k adds no nominal multinomial, grouped-binomial, count, or frequency-response
likelihood.

## Machine-readable disposition

```text
HigherOrderLiftContract = mfrmr-jml-gpcm-higher-order-face-lifts-0.2.3-v1
EstimatorIdentity = unpenalized_fixed_effects_jml_no_finite_box
ObjectiveIdentity = identified_conditional_joint_log_likelihood
ZeroAffineOffsetRequired = TRUE
SemialgebraicCurveSelectionReductionDerived = TRUE
PuiseuxOwnerLeadingRateReductionDerived = TRUE
OrderedIntegerRateCompressionDerived = TRUE
HierarchyLinearConditionsNecessaryForClosure = TRUE
HierarchyLinearConditionsSufficientByExplicitPath = TRUE
AllRequiredOrderedOwnerRateHierarchiesEnumerated = TRUE
TargetwiseZeroOffsetClosureMembershipClassified = TRUE
SourceClosureCertificateCanBeWeakened = FALSE
P2iMissingAxesRecovered = TRUE
P2jFirstOrderOpenFacesCanBeResolved = TRUE
P2jOuterOnlyCounterexampleExcludedByAllHierarchies = TRUE
NonnegativeFaceConditionSufficientForGeneralClosure = FALSE
SymbolicEntireOperatorClosureStratified = FALSE
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
NextGate = general_boundary_likelihood_envelope_over_rate_hierarchies
```

## Identity

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-higher-order-face-lifts.R` | `bf3e0bc4118c1eb7b7f49f72d69032ec76e39634af497231f3a756d2a7ca3db8` |
| `R/core-jml-gpcm-response-image-face-chart.R` | `92fce482bc185039df804986e4de62258472fa13f434beace5305e2c99b7c22c` |
| `R/api-estimation.R` | `3b93e4ef9600ae5a2064876aacd33b8f79f3dc02b2d4d7cf2d821e71e321c232` |
| `man/fit_mfrm.Rd` | `240cf9ecc13d282af667d345718cd4ab40403ef1a18ff27bbb8e692608f8311d` |
| `tests/testthat/test-jml-gpcm-higher-order-face-lifts.R` | `00ad4c0f6dbce621d39fedb74ec03df3925239116c093b6bae37d4d3393f4d96` |
| `tests/testthat/test-jml-gpcm-response-image-face-chart.R` | `1588157f311d229f4f833d27edda5303dd3a9678dcf026dfbc3c0ccc71a54ba7` |
| `NEWS.md` | `067b7fbe7d785efb98a1ef44b7d4acf1e919a83956bfcbc6b01601dbfd15311e` |
| `ROADMAP.md` | `01c6a74efb081b0d7e34574f8c197bb86cd2544e7678ca8d0929cdf5e8b4fb73` |
| `inst/validation/README.md` | `1e0eaf9028709142c974609651fe9e694ca163af1c9da8423ee7e0556bd6fb4a` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `319451a0304d86ae7e05c257190f5538c86b1c2b3ee084de619b536be978f5b0` |
| `inst/validation/claim-disposition-profile-0.2.3.csv` | `545409821e4674a45cc10e3f03483fdbfa87b4762ad5da4521efcafba0f66eff` |
| `inst/validation/claim-disposition-profile-0.2.3.md` | `0203b1e7ae55403688537e75737a74a318a8e16285ace52df70393d629959779` |
