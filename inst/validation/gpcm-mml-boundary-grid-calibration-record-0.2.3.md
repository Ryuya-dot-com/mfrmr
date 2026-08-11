# GPCM MML boundary/grid retrospective calibration record for mfrmr 0.2.3

Status: completed Draft.70 retrospective calibration; not a positive-path
detection study, tolerance freeze, confirmation result, readiness promotion, or
release authorization

Run date: 2026-08-09 JST (completion marker: 2026-08-08 17:16:24 UTC)

## Scope and identity

The run re-estimated the exact 40 already-inspected Draft.68 datasets under the
Draft.69 runtime. Criterion/Rater slope ownership, four connectivity and range
designs, five replicates, and q=31/61/91 were retained without dataset removal,
retry, or outcome-dependent stopping. The new post-optimization instrument
enumerated the declared constant two-group sum-zero log-slope paths for the
finite fixed quadrature likelihood. Direct q91-minus-q61 comparisons covered
identified log slopes, non-Person facets, owner steps, Person EAPs, and Person
posterior SDs.

| Field | Value |
| --- | --- |
| Runtime package SHA-256 | `2a6344a815dadee12dc50eeac339e2f5774cf43cce2b86771a24aa8c132aa0e3` |
| Runner SHA-256 | `8810d40a43135b80e5545f6ecf0b03434796c11b20292b5ab830e15cffefd82e` |
| Contract SHA-256 | `befbdc663c0434f37fb51caeab0dee94bc84b177dfdf703655ebbf5bb3103d44` |
| Independent completion-validator SHA-256 | `2164b1a9fe8cddfc4acb4bfc9a2675e4c628749181b6810718a46b59ebefdc82` |
| Draft.68 source execution | `d993825cc8a58a3e3e1d17c6e4a8a6e2cc4fb16611c0429acd32296b81f70e70` |
| Draft.68 source inventory | `7b06b49da81f40768618ab814caac39fe7d2bc53fdb43421fa24c0064ce91bb4` |
| Dataset manifest SHA-256 | `a87cb82075f4f1ee3f3c977270f8fc633791075f27c0d05607bf62c97e331239` |
| Execution SHA-256 | `63a40b54a84d2c4f5c9bd9bb57deff73d1e91447dbb151cde022ce059f402ab7` |
| Completion inventory SHA-256 | `03542d2ac5b715519c769e824a0947db2b60dec339d23df5d328fb7a3a52dd6b` |
| Completion inventory | 49 files: eight aggregate CSVs, one RDS result, and 40 atomic dataset checkpoints |
| Local bundle | ignored workspace path `validation-results/gpcm-mml-boundary-grid-calibration-draft70/` |

Selected aggregate hashes are:

| Artifact | SHA-256 |
| --- | --- |
| `gpcm-mml-boundary-grid-calibration.rds` | `2ea8e2606473b5ccbe7ba1f21766113d466fc25df383ccca2693d1dfe61e4dc1` |
| `run-complete.rds` | `bd3423ae3d2533a36f09f32d782f15f71e0b8e9e8f503c2a9da2c42aa5881efc` |
| `run-results.csv` | `da6d91ebced4eb72b1963a78d96b8e1c9d56e3ec3329892a09788f08479c540d` |
| `dataset-summary.csv` | `a0e491c63e61fce35fecda3919196f27b06090527c1d23636b97af516cf15550` |
| `audit-summary.csv` | `cef94b094367ba2b151da3d8648df5996fee8accd156744c40cf909253d098f2` |
| `numeric-summary.csv` | `bfc5bcd319779a10bf756183fc721cf6755ad9ad29ee0db258bcdc80895b6102` |
| `summary.csv` | `66f821de1f968fd59c7f06195ecf3fc8be90f55007f1d1534fd617d8c6e22453` |
| `checkpoint-ledger.csv` | `e76bc3770481246d18d1440feeb3e9a9d4a41fe56ce35c3b2cb2014fe7170964` |

## Complete accounting and independent validation

- All 40 datasets, 120 q arms, and 40 checkpoints completed; every fit and
  every marginal slope-path calculation returned.
- All 120 arms had fixed-quadrature scope complete, continuous-integral scope
  false, zero likelihood-reconstruction error, and
  `none_instrumentation_only` readiness effect.
- All 120 arms had state
  `none_certified_fixed_quadrature_marginal`; no enumerated direction was
  certified. Audit state, certified direction set, and target status were
  identical across q=31/61/91 for all 40 exact datasets.
- No raw slope estimate became evidence-inference-ready. Confirmation remained
  false and every tolerance remained unfrozen.
- The Draft.69 post-optimization instrument left all Draft.68 own-grid and
  common-q91 likelihood values bit-for-bit unchanged: the maximum recorded
  difference was zero in all 40 datasets.
- The independent validator recalculated all 49 artifact hashes, rejected
  unlisted or omitted files, validated every checkpoint and ledger entry,
  reconstructed both 120-row and 40-row aggregates, regenerated the frozen
  manifest, matched all retained-data hashes and likelihood differences to
  Draft.68, and rechecked non-confirmation protection.

The zero positive count is a negative-case result, not evidence that finite
slope maxima exist. The sufficient path condition is intentionally narrow and
may fail to certify a real recession direction. With no positive ordinary
case, this panel gives no estimate of positive-path sensitivity, false-negative
behavior, or q-grid stability conditional on certification.

## Direct q61-to-q91 calibration

The table reports the maximum over five replicates in each owner/design cell.
Values are descriptive raw-scale differences. `EAP` and `PSD` columns are
RMSEs; the structural columns are maximum absolute coordinate differences.

| Owner | Design | q61 common-q91 regret | log slope | facet | step | EAP RMSE | PSD RMSE |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Criterion | core | 0.000487 | 0.00116 | 0.000591 | 0.00173 | 0.00437 | 0.00699 |
| Criterion | range restricted | 0.000399 | 0.00249 | 0.000854 | 0.00288 | 0.00454 | 0.00671 |
| Criterion | weak bridge | 0.000125 | 0.00258 | 0.00137 | 0.00464 | 0.00106 | 0.000973 |
| Criterion | zero shared | `1.02e-12` | `1.80e-8` | `1.62e-8` | `3.52e-8` | `8.84e-9` | `7.91e-9` |
| Rater | core | 0.000341 | 0.00142 | 0.000694 | 0.00167 | 0.00430 | 0.00662 |
| Rater | range restricted | 0.00147 | 0.00384 | 0.00285 | 0.00530 | 0.00552 | 0.00790 |
| Rater | weak bridge | 0.000342 | 0.00619 | 0.0132 | 0.0553 | 0.00262 | 0.00137 |
| Rater | zero shared | `5.24e-7` | 0.000149 | 0.000152 | `9.96e-5` | `6.56e-5` | `4.09e-5` |

Across all 40 datasets, the maxima were 0.001471 common-q91 regret, 0.00619
log-slope change, 0.0132 facet change, 0.0553 step change, 0.00552 EAP RMSE,
0.00966 maximum absolute EAP change, 0.00790 posterior-SD RMSE, and 0.0147
maximum absolute posterior-SD change. The most visible structural sensitivity
was rater-owned weak-bridge step estimation; the largest common-grid regret and
EAP/PSD RMSE occurred in rater-owned range restriction. Core posterior
summaries remained more node-sensitive than the structural coordinates.

These results support q=61 as a useful dense comparison grid for this exact
panel, but not as a universal default or equivalence threshold. The five
replicates were previously inspected, no sampling uncertainty beyond cell MCSE
was used to set tolerances, and q=91 itself was not established as the
continuous-integral limit. Near-zero zero-shared differences reflect the fixed
common-population assumption and do not repair design identification.

## Gate consequences and next design

No release checklist row becomes `ok`; no slope, facet, step, EAP, posterior-
SD, or likelihood tolerance is frozen. The next boundary/grid lane must be
prospective and use untouched seeds with three separately labelled strata:

1. positive constructed controls that satisfy the sufficient two-group path
   condition, including near-boundary margins and q=31/61/91;
2. negative ordinary controls and adversarial cases where the sufficient test
   is silent despite challenging optimization geometry; and
3. a fresh owner/design panel for direct q61-to-q91 structural and Person
   differences, with its candidate rule fixed before outcomes are opened.

Readiness propagation should be tested only after positive and negative
classification behavior is established. Estimator recovery/coverage, JML-MML
attribution, fit statistics, and DFF operating characteristics remain separate
claim families with their own sample-size, sparsity, failure-denominator, and
uncertainty contracts.
