# Factor-structured TAM/immer/mfrmr JML smoke record for mfrmr 0.2.3

Status: Draft.76 repository-only feasibility record, 2026-08-09.

## Execution identity and accounting

The run reused the Draft.75 loaded-function identity contract for development
mfrmr 0.2.3, TAM 4.3-25, and immer 1.5-13. All 22 declared RSM/PCM datasets
generated successfully.

| Expected state | Datasets | Observed result |
| --- | ---: | --- |
| Nine mode rows attempted | 18 | 18 matched |
| Guarded anchor non-attempt | 2 | 2 matched |
| Structurally unidentified negative control | 2 | 2 matched |

The low-scale profile had 48 Persons, 3 Raters, 2 Criteria, and only one Rater
per Person. With no cross-Rater common Persons, RSM had rank 50/52 and PCM rank
51/53; optimization was correctly not run. The 25% anchor profiles retained
their generated truth anchor tables and stopped at the declared common-basis
guard.

The other 18 datasets retained 162 mode rows and 3,050 metric rows under the
current registry. The overall contract passed. No row is release evidence.

## Extreme scores and method availability

Only seven of the 18 fitted datasets had no observed extreme Person. TAM
`adj = 0` raw and classical modes returned on those seven and failed on the
other 11; all 22 failed mode rows retain
`missing value where TRUE/FALSE needed`. mfrmr raw finite traces and all immer
`jml` modes returned, but original-raw eligibility for mfrmr raw and immer
`jml` was likewise only 7/18. Numerical return and estimand eligibility are
therefore visibly different denominators.

The forced-endpoint profiles realized approximately 9.4% all-minimum and 9.4%
all-maximum Persons. Natural extremes also occurred in reference, missing, and
low-information profiles, which confirms that extreme handling cannot be
restricted to an explicitly forced-extreme scenario label.

## Sparse and missing exposure changes the corrections

The complete Draft.75 smoke made TAM and immer classical factors both `8/9`.
Draft.76 breaks that coincidence:

| Condition | TAM effective `I` / factor | immer effective `Ibar` / factor |
| --- | ---: | ---: |
| Sparse workload, 8 Raters x 4 Criteria, 2 Raters/Person | `32`, `31/32 = 0.96875` | `8`, `7/8 = 0.875` |
| MCAR examples | `16`, `15/16 = 0.9375` | about `6.35--6.50`, about `0.843--0.846` |
| Rater-MAR examples | `16`, `15/16 = 0.9375` | about `6.26--6.34`, about `0.840--0.842` |
| Score-MNAR examples | `16`, `15/16 = 0.9375` | about `6.33`, about `0.8421` |

Across fitted smoke cells, TAM factors ranged `0.9375--0.97917`; immer factors
ranged `0.84027--0.95833`. Thus correction identity depends materially on
whether `I` means the potential pseudoitem panel or mean observed exposure.

The source/output audit also found that TAM `errorP` is unchanged between raw
and classically postscaled fits, and immer `xsi_se` is unchanged between
`jml` and `jml_bc`, while their point estimates are scaled. Common-surface
coverage is consequently withheld rather than constructed from those
untransformed marginal SEs.

## Descriptive recovery and rank traces

Across all eligible one-seed method/cell rows:

| Scope | RMSE range | Rank/separation context |
| --- | ---: | --- |
| Expanded cumulative-difficulty surface | `0.157--4.092` | Surface bias ranged about `-0.224--0.019` after location alignment. |
| Criterion positions | `0.031--0.276` | Spearman recovery `0.40--1.00`; pairwise order accuracy `0.667--1.00`. |
| Rater positions | `0.026--1.489` | Spearman recovery `0.20--1.00`; pairwise order accuracy `0.50--1.00`. |

Recovery separation ranged about `0.87--11.05` for Criteria and
`0.19--14.03` for Raters. These values are the declared truth-SD/RMSE ratio,
not engine-reported facet separation.

The wide range is expected: it pools different sizes, endpoint mechanisms,
dependence, missingness, and estimator conventions solely to inspect metric
computability. It is not a performance ranking. In particular, combined
adversity had the largest mean RMSE, while high exposure had the smallest, but
one seed cannot establish either ordering.

## Numerical convergence is definition-specific

Among the 18 datasets with mode attempts, the engine-labelled numerical
success counts were:

| Mode | Successful / attempted | Definition |
| --- | ---: | --- |
| mfrmr raw | `18/18` | Optimizer convergence code zero. |
| mfrmr profile | `18/18` | Profile complete/no-op complete. |
| TAM adjusted / combined | `12/18` each | Iteration terminated before `maxiter`; proxy only. |
| TAM raw / classical | `4/18` each | Includes extreme-score failures and iteration ceilings. |
| immer `jml`, `eps_adj`, `jml_bc` | `17/18` each | Iteration terminated before `maxiter`; proxy only. |

mfrmr raw numerical convergence was 18/18 while original-raw estimand
eligibility was 7/18. This is precisely why convergence rate, finite return,
and valid-estimand rate must remain separate.

## Withheld metrics and next gate

Eligible common-surface SE coverage rows: `0`. Eligible definition-matched
reported facet-separation rows: `0`. Both absences are intentional contract
results, not missing values to impute.

The next authorized execution is the guarded 290-dataset factor pilot. Before
any high-replication coverage stage, work must separately close:

1. common anchor reparameterization and negative fixtures;
2. native-basis or bootstrap/refit covariance identity for coverage;
3. definition-matched facet separation, if a shared statistic is feasible;
4. engine-specific convergence extraction beyond the external iteration-ceiling
   proxy; and
5. replication and Monte Carlo precision adequate for coverage and failure
   probabilities.

No correction, sample-size recommendation, threshold, default, checklist
state, candidate, or confirmation state changes.

## Draft.77 completion note

The guarded next pilot named above has now been executed with dataset-level
atomic checkpoints. Its 290/290 accounting, 2,070 attempted method rows,
39,406 metrics, factor-level descriptive summaries, and continuing
prohibitions are recorded separately in
`tam-immer-jml-factor-pilot-record-0.2.3.md`. The smoke record remains the
historical feasibility result and is not retroactively treated as the pilot.
