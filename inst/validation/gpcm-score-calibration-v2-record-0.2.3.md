# mfrmr 0.2.3 bounded GPCM score calibration v2 record

Status: completed negative calibration and post-result mathematical
attribution, 2026-08-11. The v2 decision is `rejected` and remains unchanged.
No general score tolerance, boundary result, inference, selection,
confirmation, or release promotion is authorized.

## Identity and design

The calibration executed the complete frozen
`mfrmr_gpcm_score_calibration_design_v2` grid: Criterion/Rater aligned
slope-step ownership crossed with deterministic five-category core, one-Person
weak-bridge, workload-imbalance, and category-imbalance fixtures. Each owner
pair used the same 40-Person, four-Rater, four-Criterion data. Four parameter
points and four parameter classes produced 128 mandatory evidence rows and 672
coordinate rows.

Before these eight cells were opened, one Criterion/core runner preflight
showed that the v1 expanded-log-Jacobian cap `1e-10` was below the already
documented central-difference roundoff `1.40e-10`. V2 changed only that cap to
`5e-10`; the preflight is excluded from the 128 calibration rows.

| Field | Value |
| --- | --- |
| Execution contract | `mfrmr_gpcm_score_calibration_execution_v1` |
| Design contract | `mfrmr_gpcm_score_calibration_design_v2` |
| R / platform | R 4.6.1 / `aarch64-apple-darwin23` |
| Loaded package version | 0.2.3 |
| Package payload SHA-256 | `059515d620f2e1d31a10ea43bf5f843aadda4154f4096dfd3b5139ab0301a0bf` |
| Design SHA-256 | `4dbb7ff17f55edab5ab6540e03f36ff4a32e2f0b69f3b2c896327e7be7adfb8c` |
| Design-contract SHA-256 | `45d1b6f04146d8b8d129b4a042dd80827442c3b660ce8aea7a6bfe9188768096` |
| Non-unit oracle SHA-256 | `878e8bff3cca5fd8f2fbc04ae4a516e21f741a3b14223cd6c455a235aea008f8` |
| Runner SHA-256 | `7fdd8ed5b83eb2ec265aa52aa8b8abad469fc6f82de71d1a7f3588035bebbc68` |
| Runtime identity SHA-256 | `6d2d218efd8b6f4be0556599270e4439709b8f7a9fe46aedea7dc4212cf49ebc` |
| Manifest SHA-256 | `2d9420e0d98c208f6d3ca691af58ef73c7652222e3ab0a21b799d097f0f17ae7` |
| Total elapsed time | 79.09 seconds; local scheduling trace only |

## Formal v2 outcome

All eight fits returned finite retained vectors. Seven had optimizer code zero;
Criterion-owner weak bridge retained code 52 and `blocked`. Every fit remained
`InferenceReady = FALSE`: seven were `review` and one was `blocked`. Numerical
calibration therefore did not override the existing GPCM readiness boundary.

| Quantity | Result |
| --- | ---: |
| Required evidence rows | 128 / 128 complete |
| Coordinate rows | 672 |
| Coordinate rows passing the v2 rule | 639 |
| Coordinate rows failing the v2 rule | 33 |
| Point rows with exact structural-oracle agreement | 32 / 32 |
| Point rows passing the v2 Jacobian rule | 29 / 32 |
| Point rows with every coordinate passing | 28 / 32 |
| Formal status | `rejected` |

The 33 coordinate failures occurred in four point rows:

- Criterion-owner weak bridge, retained solution: 12 failures;
- Rater-owner weak bridge, retained solution: seven failures;
- Rater-owner weak bridge, forward finite-slope stress: five failures; and
- Rater-owner workload imbalance, retained solution: nine failures.

The three problematic retained vectors had maximum slopes approximately
`3.27e6`, `2.45e5`, and `2.58e5`, with minimum slopes approximately
`0.00169`, `0.0103`, and `0.00300`. Their positive-slope Jacobians had small
scaled differences (`2.02e-10`, `2.49e-11`, and `2.68e-10`) but absolute
differences up to `6.58e-4`. Requiring both a small absolute error and a small
scaled error therefore rejected transformations whose relative agreement was
near floating-point precision.

At the moderate forward stress point, slopes remained in `exp(-3)`--`exp(3)`.
The largest affected score differences were `6.99e-5` for owner-additive and
`1.09e-5` for steps, while the corresponding scaled errors were `2.25e-7` and
`7.92e-8`. This exposed the same defect in the conjunctive absolute-and-scaled
rule for legitimately large nonzero scores.

## Why the retained finite difference failed

The five-point stencil used optimizer-coordinate steps
`h * max(1, abs(parameter))`. A GPCM step perturbation enters the category
kernel multiplied by its slope. Thus the relevant local movement is
approximately `a * delta`, not `delta` alone. When `a` is `1e5`--`1e6`, even a
nominal `h = 3e-4` moves some category logits by hundreds or thousands and no
longer approximates a local derivative. Shrinking `h` eventually causes
subtraction cancellation in the marginal objective.

A post-result ladder from `1e-3` to `1e-8` confirmed this tradeoff. Moderate
stress derivatives converged to small scaled discrepancies, while no common
objective-difference step stably resolved every parameter class at the three
extreme retained vectors. This ladder is attribution only and cannot repair or
replace the rejected v2 decision.

## Independent analytic-score attribution

The follow-up contract
`mfrmr_gpcm_extreme_score_attribution_v1` independently reconstructed the
fixed-quadrature Person posterior and the sufficient-statistic score. For
Person `p`, node `q`, and parameter `xi`, it used

`d[-log L]/d xi = -sum_p sum_q posterior[p,q] * d ell[p,q]/d xi`,

with separate GPCM expected-category, cumulative-category, and log-slope
linear-part residuals, followed by independently coded sum-zero pullbacks for
facet, step, and log-slope coordinates.

All 48 scenario/point/class rows passed the predeclared combined allowance
`1e-8 + 1e-10 * score_scale`. The maximum package-versus-independent analytic
score difference was `1.04774e-9`; the maximum allowance ratio was `0.10374`.
All probability and marginal-objective structural comparisons also passed.

This strongly attributes the v2 rejection to finite-difference resolution and
the conjunctive scale rule rather than to the implemented analytic GPCM score.
It does not prove a finite maximum at the extreme retained vectors. The
Criterion weak-bridge fit remains optimizer-failed/blocked, and the other two
extreme-slope fits remain review-only numerical traces.

## Consequence for the next rule

V2 is a useful negative calibration, not a gate pass. A v3 proposal must be
specified before new calibration evidence is opened and must separate:

1. a finite-slope stationarity region, with the already exercised expanded-log
   envelope `[-3, 3]`, independent analytic-score agreement, and a combined
   absolute-plus-relative finite-difference allowance;
2. extreme retained slope traces outside that envelope, which require analytic
   identity checks and an explicit boundary/readiness handoff but cannot count
   as finite-stationarity passes; and
3. transformation Jacobian comparison using a combined absolute-plus-relative
   allowance rather than requiring each component separately.

The same eight datasets may inform a retrospective v3 calibration, but they
cannot serve as independent confirmation. After v3 is frozen, confirmation
must use disjoint deterministic fixtures or source-bound candidate data and
must preserve the rule unchanged. Automatic expansion to a large replication
study is not warranted by this result.

## Retained artifact identities

The result bundle is retained locally under the ignored validation-results
directory; the record preserves its content identity.

| Artifact | SHA-256 |
| --- | --- |
| `gpcm-score-calibration-v2.rds` | `aaa6685ce0f2114ac6489836d5bc5cdedb314fc49e27c172d5141ce8514e8f8a` |
| `evidence.csv` | `59b2edf229c9bb2a5eff4c89898612a561dbb1c7d936dcdedaa262c71235dadc` |
| `coordinates.csv` | `6a342974006effb1d0175a7c8c37d60df62b4b398f539bf634c1e52e177dffee` |
| `point-summary.csv` | `d550dd41275806f4664bd9f8f6a3b7a2c899eae001cae33df5b40051849d4d76` |
| `decision.csv` | `47211701dfa0706ac26d282c85b1e7eea69890e4bb1e7e92caf0debde76adaa7` |
| `step-attribution.csv` | `2dc1fe1168d9173f6656dd524fd407b36cecb82339de665b61e66655736f7d1c` |
| `extreme-score-attribution.rds` | `bbdc7d7bba0a7649e3f29ab1980f7fdffeea817a19aa47a0cc7992bdc45eafe3` |
| `attribution-evidence.csv` | `8b49bad827e7d117727ea840080115bed39d43f071766d865be6b34915f3bb4c` |
