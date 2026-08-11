# Five-category GPCM endpoint solution-stability P0b record for 0.2.3

Status: completed deterministic calibration microcases, 2026-08-12.
Contract: `mfrmr_gpcm_endpoint_solution_stability_p0b_v1`.
Specification: `0.2.3-draft.1`.

This record extends the P0 instrument to exact and near Person endpoints under
the current free-population GPCM-MML identification. It does not select a
solution, freeze a numerical tolerance, establish a finite population-
variance maximum, prove the continuous-normal marginal likelihood, or promote
GPCM, uncertainty, DFF, fit, rank, separation, or external-agreement claims.

## Execution identity

- branch: `development/0.2.3`
- parent commit: `ee515cdcaa5bf145001b9c655da35e43b7d26021`
- source-tree version: `0.2.3`
- P0b runner:
  `gpcm-endpoint-solution-stability-p0b-0.2.3.R`
- P0b runner SHA-256:
  `63dbb2ae1ec6b9df56e252d8d7bf55a2ff61870c17d2c366da6ddedd46ca8364`
- P0b test:
  `test-gpcm-endpoint-solution-stability-p0b.R`
- P0b test SHA-256:
  `7c0362f5cf22826f969bc994424169b90d8f42a9dd21730dd181b7fe0bb69d41`
- P0 dependency contract: `mfrmr_gpcm_solution_stability_p0_v1`
- P0 dependency SHA-256:
  `89b20f7185ca3eaf06920cd5468711d47429df9f6d6841f59ef7a425e5e51c6f`
- model: Criterion-owned steps and relative slopes, additive Rater facet,
  five categories scored 1--5
- estimator: direct MML, `free_population`, requested `L-BFGS-B`
- integration and controls: q=31, `maxit = 800`, `reltol = 1e-12`
- starts: the seven preregistered P0 starts
- derivative calibration ladder: relative steps `1e-5`, `1e-6`, `1e-7`,
  `1e-8`, and `1e-9`; no step is selected for an acceptance rule

## Fixed reflected microcases

Each dataset has 20 Persons, five Raters, four Criteria, 20 responses per
Person, and 400 rows. All five categories remain observed within every
Criterion. The low cases are exact score reflections of the corresponding
high cases: paired scores sum to 6 in every row.

| Scenario | P01 endpoint responses | Rate | Fixture SHA-256 |
| --- | ---: | ---: | --- |
| `EXT5-P-HI` | 20/20 at 5 | 1.00 | `c662d1f24109be2865d874640c3f29d11f3879777b65f6ba815f04dc75007448` |
| `EXT5-P-LO` | 20/20 at 1 | 1.00 | `2e7149ad70c40e3dda42ff62fee8dbf93092f0eb092227f1f49e5138744ec508` |
| `EXT5-P-NEAR-HI` | 19/20 at 5; one 4 | 0.95 | `884315ae19763c5dffee528e2c043ec67524e523c32b29de4eed779827d99cf3` |
| `EXT5-P-NEAR-LO` | 19/20 at 1; one 2 | 0.95 | `8884f005a14cf31876456a840cd3fa3c13f6f184e0dff19a036fa13af7ca5217` |

The exact cases replay `ResponseExtreme = high/low` and
`mml_extreme_response_prior_regularized`. The 0.95 cases replay
`ResponseExtreme = none` with no exact-boundary reason code. All four source
Person values have `PrimaryEstimateBasis = posterior_eap`; this is provenance,
not evidence that the source population fit is stable.

## Source-fit result

| Scenario | P01 EAP | Posterior SD | Population variance | Numerical state |
| --- | ---: | ---: | ---: | --- |
| `EXT5-P-HI` | `4.5920068481176787e17` | `2.4619533341213642e17` | `2.1085809642021885e35` | `review` |
| `EXT5-P-LO` | `-2.3160821824913673e20` | `1.2417416697932585e20` | `5.3640542133432818e40` | `review` |
| `EXT5-P-NEAR-HI` | `7.9949657425812266e12` | `3.4621559054028789e12` | `8.3621157158749199e25` | `review` |
| `EXT5-P-NEAR-LO` | `-1.0756256721475396e12` | `4.6579231317489276e11` | `1.5131066062084316e24` | `review` |

All four source fits have `PopulationConverged = FALSE`, `FitReadiness =
review`, `InferenceReady = FALSE`, and fit boundary state `not_evaluated`.
Their finite EAPs therefore cannot be summarized as ordinary stable finite
estimates. In particular, MML integration prevents an exact Person MLE from
being reported as infinity, but it does not guarantee that the estimated
population variance is interior or numerically stable.

The fixed-q marginal slope-path audit completed and certified no retained-
additive constant slope-only path in these source fits. Its continuous-
integral certificate is false and its readiness effect remains instrumentation
only. This negative sufficient-path result does not repair the population-
variance or multi-start finding.

## Seven-start result

All 28 candidate optimizations returned finite vectors and all five total-free-
dimension counts equal 24. Each scenario had exactly one candidate passing the
existing optimizer numerical rule: `variance_low`. The default candidate was
`review` in every case. `retained_restart` was `fail` for `EXT5-P-LO`; the
other non-`variance_low` candidates were review-only.

| Scenario | Existing-pass starts | Diagnostic lowest objective | Default-minus-lowest objective | Lowest-candidate variance | Lowest-candidate slope range |
| --- | ---: | --- | ---: | ---: | --- |
| `EXT5-P-HI` | 1/7 | `variance_low` | `1.7199318723505712` | `0.030001627415204256` | `0.9964715152760709–1.0035406758429417` |
| `EXT5-P-LO` | 1/7 | `variance_low` | `1.7192247993521050` | `0.030001313684274500` | `0.9964716451545892–1.0035382545347895` |
| `EXT5-P-NEAR-HI` | 1/7 | `variance_low` | `4.1771515367876191` | `0.025442499693513324` | `0.9269645521631196–1.0336611160794216` |
| `EXT5-P-NEAR-LO` | 1/7 | `variance_low` | `4.1899170533547476` | `0.025442159014341593` | `0.9269504251556421–1.0336683059475240` |

The maximum absolute expanded semantic difference across starts ranges from
`8.36e25` to `6.29e75` by scenario and is dominated by population-variance
scale differences. Such values must remain class-specific; pooling them with
additive, step, or log-slope coordinates would be meaningless. Every candidate
has `P0StabilityEligible = FALSE`, and the diagnostic lowest-objective label
does not authorize selection.

The finding is stronger than a rounding discrepancy: the only existing-pass
candidate in every scenario has a materially lower common objective than the
default trace and a qualitatively different population scale. It still does
not prove a global finite maximum or justify silently replacing the public
optimizer result. A variance profile, integration adjudication, and a frozen
candidate-selection rule are prerequisites.

## Derivative-step calibration

The original P0 relative step `3e-5` is too coarse for the large-log-variance
source traces. The P0b calibration therefore evaluates the fixed five-step
ladder only for the default and diagnostic-lowest candidates.

| Scenario | Default minimum analytic/numeric difference (diagnostic step) | Lowest-candidate minimum difference (diagnostic step) |
| --- | --- | --- |
| `EXT5-P-HI` | `1.1088202171938288e-5` (`1e-8`) | `1.5790021965097516e-8` (`1e-5`) |
| `EXT5-P-LO` | `9.3601159039330764e-6` (`1e-8`) | `1.0221158052714474e-8` (`1e-5`) |
| `EXT5-P-NEAR-HI` | `1.5470336620643232e-4` (`1e-9`) | `1.1202840392157752e-8` (`1e-5`) |
| `EXT5-P-NEAR-LO` | `1.4550321748174611e-4` (`1e-9`) | `1.0342635542461394e-8` (`1e-5`) |

These minima are retrospective calibration descriptions, not chosen derivative
steps or pass thresholds. They show that the very large single-step mismatch
at the source trace is substantially step-dependent, while the lower-objective
candidate has a stable finite-difference window. This supports continued
analytic-gradient scrutiny but does not turn the ladder into confirmation.

## Decision signature

The endpoint signature separates:

- exact or near response provenance;
- posterior-EAP basis;
- source population convergence;
- the seven-start numerical panel;
- population boundary and continuous integration;
- candidate-specific EAPs; and
- DFF, fit, Person/Rater ranks, and facet separation.

Only the endpoint provenance fields pass. Population convergence and optimizer
panel remain review; every later field is `not_evaluated`; overall status is
review. Near-endpoint rows receive an explicit
`no_exact_response_boundary_reason_near_endpoint` reason rather than an empty
decision-signature field. Mutation tests detect a changed population-boundary
classification exactly, and a failed source fit produces a complete blocked
signature with no candidate vectors.

## Verification

The repository-mode focused test contains 124 expectations covering the
manifest, exact high/low reflection, category support, endpoint provenance,
all 28 candidate rows, five-way free-dimension identity, semantic comparisons,
the derivative ladder, decision-signature mutation, and failed-source-fit
retention. At the recorded source it completed with zero failures, warnings,
skips, or errors.

## Consequence and next gate

This P0b result changes the next priority. Another broad simulation is not
admissible. The next deterministic P1 work is:

1. profile `log_sigma2` toward both small natural variance and the observed
   large-variance direction from the same canonical candidate basis;
2. cross the default and `variance_low` basins with q=31/61/91 and reevaluate
   them on one common dense grid, without claiming a continuous integral;
3. preserve separate slope-only, population-variance, and joint movement
   states; and
4. only after those steps, materialize candidate-specific EAP and posterior-SD
   comparisons and decide whether any solution may enter Hessian/interval work.

Isolated all-high/all-low Raters and the five-category constant-response
non-recession control remain separate fixed-facet boundary work. They must not
inherit this Person-population result.
