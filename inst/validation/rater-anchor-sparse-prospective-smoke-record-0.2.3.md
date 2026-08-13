# Prospective Rater-anchor sparse-design smoke record for 0.2.3

Status: **software execution contract passed; scientific readiness failed;
feasibility withheld**

Run date: 2026-08-13

Specification: `0.2.3-draft.1`

Contract: `mfrmr_rater_anchor_sparse_prospective_smoke_v1`

## Scope and authority

An explicit continuation instruction authorized this bounded smoke execution.
The prospective design artifact remained non-self-authorizing, and the runner
default remained `execute = FALSE`. The runner refuses any profile other than
`smoke`; it cannot launch the 560-fit feasibility manifest.

The execution retained the frozen direct lane:

- PCM response model and unpenalized mfrmr JML;
- 160 Persons, 16 Raters, four Criteria, and four ordered categories;
- response-data seed `616001`;
- external Rater-selection seed `816001`;
- three assignment designs and four anchor conditions;
- no FACETS executable, GPCM slope, or MML model selection; and
- no operational anchor-rate or release claim.

There were **12 declared PCM/JML smoke fits**. The same complete generated
truth and response realization was deterministically subset for all designs.
Within a design, all four anchor arms used identical retained responses. Each
external selection or value-error realization was reused across all three
designs.

## External calibration realization

The positive-rate arms all selected four Raters from the same external
calibration estimate. Relative to generating Rater severity, that external
estimate had RMSE 0.1198 and Spearman correlation 0.9794.

| Anchor condition | Realized mean error | Realized error RMSE | Maximum absolute error |
|---|---:|---:|---:|
| exact 25% | 0.0000 | 0.0000 | 0.0000 |
| normal-SD-0.25 25% | 0.0047 | 0.1360 | 0.2095 |
| shifted-plus-0.25 25% | 0.2500 | 0.2500 | 0.2500 |

The normal arm's declared generating SD is 0.25; its four realized errors are
not expected to have sample RMSE exactly 0.25. The realized values are retained
so that this single smoke draw cannot be described as a generic SD-0.25 result.

## Execution and readiness

All 12 anchor reviews passed with zero issue rows. All 12 fits returned
convergence code zero, and every free design was structurally identified.
Nevertheless, no fit was inference-ready.

| Design | Fits returned | Inference-ready | Numerical result | Boundary result |
|---|---:|---:|---|---|
| complete | 4/4 | 0/4 | terminal-gradient review | finite; no extremes |
| single-Rater plus 5% range link | 4/4 | 0/4 | converged | five high and four low extreme Persons |
| two-Rater connected cycle | 4/4 | 0/4 | converged | two high and one low extreme Persons |

The common terminal-gradient review tolerance was `1e-4`. Complete-design
maximum absolute terminal gradients were:

| Anchor condition | Terminal-gradient sup-norm |
|---|---:|
| none | 4.965448e-4 |
| exact 25% | 1.155526e-4 |
| normal-SD-0.25 25% | 7.678940e-4 |
| shifted-plus-0.25 25% | 1.599921e-4 |

The exact 25% arm was close to the gate but remained above it. Code zero does
not override that numerical review. The sparse-design gradients were all below
`1e-4`; their holds arose from typed extreme-Person exclusions instead.

## Descriptive recovery traces

The following values are retained for debugging only. Every row is non-ready,
there is one response seed, and neither differences nor rankings estimate an
operating characteristic.

| Design | Anchor condition | Free-Rater absolute RMSE | Person absolute RMSE | Person rank |
|---|---|---:|---:|---:|
| complete | none | 0.0534 | 0.1887 | 0.9864 |
| complete | exact 25% | 0.0577 | 0.1914 | 0.9862 |
| complete | normal-SD-0.25 25% | 0.0581 | 0.1942 | 0.9863 |
| complete | shifted-plus-0.25 25% | 0.0580 | 0.1847 | 0.9864 |
| single-Rater + 5% link | none | 0.2583 | 0.8294 | 0.8100 |
| single-Rater + 5% link | exact 25% | 0.2019 | 0.8054 | 0.8081 |
| single-Rater + 5% link | normal-SD-0.25 25% | 0.2040 | 0.8062 | 0.8026 |
| single-Rater + 5% link | shifted-plus-0.25 25% | 0.2016 | 0.8065 | 0.8028 |
| two-Rater cycle | none | 0.2726 | 0.5984 | 0.9078 |
| two-Rater cycle | exact 25% | 0.2332 | 0.5665 | 0.9124 |
| two-Rater cycle | normal-SD-0.25 25% | 0.2012 | 0.5619 | 0.9138 |
| two-Rater cycle | shifted-plus-0.25 25% | 0.2626 | 0.5782 | 0.9062 |

The apparent sparse-design improvements do not authorize 25%, and the
complete-design traces do not favor it. In particular, a noisy arm appearing
better than an exact arm in one non-ready seed is sampling and optimization
trace, not evidence that error helps.

## Decision and next diagnostic

The software smoke contract passed: all identities, pairing, assignment counts,
anchor counts, external seeds, support audits, fits, failure classifications,
and decision fields were complete. The scientific readiness gate failed because
`InferenceReady = FALSE` for 12/12 fits.

The frozen feasibility manifest must not run. The next work is a disjoint
diagnostic calibration with two separate questions:

1. reproduce the complete-design terminal-gradient hold while retaining the
   objective, polishing stages, tolerance, and parameter changes; and
2. quantify which response patterns create the three versus nine extreme
   Persons in the two sparse networks before deciding whether a new design
   needs additional rating information.

Any adjusted optimizer or data-generating design requires a new prospective
candidate identity. It cannot overwrite this smoke or its manifest.

## Reproduction policy

Runtime fingerprints are retained for within-run pairing of datasets, external
calibrations, and anchor sets. They are not a cross-machine numerical
reproduction criterion. The scientific checks are the declared response counts,
design densities, fit-return and failure classifications, numerical tolerances,
recovery measures, readiness decisions, and authority state. Retained fit time
is descriptive only. Source provenance is supplied by version control.

## Authority state

`SmokeExecuted = TRUE`

`SmokeExecutionContractPassed = TRUE`

`SmokeScientificReadinessObserved = FALSE`

`FeasibilityHandoffAuthorized = FALSE`

`FeasibilityExecutionAuthorized = FALSE`

`AppropriateAnchorRateSelected = FALSE`

`BroadSimulationAuthorized = FALSE`

`ConfirmationAuthorized = FALSE`

The smoke changes no public default, inference-readiness rule, FACETS claim,
PCM/GPCM decision, operational anchor percentage, or release gate.

## Post-run maintenance note

The runner now retains warnings from a failed support audit and classifies the
package's typed `mfrmr_estimability_error` before using a narrowly defined
legacy-message fallback. Neither path occurred in the retained 12-fit smoke.
Fresh R 4.4.2 and R 4.5.1 runs reproduced the declared fits and the relevant
numerical and decision checks. Result-object hashes are deliberately not
emitted or imposed on CRAN users; serialized numerical bytes are not the
scientific estimand.

## Subsequent minimal diagnostic

`rater-anchor-sparse-smoke-minimal-diagnostic-record-0.2.3.md` records the
bounded follow-up. Doubling maxit changed no complete-design solution, and
existing-response accounting showed that two Raters reduced nine extreme
Persons to three. The result does not reopen feasibility; it isolates the next
question as a prospective estimand decision about Person boundary coverage
versus Rater-scale recovery.
