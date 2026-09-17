# Pair allocation from retained independent-pilot fits

## Question and design fixed before additional scoring

Does evaluating more prespecified disjoint person differences per fitted
dataset reduce the simulation effort needed to estimate marginal coverage?
The four-pair pilot spends a calibration fit on N=24 or N=120 people but uses
only eight people for its difference estimand. Additional pairs can reuse that
fit; their common estimated calibration prevents assuming independent-pair
precision. This follow-up informs allocation, not a new independent confirmation
of coverage or a correction for calibration uncertainty.

Reuse all 40 datasets, latent truths and accepted fits in
`local-testlet-independent-pilot-0.2.4-evidence.rds` (MD5
`c052bb1df54c2d6b0015e01080896935`). No optimizer call, new data generation,
person rescoring or replacement of the original four-pair records is allowed.
Keep the original two methods: true calibration (oracle) and uncorrected
same-sample plug-in calibration. The model and all numerical acceptance rules
remain those of the independent pilot.

For each dataset define pairs `(P1,P2), (P3,P4), ... (P(N-1),PN)` before
additional scoring. Person identifiers were assigned without sorting latent
ability or outcomes. Evaluate all N/2 disjoint pairs and compare nested prefixes:

- N=24: 4, 8, 12 pairs;
- N=120: 4, 12, 30, 60 pairs.

Reuse pairs 1--4 and score only pairs 5--N/2: 1,280 additional pairs, each with
two methods, hence 2,560 new rows. A bounded compatibility check evaluates just
the first saved pair for each method in replicate 1 of each cell (eight rows).
It requires identical coverage rows and integration-attempt payloads, excluding
elapsed time. These bridge rows are not added to the analysis. The new driver
accepts explicit targets; its integration logic is copied unchanged from the
frozen scorer to preserve the historical source hash. Numerical kernels are
shared. The plan, source/input hashes and complete target lists are saved before
the bridge and additional scoring. Retain every attempt and failure.

## Analysis and allocation rule

For each cell and prefix report oracle coverage, plug-in coverage and their
matched plug-in-minus-oracle difference. Keep all ten dataset clusters;
unavailable targets contribute no available/matched denominator. Also report
assigned, available and covered counts, and available-and-covered/assigned.
Use the existing ratio influence-function `pec_cluster()` for MCSE, preserving
dependence among pairs sharing a dataset. Zero observed cluster variance is
uninformative for extrapolation, not proof of zero uncertainty. These ten-cluster
estimates are noisy; neither monotone gains nor an optimal pair count is assumed.

Retain all-person planning results unchanged. For each pair-count choice project
the dataset count for all six planning metrics (two coverages plus their paired
difference for persons and pairs) to MCSE .005 using
`ceil(10 * (pilot_MCSE / .005)^2)`. Mark zero/undefined MCSE as uninformed.
Compare all 3 x 4 allocations of the candidate N-specific pair counts. For a
simple equal-replication design, round the largest finite cell/metric projection
up to the next 100 datasets per cell, with a floor of 200. Report the number of
uninformed metrics; a rounded candidate is not a precision guarantee.

Record added scoring wall time and per-target attempt times. Approximate future
serial effort by adding the retained fit, higher-order reference and person
scoring times to the selected pair scoring times. Additional batches repeat
normalizer setup, so this is a conservative setup accounting approximation,
not a benchmark guarantee; loading, writing and orchestration overhead are
excluded. Compare cost alongside cluster MCSE and coverage, without selecting
pairs based on whether they cover the truth.

This is a planning analysis of already examined pilot datasets. Any main study
must use new independent seeds and a protocol fixed before its own results.
Marginal coverage averages over the specified latent distribution; it does not
promise .95 coverage at each fixed ability or within each ability band. No
interval widths, corrected uncertainty, shared random-rater model, alternative
rating design, public API or release gate is established by this analysis.

## Supplementary oracle benchmark, declared during scoring

After the plan was saved and additional scoring began, but before the complete
allocation results were available, an analytic oracle benchmark was added to
the reporting specification. It does not change pair selection, scoring, or
the frozen empirical projection; those original columns remain separately
reported. This is a derived benchmark, not another fitted experiment.

For an exact oracle posterior interval C(Y),
`E[I{truth in C(Y)}] = E[P{truth in C(Y) | Y}] = .95` under the declared data
and latent distribution. Nonoverlapping pairs involve independent latent
variables/responses when calibration is held at the truth. With m such pairs
per dataset and B independent datasets, the ideal oracle coverage MCSE is
`sqrt(.95*.05/(B*m))`. Thus MCSE .005 requires at least 475, 238 and 159
datasets for m=4,8,12, respectively (64 for m=30; 32 for m=60).
All-person oracle requirements are smaller than the pair requirements here.

The allocation table adds this ideal-oracle requirement and an adjusted
equal-cell candidate obtained by taking the larger of the original empirical
candidate and the ideal-oracle requirement rounded up to 100. This prevents
an unusually small empirical oracle variance from being interpreted as a
smaller ideal sample-size requirement. It remains no guarantee of plug-in or
paired-difference precision. The analytic expression assumes exact scoring
and full availability; it does not describe oracle coverage conditioned on
successful plug-in fitting or a true-ability band.

## Recorded results, 2026-09-17

All 2,560 additional method/pair events are available. The complete pool has
2,880 events, including the 320 unchanged original four-pair events. All 5,120
additional scoring attempts are free of errors/warnings; every target resolves
at local/midpoint orders 121/81 after the initial 61/41 comparison. Eight bridge
rows and their integration histories match the saved originals exactly.

Maximum mass error is 6.127e-11, CDF change 6.447e-9, mean change 1.774e-9,
and propagated integration-error estimate 2.670e-8. The nearest coverage cutoff
is 5.298e-5 away, above the 1e-6 ambiguity limit. Sixteen saved-evidence audits
pass, including disjoint membership, original-row preservation, complete
denominators and agreement of cluster MCSE with direct dataset-mean MCSE when
all denominators are equal. An aggregation warning about recycled row names
was traced to table assembly and removed by explicitly repeating the dataset/
key rows. Aggregation then completed with warnings treated as errors. Only
aggregation was repeated; no fit or scoring attempt was rerun for that repair.

### What twelve pairs change

Each cell now contributes 120 pairs at the selected 12-pair prefix:

| N | True v | Oracle covered | Plug-in covered | Difference, percentage points | Difference MCSE, percentage points |
|---|---|---|---|---|---|
| 24 | 0 | 114/120 (95.00%) | 113/120 (94.17%) | -.83 | 1.50 |
| 120 | 0 | 111/120 (92.50%) | 112/120 (93.33%) | +.83 | .83 |
| 24 | .49 | 116/120 (96.67%) | 115/120 (95.83%) | -.83 | 1.50 |
| 120 | .49 | 116/120 (96.67%) | 115/120 (95.83%) | -.83 | .83 |

The original four-pair estimates remain unchanged, and all-person results
are copied without rescoring. Pair coverage MCSEs for oracle/plug-in at twelve
pairs are 2.55/1.78, 2.31/2.42, 1.36/1.86 and 1.36/1.39 percentage points.
The N=120/v=0 plug-in MCSE is only slightly smaller than its four-pair value
of 2.50 points; gains are not uniform or proportional to pair counts. The
zero empirical pair variances from the original pilot become nonzero at
twelve pairs. For the four paired differences, plug-in-only/oracle-only
coverage counts are 1/2, 1/0, 1/2 and 0/1. Net differences alone would conceal
these distinct gains/losses.

Adding targets changes Monte Carlo precision and the realized coverage
estimate; it does not improve an individual interval. In particular, the
oracle's observed 92.5% in cell 2 is a noisy estimate of its ideal marginal
95% property, not a demonstrated failure of the known-calibration model.
Ten dataset clusters remain too few for interval qualification or a general
sample-size conclusion. The main study must settle the coverage differences.

### Allocation decision

The [full comparison](local-testlet-pair-allocation-0.2.4-allocations.csv)
evaluates all 12 N-specific allocations. Selected examples are:

| Pairs at N=24 / N=120 | Datasets per cell | Total datasets | Uninformed metrics | Estimated serial hours |
|---|---|---|---|---|
| 4 / 4 | 700 | 2,800 | 4 | 9.82 |
| 8 / 4 | 500 | 2,000 | 2 | 8.40 |
| 8 / 12 | 400 | 1,600 | 1 | 9.09 |
| **12 / 12** | **300** | **1,200** | **0** | **7.62** |
| 12 / 30 | 300 | 1,200 | 0 | 11.30 |
| 12 / 60 | 300 | 1,200 | 0 | 17.44 |

The supplementary oracle benchmark changes none of these candidates in this
pilot. At twelve pairs, the six-metric maximum finite projection is 260/235/
156/78 by cell. The first is driven by N=24/v=0 oracle pair coverage, the
second by N=120/v=0 plug-in pair coverage. The N=24/v=.49 all-person plug-in
result drives the third cell; its person result must not be dropped merely
because the present follow-up concerns pairs.

Select **12 pairs and 300 independent datasets per cell**, the lowest observed
cost projection among the declared candidates, for the
[main protocol](local-testlet-main-coverage-0.2.4-protocol.md). Relative to the
four-pair candidate, this reduces planned calibration fits by 57% and estimated
serial time by 22%. At N=120, scoring all 60 pairs adds substantial integration
cost without reducing the common 300-dataset requirement driven by N=24.
The 7.62-hour estimate is hardware/data dependent and excludes general I/O
overhead; it does not establish an optimal allocation or guarantee MCSE .005.
Freeze new seeds and fixed stopping rules before any main-study generation.
The main study has not started in this follow-up.

### Reproduction and retained evidence

Additional scoring spans 20:12:24--20:38:59 JST; the summed additional batch
wall time is 1,588.325 seconds (26.47 minutes). No calibration was refitted,
no person rescored and no package, TAM or FairZ experiment repeated. Eight
old pair/method events were evaluated only for the bounded driver bridge.

The [portable RDS](local-testlet-pair-allocation-0.2.4-evidence.rds), about
3.40 MB, embeds the unchanged independent-pilot evidence, the frozen original
plan, supplementary analysis specification, all additional attempts, bridges,
tables and audits. CSV companions contain pair rows, scoring, timing,
dataset-level summaries, planning, cell projections and allocation comparisons.
Raw checkpoints are in `validation-results/local-testlet-pair-allocation-20260917/`.
Run `Rscript inst/validation/local-testlet-pair-allocation-0.2.4-summary.R` from
the development repository root to aggregate these checkpoints without fitting
or scoring. The RDS is inspectable without that raw directory.

Runner MD5: `278a19706a9a3a153e96055b1a162526`; aggregation MD5:
`802d910dfd78876acf3f3993ba4993d1`. Numerical source/input hashes remain unchanged
throughout scoring. R 4.6.1 on `aarch64-apple-darwin23`, parent `c90ed0f`.
No public API, package dependency or 0.2.4 release eligibility is changed.
