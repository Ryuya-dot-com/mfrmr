# GPCM JML general constant-rate boundary P1x record (0.2.3)

## Decision

P1x extends the production fixed-objective JML GPCM joint-boundary audit from
ordered `+1/-1` log-slope pairs to a finite canonical family covering general
constant sum-zero log-slope rate vectors with linear additive movement. The
P1v fixed-objective classification contract advances from v1 to v2 and every
fit retains the added results in
`config$boundary_audit$gpcm_joint_boundary$rate_certificates`.

The extension is material. A constructed three-level `(3,-1,-2)` path has a
strict positive-tail certificate and a competitive analytic boundary although
all six ordered pair LPs are negative. Direct likelihood evaluations converge
monotonically to the independently computed boundary value.

This remains a sufficient, workload-bounded constant-rate audit. Curved paths,
paths without a limiting rate vector, unrestricted nonlinear additive motion,
and MML marginal geometry are not classified. Negative completion therefore
does not certify a finite global maximum or global boundary absence.

P1y subsequently adds a separate positive-only continuity transport for
curved perturbations whose additive and sum-zero log-slope residuals converge
to zero. It does not alter P1x negative conclusions: bounded nonvanishing
residuals and general curved or rate-nonconvergent paths remain unclassified.

## Canonical rate derivation

Let the expanded log slopes follow

```text
log alpha_j(t) = log alpha_j(0) + q_j t,
sum_j q_j = 0.
```

For a nonzero rate vector define four disjoint groups:

- `P = {j: q_j > 0}`;
- `Z = {j: q_j = 0}`;
- `L`, the nonempty negative tier closest to zero; and
- `D`, all more-negative tiers.

Rescale time so the leading negative tier has rate `-1`. For the audited tail
conditions, exact rate magnitudes inside `P` and below `L` do not affect the
category limit: positive slopes diverge, zero slopes remain finite, `L`
controls the first negative-rate derivative term, and `D` vanishes faster.
The following canonical representative preserves those roles:

```text
q_j = (|L| + 2|D|) / |P|,  j in P
q_j = 0,                    j in Z
q_j = -1,                   j in L
q_j = -2,                   j in D.
```

It is exactly sum zero. Thus every admitted constant-rate role pattern is
represented by one four-way partition with nonempty `P` and `L`. The number
of candidates for `J` slope levels is

```text
4^J - 2*3^J + 2^J.
```

The `J(J-1)` partitions with one positive level, one leading-negative level,
no deeper-negative level, and all other levels zero are precisely the existing
ordered pair paths. P1x evaluates only the additional candidates in the new
loop:

| Slope levels | All canonical candidates | Existing pairs | Additional P1x candidates |
| ---: | ---: | ---: | ---: |
| 2 | 2 | 2 | 0 |
| 3 | 18 | 6 | 12 |
| 4 | 110 | 12 | 98 |
| 5 | 570 | 20 | 550 |
| 6 | 2,702 | 30 | 2,672 |

The default additional-candidate guard is 1,000, so the rate family completes
through five slope levels when the other observation, contrast, coordinate,
LP, and pair guards also pass. Larger families return typed workload
non-evaluation rather than a negative conclusion.

## Certificate conditions and boundary

For a candidate partition, the sparse LP seeks a bounded additive direction
such that:

1. every positive-rate observed category has a strictly positive contrast
   margin;
2. every zero-rate observed category has a nonnegative contrast margin; and
3. the weighted aggregate leading-negative contrast coefficient is strictly
   favorable.

Deeper-negative rows impose no direction constraint because their
`t exp(q_j t)` contribution is lower order than the leading-negative tier.
At the analytic boundary, positive-rate rows contribute log probability zero,
all negative-rate rows become uniform over categories, and zero-rate rows use
the retained finite slope and the top additive-direction category set. The
boundary log likelihood must be no worse than the reconstructed retained JML
log likelihood before the path becomes a competitive certificate.

Ordered-pair helpers remain exact wrappers around the generalized LP and limit
helpers, including their existing reason codes and result tables. Existing
consumers therefore retain compatibility while the additional candidates and
loadings remain separately inspectable.

## Pair-negative/general-positive construction

The independent four-row construction uses one additive direction with
observed contrasts `(1,-1,1,-1)` and slope ownership `(1,2,3,3)`.

- Candidate roles are `P={1}`, `L={2}`, `D={3}`, giving rates `(3,-1,-2)`.
- The generalized LP has positive minimum margin `1` and leading-negative
  coefficient `0.5`.
- Every one of the six ordered positive/negative pair LPs is negative: when
  slope 3 is neutral its opposing rows force a zero direction, and when it is
  leading negative its aggregate cancels.
- With binary categories and zero retained utilities, the retained log
  likelihood is `-4 log(2)` and the analytic boundary is `-3 log(2)`, an
  improvement of `log(2)`.
- Direct evaluations at `t = 2,4,8,16` are nondecreasing and the final value
  agrees with `-3 log(2)` within `1e-6`.

This proves that P1x adds a boundary geometry not represented by pair
enumeration. It is a constructed sufficient example, not a prevalence or
recovery result.

## Production-path and fail-closed checks

A balanced three-level production JML GPCM fixture evaluates all six pair and
12 additional canonical candidates, finds no certificate, and returns
`finite_retained_point_no_path_certified` under classifier v2. The state still
sets global finite-maximum and boundary-absence flags false.

When the additional-candidate guard is below 12, the same negative fixture
returns `not_evaluated_rate_size_limit`; the classifier cannot issue a scoped
negative. Conversely, an already valid positive pair remains a positive
boundary certificate even if the wider rate family is workload-incomplete.
This preserves the asymmetric rule that one sufficient positive direction is
decisive within its scope, whereas a negative claim requires full completion
of every declared family.

## Verification

Five focused files pass 369 expectations with zero failures, skips, warnings,
or errors:

| Test surface | Expectations |
| --- | ---: |
| P1x general constant-rate boundary | 54 |
| JML GPCM joint boundary | 74 |
| P1v/v2 fixed-objective classifier | 60 |
| P1w terminal-gradient stability | 83 |
| JML GPCM slope-only boundary | 98 |

Nine additional release/readiness/scope/documentation guard files pass 1,077
expectations with zero failures or errors. Three expected skips remain: two
require the uninstalled optional `diffobj` package, and one is the separately
opt-in P1p stored-result pilot. The checklist remains 106 rows and the joint
boundary row remains `review` with `pilot_required` criteria. The local
`testthat` R-version build warning is unchanged.

## FACETS and claim consequence

P1x changes no FACETS role. FACETS PCM/JMLE versus mfrmr PCM/JML remains the
only possible future direct common-estimand FACETS lane. Non-unit GPCM/JML
remains truth-first, FACETS PCM remains a deliberately misspecified control,
and FACETS Table 7 discrimination remains diagnostic-only. No external
program, tolerance, recovery rule, broad simulation, inference promotion, or
confirmation is authorized.

## Machine-readable disposition

```text
FixedObjectiveClassifierContract = mfrmr-jml-gpcm-fixed-objective-boundary-0.2.3-v2
GeneralConstantRateCanonicalizationImplemented = TRUE
OrderedPairPathsRemainExactSubfamily = TRUE
PairNegativeGeneralPositiveConstructionPassed = TRUE
ThreeLevelAdditionalCandidateCount = 12
FourLevelAdditionalCandidateCount = 98
DefaultAdditionalCandidateLimit = 1000
VanishingResidualCurvedNeighborhoodClassifiedByP1y = TRUE
GeneralCurvedPathsClassified = FALSE
RateNonconvergentPathsClassified = FALSE
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
| `R/core-jml-gpcm-joint-boundary.R` | `e1d2b7bb3cfb9e00789dcfa7d6cbb87c8de61adb65b59d533651e446d1660dcd` |
| `R/core-jml-gpcm-boundary-classification.R` | `fc28b5b61e366d127a24aacf2d408240e577fcb67cfc0ea903a55d8a67bf5997` |
| `R/core-jml-gpcm-terminal-gradient.R` | `9ab72ae7e2524b9a29ae4505f3275238f9f1532d5c947fc59db25c2cf519a88e` |
| `R/mfrm_core.R` | `c54302de50ea7048b3959aa700b9a91f3485975597f8b6a8be70293ddf1fd76f` |
| `R/api-estimation.R` | `eaaaaa805df19d0b39564d5f05f1b66a440a4228ca934af7db9aa57c31507e86` |
| `man/fit_mfrm.Rd` | `f2ba74fca78850897d343daa84f39e1388406b8bcf6684dfd3e85c043993f420` |
| `tests/testthat/test-jml-gpcm-general-rate-boundary.R` | `7570ad5f6a85057875a7b7ad8d24c199a00eeabc877d97391c8188a4aa6f28d4` |
| `tests/testthat/test-jml-gpcm-joint-boundary.R` | `8b61e97eef9216d58bd0698bdcc348fe535e124e4a2c821bed8aa9ee84dd5ebb` |
| `tests/testthat/test-jml-gpcm-fixed-objective-boundary-classification.R` | `f8067ca7ea1794decbc7362b147f8a4c932a8607d7be17b77dc01c2cd675cdaf` |
| `tests/testthat/test-jml-gpcm-terminal-gradient-stability.R` | `d0199bcf388bbf114d6ecb329a683d39dfe739945de855710f691c68060f67e4` |
| `tests/testthat/test-jml-gpcm-slope-boundary.R` | `2c9bd9306e806c55a64788c607428476d6756fc5d50e96d36cdeb2ec7c7f03ff` |
| `NEWS.md` | `b1aee634f86ae599e4eea02b22e19bbbf0be5af86069769be592f32aa7e69d5c` |
| `ROADMAP.md` | `71c11b7810a41787abf67701a4fa4e3424ff4b75139ca6e9ad63b0e7a962aeaf` |
| `inst/validation/README.md` | `c9cc2f77097a3a680c8159560722eb4ac2f79de9fb916facbf07707465eec002` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `4e307852e8e9402c0306951cc721a8dfffcba3876b2e103e9de86c3a5c55db40` |
