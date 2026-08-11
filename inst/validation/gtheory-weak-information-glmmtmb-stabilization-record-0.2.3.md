# Draft.83d2b2b1g glmmTMB stabilization design record

Status: prospective design and manifest complete; runner absent and execution
unauthorized, 2026-08-10.

## Frozen identity

| Object | SHA-256 / scientific identity |
| --- | --- |
| b1e numerical execution | `37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94` |
| b1f typed-replay result | `e200a9ee7984bbc3be32ab5ef209ce2eb26c0b42c8df3ad758bab7baf559f8c1` |
| b1g stabilization contract | `8feb8695c655c0621d61863e00d82fffe7fd5d7b619761decefaed6e89b0c326` |
| b1g stabilization manifest | `92435f41b0dab7e13bf1febcf6e043fc1ae8d4a2cb7d159401dd1d78b4c9ff3e` |
| contract artifact | `4f5fe7b92e7625e3550346beb37c3148eb7a7ffac148d474a2b6e874a21fed64` |
| design prototype | `acceb71ca7ee909db621a0dacd1184c0e6749599175e300b990b354fcd629b1e` |
| focused test source | `ecb5678c1dfad3767beeb1c7afc52da04a5660e51c27ea42bae21f7b186e03b6` |

The contract hash binds the exact b1e/b1f identities, six-profile directed
acyclic graph, ten start blocks, package versions, derivative schema,
Richardson arguments, reporting grids, prohibited actions, and function
hashes. The manifest hash additionally binds all 9,000 planned rows.

## Manifest accounting

| Quantity | Exact count |
| --- | ---: |
| viewed b1e glmmTMB base routes | 1,500 |
| independent datasets | 750 |
| likelihood identities per dataset | 2 |
| profiles per base route | 6 |
| cold-root pairs | 3,000 |
| dependent self/cross-start pairs | 6,000 |
| planned full/reduced pairs | 9,000 |
| planned backend fits | 18,000 |
| duplicate stabilization route IDs | 0 |
| missing parent-route identities | 0 |

Every dataset has 12 manifest rows. Each profile has all 1,500 routes. The two
algorithms each appear in three profiles; cold, self-restart, and cross-
algorithm lineages each appear symmetrically twice. Parent failure remains an
explicit dependent failure rather than silently becoming a cold fit.

## Start and derivative schema probe

A one-route, already-viewed interface probe was used only to verify that the
installed glmmTMB 1.1.14 surface supports the planned schema. It is not a
stabilization result and does not enter a readiness denominator.

The returned canonical blocks were `beta`, `betazi`, `betadisp`, `b`, `bzi`,
`bdisp`, `theta`, `thetazi`, `thetadisp`, and `psi`. For the probed full model,
their lengths were 1, 0, 1, 924, 0, 0, 6, 0, 0, and 0; the corresponding
reduced-model `b` and `theta` lengths were 920 and 5. This confirms why full
and reduced starts cannot be exchanged. A subsequent closure audit found that
`parList()` defaults its full `par` argument to mutable `last.par`; therefore
the runner must snapshot `last.par.best` immediately and call
`parList(x=fit$fit$par, par=joint_best)`. The earlier one-route objective
observation remains non-evidential schema telemetry and is not used to justify
the corrected extraction rule.

Restarting the same viewed fit with all exact blocks reproduced its reported
objective in this single probe. Nevertheless, the full-model maximum absolute
outer gradient was about 2.79e-4 and its symmetrized Richardson Hessian had a
minimum-to-maximum-absolute eigenvalue ratio about 5.70e-10, whereas the
reduced values were about 3.40e-6 and 3.27e-4. This observation is schema
telemetry only. It does not define a gradient or Hessian cutoff and cannot be
generalized from one route.

## Tests and fail-closed controls

Five focused tests and 73 expectations pass, including:

- exact six-profile DAG and symmetric algorithm/lineage accounting;
- canonical-order invariance of all ten start blocks;
- rejection of missing, duplicated, nonnumeric, or non-finite blocks;
- exact 9,000-row route and parent closure;
- rejection of a profile cycle;
- rejection of changed b1e or b1f identities; and
- reproduction of the exact b1g contract and manifest hashes from the retained
  upstream ledgers.

## Readiness adjudication

- `ManifestReady = TRUE`;
- `StabilizationRunnerImplemented = FALSE`;
- `StabilizationExecutionAuthorized = FALSE`;
- `NumericalStabilizationReady = FALSE`;
- `NumericalSensitivityEvidenceReady = FALSE`;
- `CalibrationEvidenceReady = FALSE`;
- `ThresholdFrozen = FALSE`;
- `InferenceReady = FALSE`; and
- `DecisionReady = FALSE`.

The next slice must implement and test the atomic runner, including exact
parent-start equality, derivative hashes, typed parent failure, checkpoint
identity, interruption/resume, and a small viewed-data covering smoke. Only a
separate subsequent authorization may permit all 18,000 fits. Calibration
replicates 201--300, bootstrap operating characteristics, estimator selection,
coefficients, and D-study decisions remain prohibited.
