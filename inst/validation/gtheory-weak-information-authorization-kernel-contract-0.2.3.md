# Weak-information authorization-kernel contract

## Identity

- Version: `0.2.3-draft.83d2b2b1g20`
- Parent b1g19 lineage receipt:
  `4a453c9b44fd03ae456ba1fda2f8d65208c3ab63b23c6c51d1f6026dfe3e4e92`
- Kernel policy:
  `ca0b9691600d4aa1241741cb0fa8710de1ea892a8e243c323425c6b76047136c`
- Kernel contract:
  `86a6015b1eebdb4c9cf8cfa57110d24354ec5999e62f477c82506d8cc6b1edce`
- Isolated worker source:
  `6c1138afe41995a7a14fdb1fa6bf91e62cc4b667187a18f21bdf2a52860959f0`

## Architectural decision

b1g20 stops decomposing preauthorization into progressively smaller evidence
slices. The remaining reusable infrastructure is consolidated into one kernel
with three services:

1. an isolated `Rscript --vanilla` runtime with explicit RNG, locale,
   timezone, glmmTMB parallel control, and numerical-library thread state;
2. an atomic directory lock and activation-marker state machine that
   distinguishes initial activation from exact resume and rejects unmarked
   roots; and
3. a fresh same-directory write/rename/readback and remaining-capacity probe.

Seed uniqueness, complete-denominator accounting, confirmation exclusion, and
hardened manifest lineage are not reimplemented. Their existing frozen
receipts are inputs. This keeps the kernel reusable for future numerical
calibration, G-theory recovery, bootstrap, and other checkpointed simulation
runs without turning it into a model-specific workflow engine.

## Portable and site-specific identity

The worker canonicalizes its invocation by retaining `--vanilla` and the
worker basename while replacing the temporary receipt path. The isolated
runtime hash is therefore reproducible across probe calls. It binds:

- R, platform, operating-system, BLAS/LAPACK, and matrix-product identity;
- exact package versions;
- `Mersenne-Twister` / `Inversion` / `Rejection` RNG kinds;
- `LC_ALL=C` and `TZ=UTC`;
- suppressed user environment/profile startup;
- glmmTMB `n=1`, `autopar=FALSE`; and
- `OMP`, OpenBLAS, MKL, Accelerate, and BLIS thread counts fixed to one.

Available bytes and raw `df -Pk` output are site snapshots and do not enter the
portable contract hash. Capacity must be rechecked immediately before every
future shard against the conservative 47,775,834,368-byte requirement.

## Lock and root semantics

Lock acquisition uses atomic directory creation. A second acquisition fails;
automatic stale-lock takeover is forbidden. A held lock owns an exact marker,
and release fails if that marker changes.

The first activation creates a root and atomically installs a marker binding
manifest, runtime, and policy hashes. A subsequent call is an exact resume
only when the marker agrees. A pre-existing unmarked root and a changed marker
fail closed. These mechanics are tested only in disposable fixture roots;
b1g20 never creates the reserved output root.

## Gate reduction and non-authorization boundary

The response-free preflight passes nine shared infrastructure gates:
`RNG-01`, `LINEAGE-01`, `RUNTIME-01`, `THREAD-01`, `PROCESS-01`, `LOCK-01`,
`ROOT-01`, `CAPACITY-01`, and `CONFIRM-01`.

Two scientifically material gates remain:

- `RUNNER-01`: a reserved-only candidate/reference runner must bind one exact
  shard, runtime receipt, lock, activation marker, and complete denominator;
- `AUTH-RECORD-01`: a separate immutable record must authorize that exact
  runner and one shard only after all negative controls pass.

`AuthorizationKernelReady=TRUE` means only that the reusable infrastructure is
ready. The kernel cannot generate responses, fit models, issue an
authorization record, open replicate 201, or access confirmation data.
`AuthorizationRNG01Closed`, `AuthorizationActivationEligible`, and
`LargeSimulationMayStart` remain false.

## Priority and stopping rule

No additional preauthorization abstraction layer should be added unless a new
failure mode cannot be represented by this kernel. The next implementation is
the actual guarded single-shard runner, exercised first on nonreserved data.
Only its passing contention, drift, marker-corruption, capacity-loss,
complete-denominator, and confirmation-access controls justify a separate
authorization decision.

After numerical-rule calibration, development priority returns to scientific
claims: freeze the stationarity rule, validate G-study/D-study component and
coefficient recovery, implement full-refit uncertainty, and only then promote
crossed/nested or multivariate public support. Runtime infrastructure must not
be allowed to displace those estimand and operating-characteristic goals.
