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
and result hashes were complete. The scientific readiness gate failed because
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

## Deterministic identities

Prospective registry SHA-256:

`d5e014472d93f31aef336388e7232bbfdc8d81635dace84833dfa9b50864ed2e`

Smoke manifest SHA-256:

`b69d015673965c2286f50c1ed943968c7711de42ba60c45a249635fd13d8d949`

Canonical-hash helper SHA-256:

`c229fc37f671cf68f7ba8ba5ee80da8b2cf8a5bbfca783081486b785890e276f`

Canonical-hash focused-test SHA-256:

`4a14dcc56c541124eca51a52f16e5ece295156dc090ad51f7c99d75c3b0a660a`

Prospective-contract file SHA-256:

`b628bcfd5ebe11f23e30ba27738a5e5b1e0a8221d14a43c83fbd47489518a501`

Stress-pilot helper file SHA-256:

`0165dff013f959eccc229ff44d2f79474e664aff822cf4934ed76c75f75ad9ab`

Smoke-runner file SHA-256:

`d86fb1c1ea73490ad767c6dfde5f2b84d1e3cbff32c7f95a74adfeaefc58fb67`

Focused-test SHA-256:

`bfb38037bfec244291808316d3d35d79ef1429dd804d86993e410723ead790c8`

Deterministic evidence SHA-256 (elapsed time excluded):

`172856a67442812f421511c014da2497f809eb04fe227327c7f11d57cf50cfb1`

Deterministic summary SHA-256 (elapsed time excluded):

`24fe3bdf216aa759e0ab673bd7c579d738765bb295ce9e32a31bf02abe9dc4a4`

The evidence and summary identities matched fresh R 4.4.2 and R 4.5.1 runs
after canonicalization. Retained fit time is descriptive only.

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

The runner retains warnings from a failed support audit and classifies the
package's typed `mfrmr_estimability_error` before using a narrowly defined
legacy-message fallback. Neither path occurred in the retained 12-fit smoke.
The earlier R-object digests differed from the historical record even when the
pre-maintenance runner was replayed, while fresh Windows R 4.4.2 and R 4.5.1
runs agreed with each other. This is consistent with, but does not prove, a
Mac-versus-Windows runtime difference: serialized attributes, encodings, R
versions, numerical libraries, or final floating-point bits can all contribute.
The replacement hashes are derived from canonical evidence tables, while code
and test identities normalize UTF-8 text to LF. Evidence identities matched
exactly in R 4.4.2 and R 4.5.1. Scientific values and authority states did not
change.

## Subsequent minimal diagnostic

`rater-anchor-sparse-smoke-minimal-diagnostic-record-0.2.3.md` records the
bounded follow-up. Doubling maxit changed no complete-design solution, and
existing-response accounting showed that two Raters reduced nine extreme
Persons to three. The result does not reopen feasibility; it isolates the next
question as a prospective estimand decision about Person boundary coverage
versus Rater-scale recovery.
