# GPCM coordinate-scaled joint-limit P1e record for 0.2.3

Status: completed deterministic calibration, 2026-08-12.
Contract: `mfrmr_gpcm_coordinate_scaled_joint_limit_p1e_v1`.
Specification: `0.2.3-draft.1`.

P1d showed that the observed Criterion C4 joint lower-boundary ray is coherent
under q=61/91/121 evaluation but becomes nonstationary in the package's raw
free coordinates. P1e asks whether that failure reflects the likelihood or the
mixed coordinate rates forced by the joint limit. It supplies an exact
finite-`t` affine reparameterization and a separately derived direct
`t = Inf` reduced likelihood. The result adjudicates this declared C4 ray only;
it does not profile asymmetric or curved slope-rate paths, the upper variance
boundary, or select a package solution.

## Execution identity

- branch: `development/0.2.3`
- parent commit: `23ff1da207a6c913e88848f2d8860dd53d4f558c`
- source-tree version: `0.2.3`
- P1e runner: `gpcm-coordinate-scaled-joint-limit-p1e-0.2.3.R`
- P1e runner SHA-256:
  `38a931ab9f2de9e8c48579f4fd1bf356f013d2e14c9dc7c7993d9b2e0691915f`
- P1e test: `test-gpcm-coordinate-scaled-joint-limit-p1e.R`
- P1e test SHA-256:
  `f09071f6bd1054864e2c6d25146ee7730a123ede16a4e75472caa7ed89473a98`
- P1d dependency contract:
  `mfrmr_gpcm_zero_variance_log_slope_path_p1d_v1`
- P1d dependency SHA-256:
  `5480c1e9c1ff04e208df9e375dd54b99395b25df28b11b5ba96625259338af51`
- finite transformed points: `t = 4, 6, 8, 10`
- starts: P1d forward and reverse route vectors
- finite and limit optimization quadrature: q=121
- same-vector evaluation quadrature: q=61, 91, and 121
- optimization controls: `maxit = 800`, `reltol = 1e-12`
- independent transformed-gradient step: `1e-6`

## Why the raw coordinates become stiff

The declared P1d ray uses, for `J = 4` criteria,

```text
epsilon = exp(-t),               rho = exp(-t / 3),
sigma(t) = sigma0 epsilon,
a_4(t) = a_4(0) / epsilon,
a_c(t) = a_c(0) rho,             c != 4.
```

The implemented GPCM category numerator for criterion `c` is

```text
a_c [k eta - Delta_c,k],
```

where `Delta_c,k` is a cumulative step and, in this fixture,

```text
eta = beta - Rater - Criterion + sigma Z.
```

For C4 logits to remain finite, its mean location, Rater effects, and steps
must be of order `epsilon`. For C1--C3 logits to retain information while their
slopes vanish, their criterion-specific mean locations and steps may be of
order `1 / rho`. A single raw vector therefore contains coordinates shrinking
as `exp(-t)` alongside coordinates growing as `exp(t/3)`, plus a population
intercept and sum-zero Criterion facets that cancel to produce each
criterion-specific mean. An absolute gradient threshold in those raw
coordinates is not scale neutral.

## Exact finite reparameterization

Define the criterion-specific mean location

```text
x_c = beta - gamma_c,
```

where the identified Criterion facets satisfy `sum(gamma_c) = 0`. The inverse
map is exact:

```text
beta = mean(x_c),                 gamma_c = beta - x_c.
```

P1e optimizes finite transformed coordinates

```text
U_4 = x_4 / epsilon,              U_c = rho x_c,       c != 4,
Q_r = Rater_r / epsilon,
H_4 = step_4 / epsilon,           H_c = rho step_c,    c != 4.
```

At every finite `t`, this is an affine, rank-20 map into the 20 nuisance
coordinates left after fixing three identified log slopes and one log
variance. The raw model, constraints, objective, and q=121 integration are
unchanged. Across all 32 fitted points, the maximum nuisance round-trip error
is `1.3878e-17`. The analytic transformed gradient is the exact chain-rule
product `J' grad_raw`; its maximum discrepancy from an independent central
difference is `2.1979e-7`.

All 32 transformed fits pass the existing numerical threshold on the
transformed scale. Only one of the same 32 returned vectors passes that
absolute threshold in raw nuisance coordinates. At `t = 10`, transformed
gradient maxima remain below `9.95e-5`, while raw nuisance maxima range up to
`1.3963`. This does not make stationarity mathematically coordinate-dependent:
the exact zero-gradient condition is invariant under every finite nonsingular
map. It shows that a finite stopping threshold applied to an increasingly
ill-conditioned raw map is coordinate-dependent and cannot adjudicate this
limit by itself.

Same-vector finite q=61/91/121 objective ranges remain at most
`1.7167e-11`, matching P1d. The transformed estimates approach the direct
limit monotonically in absolute objective difference:

| `t` | Exact finite minus limit | Near finite minus limit |
| ---: | ---: | ---: |
| `4` | about `-3.1473e-2` | about `-2.4066e-2` |
| `6` | about `-2.1841e-3` | about `-1.6695e-3` |
| `8` | about `-1.5174e-4` | about `-1.1599e-4` |
| `10` | about `-1.0544e-5` | about `-8.059e-6` |

Both forward and reverse starts give the same pattern. No observed difference
is converted into a general solution tolerance.

## Direct reduced-limit likelihood

Substituting the transformed coordinates and taking `t -> Inf` gives the C4
logits

```text
a_4(0) [k {U_4 - Q_r + sigma0 Z} - cumulative(H_4)],
```

so C4 retains both Rater and latent-normal variation. For `c != 4`, the limit
is

```text
a_c(0) [k U_c - cumulative(H_c)].
```

The non-target criteria become independent of Rater and latent person
variation on this ray. P1e reconstructs observation probabilities, personwise
quadrature aggregation, posterior node weights, and the analytic gradient of
this reduced likelihood independently of the raw finite model.

All eight direct-limit optimizations return and pass the existing numerical
rule. Analytic/numeric limit-gradient discrepancies are at most `1.7866e-7`.
The q=61/91/121 objective range is at most `3.4107e-13`. Forward/reverse route
objective differences are also at most `3.4107e-13`.

| Scenario | Direct limit objective | Interior objective | Limit minus interior |
| --- | ---: | ---: | ---: |
| `EXT5-P-HI` | `643.321752886878` | `639.167459977714` | `4.154292909164` |
| `EXT5-P-LO` | `643.321731026340` | `639.167459977761` | `4.154271048579` |
| `EXT5-P-NEAR-HI` | `643.198762978237` | `639.819148201874` | `3.379614776362` |
| `EXT5-P-NEAR-LO` | `643.198713635438` | `639.819148202090` | `3.379565433348` |

The table uses one displayed value per scenario because the two route values
agree to floating-point precision. Every direct C4-ray limit is worse than the
qualified interior candidate.

## Decision

P1e changes the interpretation of P1d without widening the package claim:

- **implemented:** an exact finite coordinate transform with rank and
  round-trip checks;
- **implemented:** an independently coded direct reduced-limit likelihood and
  analytic gradient;
- **supported locally:** all 32 finite transformed fits and all eight direct
  limit fits pass their declared numerical rules;
- **supported locally:** two starts agree and the direct C4-ray limit is
  3.38--4.15 objective units worse than the qualified interior candidate;
- **adjudicated only for this ray:** the symmetric one-dominant C4 joint limit
  is locally noncompetitive with the interior candidate;
- **NO-GO:** this result cannot be generalized to asymmetric rate allocations,
  multiple growing slopes, curved paths, or other target sets;
- **NO-GO:** the global lower joint boundary, upper variance boundary, and
  source-solution rule remain unresolved; and
- **NO-GO:** Hessian, interval, DFF, fit, rank, separation, and broad
  simulation remain downstream.

All four decisions are
`declared_c4_ray_two_route_stationary_limit_above_interior`. Reflection-pair
signatures remain invariant. `SelectionAuthorized` and
`ConfirmationAuthorized` remain false throughout.

The next efficient slice is a rate-cone audit, not another arbitrary `t` grid.
Under sum-zero log-slope identification, enumerate the finitely distinct
asymptotic target sets and extreme rate allocations that can retain one or
more `a_c sigma` products. Derive the corresponding reduced likelihoods before
running them. This can determine whether the observed C4 ray is representative
without turning the task into a broad simulation. The upper/joint variance
path remains separate and later.

## Verification

The ordinary focused suite pins the P1d dependency and P1e runner; checks the
rate contract, stable softmax, missing-route behavior, local-only decision,
and signature mutation; and keeps dependency-complete execution opt-in through
`MFRMR_RUN_LONG_VALIDATION=true`. The P1e layer contains 32 finite transformed
fits, eight direct-limit fits, four route comparisons, four decisions, and two
reflection comparisons. With a recorded P1d result supplied, the P1e layer
took about 37.3 seconds. The lightweight suite reports 45 passed expectations
with one intentional long-run skip. The complete dependency-rebuilding suite
reports 72 passed expectations with no failure, error, warning, or skip.
Runtime is descriptive only.
