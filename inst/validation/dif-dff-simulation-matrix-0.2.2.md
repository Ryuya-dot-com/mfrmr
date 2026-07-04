# DIF/DFF simulation matrix evidence (0.2.2)

This is a seeded smoke validation summary for the 0.2.2 DIF/DFF program.
It is not a calibrated operating-characteristic study. Increase `reps`
and retain the CSV outputs before using the results as power or false-
positive-rate evidence.

- `DIFDFFSimulationStatus = "ok"`;
- `Replications = 1` per requested model/scenario;
- `Models = RSM, PCM, GPCM`;
- `Scenarios = categorical_signal, categorical_null, categorical_three_level, continuous_signal`;
- `Cases = 12`;
- `Checks = 118`;
- `FailedChecks = 0`.

## Interpretation boundary

Seeded smoke matrix for DFF/DIF helper behavior across RSM, PCM, and bounded GPCM. Results support route-boundary and target-direction checks only; they are not calibrated power, Type-I-error, fairness, invariance, or operational subgroup-decision evidence.

## Summary

 Model                Scenario Replications FitCompletedRate
  GPCM        categorical_null            1                1
  GPCM      categorical_signal            1                1
  GPCM categorical_three_level            1                1
  GPCM       continuous_signal            1                1
   PCM        categorical_null            1                1
   PCM      categorical_signal            1                1
   PCM categorical_three_level            1                1
   PCM       continuous_signal            1                1
   RSM        categorical_null            1                1
   RSM      categorical_signal            1                1
   RSM categorical_three_level            1                1
   RSM       continuous_signal            1                1
 TargetScreenPositiveRate DirectionOKRate MeanTargetEffect
                        0              NA       0.01309299
                        1               1       0.45014614
                        1               1      -0.44231427
                        1               1       0.13172713
                        0              NA       0.11859293
                        1               1       0.29189890
                        1               1      -0.54157868
                        1               1       0.07621175
                        0              NA       0.14352479
                        1               1       0.52355748
                        1               1      -0.40671902
                        1               1       0.17348299
 MeanScreenPositiveCount MeanNonTargetScreenPositiveCount BoundaryOKRate
                       0                                0              1
                       1                                0              1
                       3                                2              1
                       1                                0              1
                       0                                0              1
                       2                                1              1
                       4                                3              1
                       1                                0              1
                       0                                0              1
                       3                                2              1
                       2                                1              1
                       1                                0              1
                                     ModelScope
 fitted_mfrm_bounded_gpcm_screening_with_caveat
 fitted_mfrm_bounded_gpcm_screening_with_caveat
 fitted_mfrm_bounded_gpcm_screening_with_caveat
 fitted_mfrm_bounded_gpcm_screening_with_caveat
             fitted_mfrm_rasch_family_screening
             fitted_mfrm_rasch_family_screening
             fitted_mfrm_rasch_family_screening
             fitted_mfrm_rasch_family_screening
             fitted_mfrm_rasch_family_screening
             fitted_mfrm_rasch_family_screening
             fitted_mfrm_rasch_family_screening
             fitted_mfrm_rasch_family_screening

## Generated output files

The helper writes the following CSVs when regenerating this evidence. They are
generated outputs, not bundled sibling release-evidence files, unless an
explicit future release review decides to preserve them.

- `dif-dff-simulation-matrix-0.2.2-results.csv`
- `dif-dff-simulation-matrix-0.2.2-summary.csv`
- `dif-dff-simulation-matrix-0.2.2-checks.csv`
