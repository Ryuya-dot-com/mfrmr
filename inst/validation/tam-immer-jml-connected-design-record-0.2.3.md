# Connected-assignment TAM/immer/mfrmr JML smoke record for mfrmr 0.2.3

Status: Draft.78 repository-only structural-feasibility record,
2026-08-09.

## Execution and exact accounting

The 18-profile x RSM/PCM deterministic smoke was run from the current
development tree using `pkgload::load_all()` and the frozen Draft.78 manifest.
All expected states matched:

| State | Datasets | Retained method rows |
| --- | ---: | ---: |
| Connected design; nine modes attempted | 30 | 270 |
| Structurally unidentified before optimization | 6 | 0 |

The result contains 4,998 metric rows, all with `EvidenceReady = FALSE`.
`ContractPassed` is `TRUE`. The ignored local bundle is
`validation-results/draft78-tam-immer-jml-connected-smoke-20260809/`.

The final artifact identities are:

| Artifact | SHA-256 |
| --- | --- |
| Aggregate RDS file | `6e66a461a5fa34ea68c2c367856bfccdedb2f29d118832f78b3581f533c26da3` |
| Serialized result object | `e0d794a987af335fadf45802ca2108920787045333034dcaf09589ed84c97fe0` |
| Manifest CSV | `7da58dd448bc3e8523b4529b7dc58b6fa6b68163485864460830c0a037a33e04` |
| Dataset-state CSV | `00bf3090d88e30de62ccf293b9a4236fcf2fc95d20e21648f712fdf8eee4a323` |
| Graph-audit CSV | `b167ba01865f87947b241f82b6a79f24e1473e7a7e1214c7e69078c0a8b612da` |
| Mode CSV | `a35c325905ee4a9505ccec210b5eab60a3d74489f0355e37eb7b6686b9c31ea0` |
| Metric CSV | `02ebd8652ac53780d04e96645535f083909bb520188e3a0cd925da0ebb34d518` |

A prior complete execution produced the same manifest, dataset-state,
graph-audit, and metric hashes. The mode hash changed because mode rows retain
elapsed wall time; it is not treated as a deterministic numerical identity.
Draft.78 is a short smoke and does not yet have the Draft.77 per-dataset
checkpoint/replay contract.

The runtime was R 4.6.1 on `aarch64-apple-darwin23`, with mfrmr 0.2.3,
TAM 4.3.25, and immer 1.5.13. The loaded primary-function hashes were:

- mfrmr `fit_mfrm`:
  `ffa3802190772b30c04f2d1afe3e6a58968248e2c0981a32da5185b75a98582e`;
- TAM `tam.jml`:
  `7b131ddd1d333673cc3103e7d24178afb8e86781d95e2947c4c00a877c725386`;
- immer `immer_jml`:
  `31163e6eedba375989dbd14f7d4b270a9379839fddde25be43c5ee997a09692b`.

## Bridge rate is not bridge information

The constructed graph results were identical for RSM and PCM because the
assignment topology is model-independent:

| Profile | Bridge Persons | Mean degree | Density | Components | Minimum shared Persons on an edge | Weighted algebraic connectivity |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 120 Persons, 0% bridge | 0 | 1.000 | 0.1250 | 8 | 0 | 0 |
| 120 Persons, 5% bridge | 6 | 1.050 | 0.1313 | 2 | 1 | 0 |
| 60 Persons, 10% bridge | 6 | 1.100 | 0.1375 | 2 | 1 | 0 |
| 120 Persons, 10% bridge | 12 | 1.100 | 0.1375 | 1 | 1 | 0.7511 |
| 60 Persons, 20% bridge | 12 | 1.200 | 0.1500 | 1 | 1 | 0.7511 |
| 480 Persons, 2.5% bridge | 12 | 1.025 | 0.1281 | 1 | 1 | 0.7511 |
| 120 Persons, 25% bridge | 30 | 1.250 | 0.1563 | 1 | 3 | 2.0636 |
| 120 Persons, 50% bridge | 60 | 1.500 | 0.1875 | 1 | 7 | 4.3665 |

The three six-bridge RSM/PCM negative-control profiles stopped at the mfrmr
structural-rank audit as planned. For example, `BRIDGE_B005` was rank 131 of
132 with nullity one; optimization was not run.

The three 12-bridge positive constructions have the same edge weights and the
same algebraic connectivity despite Person counts of 60, 120, and 480. Adding
Persons who are each seen by only one Rater adds within-Rater information but
does not strengthen the cross-Rater links. Consequently, neither total Person
count nor bridge percentage alone can support a design recommendation. The
absolute bridge count, allocation topology, shared-Person multiplicity, and
Rater count must be declared.

This does not establish 12 as an adequate bridge count. It only establishes
connectedness for this cyclic construction. A connected graph with minimum
edge weight one and algebraic connectivity 0.7511 remains a weak-link design.

## Missingness can change the graph

The assigned 25% bridge profiles all had 150 Person-Rater pairs, 30 bridge
Persons, and algebraic connectivity 2.0636. After 30% response-level
missingness:

| Mechanism | Observed Person-Rater pairs | Realized bridge Persons | Components | Minimum shared Persons | Algebraic connectivity |
| --- | ---: | ---: | ---: | ---: | ---: |
| Rater-MAR | 148 | 28 | 1 | 2 | 1.8066 |
| MCAR | 150 | 30 | 1 | 3 | 2.0636 |
| Score-MNAR | 150 | 30 | 1 | 3 | 2.0636 |

For these seeds, Rater-MAR removed all Criterion responses from two complete
Person-Rater blocks but did not disconnect the graph. MCAR and score-MNAR did
not erase an entire block. This is one deterministic realization, not evidence
that MCAR or MNAR preserves connectedness generally. Both assigned and
observed graphs remain required in the replicated design.

## Density and Rater count remain conditional contrasts

At fixed degree two and 120 Persons, changing from 4 to 8 to 12 Raters changed
density from 0.50 to 0.25 to 0.1667, minimum shared Persons per edge from 30 to
15 to 10, and algebraic connectivity from 60.0 to 8.79 to 2.68. This combines
more Rater parameters, lower density, and thinner cross-Rater links.

At fixed density 0.50, the 4/2, 8/4, and 12/6 Rater/degree designs instead
raised exposure while increasing Rater count. Their algebraic connectivity was
60.0, 137.57, and 210.72. This is not contradictory; it is a different
conditional slice. Neither sequence identifies an isolated Rater-count main
effect.

The workload targets are assignment-sampling pressure, not achieved max/min
ratios. The target-4 profile realized Gini 0.233 and max/min 4.82; target-12
realized Gini 0.364 and max/min 8.00. Later analyses must use these realized
diagnostics rather than relabel the targets as observed imbalance.

## Method availability and natural extreme Persons

Natural all-minimum/all-maximum Persons occurred in 20 of the 30 connected
datasets. Low exposure therefore creates the JML boundary problem even without
forced extremes. Method accounting was:

| Mode | Returned / 30 | Engine-labelled numerical convergence | Evidence-eligible |
| --- | ---: | ---: | ---: |
| mfrmr raw | 30 | 30 | 10 |
| mfrmr extended profile | 30 | 30 | 30 |
| TAM raw | 9 | 0 | 9 |
| TAM adjusted | 30 | 8 | 30 |
| TAM classical correction | 9 | 0 | 9 |
| TAM adjusted + classical | 30 | 8 | 30 |
| immer `jml` | 30 | 30 | 10 |
| immer `eps_adj` | 30 | 30 | 30 |
| immer `jml_bc` | 30 | 30 | 30 |

The TAM convergence counts are only the prespecified `iter < maxiter` proxy;
most adjusted fits reached the 500-iteration smoke ceiling. They are not
evidence of score-equation failure or success. TAM raw/classical were blocked
by natural extreme Persons in 20 cells and returned on nine of the ten
no-extreme cells. The remaining no-extreme PCM `FIXDEG_R12_D2` row retained
TAM's native `missing value where TRUE/FALSE needed` error.

TAM classical factors ranged 0.9375--0.97917 and immer factors
0.70443--0.95833. The wider difference arises from different effective-item
definitions under sparse and missing assignments. No factor is selected. A
classically postscaled point remains distinct from the original JML maximizer.

Common-surface 95% SE coverage and definition-matched reported facet
separation have zero eligible rows. The single-replicate bias, RMSE, rank, and
recovery-separation values are retained for debugging only and are not used to
rank methods or recommend a design.

## What Draft.78 changes, and what it does not

Draft.78 closes the immediate design bug in Draft.77: low exposure can now be
studied without automatically making Rater contrasts structurally
unidentified. It also makes the graph a first-class part of the ADEMP design
rather than an after-the-fact diagnostic.

It does not establish an adequate bridge rate, adequate sample size, algebraic-
connectivity threshold, correction, estimator winner, convergence threshold,
coverage result, facet-separation result, or release decision.

The next replicated topology calibration must compare chain, cycle, balanced,
and concentrated/hub bridge allocations at matched bridge counts; retain
articulation-point and graph-edge vulnerability; add Draft.77-style atomic
checkpoints; and freeze Monte Carlo precision before performance results are
inspected. Only after the additive RSM/PCM topology and uncertainty lanes are
calibrated may this design be transferred, separately, to Criterion-owned and
Rater-owned GPCM.
