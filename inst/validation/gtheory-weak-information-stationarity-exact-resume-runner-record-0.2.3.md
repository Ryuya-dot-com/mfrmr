# Draft.83d2b2b1g13 exact-resume stationarity runner record

Status: completed repository-only runner-mechanics slice, 2026-08-10. No
reserved calibration or confirmation response was generated, opened,
summarized, or used.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| upstream b1g12 contract | `53a36d72388eb8b4e096ef817aaf94959aa1b3fd3257190cf5c0a8164383d9da` |
| b1g7 authorization audit | `b293987e768ec0e998d3224a6df0689f0ab8b6f2268704ef422e333865d82765` |
| b1g7 sealed corrected manifest | `7cce9d42faccfbbdf928c9ec4978fef25c50aa562750141fbab45a53b75885f8` |
| b1g11 acceptance policy | `7962e47df285812d8c785f206d51925b44a13d02037b7b40a619cb80ce833a62` |
| b1g11 reference receipt | `777e7550a188f89515854738e3b7e42ef418037de4c9f7166a67d61e6dfa2e9e` |
| b1g13 runner policy | `c346aebac1a13770e755402b6a0b7f0e1338d8f9f8b238103b7291e01e250f38` |
| b1g13 profile registry | `ac9baecccb374ab16bcee6d3a04bbf24a6d5ea68efaee2e772cad6f99bc3ba63` |
| b1g13 candidate grid | `659152277636b2c2a912d97d24909f97171019207b30f0d1dded374e5077acdd` |
| b1g13 function registry | `ebcd9f74248cbcd4120015038fa0aaf2d2c1c03760928018162f0833aab911cf` |
| b1g13 runner contract object | `8fb599cd4abbabb454ce416fe3470d3e0f8d23f0bc8f2662630083fb1ec388da` |
| nonreserved fixture manifest | `af13168b59d6f083bade0c66b85ff6befa48b195f1a27434c95e8acc6e18d098` |
| nonreserved fixture execution | `4cdbb0ed2ba69588f81e3fcbd3df634b92a4b7e1929bac387cd6a8562a18100f` |
| source artifact | `7ebaa21434bf5be2af4a530383081989fc835778e86345e9bcec96c900271271` |
| contract artifact | `05be3ff1e97db86cf2f85179c17e1c43c337d64d816fba9041024727d8fcd6e6` |
| focused test artifact | `34a37b72122c9a8f24d011ae171fc98339f0b815edf7881b4047f8db6042d9ba` |

## Result

The runner now has an indivisible dataset-method checkpoint that retains all
backend profiles, both full/reduced roles, both reference problems, and all 48
candidate decisions. The sealed workload independently reconstructs 3,000
dataset markers, 12,000 atomic units, 108,000 candidate-fit rows, 576,000
candidate-decision rows, and 24,000 reference rows. No decision-row expansion
can compensate for a missing fit or reference row.

Evaluator errors and schema violations expand to complete typed failure rows.
Profile selection uses only the frozen within-role objective rule; neither
generating truth nor a diagnostic metric enters selection. Partial completion
returns a progress object explicitly labelled as non-evidence.

The nonreserved fixture passed cold execution, interruption after three new
units, exact resume of five units, and complete eight-unit reuse. All three
complete routes returned execution hash
`4cdbb0ed2ba69588f81e3fcbd3df634b92a4b7e1929bac387cd6a8562a18100f`.
After one stored candidate-fit row was deliberately corrupted, validation
recomputed exactly that unit, reused the other seven, and recovered the same
scientific hash. The fixture retains four intentional candidate-fit failures
and four unresolved/not-evaluable reference rows in their denominators.

Nine focused tests with 129 expectations pass without failures, errors,
warnings, or skips.

## Readiness interpretation

The following narrow flags are newly true:

- `ExactResumeRunnerImplemented`;
- `RunnerImplementationReady`;
- `AtomicCheckpointSchemaReady`; and
- `CompleteFailureAccountingRequired`.

The following remain false:

- `ProductionEvaluatorAdaptersFrozen` and `ReservedRunManifestFrozen`;
- calibration authorization, execution, data-generation, and results-viewing;
- stationarity threshold and production-criterion readiness; and
- confirmation, inference, coefficient, decision, and D-study readiness.

The next gate is not reserved execution. It is the response-free production
adapter and run-manifest preflight, including exact runtime, evaluator, shard,
output, and one-way authorization identities. Only after that independent
audit may opening replicate 201 be reconsidered.
