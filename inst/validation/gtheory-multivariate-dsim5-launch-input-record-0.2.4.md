# D-SIM-5 shardable launch-input record

Date: 2026-09-01
Status: **launch input ready; execution closed**

## Outcome

The exact D-SIM-4 worker denominator is partitioned into 50 balanced shards.
Each shard contains replicate blocks of 50 across all six confirmation
scenarios: 300 outer attempts, 100 interval-eligible outer attempts, 19,900
inner bootstrap attempts, 650 primary fits, 39,800 refits, and 40,450 planned
backend fit calls.

Each outer attempt and its complete 199-attempt bootstrap block remain in one
shard. All six scenarios and all four scientific roles are represented in
every shard. No scenario, estimator, interval, acceptance rule, attempt,
seed identity, or denominator from the D-SIM-4 freeze was changed.

## Exact identities

- contract: `74716dd0fbba6ac2ceb93c225818a5b7c0e0dd33ab9a0c7440619b4e34a70cf2`
- launch input: `e93d5de438a99d89f89d51f24c9dcd58393dc52127b90926133c7e50a0c91071`
- parent worker manifest: `459abaa38eedfb5ecc8a918d3d1b99cd765867297ab392dd5c896ec276a06f1a`
- parent inner identity: `fe14e64b42fadce5a7f47d0706fc04cb38298adafa8a8b5313fb63e9a5759bd8`
- source SHA-256: `8d3a36b2472804bffa63a8232954658d162937338909b44d754942698333c296`
- runner SHA-256: `ad6b575f05ee10ecf60d30041e4b50d46d9e567a2634eed5fc9cdb28bd248b31`
- local binary SHA-256: `5b2fb0363509a5a220ca6e72b795540d4cd53158c12fce18d6e4455de3ccc9e4`

The local binary is outside the package payload at
`validation-results/gtheory-multivariate-dsim5-launch-input-0.2.4/launch-input.rds`.

## Claim boundary

- launch input ready: **yes**
- shard execution authorized: **no**
- D-SIM-5 execution authorized: **no**
- 857/858 RNG stream opened: **no**
- response generated or backend called: **no**
- simulation validation or public support ready: **no**

The next boundary is an explicit execution admission for a named shard or
shard set. Packaging alone grants no authority to open a seed or fit a model.
