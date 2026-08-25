# Fixed-calibration post-maintenance G4 v6 contract record

Status: `v6_rules_frozen_candidate_unbound_confirmation_unopened`,
2026-08-26.

## Frozen authority

- Specification:
  `0.2.4-fixed-calibration-post-maintenance-boundary-evidence-v6`
- Contract: `mfrmr_fixed_calibration_g4_post_maintenance_evidence_v6`
- `V6ContractFrozen=TRUE`
- `V6CandidateBound=FALSE`
- `V6ExecutionOpened=FALSE`
- `V6DenominatorCells=49`
- `V6NumericalRules=11`
- `V6ProductionBoundaryFiles=8`
- `V6HostedPlatformCells=5`
- `HistoricalV5ReceiptsReusableForV6=FALSE`
- `CORE05Complete=FALSE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `G6Authorized=FALSE`
- `PublicAPIAuthorized=FALSE`

## Disjoint confirmation design

The authorizing default-31 RSM/PCM fixtures use modular-1061 generation with
61 source Persons, 13 confirmation Persons, source offset 307, confirmation
offset 947, and fit quadrature order 15. The authorizing one-node source-fit
adversaries use modular-1063 generation with 53 source Persons, 10
confirmation Persons, source offset 463, and confirmation offset 1007.

These identities are disjoint from the consumed modular-997, 1009, 1013,
1019, 1021, 1031, 1033, 1039, and 1049 identities. The explicit nine-node
modular-997 fixture remains only as a historical non-authorizing regression
control. No result from v5 or an earlier identity may be pooled into v6.

## Maintenance boundary

The production registry contains the six v5 boundary files plus
`src/mml_backend.cpp` and `src/cpp11.cpp`. The support registry binds the v6
contract, worker, repository test, binding preflight, hosted runner, two
manual-only workflows, `test-compiled-header-contract.R`, the maintenance
admission review, and the exact 0.2.3.1 public-predecessor identity.

Routine `R-CMD-check` remains check-only and cannot issue a G4 receipt. The v6
five-platform path is a distinct `workflow_dispatch` workflow. Candidate
binding and execution remain closed until this frozen source is committed and
one exact clean source tarball is bound.

## Next gate

`NextGate=bind-clean-v6-candidate-run-local-denominator-and-gcc-lto`
