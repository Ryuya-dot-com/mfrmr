# mfrmr 0.2.3 GPCM score v4 boundary-completion design

Status: calibration-only fixture sealed; execution not authorized, 2026-08-11.
No fit or finite-difference result has been opened.

This design fills exactly the one evidence gap identified by no-fit v4
retrospective calibration. It contains one Criterion-owned slope/step GPCM
scenario with 31 Persons, 3 Raters, 6 Criteria, 4 categories, and 558 completely
crossed deterministic responses. `B`/`W`/`E` level namespaces are new. Every
Rater-category and Criterion-category cell has positive support.

The fixture SHA-256 is
`57ad036bb60bd0f2cff0d2666584f3cb6d51ccb7255f4993068803a3c15a2c89`.
The design source SHA-256 is
`bf6ae572a3c0c2253c6fbd35fc5138eaaae92728d7d9588f1d50cebfafcae838`.
It binds v4 rule SHA-256
`c746bd02b435e851af0ff89fff6320c34e66a1aa9fe8c52d0b6447689dd5a126`
and retrospective evaluator SHA-256
`831fcd4683e46785291c832242867f1962b56ce3a142c09da78fcbc311d08025`.

Only `finite_slope_stress_forward` is in scope. The complete future denominator
is four parameter-class evidence rows, 24 coordinate rows, one point row, and
30 entrywise Jacobian rows. The represented six-level maximum exceeds three by
`8.881784e-16`, within its independently derived `6.905587e-15` construction
bound.

The decision is
`boundary_completion_design_sealed_execution_not_authorized`. The fixture is
permanently `CalibrationOnly = TRUE` and `ConfirmationEligible = FALSE`.
Execution must use a dry-run-by-default runner, a separate target-bound
authorization, and a saved result that embeds the exact consumed authorization
row. No rule, fixture, quadrature, optimizer, stopping, or point-construction
change is permitted after execution. The fixture cannot be reused for later v4
confirmation.
