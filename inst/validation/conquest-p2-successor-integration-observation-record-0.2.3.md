# ConQuest P2 successor integration observation for mfrmr 0.2.3

Status:
`fixed_q121_successor_rejected_unequal_workload_integration_unresolved`; the
thirteen-fixture no-fit truth-oracle audit rejected the fixed q121 ceiling,
2026-08-15.

- Specification: `0.2.3-conquest-p2-successor-integration-observation-v1`
- Contract: `mfrmr_conquest_p2_successor_integration_observation_v1`
- Candidate output read: none
- Model fits: none
- ConQuest launches: none

## Complete-denominator result

All thirteen existing P2 truth fixtures returned finite q31, q61, q121, and
adaptive-continuous likelihoods. Eleven passed both governing layers. The two
unequal-workload fixtures failed both:

| Fixture | q31--q61 diagnostic deviance movement | q61--q121 deviance movement | q121--continuous deviance movement | Limits | Result |
| --- | ---: | ---: | ---: | --- | --- |
| P2-RSM-UNEQUAL-WORKLOAD | 0.01082666 | 0.00001507427 | 0.000001898386 | 0.000002 / 0.0000001 | fail |
| P2-PCM-UNEQUAL-WORKLOAD | 0.009074817 | 0.000007395970 | 0.000002185104 | 0.000002 / 0.0000001 | fail |

The connected-multibridge target rows passed q61--q121 at about `4.24e-10`
and `5.14e-10`, and q121--continuous below `1e-12`. They are not used to
narrow the failed all-envelope contract after inspection.

## Interpretation

The result refutes one fixed density ceiling for the whole P2 envelope. The
failure follows workload shape despite a common Person count and response
family; q adequacy is therefore design-dependent. It does not imply optimizer
or cross-engine disagreement, and it does not justify relaxing `2e-6` or
`1e-7`.

A successor should freeze a bounded, design-adaptive node ladder before any
candidate is generated. It should select the lowest adjacent dense pair that
passes the unchanged budgets for every numerical arm in the slice, require the
higher grid to pass the continuous target, cap the maximum node count, and
retain all earlier snapshots and failures. Selection must occur during an
mfrmr-only preflight before any ConQuest command is authorized.

## Decision

- `FixedQ121ContractConsumed=TRUE`
- `FixedQ121ContractPassed=FALSE`
- `Candidate003Reclassified=FALSE`
- `Candidate004GenerationAuthorized=FALSE`
- `FixedThresholdChangeAuthorized=FALSE`
- `DesignAdaptiveDensityContractRequired=TRUE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
