# GPCM JML declared lexicographic likelihood-limit P2b record (0.2.3)

## Decision

P2b implements an internal analytic likelihood-limit oracle for a narrow,
explicitly declared class of joint additive and expanded-log-slope JML GPCM
paths. Applicable production fits retain only the scope advertisement at
`config$boundary_audit$gpcm_lexicographic_limit`; the package does not infer a
path from the retained optimizer trace and does not search the boundary.

The v1 oracle admits at most two strictly ordered positive-power scales in
each block. Every expanded log-slope coefficient vector must satisfy the exact
global sum-zero identification. The caller supplies unscaled cumulative
category-utility directions directly. Their reachability from the fitted
additive parameter design is not checked, exact zero and tie identities are
used, and no omitted remainder may change those identities.

This closes the analytic likelihood calculation for that declared subclass.
It does not classify arbitrary paths, establish monotonicity or competitiveness,
certify a common limit across accumulation subsequences, or prove a finite
global maximum or global boundary absence.

## Declared path

For observation `i`, category `k`, and slope level `j(i)`, write

```text
ell_j(t) = ell_0j + sum_h t^alpha_h q_hj,
a_j(t)   = exp(ell_j(t)),
U_ik(t)  = U_0ik + sum_g t^beta_g D_gik,
P_i(k;t) = exp(a_j(i)(t) U_ik(t)) /
           sum_m exp(a_j(i)(t) U_im(t)).
```

The exponents within each block are positive and strictly decreasing. There
are at most two `alpha` stages and at most two `beta` stages. Every `q_h` is
nonzero and sums exactly to zero over the expanded slope levels. At least one
row-category contrast must change at every declared additive stage.

The first nonzero normalized slope coefficient for a level determines whether
its slope tends to infinity or zero. A level with zero coefficients at every
declared slope stage remains at its positive finite base slope.

## Row-limit theorem

For each row, resolve category candidates lexicographically through the
declared additive directions. Let `T_i` be the exact tie set left after the
last divergent additive scale.

| Slope state | Analytic row limit |
| --- | --- |
| Infinite | Refine `T_i` by the base utility. Probability is uniform on the exact final maxima and zero elsewhere. |
| Zero | Exponential slope decay dominates every admitted polynomial utility scale, so all scaled logits tend to zero and all categories have probability `1/K`. |
| Finite | Categories outside `T_i` have probability zero; categories inside it receive the ordinary softmax of the base utilities at the finite base slope. |

A positive-weight observed category outside its limit support gives row and
joint log-likelihood limit `-Inf`. Zero-weight rows retain their diagnostic row
limit but cannot force the weighted joint limit to negative infinity.
Positive-infinite log-likelihood limits are impossible because every row log
probability is at most zero.

## Representative construction

The principal three-row construction uses

```text
q_1 = ( 1,  -1,    0), alpha_1 = 1,
q_2 = (-0.5,-0.5,  1), alpha_2 = 1/2,
beta = (1, 1/2).
```

The three slope states are infinite, zero, and infinite. The declared additive
hierarchy and base utilities leave response supports of sizes one, three, and
two. Their row log-probability limits are

```text
0, -log(3), -log(2),
```

so the joint limit is `-log(6)`. Direct evaluations at distances
`4, 16, 64, 256` approach the same answer and agree with every analytic row
limit at the final distance within `1e-8`.

Separate tests show that a finite slope uses the base-slope softmax only on the
additive tie set, an excluded positive-weight response yields `-Inf`, a
zero-weight excluded response is ignored by the joint likelihood, and a
vanishing slope remains uniform even when additive utilities grow at a faster
polynomial power.

## Production and failure states

The applicable fit-level state is
`declared_two_stage_limit_oracle_available_no_path_inferred`. It advertises the
internal contract and checks the upstream P2a contract identity, but it does
not classify any production path.

The direct helper returns finite or negative-infinite declared-path states and
typed failures for malformed base arrays, slope-level labels, stage mappings,
stage counts, scale order, sum-zero identification, redundant additive stages,
observation mappings, workload limits, and controls. The finite-distance
evaluator separately rejects nonpositive distances and nonfinite numerical
evaluations.

The fit-level scope has distinct PCM/non-GPCM, MML, unit-slope, and invalid-
dimension states. The JML conditional likelihood result is never reused for
MML.

## Verification

Nine focused JML GPCM boundary files pass 807 expectations with zero failures,
skips, warnings, or errors:

| Test surface | Expectations |
| --- | ---: |
| P2b declared lexicographic limit | 136 |
| P2a finite-depth rate hierarchy | 135 |
| P1z boundary compactification | 107 |
| P1y asymptotically-affine transport | 60 |
| P1x general constant-rate boundary | 54 |
| JML GPCM joint boundary | 74 |
| P1v/v2 fixed-objective classifier | 60 |
| P1w terminal-gradient stability | 83 |
| JML GPCM slope-only boundary | 98 |

The P2b file covers all three slope regimes, two slope and additive scales,
exact tie refinement, finite-slope softmax, negative-infinite exclusion,
zero-weight handling, exponential-versus-polynomial dominance, direct
finite-distance convergence, typed malformed inputs, workload limits,
production attachment, upstream identity, unit-slope reduction, and non-reuse
for MML or PCM.

The existing release/readiness/scope/documentation guards pass 1,084
expectations. Their three expected skips remain: two require the uninstalled
optional `diffobj` package and one is the separately opt-in P1p stored-result
pilot. The checklist remains 106 rows; line 83, the JML-GPCM joint-boundary
row, stays `review` with `pilot_required` criteria. The local warning that
`testthat` was built under R 4.5.3 while checks run under R 4.5.1 is unchanged.

A source tarball built successfully and passed `R CMD check` with zero errors
and zero warnings under the offline development setting
`_R_CHECK_FORCE_SUGGESTS_=false` and without manuals or vignettes. The single
NOTE reports Rd cross-references to the unavailable optional Suggests
`lme4`, `eRm`, `mirt`, and `TAM`; package installation, static code analysis,
Rd validation, examples, and the complete test suite were OK.

No external executable, recovery run, broad simulation, or confirmation run
is part of P2b.

## FACETS and claim consequence

P2b changes no FACETS comparison role. FACETS PCM/JMLE versus mfrmr PCM/JML
remains the only possible future direct common-estimand lane. Non-unit
GPCM/JML remains truth-first, FACETS PCM remains a deliberately misspecified
control, and FACETS Table 7 discrimination remains diagnostic-only. An
analytic limit for a caller-declared GPCM path cannot create shared model,
estimator, conditioning, or parameter identity with FACETS.

## Machine-readable disposition

```text
LexicographicLimitOracleImplemented = TRUE
LexicographicLimitContract = mfrmr-jml-gpcm-lexicographic-limit-0.2.3-v1
MaximumSlopeStages = 2
MaximumAdditiveStages = 2
PositivePowerScalesOnly = TRUE
GlobalSlopeCoefficientSumZeroRequired = TRUE
ExactCoefficientAndTieComparisons = TRUE
InfiniteSlopeLimitClassified = TRUE
VanishingSlopeLimitClassified = TRUE
FiniteSlopeLimitClassified = TRUE
WeightedJointLikelihoodLimitClassified = TRUE
DirectFiniteDistanceEvaluatorAvailable = TRUE
DeclaredUtilityPathParameterReachabilityChecked = FALSE
PathInferredFromOptimizerTrace = FALSE
PathSearchPerformed = FALSE
MonotoneTailCertified = FALSE
CompetitiveBoundaryCertified = FALSE
CommonSubsequenceLimitCertified = FALSE
ArbitraryPathLimitClassified = FALSE
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
| `R/core-jml-gpcm-lexicographic-limit.R` | `2701ca0e97a75d40e368414452d0c18da8a1888194ac0615b69558ac8e08178d` |
| `R/core-jml-gpcm-rate-hierarchy.R` | `76f628b4f8ef224a75b9e289d8b06ee6e785f95832132f9e3b34842fbbef16a0` |
| `R/mfrm_core.R` | `14e1f58d84ba01eb09de73aa555786f0ce672116ca26c5ec8eab31aeb8e52c79` |
| `R/api-estimation.R` | `473f9006600d47ef09d5725f197ca5ee5d66239e9de1aac261b46b5de29779c5` |
| `man/fit_mfrm.Rd` | `69878b5e35bfeab69a1e90fea740811f8cbc1cb1d29ed84c632a1dc6a6aa5e1b` |
| `tests/testthat/test-jml-gpcm-lexicographic-limit.R` | `992ca1dd7349bd8888a14bd2072ba04f033f0802d96a2a9315f7c1e72131e187` |
| `NEWS.md` | `6bad3eb52123618637a995519360668d2341f22ff6bc52698af0878aea8af209` |
| `ROADMAP.md` | `216e7448e17967993b8ffa29d6ad38e234e634e7956597bb974b417e34653c46` |
| `inst/validation/README.md` | `652bbf236c9539a049a2a5c8ef9d53ac51bc0b8ccca89455b66786ad9c1069b2` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `55b843cf1a68fa613c04f76237631e34c76ddafd540c169566bde3f8de07d6f9` |
