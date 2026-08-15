# ConQuest P2 successor integration contract for mfrmr 0.2.3

Status: `P2_successor_integration_contract_frozen_truth_oracles_unopened`,
2026-08-15.

- Specification: `0.2.3-conquest-p2-successor-integration-contract-v1`
- Contract: `mfrmr_conquest_p2_successor_integration_contract_v1`
- Candidate 003 reclassification: prohibited
- Candidate 004 generation: held until the no-fit truth-oracle audit passes

## Why the ladder changes only for a future candidate

Candidate 003 failed its prospectively governing q31--q61 rule and remains
closed. This successor does not enlarge that threshold or reinterpret the
result. Before candidate-003 output existed, the package's independent
integration pilot already classified q31 as a standard starting grid rather
than a sufficiency certificate, used q121 as a reference, and observed much
smaller q91/q121 than q31/q61 drift. The separately developed P3 contract also
distinguished a required q31 diagnostic from a governing dense-grid and
continuous-target layer.

The future P2 ladder is therefore `31;61;121` with asymmetric roles:

- q31--q61 movement is finite and mandatory in the complete denominator, but
  diagnostic and has no pass threshold;
- q61--q121 must keep every expanded coordinate and deviance within the
  unchanged same-estimand P2 budget of `2e-6`; and
- q121 deviance must be within `1e-7` of an independently integrated continuous
  target.

No P3 numerical budget is transferred. The continuous budget is a
candidate-uninformed numerical-oracle budget, set at 1000 times the declared
`1e-10` relative integration tolerance. Passing it would establish finite-grid
adequacy only for the audited P2 truth fixtures, not substantive equivalence.

## Prospective no-fit audit

The contract includes an independent normal-GHQ evaluator at q=31/61/121 and
uses the existing adaptive continuous integral. It will evaluate all thirteen
pre-existing P2 fixtures at their frozen truth coordinates. The contract is
accepted only if every result is finite, every q61--q121 deviance movement is
at most `2e-6`, and every q121--continuous deviance movement is at most `1e-7`.
No model is fitted and no candidate-003 output is read.

## Current decision

- `TruthOracleAuditOpened=FALSE`
- `Candidate003Reclassified=FALSE`
- `Candidate004GenerationAuthorized=FALSE`
- `Candidate004FitAuthorized=FALSE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
