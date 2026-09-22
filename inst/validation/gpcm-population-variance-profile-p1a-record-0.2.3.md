# GPCM population-variance nuisance-profile P1a record for 0.2.3

Status: completed deterministic calibration, 2026-08-12.
Contract: `mfrmr_gpcm_population_variance_profile_p1a_v1`.
Specification: `0.2.3-draft.1`.

This record follows the endpoint P0b finding that a prespecified low-variance
start has a materially lower fixed-q objective than the default source trace.
It asks whether that difference remains after fixing `log_sigma2` on a bounded
grid and reoptimizing every other free coordinate. It does not certify a global
profile, a zero- or infinite-variance limit, continuous-normal integration, a
selected solution, Hessian uncertainty, or any GPCM/DFF/fit/rank capability.

## Execution identity

- branch: `development/0.2.3`
- parent commit: `c1cd548a503acb4390f23da7874e8367140c1cfe`
- source-tree version: `0.2.3`
- P1a runner:
  `gpcm-population-variance-profile-p1a-0.2.3.R`
- P1a runner SHA-256:
  `dc085c99f068ee5854ae67899c265b5f6a9e0fc7634ef31c064bdb0dc945064b`
- P1a test:
  `test-gpcm-population-variance-profile-p1a.R`
- P1a test SHA-256:
  `c3bdd451d409d95df0129470f74c0e09af363d6b7af35f78e3d38fc97a823cbc`
- P0b dependency contract:
  `mfrmr_gpcm_endpoint_solution_stability_p0b_v1`
- P0b dependency SHA-256:
  `63dbb2ae1ec6b9df56e252d8d7bf55a2ff61870c17d2c366da6ddedd46ca8364`
- quadrature: q=31 only
- fixed coordinate: one `log_sigma2` coordinate
- nuisance dimension: 23 of 24 identified free coordinates
- independent anchor starts at every grid point: `default` and `variance_low`
- requested profile controls: L-BFGS-B, `maxit = 400`, `reltol = 1e-10`
- polish contract: the package's same objective-nondegrading L-BFGS-B ladder,
  followed when needed by bounded BFGS at `1e-13` and `1e-14`

## Mathematical scope

For fixed quadrature rule q=31 and fixed log population variance `v`, the
implemented row minimizes the negative marginal log-likelihood over the
remaining free coordinates from one declared anchor:

```text
h_a(v) = locally minimized_xi[-log L_q31(xi, log_sigma2 = v) | anchor a]
```

The lower finite value over the two anchors is retained as a diagnostic
envelope only:

```text
h_diag(v) = min(h_default(v), h_variance_low(v)).
```

This is not asserted to equal the global nuisance profile because two starts
cannot exclude another local basin. A returned finite value is also separated
from an existing-rule nuisance-stationarity pass. Only the latter is a
qualified local-profile point. Neither the lower finite grid endpoint nor the
upper endpoint represents the mathematical limits `v -> -Inf` or `v -> Inf`.

## Fixed finite grid

Each scenario uses ten strictly increasing values:

1. fixed small-variance tail values `-16`, `-12`, and `-8`;
2. the observed P0b `variance_low` anchor minus 0.5, at the anchor, and plus
   0.5;
3. zero, corresponding to unit population variance;
4. the midpoint between the observed low- and default-basin anchors;
5. the observed default-basin anchor; and
6. the default anchor plus four.

The scenario-specific grid hashes are:

| Scenario | Grid SHA-256 |
| --- | --- |
| `EXT5-P-HI` | `5001607cbfd96c30a619ac3f8132da4c8e9964c1e604ed30b23683a07a6c833c` |
| `EXT5-P-LO` | `699e5b85f430c0cb62a90c33eca4e4b05eb9a1d52431822ceab57eacd4f5fdc9` |
| `EXT5-P-NEAR-HI` | `992dc1bb4bfe084849c97dbdb0e0cf34d0b6e1c10be8384175c49b6ca418a6a2` |
| `EXT5-P-NEAR-LO` | `256fd03a410b3bc0e82ebfab8e61975735115f62b5c21a1fa54a49af929029b4` |

## Execution result

All 80 declared optimization rows returned finite free vectors and common
objectives. Seventy-one rows triggered polish; 19 reached an existing-rule
pass through polish, and 28 retained BFGS as their best non-objective-worsening
stage. The final pass/review/fail counts were:

| Scenario | Pass | Review | Fail |
| --- | ---: | ---: | ---: |
| `EXT5-P-HI` | 6 | 14 | 0 |
| `EXT5-P-LO` | 6 | 9 | 5 |
| `EXT5-P-NEAR-HI` | 6 | 14 | 0 |
| `EXT5-P-NEAR-LO` | 4 | 14 | 2 |

The maximum absolute difference between the analytic fixed-coordinate
derivative and its independent central difference was
`9.973169e-08`. This derivative check does not repair a row whose nuisance
gradient remains too large.

## Diagnostic finite-grid envelope

The minimum diagnostic envelope value lies at the P0b low-variance anchor in
all four cases. Those four minimum rows pass the existing nuisance optimizer
rule and are interior to this finite grid.

| Scenario | `log_sigma2` | `sigma2` | Objective | High-tail objective |
| --- | ---: | ---: | ---: | ---: |
| `EXT5-P-HI` | `-3.5065036516178312` | `0.030001627415204256` | `639.16745997775024` | `640.88733059847868` |
| `EXT5-P-LO` | `-3.5065141088028962` | `0.030001313684274500` | `639.16745997779992` | `640.88668477716635` |
| `EXT5-P-NEAR-HI` | `-3.6713342869444361` | `0.025442499693513324` | `639.81914820187637` | `643.99613024018709` |
| `EXT5-P-NEAR-LO` | `-3.6713476771952656` | `0.025442159014341593` | `639.81914820209806` | `644.00881018217774` |

The far small-variance endpoint is also worse than the diagnostic minimum:
`641.74674838903968`, `641.74675060512573`, `641.88646491930911`, and
`641.88646082957996`, respectively. Thus neither displayed finite endpoint is
the grid minimum.

This is evidence for a locally stationary finite low-variance basin under
q=31, not proof that it is the unique or global marginal-likelihood solution.
The default/high tail is especially ineligible for such an interpretation:
none of the four high-tail diagnostic rows passes nuisance stationarity. The
near-high high-tail nuisance gradient remains as large as about 1.69 after
polish; the near-low counterpart remains about 0.27.

## Reflection audit

Exact score reflection should preserve the mathematical likelihood after the
corresponding sign/step transformation. The diagnostic envelope nevertheless
retains maximum high/low objective differences of about `0.0006458213` for the
exact pair and `0.01276552` for the near pair. The low-anchor minima themselves
are much closer, but the wider curves are not numerically reflection-invariant.

The discrepancy is therefore attributed to local optimization/path quality at
this stage, not to a substantive high/low model difference and not to decimal
rounding. A tolerance is not reverse-engineered from these observed values.

## Decision

P1a produces a split decision:

- **GO, narrowly:** retain the low-variance q=31 basin as a qualified local
  candidate for a prespecified quadrature sensitivity audit;
- **NO-GO:** do not call the finite-grid envelope a global profile, do not
  select the low-variance candidate as the package result, and do not treat the
  high-variance plateau as a stationary competing solution;
- **NO-GO:** do not enter Hessian, interval, DFF, fit, or ranking inference;
  and
- **NO-GO:** do not start a broad simulation.

The next admissible slice is a bounded q=31/61/91 audit in which the qualified
low-variance basin is refit and every returned vector is reevaluated on one
common dense grid. The raw default/high-variance basin may be retained as a
diagnostic start, but it is not comparison eligible unless nuisance
stationarity is independently repaired. Finite q agreement will still not be
called a continuous-integral certificate.

## Verification

The ordinary focused suite uses a three-coordinate analytic quadratic to test
the fixed-coordinate/nuisance decomposition, dimension identity, optimizer
pass, analytic versus independent fixed derivative, qualified versus merely
finite envelope fields, typed failed rows, and decision-signature mutation.
The 80-row four-scenario calculation is explicitly opt-in through
`MFRMR_RUN_LONG_VALIDATION=true`; it is not imposed on ordinary package tests.
At the recorded source the lightweight suite reports 58 test events with one
intentional long-run skip and no failures, errors, or warnings. The complete
opt-in suite then completed 69 expectations in about 448.5 seconds with no
failure, skip, error, or warning. It returned all 80 profile rows and retained
zero authorization for boundary, continuous integration, profile selection,
general selection, or confirmation. Runtime is descriptive and is not used as
evidence of numerical or statistical validity.
