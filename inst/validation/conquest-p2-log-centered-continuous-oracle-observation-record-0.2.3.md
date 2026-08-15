# ConQuest P2 log-centered continuous-oracle observation for mfrmr 0.2.3

Status: `log_centered_continuous_oracle_qualified_for_future_p2_candidates`;
all thirteen frozen truth-fixture rows passed, 2026-08-15.

- Specification:
  `0.2.3-conquest-p2-log-centered-continuous-oracle-observation-v1`
- Contract:
  `mfrmr_conquest_p2_log_centered_continuous_oracle_observation_v1`
- Audit denominator: 13/13 pre-existing P2 fixtures
- Candidate-output or external-executable input: none

## Observation

All mode, local-maximum, integration-success, and finite-value checks passed.
The largest q121--log-centered deviance movement was `1.01e-10`, the largest
q241--log-centered movement was `2.27e-12`, and the largest declared
numerical-plus-tail deviance error bound was `2.22e-11`. These are below the
prospectively frozen `1e-7`, `1e-7`, and `1e-8` limits, respectively.

The legacy continuous result remained outside `1e-7` only for the two
unequal-workload fixtures: approximately `1.90e-6` for RSM and `2.19e-6` for
PCM. q121 and q241 instead agree with the independently mode-centered integral
on those rows. Together with their q121--q241 convergence, this supports a
limitation in the legacy numerical reference rather than insufficient finite
quadrature density. It does not identify the legacy failure mechanism.

## Scope and limitations

The log-centered result is qualified as the repository's continuous numerical
reference for future P2 candidates. It is not independent cross-software
validation: the finite and continuous calculations share the repository's
probability implementation. The numerical part of the declared error bound is
the integration routine's reported error estimate, not an interval-arithmetic
certificate; only the omitted normal-tail component has an analytic bound.
These results establish numerical consistency under the frozen challenge, not
parameter recovery, calibration, or scientific equivalence.

## Decision

- `LogCenteredContinuousOracleQualified=TRUE`
- `LegacyContinuousOracleReplacedForFutureCandidates=TRUE`
- `LegacyReferenceLimitationSupported=TRUE`
- `LegacyFailureMechanismProven=FALSE`
- `IntervalCertifiedErrorBound=FALSE`
- `IndependentSoftwareValidationCompleted=FALSE`
- `Candidate003Reclassified=FALSE`
- `ConsumedPredecessorReclassified=FALSE`
- `Candidate004GenerationAuthorized=TRUE`
- `Candidate004FitAuthorized=FALSE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`

Candidate 004 may now be generated as a new, disjoint fixture under the same
thirteen pre-fit gates and support-conditioned sampling contract. Its fitting
contract, output-root/sentinel checks, minimum audit, and any ConQuest execution
remain separate future gates.
