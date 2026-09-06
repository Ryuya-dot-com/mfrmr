# D-SIM-2 v4 nonreserved plumbing-smoke record

Status: plumbing complete; D-SIM-3 design construction allowed, execution closed
Date: 2026-08-30
Contract: `MFRMR-GTHEORY-MV-DSIM2-PLUMBING-V1`
Parent D-SIM-1 hash: `6fd89f49fe6238a56bb5621fa07cfb2f7ddb4aba4d3323b69246a99620b937db`
Contract hash: `5202fcbe1975c3fc898f557b06c50f6fdcbb1cd248b745eb4500d42b163d960b`
Observed run hash: `ff30e8e4ea321b18476eb031f4d43ccd3029f9f286c1b362ff656dad4bb658bc`

## Scope

D-SIM-2 exercises one attempt, one nonreserved fixture, and one representable
backend route through:

```text
generator -> fit -> G/Phi metric -> terminal state
```

It is a plumbing test. It is not a recovery study, simulation-validation
result, backend comparison, inference result, user recommendation, or public
support claim. Automatic expansion to a second scenario or route is forbidden.

The fixture is `FX-C1-I2-BAL`, using nonreserved fixture seed `854000001` and
720 response rows. The seed registry was inspected only to establish that this
fixture does not collide with a planned seed. No planned RNG stream was opened.
The generated truth audit was not released to the fit or metric stages.

## Design and route identity

The exercised cell is `S2-SHARED-DISTINCT-C1`:

- raters are shared across the two strata;
- response events are distinct by stratum, rater, and within-cell replicate;
- Object, Rater, and Object:Rater covariance blocks are unstructured;
- the level-1 residual is one common independent variance; and
- the route is `lme4` REML.

This is the narrow matched-backend intersection already represented by the
internal prototype. It is not a sixth D-SIM-1 canonical anchor and does not
stand in for the linked-event residual design. `lme4` was chosen because the
declared diagonal level-1 residual is in its qualified representation class.
No second backend was invoked or allowed to vote.

## Observed stage result

| Stage | Result | Evidence |
|---|---|---|
| generator | completed | 720 rows; nonreserved seed; no collision |
| fit | completed | `identified_point_fit`; point gate passed |
| metric | completed | finite separate `REL-G` and `ABS-PHI` values |
| terminal state | completed | `plumbing_complete_nonpromoting` |

The fitted log likelihood was `-801.28020718433277`. The equal-weight,
plumbing-only metric produced `G = 0.92682817864050959` and
`Phi = 0.87081461385536474`, preserving `Phi <= G`. These values were compared
with neither generating truth nor a target and are not promotable evidence.

The exact replay reproduced the run, generation-receipt, fit-receipt,
metric-receipt, G, and Phi identities.

## Hash record

| Object | Hash |
|---|---|
| generation receipt | `10cf5d124ea09caf1fe7d67e5d16fc9b11ef9844de327f1f74f8f569b3098fd1` |
| fit receipt | `ccf20052eec6c1445c73cdcf88f2f1133054b96db279f06e0970d918d99341f8` |
| matched fit result | `1fcbca46df0209220eb24bba51488fed4fa693920a86c0606c0f2a6484f32988` |
| metric receipt | `4cc3bc6e6471c08e88fafa8995949a4ba90a9e30975a48d541e6c50cf65743c9` |
| full run | `ff30e8e4ea321b18476eb031f4d43ccd3029f9f286c1b362ff656dad4bb658bc` |

The observed run hash is environment-bound to the recorded implementation and
`lme4 2.0.6`; the portable contract hash is frozen independently.

## Readiness boundary

The bounded internal route is now implemented as plumbing. The overall
multivariate G-theory feature remains at `specified` maturity because one
fixture and one route do not establish operating behavior across the v4
multiverse.

Still false are planned RNG execution, truth recovery comparison, backend
comparison, simulation validation, reference validation, inference, decision,
and public support.

D-SIM-3 subsequently froze an exploratory coverage manifest with 21 design
cells covering all 44 levels and all 603 feasible dataset-axis pairs. Those
cells generated zero datasets and opened no planned RNG stream. Its separate
execution contract subsequently froze a 42-dataset, 210-route, 420-coordinate
denominator in the 855 band without executing it. Full-profile pre-execution
qualification is still required before any multiverse response may be generated.
