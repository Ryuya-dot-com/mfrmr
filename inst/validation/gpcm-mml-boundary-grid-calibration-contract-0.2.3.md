# GPCM MML boundary/grid retrospective calibration contract for mfrmr 0.2.3

Status: Draft.70 retrospective calibration protocol; independent confirmation,
threshold freeze, readiness propagation, and release use prohibited

## Purpose

This lane reruns the exact 40 Draft.68 MML datasets under the Draft.69 runtime
to connect three previously separate quantities:

1. stability of the fixed-quadrature marginal slope-boundary certificate at
   q=31, q=61, and q=91;
2. direct q61-to-q91 differences in structural and Person estimands; and
3. reproduction of the Draft.68 optimization and common-q91 likelihood
   results after adding post-optimization boundary instrumentation.

The datasets and their outcomes were already inspected in Draft.68. Therefore
this is retrospective calibration only. It may propose a prospective rule for
new seeds, but it cannot test, freeze, or confirm that rule.

## Frozen source panel and execution

The source panel is identified by:

- Draft.68 execution SHA-256
  `d993825cc8a58a3e3e1d17c6e4a8a6e2cc4fb16611c0429acd32296b81f70e70`;
- Draft.68 inventory SHA-256
  `7b06b49da81f40768618ab814caac39fe7d2bc53fdb43421fa24c0064ce91bb4`;
- Draft.68 aggregate RDS SHA-256
  `7753d1a886602b324cc9c6411ad61f3f00c18dda2f4920e453a16e3a3ea24c2f`;
  and
- Draft.66 owner execution SHA-256
  `f96895c9325e15390c5fd896a687a47cf786f6b4f71af94c3481753991e38037`.

The 40 datasets cross Criterion/Rater slope and step ownership, core,
weak-bridge, range-restricted, and zero-common-Person designs, and five
replicates. Each exact generated dataset is fitted at q=31, q=61, and q=91
with direct fixed-standard-normal MML, `optimizer = "auto"`, `maxit = 400`,
unchanged starts, and geometric-mean-one owner slopes. There is no adaptive
node selection, refit retry, dataset removal, or outcome-dependent stopping.

The loaded runtime hash, runner, this contract, source identities, full
manifest, controls, and non-confirmation state form one execution identity.
Atomic dataset checkpoints contain all three q arms and fail closed on any
identity, row, result, or payload mismatch. Aggregate publication requires all
40 checkpoints and a complete relative-path/SHA-256 inventory.

## Required outputs

For every q arm retain:

- fit, optimizer, evidence-readiness, warning, and error state;
- exact retained-data hash and own-grid/common-q91 likelihood;
- marginal slope-boundary audit state, completeness, quadrature scope,
  likelihood reconstruction, certified-pair count and identities, and
  readiness effect; and
- numerical slope-proposal rejection count.

For every exact dataset retain:

- equality of retained-data hashes across all three arms and against Draft.68;
- equality of the certified direction set and target status across q grids;
- direct q91-minus-q61 RMSE and maximum absolute differences for identified
  log slopes, non-Person facets, owner steps, Person EAPs, and posterior SDs;
- common-q91 q61 regret; and
- maximum own-grid and common-grid difference from the corresponding Draft.68
  result, separated from expected audit-only metadata changes.

All planned arms remain in denominators. Missing numeric values and failed
fits are counts, not silent exclusions. Zero-common-Person rows remain guarded
population-assumption controls and cannot become owner evidence.

## Interpretation limits

Certificate stability across q grids only addresses the enumerated sufficient
fixed-additive two-group path family. It does not establish a continuous-
integral path, completeness over joint coordinate movement, or a finite MLE.
If no ordinary source dataset is certified, this lane provides negative-case
reproducibility but no operating-characteristic estimate for positive-path
detection; independent challenge cells must then be added prospectively.

Direct q61-to-q91 differences are descriptive calibration quantities. Any
candidate tolerance must be declared with metric, aggregation, denominator,
Monte Carlo uncertainty, owner/design scope, and failure treatment before
new-seed execution. No single likelihood tolerance may substitute for slope,
facet, step, EAP, or posterior-SD stability.

This run cannot rank JML against MML, establish sample-size sufficiency,
promote finite optimizer slopes, validate fit or DFF cutoffs, pass a release
checklist row, or authorize confirmation.
