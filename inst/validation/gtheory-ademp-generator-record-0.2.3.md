# Draft.83d2a deterministic G-theory ADEMP generator record

Date: 2026-08-09
Scope: repository-only deterministic generation and replay audit
Result: Draft.83d2a generation gate passed; no backend fit or recovery gate run

## Outcome

The frozen Draft.83d1 registry replays to 22 generated scenario identities and
two typed anchor blocks. Every generated identity contains separate complete
potential, assigned, and post-missingness analysis tables; nominal truth;
finite observed-score projection truth where registered; generated level
effects; realized design audits; eleven generator-function hashes; and one
aggregate generator hash.

The all-scenario smoke identity is:

`1ed0856cc91ceb36115806dcf0f135ef7491d9e1ef53106276c0fd81584e0844`.

Ten focused tests and 185 expectations pass with no warning, skip, failure, or
error. These results establish generation and replay behavior only. No
analysis-table lme4 or glmmTMB fit is included. Draft.82 MoM is used only to
define the bounded complete-finite-table projection target; it is not counted
as a recovery fit.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| digest | 0.6.39 |
| reformulas | 0.4.4 |
| lme4 parser availability | 2.0.6 |

`lme4` is present only because the typed formula parser may use it when
`reformulas` is unavailable. This generation record does not fit an lme4
model.

## Registry and generation accounting

| Quantity | Result |
| --- | ---: |
| Registry scenarios | 24 |
| Generated scenarios | 22 |
| Typed anchor blocks | 2 |
| Registry hash | `9961558027b79fcc755696b7b7d15ecd629a91e6ac7380386e2f5a69a9f5ff8e` |
| Smallest complete-potential table | 400 rows |
| Largest complete-potential table | 19,200 rows |
| Missingness rates when registered | exactly 0.20 |
| Generator-defining function hashes per generated result | 11 |

All generated scenarios realize the exact registered number of observations
per Person and assignment density. Every declared Rater has at least one
assigned observation. Scores remain complete in `AssignedData`; omissions
appear only in `AnalysisData`.

## Assignment and workload checks

| Scenario | Density | Assigned rows | Rater-load CV |
| --- | ---: | ---: | ---: |
| `GT-SPARSE-CYCLE-LOW` | 0.125 | 400 | 0.02619 |
| `GT-SPARSE-CYCLE-MID` | 0.500 | 1,600 | 0.00000 |
| `GT-IMBAL-HUB-MOD` | 0.250 | 800 | 0.66175 |
| `GT-IMBAL-HUB-HIGH` | 0.250 | 800 | 1.05560 |

The last two rows hold density and observations per Person fixed while
changing only the frozen workload weighting. Thus the high/moderate contrast
is not an accidental sparsity contrast. The low connected cycle is nearly,
but not arithmetically perfectly, balanced because 100 Persons do not complete
an integer number of all rotating cell offsets; its connected-design purpose
is unaffected and the realized CV is retained rather than rounded to zero.

## Bounded-score target checks

| Scenario | Declared K | Observed K | Endpoint rate | Projection hash |
| --- | ---: | ---: | ---: | --- |
| `GT-BOUNDED-K03-ENDHI` | 3 | 3 | 0.50 | `6a0b6e6caddb646bc841088900be627c691bb1df03c2c44431fc77568152a325` |
| `GT-BOUNDED-K05-ENDMOD` | 5 | 5 | 0.25 | `81493c5eb15903c74bfe900364b6e7e466b3a902f5575a8afa31e55aa36206fc` |
| `GT-BOUNDED-K07-ENDNONE` | 7 | 5 | 0.00 | `fdbbc7b23ee8153e6dfa517d064af2b3db1945e1038db54d6ca639181502fc6f` |

The seven-category zero-endpoint cell intentionally uses categories 2--6 and
does not use endpoints 1 or 7. All three projection vectors contain seven
finite semantic component values and differ from their latent nominal
variance vectors.

## Missingness checks

| Scenario | Retained | Omitted mean score | Retained mean score | Omitted mean Rater load | Retained mean Rater load |
| --- | ---: | ---: | ---: | ---: | ---: |
| `GT-MISS-MCAR` | 1,280 | 0.2774 | 0.2259 | 400.00 | 400.00 |
| `GT-MISS-MAR` | 640 | -0.1491 | -0.0163 | 243.00 | 101.69 |
| `GT-MISS-MNAR` | 640 | 1.7949 | -0.8060 | 127.67 | 123.40 |
| `GT-MISS-UNKNOWN` | 640 | 1.9557 | 0.0944 | 249.12 | 186.73 |

These are deterministic one-replicate mechanism diagnostics, not empirical
effect estimates. They verify that MCAR does not use Rater load, load-MAR
preferentially omits high-load rows, and score-MNAR preferentially omits high
scores. They do not establish missingness ignorability or estimator validity.

## Dependence, boundary, and negative controls

The empirical lag-one residual correlations are 0.2530 for registered
`rho=0.25` and 0.4999 for `rho=0.50`. These cells retain the
independence-model-reference target and cannot enter exact component recovery.

The near-zero boundary has nominal Rater variance `1e-10` and a nonconstant
small generated effect vector. The exact-zero boundary has nominal variance
zero and an all-zero Rater effect vector. Both remain expected-not-ready.

The simplified nested Site/Rater scenario passes the Draft.83a observed-design
screen. The two negative controls fail as intended:

| Scenario | Screen | Recorded issue core |
| --- | --- | --- |
| `GT-NESTED-BAL` | pass | none |
| `GT-NEG-DISCONNECTED` | fail | disconnected Person/Rater incidence, rank deficiency, no residual df |
| `GT-NEG-ALIASED` | fail | no residual df; highest-order/residual not separable |

Interaction-rich nested terms were not forced through the current rank audit.
Their identification requires a later operator/information contract rather
than inference from the simpler nested pass.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-ademp-generator-prototype-0.2.3.R` | `7a38a7ca55d2c3faf9107e679eb3b5627315abddaf17a88e1a8c73934166e182` |
| `gtheory-ademp-generator-contract-0.2.3.md` | `d5792a311630ebe6662c6446b8aff834e7a5b728ce43915fdb9fca7c1284718f` |
| `test-gtheory-ademp-generator-prototype.R` | `0621f5cd325b575313717bf6f1d315a497eaf07e2678117560dde4e4154093b0` |

The record's own hash is omitted because recording it would change the file.

## Readiness and next gate

Generated results set `GenerationEvidenceReady=TRUE` and retain
`EstimationReady`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` as false. Anchor results also keep generation evidence false.

Draft.83d2b must now attach pre-fit incidence audits and atomic backend
success/failure rows to all 89 manifest units, preserve paired data identity,
extract variance and centered conditional effects, and demonstrate zero false
readiness in boundary and identification controls. It remains a one-replicate
software smoke. A separately designed feasibility pilot must freeze Monte
Carlo precision and replication counts before confirmation, and Draft.84 must
validate full-refit interval coverage.
