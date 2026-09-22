# Draft.83d2b2b1g9 lme4 objective-reference preflight record

Status: completed repository-only analytic preflight, 2026-08-10. This run
used only a deterministic synthetic crossed random-intercept fixture. It did
not generate or read nonreserved replicates 901--902, calibration 201--300, or
confirmation 501--700.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| upstream b1g8 contract | `1216ae3591fc026a61b4fb6581ebe79e33d34e4e2b6bf04a969a4c93c3e06689` |
| upstream b1g8 execution receipt | `46ea4be751a3c54904bac28da31f15e5e05f347b9e8f10a1194887f55557807d` |
| b1g9 analytic audit | `83faaaf570bd814c000924aa21396ade00958fb8134cec553a0eaa985382ca67` |
| b1g9 preflight contract | `20d6fb656ac2f2996e5881a07729a3e4fb2f417859f90efde7ee72784ba62092` |

The audit environment was R 4.6.1, lme4 2.0.6, Matrix 1.7-6, and numDeriv
2016.8-1.1. The lme4 objective/accessor functions and every b1g9 function are
source-hashed in the contract.

## Objective and derivative result

The independent dense formulas agree with lme4's theta-only closures in both
likelihood modes:

| mode | oracle objective | absolute objective difference | maximum gradient difference | maximum gradient magnitude |
| --- | ---: | ---: | ---: | ---: |
| ML | -76.10959 | 3.55e-13 | 1.90e-09 | 1.30694 |
| REML | -75.35420 | 1.11e-12 | 4.93e-09 | 1.15873 |

At the fitted theta, the independent criterion differs from the selected
lme4 fit accessor by at most `3.70e-13`; the selected accessor and
`-2*logLik(..., REML=mode)` agree exactly. Repeating the off-optimum closure
evaluation before and after a perturbed evaluation produces range zero in
both modes.

For the exact-zero identity fixture, the full-model objective with Rater
theta fixed at zero equals the fitted reduced-model objective exactly in both
routes and modes:

| mode | full at boundary | reduced | absolute difference |
| --- | ---: | ---: | ---: |
| ML | 86.50461 | 86.50461 | 0 |
| REML | 87.74175 | 87.74175 | 0 |

## Accessor negative controls

The installed `devfun2()` body contains `refitML()`. For the ML fixture its
`basedev` is -76.88599, whereas evaluation at its advertised optimum returns
103.2940. Thus it both lacks REML-mode preservation and fails the local
baseline-reproduction control; it is ineligible.

For the REML fixture, `REMLcrit(fit)` is -76.04388, while
`deviance(fit, REML=TRUE)` returns -76.85410. The source-hashed
`deviance.merMod` body routes that call to `devCrit(..., REML=FALSE)`, so the
convenience argument is also ineligible. The negative controls prevent a
plausible-looking ML-at-REML-fit value from being mislabeled as the REML
criterion.

## Gate interpretation

Seven focused tests with 67 expectations pass, including independent
objective/gradient agreement, fit-accessor identity, evaluation-order
stability, exact-zero reduction, unsupported-coordinate/weight rejection,
namespace implementation negatives, upstream mutation, and exact hash
checks.

`Lme4ObjectivePreflightReady=TRUE` is intentionally narrower than reference-
method readiness. No lme4 nonreserved objective has yet been subjected to the
deterministic multialgorithm solver, Newton polishing, derivative-resolution,
curvature, boundary-profile, or sidecar-integrity gates. Reference coverage
therefore remains two of four lanes, and calibration, production
stationarity, confirmation, inference, coefficients, and D-study decisions
remain false or unauthorized.
