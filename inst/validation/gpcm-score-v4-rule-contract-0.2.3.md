# mfrmr 0.2.3 GPCM score-rule v4 no-execution contract

Status: prospective rule specified after negative v3 confirmation, 2026-08-11.
No v4 calibration or confirmation has been executed. V3 remains rejected.

## Scope of the change

V4 changes only the classification of contract-constructed points intended to
lie on the inclusive expanded-log-slope boundary. The four analytic,
finite-difference, expanded-log-Jacobian, and positive-slope-Jacobian combined
rules are byte-for-byte numerically unchanged from v3. Retained solutions
receive zero boundary allowance and cannot be rescued from the extreme-slope
review handoff.

## Error-derived construction allowance

Let `u = .Machine$double.eps / 2` be IEEE-754 binary64 unit roundoff, `B = 3`,
and `z_free` contain the `n` represented free log slopes used to reconstruct
the final sum-zero coordinate. Define

`gamma_n = n*u/(1-n*u)`.

For contract-constructed points only, the inclusive comparison uses

`B + 2*u*sum(max(1, abs(z_free)))
   + gamma_n*sum(abs(z_free))
   + 2*u*max(1, B, max(abs(z_expanded)))`.

The three terms conservatively cover input construction rounding, sequential
summation, and final magnitude/comparison rounding. This is a point-specific
forward-error bound, not a fitted tolerance and not a general optimizer box.
A material excess remains an extreme handoff.

For the six-level stress construction implicated by v3, the total calculated
bound is approximately `6.905587e-15`; the observed representational excess
was `8.881784e-16`. A constructed point is therefore classified as intended,
while the same represented vector supplied as `retained_solution` remains
extreme because its allowance is exactly zero.

## Authorization provenance

Every future saved v4 result must embed the exact consumed authorization row,
including contract version, runner and manifest identities, authorization
hash, output target, process ID, issue/consume timestamps, and state flags.
Every field is mandatory. Post-hoc reconstruction is forbidden.

## Evidence boundary

The opened v3 confirmation fixtures may be used only for retrospective v4
calibration of this prespecified rule. They cannot confirm v4. Before new data
are opened, the v4 rule, source identity, calibration interpretation, result
schema, and authorization embedding must be reviewed and frozen. A later
confirmation needs a new structurally disjoint fixture family.

The rule source SHA-256 is
`c746bd02b435e851af0ff89fff6320c34e66a1aa9fe8c52d0b6447689dd5a126`.
Twenty-three focused expectations cover unchanged numerical thresholds,
forward-error construction, constructed-versus-retained separation, material
excess rejection, and mandatory authorization provenance.

V4 currently authorizes no execution, confirmation, general score tolerance,
boundary claim, inference, or release promotion.
