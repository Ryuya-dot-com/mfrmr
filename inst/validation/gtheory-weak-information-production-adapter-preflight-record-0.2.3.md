# Draft.83d2b2b1g14 production-adapter and reserved-manifest preflight record

Status: completed repository-only production preflight, 2026-08-10. Reserved
calibration and confirmation responses were not generated, opened, summarized,
or used.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| upstream b1g13 runner contract | `8fb599cd4abbabb454ce416fe3470d3e0f8d23f0bc8f2662630083fb1ec388da` |
| upstream b1g12 boundary contract | `53a36d72388eb8b4e096ef817aaf94959aa1b3fd3257190cf5c0a8164383d9da` |
| upstream b1g6 glmmTMB reference contract | `60e04706736c0e7273dfa321d0d41a3a9ed4bb8362a0b7d428f8507653ecce9a` |
| upstream b1g10 lme4 reference contract | `419fbf43fd1b86ab494aa96224916c0bfa9c1e1ef2668f8877d9d39659bcc7e0` |
| b1g14 adapter policy | `f66448882706c5ade2b7d1160b7ed339892c07b8a43a8878e528527c360731b3` |
| b1g14 adapter registry | `2ca8ef60ea078bac2011791c73dee0a7119a5508c4cb725332630da905e8533e` |
| b1g14 dependency registry | `9588628175dbc6de7899806754b4ede2019e7d3032745b146e9313e69c2d8d8b` |
| b1g14 function registry | `d73a7839d6bceed511d486514ce56aff6abd8b0ae37baff3e7b664b02501212c` |
| b1g14 runtime | `94cb18393b87ef8409f231b2e62c507f43fb3294cdefeb0f3e8c19c8235e7753` |
| b1g14 adapter contract object | `baf48a948b86c1769aba8a574619c6ce57be17b4b5747ae935f0e430392518a1` |
| reserved run manifest | `019fedf063ce90c3492f9eb37f6dbec43a42474ce9096e7cc2891491d7a158c8` |
| nonreserved dry-run manifest | `cb9fe43e82be6ed64dc08db94998114b5a3f1f420914e1e5491cee3c79f2554c` |
| nonreserved dry-run execution | `b9ad747a62b1e14cf1da1e0e4cee8a0a341db969596df3e2de87b25ba908caae` |
| b1g14 preflight audit | `eddbe9cb3e1ab56d3389f9f896524f0bf0ae92b224b2997f4e5f6014219a31cf` |
| source artifact | `7772a5c0f11264e81b10c19b1f857c913759ffe9cdf823757d997166e55244aa` |
| contract artifact | `57d96400a4444ecfe6bc8cc099a0a0ede45a0f73ed81142f090ebe0cd5b9abd1` |
| focused test artifact | `fa40f4469d638e8ca81aff8b98acc3c54e9987e21d4f0aa066bfae24ca96c4bb` |

The frozen runtime is R 4.6.1 on aarch64-apple-darwin23 / Darwin 25.5.0,
with digest 0.6.39, lme4 2.0.6, Matrix 1.7.6, glmmTMB 1.1.14, TMB 1.9.23,
minqa 1.2.8, nloptr 2.2.1, and numDeriv 2016.8.1.1. These versions are part
of the manifest identity rather than a claim of portability to an untested
runtime.

## Reserved manifest result

The response-free manifest contains exactly 100 immutable shards, `R0201`
through `R0300`. Each shard contains all 30 scenarios and all four methods for
one replicate: 120 atomic units, 1,080 candidate fits, 5,760 candidate
decisions, and 240 references. The aggregate counts are 3,000 datasets,
12,000 atomic units, 108,000 candidate fits, 576,000 decisions, and 24,000
references. Every shard identity is content-addressed.

The output root is
`validation-results/gtheory-stationarity-calibration-draft83d2b2b1g14`.
It is a frozen relative identity, not evidence that production permissions,
capacity, or filesystem behavior have passed. The manifest retains
`ExecutionAuthorized=FALSE`, `CalibrationDataGenerated=FALSE`, and
`CalibrationResultsViewed=FALSE`.

## Real-adapter dry-run result

The production adapters completed all four lme4/glmmTMB x ML/REML atomic
units on nonreserved replicate 902. Exact accounting retained 36 planned
candidate-fit rows, 192 candidate-decision rows, and eight high-accuracy
reference rows.

Thirty-five of 36 candidate fits returned. The single failed row was the
glmmTMB ML full-model BFGS-from-BFGS restart at the `start_snapshot` stage.
It remains a typed planned-denominator failure and was neither retried under
an unregistered rule nor deleted. All eight reference rows resolved: glmmTMB
ML/REML full/reduced references were `finite_local_minimum`, and lme4 ML/REML
full/reduced references were `finite_box_local_minimum`.

Candidate and reference rows shared the same generator and structural pre-fit
identities in every atomic unit. All 192 decisions recorded
`GeneratingTruthUsed=FALSE` and `MetricUsedToSelectProfile=FALSE`. A complete
second execution reused all four checkpoints, computed zero units, and
reproduced execution hash
`b9ad747a62b1e14cf1da1e0e4cee8a0a341db969596df3e2de87b25ba908caae`.
The preflight recomputed that scientific execution hash before using any
ledger; mutation of one stored pre-fit identity was rejected as an invalid
execution input.

Seven focused tests with 114 explicit assertions pass without failures,
errors, warnings, or skips. They also reject direct reserved-unit calls and
mutated adapter, runtime, shard, and manifest identities.

## Readiness interpretation

The following narrow flags are newly true in the preflight result:

- `ProductionEvaluatorAdaptersFrozen`;
- `ReservedRunManifestFrozen`;
- `ProductionAdapterPreflightReady`;
- `DryRunEvidenceReady`;
- `GeneratorHashMatch`;
- `PreFitHashMatch`; and
- `ShardAccountingExact`.

The following remain false:

- calibration authorization, execution, data generation, and results viewing;
- stationarity threshold and production criterion readiness;
- confirmation authorization;
- inference, coefficient, decision, and D-study readiness; and
- every public-support or release-checklist promotion.

The next admissible step is an independent one-way authorization audit. It
must be response-free and separately verify exact identities, output
permissions and capacity, same-filesystem checkpoint installation, shard
accounting, no early stopping, and confirmation isolation. Only a subsequent
immutable authorization artifact may reconsider opening replicate 201.
