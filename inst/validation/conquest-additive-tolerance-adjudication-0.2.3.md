# ConQuest additive tolerance adjudication for 0.2.3

Status: repository-only Wave C decision, 2026-08-11. No external program is
launched, no tolerance is inferred, and no confirmation is authorized.

## Decision

The four-arm additive RSM/PCM run is calibration, not confirmation. Its
observed differences may inform an error budget for a future disjoint
candidate, but using their maximum (or a rounded multiple of that maximum) to
declare this same calibration a pass would reuse the result to define its own
acceptance rule. The decision is therefore
`hold_no_post_hoc_tolerance_freeze`.

This does not delete the broad external-validation claim from the long-term
portfolio. It keeps that claim as a future gate while limiting the present
public statement to a descriptive calibration result.

## Five separate numerical layers

1. **Representation.** Native numeric tokens and file hashes are retained.
   The ConQuest 5.47.5 manual says that `decimals` affects screen display and
   is ignored for file output, but does not specify CSV significant digits or
   a rounding mode. A lexical unit such as `1e-6` is therefore not an
   uncertainty interval.
2. **Optimizer termination.** The calibration fixed
   `convergence=1e-8`, `deviancechange=1e-10`, and `iterations=2000`, and kept
   complete transcripts and final exports. This closes the calibration run;
   it does not prove termination for a future release candidate.
3. **Integration.** q=31 and q=61 final native coordinates are identical at
   retained tokens for both models. This is useful stability evidence, but is
   not `IC-INTEGRATION-TOL` and does not establish equality of unprinted
   values.
4. **Scientific acceptance.** `EXT-CQ-TOL` must be a separately justified,
   pre-confirmation rule by common estimand. Calibration may estimate relevant
   numerical scales, but the future candidate result cannot change the frozen
   rule. Token equality, numerical-tolerance passage, and scientific
   equivalence remain distinct fields.
5. **Candidate binding.** The exact package source, executable, commands,
   inputs, and empty output targets must be sealed before a fresh candidate
   run. The opened working-tree calibration cannot fill this role.

The old `export_tolerance=1e-6` argument in the repository-only ConQuest IC
normalizer was an internal handoff-consistency threshold. It has been renamed
`handoff_tolerance`; the old name remains a deprecated alias. The audit now
records the CSV export resolution as unknown and explicitly states that the
handoff tolerance is not a cross-engine tolerance.

## Ordered next action

Obtain an independently adjudicated, pre-confirmation record for `EXT-CQ-TOL`
and `IC-INTEGRATION-TOL`; complete the Binary reported-output normalizer; bind
an exact candidate; and run all six `Binary/RSM/PCM x q31/q61` arms. The four
opened RSM/PCM arms remain calibration and cannot fill those six clean slots.
One connected sparse/load-imbalanced microcase follows only after that core
passes. Large simulation remains downstream and is not authorized by this
adjudication.
