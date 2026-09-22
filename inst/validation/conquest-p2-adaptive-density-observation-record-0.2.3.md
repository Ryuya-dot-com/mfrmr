# ConQuest P2 bounded adaptive-density observation for mfrmr 0.2.3

Status: `q241_ceiling_reached_continuous_reference_unresolved`; every
q121--q241 truth-fixture comparison passed, but the two unequal-workload rows
still failed against the legacy continuous reference, 2026-08-15.

- Specification: `0.2.3-conquest-p2-bounded-adaptive-density-observation-v1`
- Contract: `mfrmr_conquest_p2_bounded_adaptive_density_observation_v1`
- Maximum q: 241, consumed
- Additional q authorized: no

## Observation

All thirteen q121--q241 deviance movements were at most `9.85e-11`, far below
the unchanged `2e-6` finite-grid budget. The two unequal-workload rows retained
q241--legacy-continuous movements of about `1.90e-6` and `2.19e-6`, above the
`1e-7` continuous budget. Every other row passed; the next largest continuous
movement was about `5.10e-9`.

The same two rows differed from the legacy continuous result at essentially
the same scale at q121 and q241, while q121 and q241 agreed with each other.
This is evidence that the disagreement is no longer resolved by increasing
the finite quadrature density. It does not by itself prove which numerical
reference is wrong.

## Decision

- `FiniteGridConvergencePassedAllRows=TRUE`
- `Q241CeilingConsumed=TRUE`
- `FurtherNodeExpansionAuthorized=FALSE`
- `FixedThresholdChangeAuthorized=FALSE`
- `LegacyContinuousOracleQualified=FALSE`
- `LogCenteredContinuousOracleQualificationRequired=TRUE`
- `Candidate003Reclassified=FALSE`
- `Candidate004GenerationAuthorized=FALSE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`

The next contract must qualify the continuous reference itself. A suitable
challenge computes each Person integral after subtracting an independently
located log-integrand maximum, uses explicit tail and numerical error controls,
and compares the result with both q121 and q241. It must be frozen before those
values are observed. It may replace an unqualified reference for a future
candidate, but cannot pass either consumed predecessor retrospectively.
