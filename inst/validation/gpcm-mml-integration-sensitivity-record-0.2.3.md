# GPCM MML integration-sensitivity record for mfrmr 0.2.3

Status: completed Draft.68 calibration sensitivity; not a quadrature-tolerance
freeze, estimator ranking, confirmation result, or release authorization

Run date: 2026-08-09 JST (completion marker: 2026-08-08 15:52:22 UTC)

## Scope and identity

The run used 40 exact owner-pilot datasets: Criterion/Rater slope ownership,
core/weak-bridge/range-restricted/zero-common-Person designs, and five
replicates per cell. Every dataset was fitted at q=31, q=61, and q=91 with
direct fixed-standard-normal MML, `optimizer = "auto"`, `maxit = 400`, the
aligned single-owner GPCM likelihood, and unchanged starting values. Candidate
parameters from all grids were also evaluated on a common q=91 grid.

| Field | Value |
| --- | --- |
| Runtime package SHA-256 | `31c87d7a888ca760afa02476f1c226bae148403475e34b75eefaaa9679522920` |
| Runner SHA-256 | `dc7033becb3fa32a139bb1d633ad01aa848dee9f7261fa58589040436340ae93` |
| Contract SHA-256 | `3d06813271bafbc0b8a6f33d37f237b1a0a7f3e2f2b9bd4c017434fdee35e06a` |
| Independent completion-validator SHA-256 | `94402103a41e7461f4d419ca68dafc87070b809bf043117649af65b8dbb80f8a` |
| Owner runner SHA-256 | `b71ee33aa39d07431f43505d70dc531f0abb9db2529ff9a433ea74b4b1dbfb16` |
| Model-identity contract SHA-256 | `08c906508f2fb6cbbee8f2ba6f8c985105e45a31336e4355809d96f83e91f7aa` |
| Source owner execution | `f96895c9325e15390c5fd896a687a47cf786f6b4f71af94c3481753991e38037` |
| Source owner RDS SHA-256 | `2355b6f023fa5641261cf2f8bae51b3bd09eb94ad38bb7527ae17201b06e30bd` |
| Dataset manifest SHA-256 | `316db2a3670abc063e88447dc5cfaf8f42ce646c5994be95c8a1cbef8baff318` |
| Execution SHA-256 | `d993825cc8a58a3e3e1d17c6e4a8a6e2cc4fb16611c0429acd32296b81f70e70` |
| Completion inventory SHA-256 | `7b06b49da81f40768618ab814caac39fe7d2bc53fdb43421fa24c0064ce91bb4` |
| Completion inventory | 48 files: seven aggregate CSVs, one RDS result, and 40 atomic dataset checkpoints |
| Local bundle | ignored workspace path `validation-results/gpcm-mml-integration-sensitivity-draft68/` |

Selected aggregate hashes are:

| Artifact | SHA-256 |
| --- | --- |
| `dataset-manifest.csv` | `8e4fc8592b6fe495c3bf7c01c6b9f0d471a2d1ba1b0ef0abb73d60d0515daf22` |
| `run-results.csv` | `39e7cb7318b78c21ab929b19c064a69c697a35263686d6840c027a42c3753809` |
| `numeric-summary.csv` | `32ba9d606df1ae2c030b3e0000665d7c8bec8ad64cae9339325a6fe3164ecad6` |
| `rate-summary.csv` | `4eb343f391523efbb791fde48257c6e0486bdf1467b6888e3c6f295473d1e499` |
| `summary.csv` | `c66796c4220a24eab344a580a0f48f416f0a32a6ded6adace64d878032efa0e0` |
| `execution-identity.csv` | `695b83b8b2bcb350f34cefa6ef92499e71d80e6612d924fdf6103339a6a8483f` |
| `checkpoint-ledger.csv` | `d4ddc0146f2c614c18957e8eec907b5e63bb7769d0e08de16542570e2b8e66fb` |

## Complete accounting

- All 40 datasets, 120 fit arms, and 40 checkpoints completed.
- All 120 arms returned fitted objects; no slope numeric-boundary proposal was
  rejected in this MML panel.
- 113/120 arms passed the optimizer-gradient gate. Seven code-zero fits
  remained review because their terminal gradient exceeded the common
  tolerance: two at q=31, four at q=61, and one at q=91. More nodes therefore
  did not monotonically improve numerical convergence.
- Raw and evidence inference-ready counts remained zero. All 30 zero-shared
  arms were explicitly blocked at the evidence layer despite numerical fit
  success; the other 90 remained review under the unfinished MML slope-boundary
  contract.
- Every retained-data SHA-256 appeared exactly three times, proving exact
  q-grid pairing.
- A separately sourced completion validator recomputed every listed artifact
  hash, rejected extra or omitted files, regenerated the frozen 40-row
  manifest, validated all 40 checkpoint payloads, and recovered the exact
  31/61/91 ordering and within-dataset data hashes.

## Common q=91 likelihood sensitivity

The table gives mean and maximum q=91 negative-log-likelihood regret relative
to the best of the three fitted candidates for each exact dataset. Smaller is
better; these are raw log-likelihood units, not normalized effect sizes or a
frozen tolerance.

| Owner | Design | q=31 mean / max | q=61 mean / max |
| --- | --- | ---: | ---: |
| Criterion | core | 0.0231 / 0.0428 | 0.000284 / 0.000487 |
| Rater | core | 0.0576 / 0.1597 | 0.000266 / 0.000341 |
| Criterion | range restricted | 0.0251 / 0.0602 | 0.000243 / 0.000399 |
| Rater | range restricted | 0.1497 / 0.5443 | 0.000552 / 0.001471 |
| Criterion | weak bridge | 0.00114 / 0.00300 | 0.000029 / 0.000125 |
| Rater | weak bridge | 0.00842 / 0.0281 | 0.000115 / 0.000342 |
| Criterion | zero shared | approximately 0 | approximately 0 |
| Rater | zero shared | 0.000933 / 0.00355 | below `5.24e-7` |

At the common q=91 evaluation, q=91 supplied the best candidate in every
ordinary cell; zero-shared differences were floating-point-scale ties. q=61
was much closer to q=91 than q=31 in objective value, with maximum regret
0.001471. This does not prove that q=91 is exact or that q=61 and q=91 yield
equivalent parameters.

## Estimand sensitivity relative to q=31

Across q=91 arms, the largest observed changes from q=31 were:

- identified expanded log slope: 0.0914;
- non-Person facet location: 0.1424;
- owner-step parameter: 0.6011;
- Person EAP RMSE: 0.0745, with maximum absolute Person change about 0.123;
  and
- Person posterior-SD RMSE: 0.0591, with maximum absolute change about 0.087.

The largest common-grid regret, log-slope change, and EAP RMSE all occurred in
rater-owned range-restricted replicate 5, while the largest step change
occurred in rater-owned weak bridge. Core q=31-to-q=91 EAP RMSE was still about
0.041 for both owners; increasing the nominal Person count to 120 therefore
did not make Person posterior summaries integration-insensitive.

The q=61 and q=91 changes relative to q=31 were usually similar in direction
and scale, while q=61 common-grid regret was small. Because this run retained
only q-to-q31 parameter contrasts, it does not claim a direct q61-to-q91
parameter tolerance. A later frozen rule would need that direct comparison and
independent seeds.

## Interpretation for likelihood method, sparsity, and sample size

This result strengthens four distinctions:

1. MML integration error is a separate numerical dimension from optimizer
   convergence. q=61 produced more gradient-review fits than either q=31 or
   q=91 even though its common-grid likelihood was far closer to q=91.
2. Person EAP and posterior SD are more node-sensitive than the structural
   objective alone suggests. A tiny common-grid regret cannot be used as a
   universal proxy for Person-estimand stability.
3. Sparse and range-restricted designs can amplify sensitivity, but the
   pattern depends on which facet owns slopes and steps. No scalar “sparse
   data” adjustment or owner ranking follows from these five replicates.
4. Zero-common-Person MML stability is not evidence of design identification.
   It reflects the fixed common-population integration assumption and remains
   blocked for cross-panel owner claims.

The run also cannot be used to rank MML against JML: MML integrates a declared
Person distribution, while JML estimates Person effects and has different
incidental-parameter and recession geometry. Own-grid AIC/BIC values across q
are not substituted for the common-grid evaluation.

## Gate consequences and roadmap refinement

q=31 remains a documented *selection starting grid*, not an integration-
insensitivity certificate. The observed common-grid and Person-estimand
differences are too large to freeze q=31 as sufficient for the current GPCM
claim portfolio. q=61 is promising as a dense sensitivity grid on the common
objective, but no public default or tolerance changes from this five-replicate
calibration.

No checklist row becomes `ok`, no numerical cutoff is frozen, no zero-shared
claim is promoted, and confirmation remains unauthorized. The next sequence
is:

1. add direct q61-to-q91 parameter contrasts and prospective tolerances to the
   expanded-replication design before confirmation;
2. complete MML marginal slope-boundary propagation so finite optimizer values
   can become primary only when geometry permits;
3. build the paired owner/estimator attribution lane with estimator-specific
   likelihood and Person-estimand reporting;
4. add coverage for facets, steps, slopes, EAPs, and posterior uncertainty;
   and
5. keep fit and DFF operating-characteristic calibration separate from
   integration stability.
