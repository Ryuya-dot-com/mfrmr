# ConQuest P2 log-centered continuous-oracle contract for mfrmr 0.2.3

Status: `log_centered_continuous_oracle_contract_frozen_audit_unopened`,
2026-08-15.

- Specification: `0.2.3-conquest-p2-log-centered-continuous-oracle-v1`
- Contract: `mfrmr_conquest_p2_log_centered_continuous_oracle_v1`
- Tail interval: `[-12,12]`
- Integration tolerances: relative `1e-12`, absolute `1e-14`
- Subdivision cap: 1,000 per half-integral

## Numerical design

For each Person, the response-pattern log likelihood plus standard-normal log
density is maximized independently on `[-12,12]`. The exponential integrand is
then centered at that maximum and integrated separately to its left and right.
The contract checks that the mode is interior and locally maximal and that
both integrations report success.

The response-pattern likelihood is at most one. Therefore, the omitted
integral outside `[-12,12]` is bounded by the corresponding standard-normal
tail mass. The implementation combines that tail bound with the reported
scaled numerical integration error and transports both to a conservative
Person-log-likelihood and summed positive-deviance error bound.

## Qualification gates

All thirteen pre-existing P2 fixtures must be present. Each must have finite,
successful, interior-mode results; both q121 and q241 deviance must be within
`1e-7` of the log-centered continuous result; and the declared numerical-plus-
tail deviance error bound must be at most `1e-8`. The legacy continuous result
is retained as a comparator but is not allowed to veto or pass the new oracle.

These gates were fixed before running the log-centered audit. Candidate-003
output did not set them, and neither candidate 003 nor the two consumed
successor contracts can be reclassified. A pass may qualify the new reference
only for future P2 candidates.

## Current decision

- `OracleAuditOpened=FALSE`
- `OracleQualified=FALSE`
- `LegacyContinuousOracleReplacedForFutureCandidates=FALSE`
- `Candidate003Reclassified=FALSE`
- `Candidate004GenerationAuthorized=FALSE`
- `Candidate004FitAuthorized=FALSE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
