# Factor-structured TAM/immer/mfrmr JML pilot record for mfrmr 0.2.3

Status: Draft.77 repository-only five-replicate calibration record,
2026-08-09.

## Execution and accounting

The declared 29 profiles x RSM/PCM x five replicates completed under the
Draft.77 checkpoint contract. All 290 cells were regenerated from the frozen
manifest and all expected states matched:

| State | Datasets | Retained method rows |
| --- | ---: | ---: |
| Nine method modes attempted | 230 | 2,070 |
| Structurally unidentified before fitting | 40 | 0 |
| Guarded common-anchor-basis non-attempt | 20 | 0 |

The four one-Rater-per-Person profile families were `EXPOSURE_LOW`,
`RATERS_LOW`, `DENSITY_LOW`, and `LOWINFO_LD_EXTREME`. With no common Persons
linking Raters, all 40 RSM/PCM replicate cells failed the planned structural
rank screen. This is a design result, not an optimizer failure. The 25% and 50%
Rater-anchor profiles retained truth anchors but stopped before fitting because
the three engines do not yet share a proved anchor basis.

The run retained 39,406 metric rows. Its deterministic aggregate result hash is
`bd506dfdad21d1bafa3ee45409e64a77d8d63e5b75483a35db304644a224ab53`.
The completion-marker file SHA-256 is
`9bf8b8db3ce45ccd416d0fe12d5906bd33c104d5aa00db8925edfd410faa999c`.
A separate process resumed all 290 checkpoints, refit zero cells, and
reconstructed both hashes exactly. The aggregate RDS file SHA-256 is
`70646c2a53c21f989a75c24efbc2a452748de0492d834451e73f6c240eea7413`.

The ignored local evidence bundle is
`validation-results/draft77-tam-immer-jml-factor-pilot-20260809/`. It contains
the aggregate RDS, 290 cell checkpoints, completion marker, raw dataset/mode/
metric tables, and deterministic descriptive-review tables. It is not part of
the CRAN package or confirmation evidence.

## Availability, convergence, and estimand eligibility

| Mode | Returned / 230 | Engine-labelled numerical convergence | Evidence-eligible |
| --- | ---: | ---: | ---: |
| mfrmr raw | 230 | 230 | 104 |
| mfrmr extended profile | 228 | 228 | 228 |
| TAM raw | 103 | 84 | 103 |
| TAM adjusted | 230 | 192 | 230 |
| TAM classical correction | 103 | 84 | 103 |
| TAM adjusted + classical correction | 230 | 192 | 230 |
| immer `jml` | 230 | 230 | 104 |
| immer `eps_adj` | 230 | 230 | 230 |
| immer `jml_bc` | 230 | 230 | 230 |

Observed extreme Persons occurred in 126/230 fitted datasets, leaving only 104
original-raw-eligible datasets. TAM raw/classical returned on 103: one
no-extreme PCM `CRITERIA_HIGH` replicate also failed with its retained native
error. The mfrmr extended profile failed on two RSM `PERSONS_HIGH` replicates;
the raw optimizer fits returned on both. Those failures remain in every
denominator.

The external numerical-convergence counts are iteration-before-ceiling proxies,
not common score-equation proofs. In particular, a finite returned surface,
engine-labelled convergence, and evidence-eligible estimand remain three
separate quantities.

## Correction identity and finite-item bias trace

Across the pilot, TAM's classical factor ranged `0.875--0.96875`; immer's
factor ranged `0.75--0.9375`. The largest mean differences arose for two
Criteria (`0.875` versus `0.75`), sparse-load-MAR (about `0.96875` versus
`0.84460`), and 30% missingness (TAM `0.9375` versus immer about
`0.82043--0.82416`). Thus unequal exposure makes the two classical corrections
materially different estimator identities.

On common original-raw-eligible cumulative-surface rows:

| Pair | Datasets | Mean raw bias | Mean corrected bias | Fraction with smaller absolute bias | Mean raw RMSE | Mean corrected RMSE | Fraction with smaller RMSE |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| TAM raw -> classical | 103 | -0.0790 | -0.0533 | 0.932 | 0.4713 | 0.4109 | 0.951 |
| immer `jml` -> `jml_bc` | 104 | -0.0790 | -0.0299 | 0.913 | 0.4712 | 0.3617 | 0.942 |
| TAM adjusted -> adjusted + classical | 230 | -0.0910 | -0.0635 | 0.948 | 0.5228 | 0.4531 | 0.974 |

These are five-replicate descriptive calibration traces. They support the
expected direction of finite-item scale contraction but do not select a
correction. A corrected point estimate is not the maximizer of the original
unadjusted JML likelihood. TAM `errorP` and immer `xsi_se` also remain on their
untransformed returned bases, so the table supplies no corrected-estimand Wald
coverage claim.

## Factor-level descriptive signals

For each model/mode/facet, replicate-mean RMSE was divided by its corresponding
reference mean. The numbers below are medians across those method-specific
ratios, not pooled estimands or method rankings.

| Profile | Cumulative surface | Criterion position | Rater position |
| --- | ---: | ---: | ---: |
| Persons low (48) | 1.48 | 1.69 | 1.33 |
| Persons high (480) | 0.53 | 0.59 | 0.42 |
| Exposure high (four Raters/Person) | 0.61 | 0.93 | 0.51 |
| Criteria low / high | 1.70 / 0.83 | 1.13 / 1.12 | 1.62 / 0.73 |
| Categories low / high | 0.87 / 1.25 | 1.68 / 0.86 | 0.79 / 0.82 |
| Workload high | 1.25 | 1.24 | 1.23 |
| Local dependence 0.20 / 0.50 | 1.36 / 1.71 | 1.01 / 1.34 | 1.46 / 1.57 |
| MCAR 15% / 30% | 1.18 / 1.41 | 1.73 / 1.73 | 0.90 / 1.30 |
| Rater-MAR 15% / 30% | 1.13 / 1.33 | 1.51 / 1.08 | 0.98 / 0.99 |
| Score-MNAR 15% / 30% | 1.69 / 2.43 | 1.38 / 2.19 | 1.37 / 1.23 |
| Sparse + high load + MAR | 2.01 | 1.31 | 2.52 |

The clearest feasibility signals are that more Persons reduces variance but
does not by itself prove removal of fixed-exposure incidental-parameter bias;
additional Rater exposure benefits Rater recovery more than Criterion recovery;
high workload imbalance degrades all three scopes; and local dependence,
score-MNAR, and their sparse interaction can substantially degrade surface or
Rater recovery.

Metric conclusions are not interchangeable. For example, median Criterion
Spearman recovery was `0.64` under 30% score-MNAR versus `0.88` at reference,
while median Rater Spearman was about `0.681` under sparse-load-MAR versus
`0.76` at reference. Some cells with worse RMSE retained or improved ordering.
Detection of ordering does not imply accurate location recovery.

The apparent advantages of `DENSITY_HIGH` and some endpoint profiles are not
interpretable as general benefits. `DENSITY_HIGH` also reduces the number of
Raters to two, making Rater recovery easier, while one-Rater-per-Person low-
density cells are unidentified. Forced extremes invalidate original raw JML
even when adjusted modes show small structural RMSE. These are design aliases
and estimator-eligibility effects, not causal factor conclusions.

## Withheld conclusions and next design revision

Common-surface SE coverage and definition-matched reported facet separation
still have zero eligible rows. The truth-SD/RMSE recovery-separation ratio is
retained separately and is never relabelled as Rasch/FACETS separation.

Five replicates are insufficient for coverage, rare failures, a sample-size
recommendation, or a correction choice. Draft.77 therefore authorizes no
threshold, default, winner, release state, or confirmation run. The next
revision must:

1. replace one-Rater-per-Person main-effect cells with connected low-exposure
   designs containing a prespecified bridge fraction;
2. separate Rater count from assignment density and realized exposure more
   cleanly;
3. prove a common anchor constraint basis;
4. obtain a transformed covariance or frozen bootstrap/refit uncertainty route;
5. match any reported facet-separation definition and extract stronger native
   convergence evidence; and
6. set high-replication Monte Carlo precision and untouched confirmation seeds
   before deriving sample-size or coverage claims.

Only after this additive RSM/PCM infrastructure is closed should the same
factor topology be transferred to Criterion-owned and Rater-owned GPCM as two
separate model identities.
