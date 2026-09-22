# Paired PCM/GPCM JML calibration record for 0.2.3

Status: **completed calibration; non-promoting**

Run date: 2026-08-13

Source revision at execution: `771054e`

Specification: `0.2.3-draft.1`

Contract: `mfrmr_pcm_gpcm_jml_paired_calibration_v1`

## Question and fixed scope

This calibration asks what the new PCM-versus-GPCM comparison contract reports
when both JML models are fitted to exactly the same simulated ordered responses.
It is intentionally smaller than a performance simulation:

- three deterministic replicates under Criterion slopes fixed at one;
- three deterministic replicates under centered log slopes spanning
  `-0.25` to `0.25`;
- 40 Persons, three Raters, four Criteria, four ordered categories, and a
  complete crossing in every dataset;
- Criterion-owned PCM steps and Criterion-owned GPCM relative slopes;
- unpenalized JML with `maxit = 100` for both models.

The six-pair manifest was fixed before the retained execution. It cannot
estimate false-selection probability, power, or stable operating
characteristics. It contains no FACETS execution.

## Retained result

All six model pairs fitted. PCM was inference-ready in all six datasets;
GPCM/JML was inference-ready in none. Accordingly, every finite likelihood
difference was typed as `optimizer_trace_only_not_inference_ready`, every
evidence tier was `jml_optimizer_trace_only_not_inference_ready`, and no row
made formal model selection available.

| Regime | Seed | Category counts | PCM ready | GPCM ready | GPCM minus PCM log likelihood | Max absolute fitted centered log slope | Slope log-RMSE |
|---|---:|---|---|---|---:|---:|---:|
| unit slopes | 613001 | 112;157;130;81 | yes | no | 0.561441 | 0.164611 | 0.103948 |
| unit slopes | 613002 | 62;140;166;112 | yes | no | 0.479878 | 0.121705 | 0.094209 |
| unit slopes | 613003 | 87;154;162;77 | yes | no | 0.703421 | 0.156246 | 0.117389 |
| moderate | 613101 | 100;167;152;61 | yes | no | 6.000802 | 0.596434 | 0.219089 |
| moderate | 613102 | 77;137;163;103 | yes | no | 5.093004 | 0.463473 | 0.227085 |
| moderate | 613103 | 140;170;123;47 | yes | no | 1.669343 | 0.288669 | 0.178433 |

The descriptive regime summaries were:

| Regime | Pairs | Mean likelihood difference | Mean max absolute centered log slope | Mean slope log-RMSE | Formal selections |
|---|---:|---:|---:|---:|---:|
| unit slopes | 3 | 0.581580 | 0.147521 | 0.105182 | 0 |
| moderate | 3 | 4.254383 | 0.449525 | 0.208202 | 0 |

The moderate regime produced larger apparent fitted slope dispersion and a
larger optimizer likelihood gain than the unit regime in this tiny retained
set. That is a calibration observation, not evidence of a selection rule.
In particular, the nonzero apparent spread under unit slopes demonstrates why
the fitted slope spread alone cannot decide between PCM and GPCM.

## Comparison and FACETS interpretation

The retained rows enforce:

- `SelectionRoute = withheld_JML_has_no_automatic_PCM_GPCM_selection`;
- `PCMvsGPCMLRT = withheld_current_scope`;
- `FACETSComparisonRole = PCM_JML_side_only_no_FACETS_free_slope_GPCM_counterpart`.

Thus FACETS can enter a later direct PCM/JML comparison, but it does not supply
a jointly fitted free-slope GPCM counterpart. A FACETS discrimination
diagnostic must not be substituted for these GPCM slope estimates.

## Reproducibility identities

Runner SHA-256:

`7a3a99d5e809f25ec541d91d5f1f5dbffc28c4833722f7225630a3b332261277`

Focused-test SHA-256:

`7ebc14a6ef03eddf1a2c691789ad572078a1e09892a9430f07b30f25c4466166`

Retained result-table SHA-256:

`bd046d93d249a09406d6ff54d2c70d65ba9453dc998c3b3b519213db3b591b1d`

Paired response-data SHA-256 values, in manifest order:

- `PGJP-P-UNIT-R01`: `f6652d2953d626488a87187187cec2f0b9ae22285065be64b657145b7f014097`
- `PGJP-P-UNIT-R02`: `9980ffb13e39da6a206035a594f1242afd5e6c97acbc577f10843f0b1002afcd`
- `PGJP-P-UNIT-R03`: `1bbee8943e4bd0b9bf5b4a02439aaac7738d9ce415aad84431bc8013c96990c9`
- `PGJP-P-MOD-R01`: `32dd0908e1f1b22a4bcb7c9c5457625f0564b9dc1951ccadd986be8e42c01b65`
- `PGJP-P-MOD-R02`: `56fec94d2a1db8cb30654ad6bb54d9aa2863de4466a9d8793e9b1571d7a83499`
- `PGJP-P-MOD-R03`: `41fff6e29b1fbade3870b5124111a0e7b164ffc9bc772d6fb9e7575a572eaa7c`

## Authority state

`CalibrationOnly = TRUE`

`ModelSelectionAuthorized = FALSE`

`BroadSimulationAuthorized = FALSE`

`ConfirmationAuthorized = FALSE`

The prospective design is now fixed separately in
`pcm-gpcm-comparison-ademp-contract-record-0.2.3.md`. Its execution remains
unauthorized. These six pairs must not be retrospectively converted into that
study or into a PCM-versus-GPCM cutoff.
