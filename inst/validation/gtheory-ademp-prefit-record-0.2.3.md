# Draft.83d2b0 scalable G-theory ADEMP pre-fit record

Date: 2026-08-09
Scope: repository-only structural pre-fit adjudication
Result: Draft.83d2b0 pre-fit gate passed; no backend fit or recovery gate run

## Outcome

All 22 executable Draft.83d2a datasets were regenerated and bound to the
Draft.83a observed-design audit, the exact scalable covariance-component rank
audit, and all 89 Draft.83d1 planned fit units. Nineteen scenarios and 77 fit
units are structurally eligible for a later method adapter; three scenarios
and 12 fit units are blocked before fitting.

The frozen pre-fit plan identity is:

`022ae8b01eb9febc3b1648bd232066fd11a56609e483e9e8b64d4a526ff94986`.

Eight focused tests and 71 expectations pass with no warning, skip, failure,
or error. The tests exhaustively compare equality masks on a finite fixture,
match the earlier dense covariance-rank oracle on four feasible scenarios,
verify the exact null directions, and audit the N=300 scenario without forming
a dense covariance-derivative design.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| digest | 0.6.39 |
| reformulas | 0.4.4 |
| lme4 parser availability | 2.0.6 |

`lme4` is available only to support the typed formula parser. Draft.83d2b0
runs no lme4, glmmTMB, or method-of-moments analysis-table fit.

## Scalable-rank validation

The exact equality-signature rank equals the dense Draft.83c1 covariance-
design rank for the four fixtures on which the dense design is feasible:

| Scenario | Retained rows | Rank/dimension |
| --- | ---: | ---: |
| `GT-EXACT-N030` | 480 | 7/7 |
| `GT-EXACT-R02-C02` | 400 | 7/7 |
| `GT-SPARSE-CYCLE-LOW` | 400 | 6/7 |
| `GT-NEG-DISCONNECTED` | 400 | 6/7 |

The N=300 complete scenario retains 19,200 rows and has exact rank 7/7. A
dense seven-component lower-triangular design would require 1,290,307,200
cells. The scalable audit instead enumerates the eight possible equality masks
for the three effective factors and retains only unique supported signatures.
No derivative matrix is materialized.

This reduction is exact for the registered independent scalar random-
intercept family. It is not a rank proof for random slopes, structured
residual covariance, multivariate component covariance, or latent GPCM/GT-IRT
likelihoods.

## Scenario and fit-unit adjudication

| State | Scenarios | Planned fit units |
| --- | ---: | ---: |
| eligible, likelihood information pending | 19 | 77 |
| blocked before fitting | 3 | 12 |
| total executable | 22 | 89 |

Every connected mid-density, unequal-hub, simplified nested, missingness,
bounded-score, local-dependence, and boundary scenario has full structural
component rank. Boundary scenarios remain eligible only for a numerical fit
attempt: they are expected to fail a later regularity/readiness gate rather
than be treated as pre-fit aliases.

The three blocked scenarios retain their distinct causes:

| Scenario | Rank/dimension | Blocking result |
| --- | ---: | --- |
| `GT-SPARSE-CYCLE-LOW` | 6/7 | `Person:Rater` and Residual have the same observed covariance signature |
| `GT-NEG-DISCONNECTED` | 6/7 | Person/Rater incidence is disconnected; the same component alias is also exposed |
| `GT-NEG-ALIASED` | 7/8 | unreplicated `Person:Rater:Criterion` is identical to Residual |

The computed null directions have the expected signed form: minus one on the
aliased interaction and plus one on Residual, with numerical zero on the
other components. Multiplication by the supported signature matrix is zero to
the test tolerance.

## Incidence and missingness interpretation

Fixed-effect-equivalent rank deficiency remains a diagnostic, not a proof of
covariance-component confounding. The earlier dense-audit capacity state is
superseded only for structural covariance rank. Disconnected incidence and an
unreplicated highest-order/residual identity are blocking; an unrecognized
issue fails closed.

Declared factor levels with no retained rows restrict level- and rank-recovery
metrics but do not by themselves block a component point fit. Unknown
missingness with omissions remains a sensitivity label and blocks an
ignorability interpretation, not the numerical attempt. MCAR, load-MAR,
score-MNAR, and unknown mechanisms therefore remain separate evidence lanes.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-ademp-prefit-prototype-0.2.3.R` | `80058b98c965b45f6bc34cb785127ac76504b10bb8fff8f1cb847ab0ebe3b910` |
| `gtheory-ademp-prefit-contract-0.2.3.md` | `0ddf1f97270e08fc0417c986e6a5817d5ff8f97d92a54505f9bd52250c190452` |
| `test-gtheory-ademp-prefit-prototype.R` | `b61fb3bf0752489bb60ce8940ccaddde8b060611614b6b7e3b540ec3f5423dd4` |

The record's own hash is omitted because recording it would change the file.

## Readiness and next gate

Every one of the 89 manifest rows has a generated-data, incidence, structural-
rank, method, and backend identity. All retain
`FitAttemptAuthorized=FALSE`, `AtomicResultRecorded=FALSE`,
`FitAttempted=FALSE`, `RecoveryEvidenceReady=FALSE`,
`InferenceReady=FALSE`, `CoefficientEligible=FALSE`, and
`DecisionReady=FALSE`. Consequently no fit-return, convergence, recovery, or
false-ready denominator has been entered.

Draft.83d2b1 must freeze method-specific adapters and likelihood-information/
regularity rules, then record one atomic success or typed failure for every
planned unit. The 12 pre-fit-blocked units must be recorded without calling a
backend. Effect extraction and one-replicate recovery accounting follow in
later Draft.83d2 slices; Draft.84 still owns full-refit interval validation.
