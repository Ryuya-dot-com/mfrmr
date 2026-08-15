# ConQuest P2 bounded adaptive-density contract for mfrmr 0.2.3

Status: `bounded_adaptive_density_contract_frozen_truth_oracles_unopened`,
2026-08-15.

- Specification: `0.2.3-conquest-p2-bounded-adaptive-density-contract-v1`
- Contract: `mfrmr_conquest_p2_bounded_adaptive_density_contract_v1`
- Frozen snapshots: q=31, 61, 121, 241
- Hard ceiling: q=241
- Candidate 003 reclassification: prohibited

## Selection and stop rule

q31--q61 is a required diagnostic with no pass threshold. The only candidate
dense pairs are q61--q121 and q121--q241, in that order. For a future
candidate, the lowest pair is selected only when every numerical arm in the
slice has:

- the complete expected coordinate denominator;
- finite coordinate, deviance, and higher-grid continuous-target movement;
- maximum coordinate and deviance movement at or below the unchanged P2
  `2e-6` budgets; and
- higher-grid deviance within `1e-7` of the independent continuous target.

If one arm fails, the whole slice proceeds to the second pair. If any arm still
fails at q121--q241 or q241--continuous, execution stops. No higher q,
threshold change, row deletion, family-specific cherry-picking, or candidate
repair is authorized.

The truth-fixture audit treats coordinate movement as not applicable because
coordinates are fixed at truth rather than refitted. It can validate the
bounded integration-density ceiling, not future optimizer stability. The
candidate-specific mfrmr preflight must later supply actual complete
coordinate movement for every fitted arm.

## Current decision

- `TruthOracleAuditOpened=FALSE`
- `Candidate003Reclassified=FALSE`
- `Candidate004GenerationAuthorized=FALSE`
- `Candidate004FitAuthorized=FALSE`
- `FurtherNodeExpansionAuthorized=FALSE`
- `ThresholdChangeAuthorized=FALSE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
