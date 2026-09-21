# D-SIM-3 execution-bridge request-contract record

Status: frozen request denominator; worker and reconciliation remain open
Date: 2026-08-31
Scope: route meaning and exact request compilation only; no execution

## Decision

Freeze the executable meaning of both candidate route families before writing
the fit worker. Both routes must return complete, named, per-stratum vectors of
G and Phi. The package does not pool strata into one scalar, define decision
weights, or let route outcomes vote. This avoids inserting an undocumented
user decision rule merely because scalar output would be convenient to
implement.

The restricted multivariate route may estimate cross-stratum covariance, but
the current G/Phi calculation uses the marginal component diagonals only. The
separate-univariate route estimates each registered stratum independently.
Neither route silently treats facet count as latent dimension count or treats
an absent fitted off-diagonal as a scientific zero.

Compile every request required by the frozen 856 plan, while leaving each
request unauthorized and unexecuted. Historical shadow receipts demonstrate
mechanics but are not inherited by the superseding identity.

## Frozen identity

| field | value |
|---|---|
| contract | `MFRMR-GTHEORY-MV-DSIM3-EXECUTION-BRIDGE-REQUEST-V1` |
| contract hash | `c37fbedb03f0535d2e8aab1380949385ba10b0fc32b205f77df17074d52fd67e` |
| manifest hash | `69cf70189e1a72fbdda3af4fcca5d37873ef3e5f23d96c0d2cb4b1b87e8e1cef` |
| source SHA-256 | `1c647b20aeccc63ca58c9f2b6ba83c84ef71f7d8602e51f3effd822e20b859de` |
| parent plan contract | `23469d19faab020974a15d0b874ec1b0dac34eda8d6440d0db198b6452f08297` |
| parent plan | `58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a` |
| seed namespace | unopened `DSIM3-SUPERSEDING-856` |

## Route semantics

| property | restricted multivariate | separate univariate |
|---|---|---|
| backend / criterion | lme4 / REML | lme4 / REML |
| candidate requests | 8 | 42 |
| fit scope | joint stratum model | one fit per registered stratum |
| required metric shape | named per-stratum G/Phi vectors | named per-stratum G/Phi vectors |
| all registered strata required | yes | yes |
| scalar pooling across strata | prohibited | prohibited |
| decision-weight vector | absent | absent |
| cross-stratum covariance fitted | yes | no |
| cross-stratum covariance used in G/Phi | no | no |
| coefficient inputs | marginal component diagonals | marginal component diagonals |
| one-repeat representation | combined error block | combined error block |

This is an implementation contract, not a claim that the multivariate route
has already recovered the target, nor a claim that cross-stratum covariance is
irrelevant in every future estimand. A future pooled or utility-weighted
coefficient would require a separately named estimand and user-supplied rule.

## Exact request denominator

| registry | compiled | executed |
|---|---:|---:|
| scenario profiles | 21 | 0 |
| generation requests | 42 | 0 |
| backend requests | 50 | 0 |
| metric requests | 100 | 0 |
| terminal-orchestration requests | 92 | 0 |
| resource bindings | 5 | 0 |
| total executable/binding requests | 289 | 0 |

Generation requests bind the plan, dataset, scenario, replicate, 856 seed,
profile semantics, and qualified reference bundle. Backend requests additionally
bind the originating generation request, route, lme4/REML model-specification
class, and metric semantics. Each of the 50 candidate route requests has two
nonvoting metric requests, ABS-PHI and REL-G. The 42 dataset and 50 candidate
route units each have one future terminal-orchestration request, but no
terminal receipt is issued before an attempt.

## Readiness result

| check | result |
|---|---:|
| frozen gates | 8/10 pass |
| route-family semantics | 2/2 |
| exact request/binding denominators | 289/289 |
| inherited historical receipts | 0 |
| inherited mechanics qualifications | 0 |
| RNG streams opened | 0/42 |
| responses generated | 0/42 |
| backend calls / fits | 0/50 |
| fitted metrics | 0/100 |
| terminal receipts | 0/92 |

The two open gates are intentionally executable-boundary gates:

1. implement and shadow-qualify one common fit/metric worker plus the terminal
   and resource orchestrator for both route-family templates; and
2. rerun nonexecuting launch-readiness reconciliation against the exact
   environment and every compiled request hash.

## Next bounded action

Implement the common worker and orchestrator against nonreserved shadow
fixtures. Qualification must exercise every distinct design-dependent model
template, both route families, the combined one-repeat error representation,
complete named stratum output, failure/resource terminalization, and exact
receipt cardinality. It must not contain scenario-specific patches, scalar
pooling, adaptive weighting, partial launch, or historical receipt reuse.

Only after that shadow evidence is complete should reconciliation be repeated.
The 856 RNG stream, exploratory recovery study, inference, confirmation, and
public support remain closed.
