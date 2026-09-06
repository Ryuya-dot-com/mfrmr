# D-SIM-5 execution-admission record

Date: 2026-09-01
Status: **full denominator admitted; execution not started**

## Decision

The exact set `D5-SHARD-001`--`D5-SHARD-050` is admitted as one confirmation
denominator. All 8/8 admission criteria pass. This is an all-or-none scientific
commitment to 15,000 outer attempts, 995,000 inner bootstrap attempts, and
2,022,500 planned backend fit calls; it is not a sequence of 50 opportunities
to reconsider the design.

Partial-set authorization, sequential outcome review, outcome-based shard
cancellation, replacement, and success replenishment are prohibited. A
resource or process interruption may pause new work and resume the exact
remaining identities, but it cannot change the denominator. Scientific
adjudication requires all outer attempts to reach a retained terminal state.

## Exact identities

- contract: `f0744d6622755bd78489b81665f50d7bf3471548b426e31c22b9a32a67a838a6`
- admission manifest: `8f13db52ad19cbe5adcda0aabb6be6ec8ff949cb555d6043ea1dba0e74972510`
- parent launch input: `e93d5de438a99d89f89d51f24c9dcd58393dc52127b90926133c7e50a0c91071`
- source SHA-256: `06e87dfde86f67f6eb2a06e2d9b92eadbd67bbf7a6e7f121ca839f378e82ee84`
- runner SHA-256: `cd678738955453d4262a0350999f5681fbcd3ee4516f1e426f471966c880f5e8`
- local binary SHA-256: `e6b59fd32fb70d143894e3cbe6e992f6f22c20498bf9b13b47e3fcab46d2124c`

The local binary is outside the package payload at
`validation-results/gtheory-multivariate-dsim5-execution-admission-0.2.4/admission-manifest.rds`.

## State boundary

- all 50 shard identities execution-authorized: **yes**
- execution started: **no**
- 857/858 RNG stream opened: **no**
- response generated, backend called, or result viewed: **no**
- interim scientific adjudication allowed: **no**
- simulation validation or public support ready: **no**

The next bounded task is one admission-bound shard executor with exact
checkpoint/resume and terminal-attempt accounting. It must not contain a
result-dependent branch that can alter the authorized shard set.
