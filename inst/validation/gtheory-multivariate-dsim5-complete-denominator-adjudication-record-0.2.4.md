# D-SIM-5 blind complete-denominator adjudication qualification (0.2.4)

Date: 2026-09-06
Scope: repository-internal package-capability validation
Disposition: `complete_denominator_adjudicated_fail_no_promotion`

## Exact identity

- adjudication contract:
  `71a4e969d665b5bc11110247f7e26de9424873493386fb7853623a4d5cec5f06`
- source SHA-256:
  `13ba08c90e86745509783d384c03a0bfa5039cd0d18d2e0dde0dc274b7993dea`
- sentinel-test SHA-256:
  `46b1621b333e8d28545dedb5132c9c263e491b664acd3c574bf632ecff38bff6`
- read-only runner SHA-256:
  `ee32b9773af8b48a4fd7e73eba399a8bfede0404121b6290ccfe218c772d5141`
- parent D-SIM-4 freeze manifest:
  `8e8b4b3d4f28a1ac9c94a42fbbdb193aa4979c57bf8a6f2d1a5ecb24ee4d713e`
- parent D-SIM-5 launch input:
  `e93d5de438a99d89f89d51f24c9dcd58393dc52127b90926133c7e50a0c91071`
- parent D-SIM-5 admission manifest:
  `8f13db52ad19cbe5adcda0aabb6be6ec8ff949cb555d6043ea1dba0e74972510`
- parent D-SIM-5 executor contract:
  `a64facef158aaf7f4e4463512af9b7367195f708d45183e2cd3d5d63ec9bf6f3`
- frozen D-SIM-3 truth-source manifest:
  `ad97f0f48f382bd41c6353dab6ce1405453b6146ce3fd4dfbb4ea04406fb8f8f`

## Outcome-blind executable interpretation

The v4 acceptance registry had already frozen the numerical limits, but its
plain-text rule did not make the standardization denominator or unavailable-
interval MCSE calculation executable. Those choices were fixed here before
opening any D-SIM-5 coefficient or interval value:

- the unit is `confirmation scenario x stratum x estimand`;
- ABS-PHI and REL-G are evaluated separately, with no cross-cell pooling or
  voting;
- standardized bias is mean estimation error divided by the empirical Monte
  Carlo SD of the estimates in the same complete 2,500-attempt cell;
- its MCSE is the raw bias MCSE, `sd(estimate) / sqrt(N)`, divided by the same
  empirical SD;
- a point cell with any unavailable planned estimate is `indeterminate`, not a
  successful-fit analysis;
- interval coverage uses all 2,500 planned attempts. The lower bound treats
  unavailable intervals as noncoverage and the upper bound treats them as
  coverage;
- each bound uses `sqrt(p * (1 - p) / N)` and both bounds must satisfy the
  frozen `|p - 0.95| <= 0.03 + 2 MCSE` rule; and
- boundary and closure cells do not receive the regular-interior bias or
  coverage threshold. They retain reference-transform, coefficient-order,
  failure, and attempt-accounting checks.

This clarification changes no data generator, estimator, truth, interval,
route, replication count, seed, scenario, or numerical threshold. Scientific
values cannot revise it.

## Blind qualification

The focused test ran through `scripts/run-quiet.sh` and passed 20 expectations.
Synthetic sentinels established that the assembler rejects:

1. missing attempt identities;
2. duplicate attempt identities;
3. foreign attempt identities;
4. altered request identities;
5. altered checkpoint payloads;
6. partial or foreign checkpoint directories; and
7. altered shard receipts.

Additional sentinels verify that unavailable point estimates make a bias cell
indeterminate and that unavailable intervals remain in the two worst-case
coverage bounds. The synthetic qualification constructed no response, opened
no planned 857/858 RNG stream, called no backend, and read no D-SIM-5 result.

The first read-only runner smoke then stopped on the first checkpoint before
numerical extraction because the stored coefficient registry correctly uses
the confirmation-scenario ID in its `ScenarioId` field. Only identity columns
were inspected to correct that loader assertion; no coefficient or interval
number was printed, summarized, or used to revise a scientific rule. A prior
smoke stopped still earlier on a missing parent-validator source. A subsequent
identity-only smoke rejected equal identity columns because their irrelevant R
row names differed; the comparison now uses only the three contract-defined
identity columns and has a dedicated row-name sentinel. None of these attempts
wrote an adjudication artifact. The first full stream then reached the final
count gate and stopped because list length had been queried with `nrow()`;
changing that mechanical check to `length()` did not inspect or alter a result,
formula, threshold, denominator, or disposition.

## Qualification-time claim boundary

- blind assembler/adjudicator qualified: **yes**
- complete 15,000-attempt denominator assembled scientifically: **no**
- D-SIM-5 numerical coefficient or interval value adjudicated: **no**
- scientific adjudication computed: **no**
- simulation validation ready: **no**
- reference validation ready: **no**
- public support ready: **no**

The next bounded action is one read-only assembly and adjudication over the
already closed 15,000-attempt denominator. It may write one internal immutable
result artifact, but it may not add attempts, replenish failures, alter a
threshold, select a scenario, or promote a public API.

## Complete-denominator result

The qualified runner subsequently assembled and adjudicated the full immutable
denominator in 136 seconds without a fit, seed change, replacement, or
replenishment. The single internal artifact is
`validation-results/gtheory-multivariate-dsim5-complete-denominator-adjudication-0.2.4/adjudication.rds`.

- artifact hash:
  `d46b8918e3386c36bb3ca38e54ca79a1fb1e2ceab0a4d89eb33a044f36e2aa13`
- assembly hash:
  `e95b1b51436c2de7e3a942a481f2d1c49302e93160cbf8c3e5ecfbffb666bb59`
- adjudication hash:
  `4c3f74548d578694d8cfe436a9cfd8b5a7190487334fa794ec11eb0b06cacb3d`
- artifact file SHA-256:
  `f97f84fec6ec83eba5bd4e4e58fe88713618ff4a3fc935a031b93f6b0cd7c735`
- artifact bytes: `2,240,647`

All 15,000 outer attempts and 995,000 inner attempts remain accounted for.
There are 9,973 `complete_point_only`, 5,000 `complete_with_interval`, and 27
`primary_fit_or_target_failure` terminal attempts. All 27 failures occur in
boundary cell D4-S005. They leave 56/45,000 boundary/control scalar positions
unavailable: 2, 3, and 23 positions per estimand in S1, S2, and S3. All remain
in the planned denominator. The other 44,944 boundary/control scalar positions
pass the direct reference transform and Phi-not-greater-than-G checks; all 18
boundary/control cells therefore pass their applicable fail-closed criteria.

The two regular-interior scenarios contain all 20,000 planned intervals, with
zero unavailable intervals. Results by cell are:

| Scenario | Stratum | Estimand | Bias | Standardized bias | Bias | Coverage | Coverage |
| --- | --- | --- | ---: | ---: | --- | ---: | --- |
| D4-S001 | S1 | ABS-PHI | -0.000792 | -0.0247 | pass | 0.9176 | pass |
| D4-S001 | S1 | REL-G | -0.001551 | -0.1018 | fail | 0.9368 | pass |
| D4-S001 | S2 | ABS-PHI | -0.000553 | -0.0171 | pass | 0.9140 | pass |
| D4-S001 | S2 | REL-G | -0.001424 | -0.0908 | fail | 0.9376 | pass |
| D4-S006 | S1 | ABS-PHI | -0.009748 | -0.8076 | fail | 0.8948 | fail |
| D4-S006 | S1 | REL-G | -0.010348 | -2.7069 | fail | 0.1716 | fail |
| D4-S006 | S2 | ABS-PHI | -0.009729 | -0.7710 | fail | 0.8852 | fail |
| D4-S006 | S2 | REL-G | -0.010312 | -2.6544 | fail | 0.1720 | fail |

The standardized-bias MCSE is 0.02 in every complete 2,500-attempt cell, so
the frozen limit plus two MCSE is 0.09. D4-S001 passes all four coverage cells
and its two ABS-PHI bias cells, but its two REL-G bias cells fail. D4-S006
fails all four bias and all four coverage cells. Its REL-G coverage near 0.17
is not an unavailable-interval artifact: all 2,500 intervals in each stratum
are available.

ABS-PHI and REL-G therefore each receive `fail`; the overall D-SIM-5
disposition is `fail`. This is a valid negative confirmation result, not an
execution failure. It does not license post-outcome threshold changes, a local
patch followed by replay on the same seed band, deletion of D4-S006, or a
successful-cell support claim.

## Final claim boundary

- blind assembler/adjudicator qualified: **yes**
- complete denominator assembled: **yes**
- attempt accounting passed: **yes**
- D-SIM-5 scientific adjudication computed: **yes**
- D-SIM-5 disposition: **fail for ABS-PHI and REL-G**
- simulation validation ready: **no**
- reference validation ready: **no**
- public support ready: **no**

The next bounded task is D-SIM-6 evidence-bounded maturity assignment and
root-cause planning. Diagnosis may explain the targeted-structural failure,
but it cannot retroactively change this D-SIM-5 disposition or reuse these
opened seeds as confirmation for a revised estimator or interval.
