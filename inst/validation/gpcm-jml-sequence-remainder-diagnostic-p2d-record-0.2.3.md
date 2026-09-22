# GPCM JML finite sequence and logit-remainder P2d record (0.2.3)

## Decision

P2d separates two questions which do not carry the same evidential force.

First, optimizer output can provide only a finite descriptive sequence. The
current optimizer retains aggregate stage rows and now exposes the parameter
vector at each optimization or polish-stage endpoint transiently while
`mfrm_estimate()` constructs its audits. These are not within-stage optimizer
iterations. The coordinate matrix is deleted before the returned `mfrm_fit` is
assembled. Fewer than three endpoints are explicitly insufficient. Three or
more endpoints may receive a finite Euclidean SVD direction/scale diagnostic,
but no estimated direction or power exponent is certified as asymptotic or
passed to P2b.

Second, a narrow analytic remainder class can extend a completed P2c path. If
the perturbation is declared directly on the already scaled category logits as
a finite sum of fixed directions times strictly ordered negative powers of
distance, all within-row category contrasts of the perturbation vanish. The
row response probabilities and finite weighted joint log likelihood therefore
retain the exact P2b limit. This theorem is not inferred from optimizer output
and does not separately classify utility or slope remainders.

The contract is
`mfrmr-jml-gpcm-sequence-remainder-diagnostic-0.2.3-v1`. It is internal and
diagnostic-only. It changes no readiness, ordinary uncertainty, recovery,
simulation, promotion, or external-comparison decision.

## Transient optimizer-stage sequence

`run_mfrm_direct_optimization()` exposes one endpoint vector for the initial
optimization stage and each attempted polish stage. The aggregate
`optimizer_polish$Stages` table and endpoint coordinate matrix have the same
row order. `run_mfrm_mml_em_optimization()` exposes its single final endpoint
only so the generic transient lifecycle remains dimensionally defined; the
conditional diagnostic rejects MML before inspecting it.

Immediately after optimization, `mfrm_estimate()` copies the endpoint matrix
to a local variable and removes it from `opt`. The JML GPCM audit consumes the
local copy after the P2c scope has been attached. Neither `fit$opt` nor
`fit$config` retains the raw coordinate vectors. Existing aggregate stage
history remains unchanged.

The fit-level audit requires all of the following:

1. model `GPCM` and estimator `JML`;
2. a non-unit free log-slope block;
3. the current P2c parameter-path contract;
4. finite endpoint vectors aligned with aggregate stage rows and the full free
   optimizer dimension; and
5. at least three stage endpoints for a finite diagnostic.

The ordinary verification fixture has one optimizer endpoint and therefore
returns `not_evaluated_insufficient_stage_endpoints`. This is the intended
result, not missing data. It records that endpoint coordinates were available
during fit construction and not retained afterward.

## Finite direction/scale diagnostic

For an explicitly supplied sequence `x_1,...,x_m` and a supplied reference
`x_0` or the first sequence point, define the displacement matrix

```text
D[r,] = x_r - x_0.
```

P2d computes a finite singular-value decomposition and retains at most two
right-singular directions. Per-point scales are the projections `D v_g`. If
the caller supplies positive strictly increasing distances, a descriptive
power exponent is estimated by regressing `log(abs(scale_g))` on
`log(distance)`. A tail reconstruction ratio is also reported.

These values are deliberately typed as descriptive:

- the SVD depends on the supplied Euclidean coordinate basis;
- endpoint count and spacing are optimizer-stage artifacts;
- endpoints are not optimizer iterations and do not approach a declared
  asymptotic index by construction;
- a finite low-rank reconstruction does not establish a limiting direction;
- a fitted log-log slope is not a certified power law;
- exact zero coefficients and ties cannot be inferred from floating output;
  and
- no direction, scale, or residual from this diagnostic is eligible for P2b.

The diagnostic therefore keeps `asymptotic_direction_certified`,
`scale_exponents_certified`, `remainder_vanishing_certified`,
`exact_coefficient_comparisons_eligible`, and `p2b_handoff_eligible` false.

## Negative-power scaled-logit remainder theorem

Let `z_i,k(t)` be the scaled category logits of a completed P2c path already
classified by P2b. P2d admits only residuals of the declared form

```text
r_i,k(t) = sum_g t^(-gamma_g) B_g[i,k],
0 < gamma_1 < ... < gamma_G,
```

where `G` is finite and every `B_g` is a fixed finite matrix with the same
observation-by-category dimensions as `z`. For row `i`, let

```text
span_i(B_g) = max_k B_g[i,k] - min_k B_g[i,k].
```

Then

```text
span_i(r(t)) <= sum_g t^(-gamma_g) span_i(B_g) -> 0.
```

For any finite vectors `z` and `r`, the change in an observed-category
log-softmax is bounded in absolute value by `max(r)-min(r)`. Hence each row log
probability under `z_i(t)+r_i(t)` differs from that under `z_i(t)` by a term
tending to zero. The retained response set is finite and weights are fixed, so
the weighted joint log-likelihood difference also tends to zero. The P2b limit
is unchanged.

The theorem allows finite-distance residuals to break a tie; it requires only
that their within-row contrasts vanish. Row-common residual shifts have zero
span and cancel exactly. A direct evaluator reconstructs the completed P2c
logits, adds the declared residual at a finite distance, and evaluates stable
row log probabilities for numeric verification.

The theorem does not cover arbitrary remainders. In particular it does not:

- decompose a utility perturbation and a changing slope perturbation;
- infer residual directions or decay exponents from optimizer endpoints;
- cover bounded non-vanishing oscillation, logarithmic terms, or slower
  divergent secondary scales;
- prove monotonicity, competitiveness, or common-subsequence agreement; or
- classify the global boundary or absence of a finite maximum.

## Typed scope separation

The finite diagnostic and remainder theorem separately reject malformed
sequences, references, distances, coordinate maps, dimensions, stage counts,
controls, source contracts, and exponent orders. The production audit also has
separate states for PCM, MML, the exact unit-slope reduction, legacy P2c
sources, misaligned coordinate history, and too few endpoints.

No state borrows authority across model or estimator boundaries. In
particular, the conditional JML result is not reused for marginal MML, and the
unit-slope GPCM reduction continues to use the existing PCM geometry.

## Verification

The new P2d file passes 112 expectations with zero failures, skips, warnings,
or errors:

| Test surface | Expectations |
| --- | ---: |
| Finite sequence contract and non-promotion flags | 22 |
| Rank-one descriptive power-scale example | 7 |
| Invalid finite-sequence inputs and workload controls | 9 |
| Transient fit endpoint lifecycle | 25 |
| Explicit multi-endpoint fit-scope diagnostic | 9 |
| Negative-power scaled-logit remainder theorem and direct convergence | 29 |
| Invalid remainder inputs | 7 |
| PCM, MML, unit-slope, and legacy-source separation | 4 |

Eleven focused JML GPCM boundary files from P1v through P2d pass 1,044
expectations with zero failures, skips, warnings, or errors. This includes the
112 P2d expectations, 125 P2c expectations, 136 P2b expectations, 135 P2a
expectations, and the existing compactification, transport, general-rate,
joint-boundary, fixed-objective, terminal-gradient, and slope-boundary suites.

A source tarball built successfully. Under R 4.5.1 on Windows, the final
offline `R CMD check --no-manual --ignore-vignettes` passes package
installation, static code analysis, Rd validation, examples, and the complete
test suite with zero errors and zero warnings. The single NOTE is unchanged:
Rd cross-references name unavailable optional Suggested packages `lme4`,
`eRm`, `mirt`, and `TAM`. Repository-index access warnings are consequences of
the offline environment and do not change the check status.

No external executable, recovery run, broad simulation, or confirmation run
is part of P2d.

## FACETS and claim consequence

P2d changes no FACETS comparison role. FACETS PCM/JMLE versus mfrmr PCM/JML
remains the only possible future direct common-estimand lane. Non-unit
GPCM/JML remains truth-first, FACETS PCM remains a deliberately misspecified
control, and FACETS Table 7 discrimination remains diagnostic-only. A finite
SVD of mfrmr optimizer coordinates and a theorem about declared mfrmr scaled-
logit residuals cannot create shared model, estimator, conditioning, parameter
identity, or output semantics with FACETS.

Consequently `external_comparison_eligible` remains false throughout P2d and
the existing FACETS comparison-role contract is unchanged.

## Machine-readable disposition

```text
SequenceRemainderContract = mfrmr-jml-gpcm-sequence-remainder-diagnostic-0.2.3-v1
OptimizerStageEndpointsExposedTransiently = TRUE
OptimizerStageEndpointsRetainedInFit = FALSE
StageEndpointsAreOptimizerIterations = FALSE
MinimumEndpointsForFiniteDiagnostic = 3
FiniteSequenceDiagnosticBasis = euclidean_svd_of_explicit_free_parameter_sequence
MaximumFiniteDiagnosticStages = 2
FiniteLowRankScreenAvailable = TRUE
ScaleExponentEstimateAvailableWhenDistancesDeclared = TRUE
DirectionEstimatesCoordinateBasisDependent = TRUE
AsymptoticDirectionCertified = FALSE
ScaleExponentsCertified = FALSE
ExactCoefficientComparisonsEligible = FALSE
OptimizerSequenceRemainderCertified = FALSE
P2bHandoffFromFiniteSequenceEligible = FALSE
DecayingScaledLogitRemainderTheoremImplemented = TRUE
RemainderClass = finite_sum_of_fixed_scaled_logit_directions_times_negative_powers
StrictlyIncreasingPositiveDecayExponentsRequired = TRUE
WithinRowLogitContrastRemainderVanishes = TRUE
SameRowProbabilityLimitsCertifiedWithinClass = TRUE
SameJointLogLikelihoodLimitCertifiedWithinClass = TRUE
ArbitraryUtilityRemainderClassified = FALSE
ArbitrarySlopeRemainderClassified = FALSE
ArbitraryLogitRemainderClassified = FALSE
PathInferredFromOptimizerTrace = FALSE
PathSearchPerformed = FALSE
MonotoneTailCertified = FALSE
CompetitiveBoundaryCertified = FALSE
GlobalBoundaryClassified = FALSE
GlobalFiniteMaximumCertified = FALSE
GlobalBoundaryAbsenceCertified = FALSE
ReadinessEffect = none_diagnostic_only
ExternalComparisonAuthorized = FALSE
FACETSComparisonRoleChanged = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

## Identity

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-sequence-remainder-diagnostic.R` | `c09893e552cd7c3d36e28f7c1b24e8401025eec5bc6c7754a053b0152f0acaeb` |
| `R/core-optimizer.R` | `b1fbe63d77c24210f0fa40e6219be4e7d5d5cd410e620db9e99ea4199d64f31f` |
| `R/mfrm_core.R` | `038961409d8f8cc10609298acb5b71bd0ecee45dcb2bc66985b8269c6091a036` |
| `R/api-estimation.R` | `e56c81ea571c115d5d2e316059c4ff2cf416222c81d46b1474d4330764f25610` |
| `man/fit_mfrm.Rd` | `aa182251209f5005055f9bf067f6fcdae84e135964ab1f6e03cb0622825e5c11` |
| `tests/testthat/test-jml-gpcm-sequence-remainder-diagnostic.R` | `c5d6307e700339c2539959cb0b93abe36fb0bc09a43f7f491af679515ffb60ce` |
| `NEWS.md` | `8b2858ac1a6acbff7ae835fc9026b4b400dcb510e0e13f4a63cb6db91bfaae53` |
| `ROADMAP.md` | `1266376f7ca80b74377fbaeefef18977c6860d080513f73111cd6def48281003` |
| `inst/validation/README.md` | `6f6f9a2854acfaae35d09137a3181b9ca9227913ae3cc7073354c1e5b8ff7ca4` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `14b02bd0b65299c272a4d54f45d927042ae9a3e600839c24f2481f1b74d68120` |
