# TAM MML density diagnostic record for mfrmr 0.2.4

Status: `integration mechanism supported; release remedy still required`,
2026-09-06. This post-result diagnostic reuses all 21 dataset identities from
the retained q31/q61 failure. It does not replace, relax, or reclassify the
frozen 12/42 pair and 6/21 integration result.

## Bound execution

| Field | Value |
| --- | --- |
| Contract | `mfrmr_tam_mml_density_diagnostic_v1` |
| Source commit | `1b1e15265da7a2ca8582ad78f14b09f3dd29d18c` |
| Reused dataset identities | 21/21 |
| q-specific comparisons | 42: q121 and q181 for every dataset |
| Execution errors | 0 |
| q121 pair rules passed | 15/21 |
| q181 pair rules passed | 17/21 |
| q121-to-q181 stability rules passed | 21/21 |
| Changes frozen q31/q61 result | `FALSE` |
| Release authorized | `FALSE` |

Across every dataset, the maximum q121-to-q181 movement stayed below the
existing `1e-3` review bound:

| Metric | Maximum movement |
| --- | ---: |
| mfrmr deviance | `7.237271e-4` |
| TAM deviance | `3.397484e-5` |
| mfrmr cumulative-difficulty surface | `1.090376e-5` |
| TAM cumulative-difficulty surface | `6.483461e-7` |
| mfrmr EAP | `3.986841e-5` |
| TAM EAP | `6.083834e-6` |
| mfrmr posterior SD | `9.219072e-5` |
| TAM posterior SD | `1.399091e-5` |
| mfrmr estimated population mean | `4.362010e-5` |
| mfrmr estimated population variance | `2.770028e-6` |

The fixed baseline, MCAR, sparse-Rater, and weak-exposure q181 comparisons all
passed except the three forced-extreme datasets. Both estimated-population
baseline comparisons passed at q121 and q181; one estimated weak-exposure seed
remained just outside the posterior-SD bound.

## Tail-range mechanism probe

The four q181 pair failures were rechecked at q241 and q301 with TAM's retained
`[-6,6]` node range. Their small differences plateaued rather than shrinking:
the three forced-extreme q301 deviances differed by approximately
`0.000206`--`0.000363`, and the estimated weak-exposure posterior-SD difference
was `0.000125`. This pattern is inconsistent with node density alone.

Two representative q301 fits were then repeated without changing the data,
model, fixed/estimated population mode, optimizer, or comparison bound; only
the TAM node range was widened.

| Dataset | TAM node range | deviance difference | surface difference | EAP difference | posterior-SD difference |
| --- | --- | ---: | ---: | ---: | ---: |
| fixed / extreme replicate 1 | `[-6,6]` | `2.89705486e-4` | `3.02818744e-6` | `5.18658263e-5` | `1.31354001e-4` |
| fixed / extreme replicate 1 | `[-7,7]` | `4.16687726e-7` | `6.34997158e-7` | `5.92382525e-8` | `3.61713784e-7` |
| fixed / extreme replicate 1 | `[-8,8]` | `1.91903382e-10` | `6.22468740e-7` | `4.13028660e-8` | `2.61072255e-9` |
| estimated / weak replicate 3 | `[-6,6]` | `2.93706842e-5` | `8.49987452e-6` | `6.15697072e-5` | `1.25364180e-4` |
| estimated / weak replicate 3 | `[-7,7]` | `1.81003998e-7` | `5.87649391e-7` | `5.47885697e-7` | `1.33908017e-6` |
| estimated / weak replicate 3 | `[-8,8]` | `5.42058842e-10` | `4.84046589e-7` | `1.51216827e-7` | `9.54556179e-9` |

The remaining high-q cross-engine failures are therefore explained by TAM's
finite tail range, not by a demonstrated difference in mfrmr's RSM likelihood,
facet coordinate map, or full-normal Gauss-Hermite target. These tail probes
are mechanism evidence, not new confirmation passes.

## Interpretation and next action

The evidence now distinguishes three matters:

1. The mfrmr and TAM RSM MML targets agree when integration density and TAM's
   finite tail range are adequate.
2. The current mfrmr q31 default is not numerically stable for the retained
   24--30-response Person patterns; q61 is also insufficient there.
3. No universal fixed q follows from these five profiles. Hard-coding q181 as
   a new default would move the failure boundary without solving the general
   problem.

The smallest truthful 0.2.4 remedy is therefore not a blanket default increase
or TAM compatibility mode. The package needs an RSM/PCM same-data quadrature
sensitivity route and a fail-closed portable-calibration rule that does not
freeze a source fit whose fit-time integration has not been shown stable for
its data. Any automatic cutoff must be justified independently; the present
`1e-4` is an external engineering comparison bound, not a user decision rule.

Because the issue arises from Person-pattern concentration rather than RSM
step sharing, the conditional PCM stress lane remains required after the
remedy is specified. `population_formula = ~1` remains fitted-object-only and
`design_rank_not_evaluated`; the numerical overlap does not promote it.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `tam-mml-density-diagnostic-0.2.4.R` | `e79a044038af8d5854054f728ba3df1343e88f69a9d277a315fbc700c9c14d90` |
| `tam-mml-density-diagnostic-plan-0.2.4.csv` | `05116c7eb64022de5e5952aaacb0358fb978ed5fab2834dadb0c553451c3caa9` |
| `tam-mml-density-diagnostic-summary-0.2.4.csv` | `674b01923c9119522ff578447a936225f8c27c02e4f124221042a757b379167b` |
| `tam-mml-density-diagnostic-surface-0.2.4.csv` | `1d68b0e49844131adc89486b711bc55bba2b4671e1fde6a129677266aaa227a1` |
| `tam-mml-density-diagnostic-score-0.2.4.csv` | `5522f1746673a0340accda662df62d9618d170b0a3c1d21815a61f7598e7321e` |
| `tam-mml-density-diagnostic-integration-0.2.4.csv` | `502250974e3c2f4c5142fcf167c78870ac552c6f6cc9ebfdc78505b97def8dc9` |

