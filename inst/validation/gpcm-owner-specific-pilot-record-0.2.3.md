# Owner-specific GPCM calibration-pilot record for mfrmr 0.2.3

Status: completed `0.2.3-draft.66` calibration pilot; not confirmation,
threshold freeze, external validation, or release authorization

Run date: 2026-08-08 JST (completion marker: 2026-08-07 18:41:09 UTC)

## Scope and identity

The run executed all 120 prespecified rows: criterion-owned and rater-owned
aligned single-owner GPCM, JML and MML, six design conditions, and five
replicates per cell. The primary controls were `maxit = 400` and 31-point
Gaussian--Hermite quadrature. All score supports were retained with
`keep_original = TRUE`. Confirmation remained unauthorized.

| Field | Value |
| --- | --- |
| Validation source base commit | `7ee1fd5cb9cb3ab6588811eb4b31f3337076c369`; dirty development worktree, so the content identities below are authoritative |
| Runtime package | mfrmr 0.2.3 temporary installation; R 4.6.1, aarch64-apple-darwin23 |
| Runtime package SHA-256 | `ebd9e8eb219ece646adfd37301eba997392637749513191ca7c52d33ce77356d` |
| Runner SHA-256 | `b71ee33aa39d07431f43505d70dc531f0abb9db2529ff9a433ea74b4b1dbfb16` |
| Model-identity contract SHA-256 | `08c906508f2fb6cbbee8f2ba6f8c985105e45a31336e4355809d96f83e91f7aa` |
| Execution contract SHA-256 | `54d52c6a05b3fe98c0d19b54a66df8c8a83b21785f63a2300495f415f7733879` |
| Declared-manifest SHA-256 | `06ed7b7a1faa054e528adf2caa97c2e314ed22b9bc7ca47cd0f815b8998c3857` |
| Row manifest hash | `5e7bf32fdb1764c554e735709d8a9c8b841efa91956c7250f5a0307266ba2114` |
| Global execution SHA-256 | `f96895c9325e15390c5fd896a687a47cf786f6b4f71af94c3481753991e38037` |
| Completion schema | `mfrmr-gpcm-owner-completion-v1` |
| Completion inventory SHA-256 | `d8344b2bb351fbc7fc297371e6eba32acb933ee6c602f30053ee30f40bbe4a7e` |
| Full execution wall time | 209.7 seconds; this is one local scheduling trace, not a performance criterion |
| Local bundle | ignored workspace path `validation-results/gpcm-owner-specific-pilot-draft66/` |

The completion marker inventories 130 retained files: ten aggregate artifacts
and 120 one-row checkpoints. Selected aggregate hashes are:

| Artifact | SHA-256 |
| --- | --- |
| `declared-manifest.csv` | `1291e5a83562801aad88d768272d4109b37534a2bb5bb6263432071dec2d98e1` |
| `run-results.csv` | `8b699374592886cda15d7a35be9b41b43911b721549511842aceb6812fe832fc` |
| `summary.csv` | `2a376188c92b99854da0b20aa74dacd3828f6063c43f80b932ea10cd873ddb2f` |
| `rate-summary.csv` | `b528a4349df7bb869738a0d229b24cd47c18702d6ac87e9d439dfaf407c69555` |
| `numeric-summary.csv` | `ba0df90785fdfba5f5840a3a73f2de01c568e6a4d245824746039fa5ef5c2729` |
| `execution-identity.csv` | `084836ddc3f8ef7dda92851bbae51610ca3086025b995b39c86629a8dee9ef37` |
| `checkpoint-ledger.csv` | `82add7772f89f5f65870cd38beac4da096d887b129b342c0432023b9552923e4` |
| `gpcm-owner-specific-pilot.rds` | `2355b6f023fa5641261cf2f8bae51b3bd09eb94ad38bb7527ae17201b06e30bd` |

## Draft.65 defect and correction

The first complete Draft.65 run found that the intended `internal_zero`
challenge was generated with observed scores 1/3/4 but fitted under
`keep_original = FALSE`. The estimator therefore recoded the observations to
1/2/3. The evidence-layer support guard still blocked the result, but the fit
did not exercise the declared internal-category gap. Those 20 cells, and the
Draft.65 bundle as a promotion unit, are superseded.

Draft.66 fixes `keep_original = TRUE` and changes the execution identity.
Every one of the 20 corrected internal-zero rows now stops before optimization
with the typed unsupported-internal-category step-recession error. Draft.65
fitted 19 of those 20 rows; Draft.66 fits zero. For the other 100 rows, all 52
non-identity result fields are exactly equal between Draft.65 and Draft.66.
This isolates the correction to the declared category-support contract without
silently relabelling the earlier output.

## Complete accounting

- 120/120 rows executed and 120/120 checkpoints validated.
- 88/120 fits returned fitted objects; 32 failures remain in every denominator.
- Thirty rows were prespecified fail-closed controls: all 20 internal-zero
  rows and all ten zero-common-Person JML rows.
- Ten zero-common-Person MML rows returned fitted objects but remained guarded
  negative controls linked to the latent-population assumption.
- Two additional JML rows failed optimization: criterion-owned weak-bridge
  replicate 3 and rater-owned workload-imbalance replicate 4. Both reported
  non-finite/non-positive expanded slopes after log-scale identification.
- Model-identity violations: 0. Raw inference-ready rows: 0. Evidence
  inference-ready rows: 0. Raw false-ready rows: 0. Final false-ready rows: 0.
- Of the 120 raw readiness states, 83 were `review`, five were `blocked`, and
  32 were unavailable because no fitted object existed. The dominant open
  reasons are incomplete JML joint-boundary or MML slope-boundary audits and
  unevaluated design-rank state. Numerical fit success is therefore not a
  gate pass.

With five planned rows per cell, even 5/5 fit success has a 95% Wilson lower
bound of 0.566; 4/5 has interval [0.376, 0.964], and 0/5 has upper bound 0.434.
These intervals prohibit interpreting the observed proportions as stable
operating characteristics.

## Optimizer-slope recovery traces

The table reports centered log-slope RMSE from finite optimizer estimates.
It is not primary-parameter or interval-coverage evidence. `Fit` retains the
five-row denominator; MCSE is `SD / sqrt(finite count)`.

| Owner | Estimator | Design | Fit | Mean RMSE | MCSE |
| --- | --- | --- | ---: | ---: | ---: |
| Criterion | JML | core | 5/5 | 0.073 | 0.012 |
| Criterion | JML | internal zero | 0/5 | -- | -- |
| Criterion | JML | range restricted | 5/5 | 0.166 | 0.030 |
| Criterion | JML | weak bridge | 4/5 | 4.843 | 0.117 |
| Criterion | JML | workload imbalance | 5/5 | 0.093 | 0.014 |
| Criterion | JML | zero shared Person | 0/5 | -- | -- |
| Criterion | MML | core | 5/5 | 0.075 | 0.011 |
| Criterion | MML | internal zero | 0/5 | -- | -- |
| Criterion | MML | range restricted | 5/5 | 0.095 | 0.008 |
| Criterion | MML | weak bridge | 5/5 | 0.211 | 0.026 |
| Criterion | MML | workload imbalance | 5/5 | 0.069 | 0.012 |
| Criterion | MML | zero shared Person | 5/5 | 0.217 | 0.021 |
| Rater | JML | core | 5/5 | 0.085 | 0.010 |
| Rater | JML | internal zero | 0/5 | -- | -- |
| Rater | JML | range restricted | 5/5 | 0.141 | 0.025 |
| Rater | JML | weak bridge | 5/5 | 0.691 | 0.360 |
| Rater | JML | workload imbalance | 4/5 | 0.130 | 0.014 |
| Rater | JML | zero shared Person | 0/5 | -- | -- |
| Rater | MML | core | 5/5 | 0.084 | 0.014 |
| Rater | MML | internal zero | 0/5 | -- | -- |
| Rater | MML | range restricted | 5/5 | 0.114 | 0.019 |
| Rater | MML | weak bridge | 5/5 | 0.410 | 0.124 |
| Rater | MML | workload imbalance | 5/5 | 0.093 | 0.021 |
| Rater | MML | zero shared Person | 5/5 | 0.249 | 0.023 |

Core and workload-imbalance traces are small in this limited design, but that
does not establish a threshold. Weak linkage is the dominant recovery risk:
criterion-owned JML is grossly unstable, rater-owned JML has a wide finite
range, and both MML owner strata degrade relative to core. Range restriction
also degrades both JML strata. The owner and estimator rows use distinct seeds
and are not a paired causal attribution design, so their numerical differences
must not be interpreted as proof that one owner or estimator is intrinsically
better.

## Gate consequences and next work

No checklist row, numeric recovery rule, minimum sample-size rule, fit or DFF
cutoff, owner-consistency interpretation, or confirmation state is promoted.
The owner-evidence-partition and rater-category-support checklist rows move
from `not_run` to `review` because pilot evidence now exists; neither becomes
`ok`, and both retain `pilot_required` criteria.
Draft.67 completes the first item below in
`gpcm-owner-jml-optimizer-attribution-record-0.2.3.md`: both failed rows are
retained after typed line-search rejection, the workload path is a numerical
trial-step accident, and criterion weak bridge remains a convergence-failed
boundary-risk path. Draft.67 refines the remaining order:

Draft.68 also completes the first fixed q=31/61/91 sensitivity run in
`gpcm-mml-integration-sensitivity-record-0.2.3.md`. It rejects q=31 as an
integration-sufficiency certificate and leaves direct q61-to-q91 parameter
tolerance calibration for the expanded-replication design. The active order is
now:

1. complete the joint weak-link Person--additive--slope geometry rather than
   tuning optimization until a desired status appears;
2. add a paired common-data owner/estimator attribution lane before making an
   owner or estimator contrast;
3. add facet-location, step, Person-estimand, interval-coverage, and failed-row
   consequence metrics rather than gating on optimizer slopes alone;
4. expand replication based on the observed MCSE, especially the weak-bridge
   strata, and add direct q61-to-q91 parameter contrasts before freezing any
   recovery or integration margin; and
5. keep fit, uniform/nonuniform DFF, dimensionality, response style, and local
   dependence in separate operating-characteristic lanes.

The next specification may calibrate additional pilot work from these signals.
It may not inspect confirmation seeds or turn any five-replicate observation
into a frozen release threshold.
