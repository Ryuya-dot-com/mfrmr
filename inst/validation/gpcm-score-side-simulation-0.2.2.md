# Bounded-GPCM score-side simulation evidence (0.2.2)

This is a seeded smoke validation summary for the bounded-GPCM score-side
estimand and uncertainty route. It checks the independent adjacent-category
identities used by `gpcm-score-side-estimand-0.2.2.md` and records a compact
Monte Carlo comparison of the legacy slope-scaled logit SE against the
corrected score-scale delta SE. It is not calibrated power, Type-I-error,
posterior-predictive, or operational score-scale evidence.

- `GPCMScoreSideSimulationStatus = "ok"`;
- `Replications = 1` per condition;
- `Regimes = unit, mild, strong`;
- `NPerson = 50, 150`;
- `Conditions = 6`;
- `SummaryRows = 24`;
- `ErroredReplications = 0`;
- `MaxSERatioDiff = 4.441e-16`;
- `MinConvergedRate = 1.000`;
- `FailedChecks = 0`.

## Interpretation boundary

The release gate uses this artifact to verify formula-level consistency,
score-side SE scale alignment, explicit bounded-GPCM caveat evidence, and
error-free seeded execution. Coverage rows are retained for reviewer
inspection only; they should not be reported as operating-characteristic
evidence without a larger ADEMP-style simulation.

## Identity and gate checks

```
                     Check     Value Threshold Passed
   package_expected_anchor 1.332e-15   1.0e-06   TRUE
   package_variance_anchor 3.442e-15   1.0e-06   TRUE
 expected_score_derivative 6.097e-11   1.0e-06   TRUE
      rescaling_invariance 0.000e+00   1.0e-10   TRUE
  unit_slope_pcm_reduction 0.000e+00   1.0e-12   TRUE
      errored_replications 0.000e+00   0.0e+00   TRUE
              summary_rows 2.400e+01   2.4e+01   TRUE
         se_ratio_identity 4.441e-16   1.0e-10   TRUE
  minimum_convergence_rate 1.000e+00   9.5e-01   TRUE
```

## All-condition summary

```
 regime n_person reps coverage_legacy coverage_corrected se_ratio_mean
   mild       50    1          0.9962             0.9550         1.800
 strong       50    1          0.9875             0.9287         2.073
   unit       50    1          1.0000             0.9150         1.932
   mild      150    1          0.9933             0.9283         1.907
 strong      150    1          0.9858             0.9233         2.224
   unit      150    1          1.0000             0.9429         1.866
 inv_var_mean within_raw_sd within_weighted_sd converged_rate
        1.800       0.04282            0.05967              1
        2.073       0.12515            0.07614              1
        1.932       0.04742            0.05155              1
        1.907       0.04961            0.05537              1
        2.224       0.12555            0.06220              1
        1.866       0.01614            0.05145              1
```

## Files

- `gpcm-score-side-sim-results-0.2.2.csv`
- `gpcm-score-side-sim-summary-0.2.2.csv`
- `gpcm-score-side-sim-checks-0.2.2.csv`
