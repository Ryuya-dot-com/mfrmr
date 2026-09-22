# ConQuest diagnostic-numeric-eligibility addendum for mfrmr 0.2.3

Status:
`ASP_G4N_diagnostic_numeric_eligibility_frozen_calibration_authorization_required`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-diagnostic-numeric-eligibility-addendum-v1`
- Contract:
  `mfrmr_conquest_adversarial_simulation_diagnostic_numeric_eligibility_addendum_v1`
- Completed gate: `ASP-G4N-DIAGNOSTIC-NUMERIC-ELIGIBILITY-ADDENDUM`
- Next gate: `ASP-G4A-TRANCHE-A-AUTHORIZATION-REVIEW`

## Decision

Freeze a separate `DiagnosticNumericEligible` contract, but do not generate or
run calibration tranche A yet.

The addendum does not weaken `InferenceReady`. It does not reinterpret the 16
retained mfrmr G4X terminal codes as ordinary success, erase their readiness
reasons, or modify any retained file. It determines only whether a completed
fit may enter an explicitly exploratory technical numerical summary after a
separate calibration authorization.

This distinction resolves the G4R denominator problem without converting a
diagnostic result into an inferential claim:

- `InferenceReady` answers whether the package regards the fit as ready for
  inferential use under the full readiness contract;
- `DiagnosticNumericEligible` answers whether a finite, converged, parseable,
  model-matched result is technically usable in a prespecified exploratory
  comparison;
- the second state can be true while the first remains false;
- neither state can be changed by G4N;
- diagnostic eligibility never authorizes confirmation, evidence promotion,
  or a public claim.

## Narrow mfrmr rank-hold exception

An mfrmr result with terminal code
`optimizer_nonconvergence_or_readiness_hold` is diagnostic-eligible only when
all of the following are simultaneously true:

1. the frozen structural disposition is `eligible_numeric_comparison`;
2. exactly one scheduled attempt started and completed;
3. the retained G4X parser classified the complete result as finite and
   parseable;
4. observed and expected free dimensions are equal;
5. model identity and the registered artifact set match;
6. any required paired-missingness semantic bridge passed;
7. retry was forbidden and no numerical agreement was previously inspected;
8. the model family and quadrature identity match the frozen arm, the requested
   and used mfrmr engines are both `direct`, and `Converged=TRUE`,
   `ConvergenceCode=0`, `ConvergenceStatus=converged`,
   `ConvergenceSeverity=pass`, and `ReviewableWarning=FALSE`;
9. `FitReadiness=review`, `InferenceReady=FALSE`,
   `EstimabilityState=not_evaluated`, `CategoryState=adequate`,
   `BoundaryState=finite`, and `NumericalState=ready`;
10. an ordinary/planned representation has exactly
    `InputState=pass` and reason `design_rank_not_evaluated`;
11. an explicit-missing representation has exactly `InputState=review` and
    reasons `design_rank_not_evaluated;input_review_required`, ignoring only
    their order; and
12. the original terminal code, secondary code, failure count, readiness
    state, and reasons remain unchanged.

This is not a generic exception for optimizer nonconvergence. Actual
nonconvergence, iteration limits, nonfinite output, parser failure, dimension
or model mismatch, boundary exclusions, weak categories, structural
nonidentification, unknown reasons, missing artifacts, failed semantic bridges,
or reopened/retried attempts remain diagnostic-ineligible.

An ordinary mfrmr `complete_numeric_eligible` result remains eligible through
a separate standard path requiring a converged, fully `ready`,
`InferenceReady=TRUE`, identified, finite result with no reason or failure
code. ConQuest requires clean exit status zero, the terminal marker, the full
registered artifact set, no failure code, and the ordinary complete terminal.

## Metric-use map

The addendum maps all 14 active calibration summaries rather than applying one
blanket success filter.

- Structural disposition, engine execution, joint eligibility, false-ready,
  elapsed runtime, and retained storage keep their unconditional denominators.
- Probability truth error, continuous-oracle error, parameter bias, and RMSE
  require diagnostic eligibility for the engine result being summarized.
- The primary metric denominator excludes the explicit-missing invariance
  companion so that one dataset is not counted twice.
- Cross-engine coordinate difference requires both engines to be diagnostic-
  eligible for the same dataset, family, quadrature setting, and primary
  semantic arm; any required bridge must pass.
- Quadrature sensitivity requires diagnostic-eligible q61 and q121 results for
  the same engine, dataset, family, and primary semantic arm.
- Representation invariance requires diagnostic-eligible planned-absence and
  explicit-missing mfrmr fits plus the semantic bridge.
- Every conditional numerical summary retains its unconditional failure or
  eligibility companion.
- False-ready is a cross-tabulation of diagnostic eligibility against the
  unchanged `InferenceReady` state. It is evidence about the safety boundary,
  not a route for promoting a fit.

No threshold, direction of desirable agreement, confirmation rule, or public
interpretation is set by this addendum.

## Adversarial validation

Executable truth-table tests reject each single-point mutation of the narrow
exception: nonconvergence, wrong convergence status, parse failure, dimension
mismatch, model mismatch, unknown reason, structural nonidentification, weak
category information, boundary exclusion, numerical failure, optimizer-error
terminal, missing artifact, failed semantic bridge, duplicate attempt, retry
permission, and prior result inspection. Explicit missingness also fails when
its extra input-review reason is missing or attached to the wrong
representation.

Metric gates separately show that one engine cannot populate cross-engine
agreement, one quadrature point cannot populate sensitivity, and two
representations cannot populate invariance without the semantic bridge.
Unconditional failure and resource summaries remain available when all
conditional numerical gates are false.

## G4X categorical reachability

The addendum was applied to G4X mechanics and categorical-readiness fields
without reading coordinates, estimates, likelihoods, deviances, truth errors,
or cross-engine differences.

- all 16 mfrmr outcomes reach `diagnostic_rank_hold_only`;
- all 14 ConQuest outcomes reach `complete_numeric`;
- all 30 original terminal codes are preserved;
- all 16 mfrmr `InferenceReady=FALSE` states are preserved;
- no G4X output was rewritten or rerun; and
- categorical reachability is not numerical agreement evidence.

The result establishes that the frozen tranche can, in principle, populate
its main diagnostic denominators. It does not establish agreement, acceptable
error, calibration precision, or scientific equivalence.

## Why calibration remains closed

G4N defines admissible use but is not an execution authorization. G4A must
separately bind the addendum to the frozen calibration identity, confirm that
seeds, DGPs, workload, attempt order, pairing rules, caps, and failure retention
are unchanged, require an absent output target and a fresh same-process runtime
sentinel, and preserve one-attempt/no-result-driven-retry behavior. G4A must
also decide whether the expected information gain of tranche A still exceeds
its runtime and interpretive cost.

Current state:

- `G4XMfrmrDiagnosticNumericReachable=16`
- `G4XConQuestDiagnosticNumericReachable=14`
- `G4XTerminalCodesRelabelled=FALSE`
- `G4XInferenceReadyStatesChanged=FALSE`
- `CalibrationNumericValuesInspected=FALSE`
- `CalibrationResponseGenerationAuthorized=FALSE`
- `CalibrationExecutionAuthorized=FALSE`
- `EngineMechanicsRerunAuthorized=FALSE`
- `ConfirmationUseAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
- `SeparateCalibrationAuthorizationRequired=TRUE`
