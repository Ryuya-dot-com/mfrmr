# mfrmr 0.2.3 deterministic GPCM score v3 replay record

Status: completed retrospective calibration replay, 2026-08-11. A subsequent
freeze review found that this replay identity omitted the numerical helper
source. The source-bound replay and freeze record supersede it as acceptance
evidence; the numerical tables and decision were unchanged. V2 remains
rejected, all source fits remain review-only, and no general
`NUM-SCORE-TOL`, boundary conclusion, inference readiness, or confirmation is
authorized.

## Pre-replay defect and invalidated result

The first v3 replay under package payload
`059515d620f2e1d31a10ea43bf5f843aadda4154f4096dfd3b5139ab0301a0bf`
returned a nominal v3 pass. It is invalidated, not accepted. A single-cell
preflight and the complete replay gave different optimizer codes and retained
vectors for the same weak-bridge fixture. Two consecutive fits in one fresh
process then differed in objective, parameter vector, and termination code.

The cause was the use of `max.col(log_num)` with R's default
`ties.method = "random"` in log-sum-exp stabilization. Approximate category
ties consumed RNG and could choose different stabilization columns. Every
likelihood and prediction occurrence now uses deterministic
`ties.method = "first"`; optimizer cache keys also retain owned parameter
snapshots. After correction, two consecutive weak-bridge GPCM fits preserve
the RNG state and agree bitwise in objective, parameters, termination code,
and every non-timing optimizer-stage field.

The invalidated local v3 RDS has SHA-256
`ac52e489456d8d164cc981cf78359d89e9fc564bd596f771f9f90072fb76c007`.
It is retained only as an audit artifact and supplies no acceptance evidence.

## Corrected-payload v2 baseline

Because the source payload changed, the earlier v2/attribution artifacts
could not be reused. The unchanged eight-cell v2 design and its original
conjunctive rule were rerun once under corrected package payload
`ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a`.

- v2 result RDS SHA-256:
  `73cd295f7929ff1457e53e79810e58497a31acf5b34965580bce2160130e6068`
- v2 execution identity:
  `766e97cde920989694e3387f5856b7a776086d4c5ea2f29ed615e97de128cb5e`
- v2 manifest:
  `fd3b6230361e9f782fbe32884fabf549907cfcc8403c3cad22e7c0d5954fe73d`
- corrected analytic-attribution RDS SHA-256:
  `b070106ab5170959fee091f40793c5c6bf86759b98d36d8239429dd45e73fcdc`

V2 again returned `rejected`: all 128 evidence strata were complete, but the
same 33/672 coordinate rows and three/32 Jacobian point rows failed. The same
three retained points had extreme slopes. The separate 48-stratum independent
analytic attribution passed; its maximum absolute difference was
`1.920853e-9` and maximum allowance ratio was `0.1716381`. Thus the
deterministic correction did not convert the negative v2 result into a pass.

## Corrected v3 replay identity

- rule contract SHA-256:
  `caa58301fcb676d22ab60263c23b641dfd6b6559bc5f72fa52391db0ebe61e60`
- replay runner SHA-256:
  `1f886eed2cdc125c0ea0bd53eff929235d1b1e9fdc5ddad7d2aebbb81b69ae55`
- replay identity:
  `749dc428c0c5b1474881f7e07a287a0444464ffbdd0b48277601acb5abb7ec9a`
- replay manifest:
  `620104134df3b57ce2245e9a852c6b553ebef3c82dcbd413c2e951efb0e95300`
- replay result RDS SHA-256:
  `7e29477752297420812166f01162454b199a105b9e7fe4f30188a0229153085c`
- elapsed time: `76.101` seconds, recorded diagnostically only

The runner requires the exact development namespace, rejects an installed
0.2.2 namespace, binds both corrected source artifacts, defaults to dry-run,
and requires explicit replay authorization. The result contains 672
coordinate rows, 128 complete evidence strata, 32 point summaries, and 384
entrywise Jacobian rows.

## V3 result

The complete decision is `v3_rule_contract_ready`:

| Check | Result |
| --- | ---: |
| structure / region classification | pass |
| constructed points inside finite-slope envelope | pass |
| finite-slope combined rule | pass |
| extreme-slope review handoff | pass |
| common structural / analytic / Jacobian rule | pass |
| maximum independent analytic-score combined ratio | 0.171638051 |
| maximum finite-difference combined ratio | 0.001754898 |
| maximum expanded-log-Jacobian combined ratio | 0.171708573 |
| maximum positive-slope-Jacobian combined ratio | 0.267669464 |

There were 29 finite-slope points, producing 116 finite-difference evidence
strata, and three extreme retained points, producing 12 explicit
`not_applicable_extreme_slope` strata:

- `NUM-GPCM-SCORE-CAL-C-WEAK5`: slopes about 0.00172 to 3.12e6;
- `NUM-GPCM-SCORE-CAL-R-WEAK5`: slopes about 0.0103 to 2.45e5; and
- `NUM-GPCM-SCORE-CAL-R-WORK5`: slopes about 0.00300 to 2.58e5.

All three entered the non-promoting review handoff. Every source fit had
`FitReadiness = review` and `InferenceReady = FALSE`; optimizer code zero did
not override the large terminal-score/readiness assessment.

## Interpretation boundary

This replay establishes that the post-v2 v3 rule can consistently adjudicate
the bounded calibration design after deterministic likelihood correction. It
does not establish that an extreme retained trace is a finite maximum or a
proved boundary, and it does not validate recovery, standard errors, DFF,
fit statistics, sparse-design inference, or external-software equivalence.

The v3 thresholds were informed by v2 and remain calibration thresholds.
Before any candidate-facing `NUM-SCORE-TOL` can be frozen, the rule and this
corrected source identity require review. Confirmation must then use disjoint
fixtures or exact-candidate data without changing the retained rule.
