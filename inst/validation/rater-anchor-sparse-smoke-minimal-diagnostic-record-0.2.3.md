# Minimal Rater-anchor smoke diagnostic record for 0.2.3

Status: **diagnostic completed; feasibility remains closed**

Run date: 2026-08-13

Contract: `mfrmr_rater_anchor_sparse_smoke_minimal_diagnostic_v1`

## Essential question

The 12-fit smoke returned estimates for every run but marked every run
non-ready. The essential question is not how to make that gate pass. It is:

> Must a Rater-anchor-rate study require finite inference for every Person, or
> can Rater-scale recovery be evaluated while typed Person boundary coverage
> remains a separate outcome?

An independent critical review was used to keep the diagnostic bounded. It
recommended no new seeds, anchor rates, sparse designs, thresholds, response
models, estimators, or external engines.

## Minimal work performed

Only two checks were run:

1. the four complete-design anchor conditions were fitted at the frozen
   `maxit = 200` and package-default `maxit = 400`; and
2. the already generated sparse responses were grouped by Person and Rater to
   locate all-minimum and all-maximum patterns, without refitting either sparse
   design.

There were eight diagnostic fits. No convergence tolerance or readiness rule
was changed.

## Complete-design numerical result

Doubling `maxit` changed nothing in any of the four conditions.

| Anchor condition | Gradient at 200 | Gradient at 400 | LogLik change | Maximum Person change | Maximum free-Rater change |
|---|---:|---:|---:|---:|---:|
| none | 4.965448e-4 | 4.965448e-4 | 0 | 0 | 0 |
| exact 25% | 1.155526e-4 | 1.155526e-4 | 0 | 0 | 0 |
| normal-SD-0.25 25% | 7.678940e-4 | 7.678940e-4 | 0 | 0 | 0 |
| shifted-plus-0.25 25% | 1.599921e-4 | 1.599921e-4 | 0 | 0 | 0 |

All values remained above the fixed `1e-4` terminal-gradient review gate. The
optimizer had already stopped at the same retained solutions; insufficient
iteration budget is therefore not the explanation. Further result-driven
increases in `maxit`, decreases in `reltol`, or relaxation of the gradient gate
are not justified by this diagnostic.

## Sparse extreme-response result

| Design | Response rows per ordinary Person | High extremes | Low extremes | Total | Link extremes |
|---|---:|---:|---:|---:|---:|
| single-Rater plus 5% common link | 4 | 5 | 4 | 9 | 0 |
| two-Rater connected cycle | 8 | 2 | 1 | 3 | 0 |

All three cycle extremes were contained in the nine single-Rater extremes.
Adding a second Rater removed six of the nine all-endpoint patterns for this
fixed response realization. The extreme Persons were all ordinary non-link
Persons. Their true abilities ranged from -1.813 to 2.551 in the single-Rater
design and from -1.813 to 1.978 in the cycle, so they were not created by one
link-selection mistake.

Extreme assignments were distributed rather than owned by one Rater: no Rater
was assigned more than two extreme Persons in either design. This does not
prove that Person exclusions are harmless to Rater recovery; it only rules out
a single dominant-Rater explanation in this smoke.

## Metacognitive stop decision

The diagnostic answers the two narrow factual questions:

- increasing the iteration ceiling does not resolve the complete-design hold;
  and
- additional response information reduces, but does not eliminate, JML
  extreme Persons.

It does not answer the estimand-policy question at the top of this record.
Consequently:

- do not run the 560-fit feasibility manifest;
- do not weaken the package's public `InferenceReady` rule after seeing these
  results;
- do not add GPCM, MML, FACETS, regularization, or more simulation conditions;
  and
- before further simulation, write one prospective estimand decision that
  states whether Person boundary coverage is a gate or a separately reported
  performance outcome for the Rater-anchor-rate question.

If all Persons must have finite JML inference, the current sparse designs are
not eligible and the design must change. If the primary estimand is Rater-scale
recovery, a future simulation-specific Rater-recovery eligibility rule may be
considered, but it must leave public fit readiness unchanged and retain Person
coverage and conditional Person recovery as explicit outcomes. This choice is
not made here.

## Post-run maintenance note

The diagnostic now preserves every captured fit warning and marks the
maxit-200/maxit-400 comparison `indeterminate` when either fit or its parameter
contract is unavailable. In the retained diagnostic, all eight fits returned
and all four comparisons remained `compared`. The gradients, log-likelihood
changes, parameter changes, readiness decisions, and authority state above are
unchanged. The evidence identity changed because the previously muffled eight
convergence-review warnings and explicit comparison status are now part of the
auditable payload.

## Deterministic identities

Diagnostic script SHA-256:

`b562369c5e495a10eff90c921e2b2f1ffab7fac0f57075924b7bc1518e56d349`

Focused-test SHA-256:

`8565e0add908f49676a151ecd9ba501c0bf3000a6fc731237455069809be4629`

Deterministic evidence SHA-256 (elapsed time excluded):

`caa4a3c659e544c2cfaa2e4efe492f0e6b7ffc7781118c6c1abb8ed43518cc1c`

## Authority state

`DiagnosticExecuted = TRUE`

`FeasibilityHandoffAuthorized = FALSE`

`AppropriateAnchorRateSelected = FALSE`

`ConfirmationAuthorized = FALSE`

The diagnostic changes no public readiness rule, optimizer default, anchor
percentage, FACETS claim, PCM/GPCM conclusion, or release gate.
