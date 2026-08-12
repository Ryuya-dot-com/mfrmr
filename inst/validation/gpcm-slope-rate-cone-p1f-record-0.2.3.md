# GPCM lower-boundary slope-rate cone P1f record (0.2.3)

## Scope and correction

P1f classifies the linear slope-rate geometry that can retain finite random
coefficients while the MML population standard deviation tends to zero. It
also derives a canonical reduced likelihood with a free positive coefficient
for every retained criterion. This is an analytic and implementation gate,
not a global joint-boundary certificate.

The audit corrects the scope of P1e. P1e optimized its nuisance coordinates
conditional on the path constants
`lambda_c = a_c(0) * sigma(0)`. It did **not** optimize `lambda_c` and therefore
did not optimize the entire C4 target face. Its conclusion that the declared
C4 limit lay above the qualified interior remains valid for that fixed-
coefficient path only.

Frozen status remains:

- `AllTargetSetsOptimized = FALSE`;
- `NoRandomProductStratumClassified = FALSE`;
- `GlobalJointBoundaryProfileCertified = FALSE`;
- `SelectionAuthorized = FALSE`;
- `ConfirmationAuthorized = FALSE`.

## Rate-simplex derivation

Write

```text
sigma(t) = sigma_0 exp(-s t),       s > 0,
a_c(t)   = a_c0 exp(r_c t).
```

Geometric-mean-one slope identification implies
`sum_c r_c = 0`. A random coefficient `a_c(t) sigma(t)` cannot remain finite
when `r_c > s`. Normalize by `u_c = r_c / s`. The finite-random-coefficient
rate set is

```text
sum_c u_c = 0,        u_c <= 1.
```

For `J` criteria, set

```text
w_c = (1 - u_c) / J,        u_c = 1 - J w_c.
```

Then `w_c >= 0` and `sum_c w_c = 1`. This is an affine bijection to the
standard simplex. It also supplies the implicit lower bound
`u_c >= -(J - 1)`. The rate-simplex vertices have one rate `-(J - 1)` and all
other rates equal to 1.

The retained random target set is

```text
T = {c : u_c = 1} = {c : w_c = 0}.
```

Every nonempty proper subset is feasible. For four criteria there are
`2^4 - 2 = 14` such sets: four single-target two-dimensional faces, six
two-target one-dimensional faces, and four three-target vertices. P1e's rate
allocation `( -1/3, -1/3, -1/3, 1 )` is the barycenter of the C4 face, not a
rate-simplex vertex.

## Canonical reduced likelihood

For `c` in a nonempty target set `T`, define the finite coefficient

```text
lambda_c = lim a_c sigma > 0.
```

After scaling target locations, rater severities, and steps by `sigma`, the
target-category log numerator is

```text
lambda_c [ k (u_c - q_r + z) - H_ck ],       z ~ N(0, 1).
```

For `c` outside `T`, its random and rater terms vanish under this stratum and
its separately slope-scaled deterministic log numerator is

```text
k v_c - G_ck.
```

P1f implements the personwise marginal likelihood and its analytic gradient
for rater coordinates, target/non-target locations, steps, and free
`log(lambda_c)`. The free dimension in the declared fixture is `20 + |T|`.
This representation depends on the target set but not on the exact
sub-target rates within the corresponding simplex-face relative interior.

The empty target set is deliberately excluded. When every `a_c sigma`
vanishes, a second rate hierarchy can still retain deterministic rater terms
for criteria with maximal slope rate. That no-random-product stratum requires
its own classification; treating it as the target-free version of the above
formula would be incomplete.

## P1e nested-identity check

The exact coordinate conversion from the P1e C4 fixed-coefficient model to
the P1f canonical C4 model was evaluated for all four scenarios, both routes,
and q=61/91/121.

- all 8 nested evaluations were finite;
- maximum P1e/P1f objective difference: `1.1368683772161603e-13`;
- maximum q=61/91/121 objective range: `3.4106051316484809e-13`;
- maximum analytic/numeric full-gradient difference:
  `1.5029015623995812e-07`;
- fixed `lambda_C4` range: `0.14785433280326632` to
  `0.17382307186384569`.

The newly exposed free-`log(lambda_C4)` objective gradients range from
`2.4154029764739540` to `2.8905968965106825`. They are far larger than their
analytic/numeric discrepancies. A signed `0.001` probe in the derivative's
descent direction reduces the objective by `0.0024128886881271683` to
`0.0028875848278175908` across the eight evaluations. Therefore every P1e
terminal point is resolved as nonstationary in the free face-coefficient
direction. This does not prove that the optimized C4 face beats the interior;
it proves that P1e did not answer that question.

## Decision and next gate

P1f establishes the following:

1. the finite-random-product linear rate set is a standard simplex under an
   exact affine change of coordinates;
2. all 14 nonempty proper target faces are enumerated;
3. one canonical reduced likelihood with free positive target coefficients is
   derived and independently differentiated;
4. P1e is recovered exactly as a fixed-coefficient single-target submodel;
5. P1e's fixed coefficient is not stationary when released.

P1f does not establish the following:

- no target face has yet been optimized from multiple starts;
- the no-random-product deterministic-rater hierarchy is not classified;
- paths without a limiting linear rate vector are not classified;
- the upper/joint population-variance boundary is not evaluated;
- no source solution, Hessian, interval, DFF, fit, rank, separation, or broad
  simulation analysis is authorized.

The next efficient gate is therefore multistart optimization of the 14
canonical target-face likelihoods, beginning with the now-corrected C4 face
and then exploiting nested-face warm starts. The empty-target hierarchy
remains a separate lower-boundary gate. This ordering tests the newly exposed
direction before adding a general multidimensional search.

## Reproduction

Runner:

```text
inst/validation/gpcm-slope-rate-cone-p1f-0.2.3.R
```

Test:

```text
tests/testthat/test-gpcm-slope-rate-cone-p1f.R
```

Frozen SHA-256 values:

- runner:
  `01e6b04af33565a4dc350fdd24285e619a5cc2cbaec35f8ce5d2ab49d99d59d9`;
- test:
  `394ada837fe5831d2d45915aca497ca7ed8d4ab082077c00235cd31e8fb3b5e0`.

The recorded execution used the frozen P1e result only as a dependency
payload; all P1f likelihoods and gradients were recomputed.

The focused lightweight test reports 61 passed expectations and one
intentional dependency-complete skip. With
`NOT_CRAN=true MFRMR_RUN_LONG_VALIDATION=true`, the final test rebuilds the
P0--P1e dependency chain and reports 73 passed expectations with no failure,
error, warning, or skip. Documentation terminology, first-use readiness,
readiness propagation, release readiness, and results readiness regression
tests also pass; the first-use suite emits its prespecified sparse-category
review warning. Runtime is descriptive and does not enter any statistical
decision.
