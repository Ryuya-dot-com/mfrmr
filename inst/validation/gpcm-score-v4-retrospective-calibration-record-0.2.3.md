# mfrmr 0.2.3 GPCM score v4 retrospective calibration record

Status: classification calibrated; numerical evidence incomplete, 2026-08-11.
No fit was run, the rejected v3 artifact was unchanged, and v4 is not frozen.

The no-fit evaluator binds rejected v3 result SHA-256
`7836d859cca48e9a3641d94edda000218bb9c9f2903d801d7b9c9f03da017f2e`
and prospective v4 rule SHA-256
`c746bd02b435e851af0ff89fff6320c34e66a1aa9fe8c52d0b6447689dd5a126`.
It reconstructs all 24 expanded log-slope vectors from the 376 saved
entrywise Jacobian rows and applies v4 without changing the source artifact.

Exactly one region changed: the six-level Criterion-owned workload stress
point moved from `extreme_slope_review_handoff` to `finite_slope_region`.
Its raw maximum was `3.0000000000000009`, raw excess
`8.8817841970012523e-16`, and error-derived construction allowance
`6.9055872131684756e-15`. All retained-solution classifications were
unchanged; v4 did not promote an estimated extreme trace.

The correct decision is
`classification_calibrated_numerical_evidence_incomplete`, not a v4 pass.
V3 did not calculate or save finite differences for the reclassified point,
because its frozen classifier had correctly treated that point as extreme.
The missing derivative cannot be reconstructed from aggregate score/Jacobian
tables. The rejected v3 result also lacks its consumed authorization row.

Consequently:

- classification calibration passes;
- one required finite-difference point is unavailable;
- the full numerical decision is incomplete;
- the old authorization schema is incomplete;
- `V4FreezeReady = FALSE`;
- confirmation, general tolerance, inference, and release promotion remain
  unauthorized.

The retrospective evaluator source SHA-256 is
`831fcd4683e46785291c832242867f1962b56ce3a142c09da78fcbc311d08025`.
Nineteen focused expectations verify artifact immutability, the unique region
change, retained-extreme preservation, missing finite-difference accounting,
and fail-closed authorization status.

Filling the missing evidence requires a new, explicitly calibration-only
deterministic boundary fixture and a runner that embeds its consumed
authorization record. Re-fitting the opened v3 confirmation cells would be a
result-dependent retry and is prohibited. The completion fixture must be
sealed before execution and cannot later serve as v4 confirmation. This is a
single bounded calibration task, not a large simulation.
