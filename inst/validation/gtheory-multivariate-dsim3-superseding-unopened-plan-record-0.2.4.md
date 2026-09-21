# D-SIM-3 v4 superseding unopened-plan record

Status: frozen and unopened; shared execution bridge next
Date: 2026-08-31
Scope: identity and denominator plan only; no exploratory execution

## Decision

Issue a new D-SIM-3 plan rather than mutating the historical unopened 855
plan. Preserve every scientific unit in the old denominator one-to-one, but
assign a new plan identity, new attempt identities, and a disjoint unopened
856 seed namespace. Bind each of the 21 scenario profiles to its qualified
design-dependent truth projection, incidence-aware allocation operator, and
separate-univariate truth coefficient identity.

The old plan remains immutable evidence of what was specified before the
truth/operator/metric qualification sequence. Reusing its attempt or seed
identities would make a later receipt ambiguous about which semantic bundle
was executed. A one-to-one supersession map preserves comparability without
creating that ambiguity.

## Frozen identity

| field | value |
|---|---|
| contract | `MFRMR-GTHEORY-MV-DSIM3-SUPERSEDING-UNOPENED-PLAN-V1` |
| contract hash | `23469d19faab020974a15d0b874ec1b0dac34eda8d6440d0db198b6452f08297` |
| plan hash | `58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a` |
| source SHA-256 | `0d1bc758c17ec98b2cafa57868d2d6070a94e339cfcf252346ada611107046fc` |
| superseded plan hash | `b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7` |
| truth manifest | `97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5` |
| operator manifest | `526298d0c598e34a92e98b96b7bc59c0714fc053636bc25ea423d4c87c895093` |
| truth-metric manifest | `969afca1d3fb23a68d58500cd6959152b385b0e9b2e64c25cc75a3cd79feb37c` |
| new seed band | `DSIM3-SUPERSEDING-856` |
| planned seed range | `856001001`--`856021002` |

## Denominator preservation

| registered unit | old | new | one-to-one semantic map | identity reused |
|---|---:|---:|---:|---:|
| scenario profile | 21 | 21 | 21/21 | not an attempt identity |
| dataset attempt | 42 | 42 | 42/42 | 0 |
| route unit | 210 | 210 | 210/210 | 0 |
| dataset-estimand unit | 84 | 84 | 84/84 | 0 |
| route-estimand coordinate | 420 | 420 | 420/420 | 0 |
| deterministic control definition | 3 | 3 | 3/3 | 0 plan-unit identities |

The route disposition denominator is unchanged: 50 qualification candidates,
40 planned negative-control prefit rejections, 8 frozen not-applicable units,
and 112 blocked unimplemented-contract units. The old 14 denominator rules,
13 terminal states, five resource scopes, and route-disposition map are copied
into the new contract exactly. This is semantic inheritance, not inheritance
of historical execution qualification or receipts.

## Semantic binding boundary

All 21 datasets bind one scenario-specific reference bundle containing:

- the qualified truth-projection row hash;
- the qualified profile allocation-operator hash; and
- the qualified profile truth-coefficient hash.

The truth coefficient is directly applicable to the 42
`separate_univariate` route units and their 84 G/Phi coordinates. The other
168 route units retain the same scenario reference but are explicitly marked
`scenario_reference_not_route_qualified`. Thus the plan does not silently
generalize the separate-univariate coefficient contract to a multivariate or
otherwise unsupported output shape.

## Readiness result

| check | result |
|---|---:|
| frozen gates | 9/10 pass |
| profile truth/operator/metric bundles | 21/21 |
| old/new dataset ID overlap | 0 |
| old/new route ID overlap | 0 |
| old/new estimand-unit ID overlap | 0 |
| old/new coordinate ID overlap | 0 |
| old/new seed overlap | 0 |
| downstream interfaces rebound to new identity | 0/6 |
| RNG streams opened | 0/42 |
| responses generated | 0/42 |
| backend calls, fits, fitted coefficients | 0 |

The single blocking gate is `shared_execution_bridge_rebound`. Generation,
route admission, fit/metric work, terminal orchestration, resource-controller
requests, and launch-readiness reconciliation must each be rebound to the new
plan identity. Earlier shadow qualifications remain useful implementation
evidence, but they are not automatically valid receipts for the new attempts.

## Next bounded action

Build one common identity-bound execution bridge and qualify it first on
nonreserved shadow fixtures. It must cover generation request construction,
both candidate route families, fitted G/Phi calculation, terminal receipt
orchestration, and the existing five-scope resource controller. Then rerun a
nonexecuting launch-readiness reconciliation against the exact 856 plan.

Do not open the 856 streams during bridge construction or interpret 9/10
planning gates as simulation-validation evidence. Exploratory execution,
recovery, uncertainty, model adequacy, inference, decision, and public support
all remain false.
