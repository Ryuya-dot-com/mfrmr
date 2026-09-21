# D-SIM-5 shard-executor qualification record

Date: 2026-09-01
Status: **executor qualified; full denominator authorized; execution not started**

## Result

The admission-bound executor resolves all 50 authorized shards and all 15,000
outer identities. Each job contains 300 outer attempts, 100 interval-eligible
attempts, 19,900 inner terminal identities, and 40,450 expected backend fit
calls. Qualification also routes the existing nonreserved D3-S001 generation
through the same integrated attempt function: 2 primary fits, 199 bootstrap
attempts, 398 refits, 796 finite metrics, and 4 available intervals complete
with caller RNG restoration. That shadow work uses 854100001/854900001, does
not count as a D-SIM-5 attempt, and opens no 857/858 RNG stream, planned response,
planned backend call, confirmation result, or scientific adjudication.

The runner has two explicit modes. `preflight` is the default, repeats the
nonreserved integrated qualification, and verifies its manifest. Planned
execution requires the separate command `execute D5-SHARD-NNN`; that mode
validates the saved manifest without repeating the shadow workload and was not
called for this record.

## Execution and resume semantics

- The atomic checkpoint is one complete outer attempt. A committed terminal
  checkpoint is never rerun, replaced, or replenished.
- If a process ends before that atomic commit, resume reruns the same attempt
  identity with the same 857 data seed and, where eligible, the same 858
  bootstrap seed.
- Every eligible outer attempt retains exactly 199 inner terminal receipts.
  Generation or primary-fit dependency failures create 199 explicit
  `not_attempted_*_dependency` receipts and an unavailable interval rather than
  shrinking the denominator.
- The resume planner uses only attempt/request/block/result hashes. It does not
  carry terminal states or numerical values into its remaining-work decision.
- A completed shard receipt contains all 300 ordered result hashes but keeps
  scientific adjudication and complete-denominator readiness false. Progress
  output exposes checkpoint counts and attempt IDs, not coefficients,
  intervals, or acceptance results.
- Checkpoints intentionally stop at the outer-attempt boundary. Inner-
  bootstrap checkpointing is deferred unless observed interruption cost shows
  that the additional state machinery is warranted.

## Reused statistical substrate

The executor does not introduce a new estimator. It parameterizes the existing
D-SIM-3 stochastic generator for the exact 857 identity, then reuses the
frozen D-SIM-3 separate-univariate formulas and D-study operators plus the
D-SIM-4 `simulate(..., re.form = NA)` / same-fit `refit()` / type-7 interval
procedure. The parent worker identity remains bound to R 4.6.1, Matrix 1.7.6,
and lme4 2.0.6. D-SIM-5 uses the frozen separate-univariate random-intercept
formula classes; it does not depend on the version-sensitive multivariate
random-slope representation.

The earlier nonreserved D-SIM-4 shadow run qualifies those generator, fitting,
refit, coefficient, interval, failure, and RNG-restoration components. This
record additionally runs their integrated executor composition on the same
nonreserved identity. It does not claim that the 857/858 confirmation path has
already run.

## Exact identities

- executor contract: `a64facef158aaf7f4e4463512af9b7367195f708d45183e2cd3d5d63ec9bf6f3`
- qualification manifest: `e7a6442be5c1f5f987d5f5283c380f7a07c3ff9e7aef4cc187348814067d1fa7`
- parent admission manifest: `8f13db52ad19cbe5adcda0aabb6be6ec8ff949cb555d6043ea1dba0e74972510`
- parent launch input: `e93d5de438a99d89f89d51f24c9dcd58393dc52127b90926133c7e50a0c91071`
- source SHA-256: `44ffdfda0f72c43af036f1e99187c5286adcf273d543158cd677a5f85ad07735`
- runner SHA-256: `8d4a21fee77507f9af7e916280f43e4e28e86f18c4d5f51ca77f4baaaab29b94`
- local binary SHA-256: `4803a74bc751c275666d92d4291cabf31dffaef6aaf97602b9aa11481f54fa27`

The binary is outside the package payload at
`validation-results/gtheory-multivariate-dsim5-shard-executor-0.2.4/executor-qualification-manifest.rds`.

## Claim boundary and next action

Execution is authorized but remains unstarted. Simulation validation, complete-
denominator adjudication, and public support remain false. The next state-
changing action is an intentional launch of the admitted shard set. Once that
starts, operational pauses may change timing only; no shard, attempt, seed,
failure, or interval can be removed in response to observed results, and no
scientific adjudication is permitted before all 15,000 outer attempts have one
retained terminal checkpoint.
