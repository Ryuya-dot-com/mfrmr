# GPCM low-basin quadrature P1b record for 0.2.3

Status: completed deterministic calibration, 2026-08-12.
Contract: `mfrmr_gpcm_low_basin_quadrature_p1b_v1`.
Specification: `0.2.3-draft.1`.

This record follows the P1a result that the low-population-variance basin is a
locally stationary finite-grid candidate at q=31, whereas the default/high-
variance tail is not. It asks whether independent refits of that qualified
local candidate remain numerically coherent at q=31, 61, and 91 when every
returned vector is also evaluated with one held-out q=121 rule. It does not
certify a continuous-normal integral, freeze a quadrature or solution
tolerance, select a package solution, or authorize Hessian, interval, DFF,
fit, rank, separation, simulation, or capability claims.

## Execution identity

- branch: `development/0.2.3`
- parent commit: `6b3c2019746b3320fad80c8039150a4cf8c4f3e2`
- source-tree version: `0.2.3`
- P1b runner: `gpcm-low-basin-quadrature-p1b-0.2.3.R`
- P1b runner SHA-256:
  `80a53048c687d10011bdf9a5e389abc9b29458b60277ec28e75ad94a05aafd9a`
- P1b test: `test-gpcm-low-basin-quadrature-p1b.R`
- P1b test SHA-256:
  `1f1b93bd5366145fafb717d4939d857f1d20e7721e8d6af2213d9e6da4d4f4fb`
- P1a dependency contract:
  `mfrmr_gpcm_population_variance_profile_p1a_v1`
- P1a dependency SHA-256:
  `dc085c99f068ee5854ae67899c265b5f6a9e0fc7634ef31c064bdb0dc945064b`
- native refit quadrature: q=31, 61, and 91
- held-out common evaluation quadrature: q=121
- requested refit controls: L-BFGS-B, `maxit = 800`, `reltol = 1e-12`
- independent derivative check: central difference with relative step `1e-5`

## Mathematical and eligibility contract

For scenario `s`, source lane `a`, and finite quadrature rule `q`, the runner
starts from the declared P0b vector and obtains a local refit

```text
eta_hat(s,a,q) = local argmin_eta[-log L_q(eta) | declared source a].
```

It then evaluates, without reoptimizing, the q=121 objective, analytic score,
independent central-difference score, EAP, and posterior SD at that same
vector:

```text
h_121(s,a,q) = -log L_121(eta_hat(s,a,q)).
```

Thus q=121 is a common finite comparison rule, not a claim about the continuous
integral and not a q=121 optimum. Every vector is also transformed to labelled
additive, step, log-slope, natural-slope, population-regression, log-variance,
and variance coordinates before pairwise comparison.

Eligibility was fixed before execution:

- `qualified_low` starts from P0b `variance_low` and may enter q-pair
  comparisons only if native stationarity, common evaluation, and posterior
  materialization complete;
- `diagnostic_default` starts from P0b `default` and remains comparison-
  ineligible even if a later numerical field happens to improve; and
- neither lane is solution-selection or confirmation eligible.

This pre-result rule prevents retrospective admission of the unstable default
trace. It also keeps a finite q=121 value distinct from inference readiness.

## Execution result

All 24 declared refits returned finite vectors. The qualified lane passed the
existing native optimizer rule in all 12 arms and all 12 entered the declared
within-scenario q comparisons. The diagnostic-default lane passed in zero of
12 arms and entered none. Its outcome classifications were ten `review`, one
`fail`, and one additional `review` rather than evidence of a second qualified
solution. The resulting objects contain 12 qualified q-pair rows, 432 labelled
semantic-coordinate rows, 12 high/low reflection rows, and 12 exact
decision-signature comparisons.

### Qualified low-variance lane

| Scenario | Native objective range | q=121 objective range | sigma2 q31 | sigma2 q61 | sigma2 q91 | q=121 P01 EAP q31 / q61 / q91 |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `EXT5-P-HI` | `3.6948e-11` | `1.1369e-13` | `0.0300016285500861` | `0.0300016285502387` | `0.0300016285502387` | `0.619796228242621 / 0.619796228248041 / 0.619796228248038` |
| `EXT5-P-LO` | `3.6721e-11` | `1.1369e-13` | `0.0300013169475212` | `0.0300013169475722` | `0.0300013169475722` | `-0.619793179414785 / -0.619793179419764 / -0.619793179419766` |
| `EXT5-P-NEAR-HI` | `2.3874e-12` | `0` | `0.0254424999483536` | `0.0254424999483555` | `0.0254424999483555` | `0.553068320733864 / 0.553068320734036 / 0.553068320734034` |
| `EXT5-P-NEAR-LO` | `2.3874e-12` | `0` | `0.0254421640013917` | `0.0254421640013987` | `0.0254421640013987` | `-0.553064398517236 / -0.553064398517632 / -0.553064398517635` |

Across the 12 qualified q pairs, the largest observed differences were:

| Quantity | Maximum absolute difference |
| --- | ---: |
| common q=121 objective | `1.1369e-13` |
| additive coordinate | `8.3481e-12` |
| step coordinate | `9.1243e-12` |
| log-slope coordinate | `2.5635e-12` |
| population variance | `1.5262e-13` |
| common q=121 Person EAP | `5.4197e-12` |
| common q=121 posterior SD | `3.4550e-13` |

The maximum native analytic-versus-independent-numeric gradient discrepancy
in this lane was `1.6678e-8`; the corresponding q=121 maximum was `1.6658e-8`.
These are observed calibration values, not frozen tolerances. The largest
native and q=121 analytic gradient magnitudes were respectively about
`7.8941e-5` and `7.8941e-5`, and all qualified rows passed the package's
existing numerical rule.

### Diagnostic default/high-variance lane

The ineligible lane is strongly q- and path-sensitive:

| Scenario | Native objective range | q=121 objective range | max q=121 gradient | population-variance range |
| --- | ---: | ---: | ---: | ---: |
| `EXT5-P-HI` | `10.0170` | `5.7439e8` | `5.7420e8` | `6.5488e29` to `2.1086e35` |
| `EXT5-P-LO` | `10.0170` | `2.8241e11` | `2.8214e11` | `6.6853e29` to `5.3641e40` |
| `EXT5-P-NEAR-HI` | `10.1505` | `2.6043e5` | `1.1356e7` | `8.3605e25` to `8.3621e25` |
| `EXT5-P-NEAR-LO` | `10.1505` | `1.6150e4` | `5.3749e6` | `1.5131e24` to `1.5131e24` |

The q=61 diagnostic vectors have far smaller q=121 objectives than the q=31
and q=91 diagnostic vectors, but they still fail the native stationarity rule.
Their common P01 EAPs remain on the order of `1e12` to `1e15`; other diagnostic
arms reach `1e17` to `1e20`. Finite arithmetic therefore does not make this
lane a stable solution or ordinary Person-scale result. Large analytic/numeric
score discrepancies in this nonstationary lane are recorded as additional
diagnostic failure, not averaged with the qualified lane.

## Reflection audit

For the qualified exact high/low pair, the q=121 objective reflection
difference is about `4.72e-11` to `4.74e-11` across q. For the qualified near
pair it is about `2.1623e-10`. The corresponding population-variance
reflection differences are about `3.1160e-7` and `3.3595e-7`.

The exact-pair EAP sign-reflection RMSE is about `7.6265e-7`, with maximum
absolute difference about `3.0488e-6`; the near-pair values are about
`8.7787e-7` and `3.9222e-6`. Maximum posterior-SD reflection differences are
about `4.9667e-7` and `5.9576e-7`. These stable cross-q patterns are reported
without reverse-engineering a reflection tolerance. The ineligible default
lane retains enormous reflection discrepancies and cannot enter the same
denominator.

## Decision

P1b produces a deliberately conditional result:

- **GO, narrowly:** retain the qualified low-variance local basin as the sole
  input to the next boundary/solution-adjudication design; its q=31/61/91
  refits are mutually coherent under the held-out finite q=121 evaluator;
- **NO-GO:** do not treat the default/high-variance lane as a competing
  stationary solution and do not average its diagnostics into the qualified
  q comparison;
- **NO-GO:** do not infer continuous-integration accuracy or freeze a q,
  coordinate, reflection, or solution tolerance from these observed values;
- **NO-GO:** do not replace the package's current source solution solely from
  this local audit; and
- **NO-GO:** do not enter Hessian, interval, DFF, fit, rank, separation,
  broad simulation, or capability promotion yet.

The next admissible work is not a larger q ladder by default. It is to decide
the population-boundary and competing-solution contract and to connect the
qualified local candidate to a prespecified source-fit selection rule. The
separate fixed-facet Rater endpoint lane also remains open. Only after a source
solution is admissible can uncertainty and downstream decision-invariance
gates have a statistically meaningful denominator.

## Verification

The ordinary focused suite tests the pinned P1a dependency and P1b runner,
two-lane plan, typed failure row, qualified-only pairwise rule, failed-arm
pairwise and reflection aggregation, reflected-lane eligibility, finite-
evaluation versus readiness signature, and a mutated signature. The 24-arm
calculation is explicitly opt-in through
`MFRMR_RUN_LONG_VALIDATION=true`; it is not imposed on ordinary package tests.
The lightweight suite reports 65 passed expectations with one intentional
long-run skip and no failures, errors, or warnings. The complete opt-in suite
reports 83 expectations in about 95.0 seconds with no failure, skip, error, or
warning. It retains
`ContinuousIntegralCertificate = FALSE`, `SelectionAuthorized = FALSE`, and
`ConfirmationAuthorized = FALSE` throughout. Runtime is descriptive only and
is not used as evidence of numerical or statistical validity.
