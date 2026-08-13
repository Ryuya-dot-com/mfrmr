# GPCM JML parameter-sequence contrast-flag P2e record (0.2.3)

## Decision

P2e closes a narrower question than global JMLE existence. It proves that
every sequence of finite non-unit GPCM/JML parameter points has a further
subsequence whose retained response probabilities and weighted conditional
joint log likelihood have a classifiable limit in the extended real line.

The proof first evaluates the exact nonlinear GPCM response map and only then
uses compactness. This order matters: cumulative utilities are linear in the
additive coordinates, expanded log slopes are linear in their identified free
coordinates, and category logits multiply utilities by exponentiated log
slopes. A Euclidean direction extracted before that product can miss
cancellation or an intermediate scale. Reference-category logit contrasts
remove the irrelevant row gauge and place the exact response image in the
finite-dimensional space `R^(N(K-1))`.

The contract is
`mfrmr-jml-gpcm-parameter-sequence-flag-0.2.3-v1`. It is internal and
diagnostic-only. The production fit declares no parameter sequence, selects
no subsequence, and extracts no flag. P2e does not prove that the original
sequence converges, that different subsequences share a limit, that a boundary
sequence is competitive, or that a finite JMLE exists. Those are the global
questions reserved for P2f.

## Exact nonlinear contrast image

For retained observation `i` and category `k`, let `z_i,k(x)` denote the GPCM
category logit obtained by fully expanding a finite identified free-parameter
vector `x`. P2e applies the package's actual adjacent-logit kernel, including
the slope-times-cumulative-utility product, and then keeps

```text
y_i,k(x) = z_i,k(x) - z_i,0(x),  k = 1,...,K-1.
```

Thus every finite parameter point maps exactly to one vector in
`R^D`, where `D = N(K-1)`. Row-common logit shifts cancel exactly. No Taylor
linearization, parameter-space normalization, inverse projection, tolerance,
or power-law scale assumption enters this map.

`mfrmr_jml_gpcm_parameter_sequence_contrast_image()` exposes this calculation
for a finite caller-declared sequence on a current retained fit. It is a
numeric image only. In particular, it does not turn a finite sample of points
or optimizer stage endpoints into an asymptotic sequence, choose a
subsequence, infer directions, or certify scales and remainders.

## Finite-dimensional flag theorem

Let `(y_n)` be any sequence in `R^D`.

If `(y_n)` is bounded, Bolzano-Weierstrass gives a convergent further
subsequence. Its limit is the finite base and the divergent flag is empty.

If it is unbounded, pass to a further subsequence with `||y_n|| -> infinity`.
After another subsequence, compactness of the unit sphere gives

```text
y_n / ||y_n|| -> v_1.
```

Choose the sign so the first scale
`s_1,n = <y_n, v_1>` is eventually positive. Then `s_1,n -> infinity` and the
orthogonal residual

```text
r_1,n = y_n - s_1,n v_1
```

satisfies `||r_1,n|| / s_1,n -> 0`. If this residual is bounded, pass to a
convergent further subsequence and stop. If it is unbounded, repeat the same
argument inside `v_1`'s orthogonal complement. At stage `g`, this yields an
orthonormal direction `v_g`, an eventually positive scale `s_g,n -> infinity`,
and

```text
s_(g+1),n / s_g,n -> 0.
```

Each divergent stage consumes a new orthogonal dimension, so the recursion
stops after at most `D` stages. Passing to a final subsequence for the bounded
terminal residual gives

```text
y_n = b + sum_g s_g,n v_g + e_n,
max_d |e_n,d| -> 0,
s_g,n -> infinity,
s_(g+1),n / s_g,n -> 0.
```

This is a general scale-separated flag. The scales need not be powers of a
common index; logarithmic, exponential, and mixed rates are admitted whenever
they satisfy the displayed ordering on the selected subsequence.

Because the exact nonlinear map is applied before this argument, the theorem
also covers slope-utility cancellations and secondary scales that are not
visible as a fixed Euclidean direction in free-parameter coordinates.

## Likelihood limit on a declared flag

For each response row, start with all categories. At stage 1 retain the exact
maximizers of the first contrast direction, at stage 2 retain the exact
maximizers within that tie set, and continue lexicographically. A category
removed at stage `g` has a strictly negative contrast against a surviving
category at scale `s_g,n`; every later term is asymptotically smaller, so its
probability tends to zero.

On the final tie set, all divergent-stage contrasts cancel. The `o(1)`
remainder vanishes and the limiting conditional probabilities are the softmax
of the finite base `b` restricted to that set. Therefore:

- if a positive-weight observed category is removed, its row log probability
  and the weighted joint log likelihood tend to `-Inf`;
- otherwise every effective observed row has the finite restricted-base
  log-softmax limit, and the finite weighted sum is the joint limit; and
- a positive-infinite log-likelihood limit is impossible because every row
  log probability is non-positive.

`mfrmr_jml_gpcm_declared_contrast_flag_limit()` implements this exact
lexicographic oracle for a caller-declared base and flag. Exact coefficient
comparisons are appropriate because the theorem input is declared analytic
data, not a flag inferred from floating optimizer output. The oracle does not
claim that arbitrary supplied directions are reachable from parameter space;
the abstract theorem supplies reachability only for a flag obtained from the
exact image of an actual parameter sequence.

`mfrmr_jml_gpcm_declared_contrast_flag_loglik_at()` evaluates finite positive,
strictly scale-ordered points with an optional finite contrast remainder. It
is a numerical verification helper, not an estimator of asymptotic scales.

## Production and typed scope

For a current non-unit GPCM/JML fit with the current P1z and P2d source
contracts, the fit-level audit records
`parameter_sequence_further_subsequence_flag_theorem_available_no_sequence_declared`.
If the response contrast dimension exceeds the oracle workload control, the
mathematical theorem remains available while only the executable oracle is
withheld.

The audit separately rejects malformed controls or dimensions, PCM, MML, the
exact unit-slope reduction, and legacy source contracts. The oracle separately
rejects malformed bases, scores, weights, directions, zero stages, stage depth,
dimensions, and element workloads. The finite exact-map helper separately
checks current-fit identity, parameter-sequence dimensions, numeric expansion,
and point/element workloads.

No production state uses optimizer endpoints as an asymptotic sequence. No
P2b handoff, standard error, confidence interval, readiness, recovery,
simulation, or external-comparison eligibility is created.

## What remains open for P2f

P2e is deliberately a further-subsequence theorem. It leaves all of the
following unresolved:

- whether the original parameter sequence has a likelihood limit;
- whether all further-subsequence limits agree;
- which reachable flags can approach or improve the finite supremum;
- whether a maximizing sequence must remain in a compact parameter set after
  identification;
- whether the conditional joint likelihood attains its supremum at a finite
  point; and
- the exact global separation/nonexistence criterion when it does not.

P2f must connect the local flag classification to global upper-level sets and
finite attainment. It cannot obtain that conclusion merely by relabeling the
P2e compactness result.

## Verification

The new P2e file passes 145 expectations with zero failures, skips, warnings,
or errors:

| Test surface | Expectations |
| --- | ---: |
| Reference contrasts and row-gauge invariance | 3 |
| Exact two-stage flag and finite likelihood limit | 27 |
| Bounded-image empty flag and base softmax | 9 |
| Observed-category exclusion and zero weights | 18 |
| General non-power scales and vanishing remainder | 9 |
| Agreement with the fixed-slope P2b special case | 14 |
| Malformed oracle, scale, and workload contracts | 18 |
| Current-fit theorem state and production non-promotion | 20 |
| Exact finite nonlinear parameter-sequence image | 17 |
| Model, estimator, unit-slope, source, and control separation | 10 |

Twelve focused JML GPCM boundary files from P1v through P2e pass 1,189
expectations with zero failures, skips, warnings, or errors. The surrounding
claim, documentation, release-readiness, model-identity, FACETS-role,
external-comparison, and core-workflow guard files pass 1,351 expectations
with zero failures, warnings, or errors and two existing CRAN-only skips. The
GPCM capability file separately passes 67 expectations with zero failures,
warnings, or errors and three existing CRAN-only skips when its installed
package-private registries are bound into the isolated `test_file()`
environment. The initial isolated invocation omitted those bindings; its four
name-resolution errors were a test-harness issue rather than a package or P2e
failure.

A source tarball builds successfully with the existing prebuilt vignettes.
Under R 4.5.1 on Windows, the offline
`R CMD check --no-manual --ignore-vignettes` passes package installation,
static code analysis, Rd validation, examples, and the complete test suite with
zero errors and zero warnings. The single NOTE is unchanged: Rd
cross-references name unavailable optional Suggested packages `lme4`, `eRm`,
`mirt`, and `TAM`. Repository-index access warnings are consequences of the
offline environment and do not change the check status. A build that attempted
to regenerate the unchanged R Markdown vignettes stopped only because Pandoc
is not installed in the validation environment; it did not reach package code
or test evaluation.

No external executable, recovery run, broad simulation, or confirmation run
is part of P2e.

## FACETS and claim consequence

P2e changes no FACETS comparison role. FACETS PCM/JMLE versus mfrmr PCM/JML
remains the only possible future direct common-estimand lane. Non-unit
GPCM/JML remains truth-first, FACETS PCM remains a deliberately misspecified
control, and FACETS Table 7 discrimination remains diagnostic-only.

An exact compactification of mfrmr GPCM category-logit contrasts does not
create shared response model, estimator, conditioning, parameter identity, or
output semantics with FACETS. `external_comparison_eligible` therefore remains
false and the existing comparison-role contract is unchanged.

## Machine-readable disposition

```text
ParameterSequenceFlagContract = mfrmr-jml-gpcm-parameter-sequence-flag-0.2.3-v1
EstimatorIdentity = unpenalized_fixed_effects_jml_no_finite_box
ObjectiveIdentity = identified_conditional_joint_log_likelihood
ResponseCoordinateSystem = category_logit_contrasts_relative_to_category_zero
ExactNonlinearSlopeUtilityMapPrecedesCompactification = TRUE
FiniteDimensionalContrastImage = TRUE
ContrastDimension = N_times_K_minus_1
BoundedContrastSequenceHasConvergentSubsequence = TRUE
UnboundedContrastSequenceHasScaleSeparatedFlagSubsequence = TRUE
FlagDirectionsCanBeChosenOrthonormal = TRUE
MaximumDivergentFlagStages = N_times_K_minus_1
FlagScalesDivergeToPositiveInfinity = TRUE
SuccessiveFlagScaleRatiosTendToZero = TRUE
PowerLawScalesRequired = FALSE
TerminalReferenceContrastRemainderTendsToZero = TRUE
FurtherSubsequenceRowProbabilityLimitClassifiable = TRUE
FurtherSubsequenceJointLikelihoodLimitClassifiable = TRUE
PositiveInfiniteLogLikelihoodLimitPossible = FALSE
ExactDeclaredFlagOracleImplemented = TRUE
FiniteExactParameterSequenceMapImplemented = TRUE
ProductionParameterSequencesDeclared = 0
ProductionParameterSequenceMapped = FALSE
ProductionSubsequenceSelected = FALSE
ProductionFlagExtracted = FALSE
OptimizerStageEndpointsUsedAsAsymptoticSequence = FALSE
OriginalSequenceLimitClassified = FALSE
CommonSubsequenceLimitCertified = FALSE
AllSubsequenceLimitsEqualCertified = FALSE
CompetitiveBoundaryCertified = FALSE
GlobalBoundaryClassified = FALSE
GlobalFiniteMaximumCertified = FALSE
GlobalBoundaryAbsenceCertified = FALSE
P2bHandoffEligible = FALSE
ReadinessEffect = none_diagnostic_only
ExternalComparisonAuthorized = FALSE
FACETSComparisonRoleChanged = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
NextGate = P2f_global_finite_JMLE_existence_and_boundary_competitiveness
```

## Identity

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-parameter-sequence-flag.R` | `f877ea84c7bde59508deb33df5a79db1790b0472eb96df6ed230b46394bca218` |
| `R/mfrm_core.R` | `a45d8c7e23b076b38b97cf46b30fefae567ed3499488fdd809bb4ce71560a596` |
| `R/api-estimation.R` | `eca37a69c1186459014f6b07c0aa8898b2173334c2259460a7fa9853fabba1d6` |
| `man/fit_mfrm.Rd` | `28c8dc7822af904d5da3ed1f842aa200eaa62aeb0a1f34b7cb9b05e9f69d0276` |
| `tests/testthat/test-jml-gpcm-parameter-sequence-flag.R` | `54aa8e049b9d83c1991ed2661dd388cc3b5c0bd5ea17f0f26e1314101bece08d` |
| `NEWS.md` | `d070a3bbc659f5557660145e823f4849b62d37d5ee2f9db18477d0efa3bb48ef` |
| `ROADMAP.md` | `8c31b4626577d9c951d1c693992d923bd197fe41260398d436bbbe322b991798` |
| `inst/validation/README.md` | `748962076423ef5d1c668a8209ce264700511be8aae6ce9f01023338971e236b` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `a28b27ba76a4bab9c026471d2fac24efb969b01b6ea9addcae13a39fb3f6e205` |
