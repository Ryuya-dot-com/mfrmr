# GPCM slope-action population projection

Status: completed repository-only model-identity audit; no public likelihood,
readiness, or release change

Review date: 2026-08-14

## Question

The implemented bounded GPCM uses the complete-predictor adjacent logit

\[
L^{C}_{prck}=\alpha_c(\theta_p-\rho_r-b_{ck}),
\]

whereas the loading-only comparison uses

\[
L^{L}_{prck}=\alpha_c\theta_p-\rho_r-b_{ck}.
\]

Can their difference be removed by changing parameter coordinates, or does it
remain when heterogeneous Criterion slopes and Rater severity contrasts occur
in a crossed design?

## Algebraic discriminator

For two Raters \(r,s\) and two Criteria \(c,d\), define the adjacent-logit
difference in differences

\[
D=(L_{rc}-L_{sc})-(L_{rd}-L_{sd}).
\]

The loading-only model gives \(D=0\). The complete-predictor model gives

\[
D=-(\alpha_c-\alpha_d)(\rho_r-\rho_s).
\]

Consequently, the models have an exact common reduction when slopes are all
one or when the non-owner Rater contrast is zero. With heterogeneous slopes,
nonzero Rater contrasts, and Raters crossing Criteria, the models are not
generally reparameterizations of each other.

## Deterministic projection design

- Four Criteria and four Raters are fully crossed.
- Four ordered categories give three Criterion-specific transition
  boundaries.
- Criterion slopes have geometric mean one and Rater severities sum to zero.
- The latent distribution is fixed standard normal.
- Expected per-response Kullback--Leibler loss is integrated at q=31 and q=41.
- Each truth family is projected into the other family with all slopes,
  severities, and transition boundaries re-estimated.
- Maximum probability differences are evaluated on the common grid
  \(\theta=-4,-3.95,\ldots,4\), rather than on q-specific extreme nodes.

This is a population-oracle model-form audit. It is not JML, a finite-sample
MML simulation, an uncertainty study, or a comparison of optimizer readiness.

## Fixed scenarios

| Scenario | Slope condition | Rater severity condition | Expected relation | Complete-predictor \(D\) |
| --- | --- | --- | --- | ---: |
| `unit_slopes` | all 1 | -0.60, -0.20, 0.20, 0.60 | exact reduction | 0 |
| `zero_rater_contrast` | exp(-0.45, -0.15, 0.15, 0.45) | all 0 | exact reduction | 0 |
| `moderate_crossed` | exp(-0.30, -0.10, 0.10, 0.30) | -0.45, -0.15, 0.15, 0.45 | distinct models | -0.5481365282 |
| `strong_crossed` | exp(-0.45, -0.15, 0.15, 0.45) | -0.80, -0.25, 0.25, 0.80 | distinct models | -1.4890944542 |

The independently evaluated algebraic expression and computed
complete-predictor difference in differences agree to numerical precision;
the loading-only values are numerical zero in all four scenarios.

## q=31 population projections

| Scenario | Truth | Candidate | Projected KL / response | Maximum probability difference |
| --- | --- | --- | ---: | ---: |
| `unit_slopes` | complete | loading-only | numerical zero | 0.0000000017 |
| `unit_slopes` | loading-only | complete | numerical zero | 0.0000000018 |
| `zero_rater_contrast` | complete | loading-only | numerical zero | 0.0000000074 |
| `zero_rater_contrast` | loading-only | complete | numerical zero | 0.0000000029 |
| `moderate_crossed` | complete | loading-only | 0.0015929961 | 0.0466938020 |
| `moderate_crossed` | loading-only | complete | 0.0015814829 | 0.0614915768 |
| `strong_crossed` | complete | loading-only | 0.0085423564 | 0.1090822450 |
| `strong_crossed` | loading-only | complete | 0.0087751728 | 0.1843185277 |

All 16 q-specific optimizations returned convergence code zero. This is a
local optimizer result, not proof of a global KL minimum. The maximum absolute
q=31-to-q=41 change in the retained projected KL was `3.65e-9`; the maximum
change in common-grid maximum probability difference was `2.99e-8`. The
distinction is therefore not a q=31 integration artifact in this fixed design.

## Interpretation

1. The unit-slope and zero-Rater-contrast controls recover the expected exact
   reductions. This guards against treating a coordinate change as model
   misspecification.
2. Once both slope and Rater contrasts are present in the crossed design,
   re-estimating all available parameters does not remove the probability
   discrepancy.
3. The effect grows in the stronger fixed condition, but these two conditions
   do not establish a universal practical threshold or prevalence claim.
4. A loading-only kernel should therefore be treated as a separate candidate
   response family, not a silent interpretation switch for an existing mfrmr
   GPCM fit.
5. Before adding that family publicly, a finite-sample study must separately
   assess recovery, uncertainty, sparse crossing, model-selection behavior,
   and whether observed data contain enough Rater-by-Criterion information to
   distinguish the slope actions.

ImplementedFamilyChanged = FALSE

LoadingOnlyPublicFamilyAdded = FALSE

ReadinessOverridden = FALSE

ScientificThresholdFrozen = FALSE

ReleaseAuthorized = FALSE
