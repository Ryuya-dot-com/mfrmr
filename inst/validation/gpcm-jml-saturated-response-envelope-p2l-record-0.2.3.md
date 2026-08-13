# GPCM JML saturated-response likelihood envelope P2l record (0.2.3)

Status: repository theorem-only evidence; no production promotion.

## Scope

P2l connects the P2j/P2k targetwise response-image closure theorem to the
ordered-category likelihood for a fixed zero-offset JML GPCM operator. It
answers a narrower question than the complete likelihood envelope over every
closure stratum: what happens when the unique independent saturated response
optimum itself is in the finite response image, on a missing finite boundary,
or outside the response-image closure?

The result:

1. derives the independent saturated adjacent contrasts and likelihood value
   for strictly positive category mass;
2. proves strict concavity in complete response-contrast coordinates;
3. proves that unbounded response contrasts send the likelihood to minus
   infinity;
4. passes the unique saturated target to P2j/P2k for targetwise finite-image
   and closure classification;
5. certifies a finite global JMLE when the target is finitely represented;
6. certifies an exact nonattained global supremum and finite-JMLE
   nonexistence when the target is in the closure but not the finite image;
7. evaluates the corresponding P2j/P2k product-one finite path and its
   likelihood gap; and
8. when the saturated target is outside the closure, proves that a constrained
   closure maximum exists strictly below the saturated upper bound while
   leaving its value, location, and finite representability open.

P2l requires a zero additive offset, complete transition-major adjacent rows,
contiguous slope-owner identifiers, strictly positive finite category mass,
and successful workload-bounded P2j/P2k certificates. It consumes no optimizer
trace and changes no stored fit, estimate, uncertainty, readiness, MML, or
external-comparison state.

## Ordered-category saturated optimum

For observation `i`, let categories be `k = 0,...,K-1`, let every grouped mass
`m_ik` be strictly positive, and set `n_i = sum_k m_ik`. With category-zero
utility fixed at zero, cumulative utilities and adjacent contrasts satisfy

```text
eta_i0 = 0,
eta_ik = sum_{h=0}^{k-1} z_ih,
z_ih = eta_i,h+1 - eta_ih.
```

The observation log likelihood is

```text
L_i(eta_i) = sum_k m_ik eta_ik
             - n_i log(sum_k exp(eta_ik)).                 (1)
```

Its score sets the softmax probability equal to `m_ik / n_i`, so the unique
solution is

```text
eta_ik* = log(m_ik / m_i0),
z_ih* = log(m_i,h+1 / m_ih).                              (2)
```

Substitution gives the independent saturated value

```text
L_sat = sum_i sum_k m_ik log(m_ik / n_i).                 (3)
```

On the `K-1` free cumulative utilities, the negative Hessian is `n_i` times
the positive-definite baseline-coordinate submatrix of
`diag(p_i) - p_i p_i'`. Strict positivity of every mass makes every `p_ik`
positive, so (1) is strictly concave and (2) is the unique response optimum.
The adjacent-to-cumulative transformation is invertible; uniqueness therefore
also holds in adjacent contrasts.

This is the existing ordered-category softmax likelihood written with grouped
repeated-row mass. Integer masses can encode literal repetitions and positive
noninteger masses can encode likelihood weights. Neither representation adds
a nominal-multinomial response, a grouped-binomial response family, a Poisson
or other count likelihood, or a generic frequency outcome to mfrmr.

## Response-space coercivity

For any observation, let `R_i = max_k eta_ik - min_k eta_ik`. Since every
summand `eta_ik - logsumexp(eta_i)` is nonpositive, choosing a minimum-utility
category gives

```text
L_i(eta_i) <= -m_i,min R_i.                               (4)
```

Every adjacent contrast is the difference of two consecutive cumulative
utilities, so `R_i >= max_h |z_ih|`. With finitely many observations, an
unbounded full adjacent-contrast norm therefore makes at least one `R_i`
unbounded. Equation (4) proves that the joint likelihood tends to minus
infinity. Consequently every parameter sequence with a finite likelihood
limsup has a bounded response-contrast subsequence.

This argument is in finite response space and does not assert that the
parameter-to-response map is proper. P2h/P2k explicitly exhibit divergent
parameters with bounded response images.

## Closure disposition theorem

Let `I` be the finite response image of the fixed identified zero-offset GPCM
operator and `cl(I)` its Euclidean closure. The likelihood is continuous, and
`I` is dense in `cl(I)` by definition, so

```text
sup_{z in I} L(z) = sup_{z in cl(I)} L(z).                (5)
```

P2j tests finite membership of `z*` and supplies every necessary simplex-face
witness. P2k exhausts the ordered inverse-slope owner-rate hierarchies and
either constructs an explicit finite product-one path or excludes `z*` from
the closure. Equations (1)--(5) then give three dispositions.

### Finite saturated target

If `z* in I`, the P2j finite representative attains `L_sat`. No response point
can have a larger likelihood, so this representative is a finite global JMLE.

### Missing finite saturated boundary

If `z* in cl(I) \ I`, a P2j/P2k finite product-one path converges to `z*` and
its likelihood converges to `L_sat`. Strict concavity makes `z*` the only
response point attaining `L_sat`; because `z*` has no finite representative,
no finite parameter point attains the global supremum. This proves finite-JMLE
nonexistence without observation-category separation: all `m_ik` are positive.

### Saturated target outside the closure

If `z*` is outside `cl(I)`, its value is only an upper bound. Coercivity makes
every relevant upper level set compact; intersecting with the nonempty closed
set `cl(I)` gives a closure maximizer. Strict concavity and uniqueness of `z*`
make its value strictly smaller than `L_sat`. P2l does not calculate this
constrained value or location, and it does not decide whether that maximizing
closure response has a finite representative. This is the remaining general
boundary likelihood-envelope gate.

## Canonical checks

The P2i operator uses

```text
A = [1 0 -1; 0 1 -1; 1 0 1; 0 1 1],
owner = (1,1,2,2).
```

With binary failure mass `(1,1,1,1)` and success mass `(2,4,1,1)`, (2) gives
`z* = (log(2),log(4),0,0)`. P2k places this target on the missing owner-1
dominant boundary and supplies `rates_1_0`. P2l reproduces the exact P2i value
`-7.184143344815158`, certifies nonattainment, and directly verifies decreasing
response distance and likelihood gap along indices `0,1,3,8,20`.

Success mass `(4,2,4,2)` gives a finite-image saturated target and a finite
global representative. Success mass `exp(1,-2,0,1)` gives opposite nonzero
owner differences, so P2k excludes the saturated target from the closure; P2l
records an uncomputed constrained maximum strictly below the saturated bound.

A three-category check stacks two copies of the P2i additive operator in
transition-major order. Mass rows `(1, exp(z_i), exp(z_i))` give first-adjacent
targets `(log(2),log(4),0,0)` and second-adjacent targets zero. The same missing
boundary and likelihood-convergent product-one path are certified. A separate
four-row identity operator supplies a finite three-category control. Thus P2l
is not restricted to binary outcomes, although it remains restricted to
ordered adjacent-category likelihoods.

## Guard behavior

Nonpositive, nonfinite, nonnumeric, one-category, dimension-mismatched, or
workload-excess mass inputs fail closed. Invalid or noncontiguous owner maps,
nonfinite designs, nonzero or mismatched offsets, invalid controls, incomplete
face enumeration, incomplete hierarchy enumeration, numerical LP margins, and
invalid path indices or exponent spans also fail closed. A valid positive-mass
problem retains its strict-concavity and coercivity facts even if numerical or
workload limits leave closure membership unclassified; it never promotes a
finite existence or nonexistence claim in that state.

## Verification

The focused P2l file executes 322 expectations with zero failures, skips, test
warnings, or errors. It covers:

- exact cumulative-utility, log-sum-exp, saturated target, and objective
  reconstruction;
- the P2i positive-mass missing boundary and exact supremum;
- product-one finite path response and likelihood convergence;
- finite-image and finite-JMLE controls, including the equal-difference
  intersection;
- saturated targets outside the closure and the strict-lower-bound scope;
- binary and three-category ordered responses;
- direct strict-concavity and response-coercivity checks;
- mass scaling, aligned response-row permutation, sparse input, and redundant
  additive-column invariance; and
- malformed mass, design, owner, offset, workload, numerical-margin, and path
  controls.

All 19 focused `test-jml-gpcm-*` files execute 2,620 expectations with zero
failures, skips, test warnings, or errors. This reproduces the prior 2,298
P1v--P2k expectations and adds 322 P2l expectations without changing an
earlier result. The documentation-terminology, external-comparison-eligibility,
and FACETS GPCM/JML comparison-role guards execute 121 expectations with zero
failures, skips, test warnings, or errors. The separate package-loading warning
that `testthat` was built under R 4.5.3 while verification used R 4.5.1 is
environmental and is not a test warning.

A vignette-bearing `mfrmr_0.2.3.tar.gz` was built from the final source with
all seven vignettes generated successfully. The tarball passes
`R CMD check --no-manual --ignore-vignettes` under R 4.5.1 with zero errors,
zero warnings, and one known optional cross-reference NOTE for unavailable
`lme4`, `eRm`, `mirt`, and `TAM`. The definitive check used a nonsynchronized
temporary directory so that a Dropbox file-rename race could not create an
environmental installation warning. The standard package test slice passed
inside that clean tarball check.

The checksum-bound claim-disposition profile then passes its 30 expectations
with zero failures, skips, test warnings, or errors after the revised release
checklist hash is bound. Together with the three documentation/FACETS/external-
comparison guard files, the final guard set executes 151 expectations.

## FACETS and response-family consequence

P2l changes no FACETS comparison role. FACETS PCM/JMLE and mfrmr PCM/JML remain
the only potential future direct common-estimand lane. P2l concerns free GPCM
slope owners; FACETS Table 7 discrimination remains a post-fit diagnostic and
is not a jointly estimated FACETS GPCM slope.

The response is ordered binary or ordered polytomous. The category-mass matrix
groups repetitions of those ordered response rows inside the theorem. It does
not authorize nominal multinomial, grouped-binomial, Poisson/count, or generic
frequency-response fitting in mfrmr.

## Machine-readable disposition

```text
SaturatedEnvelopeContract = mfrmr-jml-gpcm-saturated-response-envelope-0.2.3-v1
EstimatorIdentity = unpenalized_fixed_effects_jml_no_finite_box
ObjectiveIdentity = identified_conditional_joint_log_likelihood
ZeroAffineOffsetRequired = TRUE
StrictlyPositiveCategoryMassRequired = TRUE
IndependentSaturatedOptimumUnique = TRUE
UnboundedResponseContrastLikelihoodLimit = minus_infinity
TargetwiseClosureSource = P2j_P2k
FiniteSaturatedTargetImpliesFiniteGlobalJMLE = TRUE
MissingFiniteSaturatedTargetImpliesNonattainedGlobalSupremum = TRUE
OutsideClosureSaturatedTargetIsExactConstrainedSupremum = FALSE
OutsideClosureConstrainedMaximumExistsStrictlyBelowSaturatedBound = TRUE
AllPositiveMassProfilesSymbolicallyClassified = FALSE
ConstrainedOutsideTargetEnvelopeConstructed = FALSE
OptimizerTraceUsed = FALSE
ProductionFitApplied = FALSE
MMLGeometryClassified = FALSE
ReadinessEffect = none_theorem_only
ExternalComparisonAuthorized = FALSE
FACETSComparisonRoleChanged = FALSE
NominalMultinomialResponseAdded = FALSE
CountOrFrequencyResponseAdded = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
NextGate = constrained_closure_envelope_then_exact_current_fit_reconstruction
```

## Identity

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-saturated-response-envelope.R` | `0e25ad4d0da8fd2bbec084f410330f97e88006ac8d536e42bda98a41f1535af4` |
| `R/core-jml-gpcm-higher-order-face-lifts.R` | `bf3e0bc4118c1eb7b7f49f72d69032ec76e39634af497231f3a756d2a7ca3db8` |
| `R/core-jml-gpcm-response-image-face-chart.R` | `92fce482bc185039df804986e4de62258472fa13f434beace5305e2c99b7c22c` |
| `R/api-estimation.R` | `3c0234c17a19b94a8b6e0f34a501a0aa73d775d5ed24f92f4f81c77bb330cd04` |
| `man/fit_mfrm.Rd` | `8ca0a6ae23c20e3dbea1a54455b9d9f98b784336189aca7caac35d443ff2b62f` |
| `tests/testthat/test-jml-gpcm-saturated-response-envelope.R` | `0de1520c94ad8c076c2e689c4f0b5d7a5cdd26ed98fdd75e41640b4488ab2274` |
| `tests/testthat/test-jml-gpcm-higher-order-face-lifts.R` | `00ad4c0f6dbce621d39fedb74ec03df3925239116c093b6bae37d4d3393f4d96` |
| `NEWS.md` | `5d98f6f18972cf9d44ea8d20da5f18a0101036803cbb5f2884bd711ee87dee3a` |
| `ROADMAP.md` | `135049caf402f031f96ca6a9c54dd8a8c68180038e950e7ee758be1e24d6f09d` |
| `inst/validation/README.md` | `965e5e9043974c7ab02f4b76eeac7781d1716ea4387c3214e9f62fc5d0956161` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `baa8a883a5e278fc101c5febb9bf402a643e144671a016a885c7e706b475c175` |
| `inst/validation/claim-disposition-profile-0.2.3.csv` | `545409821e4674a45cc10e3f03483fdbfa87b4762ad5da4521efcafba0f66eff` |
| `inst/validation/claim-disposition-profile-0.2.3.md` | `3e6c1a50d5c70c5993f23e4d0c9b144dc44d2c9d419d4a290c915ec26ede0153` |
