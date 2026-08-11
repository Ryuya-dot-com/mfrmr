# mfrmr 0.2.3 GPCM score v3 disjoint-confirmation design record

Status: fixture and denominator design sealed; execution not authorized,
2026-08-11. No model was fitted and no confirmation result was opened.

## Purpose and separation

This design applies the already frozen bounded v3 score rule to data that do
not reuse the eight calibration cells. It changes neither the four combined
rules nor the inclusive `max(abs(z)) <= 3` finite-slope envelope. Its only
purpose is candidate-specific numerical confirmation; it cannot validate
recovery, standard errors, DFF, fit indices, sparse-design adequacy, or general
GPCM inference.

Separation from calibration is structural rather than seed-only. Confirmation
uses `Q`/`V`/`D` level namespaces instead of calibration `P`/`R`/`C` levels,
different Person/Rater/Criterion dimensions, and three new assignment/category
structures. Every fixture is deterministic and has positive support for every
Rater-category and Criterion-category combination.

## Sealed design

| Design | Persons | Raters | Criteria | Categories | Rows | Assignment |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `rect4` | 37 | 3 | 5 | 4 | 555 | complete crossing |
| `cyclic5` | 43 | 5 | 3 | 5 | 258 | two cyclic Raters per Person, all Criteria |
| `work6` | 46 | 4 | 6 | 6 | 804 | deterministic unequal Rater workloads |

Each design is paired with Criterion-owned and Rater-owned slope/step models,
giving six scenarios. Four frozen point identities and four parameter classes
give 96 mandatory evidence strata. The prespecified complete denominators are
560 coordinate rows, 24 point rows, and 376 entrywise Jacobian rows.

Fixture SHA-256 identities are:

- `rect4`: `71f144dbee608f04f49d68c6155dd27d92d6be83d9e1b3f3fad1c5bfc5087309`
- `cyclic5`: `02630b52b65f74948e3158b2ef03da7ed7ebac8757689d586c65c61f67ac195a`
- `work6`: `e82b1c8ab9d8e1914a5534c2f5c40daed9765c2ed4929db8f3276dbff865a44c`

The design source SHA-256 is
`c22bf47998fbad9b46e6d8b205af8a52ef6a03b17a190fb24207f2b0fc7d4ec6`.
It binds frozen package payload
`ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a`,
frozen replay identity
`5651592f12e2ba5f4c4d394d49516de1d1720e0a1c300feb1af7be4dc753f3a7`,
and freeze contract SHA-256
`de3b3bcf6e78ba99806bc67fafe85e908557e912c9c4212cbe6233c5913074bd`.

## Fail-closed boundary

The design rejects missing or changed fixture hashes, incomplete owner-category
support, duplicated response keys, changed evidence denominators, reuse of
calibration data, a changed freeze seal, or any result/execution authorization
flag. Its current decision is
`confirmation_design_sealed_execution_not_authorized`.

The next bounded task is not execution. A record-consuming runner must first
default to dry-run and bind this exact design source, freeze seal, package
payload, validation sources, fixture hashes, coordinate/Jacobian denominators,
and a fresh-process runtime. A separate authorization decision must require an
absent output target and must remain NO-GO until that runner and its negative
tests are complete. No large simulation is implicated by this confirmation.
