# GPCM zero-population-variance P1c record for 0.2.3

Status: completed deterministic calibration, 2026-08-12.
Contract: `mfrmr_gpcm_zero_variance_boundary_p1c_v1`.
Specification: `0.2.3-draft.1`.

P1b established that one low-population-variance local GPCM-MML basin is
coherent across q=31, 61, and 91 under a held-out q=121 evaluator. P1c asks the
logically prior question of what happens at the exact `sigma2 = 0` boundary.
It implements the fixed-nuisance likelihood limit, locally refits nuisance
coordinates from three declared starts, and retains a one-sided positive-
variance path. It does not certify a global boundary profile, the upper or
joint variance boundary, a solution tolerance, a selected package solution,
Hessian inference, DFF, fit, rank, separation, simulation, or capability.

## Execution identity

- branch: `development/0.2.3`
- parent commit: `1f8e30b1fad318c8542482a8e26111bf7723c3f3`
- source-tree version: `0.2.3`
- P1c runner: `gpcm-zero-variance-boundary-p1c-0.2.3.R`
- P1c runner SHA-256:
  `9feeabfc715d32bc7056e116c58273dcc82363e2111363c1df42d485f6afd8f5`
- P1c test: `test-gpcm-zero-variance-boundary-p1c.R`
- P1c test SHA-256:
  `bf8ddcbb0c37f8cd98286f4f9d14e50d17bd7f5d1dc1f3c046882dcfe869586e`
- P1b dependency contract:
  `mfrmr_gpcm_low_basin_quadrature_p1b_v1`
- P1b dependency SHA-256:
  `80a53048c687d10011bdf9a5e389abc9b29458b60277ec28e75ad94a05aafd9a`
- boundary quadrature: q=1
- interior comparator: independent q=61 refit, evaluated again at q=121
- boundary starts: P0b `variance_low`, P0b `default`, and an all-zero
  identified nuisance vector
- requested boundary controls: L-BFGS-B plus the existing objective-
  nondegrading polish ladder, `maxit = 800`, `reltol = 1e-12`
- natural-variance path: 11 fixed values from `1e-2` through `1e-8`, q=121
- derivative audit: the previously declared P0b relative-step ladder
  `1e-5`, `1e-6`, `1e-7`, `1e-8`, and `1e-9`

## Exact fixed-nuisance limit

For Person `p`, fixed nuisance vector `eta`, population mean `mu_p`, and
natural residual variance `v`, write the marginal response likelihood as

```text
m_p(v; eta) = E[L_p(mu_p + sqrt(v) Z; eta)],   Z ~ N(0, 1).
```

The finite-category GPCM response likelihood is continuous in theta and lies
between zero and one. Dominated convergence therefore gives, for fixed finite
nuisance coordinates,

```text
lim_{v -> 0+} m_p(v; eta) = L_p(mu_p; eta).
```

The package's standard-normal q=1 Gauss-Hermite rule has exactly one node at
zero with weight one. It consequently evaluates the degenerate likelihood on
the right-hand side exactly. This statement concerns the likelihood at fixed
nuisance coordinates. It does not imply interchange of limit and global
nuisance optimization, nor existence of a finite nuisance maximizer at the
boundary.

P1c also reconstructs the q=1 objective independently from the conditional
GPCM log likelihood, using the population design matrix, beta, additive
facets, steps, and expanded positive slopes directly. Across all 12 returned
boundary vectors, the q=1 objective is invariant when the otherwise irrelevant
`log_sigma2` placeholder is changed among `-32`, `0`, and `32`. The maximum
q=1 versus direct-oracle difference is `1.7054e-12`.

## Boundary nuisance result

All 12 declared boundary optimizations returned finite vectors. None passed
the existing nuisance-stationarity rule, so none enters the boundary
comparison denominator and no diagnostic boundary envelope is selected.

| Scenario | Boundary objective range | Nuisance gradient range | Maximum returned slope | Maximum returned slope ratio |
| --- | ---: | ---: | ---: | ---: |
| `EXT5-P-HI` | `641.7459191`--`641.7519238` | `0.002071`--`0.014369` | `1481.49` | `4.07e4` |
| `EXT5-P-LO` | `641.7457396`--`641.7458465` | `0.004255`--`0.008958` | `1363.52` | `6.77e4` |
| `EXT5-P-NEAR-HI` | `641.8847183`--`642.2519466` | `0.001285`--`0.175417` | `36531.50` | `1.58e17` |
| `EXT5-P-NEAR-LO` | `641.8847308`--`642.2635551` | `0.001363`--`0.178290` | `15779.64` | `9.18e15` |

These slope magnitudes are observables, not a frozen slope-boundary cutoff.
They nevertheless explain why increasing the iteration ceiling alone is not a
sound repair: in a representative exact-high zero-nuisance run, raising
`maxit` from 800 to 3000 returned the same objective and gradient after the
same precision-limited polish sequence. The expanded slopes there were about
`0.867`, `0.123`, `0.117`, and `79.99`.

The independent derivative ladder is retained rather than choosing one
favorable finite-difference step. The minimum analytic/numeric maximum
difference by returned vector ranges from about `1.58e-7` to `1.76e-4`.
Large-step discrepancies become enormous for the stiffest default-start
traces, while smaller steps can enter subtraction noise. The analytic
gradients remain above the existing stationarity threshold regardless; the
derivative ladder is therefore diagnostic and does not rescue a boundary
candidate.

## Interior and one-sided path evidence

The four independent q=61 `variance_low` refits reproduce the qualified P1b
interior lane. All four pass the existing native rule and remain finite at
q=121:

| Scenario | q=121 objective | Population `sigma2` |
| --- | ---: | ---: |
| `EXT5-P-HI` | `639.1674599777135` | `0.0300016285502387` |
| `EXT5-P-LO` | `639.1674599777607` | `0.0300013169475722` |
| `EXT5-P-NEAR-HI` | `639.8191482018740` | `0.0254424999483555` |
| `EXT5-P-NEAR-LO` | `639.8191482020902` | `0.0254421640013987` |

At each returned zero-boundary nuisance trace, q=121 was also evaluated while
holding nuisance fixed and increasing natural variance along the declared
ladder. All displayed difference quotients are positive. This fixed-nuisance
path cannot be interpreted as selecting the zero boundary: every source trace
is nonstationary, several slopes are extreme, and the separately reoptimized
interior basin has a lower objective. The combination is evidence of
basin/joint-boundary competition, not a regular one-dimensional variance
profile. Consequently P1c deliberately leaves all boundary-versus-interior
objective fields `NA` in the decision table rather than comparing an
ineligible boundary trace with a qualified interior candidate.

## Decision

P1c produces a split but fail-closed conclusion:

- **implemented:** the fixed-nuisance `sigma2 -> 0+` likelihood limit is exact
  under q=1 and agrees with an independent conditional-GPCM oracle;
- **NO-GO:** none of the 12 finite boundary nuisance traces is stationary, so
  none is a local boundary-profile candidate or a valid likelihood-ratio
  denominator;
- **NO-GO:** observed large and highly start-sensitive slopes are not relabelled
  as a certified slope boundary without an explicit joint path;
- **NO-GO:** the qualified finite interior basin is not selected as the package
  solution while the zero-variance-by-slope and upper/joint variance paths are
  unresolved; and
- **NO-GO:** Hessian, interval, DFF, fit, rank, separation, and broad simulation
  remain downstream of source-solution adjudication.

The next admissible slice is a small, prespecified joint
`sigma2 -> 0`/log-slope path audit using the exact q=1 oracle and the observed
expanded-slope geometry. It should ask whether a nonattained joint boundary
improves or only approaches the finite boundary traces. It must remain
separate from the upper-variance joint path and must not infer a universal
slope cutoff from the values observed here.

## Verification

The ordinary focused suite pins the P1b dependency and P1c runner; checks the
q=1 node/weight and dominated-convergence scope; enforces boundary-envelope
eligibility, missing-arm pairwise behavior, candidate-absent decision logic,
and exact signature mutation; and leaves the four-scenario execution opt-in
through `MFRMR_RUN_LONG_VALIDATION=true`. The lightweight suite reports 53
passed expectations with one intentional long-run skip and no failure, error,
or warning. The complete opt-in suite reports 72 expectations in about 86.8
seconds with no failure, skip, error, or warning. It retains
`UpperVarianceJointPathStatus = not_evaluated`,
`SolutionToleranceStatus = not_frozen`, `SelectionAuthorized = FALSE`, and
`ConfirmationAuthorized = FALSE`. Runtime is descriptive only.
