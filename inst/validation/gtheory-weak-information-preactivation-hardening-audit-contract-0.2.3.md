# Weak-information pre-activation hardening audit contract

## Identity

- Version: `0.2.3-draft.83d2b2b1g16`
- Scope: repository-internal G-theory weak-information numerical calibration
- Upstream authorization-preflight contract:
  `44a6d4e2677af111e6eeeae8b7b3143ce8521db34da1769a86b85f32c63ca551`
- Upstream prospective shard bundle:
  `dfd5099b84dc8ff64b605261d957173e63b8b04645b1f90cc7262b8120d54e82`
- Upstream Monte Carlo value contract:
  `9695149f99885bd4647c40466fef37e99cf321aa7786e232476586730f4fa1d8`
- Upstream Monte Carlo value audit:
  `67987463d2fa587441714da5b6a8fc9046f6c2cc3ec604a416a264762d868f45`
- Hardening policy:
  `dc3fb20ef72d64842b1fed7273ebcaa6b2bd794b8757f59ccea03a4d3e945c3c`
- Hardening contract:
  `9ea428bfec87509cacdadba6250d837aef5090c07550f2c0603b79164f2c58c0`

## Purpose

Draft.83d2b2b1g15 established that the filesystem, capacity, prospective shard
partition, and conservative runtime plan were adequate at one preflight
snapshot. Draft.83d2b2b1g15a established that 3,000 independent datasets are
proportionate for numerical-rule calibration, but not for broad operating-
characteristic claims. Neither result proves that an authorized multi-process,
multi-day execution is deterministic or single-writer safe.

Draft.83d2b2b1g16 therefore adds a stronger, response-free pre-activation
audit. A successful audit is not an authorization. Any unresolved required
gate makes `AuthorizationActivationEligible`, `LargeSimulationMayStart`, and
`Replicate201MayBeOpened` false.

## Source basis

- R's random-number documentation states that `set.seed()` can receive the
  uniform, normal, and sample RNG kinds and recommends explicit kinds for
  later reproducibility:
  <https://stat.ethz.ch/R-manual/R-devel/library/base/help/Random.html>.
- `sessionInfo()` exposes RNG kind, matrix-product mode, BLAS, LAPACK, locale,
  and timezone in addition to R and package versions:
  <https://stat.ethz.ch/R-manual/R-devel/library/utils/html/sessionInfo.html>.
- `Rscript --vanilla` supplies the no-environment, no-site-profile,
  no-user-profile, and no-restore startup boundary required by this contract:
  <https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html>.
- glmmTMB exposes optimizer parallelism through `glmmTMBControl(parallel=)`;
  thread count is therefore an execution input, not merely a performance
  detail: <https://glmmtmb.github.io/glmmTMB/articles/parallel.html>.
- Atomic checkpoint installation continues to require a checked same-directory
  `file.rename()`:
  <https://stat.ethz.ch/R-manual/R-devel/library/base/html/files.html>.

## Frozen checks

### Seed ledger

The ledger enumerates scenario-replicate datasets only; it does not generate
responses. The exact phase counts are:

| Phase | Datasets | Replicate band |
|---|---:|---:|
| schema smoke | 6 | 2--3 |
| feasibility | 750 | 101--125 |
| calibration | 3,000 | 201--300 |
| confirmation | 6,000 | 501--700 |
| total | 9,756 | phase-specific |

The schema smoke contains three baseline control scenarios, not all 30
scenarios. Across the actual 9,756 phase-specific rows, all 9,756 integer seeds
are unique. Calibration and confirmation seed sets are disjoint. This check
does not open any response.

### Ambient-RNG negative control

The exact nonreserved scenario
`GT-WI-baseline_complete-exact_zero/R0901` is generated twice with the same
integer seed. The only intended change is the ambient uniform RNG:
`Mersenne-Twister` versus `Wichmann-Hill`; normal and sample kinds remain
`Inversion` and `Rejection`.

The current generator calls `set.seed(seed)` without explicit RNG kinds and
does not record `RNGKind` in its generator identity. The two generated score
vectors and generator hashes differ. This is a deliberate negative result:
the current generator is seed-indexed but not self-contained with respect to
the R session's RNG configuration.

### Extended runtime identity

The b1g14 runtime identity includes R version, platform, architecture, OS,
package versions, and their hash. It does not bind the following fields now
required before activation:

- RNG kind;
- matrix-product mode;
- BLAS and LAPACK libraries and LAPACK version;
- locale and timezone;
- glmmTMB parallel-control state; and
- numerical-library thread environment.

The current host happens to report the required three-part RNG kind and
`glmmTMBControl()$parallel == list(n=1L, autopar=FALSE)`. That observation is
not an authorization-bound guarantee. The relevant thread environment is also
unset rather than explicitly serial.

### Execution-path requirements

Before authorization, the reserved runner must add all of the following:

1. an isolated `Rscript --vanilla` process with explicit locale, timezone,
   RNG, glmmTMB, and numerical-library thread state;
2. a content-addressed authorized runner that accepts only one exact b1g15
   prospective shard hash;
3. an exclusive single-writer lock; automatic stale-lock takeover is
   prohibited;
4. an atomically installed activation marker that distinguishes first
   activation from exact resume and rejects an unmarked existing root;
5. a fresh same-directory write/rename/readback probe and remaining-capacity
   check before every shard; and
6. the existing complete-denominator, typed-failure, no-early-stopping, and
   confirmation-isolation rules.

## Current gate result

The seed, shard, denominator, and confirmation gates pass. Eight required
gates do not:

- `RNG-01`: generator RNG self-containment;
- `RUNTIME-01`: authorization-bound extended runtime;
- `THREAD-01`: explicit serial thread state;
- `PROCESS-01`: isolated vanilla process;
- `RUNNER-01`: reserved-only authorized runner;
- `LOCK-01`: exclusive single-writer lock;
- `ROOT-01`: activation marker and typed resume-root lifecycle; and
- `CAPACITY-01`: per-shard filesystem and capacity recheck.

The historical b1g15 readiness result remains valid for the narrower checks it
performed, but its activation-eligibility conclusion is superseded by this
stronger audit. No authorization record is issued. Calibration replicates
201--300 and confirmation replicates 501--700 remain sealed.

The observed extended-runtime hash and the full audit hash are intentionally
site snapshots: a test harness may alter otherwise legitimate session state.
They do not enter the portable contract hash. The portable blocker decision
has its own hash and the activation runner must compare a fresh site snapshot
against a separately frozen required-runtime identity.

## Required repair order

1. Make the generator set all three RNG kinds explicitly and record them in
   generator identity.
2. Because that changes a hashed scientific dependency, rebuild and re-run the
   downstream nonreserved adapter/reference/preflight chain rather than
   editing old hashes in place.
3. Freeze the extended runtime/process contract and implement lock, activation
   marker, typed resume, and per-shard preflight mechanics.
4. Exercise contention, stale-lock, wrong-root, runtime-drift, RNG-drift,
   capacity-loss, corrupted-checkpoint, and confirmation-access negative
   controls using temporary or nonreserved fixtures.
5. Only after every gate passes may a separate immutable authorization record
   be considered. This contract itself can never authorize execution.
