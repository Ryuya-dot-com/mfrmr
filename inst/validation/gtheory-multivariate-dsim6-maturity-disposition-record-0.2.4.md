# D-SIM-6 evidence-bounded maturity disposition (0.2.4)

Date: 2026-09-06
Scope: repository-internal package-capability validation
Disposition: `specified_negative_confirmation_complete`

## Evidence entering D-SIM-6

- D-SIM-0 v4 capability contract:
  `9b68d194e13625ec73992f314a9494e29c36f77838e0da19a15020f2af74a214`
- D-SIM-1 deterministic qualification:
  `6fd89f49fe6238a56bb5621fa07cfb2f7ddb4aba4d3323b69246a99620b937db`
- D-SIM-2 nonreserved plumbing run:
  `ff30e8e4ea321b18476eb031f4d43ccd3029f9f286c1b362ff656dad4bb658bc`
- D-SIM-5 complete assembly:
  `e95b1b51436c2de7e3a942a481f2d1c49302e93160cbf8c3e5ecfbffb666bb59`
- D-SIM-5 adjudication:
  `4c3f74548d578694d8cfe436a9cfd8b5a7190487334fa794ec11eb0b06cacb3d`
- D-SIM-5 artifact file SHA-256:
  `f97f84fec6ec83eba5bd4e4e58fe88713618ff4a3fc935a031b93f6b0cd7c735`

The confirmation is complete and valid as a negative result. Both ABS-PHI and
REL-G fail the frozen regular-interior acceptance set. Attempt accounting and
all applicable boundary/control checks pass, so this is not an execution,
denominator, or fail-closed failure.

## Maturity assignment

| v4 maturity | Assigned | Reason |
| --- | --- | --- |
| `specified` | yes | Estimands, design identities, failure rules, and evidence limits are executable and recorded. |
| `implemented` | no, at feature level | A narrow internal separate-univariate route is executable, but the declared multivariate capability is not a complete production/package surface. |
| `simulation_validated` | no | Both estimands fail D-SIM-5; D4-S006 fails every registered bias and coverage cell. |
| `reference_validated` | no | The base-R overlap checks coefficient transformation only and is not an independent estimator/backend reference. |
| `stable` | no | Simulation and independent-reference prerequisites are unmet, and no public support envelope exists. |

The package-level maturity therefore remains `specified`. This does not erase
the implemented internal plumbing or the successful deterministic, identity,
and failure-accounting evidence. It prevents those narrower successes from
being mislabeled as a validated multivariate feature.

## What the negative result identifies

D4-S001, the Gaussian full anchor, has complete point and interval output. Its
four coverage cells pass; ABS-PHI standardized bias passes and REL-G
standardized bias narrowly fails. D4-S006 has complete output but materially
fails both estimands. ABS-PHI coverage is 0.8948 and 0.8852; REL-G coverage is
0.1716 and 0.1720. The latter is not caused by unavailable intervals.

D4-S006 simultaneously combines two strata, partial condition sharing,
distinct events, full crossing, balanced allocation, 10% MCAR, 1,000 objects,
eight raters, two repeats, a regular-interior variance regime, negative-PSD
cross-stratum covariance, and an ordinal-aggregate response. The confirmation
cell proves that this declared bundle is not validated. It cannot identify
which bundled axis, interaction, or estimator/interval seam caused the result.

## Next research unit

The next unit is a read-only root-cause audit followed, only if warranted, by
one new exploratory bridge design. It must:

1. keep the D-SIM-5 artifact and `fail` disposition immutable;
2. separate point-centering error from bootstrap-width/calibration error;
3. verify the D4-S006 truth projection and D-study allocation against the
   generated component contract without fitting a new model;
4. determine whether Gaussian fitting of the ordinal aggregate, partial
   incidence/MCAR handling, or their interaction is the first unsupported
   seam;
5. use axis-separating controls rather than another minimum-cardinality
   all-level cover; and
6. require a new versioned contract and disjoint seed namespace before any
   repaired method can receive confirmation evidence.

The first decision is scope, not optimization: either restrict the candidate
route to the observed-score distributions it can support, or justify a
different estimator/interval family for ordinal aggregates. A D4-S006-specific
correction, a relaxed cutoff, same-seed replay, or removal of the cell would be
post-outcome local optimization and is prohibited.

## Claim boundary

- D-SIM-0 through D-SIM-6 cycle complete: **yes**
- valid negative confirmation retained: **yes**
- package-level maturity: **`specified`**
- narrow internal plumbing implemented: **yes**
- simulation validation ready: **no**
- independent-reference validation ready: **no**
- multivariate G-theory public support ready: **no**
- GPCM/GRM/LLTM/response-time roadmap changed by this result: **no**
