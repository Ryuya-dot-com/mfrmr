# GPCM stress covering-grid smoke record for mfrmr 0.2.3

Status: repository-only draft.41 calibration record, 2026-08-05. This is not
confirmation evidence and freezes no numerical release criterion.

## Identity

| Field | Value |
| --- | --- |
| Package | mfrmr 0.2.3 development tarball from source commit `58db5d2` |
| Package tarball SHA-256 | `E897473FC36A9A91762137A813982037646989BB302E504CAD5AAA7B8E70715F` |
| Runner | `gpcm-stress-covering-grid-0.2.3.R` |
| Runner SHA-256 | `02D068594A4253539D74F517E293640E9A0DA3D38269A15C63951ED73085A3A6` |
| R | 4.5.1 (2025-06-13 ucrt), Windows 11 x64 |
| Key packages | lpSolve 5.6.23; digest 0.6.39; psych 2.6.5 |
| Profile | `smoke`, one deterministic seed per mandatory smoke corner |
| Manifest hash | `1157044b089f9b2c261f9feceb6bf25c16aa71435307afed635aef30c05c4994` |
| Output directory | workspace `mfrmr/archive/artifacts/validation-bundles-0.2.3/gpcm-stress-covering-smoke-20260805-v1` |

Retained aggregate artifacts:

| Artifact | SHA-256 |
| --- | --- |
| `scenario-manifest.csv` | `3CF6B3A1D63AD198C75D19565ABFC4E64AB1F9DFEAAD253A0527C91E119DFE59` |
| `pairwise-coverage.csv` | `BB43FAEAFC152A77022B4D4D21A5BE1F39638141E7DEB78E0B99BE98139785DE` |
| `run-results.csv` | `D29D79EF85B7B632F80EA22EA4A9484531C83A99BB489088DCE330027C5B2114` |
| `gpcm-stress-covering-grid.rds` | `4B04C8CA8C155E1BF6F56E92A2F506AEB7F6E95C46DFB5DCE5B3F00B8C5D36FF` |

## Structural manifest result

The pilot/confirmation design has 70 rows, including 12 mandatory adversarial
corners. It covers all 1,330 required two-axis level combinations over 12
stress axes; uncovered pairs are zero. Smoke, pilot, and confirmation seed
ranges are disjoint. `PCM_JML` and `PCM_MML` are separate lower-model analysis
routes rather than labels attached to free-slope GPCM output.

The genuine one-slope-level generator remains non-executable. The current
simulation API requires at least two criterion levels, while the supported
GPCM form requires the slope facet to equal the step facet. Equal true slopes
over two estimated levels are not substituted for this missing reduction.

## Smoke outcomes

| Corner | Analysis | Rows | Support signal | Fit result | Primary/comparison result | PCA |
| --- | --- | ---: | --- | --- | --- | --- |
| `binary_unit_jml` | GPCM JML | 96 | two categories; 24 common Persons | `blocked`, boundary `not_evaluated` | 0 primary slopes; 0 comparison-eligible slopes | exploratory PC1 eigenvalue 1.803 |
| `unit_mml_reference` | PCM MML | 144 | five categories; 24 common Persons | `ready`, finite boundary | no slope parameter in the lower model | exploratory PC1 eigenvalue 2.102 |
| `two_rater_joint_warning` | GPCM JML | 29 | one shared Person; one empty category after combined thinning | `blocked`, boundary `not_evaluated` | 0 primary slopes; 0 comparison-eligible slopes | exploratory PC1 eigenvalue 2.000 |
| `zero_shared_jml` | GPCM JML | 48 | zero common Persons; one zero-common rater pair | expected pre-fit fail-closed | no fitted slope result; false-ready false | not run |
| `internal_zero_mml` | GPCM MML | 86 | one deliberately empty internal category | `review`, boundary `not_evaluated` | 0 primary slopes; 0 comparison-eligible slopes | exploratory PC1 eigenvalue 3.724 |
| `local_dependence_jml` | GPCM JML plus Occasion | 423 | 39 repeated base cells, 0 after Occasion distinguishes them | `review`, boundary `not_evaluated` | 0 primary slopes; 0 comparison-eligible slopes | exploratory PC1 eigenvalue 8.272 |
| `one_level_gap` | manifest-only | - | unsupported generator contract | known gap, not executed | no result | not run |

Top-line accounting: seven manifest rows, six executed rows, zero runner
failures, zero false-ready rows, one known non-executable gap, zero external
numeric-eligible rows, and zero frozen thresholds. All rows retain
`ReleaseUse = calibration_only`.

## Adversarial interpretation

This run establishes instrumentation behavior only.

- The ready PCM-MML row shows that the runner can preserve an applicable lower-
  model analysis. It does not make FACETS, TAM, or immer output numerically
  eligible; the external normalizer and identification contracts remain open.
- The combined two-rater/rare-category cell is blocked partly because a
  category disappears. It cannot be used to attribute the result uniquely to
  slope geometry, weak linkage, missingness, or planted bias. Isolated and
  factorial attribution cells are still required.
- The local-dependence PC1 value has no matched null distribution, frozen
  residual construction, Monte Carlo uncertainty, multiplicity rule, or
  decision threshold in this smoke run. It is proof of executable diagnostic
  plumbing, not sensitivity evidence.
- Optimizer log-slope errors are diagnostic traces while GPCM primary slope
  readiness is absent. They must not enter recovery RMSE, external agreement,
  or release pass rates as if they were estimable parameters.
- One seed cannot estimate bias, RMSE, coverage, false-ready probability,
  diagnostic Type-I error, sensitivity, failure probability, or runtime tails.

Before a frozen confirmation run, the replicated pilot must estimate operating
characteristics by estimator, parameter class, support condition, and scenario;
calibrate numerical and Monte Carlo criteria without reusing confirmation
seeds; add isolated attribution controls; benchmark target-scale runtime and
memory; and complete matched external estimator/normalizer contracts.
